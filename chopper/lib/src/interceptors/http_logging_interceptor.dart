import 'dart:async';

import 'package:chopper/src/chain/chain.dart';
import 'package:chopper/src/chopper_log_record.dart';
import 'package:chopper/src/interceptors/interceptor.dart';
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
  HttpLoggingInterceptor({this.level = Level.body, Logger? logger})
      : _logger = logger ?? chopperLogger,
        _logBody = level == Level.body,
        _logHeaders = level == Level.body || level == Level.headers;

  final Level level;
  final Logger _logger;
  final bool _logBody;
  final bool _logHeaders;

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = chain.request;
    if (level == Level.none) return chain.proceed(request);
    final http.BaseRequest baseRequest = await request.toBaseRequest();

    String startRequestMessage =
        '--> ${baseRequest.method} ${baseRequest.url.toString()}';
    String bodyRequestMessage = '';
    if (baseRequest is http.Request) {
      if (baseRequest.body.isNotEmpty) {
        bodyRequestMessage = baseRequest.body;

        if (!_logHeaders) {
          startRequestMessage += ' (${baseRequest.bodyBytes.length}-byte body)';
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', request: request));
    _logger.info(ChopperLogRecord(startRequestMessage, request: request));

    if (_logHeaders) {
      baseRequest.headers.forEach(
        (k, v) => _logger.info(ChopperLogRecord('$k: $v', request: request)),
      );

      if (baseRequest.contentLength != null &&
          baseRequest.headers['content-length'] == null) {
        _logger.info(ChopperLogRecord(
          'content-length: ${baseRequest.contentLength}',
          request: request,
        ));
      }
    }

    if (_logBody && bodyRequestMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', request: request));
      _logger.info(ChopperLogRecord(bodyRequestMessage, request: request));
    }

    if (_logHeaders || _logBody) {
      _logger.info(ChopperLogRecord(
        '--> END ${baseRequest.method}',
        request: request,
      ));
    }
    final stopWatch = Stopwatch()..start();

    final response = await chain.proceed(request);

    stopWatch.stop();

    if (level == Level.none) return response;
    final baseResponse = response.base;

    String bytes = '';
    String reasonPhrase = response.statusCode.toString();
    String bodyResponseMessage = '';
    if (baseResponse is http.Response) {
      if (baseResponse.reasonPhrase != null) {
        reasonPhrase +=
            ' ${baseResponse.reasonPhrase != reasonPhrase ? baseResponse.reasonPhrase : ''}';
      }

      if (baseResponse.body.isNotEmpty) {
        bodyResponseMessage = baseResponse.body;

        if (!_logBody && !_logHeaders) {
          bytes = ', ${response.bodyBytes.length}-byte body';
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', response: response));
    _logger.info(ChopperLogRecord(
      '<-- $reasonPhrase ${baseResponse.request?.method} ${baseResponse.request?.url.toString()} (${stopWatch.elapsedMilliseconds}ms$bytes)',
      response: response,
    ));

    if (_logHeaders) {
      baseResponse.headers.forEach(
        (k, v) => _logger.info(ChopperLogRecord('$k: $v', response: response)),
      );

      if (baseResponse.contentLength != null &&
          baseResponse.headers['content-length'] == null) {
        _logger.info(ChopperLogRecord(
          'content-length: ${baseResponse.contentLength}',
          response: response,
        ));
      }
    }

    if (_logBody && bodyResponseMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', response: response));
      _logger.info(ChopperLogRecord(bodyResponseMessage, response: response));
    }

    if (_logBody || _logHeaders) {
      _logger.info(ChopperLogRecord('<-- END HTTP', response: response));
    }

    return response;
  }
}
