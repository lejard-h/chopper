import 'package:chopper/chopper.dart';
import 'package:cancellation_token/cancellation_token.dart';

import 'definition.dart';

Future<void> main() async {
  var token = CancellationToken();
  final chopper = ChopperClient(
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [
      // the generated service
      MyService.create(ChopperClient()),
    ],
    converter: JsonConverter(),
  );

  final myService = chopper.getService<MyService>();


  Future.delayed(Duration(seconds: 2), () {
    token.cancel();
  });

  try {
    final response = await myService.getMapResource('1');
    print(response.body);
  }
  on CancelledException {
    print('cancelled by user!');
  }


  final list = await myService.getListResources();
  print(list.body);

  chopper.dispose();
}