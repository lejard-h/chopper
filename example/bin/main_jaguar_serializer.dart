import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:chopper_example/definition.dart';
import 'package:chopper_example/jaguar_serializer.dart';
import 'package:chopper_example/model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

/// Simple client to have working example without remote server
final client = MockClient((req) async {
  if (req.method == 'POST')
    return http.Response('{"type":"Fatal","message":"fatal erorr"}', 500);
  return http.Response('{"id":"1","name":"Foo"}', 200);
});

main() async {
  final chopper = new ChopperClient(
    client: client,
    baseUrl: "http://localhost:8000",
    converter: JaguarConverter(),
    errorConverter: ErrorConverter(),
    services: [
      // the generated service
      MyService.create(),
    ],
    jsonApi: true,
  );

  final myService = chopper.service<MyService>(MyService);

  final response1 = await myService.getResource("1");
  print(response1.body); // undecoded String

  final response2 = await myService.getTypedResource();
  print(response2.body); // decoded Resour

  final response3 = await myService.getMapResource("1");
  print(response3.body); // und Resource

  try {
    await myService.newResource(Resource("3", "Super Name"));
  } on Response catch (error) {
    print(error.body);
  }
}

/// Map all your serializer in a repository
final repository = SerializerRepo(serializers: [
  ResourceSerializer(),
]);

class JaguarConverter extends Converter {
  @override
  Future<T> decodeEntity<T>(entity) async {
    /// handle case when we want to access to Map<String, dynamic> directly
    /// getResource or getMapResource
    /// Avoid dynamic or unconverted value, this could lead to several issues
    if (entity is T) return entity;

    if (entity is Map) {
      final serializer = repository.getByType<T>(T);

      if (serializer == null) {
        /// throw serializer not found error;
        return null;
      }

      return serializer.fromMap(entity);
    }
    return entity;
  }

  @override
  Future encodeEntity<T>(entity) async => repository.to(entity);
}

class ErrorConverter extends Converter {
  final _serializer = ResourceErrorSerializer();

  @override
  Future decodeEntity<T>(entity) async => _serializer.fromMap(entity);

  @override
  encodeEntity<T>(T entity) async => entity;
}
