import 'dart:async';

import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// This class represents an HTTP request that can be made with Chopper.
class Request extends http.BaseRequest {
  final String path;
  final String origin;
  final dynamic body;
  final Map<String, dynamic> parameters;
  final bool multipart;
  final List<PartValue> parts;
  final bool useBrackets;
  final bool ignoreNullQueryVars;

  Request(
    String method,
    this.path,
    this.origin, {
    this.body,
    this.parameters = const {},
    Map<String, String> headers = const {},
    this.multipart = false,
    this.parts = const [],
    this.useBrackets = false,
    this.ignoreNullQueryVars = false,
  }) : super(
          method,
          buildUri(
            origin,
            path,
            parameters,
            useBrackets: useBrackets,
            ignoreNullQueryVars: ignoreNullQueryVars,
          ),
        ) {
    this.headers.addAll(headers);
  }

  /// Build the Chopper [Request] using a [Uri] instead of a [path] and [origin].
  /// Both the query parameters in the [Uri] and those provided explicitly in
  /// the [parameters] are merged together.
  Request.uri(
    String method,
    Uri url, {
    this.body,
    Map<String, dynamic>? parameters,
    Map<String, String> headers = const {},
    this.multipart = false,
    this.parts = const [],
    this.useBrackets = false,
    this.ignoreNullQueryVars = false,
  })  : origin = url.origin,
        path = url.path,
        parameters = {...url.queryParametersAll, ...?parameters},
        super(
          method,
          buildUri(
            url.origin,
            url.path,
            {...url.queryParametersAll, ...?parameters},
            useBrackets: useBrackets,
            ignoreNullQueryVars: ignoreNullQueryVars,
          ),
        ) {
    this.headers.addAll(headers);
  }

  /// Makes a copy of this [Request], replacing original values with the given ones.
  Request copyWith({
    String? method,
    String? path,
    String? origin,
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, String>? headers,
    bool? multipart,
    List<PartValue>? parts,
    bool? useBrackets,
    bool? ignoreNullQueryVars,
  }) =>
      Request(
        method ?? this.method,
        path ?? this.path,
        origin ?? this.origin,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
        multipart: multipart ?? this.multipart,
        parts: parts ?? this.parts,
        useBrackets: useBrackets ?? this.useBrackets,
        ignoreNullQueryVars: ignoreNullQueryVars ?? this.ignoreNullQueryVars,
      );

  /// Builds a valid URI from [baseUrl], [url] and [parameters].
  ///
  /// If [url] starts with 'http://' or 'https://', baseUrl is ignored.
  @visibleForTesting
  static Uri buildUri(
    String baseUrl,
    String url,
    Map<String, dynamic> parameters, {
    bool useBrackets = false,
    bool ignoreNullQueryVars = false,
  }) {
    // If the request's url is already a fully qualified URL, we can use it
    // as-is and ignore the baseUrl.
    final Uri uri = url.startsWith('http://') || url.startsWith('https://')
        ? Uri.parse(url)
        : Uri.parse('${baseUrl.strip('/')}/${url.leftStrip('/')}');

    final String query = mapToQuery(
      parameters,
      useBrackets: useBrackets,
      ignoreNullQueryVars: ignoreNullQueryVars,
    );

    return query.isNotEmpty
        ? uri.replace(query: uri.hasQuery ? '${uri.query}&$query' : query)
        : uri;
  }

  /// Converts this Chopper Request into a [http.BaseRequest].
  ///
  /// All [parameters] and [headers] are conserved.
  ///
  /// Depending on the request type the returning object will be:
  ///   - [http.StreamedRequest] if body is a [Stream<List<int>>]
  ///   - [http.MultipartRequest] if [multipart] is true
  ///   - or a [http.Request]
  Future<http.BaseRequest> toBaseRequest() async {
    if (body is Stream<List<int>>) return toStreamedRequest(body);

    if (multipart) return toMultipartRequest();

    return toHttpRequest();
  }

  /// Convert this [Request] to a [http.Request]
  @visibleForTesting
  http.Request toHttpRequest() {
    final http.Request request = http.Request(method, url)
      ..headers.addAll(headers);

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List<int>) {
        request.bodyBytes = body;
      } else if (body is Map<String, String>) {
        request.bodyFields = body;
      } else {
        throw ArgumentError.value('$body', 'body');
      }
    }

    return request;
  }

  /// Convert this [Request] to a [http.MultipartRequest]
  @visibleForTesting
  Future<http.MultipartRequest> toMultipartRequest() async {
    final http.MultipartRequest request = http.MultipartRequest(method, url)
      ..headers.addAll(headers);

    for (final PartValue part in parts) {
      if (part.value == null) continue;

      if (part.value is http.MultipartFile) {
        request.files.add(part.value);
      } else if (part.value is Iterable<http.MultipartFile>) {
        request.files.addAll(part.value);
      } else if (part is PartValueFile) {
        if (part.value is List<int>) {
          request.files.add(
            http.MultipartFile.fromBytes(part.name, part.value),
          );
        } else if (part.value is String) {
          request.files.add(
            await http.MultipartFile.fromPath(part.name, part.value),
          );
        } else {
          throw ArgumentError(
            'Type ${part.value.runtimeType} is not a supported type for PartFile'
            'Please use one of the following types'
            ' - List<int>'
            ' - String (path of your file) '
            ' - MultipartFile (from package:http)',
          );
        }
      } else {
        request.fields[part.name] = part.value.toString();
      }
    }

    return request;
  }

  /// Convert this [Request] to a [http.StreamedRequest]
  @visibleForTesting
  http.StreamedRequest toStreamedRequest(Stream<List<int>> bodyStream) {
    final http.StreamedRequest request = http.StreamedRequest(method, url)
      ..headers.addAll(headers);

    bodyStream.listen(
      request.sink.add,
      onDone: request.sink.close,
      onError: request.sink.addError,
    );

    return request;
  }
}

/// Represents a part in a multipart request.
@immutable
class PartValue<T> {
  final T value;
  final String name;

  const PartValue(
    this.name,
    this.value,
  );

  /// Makes a copy of this PartValue, replacing original values with the given ones.
  /// This method can also alter the type of the request body.
  PartValue<NewType> copyWith<NewType>({String? name, NewType? value}) =>
      PartValue<NewType>(
        name ?? this.name,
        value ?? this.value as NewType,
      );
}

/// Represents a file part in a multipart request.
@immutable
class PartValueFile<T> extends PartValue<T> {
  const PartValueFile(super.name, super.value);
}
