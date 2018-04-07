import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Response<Body> {
  final http.Response base;
  final Body body;

  const Response(this.base, this.body);

  Response replace({http.Response base, Body body}) =>
      new Response(base ?? this.base, body ?? this.body);

  int get statusCode => base.statusCode;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
