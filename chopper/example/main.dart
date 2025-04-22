import 'package:chopper/chopper.dart';
import 'package:cancellation_token/cancellation_token.dart';

import 'definition.dart';

Future<void> main() async {
  final chopper = ChopperClient(
    cancellationToken: CancellationToken(),
    baseUrl: Uri.parse('http://localhost:8000'),
    services: [
      // the generated service
      MyService.create(ChopperClient()),
    ],
    converter: JsonConverter(),
  );

  final myService = chopper.getService<MyService>();

  // cancel request after 2 seconds
  Future.delayed(Duration(seconds: 2), () {
    chopper.cancelRequests();
  });

  try {
    final response = await myService.getLongTimeTest();
    print(response.body);
  }
  on CancelledException {
    print('cancelled by user!!!!!');
  }

  // cancel request after 2 seconds
  Future.delayed(Duration(seconds: 5), () {
    chopper.cancelRequests();
  });

  try {
    final response = await myService.getLongTimeTest();
    print(response.body);
  }
  on CancelledException {
    print('cancelled by user too!!');
  }




  // final list = await myService.getListResources();
  // print(list.body);

  chopper.dispose();
}