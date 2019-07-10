import 'package:test/test.dart';
import 'package:chopper/chopper.dart';
import 'test_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Form', () {
    final buildClient =
        (http.Client httpClient, {bool isJson = false}) => ChopperClient(
              services: [
                // the generated service
                HttpTestService.create(),
              ],
              client: httpClient,
              converter: isJson ? JsonConverter() : null,
            );

    test('form-urlencoded default if no converter', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.url.toString(), equals('/test/map'));
        expect(
          req.headers['content-type'],
          'application/x-www-form-urlencoded; charset=utf-8',
        );
        expect(req.body, 'foo=test&default=hello');
        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);

      final result = await chopper.getService<HttpTestService>().mapTest({
        'foo': 'test',
        'default': 'hello',
      });

      expect(result.body, equals('ok'));

      httpClient.close();
    });

    test('form-urlencoded factory converter', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(
          req.headers['content-type'],
          'application/x-www-form-urlencoded; charset=utf-8',
        );
        expect(req.body, 'foo=test&factory=converter');
        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient, isJson: true);

      final result = await chopper.getService<HttpTestService>().postForm({
        'foo': 'test',
        'factory': 'converter',
      });

      expect(result.body, equals('ok'));

      httpClient.close();
    });

    test('form-urlencoded using headers field of annotation', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(
          req.headers['content-type'],
          'application/x-www-form-urlencoded; charset=utf-8',
        );
        expect(req.body, 'foo=test&factory=converter');
        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient, isJson: true);

      final result =
          await chopper.getService<HttpTestService>().postFormUsingHeaders({
        'foo': 'test',
        'factory': 'converter',
      });

      expect(result.body, equals('ok'));

      httpClient.close();
    });

    test('form-urlencoded with @Field()', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(
          req.headers['content-type'],
          'application/x-www-form-urlencoded; charset=utf-8',
        );
        expect(req.body, 'foo=test&bar=42');
        return http.Response('ok', 200);
      });

      final chopper = buildClient(httpClient);

      final result = await chopper
          .getService<HttpTestService>()
          .postFormFields('test', 42);

      expect(result.body, equals('ok'));

      httpClient.close();
    });
  });
}
