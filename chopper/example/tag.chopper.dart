// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TagService extends TagService {
  _$TagService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TagService;

  @override
  Future<Response<dynamic>> requestWithTag({BizTag tag = const BizTag()}) {
    final Uri $url = Uri.parse('/tag');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: tag,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> includeBodyNullOrEmptyTag(
      {IncludeBodyNullOrEmptyTag tag = const IncludeBodyNullOrEmptyTag()}) {
    final Uri $url = Uri.parse('/tag');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: tag,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
