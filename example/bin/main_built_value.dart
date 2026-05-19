import 'package:built_value/standard_json_plugin.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper_built_value/chopper_built_value.dart';
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
  if (req.url.path == '/resources/available') {
    final visitType = req.url.queryParameters['visit_type'];
    return http.Response('{"id":"$visitType","name":"Visit"}', 200);
  }

  return http.Response('{"id":"1","name":"Foo"}', 200);
});

Future<void> main() async {
  final chopper = ChopperClient(
    client: client,
    baseUrl: Uri.parse('http://localhost:8000'),
    converter: BuiltValueConverter(jsonSerializers),
    errorConverter: BuiltValueConverter(
      jsonSerializers,
      errorType: ResourceError,
    ),
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

  final response4 = await myService.getAvailableResource(VisitType.faceToFace);
  print('response 4: ${response4.body}');

  try {
    final builder = ResourceBuilder()
      ..id = '3'
      ..name = 'Super Name';
    await myService.newResource(builder.build());
  } on Response catch (error) {
    print(error.body);
  }
}
