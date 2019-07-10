import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';

/// see [applyHeaders]
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

/// apply given [headers] to the [request]
/// if [override] is true, it will erase already present headers with the new value
Request applyHeaders(
  Request request,
  Map<String, String> headers, {
  bool override = true,
}) {
  final h = Map<String, String>.from(request.headers);

  for (var k in headers.keys) {
    if (!override && h.containsKey(k)) continue;
    h[k] = headers[k];
  }

  return request.replace(headers: h);
}

final chopperLogger = Logger('Chopper');

/// transform {'foo': 'bar', 'ints': [ 1337, 42 ] }
/// to 'foo=bar&ints=1337&ints=42'
String mapToQuery(Map<String, dynamic> map) => _mapToQuery(map).join('&');

Iterable<_Pair<String, String>> _mapToQuery(
  Map<String, dynamic> map, {
  String prefix,
}) {
  final pairs = Set<_Pair<String, String>>();

  map.forEach((key, value) {
    if (value != null) {
      var name = Uri.encodeQueryComponent(key);

      if (prefix != null) {
        name = '$prefix.$name';
      }

      if (value is Iterable) {
        pairs.addAll(_iterableToQuery(name, value));
      } else if (value is Map) {
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

  String toString() => '$first=$second';
}

bool isTypeOf<ThisType, OfType>() => _Instance<ThisType>() is _Instance<OfType>;

class _Instance<T> {
  //
}
