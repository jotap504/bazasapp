// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchResultModel _$MatchResultModelFromJson(Map<String, dynamic> json) {
  return _MatchResultModel.fromJson(json);
}

/// @nodoc
mixin _$MatchResultModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_id')
  String get matchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'guest_member_id')
  String? get guestMemberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'position_in_match')
  int get positionInMatch => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_points')
  int get rawPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'exact_predictions')
  int get exactPredictions => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_bazas')
  int? get requestedBazas => throw _privateConstructorUsedError;
  @JsonKey(name: 'osadia_bazas_won')
  int get osadiaBazasWon => throw _privateConstructorUsedError;
  @JsonKey(name: 'accuracy_percent')
  double get accuracyPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_match_rounds')
  int get totalMatchRounds => throw _privateConstructorUsedError;
  @JsonKey(name: 'earned_championship_points')
  double get earnedChampionshipPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'osadia_points')
  double get osadiaPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  ProfileModel? get profile => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MatchResultModelCopyWith<MatchResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchResultModelCopyWith<$Res> {
  factory $MatchResultModelCopyWith(
          MatchResultModel value, $Res Function(MatchResultModel) then) =
      _$MatchResultModelCopyWithImpl<$Res, MatchResultModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'match_id') String matchId,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'guest_member_id') String? guestMemberId,
      @JsonKey(name: 'position_in_match') int positionInMatch,
      @JsonKey(name: 'raw_points') int rawPoints,
      @JsonKey(name: 'exact_predictions') int exactPredictions,
      @JsonKey(name: 'requested_bazas') int? requestedBazas,
      @JsonKey(name: 'osadia_bazas_won') int osadiaBazasWon,
      @JsonKey(name: 'accuracy_percent') double accuracyPercent,
      @JsonKey(name: 'total_match_rounds') int totalMatchRounds,
      @JsonKey(name: 'earned_championship_points')
      double earnedChampionshipPoints,
      @JsonKey(name: 'osadia_points') double osadiaPoints,
      @JsonKey(name: 'created_at') DateTime createdAt,
      ProfileModel? profile});

  $ProfileModelCopyWith<$Res>? get profile;
}

