import 'dart:convert' show jsonEncode;

import 'package:chopper/chopper.dart';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'fixtures/http_response_fixture.dart' as http_fixture;
import 'fixtures/payload_fixture.dart';
import 'fixtures/request_fixture.dart';
import 'fixtures/response_fixture.dart';
import 'helpers/payload.dart';

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

  group('Response', () {
    late Payload payload;
    late Response<Payload> response;

    setUp(() {
      payload = PayloadFixture.factory.makeSingle();
      response = ResponseFixture.factory<Payload>()
          .redefine(ResponseFixture.factory<Payload>().body(payload))
          .makeSingle();
    });

    test('should return true when comparing two identical objects', () {
      final http.Response base = http_fixture.ResponseFixture.factory
          .redefine(
            http_fixture.ResponseFixture.factory.body(
              jsonEncode(payload),
            ),
          )
          .makeSingle();

      expect(
        Response<Payload>(base, payload),
        equals(
          Response<Payload>(base, payload),
        ),
      );
    });

    test(
      'should return true when comparing original with copy',
      () => expect(
        response,
        equals(
          response.copyWith<Payload>(),
        ),
      ),
    );

    test(
      'should return false when comparing two different objects',
      () => expect(
        response,
        isNot(
          equals(
            ResponseFixture.factory<Payload>()
                .redefine(ResponseFixture.factory<Payload>()
                    .body(PayloadFixture.factory.makeSingle()))
                .makeSingle(),
          ),
        ),
      ),
    );

    test(
      'should return false when comparing to null',
      () => expect(
        response,
        isNot(
          equals(null),
        ),
      ),
    );

    test(
      'should return false when comparing to an object of a different type',
      () {
        expect(
          response,
          isNot(
            equals(faker.lorem.word()),
          ),
        );
      },
    );

    test(
      'should return false when comparing to an object with different props',
      () => expect(
        response,
        isNot(
          equals(
            response.copyWith<Payload>(
              body: PayloadFixture.factory.makeSingle(),
            ),
          ),
        ),
      ),
    );
  });

  group('PartValue', () {
    late PartValue<String> partValue;

    setUp(() {
      partValue = PartValue<String>(
        faker.lorem.word(),
        faker.lorem.word(),
      );
    });

    test('should return true when comparing two identical objects', () {
      expect(
        PartValue<String>('foo', 'bar'),
        equals(
          PartValue<String>('foo', 'bar'),
        ),
      );
    });

    test(
      'should return true when comparing original with copy',
      () => expect(
        partValue,
        equals(
          partValue.copyWith<String>(),
        ),
      ),
    );

    test(
      'should return false when comparing two different objects',
      () => expect(
        partValue,
        isNot(
          equals(
            PartValue('bar', 'baz'),
          ),
        ),
      ),
    );

    test(
      'should return false when comparing to null',
      () => expect(
        partValue,
        isNot(
          equals(null),
        ),
      ),
    );

    test(
      'should return false when comparing to an object of a different type',
      () {
        expect(
          partValue,
          isNot(
            equals(faker.lorem.word()),
          ),
        );
      },
    );

    test(
      'should return false when comparing to an object with different props',
      () => expect(
        partValue,
        isNot(
          equals(
            partValue.copyWith(
              value: 'bar',
            ),
          ),
        ),
      ),
    );
  });
}
