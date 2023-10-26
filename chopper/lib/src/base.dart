import 'dart:async';

import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/authenticator.dart';
import 'package:chopper/src/constants.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@visibleForTesting
const List<Type> allowedInterceptorsType = [
  RequestInterceptor,
  RequestInterceptorFunc,
  ResponseInterceptor,
  ResponseInterceptorFunc1,
  ResponseInterceptorFunc2,
  DynamicResponseInterceptorFunc,
];

/// ChopperClient is the main class of the Chopper API.
///
/// It manages registered services, encodes and decodes data, and intercepts
/// requests and responses.
base class ChopperClient {
  /// Base URL of each request of the registered services.
  /// E.g., the hostname of your service.
  final Uri baseUrl;

  /// The [http.Client] used to make network calls.
  final http.Client httpClient;

  /// The [Converter] that handles request and response transformation before
  /// the request and response interceptors are called respectively.
  final Converter? converter;

  /// The [Authenticator] that can provide reactive authentication for a
  /// request.
  final Authenticator? authenticator;

  /// The [ErrorConverter] that handles response transformation before the
  /// response interceptors are called, but only on error responses
  /// (statusCode < 200 || statusCode >= 300\).
  final ErrorConverter? errorConverter;

  late final Map<Type, ChopperService> _services;
  late final List _requestInterceptors;
  late final List _responseInterceptors;
  final StreamController<Request> _requestController =
      StreamController<Request>.broadcast();
  final StreamController<Response> _responseController =
      StreamController<Response>.broadcast();

  final bool _clientIsInternal;

  /// Creates and configures a [ChopperClient].
  ///
  /// The base URL of each request of the registered services can be defined
  /// with the [baseUrl] parameter.
  ///  E.g., the hostname of your service.
  ///  If not provided, a empty default [Uri] will be used.
  ///
  /// A custom HTTP client can be passed as the [client] parameter to be used
  /// with the created [ChopperClient].
  /// If not provided, a default [http.Client] will be used.
  ///
  /// [ChopperService]s can be added to the client with the [services] parameter.
  /// See the [ChopperApi] annotation to learn more about creating services.
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///   baseUrl: Uri.parse('localhost:8000'),
  ///   services: [
  ///     // Add a generated service
  ///     TodosListService.create()
  ///   ],
  /// );
  /// ```
  ///
  /// [RequestInterceptor]s and [ResponseInterceptor]s can be added to the client
  /// with the [interceptors] parameter.
  ///
  /// See [RequestInterceptor], [ResponseInterceptor], [HttpLoggingInterceptor],
  /// [HeadersInterceptor], [CurlInterceptor]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///   ...
  ///   interceptors: [
  ///     HttpLoggingInterceptor(),
  ///   ]
  /// );
  /// ```
  ///
  /// [Converter]s can be added to the client with the [converter]
  /// parameter.
  /// [Converter]s are used to convert the body of requests and responses to and
  /// from the HTTP format.
  ///
  /// A different converter can be used to handle error responses
  /// (when [Response.isSuccessful] == false)) with tche [errorConverter] parameter.
  ///
  /// See [Converter], [JsonConverter]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     ...
  ///     converter: JsonConverter(),
  ///     errorConverter: JsonConverter(),
  ///   );
  /// ```
  ChopperClient({
    Uri? baseUrl,
    http.Client? client,
    Iterable? interceptors,
    this.authenticator,
    this.converter,
    this.errorConverter,
    Iterable<ChopperService>? services,
  })  : assert(
          baseUrl == null || !baseUrl.hasQuery,
          'baseUrl should not contain query parameters. '
          'Use a request interceptor to add default query parameters',
        ),
        baseUrl = baseUrl ?? Uri(),
        httpClient = client ?? http.Client(),
        _clientIsInternal = client == null,
        assert(
          interceptors?.every(_isAnInterceptor) ?? true,
          'Unsupported type for interceptors, it only support the following types:\n'
          ' - ${allowedInterceptorsType.join('\n - ')}',
        ),
        _requestInterceptors = [
          ...?interceptors?.where(_isRequestInterceptor),
        ],
        _responseInterceptors = [
          ...?interceptors?.where(_isResponseInterceptor),
        ] {
    _services = <Type, ChopperService>{
      for (final ChopperService service in services?.toSet() ?? [])
        service.definitionType: service..client = this
    };
  }

  static bool _isRequestInterceptor(value) =>
      value is RequestInterceptor || value is RequestInterceptorFunc;

  static bool _isResponseInterceptor(value) =>
      value is ResponseInterceptor ||
      value is ResponseInterceptorFunc1 ||
      value is ResponseInterceptorFunc2 ||
      value is DynamicResponseInterceptorFunc;

  static bool _isAnInterceptor(value) =>
      _isResponseInterceptor(value) || _isRequestInterceptor(value);

  /// Retrieve any service included in the [ChopperClient]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///   baseUrl: Uri.parse('localhost:8000'),
  ///   services: [
  ///     // Add a generated service
  ///     TodosListService.create()
  ///   ],
  /// );
  ///
  /// final todoService = chopper.getService<TodosListService>();
  /// ```
  ServiceType getService<ServiceType extends ChopperService>() {
    if (ServiceType == dynamic || ServiceType == ChopperService) {
      throw Exception(
        'Service type should be provided, `dynamic` is not allowed.',
      );
    }
    final ChopperService? service = _services[ServiceType];
    if (service == null) {
      throw Exception("Service of type '$ServiceType' not found.");
    }

    return service as ServiceType;
  }

  Future<Request> _encodeRequest(Request request) async =>
      converter?.convertRequest(request) ?? request;

  static Future<Response<BodyType>> _decodeResponse<BodyType, InnerType>(
    Response response,
    Converter withConverter,
  ) async =>
      await withConverter.convertResponse<BodyType, InnerType>(response);

  Future<Request> _interceptRequest(Request req) async {
    final body = req.body;
    for (final i in _requestInterceptors) {
      if (i is RequestInterceptor) {
        req = await i.onRequest(req);
      } else if (i is RequestInterceptorFunc) {
        req = await i(req);
      }
    }

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
        res = await i.onResponse(res) as Response<BodyType>;
      } else if (i is ResponseInterceptorFunc1) {
        res = await i<BodyType>(res);
      } else if (i is ResponseInterceptorFunc2) {
        res = await i<BodyType, InnerType>(res);
      } else if (i is DynamicResponseInterceptorFunc) {
        res = await i(res) as Response<BodyType>;
      }
    }

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
      final errorRes = await errorConverter?.convertError<BodyType, InnerType>(
        response,
      );
      error = errorRes?.error ?? errorRes?.body;
    }

    return Response<BodyType>(response.base, null, error: error);
  }

  Future<Response<BodyType>> _handleSuccessResponse<BodyType, InnerType>(
    Response response,
    ConvertResponse? responseConverter,
  ) async {
    if (responseConverter != null) {
      response = await responseConverter(response);
    } else if (converter != null) {
      response =
          await _decodeResponse<BodyType, InnerType>(response, converter!);
    }

    return Response<BodyType>(
      response.base,
      response.body,
    );
  }

  Future<Request> _handleRequestConverter(
    Request request,
    ConvertRequest? requestConverter,
  ) async =>
      request.body != null || request.parts.isNotEmpty
          ? requestConverter != null
              ? await requestConverter(request)
              : await _encodeRequest(request)
          : request;

  /// Sends a pre-build [Request], applying all provided [Interceptor]s and
  /// [Converter]s.
  ///
  /// [BodyType] should be the expected type of the response body
  /// (e.g., `String` or `CustomObject)`.
  ///
  /// If `BodyType` is a `List` or a `BuiltList`, [InnerType] should be type of the
  /// generic parameter (e.g., `convertResponse<List<CustomObject>, CustomObject>(response)`).
  ///
  /// ```dart
  /// Response<List<CustomObject>> res = await send<List<CustomObject>, CustomObject>(request);
  /// ````
  Future<Response<BodyType>> send<BodyType, InnerType>(
    Request request, {
    ConvertRequest? requestConverter,
    ConvertResponse? responseConverter,
  }) async {
    final Request req = await _interceptRequest(
      await _handleRequestConverter(request, requestConverter),
    );

    _requestController.add(req);

    final streamRes = await httpClient.send(await req.toBaseRequest());
    if (isTypeOf<BodyType, Stream<List<int>>>()) {
      return Response(streamRes, (streamRes.stream) as BodyType);
    }

    final response = await http.Response.fromStream(streamRes);
    dynamic res = Response(response, response.body);

    if (authenticator != null) {
      final Request? updatedRequest =
          await authenticator!.authenticate(req, res, request);

      if (updatedRequest != null) {
        res = await send<BodyType, InnerType>(
          updatedRequest,
          requestConverter: requestConverter,
          responseConverter: responseConverter,
        );
        // To prevent double call with typed response
        if (_responseIsSuccessful(res.statusCode)) {
          await authenticator!
              .onAuthenticationSuccessful(updatedRequest, res, request);
          return _processResponse(res);
        } else {
          res = await _handleErrorResponse<BodyType, InnerType>(res);
          await authenticator!
              .onAuthenticationFailed(updatedRequest, res, request);
          return _processResponse(res);
        }
      }
    }

    res = _responseIsSuccessful(res.statusCode)
        ? await _handleSuccessResponse<BodyType, InnerType>(
            res,
            responseConverter,
          )
        : await _handleErrorResponse<BodyType, InnerType>(res);

    return _processResponse(res);
  }

  Future<Response<BodyType>> _processResponse<BodyType, InnerType>(
    dynamic res,
  ) async {
    res = await _interceptResponse<BodyType, InnerType>(res);
    _responseController.add(res);

    return res;
  }

  /// Makes a HTTP GET request using the [send] function.
  Future<Response<BodyType>> get<BodyType, InnerType>(
    Uri url, {
    Map<String, String> headers = const {},
    Uri? baseUrl,
    Map<String, dynamic> parameters = const {},
    dynamic body,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Get,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          headers: headers,
          parameters: parameters,
        ),
      );

  /// Makes a HTTP POST request using the [send] function
  Future<Response<BodyType>> post<BodyType, InnerType>(
    Uri url, {
    dynamic body,
    List<PartValue> parts = const [],
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    bool multipart = false,
    Uri? baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Post,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          parameters: parameters,
          multipart: multipart,
        ),
      );

  /// Makes a HTTP PUT request using the [send] function.
  Future<Response<BodyType>> put<BodyType, InnerType>(
    Uri url, {
    dynamic body,
    List<PartValue> parts = const [],
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    bool multipart = false,
    Uri? baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Put,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          parameters: parameters,
          multipart: multipart,
        ),
      );

  /// Makes a HTTP PATCH request using the [send] function.
  Future<Response<BodyType>> patch<BodyType, InnerType>(
    Uri url, {
    dynamic body,
    List<PartValue> parts = const [],
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    bool multipart = false,
    Uri? baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Patch,
          url,
          baseUrl ?? this.baseUrl,
          body: body,
          parts: parts,
          headers: headers,
          parameters: parameters,
          multipart: multipart,
        ),
      );

  /// Makes a HTTP DELETE request using the [send] function.
  Future<Response<BodyType>> delete<BodyType, InnerType>(
    Uri url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    Uri? baseUrl,
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

  /// Makes a HTTP HEAD request using the [send] function.
  Future<Response<BodyType>> head<BodyType, InnerType>(
    Uri url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    Uri? baseUrl,
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

  /// Makes a HTTP OPTIONS request using the [send] function.
  Future<Response<BodyType>> options<BodyType, InnerType>(
    Uri url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> parameters = const {},
    Uri? baseUrl,
  }) =>
      send<BodyType, InnerType>(
        Request(
          HttpMethod.Options,
          url,
          baseUrl ?? this.baseUrl,
          headers: headers,
          parameters: parameters,
        ),
      );

  /// Disposes this [ChopperClient] to clean up memory.
  ///
  /// **Warning**: If a custom [http.Client] was provided while creating this `ChopperClient`,
  /// this method ***will not*** close it. In that case, closing the client is
  /// its creator's responsibility.
  @mustCallSuper
  void dispose() {
    _requestController.close();
    _responseController.close();
    _services.clear();

    _requestInterceptors.clear();
    _responseInterceptors.clear();

    if (_clientIsInternal) {
      httpClient.close();
    }
  }

  /// A stream of processed [Request]s, as in after all [Converter]s, and
  /// [RequestInterceptor]s have been run.
  Stream<Request> get onRequest => _requestController.stream;

  /// A stream of processed [Response]s, as in after all [Converter]s and
  /// [ResponseInterceptor]s have been run.
  Stream<Response> get onResponse => _responseController.stream;
}

/// A marker and helper class used by `chopper_generator` to generate network
/// call implementations.
///
///```dart
///@ChopperApi(baseUrl: "/todos")
///abstract class TodosListService extends ChopperService {
///
/// // A helper method that helps instantiating your service
/// static TodosListService create([ChopperClient client]) =>
///     _$TodosListService(client);
///}
///```
abstract class ChopperService {
  late ChopperClient client;

  /// Used internally to retrieve the service from [ChopperClient].
  // TODO: use runtimeType
  Type get definitionType;
}

bool _responseIsSuccessful(int statusCode) =>
    statusCode >= 200 && statusCode < 300;
