// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service_base_url.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$HttpTestServiceBaseUrl extends HttpTestServiceBaseUrl {
  _$HttpTestServiceBaseUrl([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = HttpTestServiceBaseUrl;

  @override
  Future<Response<dynamic>> getAll() {
    final Uri $url = Uri.parse('https://localhost:4000/test');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllWithTrailingSlash() {
    final Uri $url = Uri.parse('https://localhost:4000/test/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<String>>> listString() {
    final Uri $url = Uri.parse('https://localhost:4000/test/list/string');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<String>> getUsingQueryParamIncludeNullQueryVars({
    String? foo,
    String? bar,
    String? baz,
  }) {
    final Uri $url = Uri.parse(
        'https://localhost:4000/test/query_param_include_null_query_vars');
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
    final Uri $url = Uri.parse('https://localhost:4000/test/list_query_param');
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
    final Uri $url = Uri.parse(
        'https://localhost:4000/test/list_query_param_with_brackets_legacy');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/list_query_param_with_brackets');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/list_query_param_with_indices');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/list_query_param_with_repeat');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/list_query_param_with_comma');
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
    final Uri $url = Uri.parse('https://localhost:4000/test/map_query_param');
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
    final Uri $url = Uri.parse(
        'https://localhost:4000/test/map_query_param_include_null_query_vars');
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
    final Uri $url = Uri.parse(
        'https://localhost:4000/test/map_query_param_with_brackets_legacy');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/map_query_param_with_brackets');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/map_query_param_with_indices');
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
    final Uri $url =
        Uri.parse('https://localhost:4000/test/map_query_param_with_repeat');
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
  Future<Response<String>> getUsingMapQueryParamWithComa(
      Map<String, dynamic> value) {
    final Uri $url =
        Uri.parse('https://localhost:4000/test/map_query_param_with_comma');
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
