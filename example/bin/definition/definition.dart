import "dart:async";
import 'package:chopper/chopper.dart';

import 'model.dart';

part "definition.chopper.dart";

@ChopperApi("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
  @Get(url: "/{id}/")
  Future<Response> getResource(@Path() String id);

  @Get(url: "/")
  Future<Response<Map>> getMapResource(@Query() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Resource>> getTypedResource();

  @Post()
  Future<Response<Resource>> newResource(@Body() Resource resource,
      {@Header() String name});
}
