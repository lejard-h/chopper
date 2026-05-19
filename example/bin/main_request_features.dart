import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:chopper_example/request_features.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Simple client to have a working example without a remote server.
final client = MockClient.streaming((req, bodyStream) async {
  if (req.url.path == '/features/search') {
    if (req case http.Abortable(:final abortTrigger?)) {
      await abortTrigger;
      throw ChopperRequestAbortedException(req.url);
    }

    return _response('search query: ${req.url.query}', 200);
  }
  if (req.url.path == '/features/form' && req.method == 'POST') {
    final body = await utf8.decodeStream(bodyStream);
    return _response('form body: $body', 200);
  }

  return _response('not found', 404);
});

Future<void> main() async {
  final chopper = ChopperClient(
    client: client,
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [RequestFeatureService.create()],
  );

  final service = chopper.getService<RequestFeatureService>();

  final searchResponse = await service.searchResources({
    'labels': ['dart', 'chopper'],
    'metadata': {'owner': 'examples'},
  }, startsAt: DateTime(2026, 5, 19));
  print(searchResponse.body);

  final abort = Completer<void>();
  final pendingSearch = service.searchResources(
    {
      'labels': ['slow'],
    },
    startsAt: DateTime(2026, 5, 19),
    abortTrigger: abort.future,
  );

  abort.complete();

  try {
    await pendingSearch;
  } on ChopperRequestAbortedException {
    print('search aborted');
  }

  final formResponse = await service.submitForm('42', 'archive');
  print(formResponse.body);

  chopper.dispose();
}

http.StreamedResponse _response(String body, int statusCode) {
  final bytes = utf8.encode(body);

  return http.StreamedResponse(
    Stream.value(bytes),
    statusCode,
    contentLength: bytes.length,
  );
}
