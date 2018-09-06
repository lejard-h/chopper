import 'dart:async';

import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:chopper/chopper.dart';
import 'test_service.dart';

void main() {
  group('Interceptors', () {
    final requestClient = MockClient(
      (request) async {
        expect(
          request.url.toString(),
          equals('/test/get/1234/intercept'),
        );
        return http.Response('', 200);
      },
    );

    final responseClient = MockClient(
      (request) async => http.Response('body', 200),
    );

    tearDown(() {
      requestClient.close();
      responseClient.close();
    });

    test('RequestInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [RequestIntercept()],
        services: [HttpTestService()],
        client: requestClient,
      );

      await chopper.service<HttpTestService>().getTest('1234');
    });

    test('RequestInterceptorFunc', () async {
      final chopper = ChopperClient(
        interceptors: [
          (Request request) => request.replace(url: '${request.url}/intercept'),
        ],
        services: [HttpTestService()],
        client: requestClient,
      );

      await chopper.service<HttpTestService>().getTest('1234');
    });

    test('ResponseInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [ResponseIntercept()],
        services: [HttpTestService()],
        client: responseClient,
      );

      final res = await chopper.service<HttpTestService>().getTest('1234');

      expect(res.body is _Intercepted, isTrue);
    });

    test('ResponseInterceptorFunc', () async {
      final chopper = ChopperClient(
        interceptors: [
          (Response response) => response.replace(
                body: _Intercepted(response.body),
              ),
        ],
        services: [HttpTestService()],
        client: responseClient,
      );

      final res = await chopper.service<HttpTestService>().getTest('1234');

      expect(res.body is _Intercepted, isTrue);
    });
  });
}

class ResponseIntercept implements ResponseInterceptor {
  @override
  FutureOr<Response> onResponse(Response response) => response.replace(
        body: _Intercepted(response.body),
      );
}

class RequestIntercept implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) =>
      request.replace(url: '${request.url}/intercept');
}

class _Intercepted {
  final dynamic body;

  _Intercepted(this.body);
}
