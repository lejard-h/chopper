# Changelog

## 8.0.1+1

- Re-remove internal `qs.ListFormat` wrapper

## 8.0.1

- Fix null body converter ([#623](https://github.com/lejard-h/chopper/pull/623))
- Directly export `qs.ListFormat` instead of internal wrapper ([#624](https://github.com/lejard-h/chopper/pull/624))
- Update dependencies and linters ([#615](https://github.com/lejard-h/chopper/pull/615))

## 8.0.0

- Add per-request timeout ([#604](https://github.com/lejard-h/chopper/pull/604))
- **BREAKING CHANGE**:
  - Restructure interceptors ([#547](https://github.com/lejard-h/chopper/pull/547))
    - `RequestInterceptor` and Function `RequestInterceptor`s are removed 
    - `ResponseInterceptor` and Function `ResponseInterceptor`s are removed
    - See [Migrating to 8.0.0](https://docs.google.com/document/d/e/2PACX-1vQFoUDisnSJBzzXCMaf53ffUD1Bvpu-1GZ_stzfaaCa0Xd3WKIegbd1mmavEQcMT6r6v8z02UqloKuC/pub) for more information and examples
  - add `onlyErrors` option to `HttpLoggingInterceptor` ([#610](https://github.com/lejard-h/chopper/pull/610))

## 7.4.0

- Use [qs_dart](https://pub.dev/packages/qs_dart) for query string encoding for query string encoding in order to support complex query objects ([#592](https://github.com/lejard-h/chopper/pull/592))

## 7.3.0

- Add support for `@Tag` annotation ([#586](https://github.com/lejard-h/chopper/pull/586))

## 7.2.0

- Add support for `@FormUrlEncoded` annotation ([#579](https://github.com/lejard-h/chopper/pull/579))

## 7.1.1+1

- Export `ChopperHttpException` in library exports ([#570](https://github.com/lejard-h/chopper/pull/570))

## 7.1.1

- Add `Target` annotations ([#567](https://github.com/lejard-h/chopper/pull/567))

## 7.1.0+1

- Bump `chopper_generator` version requirement to 7.1.0

## 7.1.0

- Add ability to omit `Response` in service ([#545](https://github.com/lejard-h/chopper/pull/545))
- Add helper function for fetching errors of specific type ([#543](https://github.com/lejard-h/chopper/pull/543))
- Improve documentation ([#548](https://github.com/lejard-h/chopper/pull/548))

## 7.0.10

- Enable the user to specify non-String type header values by calling `.toString()` on any non-String Dart type. ([#538](https://github.com/lejard-h/chopper/pull/538))

## 7.0.9

- Add success/failure callback hooks to Authenticator ([#527](https://github.com/lejard-h/chopper/pull/527))
- Add mock mixins of Chopper components ([#529](https://github.com/lejard-h/chopper/pull/529))

## 7.0.8

- Encode DateTime query parameters in ISO8601 format ([#516](https://github.com/lejard-h/chopper/pull/516))

## 7.0.7+1

- Fix Github release workflow permissions ([#512](https://github.com/lejard-h/chopper/pull/512))

## 7.0.7

- Remove charset from http request headers when the body is in bytes ([#508](https://github.com/lejard-h/chopper/pull/508))

## 7.0.6

- The @ChopperApi annotation's baseUrl property can be used as a top level constant string variable ([#493](https://github.com/lejard-h/chopper/pull/493))
- Fix ChopperClient.send() sending wrong request when using an Authenticator ([#497](https://github.com/lejard-h/chopper/pull/497))
- Add pub.dev topics to package metadata ([#495](https://github.com/lejard-h/chopper/pull/495))

## 7.0.5

- Fix documentation links in README ([#488](https://github.com/lejard-h/chopper/pull/488))

## 7.0.4

- Export ChopperLogRecord to library surface ([#480](https://github.com/lejard-h/chopper/pull/480))
- Make ChopperLogRecord final ([#481](https://github.com/lejard-h/chopper/pull/481))

## 7.0.3

- Use ChopperLogRecord in HttpLoggingInterceptor to log lines ([#475](https://github.com/lejard-h/chopper/pull/475))

## 7.0.2

- Add option to pass custom Logger to HttpLoggingInterceptor ([#470](https://github.com/lejard-h/chopper/pull/470))

## 7.0.1

- Refactor ChopperClient constructor
- Refactor ChopperClient.getService
- Refactor CurlInterceptor

## 7.0.0

- Require Dart 3.0 or later
- Add base, final, and interface modifiers to some classes ([#453](https://github.com/lejard-h/chopper/pull/453))

## 6.1.4

- Fix Multipart for List<int> and List<String> ([#439](https://github.com/lejard-h/chopper/pull/439))

## 6.1.3

- Add follow redirects to toHttpRequest ([#430](https://github.com/lejard-h/chopper/pull/430))
- Update http constraint to ">=0.13.0 <2.0.0" ([#431](https://github.com/lejard-h/chopper/pull/431))
- Add MultipartRequest log to CurlInterceptor ([#435](https://github.com/lejard-h/chopper/pull/435))

## 6.1.2

- Packages upgrade, constraints upgrade

## 6.1.1

- EquatableMixin for Request, Response and PartValue

## 6.1.0

- HttpLogging interceptor more configurable
- Apply headers field name case insensitive.

## 6.0.0

- Replaced the String based path with Uri (BREAKING CHANGE)
- Fix for Authenticator body rewrite

## 5.2.0

- Replaced the String based path with Uri (BREAKING CHANGE)
- Fix for Authenticator body rewrite

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
    - You can also use `Stream<List<int>>` as the BodyType for the response, in this case the returned response will
      contain a stream in `body`.
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
- If a full url is specified in the `path` (ex: @Get(path: 'https://...')), it won't be concaten with the baseUrl of the
  ChopperClient and the ChopperAPI
- Add `CurlInterceptor` thanks @edwardaux
- Add `HttpLoggingInterceptor`
- Add `FactoryConverter` annotation `@FactoryConverter(request: convertRequest, response: convertResponse)`

- ***BreakingChange***
    - Method.url renamed to path
    - `Converter.encode` and `Converter.decode` removed, implement `Converter.convertResponse` and
      Converter.convertRequest` instead
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
