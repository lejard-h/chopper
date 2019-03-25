import 'dart:async';
import 'dart:convert';
import "package:meta/meta.dart";
import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';
import 'utils.dart';

/// [ResponseInterceptor] are call after [Converter.convertResponse]
@immutable
abstract class ResponseInterceptor {
  FutureOr<Response> onResponse(Response response);
}

/// [RequestInterceptor] are call after [Converter.convertRequest]
@immutable
abstract class RequestInterceptor {
  FutureOr<Request> onRequest(Request request);
}

/// [Converter] is is used to convert Request or Response
/// [convertRequest] is call before [RequestInsterceptor]
/// and [convertResponse] just after the http response
@immutable
abstract class Converter {
  FutureOr<Request> convertRequest(Request request);

  /// [ResultType] is the expected type of your response
  /// ex: `String` or `CustomObject`
  ///
  /// In the case of [ResultType] is a `List` or `BuildList`
  /// [ItemType] will be the type of the generic
  /// ex: `convertResponse<List<CustomObject>, CustomObject>(response)`
  FutureOr<Response<ResultType>> convertResponse<ResultType, ItemType>(
      Response response);
}

abstract class ErrorConverter {
  FutureOr<Response> convertError<ResultType, ItemType>(Response response);
}

/// Add [headers] to each request
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
@immutable
class CurlInterceptor implements RequestInterceptor {
  Future<Request> onRequest(Request request) async {
    final baseRequest = await request.toBaseRequest();
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
    chopperLogger.info(curl);
    return request;
  }
}

@immutable
class HttpLoggingInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) async {
    final base = await request.toBaseRequest();
    chopperLogger.info('--> ${base.method} ${base.url}');
    base.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

    var bytes = '';
    if (base is http.Request) {
      final body = base.body;
      if (body != null && body.isNotEmpty) {
        chopperLogger.info(body);
        bytes = ' (${base.bodyBytes.length}-byte body)';
      }
    }

    chopperLogger.info('--> END ${base.method}$bytes');
    return request;
  }

  @override
  FutureOr<Response> onResponse(Response response) {
    final base = response.base.request;
    chopperLogger.info('<-- ${response.statusCode} ${base.url}');

    response.base.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

    var bytes;
    if (response.base.body != null && response.base.body.isNotEmpty) {
      chopperLogger.info(response.base.body);
      bytes = ' (${response.base.bodyBytes.length}-byte body)';
    }

    chopperLogger.info('--> END ${base.method}$bytes');
    return response;
  }
}

/// [json.encode] on [Request] and [json.decode] on [Request]
/// Also add `application/json` header to each request
@immutable
class JsonConverter implements Converter, ErrorConverter {
  @override
  Request convertRequest(Request request) => applyHeader(
        encodeJson(request),
        contentTypeKey,
        jsonHeaders,
      );

  Request encodeJson(Request request) =>
      request.replace(body: json.encode(request.body));

  Response decodeJson(Response response) {
    var contentType = response.headers[contentTypeKey];
    var body = response.body;
    if (contentType != null && contentType.contains(jsonHeaders)) {
      // If we're decoding JSON, there's some ambiguity in https://tools.ietf.org/html/rfc2616
      // about what encoding should be used if the content-type doesn't contain a 'charset'
      // parameter. See https://github.com/dart-lang/http/issues/186. In a nutshell, without
      // an explicit charset, the Dart http library will fall back to using ISO-8859-1, however,
      // https://tools.ietf.org/html/rfc8259 says that JSON must be encoded using UTF-8. So,
      // we're going to explicitly decode using UTF-8... if we don't do this, then we can easily
      // end up with our JSON string containing incorrectly decoded characters.
      body = utf8.decode(response.bodyBytes);
    }
    return response.replace(
      body: _tryDecodeJson(body),
    );
  }

  @override
  Response<ResultType> convertResponse<ResultType, ItemType>(
          Response response) =>
      decodeJson(response) as Response<ResultType>;

  dynamic _tryDecodeJson(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      chopperLogger.warning(e);
      return data;
    }
  }

  @override
  Response convertError<ResultType, ItemType>(Response response) =>
      decodeJson(response);
}

@immutable
class FormUrlEncodedConverter implements Converter, ErrorConverter {
  @override
  Request convertRequest(Request request) => applyHeader(
        request,
        contentTypeKey,
        formEncodedHeaders,
      );

  @override
  Response<ResultType> convertResponse<ResultType, ItemType>(
          Response response) =>
      response;

  @override
  FutureOr<Response> convertError<ResultType, ItemType>(Response response) =>
      response;
}
