import 'package:chopper/src/response.dart';

/// An exception thrown when a [Response] is unsuccessful < 200 or > 300.
class ChopperHttpException implements Exception {
  ChopperHttpException(this.response);

  final Response response;

  @override
  String toString() {
    return 'Could not fetch the response for ${response.base.request}. Status code: ${response.statusCode}, error: ${response.error}';
  }
}
