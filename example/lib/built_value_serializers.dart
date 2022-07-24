library serializers;

import 'package:built_value/serializer.dart';

import 'built_value_resource.dart';

part 'built_value_serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([
  Resource,
  ResourceError,
])
final Serializers serializers = _$serializers;
