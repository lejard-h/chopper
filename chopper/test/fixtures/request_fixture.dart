import 'dart:convert' show jsonEncode;

import 'package:chopper/chopper.dart' show Request;
import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:meta/meta.dart';

extension RequestFixture on Request {
  static RequestFixtureFactory get factory => RequestFixtureFactory();
}

@internal
final class RequestFixtureFactory extends FixtureFactory<Request> {
  @override
  FixtureDefinition<Request> definition() {
    final String method =
        faker.randomGenerator.element(['GET', 'POST', 'PUT', 'DELETE']);

    return define(
      (Faker faker) => Request(
        method,
        Uri.parse('/${faker.lorem.word()}'),
        Uri.https(faker.internet.domainName()),
        headers: faker.randomGenerator.boolean()
            ? {'x-${faker.lorem.word()}': faker.lorem.word()}
            : {},
        parameters: faker.randomGenerator.boolean()
            ? {faker.lorem.word(): faker.lorem.word()}
            : null,
        body:
            faker.randomGenerator.boolean() && ['POST', 'PUT'].contains(method)
                ? jsonEncode({faker.lorem.word(): faker.lorem.sentences(10)})
                : null,
      ),
    );
  }
}
