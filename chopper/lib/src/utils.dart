import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';

Request applyHeader(Request request, String name, String value) =>
    applyHeaders(request, {
      name: value,
    });

Request applyHeaders(Request request, Map<String, String> headers) {
  final h = Map<String, String>.from(request.headers);
  h.addAll(headers);
  return request.replace(headers: h);
}

final chopperLogger = Logger('Chopper');

const contentTypeKey = 'content-type';
const jsonHeaders = "application/json";
const formEncodedHeaders = "application/x-www-form-urlencoded";
