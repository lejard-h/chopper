# Changelog

## 8.0.1

- Directly export `qs.ListFormat` instead of internal wrapper ([#624](https://github.com/lejard-h/chopper/pull/624))
- Update dependencies and linters ([#615](https://github.com/lejard-h/chopper/pull/615))

## 8.0.0

- Add per-request timeout ([#604](https://github.com/lejard-h/chopper/pull/604))
- **BREAKING CHANGE**:
  - Restructure interceptors ([#547](https://github.com/lejard-h/chopper/pull/547))
    - `RequestInterceptor` and Function `RequestInterceptor`s are removed 
    - `ResponseInterceptor` and Function `ResponseInterceptor`s are removed
    - See [Migrating to 8.0.0](https://docs.google.com/document/d/e/2PACX-1vQFoUDisnSJBzzXCMaf53ffUD1Bvpu-1GZ_stzfaaCa0Xd3WKIegbd1mmavEQcMT6r6v8z02UqloKuC/pub) for more information and examples

## 7.4.0

- Use [qs_dart](https://pub.dev/packages/qs_dart) for query string encoding in order to support complex query objects ([#592](https://github.com/lejard-h/chopper/pull/592))

## 7.3.0

- Add support for `@Tag` annotation ([#586](https://github.com/lejard-h/chopper/pull/586))

## 7.2.0

- Add support for `@FormUrlEncoded` annotation ([#579](https://github.com/lejard-h/chopper/pull/579))

## 7.1.1

- Add option to override build_extension via build.yaml ([#562](https://github.com/lejard-h/chopper/pull/562))

## 7.1.0

- Add ability to omit `Response` in service ([#545](https://github.com/lejard-h/chopper/pull/545))
- Fix `FactoryConverter` regression introduced in v7.0.7 ([#549](https://github.com/lejard-h/chopper/pull/549))

## 7.0.7

- Enable the user to specify non-String type header values by calling `.toString()` on any non-String Dart type. ([#538](https://github.com/lejard-h/chopper/pull/538))

## 7.0.6

- Fix incorrect url generation when using new baseUrl ([#520](https://github.com/lejard-h/chopper/pull/520))

## 7.0.5+1

- Fix Github release workflow permissions ([#512](https://github.com/lejard-h/chopper/pull/512))

## 7.0.5

- Correct static analysis suppression of *.chopper.dart files ([#507](https://github.com/lejard-h/chopper/pull/507))

## 7.0.4

- Ignore unnecessary_string_interpolations ([#501](https://github.com/lejard-h/chopper/pull/501))

## 7.0.3

- The @ChopperApi annotation's baseUrl property can be used as a top level constant string variable ([#493](https://github.com/lejard-h/chopper/pull/493))
- Add pub.dev topics to package metadata ([#495](https://github.com/lejard-h/chopper/pull/495))

## 7.0.2

- Update analyzer dependency to >=5.13.0 <7.0.0 ([#484](https://github.com/lejard-h/chopper/pull/484))

## 7.0.1

- Add final class modifier to generated Chopper API implementations

## 7.0.0

- Require Dart 3.0 or later
- Add final modifier to some classes ([#453](https://github.com/lejard-h/chopper/pull/453))
- Replace deprecated Element.enclosingElement3 with Element.enclosingElement

## 6.0.3

- Simplify library export
- Extract PartBuilder into its own file
- Extract constant variables into an enum
- Extract helper methods into a Utils class
- Use a const constructor
- Make all methods static
- Ensure all immutable variables are final
- Simplify syntax
- Add API documentation
- Update README

## 6.0.2

- Add support for generating files in different directories ([#444](https://github.com/lejard-h/chopper/pull/444))

## 6.0.1

- Packages upgrade, constraints upgrade

## 6.0.0

- Replaced the String based path with Uri (BREAKING CHANGE)

## 5.2.0

- Replaced the String based path with Uri (BREAKING CHANGE)

## 5.1.0

- Annotation to include null vars in query

## 5.0.1

- Types added

## 5.0.0

- API breaking changes (FutureOr usage)

## 4.0.3

- Analyzer dependency upgrade

## 4.0.2

- Analyzer dependency upgrade
- PartValueFile nullability fix

## 4.0.1

- Fix for the null safety support

## 4.0.0

- **Null safety support**
- Fix `@Header` annotation not generating null safe code
- Respect `required` keyword in functions

## 3.0.5

- Packages upgrade

## 3.0.4

- Analyzer update

## 3.0.3

- Documentations update
- Generate code compatible with pedantic analysis option

## 3.0.2

- Fix factory converter

## 3.0.1

- Fix Avoid using braces in interpolation when not needed

## 3.0.0

- Maintenance release to support last version of `chopper` package (3.0.0) that introduced a breaking change on error
  handling

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

- Fix PartValue cast

## 2.4.0

- Deprecate `@FileField`, use `@PartFile` instead
- support `chopper: ^2.4.1`

## 2.3.4

fix trailing slash when empty path

## 2.3.3

- update analyzer to `0.35.0`

## 2.3.2

- do not set to null explicitly

## 2.3.1

- Fixed @Path issue, thanks to @kiruto
- update `built_collection` to `4.0.0`

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
  ```dart
  @ChopperApi()
  abstract class MyService extends ChopperService {
  static MyService create([ChopperClient client]) => _$MyService(client);
  }
  ```

## 1.0.1

- update build package

## 1.0.0

- Multipart request
- form url encoded
- add jsonAPI and formUrlEncodedApi boolean to ChopperClient
- json and formUrlEncoding are now builtin
- `onError`, `onResponse`, `onRequest` stream
- error converter
- add withClient constructor

## 0.1.0

- update dart sdk

## 0.0.2

- the generated extension is now `*.chopper.dart`

- rename `ServiceDefinition` to `ChopperApi`
- rename `ChopperClient.services` field to `ChopperClient.apis`

## 0.0.1

- Initial version, created by Stagehand
