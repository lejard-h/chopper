// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$HttpTestService extends HttpTestService with ChopperServiceMixin {
  _$HttpTestService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = HttpTestService;

  Future<Response> getTest(String id, {String dynamicHeader}) {
    final url = '/test/get/$id';
    final headers = {'test': dynamicHeader};
    final request = new Request('GET', url, headers: headers);
    return client.send(request);
  }

  Future<Response> postTest(String data) {
    final url = '/test/post';
    final body = data;
    final request = new Request('POST', url, body: body);
    return client.send(request);
  }

  Future<Response> putTest(String test, String data) {
    final url = '/test/put/$test';
    final body = data;
    final request = new Request('PUT', url, body: body);
    return client.send(request);
  }

  Future<Response> deleteTest(String id) {
    final url = '/test/delete/$id';
    final headers = {'foo': 'bar'};
    final request = new Request('DELETE', url, headers: headers);
    return client.send(request);
  }

  Future<Response> patchTest(String id, String data) {
    final url = '/test/patch/$id';
    final body = data;
    final request = new Request('PATCH', url, body: body);
    return client.send(request);
  }

  Future<Response> mapTest(Map map) {
    final url = '/test/map';
    final body = map;
    final request = new Request('POST', url, body: body);
    return client.send(request);
  }

  Future<Response> forceJsonTest(Map map) {
    final url = '/test/map/json';
    final body = map;
    final request = new Request('POST', url, body: body, json: true);
    return client.send(request);
  }

  Future<Response> forceFormTest(Map map) {
    final url = '/test/map/form';
    final body = map;
    final request = new Request('POST', url, body: body, formUrlEncoded: true);
    return client.send(request);
  }

  Future<Response> postResources(Map a, Map b) {
    final url = '/test/multi';
    final parts = [new PartValue<Map>('1', a), new PartValue<Map>('2', b)];
    final request = new Request('POST', url, parts: parts, multipart: true);
    return client.send(request);
  }

  Future<Response> postFile(List<int> bytes) {
    final url = '/test/file';
    final parts = [new PartFile<List<int>>('file', bytes)];
    final request = new Request('POST', url, parts: parts, multipart: true);
    return client.send(request);
  }
}
