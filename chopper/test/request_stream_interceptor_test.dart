import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptors/request_stream_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('RequestStreamInterceptor', () {
    late List<Request> recordedRequests;
    late RequestStreamInterceptor interceptor;

    setUp(() {
      recordedRequests = [];
      interceptor = RequestStreamInterceptor((request) {
        recordedRequests.add(request);
      });
    });

    test('calls the callback with the request', () async {
      final request = Request(
        'POST',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
        body: 'test body',
      );

      final chain = CustomFakeChain(request);

      await interceptor.intercept(chain);

      // Verify the callback was called with the request
      expect(recordedRequests, hasLength(1));
      expect(recordedRequests.first, equals(request));

      // Verify the request was passed through to the chain
      expect(chain.processedRequest, equals(request));
    });

    test('handles requests with null body', () async {
      final request = Request(
        'GET',
        Uri.parse('/resource'),
        Uri.parse('https://api.example.com'),
      );

      final chain = CustomFakeChain(request);

      await interceptor.intercept(chain);

      // Verify the callback was called with the request
      expect(recordedRequests, hasLength(1));
      expect(recordedRequests.first, equals(request));
    });

    test(
      'handles requests with stream body (passes through)',
      () async {
        final streamController = StreamController<String>();
        final completer = Completer<void>();

        // Create a request with a stream body
        final request = Request(
          'POST',
          Uri.parse('/resource'),
          Uri.parse('https://api.example.com'),
          body: streamController.stream,
        );

        final chain = CustomFakeChain(request);

        // Add data to the stream and close it immediately to avoid hanging
        streamController.add('test data');
        streamController.close();

        // Properly handle the FutureOr return type
        final result = interceptor.intercept(chain);
        if (result is Future) {
          await result;
        }
        completer.complete();

        // Wait for the interceptor to complete
        await completer.future;

        // Verify the callback was called with the request
        expect(recordedRequests, hasLength(1));
        expect(recordedRequests.first, equals(request));

        // The stream should be the same instance, but we can't directly compare streams
        // Instead verify it's a Stream instance
        expect(chain.processedRequest?.body, isA<Stream<String>>());
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });
}

/// Custom implementation of FakeChain to track processed requests
class CustomFakeChain<T> implements Chain<T> {
  CustomFakeChain(this.request, {this.response});

  @override
  final Request request;

  final Response<T>? response;

  Request? processedRequest;

  @override
  Future<Response<T>> proceed(Request request) async {
    processedRequest = request;
    return Response<T>(http.Response('', 200), null as T);
  }
}
