// ignore_for_file: long-method

import 'package:chopper/src/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('String.leftStrip', () {
    test('leftStrip without character any leading whitespace', () {
      expect('/foo'.leftStrip(), '/foo');
      expect('     /foo'.leftStrip(), '/foo');
      expect('/foo   '.leftStrip(), '/foo   ');
      expect('   /foo   '.leftStrip(), '/foo   ');
    });

    test(
      'leftStrip with character removes single leading character and any leading whitespace',
      () {
        expect('/foo'.leftStrip('/'), 'foo');
        expect('//foo'.leftStrip('/'), '/foo');
        expect('     /foo'.leftStrip('/'), 'foo');
        expect('/foo   '.leftStrip('/'), 'foo   ');
        expect('   /foo   '.leftStrip('/'), 'foo   ');
      },
    );
  });

  group('String.rightStrip', () {
    test('rightStrip without character any trailing whitespace', () {
      expect('foo/'.rightStrip(), 'foo/');
      expect('     foo/'.rightStrip(), '     foo/');
      expect('foo/   '.rightStrip(), 'foo/');
      expect('   foo/   '.rightStrip(), '   foo/');
    });

    test(
      'rightStrip with character removes single trailing character and any trailing whitespace',
      () {
        expect('foo/'.rightStrip('/'), 'foo');
        expect('foo//'.rightStrip('/'), 'foo/');
        expect('     foo/'.rightStrip('/'), '     foo');
        expect('foo/   '.rightStrip('/'), 'foo');
        expect('   foo/   '.rightStrip('/'), '   foo');
      },
    );
  });

  group('String.strip', () {
    test('strip without character any leading and trailing whitespace', () {
      expect('/foo/'.strip(), '/foo/');
      expect('     /foo/'.strip(), '/foo/');
      expect('/foo/   '.strip(), '/foo/');
      expect('   /foo/   '.strip(), '/foo/');
    });

    test(
      'strip with character removes single leading and trailing character and any leading and trailing whitespace',
      () {
        expect('/foo/'.strip('/'), 'foo');
        expect('//foo//'.strip('/'), '/foo/');
        expect('     /foo/'.strip('/'), 'foo');
        expect('/foo/   '.strip('/'), 'foo');
        expect('   /foo/   '.strip('/'), 'foo');
      },
    );
  });
}
