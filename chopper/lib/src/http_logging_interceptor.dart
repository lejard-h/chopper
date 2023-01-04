import 'dart:async';

import 'package:chopper/src/interceptor.dart';
import 'package:chopper/src/request.dart';
import 'package:chopper/src/response.dart';
import 'package:chopper/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

enum Level {
  /// No logs.
  none,

  /// Logs request and response lines.
  ///
  /// Example:
  /// ```
  /// --> POST /greeting (3-byte body)
  ///
  /// <-- 200 OK (6-byte body)
  /// ```
  basic,

  /// Logs request and response lines and their respective headers.
  ///
  /// Example:
  /// ```
  /// --> POST /greeting
  /// Host: example.com
  /// Content-Type: plain/text
  /// Content-Length: 3
  /// --> END POST
  ///
  /// <-- 200 OK
  /// Content-Type: plain/text
  /// Content-Length: 6
  /// <-- END HTTP
  /// ```
  headers,

  /// Logs request and response lines and their respective headers and bodies (if present).
  ///
  /// Example:
  /// ```
  /// --> POST /greeting
  /// Host: example.com
  /// Content-Type: plain/text
  /// Content-Length: 3
  ///
  /// Hi?
  /// --> END POST
  ///
  /// <-- 200 OK
  /// Content-Type: plain/text
  /// Content-Length: 6
  ///
  /// Hello!
  /// <-- END HTTP
  /// ```
  body,
}

/// A [RequestInterceptor] and [ResponseInterceptor] implementation which logs
/// HTTP request and response data.
///
/// **Warning:** Log messages written by this interceptor have the potential to
/// leak sensitive information, such as `Authorization` headers and user data
/// in response bodies. This interceptor should only be used in a controlled way
/// or in a non-production environment.
@immutable
class HttpLoggingInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  const HttpLoggingInterceptor({this.level = Level.basic})
      : _logBody = level == Level.body,
        _logHeaders = level == Level.body || level == Level.headers;

  final Level level;
  final bool _logBody;
  final bool _logHeaders;

  @override
  FutureOr<Request> onRequest(Request request) async {
    if (level == Level.none) return request;
    final http.BaseRequest base = await request.toBaseRequest();

    String startRequestMessage = '--> ${base.method} ${base.url.toString()}';
    String bodyMessage = '';
    if (base is http.Request) {
      final body = base.body;
      if (!_logHeaders && body.isNotEmpty) {
        startRequestMessage += ' (${base.bodyBytes.length}-byte body)';
      }
      if (body.isNotEmpty) {
        bodyMessage = body;
      }
    }

    // Always start on a new line
    chopperLogger.info('');
    chopperLogger.info(startRequestMessage);

    if (_logHeaders) {
      base.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

      if (base.contentLength != null &&
          base.headers['content-length'] == null) {
        chopperLogger.info('content-length: ${base.contentLength}');
      }
    }

    if (_logBody && bodyMessage.isNotEmpty) {
      chopperLogger.info('');
      chopperLogger.info(bodyMessage);
    }

    if (_logHeaders || _logBody) {
      chopperLogger.info('--> END ${base.method} ${base.url.toString()}');
    }

    return request;
  }

  @override
  FutureOr<Response> onResponse(Response response) {
    if (level == Level.none) return response;

    String bytes = '';
    String reasonPhrase = response.statusCode.toString();
    String bodyMessage = '';
    if (response.base is http.Response) {
      final resp = response.base as http.Response;
      if (resp.reasonPhrase != null) {
        reasonPhrase +=
            ' ${resp.reasonPhrase != reasonPhrase ? resp.reasonPhrase : ''}';
      }

      if (resp.body.isNotEmpty) {
        bodyMessage = resp.body;
        if (!_logBody && !_logHeaders) {
          bytes = ' (${response.bodyBytes.length}-byte body)';
        }
      }
    }

    // Always start on a new line
    chopperLogger.info('');
    chopperLogger.info(
      '<-- $reasonPhrase ${response.base.request?.method} ${response.base.request?.url.toString()}$bytes',
    );

    if (_logHeaders) {
      response.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

      if (response.base.contentLength != null &&
          response.headers['content-length'] == null) {
        chopperLogger.info('content-length: ${response.base.contentLength}');
      }
    }

    if (_logBody && bodyMessage.isNotEmpty) {
      chopperLogger.info('');
      chopperLogger.info(bodyMessage);
    }

    if (_logBody || _logHeaders) {
      chopperLogger.info('<-- END');
    }

    return response;
  }
}
