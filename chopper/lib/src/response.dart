import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Response<BodyType> {
  final http.BaseResponse base;
  final BodyType body;
  final Object error;

  Response(this.base, this.body, {this.error});

  Response replace<NewBodyType>({
    http.BaseResponse base,
    NewBodyType body,
    Object bodyError,
  }) =>
      Response<NewBodyType>(
        base ?? this.base,
        body ?? this.body,
        error: bodyError ?? this.error,
      );

  int get statusCode => base.statusCode;

  /// true if status code is >= 200 && <3
  /// if false, [error] will contains the response
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  Map<String, String> get headers => base.headers;

  Uint8List get bodyBytes =>
      base is http.Response ? (base as http.Response).bodyBytes : null;

  String get bodyString =>
      base is http.Response ? (base as http.Response).body : null;
}

bool responseIsSuccessful(int statusCode) =>
    statusCode >= 200 && statusCode < 300;
