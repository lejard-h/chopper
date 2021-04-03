import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'utils.dart';
import 'constants.dart';

/// This class represents an HTTP request that can be made with Chopper.
@immutable
class Request {
  final String method;
  final String baseUrl;
  final String url;
  final dynamic body;
  final List<PartValue> parts;
  final Map<String, dynamic> parameters;
  final Map<String, String> headers;
  final bool multipart;

  const Request(
    this.method,
    this.url,
    this.baseUrl, {
    this.body,
    this.parameters = const {},
    this.headers = const {},
    this.multipart = false,
    this.parts = const [],
  });

  /// Makes a copy of this request, replacing original values with the given ones.
  Request copyWith({
    HttpMethod? method,
    String? url,
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, String>? headers,
    Encoding? encoding,
    List<PartValue>? parts,
    bool? multipart,
    String? baseUrl,
  }) =>
      Request(
        (method ?? this.method) as String,
        url ?? this.url,
        baseUrl ?? this.baseUrl,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
        parts: parts ?? this.parts,
        multipart: multipart ?? this.multipart,
      );

  Uri _buildUri() => buildUri(baseUrl, url, parameters);

  Map<String, String> _buildHeaders() => Map<String, String>.from(headers);

  /// Converts this Chopper Request into a [http.BaseRequest].
  ///
  /// All [parameters] and [headers] are conserved.
  ///
  /// Depending on the request type the returning object will be:
  ///   - [http.StreamedRequest] if body is a [Stream<List<int>>]
  ///   - [http.MultipartRequest] if [multipart] is true
  ///   - or a [http.Request]
  Future<http.BaseRequest> toBaseRequest() async {
    final uri = _buildUri();
    final heads = _buildHeaders();

    if (body is Stream<List<int>>) {
      return toStreamedRequest(
        body,
        method,
        uri,
        heads,
      );
    }

    if (multipart) {
      return toMultipartRequest(
        parts,
        method,
        uri,
        heads,
      );
    }
    return toHttpRequest(
      body,
      method,
      uri,
      heads,
    );
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
  PartValueFile(String name, T value) : super(name, value);
}

/// Builds a valid URI from [baseUrl], [url] and [parameters].
///
/// If [url] starts with 'http://' or 'https://', baseUrl is ignored.
Uri buildUri(String baseUrl, String url, Map<String, dynamic> parameters) {
  var uri;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    // If the request's url is already a fully qualified URL, we can use it
    // as-is and ignore the baseUrl.
    uri = Uri.parse(url);
  } else {
    if (!baseUrl.endsWith('/') && !url.startsWith('/')) {
      uri = Uri.parse('$baseUrl/$url');
    } else {
      uri = Uri.parse('$baseUrl$url');
    }
  }

  var query = mapToQuery(parameters);
  if (query.isNotEmpty) {
    if (uri.hasQuery) {
      query += '&${uri.query}';
    }
    return uri.replace(query: query);
  }
  return uri;
}

@visibleForTesting
Future<http.Request> toHttpRequest(
  body,
  String method,
  Uri uri,
  Map<String, String> headers,
) async {
  final baseRequest = http.Request(method, uri);
  baseRequest.headers.addAll(headers);

  if (body != null) {
    if (body is String) {
      baseRequest.body = body;
    } else if (body is List<int>) {
      baseRequest.bodyBytes = body;
    } else if (body is Map<String, String>) {
      baseRequest.bodyFields = body;
    } else {
      throw ArgumentError.value('$body', 'body');
    }
  }
  return baseRequest;
}

@visibleForTesting
Future<http.MultipartRequest> toMultipartRequest(
  List<PartValue> parts,
  String method,
  Uri uri,
  Map<String, String> headers,
) async {
  final baseRequest = http.MultipartRequest(method, uri);
  baseRequest.headers.addAll(headers);

  for (final part in parts) {
    if (part.value == null) continue;

    if (part.value is http.MultipartFile) {
      baseRequest.files.add(part.value);
    } else if (part.value is Iterable<http.MultipartFile>) {
      baseRequest.files.addAll(part.value);
    } else if (part is PartValueFile) {
      if (part.value is List<int>) {
        baseRequest.files.add(
          http.MultipartFile.fromBytes(part.name, part.value),
        );
      } else if (part.value is String) {
        baseRequest.files.add(
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
      baseRequest.fields[part.name] = part.value.toString();
    }
  }
  return baseRequest;
}

@visibleForTesting
Future<http.StreamedRequest> toStreamedRequest(
  Stream<List<int>> bodyStream,
  String method,
  Uri uri,
  Map<String, String> headers,
) async {
  final req = http.StreamedRequest(method, uri);
  req.headers.addAll(headers);

  bodyStream.listen(req.sink.add,
      onDone: req.sink.close, onError: req.sink.addError);

  return req;
}
