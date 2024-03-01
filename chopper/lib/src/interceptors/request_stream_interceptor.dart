import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class RequestStreamInterceptor implements InternalInterceptor {
  const RequestStreamInterceptor(this.callback);

  final void Function(Request event) callback;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    callback(chain.request);

    return chain.proceed(chain.request);
  }
}
