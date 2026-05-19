import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'data.g.dart';

abstract class DataModel implements Built<DataModel, DataModelBuilder> {
  int get id;
  String get name;

  static Serializer<DataModel> get serializer => _$dataModelSerializer;
  factory DataModel([Function(DataModelBuilder b) updates]) = _$DataModel;
  DataModel._();
}

abstract class ErrorModel implements Built<ErrorModel, ErrorModelBuilder> {
  String get message;

  static Serializer<ErrorModel> get serializer => _$errorModelSerializer;
  factory ErrorModel([Function(ErrorModelBuilder b) updates]) = _$ErrorModel;
  ErrorModel._();
}

class VisitType extends EnumClass {
  const VisitType._(super.name);

  @BuiltValueEnumConst(wireName: 'face_to_face')
  static const VisitType faceToFace = _$faceToFace;

  static const VisitType phone = _$phone;

  static BuiltSet<VisitType> get values => _$visitTypeValues;
  static VisitType valueOf(String name) => _$visitTypeValueOf(name);
  static Serializer<VisitType> get serializer => _$visitTypeSerializer;
}
