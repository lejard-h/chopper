import 'dart:typed_data';

import 'package:chopper/src/chopper_http_exception.dart';
import 'package:equatable/equatable.dart' show EquatableMixin;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// {@template response}
/// A [http.BaseResponse] wrapper representing a response of a Chopper network call.
///
/// ```dart
/// @Get(path: '/something')
/// Future<Response> fetchSomething();
/// ```
///
/// ```dart
/// @Get(path: '/items/{id}')
/// Future<Response<Item>> fetchItem();
/// ```
/// {@endtemplate}
@immutable
base class Response<BodyType> with EquatableMixin {
  /// The [http.BaseResponse] from `package:http` that this [Response] wraps.
  final http.BaseResponse base;

  /// The body of the response after conversion by Chopper
  /// See [Converter] for more on body conversion.
  ///
  /// Can be null if [isSuccessful] is not true.
  /// Use [error] to get error body.
  final BodyType? body;

  /// The body of the response if [isSuccessful] is false.
  final Object? error;

  /// {@macro response}
  const Response(this.base, this.body, {this.error});

  /// Makes a copy of this Response, replacing original values with the given ones.
  /// This method can also alter the type of the response body.
  Response<NewBodyType> copyWith<NewBodyType>({
    http.BaseResponse? base,
    NewBodyType? body,
    Object? bodyError,
  }) =>
      Response<NewBodyType>(
        base ?? this.base,
        body ?? (this.body as NewBodyType?),
        error: bodyError ?? error,
      );

  /// The HTTP status code of the response.
  int get statusCode => base.statusCode;

  /// Whether the network call was successful or not.
  ///
  /// `true` if the result code of the network call is >= 200 && <300
  /// If false, [error] will contain the converted error response body.
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  /// HTTP headers of the response.
  Map<String, String> get headers => base.headers;

  /// Returns the response body as bytes ([Uint8List]) provided the network
  /// call was successful, else this will be `null`.
  Uint8List get bodyBytes =>
      base is http.Response ? (base as http.Response).bodyBytes : Uint8List(0);

  /// Returns the response body as a String provided the network
  /// call was successful, else this will be `null`.
  String get bodyString =>
      base is http.Response ? (base as http.Response).body : '';

  /// Check if the response is an error and if the error is of type [ErrorType] and casts the error to [ErrorType]. Otherwise it returns null.
  ErrorType? errorWhereType<ErrorType>() {
    if (error != null && error is ErrorType) {
      return error as ErrorType;
    } else {
      return null;
    }
  }

  /// Returns the response body if [Response] [isSuccessful] and [body] is not null.
  /// Otherwise it throws an [HttpException] with the response status code and error object.
  /// If the error object is an [Exception], it will be thrown instead.
  BodyType get bodyOrThrow {
    if (isSuccessful && body != null) {
      return body!;
    } else {
      if (error is Exception) {
        throw error!;
      }
      throw ChopperHttpException(this);
    }
  }

  @override
  List<Object?> get props => [
        base,
        body,
        error,
      ];
}

///
/// [Response] mixin for the purposes of creating mocks
/// using a mocking framework such as Mockito or Mocktail.
///
/// ```dart
/// base class MockResponse<BodyType> extends Mock with MockResponseMixin<BodyType> {}
/// ```
///
@visibleForTesting
base mixin MockResponseMixin<BodyType> implements Response<BodyType> {}
