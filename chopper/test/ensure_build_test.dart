@TestOn('vm')
@Timeout(Duration(seconds: 120))
library;

import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test(
    'ensure_build',
    () async {
      await expectBuildClean(
        packageRelativeDirectory: 'chopper',
        gitDiffPathArguments: [
          'test/test_service.chopper.dart',
          'test/test_service_variable.chopper.dart',
          'test/test_without_response_service.chopper.dart',
          'test/test_service_base_url.chopper.dart',
        ],
      );
    },
  );
}
