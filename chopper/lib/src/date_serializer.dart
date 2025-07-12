import 'package:qs_dart/qs_dart.dart' as qs show DateSerializer;

/// Enum defining different serialization strategies for DateTime objects.
///
/// Each serializer converts a DateTime to a string representation suitable
/// for different use cases (APIs, databases, etc.).
enum DateSerializer {
  /// Converts DateTime to seconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200"
  seconds(_seconds),

  /// Converts DateTime to milliseconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200000"
  milliseconds(_milliseconds),

  /// Converts DateTime to microseconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200000000"
  microseconds(_microseconds),

  /// Converts DateTime to UTC ISO8601 string.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000Z"
  utcIso8601(_utcIso8601),

  /// Converts DateTime to local ISO8601 string.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000"
  localIso8601(_localIso8601),

  /// Converts DateTime to ISO8601 string in current timezone.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000"
  iso8601(_iso8601),

  /// Converts DateTime to default string representation.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01 00:00:00.000"
  string(_string);

  const DateSerializer(this.serializer);

  final qs.DateSerializer serializer;

  @override
  String toString() => name;

  static String _seconds(DateTime datetime) =>
      (datetime.millisecondsSinceEpoch / 1000).round().toString();

  static String _milliseconds(DateTime datetime) =>
      datetime.millisecondsSinceEpoch.toString();

  static String _microseconds(DateTime datetime) =>
      datetime.microsecondsSinceEpoch.toString();

  static String _utcIso8601(DateTime datetime) =>
      datetime.toUtc().toIso8601String();

  static String _localIso8601(DateTime datetime) =>
      datetime.toLocal().toIso8601String();

  static String _string(DateTime datetime) => datetime.toString();

  static String _iso8601(DateTime datetime) => datetime.toIso8601String();
}
