import 'package:chopper/chopper.dart';
import 'package:test/test.dart';

void main() {
  group('DateSerializer', () {
    final testDateTime = DateTime.utc(2023, 1, 1, 12, 30, 45, 500);

    test('enum values have correct names', () {
      expect(DateSerializer.seconds.name, equals('seconds'));
      expect(DateSerializer.milliseconds.name, equals('milliseconds'));
      expect(DateSerializer.microseconds.name, equals('microseconds'));
      expect(DateSerializer.utcIso8601.name, equals('utcIso8601'));
      expect(DateSerializer.localIso8601.name, equals('localIso8601'));
      expect(DateSerializer.iso8601.name, equals('iso8601'));
      expect(DateSerializer.string.name, equals('string'));
    });

    test('toString returns the name of the enum value', () {
      expect(DateSerializer.seconds.toString(), equals('seconds'));
      expect(DateSerializer.milliseconds.toString(), equals('milliseconds'));
      expect(DateSerializer.microseconds.toString(), equals('microseconds'));
      expect(DateSerializer.utcIso8601.toString(), equals('utcIso8601'));
      expect(DateSerializer.localIso8601.toString(), equals('localIso8601'));
      expect(DateSerializer.iso8601.toString(), equals('iso8601'));
      expect(DateSerializer.string.toString(), equals('string'));
    });

    test('serializers produce expected format', () {
      // Test that seconds serializer produces a numeric string
      final secondsResult = DateSerializer.seconds.serializer(testDateTime);
      expect(secondsResult, matches(r'^\d+$'));

      // Test that milliseconds serializer produces a numeric string
      final msResult = DateSerializer.milliseconds.serializer(testDateTime);
      expect(msResult, matches(r'^\d+$'));

      // Test that microseconds serializer produces a numeric string
      final usResult = DateSerializer.microseconds.serializer(testDateTime);
      expect(usResult, matches(r'^\d+$'));

      // Test that utcIso8601 serializer produces an ISO8601 string with Z
      final utcResult = DateSerializer.utcIso8601.serializer(testDateTime);
      expect(
          utcResult, matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$'));

      // Test that localIso8601 serializer produces an ISO8601 string
      final localResult = DateSerializer.localIso8601.serializer(testDateTime);
      expect(
          localResult, matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}'));

      // Test that iso8601 serializer produces an ISO8601 string
      final isoResult = DateSerializer.iso8601.serializer(testDateTime);
      expect(
          isoResult, matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}'));

      // Test that string serializer produces a string
      final stringResult = DateSerializer.string.serializer(testDateTime);
      expect(stringResult, isA<String>());
    });
  });

  group('Request with DateSerializer', () {
    final testDateTime = DateTime.utc(2023, 1, 1, 12, 30, 45, 500);

    test('can be constructed with a DateSerializer', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateSerializer: DateSerializer.seconds,
      );

      expect(request.dateSerializer, equals(DateSerializer.seconds));
    });

    test('preserves DateSerializer in copyWith', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateSerializer: DateSerializer.seconds,
      );

      final copiedRequest = request.copyWith(
        method: 'POST',
      );

      expect(copiedRequest.dateSerializer, equals(DateSerializer.seconds));
    });

    test('can override DateSerializer in copyWith', () {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
        parameters: {'date': testDateTime},
        dateSerializer: DateSerializer.seconds,
      );

      final copiedRequest = request.copyWith(
        dateSerializer: DateSerializer.milliseconds,
      );

      expect(copiedRequest.dateSerializer, equals(DateSerializer.milliseconds));
    });
  });
}
