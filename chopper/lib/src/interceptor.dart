import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';
import 'utils.dart';
import 'constants.dart';

/// Interface to implements a response interceptor.
/// Not recommended to modify body inside interceptor, see [Converter] to decode body response.
///
/// [ResponseInterceptor] are call after [Converter.convertResponse].
///
/// See builtin interceptor [HttpLoggingInterceptor]
///
/// ```dart
/// class MyResponseInterceptor  implements ResponseInterceptor {
///   String _token;
///
///   @override
///   FutureOr<Response> onResponse(Response response) {
///     _token ??= response.headers['auth_token'];
///     return response;
///   }
/// }
/// ```
@immutable
abstract class ResponseInterceptor {
  FutureOr<Response> onResponse(Response response);
}

/// Interface to implements a request interceptor.
/// Not recommended to modify body inside interceptor, see [Converter] to encode body request.
///
/// [RequestInterceptor] are call after [Converter.convertRequest]
///
/// See builtin interceptor [CurlInterceptor], [HttpLoggingInterceptor]
///
/// ```dart
/// class MyRequestInterceptor implements ResponseInterceptor {
///   @override
///   FutureOr<Request> onRequest(Request request) {
///     return applyHeader(request, 'auth_token', 'Bearer $token');
///   }
/// }
/// ```
@immutable
abstract class RequestInterceptor {
  FutureOr<Request> onRequest(Request request);
}

/// [Converter] is is used to convert body of Request or Response
/// [convertRequest] is call before [RequestInterceptor]
/// and [convertResponse] just after the http response, before [ResponseInterceptor].
///
/// See [JsonConverter], [FormUrlEncodedConverter]
@immutable
abstract class Converter {
  FutureOr<Request> convertRequest(Request request);

  /// [BodyType] is the expected type of your response
  /// ex: `String` or `CustomObject`
  ///
  /// In the case of [BodyType] is a `List` or `BuildList`
  /// [InnerType] will be the type of the generic
  /// ex: `convertResponse<List<CustomObject>, CustomObject>(response)`
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  );
}

abstract class ErrorConverter {
  FutureOr<Response> convertError<BodyType, InnerType>(Response response);
}

/// Add [headers] to each request
@immutable
class HeadersInterceptor implements RequestInterceptor {
  final Map<String, String> headers;

  const HeadersInterceptor(this.headers);

  @override
  Future<Request> onRequest(Request request) async =>
      applyHeaders(request, headers);
}

typedef ResponseInterceptorFunc1 = FutureOr<Response<BodyType>>
    Function<BodyType>(
  Response<BodyType> response,
);
typedef ResponseInterceptorFunc2 = FutureOr<Response<BodyType>>
    Function<BodyType, InnerType>(
  Response<BodyType> response,
);
typedef DynamicResponseInterceptorFunc = FutureOr<Response> Function(
  Response response,
);
typedef RequestInterceptorFunc = FutureOr<Request> Function(Request request);

/// Interceptor that print a curl request
/// thanks @edwardaux
@immutable
class CurlInterceptor implements RequestInterceptor {
  @override
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
    if (response.base is http.Response) {
      final resp = response.base as http.Response;
      if (resp.body != null && resp.body.isNotEmpty) {
        chopperLogger.info(resp.body);
        bytes = ' (${response.bodyBytes?.length}-byte body)';
      }
    }

    chopperLogger.info('--> END ${base.method}$bytes');
    return response;
  }
}

/// [json.encode] on [Request] and [json.decode] on [Response]
/// Also add `application/json` header to each request
///
/// If content type header overrided using @Post(headers: {'content-type': '...'})
/// The converter won't add json header and won't apply json.encode if content type is not JSON
@immutable
class JsonConverter implements Converter, ErrorConverter {
  const JsonConverter();

  @override
  Request convertRequest(Request request) {
    final req = applyHeader(
      request,
      contentTypeKey,
      jsonHeaders,
      override: false,
    );

    return encodeJson(req);
  }

  Request encodeJson(Request request) {
    var contentType = request.headers[contentTypeKey];
    if (contentType != null && contentType.contains(jsonHeaders)) {
      return request.copyWith(body: json.encode(request.body));
    }
    return request;
  }

  Response decodeJson<BodyType, InnerType>(Response response) {
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

    body = _tryDecodeJson(body);
    if (isTypeOf<BodyType, Iterable<InnerType>>()) {
      body = body.cast<InnerType>();
    } else if (isTypeOf<BodyType, Map<String, InnerType>>()) {
      body = body.cast<String, InnerType>();
    }

    return response.copyWith<BodyType>(body: body);
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    return decodeJson<BodyType, InnerType>(response);
  }

  dynamic _tryDecodeJson(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      chopperLogger.warning(e);
      return data;
    }
  }

  @override
  Response convertError<BodyType, InnerType>(Response response) =>
      decodeJson(response);

  static Response<BodyType> responseFactory<BodyType, InnerType>(
    Response response,
  ) {
    return const JsonConverter().convertResponse<BodyType, InnerType>(response);
  }

  static Request requestFactory(Request request) {
    return const JsonConverter().convertRequest(request);
  }
}

@immutable
class FormUrlEncodedConverter implements Converter, ErrorConverter {
  const FormUrlEncodedConverter();

  @override
  Request convertRequest(Request request) {
    var req = applyHeader(
      request,
      contentTypeKey,
      formEncodedHeaders,
      override: false,
    );

    if (req.body is Map<String, String>) return req;

    if (req.body is Map) {
      final body = <String, String>{};

      req.body.forEach((key, val) {
        if (val != null) {
          body[key.toString()] = val.toString();
        }
      });

      req = req.copyWith(body: body);
    }

    return req;
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) =>
      response;

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(Response response) =>
      response;

  static Request requestFactory(Request request) {
    return const FormUrlEncodedConverter().convertRequest(request);
  }
}
