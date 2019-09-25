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
  Iterable<Object> serialize(Serializers serializers, Resource object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  Resource deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ResourceBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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
  Iterable<Object> serialize(Serializers serializers, ResourceError object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
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
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ResourceErrorBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
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

  factory _$Resource([void Function(ResourceBuilder) updates]) =>
      (new ResourceBuilder()..update(updates)).build();

  _$Resource._({this.id, this.name}) : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('Resource', 'id');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('Resource', 'name');
    }
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
    return (newBuiltValueToStringHelper('Resource')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class ResourceBuilder implements Builder<Resource, ResourceBuilder> {
  _$Resource _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  ResourceBuilder();

  ResourceBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Resource other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Resource;
  }

  @override
  void update(void Function(ResourceBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Resource build() {
    final _$result = _$v ?? new _$Resource._(id: id, name: name);
    replace(_$result);
    return _$result;
  }
}

class _$ResourceError extends ResourceError {
  @override
  final String type;
  @override
  final String message;

  factory _$ResourceError([void Function(ResourceErrorBuilder) updates]) =>
      (new ResourceErrorBuilder()..update(updates)).build();

  _$ResourceError._({this.type, this.message}) : super._() {
    if (type == null) {
      throw new BuiltValueNullFieldError('ResourceError', 'type');
    }
    if (message == null) {
      throw new BuiltValueNullFieldError('ResourceError', 'message');
    }
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
    return (newBuiltValueToStringHelper('ResourceError')
          ..add('type', type)
          ..add('message', message))
        .toString();
  }
}

class ResourceErrorBuilder
    implements Builder<ResourceError, ResourceErrorBuilder> {
  _$ResourceError _$v;

  String _type;
  String get type => _$this._type;
  set type(String type) => _$this._type = type;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  ResourceErrorBuilder();

  ResourceErrorBuilder get _$this {
    if (_$v != null) {
      _type = _$v.type;
      _message = _$v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceError other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ResourceError;
  }

  @override
  void update(void Function(ResourceErrorBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ResourceError build() {
    final _$result = _$v ?? new _$ResourceError._(type: type, message: message);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
