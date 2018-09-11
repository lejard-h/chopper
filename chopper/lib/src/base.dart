import "dart:async";
import 'dart:convert' hide Converter;
import "package:meta/meta.dart";
import 'package:http/http.dart' as http;

import "interceptor.dart";
import "request.dart";
import 'response.dart';

@immutable
class ChopperClient {
  final String baseUrl;
  final http.Client httpClient;
  final Converter _converter;
  final Map<Type, ChopperService> _apis = {};
  final _requestInterceptors = [];
  final _responseInterceptors = [];

  final bool jsonApi;
  final bool formUrlEncodedApi;

  ChopperClient({
    this.baseUrl: "",
    http.Client client,
    Iterable interceptors: const [],
    Converter converter,
    Iterable<ChopperService> services: const [],
    this.jsonApi: false,
    this.formUrlEncodedApi: false,
  })  : httpClient = client ?? http.Client(),
        _converter = converter {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw Exception(
          "Unsupported type for interceptors, it only support the following types: RequestInterceptor, RequestInterceptorFunc, ResponseInterceptor, ResponseInterceptorFunc");
    }

    _requestInterceptors.addAll(interceptors.where(_isRequestInterceptor));
    _responseInterceptors.addAll(interceptors.where(_isResponseInterceptor));

    services.toSet().forEach((s) {
      s.client = this;
      _apis[s.runtimeType] = s;
    });
  }

  bool _isRequestInterceptor(value) =>
      value is RequestInterceptor || value is RequestInterceptorFunc;

  bool _isResponseInterceptor(value) =>
      value is ResponseInterceptor || value is ResponseInterceptorFunc;

  bool _isAnInterceptor(value) =>
      _isResponseInterceptor(value) || _isRequestInterceptor(value);

  T service<T extends ChopperService>(Type type) {
    final s = _apis[type];
    if (s == null) {
      throw Exception("Service of type '$type' not found.");
    }
    return s;
  }

  Future<Request> encodeRequest(Request request) async {
    final converted = await _converter?.encode(request) ?? request;

    if (converted == null) {
      throw Exception(
          "No converter found for type ${request.body?.runtimeType}");
    }

    if (jsonApi || converted.json == true) {
      return converted.replace(body: json.encode(converted.body));
    }
    return converted;
  }

  Future<Response<Value>> decodeResponse<Value>(
    Response response,
  ) async {
    if (_converter == null) return response as Response<Value>;

    final converted = await _converter.decode<Value>(response);

    if (converted == null) {
      throw Exception("No converter found for type $Value");
    }

    return converted;
  }

  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    for (final i in _requestInterceptors) {
      if (i is RequestInterceptor) {
        req = await i.onRequest(req);
      } else if (i is RequestInterceptorFunc) {
        req = await i(req);
      }
    }
    return req;
  }

  Future<Response> interceptResponse<Value>(Response<Value> response) async {
    Response<Value> res = response;
    for (final i in _responseInterceptors) {
      if (i is ResponseInterceptor) {
        res = await i.onResponse<Value>(res);
      } else if (i is ResponseInterceptorFunc) {
        res = await i(res);
      }
    }
    return res;
  }

  Future<Response<Value>> send<Value>(Request request) async {
    Request req = request;

    if (req.body != null || req.parts.isNotEmpty) {
      req = await encodeRequest(request);
    }

    req = await interceptRequest(req);

    final stream = await httpClient.send(await req.toHttpRequest(
      baseUrl,
      jsonApi: jsonApi,
      formUrlEncodedApi: formUrlEncodedApi,
    ));

    final response = await http.Response.fromStream(stream);

    Response res = Response(response, response.body);

    if ((jsonApi == true && req.formUrlEncoded != true) || req.json == true) {
      res = _tryDecodeJson(res);
    }

    if (res.isSuccessful) {
      res = await decodeResponse<Value>(res);
    }

    res = await interceptResponse<Value>(res);

    if (!res.isSuccessful) {
      throw res;
    }

    return res;
  }

  Response _tryDecodeJson(Response res) {
    try {
      return res.replace(body: json.decode(res.body));
    } catch (_) {
      return res;
    }
  }
}

abstract class ChopperService {
  ChopperClient client;
}
