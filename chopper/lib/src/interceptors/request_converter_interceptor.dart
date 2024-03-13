import 'dart:async';

import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// {@template RequestConverterInterceptor}
/// Internal interceptor that handles request conversion provided by [_requestConverter] or [_converter].
/// {@endtemplate}
class RequestConverterInterceptor implements InternalInterceptor {
  /// {@macro RequestConverterInterceptor}
  RequestConverterInterceptor(this._converter, this._requestConverter);

  /// Converter to be used for request conversion.
  final Converter? _converter;

  /// Request converter to be used for request conversion.
  final ConvertRequest? _requestConverter;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
          Chain<BodyType> chain) async =>
      await chain.proceed(
        await _handleRequestConverter(
          chain.request,
          _requestConverter,
        ),
      );

  /// Converts the [request] using [_requestConverter] if it is not null, otherwise uses [_converter].
  Future<Request> _handleRequestConverter(
    Request request,
    ConvertRequest? requestConverter,
  ) async =>
      request.body != null || request.parts.isNotEmpty
          ? requestConverter != null
              ? await requestConverter(request)
              : await _encodeRequest(request)
          : request;

  /// Encodes the [request] using [_converter] if not null.
  Future<Request> _encodeRequest(Request request) async =>
      _converter?.convertRequest(request) ?? request;
}
