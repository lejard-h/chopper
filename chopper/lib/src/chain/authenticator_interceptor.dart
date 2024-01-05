import 'package:chopper/src/authenticator.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// Interceptor which uses Authenticator to authenticate requests.
class AuthenticatorInterceptor implements InternalInterceptor {
  AuthenticatorInterceptor(this.authenticator);

  final Authenticator authenticator;

  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(Chain chain) async {
    final realChain = chain as RealInterceptorChain;

    final originalRequest = realChain.request;

    Response<BodyType> response =
        await realChain.proceed<BodyType, InnerType>(originalRequest);

    final Request? updatedRequest = await authenticator.authenticate(
      originalRequest,
      response,
      originalRequest,
    );

    if (updatedRequest != null) {
      response = await realChain.proceed<BodyType, InnerType>(updatedRequest);
      if (response.statusCode.isSuccessfulStatusCode) {
        await authenticator.onAuthenticationSuccessful
            ?.call(updatedRequest, response, originalRequest);
      } else {
        await authenticator.onAuthenticationFailed
            ?.call(updatedRequest, response, originalRequest);
      }
    }

    return response;
  }
}
