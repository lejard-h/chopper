import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class ChopperLogRecord {
  const ChopperLogRecord(this.message, {this.request, this.response});

  final String message;
  final Request? request;
  final Response? response;

  @override
  String toString() => message;
}
