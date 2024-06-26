import 'dart:async';

import 'package:chopper/src/constants.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';
import 'package:qs_dart/qs_dart.dart' show ListFormat;

/// {@template ChopperApi}
/// Defines a Chopper API.
///
/// Must be used on an abstract class that extends the [ChopperService] class.
/// To simplify instantiation, it's recommended to define a static `create` method.
///
/// ```dart
/// @ChopperApi(baseUrl: '/todos')
/// abstract class TodosListService extends ChopperService {
///   static TodosListService create([ChopperClient client]) =>
///       _$TodosListService(client);
/// }
/// ```
///
/// See [Method] to define an HTTP request
/// {@endtemplate}
@immutable
@Target({TargetKind.classType})
final class ChopperApi {
  /// A part of a URL that every request defined inside a class annotated with [ChopperApi] will be prefixed with.
  ///
  /// The `baseUrl` can be a top level constant string variable.
  final String baseUrl;

  /// {@macro ChopperApi}
  const ChopperApi({
    this.baseUrl = '',
  });
}

/// {@template Path}
/// Provides a parameter in the url.
///
/// Declared as follows inside the path String:
/// ```dart
/// @Get(path: '/{param}')
/// ```
///
/// Available inside method declaration:
/// ```dart
/// @Get(path: '/{param}')
/// Future<Response> fetch(@Path() String param);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Path {
  /// Name is used to bind a method parameter to
  /// a URL path parameter.
  /// ```dart
  /// @Get(path: '/{param}')
  /// Future<Response> fetch(@Path('param') String hello);
  /// ```
  final String? name;

  /// {@macro Path}
  const Path([this.name]);
}

/// {@template Query}
/// Provides the query parameters of a request.
///
/// [Query] is used to add query parameters after the request url.
/// Example: /something?id=42
/// ```dart
/// @Get(path: '/something')
/// Future<Response> fetch({@Query() String id});
/// ```
///
/// See [QueryMap] to pass an [Map<String, dynamic>] as value
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Query {
  /// Name is used to bind a method parameter to
  /// the query parameter.
  /// ```dart
  /// @Get(path: '/something')
  /// Future<Response> fetch({@Query('id') String mySuperId});
  /// ```
  final String? name;

  /// {@macro Query}
  const Query([this.name]);
}

/// {@template QueryMap}
/// Provides query parameters of a request as [Map<String, dynamic>].
///
/// ```dart
/// @Get(path: '/something')
/// Future<Response> fetch(@QueryMap() Map<String, dynamic> query);
/// ```
///
/// Supports passing list value as follows:
/// ```dart
/// fetch({'foo':'bar','list':[1,2]});
/// // something?foo=bar&list=1&list=2
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class QueryMap {
  /// {@macro QueryMap}
  const QueryMap();
}

/// {@template Body}
/// Declares the Body of [Post], [Put], and [Patch] requests
///
/// ```dart
/// @Post()
/// Future<Response> post(@Body() Map<String, dynamic> body);
/// ```
///
/// The body can be of any type, but chopper does not automatically convert it to JSON.
/// See [Converter] to apply conversion to the body.
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Body {
  /// {@macro Body}
  const Body();
}

/// {@template Header}
/// Passes a value to the header of the request.
///
/// Use the name of the method parameter or the name specified in the annotation.
///
/// ```dart
/// @Get()
/// Future<Response> fetch(@Header() String foo);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Header {
  /// Name is used to bind a method parameter to
  /// a header name.
  /// ```dart
  /// @Get()
  /// Future<Response> fetch(@Header('foo') String headerFoo);
  /// ```
  final String? name;

  /// {@macro Header}
  const Header([this.name]);
}

/// {@template Method}
/// Defines an HTTP method.
///
/// Must be used inside a [ChopperApi] definition.
///
/// Recommended:
/// [Get], [Post], [Put], [Delete], [Patch], or [Head] should be used instead.
///
/// ```dart
/// @Get(headers: const {'foo': 'bar' })
/// Future<Response> myGetRequest();
/// ```
///
/// The annotated method must always return a [Future<Response>].
///
/// The [Response] type also supports typed parameters like `Future<Response<MyObject>>`.
/// However, chopper will not automatically convert the body response to your type.
/// A [Converter] needs to be specified for conversion.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
sealed class Method {
  /// HTTP method for the request
  final String method;

  /// Path to the request that will be concatenated with the [ChopperApi.baseUrl].
  final String path;

  /// Headers [Map] that should be apply to the request
  final Map<String, String> headers;

  /// Mark the body as optional to suppress warnings during code generation
  final bool optionalBody;

  /// List format to use when encoding lists
  ///
  /// - [ListFormat.repeat] `hxxp://path/to/script?foo=123&foo=456&foo=789` (default)
  /// - [ListFormat.brackets] `hxxp://path/to/script?foo[]=123&foo[]=456&foo[]=789`
  /// - [ListFormat.indices] `hxxp://path/to/script?foo[0]=123&foo[1]=456&foo[2]=789`
  /// - [ListFormat.comma] `hxxp://path/to/script?foo=123,456,789`
  final ListFormat? listFormat;

