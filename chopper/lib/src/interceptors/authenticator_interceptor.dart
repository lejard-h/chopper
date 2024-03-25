import 'dart:async';

import 'package:chopper/src/authenticator.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// {@template AuthenticatorInterceptor}
/// Internal interceptor that handles authentication provided by [authenticator].
/// {@endtemplate}
class AuthenticatorInterceptor implements InternalInterceptor {
  /// {@macro AuthenticatorInterceptor}
  AuthenticatorInterceptor(this._authenticator);

  /// Authenticator to be used for authentication.
  final Authenticator _authenticator;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final originalRequest = chain.request;

    Response<BodyType> response = await chain.proceed(originalRequest);

    final Request? updatedRequest = await _authenticator.authenticate(
      originalRequest,
      response,
      originalRequest,
    );

    if (updatedRequest != null) {
      response = await chain.proceed(updatedRequest);
      if (response.statusCode.isSuccessfulStatusCode) {
        await _authenticator.onAuthenticationSuccessful
            ?.call(updatedRequest, response, originalRequest);
      } else {
        await _authenticator.onAuthenticationFailed
            ?.call(updatedRequest, response, originalRequest);
      }
    }

    return response;
  }
}
