# Built Value Converter

{% hint style="warning" %}
Experimental
{% endhint %}

Chopper converter for [built\_value](https://pub.dev/packages/built_value) serializer.

## Installation

```yaml
# pubspec.yaml

dependencies:
  chopper_build_value: ^0.0.1
```

## Getting started

### Built value

Define your models.

```dart
abstract class DataModel implements Built<DataModel, DataModelBuilder> {
  int get id;
  String get name;

  static Serializer<DataModel> get serializer => _$dataModelSerializer;
  factory DataModel([updates(DataModelBuilder b)]) = _$DataModel;
  DataModel._();
}
```

Aggregate all serializers

```dart
/// Collection of generated serializers for the built_value
@SerializersFor([
  DataModel,
])
final Serializers serializers = _$serializers;
```

See built\_value [documentation](https://pub.dev/packages/built_value) for more informations.

### Chopper

Provide serializers to the converter and to the ChopperClient.

```dart
final builder = serializers.toBuilder();
builder.addPlugin(StandardJsonPlugin());

final jsonSerializers = builder.build();
final converter = BuiltValueConverter(jsonSerializers);

final client = ChopperClient(converter: converter);
```

#### Error converter

You can use `BuiltValueConverter` as an error converter. It will try to decode error using the `wireName` inside JSON `{"$":"ErrorModel"}` if available.

If `wireName` is not available, you can specify the type of your error to the converter.

```dart
BuiltValueConverter(jsonSerializers, errorType: ErrorModel);
```



