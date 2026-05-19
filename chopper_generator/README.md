# chopper_generator

[![pub package](https://img.shields.io/pub/v/chopper_generator.svg)](https://pub.dev/packages/chopper_generator)

This package provides the code generator for the [Chopper](https://github.com/lejard-h/chopper) package.

## Installation

Add this package as a development dependency alongside `build_runner`:

```bash
dart pub add dev:build_runner dev:chopper_generator
```

## Usage

After defining services with `@ChopperApi`, generate the `.chopper.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For examples please refer to the main [Chopper](https://github.com/lejard-h/chopper) package and/or read the
[documentation](https://hadrien-lejard.gitbook.io/chopper).
