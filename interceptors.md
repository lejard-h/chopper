# Interceptors

## **Request**

Implement `Interceptor` class.

{% hint style="info" %}
Request interceptor are called just before sending request.
{% endhint %}

```dart
class MyRequestInterceptor implements Interceptor {
  
  MyRequestInterceptor(this.token);
  
  final String token;
  
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = applyHeader(chain.request, 'auth_token', 'Bearer $token');
    return chain.proceed(request);
  }
}
```

## **Response**

Implement `Interceptor` class.

{% hint style="info" %}
Called after successful or failed request.
{% endhint %}

```dart
class MyResponseInterceptor implements Interceptor {
  MyResponseInterceptor(this._token);
  
  String _token;
  
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final response = await chain.proceed(chain.request);
    _token = response.headers['auth_token'];
    return response;
  }
}
```

## Builtins
* [CurlInterceptor](https://pub.dev/documentation/chopper/latest/chopper/CurlInterceptor-class.html): Interceptor that prints curl commands for each execute request
* [HeadersInterceptor](https://pub.dev/documentation/chopper/latest/chopper/HeadersInterceptor-class.html): Interceptor that adds headers to each request
* [HttpLoggingInterceptor](https://pub.dev/documentation/chopper/latest/chopper/HttpLoggingInterceptor-class.html): Interceptor that logs request and response data

Both the `CurlInterceptor` and `HttpLoggingInterceptor` use the dart [logging package](https://pub.dev/packages/logging). 
In order to see logging in console the logging package also needs to be added to your project and configured.

For example:
```dart
Logger.root.level = Level.ALL; // defaults to Level.INFO
Logger.root.onRecord.listen((record) {
  print('${record.level.name}: ${record.time}: ${record.message}');
});
```

