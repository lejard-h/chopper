import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';

class ResponseConverterInterceptor<InnerType> implements InternalInterceptor {
  ResponseConverterInterceptor({
    this.converter,
    this.errorConverter,
    this.responseConverter,
  });

  final Converter? converter;
  final ErrorConverter? errorConverter;
  final ConvertResponse? responseConverter;

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final realChain = chain as InterceptorChain<BodyType>;
    final typedChain = switch (isTypeOf<BodyType, Stream<List<int>>>()) {
      true => realChain,
      false => realChain.copyWith<String>(),
    };

    final response = await typedChain.proceed(chain.request);

    return response.statusCode.isSuccessfulStatusCode
        ? _handleSuccessResponse<BodyType>(response, responseConverter)
        : _handleErrorResponse(response);
  }

  Future<Response<BodyType>> _handleSuccessResponse<BodyType>(
    Response response,
    ConvertResponse? responseConverter,
  ) async {
    Response? newResponse;
    if (responseConverter != null) {
      newResponse = await responseConverter(response);
    } else if (converter != null) {
      newResponse = await _decodeResponse<BodyType>(response, converter!);
    }

    return Response<BodyType>(
      newResponse?.base ?? response.base,
      newResponse?.body ?? response.body,
    );
  }

  Future<Response<BodyType>> _decodeResponse<BodyType>(
    Response response,
    Converter withConverter,
  ) async =>
      await withConverter.convertResponse<BodyType, InnerType>(response);

  Future<Response<BodyType>> _handleErrorResponse<BodyType>(
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
