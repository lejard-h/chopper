import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/base.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/interceptors/authenticator_interceptor.dart';
import 'package:chopper/src/interceptors/http_call_interceptor.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/request_converter_interceptor.dart';
import 'package:chopper/src/interceptors/response_converter_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// {@template Call}
/// A single call to a HTTP endpoint. It holds the [request] and the [client].
/// {@endtemplate}
class Call {
  /// {@macro Call}
  Call({
    required this.request,
    required this.client,
  });

  /// Request to be executed.
  final Request request;

  /// Chopper client that created this call.
  final ChopperClient client;

  Future<Response<BodyType>> execute<BodyType, InnerType>(
    ConvertRequest? requestConverter,
    ConvertResponse<BodyType>? responseConverter,
  ) async {
    final interceptors = <Interceptor>[
      RequestConverterInterceptor(client.converter, requestConverter),
      ...client.interceptors,
      if (client.authenticator != null)
        AuthenticatorInterceptor(client.authenticator!),
      ResponseConverterInterceptor<InnerType>(
        converter: client.converter,
        errorConverter: client.errorConverter,
        responseConverter: responseConverter,
      ),
      HttpCallInterceptor(client.httpClient),
    ];

    final interceptorChain = InterceptorChain<BodyType>(
      request: request,
      interceptors: interceptors,
    );

    return await interceptorChain.proceed(request);
  }
}
