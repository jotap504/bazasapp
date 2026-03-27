// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) {
  return _GroupModel.fromJson(json);
}

/// @nodoc
mixin _$GroupModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_quorum')
  int get minQuorum => throw _privateConstructorUsedError;
  @JsonKey(name: 'f1_points_system')
  List<int> get f1PointsSystem => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_attendance_pct')
  int get minAttendancePct => throw _privateConstructorUsedError;
  @JsonKey(name: 'osadia_multiplier')
  double get osadiaMultiplier => throw _privateConstructorUsedError;
  @JsonKey(name: 'efectividad_multiplier')
  double get efectividadMultiplier => throw _privateConstructorUsedError;
  @JsonKey(name: 'pts_per_promise')
  int get ptsPerPromise => throw _privateConstructorUsedError;
  @JsonKey(name: 'pts_per_trick')
  int get ptsPerTrick => throw _privateConstructorUsedError;
  @JsonKey(name: 'osadia_config')
  List<Map<String, dynamic>>? get osadiaConfig =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'invite_code')
  String? get inviteCode => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Relaciones opcionales (JOIN)
  @JsonKey(name: 'member_count')
  int? get memberCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_count')
  int? get matchCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupModelCopyWith<GroupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupModelCopyWith<$Res> {
  factory $GroupModelCopyWith(
          GroupModel value, $Res Function(GroupModel) then) =
      _$GroupModelCopyWithImpl<$Res, GroupModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'min_quorum') int minQuorum,
      @JsonKey(name: 'f1_points_system') List<int> f1PointsSystem,
      @JsonKey(name: 'min_attendance_pct') int minAttendancePct,
      @JsonKey(name: 'osadia_multiplier') double osadiaMultiplier,
      @JsonKey(name: 'efectividad_multiplier') double efectividadMultiplier,
      @JsonKey(name: 'pts_per_promise') int ptsPerPromise,
      @JsonKey(name: 'pts_per_trick') int ptsPerTrick,
      @JsonKey(name: 'osadia_config') List<Map<String, dynamic>>? osadiaConfig,
      @JsonKey(name: 'invite_code') String? inviteCode,
      String status,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'member_count') int? memberCount,
      @JsonKey(name: 'match_count') int? matchCount});
}

/// @nodoc
class _$GroupModelCopyWithImpl<$Res, $Val extends GroupModel>
    implements $GroupModelCopyWith<$Res> {
  _$GroupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdBy = null,
    Object? minQuorum = null,
    Object? f1PointsSystem = null,
    Object? minAttendancePct = null,
    Object? osadiaMultiplier = null,
    Object? efectividadMultiplier = null,
    Object? ptsPerPromise = null,
    Object? ptsPerTrick = null,
    Object? osadiaConfig = freezed,
    Object? inviteCode = freezed,
    Object? status = null,
    Object? closedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? memberCount = freezed,
    Object? matchCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      minQuorum: null == minQuorum
          ? _value.minQuorum
          : minQuorum // ignore: cast_nullable_to_non_nullable
              as int,
      f1PointsSystem: null == f1PointsSystem
          ? _value.f1PointsSystem
          : f1PointsSystem // ignore: cast_nullable_to_non_nullable
              as List<int>,
      minAttendancePct: null == minAttendancePct
          ? _value.minAttendancePct
          : minAttendancePct // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaMultiplier: null == osadiaMultiplier
          ? _value.osadiaMultiplier
          : osadiaMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      efectividadMultiplier: null == efectividadMultiplier
          ? _value.efectividadMultiplier
          : efectividadMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      ptsPerPromise: null == ptsPerPromise
          ? _value.ptsPerPromise
          : ptsPerPromise // ignore: cast_nullable_to_non_nullable
              as int,
      ptsPerTrick: null == ptsPerTrick
          ? _value.ptsPerTrick
          : ptsPerTrick // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaConfig: freezed == osadiaConfig
          ? _value.osadiaConfig
          : osadiaConfig // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      memberCount: freezed == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int?,
      matchCount: freezed == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupModelImplCopyWith<$Res>
    implements $GroupModelCopyWith<$Res> {
  factory _$$GroupModelImplCopyWith(
          _$GroupModelImpl value, $Res Function(_$GroupModelImpl) then) =
      __$$GroupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'min_quorum') int minQuorum,
      @JsonKey(name: 'f1_points_system') List<int> f1PointsSystem,
      @JsonKey(name: 'min_attendance_pct') int minAttendancePct,
      @JsonKey(name: 'osadia_multiplier') double osadiaMultiplier,
      @JsonKey(name: 'efectividad_multiplier') double efectividadMultiplier,
      @JsonKey(name: 'pts_per_promise') int ptsPerPromise,
      @JsonKey(name: 'pts_per_trick') int ptsPerTrick,
      @JsonKey(name: 'osadia_config') List<Map<String, dynamic>>? osadiaConfig,
      @JsonKey(name: 'invite_code') String? inviteCode,
      String status,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'member_count') int? memberCount,
      @JsonKey(name: 'match_count') int? matchCount});
}

