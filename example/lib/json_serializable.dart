import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_serializable.chopper.dart';

part 'json_serializable.g.dart';

@JsonSerializable()
class Resource {
  final String id;
  final String name;

  Resource(this.id, this.name);

  static const fromJsonFactory = _$ResourceFromJson;

  Map<String, dynamic> toJson() => _$ResourceToJson(this);
}

@JsonSerializable()
class ResourceError {
  final String type;
  final String message;

  ResourceError(this.type, this.message);

  static const fromJsonFactory = _$ResourceErrorFromJson;

  Map<String, dynamic> toJson() => _$ResourceErrorToJson(this);
}

@ChopperApi(baseUrl: "/resources")
abstract class MyService extends ChopperService {
  static MyService create([ChopperClient client]) => _$MyService(client);

  @Get(path: "/{id}/")
  Future<Response> getResource(@Path() String id);

  @Get(path: "/all", headers: const {"test": "list"})
  Future<Response<List<Resource>>> getResources();

  @Get(path: "/")
  Future<Response<Map>> getMapResource(@Query() String id);

  @Get(path: "/", headers: const {"foo": "bar"})
  Future<Response<Resource>> getTypedResource();

  @Post()
  Future<Response<Resource>> newResource(@Body() Resource resource,
      {@Header() String name});

  @Post(path: "feilds/post")
  Future<Response> fieldsPost(
    @Field('1') String a,
    @Field('2') int b,
    @Field('3') double c,
  );
}
