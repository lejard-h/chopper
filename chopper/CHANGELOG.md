# Changelog

## 5.1.0

- Base class changed for http.BaseRequest
- Annotation to include null vars in query

## 5.0.1

- mapToQuery changes

## 5.0.0

- API breaking changes (FutureOr)

## 4.0.1

- Fix for the null safety support
## 4.0.0

- **Null safety support**
- Fix infinite loop when using Authenticators
- Remove deprecated `FileField`, use `PartFile` instead
- Remove deprecated `Request.replace`, use `Request.copyWith` instead
- Remove deprecated `PartValue.replace`, use `PartValue.copyWith` instead
- Remove deprecated `Response.replace`, use `Response.copyWith` instead
- Support for OPTIONS requests
- Support for passing data in the body of GET requests (anti-pattern, but requested)
- Support for OkHttp-like Authenticator implementation
- Support for generic API methods
- Updated public API documentation and how-tos

## 3.0.3

- Packages upgrade

## 3.0.2

- Update analyzer
- On `Response` and `Request`, deprecate `replace` method, use `copyWith` instead

## 3.0.1+1

- Documentations update

## 3.0.1

- ResponseInterceptor function support typed parameter
- Fix JsonConverter when converting core types

## 3.0.0

**Breaking change**
New way to handle errors
    if (response.isSuccessful) {
      final body = response.body;
    } else {
      final error = response.error;
    }
- Fix error handling by introducing `Response.error` getter
- Remove `onError` since every response are available via `onResponse` stream


## 2.5.0

- Unsuccessful response are not throw anymore, use `Response.isSuccessful` getter or `statusCode` instead
- Support HEAD request

## 2.4.2

- Fix on JsonConverter
    If content type header overrided using @Post(headers: {'content-type': '...'})
    The converter won't add json header and won't apply json.encode if content type is not JSON

- add `bool override` on `applyHeader(s)` functions, true by default

- support `List<MultipartFile>`

## 2.4.1

- Deprecate `@FieldField`, use `@PartFile` instead

## 2.4.0

- ***Breaking Change***
  `Response.base` is now a `BaseRequest` instead of a `Request`, which means that you can't do base.body now.
  Please use Response.bodyBytes or Response.bodyString instead for non streaming case.
- Now supports streams !
  - You can pass `Stream<List<int>>` as a body to a request
  - You can also use `Stream<List<int>>` as the BodyType for the response, in this case the returned response will contain a stream in `body`.
- Support passing `MutlipartFile` (from packages:http) directly to `@FileField` annotation

## 2.3.2

- Fix trailing slash when path empty

## 2.3.1

- Default value for a path is now `''` instead of '/'
- Do not send null value for Multipart request

## 2.3.0

- ***Breaking Change***
  `ChopperClient.errorConverter` is now taking an `ErrorConverter` as a parameter
  ```dart
  abstract class ErrorConverter {
    FutureOr<Response> convertError<ResultType, ItemType>(Response response);
  }
  ```
- Remove deprecated `Chopper.service<Type>(Type)`
- Add `QueryMap` annotation
- Fix https://github.com/lejard-h/chopper/issues/28
- Fix https://github.com/lejard-h/chopper/issues/21
- Fix https://github.com/lejard-h/chopper/issues/37

## 2.2.0

- Fix converter issue on List
  - ***Breaking Change***
  on `Converter.convertResponse<ResultType>(response)`,
  it take a new generic type => `Converter.convertResponse<ResultType, ItemType>(response)`

- deprecated `Chopper.service<Type>(Type)`, use `Chopper.getservice<Type>()` instead
thanks to @MichaelDark

## 2.1.0

- fix casting issue

## 2.0.0

- Fix type safety
- Fix json converter
- Handle BuiltList

## 2.0.0

- Request is now containing baseUrl
- Can call `Request.toHttpRequest()` direclty to get the `http.BaseRequest` will receive
- If a full url is specified in the `path` (ex: @Get(path: 'https://...')), it won't be concaten with the baseUrl of the ChopperClient and the ChopperAPI
- Add `CurlInterceptor` thanks @edwardaux
- Add `HttpLoggingInterceptor`
- Add `FactoryConverter` annotation `@FactoryConverter(request: convertRequest, response: convertResponse)`

- ***BreakingChange***
  - Method.url renamed to path
  - `Converter.encode` and `Converter.decode` removed, implement `Converter.convertResponse` and Converter.convertRequest` instead
  - `ChopperClient.jsonApi` deprecated, use a `JsonConverter` instead
  - `ChopperClient.formUrlEncodedApi`, use `FormUrlEncodedConverter` instead
  - remove `JsonEncoded` annotation, use `FactoryConverter` instead

## 1.1.0

- ***BreakingChange***
    Removed `name` parameter on `ChopperApi`
    New way to instanciate a service

        @ChopperApi()
        abstract class MyService extends ChopperService {
            static MyService create([ChopperClient client]) => _$MyService(client);
        }


## 1.0.0

- Multipart request
- form url encoded
- add jsonAPI and formUrlEncodedApi boolean to ChopperClient
- json and formUrlEncoding are now builtin
- `onError`, `onResponse`, `onRequest` stream
- error converter
- add withClient constructor

## 0.1.1

- Remove trimSlashes

## 0.1.0

- update dart sdk

## 0.0.2

- the generated extension is now `*.chopper.dart`

- rename `ServiceDefinition` to `ChopperApi`
- rename `ChopperClient.services` field to `ChopperClient.apis`

## 0.0.1

- Initial version, created by Stagehand
