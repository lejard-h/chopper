import 'dart:async' show FutureOr;

import 'package:chopper/chopper.dart';

class FakeAuthenticator extends Authenticator {
  Request? capturedRequest;

  Response? capturedResponse;

  Request? capturedOriginalRequest;

  Request? capturedAuthenticateRequest;

  Response? capturedAuthenticateResponse;

  Request? capturedAuthenticateOriginalRequest;

  bool onAuthenticationSuccessfulCalled = false;

  bool onAuthenticationFailedCalled = false;

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode == 401) {
      capturedAuthenticateResponse = response;
      capturedAuthenticateOriginalRequest = originalRequest;
      capturedAuthenticateRequest = request.copyWith(
        headers: <String, String>{
          ...request.headers,
          'authorization': 'some_fake_token',
        },
      );
      return capturedAuthenticateRequest;
    }

    return null;
  }

  @override
  FutureOr<void> onAuthenticationSuccessful(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) {
    onAuthenticationSuccessfulCalled = true;
    capturedRequest = request;
    capturedResponse = response;
    capturedOriginalRequest = originalRequest;
  }

  @override
  FutureOr<void> onAuthenticationFailed(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) {
    onAuthenticationFailedCalled = true;
    capturedRequest = request;
    capturedResponse = response;
    capturedOriginalRequest = originalRequest;
  }
}
