[![Build Status](https://travis-ci.org/lejard-h/chopper.svg?branch=master)](https://travis-ci.org/lejard-h/chopper)
[![Coverage Status](https://coveralls.io/repos/github/lejard-h/chopper/badge.svg?branch=master)](https://coveralls.io/github/lejard-h/chopper?branch=master)

Chopper is an http client generator using source_gen and inspired by Retrofit.

## Usage

### Generator

Add the generator to your dev dependencies

```yaml
dependencies:
  chopper: ^1.0.0

dev_dependencies:
  build_runner: ^0.8.0
  chopper_generator: ^1.0.0
```

### Define and Generate your API

```dart
// my_service.dart

import "dart:async";
import 'package:chopper/chopper.dart';

part "my_service.chopper.dart";

@ChopperApi("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
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

Create a Chopper client and inject your generated api.

```dart
import 'package:chopper/chopper.dart';

final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    services: [
      // the generated service
      MyService()
    ],
    jsonApi: true,
);

final myService = chopper.service<MyService>(MyService);

final response = await myService.getMapResource("1");

chopper.close();
```

Or instanciate your service with defined client

```dart
final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    jsonApi: true,
);

final service = MyService.withClient(chopper);

```

## More example

  - [Custom Converter](https://github.com/lejard-h/chopper/blob/master/example/bin/main_basic_converter.dart)
  - [Jaguar Serializer](https://github.com/lejard-h/chopper/blob/master/example/bin/main_jaguar_serializer.dart)
  
## [Issue Tracker](https://github.com/lejard-h/chopper/issues)
