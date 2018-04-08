import "dart:async";
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

  ChopperClient(
      {this.baseUrl: "",
      http.Client client,
      Iterable interceptors: const [],
      Converter converter,
      Iterable<ChopperService> apis: const []})
      : httpClient = client ?? new http.Client(),
        _converter = converter {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw new Exception(
          "Unsupported type for interceptors, it only support the following types: RequestInterceptor, RequestInterceptorFunc, ResponseInterceptor, ResponseInterceptorFunc");
    }

    _requestInterceptors.addAll(interceptors.where(_isRequestInterceptor));
    _responseInterceptors.addAll(interceptors.where(_isResponseInterceptor));

    apis.toSet().forEach((s) {
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

  ChopperService service(Type type) {
    final s = _apis[type];
    if (s == null) {
      throw new Exception("Service of type '$type' not found.");
    }
    return s;
  }

  Future<Request> encodeRequest(Request request) async {
    final converted = await _converter?.encode(request) ?? request;

    if (converted == null) {
      throw new Exception(
          "No converter found for type ${request.body?.runtimeType}");
    }

    return converted;
  }

  Future<Response<Value>> decodeResponse<Value>(
      Response<String> response, Type responseType) async {
    final converted = await _converter?.decode(response, responseType);

    if (converted == null) {
      throw new Exception("No converter found for type $Value");
    }

    return converted as Response<Value>;
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

  Future<Response> interceptResponse(Response response) async {
    Response res = response;
    for (final i in _responseInterceptors) {
      if (i is ResponseInterceptor) {
        res = await i.onResponse(res);
      } else if (i is ResponseInterceptorFunc) {
        res = await i(res);
      }
    }
    return res;
  }

  /* note(lejard_h) responseType have to be equal to Value generic type, dart does not support testing on generics yet */
  Future<Response<Value>> send<Value>(Request request,
      {Type responseType}) async {
    Request req = request;

    if (req.body != null) {
      req = await encodeRequest(request);
    }

    req = await interceptRequest(req);

    final stream = await httpClient.send(req.toHttpRequest(baseUrl));

    final response = await http.Response.fromStream(stream);

    Response res = new Response<String>(response, response.body);

    if (res.isSuccessful && responseType != null) {
      res = await decodeResponse<Value>(res, responseType);
    }

    res = await interceptResponse(res);

    if (!res.isSuccessful) {
      throw res;
    }

    return res;
  }
}

abstract class ChopperService {
  ChopperClient client;
}
