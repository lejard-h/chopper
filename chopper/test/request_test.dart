// ignore_for_file: long-method

import 'package:chopper/chopper.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('Request', () {
    test('constructor produces a BaseRequest', () {
      expect(
        Request('GET', Uri.parse('/bar'), Uri.parse('https://foo/')),
        isA<http.BaseRequest>(),
      );
    });

    test('method gets preserved in BaseRequest', () {
      expect(
        Request('GET', Uri.parse('/bar'), Uri.parse('https://foo/')).method,
        equals('GET'),
      );
    });

    test('url is correctly parsed and set in BaseRequest', () {
      expect(
        Request('GET', Uri.parse('/bar'), Uri.parse('https://foo/')).url,
        equals(Uri.parse('https://foo/bar')),
      );

      expect(
        Request(
          'GET',
          Uri.parse('/bar?lorem=ipsum&dolor=123'),
          Uri.parse('https://foo/'),
        ).url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request(
          'GET',
          Uri.parse('/bar'),
          Uri.parse('https://foo/'),
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
          Uri.parse('/bar?first=sit&second=amet&first_list=a&first_list=b'),
          Uri.parse('https://foo/'),
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
        Uri.parse('/bar'),
        Uri.parse('https://foo/'),
        headers: headers,
      );

      expect(
        MapEquality().equals(request.headers, headers),
        true,
      );
    });

    test('copyWith creates a BaseRequest', () {
      expect(
        Request('GET', Uri.parse('/bar'), Uri.parse('https://foo/'))
            .copyWith(method: HttpMethod.Put),
        isA<http.BaseRequest>(),
      );
    });
  });

  group('Request', () {
    test('constructor produces a BaseRequest', () {
      expect(
        Request('GET', Uri.parse('https://foo/bar'), Uri.parse('')),
        isA<http.BaseRequest>(),
      );
    });

    test('method gets preserved in BaseRequest', () {
      expect(
        Request('GET', Uri.parse('https://foo/bar'), Uri.parse('')).method,
        equals('GET'),
      );
    });

    test('url is correctly parsed and set in BaseRequest', () {
      expect(
        Request('GET', Uri.parse('https://foo/bar'), Uri.parse('')).url,
        equals(Uri.parse('https://foo/bar')),
      );

      expect(
        Request(
          'GET',
          Uri.parse('https://foo/bar?lorem=ipsum&dolor=123'),
          Uri.parse(''),
        ).url,
        equals(Uri.parse('https://foo/bar?lorem=ipsum&dolor=123')),
      );

      expect(
        Request(
          'GET',
          Uri.parse('https://foo/bar'),
          Uri.parse(''),
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
          Uri.parse(
            'https://foo/bar?first=sit&second=amet&first_list=a&first_list=b',
          ),
          Uri.parse(''),
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

      expect(
        Request(
          'GET',
          Uri.parse(
            'https://chopper.dev/test3',
          ),
          Uri.parse(''),
          parameters: {
            'foo': 'bar',
            'foo_list': [
              'one',
              'two',
              'three',
            ],
            'user': {
              'name': 'john',
              'surname': 'doe',
            },
          },
        ).url.toString(),
        equals(
          'https://chopper.dev/test3'
          '?foo=bar'
          '&foo_list=one'
          '&foo_list=two'
          '&foo_list=three'
          '&user.name=john'
          '&user.surname=doe',
        ),
      );
    });

    test('headers are preserved in BaseRequest', () {
      final Map<String, String> headers = {
        'content-type': 'application/json; charset=utf-8',
        'accept': 'application/json; charset=utf-8',
      };

      final Request request = Request(
        'GET',
        Uri.parse('https://foo/bar'),
        Uri.parse(''),
        headers: headers,
      );

      expect(
        MapEquality().equals(request.headers, headers),
        true,
      );
    });

    test('copyWith creates a BaseRequest', () {
      expect(
        Request('GET', Uri.parse('https://foo/bar'), Uri.parse(''))
            .copyWith(method: HttpMethod.Put),
        isA<http.BaseRequest>(),
      );
    });
  });

  test('request baseUri cannot contain query parameters', () {
    expect(
      () => Request(
        'GET',
        Uri.parse('foo'),
        Uri.http(
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
      () => Request(
        'GET',
        Uri.parse('foo'),
        Uri.parse('foo/bar?first=123'),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );

    expect(
      () => Request(
        'GET',
        Uri.parse('foo'),
        Uri(
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
      () => Request(
        'GET',
        Uri.parse('foo'),
        Uri(query: 'first=123&second=456'),
      ),
      throwsA(
        TypeMatcher<AssertionError>(),
      ),
    );
  });
}
