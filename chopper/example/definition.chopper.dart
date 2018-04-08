// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// Generator: ChopperGenerator
// **************************************************************************

class MyService extends ChopperService implements MyServiceDefinition {
  Future<Response> getResource(String id) {
    final url = '/$id';
    final request = new Request('GET', url);
    return client.send(request);
  }

  Future<Response<Map>> getMapResource(String id) {
    final url = '/';
    final params = {'id': id};
    final headers = {'foo': 'bar'};
    final request =
        new Request('GET', url, parameters: params, headers: headers);
    return client.send<Map>(request, responseType: Map);
  }
}
