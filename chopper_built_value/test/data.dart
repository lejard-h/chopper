import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'data.g.dart';

abstract class DataModel implements Built<DataModel, DataModelBuilder> {
  int get id;
  String get name;

  static Serializer<DataModel> get serializer => _$dataModelSerializer;
  factory DataModel([updates(DataModelBuilder b)]) = _$DataModel;
  DataModel._();
}

abstract class ErrorModel implements Built<ErrorModel, ErrorModelBuilder> {
  String get message;

  static Serializer<ErrorModel> get serializer => _$errorModelSerializer;
  factory ErrorModel([updates(ErrorModelBuilder b)]) = _$ErrorModel;
  ErrorModel._();
}
