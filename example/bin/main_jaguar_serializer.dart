import 'package:chopper/chopper.dart';
import 'package:chopper_example/jaguar_serializer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

/// Simple client to have working example without remote server
final client = MockClient((req) async {
  if (req.method == 'POST')
    return http.Response('{"type":"Fatal","message":"fatal erorr"}', 500);
  if (req.method == 'GET' && req.headers['test'] == 'list')
    return http.Response('[{"id":"1","name":"Foo"}]', 200);
  return http.Response('{"id":"1","name":"Foo"}', 200);
});

main() async {
  final chopper = new ChopperClient(
    client: client,
    baseUrl: "http://localhost:8000",
    converter: JaguarConverter(),
    errorConverter: JaguarConverter(),
    services: [
      // the generated service
      MyService.create(),
    ],
  );

  final myService = chopper.getService<MyService>();

  final response1 = await myService.getResource("1");
  print('response 1: ${response1.body}'); // undecoded String

  final response2 = await myService.getResources();
  print('response 2: ${response2.body}'); // decoded list of Resources

  final response3 = await myService.getTypedResource();
  print('response 3: ${response3.body}'); // decoded Resource

  final response4 = await myService.getMapResource("1");
  print('response 4: ${response4.body}'); // undecoded Resource

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
  dynamic _decode<Item>(entity) {
    /// handle case when we want to access to Map<String, dynamic> directly
    /// getResource or getMapResource
    /// Avoid dynamic or unconverted value, this could lead to several issues
    if (entity is Item) return entity;

    final serializer = repository.getByType<Item>(
      Item,
    );

    /// throw serializer not found error;
    if (serializer == null) return null;

    if (entity is Map) return serializer.fromMap(entity);

    if (entity is List) return serializer.fromList(entity.cast<Map>());

    return entity;
  }

  @override
  Response<ResultType> convertResponse<ResultType, Item>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse<ResultType, Item>(response);

    return jsonRes.copyWith<ResultType>(
      body: _decode<Item>(jsonRes.body),
    );
  }

  @override
  Request convertRequest(Request request) => super.convertRequest(
        request.copyWith(
          body: repository.to(request.body),
        ),
      );

  final _errorSerializer = ResourceErrorSerializer();

  @override
  Response convertError<ResultType, ItemType>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertError(response);
    return jsonRes.copyWith(body: _errorSerializer.fromMap(jsonRes.body));
  }
}
