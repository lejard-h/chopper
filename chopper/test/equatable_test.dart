import 'package:chopper/chopper.dart';
import 'package:faker/faker.dart';
import 'package:test/test.dart';

import 'fixtures/request_fixture.dart';

void main() {
  final Faker faker = Faker();

  group('Request', () {
    final Uri baseUrl = Uri.parse(faker.internet.httpsUrl());
    late Request request;

    setUp(() {
      request = RequestFixture.factory.makeSingle();
    });

    test('should return true when comparing two identical objects', () {
      expect(
        Request(
          'GET',
          Uri.parse('/foo'),
          baseUrl,
          headers: {'bar': 'baz'},
        ),
        equals(
          Request(
            'GET',
            Uri.parse('/foo'),
            baseUrl,
            headers: {'bar': 'baz'},
          ),
        ),
      );
    });

    test(
      'should return true when comparing original with copy',
      () => expect(
        request,
        equals(
          request.copyWith(),
        ),
      ),
    );

    test(
      'should return false when comparing two different objects',
      () => expect(
        request,
        isNot(
          equals(
            RequestFixture.factory.makeSingle(),
          ),
        ),
      ),
    );

    test(
      'should return false when comparing to null',
      () => expect(
        request,
        isNot(
          equals(null),
        ),
      ),
    );

    test(
      'should return false when comparing to an object of a different type',
      () {
        expect(
          request,
          isNot(
            equals(faker.lorem.word()),
          ),
        );
      },
    );

    test(
      'should return false when comparing to an object with different props',
      () => expect(
        request,
        isNot(
          equals(
            request.copyWith(
              headers: {'bar': 'bazzz'},
            ),
          ),
        ),
      ),
    );
  });
}
