// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) {
  return _MatchModel.fromJson(json);
}

/// @nodoc
mixin _$MatchModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'played_at')
  DateTime get playedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'scoresheet_image_url')
  String? get scoresheetImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_official')
  bool get isOfficial => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'players_count')
  int get playersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MatchModelCopyWith<MatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchModelCopyWith<$Res> {
  factory $MatchModelCopyWith(
          MatchModel value, $Res Function(MatchModel) then) =
      _$MatchModelCopyWithImpl<$Res, MatchModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'played_at') DateTime playedAt,
      @JsonKey(name: 'scoresheet_image_url') String? scoresheetImageUrl,
      @JsonKey(name: 'is_official') bool isOfficial,
      String? notes,
      @JsonKey(name: 'players_count') int playersCount,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$MatchModelCopyWithImpl<$Res, $Val extends MatchModel>
    implements $MatchModelCopyWith<$Res> {
  _$MatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? playedAt = null,
    Object? scoresheetImageUrl = freezed,
    Object? isOfficial = null,
    Object? notes = freezed,
    Object? playersCount = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      playedAt: null == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scoresheetImageUrl: freezed == scoresheetImageUrl
          ? _value.scoresheetImageUrl
          : scoresheetImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      playersCount: null == playersCount
          ? _value.playersCount
          : playersCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchModelImplCopyWith<$Res>
    implements $MatchModelCopyWith<$Res> {
  factory _$$MatchModelImplCopyWith(
          _$MatchModelImpl value, $Res Function(_$MatchModelImpl) then) =
      __$$MatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'played_at') DateTime playedAt,
      @JsonKey(name: 'scoresheet_image_url') String? scoresheetImageUrl,
      @JsonKey(name: 'is_official') bool isOfficial,
      String? notes,
      @JsonKey(name: 'players_count') int playersCount,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$MatchModelImplCopyWithImpl<$Res>
    extends _$MatchModelCopyWithImpl<$Res, _$MatchModelImpl>
    implements _$$MatchModelImplCopyWith<$Res> {
  __$$MatchModelImplCopyWithImpl(
      _$MatchModelImpl _value, $Res Function(_$MatchModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? playedAt = null,
    Object? scoresheetImageUrl = freezed,
    Object? isOfficial = null,
    Object? notes = freezed,
    Object? playersCount = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MatchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      playedAt: null == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scoresheetImageUrl: freezed == scoresheetImageUrl
          ? _value.scoresheetImageUrl
          : scoresheetImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      playersCount: null == playersCount
          ? _value.playersCount
          : playersCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchModelImpl implements _MatchModel {
  const _$MatchModelImpl(
      {required this.id,
      @JsonKey(name: 'group_id') required this.groupId,
      @JsonKey(name: 'played_at') required this.playedAt,
      @JsonKey(name: 'scoresheet_image_url') this.scoresheetImageUrl,
      @JsonKey(name: 'is_official') this.isOfficial = false,
      this.notes,
      @JsonKey(name: 'players_count') this.playersCount = 0,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$MatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  @JsonKey(name: 'played_at')
  final DateTime playedAt;
  @override
  @JsonKey(name: 'scoresheet_image_url')
  final String? scoresheetImageUrl;
  @override
  @JsonKey(name: 'is_official')
  final bool isOfficial;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'players_count')
  final int playersCount;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'MatchModel(id: $id, groupId: $groupId, playedAt: $playedAt, scoresheetImageUrl: $scoresheetImageUrl, isOfficial: $isOfficial, notes: $notes, playersCount: $playersCount, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.scoresheetImageUrl, scoresheetImageUrl) ||
                other.scoresheetImageUrl == scoresheetImageUrl) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.playersCount, playersCount) ||
                other.playersCount == playersCount) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupId,
      playedAt,
      scoresheetImageUrl,
      isOfficial,
      notes,
      playersCount,
      createdBy,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      __$$MatchModelImplCopyWithImpl<_$MatchModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchModelImplToJson(
      this,
    );
  }
}

abstract class _MatchModel implements MatchModel {
  const factory _MatchModel(
      {required final String id,
      @JsonKey(name: 'group_id') required final String groupId,
      @JsonKey(name: 'played_at') required final DateTime playedAt,
      @JsonKey(name: 'scoresheet_image_url') final String? scoresheetImageUrl,
      @JsonKey(name: 'is_official') final bool isOfficial,
      final String? notes,
      @JsonKey(name: 'players_count') final int playersCount,
      @JsonKey(name: 'created_by') final String? createdBy,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      required final DateTime updatedAt}) = _$MatchModelImpl;

  factory _MatchModel.fromJson(Map<String, dynamic> json) =
      _$MatchModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  @JsonKey(name: 'played_at')
  DateTime get playedAt;
  @override
  @JsonKey(name: 'scoresheet_image_url')
  String? get scoresheetImageUrl;
  @override
  @JsonKey(name: 'is_official')
  bool get isOfficial;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'players_count')
  int get playersCount;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
