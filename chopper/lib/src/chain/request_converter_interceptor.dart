import 'package:chopper/src/annotations.dart';
import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chain/real_interceptor_chain.dart';
import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

class RequestConverterInterceptor implements Interceptor {
  RequestConverterInterceptor(this.converter, this.requestConverter);

  final Converter? converter;
  final ConvertRequest? requestConverter;

  @override
  Future<Response<BodyType>> intercept<BodyType, InnerType>(
    Chain chain,
  ) async {
    final realChain = (chain as RealInterceptorChain).copyWith(exchangable: true);
    final request =
        await _handleRequestConverter(chain.request, requestConverter);

    final response = await realChain.proceed<BodyType, InnerType>(request);

    return response;
  }

  Future<Request> _handleRequestConverter(
    Request request,
    ConvertRequest? requestConverter,
  ) async =>
      request.body != null || request.parts.isNotEmpty
          ? requestConverter != null
              ? await requestConverter(request)
              : await _encodeRequest(request)
          : request;

  Future<Request> _encodeRequest(Request request) async =>
      converter?.convertRequest(request) ?? request;
}
