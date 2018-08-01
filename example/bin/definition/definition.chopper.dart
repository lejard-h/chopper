// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class MyService extends ChopperService implements MyServiceDefinition {
  Future<Response> getResource(String id) {
    final url = '/$id/';
    final request = new Request('GET', url);
    return client.send(request);
  }

  Future<Response<Map>> getMapResource(String id) {
    final url = '/';
    final params = {'id': id};
    final request = new Request('GET', url, parameters: params);
    return client.send<Map>(request, responseType: Map);
  }

  Future<Response<Resource>> getTypedResource() {
    final url = '/';
    final headers = {'foo': 'bar'};
    final request = new Request('GET', url, headers: headers);
    return client.send<Resource>(request, responseType: Resource);
  }

  Future<Response<Resource>> newResource(Resource resource, {String name}) {
    final url = '/';
    final headers = {'name': name};
    final request = new Request('POST', url, body: resource, headers: headers);
    return client.send<Resource>(request, responseType: Resource);
  }
}
