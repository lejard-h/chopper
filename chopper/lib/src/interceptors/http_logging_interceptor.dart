import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chopper_log_record.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

enum Level {
  /// No logs.
  none,

  /// Logs request and response lines.
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting (3-byte body)
  ///
  /// <-- 200 OK POST https://foo.bar/greeting (6-byte body)
  /// ```
  basic,

  /// Logs request and response lines and their respective headers.
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 3
  /// --> END POST
  ///
  /// <-- 200 OK POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 6
  /// <-- END HTTP
  /// ```
  headers,

  /// Logs request and response lines and their respective headers and bodies (if present).
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 3
  ///
  /// Hi?
  /// --> END POST https://foo.bar/greeting
  ///
  /// <-- 200 OK POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 6
  ///
  /// Hello!
  /// <-- END HTTP
  /// ```
  body,
}

/// {@template http_logging_interceptor}
/// A [Interceptor] implementation which logs
/// HTTP request and response data.
///
/// Log levels can be set by applying [level] for more fine grained control
/// over amount of information being logged.
///
/// **Warning:** Log messages written by this interceptor have the potential to
/// leak sensitive information, such as `Authorization` headers and user data
/// in response bodies. This interceptor should only be used in a controlled way
/// or in a non-production environment.
/// {@endtemplate}
@immutable
class HttpLoggingInterceptor implements Interceptor {
  /// {@macro http_logging_interceptor}
  HttpLoggingInterceptor({
    this.level = Level.body,
    this.onlyErrors = false,
    Logger? logger,
  })  : _logger = logger ?? chopperLogger,
        _logBody = level == Level.body,
        _logHeaders = level == Level.body || level == Level.headers;

  final Level level;
  final bool onlyErrors;
  final Logger _logger;
  final bool _logBody;
  final bool _logHeaders;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final Request request = chain.request;

    final Stopwatch stopWatch = Stopwatch()..start();

    final Response<BodyType> response = await chain.proceed(request);

    stopWatch.stop();

    if (level == Level.none || (onlyErrors && response.statusCode < 400)) {
      return response;
    }

    final http.BaseRequest baseRequest = await request.toBaseRequest();

    final StringBuffer startRequestMessage = StringBuffer(
      '--> ${baseRequest.method} ${baseRequest.url.toString()}',
    );
    final StringBuffer bodyRequestMessage = StringBuffer();
    if (baseRequest is http.Request) {
      if (baseRequest.body.isNotEmpty) {
        bodyRequestMessage.write(baseRequest.body);

        if (!_logHeaders) {
          startRequestMessage.write(
            ' (${baseRequest.bodyBytes.length}-byte body)',
          );
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', request: request));
    _logger.info(
      ChopperLogRecord(startRequestMessage.toString(), request: request),
    );

    if (_logHeaders) {
      baseRequest.headers.forEach(
        (String k, String v) => _logger.info(
          ChopperLogRecord('$k: $v', request: request),
        ),
      );

      if (baseRequest.contentLength != null &&
          baseRequest.headers['content-length'] == null) {
        _logger.info(
          ChopperLogRecord(
            'content-length: ${baseRequest.contentLength}',
            request: request,
          ),
        );
      }
    }

    if (_logBody && bodyRequestMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', request: request));
      _logger.info(
        ChopperLogRecord(bodyRequestMessage.toString(), request: request),
      );
    }

    if (_logHeaders || _logBody) {
      _logger.info(
        ChopperLogRecord('--> END ${baseRequest.method}', request: request),
      );
    }

    final http.BaseResponse baseResponse = response.base;

    final StringBuffer bytes = StringBuffer();
    final StringBuffer reasonPhrase = StringBuffer(
      response.statusCode.toString(),
    );
    final StringBuffer bodyResponseMessage = StringBuffer();
    if (baseResponse is http.Response) {
      if (baseResponse.reasonPhrase != null) {
        if (baseResponse.reasonPhrase != reasonPhrase.toString()) {
          reasonPhrase.write(' ${baseResponse.reasonPhrase}');
        }
      }

      if (baseResponse.body.isNotEmpty) {
        bodyResponseMessage.write(baseResponse.body);

        if (!_logBody && !_logHeaders) {
          bytes.write(', ${response.bodyBytes.length}-byte body');
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', response: response));
    _logger.info(
      ChopperLogRecord(
        '<-- $reasonPhrase ${baseResponse.request?.method} ${baseResponse.request?.url.toString()} (${stopWatch.elapsedMilliseconds}ms$bytes)',
        response: response,
      ),
    );

    if (_logHeaders) {
      baseResponse.headers.forEach(
        (String k, String v) => _logger.info(
          ChopperLogRecord('$k: $v', response: response),
        ),
      );

      if (baseResponse.contentLength != null &&
          baseResponse.headers['content-length'] == null) {
        _logger.info(
          ChopperLogRecord(
            'content-length: ${baseResponse.contentLength}',
            response: response,
          ),
        );
      }
    }

    if (_logBody && bodyResponseMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', response: response));
      _logger.info(
        ChopperLogRecord(
          bodyResponseMessage.toString(),
          response: response,
        ),
      );
    }

    if (_logBody || _logHeaders) {
      _logger.info(ChopperLogRecord('<-- END HTTP', response: response));
    }

    return response;
  }
}
