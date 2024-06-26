import 'dart:async' show Stream;

import 'package:chopper/src/extensions.dart';
import 'package:chopper/src/utils.dart';
import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:qs_dart/qs_dart.dart' show ListFormat;

/// {@template request}
/// This class represents an HTTP request that can be made with Chopper.
/// {@endtemplate}
base class Request extends http.BaseRequest with EquatableMixin {
  final Uri uri;
  final Uri baseUri;
  final dynamic body;
  final Map<String, dynamic> parameters;
  final Object? tag;
  final bool multipart;
  final List<PartValue> parts;
  final ListFormat? listFormat;
  @Deprecated('Use listFormat instead')
  final bool? useBrackets;
  final bool? includeNullQueryVars;

  /// {@macro request}
  Request(
    String method,
    this.uri,
    this.baseUri, {
    this.body,
    Map<String, dynamic>? parameters,
    Map<String, String> headers = const {},
    this.multipart = false,
    this.parts = const [],
    this.tag,
    this.listFormat,
    @Deprecated('Use listFormat instead') this.useBrackets,
    this.includeNullQueryVars,
  })  : assert(
            !baseUri.hasQuery,
            'baseUri should not contain query parameters.'
            'Use a request interceptor to add default query parameters'),
        // Merge uri.queryParametersAll in the final parameters object so the request object reflects all configured queryParameters
        parameters = {...uri.queryParametersAll, ...?parameters},
        super(
          method,
          buildUri(
            baseUri,
            uri,
            {...uri.queryParametersAll, ...?parameters},
            listFormat: listFormat,
            // ignore: deprecated_member_use_from_same_package
            useBrackets: useBrackets,
            includeNullQueryVars: includeNullQueryVars,
          ),
        ) {
    this.headers.addAll(headers);
  }

  /// Makes a copy of this [Request], replacing original values with the given ones.
  Request copyWith({
    String? method,
    Uri? uri,
    Uri? baseUri,
    dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, String>? headers,
    bool? multipart,
    List<PartValue>? parts,
    ListFormat? listFormat,
    @Deprecated('Use listFormat instead') bool? useBrackets,
    bool? includeNullQueryVars,
    Object? tag,
  }) =>
      Request(
        method ?? this.method,
        uri ?? this.uri,
        baseUri ?? this.baseUri,
        body: body ?? this.body,
        parameters: parameters ?? this.parameters,
        headers: headers ?? this.headers,
        multipart: multipart ?? this.multipart,
        parts: parts ?? this.parts,
        listFormat: listFormat ?? this.listFormat,
        // ignore: deprecated_member_use_from_same_package
        useBrackets: useBrackets ?? this.useBrackets,
        includeNullQueryVars: includeNullQueryVars ?? this.includeNullQueryVars,
        tag: tag ?? this.tag,
      );

  /// Builds a valid URI from [baseUrl], [url] and [parameters].
  ///
  /// If [url] starts with 'http://' or 'https://', baseUrl is ignored.
  @visibleForTesting
  static Uri buildUri(
    Uri baseUrl,
    Uri url,
    Map<String, dynamic> parameters, {
    ListFormat? listFormat,
    @Deprecated('Use listFormat instead') bool? useBrackets,
    bool? includeNullQueryVars,
  }) {
    // If the request's url is already a fully qualified URL, we can use it
    // as-is and ignore the baseUrl.
    final Uri uri = url.isScheme('HTTP') || url.isScheme('HTTPS')
        ? url
        : _mergeUri(baseUrl, url);

    // Check if parameter also has all the queryParameters from the url (not the merged uri)
    final bool parametersContainsUriQuery = parameters.keys
        .every((element) => url.queryParametersAll.keys.contains(element));
    final Map<String, dynamic> allParameters = parametersContainsUriQuery
        ? parameters
        : {...url.queryParametersAll, ...parameters};

    final String query = mapToQuery(
      allParameters,
      listFormat: listFormat,
      // ignore: deprecated_member_use_from_same_package
      useBrackets: useBrackets,
      includeNullQueryVars: includeNullQueryVars,
    );

    return query.isNotEmpty ? uri.replace(query: query) : uri;
  }

  /// Merges Uri into another Uri preserving queries and paths
  static Uri _mergeUri(Uri baseUri, Uri addToUri) {
    final path = baseUri.hasEmptyPath
        ? addToUri.path
        : '${baseUri.path.rightStrip('/')}/${addToUri.path.leftStrip('/')}';

    return baseUri.replace(
      path: path,
      query: addToUri.hasQuery ? addToUri.query : null,
    );
  }

  /// Converts this Chopper Request into a [http.BaseRequest].
  ///
  /// All [parameters] and [headers] are conserved.
  ///
  /// Depending on the request type the returning object will be:
  ///   - [http.StreamedRequest] if body is a [Stream<List<int>>]
  ///   - [http.MultipartRequest] if [multipart] is true
  ///   - or a [http.Request]
  Future<http.BaseRequest> toBaseRequest() async {
    if (body is Stream<List<int>>) return toStreamedRequest(body);

    if (multipart) return toMultipartRequest();

    return toHttpRequest();
  }

  /// Convert this [Request] to a [http.Request]
  @visibleForTesting
  http.Request toHttpRequest() {
    final http.Request request = http.Request(method, url)
      ..followRedirects = followRedirects;

    if (body == null) {
      request.headers.addAll(headers);
    } else {
      if (body is String) {
        request
          ..headers.addAll(headers)
          ..body = body;
      } else if (body is List<int>) {
        request
          ..bodyBytes = body
          ..headers.addAll(headers);
      } else if (body is Map<String, String>) {
        request
          ..headers.addAll(headers)
          ..bodyFields = body;
      } else {
        throw ArgumentError.value('$body', 'body');
      }
    }

    return request;
  }

  /// Convert this [Request] to a [http.MultipartRequest]
  @visibleForTesting
  Future<http.MultipartRequest> toMultipartRequest() async {
    final http.MultipartRequest request = http.MultipartRequest(method, url)
      ..headers.addAll(headers);

    for (final PartValue part in parts) {
      if (part.value == null) continue;

      if (part.value is http.MultipartFile) {
        request.files.add(part.value);
      } else if (part.value is Iterable<http.MultipartFile>) {
        request.files.addAll(part.value);
      } else if (part is PartValueFile) {
        if (part.value is List<int>) {
          request.files.add(
            http.MultipartFile.fromBytes(part.name, part.value),
          );
        } else if (part.value is String) {
          request.files.add(
            await http.MultipartFile.fromPath(part.name, part.value),
          );
        } else {
          throw ArgumentError(
            'Type ${part.value.runtimeType} is not a supported type for PartFile. '
            'Please use one of the following types:\n'
            '- List<int>\n'
            '- String (path of your file)\n'
            '- MultipartFile (from package:http)',
          );
        }
      } else if (part.value is Iterable) {
        request.fields.addAll({
          for (int i = 0; i < part.value.length; i++)
            '${part.name}[$i]': part.value.elementAt(i).toString(),
        });
      } else {
        request.fields[part.name] = part.value.toString();
      }
    }

    return request;
  }

  /// Convert this [Request] to a [http.StreamedRequest]
  @visibleForTesting
  http.StreamedRequest toStreamedRequest(Stream<List<int>> bodyStream) {
    final http.StreamedRequest request = http.StreamedRequest(method, url)
      ..headers.addAll(headers);

    bodyStream.listen(
      request.sink.add,
      onDone: request.sink.close,
      onError: request.sink.addError,
    );

    return request;
  }

  @override
  List<Object?> get props => [
        method,
        uri,
        baseUri,
        body,
        parameters,
        headers,
        multipart,
        parts,
        listFormat,
        // ignore: deprecated_member_use_from_same_package
        useBrackets,
        includeNullQueryVars,
      ];
}

