import 'dart:async' show Completer, Timer;

import 'package:http/http.dart' show RequestAbortedException;

/// Typedefs to avoid exposing dart:async and http package in the public API.

/// Wrapper around [Completer] to avoid exposing dart:async in the public API.
typedef ChopperCompleter<T> = Completer<T>;

/// Wrapper around [Timer] to avoid exposing dart:async in the public API.
typedef ChopperTimer = Timer;

/// Wrapper around [RequestAbortedException] to avoid exposing http package in the public API.
typedef ChopperRequestAbortedException = RequestAbortedException;
