// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_without_response_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$HttpTestService extends HttpTestService {
  _$HttpTestService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = HttpTestService;

  @override
  Future<String> getTest(
    String id, {
    required String dynamicHeader,
  }) async {
    final Uri $url = Uri.parse('/test/get/${id}');
    final Map<String, String> $headers = {
      'test': dynamicHeader,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> headTest() async {
    final Uri $url = Uri.parse('/test/head');
    final Request $request = Request(
      'HEAD',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> optionsTest() async {
    final Uri $url = Uri.parse('/test/options');
    final Request $request = Request(
      'OPTIONS',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Stream<List<int>>> getStreamTest() async {
    final Uri $url = Uri.parse('/test/get');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response =
        await client.send<Stream<List<int>>, int>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getAll() async {
    final Uri $url = Uri.parse('/test');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getAllWithTrailingSlash() async {
    final Uri $url = Uri.parse('/test/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryTest({
    String name = '',
    int? number,
    int? def = 42,
  }) async {
    final Uri $url = Uri.parse('/test/query');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryMapTest(Map<String, dynamic> query) async {
    final Uri $url = Uri.parse('/test/query_map');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryMapTest2(
    Map<String, dynamic> query, {
    bool? test,
  }) async {
    final Uri $url = Uri.parse('/test/query_map');
    final Map<String, dynamic> $params = <String, dynamic>{'test': test};
    $params.addAll(query);
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryMapTest3({
    String name = '',
    int? number,
    Map<String, dynamic> filters = const {},
  }) async {
    final Uri $url = Uri.parse('/test/query_map');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryMapTest4({
    String name = '',
    int? number,
    Map<String, dynamic>? filters,
  }) async {
    final Uri $url = Uri.parse('/test/query_map');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getQueryMapTest5({Map<String, dynamic>? filters}) async {
    final Uri $url = Uri.parse('/test/query_map');
    final Map<String, dynamic> $params = filters ?? const {};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> getBody(dynamic body) async {
    final Uri $url = Uri.parse('/test/get_body');
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postTest(String data) async {
    final Uri $url = Uri.parse('/test/post');
    final $body = data;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postStreamTest(Stream<List<int>> byteStream) async {
    final Uri $url = Uri.parse('/test/post');
    final $body = byteStream;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> putTest(
    String test,
    String data,
  ) async {
    final Uri $url = Uri.parse('/test/put/${test}');
    final $body = data;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<void> deleteTest(String id) async {
    final Uri $url = Uri.parse('/test/delete/${id}');
    final Map<String, String> $headers = {
      'foo': 'bar',
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    final Response $response = await client.send<void, void>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> patchTest(
    String id,
    String data,
  ) async {
    final Uri $url = Uri.parse('/test/patch/${id}');
    final $body = data;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> mapTest(Map<String, String> map) async {
    final Uri $url = Uri.parse('/test/map');
    final $body = map;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postForm(Map<String, String> fields) async {
    final Uri $url = Uri.parse('/test/form/body');
    final $body = fields;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>(
      $request,
      requestConverter: convertForm,
    );
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postFormUsingHeaders(Map<String, String> fields) async {
    final Uri $url = Uri.parse('/test/form/body');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postFormFields(
    String foo,
    int bar,
  ) async {
    final Uri $url = Uri.parse('/test/form/body/fields');
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
    final Response $response = await client.send<dynamic, dynamic>(
      $request,
      requestConverter: convertForm,
    );
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> forceJsonTest(Map<dynamic, dynamic> map) async {
    final Uri $url = Uri.parse('/test/map/json');
    final $body = map;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<dynamic, dynamic>(
      $request,
      requestConverter: customConvertRequest,
      responseConverter: customConvertResponse,
    );
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postResources(
    Map<dynamic, dynamic> a,
    Map<dynamic, dynamic> b,
  ) async {
    final Uri $url = Uri.parse('/test/multi');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postFile(List<int> bytes) async {
    final Uri $url = Uri.parse('/test/file');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postImage(List<int> imageData) async {
    final Uri $url = Uri.parse('/test/image');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postMultipartFile(
    MultipartFile file, {
    String? id,
  }) async {
    final Uri $url = Uri.parse('/test/file');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postListFiles(List<MultipartFile> files) async {
    final Uri $url = Uri.parse('/test/files');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> postMultipartList({
    required List<int> ints,
    required List<double> doubles,
    required List<num> nums,
    required List<String> strings,
  }) async {
    final Uri $url = Uri.parse('/test/multipart_list');
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
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> fullUrl() async {
    final Uri $url = Uri.parse('https://test.com');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<List<String>> listString() async {
    final Uri $url = Uri.parse('/test/list/string');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response =
        await client.send<List<String>, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<dynamic> noBody() async {
    final Uri $url = Uri.parse('/test/no-body');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
    );
    final Response $response = await client.send<dynamic, dynamic>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingQueryParamIncludeNullQueryVars({
    String? foo,
    String? bar,
    String? baz,
  }) async {
    final Uri $url = Uri.parse('/test/query_param_include_null_query_vars');
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
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParam(List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParamWithBracketsLegacy(
      List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param_with_brackets_legacy');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      useBrackets: true,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParamWithBrackets(List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param_with_brackets');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.brackets,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParamWithIndices(List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param_with_indices');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.indices,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParamWithRepeat(List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param_with_repeat');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.repeat,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingListQueryParamWithComma(List<String> value) async {
    final Uri $url = Uri.parse('/test/list_query_param_with_comma');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.comma,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParam(Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamIncludeNullQueryVars(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_include_null_query_vars');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      includeNullQueryVars: true,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamWithBracketsLegacy(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_with_brackets_legacy');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      useBrackets: true,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamWithBrackets(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_with_brackets');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.brackets,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamWithIndices(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_with_indices');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.indices,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamWithRepeat(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_with_repeat');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.repeat,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getUsingMapQueryParamWithComma(
      Map<String, dynamic> value) async {
    final Uri $url = Uri.parse('/test/map_query_param_with_comma');
    final Map<String, dynamic> $params = <String, dynamic>{'value': value};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.comma,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<String> getHeaders({
    required String stringHeader,
    bool? boolHeader,
    int? intHeader,
    double? doubleHeader,
    ExampleEnum? enumHeader,
  }) async {
    final Uri $url = Uri.parse('/test/headers');
    final Map<String, String> $headers = {
      'x-string': stringHeader,
      if (boolHeader != null) 'x-boolean': boolHeader.toString(),
      if (intHeader != null) 'x-int': intHeader.toString(),
      if (doubleHeader != null) 'x-double': doubleHeader.toString(),
      if (enumHeader != null) 'x-enum': enumHeader.toString(),
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    final Response $response = await client.send<String, String>($request);
    return $response.bodyOrThrow;
  }
}