///
/// [Request] mixin for the purposes of creating mocks
/// using a mocking framework such as Mockito or Mocktail.
///
/// ```dart
/// base class MockRequest extends Mock with MockRequestMixin {}
/// ```
///
@visibleForTesting
base mixin MockRequestMixin implements Request {}

/// Represents a part in a multipart request.
@immutable
final class PartValue<T> with EquatableMixin {
  final T value;
  final String name;

  const PartValue(
    this.name,
    this.value,
  );

  /// Makes a copy of this PartValue, replacing original values with the given ones.
  /// This method can also alter the type of the request body.
  PartValue<NewType> copyWith<NewType>({String? name, NewType? value}) =>
      PartValue<NewType>(
        name ?? this.name,
        value ?? this.value as NewType,
      );

  @override
  List<Object?> get props => [
        name,
        value,
      ];
}

///
/// [PartValue] mixin for the purposes of creating mocks
/// using a mocking framework such as Mockito or Mocktail.
///
/// ```dart
/// base class MockPartValue<T> extends Mock with MockPartValueMixin<T> {}
/// ```
///
@visibleForTesting
base mixin MockPartValueMixin<T> implements PartValue<T> {}

/// Represents a file [PartValue] in a multipart request.
@immutable
final class PartValueFile<T> extends PartValue<T> {
  const PartValueFile(super.name, super.value);
}

///
/// [PartValueFile] mixin for the purposes of creating mocks
/// using a mocking framework such as Mockito or Mocktail.
///
/// ```dart
/// base class MockPartValueFile<T> extends Mock with MockPartValueFileMixin<T> {}
/// ```
///
@visibleForTesting
base mixin MockPartValueFileMixin<T> implements PartValueFile<T> {}
