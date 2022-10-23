import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper_example/built_value_resource.dart';
import 'package:chopper_example/built_value_serializers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final jsonSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

/// Simple client to have working example without remote server
final client = MockClient((req) async {
  if (req.method == 'POST') {
    return http.Response('{"type":"Fatal","message":"fatal erorr"}', 500);
  }
  if (req.url.path == '/resources/list') {
    return http.Response('[{"id":"1","name":"Foo"}]', 200);
  }

  return http.Response('{"id":"1","name":"Foo"}', 200);
});

main() async {
  final chopper = ChopperClient(
    client: client,
    baseUrl: Uri.parse('http://localhost:8000'),
    converter: BuiltValueConverter(),
    errorConverter: BuiltValueConverter(),
    services: [
      // the generated service
      MyService.create(),
    ],
  );

  final myService = chopper.getService<MyService>();

  final response1 = await myService.getResource('1');
  print('response 1: ${response1.body}'); // undecoded String

  final response2 = await myService.getTypedResource();
  print('response 2: ${response2.body}'); // decoded Resource

  final response3 = await myService.getBuiltListResources();
  print('response 3: ${response3.body}');

  try {
    final builder = ResourceBuilder()
      ..id = '3'
      ..name = 'Super Name';
    await myService.newResource(builder.build());
  } on Response catch (error) {
    print(error.body);
  }
}

class BuiltValueConverter extends JsonConverter {
  T? _deserialize<T>(dynamic value) {
    final serializer = jsonSerializers.serializerForType(T) as Serializer<T>?;
    if (serializer == null) {
      throw Exception('No serializer for type $T');
    }

    return jsonSerializers.deserializeWith<T>(serializer, value);
  }

  BuiltList<T> _deserializeListOf<T>(Iterable value) => BuiltList(
        value.map((value) => _deserialize<T>(value)).toList(growable: false),
      );

  dynamic _decode<T>(dynamic entity) {
    /// handle case when we want to access to Map<String, dynamic> directly
    /// getResource or getMapResource
    /// Avoid dynamic or unconverted value, this could lead to several issues
    if (entity is T) return entity;

    try {
      return entity is List
          ? _deserializeListOf<T>(entity)
          : _deserialize<T>(entity);
    } catch (e) {
      print(e);

      return null;
    }
  }

  @override
  FutureOr<Response<ResultType>> convertResponse<ResultType, Item>(
    Response response,
  ) async {
    // use [JsonConverter] to decode json
    final Response jsonRes = await super.convertResponse(response);
    final body = _decode<Item>(jsonRes.body);

    return jsonRes.copyWith<ResultType>(body: body);
  }

  @override
  Request convertRequest(Request request) => super.convertRequest(
        request.copyWith(
          body: serializers.serialize(request.body),
        ),
      );
}
