// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class HttpTestService extends ChopperService
    implements HttpTestServiceDefinition {
  Future<Response> getTest(String id) {
    final url = '/test/get/$id';
    final request = new Request('GET', url);
    return client.send(request);
  }

  Future<Response> postTest(String data) {
    final url = '/test/post';
    final body = data;
    final request = new Request('POST', url, body: body);
    return client.send(request);
  }

  Future<Response> putTest(String id, String data) {
    final url = '/test/put/$id';
    final body = data;
    final request = new Request('PUT', url, body: body);
    return client.send(request);
  }

  Future<Response> deleteTest(String id) {
    final url = '/test/delete/$id';
    final request = new Request('DELETE', url);
    return client.send(request);
  }

  Future<Response> patchTest(String id, String data) {
    final url = '/test/patch/$id';
    final body = data;
    final request = new Request('PATCH', url, body: body);
    return client.send(request);
  }
}
