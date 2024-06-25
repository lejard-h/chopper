import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/response_converter_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late InterceptorChain interceptorChain;
  final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'));

  group('response converter tests', () {
    test(
        'response is successful converter is null and response converter is null, response is not converted',
        () async {
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, 'TestResponse');
    });

    test(
        'response is successful converter is not null and response converter is null, response is converted',
        () async {
      final converter = ResponseConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(converter: converter),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, 'converted');
      expect(converter.called, 1);
    });

    test(
        'response is successful converter is not null and response converter is not null, response is converted by response converter',
        () async {
      final converter = ResponseConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(
              converter: converter,
              responseConverter: (response) =>
                  response.copyWith(body: 'response converted')),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, 'response converted');
      expect(converter.called, 0);
    });

    test(
        'response is successful converter is not null and response converter is null, response is converted with null body',
        () async {
      final converter = ResponseNullBodyConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(converter: converter),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, null);
      expect(converter.called, 1);
    });

    test(
        'response is successful converter is not null and response converter is not null, response is converted by response converter with null body',
        () async {
      final converter = ResponseNullBodyConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(
              converter: converter,
              responseConverter: (response) => Response(response.base, null)),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, null);
      expect(converter.called, 0);
    });

    test(
        'response is unsuccessful converter is not null and response converter is not null, response is not converted',
        () async {
      final converter = ResponseConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(
              converter: converter,
              responseConverter: (response) =>
                  response.copyWith(body: 'response converted')),
          ResponseInterceptor(
              response: Response<String>(
                  http.Response('error base', 500, request: testRequest),
                  'error')),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, null);
      expect(response.error, 'error');
      expect(converter.called, 0);
    });
  });

  group('response error converter tests', () {
    final errorResponse = Response<String>(
        http.Response('error base', 500, request: testRequest), 'error');
    test(
        'response is unsuccessful converter is null, response is not converted',
        () async {
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(),
          ResponseInterceptor(response: errorResponse),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, null);
      expect(response.error, 'error');
    });

    test(
        'response is unsuccessful converter is not null, response is converted',
        () async {
      final converter = ResponseErrorConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(errorConverter: converter),
          ResponseInterceptor(response: errorResponse),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, null);
      expect(response.error, 'converted');
      expect(converter.called, 1);
    });

    test(
        'response is successful converter is not null, response is not converter',
        () async {
      final converter = ResponseErrorConverter();
      interceptorChain = InterceptorChain(
        interceptors: [
          ResponseConverterInterceptor(errorConverter: converter),
          ResponseInterceptor(),
        ],
        request: testRequest,
      );

      final response = await interceptorChain.proceed(testRequest);

      expect(response.body, 'TestResponse');
      expect(converter.called, 0);
    });
  });

  group('response converter returns converted response tests', () {});
}

// ignore mutability warning for test class.
//ignore: must_be_immutable
class ResponseConverter implements Converter {
  int called = 0;

  @override
  FutureOr<Request> convertRequest(Request request) {
    return request;
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
      Response response) {
    called++;
    return response.copyWith(body: 'converted' as BodyType);
  }
}

// ignore mutability warning for test class.
//ignore: must_be_immutable
class ResponseNullBodyConverter implements Converter {
  int called = 0;

  @override
  FutureOr<Request> convertRequest(Request request) {
    return request;
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
      Response response) {
    called++;
    return Response(response.base, null as BodyType);
  }
}

// ignore mutability warning for test class.
//ignore: must_be_immutable
class ResponseErrorConverter implements ErrorConverter {
  int called = 0;

  @override
  FutureOr<Response<BodyType>> convertError<BodyType, InnerType>(
      Response response) {
    called++;
    return response.copyWith(body: 'converted' as BodyType);
  }
}

class ResponseInterceptor implements Interceptor {
  ResponseInterceptor({this.response});

  final Response? response;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    return response as Response<BodyType>? ??
        Response(
            http.Response('TestResponse base', 200, request: chain.request),
            'TestResponse' as BodyType);
  }
}
