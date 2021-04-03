import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:chopper/chopper.dart';
import 'package:chopper_built_value/chopper_built_value.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'data.dart';
import 'serializers.dart';

void main() {
  final builder = serializers.toBuilder();
  builder.addPlugin(StandardJsonPlugin());

  final jsonSerializers = builder.build();

  final converter = BuiltValueConverter(
    jsonSerializers,
    errorType: ErrorModel,
  );

  final data = DataModel((b) {
    b.id = 42;
    b.name = 'foo';
  });

  group('BuiltValueConverter', () {
    test('convert request', () {
      var request = Request('', '', '', body: data);
      request = converter.convertRequest(request);
      expect(request.body, '{"\$":"DataModel","id":42,"name":"foo"}');
    });

    test('convert response with wireName', () {
      final string = '{"\$":"DataModel","id":42,"name":"foo"}';
      final response = Response(http.Response(string, 200), string);
      final convertedResponse =
          converter.convertResponse<DataModel, DataModel>(response);

      expect(convertedResponse.body?.id, equals(42));
      expect(convertedResponse.body?.name, equals('foo'));
    });

    test('convert response without wireName', () {
      final string = '{"id":42,"name":"foo"}';
      final response = Response(http.Response(string, 200), string);
      final convertedResponse =
          converter.convertResponse<DataModel, DataModel>(response);

      expect(convertedResponse.body?.id, equals(42));
      expect(convertedResponse.body?.name, equals('foo'));
    });

    test('convert response List', () {
      final string = '[{"id":42,"name":"foo"},{"id":25,"name":"bar"}]';
      final response = Response(http.Response(string, 200), string);
      final convertedResponse =
          converter.convertResponse<BuiltList<DataModel>, DataModel>(response);

      final list = convertedResponse.body;
      expect(list?.first.id, equals(42));
      expect(list?.first.name, equals('foo'));
      expect(list?.last.id, equals(25));
      expect(list?.last.name, equals('bar'));
    });

    test('has json headers', () {
      var request = Request('', '', '', body: data);
      request = converter.convertRequest(request);

      expect(request.headers['content-type'], equals('application/json'));
    });

    test('convert error with wire name', () {
      final string = '{"\$":"DataModel","id":42,"name":"foo"}';
      final response = Response(http.Response(string, 200), string);
      final convertedResponse = converter.convertError(response);

      expect(convertedResponse.body.id, equals(42));
      expect(convertedResponse.body.name, equals('foo'));
    });

    test('convert error using provided type', () {
      final string = '{"message":"Error message"}';
      final response = Response(http.Response(string, 200), string);
      final convertedResponse = converter.convertError(response);

      expect(convertedResponse.body.message, equals('Error message'));
    });
  });
}
