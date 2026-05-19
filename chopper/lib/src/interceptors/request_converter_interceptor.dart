import 'dart:async';
import 'dart:collection';

import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:meta/meta.dart';

part 'request_converter_interceptor_frames.dart';
part 'request_converter_interceptor_conversion_result.dart';

/// {@template RequestConverterInterceptor}
/// Internal interceptor that converts query parameters with
/// [_parameterConverter], then handles request conversion provided by
/// [_requestConverter] or [_converter].
///
/// Query parameters are converted before user request interceptors and request
/// stream events see the request.
/// {@endtemplate}
class RequestConverterInterceptor implements InternalInterceptor {
  /// {@macro RequestConverterInterceptor}
  RequestConverterInterceptor(
    this._converter,
    this._requestConverter, [
    this._parameterConverter,
  ]);

  /// Converter to be used for request conversion.
  final Converter? _converter;

  /// Request converter to be used for request conversion.
  final ConvertRequest? _requestConverter;

  /// Parameter converter to be used for query parameter conversion.
  final ParameterConverter? _parameterConverter;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async => await chain.proceed(
    await _handleRequestConverter(chain.request, _requestConverter),
  );

  /// Converts the [request] using [_requestConverter] if it is not null, otherwise uses [_converter].
  Future<Request> _handleRequestConverter(
    Request request,
    ConvertRequest? requestConverter,
  ) async {
    final Request requestWithConvertedParameters = _convertQueryParameters(
      request,
    );

    return requestWithConvertedParameters.body != null ||
            requestWithConvertedParameters.parts.isNotEmpty
        ? requestConverter != null
              ? await requestConverter(requestWithConvertedParameters)
              : await _encodeRequest(requestWithConvertedParameters)
        : requestWithConvertedParameters;
  }

  /// Encodes the [request] using [_converter] if not null.
  Future<Request> _encodeRequest(Request request) async =>
      _converter?.convertRequest(request) ?? request;

  Request _convertQueryParameters(Request request) {
    final ParameterConverter? converter = _parameterConverter;

    if (converter == null || request.parameters.isEmpty) {
      return request;
    }

    final _ConversionResult result = _convertQueryParameterMap(
      request.parameters,
      converter,
    );

    // Avoid allocating a new Request when no leaf value actually changed.
    return result.changed
        ? request.copyWith(parameters: result.parameters)
        : request;
  }
}

/// Converts query parameters before they are serialized to a query string.
///
/// Recurses into nested `Map` and `Iterable` values and calls
/// [ParameterConverter.convertParameter] on each leaf, preserving the original
/// nesting structure so that chopper's existing query encoder
/// (`mapToQuery`, `ListFormat`, etc.) keeps working unchanged.
///
/// Nested maps are rebuilt as `Map<String, dynamic>`; non-`String` map keys
/// are stringified via `toString()`, matching how chopper's query encoder
/// already serializes them.
@visibleForTesting
Map<String, dynamic> convertQueryParameterMap(
  Map<String, dynamic> parameters,
  ParameterConverter converter,
) => _convertQueryParameterMap(parameters, converter).parameters;

/// Internal worker that also reports whether any leaf value was actually
/// changed by [converter]. Used by [RequestConverterInterceptor] to avoid
/// allocating a new [Request] when no leaf was modified.
_ConversionResult _convertQueryParameterMap(
  Map<String, dynamic> parameters,
  ParameterConverter converter,
) {
  final Map<String, dynamic> converted = {};
  final HashSet<Object> activePath = HashSet<Object>.identity();
  bool changed = false;
  final List<_ParameterConversionFrame> stack = [
    for (final MapEntry<String, dynamic> entry
        in parameters.entries.toList(growable: false).reversed)
      _ParameterConversionFrame.enter(
        value: entry.value,
        name: entry.key,
        assign: (value) {
          converted[entry.key] = value;
        },
      ),
  ];

  while (stack.isNotEmpty) {
    final _ParameterConversionFrame frame = stack.removeLast();

    if (frame case _ExitParameterConversionFrame(:final value)) {
      activePath.remove(value);
      continue;
    }

    final _EnterParameterConversionFrame enterFrame =
        frame as _EnterParameterConversionFrame;
    final Object? value = enterFrame.value;

    if (value is Map) {
      if (!activePath.add(value)) {
        throw _cyclicQueryParameterValue(
          enterFrame.name,
          ParameterLocation.query,
        );
      }

      final Map<String, dynamic> childMap = {};
      enterFrame.assign(childMap);
      stack.add(_ParameterConversionFrame.exit(value));

      final List<MapEntry<dynamic, dynamic>> entries = value.entries.toList(
        growable: false,
      );
      for (int i = entries.length - 1; i >= 0; i--) {
        final MapEntry<dynamic, dynamic> entry = entries[i];
        final String childKey = entry.key.toString();
        stack.add(
          _ParameterConversionFrame.enter(
            value: entry.value,
            name: '${enterFrame.name}.$childKey',
            assign: (value) {
              childMap[childKey] = value;
            },
          ),
        );
      }
      continue;
    }

    if (value is Iterable) {
      if (!activePath.add(value)) {
        throw _cyclicQueryParameterValue(
          enterFrame.name,
          ParameterLocation.query,
        );
      }

      final List<dynamic> values = value.toList(growable: false);
      final List<dynamic> childList = List<dynamic>.filled(values.length, null);
      enterFrame.assign(childList);
      stack.add(_ParameterConversionFrame.exit(value));

      for (int i = values.length - 1; i >= 0; i--) {
        stack.add(
          _ParameterConversionFrame.enter(
            value: values[i],
            name: '${enterFrame.name}[$i]',
            assign: (value) {
              childList[i] = value;
            },
          ),
        );
      }
      continue;
    }

    final Object? convertedValue = converter.convertParameter(
      value,
      ParameterConversionContext(
        name: enterFrame.name,
        location: ParameterLocation.query,
      ),
    );
    if (!identical(convertedValue, value)) {
      changed = true;
    }
    enterFrame.assign(convertedValue);
  }

  return _ConversionResult(converted, changed);
}

/// Creates an [ArgumentError] for a cyclic query parameter value at [name]
/// in the parameter [location].
ArgumentError _cyclicQueryParameterValue(
  String name,
  ParameterLocation location,
) => ArgumentError('Cyclic ${location.name} parameter value at "$name".');
