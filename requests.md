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

* `ChopperClient` base URL: https://example.com/  
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

Dynamic path parameters can be defined in the URL with replacement blocks. A replacement block is an alphanumeric substring of the path surrounded by `{` and `}`. In the following example `{id}` is a replacement block.

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

Dynamic query parameters can be added to the URL by adding parameters to a request method annotated with the `@Query` annotation. Default values are supported.

```dart
Future<Response> search(
    @Query() String name, {
    @Query("count") int numberOfResults = 42,
});
```

If the parameter of the `@Query` annotation is not set, Chopper will use the actual name of the annotated parameter as the key for the query parameter in the URL.

If you prefer to pass a `Map` of query parameters, you can do so with the `@QueryMap` annotation.

```dart
Future<Response> search(@QueryMap() Map<String, dynamic> query);
```

## Request body

Use the `@Body` annotation on a request method parameter to specify data that will be sent as the request's body.

```dart
@Post(path: "todo/create")
Future<Response> postData(@Body() String data);
```

{% hint style="warning" %}
Chopper does not automatically convert `Object`s to `Map`then `JSON`.

You have to pass a [Converter](converters/converters.md) instance to a `ChopperClient` for JSON conversion to happen. See [built\_value\_converter](converters/built-value-converter.md#built-value) for an example Converter implementation.
{% endhint %}

## Headers

Request headers can be set by providing a `Map<String, String>` object to the `headers` parameter each of the HTTP verb annotations have.

```dart
@Get(path: "/", headers: {"foo": "bar"})
Future<Response> fetch();
```

The `@Header` annotation can be used on method parameters to set headers dynamically for each request call. 

```dart
@Get(path: "/")
Future<Response> fetch(@Header("foo") String bar);
```

> Setting request headers dynamically is also supported by [Interceptors](interceptors.md) and [Converters](converters/converters.md).
>
> As Chopper invokes Interceptors and Converter(s) *after* creating a Request, Interceptors and Converters *can* override headers set with the `headers` parameter or `@Header` annotations.

## Sending `application/x-www-form-urlencoded` data

If no Converter is specified for a request (neither on a `ChopperClient` nor with the `@FactoryConverter` annotation) and the request body is of type `Map<String, String>`, the body will be sent as form URL encoded data.

> This is the default behavior of the http package.

You can also use `FormUrlEncodedConverter` that will add the correct `content-type` and convert a `Map` into `Map<String, String>` for requests.

```dart
final chopper = ChopperClient(
      converter: FormUrlEncodedConverter(),
);
```

### On a single method

To do only a single type of request with form encoding in a service, use the provided `FormUrlEncodedConverter`'s `requestFactory` method with the `@FactoryConverter` annotation.

```dart
@Post(
  path: "form", 
  headers: {contentTypeKey: formEncodedHeaders},
)
@FactoryConverter(
  request: FormUrlEncodedConverter.requestFactory,
)
Future<Response> postForm(@Body() Map<String, String> fields);
```

### Defining fields individually

To specify fields individually, use the `@Field` annotation on method parameters. If the field's name is not provided, the parameter's name is used as the field's name.

```dart
@Post(path: "form")
@FactoryConverter(
  request: FormUrlEncodedConverter.requestFactory,
)
Future<Response> post(@Field() String foo, @Field("b") int bar);
```

## Sending files

