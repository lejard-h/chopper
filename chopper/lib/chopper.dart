/// Chopper is an http client generator using source_gen and inspired by Retrofit.
///
/// [Getting Started](https://hadrien-lejard.gitbook.io/chopper)
library chopper;

export 'package:qs_dart/qs_dart.dart' show ListFormat;
export 'src/annotations.dart';
export 'src/authenticator.dart';
export 'src/base.dart';
export 'src/chopper_http_exception.dart';
export 'src/chopper_exception.dart';
export 'src/chopper_log_record.dart';
export 'src/constants.dart';
export 'src/extensions.dart';
export 'src/chain/chain.dart';
export 'src/interceptors/interceptor.dart';
export 'src/converters.dart';
export 'src/request.dart';
export 'src/response.dart';
export 'src/utils.dart' hide mapToQuery;
