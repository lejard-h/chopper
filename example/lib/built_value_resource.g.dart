// GENERATED CODE - DO NOT MODIFY BY HAND

part of resource;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Resource> _$resourceSerializer = new _$ResourceSerializer();
Serializer<ResourceError> _$resourceErrorSerializer =
    new _$ResourceErrorSerializer();

class _$ResourceSerializer implements StructuredSerializer<Resource> {
  @override
  final Iterable<Type> types = const [Resource, _$Resource];
  @override
  final String wireName = 'Resource';

  @override
  Iterable<Object?> serialize(Serializers serializers, Resource object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Resource deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ResourceBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$ResourceErrorSerializer implements StructuredSerializer<ResourceError> {
  @override
  final Iterable<Type> types = const [ResourceError, _$ResourceError];
  @override
  final String wireName = 'ResourceError';

  @override
  Iterable<Object?> serialize(Serializers serializers, ResourceError object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'type',
      serializers.serialize(object.type, specifiedType: const FullType(String)),
      'message',
      serializers.serialize(object.message,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  ResourceError deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ResourceErrorBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Resource extends Resource {
  @override
  final String id;
  @override
  final String name;

  factory _$Resource([void Function(ResourceBuilder)? updates]) =>
      (new ResourceBuilder()..update(updates))._build();

  _$Resource._({required this.id, required this.name}) : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Resource', 'id');
    BuiltValueNullFieldError.checkNotNull(name, r'Resource', 'name');
  }

  @override
  Resource rebuild(void Function(ResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBuilder toBuilder() => new ResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Resource && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, id.hashCode), name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Resource')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class ResourceBuilder implements Builder<Resource, ResourceBuilder> {
  _$Resource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ResourceBuilder();

  ResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Resource other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Resource;
  }

  @override
  void update(void Function(ResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Resource build() => _build();

  _$Resource _build() {
    final _$result = _$v ??
        new _$Resource._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Resource', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'Resource', 'name'));
    replace(_$result);
    return _$result;
  }
}

class _$ResourceError extends ResourceError {
  @override
  final String type;
  @override
  final String message;

  factory _$ResourceError([void Function(ResourceErrorBuilder)? updates]) =>
      (new ResourceErrorBuilder()..update(updates))._build();

  _$ResourceError._({required this.type, required this.message}) : super._() {
    BuiltValueNullFieldError.checkNotNull(type, r'ResourceError', 'type');
    BuiltValueNullFieldError.checkNotNull(message, r'ResourceError', 'message');
  }

  @override
  ResourceError rebuild(void Function(ResourceErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceErrorBuilder toBuilder() => new ResourceErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceError &&
        type == other.type &&
        message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, type.hashCode), message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceError')
          ..add('type', type)
          ..add('message', message))
        .toString();
  }
}

class ResourceErrorBuilder
    implements Builder<ResourceError, ResourceErrorBuilder> {
  _$ResourceError? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ResourceErrorBuilder();

  ResourceErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceError other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ResourceError;
  }

  @override
  void update(void Function(ResourceErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceError build() => _build();

  _$ResourceError _build() {
    final _$result = _$v ??
        new _$ResourceError._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'ResourceError', 'type'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'ResourceError', 'message'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
