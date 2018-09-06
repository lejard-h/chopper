import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

@immutable
class Request {
  final String method;
  final String url;
  final dynamic body;
  final List<PartValue> parts;
  final Map<String, dynamic> parameters;
  final Map<String, String> headers;
  final bool formUrlEncoded;
  final bool multipart;
  final bool json;

  const Request(
    this.method,
    this.url, {
    this.body,
    this.parameters: const {},
    this.headers: const {},
    this.multipart: false,
    this.formUrlEncoded,
    this.json,
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
    bool json,
    bool multipart,
    bool formUrlEncoded,
  }) =>
      Request(
        method ?? this.method,
        url ?? this.url,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
        parts: parts ?? this.parts,
        json: json ?? this.json,
        formUrlEncoded: formUrlEncoded ?? this.formUrlEncoded,
        multipart: multipart ?? this.multipart,
      );

  Uri _buildUri(String baseUrl) {
    var uri;
    if (!baseUrl.endsWith('/') && !url.startsWith('/')) {
      uri = Uri.parse("$baseUrl/$url");
    } else {
      uri = Uri.parse("$baseUrl$url");
    }

    if (parameters.isNotEmpty) {
      return uri.replace(
        queryParameters: parameters.map((k, v) => MapEntry(k, "$v")),
      );
    }
    return uri;
  }

  Future<http.BaseRequest> _toMultipartRequest(
    String method,
    Uri uri, {
    bool formUrlEncodedApi: false,
  }) async {
    final baseRequest = http.MultipartRequest(method, uri);
    baseRequest.headers.addAll(headers);

    if (formUrlEncodedApi || formUrlEncoded == true) {
      baseRequest.headers["Content-Type"] = 'application/x-www-form-urlencoded';
    }

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

  http.BaseRequest toHttpRequest(
    String baseUrl, {
    bool formUrlEncodedApi: false,
  }) {
    final uri = _buildUri(baseUrl);

    var baseRequest;

    if (multipart) {
      baseRequest = _toMultipartRequest(
        _getMethod(method),
        uri,
        formUrlEncodedApi: formUrlEncodedApi,
      );
    } else {
      baseRequest = http.Request(_getMethod(method), uri);
      baseRequest.headers.addAll(headers);

      if (formUrlEncodedApi || formUrlEncoded == true) {
        baseRequest.headers["Content-Type"] =
            'application/x-www-form-urlencoded';
      }
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
    }

    return baseRequest;
  }
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
}

@immutable
class PartFile<T> extends PartValue<T> {
  PartFile(String name, T value) : super(name, value);
}
