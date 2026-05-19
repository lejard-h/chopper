library;

import 'package:built_value/serializer.dart';

import 'built_value_resource.dart';

part 'built_value_serializers.g.dart';

/// Collection of generated serializers for the built_value Chopper example.
@SerializersFor([Resource, ResourceError, VisitType])
final Serializers serializers = _$serializers;
