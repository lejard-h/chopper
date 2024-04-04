import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;

part 'test_without_response_service.chopper.dart';

@ChopperApi(baseUrl: '/test')
abstract class HttpTestService extends ChopperService {
  static HttpTestService create([ChopperClient? client]) =>
      _$HttpTestService(client);

  @Get(path: 'get/{id}')
  Future<String> getTest(
    @Path() String id, {
    @Header('test') required String dynamicHeader,
  });

  @Head(path: 'head')
  Future headTest();

  @Options(path: 'options')
  Future optionsTest();

  @Get(path: 'get')
  Future<Stream<List<int>>> getStreamTest();

  @Get(path: '')
  Future getAll();

  @Get(path: '/')
  Future getAllWithTrailingSlash();

  @Get(path: 'query')
  Future getQueryTest({
    @Query('name') String name = '',
    @Query('int') int? number,
    @Query('default_value') int? def = 42,
  });

  @Get(path: 'query_map')
  Future getQueryMapTest(@QueryMap() Map<String, dynamic> query);

  @Get(path: 'query_map')
  Future getQueryMapTest2(
    @QueryMap() Map<String, dynamic> query, {
    @Query('test') bool? test,
  });

  @Get(path: 'query_map')
  Future getQueryMapTest3({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic> filters = const {},
  });

  @Get(path: 'query_map')
  Future getQueryMapTest4({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic>? filters,
  });

  @Get(path: 'query_map')
  Future getQueryMapTest5({
    @QueryMap() Map<String, dynamic>? filters,
  });

  @Get(path: 'get_body')
  Future getBody(@Body() dynamic body);

  @Post(path: 'post')
  Future postTest(@Body() String data);

  @Post(path: 'post')
  Future postStreamTest(@Body() Stream<List<int>> byteStream);

  @Put(path: 'put/{id}')
  Future putTest(@Path('id') String test, @Body() String data);

  @Delete(path: 'delete/{id}', headers: {'foo': 'bar'})
  Future<void> deleteTest(@Path() String id);

  @Patch(path: 'patch/{id}')
  Future patchTest(@Path() String id, @Body() String data);

  @Post(path: 'map')
  Future mapTest(@Body() Map<String, String> map);

  @FactoryConverter(request: convertForm)
  @Post(path: 'form/body')
  Future postForm(@Body() Map<String, String> fields);

  @Post(path: 'form/body', headers: {contentTypeKey: formEncodedHeaders})
  Future postFormUsingHeaders(@Body() Map<String, String> fields);

  @FactoryConverter(request: convertForm)
  @Post(path: 'form/body/fields')
  Future postFormFields(@Field() String foo, @Field() int bar);

  @Post(path: 'map/json')
  @FactoryConverter(
    request: customConvertRequest,
    response: customConvertResponse,
  )
  Future forceJsonTest(@Body() Map map);

  @Post(path: 'multi')
  @multipart
  Future postResources(
    @Part('1') Map a,
    @Part('2') Map b,
  );

  @Post(path: 'file')
  @multipart
  Future postFile(
    @PartFile('file') List<int> bytes,
  );

  @Post(path: 'image')
  @multipart
  Future postImage(
    @PartFile('image') List<int> imageData,
  );

  @Post(path: 'file')
  @multipart
  Future postMultipartFile(
    @PartFile() MultipartFile file, {
    @Part() String? id,
  });

  @Post(path: 'files')
  @multipart
  Future postListFiles(@PartFile() List<MultipartFile> files);

  @Post(path: 'multipart_list')
  @multipart
  Future postMultipartList({
    @Part('ints') required List<int> ints,
    @Part('doubles') required List<double> doubles,
    @Part('nums') required List<num> nums,
    @Part('strings') required List<String> strings,
  });

  @Get(path: 'https://test.com')
  Future fullUrl();

  @Get(path: '/list/string')
  Future<List<String>> listString();

  @Post(path: 'no-body')
  Future noBody();

  @Get(path: '/query_param_include_null_query_vars', includeNullQueryVars: true)
  Future<String> getUsingQueryParamIncludeNullQueryVars({
    @Query('foo') String? foo,
    @Query('bar') String? bar,
    @Query('baz') String? baz,
  });

  @Get(path: '/list_query_param')
  Future<String> getUsingListQueryParam(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_brackets_legacy', useBrackets: true)
  Future<String> getUsingListQueryParamWithBracketsLegacy(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_brackets', listFormat: ListFormat.brackets)
  Future<String> getUsingListQueryParamWithBrackets(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_indices', listFormat: ListFormat.indices)
  Future<String> getUsingListQueryParamWithIndices(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_repeat', listFormat: ListFormat.repeat)
  Future<String> getUsingListQueryParamWithRepeat(
    @Query('value') List<String> value,
  );

  @Get(path: '/list_query_param_with_comma', listFormat: ListFormat.comma)
  Future<String> getUsingListQueryParamWithComma(
    @Query('value') List<String> value,
  );

  @Get(path: '/map_query_param')
  Future<String> getUsingMapQueryParam(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(
    path: '/map_query_param_include_null_query_vars',
    includeNullQueryVars: true,
  )
  Future<String> getUsingMapQueryParamIncludeNullQueryVars(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_brackets_legacy', useBrackets: true)
  Future<String> getUsingMapQueryParamWithBracketsLegacy(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_brackets', listFormat: ListFormat.brackets)
  Future<String> getUsingMapQueryParamWithBrackets(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_indices', listFormat: ListFormat.indices)
  Future<String> getUsingMapQueryParamWithIndices(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_repeat', listFormat: ListFormat.repeat)
  Future<String> getUsingMapQueryParamWithRepeat(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: '/map_query_param_with_comma', listFormat: ListFormat.comma)
  Future<String> getUsingMapQueryParamWithComma(
    @Query('value') Map<String, dynamic> value,
  );

  @Get(path: 'headers')
  Future<String> getHeaders({
    @Header('x-string') required String stringHeader,
    @Header('x-boolean') bool? boolHeader,
    @Header('x-int') int? intHeader,
    @Header('x-double') double? doubleHeader,
    @Header('x-enum') ExampleEnum? enumHeader,
  });
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

enum ExampleEnum {
  foo,
  bar,
  baz;

  @override
  String toString() => name;
}
