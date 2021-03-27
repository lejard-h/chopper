import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';
import 'utils.dart';
import 'constants.dart';

/// An interface for implementing response interceptors.
///
/// [ResponseInterceptor]s are called after [Converter.convertResponse].
///
/// While [ResponseInterceptor]s *can* modify the body of responses,
/// converting (decoding) the response body should be handled by [Converter]s.
///
/// See built-in [HttpLoggingInterceptor] for a fully functional example implementation.
///
/// A short example for extracting a header value from a response:
///
/// ```dart
/// class MyResponseInterceptor implements ResponseInterceptor {
///   String _token;
///
///   @override
///   FutureOr<Response> onResponse(Response response) {
///     _token = response.headers['auth_token'];
///     return response;
///   }
/// }
/// ```
@immutable
abstract class ResponseInterceptor {
  FutureOr<Response> onResponse(Response response);
}

/// An interface for implementing request interceptors.
///
/// [RequestInterceptor]s are called after [Converter.convertRequest].
///
/// While [RequestInterceptor]s *can* modify the body of requests,
/// converting (encoding) the request body should be handled by [Converter]s.
///
/// See built-in [CurlInterceptor] and [HttpLoggingInterceptor] for fully
/// functional example implementations.
///
/// A short example for adding an authentication token to every request:
///
/// ```dart
/// class MyRequestInterceptor implements ResponseInterceptor {
///   @override
///   FutureOr<Request> onRequest(Request request) {
///     return applyHeader(request, 'auth_token', 'Bearer $token');
///   }
/// }
/// ```
///
/// (See [applyHeader(request, name, value)] and [applyHeaders(request, headers)].)
@immutable
abstract class RequestInterceptor {
  FutureOr<Request> onRequest(Request request);
}

/// An interface for implementing request and response converters.
///
/// [Converter]s convert objects to and from their representation in HTTP.
///
/// [convertRequest] is called before [RequestInterceptor]s
/// and [convertResponse] is called just after the HTTP response,
/// before [ResponseInterceptor]s.
///
/// See [JsonConverter] and [FormUrlEncodedConverter] for example implementations.
@immutable
abstract class Converter {
  /// Converts the received [Request] to a [Request] which has a body with the
  /// HTTP representation of the original body.
  FutureOr<Request> convertRequest(Request request);

  /// Converts the received [Response] to a [Response] which has a body of the
  /// type [BodyType].
  ///
  /// `BodyType` is the expected type of the resulting `Response`'s body
  /// \(e.g., `String` or `CustomObject)`.
  ///
  /// If `BodyType` is a `List` or a `BuiltList`, `InnerType` is the type of the
  /// generic parameter (e.g., `convertResponse<List<CustomObject>, CustomObject>(response)` ).
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  );
}

/// An interface for implementing error response converters.
///
/// An `ErrorConverter` is called only on error responses
/// (statusCode < 200 || statusCode >= 300) and before any [ResponseInterceptor]s.
abstract class ErrorConverter {
  /// Converts the received [Response] to a [Response] which has a body with the
  /// HTTP representation of the original body.
  FutureOr<Response> convertError<BodyType, InnerType>(Response response);
}

/// A [RequestInterceptor] that adds [headers] to every request.
///
/// Note that this interceptor will overwrite existing headers having the same
/// keys as [headers].
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

/// A [RequestInterceptor] implementation that prints a curl request equivalent
/// to the network call channeled through it for debugging purposes.
///
/// Thanks, @edwardaux
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
      if (body.isNotEmpty) {
        curl += ' -d \'$body\'';
      }
    }
    curl += ' \"$url\"';
    chopperLogger.info(curl);
    return request;
  }
}

/// A [RequestInterceptor] and [ResponseInterceptor] implementation which logs
/// HTTP request and response data.
///
/// **Warning:** Log messages written by this interceptor have the potential to
/// leak sensitive information, such as `Authorization` headers and user data
/// in response bodies. This interceptor should only be used in a controlled way
/// or in a non-production environment.
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
      if (body.isNotEmpty) {
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
    chopperLogger.info('<-- ${response.statusCode} ${base!.url}');

    response.base.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

    var bytes;
    if (response.base is http.Response) {
      final resp = response.base as http.Response;
      if (resp.body.isNotEmpty) {
        chopperLogger.info(resp.body);
        bytes = ' (${response.bodyBytes.length}-byte body)';
      }
    }

    chopperLogger.info('--> END ${base.method}$bytes');
    return response;
  }
}

/// A [Converter] implementation that calls [json.encode] on [Request]s and
/// [json.decode] on [Response]s using the [dart:convert](https://api.dart.dev/stable/2.10.3/dart-convert/dart-convert-library.html)
/// package's [utf8] and [json] utilities.
///
/// See the official documentation on
/// [Serializing JSON manually using dart:convert](https://flutter.dev/docs/development/data-and-backend/json#serializing-json-manually-using-dartconvert)
/// to learn more about when and how this `Converter` works as intended.
///
/// This `Converter` also adds the `content-type: application/json` header to each request.
///
/// If content type header is modified (for example by using
/// `@Post(headers: {'content-type': '...'})`), `JsonConverter` won't add the
/// header and it won't call json.encode if content type is not JSON.
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
    final supportedContentTypes = [jsonHeaders, jsonApiHeaders];

    final contentType = response.headers[contentTypeKey];
    var body = response.body;

    if (supportedContentTypes.contains(contentType)) {
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
    return decodeJson<BodyType, InnerType>(response) as Response<BodyType>;
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

/// A [Converter] implementation that converts only [Request]s having a [Map] as their body.
///
/// This `Converter` also adds the `content-type: application/x-www-form-urlencoded`
/// header to each request, but only if the `content-type` header is not set in
/// the original request.
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
      response as Response<BodyType>;

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(Response response) =>
      response;

  static Request requestFactory(Request request) {
    return const FormUrlEncodedConverter().convertRequest(request);
  }
}
