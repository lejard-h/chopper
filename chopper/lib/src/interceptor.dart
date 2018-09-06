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

  Future<Request> encode(Request request) async {
    if (request.body != null) {
      return request.replace(body: await encodeEntity(request.body));
    } else if (request.parts.isNotEmpty) {
      final parts = new List(request.parts.length);
      final futures = <Future>[];

      for (int i = 0; i < parts.length; i++) {
        final p = request.parts[i];
        futures.add(encodeEntity(p.value).then((e) {
          parts[i] = PartValue(p.name, e);
        }));
      }

      await Future.wait(futures);
      return request.replace(parts: parts);
    }
    return request;
  }

  Future<Response> decode<T>(Response response) async {
    if (response.body != null) {
      return response.replace(body: await decodeEntity<T>(response.body));
    }
    return response;
  }

  Future encodeEntity(entity);

  Future decodeEntity<T>(entity);
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
