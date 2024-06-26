// ignore_for_file: deprecated_member_use_from_same_package

import 'package:chopper/src/request.dart';
import 'package:chopper/src/utils.dart';
import 'package:qs_dart/qs_dart.dart' show ListFormat;
import 'package:test/test.dart';

import 'fixtures/example_enum.dart';

void main() {
  group('mapToQuery single', () {
    <Map<String, dynamic>, String>{
      {'foo': null}: '',
      {'foo': ''}: '',
      {'foo': ' '}: 'foo=%20',
      {'foo': '  '}: 'foo=%20%20',
      {'foo': '\t'}: 'foo=%09',
      {'foo': '\t\t'}: 'foo=%09%09',
      {'foo': 'null'}: 'foo=null',
      {'foo': 'bar'}: 'foo=bar',
      {'foo': ' bar '}: 'foo=%20bar%20',
      {'foo': '\tbar\t'}: 'foo=%09bar%09',
      {'foo': '\t\tbar\t\t'}: 'foo=%09%09bar%09%09',
      {'foo': 123}: 'foo=123',
      {'foo': 0}: 'foo=0',
      {'foo': -0.01}: 'foo=-0.01',
      {'foo': '0.00'}: 'foo=0.00',
      {'foo': 123.456}: 'foo=123.456',
      {'foo': 123.450}: 'foo=123.45',
      {'foo': -123.456}: 'foo=-123.456',
      {'foo': true}: 'foo=true',
      {'foo': false}: 'foo=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery single with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {'foo': null}: 'foo=',
      {'foo': ''}: 'foo=',
      {'foo': ' '}: 'foo=%20',
      {'foo': '  '}: 'foo=%20%20',
      {'foo': '\t'}: 'foo=%09',
      {'foo': '\t\t'}: 'foo=%09%09',
      {'foo': 'null'}: 'foo=null',
      {'foo': 'bar'}: 'foo=bar',
      {'foo': ' bar '}: 'foo=%20bar%20',
      {'foo': '\tbar\t'}: 'foo=%09bar%09',
      {'foo': '\t\tbar\t\t'}: 'foo=%09%09bar%09%09',
      {'foo': 123}: 'foo=123',
      {'foo': 0}: 'foo=0',
      {'foo': -0.01}: 'foo=-0.01',
      {'foo': '0.00'}: 'foo=0.00',
      {'foo': 123.456}: 'foo=123.456',
      {'foo': 123.450}: 'foo=123.45',
      {'foo': -123.456}: 'foo=-123.456',
      {'foo': true}: 'foo=true',
      {'foo': false}: 'foo=false',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(mapToQuery(map, includeNullQueryVars: true), query),
      ),
    );
  });

  group('mapToQuery multiple', () {
    <Map<String, dynamic>, String>{
      {'foo': null, 'baz': null}: '',
      {'foo': '', 'baz': ''}: '',
      {'foo': null, 'baz': ''}: '',
      {'foo': '', 'baz': null}: '',
      {'foo': 'bar', 'baz': ''}: 'foo=bar',
      {'foo': null, 'baz': 'etc'}: 'baz=etc',
      {'foo': '', 'baz': 'etc'}: 'baz=etc',
      {'foo': 'bar', 'baz': 'etc'}: 'foo=bar&baz=etc',
      {'foo': 'null', 'baz': 'null'}: 'foo=null&baz=null',
      {'foo': ' ', 'baz': ' '}: 'foo=%20&baz=%20',
      {'foo': '\t', 'baz': '\t'}: 'foo=%09&baz=%09',
      {'foo': 123, 'baz': 456}: 'foo=123&baz=456',
      {'foo': 0, 'baz': 0}: 'foo=0&baz=0',
      {'foo': '0.00', 'baz': '0.00'}: 'foo=0.00&baz=0.00',
      {'foo': 123.456, 'baz': 789.012}: 'foo=123.456&baz=789.012',
      {'foo': 123.450, 'baz': 789.010}: 'foo=123.45&baz=789.01',
      {'foo': -123.456, 'baz': -789.012}: 'foo=-123.456&baz=-789.012',
      {'foo': true, 'baz': true}: 'foo=true&baz=true',
      {'foo': false, 'baz': false}: 'foo=false&baz=false',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery multiple with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {'foo': null, 'baz': null}: 'foo=&baz=',
      {'foo': '', 'baz': ''}: 'foo=&baz=',
      {'foo': null, 'baz': ''}: 'foo=&baz=',
      {'foo': '', 'baz': null}: 'foo=&baz=',
      {'foo': 'bar', 'baz': ''}: 'foo=bar&baz=',
      {'foo': null, 'baz': 'etc'}: 'foo=&baz=etc',
      {'foo': '', 'baz': 'etc'}: 'foo=&baz=etc',
      {'foo': 'bar', 'baz': 'etc'}: 'foo=bar&baz=etc',
      {'foo': 'null', 'baz': 'null'}: 'foo=null&baz=null',
      {'foo': ' ', 'baz': ' '}: 'foo=%20&baz=%20',
      {'foo': '\t', 'baz': '\t'}: 'foo=%09&baz=%09',
      {'foo': 123, 'baz': 456}: 'foo=123&baz=456',
      {'foo': 0, 'baz': 0}: 'foo=0&baz=0',
      {'foo': '0.00', 'baz': '0.00'}: 'foo=0.00&baz=0.00',
      {'foo': 123.456, 'baz': 789.012}: 'foo=123.456&baz=789.012',
      {'foo': 123.450, 'baz': 789.010}: 'foo=123.45&baz=789.01',
      {'foo': -123.456, 'baz': -789.012}: 'foo=-123.456&baz=-789.012',
      {'foo': true, 'baz': true}: 'foo=true&baz=true',
      {'foo': false, 'baz': false}: 'foo=false&baz=false',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(mapToQuery(map, includeNullQueryVars: true), query),
      ),
    );
  });

  group('mapToQuery lists with repeat (default)', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo=bar&foo=baz&foo=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo=bar&foo=123&foo=456.789&foo=0&foo=-123&foo=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo=baz&foo=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo=bar&foo=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo=bar&foo=baz',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo=baz&foo=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo=bar&foo=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo=bar&foo=baz',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo=bar&foo=baz&foo=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo=bar&foo=baz&foo=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo=bar&foo=baz&foo=etc&bar=baz',
    }.forEach((map, query) {
      test(
        '$map -> $query',
        () => expect(
          mapToQuery(map),
          query,
          reason: 'legacy default',
        ),
      );

      test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.repeat),
          query,
        ),
      );
    });
  });

  group('mapToQuery lists with repeat (default) with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo=bar&foo=baz&foo=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo=bar&foo=123&foo=456.789&foo=0&foo=-123&foo=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo=&foo=baz&foo=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo=bar&foo=&foo=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo=bar&foo=baz&foo=',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo=&foo=baz&foo=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo=bar&foo=&foo=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo=bar&foo=baz&foo=',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo=bar&foo=baz&foo=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo=bar&foo=baz&foo=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo=bar&foo=baz&foo=etc&bar=baz&etc=&xyz=',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, includeNullQueryVars: true),
            query,
            reason: 'legacy default',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.repeat,
              includeNullQueryVars: true,
            ),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery lists with brackets', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo%5B%5D=bar&foo%5B%5D=123&foo%5B%5D=456.789&foo%5B%5D=0&foo%5B%5D=-123&foo%5B%5D=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc&bar=baz',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, useBrackets: true),
            query,
            reason: 'legacy brackets',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, listFormat: ListFormat.brackets),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery lists with brackets with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo%5B%5D=bar&foo%5B%5D=123&foo%5B%5D=456.789&foo%5B%5D=0&foo%5B%5D=-123&foo%5B%5D=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo%5B%5D=&foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=&foo%5B%5D=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo%5B%5D=&foo%5B%5D=baz&foo%5B%5D=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo%5B%5D=bar&foo%5B%5D=&foo%5B%5D=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc&bar=baz&etc=&xyz=',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              useBrackets: true,
              includeNullQueryVars: true,
            ),
            query,
            reason: 'legacy brackets',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.brackets,
              includeNullQueryVars: true,
            ),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery lists with indices', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=123&foo%5B2%5D=456.789&foo%5B3%5D=0&foo%5B4%5D=-123&foo%5B5%5D=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B2%5D=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B2%5D=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=etc&bar=baz',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.indices),
          query,
        ),
      ),
    );
  });

  group('mapToQuery lists with indices with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=123&foo%5B2%5D=456.789&foo%5B3%5D=0&foo%5B4%5D=-123&foo%5B5%5D=-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo%5B0%5D=&foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=&foo%5B2%5D=etc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo%5B0%5D=&foo%5B1%5D=baz&foo%5B2%5D=etc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=&foo%5B2%5D=etc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo%5B0%5D=bar&foo%5B1%5D=baz&foo%5B2%5D=etc&bar=baz&etc=&xyz=',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(
            map,
            listFormat: ListFormat.indices,
            includeNullQueryVars: true,
          ),
          query,
        ),
      ),
    );
  });

  group('mapToQuery lists with comma', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo=bar%2Cbaz%2Cetc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo=bar%2C123%2C456.789%2C0%2C-123%2C-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo=%2Cbaz%2Cetc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo=bar%2C%2Cetc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo=bar%2Cbaz%2C',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo=%2Cbaz%2Cetc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo=bar%2C%2Cetc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo=bar%2Cbaz%2C',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo=bar%2Cbaz%2C%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo=bar%2Cbaz%2C%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo=bar%2Cbaz%2Cetc&bar=baz',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.comma),
          query,
        ),
      ),
    );
  });

  group('mapToQuery lists with comma with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': ['bar', 'baz', 'etc'],
      }: 'foo=bar%2Cbaz%2Cetc',
      {
        'foo': ['bar', 123, 456.789, 0, -123, -456.789],
      }: 'foo=bar%2C123%2C456.789%2C0%2C-123%2C-456.789',
      {
        'foo': ['', 'baz', 'etc'],
      }: 'foo=%2Cbaz%2Cetc',
      {
        'foo': ['bar', '', 'etc'],
      }: 'foo=bar%2C%2Cetc',
      {
        'foo': ['bar', 'baz', ''],
      }: 'foo=bar%2Cbaz%2C',
      {
        'foo': [null, 'baz', 'etc'],
      }: 'foo=%2Cbaz%2Cetc',
      {
        'foo': ['bar', null, 'etc'],
      }: 'foo=bar%2C%2Cetc',
      {
        'foo': ['bar', 'baz', null],
      }: 'foo=bar%2Cbaz%2C',
      {
        'foo': ['bar', 'baz', ' '],
      }: 'foo=bar%2Cbaz%2C%20',
      {
        'foo': ['bar', 'baz', '\t'],
      }: 'foo=bar%2Cbaz%2C%09',
      {
        'foo': ['bar', 'baz', 'etc'],
        'bar': 'baz',
        'etc': '',
        'xyz': null,
      }: 'foo=bar%2Cbaz%2Cetc&bar=baz&etc=&xyz=',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(
            map,
            listFormat: ListFormat.comma,
            includeNullQueryVars: true,
          ),
          query,
        ),
      ),
    );
  });

  group('mapToQuery maps with repeat (default)', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo.bar=baz',
      {
        'foo': {'bar': ''},
      }: '',
      {
        'foo': {'bar': null},
      }: '',
      {
        'foo': {'bar': ' '},
      }: 'foo.bar=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo.bar=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo.bar=baz&foo.etc=xyz&foo.space=%20&foo.tab=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo.bar=baz&foo.int=123&foo.double=456.789&foo.zero=0&foo.negInt=-123&foo.negDouble=-456.789&foo.space=%20&foo.tab=%09&foo%2Elist=a&foo%2Elist=123&foo%2Elist=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo.bar=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo.bar=baz&foo.zap=abc&foo%2Eetc.abc=def&foo%2Eetc.ghi=jkl&foo%2Eetc%2Emno.opq=rst&foo%2Eetc%2Emno.uvw=xyz&foo%2Eetc%2Emno%2Eaab=bbc&foo%2Eetc%2Emno%2Eaab=ccd&foo%2Eetc%2Emno%2Eaab=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: r'filters%2E$or%2Edate.$eq=2020-01-01&filters%2E$or%2Edate.$eq=2020-01-02&filters%2Eauthor%2Ename.$eq=John%20doe',
    }.forEach((map, query) {
      test(
        '$map -> $query',
        () => expect(
          mapToQuery(map),
          query,
          reason: 'legacy default',
        ),
      );

      test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.repeat),
          query,
        ),
      );
    });
  });

  group('mapToQuery maps with repeat (default) with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo.bar=baz',
      {
        'foo': {'bar': ''},
      }: 'foo.bar=',
      {
        'foo': {'bar': null},
      }: 'foo.bar=',
      {
        'foo': {'bar': ' '},
      }: 'foo.bar=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo.bar=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo.bar=baz&foo.etc=xyz&foo.space=%20&foo.tab=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo.bar=baz&foo.int=123&foo.double=456.789&foo.zero=0&foo.negInt=-123&foo.negDouble=-456.789&foo.emptyString=&foo.nullValue=&foo.space=%20&foo.tab=%09&foo%2Elist=a&foo%2Elist=123&foo%2Elist=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo.bar=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo.bar=baz&foo.zap=abc&foo%2Eetc.abc=def&foo%2Eetc.ghi=jkl&foo%2Eetc%2Emno.opq=rst&foo%2Eetc%2Emno.uvw=xyz&foo%2Eetc%2Emno%2Eaab=bbc&foo%2Eetc%2Emno%2Eaab=ccd&foo%2Eetc%2Emno%2Eaab=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: r'filters%2E$or%2Edate.$eq=2020-01-01&filters%2E$or%2Edate.$eq=2020-01-02&filters%2Eauthor%2Ename.$eq=John%20doe',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, includeNullQueryVars: true),
            query,
            reason: 'legacy default',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.repeat,
              includeNullQueryVars: true,
            ),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery maps with brackets', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: '',
      {
        'foo': {'bar': null},
      }: '',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D%5B%5D=a&foo%5Blist%5D%5B%5D=123&foo%5Blist%5D%5B%5D=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=bbc&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=ccd&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, useBrackets: true),
            query,
            reason: 'legacy brackets',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, listFormat: ListFormat.brackets),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery maps with brackets with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': null},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5BemptyString%5D=&foo%5BnullValue%5D=&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D%5B%5D=a&foo%5Blist%5D%5B%5D=123&foo%5Blist%5D%5B%5D=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=bbc&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=ccd&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B%5D=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              useBrackets: true,
              includeNullQueryVars: true,
            ),
            query,
            reason: 'legacy brackets',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.brackets,
              includeNullQueryVars: true,
            ),
            query,
          ),
        );
      },
    );
  });

  group('mapToQuery maps with indices', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: '',
      {
        'foo': {'bar': null},
      }: '',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D%5B0%5D=a&foo%5Blist%5D%5B1%5D=123&foo%5Blist%5D%5B2%5D=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B0%5D=bbc&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B1%5D=ccd&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B2%5D=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D%5B0%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B1%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.indices),
          query,
        ),
      ),
    );
  });

  group('mapToQuery maps with indices with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': null},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5BemptyString%5D=&foo%5BnullValue%5D=&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D%5B0%5D=a&foo%5Blist%5D%5B1%5D=123&foo%5Blist%5D%5B2%5D=false',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B0%5D=bbc&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B1%5D=ccd&foo%5Betc%5D%5Bmno%5D%5Baab%5D%5B2%5D=eef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D%5B0%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B1%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(
            map,
            listFormat: ListFormat.indices,
            includeNullQueryVars: true,
          ),
          query,
        ),
      ),
    );
  });

  group('mapToQuery maps with comma', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: '',
      {
        'foo': {'bar': null},
      }: '',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D=a%2C123%2Cfalse',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D=bbc%2Cccd%2Ceef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D=%7Bdate%3A%20%7B%24eq%3A%202020-01-01%7D%7D%2C%7Bdate%3A%20%7B%24eq%3A%202020-01-02%7D%7D&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, listFormat: ListFormat.comma),
          query,
        ),
      ),
    );
  });

  group('mapToQuery maps with comma with includeNullQueryVars', () {
    <Map<String, dynamic>, String>{
      {
        'foo': {'bar': 'baz'},
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': {'bar': ''},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': null},
      }: 'foo%5Bbar%5D=',
      {
        'foo': {'bar': ' '},
      }: 'foo%5Bbar%5D=%20',
      {
        'foo': {'bar': '\t'},
      }: 'foo%5Bbar%5D=%09',
      {
        'foo': {'bar': 'baz', 'etc': 'xyz', 'space': ' ', 'tab': '\t'},
      }: 'foo%5Bbar%5D=baz&foo%5Betc%5D=xyz&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
      {
        'foo': {
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
          'space': ' ',
          'tab': '\t',
          'list': ['a', 123, false],
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5BemptyString%5D=&foo%5BnullValue%5D=&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D=a%2C123%2Cfalse',
      {
        'foo': {'bar': 'baz'},
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz&etc=xyz',
      {
        'foo': {
          'bar': 'baz',
          'zap': 'abc',
          'etc': {
            'abc': 'def',
            'ghi': 'jkl',
            'mno': {
              'opq': 'rst',
              'uvw': 'xyz',
              'aab': [
                'bbc',
                'ccd',
                'eef',
              ],
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz&foo%5Betc%5D%5Bmno%5D%5Baab%5D=bbc%2Cccd%2Ceef',
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'John doe',
            },
          }
        }
      }: 'filters%5B%24or%5D=%7Bdate%3A%20%7B%24eq%3A%202020-01-01%7D%7D%2C%7Bdate%3A%20%7B%24eq%3A%202020-01-02%7D%7D&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=John%20doe',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(
            map,
            listFormat: ListFormat.comma,
            includeNullQueryVars: true,
          ),
          query,
        ),
      ),
    );
  });

  group('mapToQuery maps with indices and nested lists', () {
    group(
      'mapToQuery maps with repeat (default) and nested lists',
      () {
        <Map<String, dynamic>, String>{
          {
            'filters': {
              r'$or': [
                {
                  'date': {
                    r'$eq': '2020-01-01',
                  }
                },
                null,
                {
                  'date': {
                    r'$eq': '2020-01-02',
                  }
                }
              ],
              'author': {
                'name': {
                  r'$eq': 'Kai doe',
                },
              }
            }
          }: r'filters%2E$or%2Edate.$eq=2020-01-01&filters%2E$or%2Edate.$eq=2020-01-02&filters%2Eauthor%2Ename.$eq=Kai%20doe',
          {
            'filters': {
              'id': {
                r'$in': [3, 6, 8],
              },
            }
          }: r'filters%2Eid%2E$in=3&filters%2Eid%2E$in=6&filters%2Eid%2E$in=8'
        }.forEach(
          (map, query) {
            test(
              '$map -> $query',
              () => expect(
                mapToQuery(
                  map,
                ),
                query,
                reason: 'legacy default',
              ),
            );

            test(
              '$map -> $query',
              () => expect(
                mapToQuery(
                  map,
                  listFormat: ListFormat.repeat,
                ),
                query,
              ),
            );
          },
        );
      },
    );

    group(
      'mapToQuery maps with brackets and nested lists',
      () {
        <Map<String, dynamic>, String>{
          {
            'filters': {
              r'$or': [
                {
                  'date': {
                    r'$eq': '2020-01-01',
                  }
                },
                {
                  'date': {
                    r'$eq': '2020-01-02',
                  }
                }
              ],
              'author': {
                'name': {
                  r'$eq': 'Kai doe',
                },
              }
            }
          }: 'filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
          {
            'filters': {
              'id': {
                r'$in': [3, 6, 8],
              },
            }
          }: 'filters%5Bid%5D%5B%24in%5D%5B%5D=3&filters%5Bid%5D%5B%24in%5D%5B%5D=6&filters%5Bid%5D%5B%24in%5D%5B%5D=8'
        }.forEach(
          (map, query) {
            test(
              '$map -> $query',
              () => expect(
                mapToQuery(
                  map,
                  useBrackets: true,
                ),
                query,
                reason: 'legacy brackets',
              ),
            );

            test(
              '$map -> $query',
              () => expect(
                mapToQuery(
                  map,
                  listFormat: ListFormat.brackets,
                ),
                query,
              ),
            );
          },
        );
      },
    );

    group(
      'mapToQuery maps with comma and nested lists',
      () {
        <Map<String, dynamic>, String>{
          {
            'filters': {
              r'$or': [
                {
                  'date': {
                    r'$eq': '2020-01-01',
                  }
                },
                {
                  'date': {
                    r'$eq': '2020-01-02',
                  }
                }
              ],
              'author': {
                'name': {
                  r'$eq': 'Kai doe',
                },
              }
            }
          }: 'filters%5B%24or%5D=%7Bdate%3A%20%7B%24eq%3A%202020-01-01%7D%7D%2C%7Bdate%3A%20%7B%24eq%3A%202020-01-02%7D%7D&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
          {
            'filters': {
              'id': {
                r'$in': [3, 6, 8],
              },
            }
          }: 'filters%5Bid%5D%5B%24in%5D=3%2C6%2C8'
        }.forEach(
          (map, query) => test(
            '$map -> $query',
            () => expect(
              mapToQuery(
                map,
                listFormat: ListFormat.comma,
                includeNullQueryVars: true,
              ),
              query,
            ),
          ),
        );
      },
    );
    <Map<String, dynamic>, String>{
      {
        'filters': {
          r'$or': [
            {
              'date': {
                r'$eq': '2020-01-01',
              }
            },
            {
              'date': {
                r'$eq': '2020-01-02',
              }
            }
          ],
          'author': {
            'name': {
              r'$eq': 'Kai doe',
            },
          }
        }
      }: 'filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
      {
        'filters': {
          'id': {
            r'$in': [3, 6, 8],
          },
        }
      }: 'filters%5Bid%5D%5B%24in%5D%5B%5D=3&filters%5Bid%5D%5B%24in%5D%5B%5D=6&filters%5Bid%5D%5B%24in%5D%5B%5D=8'
    }.forEach(
      (map, query) {
        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, useBrackets: true),
            query,
            reason: 'legacy brackets',
          ),
        );

        test(
          '$map -> $query',
          () => expect(
            mapToQuery(map, listFormat: ListFormat.brackets),
            query,
          ),
        );
      },
    );
  });

  group(
    'mapToQuery maps with repeat (default) with includeNullQueryVars and nested lists',
    () {
      <Map<String, dynamic>, String>{
        {
          'filters': {
            r'$or': [
              {
                'date': {
                  r'$eq': '2020-01-01',
                }
              },
              null,
              {
                'date': {
                  r'$eq': '2020-01-02',
                }
              }
            ],
            'author': {
              'name': {
                r'$eq': 'Kai doe',
              },
            }
          }
        }: r'filters%2E$or%2Edate.$eq=2020-01-01&filters%2E$or=&filters%2E$or%2Edate.$eq=2020-01-02&filters%2Eauthor%2Ename.$eq=Kai%20doe',
        {
          'filters': {
            'id': {
              r'$in': [3, null, 8],
            },
          }
        }: r'filters%2Eid%2E$in=3&filters%2Eid%2E$in=&filters%2Eid%2E$in=8'
      }.forEach(
        (map, query) {
          test(
            '$map -> $query',
            () => expect(
              mapToQuery(
                map,
                includeNullQueryVars: true,
              ),
              query,
              reason: 'legacy default',
            ),
          );

          test(
            '$map -> $query',
            () => expect(
              mapToQuery(
                map,
                listFormat: ListFormat.repeat,
                includeNullQueryVars: true,
              ),
              query,
            ),
          );
        },
      );
    },
  );

  group(
    'mapToQuery maps with brackets with includeNullQueryVars and nested lists',
    () {
      <Map<String, dynamic>, String>{
        {
          'filters': {
            r'$or': [
              {
                'date': {
                  r'$eq': '2020-01-01',
                }
              },
              null,
              {
                'date': {
                  r'$eq': '2020-01-02',
                }
              }
            ],
            'author': {
              'name': {
                r'$eq': 'Kai doe',
              },
            }
          }
        }: 'filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B%5D=&filters%5B%24or%5D%5B%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
        {
          'filters': {
            'id': {
              r'$in': [3, null, 8],
            },
          }
        }: 'filters%5Bid%5D%5B%24in%5D%5B%5D=3&filters%5Bid%5D%5B%24in%5D%5B%5D=&filters%5Bid%5D%5B%24in%5D%5B%5D=8'
      }.forEach(
        (map, query) {
          test(
            '$map -> $query',
            () => expect(
              mapToQuery(
                map,
                useBrackets: true,
                includeNullQueryVars: true,
              ),
              query,
              reason: 'legacy brackets',
            ),
          );

          test(
            '$map -> $query',
            () => expect(
              mapToQuery(
                map,
                listFormat: ListFormat.brackets,
                includeNullQueryVars: true,
              ),
              query,
            ),
          );
        },
      );
    },
  );

  group(
    'mapToQuery maps with indices with includeNullQueryVars and nested lists',
    () {
      <Map<String, dynamic>, String>{
        {
          'filters': {
            r'$or': [
              {
                'date': {
                  r'$eq': '2020-01-01',
                }
              },
              null,
              {
                'date': {
                  r'$eq': '2020-01-02',
                }
              }
            ],
            'author': {
              'name': {
                r'$eq': 'Kai doe',
              },
            }
          }
        }: 'filters%5B%24or%5D%5B0%5D%5Bdate%5D%5B%24eq%5D=2020-01-01&filters%5B%24or%5D%5B1%5D=&filters%5B%24or%5D%5B2%5D%5Bdate%5D%5B%24eq%5D=2020-01-02&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
        {
          'filters': {
            'id': {
              r'$in': [3, null, 8],
            },
          }
        }: 'filters%5Bid%5D%5B%24in%5D%5B0%5D=3&filters%5Bid%5D%5B%24in%5D%5B1%5D=&filters%5Bid%5D%5B%24in%5D%5B2%5D=8'
      }.forEach(
        (map, query) => test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.indices,
              includeNullQueryVars: true,
            ),
            query,
          ),
        ),
      );
    },
  );

  group(
    'mapToQuery maps with comma with includeNullQueryVars and nested lists',
    () {
      <Map<String, dynamic>, String>{
        {
          'filters': {
            r'$or': [
              {
                'date': {
                  r'$eq': '2020-01-01',
                }
              },
              null,
              {
                'date': {
                  r'$eq': '2020-01-02',
                }
              }
            ],
            'author': {
              'name': {
                r'$eq': 'Kai doe',
              },
            }
          }
        }: 'filters%5B%24or%5D=%7Bdate%3A%20%7B%24eq%3A%202020-01-01%7D%7D%2C%2C%7Bdate%3A%20%7B%24eq%3A%202020-01-02%7D%7D&filters%5Bauthor%5D%5Bname%5D%5B%24eq%5D=Kai%20doe',
        {
          'filters': {
            'id': {
              r'$in': [3, null, 8],
            },
          }
        }: 'filters%5Bid%5D%5B%24in%5D=3%2C%2C8'
      }.forEach(
        (map, query) => test(
          '$map -> $query',
          () => expect(
            mapToQuery(
              map,
              listFormat: ListFormat.comma,
              includeNullQueryVars: true,
            ),
            query,
          ),
        ),
      );

      test('mapToQuery maps with enums', () {
        final map = {
          'filters': {
            'name': 'foo',
            'example': ExampleEnum.bar,
          }
        };

        expect(
          mapToQuery(map),
          equals('filters.name=foo&filters.example=bar'),
        );
      });
    },
  );

  Request createRequest(Map<String, String> headers) => Request(
        'POST',
        Uri.parse('foo'),
        Uri.parse('bar'),
        headers: headers,
      );

  group('applyHeader tests', () {
    test('request apply single header', () {
      final testRequest = createRequest({});

      final result = applyHeader(testRequest, 'foo', 'bar');

      expect(result.headers['foo'], 'bar');
    });

    test('request apply single header overrides existing', () {
      final testRequest = createRequest({'foo': 'bar'});

      final result = applyHeader(testRequest, 'foo', 'whut');

      expect(result.headers['foo'], 'whut');
    });

    test(
      'request apply single header overrides existing field name case insensitive',
      () {
        final testRequest = createRequest({'Foo': 'bar'});

        final result = applyHeader(testRequest, 'foo', 'whut');

        expect(result.headers['foo'], 'whut');
      },
    );

    test('request apply single header doesn\'t overrides existing', () {
      final testRequest = createRequest({'foo': 'bar'});

      final result = applyHeader(testRequest, 'foo', 'whut', override: false);

      expect(result.headers['foo'], 'bar');
    });

    test(
      'request apply single header doesn\'t overrides existing field name case insensitive',
      () {
        final testRequest = createRequest({'Foo': 'bar'});

        final result = applyHeader(testRequest, 'foo', 'whut', override: false);

        expect(result.headers['Foo'], 'bar');
      },
    );
  });

  group('applyHeaders tests', () {
    test('request apply headers', () {
      final testRequest = createRequest({});

      final result = applyHeaders(testRequest, {'foo': 'bar'});

      expect(result.headers['foo'], 'bar');
    });

    test('request apply headers overrides existing', () {
      final testRequest = createRequest({'foo': 'bar'});

      final result = applyHeaders(testRequest, {'foo': 'whut'});

      expect(result.headers['foo'], 'whut');
    });

    test(
      'request apply headers overrides existing field name case insensitive',
      () {
        final testRequest = createRequest({'Foo': 'bar'});

        final result = applyHeaders(testRequest, {'foo': 'whut'});

        expect(result.headers['foo'], 'whut');
      },
    );

    test('request apply headers doesn\'t overrides existing', () {
      final testRequest = createRequest({'foo': 'bar'});

      final result =
          applyHeaders(testRequest, {'foo': 'whut'}, override: false);

      expect(result.headers['foo'], 'bar');
    });

    test(
      'request apply headers doesn\'t overrides existing field name case insensitive',
      () {
        final testRequest = createRequest({'Foo': 'bar'});

        final result =
            applyHeaders(testRequest, {'foo': 'whut'}, override: false);

        expect(result.headers['Foo'], 'bar');
      },
    );

    test(
      'request apply headers multiple headers with override false',
      () {
        final testRequest = createRequest(
          {
            'Foo': 'bar',
            'tomato': 'apple',
            'phone': 'tablet',
          },
        );

        final result = applyHeaders(
          testRequest,
          {
            'foo': 'whut',
            'phone': 'computer',
            'chair': 'table',
          },
          override: false,
        );

        expect(result.headers['Foo'], 'bar');
        expect(result.headers['tomato'], 'apple');
        expect(result.headers['chair'], 'table');
        expect(result.headers['phone'], 'tablet');
        expect(result.headers.length, 4);
      },
    );

    test(
      'request apply headers multiple headers with override true',
      () {
        final testRequest = createRequest(
          {
            'Foo': 'bar',
            'tomato': 'apple',
            'phone': 'tablet',
          },
        );

        final result = applyHeaders(
          testRequest,
          {
            'foo': 'whut',
            'phone': 'computer',
            'chair': 'table',
          },
          override: true,
        );

        expect(result.headers['Foo'], 'whut');
        expect(result.headers['tomato'], 'apple');
        expect(result.headers['chair'], 'table');
        expect(result.headers['phone'], 'computer');
        expect(result.headers.length, 4);
      },
    );
  });
}
