import 'package:chopper/chopper.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'test_service.dart';

const baseUrl = "http://localhost:8000";

void main() {
  group('Converter', () {
    final buildClient = (http.BaseClient client) => ChopperClient(
          baseUrl: baseUrl,
          client: client,
          converter: TestConverter(),
          errorConverter: TestErrorConverter(),
        );

    test('base decode', () async {
      final converter = TestConverter();

      final decoded = await converter.convertResponse<_Converted<String>>(
        Response<String>(http.Response('', 200), 'foo'),
      );

      expect(decoded.body is _Converted<String>, isTrue);
      expect(decoded.body.data, equals('foo'));
    });

    test('base encode', () async {
      final converter = TestConverter();

      final encoded = await converter.convertRequest(
        Request('GET', '/', baseUrl, body: _Converted<String>('foo')),
      );

      expect(encoded.body is String, isTrue);
      expect(encoded.body, equals('foo'));
    });

    test('on error converter', () async {
      final httpClient = MockClient((http.Request request) async {
        return http.Response('error', 404);
      });

      final chopper = buildClient(httpClient);

      final service = HttpTestService.create(chopper);

      try {
        await service.getTest('1');
      } catch (e) {
        expect(e is Response, isTrue);
        expect((e as Response).body is _ConvertedError, isTrue);
        expect(e.body.data, equals('error'));
      }
      httpClient.close();
    });
  });
}

class TestConverter extends Converter {
  @override
  Response<T> convertResponse<T>(Response res) {
    if (res.body is String) {
      return res.replace<_Converted<String>>(body: _Converted<String>(res.body))
          as Response<T>;
    }
    return res;
  }

  @override
  Request convertRequest(Request req) {
    if (req.body is _Converted) return req.replace(body: req.body.data);
    return req;
  }
}

class TestErrorConverter extends Converter {
  @override
  Response<T> convertResponse<T>(Response res) {
    if (res.body is String) {
      return res.replace<_ConvertedError<String>>(
          body: _ConvertedError<String>(res.body));
    }
    return res;
  }

  @override
  Request convertRequest(Request req) {
    if (req.body is _ConvertedError) return req.replace(body: req.body);
    return req;
  }
}

class _Converted<T> {
  final T data;

  _Converted(this.data);
}

class _ConvertedError<T> {
  final T data;

  _ConvertedError(this.data);
}
