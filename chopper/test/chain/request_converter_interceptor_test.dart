import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/request_converter_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late InterceptorChain interceptorChain;

  test('request body is null and parts is empty, is not converted', () async {
    final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'));
    final converter = RequestConverter();
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(
          converter,
          null,
        ),
        RequestInterceptor(onRequest: (request) {
          expect(request.body, null);
        }),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(converter.called, 0);
  });

  test(
      'request body is not null and parts is empty, requestConverter is not provided, request is converted by converter',
      () async {
    final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'),
        body: 'not converted');
    final converter = RequestConverter();
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(
          converter,
          null,
        ),
        RequestInterceptor(onRequest: (request) {
          expect(request.body, 'converted');
        }),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(converter.called, 1);
  });

  test(
      'request body is null and parts is not empty, requestConverter is not provided, request is converted by converter',
      () async {
    final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'),
        parts: [PartValue('not converted', 1)]);
    final converter = RequestConverter();
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(
          converter,
          null,
        ),
        RequestInterceptor(onRequest: (request) {
          expect(request.body, 'converted');
        }),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(converter.called, 1);
  });

  test(
      'request body is not null and parts is empty, requestConverter is provided, request is converted by requestConverter',
      () async {
    final testRequest = Request('GET', Uri.parse('foo'), Uri.parse('bar'),
        body: 'not converted');
    final converter = RequestConverter();
    int called = 0;
    interceptorChain = InterceptorChain(
      interceptors: [
        RequestConverterInterceptor(
          converter,
          (req) {
            called++;
            return req.copyWith(body: 'foo');
          },
        ),
        RequestInterceptor(onRequest: (request) {
          expect(request.body, 'foo');
        }),
      ],
      request: testRequest,
    );

    await interceptorChain.proceed(testRequest);

    expect(called, 1);
    expect(converter.called, 0);
  });
}

// ignore mutability warning for test class.
//ignore: must_be_immutable
class RequestConverter implements Converter {
  int called = 0;
  @override
  FutureOr<Request> convertRequest(Request request) {
    called++;
    return request.copyWith(body: 'converted');
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
      Response response) {
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
    return Response(http.Response('TestResponse', 200, request: chain.request),
        'TestResponse' as BodyType);
  }
}