/// @nodoc
class __$$GroupModelImplCopyWithImpl<$Res>
    extends _$GroupModelCopyWithImpl<$Res, _$GroupModelImpl>
    implements _$$GroupModelImplCopyWith<$Res> {
  __$$GroupModelImplCopyWithImpl(
      _$GroupModelImpl _value, $Res Function(_$GroupModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdBy = null,
    Object? minQuorum = null,
    Object? f1PointsSystem = null,
    Object? minAttendancePct = null,
    Object? osadiaMultiplier = null,
    Object? efectividadMultiplier = null,
    Object? ptsPerPromise = null,
    Object? ptsPerTrick = null,
    Object? osadiaConfig = freezed,
    Object? inviteCode = freezed,
    Object? status = null,
    Object? closedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? memberCount = freezed,
    Object? matchCount = freezed,
  }) {
    return _then(_$GroupModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      minQuorum: null == minQuorum
          ? _value.minQuorum
          : minQuorum // ignore: cast_nullable_to_non_nullable
              as int,
      f1PointsSystem: null == f1PointsSystem
          ? _value._f1PointsSystem
          : f1PointsSystem // ignore: cast_nullable_to_non_nullable
              as List<int>,
      minAttendancePct: null == minAttendancePct
          ? _value.minAttendancePct
          : minAttendancePct // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaMultiplier: null == osadiaMultiplier
          ? _value.osadiaMultiplier
          : osadiaMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      efectividadMultiplier: null == efectividadMultiplier
          ? _value.efectividadMultiplier
          : efectividadMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      ptsPerPromise: null == ptsPerPromise
          ? _value.ptsPerPromise
          : ptsPerPromise // ignore: cast_nullable_to_non_nullable
              as int,
      ptsPerTrick: null == ptsPerTrick
          ? _value.ptsPerTrick
          : ptsPerTrick // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaConfig: freezed == osadiaConfig
          ? _value._osadiaConfig
          : osadiaConfig // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      memberCount: freezed == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int?,
      matchCount: freezed == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupModelImpl implements _GroupModel {
  const _$GroupModelImpl(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'created_by') required this.createdBy,
      @JsonKey(name: 'min_quorum') this.minQuorum = 5,
      @JsonKey(name: 'f1_points_system')
      required final List<int> f1PointsSystem,
      @JsonKey(name: 'min_attendance_pct') this.minAttendancePct = 50,
      @JsonKey(name: 'osadia_multiplier') this.osadiaMultiplier = 1.0,
      @JsonKey(name: 'efectividad_multiplier') this.efectividadMultiplier = 1.0,
      @JsonKey(name: 'pts_per_promise') this.ptsPerPromise = 10,
      @JsonKey(name: 'pts_per_trick') this.ptsPerTrick = 1,
      @JsonKey(name: 'osadia_config')
      final List<Map<String, dynamic>>? osadiaConfig,
      @JsonKey(name: 'invite_code') this.inviteCode,
      this.status = 'open',
      @JsonKey(name: 'closed_at') this.closedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'member_count') this.memberCount,
      @JsonKey(name: 'match_count') this.matchCount})
      : _f1PointsSystem = f1PointsSystem,
        _osadiaConfig = osadiaConfig;

  factory _$GroupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'min_quorum')
  final int minQuorum;
  final List<int> _f1PointsSystem;
  @override
  @JsonKey(name: 'f1_points_system')
  List<int> get f1PointsSystem {
    if (_f1PointsSystem is EqualUnmodifiableListView) return _f1PointsSystem;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_f1PointsSystem);
  }

  @override
  @JsonKey(name: 'min_attendance_pct')
  final int minAttendancePct;
  @override
  @JsonKey(name: 'osadia_multiplier')
  final double osadiaMultiplier;
  @override
  @JsonKey(name: 'efectividad_multiplier')
  final double efectividadMultiplier;
  @override
  @JsonKey(name: 'pts_per_promise')
  final int ptsPerPromise;
  @override
  @JsonKey(name: 'pts_per_trick')
  final int ptsPerTrick;
  final List<Map<String, dynamic>>? _osadiaConfig;
  @override
  @JsonKey(name: 'osadia_config')
  List<Map<String, dynamic>>? get osadiaConfig {
    final value = _osadiaConfig;
    if (value == null) return null;
    if (_osadiaConfig is EqualUnmodifiableListView) return _osadiaConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'closed_at')
  final DateTime? closedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// Relaciones opcionales (JOIN)
  @override
  @JsonKey(name: 'member_count')
  final int? memberCount;
  @override
  @JsonKey(name: 'match_count')
  final int? matchCount;

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, description: $description, createdBy: $createdBy, minQuorum: $minQuorum, f1PointsSystem: $f1PointsSystem, minAttendancePct: $minAttendancePct, osadiaMultiplier: $osadiaMultiplier, efectividadMultiplier: $efectividadMultiplier, ptsPerPromise: $ptsPerPromise, ptsPerTrick: $ptsPerTrick, osadiaConfig: $osadiaConfig, inviteCode: $inviteCode, status: $status, closedAt: $closedAt, createdAt: $createdAt, updatedAt: $updatedAt, memberCount: $memberCount, matchCount: $matchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.minQuorum, minQuorum) ||
                other.minQuorum == minQuorum) &&
            const DeepCollectionEquality()
                .equals(other._f1PointsSystem, _f1PointsSystem) &&
            (identical(other.minAttendancePct, minAttendancePct) ||
                other.minAttendancePct == minAttendancePct) &&
            (identical(other.osadiaMultiplier, osadiaMultiplier) ||
                other.osadiaMultiplier == osadiaMultiplier) &&
            (identical(other.efectividadMultiplier, efectividadMultiplier) ||
                other.efectividadMultiplier == efectividadMultiplier) &&
            (identical(other.ptsPerPromise, ptsPerPromise) ||
                other.ptsPerPromise == ptsPerPromise) &&
            (identical(other.ptsPerTrick, ptsPerTrick) ||
                other.ptsPerTrick == ptsPerTrick) &&
            const DeepCollectionEquality()
                .equals(other._osadiaConfig, _osadiaConfig) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.matchCount, matchCount) ||
                other.matchCount == matchCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        createdBy,
        minQuorum,
        const DeepCollectionEquality().hash(_f1PointsSystem),
        minAttendancePct,
        osadiaMultiplier,
        efectividadMultiplier,
        ptsPerPromise,
        ptsPerTrick,
        const DeepCollectionEquality().hash(_osadiaConfig),
        inviteCode,
        status,
        closedAt,
        createdAt,
        updatedAt,
        memberCount,
        matchCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupModelImplCopyWith<_$GroupModelImpl> get copyWith =>
      __$$GroupModelImplCopyWithImpl<_$GroupModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupModelImplToJson(
      this,
    );
  }
}

