# Getting started

## How does Chopper work?

Due to limitations in Dart on Flutter and the Web browser, Chopper doesn't use reflection. Instead, it uses code
generation with the help of the [build](https://pub.dev/packages/build) and [source_gen](https://pub.dev/packages/source_gen) packages from the Dart Team.

## Installation

Add `chopper` as a dependency and `chopper_generator` plus `build_runner` as development dependencies.

For a Dart package, run:

```bash
dart pub add chopper
dart pub add --dev build_runner chopper_generator
```

For a Flutter app, run:

```bash
flutter pub add chopper
flutter pub add --dev build_runner chopper_generator
```

Or add them manually to your `pubspec.yaml`, using the latest versions from
pub.dev:

```yaml
# pubspec.yaml

dependencies:
  chopper: ^<latest version>

dev_dependencies:
  build_runner: ^<latest version>
  chopper_generator: ^<latest version>
```

Run `dart pub get` or `flutter pub get` to start using Chopper in your project.

## Define your API

### ChopperApi

To define a client, use the `@ChopperApi` annotation on an abstract class that extends the `ChopperService` class.

```dart
// YOUR_FILE.dart

import "dart:async";
import 'package:chopper/chopper.dart';

// This is necessary for the generator to work.
part "YOUR_FILE.chopper.dart";

@ChopperApi(baseUrl: "/todos")
abstract class TodosListService extends ChopperService {
  // A helper method that helps instantiate the service. You can omit this
  // method and use the generated class directly instead.
  static TodosListService create([ChopperClient? client]) =>
    _$TodosListService(client);
}
```

The `@ChopperApi` annotation takes one optional parameter - the `baseUrl` - that
will prefix all the request URLs defined in the class.

> There's an exception from this behavior described in the [Requests](requests.md) section of the documentation.

### Defining a request

Use one of the following annotations on abstract methods of a service class to define requests:

* `@GET`

* `@POST`

* `@PUT`

* `@PATCH`

* `@DELETE`

* `@HEAD`

* `@OPTIONS`

Request methods must return values of the type `Future<Response>`, `Future<Response<SomeType>>` or `Future<SomeType>`.
The `Response` class is a wrapper around the HTTP response that contains the response body, status code and error, if any.

This class can be omitted if only a non-null response body is needed. When omitting the `Response` class, Chopper
returns `response.bodyOrThrow`, so an unsuccessful response (`statusCode < 200 || statusCode >= 300`) throws the
response error when it is an `Exception`, otherwise a `ChopperHttpException`. A successful response whose converted
body is `null` also throws a `ChopperHttpException`; use `Future<Response<T>>` and read `response.body` directly for
endpoints where a successful `null` body is expected, such as HTTP 204/no-content responses.

To define a `GET` request to the endpoint `/todos` in the service class above, add one of the following method
declarations to the class:

```dart
@GET()
Future<Response> getTodos();
```

or

```dart
@GET()
Future<Response<List<Todo>>> getTodos();
```

or

```dart
@GET()
Future<List<Todo>> getTodos();
```

URL manipulation with dynamic path and query parameters is also supported. To learn more, see the [Requests](requests.md)
section of the documentation.

## Defining a ChopperClient

After defining one or more `ChopperService`s, bind instances of them to a `ChopperClient`. The `ChopperClient` provides
the base URL for every service and is responsible for applying [interceptors](interceptors.md) and [converters](converters/converters.md) on the requests it handles.

```dart
import "dart:async";
import 'package:chopper/chopper.dart';

import 'YOUR_FILE.dart';

void main() async {
  final chopper = ChopperClient(
    baseUrl: Uri.parse('http://my-server:8000'),
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

Handle I/O and other exceptions by surrounding requests with `try-catch` blocks.
