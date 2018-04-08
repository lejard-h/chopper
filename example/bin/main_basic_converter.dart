import "dart:async";
import 'package:chopper/chopper.dart';
import 'definition/definition.dart';
import 'definition/model.dart';

main() async {
  final chopper = new ChopperClient(
      baseUrl: "http://localhost:8000",
      converter: const ModelConverter(),
      apis: [
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


class ModelConverter extends JsonConverter {
  const ModelConverter();

  @override
  Future<Response> decode(Response response, Type responseType) async {
    final d = await super.decode(response, responseType);
    var body = d.body;
    if (responseType == Resource) {
      body = new Resource.fromJson(body as Map<String, dynamic>);
    }
    return response.replace(body: body);
  }

  @override
  Future<Request> encode(Request request) {
    var body = request.body;
    if (request.body is Resource) {
      body = (request.body as Resource).toJson();
    }
    return super.encode(request.replace(body: body));
  }
}