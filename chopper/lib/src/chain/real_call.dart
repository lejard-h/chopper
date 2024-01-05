import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/base.dart';
import 'package:chopper/src/chain/authenticator_interceptor.dart';
import 'package:chopper/src/chain/http_call_interceptor.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/chain/request_converter_interceptor.dart';
import 'package:chopper/src/chain/response_converter_interceptor.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class RealCall {
  RealCall({
    required this.request,
    required this.client,
  });

  final Request request;
  final ChopperClient client;

  Future<Response<BodyType>> execute<BodyType, InnerType>(
    ConvertRequest? requestConverter,
    ConvertResponse? responseConverter,
  ) async {
    final interceptors = <Interceptor>[
      ...client.interceptors,
      RequestConverterInterceptor(client.converter, requestConverter),
      if (client.authenticator != null)
        AuthenticatorInterceptor(client.authenticator!),
      ResponseConverterInterceptor(
        converter: client.converter,
        errorConverter: client.errorConverter,
        responseConverter:
            responseConverter,
      ),
      HttpCallInterceptor(client.httpClient),
    ];

    final interceptorChain = RealInterceptorChain(
      request: request,
      interceptors: interceptors,
      call: this,
    );

    return await interceptorChain.proceed<BodyType, InnerType>(request);
  }
}
