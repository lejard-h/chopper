import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:meta/meta.dart';

import '../helpers/payload.dart';

extension PayloadFixture on Payload {
  static PayloadFactory get factory => PayloadFactory();
}

@internal
final class PayloadFactory extends FixtureFactory<Payload> {
  @override
  FixtureDefinition<Payload> definition() => define(
        (Faker faker) => Payload(
          statusCode: 200,
          message: faker.lorem.sentence(),
        ),
      );
}
