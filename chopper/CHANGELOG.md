# Changelog

## 1.2.0

- Request is now containing baseUrl
- build runner generator is now generating to cache by default
- Can call `Request.toHttpRequest()` direclty to get the `http.BaseRequest` will receive

- ***BreakingChange***
  - remove `formUrlEncodedAPI`, this is the default behavior of http package and if `jsonApi` is false

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
