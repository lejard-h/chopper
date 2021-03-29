# Converters

Converters are used to apply transformations on request and/or response bodies, for example, transforming a Dart object to a `Map<String, dynamic>` or vice versa.

Both `converter` and `errorConverter` are called before request and response interceptors.

```dart
final chopper = ChopperClient(
   converter: JsonConverter(),
   errorConverter: JsonConverter()
);
```

{% hint style="info" %}
The `errorConverter` is called only on error responses (statusCode < 200 || statusCode >= 300).
{% endhint %}

## The built-in JSON converter

Chopper provides a `JsonConverter` that is able to encode data to JSON and decode JSON strings. It will also apply the correct header to the request \(application/json\).

However, if content type header is modified (for example by using `@Post(headers: {'content-type': '...'})`), `JsonConverter` won't add the header and it won't call json.encode if content type is not JSON.

{% hint style="danger" %}
`JsonConverter` itself won't convert a Dart object into a `Map<String, dynamic>` or a `List`, but it will convert a `Map<String, dynamic>` into a JSON string.
{% endhint %}

## Implementing custom converters

You can implement custom converters by implementing the `Converter` class.

```dart
class MyConverter implements Converter {
  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    var body = response.body;
    // Convert body to BodyType however you like
    response.copyWith<BodyType>(body: body);
  }

  @override
  Request convertRequest(Request request) {
    var body = request.body;
    // Convert body to String however you like    
    return request.copyWith(body: body);
  }
}
```

`BodyType`is the expected type of the response body \(e.g., `String` or `CustomObject`).

If `BodyType` is a `List` or a `BuiltList`, `InnerType` is the type of the generic parameter \(e.g., `convertResponse<List<CustomObject>, CustomObject>(response)`).

## Using different converters for specific endpoints

If you want to apply specific converters only to a single endpoint, you can do so by using the `@FactoryConverter` annotation:

```dart
@ChopperApi(baseUrl: "/todos")
abstract class TodosListService extends ChopperService {

  @FactoryConverter(
      request: FormUrlEncodedConverter.requestFactory,
      response: convertResponse,
  )
  @Post(path: '/')
  Future<Response> post(@Field() String foo, @Field() int bar);

}

Response<T> convertResponse<T>(Response res) =>
    JsonConverter().convertResponse(res);
```
