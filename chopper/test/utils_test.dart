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
        'foo': <dynamic>['bar', 123, 456.789, 0, -0, -123, -456.789],
      }: 'foo=bar'
          '&foo=123'
          '&foo=456.789'
          '&foo=0'
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
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'zap': 'abc',
          'etc': <String, dynamic>{
            'abc': 'def',
            'ghi': 'jkl',
            'mno': <String, dynamic>{
              'opq': 'rst',
              'uvw': 'xyz',
            },
          },
        },
      }: 'foo.bar=baz'
          '&foo.zap=abc'
          '&foo.etc.abc=def'
          '&foo.etc.ghi=jkl'
          '&foo.etc.mno.opq=rst'
          '&foo.etc.mno.uvw=xyz',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery maps with brackets', () {
    <Map<String, dynamic>, String>{
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
        },
      }: 'foo%5Bbar%5D=baz',
      {
        'foo': <String, dynamic>{
          'bar': '',
        },
      }: 'foo%5Bbar%5D=',
      {
        'foo': <String, dynamic>{
          'bar': null,
        },
      }: 'foo%5Bbar%5D=',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'etc': 'xyz',
        },
      }: 'foo%5Bbar%5D=baz'
          '&foo%5Betc%5D=xyz',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'int': 123,
          'double': 456.789,
          'zero': 0,
          'negZero': -0,
          'negInt': -123,
          'negDouble': -456.789,
          'emptyString': '',
          'nullValue': null,
        },
      }: 'foo%5Bbar%5D=baz'
          '&foo%5Bint%5D=123'
          '&foo%5Bdouble%5D=456.789'
          '&foo%5Bzero%5D=0'
          '&foo%5BnegZero%5D=0'
          '&foo%5BnegInt%5D=-123'
          '&foo%5BnegDouble%5D=-456.789'
          '&foo%5BemptyString%5D='
          '&foo%5BnullValue%5D=',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
        },
        'etc': 'xyz',
      }: 'foo%5Bbar%5D=baz'
          '&etc=xyz',
      {
        'foo': <String, dynamic>{
          'bar': 'baz',
          'zap': 'abc',
          'etc': <String, dynamic>{
            'abc': 'def',
            'ghi': 'jkl',
            'mno': <String, dynamic>{
              'opq': 'rst',
              'uvw': 'xyz',
            },
          },
        },
      }: 'foo%5Bbar%5D=baz'
          '&foo%5Bzap%5D=abc'
          '&foo%5Betc%5D%5Babc%5D=def'
          '&foo%5Betc%5D%5Bghi%5D=jkl'
          '&foo%5Betc%5D%5Bmno%5D%5Bopq%5D=rst'
          '&foo%5Betc%5D%5Bmno%5D%5Buvw%5D=xyz',
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
