import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

@immutable
class Request {
  final String method;
  final String url;
  final dynamic body;
  final Map<String, dynamic> parameters;
  final Map<String, String> headers;

  const Request(
    this.method,
    this.url, {
    this.body,
    this.parameters: const {},
    this.headers: const {},
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
  }) =>
      new Request(
        method ?? this.method,
        url ?? this.url,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
      );

  http.BaseRequest toHttpRequest(String baseUrl) {
    final uri = Uri.parse("$baseUrl/${url}").replace(
      queryParameters: parameters.map((k, v) => new MapEntry(k, "$v")),
    );
    final baseRequest = new http.Request(_getMethod(method), uri);
    baseRequest.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        baseRequest.body = body as String;
      } else if (body is List) {
        baseRequest.bodyBytes = (body as List<int>).cast<int>();
      } else if (body is Map) {
        baseRequest.bodyFields = (body as Map).cast<String, String>();
      } else {
        throw new ArgumentError('Invalid request body "${body}".');
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
