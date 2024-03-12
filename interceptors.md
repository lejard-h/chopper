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

## Breaking out of an interceptor

In some cases you may run into a case where it's not possible to continue within an interceptor and want to break out/cancel the request. This can be achieved by throwing an exception.
This will not return a response and the request will not be executed.

>Keep in mind that when throwing an exception you also need to handle/catch the exception in calling code.

For example if you want to stop the request if the token is expired:

```dart
class AuthInterceptor implements Interceptor {

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = applyHeader(chain.request, 'authorization',
        SharedPrefs.localStorage.getString(tokenHeader),
        override: false);
   
    final response = await chain.proceed(request);
   
    if (response?.statusCode == 401) {
      // Refreshing fails
      final bool isRefreshed = await _refreshToken();
      if(!isRefreshed){
        // Throw a exception to stop the request. 
        throw Exception('Token expired');
      }
    }
    
    return response;
  }
}
```

It's not strictly needed to throw an exception in order to break out of the interceptor. 
Other construction can also be used depending on how the project is structured.
Another could be calling a service that is injected or providing a callback that handles the state of the app.

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

