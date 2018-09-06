import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

void main() {
  group('Generated Service', () {

    final buildClient = (http.Client httpClient) => ChopperClient(
        baseUrl: "http://localhost:8000",
        apis: [
          // the generated service
          HttpTestService(),
        ],
        client: httpClient,
      );
    test('GET', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('http://localhost:8000/test/get/1234'),
        );
        expect(request.method, equals('GET'));

        return http.Response('get response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.service<HttpTestService>();

      final response = await service.getTest('1234');

      expect(response.body, equals('get response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('POST', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('http://localhost:8000/test/post'),
        );
        expect(request.method, equals('POST'));
        expect(request.body, equals('post body'));

        return http.Response('post response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.service<HttpTestService>();

      final response = await service.postTest('post body');

      expect(response.body, equals('post response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PUT', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('http://localhost:8000/test/put/1234'),
        );
        expect(request.method, equals('PUT'));
        expect(request.body, equals('put body'));

        return http.Response('put response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.service<HttpTestService>();

      final response = await service.putTest('1234', 'put body');

      expect(response.body, equals('put response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('PATCH', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('http://localhost:8000/test/patch/1234'),
        );
        expect(request.method, equals('PATCH'));
        expect(request.body, equals('patch body'));

        return http.Response('patch response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.service<HttpTestService>();

      final response = await service.patchTest('1234', 'patch body');

      expect(response.body, equals('patch response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });

    test('DELETE', () async {
      final httpClient = MockClient((request) async {
        expect(
          request.url.toString(),
          equals('http://localhost:8000/test/delete/1234'),
        );
        expect(request.method, equals('DELETE'));

        return http.Response('delete response', 200);
      });

      final chopper = buildClient(httpClient);
      final service = chopper.service<HttpTestService>();

      final response = await service.deleteTest('1234');

      expect(response.body, equals('delete response'));
      expect(response.statusCode, equals(200));

      httpClient.close();
    });
  });
}
