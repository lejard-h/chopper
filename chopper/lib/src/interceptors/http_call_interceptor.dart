import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chopper_exception.dart';
import 'package:chopper/src/interceptors/internal_interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

/// {@template HttpCallInterceptor}
/// Internal interceptor that handles the actual HTTP calls. HTTP calls are handled by [_httpClient] for http package.
/// {@endtemplate}
class HttpCallInterceptor implements InternalInterceptor {
  /// {@macro HttpCallInterceptor}
  const HttpCallInterceptor(this._httpClient);

  /// HTTP client to be used for making the actual HTTP calls.
  final http.Client _httpClient;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final finalRequest = await chain.request.toBaseRequest();
    final streamRes = await _httpClient.send(finalRequest);

    if (isTypeOf<BodyType, Stream<List<int>>>()) {
      return Response(streamRes, (streamRes.stream) as BodyType);
    } else if (isTypeOf<BodyType, String>()) {
      final response = await http.Response.fromStream(streamRes);
      return Response(response, response.body as BodyType);
    } else {
      throw ChopperException('Unsupported type', request: chain.request);
    }
  }
}
