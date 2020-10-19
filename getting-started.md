# Getting started

## How it works ?

Due to Dart limitation on Flutter and Web browser, Chopper does not use reflection but code generation with the help of the [build](https://pub.dev/packages/build) and [source\_gen](https://pub.dev/packages/source_gen) packages from the Dart Team.

## Installation

First you need to add `chopper` and `chopper_generator` to your project dependencies.

```yaml
# pubspec.yaml

dependencies:
  chopper: ^2.0.0

dev_dependencies:
  build_runner: ^1.0.0
  chopper_generator: ^2.0.0
```

And run `pub get`

## Define your API

### ChopperApi

To define a client, use the `ChopperApi` annotation on a class and extends the `ChopperService` client.

```dart
// YOUR_FILE.dart

import "dart:async";
import 'package:chopper/chopper.dart';

// this is necessary for the generated code to find your class
part "YOUR_FILE.chopper.dart";

@ChopperApi(baseUrl: "/todos")
abstract class TodosListService extends ChopperService {

  // helper methods that help you instantiate your service
  static TodosListService create([ChopperClient client]) => 
      _$TodosListService(client);
}
```

`ChopperApi` annotation takes one optional parameter, the `baseUrl` that will prefix all the request define in the class.

### Define a request

To define a request, use one of the following annotations `Get`, `Post`, `Put`, `Patch`, `Delete` and must return a `Future<Response>`

Let's say you want to do a `GET` request on the following endpoint `/todos/TODO_ID`, add the following method declaration to your class.

```dart
@Get(path: '/{id}')
Future<Response> getTodo(@Path() String id);
```

Using `{id}` and the `Path` annotation your are telling chopper to replace `{id}` in the url by the value of the `id` parameter.

## ChopperClient

After defining your `ChopperService` you need to attribute a `ChopperClient` to it. The `ChopperClient` will manage the server hostname to call and can handle multiple `ChopperService`. It is also responsible of applying [interceptors](interceptors.md) and [converter]() to your requests.

```dart
import "dart:async";
import 'package:chopper/chopper.dart';

import 'YOUR_FILE.dart';

void main() async {
  final chopper = ChopperClient(
      baseUrl: "http://my-server:8000",
      services: [
        // inject the generated service
        TodosListService.create()
      ],
    );

  /// retrieve your service
  final todosService = chopper.getService<TodosListService>();
  /// or create a new one
  final todosService = TodosListService.create(chopper);

  /// then call your function
  final response = await todosService.getTodosList();
  
  if (response.isSuccessful) {
    // successful request
    final body = response.body;
  } else {
    // error from server
    final code = response.statusCode;
    final error = response.error;
  }
}

```



### 





