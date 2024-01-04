import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;

class FakeChain implements Chain {
  FakeChain(this.request, {this.response});

  @override
  final Request request;
  final Response? response;

  @override
  FutureOr<Response<BodyType>> proceed<BodyType, InnerType>(Request request) {
    return response as Response<BodyType>? ??
        Response(http.Response('TestChain', 200), 'TestChain' as BodyType);
  }
}
