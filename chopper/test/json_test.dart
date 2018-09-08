import 'dart:convert';

import 'package:test/test.dart';
import 'package:chopper/chopper.dart';
import 'test_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  final sample = {
    'foo': 'bar',
  };

  final res = {
    'result': 'ok',
  };
  group('JSON', () {
    final buildClient = (bool json, http.Client httpClient) => ChopperClient(
          services: [
            // the generated service
            HttpTestService(),
          ],
          client: httpClient,
          jsonApi: json,
        );

    test('default json', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.url.toString(), equals('/test/map'));
        expect(req.headers['content-type'], 'application/json; charset=utf-8');
        expect(req.body, equals(json.encode(sample)));
        return http.Response(json.encode(res), 200);
      });

      final chopper = buildClient(
        true,
        httpClient,
      );

      final result = await chopper
          .service<HttpTestService>(HttpTestService)
          .mapTest(sample);

      expect(result.body, equals(res));

      httpClient.close();
    });

    test('force json', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.url.toString(), equals('/test/map/json'));
        expect(req.headers['content-type'], 'application/json; charset=utf-8');
        expect(req.body, equals(json.encode(sample)));
        return http.Response(json.encode(res), 200);
      });

      final chopper = buildClient(
        false,
        httpClient,
      );

      final result = await chopper
          .service<HttpTestService>(HttpTestService)
          .forceJsonTest(sample);

      expect(result.body, equals(res));

      httpClient.close();
    });
  });
}
