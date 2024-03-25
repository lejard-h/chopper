import 'dart:convert' show jsonEncode;

import 'package:chopper/src/base.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/headers_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'fake_authenticator.dart';

void main() async {
  final Uri baseUrl = Uri.parse('http://localhost:8000');

  ChopperClient buildClient([http.Client? httpClient]) => ChopperClient(
        baseUrl: baseUrl,
        client: httpClient,
        interceptors: [
          HeadersInterceptor({'foo': 'bar'}),
        ],
        converter: JsonConverter(),
        authenticator: FakeAuthenticator(),
      );

  late bool authenticated;
  final Map<String, bool> tested = {
    'unauthenticated': false,
    'authenticated': false,
  };

  setUp(() {
    authenticated = false;
    tested['unauthenticated'] = false;
    tested['authenticated'] = false;
  });

  group('GET', () {
    test('authorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get?key=val'),
        );
        expect(request.method, equals('GET'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.get(
        Uri(
          path: '/test/get',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('unauthorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get?key=val'),
        );
        expect(request.method, equals('GET'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.get(
        Uri(
          path: '/test/get',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationSuccessfulCalled, isTrue);

      httpClient.close();
    });

    test('unauthorized total failure', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get?key=val'),
        );
        expect(request.method, equals('GET'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('Access Denied', 403);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.get(
        Uri(
          path: '/test/get',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, anyOf(isNull, isEmpty));
      expect(response.statusCode, equals(403));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationFailedCalled, isTrue);

      httpClient.close();
    });
  });

  group('POST', () {
    test('authorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post?key=val'),
        );
        expect(request.method, equals('POST'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.post(
        Uri(
          path: '/test/post',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('unauthorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post?key=val'),
        );
        expect(request.method, equals('POST'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.post(
        Uri(
          path: '/test/post',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationSuccessfulCalled, isTrue);

      httpClient.close();
    });

    test('unauthorized total failure', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post?key=val'),
        );
        expect(request.method, equals('POST'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('Access Denied', 403);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.post(
        Uri(
          path: '/test/post',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, anyOf(isNull, isEmpty));
      expect(response.statusCode, equals(403));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationFailedCalled, isTrue);

      httpClient.close();
    });
  });

  group('PUT', () {
    test('authorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put?key=val'),
        );
        expect(request.method, equals('PUT'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.put(
        Uri(
          path: '/test/put',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('unauthorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put?key=val'),
        );
        expect(request.method, equals('PUT'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.put(
        Uri(
          path: '/test/put',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationSuccessfulCalled, isTrue);

      httpClient.close();
    });

    test('unauthorized total failure', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put?key=val'),
        );
        expect(request.method, equals('PUT'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('Access Denied', 403);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.put(
        Uri(
          path: '/test/put',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, anyOf(isNull, isEmpty));
      expect(response.statusCode, equals(403));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.onAuthenticationFailedCalled, isTrue);

      httpClient.close();
    });
  });

  group('PATCH', () {
    test('authorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch?key=val'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.patch(
        Uri(
          path: '/test/patch',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('unauthorized', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch?key=val'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.patch(
        Uri(
          path: '/test/patch',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, equals('ok'));
      expect(response.statusCode, equals(200));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.onAuthenticationSuccessfulCalled, isTrue);

      httpClient.close();
    });

    test('unauthorized total failure', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch?key=val'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(
          request.body,
          jsonEncode(
            {
              'name': 'john',
              'surname': 'doe',
            },
          ),
        );

        if (!authenticated) {
          tested['unauthenticated'] = true;
          authenticated = true;

          return http.Response('unauthorized', 401);
        } else {
          tested['authenticated'] = true;
          expect(request.headers['authorization'], equals('some_fake_token'));
        }

        return http.Response('Access Denied', 403);
      });

      final chopper = buildClient(httpClient);
      final authenticator = chopper.authenticator as FakeAuthenticator;
      final response = await chopper.patch(
        Uri(
          path: '/test/patch',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {
          'name': 'john',
          'surname': 'doe',
        },
      );

      expect(response.body, anyOf(isNull, isEmpty));
      expect(response.statusCode, equals(403));
      expect(tested['authenticated'], equals(true));
      expect(tested['unauthenticated'], equals(true));
      expect(authenticator.capturedRequest,
          authenticator.capturedAuthenticateRequest);
      expect(authenticator.capturedResponse, response);
      expect(authenticator.capturedOriginalRequest,
          authenticator.capturedAuthenticateOriginalRequest);
      expect(authenticator.onAuthenticationFailedCalled, isTrue);

      httpClient.close();
    });
  });
}
