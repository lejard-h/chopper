import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:chopper_example/json_serializable.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Simple client to have working example without remote server
final client = MockClient((req) async {
  if (req.method == 'POST') {
    return http.Response('{"type":"Fatal","message":"fatal erorr"}', 500);
  }
  if (req.method == 'GET' && req.headers['test'] == 'list') {
    return http.Response('[{"id":"1","name":"Foo"}]', 200);
  }

  return http.Response('{"id":"1","name":"Foo"}', 200);
});

main() async {
  final converter = JsonSerializableConverter({
    Resource: Resource.fromJsonFactory,
  });

  final chopper = ChopperClient(
    client: client,
    baseUrl: Uri.parse('http://localhost:8000'),
    // bind your object factories here
    converter: converter,
    errorConverter: converter,
    services: [
      // the generated service
      MyService.create(),
    ],
    /* Interceptors */
    interceptors: [AuthInterceptor()],
  );

  final myService = chopper.getService<MyService>();

  final response1 = await myService.getResource('1');
  print('response 1: ${response1.body}'); // undecoded String

  final response2 = await myService.getResources();
  print('response 2: ${response2.body}'); // decoded list of Resources

  final response3 = await myService.getTypedResource();
  print('response 3: ${response3.body}'); // decoded Resource

  final response4 = await myService.getMapResource('1');
  print('response 4: ${response4.body}'); // undecoded Resource

  try {
    await myService.newResource(Resource('3', 'Super Name'));
  } on Response catch (error) {
    print(error.body);
  }
}

class AuthInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    return chain.proceed(
      applyHeader(
        chain.request,
        'Authorization',
        '42',
      ),
    );
  }
}

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  final Map<Type, JsonFactory> factories;

  const JsonSerializableConverter(this.factories);

  T? _decodeMap<T>(Map<String, dynamic> values) {
    /// Get jsonFactory using Type parameters
    /// if not found or invalid, throw error or return null
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
      /// throw serializer not found error;
      return null;
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => _decode<T>(v)).toList();

  dynamic _decode<T>(entity) {
    if (entity is Iterable) return _decodeList<T>(entity as List);

    if (entity is Map) return _decodeMap<T>(entity as Map<String, dynamic>);

    return entity;
  }

  @override
  FutureOr<Response<ResultType>> convertResponse<ResultType, Item>(
    Response response,
  ) async {
    // use [JsonConverter] to decode json
    final jsonRes = await super.convertResponse(response);

    return jsonRes.copyWith<ResultType>(body: _decode<Item>(jsonRes.body));
  }

  @override
  // all objects should implements toJson method
  // ignore: unnecessary_overrides
  Request convertRequest(Request request) => super.convertRequest(request);

  @override
  FutureOr<Response> convertError<ResultType, Item>(Response response) async {
    // use [JsonConverter] to decode json
    final jsonRes = await super.convertError(response);

    return jsonRes.copyWith<ResourceError>(
      body: ResourceError.fromJsonFactory(jsonRes.body),
    );
  }
}
