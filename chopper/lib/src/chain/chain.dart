import 'dart:async';

import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';

/// A single chain instance in the chain of interceptors that is called in order to process requests and responses.
///
/// The chain is used to proceed to the next interceptor in the chain.
/// Call [proceed] to proceed to the next interceptor in the chain.
/// ```dart
///   await chain.proceed(request);
/// ```
abstract interface class Chain<BodyType> {
  /// Proceed to the next interceptor in the chain.
  /// Provide the [request] to be processed by the next interceptor.
  FutureOr<Response<BodyType>> proceed(Request request);

  /// The request to be processed by the chain up to this point.
  /// The request is provide by the previous interceptor in the chain.
  Request get request;
}
