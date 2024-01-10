import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class InterceptorChain<BodyType> implements Chain<BodyType> {
  InterceptorChain({
    required this.interceptors,
    required this.request,
    this.index = 0,
  }) : assert(interceptors.isNotEmpty, 'Interceptors list must not be empty');

  @override
  final Request request;
  Response<BodyType>? response;
  final List<Interceptor> interceptors;
  final int index;

  int calls = 0;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    assert(index < interceptors.length, 'Interceptor index out of bounds');
    if(index -1 >= 0 && interceptors[index -1] is! InternalInterceptor) {
      assert(
      this.request.body == request.body,
      'Interceptor [${interceptors[index - 1]
          .runtimeType}] should not transform the body of the request, '
          'Use Request converter instead',
      );
    }

    calls++;

    final interceptor = interceptors[index];
    final next = copyWith<BodyType>(request: request, index: index + 1);
    response = await interceptor.intercept<BodyType>(next);

    if (index + 1 < interceptors.length && interceptor is! InternalInterceptor) {
      if (response == null) {
        throw Exception('Response is null');
      }

      assert(
        response?.body == next.response?.body,
        'Interceptor [${interceptor.runtimeType}] should not transform the body of the response, '
        'Use Response converter instead',
      );
    }

    return response!;
  }

  InterceptorChain<T> copyWith<T>({
    Request? request,
    int? index,
  }) =>
      InterceptorChain<T>(
        request: request ?? this.request,
        index: index ?? this.index,
        interceptors: interceptors,
      );
}
