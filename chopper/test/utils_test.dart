import 'package:chopper/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('mapToQuery single', () {
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
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery multiple', () {
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
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery lists', () {
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
      }: 'foo=bar&foo=baz&foo=etc&bar=baz&etc=&xyz=',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery maps', () {
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
        },
      }: 'foo.bar=baz&foo.int=123&foo.double=456.789&foo.zero=0&foo.negInt=-123&foo.negDouble=-456.789&foo.emptyString=&foo.nullValue=&foo.space=%20&foo.tab=%09',
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
            },
          },
        },
      }: 'foo.bar=baz&foo.zap=abc&foo.etc.abc=def&foo.etc.ghi=jkl&foo.etc.mno.opq=rst&foo.etc.mno.uvw=xyz',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery maps with brackets', () {
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
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5BemptyString%5D=&foo%5BnullValue%5D=&foo%5Bspace%5D=%20&foo%5Btab%5D=%09',
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
            },
          },
        },
      }: 'foo%5Bbar%5D=baz&foo%5Bzap%5D=abc&foo%5Betc%5D%5Babc%5D=def&foo%5Betc%5D%5Bghi%5D=jkl&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, separator: QueryMapSeparator.brackets),
          query,
        ),
      ),
    );
  });
}
