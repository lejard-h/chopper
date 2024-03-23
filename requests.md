# Requests

## Available Request annotations

| Annotation                                 | HTTP verb | Description                                            |
|--------------------------------------------|-----------|--------------------------------------------------------|
| `@Get()`, `@get`                           | `GET`     | Defines a `GET` request.                               |
| `@Post()`, `@post`                         | `POST`    | Defines a `POST` request.                              |
| `@Put()`, `@put`                           | `PUT`     | Defines a `PUT` request.                               |
| `@Patch()`, `@patch`                       | `PATCH`   | Defines a `PATCH` request.                             |
| `@Delete()`, `@delete`                     | `DELETE`  | Defines a `DELETE` request.                            |
| `@Head()`, `@head`                         | `HEAD`    | Defines a `HEAD` request.                              |
| `@Body()`, `@body`                         | -         | Defines the request's body.                            |
| `@FormUrlEncoded`, `@formUrlEncoded`       | -         | Defines a `application/x-www-form-urlencoded` request. |
| `@Multipart()`, `@multipart`               | -         | Defines a `multipart/form-data` request.               |         
| `@Query()`, `@query`                       | -         | Defines a query parameter.                             |             
| `@QueryMap()`, `@queryMap`                 | -         | Defines a query parameter map.                         |          
| `@FactoryConverter()`, `@factoryConverter` | -         | Defines a request/response converter factory.          |  
| `@Field()`, `@field`                       | -         | Defines a form field.                                  |             
| `@FieldMap()`, `@fieldMap`                 | -         | Defines a form field map.                              |          
| `@Part()`, `@part`                         | -         | Defines a multipart part.                              |              
| `@PartMap()`, `@partMap`                   | -         | Defines a multipart part map.                          |           
| `@PartFile()`, `@partFile`                 | -         | Defines a multipart file part.                         |          
| `@PartFileMap()`, `@partFileMap`           | -         | Defines a multipart file part map.                     |
| `@Tag`, `@tag`                             | -         | Defines a tag parameter.                               |              


## Path resolution

Chopper handles paths passed to HTTP verb annotations' `path` parameter based on the path's content.

If the `path` value is a relative path, it will be concatenated to the URL composed of the `baseUrl` of
the `ChopperClient` and the `baseUrl` of the enclosing service class (provided as a parameter of the `@ChopperApi`
annotation).

Here are a few examples of the described behavior:

| Variable   | URI                         |
|------------|-----------------------------|
| base URL   | https://example.com/        |  
| Path       | profile                     |
| **Result** | https://example.com/profile |

| Variable         | URI                               |
|------------------|-----------------------------------|
| base URL         | https://example.com/              |  
| Service base URL | profile                           |
| Path             | /image                            |
| **Result**       | https://example.com/profile/image |

| Variable         | URI                               |
|------------------|-----------------------------------|
| base URL         | https://example.com/              |  
| Service base URL | profile                           |
| Path             | image                             |
| **Result**       | https://example.com/profile/image |

> Chopper detects and handles missing slash (`/`) characters on URL segment borders, but *does not* handle duplicate
> slashes.

If the service's `baseUrl` concatenated with the request's `path` results in a full URL, the `ChopperClient`'s `baseUrl`
is ignored.

| Variable         | URI                         |
|------------------|-----------------------------|
| base URL         | https://example.com/        |  
| Service base URL | https://api.github.com/     |
| Path             | user                        |
| **Result**       | https://api.github.com/user |

A `path` containing a full URL replaces the base URLs of both the `ChopperClient` and the service class entirely for a
request.

| Variable   | URI                         |
|------------|-----------------------------|
| base URL   | https://example.com/        |  
| Path       | https://api.github.com/user |
| **Result** | https://api.github.com/user |

| Variable         | URI                         |
|------------------|-----------------------------|
| base URL         | https://example.com/        |  
| Service base URL | profile                     |
| Path             | https://api.github.com/user |
| **Result**       | https://api.github.com/user |

## Path parameters

Dynamic path parameters can be defined in the URL with replacement blocks. A replacement block is an alphanumeric
substring of the path surrounded by `{` and `}`. In the following example `{id}` is a replacement block.

```dart
@Get(path: "/{id}")
```

Use the `@Path()` annotation to bind a parameter to a replacement block. This way the parameter's name must match a
replacement block's string.

```dart
@Get(path: "/{id}")
Future<Response> getItemById(@Path() String id);
```

As an alternative, you can set the `@Path` annotation's `name` parameter to match a replacement block's string while
using a different parameter name, like in the following example:

```dart
@Get(path: "/{id}")
Future<Response> getItemById(@Path("id") int itemId);
```

> Chopper uses String interpolation to replace replacement blocks with the provided values in the request URLs.

## Query parameters

Dynamic query parameters can be added to the URL by adding parameters to a request method annotated with the `@Query`
annotation. Default values are supported.

```dart
Future<Response> search(
    @Query() String name, {
    @Query("count") int numberOfResults = 42,
});
```

If the parameter of the `@Query` annotation is not set, Chopper will use the actual name of the annotated parameter as
the key for the query parameter in the URL.

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

