import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

void main() {
  group('Converter', () {
    final buildClient = (http.BaseClient client) => ChopperClient(
          baseUrl: "http://localhost:8000",
          client: client,
          converter: TestConverter(),
          errorConverter: TestErrorConverter(),
        );

    test('base decode', () async {
      final converter = TestConverter();

      final decoded = await converter.decode<_Converted<String>>(
        Response<String>(http.Response('', 200), 'foo'),
      );

      expect(decoded.body is _Converted<String>, isTrue);
      expect(decoded.body.data, equals('foo'));
    });

    test('base encode', () async {
      final converter = TestConverter();

      final encoded = await converter.encode<_Converted<String>>(
        Request('GET', '/', body: _Converted<String>('foo')),
      );

      expect(encoded.body is String, isTrue);
      expect(encoded.body, equals('foo'));
    });

    test('on error converter', () async {
      final httpClient = MockClient((http.Request request) async {
        return http.Response('error', 404);
      });

      final chopper = buildClient(httpClient);

      final service = HttpTestService.create(chopper);

      try {
        await service.getTest('1');
      } catch (e) {
        expect(e is Response, isTrue);
        expect((e as Response).body is _ConvertedError, isTrue);
        expect(e.body.data, equals('error'));
      }
      httpClient.close();
    });
  });
}

class TestConverter extends Converter {
  @override
  @protected
  Future decodeEntity<T>(entity) async {
    if (entity is String) return _Converted<String>(entity);
    return null;
  }

  @override
  @protected
  Future encodeEntity<T>(T entity) async {
    if (entity is _Converted) return entity.data;
    return entity;
  }
}

class TestErrorConverter extends Converter {
  @override
  @protected
  Future decodeEntity<T>(entity) async {
    if (entity is String) return _ConvertedError<String>(entity);
    return null;
  }

  @override
  @protected
  Future encodeEntity<T>(T entity) async {
    if (entity is _ConvertedError) return entity.data;
    return entity;
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
