# FAQ

## \*.chopper.dart not found ?

If you have this error, you probably forgot to run the `build` package. To do that, simply run the following command in your shell.

`pub run build_runner build`

It will generate the code that actually do the HTTP request \(YOUR_FILE.chopper.dart\). If you wish to update the code automatically when you change your definition run the `watch` command.

`pub run build_runner watch`

## How to increase timeout ?

Connection timeout is very limited for now due to http package \(see: [dart-lang/http\#21](https://github.com/dart-lang/http/issues/21)\)

But if you are on VM or Flutter you can set the `connectionTimeout` you want

```dart
import 'package:http/io_client.dart' as http;
import 'dart:io';

final chopper = ChopperClient(
    client: http.IOClient(
      HttpClient()..connectionTimeout = const Duration(seconds: 60),
    ),
  );
```

## Add query parameter to all requests

Possible using an interceptor.

```dart
final chopper = ChopperClient(
    interceptors: [_addQuery],
);

Request _addQuery(Request req) {
  final params = Map<String, dynamic>.from(req.parameters);
  params['key'] = '123';

  return req.copyWith(parameters: params);
}
```

## GZip converter example

You can use converters for modifying requests and responses.
For example, to use GZip for post request you can write something like this:

```dart
Request compressRequest(Request request) {
  request = applyHeader(request, 'Content-Encoding', 'gzip');
  request = request.replace(body: gzip.encode(request.body));
  return request;
}
...

@FactoryConverter(request: compressRequest)
@Post()
Future<Response> postRequest(@Body() Map<String, String> data);
```

## Runtime baseUrl change

You may need to change the base URL of your network calls during runtime, for example, if you have to use different servers or routes dynamically in your app in case of a "regular" or a "paid" user. You can store the current server base url in your SharedPreferences (encrypt/decrypt it if needed) and use it in an interceptor like this:

```dart
...
(Request request) async =>
              SharedPreferences.containsKey('baseUrl')
                  ? request.copyWith(
                      baseUrl: SharedPreferences.getString('baseUrl'))
                  : request
...
```

## Mock ChopperClient for testing

Chopper is built on top of `http` package.

So, one can just use the mocking API of the HTTP package.
https://pub.dev/documentation/http/latest/testing/MockClient-class.html

Also, you can follow this code by [ozburo](https://github.com/ozburo):

```dart
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

part 'api_service.chopper.dart';

@ChopperApi()
abstract class ApiService extends ChopperService {
  static ApiService create() {
    final client = ChopperClient(
      client: MockClient((request) async {
        Map result = mockData[request.url.path]?.firstWhere((mockQueryParams) {
          if (mockQueryParams['id'] == request.url.queryParameters['id']) return true;
          return false;
        }, orElse: () => null);
        if (result == null) {
          return http.Response(
              json.encode({'error': "not found"}), 404);
        }
        return http.Response(json.encode(result), 200);
      }),
      baseUrl: 'https://mysite.com/api',
      services: [
        _$ApiService(),
      ],
      converter: JsonConverter(),
      errorConverter: JsonConverter(),
    );
    return _$ApiService(client);
  }

  @Get(path: "/get")
  Future<Response> get(@Query() String url);
}
```

## Use Https certificate

Chopper is built on top of `http` package and you can override the inner http client.

```dart
import 'dart:io';
import 'package:http/io_client.dart' as http;

final ioc = new HttpClient();
ioc.findProxy = (url) => 'PROXY 192.168.0.102:9090';
ioc.badCertificateCallback = (X509Certificate cert, String host, int port)
  => true;

final chopper = ChopperClient(
  client: http.IOClient(ioc),
);
```

## Authorized HTTP requests

Basically, the algorithm goes like this (credits to [stewemetal](https://github.com/stewemetal)):

Add the authentication token to the request (by "Authorization" header, for example) -> try the request -> if it fails use the refresh token to get a new auth token ->
if that succeeds, save the auth token and retry the original request with it
if the refresh token is not valid anymore, drop the session (and navigate to the login screen, for example)

Simple code example:

```dart
interceptors: [
  // Auth Interceptor
  (Request request) async => applyHeader(request, 'authorization',
      SharedPrefs.localStorage.getString(tokenHeader),
      override: false),
  (Response response) async {
    if (response?.statusCode == 401) {
      SharedPrefs.localStorage.remove(tokenHeader);
      // Navigate to some login page or just request new token
    }
    return response;
  },
]
```

The actual implementation of the algorithm above may vary based on how the backend API - more precisely the login and session handling - of your app looks like.

## Decoding JSON using Isolates

Sometimes you want to decode JSON outside the main thread in order to reduce janking. In this example we're going to go
even further and implement a Worker Pool using [Squadron](https://pub.dev/packages/squadron/install) which can 
dynamically spawn a maximum number of Workers as they become needed.

#### Install the dependencies

- [squadron](https://pub.dev/packages/squadron)
- [squadron_builder](https://pub.dev/packages/squadron_builder)
- [json_annotation](https://pub.dev/packages/json_annotation)
- [json_serializable](https://pub.dev/packages/json_serializable)

#### Write a JSON decode service

We'll leverage [squadron_builder](https://pub.dev/packages/squadron_builder) and the power of code generation.

```dart
import 'dart:async';
import 'dart:convert' show json;

import 'package:squadron/squadron.dart';
import 'package:squadron/squadron_annotations.dart';

import 'json_decode_service.activator.g.dart';

part 'json_decode_service.worker.g.dart';

@SquadronService()
class JsonDecodeService extends WorkerService with $JsonDecodeServiceOperations {
  @SquadronMethod()
  Future<dynamic> jsonDecode(String source) async => json.decode(source);
}
```

Extracted from the [full example here](example/lib/json_decode_service.dart).

#### Write a custom JsonConverter

Using [json_serializable](https://pub.dev/packages/json_serializable) we'll create a [JsonConverter](https://github.com/lejard-h/chopper/blob/master/chopper/lib/src/interceptor.dart#L228) 
which works with or without a [WorkerPool](https://github.com/d-markey/squadron#features).

```dart
import 'dart:async' show FutureOr;
import 'dart:convert' show jsonDecode;

import 'package:chopper/chopper.dart';
import 'package:chopper_example/json_decode_service.dart';
import 'package:chopper_example/json_serializable.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class JsonSerializableWorkerPoolConverter extends JsonConverter {
  const JsonSerializableWorkerPoolConverter(this.factories, [this.workerPool]);

  final Map<Type, JsonFactory> factories;
  
  /// Make the WorkerPool optional so that the JsonConverter still works without it
  final JsonDecodeServiceWorkerPool? workerPool;

  /// By overriding tryDecodeJson we give our JsonConverter 
  /// the ability to decode JSON in an Isolate.
  @override
  FutureOr<dynamic> tryDecodeJson(String data) async {
    try {
      return workerPool != null
          ? await workerPool!.jsonDecode(data)
          : jsonDecode(data);
    } catch (error) {
      print(error);

      chopperLogger.warning(error);

      return data;
    }
  }
  
  T? _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
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
    final jsonRes = await super.convertResponse(response);

    return jsonRes.copyWith<ResultType>(body: _decode<Item>(jsonRes.body));
  }

  @override
  FutureOr<Response> convertError<ResultType, Item>(Response response) async {
    final jsonRes = await super.convertError(response);

    return jsonRes.copyWith<ResourceError>(
      body: ResourceError.fromJsonFactory(jsonRes.body),
    );
  }
}
```

Extracted from the [full example here](example/bin/main_json_serializable_squadron_worker_pool.dart).

#### Code generation

It goes without saying that running the code generation is a pre-requisite at this stage

```bash
flutter pub run build_runner build
```

#### Configure a WorkerPool and run the example

```dart
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

  /// Instantiate the JsonConverter from above
  final converter = JsonSerializableWorkerPoolConverter(
    {
      Resource: Resource.fromJsonFactory,
    },
    /// make sure to provide the WorkerPool to the JsonConverter
    jsonDecodeServiceWorkerPool,
  );

  /// Instantiate a ChopperClient
  final chopper = ChopperClient(
    client: client,
    baseUrl: 'http://localhost:8000',
    // bind your object factories here
    converter: converter,
    errorConverter: converter,
    services: [
      // the generated service
      MyService.create(),
    ],
    /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
    interceptors: [authHeader],
  );

  /// Do stuff with myService
  final myService = chopper.getService<MyService>();
  
  /// ...stuff...

  /// stop the Worker Pool once done
  jsonDecodeServiceWorkerPool.stop();
}
```

[The full example can be found here](example/bin/main_json_serializable_squadron_worker_pool.dart).

#### Further reading

This barely scratches the surface. If you want to know more about [squadron](https://github.com/d-markey/squadron) and
[squadron_builder](https://github.com/d-markey/squadron_builder) make sure to head over to their respective repositories.

[David Markey](https://github.com/d-markey]), the author of squadron, was kind enough as to provide us with an [excellent Flutter example](https://github.com/d-markey/squadron_builder) using
both packages.