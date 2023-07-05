import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix != NullabilitySuffix.none;
}
