# BuiltValueConverter

{% hint style="warning" %}
Experimental
{% endhint %}

A Chopper Converter for [built\_value](https://pub.dev/packages/built_value) based serialization.

## Installation

Add the chopper_built_value package to your project's dependencies in pubspec.yaml:

```yaml
# pubspec.yaml

dependencies:
  chopper_build_value: ^<latest version>
```

The latest version is [![pub package](https://img.shields.io/pub/v/chopper_built_value.svg)](https://pub.dartlang.org/packages/chopper_built_value).

## Getting started

### Built value

Define your models as you usually do with built_value.

```dart
abstract class DataModel implements Built<DataModel, DataModelBuilder> {
  int get id;
  String get name;

  static Serializer<DataModel> get serializer => _$dataModelSerializer;
  factory DataModel([updates(DataModelBuilder b)]) = _$DataModel;
  DataModel._();
}
```

Aggregate all serializers into a top level collection.

```dart
/// Collection of generated serializers for the built_value
@SerializersFor([
  DataModel,
])
final Serializers serializers = _$serializers;
```

See [built\_value documentation](https://pub.dev/packages/built_value) for more information on how built_value works.

### Using BuiltValueConverter with Chopper

Build a `BuiltValueConverter` by providing the `built_value` serializer collection.

To use the crteated converter, pass it to `ChopperClient`'s `converter` constructor parameter. 

```dart
final builder = serializers.toBuilder();
builder.addPlugin(StandardJsonPlugin());

final jsonSerializers = builder.build();
final converter = BuiltValueConverter(jsonSerializers);

final client = ChopperClient(converter: converter);
```

#### Error converter

`BuiltValueConverter` is also an error converter. It will try to decode error response bodies using the `wireName` inside JSON `{"$":"ErrorModel"}`, if available.

If `wireName` is not available, `BuiltValueConverter` will try to convert error response bodies to `errorType`, if it was provided and is not `null`.

```dart
final jsonSerializers = ...

final converter = BuiltValueConverter(jsonSerializers, errorType: ErrorModel);
```



