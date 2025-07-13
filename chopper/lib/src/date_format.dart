import 'package:qs_dart/qs_dart.dart' as qs show DateSerializer;

/// Enum defining different serialization strategies for DateTime objects.
///
/// Each serializer converts a DateTime to a string representation suitable
/// for different use cases (APIs, databases, etc.).
enum DateFormat {
  /// Converts DateTime to ISO8601 string in current timezone.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000"
  iso8601,

  /// Converts DateTime to UTC ISO8601 string.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000Z"
  utcIso8601,

  /// Converts DateTime to local ISO8601 string.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01T00:00:00.000"
  localIso8601,

  /// Converts DateTime to seconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200"
  seconds,
  unix,

  /// Converts DateTime to milliseconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200000"
  milliseconds,

  /// Converts DateTime to microseconds since epoch as a string.
  /// Example: DateTime(2023, 1, 1) -> "1672531200000000"
  microseconds,

  /// Converts DateTime to RFC 2822 format (email/HTTP headers).
  /// Example: DateTime(2023, 1, 1) -> "Sun, 01 Jan 2023 00:00:00 GMT"
  rfc2822,

  /// Converts DateTime to date-only format.
  /// Example: DateTime(2023, 1, 1, 15, 30) -> "2023-01-01"
  date,

  /// Converts DateTime to time-only format.
  /// Example: DateTime(2023, 1, 1, 15, 30, 45) -> "15:30:45"
  time,

  /// Converts DateTime to default string representation.
  /// Example: DateTime(2023, 1, 1) -> "2023-01-01 00:00:00.000"
  string;

  const DateFormat();

  /// Call the enum directly: e.g. `DateSerializer.date(dt)`.
  String call(DateTime dt) => format(dt);

  /// If you need to pass it as a [qs.DateSerializer]:
  qs.DateSerializer get serializer => format;

  /// Format a [DateTime] according to this strategy.
  String format(DateTime dt) => switch (this) {
        seconds || unix => (dt.millisecondsSinceEpoch ~/ 1000).toString(),
        milliseconds => dt.millisecondsSinceEpoch.toString(),
        microseconds => dt.microsecondsSinceEpoch.toString(),
        utcIso8601 => dt.toUtc().toIso8601String(),
        localIso8601 => dt.toLocal().toIso8601String(),
        iso8601 => dt.toIso8601String(),
        rfc2822 => _rfc2822(dt),
        date => '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')}',
        time => '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}',
        string => dt.toString(),
      };

  /// Format a [DateTime] to RFC 2822 format.
  static String _rfc2822(DateTime datetime) {
    final DateTime utc = datetime.toUtc();

    final String wk = _weekdayNames[utc.weekday - 1];
    final String m = _monthNames[utc.month - 1];
    final String d = _twoDigits(utc.day);
    final String hh = _twoDigits(utc.hour);
    final String mm = _twoDigits(utc.minute);
    final String ss = _twoDigits(utc.second);

    return '$wk, $d $m ${utc.year} $hh:$mm:$ss GMT';
  }

  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  String toString() => name;
}
