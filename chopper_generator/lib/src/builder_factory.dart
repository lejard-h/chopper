import 'package:build/build.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates a [PartBuilder] used to generate code for [chopper.ChopperApi] annotated
/// classes. The [options] are provided by Dart's build system and read from the
/// `build.yaml` file.
Builder chopperGeneratorFactory(BuilderOptions options) {
  // Determine the build extension for the generated file.
  // Default is `.chopper.dart`, but can be overridden in `build.yaml`.
  final String buildExtension = _getBuildExtension(options);

  // Create and return the PartBuilder with the ChopperGenerator.
  return PartBuilder(
    const [ChopperGenerator()],
    buildExtension,
    header: options.config['header'],
    formatOutput: PartBuilder(
      const [ChopperGenerator()],
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
String _getBuildExtension(BuilderOptions options) => switch (options.config) {
      {'build_extensions': {'.dart': [final String ext, ...]}} => ext,
      _ => '.chopper.dart',
    };
