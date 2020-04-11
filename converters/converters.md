# Converters

Converter are used to apply transformation to a request or response body, for example transforming a Dart object to a `Map<String, dynamic>`

Both `converter` and `errorConverter` are called before request and response interceptors.

```dart
final chopper = new ChopperClient(
   converter: JsonConverter(),
   errorConverter: JsonConverter()
);
```

{% hint style="info" %}
`errorConverter` is called only on error response \(statusCode &lt; 200 \|\| statusCode &gt;= 300\)
{% endhint %}

## JSON

Chopper integrate a `JsonConverter` that take care of encoding data to JSON and decoding JSON string. It will also apply the correct header to the request \(application/json\).

However, if content type header is overrided using`@Post(headers: {'content-type': '...'})`The converter won't add json header and won't apply json.encode if content type is not JSON.

{% hint style="danger" %}
`JsonConverter` won't convert a Dart object into a `Map<String, dynamic>` or a `List`, but it will convert the `Map<String, dynamic>` into a JSON string.
{% endhint %}

## Custom converter

You can implement a converter by implementing the `Converter` class.

```dart
class MyConverter implements Converter {
  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response res) {
   return res;
  }

  @override
  Request convertRequest(Request req) {
    return req;
  }
}
```

`BodyType`is the expected type of your response \(ex: `String` or `CustomObject)`

 In the case of `BodyType` is a `List` or `BuildList`, `InnerType` will be the type of the generic \(ex: `convertResponse<List<CustomObject>, CustomObject>(response)` \)

## Factory Converter

In case you want to apply a converter to a single endpoint, you can use a `FactoryConverter`

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