You have to pass a [Converter](converters/converters.md) instance to a `ChopperClient` for JSON conversion to happen.
See [built\_value\_converter](converters/built-value-converter.md#built-value) for an example Converter implementation.
{% endhint %}

## Headers

Request headers can be set by providing a `Map<String, String>` object to the `headers` parameter each of the HTTP verb
annotations have.

```dart
@Get(path: "/", headers: {"foo": "bar"})
Future<Response> fetch();
```

The `@Header` annotation can be used on method parameters to set headers dynamically for each request call.

```dart
@Get(path: "/")
Future<Response> fetch(@Header("foo") String bar);
```

> Setting request headers dynamically is also supported by [Interceptors](interceptors.md)
> and [Converters](converters/converters.md).
>
> As Chopper invokes Interceptors and Converter(s) *after* creating a Request, Interceptors and Converters *can*
> override headers set with the `headers` parameter or `@Header` annotations.

## Sending `application/x-www-form-urlencoded` data

If no Converter (neither on a `ChopperClient` nor with the `@FactoryConverter` annotation) or formUrlEncoded (`@FormUrlEncoded` annotation) is specified for a request
and the request body is of type `Map<String, String>`, the body will be sent as form URL encoded data.

> This is the default behavior of the http package.

### FormUrlEncoded annotation

We recommend annotation `@formUrlEncoded` on method that will add the correct `content-type` and convert a `Map`
into `Map<String, String>` for requests.

```dart
@Post(
  path: "form",
)
@formUrlEncoded
Future<Response> postForm(@Body() Map<String, String> fields);
```

### FormUrlEncodedConverter

you can also use `FormUrlEncodedConverter` that also will add the correct `content-type` and convert a `Map`
into `Map<String, String>` for requests.

```dart

final chopper = ChopperClient(
  converter: FormUrlEncodedConverter(),
);
```


To do only a single type of request with form encoding in a service, use the provided `FormUrlEncodedConverter`'
s `requestFactory` method with the `@FactoryConverter` annotation.

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

To specify fields individually, use the `@Field` annotation on method parameters. If the field's name is not provided,
the parameter's name is used as the field's name.

```dart
@Post(path: "form")
@formUrlEncoded
Future<Response> post(@Field() String foo, @Field("b") int bar);
```

## Sending files with `@multipart`

### Sending a file in bytes as `List<int>` using `@PartFile`

```dart
@Post(path: 'file')
@multipart
Future<Response> postFile(@PartFile('file') List<int> bytes,);
```

### Sending a file as `MultipartFile` using `@PartFile` with extra parameters via `@Part`

```dart
@Post(path: 'file')
@multipart
Future<Response> postMultipartFile(@PartFile() MultipartFile file, {
  @Part() String? id,
});
```

### Sending multiple files as `List<MultipartFile>` using `@PartFile`

```dart
@Post(path: 'files')
@multipart
Future<Response> postListFiles(@PartFile() List<MultipartFile> files);
```

## Defining Responses

ChopperService methods need to return a `Future`. Its possible to define return types of `Future<Response>` or `Future<Response<T>>` where `T` is the type of the response body. 
When `Response` is not needed for a request its also possible to define a return type of `Future<T>` where `T` is the type of the response body.

Chopper will generate a client which will return the specified return type. When the method doesn't directly returns `Response` and the HTTP call fails a exception is thrown.

```dart
// Returns a Response<dynamic>
@Get(path: "/")
Future<Response> fetch();

// Returns a Response<MyClass>
@Get(path: "/")
Future<Response<MyClass>> fetch();

// Returns a MyClass
@Get(path: "/")
Future<MyClass> fetch();
```

> Note: Chopper doesn't convert response bodies by itself to dart object. You need to use a [Converter](converters/converters.md) for that.

## Add tag
`@Tag` parameter annotation for setting tag on the underlying Chopper `Request` object. These can be read
in `Converter`s or `Interceptor`s for tracing, analytics, varying behavior, and more.


if want to filter null value or empty String for some url. we can make an `IncludeBodyNullOrEmptyTag` Object as Tag.
```dart
class IncludeBodyNullOrEmptyTag {
  bool includeNull = false;
  bool includeEmpty = false;

  IncludeBodyNullOrEmptyTag(this.includeNull, this.includeEmpty);
}

@get(path: '/include')
Future<Response> includeBodyNullOrEmptyTag(
    {@Tag()
    IncludeBodyNullOrEmptyTag tag = const IncludeBodyNullOrEmptyTag()});
```

get tag via `request.tag` in `Converter` or `Interceptor`:

```dart
class TagConverter extends JsonConverter {
  FutureOr<Request> convertRequest(Request request) {
    final tag = request.tag;
    if (tag is IncludeBodyNullOrEmptyTag) {
      if (request.body is Map) {
        final Map body = request.body as Map;
        final Map bodyCopy = {};
        for (final MapEntry entry in body.entries) {
          if (!tag.includeNull && entry.value == null) continue;
          if (!tag.includeEmpty && entry.value == "") continue;
          bodyCopy[entry.key] = entry.value;
        }
        request = request.copyWith(body: bodyCopy);
      }
    }
  }
}
```