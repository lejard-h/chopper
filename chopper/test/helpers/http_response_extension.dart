import 'package:http/http.dart' as http;

extension HttpResponseExtension on http.Response {
  http.Response copyWith({
    String? body,
    int? statusCode,
    Map<String, String>? headers,
    bool? isRedirect,
    bool? persistentConnection,
    String? reasonPhrase,
  }) =>
      http.Response(
        body ?? this.body,
        statusCode ?? this.statusCode,
        request: request,
        headers: headers ?? this.headers,
        reasonPhrase: reasonPhrase ?? this.reasonPhrase,
        isRedirect: isRedirect ?? this.isRedirect,
        persistentConnection: persistentConnection ?? this.persistentConnection,
      );
}
