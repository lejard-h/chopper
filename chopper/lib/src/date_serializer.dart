import 'package:qs_dart/qs_dart.dart' as qs;

enum DateSerializer {

  /// millisecondsSinceEpoch
  milliseconds(_milliseconds),

  /// toUtc().toIso8601String
  utcIso8601(_utcIso8601),

  /// toLocal().toIso8601String()
  localIso8601(_localIso8601),

  /// toIso8601String()
  iso8601(_iso8601),

  /// toString()
  string(_string)

  ;

  const DateSerializer(this.serializer);

  final qs.DateSerializer serializer;

  @override
  String toString() => name;

  static String? _milliseconds(DateTime datetime) => datetime.millisecondsSinceEpoch.toString();

  static String? _utcIso8601(DateTime datetime) => datetime.toUtc().toIso8601String();

  static String? _localIso8601(DateTime datetime) => datetime.toLocal().toIso8601String();

  static String? _string(DateTime datetime) => datetime.toString();

  static String? _iso8601(DateTime datetime) => datetime.toIso8601String();
}