import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class HttpCallInterceptor implements InternalInterceptor {
  const HttpCallInterceptor(this.httpClient);

  final http.Client httpClient;

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final finalRequest = await chain.request.toBaseRequest();
    final streamRes = await httpClient.send(finalRequest);

    if (isTypeOf<BodyType, Stream<List<int>>>()) {
      return Response(streamRes, (streamRes.stream) as BodyType);
    } else if (isTypeOf<BodyType, String>()) {
      final response = await http.Response.fromStream(streamRes);
      return Response(response, response.body as BodyType);
    } else {
      throw Exception('Unsupported type');
    }
  }
}
