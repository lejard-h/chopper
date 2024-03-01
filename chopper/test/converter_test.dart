import 'dart:convert' as dart_convert;

import 'package:chopper/src/base.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'test_service.dart';

final baseUrl = Uri.parse('http://localhost:8000');

void main() {
  group('Converter', () {
    ChopperClient buildClient(http.BaseClient client) => ChopperClient(
          baseUrl: baseUrl,
          client: client,
          converter: TestConverter(),
          errorConverter: TestErrorConverter(),
        );

    test('base decode', () async {
      final converter = TestConverter();

      final decoded =
          converter.convertResponse<_Converted<String>, _Converted<String>>(
        Response<String>(http.Response('', 200), 'foo'),
      );

      expect(decoded.body is _Converted<String>, isTrue);
      expect(decoded.body!.data, equals('foo'));
    });

    test('base encode', () async {
      final converter = TestConverter();

      final encoded = converter.convertRequest(
        Request(
          'GET',
          Uri.parse('/'),
          baseUrl,
          body: _Converted<String>('foo'),
        ),
      );

      expect(encoded.body is String, isTrue);
      expect(encoded.body, equals('foo'));
    });

    test('on error converter', () async {
      final httpClient = MockClient((http.Request request) async {
        return http.Response('{"list":[1,2],"foo":"bar","int": 42}', 404);
      });

      final chopper = buildClient(httpClient);

      final service = HttpTestService.create(chopper);

      try {
        await service.getTest('1', dynamicHeader: '');
      } catch (e) {
        expect(e is Response, isTrue);
        expect((e as Response).body is _ConvertedError, isTrue);
        final res = e as Response<_ConvertedError>;
        expect(res.body!.data is Map, isTrue);
        expect(res.body!.data['list'], equals([1, 2]));
        expect(res.body!.data['foo'], equals('bar'));
        expect(res.body!.data['int'], equals(42));
      }
      httpClient.close();
    });
  });

  group('JsonConverter', () {
    final jsonConverter = JsonConverter();

    test('decode String', () async {
      final value = 'foo';
      final res = Response(http.Response('"$value"', 200), '"$value"');
      final converted =
          await jsonConverter.convertResponse<String, String>(res);

      expect(converted.body, equals(value));
    });

    test('decode List String', () async {
      final res = Response(
        http.Response('["foo","bar"]', 200),
        '["foo","bar"]',
      );
      final converted =
          await jsonConverter.convertResponse<List<String>, String>(res);

      expect(converted.body, equals(['foo', 'bar']));
    });

    test('decode List int', () async {
      final res = Response(http.Response('[1,2]', 200), '[1,2]');
      final converted =
          await jsonConverter.convertResponse<List<int>, int>(res);

      expect(converted.body, equals([1, 2]));
    });

    test('decode Map', () async {
      final res = Response(
        http.Response('{"foo":"bar"}', 200),
        '{"foo":"bar"}',
      );
      final converted =
          await jsonConverter.convertResponse<Map<String, String>, String>(res);

      expect(converted.body, equals({'foo': 'bar'}));
    });

    test('JsonConverter.isJson', () {
      expect(JsonConverter.isJson('{"foo":"bar"}'), isTrue);
      expect(JsonConverter.isJson('foo'), isFalse);
      expect(JsonConverter.isJson(''), isFalse);
      expect(JsonConverter.isJson(null), isFalse);
      expect(JsonConverter.isJson(42), isFalse);
      expect(JsonConverter.isJson([]), isFalse);
      expect(JsonConverter.isJson([1, 2, 3]), isFalse);
      expect(JsonConverter.isJson(['a', 'b', 'c']), isFalse);
      expect(JsonConverter.isJson({}), isFalse);
      expect(
        JsonConverter.isJson({
          'foo': 'bar',
          'list': [1, 2, 3],
        }),
        isFalse,
      );
    });
  });

  test('respects content-type headers', () {
    final jsonConverter = JsonConverter();
    final testRequest = Request(
      'POST',
      Uri.parse('foo'),
      Uri.parse('bar'),
      headers: {'Content-Type': 'application/vnd.api+json'},
    );

    final result = jsonConverter.convertRequest(testRequest);

    expect(result.headers['content-type'], 'application/vnd.api+json');
  });
}

class TestConverter implements Converter {
  @override
  Response<T> convertResponse<T, V>(Response res) {
    if (res.body is String) {
      return res.copyWith<_Converted<String>>(
        body: _Converted<String>(res.body),
      ) as Response<T>;
    }

    return res as Response<T>;
  }

  @override
  Request convertRequest(Request req) =>
      req.body is _Converted ? req.copyWith(body: req.body.data) : req;
}

class TestErrorConverter implements ErrorConverter {
  @override
  Response convertError<T, V>(Response res) {
    if (res.body is String) {
      final error = dart_convert.jsonDecode(res.body);

      return res.copyWith<_ConvertedError>(body: _ConvertedError(error));
    }

    return res;
  }
}

class _Converted<T> {
  final T data;

  _Converted(this.data);
}

class _ConvertedError<T> {
  final T data;

  _ConvertedError(this.data);
}
