import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';

class ResponseConverterInterceptor implements InternalInterceptor {
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
    final realChain = chain as RealInterceptorChain;

    final Response response = switch (isTypeOf<BodyType, Stream<List<int>>>()) {
      true =>
        await realChain.proceed<Stream<List<int>>, InnerType>(chain.request),
      false => await realChain.proceed<String, InnerType>(chain.request),
    };

    return response.statusCode.isSuccessfulStatusCode
        ? _handleSuccessResponse<BodyType, InnerType>(
            response, responseConverter)
        : _handleErrorResponse(response);
  }

  Future<Response<BodyType>> _handleSuccessResponse<BodyType, InnerType>(
    Response response,
    ConvertResponse? responseConverter,
  ) async {
    Response? newResponse;
    if (responseConverter != null) {
      newResponse = await responseConverter(response);
    } else if (converter != null) {
      newResponse =
          await _decodeResponse<BodyType, InnerType>(response, converter!);
    }

    return Response<BodyType>(
      newResponse?.base ?? response.base,
      newResponse?.body ?? response.body,
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
