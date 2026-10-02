@TestOn('vm')
@Timeout(Duration(seconds: 120))
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('generated method timeouts reach HTTP requests', () async {
    final String packageDirectory = Directory.current.path;
    // Older Dart SDKs generate different valid fixture text; they still run
    // the timeout smoke test in the minimum-Dart CI job.
    final bool verifyFixtures =
        Platform.environment['CHOPPER_SKIP_GENERATED_FIXTURE_CHECK'] != 'true';
    Future<void> expectCommittedFixtures() async {
      final ProcessResult diff = await Process.run('git', [
        'diff',
        '--exit-code',
        'HEAD',
        '--',
        'test/*.chopper.dart',
        'example/*.chopper.dart',
      ], workingDirectory: packageDirectory);
      expect(
        diff.exitCode,
        0,
        reason:
            'Generated fixtures differ from HEAD:\n${diff.stdout}\n${diff.stderr}',
      );
    }

    if (verifyFixtures) await expectCommittedFixtures();
    final ProcessResult build = await Process.run(Platform.resolvedExecutable, [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ], workingDirectory: packageDirectory);
    expect(
      build.exitCode,
      0,
      reason: 'build_runner failed:\n${build.stdout}\n${build.stderr}',
    );

    final ProcessResult smokeTest =
        await Process.run(Platform.resolvedExecutable, [
          'test',
          'test/base_test.dart',
          '--plain-name',
          'configured timeout supplies an HTTP abort trigger',
        ], workingDirectory: packageDirectory);
    expect(
      smokeTest.exitCode,
      0,
      reason:
          'generated timeout smoke test failed:\n${smokeTest.stdout}\n${smokeTest.stderr}',
    );
    if (verifyFixtures) await expectCommittedFixtures();
  });
}
