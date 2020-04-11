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

## Authorized HTTP requests

Basically, the algorithm goes like this (credits to [stewemetal](https://github.com/stewemetal)):

Add the authentication token to the request (by "Authorization" header, for example) -> try the request -> if it fails use the refresh token to get a new auth token ->
  if that succeeds, save the auth token and retry the original request with it
  if the refresh token is not valid anymore, drop the session (and navigate to the login screen, for example)

Simple code example:
```dart
interceptors: [
  // Auth Interceptor
  (Request request) async => applyHeader(request, 'authorization',
      SharedPrefs.localStorage.getString(tokenHeader),
      override: false),
  (Response response) async {
    if (response?.statusCode == 401) {
      SharedPrefs.localStorage.remove(tokenHeader);
      // Navigate to some login page or just request new token
    }
    return response;
  },
]
```

Of course, the actual implementation may vary based on how the backend API of your project looks like.
