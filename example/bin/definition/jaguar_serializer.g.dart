// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jaguar_serializer.dart';

// **************************************************************************
// Generator: JaguarSerializerGenerator
// **************************************************************************

abstract class _$ResourceSerializer implements Serializer<Resource> {
  Map<String, dynamic> toMap(Resource model,
      {bool withType: false, String typeKey}) {
    Map<String, dynamic> ret;
    if (model != null) {
      ret = <String, dynamic>{};
      setNullableValue(ret, "id", model.id);
      setNullableValue(ret, "name", model.name);
      setTypeKeyValue(typeKey, modelString(), withType, ret);
    }
    return ret;
  }

  Resource fromMap(Map<String, dynamic> map, {Resource model, String typeKey}) {
    if (map == null) {
      return null;
    }
    if (model is! Resource) {
      model = new Resource(map["id"] as String, map["name"] as String);
    }
    return model;
  }

  String modelString() => "Resource";
}
