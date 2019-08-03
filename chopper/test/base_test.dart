import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

const baseUrl = 'http://localhost:8000';

void main() {
  final buildClient = (
          [http.Client httpClient, ErrorConverter errorConverter]) =>
      ChopperClient(
        baseUrl: baseUrl,
        services: [
          // the generated service
          HttpTestService.create(),
        ],
        client: httpClient,
        errorConverter: errorConverter,
      );
  group('Base', () {
    test('get service', () async {
      final chopper = buildClient();
      final service = chopper.getService<HttpTestService>();

      expect(service is HttpTestService, isTrue);
    });

    test('get service errors', () async {
      final chopper = ChopperClient(
        baseUrl: baseUrl,
      );

      try {
        chopper.getService<HttpTestService>();
      } on Exception catch (e) {
        expect(
          e.toString(),
          equals("Exception: Service of type 'HttpTestService' not found."),
        );
      }

      try {
        chopper.getService();
      } on Exception catch (e) {
        expect(e.toString(),
            'Exception: Service type should be provided, `dynamic` is not allowed.');
      }
    });
    test('GET', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get/1234'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getTest('1234');

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET stream', () async {
      final httpClient = MockClient.streaming((request, stream) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get'),
        );
        expect(request.method, equals('GET'));

        final bodyStreamList = List<Future<List<int>>>();
        bodyStreamList.add(Future.value(Utf8Encoder().convert('get ')));
        bodyStreamList.add(Future.value(Utf8Encoder().convert('response')));
        final s = Stream.fromFutures(bodyStreamList);

        return http.StreamedResponse(s, 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getStreamTest();

      final bytes = List<int>();
      await response.body.forEach((d) {
        bytes.addAll(d);
      });

      expect(Utf8Decoder().convert(bytes), equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params, null value', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryTest(def: null);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params, default value', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query?default_value=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryTest();

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with query params', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query?name=Foo&int=18&default_value=40'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response =
          await service.getQueryTest(name: "Foo", def: 40, number: 18);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('POST', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post'),
        );
        expect(request.method, equals('POST'));
        expect(request.body, equals('post body'));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.postTest('post body');

      expect(response.body, equals('post response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('POST with streamed body', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post'),
        );
        expect(request.method, equals('POST'));
        expect(request.body, equals('post body'));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final bodyStreamList = List<Future<List<int>>>();
      bodyStreamList.add(Future.value(Utf8Encoder().convert('post ')));
      bodyStreamList.add(Future.value(Utf8Encoder().convert('body')));
      final s = Stream.fromFutures(bodyStreamList);

      final response = await service.postStreamTest(s);

      expect(response.body, equals('post response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PUT', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put/1234'),
        );
        expect(request.method, equals('PUT'));
        expect(request.body, equals('put body'));

        return http.Response('put response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.putTest('1234', 'put body');

      expect(response.body, equals('put response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PATCH', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch/1234'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.body, equals('patch body'));

        return http.Response('patch response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.patchTest('1234', 'patch body');

      expect(response.body, equals('patch response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('DELETE', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/delete/1234'),
        );
        expect(request.method, equals('DELETE'));

        return http.Response('delete response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.deleteTest('1234');

      expect(response.body, equals('delete response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('Head', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/head'),
        );
        expect(request.method, equals('HEAD'));

        return http.Response('head response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.headTest();

      expect(response.body, equals('head response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('const headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('foo'), isTrue);
        expect(req.headers['foo'], equals('bar'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().deleteTest('1234');

      client.close();
    });

    test('runtime headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('test'), isTrue);
        expect(req.headers['test'], equals('42'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().getTest(
            '1234',
            dynamicHeader: '42',
          );

      client.close();
    });

    test('factory', () async {
      final client = MockClient((http.Request req) async {
        expect(
          req.url.toString(),
          equals('$baseUrl/test/get/1234'),
        );
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        baseUrl: baseUrl,
        client: client,
      );

      final service = HttpTestService.create(chopper);

      await service.getTest('1234');

      client.close();
    });

    test('applyHeader', () {
      final req1 = applyHeader(
          Request(
            'GET',
            '/',
            baseUrl,
          ),
          'foo',
          'bar');

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeader(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        'bar',
        'foo',
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeader(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        'foo',
        'foo',
      );

      expect(req3.headers, equals({'foo': 'foo'}));
    });

    test('applyHeaders', () {
      final req1 = applyHeaders(Request('GET', '/', baseUrl), {'foo': 'bar'});

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeaders(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        {'bar': 'foo'},
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeaders(
        Request('GET', '/', baseUrl, headers: {'foo': 'bar'}),
        {'foo': 'foo'},
      );

      expect(req3.headers, equals({'foo': 'foo'}));
    });

    test('fullUrl', () async {
      final client = MockClient((http.Request req) async {
        return http.Response('ok', 200);
      });

      final chopper = buildClient(client);

      chopper.onRequest.listen((request) {
        expect(
          request.url.toString(),
          equals('https://test.com'),
        );
      });

      final service = HttpTestService.create(chopper);
      await service.fullUrl();

      client.close();
      chopper.dispose();
    });

    test('url concatenation', () async {
      final url1 = buildUri('foo', 'bar', {});
      expect(url1.toString(), equals('foo/bar'));

      final url2 = buildUri('foo/', 'bar', {});
      expect(url2.toString(), equals('foo/bar'));

      final url3 = buildUri('foo', '/bar', {});
      expect(url3.toString(), equals('foo/bar'));

      final url4 = buildUri('foo/', '/bar', {});
      expect(url4.toString(), equals('foo//bar'));

      final url5 = buildUri('http://foo', '/bar', {});
      expect(url5.toString(), equals('http://foo/bar'));

      final url6 = buildUri('https://foo', '/bar', {});
      expect(url6.toString(), equals('https://foo/bar'));

      final url7 = buildUri('https://foo/', '/bar', {});
      expect(url7.toString(), equals('https://foo//bar'));
    });

    test('BodyBytes', () async {
      final request = await toHttpRequest(
        [1, 2, 3],
        HttpMethod.Post,
        Uri.parse('/foo'),
        {},
      );

      expect(request.bodyBytes, equals([1, 2, 3]));
    });

    test('BodyFields', () async {
      final request = await toHttpRequest(
        {"foo": "bar"},
        HttpMethod.Post,
        Uri.parse('/foo'),
        {},
      );

      expect(request.bodyFields, equals({"foo": "bar"}));
    });

    test("Wrong body", () async {
      try {
        await toHttpRequest(
          {"foo": 42},
          HttpMethod.Post,
          Uri.parse('/foo'),
          {},
        );
      } on ArgumentError catch (e) {
        expect(e.toString(), equals('Invalid argument (body): "{foo: 42}"'));
      }
    });

    test("wrong type for interceptor", () {
      try {
        ChopperClient(
          interceptors: [
            (bool foo) => "bar",
          ],
        );
      } on ArgumentError catch (e) {
        expect(
          e.toString(),
          'Invalid argument(s): Unsupported type for interceptors, it only support the following types: $allowedInterceptorsType',
        );
      }
    });

    test('Query Map 1', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query_map?foo=bar&list=1&list=2&inner.test=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest({
        "foo": "bar",
        "list": [1, 2],
        "inner": {"test": 42},
      });

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('Query Map 2', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals(
              '$baseUrl/test/query_map?test=true&foo=bar&list=1&list=2&inner.test=42'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest2(
        {
          "foo": "bar",
          "list": [1, 2],
          "inner": {"test": 42},
        },
        test: true,
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });

  test('onRequest Stream', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('ok', 200);
    });

    final chopper = buildClient(client);

    chopper.onRequest.listen((request) {
      expect(
        request.url.toString(),
        equals('/test/get/1234'),
      );
    });

    final service = HttpTestService.create(chopper);
    await service.getTest('1234');

    client.close();
    chopper.dispose();
  });

  test('onResponse Stream', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('ok', 200);
    });

    final chopper = buildClient(client);

    chopper.onResponse.listen((response) {
      expect(response.statusCode, equals(200));
      expect(response.body, equals('ok'));
    });

    final service = HttpTestService.create(chopper);
    await service.getTest('1234');

    client.close();
    chopper.dispose();
  });

  test('error response', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('error', 400);
    });

    final chopper = buildClient(client);

    final service = HttpTestService.create(chopper);
    final res = await service.getTest('1234');

    expect(res.isSuccessful, isFalse);
    expect(res.statusCode, equals(400));
    expect(res.body, isNull);
    expect(res.error, equals('error'));

    client.close();
    chopper.dispose();
  });

  test('error Converter', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('{"error":true}', 400);
    });

    final chopper = buildClient(client, JsonConverter());

    final service = HttpTestService.create(chopper);
    final res = await service.getTest('1234');

    expect(res.isSuccessful, isFalse);
    expect(res.statusCode, equals(400));
    expect(res.error, equals({"error": true}));

    client.close();
    chopper.dispose();
  });

  test('Empty path gives no trailing slash', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final _ = await service.getAll();
  });

  test('Slash in path gives a trailing slash', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final _ = await service.getAllWithTrailingSlash();
  });

  test('timeout', () async {
    final httpClient = MockClient((http.Request req) async {
      await Future.delayed(const Duration(minutes: 1));
      return http.Response('ok', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    try {
      await service.getTest('1234').timeout(const Duration(seconds: 3));
    } catch (e) {
      expect(e is TimeoutException, isTrue);
    }

    httpClient.close();
  });
}
