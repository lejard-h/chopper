import 'dart:async' show TimeoutException;

/// Wrapper around [TimeoutException] to avoid exposing dart:async in the public API.
class ChopperTimeoutException extends TimeoutException {
  ChopperTimeoutException([super.message, super.duration]);

  @override
  String toString() {
    String result = 'ChopperTimeoutException';
    if (duration != null) result = 'ChopperTimeoutException after $duration';
    if (message != null) result = '$result: $message';
    return result;
  }
}
