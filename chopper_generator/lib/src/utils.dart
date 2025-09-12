// ignore_for_file: deprecated_member_use

import 'dart:math' show max;

import 'package:analyzer/dart/element/element2.dart';
import 'package:chopper/chopper.dart' show DateFormat, ListFormat, AbortTrigger;
import 'package:chopper_generator/src/extensions.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

/// A collection of static helpers for reading `@Get/@Post/...` options,
/// converting enum annotations to runtime values, and constructing typed
/// parameters for the generated client methods.
final class Utils {
  /// Returns whether the HTTP annotation declared `optionalBody: true`.
  static bool getMethodOptionalBody(ConstantReader method) =>
      method.read('optionalBody').boolValue;

  /// Returns the `path` value from the HTTP method annotation (e.g. `/users/:id`).
  static String getMethodPath(ConstantReader method) =>
      method.read('path').stringValue;

  /// Returns the HTTP verb name (e.g. `GET`, `POST`, ...).
  static String getMethodName(ConstantReader method) =>
      method.read('method').stringValue;

  /// Maps the `listFormat` enum on the annotation to `ListFormat`, or null if absent.
  static ListFormat? getListFormat(ConstantReader method) =>
      ListFormat.values.firstWhereOrNull(
        (ListFormat listFormat) =>
            listFormat.name ==
            method
                .peek('listFormat')
                ?.objectValue
                .getField('_name')
                ?.toStringValue(),
      );

  /// Maps the `dateFormat` enum on the annotation to `DateFormat`, or null if absent.
  static DateFormat? getDateFormat(ConstantReader method) =>
      DateFormat.values.firstWhereOrNull(
        (DateFormat fmt) =>
            fmt.name ==
            method
                .peek('dateFormat')
                ?.objectValue
                .getField('_name')
                ?.toStringValue(),
      );

  /// If set, overrides global `useBrackets` when serializing arrays in query strings.
  static bool? getUseBrackets(ConstantReader method) =>
      method.peek('useBrackets')?.boolValue;

  /// If set, include keys with `null` values in encoded query parameters for this method.
  static bool? getIncludeNullQueryVars(ConstantReader method) =>
      method.peek('includeNullQueryVars')?.boolValue;

  /// Returns the per-method timeout if specified on the annotation, clamped to
  /// a non-negative duration.
  static Duration? getTimeout(ConstantReader method) => switch (method
      .peek('timeout')
      ?.objectValue
      .getField('_duration')
      ?.toIntValue()) {
    final int us? => Duration(microseconds: max(us, 0)),
    _ => null,
  };

  /// All positional required params must support nullability
  static Parameter buildRequiredPositionalParam(
    FormalParameterElement p,
  ) => Parameter(
    (ParameterBuilder pb) =>
        pb
          ..name = switch (p.name3) {
            final String name? => name,
            null =>
              throw InvalidGenerationSourceError(
                'Encountered a required positional parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          ),
  );

  /// All optional positional params must support nullability
  static Parameter buildOptionalPositionalParam(
    FormalParameterElement p,
  ) => Parameter(
    (ParameterBuilder b) =>
        b
          ..name = switch (p.name3) {
            final String name? => name,
            null =>
              throw InvalidGenerationSourceError(
                'Encountered an optional positional parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          )
          ..defaultTo = switch (p.defaultValueCode) {
            final String code? => Code(code),
            null => null,
          },
  );

  /// Named params can be optional or required, they also need to support nullability
  static Parameter buildNamedParam(FormalParameterElement p) => Parameter(
    (ParameterBuilder pb) =>
        pb
          ..named = true
          ..name = switch (p.name3) {
            final String name? => name,
            null =>
              throw InvalidGenerationSourceError(
                'Encountered a named parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..required = p.isRequiredNamed
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          )
          ..defaultTo = switch (p.defaultValueCode) {
            final String code? => Code(code),
            null => null,
          },
  );

  static final TypeChecker _abortTriggerChecker = const TypeChecker.fromRuntime(
    AbortTrigger,
  );

  /// Locates the first parameter annotated with `@AbortTrigger`, or returns
  /// `null` if none exists. Enforces that **at most one** such parameter is
  /// present and validates its type via [_assertValidAbortTriggerType]. The
  /// accepted shapes are `Future<void>` and `Future<void>?`.
  static FormalParameterElement? findAbortTriggerParam(ExecutableElement2 m) {
    FormalParameterElement? found;

    for (final FormalParameterElement p in m.formalParameters) {
      final FormalParameterElement param = p.baseElement;
      if (_abortTriggerChecker.hasAnnotationOf(param)) {
        if (found != null) {
          throw InvalidGenerationSourceError(
            'Only one @AbortTrigger parameter is allowed on "${m.displayName}".',
            element: param,
          );
        }
        _assertValidAbortTriggerType(p);
        found = p;
      }
    }

    return found;
  }

  /// Predicate to filter parameters annotated with `@AbortTrigger`.
  static bool isAbortTriggerParam(FormalParameterElement p) =>
      _abortTriggerChecker.hasAnnotationOf(p.baseElement);

  /// Ensures the annotated parameter's type is `Future<void>` or
  /// `Future<void>?`, otherwise throws an [InvalidGenerationSourceError].
  static void _assertValidAbortTriggerType(FormalParameterElement p) {
    final String type = p.type.getDisplayString(withNullability: true);
    if (!const <String>{'Future<void>', 'Future<void>?'}.contains(type)) {
      throw InvalidGenerationSourceError(
        '@AbortTrigger parameter must be `Future<void>` or `Future<void>?`. Found: $type',
        element: p.baseElement,
      );
    }
  }
}
