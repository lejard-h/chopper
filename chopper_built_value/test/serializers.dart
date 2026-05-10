library;

import 'package:built_value/serializer.dart';

import 'data.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value
@SerializersFor([DataModel, ErrorModel, VisitType])
final Serializers serializers = _$serializers;
