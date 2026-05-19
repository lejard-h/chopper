import 'package:chopper/src/response.dart';

/// {@template ChopperHttpException}
/// An exception thrown when a [Response] cannot satisfy
/// [Response.bodyOrThrow] and [Response.error] is not an [Exception].
///
/// This can happen for unsuccessful responses (`statusCode < 200 ||
/// statusCode >= 300`) with no error or a non-[Exception] error, and for
/// successful responses whose [Response.body] is `null`. If [Response.error]
/// is an [Exception], [Response.bodyOrThrow] throws that error instead.
/// {@endtemplate}
class ChopperHttpException implements Exception {
  /// {@macro ChopperHttpException}
  ChopperHttpException(this.response);

  /// The response that caused the exception.
  final Response response;

  @override
  String toString() {
    return 'Could not fetch the response for ${response.base.request}. Status code: ${response.statusCode}, error: ${response.error}';
  }
}
