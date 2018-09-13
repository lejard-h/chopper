import 'package:chopper/chopper.dart';
import 'definition.dart';

main() async {
  final chopper = ChopperClient(
    baseUrl: "http://localhost:8000",
    services: [
      // the generated service
      MyService()
    ],
    jsonApi: true,
  );

  final myService = chopper.service<MyService>(MyService);

  final response = await myService.getMapResource("1");
  print(response.body);

  chopper.close();
}
