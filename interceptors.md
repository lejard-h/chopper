# Interceptors

## **Request**

Implement `RequestInterceptor` class or define function with following signature `FutureOr<Request> RequestInterceptorFunc(Request request)`

Request interceptor are called just before sending request

```dart
final chopper = new ChopperClient(
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
final chopper = new ChopperClient(
   interceptors: [
     (Response response) async => response.replace(body: {}),
   ]
);
```

## Builtins

* [CurlInterceptor](https://pub.dev/documentation/chopper/latest/chopper/CurlInterceptor-class.html)
* [HttpLoggingInterceptor](https://pub.dev/documentation/chopper/latest/chopper/HttpLoggingInterceptor-class.html)

