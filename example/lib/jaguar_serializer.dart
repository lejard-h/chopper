import 'package:chopper/chopper.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

part "jaguar_serializer.jser.dart";
part "jaguar_serializer.chopper.dart";

@GenSerializer()
class ResourceSerializer extends Serializer<Resource>
    with _$ResourceSerializer {}

@GenSerializer()
class ResourceErrorSerializer extends Serializer<ResourceError>
    with _$ResourceErrorSerializer {}

class Resource {
  final String id;
  final String name;

  Resource(this.id, this.name);
}

class ResourceError {
  final String type;
  final String message;

  ResourceError(this.type, this.message);
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
}
