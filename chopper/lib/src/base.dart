import 'dart:async';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

import 'interceptor.dart';
import 'request.dart';
import 'response.dart';
import 'annotations.dart';
import 'utils.dart';

Type _typeOf<T>() => T;

@visibleForTesting
final allowedInterceptorsType = <Type>[
  RequestInterceptor,
  RequestInterceptorFunc,
  ResponseInterceptor,
  ResponseInterceptorFunc1,
  ResponseInterceptorFunc2,
  DynamicResponseInterceptorFunc,
];

/// ChopperClient is the main class of the Chopper API
/// Used to manager services, encode data, intercept request, response and error.
class ChopperClient {
  /// Base url of each request to your api
  /// hostname of your api for example
  final String baseUrl;

  /// Http client used to do request
  /// from `package:http/http.dart`
  final http.Client httpClient;

  /// Converter call before request interceptor
  /// and before interceptor of successful response
  final Converter converter;

  /// Converter call on error request
  final ErrorConverter errorConverter;

  final Map<Type, ChopperService> _services = {};
  final _requestInterceptors = [];
  final _responseInterceptors = [];
  final _requestController = StreamController<Request>.broadcast();
  final _responseController = StreamController<Response>.broadcast();

  final bool _clientIsInternal;

  /// Inject any service using the [services] parameter.
  /// See [ChopperApi] annotation to define a service.
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     baseUrl: 'localhost:8000',
  ///     services: [
  ///       // inject the generated service
  ///       TodosListService.create()
  ///     ],
  ///   );
  /// ```
  ///
  /// Interceptors can be use to apply modification or log infos for each
  /// requests and responsed happening in that client.
  /// See [ResponseInterceptor] and [RequestInterceptor]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     ...
  ///     interceptors: [
  ///       HttpLoggingInterceptor(),
  ///     ]
  ///   );
  /// ```
  ///
  /// [Converter] is used to apply modification on the body of a request/response
  /// like converting an object to json (or json to object).
  /// A different converter is used when an error is happening ([Response.isSuccessful] == false)
  /// See [JsonConverter]
  ///
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     ...
  ///     converter: JsonConverter(),
  ///     errorConverter: JsonConverter(),
  ///   );
  /// ```
  ChopperClient({
    this.baseUrl = '',
    http.Client client,
    Iterable interceptors = const [],
    this.converter,
    this.errorConverter,
    Iterable<ChopperService> services = const [],
  })  : httpClient = client ?? http.Client(),
        _clientIsInternal = client == null {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw ArgumentError(
        'Unsupported type for interceptors, it only support the following types:\n'
        '${allowedInterceptorsType.join('\n - ')}',
      );
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
      value is ResponseInterceptor ||
      value is ResponseInterceptorFunc1 ||
      value is ResponseInterceptorFunc2 ||
      value is DynamicResponseInterceptorFunc;

  bool _isAnInterceptor(value) =>
      _isResponseInterceptor(value) || _isRequestInterceptor(value);

  /// Retrieve any service injected into the [ChopperClient]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     baseUrl: 'localhost:8000',
  ///     services: [
  ///       // inject the generated service
  ///       TodosListService.create()
  ///     ],
  ///   );
  ///
  /// final todoService = chopper.getService<TodosListService>();
  /// ```
  ServiceType getService<ServiceType extends ChopperService>() {
    final serviceType = _typeOf<ServiceType>();
    if (serviceType == dynamic || serviceType == ChopperService) {
      throw Exception(
          'Service type should be provided, `dynamic` is not allowed.');
    }
    final service = _services[serviceType];
    if (service == null) {
      throw Exception('Service of type \'$serviceType\' not found.');
    }
    return service;
  }

  Future<Request> _encodeRequest(Request request) async {
    if (converter != null) {
      return converter.convertRequest(request);
    }

    return request;
  }

  Future<Response<BodyType>> _decodeResponse<BodyType, InnerType>(
    Response response,
    Converter withConverter,
  ) async {
    final converted =
        await withConverter.convertResponse<BodyType, InnerType>(response);

    if (converted == null) {
      throw Exception('No converter found for type $InnerType');
    }

    return converted;
  }

  Future<Request> _interceptRequest(Request req) async {
    final body = req.body;
    for (final i in _requestInterceptors) {
      if (i is RequestInterceptor) {
        req = await i.onRequest(req);
      } else if (i is RequestInterceptorFunc) {
        req = await i(req);
      }
    }

    assert(req != null, 'Interceptors should return modified request');

    assert(
      body == req.body,
      'Interceptors should not transform the body of the request'
      'Use Request converter instead',
    );
    return req;
  }

  Future<Response<BodyType>> _interceptResponse<BodyType, InnerType>(
    Response<BodyType> res,
  ) async {
    final body = res.body;
    for (final i in _responseInterceptors) {
      if (i is ResponseInterceptor) {
        res = await i.onResponse(res);
      } else if (i is ResponseInterceptorFunc1) {
        res = await i<BodyType>(res);
      } else if (i is ResponseInterceptorFunc2) {
        res = await i<BodyType, InnerType>(res);
      } else if (i is DynamicResponseInterceptorFunc) {
        res = await i(res);
      }
    }

    assert(res != null, 'Interceptors should return modified response');

    assert(
      body == res.body,
      'Interceptors should not transform the body of the response'
      'Use Response converter instead',
    );

    return res;
  }

  Future<Response<BodyType>> _handleErrorResponse<BodyType, InnerType>(
    Response response,
  ) async {
    var error = response.body;
    if (errorConverter != null) {
      final errorRes = await errorConverter.convertError<BodyType, InnerType>(
        response,
      );
      error = errorRes.error ?? errorRes.body;
    }

    return Response<BodyType>(
      response.base,
      null,
      error: error,
    );
  }

  Future<Response<BodyType>> _handleSuccessResponse<BodyType, InnerType>(
    Response response,
    ConvertResponse responseConverter,
  ) async {
    if (responseConverter != null) {
      response = await responseConverter(response);
    } else if (converter != null) {
      response =
          await _decodeResponse<BodyType, InnerType>(response, converter);
    }

    return Response<BodyType>(
      response.base,
      response.body,
    );
  }

  Future<Request> _handleRequestConverter(
    Request request,
    ConvertRequest requestConverter,
  ) async {
    if (request.body != null || request.parts.isNotEmpty) {
      if (requestConverter != null) {
        request = await requestConverter(request);
      } else {
        request = await _encodeRequest(request);
      }
    }

    return request;
  }

  /// Send request function that apply all interceptors and converters
  ///
  /// [BodyType] is the expected type of your response
  /// ex: `String` or `CustomObject`
  ///
  /// In the case of [BodyType] is a `List` or `BuildList`
  /// [InnerType] will be the type of the generic
  ///
  /// ```dart
  /// Response<List<CustomObject>> res = await send<List<CustomObject>, CustomObject>(request);
  /// ````
  Future<Response<BodyType>> send<BodyType, InnerType>(
    Request request, {
    ConvertRequest requestConverter,
    ConvertResponse responseConverter,
  }) async {
    var req = await _handleRequestConverter(request, requestConverter);
    req = await _interceptRequest(req);
    _requestController.add(req);

    final streamRes = await httpClient.send(await req.toBaseRequest());
    if (isTypeOf<BodyType, Stream<List<int>>>()) {
      return Response(streamRes, (streamRes.stream) as BodyType);
    }

    final response = await http.Response.fromStream(streamRes);
    dynamic res = Response(response, response.body);

    if (_responseIsSuccessful(response.statusCode)) {
      res = await _handleSuccessResponse<BodyType, InnerType>(
        res,
        responseConverter,
      );
    } else {
      res = await _handleErrorResponse<BodyType, InnerType>(res);
    }

    res = await _interceptResponse<BodyType, InnerType>(res);

    _responseController.add(res);

    return res;
  }

  /// Http GET request using [send] function
  Future<Response<BodyType>> get<BodyType, InnerType>(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Get,
          url,
          baseUrl ?? this.baseUrl,
          headers: headers,
          parameters: parameters,
        ),
      );

