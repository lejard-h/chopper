import 'dart:convert';

import 'package:test/test.dart';
import 'package:chopper/chopper.dart';
import 'test_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Form', () {
    final sample = {
      'foo': 'bar',
    };

    group('Form', () {
      final buildClient = (bool form, http.Client httpClient,
              {bool json: false}) =>
          ChopperClient(
            services: [
              // the generated service
              HttpTestService(),
            ],
            client: httpClient,
            jsonApi: json,
            formUrlEncodedApi: form,
          );

      test('form-urlencoded default', () async {
        final httpClient = MockClient((http.Request req) async {
          expect(req.url.toString(), equals('/test/map'));
          expect(
            req.headers['content-type'],
            'application/x-www-form-urlencoded; charset=utf-8',
          );
          expect(req.body, 'foo=bar');
          return http.Response('ok', 200);
        });

        final chopper = buildClient(false, httpClient);

        final result = await chopper
            .service<HttpTestService>(HttpTestService)
            .mapTest(sample);

        expect(result.body, equals('ok'));

        httpClient.close();
      });

      test('force form-urlencoded', () async {
        final httpClient = MockClient((http.Request req) async {
          expect(req.url.toString(), equals('/test/map/form'));
          expect(
            req.headers['content-type'],
            'application/x-www-form-urlencoded; charset=utf-8',
          );
          expect(req.body, 'foo=bar');
          return http.Response('ok', 200);
        });

        final chopper = buildClient(false, httpClient);

        final result = await chopper
            .service<HttpTestService>(HttpTestService)
            .forceFormTest(sample);

        expect(result.body, equals('ok'));

        httpClient.close();
      });
    });
  });
}
