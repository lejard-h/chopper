import 'dart:async';

import 'package:chopper/chopper.dart';

/// This method should return a [Request] that includes credentials to satisfy
/// an authentication challenge received in
/// [response]. It should return `null` if the challenge cannot be satisfied.
///
/// Optionally, you can override either [onAuthenticationSuccessful] or
/// [onAuthenticationFailed] in order to listen to when a particular
/// authentication request succeeds or fails. You can also use it in order
/// to reset or mutate your instance's internal state for the purposes
/// of keeping track of the number of retries made to authenticate a
/// request.
abstract class Authenticator {
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]);

  // coverage:ignore-start
  FutureOr<void> onAuthenticationSuccessful(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) {}
  // coverage:ignore-end

  // coverage:ignore-start
  FutureOr<void> onAuthenticationFailed(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) {}
  // coverage:ignore-end
}
