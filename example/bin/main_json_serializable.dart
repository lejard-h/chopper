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

class JsonSerializableConverter extends JsonConverter {
  final Map<Type, JsonFactory> factories;

  JsonSerializableConverter(this.factories);

  T _decodeMap<T>(Map<String, dynamic> values) {
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

  dynamic _decode<T>(entity) {
    if (entity is Iterable) return _decodeList<T>(entity);

    if (entity is Map) return _decodeMap<T>(entity);

    return entity;
  }

  @override
  Response convertResponse<T>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse(response);

    return jsonRes.replace(
      body: _decode<T>(response.body),
    );
  }

  @override
  // all objects should implements toJson method
  Request convertRequest(Request request) => super.convertRequest(request);
}

class ErrorConverter extends JsonConverter {
  @override
  Response convertResponse<ConvertedResponseType>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse(response);

    return jsonRes.replace(
      body: ResourceError.fromJsonFactory(response.body),
    );
  }
}
