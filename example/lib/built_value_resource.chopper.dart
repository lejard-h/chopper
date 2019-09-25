// GENERATED CODE - DO NOT MODIFY BY HAND

part of resource;

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

  Future<Response<BuiltList<Resource>>> getBuiltListResources() {
    final $url = '/resources/list';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<BuiltList<Resource>, Resource>($request);
  }

  Future<Response<Resource>> getTypedResource() {
    final $url = '/resources/';
    final $headers = {'foo': 'bar'};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<Resource, Resource>($request);
  }

  Future<Response<Resource>> newResource(Resource resource, {String name}) {
    final $url = '/resources';
    final $headers = {'name': name};
    final $body = resource;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<Resource, Resource>($request);
  }
}
