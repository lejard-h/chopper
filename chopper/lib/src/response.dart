import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Response<BodyType> {
  final http.Response base;
  final BodyType body;

  const Response(this.base, this.body);

  Response replace<NewBodyType>({http.Response base, NewBodyType body}) =>
      Response<NewBodyType>(base ?? this.base, body ?? this.body);

  int get statusCode => base.statusCode;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  Map<String, String> get headers => base.headers;

  Uint8List get bodyBytes => base.bodyBytes;
}
