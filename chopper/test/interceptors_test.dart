import 'dart:async';

import 'package:chopper/src/base.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'helpers/fake_chain.dart';
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

      await chopper.getService<HttpTestService>().getTest(
            '1234',
            dynamicHeader: '',
          );
    });

    test('ResponseInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [ResponseIntercept()],
        services: [
          HttpTestService.create(),
        ],
        client: responseClient,
      );

      await chopper.getService<HttpTestService>().getTest(
            '1234',
            dynamicHeader: '',
          );

      expect(ResponseIntercept.intercepted, isA<_Intercepted>());
    });

    test('headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('foo'), isTrue);
        expect(req.headers['foo'], equals('bar'));

        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        interceptors: [
          HeadersInterceptor({'foo': 'bar'}),
        ],
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().getTest(
            '1234',
            dynamicHeader: '',
          );
    });

    final fakeRequest = Request(
      'POST',
      Uri.parse('/'),
      Uri.parse('base'),
      body: 'test',
      headers: {'foo': 'bar'},
    );

    test('Curl interceptors', () async {
      final curl = CurlInterceptor();
      var log = '';
      chopperLogger.onRecord.listen((r) => log = r.message);
      await curl.intercept(FakeChain(fakeRequest));

      expect(
        log,
        equals(
          "curl -v -X POST -H 'foo: bar' -H 'content-type: text/plain; charset=utf-8' -d 'test' \"base/\"",
        ),
      );
    });

    final fakeRequestMultipart = Request(
      'POST',
      Uri.parse('/'),
      Uri.parse('base'),
      headers: {'foo': 'bar'},
      parts: [
        PartValue<int>('p1', 123),
        PartValueFile<http.MultipartFile>(
          'p2',
          http.MultipartFile.fromBytes('file', [0], filename: 'filename'),
        ),
      ],
      multipart: true,
    );

    test('Curl interceptors Multipart', () async {
      final curl = CurlInterceptor();
      var log = '';
      chopperLogger.onRecord.listen((r) => log = r.message);
      await curl.intercept(FakeChain(fakeRequestMultipart));

      expect(
        log,
        equals(
          "curl -v -X POST -H 'foo: bar' -f 'p1: 123' -f 'file: filename' \"base/\"",
        ),
      );
    });
  });
}

class ResponseIntercept implements Interceptor {
  static dynamic intercepted;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final response = await chain.proceed(chain.request);

    intercepted = _Intercepted(response.body);

    return response;
  }
}

class RequestIntercept implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final request = chain.request;
    return chain.proceed(
      request.copyWith(
        uri: request.uri.replace(path: '${request.uri}/intercept'),
      ),
    );
  }
}

class _Intercepted<BodyType> {
  final BodyType body;

  _Intercepted(this.body);
}
