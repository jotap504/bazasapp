// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupMemberModel _$GroupMemberModelFromJson(Map<String, dynamic> json) {
  return _GroupMemberModel.fromJson(json);
}

/// @nodoc
mixin _$GroupMemberModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'guest_full_name')
  String? get guestFullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'guest_nickname')
  String? get guestNickname => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_championship_points')
  double get totalChampionshipPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_matches_played')
  int get totalMatchesPlayed => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_osadia_points')
  double get totalOsadiaPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'sum_accuracy_percent')
  double get sumAccuracyPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'count_accuracy_matches')
  int get countAccuracyMatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'effective_avg_percent')
  double get effectiveAvgPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_wins')
  int get totalWins => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_failed_osadia')
  int get totalFailedOsadia => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_chamullero_score')
  int get totalChamulleroScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_position')
  int? get currentPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_position')
  int? get previousPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // JOIN con profiles
  ProfileModel? get profile => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupMemberModelCopyWith<GroupMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberModelCopyWith<$Res> {
  factory $GroupMemberModelCopyWith(
          GroupMemberModel value, $Res Function(GroupMemberModel) then) =
      _$GroupMemberModelCopyWithImpl<$Res, GroupMemberModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'guest_full_name') String? guestFullName,
      @JsonKey(name: 'guest_nickname') String? guestNickname,
      String role,
      @JsonKey(name: 'total_championship_points')
      double totalChampionshipPoints,
      @JsonKey(name: 'total_matches_played') int totalMatchesPlayed,
      @JsonKey(name: 'total_osadia_points') double totalOsadiaPoints,
      @JsonKey(name: 'sum_accuracy_percent') double sumAccuracyPercent,
      @JsonKey(name: 'count_accuracy_matches') int countAccuracyMatches,
      @JsonKey(name: 'effective_avg_percent') double effectiveAvgPercent,
      @JsonKey(name: 'total_wins') int totalWins,
      @JsonKey(name: 'total_failed_osadia') int totalFailedOsadia,
      @JsonKey(name: 'total_chamullero_score') int totalChamulleroScore,
      @JsonKey(name: 'current_position') int? currentPosition,
      @JsonKey(name: 'previous_position') int? previousPosition,
      @JsonKey(name: 'joined_at') DateTime joinedAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      ProfileModel? profile});

  $ProfileModelCopyWith<$Res>? get profile;
}