  /// Use brackets `[ ]` to when encoding
  ///
  /// - lists
  /// `hxxp://path/to/script?foo[]=123&foo[]=456&foo[]=789`
  ///
  /// - maps
  /// `hxxp://path/to/script?user[name]=john&user[surname]=doe&user[age]=21`
  @Deprecated('Use listFormat instead')
  final bool? useBrackets;

  /// Set to [true] to include query variables with null values. This includes nested maps.
  /// The default is to exclude them.
  ///
  /// NOTE: Empty strings are always included.
  ///
  /// ```dart
  /// @Get(
  ///   path: '/script',
  ///   includeNullQueryVars: true,
  /// )
  /// Future<Response<String>> getData({
  ///   @Query('foo') String? foo,
  ///   @Query('bar') String? bar,
  ///   @Query('baz') String? baz,
  /// });
  ///
  /// final response = await service.getData(
  ///   foo: 'foo_val',
  ///   bar: null, // omitting it would have the same effect
  ///   baz: 'baz_val',
  /// );
  /// ```
  ///
  /// The above code produces hxxp://path/to/script&foo=foo_var&bar=&baz=baz_var
  final bool? includeNullQueryVars;

  /// Set a timeout for the request
  final Duration? timeout;

  /// {@macro Method}
  const Method(
    this.method, {
    this.optionalBody = false,
    this.path = '',
    this.headers = const {},
    this.listFormat,
    @Deprecated('Use listFormat instead') this.useBrackets,
    this.includeNullQueryVars,
    this.timeout,
  });
}

/// {@template Get}
/// Defines a method as an HTTP GET request.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Get extends Method {
  /// {@macro Get}
  const Get({
    super.optionalBody = true,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Get);
}

/// {@template Post}
/// Defines a method as an HTTP POST request.
///
/// Use the [Body] annotation to pass data to send.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Post extends Method {
  /// {@macro Post}
  const Post({
    super.optionalBody,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Post);
}

/// {@template Delete}
/// Defines a method as an HTTP DELETE request.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Delete extends Method {
  /// {@macro Delete}
  const Delete({
    super.optionalBody = true,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Delete);
}

/// {@template Put}
/// Defines a method as an HTTP PUT request.
///
/// Use the [Body] annotation to pass data to send.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Put extends Method {
  /// {@macro Put}
  const Put({
    super.optionalBody,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Put);
}

/// {@template Patch}
/// Defines a method as an HTTP PATCH request.
/// Use the [Body] annotation to pass data to send.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Patch extends Method {
  /// {@macro Patch}
  const Patch({
    super.optionalBody,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Patch);
}

/// {@template Head}
/// Defines a method as an HTTP HEAD request.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Head extends Method {
  /// {@macro Head}
  const Head({
    super.optionalBody = true,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Head);
}

/// {@template Options}
/// Defines a method as an HTTP OPTIONS request.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Options extends Method {
  /// {@macro Options}
  const Options({
    super.optionalBody = true,
    super.path,
    super.headers,
    super.listFormat,
    super.useBrackets,
    super.includeNullQueryVars,
    super.timeout,
  }) : super(HttpMethod.Options);
}

/// A function that should convert the body of a [Request] to the HTTP representation.
typedef ConvertRequest = FutureOr<Request> Function(Request request);

/// A function that should convert the body of a [Response] from the HTTP
/// representation to a Dart object.
typedef ConvertResponse<T> = FutureOr<Response<T>> Function(Response response);

/// {@template FactoryConverter}
/// Defines custom [Converter] methods for a single network API endpoint.
/// See [ConvertRequest], [ConvertResponse].
///
/// ```dart
/// @ChopperApi(baseUrl: '/todos')
/// abstract class TodosListService extends ChopperService {
///   static TodosListService create([ChopperClient client]) =>
///       _$TodosListService(client);
///
///   static FutureOr<Request> customRequestConverter(Request request) {
///     return request.copyWith(
///         body: // Convert request.body the way your API needs it. See [JsonConverter.encodeJson] for an example.
///     );
///   }
///
///   static FutureOr<Response> customResponseConverter(Response response) {
///     return response.copyWith(
///       body: // Convert response.body the way your API needs it. See [JsonConverter.decodeJson] for an example.
///     );
///   }
///
///   @Get(path: "/{id}")
///   @FactoryConverter(
///     request: customRequestConverter,
///     response: customResponseConverter
///   )
///   Future<Response<Todo>> getTodo(@Path("id"));
/// }
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class FactoryConverter {
  final ConvertRequest? request;
  final ConvertResponse? response;

  /// {@macro FactoryConverter}
  const FactoryConverter({
    this.request,
    this.response,
  });
}

