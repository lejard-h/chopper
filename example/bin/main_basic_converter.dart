import "dart:async";
import 'package:chopper/chopper.dart';
import 'definition/definition.dart';
import 'definition/model.dart';

main() async {
  final chopper = new ChopperClient(
    baseUrl: "http://localhost:8000",
    converter: const ModelConverter(),
    services: [
      // the generated service
      new MyService()
    ],
    /* ResponseInterceptorFunc | RequestInterceptorFunc | ResponseInterceptor | RequestInterceptor */
    interceptors: [authHeader],
    jsonApi: true,
  );

  final myService = chopper.service<MyService>(MyService);

  final response1 = await myService.getResource("1");
  print(response1.body); // undecoded String

  final response2 = await myService.getTypedResource();
  print(response2.body); // decoded Resource

  await myService.newResource(new Resource("3", "Super Name"));
}

Future<Request> authHeader(Request request) async =>
    applyHeader(request, "Authorization", "42");

class ModelConverter extends Converter {
  const ModelConverter();

  @override
  decodeEntity<T>(val) async {
    if (T == Resource && val is Map) {
      return new Resource.fromJson(val);
    }
    return val;
  }

  @override
  encodeEntity(val) async {
    if (val is Resource) {
      return val.toJson();
    }
    return val;
  }
}
