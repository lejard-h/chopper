import 'package:chopper/chopper.dart';
import 'package:chopper_example/jaguar_serializer.dart';
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
final repository = SerializerRepoImpl(serializers: [
  ResourceSerializer(),
]);

class JaguarConverter extends JsonConverter {
  dynamic _decode<ConvertedResponseType>(entity) {
    /// handle case when we want to access to Map<String, dynamic> directly
    /// getResource or getMapResource
    /// Avoid dynamic or unconverted value, this could lead to several issues
    if (entity is ConvertedResponseType) return entity;

    final serializer = repository.getByType<ConvertedResponseType>(
      ConvertedResponseType,
    );

    /// throw serializer not found error;
    if (serializer == null) return null;

    if (entity is Map) return serializer.fromMap(entity);

    if (entity is List) return serializer.fromList(entity);

    return entity;
  }

  @override
  Response convertResponse<ConvertedResponseType>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse<ConvertedResponseType>(response);

    return jsonRes.replace<ConvertedResponseType>(
      body: _decode<ConvertedResponseType>(jsonRes.body),
    );
  }

  @override
  Request convertRequest(Request request) => super.convertRequest(
        request.replace(
          body: repository.to(request.body),
        ),
      );
}

class ErrorConverter extends JsonConverter {
  final _serializer = ResourceErrorSerializer();

  @override
  Response convertResponse<ConvertedResponseType>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse(response);

    return jsonRes.replace(
      body: _serializer.fromMap(jsonRes.body),
    );
  }

  @override
  Request convertRequest(Request request) => request;
}
