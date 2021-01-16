import 'dart:async';

import 'package:chopper/chopper.dart';

/// Returns a request that includes a credential to satisfy an authentication challenge in
/// [response]. Returns null if the challenge cannot be satisfied.
abstract class Authenticator {
  FutureOr<Request> authenticate(Request request, Response response);
}