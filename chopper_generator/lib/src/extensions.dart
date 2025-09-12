import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// Returns true if the type is nullable.
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
}
