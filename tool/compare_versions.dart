import 'dart:io' show exitCode, stderr, stdout;
import 'package:cli_script/cli_script.dart' show wrapMain;
import 'package:pub_semver/pub_semver.dart' show Version;

void main(List<String> args) {
  wrapMain(() {
    exitCode = 0;

    if (args.length != 2) {
      stderr.write(
        'Please provide two arguments!\n\nExample usage:\ndart run compare_versions.dart 2.0.0+1 1.9.0+5\n',
      );
      exitCode = 1;
      return;
    }

    late final Version v1;
    late final Version v2;

    try {
      v1 = Version.parse(args[0]);
    } on FormatException catch (e) {
      stderr.write('Error parsing version 1: ${e.message}');
      exitCode = 1;
      return;
    }

    try {
      v2 = Version.parse(args[1]);
    } on FormatException catch (e) {
      stderr.write('Error parsing version 2: ${e.message}');
      exitCode = 1;
      return;
    }

    stdout.write(v1 > v2 ? 1 : 0);
  });
}
