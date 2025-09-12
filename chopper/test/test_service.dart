import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;

import 'fixtures/example_enum.dart';

part 'test_service.chopper.dart';

@ChopperApi(baseUrl: '/test')
abstract class HttpTestService extends ChopperService {
  static HttpTestService create([ChopperClient? client]) =>
      _$HttpTestService(client);

  @GET(path: 'get/{id}')
  Future<Response<String>> getTest(
    @Path() String id, {
    @Header('test') required String dynamicHeader,
  });

  @HEAD(path: 'head')
  Future<Response> headTest();

  @OPTIONS(path: 'options')
  Future<Response> optionsTest();

  @GET(path: 'get')
  Future<Response<Stream<List<int>>>> getStreamTest();

  @GET(path: '')
  Future<Response> getAll();

  @GET(path: '/')
  Future<Response> getAllWithTrailingSlash();

  @GET(path: 'query')
  Future<Response> getQueryTest({
    @Query('name') String name = '',
    @Query('int') int? number,
    @Query('default_value') int? def = 42,
  });

  @GET(path: 'query_map')
  Future<Response> getQueryMapTest(@QueryMap() Map<String, dynamic> query);

  @GET(path: 'query_map')
  Future<Response> getQueryMapTest2(
    @QueryMap() Map<String, dynamic> query, {
    @Query('test') bool? test,
  });

  @GET(path: 'query_map')
  Future<Response> getQueryMapTest3({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic> filters = const {},
  });

  @GET(path: 'query_map')
  Future<Response> getQueryMapTest4({
    @Query('name') String name = '',
    @Query('number') int? number,
    @QueryMap() Map<String, dynamic>? filters,
  });

  @GET(path: 'query_map')
  Future<Response> getQueryMapTest5({
    @QueryMap() Map<String, dynamic>? filters,
  });

  @GET(path: 'get_body')
  Future<Response> getBody(@Body() dynamic body);

  @POST(path: 'post')
  Future<Response> postTest(@Body() String data);

  @POST(path: 'post')
  Future<Response> postStreamTest(@Body() Stream<List<int>> byteStream);

  @PUT(path: 'put/{id}')
  Future<Response> putTest(@Path('id') String test, @Body() String data);

  @DELETE(path: 'delete/{id}', headers: {'foo': 'bar'})
  Future<Response> deleteTest(@Path() String id);

  @PATCH(path: 'patch/{id}')
  Future<Response> patchTest(@Path() String id, @Body() String data);

  @POST(path: 'map')
  Future<Response> mapTest(@Body() Map<String, String> map);

  @FactoryConverter(request: convertForm)
  @POST(path: 'form/body')
  Future<Response> postForm(@Body() Map<String, String> fields);

  @POST(path: 'form/body', headers: {contentTypeKey: formEncodedHeaders})
  Future<Response> postFormUsingHeaders(@Body() Map<String, String> fields);

  @FactoryConverter(request: convertForm)
  @POST(path: 'form/body/fields')
  Future<Response> postFormFields(@Field() String foo, @Field() int bar);

  @POST(path: 'map/json')
  @FactoryConverter(
    request: customConvertRequest,
    response: customConvertResponse,
  )
  Future<Response> forceJsonTest(@Body() Map map);

  @POST(path: 'multi')
  @multipart
  Future<Response> postResources(@Part('1') Map a, @Part('2') Map b);

  @POST(path: 'file')
  @multipart
  Future<Response> postFile(@PartFile('file') List<int> bytes);

  @POST(path: 'image')
  @multipart
  Future<Response> postImage(@PartFile('image') List<int> imageData);

  @POST(path: 'file')
  @multipart
  Future<Response> postMultipartFile(
    @PartFile() MultipartFile file, {
    @Part() String? id,
  });

  @POST(path: 'files')
  @multipart
  Future<Response> postListFiles(@PartFile() List<MultipartFile> files);

