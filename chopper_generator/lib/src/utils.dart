// ignore_for_file: deprecated_member_use

import 'dart:math' show max;

import 'package:analyzer/dart/element/element2.dart';
import 'package:chopper/chopper.dart' show DateFormat, ListFormat, AbortTrigger;
import 'package:chopper_generator/src/extensions.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

final class Utils {
  static bool getMethodOptionalBody(ConstantReader method) =>
      method.read('optionalBody').boolValue;

  static String getMethodPath(ConstantReader method) =>
      method.read('path').stringValue;

  static String getMethodName(ConstantReader method) =>
      method.read('method').stringValue;

  static ListFormat? getListFormat(ConstantReader method) {
    return ListFormat.values.firstWhereOrNull(
      (ListFormat listFormat) =>
          listFormat.name ==
          method
              .peek('listFormat')
              ?.objectValue
              .getField('_name')
              ?.toStringValue(),
    );
  }

  static DateFormat? getDateFormat(ConstantReader method) {
    return DateFormat.values.firstWhereOrNull(
      (DateFormat fmt) =>
          fmt.name ==
          method
              .peek('dateFormat')
              ?.objectValue
              .getField('_name')
              ?.toStringValue(),
    );
  }

  static bool? getUseBrackets(ConstantReader method) =>
      method.peek('useBrackets')?.boolValue;

  static bool? getIncludeNullQueryVars(ConstantReader method) =>
      method.peek('includeNullQueryVars')?.boolValue;

  static Duration? getTimeout(ConstantReader method) {
    final ConstantReader? timeout = method.peek('timeout');
    if (timeout != null) {
      final int? microseconds =
          timeout.objectValue.getField('_duration')?.toIntValue();
      if (microseconds != null) {
        return Duration(microseconds: max(microseconds, 0));
      }
    }

    return null;
  }

  /// All positional required params must support nullability
  static Parameter buildRequiredPositionalParam(FormalParameterElement p) =>
      Parameter(
        (ParameterBuilder pb) => pb
          ..name = switch (p.name3) {
            final String name? => name,
            null => throw InvalidGenerationSourceError(
                'Encountered a required positional parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          ),
      );

  /// All optional positional params must support nullability
  static Parameter buildOptionalPositionalParam(FormalParameterElement p) =>
      Parameter((ParameterBuilder pb) {
        pb
          ..name = switch (p.name3) {
            final String name? => name,
            null => throw InvalidGenerationSourceError(
                'Encountered an optional positional parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          );

        if (p.defaultValueCode != null) {
          pb.defaultTo = Code(p.defaultValueCode!);
        }
      });

  /// Named params can be optional or required, they also need to support nullability
  static Parameter buildNamedParam(FormalParameterElement p) =>
      Parameter((ParameterBuilder pb) {
        pb
          ..named = true
          ..name = switch (p.name3) {
            final String name? => name,
            null => throw InvalidGenerationSourceError(
                'Encountered a named parameter without a name.',
                element: p.baseElement,
              ),
          }
          ..required = p.isRequiredNamed
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          );

        if (p.defaultValueCode != null) {
          pb.defaultTo = Code(p.defaultValueCode!);
        }
      });

  static final TypeChecker _abortTriggerChecker =
      const TypeChecker.fromRuntime(AbortTrigger);

  /// Returns the first parameter annotated with `@AbortTrigger`, or null.
  /// Validates there is at most one and that it is of type `Future<void>` or `Future<void>?`.
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

  /// Quick predicate for filtering collections.
  static bool isAbortTriggerParam(FormalParameterElement p) =>
      _abortTriggerChecker.hasAnnotationOf(p.baseElement);

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
