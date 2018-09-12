import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Converter', () {
    test('base', () async {
      final converter = TestConverter();

      final decoded = await converter.decode<_Converted<String>>(
        Response<String>(http.Response('', 200), 'foo'),
      );

      expect(decoded.body is _Converted<String>, isTrue);
      expect(decoded.body.data, equals('foo'));
    });

    test('call before interceptor', () {
      // final buildClient = ChopperClient(
      //   baseUrl: "http://localhost:8000",
      //   client: httpClient,
      // );
    });

    test('call only if successful', () {});
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

class _Converted<T> {
  final T data;

  _Converted(this.data);
}
