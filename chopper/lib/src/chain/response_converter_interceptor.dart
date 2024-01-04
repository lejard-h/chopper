import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/response.dart';

class ResponseConverterInterceptor implements Interceptor {
  ResponseConverterInterceptor({
    this.converter,
    this.errorConverter,
    this.responseConverter,
  });

  final Converter? converter;
  final ErrorConverter? errorConverter;
  final ConvertResponse? responseConverter;

  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(
    Chain chain,
  ) async {
    final realChain = (chain as RealInterceptorChain).copyWith(exchangable: true);

    final response = await realChain.proceed<BodyType, InnerType>(chain.request);

    return response.statusCode.isSuccessfulStatusCode
        ? _handleSuccessResponse(response, responseConverter)
        : _handleErrorResponse(response);
  }

  Future<Response<BodyType>> _handleSuccessResponse<BodyType, InnerType>(
    Response response,
    ConvertResponse? responseConverter,
  ) async {
    if (responseConverter != null) {
      response = await responseConverter(response);
    } else if (converter != null) {
      response =
          await _decodeResponse<BodyType, InnerType>(response, converter!);
    }

    return Response<BodyType>(
      response.base,
      response.body,
    );
  }

  Future<Response<BodyType>> _decodeResponse<BodyType, InnerType>(
    Response response,
    Converter withConverter,
  ) async =>
      await withConverter.convertResponse<BodyType, InnerType>(response);

  Future<Response<BodyType>> _handleErrorResponse<BodyType, InnerType>(
    Response response,
  ) async {
    var error = response.body;
    if (errorConverter != null) {
      final errorRes = await errorConverter?.convertError<BodyType, InnerType>(
        response,
      );
      error = errorRes?.error ?? errorRes?.body;
    }

    return Response<BodyType>(response.base, null, error: error);
  }
}
