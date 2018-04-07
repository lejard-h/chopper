import 'package:chopper/chopper.dart';

Request applyHeader(Request request, String name, String value) =>
    applyHeaders(request, {name: value});

Request applyHeaders(Request request, Map<String, String> headers) {
  final h = new Map.from(request.headers);
  h.addAll(headers);
  return request.replace(headers: h);
}
