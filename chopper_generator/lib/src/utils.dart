import 'package:analyzer/dart/element/element.dart';
import 'package:chopper_generator/src/extensions.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

final class Utils {
  static bool getMethodOptionalBody(ConstantReader method) =>
      method.read('optionalBody').boolValue;

  static String getMethodPath(ConstantReader method) =>
      method.read('path').stringValue;

  static String getMethodName(ConstantReader method) =>
      method.read('method').stringValue;

  static bool getUseBrackets(ConstantReader method) =>
      method.peek('useBrackets')?.boolValue ?? false;

  static bool getIncludeNullQueryVars(ConstantReader method) =>
      method.peek('includeNullQueryVars')?.boolValue ?? false;

  /// All positional required params must support nullability
  static Parameter buildRequiredPositionalParam(ParameterElement p) =>
      Parameter(
        (ParameterBuilder pb) => pb
          ..name = p.name
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          ),
      );

  /// All optional positional params must support nullability
  static Parameter buildOptionalPositionalParam(ParameterElement p) =>
      Parameter((ParameterBuilder pb) {
        pb
          ..name = p.name
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          );

        if (p.defaultValueCode != null) {
          pb.defaultTo = Code(p.defaultValueCode!);
        }
      });

  /// Named params can be optional or required, they also need to support nullability
  static Parameter buildNamedParam(ParameterElement p) =>
      Parameter((ParameterBuilder pb) {
        pb
          ..named = true
          ..name = p.name
          ..required = p.isRequiredNamed
          ..type = Reference(
            p.type.getDisplayString(withNullability: p.type.isNullable),
          );

        if (p.defaultValueCode != null) {
          pb.defaultTo = Code(p.defaultValueCode!);
        }
      });
}
