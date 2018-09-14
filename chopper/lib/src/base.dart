import "dart:async";
import 'dart:convert' hide Converter;
import 'package:chopper/src/interceptor.dart';
import "package:meta/meta.dart";
import 'package:http/http.dart' as http;

import "interceptor.dart";
import "request.dart";
import 'response.dart';

/// Root object of chopper
/// Used to manager services, encode data, intercept request, response and error.
@immutable
class ChopperClient {
  /// base url of each request to your api
  /// hostname of your api for example
  final String baseUrl;

  /// http client used to do request
  /// from `package:http/http.dart`
  final http.Client httpClient;

  /// converter call before request interceptor
  /// and before interceptor of successful response
  final Converter converter;

  /// converter call on error request
  final Converter errorConverter;

  /// default: false
  /// Use to define your a api need json encoded data
  final bool jsonApi;

  /// default: true
  /// Use to define your a api need form url encoded data
  final bool formUrlEncodedApi;

  final Map<Type, ChopperService> _services = {};
  final _requestInterceptors = [];
  final _responseInterceptors = [];
  final _requestController = StreamController<Request>.broadcast();
  final _responseController = StreamController<Response>.broadcast();
  final _responseErrorController = StreamController<Response>.broadcast();

  ChopperClient({
    this.baseUrl: "",
    http.Client client,
    Iterable interceptors: const [],
    this.converter,
    this.errorConverter,
    Iterable<ChopperService> services: const [],
    this.jsonApi: false,
    this.formUrlEncodedApi: true,
  }) : httpClient = client ?? http.Client() {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw Exception(
          "Unsupported type for interceptors, it only support the following types: RequestInterceptor, RequestInterceptorFunc, ResponseInterceptor, ResponseInterceptorFunc");
    }

    _requestInterceptors.addAll(interceptors.where(_isRequestInterceptor));
    _responseInterceptors.addAll(interceptors.where(_isResponseInterceptor));

    services.toSet().forEach((s) {
      s.client = this;
      _services[s.runtimeType] = s;
    });
  }

  bool _isRequestInterceptor(value) =>
      value is RequestInterceptor || value is RequestInterceptorFunc;

  bool _isResponseInterceptor(value) =>
      value is ResponseInterceptor || value is ResponseInterceptorFunc;

  bool _isAnInterceptor(value) =>
      _isResponseInterceptor(value) || _isRequestInterceptor(value);

  T service<T extends ChopperService>(Type type) {
    final s = _services[type];
    if (s == null) {
      throw Exception("Service of type '$type' not found.");
    }
    return s;
  }

  Future<Request> _encodeRequest(Request request) async {
    final convertJson = jsonApi || request.json == true;

    var converted = request;

    if (converter != null) {
      converted = await converter.encode(request);
    }

    if (convertJson) {
      if (converted.body != null) {
        return converted.replace(body: json.encode(converted.body));
      } else if (converted.parts?.isNotEmpty == true) {
        final parts = converted.parts
            .map((p) => p.replace(value: json.encode(p.value)))
            .toList();
        return converted.replace(parts: parts);
      }
    }

    return converted;
  }

  Future<Response<Value>> _decodeResponse<Value>(
    Response response,
    Converter withConverter,
  ) async {
    if (withConverter == null) return response as Response<Value>;

    final converted = await withConverter.decode<Value>(response);

    if (converted == null) {
      throw Exception("No converter found for type $Value");
    }

    return converted;
  }

  Future<Request> _interceptRequest(Request request) async {
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

  Future<Response> _interceptResponse<Value>(Response<Value> response) async {
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
      req = await _encodeRequest(request);
    }

    req = await _interceptRequest(req);

    _requestController.add(req);
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
      res = await _decodeResponse<Value>(res, converter);
    } else {
      res = await _decodeResponse(res, errorConverter);
    }

    res = await _interceptResponse<Value>(res);

    if (!res.isSuccessful) {
      _responseErrorController.add(res);
      throw res;
    }
    _responseController.add(res);

    return res;
  }

  Response _tryDecodeJson(Response res) {
    try {
      return res.replace(body: json.decode(res.body));
    } catch (_) {
      return res;
    }
  }

  /// dispose [ChopperClient] to clean memory
  void close() {
    _requestController.close();
    _responseController.close();
    _responseErrorController.close();
  }

  Stream<Request> get onRequest => _requestController.stream;

  Stream<Response> get onResponse => _responseController.stream;

  Stream<Response> get onError => _responseErrorController.stream;
}

/// Used by generator to generate apis
abstract class ChopperService {
  ChopperClient client;

  ChopperService();

  ChopperService.withClient(this.client);
}
