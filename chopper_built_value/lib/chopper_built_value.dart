import 'package:chopper/chopper.dart';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

class BuiltValueConverter implements Converter, ErrorConverter {
  final Serializers serializers;
  final JsonConverter jsonConverter = JsonConverter();
  final Type errorType;

  BuiltValueConverter(this.serializers, {this.errorType});

  T _deserialize<T>(dynamic value) {
    var serializer;
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
    final deserialized = value.map((value) => _deserialize<InnerType>(value));
    return BuiltList<InnerType>(deserialized.toList(growable: false));
  }

  BodyType deserialize<BodyType, InnerType>(entity) {
    if (entity is BodyType) return entity;
    if (entity is Iterable) {
      return _deserializeListOf<InnerType>(entity) as BodyType;
    }
    return _deserialize<BodyType>(entity);
  }

  @override
  Request convertRequest(Request request) {
    request = request.copyWith(body: serializers.serialize(request.body));
    return jsonConverter.convertRequest(request);
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    final jsonResponse = jsonConverter.convertResponse(response);
    final body = deserialize<BodyType, InnerType>(jsonResponse.body);
    return jsonResponse.copyWith(body: body);
  }

  @override
  Response convertError<BodyType, InnerType>(Response response) {
    final jsonResponse = jsonConverter.convertResponse(response);

    var body;

    try {
      // try to deserialize using wireName
      body ??= _deserialize(jsonResponse.body);
    } catch (_) {
      // or check provided error type
      if (errorType != null) {
        final serializer = serializers.serializerForType(errorType);
        print(serializer);
        body = serializers.deserializeWith(serializer, jsonResponse.body);
      }
      body ??= jsonResponse.body;
    }

    return jsonResponse.copyWith(body: body);
  }
}
