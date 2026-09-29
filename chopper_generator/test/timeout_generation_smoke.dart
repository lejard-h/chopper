import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;

import 'test_service.dart';

final class _AbortTriggerClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.AbortableRequest || request.abortTrigger == null) {
      throw StateError('Generated timeout did not set an HTTP abort trigger.');
    }

    return http.StreamedResponse(Stream.value(utf8.encode('ok')), 200);
  }
}

Future<void> main() async {
  final ChopperClient chopper = ChopperClient(
    baseUrl: Uri.parse('https://example.com'),
    services: [HttpTestService.create()],
    client: _AbortTriggerClient(),
  );

  try {
    await chopper.getService<HttpTestService>().getTimeoutTest();
  } finally {
    chopper.dispose();
  }
}
