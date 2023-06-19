import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

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
