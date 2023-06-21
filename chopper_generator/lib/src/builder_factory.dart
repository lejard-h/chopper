import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates a [PartBuilder] used to generate code for a [ChopperService].
/// The [options] are provided by Dart's build system and read from the
/// `build.yaml` file.
Builder chopperGeneratorFactory(BuilderOptions options) => PartBuilder(
      [const ChopperGenerator()],
      '.chopper.dart',
      header: options.config['header'],
      formatOutput:
          PartBuilder([const ChopperGenerator()], '.chopper.dart').formatOutput,
      options: !options.config.containsKey('build_extensions')
          ? options.overrideWith(
              BuilderOptions({
                'build_extensions': {'.dart': '.chopper.dart'},
              }),
            )
          : options,
    );
