// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$MyService extends MyService {
  _$MyService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = MyService;

  Future<Response> getResource(String id) {
    final $url = '/resources/${id}/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response<List<Resource>>> getResources() {
    final $url = '/resources/all';
    final $headers = {'test': 'list'};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<List<Resource>, Resource>($request);
  }

  Future<Response<Map>> getMapResource(String id) {
    final $url = '/resources/';
    final Map<String, dynamic> $params = {'id': id};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Map, Map>($request);
  }

  Future<Response<Resource>> getTypedResource() {
    final $url = '/resources/';
    final $headers = {'foo': 'bar'};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<Resource, Resource>($request);
  }

  Future<Response<Resource>> newResource(Resource resource,
      {String name = null}) {
    final $url = '/resources/';
    final $headers = {'name': name};
    final $body = resource;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<Resource, Resource>($request);
  }

  Future<Response> fieldsPost(String a, int b, double c) {
    final $url = '/resources/feilds/post';
    final $body = {'1': a, '2': b, '3': c};
    $body.removeWhere((key, value) => value == null);
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postResources(Map a, Map b, String c) {
    final $url = '/resources/multi';
    final List<PartValue> $parts = [
      a == null ? null : PartValue<Map>('1', a),
      b == null ? null : PartValue<Map>('2', b),
      c == null ? null : PartValue<String>('3', c)
    ];
    $parts.removeWhere((val) => val == null);
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postFile(List<int> bytes) {
    final $url = '/resources/file';
    final List<PartValue> $parts = [
      bytes == null ? null : PartFile<List<int>>('file', bytes)
    ];
    $parts.removeWhere((val) => val == null);
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postMultiOptional(Map map, String str, List<int> bytes,
      {Map opMap = null, String opStr = null, List<int> opBytes = null}) {
    final $url = '/resources/file';
    final List<PartValue> $parts = [
      map == null ? null : PartValue<Map>('map', map),
      str == null ? null : PartValue<String>('str', str),
      opMap == null ? null : PartValue<Map>('opMap', opMap),
      opStr == null ? null : PartValue<String>('opStr', opStr),
      bytes == null ? null : PartFile<List<int>>('file', bytes),
      opBytes == null ? null : PartFile<List<int>>('opBytes', opBytes)
    ];
    $parts.removeWhere((val) => val == null);
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }
}
