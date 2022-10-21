// ignore_for_file: long-method

import 'package:chopper/chopper.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('Request', () {
    test('constructor produces a BaseRequest', () {
      expect(
        Request('GET', '/bar', 'https://foo/'),
        isA<http.BaseRequest>(),
      );
    });

    test('method gets preserved in BaseRequest', () {
      expect(
        Request('GET', '/bar', 'https://foo/').method,
        equals('GET'),
      );
    });

    test('url is correctly parsed and set in BaseRequest', () {
      expect(
        Request('GET', '/bar', 'https://foo/').url,
        equals(Uri.parse('https://foo/bar')),
      );

      expect(
        Request('GET', '/bar?lorem=ipsum&dolor=123', 'https://foo/').url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request(
          'GET',
          '/bar',
          'https://foo/',
          parameters: {
            'lorem': 'ipsum',
            'dolor': 123,
          },
        ).url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request(
          'GET',
          '/bar?first=sit&second=amet&first_list=a&first_list=b',
          'https://foo/',
          parameters: {
            'lorem': 'ipsum',
            'dolor': 123,
            'second_list': ['a', 'b'],
          },
        ).url,
        equals(Uri.parse(
          'https://foo/bar?first=sit&second=amet&first_list=a&first_list=b&lorem=ipsum&dolor=123&second_list=a&second_list=b',
        )),
      );
    });

    test('headers are preserved in BaseRequest', () {
      final Map<String, String> headers = {
        'content-type': 'application/json; charset=utf-8',
        'accept': 'application/json; charset=utf-8',
      };

      final Request request = Request(
        'GET',
        '/bar',
        'https://foo/',
        headers: headers,
      );

      expect(
        MapEquality().equals(request.headers, headers),
        true,
      );
    });

    test('copyWith creates a BaseRequest', () {
      expect(
        Request('GET', '/bar', 'https://foo/').copyWith(method: HttpMethod.Put),
        isA<http.BaseRequest>(),
      );
    });
  });

  group('Request.uri', () {
    test('constructor produces a BaseRequest', () {
      expect(
        Request.uri('GET', Uri.parse('https://foo/bar'), ''),
        isA<http.BaseRequest>(),
      );
    });

    test('method gets preserved in BaseRequest', () {
      expect(
        Request.uri('GET', Uri.parse('https://foo/bar'), '').method,
        equals('GET'),
      );
    });

    test('url is correctly parsed and set in BaseRequest', () {
      expect(
        Request.uri('GET', Uri.parse('https://foo/bar'), '').url,
        equals(Uri.parse('https://foo/bar')),
      );

      expect(
        Request.uri(
                'GET', Uri.parse('https://foo/bar?lorem=ipsum&dolor=123'), '')
            .url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request.uri(
          'GET',
          Uri(scheme: 'https', host: 'foo', path: 'bar', queryParameters: {
            'lorem': 'ipsum',
            'dolor': '123',
          }),
          '',
        ).url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request.uri(
          'GET',
          Uri(scheme: 'https', host: 'foo', path: 'bar', queryParameters: {
            'first': 'sit',
            'second': 'amet',
            'first_list': ['a', 'b'],
            'lorem': 'ipsum',
            'dolor': '123',
            'second_list': ['a', 'b'],
          }),
          '',
        ).url,
        equals(Uri.parse(
          'https://foo/bar?first=sit&second=amet&first_list=a&first_list=b&lorem=ipsum&dolor=123&second_list=a&second_list=b',
        )),
      );
    });

    test('headers are preserved in BaseRequest', () {
      final Map<String, String> headers = {
        'content-type': 'application/json; charset=utf-8',
        'accept': 'application/json; charset=utf-8',
      };

      final Request request = Request.uri(
        'GET',
        Uri.parse('https://foo/bar'),
        '',
        headers: headers,
      );

      expect(
        MapEquality().equals(request.headers, headers),
        true,
      );
    });

    test('copyWith creates a BaseRequest', () {
      expect(
        Request.uri('GET', Uri.parse('https://foo/bar'), '')
            .copyWith(method: HttpMethod.Put),
        isA<http.BaseRequest>(),
      );
    });
  });
}
