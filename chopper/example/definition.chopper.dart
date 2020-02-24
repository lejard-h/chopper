// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$MyService extends MyService {
  _$MyService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = MyService;

  @override
  Future<Response<dynamic>> getResource(String id) {
    final $url = '/resources/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Map<dynamic, dynamic>>> getMapResource(String id) {
    final $url = '/resources/';
    final $params = <String, dynamic>{'id': id};
    final $headers = {'foo': 'bar'};
    final $request = Request('GET', $url, client.baseUrl,
        parameters: $params, headers: $headers);
    return client.send<Map<dynamic, dynamic>, Map<dynamic, dynamic>>($request);
  }

  @override
  Future<Response<List<Map<dynamic, dynamic>>>> getListResources() {
    final $url = '/resources/resources';
    final $request = Request('GET', $url, client.baseUrl);
    return client
        .send<List<Map<dynamic, dynamic>>, Map<dynamic, dynamic>>($request);
  }

  @override
  Future<Response<dynamic>> postResourceUrlEncoded(String toto, String b) {
    final $url = '/resources/';
    final $body = <String, dynamic>{'a': toto, 'b': b};
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postResources(
      Map<dynamic, dynamic> a, Map<dynamic, dynamic> b, String c) {
    final $url = '/resources/multi';
    final $parts = <PartValue>[
      PartValue<Map<dynamic, dynamic>>('1', a),
      PartValue<Map<dynamic, dynamic>>('2', b),
      PartValue<String>('3', c)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postFile(List<int> bytes) {
    final $url = '/resources/file';
    final $parts = <PartValue>[PartValue<List<int>>('file', bytes)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }
}