  /// Http POST request using [send] function
  Future<Response<BodyType>> post<BodyType, InnerType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    bool multipart,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Post,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          multipart: multipart,
          parameters: parameters,
        ),
      );

  /// Http PUT request using [send] function
  Future<Response<BodyType>> put<BodyType, InnerType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    bool multipart,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Put,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          multipart: multipart,
          parameters: parameters,
        ),
      );

  /// Http PATCH request using [send] function
  Future<Response<BodyType>> patch<BodyType, InnerType>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    bool multipart,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Patch,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          multipart: multipart,
          parameters: parameters,
        ),
      );

  /// Http DELETE request using [send] function
  Future<Response<BodyType>> delete<BodyType, InnerType>(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Delete,
          url,
          baseUrl ?? this.baseUrl,
          headers: headers,
          parameters: parameters,
        ),
      );

  /// Http Head request using [send] function
  Future<Response<BodyType>> head<BodyType, InnerType>(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> parameters,
    String baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Head,
          url,
          baseUrl ?? this.baseUrl,
          headers: headers,
          parameters: parameters,
        ),
      );

  /// dispose [ChopperClient] to clean memory.
  ///
  /// It won't close the http client if you provided it in the [ChopperClient] constructor.
  @mustCallSuper
  void dispose() {
    _requestController.close();
    _responseController.close();

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
}

/// Used by generator to generate apis
abstract class ChopperService {
  ChopperClient client;

  /// Internally use to retrieve service from [ChopperClient]
  /// FIXME: use runtimeType ?
  Type get definitionType;

  /// Cleanup memory
  /// Should be call when the service is not used anymore
  @mustCallSuper
  void dispose() {
    client = null;
  }
}

bool _responseIsSuccessful(int statusCode) =>
    statusCode >= 200 && statusCode < 300;
