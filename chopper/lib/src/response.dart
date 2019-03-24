import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Response<Body> {
  final http.Response base;
  final Body body;

  const Response(this.base, this.body);

  Response replace<BodyType>({http.Response base, BodyType body}) =>
      Response<BodyType>(base ?? this.base, body ?? this.body);

  int get statusCode => base.statusCode;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  Map<String, String> get headers => base.headers;

  Uint8List get bodyBytes => base.bodyBytes;
}
