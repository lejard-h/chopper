import 'dart:async';

import 'package:chopper/chopper.dart';

/// This method should return a [Request] that includes credentials to satisfy an authentication challenge received in
/// [response]. It should return `null` if the challenge cannot be satisfied.
abstract class Authenticator {
  FutureOr<Request?> authenticate(Request request, Response response);
}
