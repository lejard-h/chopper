# Chopper Built Value Reference

Use this reference when users want Chopper integration with `built_value`.

## Dependencies

For Dart:

```bash
dart pub add chopper chopper_built_value
dart pub add built_value built_collection
dart pub add --dev build_runner built_value_generator chopper_generator
```

For Flutter:

```bash
flutter pub add chopper chopper_built_value
flutter pub add built_value built_collection
flutter pub add --dev build_runner built_value_generator chopper_generator
```

## Converter Setup

Build the converter from the generated `Serializers` collection and pass it to `ChopperClient`.

```dart
final jsonSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

final converter = BuiltValueConverter(jsonSerializers);

final chopper = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  services: [TodosService.create()],
  converter: converter,
  errorConverter: converter,
);
```

Use `StandardJsonPlugin` for normal JSON APIs unless the user's built_value setup intentionally uses the default built_value wire format.

## Model And Service Shape

Built value models still need normal built_value declarations, generated parts, and serializers.

```dart
abstract class Todo implements Built<Todo, TodoBuilder> {
  int get id;
  String get title;

  static Serializer<Todo> get serializer => _$todoSerializer;

  factory Todo([void Function(TodoBuilder) updates]) = _$Todo;

  Todo._();
}
```

Then Chopper endpoints can return built_value model types:

```dart
@GET(path: '/{id}')
Future<Response<Todo>> getTodo(@Path('id') int id);
```

For list responses, `BuiltValueConverter` deserializes iterable JSON into `BuiltList<InnerType>` when the endpoint return type asks for a built list.

```dart
@GET()
Future<Response<BuiltList<Todo>>> listTodos();
```

## Query Parameters

`BuiltValueConverter` also implements `ParameterConverter`. When passed as the client's `converter` or `parameterConverter`, built_value enum classes are serialized with their configured wire names.

```dart
class VisitType extends EnumClass {
  @BuiltValueEnumConst(wireName: 'face_to_face')
  static const VisitType faceToFace = _$faceToFace;

  static Serializer<VisitType> get serializer => _$visitTypeSerializer;
}

@GET(path: '/visits')
Future<Response> visits(@Query('type') VisitType type);
```

Calling `visits(VisitType.faceToFace)` sends `type=face_to_face`.

Parameter conversion applies to query values only, not keys. Nested maps/lists keep their shape and Chopper converts each leaf value.

## Error Conversion

`BuiltValueConverter` implements `ErrorConverter`. It can be used as both `converter` and `errorConverter`.

```dart
final converter = BuiltValueConverter(jsonSerializers, errorType: ErrorModel);

final chopper = ChopperClient(converter: converter, errorConverter: converter);
```

If an error JSON body includes a built_value wire name marker such as `{"$":"ErrorModel"}`, the converter tries that serializer. Otherwise, when `errorType` is provided, it tries that serializer before falling back to the decoded JSON body.

## Troubleshooting

- `Serializer not found for T`: add the model to `@SerializersFor`, expose its static serializer, and regenerate built_value code.
- JSON shape mismatch: confirm `StandardJsonPlugin` usage matches the API.
- Query enum uses `faceToFace` instead of `face_to_face`: pass the `BuiltValueConverter` as `converter` or `parameterConverter`.
- Chopper service generated but built_value code missing: run `dart run build_runner build --delete-conflicting-outputs` after both Chopper and built_value annotations are present.
