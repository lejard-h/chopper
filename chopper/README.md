# Chopper

[![pub package](https://img.shields.io/pub/v/chopper.svg)](https://pub.dartlang.org/packages/chopper) [![Build Status](https://travis-ci.com/lejard-h/chopper.svg?branch=master)](https://travis-ci.org/lejard-h/chopper) [![codecov](https://codecov.io/gh/lejard-h/chopper/branch/master/graph/badge.svg)](https://codecov.io/gh/lejard-h/chopper)

Chopper is an http client generator for Dart and Flutter using source_gen and inspired by Retrofit.

[**Documentation**](https://hadrien-lejard.gitbook.io/chopper)

## Adding Chopper to your project

In your project's `pubspec.yaml` file, 

* Add *chopper*'s latest version to your *dependencies*.
* Add `build_runner: ^1.12.2` to your *dev_dependencies*.
  * *build_runner* may already be in your *dev_dependencies* depending on your project setup and other dependencies.
* Add *chopper_generator*'s latest version to your *dev_dependencies*.

```yaml
# pubspec.yaml

dependencies:
  chopper: ^<latest version>

dev_dependencies:
  build_runner: ^1.12.2
  chopper_generator: ^<latest version>
```

Latest versions:

* *chopper* ![pub package](https://img.shields.io/pub/v/chopper.svg) 
* *chopper_generator* ![pub package](https://img.shields.io/pub/v/chopper_generator.svg) 

## Documentation

* [Getting started](getting-started.md)
* [Converters](converters/converters.md)
* [Interceptors](interceptors.md)

## Examples

* [json_serializable Converter](https://github.com/lejard-h/chopper/blob/master/example/bin/main_json_serializable.dart)
* [built_value Converter](https://github.com/lejard-h/chopper/blob/master/example/bin/main_built_value.dart)
* [Angular](https://github.com/lejard-h/chopper/blob/master/example/web/main.dart)

## If you encounter any issues, or need a feature implemented, please visit [Chopper's Issue Tracker on GitHub](https://github.com/lejard-h/chopper/issues).
