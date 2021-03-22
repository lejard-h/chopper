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
  final h = Map<String, String>.from(request.headers);

  for (var k in headers.keys) {
    var val = headers[k];
    if (val == null) continue;
    if (!override && h.containsKey(k)) continue;
    h[k] = val;
  }

  return request.copyWith(headers: h);
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
  /// ignore: prefer_collection_literals
  final pairs = Set<_Pair<String, String>>();

  map.forEach((key, value) {
    if (value != null) {
      var name = Uri.encodeQueryComponent(key);

      if (prefix != null) {
        name = '$prefix.$name';
      }

      if (value is Iterable) {
        pairs.addAll(_iterableToQuery(name, value));
      } else if (value is Map<String, dynamic>) {
        pairs.addAll(_mapToQuery(value, prefix: name));
      } else if (value.toString().isNotEmpty == true) {
        pairs.add(_Pair<String, String>(name, _normalizeValue(value)));
      }
    }
  });
  return pairs;
}

Iterable<_Pair<String, String>> _iterableToQuery(
  String name,
  Iterable values,
) =>
    values.map((v) => _Pair(name, _normalizeValue(v)));

String _normalizeValue(value) => Uri.encodeQueryComponent(value.toString());

class _Pair<A, B> {
  final A first;
  final B second;

  _Pair(this.first, this.second);

  @override
  String toString() => '$first=$second';
}

bool isTypeOf<ThisType, OfType>() => _Instance<ThisType>() is _Instance<OfType>;

class _Instance<T> {
  //
}
