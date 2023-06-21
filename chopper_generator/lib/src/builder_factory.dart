import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates a [PartBuilder] used to generate code for any [ChopperService].
/// The [options] are provided by Dart's build system. It is read from the
/// `build.yaml` file.
Builder chopperGeneratorFactory(BuilderOptions options) => PartBuilder(
      [ChopperGenerator()],
      '.chopper.dart',
      header: options.config['header'],
      formatOutput:
          PartBuilder([ChopperGenerator()], '.chopper.dart').formatOutput,
      options: !options.config.containsKey('build_extensions')
          ? options.overrideWith(
              BuilderOptions({
                'build_extensions': {'.dart': '.chopper.dart'},
              }),
            )
          : options,
    );
