// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$HttpTestService extends HttpTestService {
  _$HttpTestService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = HttpTestService;

  Future<Response> getTest(String id, {String dynamicHeader: null}) {
    final $url = '/test/get/$id';
    final $headers = {'test': dynamicHeader};
    final $request =
        new Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getQueryTest(
      {String name: null, int number: null, int def: 42}) {
    final $url = '/test/query';
    final Map<String, dynamic> $params = {
      'name': name,
      'int': number,
      'default_value': def
    };
    final $request =
        new Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getQueryMapTest(Map<String, dynamic> query) {
    final $url = '/test/query_map';
    final $params = query;
    final $request =
        new Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getQueryMapTest2(Map<String, dynamic> query,
      {bool test: null}) {
    final $url = '/test/query_map';
    final Map<String, dynamic> $params = {'test': test};
    $params.addAll(query);
    final $request =
        new Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postTest(String data) {
    final $url = '/test/post';
    final $body = data;
    final $request = new Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> putTest(String test, String data) {
    final $url = '/test/put/$test';
    final $body = data;
    final $request = new Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> deleteTest(String id) {
    final $url = '/test/delete/$id';
    final $headers = {'foo': 'bar'};
    final $request =
        new Request('DELETE', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> patchTest(String id, String data) {
    final $url = '/test/patch/$id';
    final $body = data;
    final $request = new Request('PATCH', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> mapTest(Map map) {
    final $url = '/test/map';
    final $body = map;
    final $request = new Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> forceJsonTest(Map map) {
    final $url = '/test/map/json';
    final $body = map;
    final $request = new Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request,
        requestConverter: customConvertRequest,
        responseConverter: customConvertResponse);
  }

  Future<Response> postResources(Map a, Map b) {
    final $url = '/test/multi';
    final $parts = [new PartValue<Map>('1', a), new PartValue<Map>('2', b)];
    final $request = new Request('POST', $url, client.baseUrl,
        parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postFile(List<int> bytes) {
    final $url = '/test/file';
    final $parts = [new PartFile<List<int>>('file', bytes)];
    final $request = new Request('POST', $url, client.baseUrl,
        parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future fullUrl() {
    final $url = 'https://test.com';
    final $request = new Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response<List<String>>> listString() {
    final $url = '/test/list/string';
    final $request = new Request('GET', $url, client.baseUrl);
    return client.send<List<String>, String>($request);
  }
}
