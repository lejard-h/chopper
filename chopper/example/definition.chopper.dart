// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$MyService extends MyService {
  _$MyService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = MyService;

  @override
  Future<Response<dynamic>> getResource(String id) {
    final Uri $url = Uri.parse('/resources/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Map<dynamic, dynamic>>> getMapResource(String id) {
    final Uri $url = Uri.parse('/resources/');
    final Map<String, dynamic> $params = <String, dynamic>{'id': id};
    final Map<String, String> $headers = {'foo': 'bar'};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
    );
    return client.send<Map<dynamic, dynamic>, Map<dynamic, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<dynamic, dynamic>>>> getListResources() {
    final Uri $url = Uri.parse('/resources/resources');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<List<Map<dynamic, dynamic>>, Map<dynamic, dynamic>>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> postResourceUrlEncoded(String toto, String b) {
    final Uri $url = Uri.parse('/resources/');
    final $body = <String, dynamic>{'a': toto, 'b': b};
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postResources(
    Map<dynamic, dynamic> a,
    Map<dynamic, dynamic> b,
    String c,
  ) {
    final Uri $url = Uri.parse('/resources/multi');
    final List<PartValue> $parts = <PartValue>[
      PartValue<Map<dynamic, dynamic>>('1', a),
      PartValue<Map<dynamic, dynamic>>('2', b),
      PartValue<String>('3', c),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postFile(List<int> bytes) {
    final Uri $url = Uri.parse('/resources/file');
    final List<PartValue> $parts = <PartValue>[
      PartValue<List<int>>('file', bytes),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getMassiveFile() {
    final Uri $url = Uri.parse('/resources/assets/10GB.bin');
    final ChopperCompleter $abortTrigger = ChopperCompleter<void>();
    final ChopperTimer $timeout = ChopperTimer(
      const Duration(microseconds: 30000000),
      () {
        if (!$abortTrigger.isCompleted) $abortTrigger.complete();
      },
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      abortTrigger: $abortTrigger.future,
    );
    return client
        .send<dynamic, dynamic>($request)
        .catchError(
          (_) => Future<Response<dynamic>>.error(
            ChopperTimeoutException('Request timed out after 30 seconds'),
          ),
          test:
              (Object err) =>
                  err is ChopperRequestAbortedException &&
                  $abortTrigger.isCompleted,
        )
        .whenComplete($timeout.cancel);
  }
}
