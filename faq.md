# FAQ

## \*.chopper.dart not found ?

If you have this error, you probably forgot to run the `build` package. To do that, simply run the following command in your shell.

`pub run build_runner build`

It will generate the code that actually do the HTTP request \(YOUR\_FILE.chopper.dart\). If you wish to update the code automatically when you change your definition run the `watch` command.

`pub run build_runner watch`

## How to increase timeout ?

Connection timeout is very limited for now due to http package \(see: [dart-lang/http\#21](https://github.com/dart-lang/http/issues/21)\)

But if you are on VM or Flutter you can set the `connectionTimeout` you want

```dart
import 'package:http/io_client.dart' as http;
import 'dart:io';

final chopper = ChopperClient(
    client: http.IOClient(
      HttpClient()..connectionTimeout = const Duration(seconds: 60),
    ),
  );
```

## Add query parameter to all requests

Possible using an interceptor.

```dart
final chopper = ChopperClient(
    interceptors: [_addQuery],
);

Request _addQuery(Request req) {
  final params = Map<String, dynamic>.from(req.parameters);
  params['key'] = '123';

  return req.copyWith(parameters: params);
}
```

## GZip converter example
You can use converters for anything you want to modify the requests / responses.
For example, to use GZip for post request you can write something like this:

```dart
Request compressRequest(Request request) {
  request = applyHeader(request, 'Content-Encoding', 'gzip');
  request = request.replace(body: gzip.encode(request.body));
  return request;
}

...

@FactoryConverter(request: compressRequest)
@Post()
Future<Response> postRequest(@Body() Map<String, String> data);
```

## Use Https certificate

Chopper is built on top of `http` package and you can override the inner http client.

```dart
import 'dart:io';
import 'package:http/io_client.dart' as http;

final ioc = new HttpClient();
ioc.badCertificateCallback = (X509Certificate cert, String host, int port)
  => true;

final chopper = ChopperClient(
  client: http.IOClient(ioc),
);
```

