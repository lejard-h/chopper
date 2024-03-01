import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/request.dart';
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
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final Request request = applyHeaders(chain.request, headers);

    return chain.proceed(request);
  }
}
