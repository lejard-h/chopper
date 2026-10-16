---
name: chopper
description: Use this skill whenever a user wants to install, configure, write, generate, debug, or choose options for Chopper HTTP clients in Dart or Flutter, including @ChopperApi services, ChopperClient setup, build_runner/chopper_generator, converters, interceptors, response handling, query parameters, or chopper_built_value integration.
---

# Chopper Usage Assistant

Help users build Dart and Flutter HTTP clients with Chopper. Focus on application code, generated service setup, and interoperability outcomes, not repository maintenance.

## Start With Inputs

Before producing a final snippet, collect only details that change the code:

- Runtime: Dart package, Dart server/CLI, Flutter app, or test.
- API shape: base URL, service base path, endpoint paths, methods, headers, path/query parameters, request bodies, and expected status handling.
- Response handling: raw `Response`, nullable/no-content endpoint, typed body, JSON map/list, custom model converter, stream, file, or error body.
- Serialization approach: built-in `JsonConverter`, custom converter, `json_serializable`, `built_value`, form URL encoding, multipart, or raw body.
- Generation issue details: file name, `part` directive, service declaration, build command, and relevant `build_runner` error output.

Do not over-ask when the intent is clear. State assumptions and give concrete snippets users can paste.

## When To Read References

- Read [core.md](references/core.md) for service/client setup, annotations, responses, converters, interceptors, query parameters, forms, and multipart.
- Read [generator.md](references/generator.md) for `chopper_generator`, `build_runner`, generated files, and generation troubleshooting.
- Read [built-value.md](references/built-value.md) for `chopper_built_value`, serializer setup, built_value enum query parameters, and error conversion.

## Installation

For a Dart package or CLI:

```bash
dart pub add chopper
dart pub add --dev build_runner chopper_generator
```

For Flutter:

```bash
flutter pub add chopper
flutter pub add --dev build_runner chopper_generator
```

Use the public import:

```dart
import 'package:chopper/chopper.dart';
```

Generate services after adding or changing `@ChopperApi` declarations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Use `flutter pub run build_runner ...` only when the user's project explicitly requires old Flutter tooling. Prefer the current `dart run build_runner ...` form in new snippets.

## Base Pattern

Use uppercase annotation classes in examples.

```dart
import 'package:chopper/chopper.dart';

part 'todos_service.chopper.dart';

@ChopperApi(baseUrl: '/todos')
abstract class TodosService extends ChopperService {
  static TodosService create([ChopperClient? client]) => _$TodosService(client);

  @GET()
  Future<Response<List<dynamic>>> listTodos();

  @GET(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getTodo(@Path('id') String id);

  @POST()
  Future<Response<Map<String, dynamic>>> createTodo(
    @Body() Map<String, dynamic> body,
  );
}
```

Bind generated services to a client:

```dart
final chopper = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  services: [TodosService.create()],
  converter: const JsonConverter(),
  errorConverter: const JsonConverter(),
);

final todosService = chopper.getService<TodosService>();
```

## Core Rules

- Use `ChopperClient(baseUrl: Uri.parse('https://api.example.com'))`; avoid old examples that pass a string `baseUrl`.
- Every generated service file needs a matching `part '*.chopper.dart';`.
- Generated service classes use the private `_$ServiceName` constructor helper.
- `JsonConverter` JSON-encodes maps/lists and decodes JSON text into Dart maps/lists. It does not automatically turn JSON into user model classes.
- Use `Future<Response<T>>` when callers need status code, headers, error body, nullable success bodies, or HTTP 204/no-content handling.
- Use `Future<T>` only when a non-null converted body is enough. Chopper returns `response.bodyOrThrow`; unsuccessful responses and successful `null` bodies throw.
- `@FactoryConverter` with a non-null request or response factory replaces the client-level converter for that endpoint direction. It is not chained after the client converter.
- Query parameter conversion currently applies to query values only, not keys. Chopper preserves a nested map/list shape and converts leaf values before URL encoding.

## Troubleshooting Checklist

Check these before proposing unusual fixes:

- Missing or wrong `part` directive: it must match the current Dart file name.
- Missing `chopper_generator` or `build_runner` dev dependency.
- Stale generated files: rerun `dart run build_runner build --delete-conflicting-outputs`.
- Service is not abstract, does not extend `ChopperService`, or lacks `@ChopperApi`.
- Client uses a string `baseUrl` instead of `Uri.parse(...)`.
- Typed model responses are requested without a converter that maps JSON to the model type.
- A `@FactoryConverter` endpoint unexpectedly skipped the client converter.
- A built_value query enum uses the enum name because `BuiltValueConverter` was not passed as `converter` or `parameterConverter`.

## Response Shape

For code-generation or troubleshooting requests, answer with:

1. Assumptions that affect code, especially runtime, base URL, body format, converter choice, response shape, and generation command.
2. One complete service/client snippet or the smallest patchable snippet.
3. The command to generate code when generated files are involved.
4. A brief explanation of only the annotations/options/converters used.
5. A focused troubleshooting or verification step.
