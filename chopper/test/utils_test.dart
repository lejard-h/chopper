import 'package:chopper/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('mapToQuery single', () {
    <Map<String, dynamic>, String>{
      {
        'foo': null,
      }: r'foo=',
      {
        'foo': '',
      }: r'foo=',
      {
        'foo': 'null',
      }: r'foo=null',
      {
        'foo': 'bar',
      }: r'foo=bar',
      {
        'foo': 123,
      }: r'foo=123',
      {
        'foo': 0,
      }: r'foo=0',
      {
        'foo': 0.00,
      }: r'foo=0.0',
      {
        'foo': -0,
      }: r'foo=0',
      {
        'foo': -0.01,
      }: r'foo=-0.01',
      {
        'foo': '0.00',
      }: r'foo=0.00',
      {
        'foo': 123.456,
      }: r'foo=123.456',
      {
        'foo': 123.450,
      }: r'foo=123.45',
      {
        'foo': -123.456,
      }: r'foo=-123.456',
      {
        'foo': true,
      }: r'foo=true',
      {
        'foo': false,
      }: r'foo=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery multiple', () {
    <Map<String, dynamic>, String>{
      {
        'foo': null,
        'baz': null,
      }: r'foo=&baz=',
      {
        'foo': '',
        'baz': '',
      }: r'foo=&baz=',
      {
        'foo': null,
        'baz': '',
      }: r'foo=&baz=',
      {
        'foo': '',
        'baz': null,
      }: r'foo=&baz=',
      {
        'foo': 'bar',
        'baz': '',
      }: r'foo=bar&baz=',
      {
        'foo': null,
        'baz': 'etc',
      }: r'foo=&baz=etc',
      {
        'foo': '',
        'baz': 'etc',
      }: r'foo=&baz=etc',
      {
        'foo': 'bar',
        'baz': 'etc',
      }: r'foo=bar&baz=etc',
      {
        'foo': 'null',
        'baz': 'null',
      }: r'foo=null&baz=null',
      {
        'foo': 123,
        'baz': 456,
      }: r'foo=123&baz=456',
      {
        'foo': 0,
        'baz': 0,
      }: r'foo=0&baz=0',
      {
        'foo': 0.00,
        'baz': 0.00,
      }: r'foo=0.0&baz=0.0',
      {
        'foo': '0.00',
        'baz': '0.00',
      }: r'foo=0.00&baz=0.00',
      {
        'foo': 123.456,
        'baz': 789.012,
      }: r'foo=123.456&baz=789.012',
      {
        'foo': 123.450,
        'baz': 789.010,
      }: r'foo=123.45&baz=789.01',
      {
        'foo': -123.456,
        'baz': -789.012,
      }: r'foo=-123.456&baz=-789.012',
      {
        'foo': true,
        'baz': true,
      }: r'foo=true&baz=true',
      {
        'foo': false,
        'baz': false,
      }: r'foo=false&baz=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery lists', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: r'foo=bar&foo=baz&foo=etc',
      {
        'foo': ['bar', 123, 456.789, 0, 0.00, -0, -123, -456.789],
      }: r'foo=bar&foo=123&foo=456.789&foo=0&foo=0.0&foo=0&foo=-123&foo=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: r'foo=baz&foo=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: r'foo=bar&foo=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: r'foo=bar&foo=baz',
      {
        'foo': [null, 'baz', 'etc'],
      }: r'foo=baz&foo=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: r'foo=bar&foo=etc',
      {
        'foo': ['bar', 'baz', null],
      }: r'foo=bar&foo=baz',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });
}
