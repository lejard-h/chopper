import 'package:build/build.dart';
import 'package:chopper/chopper.dart' show ChopperApi;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

import 'generator.dart';

/// Creates a [PartBuilder] used to generate code for [ChopperApi] annotated
/// classes. The [options] are provided by Dart's build system and read from the
/// `build.yaml` file.
Builder chopperGeneratorFactory(BuilderOptions options) {
  final String buildExtension = _getBuildExtension(options);

  return PartBuilder(
    [const ChopperGenerator()],
    buildExtension,
    header: options.config['header'],
    formatOutput: PartBuilder(
      [const ChopperGenerator()],
      buildExtension,
    ).formatOutput,
    options: !options.config.containsKey('build_extensions')
        ? options.overrideWith(
            BuilderOptions({
              'build_extensions': {
                '.dart': [buildExtension]
              },
            }),
          )
        : options,
  );
}

/// Returns the build extension for the generated file.
///
/// If the `build.yaml` file contains a `build_extensions` key, it will be used
/// to determine the extension. Otherwise, the default extension `.chopper.dart`
/// will be used.
///
/// Example `build.yaml`:
///
/// ```yaml
/// targets:
///   $default:
///     builders:
///       chopper_generator:
///         options:
///           build_extensions: {".dart": [".chopper.g.dart"]}
/// ```
String _getBuildExtension(BuilderOptions options) {
  if (options.config.containsKey('build_extensions')) {
    final YamlMap buildExtensions = options.config['build_extensions'];
    if (buildExtensions.containsKey('.dart')) {
      final YamlList dartBuildExtensions = buildExtensions['.dart'];
      if (dartBuildExtensions.isNotEmpty) {
        return dartBuildExtensions.first;
      }
    }
  }
  return '.chopper.dart';
}
