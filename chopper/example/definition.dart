import 'dart:async';

import 'package:chopper/chopper.dart';

part 'definition.chopper.dart';

@ChopperApi(baseUrl: '/resources')
abstract class MyService extends ChopperService {
  static MyService create([ChopperClient? client]) => _$MyService(client);

  @GET(path: '/{id}')
  Future<Response> getResource(@Path() String id);

  @GET(path: '/', headers: {'foo': 'bar'})
  Future<Response<Map>> getMapResource(@Query() String id);

  @GET(path: '/resources')
  Future<Response<List<Map>>> getListResources();

  @POST(path: '/')
  @FormUrlEncoded()
  Future<Response> postResourceUrlEncoded(
    @Field('a') String toto,
    @Field() String b,
  );

  @POST(path: '/multi')
  @Multipart()
  Future<Response> postResources(
    @Part('1') Map a,
    @Part('2') Map b,
    @Part('3') String c,
  );

  @POST(path: '/file')
  @Multipart()
  Future<Response> postFile(@PartFile('file') List<int> bytes);

  @GET(path: '/assets/10GB.bin', timeout: Duration(seconds: 30))
  Future<Response> getMassiveFile();
}
