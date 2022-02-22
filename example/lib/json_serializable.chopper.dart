// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable.dart';

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
    final $url = '/resources/${id}/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Resource>>> getResources() {
    final $url = '/resources/all';
    final $headers = {
      'test': 'list',
    };

    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<List<Resource>, Resource>($request);
  }

  @override
  Future<Response<Map<dynamic, dynamic>>> getMapResource(String id) {
    final $url = '/resources/';
    final $params = <String, dynamic>{'id': id};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<Map<dynamic, dynamic>, Map<dynamic, dynamic>>($request);
  }

  @override
  Future<Response<Resource>> getTypedResource() {
    final $url = '/resources/';
    final $headers = {
      'foo': 'bar',
    };

    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<Resource, Resource>($request);
  }

  @override
  Future<Response<Resource>> newResource(Resource resource, {String? name}) {
    final $url = '/resources';
    final $headers = {
      if (name != null) 'name': name,
    };

    final $body = resource;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<Resource, Resource>($request);
  }
}
