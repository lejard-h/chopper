# chopper_built_value

[![pub package](https://img.shields.io/pub/v/chopper_built_value.svg)](https://pub.dev/packages/chopper_built_value)

A `built_value` based converter for [Chopper](https://github.com/lejard-h/chopper).

## Installation

```bash
dart pub add chopper_built_value
```

## Usage

Create the converter with your generated `Serializers` collection and pass it to
`ChopperClient`:

```dart
final jsonSerializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

final converter = BuiltValueConverter(jsonSerializers);

final client = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  converter: converter,
  errorConverter: converter,
);
```

`BuiltValueConverter` can also convert query parameters. When used as the
client's `converter` or `parameterConverter`, built_value enum classes are
serialized with their configured wire names.

See the
full [BuiltValueConverter documentation](https://hadrien-lejard.gitbook.io/chopper/converters/built-value-converter)
for model setup and error conversion examples.
