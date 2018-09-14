import "dart:async";
import 'package:chopper/chopper.dart';

part "definition.chopper.dart";

@ChopperApi("MyService", baseUrl: "/resources")
abstract class MyServiceDefinition {
  @Get(url: "/{id}")
  Future<Response> getResource(
    @Path() String id,
  );

  @Get(url: "/", headers: const {"foo": "bar"})
  Future<Response<Map>> getMapResource(
    @Query() String id,
  );

  @Post(url: '/')
  @formUrlEncoded
  Future<Response> postResourceUrlEncoded(
    @Field('a') String toto,
    @Field() String b,
  );

  @Post(url: '/multi')
  @multipart
  Future<Response> postResources(
    @Part('1') Map a,
    @Part('2') Map b,
    @Part('3') String c,
  );

  @Post(url: '/file')
  @multipart
  Future<Response> postFile(
    @FileField('file') List<int> bytes,
  );
}
