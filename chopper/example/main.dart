import 'package:chopper/chopper.dart';
import 'package:cancellation_token/cancellation_token.dart';

import 'definition.dart';

Future<void> main() async {
  var token = CancellationToken();

  final chopper = ChopperClient(
    cancellationToken: token,
    baseUrl: Uri.parse('https://tipster-backend-pr-11.onrender.com'),
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
    final response = await myService.getLongTimeTest();
    print(response.body);
  }
  on CancelledException {
    print('cancelled by user!!!!!');
  }




  // final list = await myService.getListResources();
  // print(list.body);

  chopper.dispose();
}
