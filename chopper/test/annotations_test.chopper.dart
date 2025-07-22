// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotations_test.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$DeprecatedAnnotationService extends DeprecatedAnnotationService {
  _$DeprecatedAnnotationService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = DeprecatedAnnotationService;

  @override
  Future<Response<String>> testGet() {
    final Uri $url = Uri.parse('/test/get');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>> testPost(dynamic body) {
    final Uri $url = Uri.parse('/test/post');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPut(dynamic body) {
    final Uri $url = Uri.parse('/test/put');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPatch(dynamic body) {
    final Uri $url = Uri.parse('/test/patch');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testDelete() {
    final Uri $url = Uri.parse('/test/delete');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testHead() {
    final Uri $url = Uri.parse('/test/head');
    final Request $request = Request(
      'HEAD',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testOptions() {
    final Uri $url = Uri.parse('/test/options');
    final Request $request = Request(
      'OPTIONS',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ShorthandAnnotationService extends ShorthandAnnotationService {
  _$ShorthandAnnotationService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ShorthandAnnotationService;

  @override
  Future<Response<dynamic>> testGetShorthand() {
    final Uri $url = Uri.parse('/shorthand');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPostShorthand(dynamic body) {
    final Uri $url = Uri.parse('/shorthand');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPutShorthand(dynamic body) {
    final Uri $url = Uri.parse('/shorthand');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPatchShorthand(dynamic body) {
    final Uri $url = Uri.parse('/shorthand');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testDeleteShorthand() {
    final Uri $url = Uri.parse('/shorthand');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testHeadShorthand() {
    final Uri $url = Uri.parse('/shorthand');
    final Request $request = Request(
      'HEAD',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testOptionsShorthand() {
    final Uri $url = Uri.parse('/shorthand');
    final Request $request = Request(
      'OPTIONS',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPathShorthand(String id) {
    final Uri $url = Uri.parse('/shorthand/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testQueryShorthand(String name) {
    final Uri $url = Uri.parse('/shorthand/query');
    final Map<String, dynamic> $params = <String, dynamic>{'name': name};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testQueryMapShorthand(Map<String, dynamic> map) {
    final Uri $url = Uri.parse('/shorthand/queryMap');
    final Map<String, dynamic> $params = map;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testHeaderShorthand(String testHeader) {
    final Uri $url = Uri.parse('/shorthand/header');
    final Map<String, String> $headers = {
      'testHeader': testHeader,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testFieldShorthand(String data) {
    final Uri $url = Uri.parse('/shorthand/field');
    final Map<String, String> $headers = {
      'content-type': 'application/x-www-form-urlencoded',
    };
    final $body = <String, String>{'data': data.toString()};
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testFieldMapShorthand(Map<String, dynamic> data) {
    final Uri $url = Uri.parse('/shorthand/fieldMap');
    final Map<String, String> $headers = {
      'content-type': 'application/x-www-form-urlencoded',
    };
    final $body = data.map<String, String>((
      key,
      value,
    ) {
      return MapEntry(
        key.toString(),
        value.toString(),
      );
    });
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPartShorthand(String data) {
    final Uri $url = Uri.parse('/shorthand/multipart');
    final List<PartValue> $parts = <PartValue>[
      PartValue<String>(
        'data',
        data,
      )
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPartFileShorthand(List<int> data) {
    final Uri $url = Uri.parse('/shorthand/partFile');
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<int>>(
        'data',
        data,
      )
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPartMapShorthand(
      List<PartValue<dynamic>> data) {
    final Uri $url = Uri.parse('/shorthand/partMap');
    final List<PartValue> $parts = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testPartFileMapShorthand(
      List<PartValueFile<dynamic>> data) {
    final Uri $url = Uri.parse('/shorthand/partFileMap');
    final List<PartValue> $parts = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> testTagShorthand(String myTag) {
    final Uri $url = Uri.parse('/shorthand/tag');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: myTag,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
