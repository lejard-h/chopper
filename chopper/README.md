# Chopper

[![pub package](https://img.shields.io/pub/v/chopper.svg)](https://pub.dev/packages/chopper)
[![Dart CI](https://github.com/lejard-h/chopper/workflows/Dart%20CI/badge.svg)](https://github.com/lejard-h/chopper/actions?query=workflow%3A%22Dart+CI%22)
[![codecov](https://codecov.io/gh/lejard-h/chopper/branch/master/graph/badge.svg)](https://codecov.io/gh/lejard-h/chopper)

[<img src="https://raw.githubusercontent.com/lejard-h/chopper/develop/flutter_favorite.png" width="100" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

Chopper is an http client generator for Dart and Flutter using source_gen and inspired by Retrofit.

[**Documentation**](https://hadrien-lejard.gitbook.io/chopper)

## Adding Chopper to your project

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

Or update your project's `pubspec.yaml` file manually:

* Add *chopper*'s latest version to your *dependencies*.
* Add *build_runner*'s latest version to your *dev_dependencies*.
  * *build_runner* may already be in your *dev_dependencies* depending on your project setup and other dependencies.
* Add *chopper_generator*'s latest version to your *dev_dependencies*.

```yaml
# pubspec.yaml

dependencies:
  chopper: ^<latest version>

dev_dependencies:
  build_runner: ^<latest version>
  chopper_generator: ^<latest version>
```

Latest versions:

* *chopper* ![pub package](https://img.shields.io/pub/v/chopper.svg)
* *chopper_generator* ![pub package](https://img.shields.io/pub/v/chopper_generator.svg)

## Documentation

* [Getting started](https://github.com/lejard-h/chopper/blob/master/getting-started.md)
* [Requests](https://github.com/lejard-h/chopper/blob/master/requests.md)
* [Converters](https://github.com/lejard-h/chopper/blob/master/converters/converters.md)
* [Interceptors](https://github.com/lejard-h/chopper/blob/master/interceptors.md)

## Examples

* [json_serializable Converter](https://github.com/lejard-h/chopper/blob/master/example/bin/main_json_serializable.dart)
* [built_value Converter](https://github.com/lejard-h/chopper/blob/master/example/bin/main_built_value.dart)

## If you encounter any issues, or need a feature implemented, please visit [Chopper's Issue Tracker on GitHub](https://github.com/lejard-h/chopper/issues).
