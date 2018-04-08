import 'package:meta/meta.dart';
import 'request.dart';

@immutable
class ChopperApi {
  final String baseUrl;
  final String name;
  const ChopperApi(this.name, {this.baseUrl: "/"});
}

@immutable
class Path {
  final String name;
  const Path({this.name});
}

@immutable
class Query {
  final String name;
  const Query({this.name});
}

@immutable
class Body {
  const Body();
}

@immutable
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
class Get extends Method {
  const Get({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Get, url: url, headers: headers);
}

@immutable
class Post extends Method {
  const Post({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Post, url: url, headers: headers);
}

@immutable
class Delete extends Method {
  const Delete({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Delete, url: url, headers: headers);
}

@immutable
class Put extends Method {
  const Put({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Put, url: url, headers: headers);
}

@immutable
class Patch extends Method {
  const Patch({String url: "/", Map<String, String> headers: const {}})
      : super(HttpMethod.Patch, url: url, headers: headers);
}

/* @immutable
class FormUrlEncoded {
  const FormUrlEncoded();
}

@immutable
class Field {
  final String name;
  const Field({this.name});
} */
