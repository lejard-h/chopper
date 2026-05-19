# Chopper Core Reference

Use this reference when writing user application code with `chopper`.

## Service Shape

Chopper services are abstract classes annotated with `@ChopperApi` and extending `ChopperService`.

```dart
import 'package:chopper/chopper.dart';

part 'users_service.chopper.dart';

@ChopperApi(baseUrl: '/users')
abstract class UsersService extends ChopperService {
  static UsersService create([ChopperClient? client]) => _$UsersService(client);

  @GET(path: '/{id}')
  Future<Response<Map<String, dynamic>>> getUser(@Path('id') String id);
}
```

The `@ChopperApi(baseUrl: ...)` value prefixes paths in that service. Use endpoint annotations for per-method paths.

## Client Setup

```dart
final chopper = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  services: [UsersService.create()],
  converter: const JsonConverter(),
  errorConverter: const JsonConverter(),
);

final users = chopper.getService<UsersService>();
```

Use `Uri.parse(...)` for the client base URL. Mention custom `http.Client`only when the user needs transport customization, testing, certificates, timeouts at the socket layer, browser/native behavior, or platform clients.

## Request Annotations

Prefer uppercase annotations in examples:

- HTTP methods: `@GET`, `@POST`, `@PUT`, `@PATCH`, `@DELETE`, `@HEAD`, `@OPTIONS`.
- URL values: `@Path`, `@Query`, `@QueryMap`.
- Headers: `@Header`, method-level `headers: {...}`.
- Bodies: `@Body`, `@Field`, `@FieldMap`, `@Part`, `@PartFile`, `@PartMap`, `@PartFileMap`.
- Per-endpoint converters: `@FactoryConverter`.
- Metadata/cancellation: `@Tag`, `@AbortTrigger`.

Example:

```dart
@GET(path: '/search')
Future<Response<List<dynamic>>> search({
  @Query('q') required String query,
  @Query('page') int page = 1,
});
```

## Responses

Request methods may return `Future<Response>`, `Future<Response<T>>`, or `Future<T>`.

- Prefer `Future<Response<T>>` by default for user snippets.
- Use `Future<T>` only when the user wants a non-null converted body and does not need status, headers, or error details.
- For `Future<T>`, generated code returns `response.bodyOrThrow`.
- `bodyOrThrow` throws for unsuccessful responses unless `response.error` is already an `Exception`, and also throws when a successful response has a `null` converted body.
- For HTTP 204/no-content or nullable success bodies, use `Future<Response<T>>` and read `response.body` directly.

## Converters

`JsonConverter` handles JSON strings and maps/lists. It does not map JSON into custom model classes by itself.

```dart
final chopper = ChopperClient(
  converter: const JsonConverter(),
  errorConverter: const JsonConverter(),
);
```

When users want model instances, recommend one of:

- A custom `Converter` that maps decoded JSON into models.
- Endpoint-specific `@FactoryConverter` functions.
- `chopper_built_value` for built_value models.
- Manual mapping from `Response<Map<String, dynamic>>` or
  `Response<List<dynamic>>` in application code for small cases.

`@FactoryConverter` replaces the client-level converter for that endpoint direction when the request or response factory is non-null. If it needs JSON decoding first, call `JsonConverter` inside the factory.

```dart
Future<Response<T>> convertUserResponse<T>(Response response) async {
  final jsonResponse = await const JsonConverter()
      .convertResponse<Map<String, dynamic>, dynamic>(response);

  return jsonResponse.copyWith<T>(body: User.fromJson(jsonResponse.body!) as T);
}
```

## Parameter Conversion

Use `ParameterConverter` for custom scalar query values such as generated enums with wire names.

```dart
class ApiParameterConverter implements ParameterConverter {
  @override
  Object? convertParameter(
    Object? parameter,
    ParameterConversionContext context,
  ) {
    if (parameter is DateTime && context.location == ParameterLocation.query) {
      return parameter.toUtc().toIso8601String();
    }

    return parameter;
  }
}
```

Pass it with `ChopperClient(parameterConverter: ApiParameterConverter())`. If no explicit `parameterConverter` is provided, Chopper uses `converter` when that converter also implements `ParameterConverter`.

Parameter conversion currently applies to query parameter values only, not keys. Nested map/list query values keep their shape; Chopper converts each leaf value before encoding.

## Forms And Multipart

For form URL encoded bodies, either use `FormUrlEncodedConverter` as the client converter or apply its request factory on the endpoint.

```dart
@FactoryConverter(request: FormUrlEncodedConverter.requestFactory)
@POST(path: '/form')
Future<Response> submitForm(@Body() Map<String, String> fields);
```

For multipart, use `@Multipart()` plus `@Part`, `@PartFile`, and related annotations.

```dart
@POST(path: '/files')
@Multipart()
Future<Response> upload(@PartFile('file') List<int> bytes);
```

## Interceptors

Use interceptors for cross-cutting request/response behavior such as auth headers, logging, analytics, or base URL rewriting.
Do not use interceptors as model converters; use `Converter`, `ErrorConverter`, or endpoint factories for body transformation.
