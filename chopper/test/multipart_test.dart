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
          contains(
            'content-disposition: form-data; name="1"\r\n'
                '\r\n'
                '{foo: bar}\r\n',
          ),
        );
        expect(
          req.body,
          contains(
            'content-disposition: form-data; name="2"\r\n'
                '\r\n'
                '{bar: foo}\r\n',
          ),
        );
        return http.Response('ok', 200);
      });

      final chopper =
          ChopperClient(client: httpClient, converter: JsonConverter());
      final service = HttpTestService.create(chopper);

      await service.postResources({'foo': 'bar'}, {'bar': 'foo'});

      chopper.dispose();
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
      final service = HttpTestService.create(chopper);

      await service.postFile([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

      chopper.dispose();
    });
  });

  test('PartValue.replace', () {
    dynamic part = PartValue<String>("foo", "bar");

    expect(part.name, equals("foo"));
    expect(part.value, equals("bar"));

    part = part.replace<int>(value: 42);

    expect(part.name, equals("foo"));
    expect(part.value, equals(42));

    part = part.replace<int>(name: "int");

    expect(part.name, equals("int"));
    expect(part.value, equals(42));
  });
}
