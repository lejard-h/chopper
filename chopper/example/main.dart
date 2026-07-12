import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'definition.dart';

Future<void> main() async {
  final chopper = ChopperClient(
    client: MockClient((request) async {
      if (request.url.path == '/resources/resources') {
        return http.Response('[{"id":"1","name":"Foo"}]', 200);
      }
      if (request.url.path == '/resources/search' &&
          request.method == HttpMethod.Query) {
        final query = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'query': query, 'matches': 1}),
          200,
          headers: {contentTypeKey: jsonHeaders},
        );
      }

      return http.Response('{"id":"1","name":"Foo"}', 200);
    }),
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [
      // the generated service
      MyService.create(),
    ],
    converter: JsonConverter(),
  );

  final myService = chopper.getService<MyService>();

  final response = await myService.getMapResource('1');
  print(response.body);

  final list = await myService.getListResources();
  print(list.body);

  final search = await myService.searchResources({
    'term': 'chopper',
    'limit': 10,
  });
  print(search.body);

  chopper.dispose();
}
