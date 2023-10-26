import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:meta/meta.dart';

final class ChopperLogRecord {
  const ChopperLogRecord(this.message, {this.request, this.response});

  final String message;
  final Request? request;
  final Response? response;

  @override
  String toString() => message;
}

///
/// [ChopperLogRecord] mixin for the purposes of creating mocks
/// using a mocking framework such as Mockito or Mocktail.
///
/// ```dart
/// base class MockChopperLogRecord extends Mock with MockChopperLogRecordMixin {}
/// ```
///
@visibleForTesting
base mixin MockChopperLogRecordMixin implements ChopperLogRecord {}
