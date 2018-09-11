// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class MyService extends ChopperService implements MyServiceDefinition {
  Future<Response> getResource(String id) {
    final url = '/resources/$id';
    final request = new Request('GET', url);
    return client.send(request);
  }

  Future<Response<Map>> getMapResource(String id) {
    final url = '/resources/';
    final params = {'id': id};
    final headers = {'foo': 'bar'};
    final request =
        new Request('GET', url, parameters: params, headers: headers);
    return client.send<Map>(request);
  }

  Future<Response> postResourceUrlEncoded(String toto, String b) {
    final url = '/resources/';
    final body = {'a': toto, 'b': b};
    final request = new Request('POST', url, body: body, formUrlEncoded: true);
    return client.send(request);
  }

  Future<Response> postResources(Map a, Map b, String c) {
    final url = '/resources/multi';
    final parts = [
      new PartValue<Map>('1', a),
      new PartValue<Map>('2', b),
      new PartValue<String>('3', c)
    ];
    final request = new Request('POST', url, parts: parts, multipart: true);
    return client.send(request);
  }

  Future<Response> postFile(List<int> bytes) {
    final url = '/resources/file';
    final parts = [new PartFile<List<int>>('file', bytes)];
    final request = new Request('POST', url, parts: parts, multipart: true);
    return client.send(request);
  }
}