/// {@template Field}
/// Defines a field for a `x-www-form-urlencoded` request.
/// Automatically binds to the name of the method parameter.
///
/// ```dart
/// @Post(path: '/')
/// Future<Response> create(@Field() String name);
/// ```
/// Will be converted to `{ 'name': value }`.
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Field {
  /// Name can be use to specify the name of the field
  /// ```dart
  /// @Post(path: '/')
  /// Future<Response> create(@Field('id') String myId);
  /// ```
  final String? name;

  /// {@macro Field}
  const Field([this.name]);
}

/// {@template FieldMap}
/// Provides field parameters of a request as [Map<String, dynamic>].
///
/// ```dart
/// @Post(path: '/something')
/// Future<Response> fetch(@FieldMap Map<String, dynamic> query);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class FieldMap {
  /// {@macro FieldMap}
  const FieldMap();
}

/// {@template Multipart}
/// Defines a multipart request.
///
/// ```dart
/// @Post(path: '/')
/// @Multipart()
/// Future<Response> create(@Part() String name);
/// ```
///
/// Use [Part] annotation to send simple data.
/// Use [PartFile] annotation to send `File` or `List<int>`.
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class Multipart {
  /// {@macro Multipart}
  const Multipart();
}

/// {@template Part}
/// Use [Part] to define a part of a [Multipart] request.
///
/// All values will be converted to [String] using their [toString] method.
///
/// Also accepts `MultipartFile` (from package:http).
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Part {
  final String? name;

  /// {@macro Part}
  const Part([this.name]);
}

/// {@template PartMap}
/// Provides part parameters of a request as [PartValue].
///
/// ```dart
/// @Post(path: '/something')
/// @Multipart
/// Future<Response> fetch(@PartMap() List<PartValue> query);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class PartMap {
  /// {@macro PartMap}
  const PartMap();
}

///   {@template PartFile}
/// Use [PartFile] to define a file field for a [Multipart] request.
///
/// ```dart
/// @Post(path: 'file')
/// @multipart
/// Future<Response> postFile(@PartFile('file') List<int> bytes);
/// ```
///
/// Supports the following values:
///   - `List<int>`
///   - [String] (path of your file)
///   - `MultipartFile` (from package:http)
///   {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class PartFile {
  final String? name;

  ///   {@macro PartFile}
  const PartFile([this.name]);
}

/// {@template PartFileMap}
/// Provides partFile parameters of a request as [PartValueFile].
///
/// ```dart
/// @Post(path: '/something')
/// @Multipart
/// Future<Response> fetch(@PartFileMap() List<PartValueFile> query);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class PartFileMap {
  /// {@macro PartFileMap}
  const PartFileMap();
}

/// {@template FormUrlEncoded}
///
///
/// Denotes that the request body will use form URL encoding. Fields should be declared as parameters
/// and annotated with [Field]/[FieldMap].
///
/// Requests made with this annotation will have application/x-www-form-urlencoded MIME
/// type. Field names and values will be UTF-8 encoded before being URI-encoded in accordance to <a
/// href="https://datatracker.ietf.org/doc/html/rfc3986">RFC-3986</a>.
///
///
/// ```dart
/// @Post(path: '/something')
/// @FormUrlEncoded
/// Future<Response> fetch(@Field("param") String? param);
/// ```
/// {@endtemplate}
@immutable
@Target({TargetKind.method})
final class FormUrlEncoded {
  /// {@macro FormUrlEncoded}
  const FormUrlEncoded();
}

///
/// {@template Tag}
/// Adds the argument instance as a request tag.
///
/// ```dart
/// Future<Response> requestWithTag(
///   @Tag() String t1,
/// );
/// ```
/// get tag via `request.tags`
///
/// {@endtemplate}
@immutable
@Target({TargetKind.parameter})
final class Tag {
  /// {@macro Tag}
  const Tag();
}

/// {@macro ChopperApi}
const chopperApi = ChopperApi();

/// {@macro Multipart}
const multipart = Multipart();

/// {@macro Body}
const body = Body();

/// {@macro Path}
const path = Path();

/// {@macro Query}
const query = Query();

/// {@macro QueryMap}
const queryMap = QueryMap();

/// {@macro Header}
const header = Header();

/// {@macro Get}
const get = Get();

/// {@macro Post}
const post = Post();

/// {@macro Delete}
const delete = Delete();

/// {@macro Put}
const put = Put();

/// {@macro Patch}
const patch = Patch();

/// {@macro Head}
const head = Head();

/// {@macro Options}
const options = Options();

/// {@macro FactoryConverter}
const factoryConverter = FactoryConverter();

/// {@macro Field}
const field = Field();

/// {@macro FieldMap}
const fieldMap = FieldMap();

/// {@macro Part}
const part = Part();

/// {@macro PartMap}
const partMap = PartMap();

/// {@macro PartFile}
const partFile = PartFile();

/// {@macro PartFileMap}
const partFileMap = PartFileMap();

/// {@macro FormUrlEncoded}
const formUrlEncoded = FormUrlEncoded();

/// {@macro Tag}
const tag = Tag();
