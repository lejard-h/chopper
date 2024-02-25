/// Chopper is an http client generator using source_gen and inspired by Retrofit.
///
/// [Getting Started](https://hadrien-lejard.gitbook.io/chopper)
library chopper;

export 'src/annotations.dart';
export 'src/authenticator.dart';
export 'src/base.dart';
export 'src/chopper_http_exception.dart';
export 'src/chopper_log_record.dart';
export 'src/constants.dart';
export 'src/extensions.dart';
export 'src/http_logging_interceptor.dart';
export 'src/interceptor.dart';
export 'src/request.dart';
export 'src/response.dart';
export 'src/utils.dart' hide mapToQuery;
