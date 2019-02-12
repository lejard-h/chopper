import 'dart:async';
import 'dart:convert';

import 'package:chopper/src/utils.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

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
    this.parameters: const {},
    this.headers: const {},
    this.multipart: false,
    this.parts: const [],
  });

  String _getMethod(String method) {
    switch (method) {
      case HttpMethod.Delete:
        return "DELETE";
      case HttpMethod.Patch:
        return "PATCH";
      case HttpMethod.Post:
        return "POST";
      case HttpMethod.Put:
        return "PUT";
      default:
        return "GET";
    }
  }

  Request replace({
    HttpMethod method,
    String url,
    dynamic body,
    Map<String, dynamic> parameters,
    Map<String, String> headers,
    Encoding encoding,
    List<PartValue> parts,
    bool multipart,
    String baseUrl,
  }) =>
      Request(
        method ?? this.method,
        url ?? this.url,
        baseUrl ?? this.baseUrl,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
        parts: parts ?? this.parts,
        multipart: multipart ?? this.multipart,
      );

  Uri _buildUri() {
    var uri;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // if the request's url is already a fully qualified URL, we can use
      // as-is and ignore the baseUrl
      uri = Uri.parse(url);
    } else {
      if (!baseUrl.endsWith('/') && !url.startsWith('/')) {
        uri = Uri.parse("$baseUrl/$url");
      } else {
        uri = Uri.parse("$baseUrl$url");
      }
    }

    if (parameters.isNotEmpty) {
      return uri.replace(
        queryParameters: parameters.map((k, v) => MapEntry(k, "$v")),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders() {
    final heads = Map<String, String>.from(headers);

    if (json == true) {
      heads["Content-Type"] = 'application/json';
    }

    return heads;
  }

  Future<http.BaseRequest> _toMultipartRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
  ) async {
    final baseRequest = http.MultipartRequest(method, uri);
    baseRequest.headers.addAll(headers);

    for (final part in parts) {
      if (part is PartFile) {
        if (part.value is List<int>) {
          baseRequest.files.add(
            http.MultipartFile.fromBytes(part.name, part.value),
          );
        } else if (part.value is String) {
          baseRequest.files.add(
            await http.MultipartFile.fromPath(part.name, part.value),
          );
        }
      } else {
        baseRequest.fields[part.name] = part.value?.toString();
      }
    }
    return baseRequest;
  }

  Future<http.BaseRequest> _toBaseRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
  ) async {
    final baseRequest = http.Request(_getMethod(method), uri);
    baseRequest.headers.addAll(headers);

    if (body != null) {
      if (body is String) {
        baseRequest.body = body as String;
      } else if (body is List) {
        baseRequest.bodyBytes = (body as List<int>).cast<int>();
      } else if (body is Map) {
        baseRequest.bodyFields = (body as Map).cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "${body}".');
      }
    }
    return baseRequest;
  }

  Future<http.BaseRequest> toHttpRequest() async {
    final uri = _buildUri();
    final met = _getMethod(method);
    final heads = _buildHeaders();

    if (multipart) {
      return _toMultipartRequest(
        met,
        uri,
        heads,
      );
    }
    return _toBaseRequest(
      met,
      uri,
      heads,
    );
  }

  bool get isJson => headers[contentTypeKey] == jsonHeaders;
}

class HttpMethod {
  static const String Get = "GET";
  static const String Post = "POST";
  static const String Put = "PUT";
  static const String Delete = "DELETE";
  static const String Patch = "PATCH";
}

@immutable
class PartValue<T> {
  final T value;
  final String name;

  const PartValue(
    this.name,
    this.value,
  );

  PartValue<T> replace<T>({String name, T value}) => PartValue<T>(
        name ?? this.name,
        value ?? this.value,
      );
}

@immutable
class PartFile<T> extends PartValue<T> {
  PartFile(String name, T value) : super(name, value);
}