abstract class _GroupModel implements GroupModel {
  const factory _GroupModel(
      {required final String id,
      required final String name,
      final String? description,
      @JsonKey(name: 'created_by') required final String createdBy,
      @JsonKey(name: 'min_quorum') final int minQuorum,
      @JsonKey(name: 'f1_points_system')
      required final List<int> f1PointsSystem,
      @JsonKey(name: 'min_attendance_pct') final int minAttendancePct,
      @JsonKey(name: 'osadia_multiplier') final double osadiaMultiplier,
      @JsonKey(name: 'efectividad_multiplier')
      final double efectividadMultiplier,
      @JsonKey(name: 'pts_per_promise') final int ptsPerPromise,
      @JsonKey(name: 'pts_per_trick') final int ptsPerTrick,
      @JsonKey(name: 'osadia_config')
      final List<Map<String, dynamic>>? osadiaConfig,
      @JsonKey(name: 'invite_code') final String? inviteCode,
      final String status,
      @JsonKey(name: 'closed_at') final DateTime? closedAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'member_count') final int? memberCount,
      @JsonKey(name: 'match_count') final int? matchCount}) = _$GroupModelImpl;

  factory _GroupModel.fromJson(Map<String, dynamic> json) =
      _$GroupModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'min_quorum')
  int get minQuorum;
  @override
  @JsonKey(name: 'f1_points_system')
  List<int> get f1PointsSystem;
  @override
  @JsonKey(name: 'min_attendance_pct')
  int get minAttendancePct;
  @override
  @JsonKey(name: 'osadia_multiplier')
  double get osadiaMultiplier;
  @override
  @JsonKey(name: 'efectividad_multiplier')
  double get efectividadMultiplier;
  @override
  @JsonKey(name: 'pts_per_promise')
  int get ptsPerPromise;
  @override
  @JsonKey(name: 'pts_per_trick')
  int get ptsPerTrick;
  @override
  @JsonKey(name: 'osadia_config')
  List<Map<String, dynamic>>? get osadiaConfig;
  @override
  @JsonKey(name: 'invite_code')
  String? get inviteCode;
  @override
  String get status;
  @override
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override // Relaciones opcionales (JOIN)
  @JsonKey(name: 'member_count')
  int? get memberCount;
  @override
  @JsonKey(name: 'match_count')
  int? get matchCount;
  @override
  @JsonKey(ignore: true)
  _$$GroupModelImplCopyWith<_$GroupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
