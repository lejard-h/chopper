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

  final bool _clientIsInternal;

  ChopperClient({
    this.baseUrl: "",
    http.Client client,
    Iterable interceptors: const [],
    this.converter,
    this.errorConverter,
    Iterable<ChopperService> services: const [],
    this.jsonApi: false,
    this.formUrlEncodedApi: false,
  })  : httpClient = client ?? http.Client(),
        _clientIsInternal = client == null {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw Exception(
          "Unsupported type for interceptors, it only support the following types: RequestInterceptor, RequestInterceptorFunc, ResponseInterceptor, ResponseInterceptorFunc");
    }

    _requestInterceptors.addAll(interceptors.where(_isRequestInterceptor));
    _responseInterceptors.addAll(interceptors.where(_isResponseInterceptor));

    services.toSet().forEach((s) {
      s.client = this;
      _services[s.definitionType] = s;
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
    final convertJson = request.json == true;

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

  Future<Response> _decodeResponse<Value>(
    Response response,
    Converter withConverter,
  ) async {
    if (withConverter == null) return response;

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

  Future<Response> _interceptResponse(Response response) async {
    var res = response;
    for (final i in _responseInterceptors) {
      if (i is ResponseInterceptor) {
        res = await i.onResponse(res);
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
    final stream = await httpClient.send(await req.toHttpRequest());

    final response = await http.Response.fromStream(stream);

    String responseBody;
    var contentType = response.headers['content-type'];
    if (contentType != null && contentType.contains("application/json")) {
      // If we're decoding JSON, there's some ambiguity in https://tools.ietf.org/html/rfc2616
      // about what encoding should be used if the content-type doesn't contain a 'charset'
      // parameter. See https://github.com/dart-lang/http/issues/186. In a nutshell, without
      // an explicit charset, the Dart http library will fall back to using ISO-8859-1, however,
      // https://tools.ietf.org/html/rfc8259 says that JSON must be encoded using UTF-8. So,
      // we're going to explicitly decode using UTF-8... if we don't do this, then we can easily
      // end up with our JSON string containing incorrectly decoded characters.
      responseBody = utf8.decode(response.bodyBytes);
    } else {
      responseBody = response.body;
    }
    Response res = Response(response, responseBody);

    if (req.json == true) {
      res = _tryDecodeJson(res);
    }

    if (res.isSuccessful) {
      res = await _decodeResponse<Value>(res, converter);
    } else {
      res = await _decodeResponse(res, errorConverter);
    }

    res = await _interceptResponse(res);

    if (!res.isSuccessful) {
      _responseErrorController.add(res);
      throw res;
    }
    _responseController.add(res);

    return res;
  }

  Future<Response<Body>> get<Body>(
    String url, {
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'GET',
          url,
          baseUrl,
          headers: headers,
        ),
      );

  Future<Response<Body>> post<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'POST',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<Body>> put<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'PUT',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<Body>> patch<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'PATCH',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<Body>> delete<Body>(
    String url, {
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'DELETE',
          url,
          baseUrl,
          headers: headers,
        ),
      );

  Response _tryDecodeJson(Response res) {
    try {
      return res.replace(body: json.decode(res.body));
    } catch (_) {
      return res;
    }
  }

  @Deprecated('use dispose')
  @mustCallSuper
  void close() {
    dispose();
  }

  /// dispose [ChopperClient] to clean memory
  @mustCallSuper
  void dispose() {
    _requestController.close();
    _responseController.close();
    _responseErrorController.close();

    _services.forEach((_, s) => s.dispose());
    _services.clear();

    _requestInterceptors.clear();
    _responseInterceptors.clear();

    if (_clientIsInternal) {
      httpClient.close();
    }
  }

  /// Event stream of request just before http call
  /// all converters and interceptors have been run
  Stream<Request> get onRequest => _requestController.stream;

  /// Event stream of response
  /// all converters and interceptors have been run
  Stream<Response> get onResponse => _responseController.stream;

  /// Event stream of error response (status code <200 >=300)
  /// all converters and interceptors have been run
  Stream<Response> get onError => _responseErrorController.stream;
}

/// Used by generator to generate apis
abstract class ChopperService {
  ChopperClient client;

  Type get definitionType => null;

  @mustCallSuper
  void dispose() {
    client = null;
  }
}
