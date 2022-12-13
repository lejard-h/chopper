// GENERATED CODE - DO NOT MODIFY BY HAND

part of resource;

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$MyService extends MyService {
  _$MyService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = MyService;

  @override
  Future<Response<dynamic>> getResource(String id) {
    final Uri $url = Uri.parse('/resources/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<BuiltList<Resource>>> getBuiltListResources() {
    final Uri $url = Uri.parse('/resources/list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<BuiltList<Resource>, Resource>($request);
  }

  @override
  Future<Response<Resource>> getTypedResource() {
    final Uri $url = Uri.parse('/resources/');
    final Map<String, String> $headers = {
      'foo': 'bar',
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<Resource, Resource>($request);
  }

  @override
  Future<Response<Resource>> newResource(
    Resource resource, {
    String? name,
  }) {
    final Uri $url = Uri.parse('/resources');
    final Map<String, String> $headers = {
      if (name != null) 'name': name,
    };
    final $body = resource;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<Resource, Resource>($request);
  }
}
