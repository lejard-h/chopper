import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// Represents the type of error occurred in Chopper.
enum ChopperExceptionType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badResponse,
  cancel,
  connectionError,
  unknown,
}

extension ChopperExceptionTypeDescription on ChopperExceptionType {
  String toPrettyDescription() {
    switch (this) {
      case ChopperExceptionType.connectionTimeout:
        return 'connection timeout';
      case ChopperExceptionType.sendTimeout:
        return 'send timeout';
      case ChopperExceptionType.receiveTimeout:
        return 'receive timeout';
      case ChopperExceptionType.badResponse:
        return 'bad response';
      case ChopperExceptionType.cancel:
        return 'request cancelled';
      case ChopperExceptionType.connectionError:
        return 'connection error';
      case ChopperExceptionType.unknown:
        return 'unknown';
    }
  }
}

class ChopperException implements Exception {
  final Request request;
  final Response? response;
  final ChopperExceptionType type;
  final Object? error;
  final StackTrace stackTrace;
  final String? message;

  static ChopperExceptionReadableStringBuilder readableStringBuilder =
      defaultChopperExceptionReadableStringBuilder;

  ChopperExceptionReadableStringBuilder? stringBuilder;

  ChopperException({
    required this.request,
    this.response,
    this.type = ChopperExceptionType.unknown,
    this.error,
    StackTrace? stackTrace,
    this.message,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  factory ChopperException.badResponse({
    required int statusCode,
    required Request request,
    required Response response,
  }) =>
      ChopperException(
        type: ChopperExceptionType.badResponse,
        request: request,
        response: response,
        message: _badResponseExceptionMessage(statusCode),
      );

  factory ChopperException.connectionTimeout({
    required Duration timeout,
    required Request request,
    Object? error,
  }) =>
      ChopperException(
        type: ChopperExceptionType.connectionTimeout,
        request: request,
        error: error,
        message: 'Connection timed out after $timeout.',
      );

  factory ChopperException.sendTimeout({
    required Duration timeout,
    required Request request,
  }) =>
      ChopperException(
        type: ChopperExceptionType.sendTimeout,
        request: request,
        message: 'Send timeout after $timeout.',
      );

  factory ChopperException.receiveTimeout({
    required Duration timeout,
    required Request request,
  }) =>
      ChopperException(
        type: ChopperExceptionType.receiveTimeout,
        request: request,
        message: 'Receive timeout after $timeout.',
      );

  factory ChopperException.cancel({
    required Request request,
    Object? reason,
  }) =>
      ChopperException(
        type: ChopperExceptionType.cancel,
        request: request,
        error: reason,
        message: 'Request was cancelled.',
      );

  factory ChopperException.connectionError({
    required Request request,
    String? reason,
    Object? error,
  }) =>
      ChopperException(
        type: ChopperExceptionType.connectionError,
        request: request,
        error: error,
        message: 'Connection error: $reason',
      );

  ChopperException copyWith({
    Request? request,
    Response? response,
    ChopperExceptionType? type,
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) {
    return ChopperException(
      request: request ?? this.request,
      response: response ?? this.response,
      type: type ?? this.type,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    try {
      return stringBuilder?.call(this) ?? readableStringBuilder(this);
    } catch (e) {
      return defaultChopperExceptionReadableStringBuilder(this);
    }
  }

  static String _badResponseExceptionMessage(int statusCode) {
    final String message;
    if (statusCode >= 100 && statusCode < 200) {
      message = 'Informational response';
    } else if (statusCode >= 200 && statusCode < 300) {
      message = 'Success response';
    } else if (statusCode >= 300 && statusCode < 400) {
      message = 'Redirection';
    } else if (statusCode >= 400 && statusCode < 500) {
      message = 'Client error';
    } else if (statusCode >= 500 && statusCode < 600) {
      message = 'Server error';
    } else {
      message = 'Non-standard HTTP response code';
    }

    return 'HTTP status $statusCode: $message';
  }
}

/// Signature for building a string from ChopperException.
typedef ChopperExceptionReadableStringBuilder = String Function(
    ChopperException e);

/// Default implementation of ChopperException toString().
String defaultChopperExceptionReadableStringBuilder(ChopperException e) {
  final buffer = StringBuffer(
    'ChopperException [${e.type.toPrettyDescription()}]: ${e.message}',
  );
  if (e.error != null) {
    buffer.writeln();
    buffer.write('Error: ${e.error}');
  }
  return buffer.toString();
}
