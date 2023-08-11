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

@visibleForTesting
base mixin MockChopperLogRecordMixin implements ChopperLogRecord {}
