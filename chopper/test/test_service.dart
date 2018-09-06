import "dart:async";
import 'package:chopper/chopper.dart';

part "test_service.chopper.dart";

@ChopperApi("HttpTestService", baseUrl: "/test")
abstract class HttpTestServiceDefinition {
  @Get(url: "/get/{id}")
  Future<Response> getTest(@Path() String id);

  @Post(url: "/post")
  Future<Response> postTest(@Body() String data);

  @Put(url: '/put/{id}')
  Future<Response> putTest(@Path() String id, @Body() String data);

  @Delete(url: '/delete/{id}')
  Future<Response> deleteTest(@Path() String id);

  @Patch(url: '/patch/{id}')
  Future<Response> patchTest(@Path() String id, @Body() String data);
}
