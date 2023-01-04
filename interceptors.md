# Interceptors

## **Request**

Implement `RequestInterceptor` class or define function with following signature `FutureOr<Request> RequestInterceptorFunc(Request request)`

Request interceptor are called just before sending request

```dart
final chopper = ChopperClient(
   interceptors: [
     (request) async => request.copyWith(body: {}),
   ]
);
```

## **Response**

Implement `ResponseInterceptor` class or define function with following signature `FutureOr<Response> ResponseInterceptorFunc(Response response)`

{% hint style="info" %}
Called after successful or failed request
{% endhint %}

```dart
final chopper = ChopperClient(
   interceptors: [
     (Response response) async => response.replace(body: {}),
   ]
);
```

## Builtins

* [CurlInterceptor](https://pub.dev/documentation/chopper/latest/chopper/CurlInterceptor-class.html)
* [HttpLoggingInterceptor](https://pub.dev/documentation/chopper/latest/chopper/HttpLoggingInterceptor-class.html)

Both the `CurlInterceptor` and `HttpLoggingInterceptor` use the dart [logging package](https://pub.dev/packages/logging). 
In order to see logging in console the logging package also needs to be added to your project and configured.

For example:
```dart
Logger.root.level = Level.ALL; // defaults to Level.INFO
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});
```

