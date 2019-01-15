import 'dart:async';
import "package:meta/meta.dart";
import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';
import 'utils.dart';

@immutable
abstract class ResponseInterceptor {
  FutureOr<Response> onResponse(Response response);
}

@immutable
abstract class RequestInterceptor {
  FutureOr<Request> onRequest(Request request);
}

@immutable
abstract class Converter {
  FutureOr<Request> encode<T>(Request request) async {
    if (request.body != null) {
      return request.replace(body: await encodeEntity<T>(request.body));
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

  Future<Response<T>> decode<T>(Response response) async {
    if (response.body != null) {
      final decoded = await decodeEntity<T>(response.body);
      return response.replaceWithNull<T>(body: decoded);
    }
    return response.replaceWithNull<T>();
  }

  @protected
  Future encodeEntity<T>(T entity);

  @protected
  Future decodeEntity<T>(entity);
}

@immutable
class HeadersInterceptor implements RequestInterceptor {
  final Map<String, String> headers;

  const HeadersInterceptor(this.headers);

  Future<Request> onRequest(Request request) async =>
      applyHeaders(request, headers);
}

typedef FutureOr<Response> ResponseInterceptorFunc<Value>(
    Response<Value> response);
typedef FutureOr<Request> RequestInterceptorFunc(Request request);

/// Interceptor that print a curl request
/// thanks @edwardaux
class CurlInterceptor implements RequestInterceptor {
  Future<Request> onRequest(Request request) async {
    final baseRequest = await request.toHttpRequest();
    final method = baseRequest.method;
    final url = baseRequest.url.toString();
    final headers = baseRequest.headers;
    var curl = '';
    curl += 'curl';
    curl += ' -v';
    curl += ' -X $method';
    headers.forEach((k, v) {
      curl += ' -H \'$k: $v\'';
    });
    // this is fairly naive, but it should cover most cases
    if (baseRequest is http.Request) {
      final body = baseRequest.body;
      if (body != null && body.isNotEmpty) {
        curl += ' -d \'$body\'';
      }
    }
    curl += ' $url';
    print(curl);
    return request;
  }
}