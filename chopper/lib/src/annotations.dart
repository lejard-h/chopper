import 'package:meta/meta.dart';
import 'request.dart';
import 'response.dart';

@immutable

/// Define an APi
/// [baseUrl] determine the prefix of every request in this api
/// [name] generate class name
class ChopperApi {
  final String baseUrl;

  const ChopperApi({
    this.baseUrl: "/",
  });
}

@immutable

/// Define path parameter of an url
///
///     @Get(path: '/{id}')
///     Future<Response> fetch(@Path('id') String resourceId);
class Path {
  final String name;
  const Path([this.name]);
}

@immutable

/// Define query parameters of a request
///
///     @Get(path: '/something')
///     Future<Response> fetch(@Query('id') String resourceId);
///
///     fetch('42');
///     // will request following path: /something?id=42
class Query {
  final String name;
  const Query([this.name]);
}

@immutable

/// Declare Body of [POST], [PUT], [PATCH] request
///
///     @Post()
///     Future<Response> post(@Body() Map<String, dynamic> body);
class Body {
  const Body();
}

@immutable

/// Override header using method parameter
///
///     @Get()
///     Future<Response> fetch(@Header('foo') String headerFoo);
class Header {
  final String name;
  const Header([this.name]);
}

@immutable
class Method {
  final String method;
  final String path;
  final Map<String, String> headers;

  const Method(this.method, {this.path: "/", this.headers: const {}});
}

@immutable

/// Define a method as an Http GET request
class Get extends Method {
  const Get({String path: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Get, path: path, headers: headers);
}

@immutable

/// Define a method as an Http POST request
/// use [Body] annotation to determine data to send
class Post extends Method {
  const Post({String path: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Post, path: path, headers: headers);
}

@immutable

/// Define a method as an Http DELETE request
class Delete extends Method {
  const Delete({String path: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Delete, path: path, headers: headers);
}

@immutable

/// Define a method as an Http PUT request
/// use [Body] annotation to determine data to send
class Put extends Method {
  const Put({String path: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Put, path: path, headers: headers);
}

@immutable

/// Define a method as an Http PATCH request
/// use [Body] annotation to determine data to send
class Patch extends Method {
  const Patch({String path: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Patch, path: path, headers: headers);
}

typedef Request ConvertRequest(Request request);
typedef Response ConvertResponse<T>(Response response);

@immutable
class FactoryConverter {
  final ConvertRequest request;
  final ConvertResponse response;

  const FactoryConverter({
    this.request,
    this.response,
  });
}

/// Define fields
///   witll be convert to { 'key': value }
///
///     @Post(path: '/')
///     Future<Response> create(@Field('id') String name);
@immutable
class Field {
  final String name;
  const Field([this.name]);
}

/// define a multipart request
///
///     @Post(path: '/')
///     @Multipart()
///     Future<Response> create(@Part('id') String name);
@immutable
class Multipart {
  const Multipart();
}

/// Use to define part of [Multipart] request
@immutable
class Part {
  final String name;
  const Part([this.name]);
}

/// Use to define a file filed for [Multipart] request
///     @Post(path: 'file')
///     @multipart
///     Future<Response> postFile(@FileField('file') List<int> bytes);
@immutable
class FileField {
  final String name;

  const FileField([this.name]);
}

const multipart = Multipart();
const body = Body();
//const parts = Parts();
