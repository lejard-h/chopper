import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/base.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/request_converter_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  late InterceptorChain interceptorChain;

  test('request body is null and parts is empty, is not converted', () async {
    final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'));
    final converter = RequestConverter();
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(converter, null),
        RequestInterceptor(
          onRequest: (request) {
            expect(request.body, null);
          },
        ),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(converter.called, 0);
  });

  test(
    'query-only request is converted by parameterConverter, not converter',
    () async {
      final testRequest = Request(
        'GET',
        Uri.parse('/foo'),
        Uri.parse('https://example.com'),
        parameters: {'value': const _ParameterValue('raw')},
      );
      final converter = RequestConverter();
      final parameterConverter = _TestParameterConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          RequestConverterInterceptor(converter, null, parameterConverter),
          RequestInterceptor(
            onRequest: (request) {
              expect(request.url.queryParameters['value'], 'converted-raw');
              expect(request.parameters['value'], 'converted-raw');
            },
          ),
        ],
        request: testRequest,
      );

      await interceptorChain.proceed(testRequest);

      expect(converter.called, 0);
      expect(parameterConverter.called, 1);
    },
  );

  test(
    'converter is used as parameterConverter when no explicit converter exists',
    () async {
      final converter = _RequestAndParameterConverter();
      final httpClient = MockClient((request) async {
        expect(request.url.queryParameters['value'], 'converted-raw');

        return http.Response('TestResponse', 200);
      });
      final client = ChopperClient(
        baseUrl: Uri.parse('https://example.com'),
        client: httpClient,
        converter: converter,
      );

      await client.get<String, String>(
        Uri.parse('/foo'),
        parameters: {'value': const _ParameterValue('raw')},
      );

      expect(converter.called, 0);
      expect(converter.parameterCalled, 1);
      httpClient.close();
    },
  );

  test('explicit parameterConverter takes precedence over converter', () async {
    final converter = _RequestAndParameterConverter();
    final parameterConverter = _TestParameterConverter();
    final httpClient = MockClient((request) async {
      expect(request.url.queryParameters['value'], 'converted-raw');

      return http.Response('TestResponse', 200);
    });
    final client = ChopperClient(
      baseUrl: Uri.parse('https://example.com'),
      client: httpClient,
      converter: converter,
      parameterConverter: parameterConverter,
    );

    await client.get<String, String>(
      Uri.parse('/foo'),
      parameters: {'value': const _ParameterValue('raw')},
    );

    expect(converter.parameterCalled, 0);
    expect(parameterConverter.called, 1);
    httpClient.close();
  });

  test('onRequest stream emits converted query parameters', () async {
    final httpClient = MockClient((request) async {
      return http.Response('TestResponse', 200);
    });
    final client = ChopperClient(
      baseUrl: Uri.parse('https://example.com'),
      client: httpClient,
      parameterConverter: _TestParameterConverter(),
    );
    addTearDown(client.dispose);
    addTearDown(httpClient.close);

    final emittedRequest = client.onRequest.first;

    await client.get<String, String>(
      Uri.parse('/foo'),
      parameters: {'value': const _ParameterValue('raw')},
    );

    final request = await emittedRequest;
    expect(request.url.queryParameters['value'], 'converted-raw');
    expect(request.parameters['value'], 'converted-raw');
  });

  test('query parameter conversion preserves nested query formatting', () {
    final converted = convertQueryParameterMap({
      'filters': {
        'items': [const _ParameterValue('a'), const _ParameterValue('b')],
      },
    }, _TestParameterConverter());
    final request = Request(
      'GET',
      Uri.parse('/foo'),
      Uri.parse('https://example.com'),
      parameters: converted,
    );

    expect(request.url.queryParametersAll['filters.items'], [
      'converted-a',
      'converted-b',
    ]);
  });

  test('query parameter conversion detects cycles', () {
    final cyclic = <String, dynamic>{};
    cyclic['self'] = cyclic;

    expect(
      () => convertQueryParameterMap({
        'value': cyclic,
      }, _TestParameterConverter()),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Cyclic query parameter value at "value.self".',
        ),
      ),
    );
  });

  test('query parameter conversion detects iterable cycles', () {
    final cyclic = <dynamic>[];
    cyclic.add(cyclic);

    expect(
      () => convertQueryParameterMap({
        'value': cyclic,
      }, _TestParameterConverter()),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Cyclic query parameter value at "value[0]".',
        ),
      ),
    );
  });

  test('query parameter conversion allows shared non-cyclic values', () {
    final shared = {'value': const _ParameterValue('shared')};
    final converted = convertQueryParameterMap({
      'left': shared,
      'right': shared,
    }, _TestParameterConverter());

    expect(converted['left'], {'value': 'converted-shared'});
    expect(converted['right'], {'value': 'converted-shared'});
  });

  test(
    'request body is not null and parts is empty, requestConverter is not provided, request is converted by converter',
    () async {
      final testRequest = Request(
        'GET',
        Uri.parse('foo'),
        Uri.parse('bar'),
        body: 'not converted',
      );
      final converter = RequestConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          RequestConverterInterceptor(converter, null),
          RequestInterceptor(
            onRequest: (request) {
              expect(request.body, 'converted');
            },
          ),
        ],
        request: testRequest,
      );

      await interceptorChain.proceed(testRequest);

      expect(converter.called, 1);
    },
  );

  test('request with body converts query parameters and body', () async {
    final testRequest = Request(
      'POST',
      Uri.parse('/foo'),
      Uri.parse('https://example.com'),
      body: 'not converted',
      parameters: {'value': const _ParameterValue('raw')},
    );
    final converter = RequestConverter(
      onConvertRequest: (request) {
        expect(request.url.queryParameters['value'], 'converted-raw');
        expect(request.parameters['value'], 'converted-raw');
      },
    );
    final parameterConverter = _TestParameterConverter();
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(converter, null, parameterConverter),
        RequestInterceptor(
          onRequest: (request) {
            expect(request.body, 'converted');
            expect(request.url.queryParameters['value'], 'converted-raw');
          },
        ),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(converter.called, 1);
    expect(parameterConverter.called, 1);
  });

  test(
    'request body is null and parts is not empty, requestConverter is not provided, request is converted by converter',
    () async {
      final testRequest = Request(
        'GET',
        Uri.parse('foo'),
        Uri.parse('bar'),
        parts: [const PartValue('not converted', 1)],
      );
      final converter = RequestConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          RequestConverterInterceptor(converter, null),
          RequestInterceptor(
            onRequest: (request) {
              expect(request.body, 'converted');
            },
          ),
        ],
        request: testRequest,
      );

      await interceptorChain.proceed(testRequest);

      expect(converter.called, 1);
    },
  );

  test(
    'request body is not null and parts is empty, requestConverter is provided, request is converted by requestConverter',
    () async {
      final testRequest = Request(
        'GET',
        Uri.parse('foo'),
        Uri.parse('bar'),
        body: 'not converted',
      );
      final converter = RequestConverter();
      int called = 0;
      interceptorChain = InterceptorChain(
        interceptors: [
          RequestConverterInterceptor(converter, (req) {
            called++;
            return req.copyWith(body: 'foo');
          }),
          RequestInterceptor(
            onRequest: (request) {
              expect(request.body, 'foo');
            },
          ),
        ],
        request: testRequest,
      );

      await interceptorChain.proceed(testRequest);

      expect(called, 1);
      expect(converter.called, 0);
    },
  );
}

