# Requests

## Path parameters

Use `{}`to specify the name and the position of your parameter directly in the url

```dart
@Get(path: '/{id}')
```

Then bind it to your method using the `Path` annotation.

```dart
Future<Response> getById(@Path() String id);
```

or

```dart
Future<Response> getById(@Path('id') int ref);
```

Chopper will use the `toString` method to concat the url with the parameter.

## Query parameters

Use the `Query` annotation to add query parameters to the url

```dart
Future<Response> search({
    @Query() String name,
    @Query('int') int number,
    @Query('default_value') int def = 42,
});
```

If you prefer to pass to pass a full `Map` you can use the `QueryMap` annotation

```dart
Future<Response> search(@QueryMap() Map<String, dynamic> query);
```

## Request body

Use `Body` annotation to specify data to send.

```dart
@Post(path: "post")
Future<Response> postData(@Body() String data);
```

{% hint style="warning" %}
Chopper does not automatically convert `Object` to `Map`then `JSON`

A [Converter](converters/converters.md) is necessary to do that, see [built\_value\_converter](converters/built-value-converter.md#built-value) for more infos.
{% endhint %}

## Headers

Request headers can be set using [Interceptor](interceptors.md) or [Converter](converters/converters.md), but also on the Method definition.

```dart
@Get(path: '/', headers: {'foo': 'bar'})
Future<Response> fetch();

/// dynamic
@Get(path: '/')
Future<Response> fetch(@Header('foo') String bar);
```

## Send application/x-www-form-urlencoded

If no converter specified and if you are just using `Map<String, String>` as body. This is the default behavior of the http package.

You can also use `FormUrlEncodedConverter` that will add the correct `content-type` and convert simple `Map` into `Map<String, String>` to all request.

```dart
final chopper = ChopperClient(
      converter: FormUrlEncodedConverter(),
);
```

#### On single method

If you wish to do a form urlencoded request on a single request, you can use a factory converter.

```dart
@Post(path: 'form', headers: {contentTypeKey: formEncodedHeaders})
Future<Response> postForm(@Body() Map<String, String> fields);
```

#### Use Field annotation

To specify each fields manually, use the `Field` annotation.

```dart
  @FactoryConverter(request: FormUrlEncodedConverter.requestFactory)
  @Post(path: 'form')
  Future<Response> post(@Field() String foo, @Field('b') int bar);
```

