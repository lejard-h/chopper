import 'dart:async';

import 'package:chopper/chopper.dart';

///
/// Callback that is called when an authentication challenge is received
/// based on the given [request], [response], and optionally the
/// [originalRequest].
///
typedef AuthenticationCallback = FutureOr<void> Function(
  Request request,
  Response response, [
  Request? originalRequest,
]);

///
/// Handles authentication challenges raised by the [ChopperClient].
///
/// Optionally, you can override either [onAuthenticationSuccessful] or
/// [onAuthenticationFailed] in order to listen to when a particular
/// authentication request succeeds or fails.
///
/// For example, you can use these in order to reset or mutate your
/// instance's internal state for the purposes of keeping track of
/// the number of retries made to authenticate a request.
///
/// Furthermore, you can use these callbacks to determine whether
/// your authentication [Request] from [authenticate] actually succeeded
/// or failed.
///
abstract class Authenticator {
  ///
  /// Returns a [Request] that includes credentials to satisfy
  /// an authentication challenge received in [response], based on
  /// the incoming [request] or optionally, the [originalRequest]
  /// (which was not modified with any previous [Interceptor]s).
  ///
  /// Otherwise, return `null` if the challenge cannot be satisfied.
  ///
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]);

  ///
  /// Optional callback called by [ChopperClient] when the outgoing
  /// request from [authenticate] was successful.
  ///
  /// You can use this to determine whether that request actually succeeded
  /// in authenticating the user.
  ///
  AuthenticationCallback? get onAuthenticationSuccessful => null;

  ///
  /// Optional callback called by [ChopperClient] when the outgoing
  /// request from [authenticate] failed to authenticate.
  ///
  /// You can use this to determine whether that request failed to recover
  /// the user's session.
  ///
  AuthenticationCallback? get onAuthenticationFailed => null;
}
