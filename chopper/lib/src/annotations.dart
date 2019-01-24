import 'package:meta/meta.dart';
import 'request.dart';

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
///     @Get(url: '/{id}')
///     Future<Response> fetch(@Path('id') String resourceId);
class Path {
  final String name;
  const Path([this.name]);
}

@immutable

/// Define query parameters of a request
///
///     @Get(url: '/something')
///     Future<Response> fetch(@Query('id') String resourceId);
///
///     fetch('42');
///     // will request following url: /something?id=42
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
  final String url;
  final Map<String, String> headers;

  const Method(this.method, {this.url: "/", this.headers: const {}});
}

@immutable

/// Define a method as an Http GET request
class Get extends Method {
  const Get({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Get, url: url, headers: headers);
}

@immutable

/// Define a method as an Http POST request
/// use [Body] annotation to determine data to send
class Post extends Method {
  const Post({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Post, url: url, headers: headers);
}

@immutable

/// Define a method as an Http DELETE request
class Delete extends Method {
  const Delete({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Delete, url: url, headers: headers);
}

@immutable

/// Define a method as an Http PUT request
/// use [Body] annotation to determine data to send
class Put extends Method {
  const Put({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Put, url: url, headers: headers);
}

@immutable

/// Define a method as an Http PATCH request
/// use [Body] annotation to determine data to send
class Patch extends Method {
  const Patch({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Patch, url: url, headers: headers);
}

/// Use to encode a single method
/// with application/json
///     @Get(url: '/')
///     @JsonEncoded()
///     Future<Response> fetch();
@immutable
class JsonEncoded {
  const JsonEncoded();
}

/// Use to encode a single method
/// with application/x-www-form-urlencoded
///
///     @Get(url: '/')
///     @FormUrlEncoded()
///     Future<Response> fetch();
@immutable
class FormUrlEncoded {
  const FormUrlEncoded();
}

/// Define field for [FormUrlEncoded] method
///
///     @Post(url: '/')
///     @FormUrlEncoded()
///     Future<Response> create(@Field('id') String name);
@immutable
class Field {
  final String name;
  const Field([this.name]);
}

/// define a multipart request
///
///     @Post(url: '/')
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
///     @Post(url: 'file')
///     @multipart
///     Future<Response> postFile(@FileField('file') List<int> bytes);
@immutable
class FileField {
  final String name;

  const FileField([this.name]);
}

const multipart = Multipart();
const formUrlEncoded = FormUrlEncoded();
const jsonEncoded = JsonEncoded();
const body = Body();
//const parts = Parts();
