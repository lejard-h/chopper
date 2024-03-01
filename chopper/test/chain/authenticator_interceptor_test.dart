import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptors/authenticator_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late MockAuthenticator authenticator;
  late AuthenticatorInterceptor authenticatorInterceptor;
  late MockChain chain;
  final request = Request('GET', Uri.parse('bar'), Uri.parse('foo'));

  setUp(() {
    chain = MockChain<String>(
      request,
      () => Response<String>(
        http.Response('', 200),
        '',
      ),
    );
    authenticator = MockAuthenticator(() => null);
    authenticatorInterceptor = AuthenticatorInterceptor(authenticator);
  });

  test('Intercepted response is authenticated, chain.proceed called once',
      () async {
    await authenticatorInterceptor.intercept(chain);

    expect(authenticator.authenticateCalled, 1);
    expect(chain.proceedCalled, 1);
  });

  test('Intercepted response is not authenticated, chain.proceed called twice',
      () async {
    authenticator = MockAuthenticator(() => request);
    authenticatorInterceptor = AuthenticatorInterceptor(authenticator);

    await authenticatorInterceptor.intercept(chain);

    expect(authenticator.authenticateCalled, 1);
    expect(chain.proceedCalled, 2);
  });

  test(
      'Intercepted response is not authenticated, authentication is successful',
      () async {
    authenticator = MockAuthenticator(() => request);
    authenticatorInterceptor = AuthenticatorInterceptor(authenticator);

    await authenticatorInterceptor.intercept(chain);

    expect(authenticator.authenticateCalled, 1);
    expect(chain.proceedCalled, 2);
    expect(authenticator.onAuthenticationSuccessfulCalled, 1);
  });

  test('Intercepted response is not authenticated, authentication failed',
      () async {
    chain = MockChain<String>(
      request,
      () => Response<String>(
        http.Response('', 400),
        '',
      ),
    );
    authenticator = MockAuthenticator(() => request);
    authenticatorInterceptor = AuthenticatorInterceptor(authenticator);

    await authenticatorInterceptor.intercept(chain);

    expect(authenticator.authenticateCalled, 1);
    expect(chain.proceedCalled, 2);
    expect(authenticator.onAuthenticationFailedCalled, 1);
  });
}

class MockChain<BodyType> implements Chain {
  MockChain(this.request, this.onProceed);

  int proceedCalled = 0;

  final Response<BodyType> Function() onProceed;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    proceedCalled++;
    return onProceed();
  }

  @override
  final Request request;
}

class MockAuthenticator implements Authenticator {
  MockAuthenticator(this.onAuthenticate) {
    onAuthenticationFailed = (
      Request request,
      Response response, [
      Request? originalRequest,
    ]) {
      onAuthenticationFailedCalled++;
      return;
    };

    onAuthenticationSuccessful = (
      Request request,
      Response response, [
      Request? originalRequest,
    ]) {
      onAuthenticationSuccessfulCalled++;
      return;
    };
  }

  final Request? Function() onAuthenticate;

  int authenticateCalled = 0;
  int onAuthenticationFailedCalled = 0;
  int onAuthenticationSuccessfulCalled = 0;
  @override
  AuthenticationCallback? onAuthenticationFailed;

  @override
  AuthenticationCallback? onAuthenticationSuccessful;

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    authenticateCalled++;
    return onAuthenticate();
  }
}
