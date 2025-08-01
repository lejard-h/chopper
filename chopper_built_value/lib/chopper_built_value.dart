import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:chopper/chopper.dart';

/// A custom [Converter] and [ErrorConverter] that handles conversion for classes
/// having a serializer implementation made with the built_value package.
class BuiltValueConverter implements Converter, ErrorConverter {
  final Serializers serializers;
  static const JsonConverter jsonConverter = JsonConverter();
  final Type? errorType;

  /// Builds a new BuiltValueConverter instance that uses built_value serializers defined
  /// in the provided [serializers] parameter.
  ///
  /// If the error body cannot be converted with serializers and [errorType] is provided
  /// and it's not `null`, BuiltValueConverter will try to deserialize the error body into
  /// [errorType].
  const BuiltValueConverter(this.serializers, {this.errorType});

  T? _deserialize<T>(dynamic value) {
    dynamic serializer;
    if (value is Map && value.containsKey('\$')) {
      serializer = serializers.serializerForWireName(value['\$']);
    }
    serializer ??= serializers.serializerForType(T);

    if (serializer == null) {
      throw 'Serializer not found for $T';
    }

    return serializers.deserializeWith<T>(serializer, value);
  }

  BuiltList<InnerType> _deserializeListOf<InnerType>(Iterable value) {
    final Iterable<InnerType?> deserialized =
        value.map((value) => _deserialize<InnerType>(value));

    return BuiltList<InnerType>(deserialized.toList(growable: false));
  }

  BodyType? deserialize<BodyType, InnerType>(dynamic entity) {
    if (entity is BodyType) return entity;
    if (entity is Iterable) {
      return _deserializeListOf<InnerType>(entity) as BodyType;
    }

    return _deserialize<BodyType>(entity);
  }

  @override
  Request convertRequest(Request request) => jsonConverter.convertRequest(
        request.copyWith(body: serializers.serialize(request.body)),
      );

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
    Response response,
  ) async {
    final Response jsonResponse = await jsonConverter.convertResponse(response);

    return jsonResponse.copyWith(
      body: deserialize<BodyType, InnerType>(jsonResponse.body),
    );
  }

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(
    Response response,
  ) async {
    final Response jsonResponse = await jsonConverter.convertResponse(response);

    dynamic body;

    try {
      // try to deserialize using wireName
      body ??= _deserialize(jsonResponse.body);
    } catch (_) {
      final type = errorType;
      // or check provided error type
      if (type != null) {
        final serializer = serializers.serializerForType(type);
        if (serializer != null) {
          body = serializers.deserializeWith(serializer, jsonResponse.body);
        }
      }
      body ??= jsonResponse.body;
    }

    return jsonResponse.copyWith(body: body);
  }
}
