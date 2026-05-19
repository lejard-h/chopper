// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'request_features.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RequestFeatureService extends RequestFeatureService {
  _$RequestFeatureService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RequestFeatureService;

  @override
  Future<Response<String>> searchResources(
    Map<String, dynamic> filters, {
    required DateTime startsAt,
    Future<void>? abortTrigger,
  }) {
    final Uri $url = Uri.parse('/features/search');
    final Map<String, dynamic> $params = <String, dynamic>{
      'starts_at': startsAt,
    };
    $params.addAll(filters);
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      listFormat: ListFormat.brackets,
      dateFormat: DateFormat.date,
      abortTrigger: abortTrigger,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<String>> submitForm(String resourceId, String action) {
    final Uri $url = Uri.parse('/features/form');
    final Map<String, String> $headers = {
      'content-type': 'application/x-www-form-urlencoded',
    };
    final $body = <String, String>{
      'resource_id': resourceId.toString(),
      'action': action.toString(),
    };
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<String, String>($request);
  }
}
