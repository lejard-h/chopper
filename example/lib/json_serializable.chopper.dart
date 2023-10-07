// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: type=lint
final class _$MyService extends MyService {
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
  Future<Response<List<Resource>>> getResources() {
    final Uri $url = Uri.parse('/resources/all');
    final Map<String, String> $headers = {
      'test': 'list',
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<List<Resource>, Resource>($request);
  }

  @override
  Future<Response<Map<dynamic, dynamic>>> getMapResource(String id) {
    final Uri $url = Uri.parse('/resources/');
    final Map<String, dynamic> $params = <String, dynamic>{'id': id};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<dynamic, dynamic>, Map<dynamic, dynamic>>($request);
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
