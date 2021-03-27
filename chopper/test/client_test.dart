import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

const baseUrl = 'http://localhost:8000';

void main() {
  final buildClient = ([http.Client? httpClient]) => ChopperClient(
        baseUrl: baseUrl,
        client: httpClient,
        interceptors: [
          (Request req) => applyHeader(req, 'foo', 'bar'),
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
        '/test/get',
        headers: {'int': '42'},
        parameters: {'key': 'val'},
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
        '/test/post',
        headers: {'int': '42'},
        body: {'content': 'body'},
        parameters: {'key': 'val'},
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
        '/test/put',
        headers: {'int': '42'},
        body: {'content': 'body'},
        parameters: {'key': 'val'},
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
        '/test/patch',
        headers: {'int': '42'},
        body: {'content': 'body'},
        parameters: {'key': 'val'},
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
        '/test/delete',
        headers: {'int': '42'},
        parameters: {'key': 'val'},
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
        '/test/get',
        headers: {'int': '42'},
        parameters: {'key': 'val'},
      );

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });
}
