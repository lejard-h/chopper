import 'dart:async';
import 'dart:convert';

import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:meta/meta.dart';

import 'constants.dart';

/// An interface for implementing request and response converters.
///
/// [Converter]s convert objects to and from their representation in HTTP.
///
/// [convertRequest] is called before [Interceptor]s
/// and [convertResponse] is called just after the HTTP response,
/// before returning through the [Interceptor]s.
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

/// An interface for converting request parameters before the request is sent.
///
/// Implement this when values used by annotations like `@Query` need to be
/// converted to their HTTP representation before query strings are encoded.
///
/// `convertParameter` is invoked **only for leaf values** during query
/// parameter conversion. When a parameter value is a `Map` or an `Iterable`,
/// Chopper recurses into it and calls `convertParameter` on each contained
/// leaf, never on the container itself. As a result, implementers do not need
/// to handle nested containers themselves — they only need to return the HTTP
/// representation of an individual scalar value.
@immutable
abstract interface class ParameterConverter {
  /// Converts the leaf [parameter] for the location described by [context].
  ///
  /// This is never called with a `Map` or `Iterable` value; Chopper walks
  /// those structures and invokes this method once per leaf.
  Object? convertParameter(
    Object? parameter,
    ParameterConversionContext context,
  );
}

/// Information about a parameter being converted.
@immutable
final class ParameterConversionContext {
  /// Creates context for a parameter conversion.
  const ParameterConversionContext({
    required this.name,
    required this.location,
  });

  /// Parameter name or path within a structured parameter value.
  final String name;

  /// Location where the parameter will be used in the request.
  final ParameterLocation location;
}

/// Locations where request parameters can appear.
///
/// Currently only [query] is converted by Chopper. The remaining values are
/// reserved for future parameter conversion support.
enum ParameterLocation {
  /// Query parameters passed with `@Query` or `@QueryMap`.
  query,

  /// Path parameters passed with `@Path`.
  path,

  /// Header parameters passed with `@Header`.
  header,

  /// Form fields passed with `@Field` or `@FieldMap`.
  field,

  /// Multipart parts passed with `@Part` or related annotations.
  part,
}

/// An interface for implementing error response converters.
///
/// An `ErrorConverter` is called only on error responses
/// (statusCode < 200 || statusCode >= 300) and before returning to any [Interceptor]s.
abstract interface class ErrorConverter {
  /// Converts the received [Response] to a [Response] which has a body with the
  /// HTTP representation of the original body.
  FutureOr<Response> convertError<BodyType, InnerType>(Response response);
}

/// {@template JsonConverter}
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
/// `@POST(headers: {'content-type': '...'})`), `JsonConverter` won't add the
/// header and it won't call json.encode if content type is not JSON.
/// {@endtemplate}
@immutable
class JsonConverter implements Converter, ErrorConverter {
  /// {@macro JsonConverter}
  const JsonConverter();

  @override
  Request convertRequest(Request request) => encodeJson(
    applyHeader(request, contentTypeKey, jsonHeaders, override: false),
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
      body = _decodeList<InnerType>(body);
    } else if (isTypeOf<BodyType, Map<String, InnerType>>()) {
      body = _decodeMap<InnerType>(body);
    }

    return response.copyWith<BodyType>(body: body);
  }

  static List<ItemType> _decodeList<ItemType>(Object? body) {
    if (body is! Iterable) {
      throw FormatException(
        'JsonConverter expected response body to be Iterable<$ItemType>, '
        'but got ${_typeName(body)}.',
      );
    }

    final result = <ItemType>[];
    var index = 0;
    for (final item in body) {
      if (item is! ItemType) {
        throw FormatException(
          'JsonConverter expected response body[$index] to be $ItemType, '
          'but got ${_typeName(item)}.',
        );
      }

      result.add(item);
      index++;
    }

    return result;
  }

  static Map<String, ItemType> _decodeMap<ItemType>(Object? body) {
    if (body is! Map) {
      throw FormatException(
        'JsonConverter expected response body to be Map<String, $ItemType>, '
        'but got ${_typeName(body)}.',
      );
    }

    final result = <String, ItemType>{};
    for (final entry in body.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException(
          'JsonConverter expected response body key to be String, '
          'but got ${_typeName(key)}.',
        );
      }

      final value = entry.value;
      if (value is! ItemType) {
        throw FormatException(
          'JsonConverter expected response body[${json.encode(key)}] '
          'to be $ItemType, but got ${_typeName(value)}.',
        );
      }

      result[key] = value;
    }

    return result;
  }

  static String _typeName(Object? value) => switch (value) {
    null => 'Null',
    Map() => 'Map',
    List() => 'List',
    Iterable() => 'Iterable',
    _ => value.runtimeType.toString(),
  };

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) async =>
      (await decodeJson<BodyType, InnerType>(response)) as Response<BodyType>;

  @protected
  @visibleForTesting
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
  ) async => await decodeJson(response);

  static FutureOr<Response<BodyType>> responseFactory<BodyType, InnerType>(
    Response response,
  ) => const JsonConverter().convertResponse<BodyType, InnerType>(response);

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

/// {@template FormUrlEncodedConverter}
/// A [Converter] implementation that converts only [Request]s having a [Map] as their body.
///
/// This `Converter` also adds the `content-type: application/x-www-form-urlencoded`
/// header to each request, but only if the `content-type` header is not set in
/// the original request.
/// {@endtemplate}
@immutable
class FormUrlEncodedConverter implements Converter, ErrorConverter {
  /// {@macro FormUrlEncodedConverter}
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
      return req.copyWith(
        body: <String, String>{
          for (final MapEntry e in req.body.entries)
            if (e.value != null) e.key.toString(): e.value.toString(),
        },
      );
    }

    return req;
  }

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) => response as Response<BodyType>;

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(Response response) =>
      response;

  static Request requestFactory(Request request) {
    return const FormUrlEncodedConverter().convertRequest(request);
  }
}