  @POST(path: 'multipart_list')
  @multipart
  Future<Response> postMultipartList({
    @Part('ints') required List<int> ints,
    @Part('doubles') required List<double> doubles,
    @Part('nums') required List<num> nums,
    @Part('strings') required List<String> strings,
  });

  @GET(path: 'https://test.com')
  Future<Response> fullUrl();

  @GET(path: '/list/string')
  Future<Response<List<String>>> listString();

  @POST(path: 'no-body')
  Future<Response> noBody();

  @GET(path: '/query_param_include_null_query_vars', includeNullQueryVars: true)
  Future<Response<String>> getUsingQueryParamIncludeNullQueryVars({
    @Query('foo') String? foo,
    @Query('bar') String? bar,
    @Query('baz') String? baz,
  });

  @GET(path: '/list_query_param')
  Future<Response<String>> getUsingListQueryParam(
    @Query('value') List<String> value,
  );

  @GET(path: '/list_query_param_with_brackets_legacy', useBrackets: true)
  Future<Response<String>> getUsingListQueryParamWithBracketsLegacy(
    @Query('value') List<String> value,
  );

  @GET(path: '/list_query_param_with_brackets', listFormat: ListFormat.brackets)
  Future<Response<String>> getUsingListQueryParamWithBrackets(
    @Query('value') List<String> value,
  );

  @GET(path: '/list_query_param_with_indices', listFormat: ListFormat.indices)
  Future<Response<String>> getUsingListQueryParamWithIndices(
    @Query('value') List<String> value,
  );

  @GET(path: '/list_query_param_with_repeat', listFormat: ListFormat.repeat)
  Future<Response<String>> getUsingListQueryParamWithRepeat(
    @Query('value') List<String> value,
  );

  @GET(path: '/list_query_param_with_comma', listFormat: ListFormat.comma)
  Future<Response<String>> getUsingListQueryParamWithComma(
    @Query('value') List<String> value,
  );

