import 'dart:async';

import 'package:chopper/src/chain/call.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class InterceptorChain<BodyType> implements Chain<BodyType> {
  InterceptorChain({
    required this.interceptors,
    required this.request,
    required this.call,
    this.index = 0,
  });

  @override
  final Request request;
  final Call call;
  final List<Interceptor> interceptors;
  final int index;

  int calls = 0;

  bool get exchangable =>
      index - 1 >= 0 && interceptors[index - 1] is InternalInterceptor;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    assert(index < interceptors.length);

    calls++;

    final next = copyWith<BodyType>(request: request, index: index + 1);
    final interceptor = interceptors[index];

    if (interceptor is! InternalInterceptor) {
      assert(
        call.request.body == request.body,
        'Interceptors should not transform the body of the request'
        'Use Request converter instead',
      );
      assert(
        calls == 1,
        'interceptor ${interceptors[index - 1]} much call proceed exactly once',
      );
    }

    final Response<BodyType> response =
        await interceptor.intercept<BodyType>(next);

    //TODO(Guldem): Hard to check if response has been modified.
    if (interceptor is! InternalInterceptor) {
      assert(
        index + 1 >= interceptors.length || next.calls == 1,
        'interceptor $interceptor must call proceed() exactly once',
      );
    }

    return response;
  }



  InterceptorChain<T> copyWith<T>({
    Request? request,
    int? index,
  }) =>
      InterceptorChain<T>(
        request: request ?? this.request,
        index: index ?? this.index,
        interceptors: interceptors,
        call: call,
      );
}