/// @nodoc
class _$GroupMemberModelCopyWithImpl<$Res, $Val extends GroupMemberModel>
    implements $GroupMemberModelCopyWith<$Res> {
  _$GroupMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = freezed,
    Object? guestFullName = freezed,
    Object? guestNickname = freezed,
    Object? role = null,
    Object? totalChampionshipPoints = null,
    Object? totalMatchesPlayed = null,
    Object? totalOsadiaPoints = null,
    Object? sumAccuracyPercent = null,
    Object? countAccuracyMatches = null,
    Object? effectiveAvgPercent = null,
    Object? totalWins = null,
    Object? totalFailedOsadia = null,
    Object? totalChamulleroScore = null,
    Object? currentPosition = freezed,
    Object? previousPosition = freezed,
    Object? joinedAt = null,
    Object? updatedAt = null,
    Object? profile = freezed,
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
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      guestFullName: freezed == guestFullName
          ? _value.guestFullName
          : guestFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      guestNickname: freezed == guestNickname
          ? _value.guestNickname
          : guestNickname // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      totalChampionshipPoints: null == totalChampionshipPoints
          ? _value.totalChampionshipPoints
          : totalChampionshipPoints // ignore: cast_nullable_to_non_nullable
              as double,
      totalMatchesPlayed: null == totalMatchesPlayed
          ? _value.totalMatchesPlayed
          : totalMatchesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      totalOsadiaPoints: null == totalOsadiaPoints
          ? _value.totalOsadiaPoints
          : totalOsadiaPoints // ignore: cast_nullable_to_non_nullable
              as double,
      sumAccuracyPercent: null == sumAccuracyPercent
          ? _value.sumAccuracyPercent
          : sumAccuracyPercent // ignore: cast_nullable_to_non_nullable
              as double,
      countAccuracyMatches: null == countAccuracyMatches
          ? _value.countAccuracyMatches
          : countAccuracyMatches // ignore: cast_nullable_to_non_nullable
              as int,
      effectiveAvgPercent: null == effectiveAvgPercent
          ? _value.effectiveAvgPercent
          : effectiveAvgPercent // ignore: cast_nullable_to_non_nullable
              as double,
      totalWins: null == totalWins
          ? _value.totalWins
          : totalWins // ignore: cast_nullable_to_non_nullable
              as int,
      totalFailedOsadia: null == totalFailedOsadia
          ? _value.totalFailedOsadia
          : totalFailedOsadia // ignore: cast_nullable_to_non_nullable
              as int,
      totalChamulleroScore: null == totalChamulleroScore
          ? _value.totalChamulleroScore
          : totalChamulleroScore // ignore: cast_nullable_to_non_nullable
              as int,
      currentPosition: freezed == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      previousPosition: freezed == previousPosition
          ? _value.previousPosition
          : previousPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProfileModelCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $ProfileModelCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GroupMemberModelImplCopyWith<$Res>
    implements $GroupMemberModelCopyWith<$Res> {
  factory _$$GroupMemberModelImplCopyWith(_$GroupMemberModelImpl value,
          $Res Function(_$GroupMemberModelImpl) then) =
      __$$GroupMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'guest_full_name') String? guestFullName,
      @JsonKey(name: 'guest_nickname') String? guestNickname,
      String role,
      @JsonKey(name: 'total_championship_points')
      double totalChampionshipPoints,
      @JsonKey(name: 'total_matches_played') int totalMatchesPlayed,
      @JsonKey(name: 'total_osadia_points') double totalOsadiaPoints,
      @JsonKey(name: 'sum_accuracy_percent') double sumAccuracyPercent,
      @JsonKey(name: 'count_accuracy_matches') int countAccuracyMatches,
      @JsonKey(name: 'effective_avg_percent') double effectiveAvgPercent,
      @JsonKey(name: 'total_wins') int totalWins,
      @JsonKey(name: 'total_failed_osadia') int totalFailedOsadia,
      @JsonKey(name: 'total_chamullero_score') int totalChamulleroScore,
      @JsonKey(name: 'current_position') int? currentPosition,
      @JsonKey(name: 'previous_position') int? previousPosition,
      @JsonKey(name: 'joined_at') DateTime joinedAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      ProfileModel? profile});

  @override
  $ProfileModelCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$GroupMemberModelImplCopyWithImpl<$Res>
    extends _$GroupMemberModelCopyWithImpl<$Res, _$GroupMemberModelImpl>
    implements _$$GroupMemberModelImplCopyWith<$Res> {
  __$$GroupMemberModelImplCopyWithImpl(_$GroupMemberModelImpl _value,
      $Res Function(_$GroupMemberModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? userId = freezed,
    Object? guestFullName = freezed,
    Object? guestNickname = freezed,
    Object? role = null,
    Object? totalChampionshipPoints = null,
    Object? totalMatchesPlayed = null,
    Object? totalOsadiaPoints = null,
    Object? sumAccuracyPercent = null,
    Object? countAccuracyMatches = null,
    Object? effectiveAvgPercent = null,
    Object? totalWins = null,
    Object? totalFailedOsadia = null,
    Object? totalChamulleroScore = null,
    Object? currentPosition = freezed,
    Object? previousPosition = freezed,
    Object? joinedAt = null,
    Object? updatedAt = null,
    Object? profile = freezed,
  }) {
    return _then(_$GroupMemberModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      guestFullName: freezed == guestFullName
          ? _value.guestFullName
          : guestFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      guestNickname: freezed == guestNickname
          ? _value.guestNickname
          : guestNickname // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      totalChampionshipPoints: null == totalChampionshipPoints
          ? _value.totalChampionshipPoints
          : totalChampionshipPoints // ignore: cast_nullable_to_non_nullable
              as double,
      totalMatchesPlayed: null == totalMatchesPlayed
          ? _value.totalMatchesPlayed
          : totalMatchesPlayed // ignore: cast_nullable_to_non_nullable
              as int,
      totalOsadiaPoints: null == totalOsadiaPoints
          ? _value.totalOsadiaPoints
          : totalOsadiaPoints // ignore: cast_nullable_to_non_nullable
              as double,
      sumAccuracyPercent: null == sumAccuracyPercent
          ? _value.sumAccuracyPercent
          : sumAccuracyPercent // ignore: cast_nullable_to_non_nullable
              as double,
      countAccuracyMatches: null == countAccuracyMatches
          ? _value.countAccuracyMatches
          : countAccuracyMatches // ignore: cast_nullable_to_non_nullable
              as int,
      effectiveAvgPercent: null == effectiveAvgPercent
          ? _value.effectiveAvgPercent
          : effectiveAvgPercent // ignore: cast_nullable_to_non_nullable
              as double,
      totalWins: null == totalWins
          ? _value.totalWins
          : totalWins // ignore: cast_nullable_to_non_nullable
              as int,
      totalFailedOsadia: null == totalFailedOsadia
          ? _value.totalFailedOsadia
          : totalFailedOsadia // ignore: cast_nullable_to_non_nullable
              as int,
      totalChamulleroScore: null == totalChamulleroScore
          ? _value.totalChamulleroScore
          : totalChamulleroScore // ignore: cast_nullable_to_non_nullable
              as int,
      currentPosition: freezed == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      previousPosition: freezed == previousPosition
          ? _value.previousPosition
          : previousPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMemberModelImpl implements _GroupMemberModel {
  const _$GroupMemberModelImpl(
      {required this.id,
      @JsonKey(name: 'group_id') required this.groupId,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'guest_full_name') this.guestFullName,
      @JsonKey(name: 'guest_nickname') this.guestNickname,
      this.role = 'member',
      @JsonKey(name: 'total_championship_points')
      this.totalChampionshipPoints = 0.0,
      @JsonKey(name: 'total_matches_played') this.totalMatchesPlayed = 0,
      @JsonKey(name: 'total_osadia_points') this.totalOsadiaPoints = 0.0,
      @JsonKey(name: 'sum_accuracy_percent') this.sumAccuracyPercent = 0.0,
      @JsonKey(name: 'count_accuracy_matches') this.countAccuracyMatches = 0,
      @JsonKey(name: 'effective_avg_percent') this.effectiveAvgPercent = 0.0,
      @JsonKey(name: 'total_wins') this.totalWins = 0,
      @JsonKey(name: 'total_failed_osadia') this.totalFailedOsadia = 0,
      @JsonKey(name: 'total_chamullero_score') this.totalChamulleroScore = 0,
      @JsonKey(name: 'current_position') this.currentPosition,
      @JsonKey(name: 'previous_position') this.previousPosition,
      @JsonKey(name: 'joined_at') required this.joinedAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      this.profile});

  factory _$GroupMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMemberModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'guest_full_name')
  final String? guestFullName;
  @override
  @JsonKey(name: 'guest_nickname')
  final String? guestNickname;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'total_championship_points')
  final double totalChampionshipPoints;
  @override
  @JsonKey(name: 'total_matches_played')
  final int totalMatchesPlayed;
  @override
  @JsonKey(name: 'total_osadia_points')
  final double totalOsadiaPoints;
  @override
  @JsonKey(name: 'sum_accuracy_percent')
  final double sumAccuracyPercent;
  @override
  @JsonKey(name: 'count_accuracy_matches')
  final int countAccuracyMatches;
  @override
  @JsonKey(name: 'effective_avg_percent')
  final double effectiveAvgPercent;
  @override
  @JsonKey(name: 'total_wins')
  final int totalWins;
  @override
  @JsonKey(name: 'total_failed_osadia')
  final int totalFailedOsadia;
  @override
  @JsonKey(name: 'total_chamullero_score')
  final int totalChamulleroScore;
  @override
  @JsonKey(name: 'current_position')
  final int? currentPosition;
  @override
  @JsonKey(name: 'previous_position')
  final int? previousPosition;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// JOIN con profiles
  @override
  final ProfileModel? profile;

  @override
  String toString() {
    return 'GroupMemberModel(id: $id, groupId: $groupId, userId: $userId, guestFullName: $guestFullName, guestNickname: $guestNickname, role: $role, totalChampionshipPoints: $totalChampionshipPoints, totalMatchesPlayed: $totalMatchesPlayed, totalOsadiaPoints: $totalOsadiaPoints, sumAccuracyPercent: $sumAccuracyPercent, countAccuracyMatches: $countAccuracyMatches, effectiveAvgPercent: $effectiveAvgPercent, totalWins: $totalWins, totalFailedOsadia: $totalFailedOsadia, totalChamulleroScore: $totalChamulleroScore, currentPosition: $currentPosition, previousPosition: $previousPosition, joinedAt: $joinedAt, updatedAt: $updatedAt, profile: $profile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.guestFullName, guestFullName) ||
                other.guestFullName == guestFullName) &&
            (identical(other.guestNickname, guestNickname) ||
                other.guestNickname == guestNickname) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(
                    other.totalChampionshipPoints, totalChampionshipPoints) ||
                other.totalChampionshipPoints == totalChampionshipPoints) &&
            (identical(other.totalMatchesPlayed, totalMatchesPlayed) ||
                other.totalMatchesPlayed == totalMatchesPlayed) &&
            (identical(other.totalOsadiaPoints, totalOsadiaPoints) ||
                other.totalOsadiaPoints == totalOsadiaPoints) &&
            (identical(other.sumAccuracyPercent, sumAccuracyPercent) ||
                other.sumAccuracyPercent == sumAccuracyPercent) &&
            (identical(other.countAccuracyMatches, countAccuracyMatches) ||
                other.countAccuracyMatches == countAccuracyMatches) &&
            (identical(other.effectiveAvgPercent, effectiveAvgPercent) ||
                other.effectiveAvgPercent == effectiveAvgPercent) &&
            (identical(other.totalWins, totalWins) ||
                other.totalWins == totalWins) &&
            (identical(other.totalFailedOsadia, totalFailedOsadia) ||
                other.totalFailedOsadia == totalFailedOsadia) &&
            (identical(other.totalChamulleroScore, totalChamulleroScore) ||
                other.totalChamulleroScore == totalChamulleroScore) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.previousPosition, previousPosition) ||
                other.previousPosition == previousPosition) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        groupId,
        userId,
        guestFullName,
        guestNickname,
        role,
        totalChampionshipPoints,
        totalMatchesPlayed,
        totalOsadiaPoints,
        sumAccuracyPercent,
        countAccuracyMatches,
        effectiveAvgPercent,
        totalWins,
        totalFailedOsadia,
        totalChamulleroScore,
        currentPosition,
        previousPosition,
        joinedAt,
        updatedAt,
        profile
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberModelImplCopyWith<_$GroupMemberModelImpl> get copyWith =>
      __$$GroupMemberModelImplCopyWithImpl<_$GroupMemberModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMemberModelImplToJson(
      this,
    );
  }
}

