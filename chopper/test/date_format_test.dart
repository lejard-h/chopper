import 'package:chopper/chopper.dart';
import 'package:test/test.dart';

void main() {
  group('DateFormat', () {
    final testDateTime = DateTime.utc(2023, 1, 1, 12, 30, 45, 500);

    test('enum values have correct names', () {
      expect(DateFormat.seconds.name, equals('seconds'));
      expect(DateFormat.unix.name, equals('unix'));
      expect(DateFormat.milliseconds.name, equals('milliseconds'));
      expect(DateFormat.microseconds.name, equals('microseconds'));
      expect(DateFormat.utcIso8601.name, equals('utcIso8601'));
      expect(DateFormat.localIso8601.name, equals('localIso8601'));
      expect(DateFormat.iso8601.name, equals('iso8601'));
      expect(DateFormat.rfc2822.name, equals('rfc2822'));
      expect(DateFormat.date.name, equals('date'));
      expect(DateFormat.time.name, equals('time'));
      expect(DateFormat.string.name, equals('string'));
    });

    test('toString returns the name of the enum value', () {
      expect(DateFormat.seconds.toString(), equals('seconds'));
      expect(DateFormat.unix.toString(), equals('unix'));
      expect(DateFormat.milliseconds.toString(), equals('milliseconds'));
      expect(DateFormat.microseconds.toString(), equals('microseconds'));
      expect(DateFormat.utcIso8601.toString(), equals('utcIso8601'));
      expect(DateFormat.localIso8601.toString(), equals('localIso8601'));
      expect(DateFormat.iso8601.toString(), equals('iso8601'));
      expect(DateFormat.rfc2822.toString(), equals('rfc2822'));
      expect(DateFormat.date.toString(), equals('date'));
      expect(DateFormat.time.toString(), equals('time'));
      expect(DateFormat.string.toString(), equals('string'));
    });

    test('serializers produce expected format', () {
      // Calculate expected values directly from testDateTime
      final expectedSeconds =
          (testDateTime.millisecondsSinceEpoch ~/ 1000).toString();
      final expectedMilliseconds =
          testDateTime.millisecondsSinceEpoch.toString();
      final expectedMicroseconds =
          testDateTime.microsecondsSinceEpoch.toString();

      // Test seconds serializer
      final secondsResult = DateFormat.seconds(testDateTime);
      expect(secondsResult, equals(expectedSeconds));

      // Test unix serializer (alias for seconds)
      final unixResult = DateFormat.unix(testDateTime);
      expect(unixResult, equals(expectedSeconds));

      // Test that seconds and unix produce the same result
      expect(secondsResult, equals(unixResult));

      // Test milliseconds serializer
      final msResult = DateFormat.milliseconds(testDateTime);
      expect(msResult, equals(expectedMilliseconds));

      // Test microseconds serializer
      final usResult = DateFormat.microseconds(testDateTime);
      expect(usResult, equals(expectedMicroseconds));

      // Calculate expected values for ISO8601 formats
      final expectedUtcIso8601 = testDateTime.toUtc().toIso8601String();
      final expectedIso8601 = testDateTime.toIso8601String();

      // Test utcIso8601 serializer
      final utcResult = DateFormat.utcIso8601(testDateTime);
      expect(utcResult, equals(expectedUtcIso8601));

      // Test localIso8601 serializer
      final localResult = DateFormat.localIso8601(testDateTime);
      // Since this converts to local timezone, we can't test exact value
      // but we can verify it follows the ISO8601 format without Z suffix
      expect(
        localResult,
        matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}$'),
      );

      // Test iso8601 serializer
      final isoResult = DateFormat.iso8601(testDateTime);
      expect(isoResult, equals(expectedIso8601));

      // Test rfc2822 serializer
      final rfc2822Result = DateFormat.rfc2822(testDateTime);
      // Manually construct expected RFC 2822 format
      final expectedRfc2822 = 'Sun, 01 Jan 2023 12:30:45 GMT';
      expect(rfc2822Result, equals(expectedRfc2822));

      // Test date serializer
      final dateResult = DateFormat.date(testDateTime);
      final expectedDate =
          '${testDateTime.year.toString().padLeft(4, '0')}-'
          '${testDateTime.month.toString().padLeft(2, '0')}-'
          '${testDateTime.day.toString().padLeft(2, '0')}';
      expect(dateResult, equals(expectedDate));

      // Test time serializer
      final timeResult = DateFormat.time(testDateTime);
      final expectedTime =
          '${testDateTime.hour.toString().padLeft(2, '0')}:'
          '${testDateTime.minute.toString().padLeft(2, '0')}:'
          '${testDateTime.second.toString().padLeft(2, '0')}';
      expect(timeResult, equals(expectedTime));

      // Test string serializer
      final stringResult = DateFormat.string(testDateTime);
      final expectedString = testDateTime.toString();
      expect(stringResult, equals(expectedString));
    });
  });

  group('Request with DateFormat', () {
    final testDateTime = DateTime.utc(2023, 1, 1, 12, 30, 45, 500);

    test('can be constructed with a DateFormat', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateFormat: DateFormat.seconds,
      );

      expect(request.dateFormat, equals(DateFormat.seconds));
    });

    test('preserves DateFormat in copyWith', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateFormat: DateFormat.seconds,
      );

      final copiedRequest = request.copyWith(method: 'POST');

      expect(copiedRequest.dateFormat, equals(DateFormat.seconds));
    });

    test('can override DateFormat in copyWith', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateFormat: DateFormat.seconds,
      );

      final copiedRequest = request.copyWith(
        dateFormat: DateFormat.milliseconds,
      );

      expect(copiedRequest.dateFormat, equals(DateFormat.milliseconds));
    });
  });
}
