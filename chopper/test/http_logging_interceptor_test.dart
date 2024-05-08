import 'package:chopper/src/interceptors/http_logging_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'helpers/fake_chain.dart';

void main() {
  final Request fakeRequest = Request(
    'POST',
    Uri.parse('/'),
    Uri.parse('base'),
    body: 'test',
    headers: {'foo': 'bar'},
  );

  group('standard', () {
    group('http logging requests', () {
      test('Http logger interceptor none level request', () async {
        final logger = HttpLoggingInterceptor(level: Level.none);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(
          logs,
          equals(
            [],
          ),
        );
      });

      test('Http logger interceptor basic level request', () async {
        final logger = HttpLoggingInterceptor(level: Level.basic);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(
          logs,
          containsAll(
            [
              '',
              '--> POST base/ (4-byte body)',
            ],
          ),
        );
      });

      test('Http logger interceptor basic level request', () async {
        final logger = HttpLoggingInterceptor(level: Level.headers);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(
          logs,
          containsAll(
            [
              '',
              '--> POST base/',
              'foo: bar',
              'content-type: text/plain; charset=utf-8',
              'content-length: 4',
              '--> END POST',
            ],
          ),
        );
      });

      test('Http logger interceptor body level request', () async {
        final logger = HttpLoggingInterceptor(level: Level.body);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(
          logs,
          containsAll(
            [
              '',
              '--> POST base/',
              'foo: bar',
              'content-type: text/plain; charset=utf-8',
              'content-length: 4',
              '',
              'test',
              '--> END POST',
            ],
          ),
        );
      });
    });

    group('http logging interceptor response logging', () {
      late Response fakeResponse;

      setUp(() async {
        fakeResponse = Response<String>(
          http.Response(
            'responseBodyBase',
            200,
            headers: {'foo': 'bar'},
            request: await fakeRequest.toBaseRequest(),
          ),
          'responseBody',
        );
      });

      test('Http logger interceptor none level response', () async {
        final logger = HttpLoggingInterceptor(level: Level.none);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(
          logs,
          equals(
            [],
          ),
        );
      });

      test('Http logger interceptor basic level response', () async {
        final logger = HttpLoggingInterceptor(level: Level.basic);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest, response: fakeResponse));

        expect(
          logs,
          containsAll(
            [
              '',
              '<-- 200 POST base/ (0ms, 16-byte body)',
            ],
          ),
        );
      });

      test('Http logger interceptor headers level response', () async {
        final logger = HttpLoggingInterceptor(level: Level.headers);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest, response: fakeResponse));

        expect(
          logs,
          containsAll(
            [
              '',
              '<-- 200 POST base/ (0ms)',
              'foo: bar',
              'content-length: 16',
              '<-- END HTTP',
            ],
          ),
        );
      });

      test('Http logger interceptor body level response', () async {
        final logger = HttpLoggingInterceptor(level: Level.body);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest, response: fakeResponse));

        expect(
          logs,
          containsAll(
            [
              '',
              '<-- 200 POST base/ (0ms)',
              'foo: bar',
              'content-length: 16',
              '',
              'responseBodyBase',
              '<-- END HTTP',
            ],
          ),
        );
      });
    });

    group('headers content-length not overridden', () {
      late Response fakeResponse;

      setUp(() async {
        fakeResponse = Response<String>(
          http.Response(
            'responseBodyBase',
            200,
            headers: {
              'foo': 'bar',
              'content-length': '42',
            },
            request: await fakeRequest.toBaseRequest(),
          ),
          'responseBody',
        );
      });

      test('request header level content-length', () async {
        final logger = HttpLoggingInterceptor(level: Level.headers);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));

        await logger.intercept(FakeChain(fakeRequest.copyWith(
            headers: {...fakeRequest.headers, 'content-length': '42'})));

        expect(
          logs,
          containsAll(
            [
              '',
              '--> POST base/',
              'foo: bar',
              'content-length: 42',
              'content-type: text/plain; charset=utf-8',
              '--> END POST',
            ],
          ),
        );
      });

      test('request body level content-length', () async {
        final logger = HttpLoggingInterceptor(level: Level.body);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));

        await logger.intercept(FakeChain(fakeRequest.copyWith(
            headers: {...fakeRequest.headers, 'content-length': '42'})));

        expect(
          logs,
          containsAll(
            [
              '',
              '--> POST base/',
              'foo: bar',
              'content-length: 42',
              'content-type: text/plain; charset=utf-8',
              '',
              'test',
              '--> END POST',
            ],
          ),
        );
      });

      test('response header level content-length', () async {
        final logger = HttpLoggingInterceptor(level: Level.headers);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest, response: fakeResponse));

        expect(
          logs,
          containsAll(
            [
              '',
              '<-- 200 POST base/ (0ms)',
              'foo: bar',
              'content-length: 42',
              '<-- END HTTP',
            ],
          ),
        );
      });
      test('response body level content-length', () async {
        final logger = HttpLoggingInterceptor(level: Level.body);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest, response: fakeResponse));

        expect(
          logs,
          containsAll(
            [
              '',
              '<-- 200 POST base/ (0ms)',
              'foo: bar',
              'content-length: 42',
              '',
              'responseBodyBase',
              '<-- END HTTP',
            ],
          ),
        );
      });
    });
  });

  group('only errors', () {
    group('http logging requests', () {
      test('Http logger interceptor none level request', () async {
        final logger =
            HttpLoggingInterceptor(level: Level.none, onlyErrors: true);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(logs, equals([]));
      });

      test('Http logger interceptor basic level request', () async {
        final logger =
            HttpLoggingInterceptor(level: Level.basic, onlyErrors: true);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(logs, equals([]));
      });

      test('Http logger interceptor basic level request', () async {
        final logger =
            HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(logs, equals([]));
      });

      test('Http logger interceptor body level request', () async {
        final logger =
            HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

        final logs = [];
        chopperLogger.onRecord.listen((r) => logs.add(r.message));
        await logger.intercept(FakeChain(fakeRequest));

        expect(logs, equals([]));
      });
    });

    group('HTTP 200', () {
      group('http logging interceptor response logging', () {
        late Response fakeResponse;

        setUp(() async {
          fakeResponse = Response<String>(
            http.Response(
              'responseBodyBase',
              200,
              headers: {'foo': 'bar'},
              request: await fakeRequest.toBaseRequest(),
            ),
            'responseBody',
          );
        });

        test('Http logger interceptor none level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.none, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger.intercept(FakeChain(fakeRequest));

          expect(
            logs,
            equals(
              [],
            ),
          );
        });

        test('Http logger interceptor basic level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.basic, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(logs, equals([]));
        });

        test('Http logger interceptor headers level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(logs, equals([]));
        });

        test('Http logger interceptor body level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(logs, equals([]));
        });
      });

      group('headers content-length not overridden', () {
        late Response fakeResponse;

        setUp(() async {
          fakeResponse = Response<String>(
            http.Response(
              'responseBodyBase',
              200,
              headers: {
                'foo': 'bar',
                'content-length': '42',
              },
              request: await fakeRequest.toBaseRequest(),
            ),
            'responseBody',
          );
        });

        test('request header level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));

          await logger.intercept(FakeChain(fakeRequest.copyWith(
              headers: {...fakeRequest.headers, 'content-length': '42'})));

          expect(logs, equals([]));
        });

        test('request body level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));

          await logger.intercept(FakeChain(fakeRequest.copyWith(
              headers: {...fakeRequest.headers, 'content-length': '42'})));

          expect(logs, equals([]));
        });

        test('response header level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(logs, equals([]));
        });
        test('response body level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(logs, equals([]));
        });
      });
    });

    group('HTTP 400', () {
      group('http logging interceptor response logging', () {
        late Response fakeResponse;

        setUp(() async {
          fakeResponse = Response<String>(
            http.Response(
              'responseBodyBase',
              400,
              headers: {'foo': 'bar'},
              request: await fakeRequest.toBaseRequest(),
            ),
            'responseBody',
          );
        });

        test('Http logger interceptor none level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.none, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger.intercept(FakeChain(fakeRequest));

          expect(
            logs,
            equals(
              [],
            ),
          );
        });

        test('Http logger interceptor basic level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.basic, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(
            logs,
            containsAll(
              [
                '',
                '<-- 400 POST base/ (0ms, 16-byte body)',
              ],
            ),
          );
        });

        test('Http logger interceptor headers level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(
            logs,
            containsAll(
              [
                '',
                '<-- 400 POST base/ (0ms)',
                'foo: bar',
                'content-length: 16',
                '<-- END HTTP',
              ],
            ),
          );
        });

        test('Http logger interceptor body level response', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(
            logs,
            containsAll(
              [
                '',
                '<-- 400 POST base/ (0ms)',
                'foo: bar',
                'content-length: 16',
                '',
                'responseBodyBase',
                '<-- END HTTP',
              ],
            ),
          );
        });
      });

      group('headers content-length not overridden', () {
        late Response fakeResponse;

        setUp(() async {
          fakeResponse = Response<String>(
            http.Response(
              'responseBodyBase',
              400,
              headers: {
                'foo': 'bar',
                'content-length': '42',
              },
              request: await fakeRequest.toBaseRequest(),
            ),
            'responseBody',
          );
        });

        test('request header level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));

          await logger.intercept(FakeChain(fakeRequest.copyWith(
              headers: {...fakeRequest.headers, 'content-length': '42'})));

          expect(logs, equals([]));
        });

        test('request body level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));

          await logger.intercept(FakeChain(fakeRequest.copyWith(
              headers: {...fakeRequest.headers, 'content-length': '42'})));

          expect(logs, equals([]));
        });

        test('response header level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.headers, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(
            logs,
            containsAll(
              [
                '',
                '<-- 400 POST base/ (0ms)',
                'foo: bar',
                'content-length: 42',
                '<-- END HTTP',
              ],
            ),
          );
        });
        test('response body level content-length', () async {
          final logger =
              HttpLoggingInterceptor(level: Level.body, onlyErrors: true);

          final logs = [];
          chopperLogger.onRecord.listen((r) => logs.add(r.message));
          await logger
              .intercept(FakeChain(fakeRequest, response: fakeResponse));

          expect(
            logs,
            containsAll(
              [
                '',
                '<-- 400 POST base/ (0ms)',
                'foo: bar',
                'content-length: 42',
                '',
                'responseBodyBase',
                '<-- END HTTP',
              ],
            ),
          );
        });
      });
    });
  });
}
