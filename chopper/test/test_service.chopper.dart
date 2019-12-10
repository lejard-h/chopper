// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$HttpTestService extends HttpTestService {
  _$HttpTestService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = HttpTestService;

  @override
  Future<Response<String>> getTest(String id, {String dynamicHeader}) {
    final $url = '/test/get/$id';
    final $headers = {'test': dynamicHeader};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send<String, String>($request);
  }

  @override
  Future<Response> headTest() {
    final $url = '/test/head';
    final $request = Request('HEAD', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> getStreamTest() {
    final $url = '/test/get';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response> getAll() {
    final $url = '/test';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getAllWithTrailingSlash() {
    final $url = '/test/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getQueryTest({String name, int number, int def = 42}) {
    final $url = '/test/query';
    final $params = <String, dynamic>{
      'name': name,
      'int': number,
      'default_value': def
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getQueryMapTest(Map<String, dynamic> query) {
    final $url = '/test/query_map';
    final $params = query;
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getQueryMapTest2(Map<String, dynamic> query, {bool test}) {
    final $url = '/test/query_map';
    final $params = <String, dynamic>{'test': test};
    $params.addAll(query);
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postTest(String data) {
    final $url = '/test/post';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postStreamTest(Stream<List<int>> byteStream) {
    final $url = '/test/post';
    final $body = byteStream;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> putTest(String test, String data) {
    final $url = '/test/put/$test';
    final $body = data;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> deleteTest(String id) {
    final $url = '/test/delete/$id';
    final $headers = {'foo': 'bar'};
    final $request = Request('DELETE', $url, client.baseUrl, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> patchTest(String id, String data) {
    final $url = '/test/patch/$id';
    final $body = data;
    final $request = Request('PATCH', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> mapTest(Map<String, String> map) {
    final $url = '/test/map';
    final $body = map;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postForm(Map<String, String> fields) {
    final $url = '/test/form/body';
    final $body = fields;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request,
        requestConverter: convertForm);
  }

  @override
  Future<Response> postFormUsingHeaders(Map<String, String> fields) {
    final $url = '/test/form/body';
    final $headers = {'content-type': 'application/x-www-form-urlencoded'};
    final $body = fields;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postFormFields(String foo, int bar) {
    final $url = '/test/form/body/fields';
    final $body = <String, dynamic>{'foo': foo, 'bar': bar};
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request,
        requestConverter: convertForm);
  }

  @override
  Future<Response> forceJsonTest(Map map) {
    final $url = '/test/map/json';
    final $body = map;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request,
        requestConverter: customConvertRequest,
        responseConverter: customConvertResponse);
  }

  @override
  Future<Response> postResources(Map a, Map b) {
    final $url = '/test/multi';
    final $parts = <PartValue>[PartValue<Map>('1', a), PartValue<Map>('2', b)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postFile(List<int> bytes) {
    final $url = '/test/file';
    final $parts = <PartValue>[PartValueFile<List<int>>('file', bytes)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postMultipartFile(MultipartFile file, {String id}) {
    final $url = '/test/file';
    final $parts = <PartValue>[
      PartValue<String>('id', id),
      PartValueFile<MultipartFile>('file', file)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> postListFiles(List<MultipartFile> files) {
    final $url = '/test/files';
    final $parts = <PartValue>[
      PartValueFile<List<MultipartFile>>('files', files)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future fullUrl() {
    final $url = 'https://test.com';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  @override
  Future<Response<List<String>>> listString() {
    final $url = '/test/list/string';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response> noBody() {
    final $url = '/test/no-body';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
