import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:meta/meta.dart';

export 'package:chopper/src/interceptors/curl_interceptor.dart';
export 'package:chopper/src/interceptors/headers_interceptor.dart';
export 'package:chopper/src/interceptors/http_logging_interceptor.dart';

/// The interface for implementing interceptors.
/// Interceptors are used for intercepting request, responses and preforming operations on them.
///
/// Interceptor are called in a Chain order.
/// The first interceptor in the chain calls the next interceptor in the chain and so on.
/// The last interceptor in the chain return the response back to the previous interceptor in the chain and so on.
/// This means the request are processed in the order defined by the chain.
/// The responses are process in the reverse order defined by the chain.
///
/// Chopper has a few built-in interceptors which can be inspected as fully working examples:
/// [HttpLoggingInterceptor], [CurlInterceptor] and [HeaderInterceptor].
///
/// A short example for adding an authentication token to every request:
///
/// ```dart
/// class MyRequestInterceptor implements Interceptor {
///   final String token;
///
///   @override
///   FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
///     final request = applyHeader(chain.request, 'auth_token', 'Bearer $token');
///     return chain.proceed(request);
///   }
/// }
/// ```
/// A short example for extracting a header value from a response:
///
/// ```dart
/// class MyResponseInterceptor implements Interceptor {
///   String _token;
///
///   @override
///   FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
///     final response = await chain.proceed(chain.request);
///
///     _token = response.headers['auth_token'];
///     return response;
///   }
/// }
/// ```
///
/// **While [Interceptor]s *can* modify the body of requests and responses,
/// converting (encoding) the request/response body should be handled by [Converter]s.**
@immutable
abstract interface class Interceptor {
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain);
}