abstract class _GroupMemberModel implements GroupMemberModel {
  const factory _GroupMemberModel(
      {required final String id,
      @JsonKey(name: 'group_id') required final String groupId,
      @JsonKey(name: 'user_id') final String? userId,
      @JsonKey(name: 'guest_full_name') final String? guestFullName,
      @JsonKey(name: 'guest_nickname') final String? guestNickname,
      final String role,
      @JsonKey(name: 'total_championship_points')
      final double totalChampionshipPoints,
      @JsonKey(name: 'total_matches_played') final int totalMatchesPlayed,
      @JsonKey(name: 'total_osadia_points') final double totalOsadiaPoints,
      @JsonKey(name: 'sum_accuracy_percent') final double sumAccuracyPercent,
      @JsonKey(name: 'count_accuracy_matches') final int countAccuracyMatches,
      @JsonKey(name: 'effective_avg_percent') final double effectiveAvgPercent,
      @JsonKey(name: 'total_wins') final int totalWins,
      @JsonKey(name: 'total_failed_osadia') final int totalFailedOsadia,
      @JsonKey(name: 'total_chamullero_score') final int totalChamulleroScore,
      @JsonKey(name: 'current_position') final int? currentPosition,
      @JsonKey(name: 'previous_position') final int? previousPosition,
      @JsonKey(name: 'joined_at') required final DateTime joinedAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      final ProfileModel? profile}) = _$GroupMemberModelImpl;

