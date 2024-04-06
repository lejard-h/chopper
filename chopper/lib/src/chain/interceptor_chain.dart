import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chopper_exception.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// {@template InterceptorChain}
/// A chain of interceptors that are called in order to process requests and responses.
/// {@endtemplate}
class InterceptorChain<BodyType> implements Chain<BodyType> {
  /// {@macro InterceptorChain}
  InterceptorChain({
    required this.interceptors,
    required this.request,
    this.index = 0,
  }) : assert(interceptors.isNotEmpty, 'Interceptors list must not be empty');

  @override
  final Request request;

  /// Response received from the next interceptor in the chain.
  Response<BodyType>? response;

  /// List of interceptors to be called in order.
  final List<Interceptor> interceptors;

  /// Index of the current interceptor in the chain.
  final int index;

  @override
  FutureOr<Response<BodyType>> proceed(Request request) async {
    assert(index < interceptors.length, 'Interceptor index out of bounds');
    if (index - 1 >= 0 && interceptors[index - 1] is! InternalInterceptor) {
      assert(
        this.request.body == request.body,
        'Interceptor [${interceptors[index - 1].runtimeType}] should not transform the body of the request, '
        'Use Request converter instead',
      );
    }

    final interceptor = interceptors[index];
    final next = copyWith<BodyType>(request: request, index: index + 1);
    response = await interceptor.intercept<BodyType>(next);

    if (index + 1 < interceptors.length &&
        interceptor is! InternalInterceptor) {
      if (response == null) {
        throw ChopperException('Response is null', request: request);
      }

      assert(
        response?.body == next.response?.body,
        'Interceptor [${interceptor.runtimeType}] should not transform the body of the response, '
        'Use Response converter instead',
      );
    }

    return response!;
  }

  /// Copy the current [InterceptorChain]. With updated [request] or [index].
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
