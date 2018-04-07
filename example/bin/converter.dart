import 'dart:async';

import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';

import 'model.dart';

@immutable
class ModelConverter extends JsonConverter {
  const ModelConverter();

  @override
  Future<Response> decode(Response response, Type responseType) async {
    final d = await super.decode(response, responseType);
    var body = d.body;
    if (responseType == Resource) {
      body = new Resource.fromJson(body as Map<String, dynamic>);
    }
    return response.replace(body: body);
  }

  @override
  Future<Request> encode(Request request) {
    var body = request.body;
    if (request.body is Resource) {
      body = (request.body as Resource).toJson();
    }
    return super.encode(request.replace(body: body));
  }
}