  @GET(path: '/map_query_param')
  Future<Response<String>> getUsingMapQueryParam(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(
    path: '/map_query_param_include_null_query_vars',
    includeNullQueryVars: true,
  )
  Future<Response<String>> getUsingMapQueryParamIncludeNullQueryVars(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(path: '/map_query_param_with_brackets_legacy', useBrackets: true)
  Future<Response<String>> getUsingMapQueryParamWithBracketsLegacy(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(path: '/map_query_param_with_brackets', listFormat: ListFormat.brackets)
  Future<Response<String>> getUsingMapQueryParamWithBrackets(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(path: '/map_query_param_with_indices', listFormat: ListFormat.indices)
  Future<Response<String>> getUsingMapQueryParamWithIndices(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(path: '/map_query_param_with_repeat', listFormat: ListFormat.repeat)
  Future<Response<String>> getUsingMapQueryParamWithRepeat(
    @Query('value') Map<String, dynamic> value,
  );

  @GET(path: '/map_query_param_with_comma', listFormat: ListFormat.comma)
  Future<Response<String>> getUsingMapQueryParamWithComma(
    @Query('value') Map<String, dynamic> value,
  );

  /// Default [DateFormat]
  @GET(path: '/date_time')
  Future<Response<String>> getDateTime(@Query('value') DateTime value);

  /// [DateFormat.iso8601]
  @GET(path: '/date_time_format_iso8601', dateFormat: DateFormat.iso8601)
  Future<Response<String>> getDateTimeFormatIso8601(
    @Query('value') DateTime value,
  );

  /// [DateFormat.utcIso8601]
  @GET(path: '/date_time_format_utcIso8601', dateFormat: DateFormat.utcIso8601)
  Future<Response<String>> getDateTimeFormatUtcIso8601(
    @Query('value') DateTime value,
  );

  /// [DateFormat.localIso8601]
  @GET(
    path: '/date_time_format_localIso8601',
    dateFormat: DateFormat.localIso8601,
  )
  Future<Response<String>> getDateTimeFormatLocalIso8601(
    @Query('value') DateTime value,
  );

  /// [DateFormat.seconds]
  @GET(path: '/date_time_format_seconds', dateFormat: DateFormat.seconds)
  Future<Response<String>> getDateTimeFormatSeconds(
    @Query('value') DateTime value,
  );

  /// [DateFormat.unix]
  @GET(path: '/date_time_format_unix', dateFormat: DateFormat.unix)
  Future<Response<String>> getDateTimeFormatUnix(
    @Query('value') DateTime value,
  );

  /// [DateFormat.milliseconds]
  @GET(
    path: '/date_time_format_milliseconds',
    dateFormat: DateFormat.milliseconds,
  )
  Future<Response<String>> getDateTimeFormatMilliseconds(
    @Query('value') DateTime value,
  );

  /// [DateFormat.microseconds]
  @GET(
    path: '/date_time_format_microseconds',
    dateFormat: DateFormat.microseconds,
  )
  Future<Response<String>> getDateTimeFormatMicroseconds(
    @Query('value') DateTime value,
  );

  /// [DateFormat.rfc2822]
  @GET(path: '/date_time_format_rfc2822', dateFormat: DateFormat.rfc2822)
  Future<Response<String>> getDateTimeFormatRfc2822(
    @Query('value') DateTime value,
  );

  /// [DateFormat.date]
  @GET(path: '/date_time_format_date', dateFormat: DateFormat.date)
  Future<Response<String>> getDateTimeFormatDate(
    @Query('value') DateTime value,
  );

  /// [DateFormat.time]
  @GET(path: '/date_time_format_time', dateFormat: DateFormat.time)
  Future<Response<String>> getDateTimeFormatTime(
    @Query('value') DateTime value,
  );

  /// [DateFormat.string]
  @GET(path: '/date_time_format_string', dateFormat: DateFormat.string)
  Future<Response<String>> getDateTimeFormatString(
    @Query('value') DateTime value,
  );

  @GET(path: 'headers')
  Future<Response<String>> getHeaders({
    @Header('x-string') required String stringHeader,
    @Header('x-boolean') bool? boolHeader,
    @Header('x-int') int? intHeader,
    @Header('x-double') double? doubleHeader,
    @Header('x-enum') ExampleEnum? enumHeader,
  });

  @POST(path: 'publish')
  @FactoryConverter(request: FormUrlEncodedConverter.requestFactory)
  Future<Response<void>> publish(
    @Field('review_id') final String reviewId,
    @Field() final List<int> negatives,
    @Field() final List<int> positives, [
    @Field() final String? signature,
  ]);

  @GET(path: 'get_timeout', timeout: Duration(seconds: 42))
  Future<Response<String>> getTimeoutTest();

  @GET(path: 'get_timeout_zero', timeout: Duration(seconds: 0))
  Future<Response<String>> getTimeoutTestZero();

  @GET(path: 'get_timeout_neg', timeout: Duration(seconds: -1))
  Future<Response<String>> getTimeoutTestNeg();

  @GET(path: 'get_timeout_with_query_header', timeout: Duration(seconds: 30))
  Future<Response<String>> getTimeoutTestQueryHeader({
    @Header('x-test') String? testHeader,
    @Query() String? name,
  });

  @GET(path: 'get_abort_trigger')
  Future<Response<String>> getWithAbortTrigger({
    @AbortTrigger() Future<void>? abortTrigger,
  });

  @GET(path: 'get_abort_trigger2')
  Future<Response<String>> getWithAbortTrigger2({
    @AbortTrigger() Future<void>? foo,
  });

  @GET(path: 'get_abort_trigger_with_query_header')
  Future<Response<String>> getWithAbortTriggerQueryHeader({
    @Header('x-test') String? testHeader,
    @Query() String? name,
    @AbortTrigger() Future<void>? abortTrigger,
  });
}

Request customConvertRequest(Request req) {
  final r = const JsonConverter().convertRequest(req);

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
