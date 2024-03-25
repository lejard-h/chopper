import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// {@template ChopperException}
/// An exception thrown when something goes wrong with Chopper.
/// {@endtemplate}
class ChopperException implements Exception {
  /// {@macro ChopperException}
  ChopperException(this.message, {this.response, this.request});

  /// The response that caused the exception.
  final Response? response;

  /// The request that caused the exception.
  final Request? request;

  /// The message of the exception.
  final String message;

  @override
  String toString() {
    return 'ChopperException: $message ${response != null ? ', \nResponse: $response' : ''}${request != null ? ', \nRequest: $request' : ''}';
  }
}
