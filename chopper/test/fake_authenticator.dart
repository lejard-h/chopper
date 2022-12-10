import 'dart:async' show FutureOr;

import 'package:chopper/chopper.dart';

class FakeAuthenticator extends Authenticator {
  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode == 401) {
      return request.copyWith(
        headers: <String, String>{
          ...request.headers,
          'authorization': 'some_fake_token',
        },
      );
    }

    return null;
  }
}
