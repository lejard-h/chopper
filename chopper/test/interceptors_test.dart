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
        services: [
          HttpTestService.create(),
        ],
        client: requestClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');
    });

    test('RequestInterceptorFunc', () async {
      final chopper = ChopperClient(
        interceptors: [
          (Request request) => request.replace(url: '${request.url}/intercept'),
        ],
        services: [
          HttpTestService.create(),
        ],
        client: requestClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');
    });

    test('ResponseInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [ResponseIntercept()],
        services: [
          HttpTestService.create(),
        ],
        client: responseClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');

      expect(ResponseIntercept.intercepted is _Intercepted, isTrue);
    });

    test('ResponseInterceptorFunc', () async {
      var intercepted;

      final chopper = ChopperClient(
        interceptors: [
          (Response response) {
            intercepted = _Intercepted(response.body);
            return response;
          },
        ],
        services: [
          HttpTestService.create(),
        ],
        client: responseClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');

      expect(intercepted is _Intercepted, isTrue);
    });

    test('headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('foo'), isTrue);
        expect(req.headers['foo'], equals('bar'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        interceptors: [
          HeadersInterceptor({'foo': 'bar'})
        ],
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().getTest('1234');
    });

    final fakeRequest = Request(
      'POST',
      '/',
      'base',
      body: 'test',
      headers: {'foo': 'bar'},
    );

    test('Curl interceptors', () async {
      final curl = CurlInterceptor();
      String log;
      chopperLogger.onRecord.listen((r) => log = r.message);
      await curl.onRequest(fakeRequest);

      expect(
        log,
        equals(
          "curl -v -X POST -H 'foo: bar' -H 'content-type: text/plain; charset=utf-8' -d 'test' base/",
        ),
      );
    });

    test('Http logger interceptor request', () async {
      final logger = HttpLoggingInterceptor();

      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));
      await logger.onRequest(fakeRequest);

      expect(
        logs,
        equals(
          [
            '--> POST base/',
            'foo: bar',
            'content-type: text/plain; charset=utf-8',
            'test',
            '--> END POST (4-byte body)',
          ],
        ),
      );
    });

    test('Http logger interceptor response', () async {
      final logger = HttpLoggingInterceptor();

      final fakeResponse = Response<String>(
        http.Response('responseBodyBase', 200,
            headers: {'foo': 'bar'},
            request: await fakeRequest.toBaseRequest()),
        'responseBody',
      );

      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));
      await logger.onResponse(fakeResponse);

      expect(
        logs,
        equals(
          [
            '<-- 200 base/',
            'foo: bar',
            'responseBodyBase',
            '--> END POST (16-byte body)',
          ],
        ),
      );
    });
  });
}

class ResponseIntercept implements ResponseInterceptor {
  static dynamic intercepted;

  @override
  FutureOr<Response> onResponse(Response response) {
    intercepted = _Intercepted(response.body);
    return response;
  }
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
