import "dart:async";
import "package:meta/meta.dart";
import 'package:http/http.dart' as http;

// ignore: uri_does_not_exist
import 'io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'io.dart';

import "interceptor.dart";
import "request.dart";
import 'response.dart';
import 'annotations.dart';

Type typeOf<T>() => T;

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
  final ErrorConverter errorConverter;

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
  })  : httpClient = client ?? createHttpClient(),
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

  ServiceType getService<ServiceType extends ChopperService>() {
    Type serviceType = typeOf<ServiceType>();
    if (serviceType == dynamic) {
      throw Exception(
          "Service type should be provided, `dynamic` is not allowed.");
    }
    final service = _services[serviceType];
    if (service == null) {
      throw Exception("Service of type '$serviceType' not found.");
    }
    return service;
  }

  Future<Request> _encodeRequest(Request request) async {
    if (converter != null) {
      return converter.convertRequest(request);
    }

    return request;
  }

  Future<Response<Body>> _decodeResponse<Body, Item>(
    Response response,
    Converter withConverter,
  ) async {
    if (withConverter == null) return response;

    final converted = await withConverter.convertResponse<Body, Item>(response);

    if (converted == null) {
      throw Exception("No converter found for type $Item");
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

  Future<Response<Body>> send<Body, Item>(
    Request request, {
    ConvertRequest requestConverter,
    ConvertResponse responseConverter,
  }) async {
    Request req = request;

    if (req.body != null || req.parts.isNotEmpty) {
      if (requestConverter != null) {
        req = await requestConverter(request);
      } else {
        req = await _encodeRequest(request);
      }
    }

    req = await _interceptRequest(req);

    _requestController.add(req);
    final stream = await httpClient.send(await req.toBaseRequest());

    final response = await http.Response.fromStream(stream);
    Response res = Response(response, response.body);

    if (res.isSuccessful) {
      if (responseConverter != null) {
        res = await responseConverter(res);
      } else {
        res = await _decodeResponse<Body, Item>(res, converter);
      }
    } else if (errorConverter != null) {
      res = await errorConverter.convertError<Body, Item>(res);
    }

    res = await _interceptResponse(res);

    if (!res.isSuccessful) {
      _responseErrorController.add(res);
      throw res;
    }
    _responseController.add(res);

    return res;
  }

  Future<Response<ResultType>> get<ResultType, ItemType>(
    String url, {
    Map<String, String> headers,
  }) =>
      send<ResultType, ItemType>(
        Request(
          HttpMethod.Get,
          url,
          baseUrl,
          headers: headers,
        ),
      );

  Future<Response<ResultType>> post<ResultType, ItemType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send<ResultType, ItemType>(
        Request(
          HttpMethod.Post,
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<ResultType>> put<ResultType, ItemType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send<ResultType, ItemType>(
        Request(
          HttpMethod.Put,
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<ResultType>> patch<ResultType, ItemType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send<ResultType, ItemType>(
        Request(
          HttpMethod.Patch,
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Future<Response<ResultType>> delete<ResultType, ItemType>(
    String url, {
    Map<String, String> headers,
  }) =>
      send<ResultType, ItemType>(
        Request(
          HttpMethod.Delete,
          url,
          baseUrl,
          headers: headers,
        ),
      );

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
