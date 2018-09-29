import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:chopper_example/model.dart';

part "jaguar_serializer.jser.dart";

@GenSerializer()
class ResourceSerializer extends Serializer<Resource>
    with _$ResourceSerializer {}

@GenSerializer()
class ResourceErrorSerializer extends Serializer<ResourceError>
    with _$ResourceErrorSerializer {}
