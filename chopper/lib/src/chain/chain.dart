import 'dart:async';

import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

abstract interface class Chain<BodyType> {
  FutureOr<Response<BodyType>> proceed(Request request);

  Request get request;
}
