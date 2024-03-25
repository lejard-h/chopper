import 'package:chopper/src/response.dart';

/// {@template ChopperHttpException}
/// An exception thrown when a [Response] is unsuccessful < 200 or > 300.
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
