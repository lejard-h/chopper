import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class HttpCallInterceptor implements Interceptor {
  const HttpCallInterceptor(this.httpClient);

  final http.Client httpClient;

  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(Chain chain) async {
    final realChain = chain as RealInterceptorChain;
    final finalRequest = await realChain.request.toBaseRequest();
    final streamRes = await httpClient.send(finalRequest);

    if (isTypeOf<BodyType, Stream<List<int>>>()) {
      return Response(streamRes, (streamRes.stream) as BodyType);
    }

    final response = await http.Response.fromStream(streamRes);
    dynamic res = Response(response, response.body);

    return res;
  }
}
