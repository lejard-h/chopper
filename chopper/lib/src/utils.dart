import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';

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
/// 'Authorization': 'Bearer <token>',
/// 'Content-Type': 'application/json',
/// });
/// ```
Request applyHeaders(
  Request request,
  Map<String, String> headers, {
  bool override = true,
}) {
  final Map<String, String> headersCopy = {...request.headers};

  for (String key in headers.keys) {
    String? value = headers[key];
    if (value == null) continue;
    if (!override && headersCopy.containsKey(key)) continue;
    headersCopy[key] = value;
  }

  return request.copyWith(headers: headersCopy);
}

final chopperLogger = Logger('Chopper');

/// Creates a valid URI query string from [map].
///
/// E.g., `{'foo': 'bar', 'ints': [ 1337, 42 ] }` will become 'foo=bar&ints=1337&ints=42'.
String mapToQuery(Map<String, dynamic> map) => _mapToQuery(map).join('&');

Iterable<_Pair<String, String>> _mapToQuery(
  Map<String, dynamic> map, {
  String? prefix,
}) {
  final Set<_Pair<String, String>> pairs = {};

  map.forEach((key, value) {
    String name = Uri.encodeQueryComponent(key);

    if (prefix != null) {
      name = '$prefix.$name';
    }

    if (value != null) {
      if (value is Iterable) {
        pairs.addAll(_iterableToQuery(name, value));
      } else if (value is Map<String, dynamic>) {
        pairs.addAll(_mapToQuery(value, prefix: name));
      } else {
        pairs.add(_Pair<String, String>(name, _normalizeValue(value)));
      }
    } else {
      pairs.add(_Pair<String, String>(name, ''));
    }
  });

  return pairs;
}

Iterable<_Pair<String, String>> _iterableToQuery(
  String name,
  Iterable values,
) =>
    values
        .where((value) => value?.toString().isNotEmpty ?? false)
        .map((value) => _Pair(name, _normalizeValue(value)));

String _normalizeValue(value) => Uri.encodeComponent(value?.toString() ?? '');

class _Pair<A, B> {
  final A first;
  final B second;

  const _Pair(this.first, this.second);

  @override
  String toString() => '$first=$second';
}

bool isTypeOf<ThisType, OfType>() => _Instance<ThisType>() is _Instance<OfType>;

class _Instance<T> {
  //
}
