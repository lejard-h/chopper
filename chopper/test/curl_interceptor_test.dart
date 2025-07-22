import 'package:chopper/src/interceptors/curl_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'helpers/fake_chain.dart';

void main() {
  group('CurlInterceptor', () {
    late Request simpleRequest;
    late Request requestWithHeaders;
    late Request requestWithBody;
    late Request requestWithQuery;

    setUp(() {
      simpleRequest = Request(
        'GET',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
      );

      requestWithHeaders = Request(
        'GET',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
        headers: {
          'Authorization': 'Bearer token123',
          'Content-Type': 'application/json',
        },
      );

      requestWithBody = Request(
        'POST',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
        body: '{"name": "test", "value": 42}',
        headers: {'Content-Type': 'application/json'},
      );

      requestWithQuery = Request(
        'GET',
        Uri.parse('/resource?param1=value1&param2=value2'),
        Uri.parse('https://api.example.com'),
      );
    });

    test('generates basic curl command for simple requests', () async {
      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(simpleRequest));

      expect(logs, hasLength(1));
      expect(logs[0],
          contains("curl -v -X GET 'https://api.example.com/resource'"));
    });

    test('includes headers in curl command', () async {
      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(requestWithHeaders));

      expect(logs, hasLength(1));
      expect(logs[0], contains("-H 'Authorization: Bearer token123'"));
      expect(logs[0], contains("-H 'Content-Type: application/json'"));
    });

    test('includes body in curl command for POST requests', () async {
      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(requestWithBody));

      expect(logs, hasLength(1));
      expect(logs[0], contains("-d '{\"name\": \"test\", \"value\": 42}'"));
    });

    test('handles query parameters in URL', () async {
      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(requestWithQuery));

      expect(logs, hasLength(1));
      expect(
          logs[0],
          contains(
              "'https://api.example.com/resource?param1=value1&param2=value2'"));
    });

    test('escapes single quotes in body', () async {
      final requestWithQuotes = Request(
        'POST',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
        body: "{'name': 'John's data', 'value': 'test'}",
        // Body with a single quote that needs escaping
        headers: {'Content-Type': 'application/json'},
      );

      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(requestWithQuotes));

      expect(logs, hasLength(1));
      // The CurlInterceptor replaces single quotes with '\'' according to the implementation
      expect(logs[0], contains("John'\\''s data"));
    });

    test('proceeds with the chain without modifying request', () async {
      final interceptor = CurlInterceptor();
      final chain = FakeChain(requestWithBody);

      final response = await interceptor.intercept(chain);

      // FakeChain.proceed returns a Response with 'TestChain' content
      expect(response, isA<Response>());
      expect(response.base, isA<http.Response>());
      expect((response.base as http.Response).body, equals('TestChain'));
    });
  });

  group('CurlInterceptor with multipart requests', () {
    test('handles multipart requests with fields and files', () async {
      // Create a mock request that will return our multipart request
      final request = MockMultipartRequest(
        'POST',
        Uri.parse('/upload'),
        Uri.parse('https://api.example.com'),
      );

      // Add fields and files to the multipart request that will be returned
      request.setupMultipart((multipart) {
        multipart.fields['field1'] = 'value1';
        multipart.fields['field2'] = 'value2';
        multipart.files.add(http.MultipartFile.fromString(
            'file', 'test content',
            filename: 'test.txt'));
      });

      final interceptor = CurlInterceptor();
      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));

      await interceptor.intercept(FakeChain(request));

      expect(logs, hasLength(1));
      // Instead of checking for exact text that might change based on implementation,
      // verify that it contains the field names and values
      expect(logs[0], contains('curl -v -X POST'));
      expect(logs[0], contains('field1'));
      expect(logs[0], contains('value1'));
      expect(logs[0], contains('field2'));
      expect(logs[0], contains('value2'));
      expect(logs[0], contains('file'));
    });
  });
}

/// A Request that returns a MultipartRequest when toBaseRequest is called
// ignore: must_be_immutable
final class MockMultipartRequest extends Request {
  MockMultipartRequest(
    super.method,
    super.url,
    super.baseUrl, {
    super.body,
    super.headers,
  });

  final http.MultipartRequest _multipartRequest = http.MultipartRequest(
    'POST',
    Uri.parse('https://api.example.com/upload'),
  );

  void setupMultipart(void Function(http.MultipartRequest) setup) {
    setup(_multipartRequest);
  }

  @override
  Future<http.BaseRequest> toBaseRequest() async {
    return _multipartRequest;
  }
}
