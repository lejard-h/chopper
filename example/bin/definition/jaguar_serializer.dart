import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import "model.dart";

part "jaguar_serializer.jser.dart";

@GenSerializer()
class ResourceSerializer extends Serializer<Resource>
    with _$ResourceSerializer {}

final repository = new JsonRepo(serializers: [new ResourceSerializer()]);

class JaguarConverter extends Converter {
  const JaguarConverter();

  @override
  Future<Response> decode(Response response, Type responseType) async =>
      response.replace(
        body: repository.getByType(responseType).fromMap(response.body),
      );

  @override
  Future<Request> encode(Request request) async =>
      request.replace(body: repository.to(request.body));
}
