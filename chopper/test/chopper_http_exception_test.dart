import 'package:chopper/src/chopper_http_exception.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('ChopperHttpException toString prints available information', () {
    final request = http.Request('GET', Uri.parse('http://localhost:8000'));
    final base = http.Response('Foobar', 400, request: request);
    final response = Response(base, 'Foobar', error: 'FooError');

    final exception = ChopperHttpException(response);

    final result = exception.toString();

    expect(
      result,
      'Could not fetch the response for GET http://localhost:8000. Status code: 400, error: FooError',
    );
  });
}
