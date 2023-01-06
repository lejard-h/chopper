import 'package:chopper/src/request.dart';
import 'package:chopper/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('mapToQuery single', () {
    <Map<String, dynamic>, String>{
      {'foo': null}: '',
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
      {'foo': '', 'baz': ''}: 'foo=&baz=',
      {'foo': null, 'baz': ''}: 'baz=',
      {'foo': '', 'baz': null}: 'foo=',
      {'foo': 'bar', 'baz': ''}: 'foo=bar&baz=',
      {'foo': null, 'baz': 'etc'}: 'baz=etc',
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
      }: 'foo=bar&foo=baz&foo=etc&bar=baz&etc=',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery lists with includeNullQueryVars', () {
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
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(mapToQuery(map, includeNullQueryVars: true), query),
      ),
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
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc&bar=baz&etc=',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, useBrackets: true),
          query,
        ),
      ),
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
      }: 'foo%5B%5D=bar&foo%5B%5D=baz&foo%5B%5D=etc&bar=baz&etc=&xyz=',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, useBrackets: true, includeNullQueryVars: true),
          query,
        ),
      ),
    );
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
      }: 'foo.bar=baz&foo.int=123&foo.double=456.789&foo.zero=0&foo.negInt=-123&foo.negDouble=-456.789&foo.emptyString=&foo.space=%20&foo.tab=%09&foo.list=a&foo.list=123&foo.list=false',
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
      }: 'foo.bar=baz&foo.zap=abc&foo.etc.abc=def&foo.etc.ghi=jkl&foo.etc.mno.opq=rst&foo.etc.mno.uvw=xyz&foo.etc.mno.aab=bbc&foo.etc.mno.aab=ccd&foo.etc.mno.aab=eef',
    }.forEach((map, query) =>
        test('$map -> $query', () => expect(mapToQuery(map), query)));
  });

  group('mapToQuery maps with includeNullQueryVars', () {
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
      }: 'foo.bar=baz&foo.int=123&foo.double=456.789&foo.zero=0&foo.negInt=-123&foo.negDouble=-456.789&foo.emptyString=&foo.nullValue=&foo.space=%20&foo.tab=%09&foo.list=a&foo.list=123&foo.list=false',
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
      }: 'foo.bar=baz&foo.zap=abc&foo.etc.abc=def&foo.etc.ghi=jkl&foo.etc.mno.opq=rst&foo.etc.mno.uvw=xyz&foo.etc.mno.aab=bbc&foo.etc.mno.aab=ccd&foo.etc.mno.aab=eef',
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(mapToQuery(map, includeNullQueryVars: true), query),
      ),
    );
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
      }: 'foo%5Bbar%5D=baz&foo%5Bint%5D=123&foo%5Bdouble%5D=456.789&foo%5Bzero%5D=0&foo%5BnegInt%5D=-123&foo%5BnegDouble%5D=-456.789&foo%5BemptyString%5D=&foo%5Bspace%5D=%20&foo%5Btab%5D=%09&foo%5Blist%5D%5B%5D=a&foo%5Blist%5D%5B%5D=123&foo%5Blist%5D%5B%5D=false',
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
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, useBrackets: true),
          query,
        ),
      ),
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
    }.forEach(
      (map, query) => test(
        '$map -> $query',
        () => expect(
          mapToQuery(map, useBrackets: true, includeNullQueryVars: true),
          query,
        ),
      ),
    );
  });

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
