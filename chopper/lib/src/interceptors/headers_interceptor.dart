import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:meta/meta.dart';

/// {@template HeadersInterceptor}
/// A [Interceptor] that adds [headers] to every request.
///
/// Note that this interceptor will overwrite existing headers having the same
/// keys as [headers].
/// {@endtemplate}
@immutable
class HeadersInterceptor implements Interceptor {
  final Map<String, String> headers;

  /// {@macro HeadersInterceptor}
  const HeadersInterceptor(this.headers);

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
          Chain<BodyType> chain) async =>
      chain.proceed(
        applyHeaders(
          chain.request,
          headers,
        ),
      );
}
