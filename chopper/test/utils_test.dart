import 'package:chopper/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('mapToQuery single', () {
    <Map<String, dynamic>, String>{
      {
        'foo': null,
      }: 'foo=',
      {
        'foo': '',
      }: 'foo=',
      {
        'foo': 'null',
      }: 'foo=null',
      {
        'foo': 'bar',
      }: 'foo=bar',
      {
        'foo': 123,
      }: 'foo=123',
      {
        'foo': 0,
      }: 'foo=0',
      {
        'foo': 0.00,
      }: 'foo=0.0',
      {
        'foo': -0,
      }: 'foo=0',
      {
        'foo': -0.01,
      }: 'foo=-0.01',
      {
        'foo': '0.00',
      }: 'foo=0.00',
      {
        'foo': 123.456,
      }: 'foo=123.456',
      {
        'foo': 123.450,
      }: 'foo=123.45',
      {
        'foo': -123.456,
      }: 'foo=-123.456',
      {
        'foo': true,
      }: 'foo=true',
      {
        'foo': false,
      }: 'foo=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery multiple', () {
    <Map<String, dynamic>, String>{
      {
        'foo': null,
        'baz': null,
      }: 'foo='
          '&baz=',
      {
        'foo': '',
        'baz': '',
      }: 'foo='
          '&baz=',
      {
        'foo': null,
        'baz': '',
      }: 'foo='
          '&baz=',
      {
        'foo': '',
        'baz': null,
      }: 'foo='
          '&baz=',
      {
        'foo': 'bar',
        'baz': '',
      }: 'foo=bar'
          '&baz=',
      {
        'foo': null,
        'baz': 'etc',
      }: 'foo='
          '&baz=etc',
      {
        'foo': '',
        'baz': 'etc',
      }: 'foo='
          '&baz=etc',
      {
        'foo': 'bar',
        'baz': 'etc',
      }: 'foo=bar'
          '&baz=etc',
      {
        'foo': 'null',
        'baz': 'null',
      }: 'foo=null'
          '&baz=null',
      {
        'foo': 123,
        'baz': 456,
      }: 'foo=123'
          '&baz=456',
      {
        'foo': 0,
        'baz': 0,
      }: 'foo=0'
          '&baz=0',
      {
        'foo': 0.00,
        'baz': 0.00,
      }: 'foo=0.0'
          '&baz=0.0',
      {
        'foo': '0.00',
        'baz': '0.00',
      }: 'foo=0.00'
          '&baz=0.00',
      {
        'foo': 123.456,
        'baz': 789.012,
      }: 'foo=123.456'
          '&baz=789.012',
      {
        'foo': 123.450,
        'baz': 789.010,
      }: 'foo=123.45'
          '&baz=789.01',
      {
        'foo': -123.456,
        'baz': -789.012,
      }: 'foo=-123.456'
          '&baz=-789.012',
      {
        'foo': true,
        'baz': true,
      }: 'foo=true'
          '&baz=true',
      {
        'foo': false,
        'baz': false,
      }: 'foo=false'
          '&baz=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery lists', () {
    <Map<String, dynamic>, String>{
      {
        'foo': <dynamic>['bar', 'baz', 'etc'],
      }: 'foo=bar'
          '&foo=baz'
          '&foo=etc',
      {
        'foo': <dynamic>['bar', 123, 456.789, 0, 0.00, -0, -123, -456.789],
      }: 'foo=bar'
          '&foo=123'
          '&foo=456.789'
          '&foo=0'
          '&foo=0.0'
          '&foo=0'
          '&foo=-123'
          '&foo=-456.789',
      {
        'foo': <dynamic>['', 'baz', 'etc'],
      }: 'foo=baz'
          '&foo=etc',
      {
        'foo': <dynamic>['bar', '', 'etc'],
      }: 'foo=bar'
          '&foo=etc',
      {
        'foo': <dynamic>['bar', 'baz', ''],
      }: 'foo=bar'
          '&foo=baz',
      {
        'foo': <dynamic>[null, 'baz', 'etc'],
      }: 'foo=baz'
          '&foo=etc',
      {
        'foo': <dynamic>['bar', null, 'etc'],
      }: 'foo=bar'
          '&foo=etc',
      {
        'foo': <dynamic>['bar', 'baz', null],
      }: 'foo=bar'
          '&foo=baz',
      {
        'foo': <dynamic>['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo=bar'
          '&foo=baz'
          '&foo=etc'
          '&bar=baz'
          '&etc='
          '&xyz=',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery maps', () {
    <Map<String, dynamic>, String>{
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
        },
      }: 'foo.bar=baz',
      {
        'foo': <String, dynamic>{
          'bar': '',
        },
      }: 'foo.bar=',
      {
        'foo': <String, dynamic>{
          'bar': null,
        },
      }: 'foo.bar=',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'etc': 'xyz',
        },
      }: 'foo.bar=baz'
          '&foo.etc=xyz',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'doubleZero': 0.00,
          'negZero': -0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
        },
      }: 'foo.bar=baz'
          '&foo.int=123'
          '&foo.double=456.789'
          '&foo.zero=0'
          '&foo.doubleZero=0.0'
          '&foo.negZero=0'
          '&foo.negInt=-123'
          '&foo.negDouble=-456.789'
          '&foo.emptyString='
          '&foo.nullValue=',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
        },
        'etc': 'xyz',
      }: 'foo.bar=baz'
          '&etc=xyz',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });
}
