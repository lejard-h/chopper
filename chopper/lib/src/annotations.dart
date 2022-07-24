import 'dart:async';

import 'package:meta/meta.dart';

import 'constants.dart';
import 'request.dart';
import 'response.dart';

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
@immutable
class ChopperApi {
  /// A part of a URL that every request defined inside a class annotated with [ChopperApi] will be prefixed with.
  final String baseUrl;

  const ChopperApi({
    this.baseUrl = '',
  });
}

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
@immutable
class Path {
  /// Name is used to bind a method parameter to
  /// a URL path parameter.
  /// ```dart
  /// @Get(path: '/{param}')
  /// Future<Response> fetch(@Path('param') String hello);
  /// ```
  final String? name;

  const Path([this.name]);
}

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
@immutable
class Query {
  /// Name is used to bind a method parameter to
  /// the query parameter.
  /// ```dart
  /// @Get(path: '/something')
  /// Future<Response> fetch({@Query('id') String mySuperId});
  /// ```
  final String? name;

  const Query([this.name]);
}

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
@immutable
class QueryMap {
  const QueryMap();
}

/// Declares the Body of [Post], [Put], and [Patch] requests
///
/// ```dart
/// @Post()
/// Future<Response> post(@Body() Map<String, dynamic> body);
/// ```
///
/// The body can be of any type, but chopper does not automatically convert it to JSON.
/// See [Converter] to apply conversion to the body.
@immutable
class Body {
  const Body();
}

/// Passes a value to the header of the request.
///
/// Use the name of the method parameter or the name specified in the annotation.
///
/// ```dart
/// @Get()
/// Future<Response> fetch(@Header() String foo);
/// ```
@immutable
class Header {
  /// Name is used to bind a method parameter to
  /// a header name.
  /// ```dart
  /// @Get()
  /// Future<Response> fetch(@Header('foo') String headerFoo);
  /// ```
  final String? name;

  const Header([this.name]);
}

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
@immutable
class Method {
  /// HTTP method for the request
  final String method;

  /// Path to the request that will be concatenated with the [ChopperApi.baseUrl].
  final String path;

  /// Headers [Map] that should be apply to the request
  final Map<String, String> headers;

  /// Mark the body as optional to suppress warnings during code generation
  final bool optionalBody;

  const Method(
    this.method, {
    this.optionalBody = false,
    this.path = '',
    this.headers = const {},
  });
}

/// Defines a method as an HTTP GET request.
@immutable
class Get extends Method {
  const Get({
    super.optionalBody = true,
    super.path,
    super.headers,
  }) : super(HttpMethod.Get);
}

/// Defines a method as an HTTP POST request.
///
/// Use the [Body] annotation to pass data to send.
@immutable
class Post extends Method {
  const Post({
    super.optionalBody,
    super.path,
    super.headers,
  }) : super(HttpMethod.Post);
}

/// Defines a method as an HTTP DELETE request.
@immutable
class Delete extends Method {
  const Delete({
    super.optionalBody = true,
    super.path,
    super.headers,
  }) : super(HttpMethod.Delete);
}

/// Defines a method as an HTTP PUT request.
///
/// Use the [Body] annotation to pass data to send.
@immutable
class Put extends Method {
  const Put({
    super.optionalBody,
    super.path,
    super.headers,
  }) : super(HttpMethod.Put);
}

/// Defines a method as an HTTP PATCH request.
/// Use the [Body] annotation to pass data to send.
@immutable
class Patch extends Method {
  const Patch({
    super.optionalBody,
    super.path,
    super.headers,
  }) : super(HttpMethod.Patch);
}

/// Defines a method as an HTTP HEAD request.
@immutable
class Head extends Method {
  const Head({
    super.optionalBody = true,
    super.path,
    super.headers,
  }) : super(HttpMethod.Head);
}

@immutable
class Options extends Method {
  const Options({
    super.optionalBody = true,
    super.path,
    super.headers,
  }) : super(HttpMethod.Options);
}

/// A function that should convert the body of a [Request] to the HTTP representation.
typedef ConvertRequest = FutureOr<Request> Function(Request request);

/// A function that should convert the body of a [Response] from the HTTP
/// representation to a Dart object.
typedef ConvertResponse<T> = FutureOr<Response> Function(Response response);

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
@immutable
class FactoryConverter {
  final ConvertRequest? request;
  final ConvertResponse? response;

  const FactoryConverter({
    this.request,
    this.response,
  });
}

/// Defines a field for a `x-www-form-urlencoded` request.
/// Automatically binds to the name of the method parameter.
///
/// ```dart
/// @Post(path: '/')
/// Future<Response> create(@Field() String name);
/// ```
/// Will be converted to `{ 'name': value }`.
@immutable
class Field {
  /// Name can be use to specify the name of the field
  /// ```dart
  /// @Post(path: '/')
  /// Future<Response> create(@Field('id') String myId);
  /// ```
  final String? name;

  const Field([this.name]);
}

/// Provides field parameters of a request as [Map<String, dynamic>].
///
/// ```dart
/// @Post(path: '/something')
/// Future<Response> fetch(@FieldMap List<Map<String, dynamic>> query);
/// ```
///
@immutable
class FieldMap {
  const FieldMap();
}

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
@immutable
class Multipart {
  const Multipart();
}

/// Use [Part] to define a part of a [Multipart] request.
///
/// All values will be converted to [String] using their [toString] method.
///
/// Also accepts `MultipartFile` (from package:http).
@immutable
class Part {
  final String? name;

  const Part([this.name]);
}

/// Provides part parameters of a request as [PartValue].
///
/// ```dart
/// @Post(path: '/something')
/// @Multipart
/// Future<Response> fetch(@PartMap() List<PartValue> query);
/// ```
///
@immutable
class PartMap {
  const PartMap();
}

/// Use [PartFile] to define a file field for a [Multipart] request.
///
/// ```
/// @Post(path: 'file')
/// @multipart
/// Future<Response> postFile(@PartFile('file') List<int> bytes);
/// ```
///
/// Supports the following values:
///   - `List<int>`
///   - [String] (path of your file)
///   - `MultipartFile` (from package:http)
@immutable
class PartFile {
  final String? name;

  const PartFile([this.name]);
}

/// Provides partFile parameters of a request as [PartValueFile].
///
/// ```dart
/// @Post(path: '/something')
/// @Multipart
/// Future<Response> fetch(@PartFileMap() List<PartValueFile> query);
/// ```
///
@immutable
class PartFileMap {
  const PartFileMap();
}

const multipart = Multipart();
const body = Body();
