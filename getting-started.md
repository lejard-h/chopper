# Getting started

## How does Chopper work?

Due to limitations to Dart on Flutter and the Web browser, Chopper doesn't use reflection but code generation with the help of the [build](https://pub.dev/packages/build) and [source\_gen](https://pub.dev/packages/source_gen) packages from the Dart Team.

## Adding Chopper to your project

In your project's `pubspec.yaml` file, 

* Add *chopper*'s latest version to your *dependencies*.
* Add `build_runner: ^1.10.3` to your *dev_dependencies*.
  * *build_runner* may already be in your *dev_dependencies* depending on your project setup and other dependencies.
* Add *chopper_generator*'s latest version to your *dev_dependencies*.

```yaml
# pubspec.yaml

dependencies:
  chopper: ^<latest version>

dev_dependencies:
  build_runner: ^1.10.3
  chopper_generator: ^<latest version>
```

Latest versions:

* *chopper* ![pub package](https://img.shields.io/pub/v/chopper.svg) 
* *chopper_generator* ![pub package](https://img.shields.io/pub/v/chopper_generator.svg)

Run `pub get` to start using Chopper in your project.

## Defining a service class

### ChopperApi

To define a client, use the `@ChopperApi` annotation on an abstract class that extends `ChopperService`.

```dart
// YOUR_FILE.dart

import "dart:async";
import 'package:chopper/chopper.dart';

// This is necessary for the generator to work.
part "YOUR_FILE.chopper.dart";

@ChopperApi(baseUrl: "/todos")
abstract class TodosListService extends ChopperService {

  // A helper method that helps instantiating the service. You can omit this method and use the generated class directly instead.
  static TodosListService create([ChopperClient client]) => 
      _$TodosListService(client);
}
```

The `@ChopperApi` annotation takes one optional parameter - the `baseUrl` - that will prefix all the request's URLs defined in the class.

> There's an exception from this behavior described in the [Requests](requests.md) section of the documentation.

### Defining requests

Use one of the following annotations on abstract methods of a service class to define requests:

* `@Get` 

* `@Post` 

* `@Put`

* `@Patch`

* `@Delete`

* `@Head`

Request methods must return with values of the type `Future<Response>` or `Future<Response<SomeType>>`.

To define a `GET` request to the endpoint `/todos` in the service class above, add one of the following method declarations to the class:

```dart
@Get()
Future<Response> getTodos();
```

or

```dart
@Get()
Future<Response<List<Todo>>> getTodos();
```

URL manipulation with dynamic path, and query parameters is also supported. To learn more about URL manipulation with Chopper, have a look at the [Requests](requests.md) section of the documentation. 

## Defining a ChopperClient

After defining one or more `ChopperService`s, you need to bind instances of them to a `ChopperClient`. The `ChopperClient` provides the base URL for every service and it is also responsible for applying [interceptors](interceptors.md) and [converters](converters/converters.md) on the requests it handles.

```dart
import "dart:async";
import 'package:chopper/chopper.dart';

import 'YOUR_FILE.dart';

void main() async {
  final chopper = ChopperClient(
      baseUrl: "http://my-server:8000",
      services: [
        // Create and pass an instance of the generated service to the client
        TodosListService.create()
      ],
    );

  /// Get a reference to the client-bound service instance...
  final todosService = chopper.getService<TodosListService>();
  /// ... or create a new instance by explicitly binding it to a client.
  final anotherTodosService = TodosListService.create(chopper);

  /// Making a request is as easy as calling a function of the service.
  final response = await todosService.getTodos();
  
  if (response.isSuccessful) {
    // Successful request
    final body = response.body;
  } else {
    // Error code received from server
    final code = response.statusCode;
    final error = response.error;
  }
}
```

Handling I/O and other exceptions should be done by surrounding requests with `try-catch` blocks.
