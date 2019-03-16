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

  Future<Response> getTest(String id, {String dynamicHeader}) {
    final $url = '/test/get/$id';
    final $headers = {'test': dynamicHeader};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postTest(String data) {
    final $url = '/test/post';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> putTest(String test, String data) {
    final $url = '/test/put/$test';
    final $body = data;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> deleteTest(String id) {
    final $url = '/test/delete/$id';
    final $headers = {'foo': 'bar'};
    final $request = Request('DELETE', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> patchTest(String id, String data) {
    final $url = '/test/patch/$id';
    final $body = data;
    final $request = Request('PATCH', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> mapTest(Map map) {
    final $url = '/test/map';
    final $body = map;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> forceJsonTest(Map map) {
    final $url = '/test/map/json';
    final $body = map;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request,
        requestConverter: customConvertRequest,
        responseConverter: customConvertResponse);
  }

  Future<Response> postResources(Map a, Map b) {
    final $url = '/test/multi';
    final $parts = [PartValue<Map>('1', a), PartValue<Map>('2', b)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postFile(List<int> bytes) {
    final $url = '/test/file';
    final $parts = [PartFile<List<int>>('file', bytes)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  Future fullUrl() {
    final $url = 'https://test.com';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }
}
