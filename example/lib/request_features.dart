import 'dart:async';

import 'package:chopper/chopper.dart';

part 'request_features.chopper.dart';

@ChopperApi(baseUrl: '/features')
abstract class RequestFeatureService extends ChopperService {
  static RequestFeatureService create([ChopperClient? client]) =>
      _$RequestFeatureService(client);

  @GET(
    path: '/search',
    listFormat: ListFormat.brackets,
    dateFormat: DateFormat.date,
  )
  Future<Response<String>> searchResources(
    @QueryMap() Map<String, dynamic> filters, {
    @Query('starts_at') required DateTime startsAt,
    @AbortTrigger() Future<void>? abortTrigger,
  });

  @POST(path: '/form')
  @FormUrlEncoded()
  Future<Response<String>> submitForm(
    @Field('resource_id') String resourceId,
    @Field() String action,
  );
}
