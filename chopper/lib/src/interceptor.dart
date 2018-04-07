import 'dart:async';
import "dart:convert";
import "package:meta/meta.dart";

import 'request.dart';
import 'response.dart';
import 'utils.dart';

@immutable
abstract class ResponseInterceptor {
  Future<Response> onResponse(Response reponse);

  const ResponseInterceptor();
}

@immutable
abstract class RequestInterceptor {
  Future<Request> onRequest(Request request);

  const RequestInterceptor();
}

@immutable
abstract class Converter {
  const Converter();

  Future<Request> encode(Request request);

  Future<Response> decode(Response response, Type responseType);
}

@immutable
class BodyConverterCodec extends Converter {
  final Codec codec;

  const BodyConverterCodec(this.codec) : super();

  Future<Request> encode(Request request) async {
    if (request.body == null) {
      return request;
    }
    return request.replace(body: codec.encode(request.body));
  }

  Future<Response> decode(Response response, Type responseType) async {
    if (response.base.body == null) {
      return response;
    }
    return response.replace(body: codec.decode(response.base.body));
  }
}

@immutable
class JsonConverter extends BodyConverterCodec {
  const JsonConverter() : super(json);
}

@immutable
class Headers implements RequestInterceptor {
  final Map<String, String> headers;

  const Headers(this.headers) : super();

  Future<Request> onRequest(Request request) async =>
      applyHeaders(request, headers);
}

typedef Future<Response> ResponseInterceptorFunc(Response response);
typedef Future<Request> RequestInterceptorFunc(Request request);
