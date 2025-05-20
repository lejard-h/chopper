import 'dart:convert' as dart_convert;

import 'package:chopper/src/base.dart';
import 'package:chopper/src/constants.dart';
import 'package:chopper/src/converters.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'test_service.dart';

final baseUrl = Uri.parse('http://localhost:8000');

void main() {
  group('Converter', () {
    ChopperClient buildClient(http.BaseClient client) => ChopperClient(
          baseUrl: baseUrl,
          client: client,
          converter: TestConverter(),
          errorConverter: TestErrorConverter(),
        );

    test('base decode', () async {
      final converter = TestConverter();

      final decoded =
          converter.convertResponse<_Converted<String>, _Converted<String>>(
        Response<String>(http.Response('', 200), 'foo'),
      );

      expect(decoded.body is _Converted<String>, isTrue);
      expect(decoded.body!.data, equals('foo'));
    });

    test('base encode', () async {
      final converter = TestConverter();

      final encoded = converter.convertRequest(
        Request(
          'GET',
          Uri.parse('/'),
          baseUrl,
          body: _Converted<String>('foo'),
        ),
      );

      expect(encoded.body is String, isTrue);
      expect(encoded.body, equals('foo'));
    });

    test('on error converter', () async {
      final httpClient = MockClient((http.Request request) async {
        return http.Response('{"list":[1,2],"foo":"bar","int": 42}', 404);
      });

      final chopper = buildClient(httpClient);

      final service = HttpTestService.create(chopper);

      try {
        await service.getTest('1', dynamicHeader: '');
      } catch (e) {
        expect(e is Response, isTrue);
        expect((e as Response).body is _ConvertedError, isTrue);
        final res = e as Response<_ConvertedError>;
        expect(res.body!.data is Map, isTrue);
        expect(res.body!.data['list'], equals([1, 2]));
        expect(res.body!.data['foo'], equals('bar'));
        expect(res.body!.data['int'], equals(42));
      }
      httpClient.close();
    });
  });

  group('JsonConverter', () {
    final jsonConverter = JsonConverter();

    test('decode String', () async {
      final value = 'foo';
      final res = Response(http.Response('"$value"', 200), '"$value"');
      final converted =
          await jsonConverter.convertResponse<String, String>(res);

      expect(converted.body, equals(value));
    });

    test('decode List String', () async {
      final res = Response(
        http.Response('["foo","bar"]', 200),
        '["foo","bar"]',
      );
      final converted =
          await jsonConverter.convertResponse<List<String>, String>(res);

      expect(converted.body, equals(['foo', 'bar']));
    });

    test('decode List int', () async {
      final res = Response(http.Response('[1,2]', 200), '[1,2]');
      final converted =
          await jsonConverter.convertResponse<List<int>, int>(res);

      expect(converted.body, equals([1, 2]));
    });

    test('decode Map', () async {
      final res = Response(
        http.Response('{"foo":"bar"}', 200),
        '{"foo":"bar"}',
      );
      final converted =
          await jsonConverter.convertResponse<Map<String, String>, String>(res);

      expect(converted.body, equals({'foo': 'bar'}));
    });

    test(
      'decodeJson with bodyBytes and application/json content type',
      () async {
        final jsonData = {'key': 'value'};
        final jsonString = dart_convert.jsonEncode(jsonData);
        final bodyBytes = dart_convert.utf8.encode(jsonString);

        final httpResponse = http.Response.bytes(
          bodyBytes,
          200,
          headers: {'content-type': 'application/json'},
        );
        // When using http.Response.bytes, Chopper's Response.body (String getter) might be empty or misinterpret bytes.
        // We pass the original httpResponse so converter can access bodyBytes.
        final chopperResponse = Response(
            httpResponse, null /* httpResponse.body could be wrong here */);

        final converted = await jsonConverter
            .convertResponse<Map<String, dynamic>, dynamic>(chopperResponse);
        expect(converted.body, equals(jsonData));
      },
    );

    test('decodeJson with bodyBytes and application/vnd.api+json content type',
        () async {
      final jsonData = {'key': 'value'};
      final jsonString = dart_convert.jsonEncode(jsonData);
      final bodyBytes = dart_convert.utf8.encode(jsonString);

      final httpResponse = http.Response.bytes(
        bodyBytes,
        200,
        headers: {'content-type': 'application/vnd.api+json'},
      );
      final chopperResponse = Response(httpResponse, null);

      final converted = await jsonConverter
          .convertResponse<Map<String, dynamic>, dynamic>(chopperResponse);
      expect(converted.body, equals(jsonData));
    });

    test('tryDecodeJson with invalid JSON returns original data', () async {
      const invalidJsonString = 'this is not a valid {json string';
      final response = Response(
        http.Response(invalidJsonString, 200,
            headers: {'content-type': 'application/json'}),
        invalidJsonString,
      );

      final converted =
          await jsonConverter.convertResponse<String, String>(response);
      // Expect the original string because json.decode fails and tryDecodeJson returns the input data
      expect(converted.body, invalidJsonString);
    });

    test('convertError decodes JSON error body', () async {
      final errorJson = {'error': 'test error', 'code': 42};
      final errorJsonString = dart_convert.jsonEncode(errorJson);
      final response = Response(
        http.Response(errorJsonString, 400,
            headers: {'content-type': 'application/json'}),
        errorJsonString,
      );

      final converted = await jsonConverter
          .convertError<Map<String, dynamic>, dynamic>(response);
      expect(converted.body, errorJson);
    });

    test('responseFactory decodes JSON response', () async {
      final jsonData = {'id': 123, 'name': 'Test Item'};
      final jsonString = dart_convert.jsonEncode(jsonData);
      final response = Response(
        http.Response(jsonString, 200,
            headers: {'content-type': 'application/json'}),
        jsonString,
      );

      final converted =
          await JsonConverter.responseFactory<Map<String, dynamic>, dynamic>(
              response);
      expect(converted.body, jsonData);
    });

    test('requestFactory encodes JSON request if content-type is json', () {
      final requestBody = {'item': 'test data'};
      final request = Request(
        'POST',
        Uri.parse('/items'),
        baseUrl,
        body: requestBody,
        headers: {'content-type': 'application/json'},
      );

      final converted = JsonConverter.requestFactory(request);
      expect(converted.body, dart_convert.jsonEncode(requestBody));
    });

    test('requestFactory does not encode if content-type is not json', () {
      final requestBody = {'item': 'test data'};
      final request = Request(
        'POST',
        Uri.parse('/items'),
        baseUrl,
        body: requestBody,
        headers: {'content-type': 'text/plain'},
      );

      final converted = JsonConverter.requestFactory(request);
      expect(converted.body, requestBody); // Should not be json encoded
    });

    test(
      'requestFactory does not double encode already JSON string with json header',
      () {
        final requestBodyJsonString = '{"item":"test data"}';
        final request = Request(
          'POST',
          Uri.parse('/items'),
          baseUrl,
          body: requestBodyJsonString,
          headers: {'content-type': 'application/json'},
        );

        final converted = JsonConverter.requestFactory(request);
        expect(converted.body, requestBodyJsonString);
      },
    );

    test('JsonConverter.isJson', () {
      expect(JsonConverter.isJson('{"foo":"bar"}'), isTrue);
      expect(JsonConverter.isJson('foo'), isFalse);
      expect(JsonConverter.isJson(''), isFalse);
      expect(JsonConverter.isJson(null), isFalse);
      expect(JsonConverter.isJson(42), isFalse);
      expect(JsonConverter.isJson([]), isFalse);
      expect(JsonConverter.isJson([1, 2, 3]), isFalse);
      expect(JsonConverter.isJson(['a', 'b', 'c']), isFalse);
      expect(JsonConverter.isJson({}), isFalse);
      expect(
        JsonConverter.isJson({
          'foo': 'bar',
          'list': [1, 2, 3],
        }),
        isFalse,
      );
    });
  });

  group('FormUrlEncodedConverter', () {
    final formConverter = FormUrlEncodedConverter();

    test(
        'convertRequest should return request as is if body is already Map<String, String>',
        () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: {'key': 'value'},
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      );
      final converted = formConverter.convertRequest(request);
      expect(converted.body, equals({'key': 'value'}));
      expect(converted.headers['content-type'],
          'application/x-www-form-urlencoded');
    });

    test(
        'convertRequest should convert Map<String, dynamic> body to Map<String, String>',
        () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: {'key': 'value', 'number': 123, 'bool': true, 'nullVal': null},
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      );
      final converted = formConverter.convertRequest(request);
      expect(converted.body,
          equals({'key': 'value', 'number': '123', 'bool': 'true'}));
      expect(converted.headers['content-type'],
          'application/x-www-form-urlencoded');
    });

    test('convertRequest should return request as is if body is not a Map', () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: 'Just a string body',
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      );
      final converted = formConverter.convertRequest(request);
      expect(converted.body, 'Just a string body');
      expect(converted.headers['content-type'],
          'application/x-www-form-urlencoded');
    });

    test('convertResponse returns response as is', () async {
      final response = Response(http.Response('foo=bar', 200), 'foo=bar');
      final converted =
          await formConverter.convertResponse<String, String>(response);
      expect(converted.body, 'foo=bar');
      expect(converted.base.statusCode, 200);
    });

    test('convertError returns response as is', () async {
      final response = Response(http.Response('error=true', 400), 'error=true');
      final converted =
          await formConverter.convertError<String, String>(response);
      expect(converted.body, 'error=true');
      expect(converted.base.statusCode, 400);
    });
  });

  group('JsonConverter encodeJson specific tests', () {
    final jsonConverter = JsonConverter();
    test(
      'encodeJson should not encode if content-type does not contain application/json',
      () {
        final request = Request(
          'POST',
          Uri.parse('/test'),
          baseUrl,
          body: {'key': 'value'},
          headers: {'content-type': 'text/plain'},
        );
        final converted = jsonConverter.encodeJson(request);
        expect(converted.body, equals({'key': 'value'})); // Not encoded
      },
    );

    test(
      'encodeJson should not encode if body is already a valid JSON string',
      () {
        final request = Request(
          'POST',
          Uri.parse('/test'),
          baseUrl,
          body: '{"key":"value"}',
          headers: {'content-type': 'application/json'},
        );
        final converted = jsonConverter.encodeJson(request);
        expect(converted.body, equals('{"key":"value"}')); // Not double encoded
      },
    );

    test(
      'encodeJson should encode if body is a string but not valid JSON and content type is JSON',
      () {
        final request = Request(
          'POST',
          Uri.parse('/test'),
          baseUrl,
          body: 'Just a string', // Not a valid JSON
          headers: {'content-type': 'application/json'},
        );
        final converted = jsonConverter.encodeJson(request);
        // It should be JSON encoded, meaning the string itself becomes a JSON string literal
        expect(converted.body, equals('"Just a string"'));
      },
    );

    test('encodeJson should encode non-string body if content type is JSON',
        () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: {'key': 'value', 'number': 123},
        headers: {'content-type': 'application/json'},
      );
      final converted = jsonConverter.encodeJson(request);
      expect(converted.body,
          equals(dart_convert.jsonEncode({'key': 'value', 'number': 123})));
    });

    test(
      'encodeJson should not encode if content-type is null, even if body could be JSON',
      () {
        final request = Request(
          'POST',
          Uri.parse('/test'),
          baseUrl,
          body: {'key': 'value'},
          headers: {}, // No content-type header
        );
        final converted = jsonConverter.encodeJson(request);
        expect(converted.body, equals({'key': 'value'})); // Not encoded
      },
    );

    test(
      'encodeJson should encode if content-type contains json and other params (e.g. charset)',
      () {
        final request = Request(
          'POST',
          Uri.parse('/test'),
          baseUrl,
          body: {'key': 'value'},
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
        final converted = jsonConverter.encodeJson(request);
        expect(converted.body, dart_convert.jsonEncode({'key': 'value'}));
      },
    );
  });

  group('JsonConverter specific decodeJson tests', () {
    final jsonConverter = JsonConverter();

    test(
        'decodeJson with Iterable<Map<String, dynamic>> and application/json content type',
        () async {
      final listMapData = [
        {'id': 1, 'name': 'item1'},
        {'id': 2, 'name': 'item2'}
      ];
      final jsonString = dart_convert.jsonEncode(listMapData);
      final bodyBytes = dart_convert.utf8.encode(jsonString);
      final httpResponse = http.Response.bytes(bodyBytes, 200,
          headers: {'content-type': 'application/json'});
      final chopperResponse = Response(httpResponse, null);

      final converted = await jsonConverter.decodeJson<
          Iterable<Map<String, dynamic>>,
          Map<String, dynamic>>(chopperResponse);
      expect(converted.body, isA<Iterable<Map<String, dynamic>>>());
      expect(converted.body.first['name'], 'item1');
    });

    test(
        'decodeJson with Map<String, Map<String, dynamic>> and application/json content type',
        () async {
      final mapMapData = {
        'item1': {'value': 100},
        'item2': {'value': 200}
      };
      final jsonString = dart_convert.jsonEncode(mapMapData);
      final bodyBytes = dart_convert.utf8.encode(jsonString);
      final httpResponse = http.Response.bytes(bodyBytes, 200,
          headers: {'content-type': 'application/json'});
      final chopperResponse = Response(httpResponse, null);

      final converted = await jsonConverter.decodeJson<
          Map<String, Map<String, dynamic>>,
          Map<String, dynamic>>(chopperResponse);
      expect(converted.body, isA<Map<String, Map<String, dynamic>>>());
      expect(converted.body['item1']!['value'], 100);
    });
  });

  group('JsonConverter specific tryDecodeJson tests', () {
    final jsonConverter = JsonConverter();

    test('tryDecodeJson with valid JSON string', () {
      final data = '{"message":"success"}';
      final decoded = jsonConverter.tryDecodeJson(data);
      expect(decoded, equals({'message': 'success'}));
    });

    test('tryDecodeJson with array JSON string', () {
      final data = '[1, 2, "test"]';
      final decoded = jsonConverter.tryDecodeJson(data);
      expect(decoded, equals([1, 2, 'test']));
    });

    test('tryDecodeJson with invalid JSON (truncated)', () {
      final data =
          r"""'{"message":"success''"""; // Missing closing brace and quote
      // Logger test would go here if we could mock/intercept chopperLogger.warning
      final result = jsonConverter.tryDecodeJson(data);
      expect(result, equals(data)); // Returns original data on failure
    });

    test('tryDecodeJson with invalid JSON (syntax error)', () {
      final data = '{"message":success}'; // Value not in quotes
      final result = jsonConverter.tryDecodeJson(data);
      expect(result, equals(data));
    });

    test('tryDecodeJson with empty string', () {
      final data = '';
      final result = jsonConverter.tryDecodeJson(data);
      expect(result, equals(data)); // Returns original data on failure
    });
  });

  group('FormUrlEncodedConverter specific tests', () {
    final formConverter = FormUrlEncodedConverter();

    test('requestFactory uses FormUrlEncodedConverter correctly', () {
      final requestBody = {'param1': 'value1', 'param2': 'value2'};
      final request = Request(
        'POST',
        Uri.parse('/submit'),
        baseUrl,
        body: requestBody,
      );
      // requestFactory in FormUrlEncodedConverter adds the header if not present
      final converted = FormUrlEncodedConverter.requestFactory(request);
      expect(converted.headers[contentTypeKey], formEncodedHeaders);
      expect(
        converted.body,
        equals(requestBody), // Body type is Map<String, String>
      );
    });

    test('convertRequest with empty map body', () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: {},
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      );
      final converted = formConverter.convertRequest(request);
      expect(converted.body, equals({}));
    });

    test('convertRequest with map containing null or empty string values', () {
      final request = Request(
        'POST',
        Uri.parse('/test'),
        baseUrl,
        body: {'key1': 'value1', 'key2': null, 'key3': '', 'key4': 'value4'},
        headers: {'content-type': 'application/x-www-form-urlencoded'},
      );
      final converted = formConverter.convertRequest(request);
      // Null values are removed, empty strings are kept if that's the Map behavior (it is for Map<String,String>)
      // The converter specifically filters out null values in its loop.
      expect(
        converted.body,
        equals({'key1': 'value1', 'key3': '', 'key4': 'value4'}),
      );
    });
  });

  test('respects content-type headers', () {
    final jsonConverter = JsonConverter();
    final testRequest = Request(
      'POST',
      Uri.parse('foo'),
      Uri.parse('bar'),
      headers: {'Content-Type': 'application/vnd.api+json'},
    );

    final result = jsonConverter.convertRequest(testRequest);

    expect(result.headers['content-type'], 'application/vnd.api+json');
  });
}

class TestConverter implements Converter {
  @override
  Response<T> convertResponse<T, V>(Response res) {
    if (res.body is String) {
      return res.copyWith<_Converted<String>>(
        body: _Converted<String>(res.body),
      ) as Response<T>;
    }

    return res as Response<T>;
  }

  @override
  Request convertRequest(Request req) =>
      req.body is _Converted ? req.copyWith(body: req.body.data) : req;
}

class TestErrorConverter implements ErrorConverter {
  @override
  Response convertError<T, V>(Response res) {
    if (res.body is String) {
      final error = dart_convert.jsonDecode(res.body);

      return res.copyWith<_ConvertedError>(body: _ConvertedError(error));
    }

    return res;
  }
}

class _Converted<T> {
  final T data;

  _Converted(this.data);
}

class _ConvertedError<T> {
  final T data;

  _ConvertedError(this.data);
}
