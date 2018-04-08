import 'package:chopper/chopper.dart';
import 'definition.dart';

main() async {
  final chopper = new ChopperClient(
      baseUrl: "http://localhost:8000",
      converter: const JsonConverter(),
      apis: [
        // the generated service
        new MyService()
      ],
      /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
      interceptors: [
        new Headers(const {"Content-Type": "application/json"}),
      ]);

  final myService = chopper.service(MyService) as MyService;

  final response = await myService.getMapResource("1");
  print(response.body);
}
