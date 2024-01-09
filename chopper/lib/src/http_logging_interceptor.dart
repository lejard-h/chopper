import 'dart:async';

import 'package:chopper/src/chopper_log_record.dart';
import 'package:chopper/src/interceptor.dart';
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
/// A [RequestInterceptor] and [ResponseInterceptor] implementation which logs
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
class HttpLoggingInterceptor
    implements RequestInterceptor, ResponseInterceptor {
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
  FutureOr<Request> onRequest(Request request) async {
    if (level == Level.none) return request;
    final http.BaseRequest base = await request.toBaseRequest();

    String startRequestMessage = '--> ${base.method} ${base.url.toString()}';
    String bodyMessage = '';
    if (base is http.Request) {
      if (base.body.isNotEmpty) {
        bodyMessage = base.body;

        if (!_logHeaders) {
          startRequestMessage += ' (${base.bodyBytes.length}-byte body)';
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', request: request));
    _logger.info(ChopperLogRecord(startRequestMessage, request: request));

    if (_logHeaders) {
      base.headers.forEach(
        (k, v) => _logger.info(ChopperLogRecord('$k: $v', request: request)),
      );

      if (base.contentLength != null &&
          base.headers['content-length'] == null) {
        _logger.info(ChopperLogRecord(
          'content-length: ${base.contentLength}',
          request: request,
        ));
      }
    }

    if (_logBody && bodyMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', request: request));
      _logger.info(ChopperLogRecord(bodyMessage, request: request));
    }

    if (_logHeaders || _logBody) {
      _logger.info(ChopperLogRecord(
        '--> END ${base.method}',
        request: request,
      ));
    }

    return request;
  }

  @override
  FutureOr<Response> onResponse(Response response) {
    if (level == Level.none) return response;
    final base = response.base;

    String bytes = '';
    String reasonPhrase = response.statusCode.toString();
    String bodyMessage = '';
    if (base is http.Response) {
      if (base.reasonPhrase != null) {
        reasonPhrase +=
            ' ${base.reasonPhrase != reasonPhrase ? base.reasonPhrase : ''}';
      }

      if (base.body.isNotEmpty) {
        bodyMessage = base.body;

        if (!_logBody && !_logHeaders) {
          bytes = ' (${response.bodyBytes.length}-byte body)';
        }
      }
    }

    // Always start on a new line
    _logger.info(ChopperLogRecord('', response: response));
    _logger.info(ChopperLogRecord(
      '<-- $reasonPhrase ${base.request?.method} ${base.request?.url.toString()}$bytes',
      response: response,
    ));

    if (_logHeaders) {
      base.headers.forEach(
        (k, v) => _logger.info(ChopperLogRecord('$k: $v', response: response)),
      );

      if (base.contentLength != null &&
          base.headers['content-length'] == null) {
        _logger.info(ChopperLogRecord(
          'content-length: ${base.contentLength}',
          response: response,
        ));
      }
    }

    if (_logBody && bodyMessage.isNotEmpty) {
      _logger.info(ChopperLogRecord('', response: response));
      _logger.info(ChopperLogRecord(bodyMessage, response: response));
    }

    if (_logBody || _logHeaders) {
      _logger.info(ChopperLogRecord('<-- END HTTP', response: response));
    }

    return response;
  }
}
