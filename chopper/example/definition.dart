import 'dart:async';

import 'package:chopper/chopper.dart';

part 'definition.chopper.dart';

@ChopperApi(baseUrl: '/')
abstract class MyService extends ChopperService {
  static MyService create(ChopperClient client) => _$MyService(client);

  @Get(path: '/abc')
  Future<Response<String>> getLongTimeTest();

  @Post(path: '/multi')
  @multipart
  Future<Response> postResources(
      @Part('1') Map a,
      @Part('2') Map b,
      @Part('3') String c,
      );

  @Post(path: '/file')
  @multipart
  Future<Response> postFile(
      @Part('file') List<int> bytes,
      );
}