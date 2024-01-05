import 'dart:async';
import 'dart:convert';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/constants.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

abstract interface class Interceptor {
  FutureOr<Response<BodyType>> intercept<BodyType, InnerType>(Chain chain);
}

abstract interface class InternalInterceptor implements Interceptor {}

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
// @immutable
// abstract interface class ResponseInterceptor {
//   FutureOr<Response> onResponse(Response response);
// }

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
// @immutable
// abstract interface class RequestInterceptor {
//   FutureOr<Request> onRequest(Request request);
// }

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
abstract interface class Converter {
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
abstract interface class ErrorConverter {
  /// Converts the received [Response] to a [Response] which has a body with the
  /// HTTP representation of the original body.
  FutureOr<Response> convertError<BodyType, InnerType>(Response response);
}

/// A [RequestInterceptor] that adds [headers] to every request.
///
/// Note that this interceptor will overwrite existing headers having the same
/// keys as [headers].
@immutable
class HeadersInterceptor implements Interceptor {
  final Map<String, String> headers;

  const HeadersInterceptor(this.headers);

  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(Chain chain) async {
    final Request request = applyHeaders(chain.request, headers);

    return chain.proceed(request);
  }
}

/// A [RequestInterceptor] implementation that prints a curl request equivalent
/// to the network call channeled through it for debugging purposes.
///
/// Thanks, @edwardaux
@immutable
class CurlInterceptor implements Interceptor {
  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(Chain chain) async {
    final http.BaseRequest baseRequest = await chain.request.toBaseRequest();
    final List<String> curlParts = ['curl -v -X ${baseRequest.method}'];
    for (final MapEntry<String, String> header in baseRequest.headers.entries) {
      curlParts.add("-H '${header.key}: ${header.value}'");
    }
    // this is fairly naive, but it should cover most cases
    if (baseRequest is http.Request) {
      final String body = baseRequest.body;
      if (body.isNotEmpty) {
        curlParts.add("-d '$body'");
      }
    }
    if (baseRequest is http.MultipartRequest) {
      for (final MapEntry<String, String> field in baseRequest.fields.entries) {
        curlParts.add("-f '${field.key}: ${field.value}'");
      }
      for (final http.MultipartFile file in baseRequest.files) {
        curlParts.add("-f '${file.field}: ${file.filename ?? ''}'");
      }
    }
    curlParts.add('"${baseRequest.url}"');
    chopperLogger.info(curlParts.join(' '));

    return chain.proceed(chain.request);
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
  Request convertRequest(Request request) => encodeJson(
        applyHeader(
          request,
          contentTypeKey,
          jsonHeaders,
          override: false,
        ),
      );

  Request encodeJson(Request request) {
    final String? contentType = request.headers[contentTypeKey];

    if ((contentType?.contains(jsonHeaders) ?? false) &&
        (request.body.runtimeType != String || !isJson(request.body))) {
      return request.copyWith(body: json.encode(request.body));
    }

    return request;
  }

  FutureOr<Response> decodeJson<BodyType, InnerType>(Response response) async {
    final List<String> supportedContentTypes = [jsonHeaders, jsonApiHeaders];

    final String? contentType = response.headers[contentTypeKey];
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

    body = await tryDecodeJson(body);
    if (isTypeOf<BodyType, Iterable<InnerType>>()) {
      body = body.cast<InnerType>();
    } else if (isTypeOf<BodyType, Map<String, InnerType>>()) {
      body = body.cast<String, InnerType>();
    }

    return response.copyWith<BodyType>(body: body);
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) async =>
      (await decodeJson<BodyType, InnerType>(response)) as Response<BodyType>;

  @protected
  FutureOr<dynamic> tryDecodeJson(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      chopperLogger.warning(e);

      return data;
    }
  }

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(
    Response response,
  ) async =>
      await decodeJson(response);

  static FutureOr<Response<BodyType>> responseFactory<BodyType, InnerType>(
    Response response,
  ) =>
      const JsonConverter().convertResponse<BodyType, InnerType>(response);

  static Request requestFactory(Request request) =>
      const JsonConverter().convertRequest(request);

  @visibleForTesting
  static bool isJson(dynamic data) {
    try {
      json.decode(data);
      return true;
    } catch (_) {
      return false;
    }
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
    final Request req = applyHeader(
      request,
      contentTypeKey,
      formEncodedHeaders,
      override: false,
    );

    if (req.body is Map<String, String>) return req;

    if (req.body is Map) {
      return req.copyWith(body: <String, String>{
        for (final MapEntry e in req.body.entries)
          if (e.value != null) e.key.toString(): e.value.toString(),
      });
    }

    return req;
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) =>
      response as Response<BodyType>;

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(Response response) =>
      response;

  static Request requestFactory(Request request) {
    return const FormUrlEncodedConverter().convertRequest(request);
  }
}
