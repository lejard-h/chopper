import "dart:async";
import 'package:chopper/chopper.dart';

part "definition.chopper.dart";

@ChopperApi("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
  @Get(url: "/{id}")
  Future<Response> getResource(@Path() String id);

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(@Query() String id);
}