/// @nodoc
class _$MatchResultModelCopyWithImpl<$Res, $Val extends MatchResultModel>
    implements $MatchResultModelCopyWith<$Res> {
  _$MatchResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? userId = freezed,
    Object? guestMemberId = freezed,
    Object? positionInMatch = null,
    Object? rawPoints = null,
    Object? exactPredictions = null,
    Object? requestedBazas = freezed,
    Object? osadiaBazasWon = null,
    Object? accuracyPercent = null,
    Object? totalMatchRounds = null,
    Object? earnedChampionshipPoints = null,
    Object? osadiaPoints = null,
    Object? createdAt = null,
    Object? profile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      guestMemberId: freezed == guestMemberId
          ? _value.guestMemberId
          : guestMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      positionInMatch: null == positionInMatch
          ? _value.positionInMatch
          : positionInMatch // ignore: cast_nullable_to_non_nullable
              as int,
      rawPoints: null == rawPoints
          ? _value.rawPoints
          : rawPoints // ignore: cast_nullable_to_non_nullable
              as int,
      exactPredictions: null == exactPredictions
          ? _value.exactPredictions
          : exactPredictions // ignore: cast_nullable_to_non_nullable
              as int,
      requestedBazas: freezed == requestedBazas
          ? _value.requestedBazas
          : requestedBazas // ignore: cast_nullable_to_non_nullable
              as int?,
      osadiaBazasWon: null == osadiaBazasWon
          ? _value.osadiaBazasWon
          : osadiaBazasWon // ignore: cast_nullable_to_non_nullable
              as int,
      accuracyPercent: null == accuracyPercent
          ? _value.accuracyPercent
          : accuracyPercent // ignore: cast_nullable_to_non_nullable
              as double,
      totalMatchRounds: null == totalMatchRounds
          ? _value.totalMatchRounds
          : totalMatchRounds // ignore: cast_nullable_to_non_nullable
              as int,
      earnedChampionshipPoints: null == earnedChampionshipPoints
          ? _value.earnedChampionshipPoints
          : earnedChampionshipPoints // ignore: cast_nullable_to_non_nullable
              as double,
      osadiaPoints: null == osadiaPoints
          ? _value.osadiaPoints
          : osadiaPoints // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MatchResultModelImplCopyWith<$Res>
    implements $MatchResultModelCopyWith<$Res> {
  factory _$$MatchResultModelImplCopyWith(_$MatchResultModelImpl value,
          $Res Function(_$MatchResultModelImpl) then) =
      __$$MatchResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'match_id') String matchId,
      @JsonKey(name: 'user_id') String? userId,
      @JsonKey(name: 'guest_member_id') String? guestMemberId,
      @JsonKey(name: 'position_in_match') int positionInMatch,
      @JsonKey(name: 'raw_points') int rawPoints,
      @JsonKey(name: 'exact_predictions') int exactPredictions,
      @JsonKey(name: 'requested_bazas') int? requestedBazas,
      @JsonKey(name: 'osadia_bazas_won') int osadiaBazasWon,
      @JsonKey(name: 'accuracy_percent') double accuracyPercent,
      @JsonKey(name: 'total_match_rounds') int totalMatchRounds,
      @JsonKey(name: 'earned_championship_points')
      double earnedChampionshipPoints,
      @JsonKey(name: 'osadia_points') double osadiaPoints,
      @JsonKey(name: 'created_at') DateTime createdAt,
      ProfileModel? profile});

  @override
  $ProfileModelCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$MatchResultModelImplCopyWithImpl<$Res>
    extends _$MatchResultModelCopyWithImpl<$Res, _$MatchResultModelImpl>
    implements _$$MatchResultModelImplCopyWith<$Res> {
  __$$MatchResultModelImplCopyWithImpl(_$MatchResultModelImpl _value,
      $Res Function(_$MatchResultModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? userId = freezed,
    Object? guestMemberId = freezed,
    Object? positionInMatch = null,
    Object? rawPoints = null,
    Object? exactPredictions = null,
    Object? requestedBazas = freezed,
    Object? osadiaBazasWon = null,
    Object? accuracyPercent = null,
    Object? totalMatchRounds = null,
    Object? earnedChampionshipPoints = null,
    Object? osadiaPoints = null,
    Object? createdAt = null,
    Object? profile = freezed,
  }) {
    return _then(_$MatchResultModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      guestMemberId: freezed == guestMemberId
          ? _value.guestMemberId
          : guestMemberId // ignore: cast_nullable_to_non_nullable
              as String?,
      positionInMatch: null == positionInMatch
          ? _value.positionInMatch
          : positionInMatch // ignore: cast_nullable_to_non_nullable
              as int,
      rawPoints: null == rawPoints
          ? _value.rawPoints
          : rawPoints // ignore: cast_nullable_to_non_nullable
              as int,
      exactPredictions: null == exactPredictions
          ? _value.exactPredictions
          : exactPredictions // ignore: cast_nullable_to_non_nullable
              as int,
      requestedBazas: freezed == requestedBazas
          ? _value.requestedBazas
          : requestedBazas // ignore: cast_nullable_to_non_nullable
              as int?,
      osadiaBazasWon: null == osadiaBazasWon
          ? _value.osadiaBazasWon
          : osadiaBazasWon // ignore: cast_nullable_to_non_nullable
              as int,
      accuracyPercent: null == accuracyPercent
          ? _value.accuracyPercent
          : accuracyPercent // ignore: cast_nullable_to_non_nullable
              as double,
      totalMatchRounds: null == totalMatchRounds
          ? _value.totalMatchRounds
          : totalMatchRounds // ignore: cast_nullable_to_non_nullable
              as int,
      earnedChampionshipPoints: null == earnedChampionshipPoints
          ? _value.earnedChampionshipPoints
          : earnedChampionshipPoints // ignore: cast_nullable_to_non_nullable
              as double,
      osadiaPoints: null == osadiaPoints
          ? _value.osadiaPoints
          : osadiaPoints // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
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
class _$MatchResultModelImpl implements _MatchResultModel {
  const _$MatchResultModelImpl(
      {required this.id,
      @JsonKey(name: 'match_id') required this.matchId,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'guest_member_id') this.guestMemberId,
      @JsonKey(name: 'position_in_match') required this.positionInMatch,
      @JsonKey(name: 'raw_points') this.rawPoints = 0,
      @JsonKey(name: 'exact_predictions') this.exactPredictions = 0,
      @JsonKey(name: 'requested_bazas') this.requestedBazas,
      @JsonKey(name: 'osadia_bazas_won') this.osadiaBazasWon = 0,
      @JsonKey(name: 'accuracy_percent') this.accuracyPercent = 0.0,
      @JsonKey(name: 'total_match_rounds') this.totalMatchRounds = 10,
      @JsonKey(name: 'earned_championship_points')
      this.earnedChampionshipPoints = 0.0,
      @JsonKey(name: 'osadia_points') this.osadiaPoints = 0.0,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.profile});

  factory _$MatchResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchResultModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'match_id')
  final String matchId;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'guest_member_id')
  final String? guestMemberId;
  @override
  @JsonKey(name: 'position_in_match')
  final int positionInMatch;
  @override
  @JsonKey(name: 'raw_points')
  final int rawPoints;
  @override
  @JsonKey(name: 'exact_predictions')
  final int exactPredictions;
  @override
  @JsonKey(name: 'requested_bazas')
  final int? requestedBazas;
  @override
  @JsonKey(name: 'osadia_bazas_won')
  final int osadiaBazasWon;
  @override
  @JsonKey(name: 'accuracy_percent')
  final double accuracyPercent;
  @override
  @JsonKey(name: 'total_match_rounds')
  final int totalMatchRounds;
  @override
  @JsonKey(name: 'earned_championship_points')
  final double earnedChampionshipPoints;
  @override
  @JsonKey(name: 'osadia_points')
  final double osadiaPoints;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final ProfileModel? profile;

  @override
  String toString() {
    return 'MatchResultModel(id: $id, matchId: $matchId, userId: $userId, guestMemberId: $guestMemberId, positionInMatch: $positionInMatch, rawPoints: $rawPoints, exactPredictions: $exactPredictions, requestedBazas: $requestedBazas, osadiaBazasWon: $osadiaBazasWon, accuracyPercent: $accuracyPercent, totalMatchRounds: $totalMatchRounds, earnedChampionshipPoints: $earnedChampionshipPoints, osadiaPoints: $osadiaPoints, createdAt: $createdAt, profile: $profile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.guestMemberId, guestMemberId) ||
                other.guestMemberId == guestMemberId) &&
            (identical(other.positionInMatch, positionInMatch) ||
                other.positionInMatch == positionInMatch) &&
            (identical(other.rawPoints, rawPoints) ||
                other.rawPoints == rawPoints) &&
            (identical(other.exactPredictions, exactPredictions) ||
                other.exactPredictions == exactPredictions) &&
            (identical(other.requestedBazas, requestedBazas) ||
                other.requestedBazas == requestedBazas) &&
            (identical(other.osadiaBazasWon, osadiaBazasWon) ||
                other.osadiaBazasWon == osadiaBazasWon) &&
            (identical(other.accuracyPercent, accuracyPercent) ||
                other.accuracyPercent == accuracyPercent) &&
            (identical(other.totalMatchRounds, totalMatchRounds) ||
                other.totalMatchRounds == totalMatchRounds) &&
            (identical(
                    other.earnedChampionshipPoints, earnedChampionshipPoints) ||
                other.earnedChampionshipPoints == earnedChampionshipPoints) &&
            (identical(other.osadiaPoints, osadiaPoints) ||
                other.osadiaPoints == osadiaPoints) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      matchId,
      userId,
      guestMemberId,
      positionInMatch,
      rawPoints,
      exactPredictions,
      requestedBazas,
      osadiaBazasWon,
      accuracyPercent,
      totalMatchRounds,
      earnedChampionshipPoints,
      osadiaPoints,
      createdAt,
      profile);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchResultModelImplCopyWith<_$MatchResultModelImpl> get copyWith =>
      __$$MatchResultModelImplCopyWithImpl<_$MatchResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchResultModelImplToJson(
      this,
    );
  }
}

