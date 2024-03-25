import 'package:chopper/src/base.dart';
import 'package:chopper/src/constants.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/request.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';
import 'package:transparent_image/transparent_image.dart';

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
          contains('content-disposition: form-data; name="file"'),
        );
        expect(
          req.body,
          contains(String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])),
        );

        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient);
      final service = HttpTestService.create(chopper);

      await service.postFile([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

      chopper.dispose();
    });

    test('image', () async {
      final httpClient = MockClient((http.Request req) async {
        final String body = String.fromCharCodes(req.bodyBytes);

        expect(req.headers['Content-Type'], contains('multipart/form-data;'));
        expect(body, contains('content-type: application/octet-stream'));
        expect(body, contains('content-disposition: form-data; name="image"'));
        expect(
          body,
          contains(String.fromCharCodes(kTransparentImage)),
        );

        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient);
      final service = HttpTestService.create(chopper);

      await service.postImage(kTransparentImage);

      chopper.dispose();
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
          ),
        );
        expect(
          req.body,
          contains(String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])),
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

    test('MultipartFile with other Part', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.headers['Content-Type'], contains('multipart/form-data;'));

        expect(
          req.body,
          contains(
            'content-disposition: form-data; name="id"\r\n\r\n42\r\n',
          ),
        );

        expect(
          req.body,
          contains('content-type: application/octet-stream'),
        );
        expect(
          req.body,
          contains(
            'content-disposition: form-data; name="file_field"; filename="file_name"',
          ),
        );
        expect(
          req.body,
          contains(String.fromCharCodes([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])),
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
      final req = await Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        parts: [
          PartValue<String>('foo', 'bar'),
          PartValue<int>('int', 42),
        ],
      ).toMultipartRequest();

      expect(req.fields['foo'], equals('bar'));
      expect(req.fields['int'], equals('42'));
    });

    test(
      'PartFile',
      () async {
        final req = await Request(
          HttpMethod.Post,
          Uri.parse('https://foo/'),
          Uri.parse(''),
          parts: [
            PartValueFile<String>('foo', 'test/multipart_test.dart'),
            PartValueFile<List<int>>('int', [1, 2]),
          ],
        ).toMultipartRequest();

        expect(
          req.files.firstWhere((f) => f.field == 'foo').filename,
          equals('multipart_test.dart'),
        );
        final bytes = await req.files
            .firstWhere((f) => f.field == 'int')
            .finalize()
            .first;
        expect(bytes, equals([1, 2]));
      },
      testOn: 'vm',
    );

    test('PartValue.replace', () {
      dynamic part = PartValue<String>('foo', 'bar');

      expect(part.name, equals('foo'));
      expect(part.value, equals('bar'));

      part = part.copyWith<int>(value: 42);

      expect(part.name, equals('foo'));
      expect(part.value, equals(42));

      part = part.copyWith<int>(name: 'int');

      expect(part.name, equals('int'));
      expect(part.value, equals(42));
    });

    test('Multipart request non nullable', () async {
      final req = await Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        parts: [
          PartValue<int>('int', 42),
          PartValueFile<List<int>>('list int', [1, 2]),
          PartValue('null value', null),
          PartValueFile('null file', null),
        ],
      ).toMultipartRequest();

      expect(req.fields.length, equals(1));
      expect(req.fields['int'], equals('42'));
      expect(req.files.length, equals(1));
      final bytes = await req.files.first.finalize().first;
      expect(bytes, equals([1, 2]));
    });

    test('PartValue with MultipartFile directly', () async {
      final req = await Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        parts: [
          PartValue<http.MultipartFile>(
            '',
            http.MultipartFile.fromBytes(
              'first',
              [1, 2],
              filename: 'list int 1',
            ),
          ),
          PartValueFile<http.MultipartFile>(
            '',
            http.MultipartFile.fromBytes(
              'second',
              [2, 1],
              filename: 'list int 2',
            ),
          ),
        ],
      ).toMultipartRequest();

      final first = req.files[0];
      final second = req.files[1];

      expect(first.filename, equals('list int 1'));
      expect(second.filename, equals('list int 2'));

      var bytes = await first.finalize().first;
      expect(bytes, equals([1, 2]));

      bytes = await second.finalize().first;
      expect(bytes, equals([2, 1]));
    });

    test('Throw exception', () async {
      expect(
        () async => await Request(
          HttpMethod.Post,
          Uri.parse('https://foo/'),
          Uri.parse(''),
          parts: [
            PartValueFile('', 123),
          ],
        ).toMultipartRequest(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Multipart request List', () async {
      const List<int> ints = [1, 2, 3];
      const List<double> doubles = [1.23, -1.23, 0.0, 0.12324, 3 / 4];
      const List<num> nums = [
        1.23443534678,
        0.00000000001,
        -34251,
        0.0,
        3 / 4,
      ];
      const List<String> strings = [
        'lorem',
        'ipsum',
        'dolor',
        '''r237tw78re ei[04o2 ]de[qwlr;,mgrrt9ie0owp[ld;s,a.vfe[plre'q/sd;poeßšđčćž''',
      ];

      final req = await Request(
        HttpMethod.Post,
        Uri.parse('https://foo/'),
        Uri.parse(''),
        parts: [
          PartValue<List<int>>('ints', ints),
          PartValue<List<double>>('doubles', doubles),
          PartValue<List<num>>('nums', nums),
          PartValue<List<String>>('strings', strings),
        ],
      ).toMultipartRequest();

      expect(
        req.fields.length,
        equals(ints.length + doubles.length + nums.length + strings.length),
      );

      for (var i = 0; i < ints.length; i++) {
        expect(req.fields['ints[$i]'], equals(ints[i].toString()));
      }

      for (var i = 0; i < doubles.length; i++) {
        expect(req.fields['doubles[$i]'], equals(doubles[i].toString()));
      }

      for (var i = 0; i < nums.length; i++) {
        expect(req.fields['nums[$i]'], equals(nums[i].toString()));
      }

      for (var i = 0; i < strings.length; i++) {
        expect(req.fields['strings[$i]'], equals(strings[i]));
      }
    });

    test('Multipart lists', () async {
      const List<int> ints = [1, 2, 3];
      const List<double> doubles = [1.23, -1.23, 0.0, 0.12324, 3 / 4];
      const List<num> nums = [
        1.23443534678,
        0.00000000001,
        -34251,
        0.0,
        3 / 4,
      ];
      const String utf8String =
          '''r237tw78re ei[04o2 ]de[qwlr;,mgrrt9ie0owp[ld;s,a.vfe[plre'q/sd;poeßšđčćž''';
      const List<String> strings = [
        'lorem',
        'ipsum',
        'dolor',
        utf8String,
      ];

      final httpClient = MockClient((http.Request req) async {
        expect(req.headers['Content-Type'], contains('multipart/form-data;'));

        for (var i = 0; i < ints.length; i++) {
          expect(
            req.body,
            contains(
              'content-disposition: form-data; name="ints[$i]"\r\n'
              '\r\n'
              '${ints[i]}\r\n',
            ),
          );
        }

        for (var i = 0; i < doubles.length; i++) {
          expect(
            req.body,
            contains(
              'content-disposition: form-data; name="doubles[$i]"\r\n'
              '\r\n'
              '${doubles[i]}\r\n',
            ),
          );
        }

        for (var i = 0; i < nums.length; i++) {
          expect(
            req.body,
            contains(
              'content-disposition: form-data; name="nums[$i]"\r\n'
              '\r\n'
              '${nums[i]}\r\n',
            ),
          );
        }

        for (var i = 0; i < strings.length; i++) {
          if (strings[i] == utf8String) {
            expect(
              req.body,
              contains(
                'content-disposition: form-data; name="strings[$i]"\r\n'
                'content-type: text/plain; charset=utf-8\r\n'
                'content-transfer-encoding: binary\r\n'
                '\r\n'
                '${strings[i]}\r\n',
              ),
            );
          } else {
            expect(
              req.body,
              contains(
                'content-disposition: form-data; name="strings[$i]"\r\n'
                '\r\n'
                '${strings[i]}\r\n',
              ),
            );
          }
        }

        return http.Response('ok', 200);
      });

      final chopper = ChopperClient(client: httpClient);
      final service = HttpTestService.create(chopper);

      await service.postMultipartList(
        ints: ints,
        doubles: doubles,
        nums: nums,
        strings: strings,
      );

      chopper.dispose();
    });
  });
}
