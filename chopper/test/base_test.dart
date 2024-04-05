// ignore_for_file: long-method

import 'dart:async';
import 'dart:convert';

import 'package:chopper/src/base.dart';
import 'package:chopper/src/constants.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';

import 'fixtures/example_enum.dart';
import 'test_service.dart';
import 'test_service_base_url.dart';
import 'test_service_variable.dart';

final baseUrl = Uri.parse('http://localhost:8000');
const String testEnv = 'https://localhost:4000';

void main() {
  ChopperClient buildClient([
    http.Client? httpClient,
    ErrorConverter? errorConverter,
  ]) =>
      ChopperClient(
        baseUrl: baseUrl,
        services: [
          // the generated service
          HttpTestService.create(),
          HttpTestServiceVariable.create(),
          HttpTestServiceBaseUrl.create(),
        ],
        client: httpClient,
        errorConverter: errorConverter,
      );

  group('Base', () {
    test('getService', () async {
      final httpClient = MockClient(
        (_) async => http.Response('get response', 200),
      );

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();
      final serviceVariable = chopper.getService<HttpTestServiceVariable>();

      expect(service, isNotNull);
      expect(serviceVariable, isNotNull);
      expect(service, isA<HttpTestService>());
      expect(serviceVariable, isA<HttpTestServiceVariable>());
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
        expect(
          e.toString(),
          'Exception: Service type should be provided, `dynamic` is not allowed.',
        );
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

      final response = await service.getTest('1234', dynamicHeader: '');

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/get/1234'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

      final response = await service.getTest('1234', dynamicHeader: '');

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

        final bodyStreamList = <Future<List<int>>>[];
        bodyStreamList.add(Future.value(Utf8Encoder().convert('get ')));
        bodyStreamList.add(Future.value(Utf8Encoder().convert('response')));
        final s = Stream.fromFutures(bodyStreamList);

        return http.StreamedResponse(s, 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getStreamTest();

      final bytes = <int>[];
      await response.body!.forEach((d) {
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

      final response = await service.getQueryTest(number: null, def: null);

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
          await service.getQueryTest(name: 'Foo', def: 40, number: 18);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('GET with body', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get_body'),
        );
        expect(request.method, equals('GET'));
        expect(request.body, equals('get body'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getBody('get body');

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

    test('POST Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/post'),
        );
        expect(request.method, equals('POST'));
        expect(request.body, equals('post body'));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

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

      final bodyStreamList = <Future<List<int>>>[];
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

    test('PUT Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/put/1234'),
        );
        expect(request.method, equals('PUT'));
        expect(request.body, equals('put body'));

        return http.Response('put response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

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

    test('PATCH Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/patch/1234'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.body, equals('patch body'));

        return http.Response('patch response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

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

    test('DELETE Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/delete/1234'),
        );
        expect(request.method, equals('DELETE'));

        return http.Response('delete response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

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

    test('Head Variable', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$testEnv/head'),
        );
        expect(request.method, equals('HEAD'));

        return http.Response('head response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestServiceVariable>();

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

      await service.getTest('1234', dynamicHeader: '');

      client.close();
    });

    test('applyHeader', () {
      final req1 = applyHeader(
        Request('GET', Uri.parse('/'), baseUrl),
        'foo',
        'bar',
      );

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeader(
        Request('GET', Uri.parse('/'), baseUrl, headers: {'foo': 'bar'}),
        'bar',
        'foo',
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeader(
        Request('GET', Uri.parse('/'), baseUrl, headers: {'foo': 'bar'}),
        'foo',
        'foo',
      );

      expect(req3.headers, equals({'foo': 'foo'}));
    });

    test('applyHeaders', () {
      final req1 =
          applyHeaders(Request('GET', Uri.parse('/'), baseUrl), {'foo': 'bar'});

      expect(req1.headers, equals({'foo': 'bar'}));

      final req2 = applyHeaders(
        Request('GET', Uri.parse('/'), baseUrl, headers: {'foo': 'bar'}),
        {'bar': 'foo'},
      );

      expect(req2.headers, equals({'foo': 'bar', 'bar': 'foo'}));

      final req3 = applyHeaders(
        Request('GET', Uri.parse('/'), baseUrl, headers: {'foo': 'bar'}),
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
      expect(
        Request.buildUri(Uri.parse('foo'), Uri.parse('bar'), {}).toString(),
        equals('foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('foo/'), Uri.parse('bar'), {}).toString(),
        equals('foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('foo'), Uri.parse('/bar'), {}).toString(),
        equals('foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('foo/'), Uri.parse('/bar'), {}).toString(),
        equals('foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('http://foo'), Uri.parse('/bar'), {})
            .toString(),
        equals('http://foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('https://foo'), Uri.parse('/bar'), {})
            .toString(),
        equals('https://foo/bar'),
      );

      expect(
        Request.buildUri(Uri.parse('https://foo/'), Uri.parse('/bar'), {})
            .toString(),
        equals('https://foo/bar'),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo/'),
          Uri.parse('/bar'),
          {'abc': 'xyz'},
        ).toString(),
        equals('https://foo/bar?abc=xyz'),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo/'),
          Uri.parse('/bar?first=123&second=456'),
          {
            'third': '789',
            'fourth': '012',
          },
        ).toString(),
        equals('https://foo/bar?first=123&second=456&third=789&fourth=012'),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo?first=123&second=456'),
          Uri.parse('/bar'),
          {
            'third': '789',
            'fourth': '012',
          },
        ).toString(),
        equals('https://foo/bar?third=789&fourth=012'),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo?first=123&second=456'),
          Uri.parse('/bar?third=789&fourth=012'),
          {
            'fifth': '345',
            'sixth': '678',
          },
        ).toString(),
        equals(
          'https://foo/bar?third=789&fourth=012&fifth=345&sixth=678',
        ),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo.bar/foobar'),
          Uri.parse('whatbar'),
          {},
        ).toString(),
        equals('https://foo.bar/foobar/whatbar'),
      );

      expect(
        Request.buildUri(
          Uri.parse('https://foo/bar?first=123&second=456'),
          Uri.parse('https://bar/foo?fourth=789&fifth=012'),
          {},
        ).toString(),
        equals('https://bar/foo?fourth=789&fifth=012'),
      );

      expect(
        Request('GET', Uri(path: '/bar'), Uri.parse('foo')).url.toString(),
        equals('foo/bar'),
      );

      expect(
        Request('GET', Uri(host: 'bar'), Uri.parse('foo')).url.toString(),
        equals('foo/'),
      );

      expect(
        Request('GET', Uri.https('bar'), Uri.parse('foo')).url.toString(),
        equals('https://bar'),
      );

      expect(
        Request(
          'GET',
          Uri(scheme: 'https', host: 'bar', port: 666),
          Uri.parse('foo'),
        ).url.toString(),
        equals('https://bar:666'),
      );
    });

    test('BodyBytes', () {
      final request = Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        body: [1, 2, 3],
      ).toHttpRequest();

      expect(request.bodyBytes, equals([1, 2, 3]));
    });

    test('BodyBytes does not have charset header', () {
      final request = Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        headers: {
          'authorization': 'Bearer fooBarBaz',
          'x-foo': 'bar',
        },
        body: kTransparentImage,
      ).toHttpRequest();

      expect(request.headers['authorization'], equals('Bearer fooBarBaz'));
      expect(request.headers['x-foo'], equals('bar'));
      expect(request.headers['content-type'], isNull);
      expect(request.headers['content-type'], isNot(contains('charset=')));
      expect(request.bodyBytes, equals(kTransparentImage));
    });

    test('BodyFields', () {
      final request = Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        body: {'foo': 'bar'},
      ).toHttpRequest();

      expect(request.bodyFields, equals({'foo': 'bar'}));
    });

    test('Wrong body', () {
      try {
        Request(
          HttpMethod.Post,
          Uri.parse('https://foo/'),
          Uri.parse(''),
          body: {'foo': 42},
        ).toHttpRequest();
      } on ArgumentError catch (e) {
        expect(e.toString(), equals('Invalid argument (body): "{foo: 42}"'));
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
        'foo': 'bar',
        'list': [1, 2],
        'inner': {'test': 42},
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
            '$baseUrl/test/query_map?test=true&foo=bar&list=1&list=2&inner.test=42',
          ),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest2(
        {
          'foo': 'bar',
          'list': [1, 2],
          'inner': {'test': 42},
        },
        test: true,
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });

  test('Query Map 3', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/query_map?name=foo&number=1234'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getQueryMapTest3(
      name: 'foo',
      number: 1234,
    );

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Query Map 4 without QueryMap', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/query_map?name=foo&number=1234'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getQueryMapTest4(
      name: 'foo',
      number: 1234,
    );

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Query Map 4 with QueryMap', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals(
          '$baseUrl/test/query_map?name=foo&number=1234&filter_1=filter_value_1',
        ),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getQueryMapTest4(
      name: 'foo',
      number: 1234,
      filters: {
        'filter_1': 'filter_value_1',
      },
    );

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test(
    'Query Map 4 with QueryMap that overwrites a previous value from Query',
    () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/query_map?name=bar&number=1234'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.getService<HttpTestService>();

      final response = await service.getQueryMapTest4(
        name: 'foo',
        number: 1234,
        filters: {
          'name': 'bar',
        },
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    },
  );

  test('Query Map 5 without QueryMap', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/query_map'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getQueryMapTest5();

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Query Map 5 with QueryMap', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/query_map?filter_1=filter_value_1'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getQueryMapTest5(
      filters: {
        'filter_1': 'filter_value_1',
      },
    );

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('onRequest Stream', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('ok', 200);
    });

    final chopper = buildClient(client);

    chopper.onRequest.listen((request) {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/get/1234'),
      );
    });

    final service = HttpTestService.create(chopper);
    await service.getTest('1234', dynamicHeader: '');

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
    await service.getTest('1234', dynamicHeader: '');

    client.close();
    chopper.dispose();
  });

  test('error response', () async {
    final client = MockClient((http.Request req) async {
      return http.Response('error', 400);
    });

    final chopper = buildClient(client);

    final service = HttpTestService.create(chopper);
    final res = await service.getTest('1234', dynamicHeader: '');

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
    final res = await service.getTest('1234', dynamicHeader: '');

    expect(res.isSuccessful, isFalse);
    expect(res.statusCode, equals(400));
    expect(res.error, equals({'error': true}));

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

    await service.getAll();
  });

  test('Empty path gives no trailing slash new base url', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$testEnv/test'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestServiceBaseUrl>();

    await service.getAll();
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

    await service.getAllWithTrailingSlash();
  });

  test('Slash in path gives a trailing slash new base url', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$testEnv/test/'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestServiceBaseUrl>();

    await service.getAllWithTrailingSlash();
  });

  test('timeout', () async {
    final httpClient = MockClient((http.Request req) async {
      await Future.delayed(const Duration(minutes: 1));

      return http.Response('ok', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    expect(
      () async {
        try {
          await service
              .getTest('1234', dynamicHeader: '')
              .timeout(const Duration(seconds: 3));
        } finally {
          httpClient.close();
        }
      },
      throwsA(isA<TimeoutException>()),
    );
  });

  test('Include null query vars', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/query_param_include_null_query_vars'
            '?foo=foo_val'
            '&bar='
            '&baz=baz_val'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingQueryParamIncludeNullQueryVars(
      foo: 'foo_val',
      baz: 'baz_val',
    );

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param'
            '?value=foo'
            '&value=bar'
            '&value=baz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParam([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param with brackets', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param_with_brackets'
            '?value%5B%5D=foo'
            '&value%5B%5D=bar'
            '&value%5B%5D=baz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParamWithBrackets([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param with brackets (legacy)', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param_with_brackets_legacy'
            '?value%5B%5D=foo'
            '&value%5B%5D=bar'
            '&value%5B%5D=baz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParamWithBracketsLegacy([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param with indices', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param_with_indices'
            '?value%5B0%5D=foo'
            '&value%5B1%5D=bar'
            '&value%5B2%5D=baz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParamWithIndices([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param with repeat', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param_with_repeat'
            '?value=foo'
            '&value=bar'
            '&value=baz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParamWithRepeat([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('List query param with comma', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/list_query_param_with_comma'
            '?value=foo'
            '%2Cbar'
            '%2Cbaz'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingListQueryParamWithComma([
      'foo',
      'bar',
      'baz',
    ]);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param using default dot QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param'
            '?value.bar=baz'
            '&value.zap=abc'
            '&value.etc.abc=def'
            '&value.etc.ghi=jkl'
            '&value.etc.mno.opq=rst'
            '&value.etc.mno.uvw=xyz'
            '&value.etc.mno.list=a'
            '&value.etc.mno.list=123'
            '&value.etc.mno.list=false'
            '&value.etc.dt=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingMapQueryParam(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param with brackets QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_with_brackets'
            '?value%5Bbar%5D=baz'
            '&value%5Bzap%5D=abc'
            '&value%5Betc%5D%5Babc%5D=def'
            '&value%5Betc%5D%5Bghi%5D=jkl'
            '&value%5Betc%5D%5Bmno%5D%5Bopq%5D=rst'
            '&value%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=a'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=123'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=false'
            '&value%5Betc%5D%5Bdt%5D=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response =
        await service.getUsingMapQueryParamWithBrackets(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param with brackets (legacy) QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_with_brackets_legacy'
            '?value%5Bbar%5D=baz'
            '&value%5Bzap%5D=abc'
            '&value%5Betc%5D%5Babc%5D=def'
            '&value%5Betc%5D%5Bghi%5D=jkl'
            '&value%5Betc%5D%5Bmno%5D%5Bopq%5D=rst'
            '&value%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=a'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=123'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B%5D=false'
            '&value%5Betc%5D%5Bdt%5D=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response =
        await service.getUsingMapQueryParamWithBracketsLegacy(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param with indices QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_with_indices'
            '?value%5Bbar%5D=baz'
            '&value%5Bzap%5D=abc'
            '&value%5Betc%5D%5Babc%5D=def'
            '&value%5Betc%5D%5Bghi%5D=jkl'
            '&value%5Betc%5D%5Bmno%5D%5Bopq%5D=rst'
            '&value%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B0%5D=a'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B1%5D=123'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D%5B2%5D=false'
            '&value%5Betc%5D%5Bdt%5D=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response =
        await service.getUsingMapQueryParamWithIndices(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param with repeat QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_with_repeat'
            '?value.bar=baz'
            '&value.zap=abc'
            '&value.etc.abc=def'
            '&value.etc.ghi=jkl'
            '&value.etc.mno.opq=rst'
            '&value.etc.mno.uvw=xyz'
            '&value.etc.mno.list=a'
            '&value.etc.mno.list=123'
            '&value.etc.mno.list=false'
            '&value.etc.dt=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response =
        await service.getUsingMapQueryParamWithRepeat(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param with comma QueryMapSeparator', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_with_comma'
            '?value%5Bbar%5D=baz'
            '&value%5Bzap%5D=abc'
            '&value%5Betc%5D%5Babc%5D=def'
            '&value%5Betc%5D%5Bghi%5D=jkl'
            '&value%5Betc%5D%5Bmno%5D%5Bopq%5D=rst'
            '&value%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz'
            '&value%5Betc%5D%5Bmno%5D%5Blist%5D=a%2C123%2Cfalse'
            '&value%5Betc%5D%5Bdt%5D=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response =
        await service.getUsingMapQueryParamWithComma(<String, dynamic>{
      'bar': 'baz',
      'zap': 'abc',
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': 'jkl',
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': 'xyz',
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param without including null query vars', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param'
            '?value.bar=baz'
            '&value.etc.abc=def'
            '&value.etc.mno.opq=rst'
            '&value.etc.mno.list=a'
            '&value.etc.mno.list=123'
            '&value.etc.mno.list=false'
            '&value.etc.dt=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service.getUsingMapQueryParam(<String, dynamic>{
      'bar': 'baz',
      'zap': null,
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': null,
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': null,
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('Map query param including null query vars', () async {
    final DateTime now = DateTime.now();

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/map_query_param_include_null_query_vars'
            '?value.bar=baz'
            '&value.zap='
            '&value.etc.abc=def'
            '&value.etc.ghi='
            '&value.etc.mno.opq=rst'
            '&value.etc.mno.uvw='
            '&value.etc.mno.list=a'
            '&value.etc.mno.list=123'
            '&value.etc.mno.list=false'
            '&value.etc.dt=${Uri.encodeComponent(now.toUtc().toIso8601String())}'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient);
    final service = chopper.getService<HttpTestService>();

    final response = await service
        .getUsingMapQueryParamIncludeNullQueryVars(<String, dynamic>{
      'bar': 'baz',
      'zap': null,
      'etc': <String, dynamic>{
        'abc': 'def',
        'ghi': null,
        'mno': <String, dynamic>{
          'opq': 'rst',
          'uvw': null,
          'list': ['a', 123, false],
        },
        'dt': now,
      },
    });

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('client baseUrl cannot contain query parameters', () {
    expect(
      () => ChopperClient(
        baseUrl: Uri.http(
          'foo',
          'bar',
          {
            'first': '123',
            'second': '456',
          },
        ),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );

    expect(
      () => ChopperClient(
        baseUrl: Uri.parse('foo/bar?first=123'),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );

    expect(
      () => ChopperClient(
        baseUrl: Uri(
          queryParameters: {
            'first': '123',
            'second': '456',
          },
        ),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );
    expect(
      () => ChopperClient(
        baseUrl: Uri(query: 'first=123&second=456'),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );
  });

  <DateTime, String>{
    DateTime.utc(2023, 1, 1): '2023-01-01T00%3A00%3A00.000Z',
    DateTime.utc(2023, 1, 1, 12, 34, 56): '2023-01-01T12%3A34%3A56.000Z',
    DateTime.utc(2023, 1, 1, 12, 34, 56, 789): '2023-01-01T12%3A34%3A56.789Z',
  }.forEach((DateTime dateTime, String expected) {
    test('DateTime is encoded as ISO8601', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/date_time?value=$expected'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient, JsonConverter());
      final service = chopper.getService<HttpTestService>();

      final response = await service.getDateTime(dateTime);

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });

  test('Local DateTime is encoded as UTC ISO8601', () async {
    final DateTime dateTime = DateTime.now();
    final String expected =
        Uri.encodeComponent(dateTime.toUtc().toIso8601String());

    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/date_time?value=$expected'),
      );
      expect(request.method, equals('GET'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient, JsonConverter());
    final service = chopper.getService<HttpTestService>();

    final response = await service.getDateTime(dateTime);

    expect(response.body, equals('get response'));
    expect(response.statusCode, equals(200));

    httpClient.close();
  });

  test('headers are always stringified', () async {
    final httpClient = MockClient((request) async {
      expect(
        request.url.toString(),
        equals('$baseUrl/test/headers'),
      );
      expect(request.method, equals('GET'));
      expect(request.headers['x-string'], equals('lorem'));
      expect(request.headers['x-boolean'], equals('true'));
      expect(request.headers['x-int'], equals('42'));
      expect(request.headers['x-double'], equals('42.42'));
      expect(request.headers['x-enum'], equals('baz'));

      return http.Response('get response', 200);
    });

    final chopper = buildClient(httpClient, JsonConverter());
    final service = chopper.getService<HttpTestService>();

    final response = await service.getHeaders(
      stringHeader: 'lorem',
      boolHeader: true,
      intHeader: 42,
      doubleHeader: 42.42,
      enumHeader: ExampleEnum.baz,
    );

    expect(response.statusCode, equals(200));

    httpClient.close();
  });
}
