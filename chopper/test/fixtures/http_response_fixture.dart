import 'dart:convert' show jsonEncode;

import 'package:data_fixture_dart/data_fixture_dart.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../helpers/http_response_extension.dart';
import 'payload_fixture.dart';

extension ResponseFixture on http.Response {
  static ResponseFactory get factory => ResponseFactory();
}

@internal
final class ResponseFactory extends FixtureFactory<http.Response> {
  @override
  FixtureDefinition<http.Response> definition() => define(
        (Faker faker) => http.Response(
          jsonEncode(PayloadFixture.factory.makeSingle().toJson()),
          200,
        ),
      );

  FixtureRedefinitionBuilder<http.Response> body(String? body) =>
      (http.Response response) => response.copyWith(body: body);

  FixtureRedefinitionBuilder<http.Response> statusCode(int? statusCode) =>
      (http.Response response) => response.copyWith(statusCode: statusCode);
}
