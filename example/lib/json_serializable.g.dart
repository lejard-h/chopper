// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Resource', json, ($checkedConvert) {
      final val = Resource(
        $checkedConvert('id', (v) => v as String),
        $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ResourceToJson(Resource instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

ResourceError _$ResourceErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ResourceError', json, ($checkedConvert) {
      final val = ResourceError(
        $checkedConvert('type', (v) => v as String),
        $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ResourceErrorToJson(ResourceError instance) =>
    <String, dynamic>{'type': instance.type, 'message': instance.message};
