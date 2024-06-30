import 'dart:collection';

import 'package:chopper/src/request.dart';
import 'package:logging/logging.dart';
import 'package:qs_dart/qs_dart.dart' show encode, EncodeOptions, ListFormat;

/// Creates a new [Request] by copying [request] and adding a header with the
/// provided key [name] and value [value] to the result.
///
/// If [request] already has a header with the key [name] and [override] is true
/// (default), the existing header value will be replaced with [value] in the resulting [Request].
///
/// ```dart
/// final newRequest = applyHeader(request, 'Authorization', 'Bearer <token>');
/// ```
Request applyHeader(
  Request request,
  String name,
  String value, {
  bool override = true,
}) =>
    applyHeaders(
      request,
      {name: value},
      override: override,
    );

/// Creates a new [Request] by copying [request] and adding the provided [headers]
/// to the result.
///
/// If [request] already has headers with keys provided in [headers] and [override]
/// is true (default), the conflicting headers will be replaced.
///
/// ```dart
/// final newRequest = applyHeaders(request, {
///   'Authorization': 'Bearer <token>',
///   'Content-Type': 'application/json',
/// });
/// ```
Request applyHeaders(
  Request request,
  Map<String, String> headers, {
  bool override = true,
}) {
  final LinkedHashMap<String, String> headersCopy = LinkedHashMap(
    equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
    hashCode: (e) => e.toLowerCase().hashCode,
  );
  headersCopy.addAll(request.headers);

  for (final entry in headers.entries) {
    if (!override && headersCopy.containsKey(entry.key)) continue;
    headersCopy[entry.key] = entry.value;
  }

  return request.copyWith(headers: headersCopy);
}

final chopperLogger = Logger('Chopper');

/// Creates a valid URI query string from [map].
///
/// E.g., `{'foo': 'bar', 'ints': [ 1337, 42 ] }` will become 'foo=bar&ints=1337&ints=42'.
String mapToQuery(
  Map<String, dynamic> map, {
  ListFormat? listFormat,
  @Deprecated('Use listFormat instead') bool? useBrackets,
  bool? includeNullQueryVars,
}) {
  listFormat ??= useBrackets == true ? ListFormat.brackets : ListFormat.repeat;

  return encode(
    map,
    EncodeOptions(
      listFormat: listFormat,
      allowDots: listFormat == ListFormat.repeat,
      encodeDotInKeys: listFormat == ListFormat.repeat,
      encodeValuesOnly: listFormat == ListFormat.repeat,
      skipNulls: includeNullQueryVars != true,
      strictNullHandling: false,
      serializeDate: (DateTime date) => date.toUtc().toIso8601String(),
    ),
  );
}

bool isTypeOf<ThisType, OfType>() => _Instance<ThisType>() is _Instance<OfType>;

final class _Instance<T> {}
