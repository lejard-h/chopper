import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// A [Interceptor] implementation that prints a curl request equivalent
/// to the network call channeled through it for debugging purposes.
///
/// Thanks, @edwardaux
@immutable
class CurlInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final http.BaseRequest baseRequest = await chain.request.toBaseRequest();
    final List<String> curlParts = ['curl -v -X ${baseRequest.method}'];
    for (final MapEntry<String, String> header in baseRequest.headers.entries) {
      curlParts.add("-H '${header.key}: ${header.value}'");
    }
    // this is fairly naive, but it should cover most cases
    if (baseRequest is http.Request) {
      final String body = baseRequest.body;
      if (body.isNotEmpty) {
        curlParts.add("-d '$body'");
      }
    }
    if (baseRequest is http.MultipartRequest) {
      for (final MapEntry<String, String> field in baseRequest.fields.entries) {
        curlParts.add("-f '${field.key}: ${field.value}'");
      }
      for (final http.MultipartFile file in baseRequest.files) {
        curlParts.add("-f '${file.field}: ${file.filename ?? ''}'");
      }
    }
    curlParts.add('"${baseRequest.url}"');
    chopperLogger.info(curlParts.join(' '));

    return chain.proceed(chain.request);
  }
}
