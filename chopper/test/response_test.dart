import 'package:chopper/src/chopper_http_exception.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'fixtures/error_fixtures.dart';

void main() {
  group('Response error casting test', () {
    test('Response is succesfull, [returns null]', () {
      final base = http.Response('Foobar', 200);

      final response = Response(base, 'Foobar');

      final result = response.errorWhereType<FooErrorType>();

      expect(result, isNull);
    });

    test('Response is unsuccessful and has no error object, [returns null]',
        () {
      final base = http.Response('Foobar', 400);

      final response = Response(base, '');

      final result = response.errorWhereType<FooErrorType>();

      expect(result, isNull);
    });

    test(
        'Response is unsuccessful and has error object of different type, [returns null]',
        () {
      final base = http.Response('Foobar', 400);

      final response = Response(base, '', error: 'Foobar');

      final result = response.errorWhereType<FooErrorType>();

      expect(result, isNull);
    });

    test(
        'Response is unsuccessful and has error object of specified type, [returns error as ErrorType]',
        () {
      final base = http.Response('Foobar', 400);

      final response = Response(base, 'Foobar', error: FooErrorType());

      final result = response.errorWhereType<FooErrorType>();

      expect(result, isNotNull);
      expect(result, isA<FooErrorType>());
    });
  });

  group('bodyOrThrow tests', () {
    test('Response is successful and has body, [bodyOrThrow returns body]', () {
      final base = http.Response('Foobar', 200);
      final response = Response(base, {'Foo': 'Bar'});

      final result = response.bodyOrThrow;

      expect(result, isNotNull);
      expect(result, {'Foo': 'Bar'});
    });

    test(
        'Response is unsuccessful and has Exception as error, [bodyOrThrow throws error]',
        () {
      final base = http.Response('Foobar', 400);
      final response = Response(base, '', error: Exception('Error occurred'));

      expect(() => response.bodyOrThrow, throwsA(isA<Exception>()));
    });

    test(
        'Response is unsuccessful and has non-exception object as error, [bodyOrThrow throws error]',
        () {
      final base = http.Response('Foobar', 400);
      final response = Response(base, '', error: 'Error occurred');

      expect(() => response.bodyOrThrow, throwsA(isA<ChopperHttpException>()));
    });

    test(
        'Response is unsuccessful and has no error, [bodyOrThrow throws ChopperHttpException]',
        () {
      final base = http.Response('Foobar', 400);
      final response = Response(base, '');

      expect(() => response.bodyOrThrow, throwsA(isA<ChopperHttpException>()));
    });

    test(
        'Response is successful and has no body, [bodyOrThrow throws ChopperHttpException]',
        () {
      final base = http.Response('Foobar', 200);
      final Response<String> response = Response(base, null);

      expect(() => response.bodyOrThrow, throwsA(isA<ChopperHttpException>()));
    });

    test('Response is successful and has void body, [bodyOrThrow returns void]',
        () {
      final base = http.Response('Foobar', 200);
      // Ignoring void checks for testing purposes
      //ignore: void_checks
      final Response<void> response = Response(base, '');

      expect(() => response.bodyOrThrow, returnsNormally);
    });
  });

  group('copyWith tests', () {
    final baseResponse = http.Response('Base response body', 200);
    final initialBody = {'key': 'value'};
    final initialError = 'Initial Error';
    final initialResponse = Response(
      baseResponse,
      initialBody,
      error: initialError,
    );

    test('copyWith no parameters uses existing values', () {
      final copiedResponse = initialResponse.copyWith();

      expect(copiedResponse.base, baseResponse);
      expect(copiedResponse.body, initialBody);
      expect(copiedResponse.error, initialError);
      expect(copiedResponse.statusCode, 200);
    });

    test('copyWith changes base response', () {
      final newBaseResponse = http.Response('New base response body', 201);
      final copiedResponse = initialResponse.copyWith(base: newBaseResponse);

      expect(copiedResponse.base, newBaseResponse);
      expect(copiedResponse.body, initialBody);
      expect(copiedResponse.error, initialError);
      expect(copiedResponse.statusCode, 201);
    });

    test('copyWith changes body', () {
      final newBody = {'newKey': 'newValue'};
      final copiedResponse = initialResponse.copyWith(body: newBody);

      expect(copiedResponse.base, baseResponse);
      expect(copiedResponse.body, newBody);
      expect(copiedResponse.error, initialError);
    });

    test('copyWith changes error', () {
      final newError = 'New Error';
      final copiedResponse = initialResponse.copyWith(bodyError: newError);

      expect(copiedResponse.base, baseResponse);
      expect(copiedResponse.body, initialBody);
      expect(copiedResponse.error, newError);
    });

    test('copyWith changes body type', () {
      final newBody = 'New body string';
      final Response<String> copiedResponse =
          initialResponse.copyWith<String>(body: newBody);

      expect(copiedResponse.base, baseResponse);
      expect(copiedResponse.body, newBody);
      expect(copiedResponse.error, initialError);
      expect(copiedResponse.body, isA<String>());
    });

    test('copyWith with all parameters', () {
      final newBaseResponse = http.Response('New base response body', 202);
      final newBody = {'newKey': 'newValue'};
      final newError = 'New Error';
      final copiedResponse = initialResponse.copyWith(
        base: newBaseResponse,
        body: newBody,
        bodyError: newError,
      );

      expect(copiedResponse.base, newBaseResponse);
      expect(copiedResponse.body, newBody);
      expect(copiedResponse.error, newError);
      expect(copiedResponse.statusCode, 202);
    });
  });
}
