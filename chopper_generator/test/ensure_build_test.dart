@TestOn('vm')
import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test(
    'ensure_build',
    () => expectBuildClean(
      packageRelativeDirectory: 'chopper_generator',
      gitDiffPathArguments: [
        'test/test_service.chopper.dart',
      ],
    ),
  );
}
