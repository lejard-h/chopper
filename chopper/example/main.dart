import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptor.dart';
import 'definition.dart';

Future<void> main() async {
  final chopper = ChopperClient(
    baseUrl: 'http://localhost:8000',
    services: [
      // the generated service
      MyService.create(ChopperClient())
    ],
    converter: JsonConverter(),
  );

  final myService = chopper.getService<MyService>();

  final response = await myService.getMapResource('1');
  print(response.body);

  final list = await myService.getListResources();
  print(list.body);

  chopper.dispose();
}
