// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service_variable.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$HttpTestServiceVariable extends HttpTestServiceVariable {
  _$HttpTestServiceVariable([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = HttpTestServiceVariable;

  @override
  Future<Response<String>> getTest(
    String id, {
    required String dynamicHeader,
  }) {
    final Uri $url = Uri.parse('${service}/get/${id}');
    final Map<String, String> $headers = {
      'test': dynamicHeader,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>> headTest() {
    final Uri $url = Uri.parse('${service}/head');
    final Request $request = Request(
      'HEAD',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> optionsTest() {
    final Uri $url = Uri.parse('${service}/options');
    final Request $request = Request(
      'OPTIONS',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Stream<List<int>>>> getStreamTest() {
    final Uri $url = Uri.parse('${service}/get');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Stream<List<int>>, int>($request);
  }

  @override
  Future<Response<dynamic>> getAll() {
    final Uri $url = Uri.parse('${service}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllWithTrailingSlash() {
    final Uri $url = Uri.parse('${service}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryTest({
    String name = '',
    int? number,
    int? def = 42,
  }) {
    final Uri $url = Uri.parse('${service}/query');
    final Map<String, dynamic> $params = <String, dynamic>{
      'name': name,
      'int': number,
      'default_value': def,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryMapTest(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('${service}/query_map');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryMapTest2(
    Map<String, dynamic> query, {
    bool? test,
  }) {
    final Uri $url = Uri.parse('${service}/query_map');
    final Map<String, dynamic> $params = <String, dynamic>{'test': test};
    $params.addAll(query);
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryMapTest3({
    String name = '',
    int? number,
    Map<String, dynamic> filters = const {},
  }) {
    final Uri $url = Uri.parse('${service}/query_map');
    final Map<String, dynamic> $params = <String, dynamic>{
      'name': name,
      'number': number,
    };
    $params.addAll(filters);
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryMapTest4({
    String name = '',
    int? number,
    Map<String, dynamic>? filters,
  }) {
    final Uri $url = Uri.parse('${service}/query_map');
    final Map<String, dynamic> $params = <String, dynamic>{
      'name': name,
      'number': number,
    };
    $params.addAll(filters ?? const {});
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getQueryMapTest5({Map<String, dynamic>? filters}) {
    final Uri $url = Uri.parse('${service}/query_map');
    final Map<String, dynamic> $params = filters ?? const {};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getBody(dynamic body) {
    final Uri $url = Uri.parse('${service}/get_body');
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postTest(String data) {
    final Uri $url = Uri.parse('${service}/post');
    final $body = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postStreamTest(Stream<List<int>> byteStream) {
    final Uri $url = Uri.parse('${service}/post');
    final $body = byteStream;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> putTest(
    String test,
    String data,
  ) {
    final Uri $url = Uri.parse('${service}/put/${test}');
    final $body = data;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteTest(String id) {
    final Uri $url = Uri.parse('${service}/delete/${id}');
    final Map<String, String> $headers = {
      'foo': 'bar',
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> patchTest(
    String id,
    String data,
  ) {
    final Uri $url = Uri.parse('${service}/patch/${id}');
    final $body = data;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> mapTest(Map<String, String> map) {
    final Uri $url = Uri.parse('${service}/map');
    final $body = map;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postForm(Map<String, String> fields) {
    final Uri $url = Uri.parse('${service}/form/body');
    final $body = fields;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>(
      $request,
      requestConverter: convertForm,
    );
  }

  @override
  Future<Response<dynamic>> postFormUsingHeaders(Map<String, String> fields) {
    final Uri $url = Uri.parse('${service}/form/body');
    final Map<String, String> $headers = {
      'content-type': 'application/x-www-form-urlencoded',
    };
    final $body = fields;
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
  Future<Response<dynamic>> postFormFields(
    String foo,
    int bar,
  ) {
    final Uri $url = Uri.parse('${service}/form/body/fields');
    final $body = <String, dynamic>{
      'foo': foo,
      'bar': bar,
    };
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>(
      $request,
      requestConverter: convertForm,
    );
  }

  @override
  Future<Response<dynamic>> forceJsonTest(Map<dynamic, dynamic> map) {
    final Uri $url = Uri.parse('${service}/map/json');
    final $body = map;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>(
      $request,
      requestConverter: customConvertRequest,
      responseConverter: customConvertResponse,
    );
  }

  @override
  Future<Response<dynamic>> postResources(
    Map<dynamic, dynamic> a,
    Map<dynamic, dynamic> b,
  ) {
    final Uri $url = Uri.parse('${service}/multi');
    final List<PartValue> $parts = <PartValue>[
      PartValue<Map<dynamic, dynamic>>(
        '1',
        a,
      ),
      PartValue<Map<dynamic, dynamic>>(
        '2',
        b,
      ),
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
  Future<Response<dynamic>> postFile(List<int> bytes) {
    final Uri $url = Uri.parse('${service}/file');
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<int>>(
        'file',
        bytes,
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
  Future<Response<dynamic>> postImage(List<int> imageData) {
    final Uri $url = Uri.parse('${service}/image');
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<int>>(
        'image',
        imageData,
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
  Future<Response<dynamic>> postMultipartFile(
    MultipartFile file, {
    String? id,
  }) {
    final Uri $url = Uri.parse('${service}/file');
    final List<PartValue> $parts = <PartValue>[
      PartValue<String?>(
        'id',
        id,
      ),
      PartValueFile<MultipartFile>(
        'file',
        file,
      ),
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
  Future<Response<dynamic>> postListFiles(List<MultipartFile> files) {
    final Uri $url = Uri.parse('${service}/files');
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<MultipartFile>>(
        'files',
        files,
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
  Future<Response<dynamic>> postMultipartList({
    required List<int> ints,
    required List<double> doubles,
    required List<num> nums,
    required List<String> strings,
  }) {
    final Uri $url = Uri.parse('${service}/multipart_list');
    final List<PartValue> $parts = <PartValue>[
      PartValue<List<int>>(
        'ints',
        ints,
      ),
      PartValue<List<double>>(
        'doubles',
        doubles,
      ),
      PartValue<List<num>>(
        'nums',
        nums,
      ),
      PartValue<List<String>>(
        'strings',
        strings,
      ),
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
  Future<Response<dynamic>> fullUrl() {
    final Uri $url = Uri.parse('https://test.com');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<String>>> listString() {
    final Uri $url = Uri.parse('${service}/list/string');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<dynamic>> noBody() {
    final Uri $url = Uri.parse('${service}/no-body');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<String>> getUsingQueryParamIncludeNullQueryVars({
    String? foo,
    String? bar,
    String? baz,
  }) {
    final Uri $url =
        Uri.parse('${service}/query_param_include_null_query_vars');
    final Map<String, dynamic> $params = <String, dynamic>{
      'foo': foo,
      'bar': bar,
      'baz': baz,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      includeNullQueryVars: true,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParam(List<String> value) {
    final Uri $url = Uri.parse('${service}/list_query_param');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParamWithBracketsLegacy(
      List<String> value) {
    final Uri $url =
        Uri.parse('${service}/list_query_param_with_brackets_legacy');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      useBrackets: true,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParamWithBrackets(
      List<String> value) {
    final Uri $url = Uri.parse('${service}/list_query_param_with_brackets');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.brackets,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParamWithIndices(
      List<String> value) {
    final Uri $url = Uri.parse('${service}/list_query_param_with_indices');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.indices,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParamWithRepeat(
      List<String> value) {
    final Uri $url = Uri.parse('${service}/list_query_param_with_repeat');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.repeat,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingListQueryParamWithComma(List<String> value) {
    final Uri $url = Uri.parse('${service}/list_query_param_with_comma');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.comma,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParam(Map<String, dynamic> value) {
    final Uri $url = Uri.parse('${service}/map_query_param');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamIncludeNullQueryVars(
      Map<String, dynamic> value) {
    final Uri $url =
        Uri.parse('${service}/map_query_param_include_null_query_vars');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      includeNullQueryVars: true,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamWithBracketsLegacy(
      Map<String, dynamic> value) {
    final Uri $url =
        Uri.parse('${service}/map_query_param_with_brackets_legacy');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      useBrackets: true,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamWithBrackets(
      Map<String, dynamic> value) {
    final Uri $url = Uri.parse('${service}/map_query_param_with_brackets');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.brackets,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamWithIndices(
      Map<String, dynamic> value) {
    final Uri $url = Uri.parse('${service}/map_query_param_with_indices');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.indices,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamWithRepeat(
      Map<String, dynamic> value) {
    final Uri $url = Uri.parse('${service}/map_query_param_with_repeat');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.repeat,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> getUsingMapQueryParamWithComma(
      Map<String, dynamic> value) {
    final Uri $url = Uri.parse('${service}/map_query_param_with_comma');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.comma,
    );
    return client.send<String, String>($request);
  }
}
