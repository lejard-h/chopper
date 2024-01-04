import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_call.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class RealInterceptorChain implements Chain {
  RealInterceptorChain({
    required this.interceptors,
    required this.request,
    required this.exchangable,
    required this.call,
    this.index = 0,
  });

  final bool exchangable;

  @override
  final Request request;
  final RealCall call;
  final List<Interceptor> interceptors;
  final int index;

  int calls = 0;

  @override
  FutureOr<Response<BodyType>> proceed<BodyType, InnerType>(
    Request request,
  ) async {
    assert(index < interceptors.length);

    calls++;

    if (!exchangable) {
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

    final next = copyWith(request: request, index: index + 1);
    final interceptor = interceptors[index];
    final Response<BodyType> response =
        await interceptor.intercept<BodyType, InnerType>(next);

    //TODO(Guldem): Hard to check if response has been modified.
    if (!exchangable) {
      assert(
        calls == 1,
        'interceptor $interceptor must call proceed() exactly once',
      );
    }

    return response;
  }

  RealInterceptorChain copyWith({
    Request? request,
    bool? exchangable,
    int? index,
  }) =>
      RealInterceptorChain(
        request: request ?? this.request,
        index: index ?? this.index,
        exchangable: exchangable ?? this.exchangable,
        interceptors: interceptors,
        call: call,
      );
}
