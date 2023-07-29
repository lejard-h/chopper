import 'package:chopper/chopper.dart' show Response;
import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'http_response_fixture.dart' as http_fixture;

extension ResponseFixture on Response {
  static ResponseFixtureFactory<T> factory<T>() => ResponseFixtureFactory<T>();
}

@internal
final class ResponseFixtureFactory<T> extends FixtureFactory<Response<T>> {
  @override
  FixtureDefinition<Response<T>> definition() {
    final http.Response base =
        http_fixture.ResponseFixture.factory.makeSingle();

    return define(
      (Faker faker) => Response<T>(base, null),
    );
  }

  FixtureRedefinitionBuilder<Response<T>> body(T? body) =>
      (Response<T> response) => response.copyWith(body: body);

  FixtureRedefinitionBuilder<Response<T>> error(Object? value) =>
      (Response<T> response) => response.copyWith(bodyError: value);
}
