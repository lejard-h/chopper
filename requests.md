# Requests

## Path resolution

Chopper handles paths passed to HTTP verb annotations' `path` parameter based on the path's content.

If the `path` value is a relative path, it will be concatenated to the URL composed of the `baseUrl` of the `ChopperClient` and the `baseUrl` of the enclosing service class (provided as a parameter of the `@ChopperApi` annotation).

Here are a few examples of the described behavior:

 * `ChopperClient` base URL: https://example.com/
    Path: profile
    Result: https://example.com/profile

* `ChopperClient` base URL: https://example.com/
  Service base URL: profile
  Path: /image
  Result: https://example.com/profile/image

* `ChopperClient` base URL: https://example.com/
  Service base URL: profile
  Path: image
  Result: https://example.com/profile/image

> Chopper detects and handles missing slash (`/`) characters on URL segment borders, but *does not* handle duplicate slashes.

If the service's `baseUrl` concatenated with the request's `path` results in a full URL, the `ChopperClient`'s `baseUrl` is ignored.

`ChopperClient` base URL: https://example.com/
Service base URL: https://api.github.com/
Path: user
Result: https://api.github.com/user

A `path` containing a full URL replaces the base URLs of both the `ChopperClient` and the service class entirely for a request.

* `ChopperClient` base URL: https://example.com/
  Path: https://api.github.com/user
  Result: https://api.github.com/user
* `ChopperClient` base URL: https://example.com/
  Service base URL: profile
  Path: https://api.github.com/user
  Result: https://api.github.com/user


## Path parameters

Path parameters can be defined in the URL with replacement blocks. A replacement block is an alphanumeric substring of the path surrounded by `{` and `}`. In the following example `{id}` is a replacement block.

```dart
@Get(path: "/{id}")
```

Use the `@Path()` annotation to bind a parameter to a replacement block. This way the parameter's name must match a replacement block's string.

```dart
@Get(path: "/{id}")
Future<Response> getItemById(@Path() String id);
```

As an alternative, you can set the `@Path` annotation's `name` parameter to match a replacement block's string while using a different parameter name, like in the following example:

```dart
@Get(path: "/{id}")
Future<Response> getItemById(@Path("id") int itemId);
```

> Chopper uses String interpolation to replace replacement blocks with the provided values in the request URLs.

## Query parameters

Use the `Query` annotation to add query parameters to the url

```dart
Future<Response> search({
    @Query() String name,
    @Query("int") int number,
    @Query("default_value") int def = 42,
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
Chopper does not automatically convert `Object` to `Map`then `JSON`.

A [Converter](converters/converters.md) is needed to do that, see [built\_value\_converter](converters/built-value-converter.md#built-value) for more infos.
{% endhint %}

## Headers

Request headers can be set using [Interceptor](interceptors.md) or [Converter](converters/converters.md), but also on the Method definition.

```dart
@Get(path: ""/"", headers: {"foo": "bar"})
Future<Response> fetch();

/// dynamic
@Get(path: ""/"")
Future<Response> fetch(@Header("foo") String bar);
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
@Post(path: "form", headers: {contentTypeKey: formEncodedHeaders})
Future<Response> postForm(@Body() Map<String, String> fields);
```

#### Use Field annotation

To specify each fields manually, use the `Field` annotation.

```dart
  @FactoryConverter(request: FormUrlEncodedConverter.requestFactory)
  @Post(path: "form")
  Future<Response> post(@Field() String foo, @Field("b") int bar);
```

