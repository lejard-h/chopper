# chopper

Chopper is an http client generator using source_gen and inspired from Retrofit.

## Usage

### Generator

Add the generator to your dev dependencies

```yaml
dev_dependencies:
  build_runner: ^0.8.0
  chopper_generator: ^0.0.1
```

### Define and Generate your API

```dart
// my_service.dart

import "dart:async";
import 'package:chopper/chopper.dart';

part "my_service.g.dart";

@ServiceDefinition("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
  @Get(url: "/{id}")
  Future<Response> getResource(@Path() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(@Query() String id);
}
```

then run the generator

`pub run build_runner build`

### Use it

Create a Chopper client and inject your generated api.

```dart
final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    converter: const JsonConverter(),
    services: [
      // the generated service
      new MyService()
    ],
    interceptors: [
      new Headers(const {"Content-Type": "application/json"}),
    ]);

final myService = chopper.service(MyService) as MyService;

final response = await myService.getMapResource("1");
```

## [More example](https://github.com/lejard-h/chopper/tree/master/example)
## [Issue Tracker](https://github.com/lejard-h/chopper/issues)