import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

void main() {
  group('Multipart', () {
    test('simple json', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.headers['Content-Type'], contains('multipart/form-data;'));
        expect(
          req.body,
          contains('''
content-disposition: form-data; name="1"\r
\r
{"foo":"bar"}\r
'''),
        );
        expect(
          req.body,
          contains('''
content-disposition: form-data; name="2"\r
\r
{"bar":"foo"}\r
'''),
        );
        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient, jsonApi: true);
      final service = HttpTestService.withClient(chopper);

      await service.postResources({'foo': 'bar'}, {'bar': 'foo'});

      chopper.close();
    });

    test('file', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.headers['Content-Type'], contains('multipart/form-data;'));
        expect(
          req.body,
          contains('content-type: application/octet-stream'),
        );
        expect(
          req.body,
          contains('''
content-disposition: form-data; name="file"\r
\r
${String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])}\r
'''),
        );
        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient);
      final service = HttpTestService.withClient(chopper);

      await service.postFile([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

      chopper.close();
    });
  });
}
