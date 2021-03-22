# Getting started

## How does Chopper work?

Due to limitations to Dart on Flutter and the Web browser, Chopper doesn't use reflection but code generation with the help of the [build](https://pub.dev/packages/build) and [source\_gen](https://pub.dev/packages/source_gen) packages from the Dart Team.

## Installation

Add the `chopper` and the `chopper_generator` packages to your project dependencies.

```yaml
# pubspec.yaml

dependencies:
  chopper: ^3.0.7

dev_dependencies:
  build_runner: ^1.12.1
  chopper_generator: ^3.0.7
```

Run `pub get` to start using Chopper in your project.

## Define your API

### ChopperApi

To define a client, use the `@
ChopperApi` annotation on an abstract class that extends the `ChopperService` class.

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

### Defining a request

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