abstract class _MatchResultModel implements MatchResultModel {
  const factory _MatchResultModel(
      {required final String id,
      @JsonKey(name: 'match_id') required final String matchId,
      @JsonKey(name: 'user_id') final String? userId,
      @JsonKey(name: 'guest_member_id') final String? guestMemberId,
      @JsonKey(name: 'position_in_match') required final int positionInMatch,
      @JsonKey(name: 'raw_points') final int rawPoints,
      @JsonKey(name: 'exact_predictions') final int exactPredictions,
      @JsonKey(name: 'requested_bazas') final int? requestedBazas,
      @JsonKey(name: 'osadia_bazas_won') final int osadiaBazasWon,
      @JsonKey(name: 'accuracy_percent') final double accuracyPercent,
      @JsonKey(name: 'total_match_rounds') final int totalMatchRounds,
      @JsonKey(name: 'earned_championship_points')
      final double earnedChampionshipPoints,
      @JsonKey(name: 'osadia_points') final double osadiaPoints,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final ProfileModel? profile}) = _$MatchResultModelImpl;

  factory _MatchResultModel.fromJson(Map<String, dynamic> json) =
      _$MatchResultModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'match_id')
  String get matchId;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'guest_member_id')
  String? get guestMemberId;
  @override
  @JsonKey(name: 'position_in_match')
  int get positionInMatch;
  @override
  @JsonKey(name: 'raw_points')
  int get rawPoints;
  @override
  @JsonKey(name: 'exact_predictions')
  int get exactPredictions;
  @override
  @JsonKey(name: 'requested_bazas')
  int? get requestedBazas;
  @override
  @JsonKey(name: 'osadia_bazas_won')
  int get osadiaBazasWon;
  @override
  @JsonKey(name: 'accuracy_percent')
  double get accuracyPercent;
  @override
  @JsonKey(name: 'total_match_rounds')
  int get totalMatchRounds;
  @override
  @JsonKey(name: 'earned_championship_points')
  double get earnedChampionshipPoints;
  @override
  @JsonKey(name: 'osadia_points')
  double get osadiaPoints;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  ProfileModel? get profile;
  @override
  @JsonKey(ignore: true)
  _$$MatchResultModelImplCopyWith<_$MatchResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
