# Chopper Generator Reference

Use this reference for `chopper_generator`, `build_runner`, and generated-file troubleshooting.

## Dependencies

For Dart:

```bash
dart pub add chopper
dart pub add --dev build_runner chopper_generator
```

For Flutter:

```bash
flutter pub add chopper
flutter pub add --dev build_runner chopper_generator
```

## Required Source Shape

Generated services need all of these:

- `import 'package:chopper/chopper.dart';`
- A `part` directive that matches the source file name.
- An abstract class annotated with `@ChopperApi`.
- The service class extends `ChopperService`.
- Abstract request methods annotated with HTTP method annotations.

Example for `lib/api/todos_service.dart`:

```dart
import 'package:chopper/chopper.dart';

part 'todos_service.chopper.dart';

@ChopperApi(baseUrl: '/todos')
abstract class TodosService extends ChopperService {
  static TodosService create([ChopperClient? client]) => _$TodosService(client);

  @GET()
  Future<Response<List<dynamic>>> listTodos();
}
```

The generated file will be `lib/api/todos_service.chopper.dart`.

## Generation Commands

Build once:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Use `flutter pub run build_runner ...` only for older Flutter setups that cannot run `dart run build_runner ...`.

## Troubleshooting

For "Target of URI hasn't been generated" or missing generated class:

- Confirm the `part` file name matches the Dart source file.
- Confirm `chopper_generator` and `build_runner` are in `dev_dependencies`.
- Confirm the service is in a package target that `build_runner` sees.
- Run `dart run build_runner build --delete-conflicting-outputs`.
- Restart the analyzer/IDE after generation if stale diagnostics remain.

For build failures:

- Read the first generator error, not the final build summary.
- Check that request method return types are `Future<Response>`, `Future<Response<T>>`, or `Future<T>`.
- Check that `@Path` names match placeholders in the path.
- Check that unsupported combinations are not mixed, such as multiple request bodies or conflicting timeout and `@AbortTrigger` usage.

For stale or conflicting generated output:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

Do not tell users to edit `.chopper.dart` files manually. Fix the annotated source file and regenerate.
