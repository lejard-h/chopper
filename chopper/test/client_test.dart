import 'dart:convert';

import 'package:chopper/src/base.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/headers_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

final baseUrl = Uri.parse('http://localhost:8000');

void main() {
  ChopperClient buildClient([http.Client? httpClient]) => ChopperClient(
        baseUrl: baseUrl,
        client: httpClient,
        interceptors: [
          HeadersInterceptor({'foo': 'bar'}),
        ],
        converter: JsonConverter(),
      );

  group('Client methods', () {
    test('GET', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get?key=val'),
        );
        expect(request.method, equals('GET'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.get(
        Uri(
          path: '/test/get',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
    test('POST', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/post?key=val'),
        );
        expect(request.method, equals('POST'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(request.body, json.encode({'content': 'body'}));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.post(
        Uri(
          path: '/test/post',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {'content': 'body'},
      );

      expect(response.body, equals('post response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PUT', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/put?key=val'),
        );
        expect(request.method, equals('PUT'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(request.body, json.encode({'content': 'body'}));

        return http.Response('put response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.put(
        Uri(
          path: '/test/put',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {'content': 'body'},
      );

      expect(response.body, equals('put response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PATCH', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/patch?key=val'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));
        expect(request.body, json.encode({'content': 'body'}));

        return http.Response('patch response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.patch(
        Uri(
          path: '/test/patch',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
        body: {'content': 'body'},
      );

      expect(response.body, equals('patch response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('DELETE', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/delete?key=val'),
        );
        expect(request.method, equals('DELETE'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        return http.Response('delete response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.delete(
        Uri(
          path: '/test/delete',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, equals('delete response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
    test('OPTIONS', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('$baseUrl/test/get?key=val'),
        );
        expect(request.method, equals('OPTIONS'));
        expect(request.headers['foo'], equals('bar'));
        expect(request.headers['int'], equals('42'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final response = await chopper.options(
        Uri(
          path: '/test/get',
          queryParameters: {'key': 'val'},
        ),
        headers: {'int': '42'},
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });
}
