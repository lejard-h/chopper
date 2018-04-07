import "dart:async";
import 'package:chopper/chopper.dart';
import 'converter.dart';
import 'definition.dart';
import 'model.dart';

main() async {
  final chopper = new ChopperClient(
      baseUrl: "http://localhost:8000",
      converter: const ModelConverter(),
      services: [
        // the generated service
        new MyService()
      ],
      /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
      interceptors: [
        new Headers(const {"Content-Type": "application/json"}),
        authHeader
      ]);

  final myService = chopper.service(MyService) as MyService;

  final response1 = await myService.getResource("1");
  print(response1.body); // undecoded String

  final response2 = await myService.getTypedResource();
  print(response2.body); // decoded Resource

  await myService.newResource(new Resource("3", "Super Name"));
}

Future<Request> authHeader(Request request) async =>
    applyHeader(request, "Authorization", "42");
