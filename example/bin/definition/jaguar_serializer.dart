import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import "model.dart";

part "jaguar_serializer.jser.dart";

@GenSerializer()
class ResourceSerializer extends Serializer<Resource>
    with _$ResourceSerializer {}

final repository = new SerializerRepo(serializers: [new ResourceSerializer()]);

class JaguarConverter extends Converter {
  const JaguarConverter();

  @override
  Future decodeEntity<T>(entity) async {
    if (entity is Map) {
      return repository.getByType<T>(T).fromMap(entity);
    }
    return entity;
  }

  @override
  Future encodeEntity(entity) async => repository.to(entity);
}
