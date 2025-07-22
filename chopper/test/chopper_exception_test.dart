import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ChopperException', () {
    test('toString() with only message', () {
      final exception = ChopperException('Test message');
      expect(exception.toString(), 'ChopperException: Test message ');
    });

    test(
      'toString() with message and response',
      () {
        final baseResponse = http.Response('Internal server error', 500);
        final chopperResponse = Response(baseResponse, 'Error body');
        final exception = ChopperException(
          'Test message with response',
          response: chopperResponse,
        );
        expect(
          exception.toString(),
          // ignore: lines_longer_than_80_chars
          'ChopperException: Test message with response , \nResponse: Response<String>(Instance of \'Response\', Error body, null)',
        );
      },
      testOn: 'vm',
    );

    test(
      'toString() with message and response',
      () {
        final baseResponse = http.Response('Internal server error', 500);
        final chopperResponse = Response(baseResponse, 'Error body');
        final exception = ChopperException(
          'Test message with response',
          response: chopperResponse,
        );
        expect(
          exception.toString(),
          // ignore: lines_longer_than_80_chars
          'ChopperException: Test message with response , \nResponse: Response<String>(Instance of \'Response0\', Error body, null)',
        );
      },
      testOn: 'chrome',
    );

    test('toString() with message and request', () {
      final chopperRequest = Request(
        'GET',
        Uri.parse('http://localhost/test'),
        Uri.parse('http://baseurl'),
      );
      final exception = ChopperException(
        'Test message with request',
        request: chopperRequest,
      );
      expect(
        exception.toString(),
        // ignore: lines_longer_than_80_chars
        'ChopperException: Test message with request , \nRequest: Request(GET, http://localhost/test, http://baseurl, null, {}, {}, false, [], null, null, null, null)',
      );
    });

    test(
      'toString() with message, response, and request',
      () {
        final baseResponse = http.Response('Not found', 404);
        final chopperResponse = Response(baseResponse, null);
        final chopperRequest = Request(
          'POST',
          Uri.parse('http://localhost/another/test'),
          Uri.parse('http://baseurl'),
          body: {'key': 'value'},
          headers: {'foo': 'bar'},
        );
        final exception = ChopperException(
          'Test message with response and request',
          response: chopperResponse,
          request: chopperRequest,
        );
        expect(
          exception.toString(),
          // ignore: lines_longer_than_80_chars
          'ChopperException: Test message with response and request , \nResponse: Response<Null>(Instance of \'Response\', null, null), \nRequest: Request(POST, http://localhost/another/test, http://baseurl, {key: value}, {}, {foo: bar}, false, [], null, null, null, null)',
        );
      },
      testOn: 'vm',
    );

    test(
      'toString() with message, response, and request',
      () {
        final baseResponse = http.Response('Not found', 404);
        final chopperResponse = Response(baseResponse, null);
        final chopperRequest = Request(
          'POST',
          Uri.parse('http://localhost/another/test'),
          Uri.parse('http://baseurl'),
          body: {'key': 'value'},
          headers: {'foo': 'bar'},
        );
        final exception = ChopperException(
          'Test message with response and request',
          response: chopperResponse,
          request: chopperRequest,
        );
        expect(
          exception.toString(),
          // ignore: lines_longer_than_80_chars
          'ChopperException: Test message with response and request , \nResponse: Response<Null>(Instance of \'Response0\', null, null), \nRequest: Request(POST, http://localhost/another/test, http://baseurl, {key: value}, {}, {foo: bar}, false, [], null, null, null, null)',
        );
      },
      testOn: 'chrome',
    );
  });
}
