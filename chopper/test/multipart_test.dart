import 'package:chopper/chopper.dart';
import 'package:http_parser/http_parser.dart';
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
            contains(
              'content-disposition: form-data; name="file"',
            ));
        expect(
          req.body,
          contains('${String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])}'),
        );
        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient);
      final service = HttpTestService.create(chopper);

      await service.postFile([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

      chopper.dispose();
    });
  });

  test('file with MultipartFile', () async {
    final httpClient = MockClient((http.Request req) async {
      expect(req.headers['Content-Type'], contains('multipart/form-data;'));
      expect(
        req.body,
        contains('content-type: application/octet-stream'),
      );

      expect(
        req.body,
        isNot(contains('content-disposition: form-data; name="id"')),
      );
      expect(
          req.body,
          contains(
            'content-disposition: form-data; name="file_field"; filename="file_name"',
          ));
      expect(
        req.body,
        contains('${String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])}'),
      );
      return http.Response('ok', 200);
    });

    final chopper = ChopperClient(client: httpClient);
    final service = HttpTestService.create(chopper);

    final file = http.MultipartFile.fromBytes(
      'file_field',
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      filename: 'file_name',
      contentType: MediaType.parse('application/octet-stream'),
    );

    await service.postMultipartFile(file);

    chopper.dispose();
  });

  test("MultipartFile with other Part", () async {
    final httpClient = MockClient((http.Request req) async {
      expect(req.headers['Content-Type'], contains('multipart/form-data;'));

      expect(req.body,
          contains('content-disposition: form-data; name="id"\r\n\r\n42\r\n'));

      expect(
        req.body,
        contains('content-type: application/octet-stream'),
      );
      expect(
          req.body,
          contains(
            'content-disposition: form-data; name="file_field"; filename="file_name"',
          ));
      expect(
        req.body,
        contains('${String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])}'),
      );
      return http.Response('ok', 200);
    });

    final chopper = ChopperClient(client: httpClient);
    final service = HttpTestService.create(chopper);

    final file = http.MultipartFile.fromBytes(
      'file_field',
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      filename: 'file_name',
      contentType: MediaType.parse('application/octet-stream'),
    );

    await service.postMultipartFile(file, id: '42');

    chopper.dispose();
  });

  test('support List<MultipartFile>', () async {
    final httpClient = MockClient((http.Request req) async {
      expect(req.headers['Content-Type'], contains('multipart/form-data;'));

      expect(
        req.body,
        contains(
          'content-type: application/octet-stream\r\n'
          'content-disposition: form-data; name="file_1"; filename="file_name_1"\r\n'
          '\r\n'
          'Hello',
        ),
      );

      expect(
        req.body,
        contains(
          'content-type: application/octet-stream\r\n'
          'content-disposition: form-data; name="file_2"; filename="file_name_2"\r\n'
          '\r\n'
          'World',
        ),
      );
      return http.Response('ok', 200);
    });

    final chopper = ChopperClient(client: httpClient);
    final service = HttpTestService.create(chopper);

    final file1 = http.MultipartFile.fromBytes(
      'file_1',
      'Hello'.codeUnits,
      filename: 'file_name_1',
      contentType: MediaType.parse('application/octet-stream'),
    );

    final file2 = http.MultipartFile.fromBytes(
      'file_2',
      'World'.codeUnits,
      filename: 'file_name_2',
      contentType: MediaType.parse('application/octet-stream'),
    );

    await service.postListFiles([file1, file2]);

    chopper.dispose();
  });

  test('PartValue', () async {
    final req = await toMultipartRequest(
      [
        PartValue<String>("foo", "bar"),
        PartValue<int>("int", 42),
      ],
      HttpMethod.Post,
      Uri.parse('/foo'),
      {},
    );

    expect(req.fields['foo'], equals('bar'));
    expect(req.fields['int'], equals('42'));
  });

  test('PartFile', () async {
    final req = await toMultipartRequest(
      [
        PartValueFile<String>("foo", "test/multipart_test.dart"),
        PartValueFile<List<int>>("int", [1, 2]),
      ],
      HttpMethod.Post,
      Uri.parse('/foo'),
      {},
    );

    expect(req.files.firstWhere((f) => f.field == 'foo').filename,
        equals('multipart_test.dart'));
    final bytes =
        await req.files.firstWhere((f) => f.field == 'int').finalize().first;
    expect(bytes, equals([1, 2]));
  }, testOn: 'vm');

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

  test('Multipart request non nullable', () async {
    final req = await toMultipartRequest(
      [
        PartValue<int>("int", 42),
        PartValueFile<List<int>>("list int", [1, 2]),
        null,
        PartValue('null value', null),
        PartValueFile('null file', null),
      ],
      HttpMethod.Post,
      Uri.parse('/foo'),
      {},
    );

    expect(req.fields.length, equals(1));
    expect(req.fields['int'], equals('42'));
    expect(req.files.length, equals(1));
    final bytes = await req.files.first.finalize().first;
    expect(bytes, equals([1, 2]));
  });

  test('PartValue with MultipartFile directly', () async {
    final req = await toMultipartRequest(
      [
        PartValue<http.MultipartFile>(
          null,
          http.MultipartFile.fromBytes(
            "first",
            [1, 2],
            filename: 'list int 1',
          ),
        ),
        PartValueFile<http.MultipartFile>(
          null,
          http.MultipartFile.fromBytes(
            "second",
            [2, 1],
            filename: 'list int 2',
          ),
        ),
      ],
      HttpMethod.Post,
      Uri.parse('/foo'),
      {},
    );

    final first = req.files[0];
    final second = req.files[1];

    expect(first.filename, equals('list int 1'));
    expect(second.filename, equals('list int 2'));

    var bytes = await first.finalize().first;
    expect(bytes, equals([1, 2]));

    bytes = await second.finalize().first;
    expect(bytes, equals([2, 1]));
  });
}
