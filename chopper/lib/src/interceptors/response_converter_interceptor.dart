import 'dart:async';

import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';

/// {@template ResponseConverterInterceptor}
/// Internal interceptor that handles response conversion provided by [_converter], [_responseConverter] or converts error instead with provided [_errorConverter].
/// {@endtemplate}
class ResponseConverterInterceptor<InnerType> implements InternalInterceptor {
  /// {@macro ResponseConverterInterceptor}
  ResponseConverterInterceptor({
    Converter? converter,
    ErrorConverter? errorConverter,
    FutureOr<Response<dynamic>> Function(Response<dynamic>)? responseConverter,
  })  : _responseConverter = responseConverter,
        _errorConverter = errorConverter,
        _converter = converter;

  /// Converter to be used for response conversion.
  final Converter? _converter;

  /// Error converter to be used for error conversion.
  final ErrorConverter? _errorConverter;

  /// Response converter to be used for response conversion.
  final ConvertResponse? _responseConverter;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final realChain = chain as InterceptorChain<BodyType>;
    final typedChain = switch (isTypeOf<BodyType, Stream<List<int>>>()) {
      true => realChain,
      false => realChain.copyWith<String>(),
    };

    final response = await typedChain.proceed(chain.request);

    return response.statusCode.isSuccessfulStatusCode
        ? _handleSuccessResponse<BodyType>(response, _responseConverter)
        : _handleErrorResponse(response);
  }

  /// Handles the successful response by converting it using [_responseConverter] or [_converter].
  Future<Response<BodyType>> _handleSuccessResponse<BodyType>(
    Response response,
    ConvertResponse? responseConverter,
  ) async {
    if (responseConverter != null) {
      response = await responseConverter(response);
    } else if (_converter != null) {
      response = await _decodeResponse<BodyType>(response, _converter!);
    }

    return Response<BodyType>(response.base, response.body);
  }

  /// Converts the [response] using [_converter].
  Future<Response<BodyType>> _decodeResponse<BodyType>(
    Response response,
    Converter withConverter,
  ) async =>
      await withConverter.convertResponse<BodyType, InnerType>(response);

  /// Handles the error response by converting it using [_errorConverter].
  Future<Response<BodyType>> _handleErrorResponse<BodyType>(
    Response response,
  ) async {
    var error = response.body;
    if (_errorConverter != null) {
      final errorRes = await _errorConverter?.convertError<BodyType, InnerType>(
        response,
      );
      error = errorRes?.error ?? errorRes?.body;
    }

    return Response<BodyType>(response.base, null, error: error);
  }
}
