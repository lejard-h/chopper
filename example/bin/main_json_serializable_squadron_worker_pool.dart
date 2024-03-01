/// This example uses
/// - https://github.com/google/json_serializable.dart
/// - https://github.com/d-markey/squadron
/// - https://github.com/d-markey/squadron_builder

import 'dart:async' show FutureOr;
import 'dart:convert' show jsonDecode;

import 'package:chopper/chopper.dart';
import 'package:chopper_example/json_decode_service.dart';
import 'package:chopper_example/json_serializable.dart';
import 'package:http/testing.dart';
import 'package:squadron/squadron.dart';
import 'package:http/http.dart' as http;

import 'main_json_serializable.dart' show AuthInterceptor;

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

/// This JsonConverter works with or without a WorkerPool
class JsonSerializableWorkerPoolConverter extends JsonConverter {
  const JsonSerializableWorkerPoolConverter(this.factories, [this.workerPool]);

  final Map<Type, JsonFactory> factories;
  final JsonDecodeServiceWorkerPool? workerPool;

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
  FutureOr<Response> convertError<ResultType, Item>(Response response) async {
    // use [JsonConverter] to decode json
    final jsonRes = await super.convertError(response);

    return jsonRes.copyWith<ResourceError>(
      body: ResourceError.fromJsonFactory(jsonRes.body),
    );
  }

  @override
  FutureOr<dynamic> tryDecodeJson(String data) async {
    try {
      // if there is a worker pool use it, otherwise run in the main thread
      return workerPool != null
          ? await workerPool!.jsonDecode(data)
          : jsonDecode(data);
    } catch (error) {
      print(error);

      chopperLogger.warning(error);

      return data;
    }
  }
}

/// Simple client to have working example without remote server
final client = MockClient((http.Request req) async {
  if (req.method == 'POST') {
    return http.Response('{"type":"Fatal","message":"fatal error"}', 500);
  }
  if (req.method == 'GET' && req.headers['test'] == 'list') {
    return http.Response('[{"id":"1","name":"Foo"}]', 200);
  }

  return http.Response('{"id":"1","name":"Foo"}', 200);
});

/// inspired by https://github.com/d-markey/squadron_sample/blob/main/lib/main.dart
void initSquadron(String id) {
  Squadron.setId(id);
  Squadron.setLogger(ConsoleSquadronLogger());
  Squadron.logLevel = SquadronLogLevel.all;
  Squadron.debugMode = true;
}

Future<void> main() async {
  /// initialize Squadron before using it
  initSquadron('worker_pool_example');

  final jsonDecodeServiceWorkerPool = JsonDecodeServiceWorkerPool(
    // Set whatever you want here
    concurrencySettings: ConcurrencySettings.oneCpuThread,
  );

  /// start the Worker Pool
  await jsonDecodeServiceWorkerPool.start();

  final converter = JsonSerializableWorkerPoolConverter(
    {
      Resource: Resource.fromJsonFactory,
    },
    // make sure to provide the WorkerPool to the JsonConverter
    jsonDecodeServiceWorkerPool,
  );

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
    /* Interceptor */
    interceptors: [AuthInterceptor()],
  );

  final myService = chopper.getService<MyService>();

  /// All of the calls below will use jsonDecode in an Isolate worker
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

  /// stop the Worker Pool
  jsonDecodeServiceWorkerPool.stop();
}
