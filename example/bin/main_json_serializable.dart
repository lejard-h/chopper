import "dart:async";
import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper_example/definition.dart';
import 'package:chopper_example/model.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Simple client to have working example without remote server
final client = MockClient((req) async {
  if (req.method == 'POST')
    return http.Response('{"type":"Fatal","message":"fatal erorr"}', 500);
  return http.Response('{"id":"1","name":"Foo"}', 200);
});

main() async {
  final chopper = ChopperClient(
    client: client,
    baseUrl: "http://localhost:8000",
    // bind your object factories here
    converter: JsonSerializableConverter(
      {
        Resource: Resource.fromJsonFactory,
      },
    ),
    errorConverter: ErrorConverter(),
    services: [
      // the generated service
      MyService.create(),
    ],
    /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
    interceptors: [authHeader],
    jsonApi: true,
  );

  final myService = chopper.service<MyService>(MyService);

  final response1 = await myService.getResource("1");
  print(response1.body); // undecoded String

  final response2 = await myService.getTypedResource();
  print(response2.body); // decoded Resour

  final response3 = await myService.getMapResource("1");
  print(response3.body); // undecoded Stringce

  try {
    await myService.newResource(Resource("3", "Super Name"));
  } on Response catch (error) {
    print(error.body);
  }
}

Future<Request> authHeader(Request request) async => applyHeader(
      request,
      "Authorization",
      "42",
    );

typedef T JsonFactory<T>(Map<String, dynamic> json);

class JsonSerializableConverter extends Converter {
  final Map<Type, JsonFactory> factories;

  JsonSerializableConverter(this.factories);

  T _decode<T>(Map<String, dynamic> values) {
    /// Get jsonFactory using Type parameters
    /// if not found or invalid, throw error or return null
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
      /// throw serializer not found error;
      return null;
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(List values) =>
      values.where((v) => v != null).map((v) => _decode<T>(v)).toList();

  @override
  Future decodeEntity<T>(entity) async {
    if (entity == null) return null;

    /// handle case when we want to access to Map<String, dynamic> directly
    /// getResource or getMapResource
    /// Avoid dynamic or unconverted value, this could lead to several issues
    if (entity is T) return entity;

    if (entity is Iterable) return _decodeList<T>(entity);

    return _decode<T>(entity);
  }

  @override
  encodeEntity<T>(T entity) async => entity;
}

class ErrorConverter extends Converter {
  @override
  Future decodeEntity<T>(entity) async => ResourceError.fromJsonFactory(entity);

  @override
  encodeEntity<T>(T entity) async => entity;
}
