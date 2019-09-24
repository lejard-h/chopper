// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<DataModel> _$dataModelSerializer = new _$DataModelSerializer();
Serializer<ErrorModel> _$errorModelSerializer = new _$ErrorModelSerializer();

class _$DataModelSerializer implements StructuredSerializer<DataModel> {
  @override
  final Iterable<Type> types = const [DataModel, _$DataModel];
  @override
  final String wireName = 'DataModel';

  @override
  Iterable<Object> serialize(Serializers serializers, DataModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  DataModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DataModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
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

class _$ErrorModelSerializer implements StructuredSerializer<ErrorModel> {
  @override
  final Iterable<Type> types = const [ErrorModel, _$ErrorModel];
  @override
  final String wireName = 'ErrorModel';

  @override
  Iterable<Object> serialize(Serializers serializers, ErrorModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'message',
      serializers.serialize(object.message,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  ErrorModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ErrorModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$DataModel extends DataModel {
  @override
  final int id;
  @override
  final String name;

  factory _$DataModel([void Function(DataModelBuilder) updates]) =>
      (new DataModelBuilder()..update(updates)).build();

  _$DataModel._({this.id, this.name}) : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('DataModel', 'id');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('DataModel', 'name');
    }
  }

  @override
  DataModel rebuild(void Function(DataModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DataModelBuilder toBuilder() => new DataModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DataModel && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, id.hashCode), name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DataModel')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class DataModelBuilder implements Builder<DataModel, DataModelBuilder> {
  _$DataModel _$v;

  int _id;
  int get id => _$this._id;
  set id(int id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  DataModelBuilder();

  DataModelBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DataModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$DataModel;
  }

  @override
  void update(void Function(DataModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$DataModel build() {
    final _$result = _$v ?? new _$DataModel._(id: id, name: name);
    replace(_$result);
    return _$result;
  }
}

class _$ErrorModel extends ErrorModel {
  @override
  final String message;

  factory _$ErrorModel([void Function(ErrorModelBuilder) updates]) =>
      (new ErrorModelBuilder()..update(updates)).build();

  _$ErrorModel._({this.message}) : super._() {
    if (message == null) {
      throw new BuiltValueNullFieldError('ErrorModel', 'message');
    }
  }

  @override
  ErrorModel rebuild(void Function(ErrorModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorModelBuilder toBuilder() => new ErrorModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorModel && message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc(0, message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ErrorModel')..add('message', message))
        .toString();
  }
}

class ErrorModelBuilder implements Builder<ErrorModel, ErrorModelBuilder> {
  _$ErrorModel _$v;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  ErrorModelBuilder();

  ErrorModelBuilder get _$this {
    if (_$v != null) {
      _message = _$v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ErrorModel;
  }

  @override
  void update(void Function(ErrorModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ErrorModel build() {
    final _$result = _$v ?? new _$ErrorModel._(message: message);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
