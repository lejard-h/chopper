import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';

part 'test_service_base_url.chopper.dart';

@ChopperApi(baseUrl: 'https://localhost:4000/test')
abstract class HttpTestServiceBaseUrl extends ChopperService {
  static HttpTestServiceBaseUrl create([ChopperClient? client]) =>
      _$HttpTestServiceBaseUrl(client);

  @Get(path: '')
  Future<Response> getAll();

  @Get(path: '/')
  Future<Response> getAllWithTrailingSlash();

  @Get(path: '/list/string')
  Future<Response<List<String>>> listString();

  @Get(path: '/query_param_include_null_query_vars', includeNullQueryVars: true)
  Future<Response<String>> getUsingQueryParamIncludeNullQueryVars({
    @Query('foo') String? foo,
    @Query('bar') String? bar,
    @Query('baz') String? baz,
  });

  @Get(path: '/list_query_param')
  Future<Response<String>> getUsingListQueryParam(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_brackets', useBrackets: true)
  Future<Response<String>> getUsingListQueryParamWithBrackets(
    @Query('value') List<String> value,
  );

  @Get(path: '/map_query_param')
  Future<Response<String>> getUsingMapQueryParam(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(
    path: '/map_query_param_include_null_query_vars',
    includeNullQueryVars: true,
  )
  Future<Response<String>> getUsingMapQueryParamIncludeNullQueryVars(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_brackets', useBrackets: true)
  Future<Response<String>> getUsingMapQueryParamWithBrackets(
    @Query('value') Map<String, dynamic> value,
  );
}

Request customConvertRequest(Request req) {
  final r = JsonConverter().convertRequest(req);

  return applyHeader(r, 'customConverter', 'true');
}

Response<T> customConvertResponse<T>(Response res) =>
    res.copyWith(body: json.decode(res.body));

Request convertForm(Request req) {
  req = applyHeader(req, contentTypeKey, formEncodedHeaders);

  if (req.body is Map) {
    final body = <String, String>{};

    req.body.forEach((key, val) {
      if (val != null) {
        body[key.toString()] = val.toString();
      }
    });

    req = req.copyWith(body: body);
  }

  return req;
}
