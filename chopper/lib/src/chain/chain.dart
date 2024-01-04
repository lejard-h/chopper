import 'dart:async';

import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

abstract interface class Chain {
  FutureOr<Response<BodyType>> proceed<BodyType, InnerType>(Request request);

  Request get request;
}