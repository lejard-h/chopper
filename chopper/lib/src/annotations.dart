import 'package:meta/meta.dart';
import 'request.dart';
import 'response.dart';
import 'constants.dart';

/// Define a Chopper API
///
/// Must be use on an abstract class that extend the [ChopperService] class.
/// To simplify instantiation, it's recommanded to define a statis `create` method.
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
  /// Url that will prefix every request define inside that API.
  final String baseUrl;

  const ChopperApi({
    this.baseUrl = '',
  });
}

/// Provide parameter inside url.
///
/// Determine as follow inside the path String
/// ```dart
/// @Get(path: '/{param}')
/// ```
///
/// And available inside method declaration
/// ```dart
/// @Get(path: '/{param}')
/// Future<Response> fetch(@Path() String param);
/// ```
@immutable
class Path {
  /// Name is used to bind a method parameter to
  /// the url parameter.
  /// ```dart
  /// @Get(path: '/{param}')
  /// Future<Response> fetch(@Path('param') String hello);
  /// ```
  final String name;

  const Path([this.name]);
}

/// Provide query parameters of a request.
///
/// [Query] is use to add query parameters after the request url
/// Example /something?id=42
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
  final String name;

  const Query([this.name]);
}

/// Provide query parameters of a request as [Map<String, dynamic>]
///
/// ```dart
/// @Get(path: '/something')
/// Future<Response> fetch(@QueryMap() Map<String, dynamic> query);
/// ```
///
/// Support list passing value as follow
/// ```dart
/// fetch({'foo':'bar','list':[1,2]});
/// // something?foo=bar&list=1&list=2
/// ```
@immutable
class QueryMap {
  const QueryMap();
}

/// Declare Body of [Post], [Put], [Patch] request
///
/// ```dart
/// @Post()
/// Future<Response> post(@Body() Map<String, dynamic> body);
/// ```
///
/// The body can be of any type, however chopper does not automatically convert it to JSON for example.
/// See [Converter] to apply conversion to the body.
@immutable
class Body {
  const Body();
}

/// Pass value to header of the request
/// Use the name of the method parameter or the name specified in the annotation.
///
/// ```dart
/// @Get()
/// Future<Response> fetch(@Header() String foo);
/// ```
@immutable
class Header {
  /// Name is used to bind a method parameter to
  /// the header name you want.
  /// ```dart
  /// @Get()
  /// Future<Response> fetch(@Header('foo') String headerFoo);
  /// ```
  final String name;

  const Header([this.name]);
}

/// Define an HTTP method
/// Must be use inside a [ChopperApi] definition.
///
/// Recommended:
/// [Get], [Post], [Put], [Delete], [Patch], [Head] should be use instead.
///
/// ```dart
/// @Get(headers: const {'foo': 'bar' })
/// Future<Response> myGetRequest();
/// ```
///
/// The annotated method must always return a [Future<Response>].
///
/// The [Response] type also support typed parameters like `Future<Response<MyObject>>`.
/// However chopper will not automatically convert the body response to you type,
/// a [Converter] need to be specified.
@immutable
class Method {
  /// HTTP method for the request
  final String method;

  /// Path to the request that will be concatenated with the [ChopperApi.baseUrl].
  final String path;

  /// Headers [Map] that should be apply to the request
  final Map<String, String> headers;

  const Method(this.method, {this.path = '', this.headers = const {}});
}

/// Define a method as an Http GET request
@immutable
class Get extends Method {
  const Get({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Get, path: path, headers: headers);
}

/// Define a method as an Http POST request
/// use [Body] annotation to determine data to send
@immutable
class Post extends Method {
  const Post({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Post, path: path, headers: headers);
}

/// Define a method as an Http DELETE request
@immutable
class Delete extends Method {
  const Delete({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Delete, path: path, headers: headers);
}

/// Define a method as an Http PUT request
/// use [Body] annotation to determine data to send
@immutable
class Put extends Method {
  const Put({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Put, path: path, headers: headers);
}

/// Define a method as an Http PATCH request
/// use [Body] annotation to determine data to send
@immutable
class Patch extends Method {
  const Patch({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Patch, path: path, headers: headers);
}

/// Define a method as an Http HEAD request
@immutable
class Head extends Method {
  const Head({String path = '', Map<String, String> headers = const {}})
      : super(HttpMethod.Head, path: path, headers: headers);
}

typedef ConvertRequest = Request Function(Request request);
typedef ConvertResponse<T> = Response Function(Response response);

@immutable
class FactoryConverter {
  final ConvertRequest request;
  final ConvertResponse response;

  const FactoryConverter({
    this.request,
    this.response,
  });
}

/// Define fields for a `x-www-form-urlencoded` request.
/// Automatically bind to the name of the method parameter.
///
/// ```dart
/// @Post(path: '/')
/// Future<Response> create(@Field() String name);
/// ```
/// Will be convert to `{ 'name': value }`
@immutable
class Field {
  /// Name can be use to specify the name of the field
  /// ```dart
  /// @Post(path: '/')
  /// Future<Response> create(@Field('id') String myId);
  /// ```
  final String name;

  const Field([this.name]);
}

/// Define a multipart request
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

/// Use to define part of [Multipart] request
/// All values will are converted to [String] using [toString] method
///
/// Also accept `MultipartFile` (from package:http)
@immutable
class Part {
  final String name;
  const Part([this.name]);
}

/// Use to define a file field for [Multipart] request
///
/// ```
/// @Post(path: 'file')
/// @multipart
/// Future<Response> postFile(@PartFile('file') List<int> bytes);
/// ```
///
/// Support the following values
///   - `List<int>`
///   - [String] (path of your file)
///   - `MultipartFile` (from package:http)
@immutable
class PartFile {
  final String name;

  const PartFile([this.name]);
}

/// Use to define a file field for [Multipart] request
///
/// ```dart
/// @Post(path: 'file')
/// @multipart
/// Future<Response> postFile(@FileField('file') List<int> bytes);
/// ```
///
/// Support the following values
///   - `List<int>`
///   - [String] (path of your file)
///   - `MultipartFile` (from package:http)
@immutable
@Deprecated('use PartFile')
class FileField extends PartFile {
  const FileField([String name]) : super(name);
}

const multipart = Multipart();
const body = Body();
