import 'dart:async';

import 'package:chopper/src/chopper_exception.dart';
import 'package:chopper/src/interceptors/http_call_interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'helpers/fake_chain.dart';

void main() {
  group('HttpCallInterceptor', () {
    late http.Client mockClient;
    late HttpCallInterceptor interceptor;

    setUp(() {
      mockClient = MockHttpClient();
      interceptor = HttpCallInterceptor(mockClient);
    });

    test('throws ChopperException for unsupported response type', () async {
      final request = Request(
        'GET',
        Uri.parse('/test'),
        Uri.parse('https://example.com'),
      );

      final chain = UnsupportedTypeChain(request);

      expect(
        () => interceptor.intercept(chain),
        throwsA(
          isA<ChopperException>()
              .having((e) => e.message, 'message', 'Unsupported type')
              .having((e) => e.request, 'request', equals(request)),
        ),
      );
    });
  });
}

// A custom Chain implementation that forces the HttpCallInterceptor to handle
// an unsupported response body type (int)
class UnsupportedTypeChain extends FakeChain<int> {
  UnsupportedTypeChain(super.request);
}

// Mock HTTP client that doesn't need to return anything for this test
class MockHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // We won't reach this code because the exception is thrown before the actual HTTP call
    return http.StreamedResponse(const Stream.empty(), 200);
  }
}
