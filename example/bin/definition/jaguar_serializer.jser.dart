// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jaguar_serializer.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ResourceSerializer implements Serializer<Resource> {
  @override
  Map<String, dynamic> toMap(Resource model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'name', model.name);
    return ret;
  }

  @override
  Resource fromMap(Map map) {
    if (map == null) return null;
    final obj = new Resource(map['id'] as String ?? getJserDefault('id'),
        map['name'] as String ?? getJserDefault('name'));
    return obj;
  }
}