final class _ParameterValue {
  const _ParameterValue(this.value);

  final String value;
}

// ignore: must_be_immutable
class _TestParameterConverter implements ParameterConverter {
  int called = 0;

  @override
  Object? convertParameter(
    Object? parameter,
    ParameterConversionContext context,
  ) {
    called++;
    if (parameter is _ParameterValue) return 'converted-${parameter.value}';

    return parameter;
  }
}

// ignore: must_be_immutable
class _RequestAndParameterConverter extends RequestConverter
    implements ParameterConverter {
  int parameterCalled = 0;

  @override
  Object? convertParameter(
    Object? parameter,
    ParameterConversionContext context,
  ) {
    parameterCalled++;
    if (parameter is _ParameterValue) return 'converted-${parameter.value}';

    return parameter;
  }
}

// ignore mutability warning for test class.
//ignore: must_be_immutable
class RequestConverter implements Converter {
  RequestConverter({this.onConvertRequest});

  final void Function(Request request)? onConvertRequest;
  int called = 0;
  @override
  FutureOr<Request> convertRequest(Request request) {
    called++;
    onConvertRequest?.call(request);
    return request.copyWith(body: 'converted');
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) {
    return response as Response<BodyType>;
  }
}

// ignore: must_be_immutable
class RequestInterceptor implements Interceptor {
  RequestInterceptor({this.onRequest});

  final void Function(Request)? onRequest;
  int called = 0;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    called++;
    onRequest?.call(chain.request);
    return Response(
      http.Response('TestResponse', 200, request: chain.request),
      'TestResponse' as BodyType,
    );
  }
}
