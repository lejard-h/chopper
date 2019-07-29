[![Build Status](https://travis-ci.org/lejard-h/chopper.svg?branch=master)](https://travis-ci.org/lejard-h/chopper)
[![codecov](https://codecov.io/gh/lejard-h/chopper/branch/master/graph/badge.svg)](https://codecov.io/gh/lejard-h/chopper)

Chopper is an http client generator using source_gen and inspired by Retrofit.

## Usage

### Generator

Add the generator to your dev dependencies

```yaml
dependencies:
  chopper: ^[latest version]

dev_dependencies:
  build_runner: ^[latest version]
  chopper_generator: ^[latest version]
```

### Define and Generate your API

```dart
// my_service.dart

import "dart:async";
import 'package:chopper/chopper.dart';

part "my_service.chopper.dart";

@ChopperApi(baseUrl: "/resources")
abstract class MyService extends ChopperService {
  static MyService create([ChopperClient client]) => _$MyService(client);

  @Get(url: "{id}")
  Future<Response> getResource(@Path() String id);

  @Get(headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(@Query() String id);

  @Post(url: 'multi')
  @multipart
  Future<Response> postResources(
    @Part('1') Map a,
    @Part('2') Map b,
    @Part('3') String c,
  );

  @Post(url: 'file')
  @multipart
  Future<Response> postFile(
    @FileField('file') List<int> bytes,
  );
}
```

then run the generator

```
pub run build_runner build

#flutter
flutter packages pub run build_runner build
```

### Use it

```dart
final chopper = ChopperClient(
    baseUrl: "http://localhost:8000",
    services: [
      // the generated service
      MyService.create()
    ],
    converter: JsonConverter(),
  );

final myService = MyService.create(chopper);

final response = await myService.getMapResource("1");

chopper.close();

```

Or create a Chopper client and inject your generated api.

```dart
import 'package:chopper/chopper.dart';

final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    services: [
      // the generated service
      MyService.create()
    ],
    converter: JsonConverter(),
);

final myService = chopper.service<MyService>(MyService);
```

### Interceptors

#### Request
implement `RequestInterceptor` class or define function with following signature `FutureOr<Request> RequestInterceptorFunc(Request request)`

Request interceptor are called just before sending request

```dart
final chopper = new ChopperClient(
   interceptors: [
     (request) async => request.replace(body: {}),
   ]
);
```

#### Response
implement `ResponseInterceptor` class or define function with following signature `FutureOr<Response> ResponseInterceptorFunc(Response response)`

Called after successfull or failed request

```dart
final chopper = new ChopperClient(
   interceptors: [
     (response) async => response.replace(body: {}),
   ]
);
```

#### Converter

Converter is used to transform body, for example transforming a Dart object to a `Map<String, dynamic>`

Both `converter` and `errorConverter` are called before request and response intercptors.

`errorConverter` is called only on error response (statusCode < 200 || statusCode >= 300)

```dart
final chopper = new ChopperClient(
   converter: MyConverter(),
   errorConverter: MyErrorConverter()
);
```


## More example

  - [Json serializable](https://github.com/lejard-h/chopper/blob/master/example/bin/main_json_serializable.dart)
  - [Jaguar Serializer](https://github.com/lejard-h/chopper/blob/master/example/bin/main_jaguar_serializer.dart)
  - [Angular](https://github.com/lejard-h/chopper/blob/master/example/web/main.dart)
  
## [Issue Tracker](https://github.com/lejard-h/chopper/issues)