  factory _GroupMemberModel.fromJson(Map<String, dynamic> json) =
      _$GroupMemberModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'guest_full_name')
  String? get guestFullName;
  @override
  @JsonKey(name: 'guest_nickname')
  String? get guestNickname;
  @override
  String get role;
  @override
  @JsonKey(name: 'total_championship_points')
  double get totalChampionshipPoints;
  @override
  @JsonKey(name: 'total_matches_played')
  int get totalMatchesPlayed;
  @override
  @JsonKey(name: 'total_osadia_points')
  double get totalOsadiaPoints;
  @override
  @JsonKey(name: 'sum_accuracy_percent')
  double get sumAccuracyPercent;
  @override
  @JsonKey(name: 'count_accuracy_matches')
  int get countAccuracyMatches;
  @override
  @JsonKey(name: 'effective_avg_percent')
  double get effectiveAvgPercent;
  @override
  @JsonKey(name: 'total_wins')
  int get totalWins;
  @override
  @JsonKey(name: 'total_failed_osadia')
  int get totalFailedOsadia;
  @override
  @JsonKey(name: 'total_chamullero_score')
  int get totalChamulleroScore;
  @override
  @JsonKey(name: 'current_position')
  int? get currentPosition;
  @override
  @JsonKey(name: 'previous_position')
  int? get previousPosition;
  @override
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override // JOIN con profiles
  ProfileModel? get profile;
  @override
  @JsonKey(ignore: true)
  _$$GroupMemberModelImplCopyWith<_$GroupMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
