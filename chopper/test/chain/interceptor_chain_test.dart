import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/interceptor_chain.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/interceptors/request_converter_interceptor.dart';
import 'package:chopper/src/interceptors/response_converter_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('InterceptorChain', () {
    late Request mockRequest;
    late MockInterceptor mockInterceptor;
    late InterceptorChain interceptorChain;

    setUp(() {
      mockRequest =
          Request('GET', Uri.parse('bar'), Uri.parse('http://localhost'));
      mockInterceptor = MockInterceptor();
      interceptorChain = InterceptorChain(
        interceptors: [mockInterceptor],
        request: mockRequest,
      );
    });

    test('is created correctly', () {
      expect(interceptorChain.interceptors, [mockInterceptor]);
      expect(interceptorChain.request, mockRequest);
    });

    test('copyWith method works as expected', () {
      final newRequest =
          Request('GET', Uri.parse('foo'), Uri.parse('http://localhost'));
      final copiedChain =
          interceptorChain.copyWith(request: newRequest, index: 666);
      expect(copiedChain.request, newRequest);
      expect(copiedChain.interceptors, [mockInterceptor]);
      expect(copiedChain.index, 666);
    });

    test('A empty Interceptor chain throws assertion', () {
      expect(
          () => InterceptorChain(
                interceptors: [],
                request: mockRequest,
              ),
          throwsA(isA<AssertionError>()));
    });

    test(
        'Intercept chain proceed called with index out of bounds throws assertion',
        () async {
      final chain = InterceptorChain(
        interceptors: [mockInterceptor],
        request: mockRequest,
        index: 666,
      );
      expect(chain.proceed(mockRequest), throwsA(isA<AssertionError>()));
    });
  });

  group('interceptor chain proceed tests', () {
    late Request mockRequest;
    late MockInterceptor mockInterceptor;
    late InterceptorChain interceptorChain;
    setUp(() {
      mockRequest = Request(
        'GET',
        Uri.parse('bar'),
        Uri.parse('http://localhost'),
        body: 'Test',
      );
      mockInterceptor = MockInterceptor();
      interceptorChain = InterceptorChain(
        interceptors: [mockInterceptor],
        request: mockRequest,
      );
    });

    test('proceed method works as expected, invokes the interceptor', () async {
      final response = await interceptorChain.proceed(mockRequest);
      expect(response.base.request, mockRequest);
      expect(response.body, 'TestResponse');
      expect(mockInterceptor.called, 1);
    });

    test('proceed modifies request body, throws assertion', () async {
      interceptorChain = InterceptorChain(
        interceptors: [RequestModifierInterceptor(), mockInterceptor],
        request: mockRequest,
      );

      expect(
        () => interceptorChain.proceed(mockRequest),
        throwsA(
          isA<AssertionError>().having(
              (e) => e.message,
              'assertion',
              'Interceptor [RequestModifierInterceptor] should not transform the body of the request, '
                  'Use Request converter instead'),
        ),
      );
    });

    test('proceed modifies response body, throws assertion', () async {
      interceptorChain = InterceptorChain(
        interceptors: [ResponseModifierInterceptor(), mockInterceptor],
        request: mockRequest,
      );

      expect(
        () => interceptorChain.proceed(mockRequest),
        throwsA(
          isA<AssertionError>().having(
              (e) => e.message,
              'assertion',
              'Interceptor [ResponseModifierInterceptor] should not transform the body of the response, '
                  'Use Response converter instead'),
        ),
      );
    });

    test(
        'Internal interceptor is allowed modify request/response when proceeding, return normally',
        () async {
      interceptorChain = InterceptorChain(
        interceptors: [InternalModifierInterceptor(), mockInterceptor],
        request: mockRequest,
      );

      expect(
        () => interceptorChain.proceed(mockRequest),
        returnsNormally,
      );
    });

    test('proceed chain is broken before reaching the end, returns normally',
        () {
      interceptorChain = InterceptorChain(
        interceptors: [
          PassthroughInterceptor(),
          mockInterceptor,
          PassthroughInterceptor(),
        ],
        request: mockRequest,
      );

      expect(
        () => interceptorChain.proceed(mockRequest),
        returnsNormally,
      );
    });
  });

  group('Chain exception tests', () {
    late Request mockRequest;
    late InterceptorChain interceptorChain;
    setUp(() {
      mockRequest = Request(
        'GET',
        Uri.parse('bar'),
        Uri.parse('http://localhost'),
        body: 'Test',
      );
    });

    test('Exception thrown inside the interceptor chain will be passed up',
        () async {
      interceptorChain = InterceptorChain(
        interceptors: [
          RequestConverterInterceptor(null, null),
          PassthroughInterceptor(),
          PassthroughInterceptor(),
          ResponseConverterInterceptor(
            converter: null,
            errorConverter: null,
            responseConverter: null,
          ),
          ExceptionThrowingInterceptor(),
        ],
        request: mockRequest,
      );

      expect(
        () => interceptorChain.proceed(mockRequest),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', 'Exception: Test exception')),
      );
    });
  });
}

class ExceptionThrowingInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    throw Exception('Test exception');
  }
}

class RequestModifierInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    return chain.proceed(
      chain.request.copyWith(
        body: '${chain.request.body} modified!',
      ),
    );
  }
}

class ResponseModifierInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final response = await chain.proceed(chain.request);

    return response.copyWith<BodyType>(
        body: '${response.body ?? ''} modified!' as BodyType);
  }
}

class DoubleProceedInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final _ = await chain.proceed(chain.request);
    final response2 = await chain.proceed(chain.request);

    return response2;
  }
}

class PassthroughInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    return await chain.proceed(chain.request);
  }
}

class InternalModifierInterceptor implements InternalInterceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final request = chain.request.copyWith(
      body: '${chain.request.body} modified!',
    );

    final response = await chain.proceed(request);

    return response.copyWith<BodyType>(
        body: '${response.body ?? ''} modified!' as BodyType);
  }
}

// ignore: must_be_immutable
class MockInterceptor implements InternalInterceptor {
  MockInterceptor({this.response});

  int called = 0;

  final Response? response;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    called++;
    return response as Response<BodyType>? ??
        Response(http.Response('TestResponse', 200, request: chain.request),
            'TestResponse' as BodyType);
  }
}
