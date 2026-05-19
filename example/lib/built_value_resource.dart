library;

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:chopper/chopper.dart';

part 'built_value_resource.chopper.dart';
part 'built_value_resource.g.dart';

abstract class Resource implements Built<Resource, ResourceBuilder> {
  String get id;

  String get name;

  static Serializer<Resource> get serializer => _$resourceSerializer;

  factory Resource([Function(ResourceBuilder b) updates]) = _$Resource;

  Resource._();
}

abstract class ResourceError
    implements Built<ResourceError, ResourceErrorBuilder> {
  String get type;

  String get message;

  static Serializer<ResourceError> get serializer => _$resourceErrorSerializer;

  factory ResourceError([Function(ResourceErrorBuilder b) updates]) =
      _$ResourceError;

  ResourceError._();
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

@ChopperApi(baseUrl: '/resources')
abstract class MyService extends ChopperService {
  static MyService create([ChopperClient? client]) => _$MyService(client);

  @GET(path: '/{id}/')
  Future<Response> getResource(@Path() String id);

  @GET(path: '/list')
  Future<Response<BuiltList<Resource>>> getBuiltListResources();

  @GET(path: '/', headers: {'foo': 'bar'})
  Future<Response<Resource>> getTypedResource();

  @GET(path: '/available')
  Future<Response<Resource>> getAvailableResource(
    @Query('visit_type') VisitType visitType,
  );

  @POST()
  Future<Response<Resource>> newResource(
    @Body() Resource resource, {
    @Header() String? name,
  });
}
