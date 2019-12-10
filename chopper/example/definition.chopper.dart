// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$MyService extends MyService {
  _$MyService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = MyService;

  @override
  Future<Response> getResource(String id) {
    final $url = '/resources/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Map>> getMapResource(String id) {
    final $url = '/resources/';
    final $params = <String, dynamic>{'id': id};
    final $headers = {'foo': 'bar'};
    final $request = Request('GET', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<Map, Map>($request);
  }

  @override
  Future<Response<List<Map>>> getListResources() {
    final $url = '/resources/resources';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<Map>, Map>($request);
  }

  @override
  Future<Response> postResourceUrlEncoded(String toto, String b) {
    final $url = '/resources/';
    final $body = <String, dynamic>{'a': toto, 'b': b};
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postResources(Map a, Map b, String c) {
    final $url = '/resources/multi';
    final $parts = <PartValue>[
      PartValue<Map>('1', a),
      PartValue<Map>('2', b),
      PartValue<String>('3', c)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postFile(List<int> bytes) {
    final $url = '/resources/file';
    final $parts = <PartValue>[PartValue<List<int>>('file', bytes)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }
}
