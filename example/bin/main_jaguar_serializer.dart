import 'package:chopper/chopper.dart';
import 'package:chopper_example/definition.dart';
import 'package:chopper_example/jaguar_serializer.dart';
import 'package:chopper_example/model.dart';

main() async {
  final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    converter: JaguarConverter(),
    services: [
      // the generated service
      MyService(),
    ],
    jsonApi: true,
  );

  final myService = chopper.service<MyService>(MyService);

  final response1 = await myService.getResource("1");
  print(response1.body); // undecoded String

  final response2 = await myService.getTypedResource();
  print(response2.body); // decoded Resource

  await myService.newResource(Resource("3", "Super Name"));
}
