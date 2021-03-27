# FAQ

## \*.chopper.dart not found ?

If you have this error, you probably forgot to run the `build` package. To do that, simply run the following command in your shell.

`pub run build_runner build`

It will generate the code that actually do the HTTP request \(YOUR_FILE.chopper.dart\). If you wish to update the code automatically when you change your definition run the `watch` command.

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

You can use converters for modifying requests and responses.
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

## Runtime baseUrl change

You may need to change the base URL of your network calls during runtime, for example, if you have to use different servers or routes dynamically in your app in case of a "regular" or a "paid" user. You can store the current server base url in your SharedPreferences (encrypt/decrypt it if needed) and use it in an interceptor like this:

```dart
...
(Request request) async =>
              SharedPreferences.containsKey('baseUrl')
                  ? request.copyWith(
                      baseUrl: SharedPreferences.getString('baseUrl'))
                  : request
...
```

## Mock ChopperClient for testing

Chopper is built on top of `http` package.

So, one can just use the mocking API of the HTTP package.
https://pub.dev/documentation/http/latest/testing/MockClient-class.html

Also, you can follow this code by [ozburo](https://github.com/ozburo):

```dart
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

part 'api_service.chopper.dart';

@ChopperApi()
abstract class ApiService extends ChopperService {
  static ApiService create() {
    final client = ChopperClient(
      client: MockClient((request) async {
        Map result = mockData[request.url.path]?.firstWhere((mockQueryParams) {
          if (mockQueryParams['id'] == request.url.queryParameters['id']) return true;
          return false;
        }, orElse: () => null);
        if (result == null) {
          return http.Response(
              json.encode({'error': "not found"}), 404);
        }
        return http.Response(json.encode(result), 200);
      }),
      baseUrl: 'https://mysite.com/api',
      services: [
        _$ApiService(),
      ],
      converter: JsonConverter(),
      errorConverter: JsonConverter(),
    );
    return _$ApiService(client);
  }

  @Get(path: "/get")
  Future<Response> get(@Query() String url);
}
```

## Use Https certificate

Chopper is built on top of `http` package and you can override the inner http client.

```dart
import 'dart:io';
import 'package:http/io_client.dart' as http;

final ioc = new HttpClient();
ioc.findProxy = (url) => 'PROXY 192.168.0.102:9090';
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

The actual implementation of the algorithm above may vary based on how the backend API - more precisely the login and session handling - of your app looks like.
