// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayerScanResult _$PlayerScanResultFromJson(Map<String, dynamic> json) {
  return _PlayerScanResult.fromJson(json);
}

/// @nodoc
mixin _$PlayerScanResult {
  @JsonKey(name: 'player_name')
  String get playerName => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_points')
  int get rawPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'exact_predictions')
  int get exactPredictions => throw _privateConstructorUsedError;
  @JsonKey(name: 'osadia_bazas_won')
  int get osadiaBazasWon => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_bazas')
  int? get requestedBazas => throw _privateConstructorUsedError;
  @JsonKey(name: 'position_in_match')
  int get positionInMatch => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_confidence')
  bool get lowConfidence => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayerScanResultCopyWith<PlayerScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerScanResultCopyWith<$Res> {
  factory $PlayerScanResultCopyWith(
          PlayerScanResult value, $Res Function(PlayerScanResult) then) =
      _$PlayerScanResultCopyWithImpl<$Res, PlayerScanResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'player_name') String playerName,
      String? userId,
      @JsonKey(name: 'raw_points') int rawPoints,
      @JsonKey(name: 'exact_predictions') int exactPredictions,
      @JsonKey(name: 'osadia_bazas_won') int osadiaBazasWon,
      @JsonKey(name: 'requested_bazas') int? requestedBazas,
      @JsonKey(name: 'position_in_match') int positionInMatch,
      @JsonKey(name: 'low_confidence') bool lowConfidence,
      String? explanation});
}

/// @nodoc
class _$PlayerScanResultCopyWithImpl<$Res, $Val extends PlayerScanResult>
    implements $PlayerScanResultCopyWith<$Res> {
  _$PlayerScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerName = null,
    Object? userId = freezed,
    Object? rawPoints = null,
    Object? exactPredictions = null,
    Object? osadiaBazasWon = null,
    Object? requestedBazas = freezed,
    Object? positionInMatch = null,
    Object? lowConfidence = null,
    Object? explanation = freezed,
  }) {
    return _then(_value.copyWith(
      playerName: null == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      rawPoints: null == rawPoints
          ? _value.rawPoints
          : rawPoints // ignore: cast_nullable_to_non_nullable
              as int,
      exactPredictions: null == exactPredictions
          ? _value.exactPredictions
          : exactPredictions // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaBazasWon: null == osadiaBazasWon
          ? _value.osadiaBazasWon
          : osadiaBazasWon // ignore: cast_nullable_to_non_nullable
              as int,
      requestedBazas: freezed == requestedBazas
          ? _value.requestedBazas
          : requestedBazas // ignore: cast_nullable_to_non_nullable
              as int?,
      positionInMatch: null == positionInMatch
          ? _value.positionInMatch
          : positionInMatch // ignore: cast_nullable_to_non_nullable
              as int,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerScanResultImplCopyWith<$Res>
    implements $PlayerScanResultCopyWith<$Res> {
  factory _$$PlayerScanResultImplCopyWith(_$PlayerScanResultImpl value,
          $Res Function(_$PlayerScanResultImpl) then) =
      __$$PlayerScanResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'player_name') String playerName,
      String? userId,
      @JsonKey(name: 'raw_points') int rawPoints,
      @JsonKey(name: 'exact_predictions') int exactPredictions,
      @JsonKey(name: 'osadia_bazas_won') int osadiaBazasWon,
      @JsonKey(name: 'requested_bazas') int? requestedBazas,
      @JsonKey(name: 'position_in_match') int positionInMatch,
      @JsonKey(name: 'low_confidence') bool lowConfidence,
      String? explanation});
}

/// @nodoc
class __$$PlayerScanResultImplCopyWithImpl<$Res>
    extends _$PlayerScanResultCopyWithImpl<$Res, _$PlayerScanResultImpl>
    implements _$$PlayerScanResultImplCopyWith<$Res> {
  __$$PlayerScanResultImplCopyWithImpl(_$PlayerScanResultImpl _value,
      $Res Function(_$PlayerScanResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerName = null,
    Object? userId = freezed,
    Object? rawPoints = null,
    Object? exactPredictions = null,
    Object? osadiaBazasWon = null,
    Object? requestedBazas = freezed,
    Object? positionInMatch = null,
    Object? lowConfidence = null,
    Object? explanation = freezed,
  }) {
    return _then(_$PlayerScanResultImpl(
      playerName: null == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      rawPoints: null == rawPoints
          ? _value.rawPoints
          : rawPoints // ignore: cast_nullable_to_non_nullable
              as int,
      exactPredictions: null == exactPredictions
          ? _value.exactPredictions
          : exactPredictions // ignore: cast_nullable_to_non_nullable
              as int,
      osadiaBazasWon: null == osadiaBazasWon
          ? _value.osadiaBazasWon
          : osadiaBazasWon // ignore: cast_nullable_to_non_nullable
              as int,
      requestedBazas: freezed == requestedBazas
          ? _value.requestedBazas
          : requestedBazas // ignore: cast_nullable_to_non_nullable
              as int?,
      positionInMatch: null == positionInMatch
          ? _value.positionInMatch
          : positionInMatch // ignore: cast_nullable_to_non_nullable
              as int,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerScanResultImpl implements _PlayerScanResult {
  const _$PlayerScanResultImpl(
      {@JsonKey(name: 'player_name') required this.playerName,
      this.userId,
      @JsonKey(name: 'raw_points') required this.rawPoints,
      @JsonKey(name: 'exact_predictions') this.exactPredictions = 0,
      @JsonKey(name: 'osadia_bazas_won') this.osadiaBazasWon = 0,
      @JsonKey(name: 'requested_bazas') this.requestedBazas,
      @JsonKey(name: 'position_in_match') required this.positionInMatch,
      @JsonKey(name: 'low_confidence') this.lowConfidence = false,
      this.explanation});

  factory _$PlayerScanResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerScanResultImplFromJson(json);

  @override
  @JsonKey(name: 'player_name')
  final String playerName;
  @override
  final String? userId;
  @override
  @JsonKey(name: 'raw_points')
  final int rawPoints;
  @override
  @JsonKey(name: 'exact_predictions')
  final int exactPredictions;
  @override
  @JsonKey(name: 'osadia_bazas_won')
  final int osadiaBazasWon;
  @override
  @JsonKey(name: 'requested_bazas')
  final int? requestedBazas;
  @override
  @JsonKey(name: 'position_in_match')
  final int positionInMatch;
  @override
  @JsonKey(name: 'low_confidence')
  final bool lowConfidence;
  @override
  final String? explanation;

  @override
  String toString() {
    return 'PlayerScanResult(playerName: $playerName, userId: $userId, rawPoints: $rawPoints, exactPredictions: $exactPredictions, osadiaBazasWon: $osadiaBazasWon, requestedBazas: $requestedBazas, positionInMatch: $positionInMatch, lowConfidence: $lowConfidence, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerScanResultImpl &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rawPoints, rawPoints) ||
                other.rawPoints == rawPoints) &&
            (identical(other.exactPredictions, exactPredictions) ||
                other.exactPredictions == exactPredictions) &&
            (identical(other.osadiaBazasWon, osadiaBazasWon) ||
                other.osadiaBazasWon == osadiaBazasWon) &&
            (identical(other.requestedBazas, requestedBazas) ||
                other.requestedBazas == requestedBazas) &&
            (identical(other.positionInMatch, positionInMatch) ||
                other.positionInMatch == positionInMatch) &&
            (identical(other.lowConfidence, lowConfidence) ||
                other.lowConfidence == lowConfidence) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      playerName,
      userId,
      rawPoints,
      exactPredictions,
      osadiaBazasWon,
      requestedBazas,
      positionInMatch,
      lowConfidence,
      explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerScanResultImplCopyWith<_$PlayerScanResultImpl> get copyWith =>
      __$$PlayerScanResultImplCopyWithImpl<_$PlayerScanResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerScanResultImplToJson(
      this,
    );
  }
}

abstract class _PlayerScanResult implements PlayerScanResult {
  const factory _PlayerScanResult(
      {@JsonKey(name: 'player_name') required final String playerName,
      final String? userId,
      @JsonKey(name: 'raw_points') required final int rawPoints,
      @JsonKey(name: 'exact_predictions') final int exactPredictions,
      @JsonKey(name: 'osadia_bazas_won') final int osadiaBazasWon,
      @JsonKey(name: 'requested_bazas') final int? requestedBazas,
      @JsonKey(name: 'position_in_match') required final int positionInMatch,
      @JsonKey(name: 'low_confidence') final bool lowConfidence,
      final String? explanation}) = _$PlayerScanResultImpl;

  factory _PlayerScanResult.fromJson(Map<String, dynamic> json) =
      _$PlayerScanResultImpl.fromJson;

  @override
  @JsonKey(name: 'player_name')
  String get playerName;
  @override
  String? get userId;
  @override
  @JsonKey(name: 'raw_points')
  int get rawPoints;
  @override
  @JsonKey(name: 'exact_predictions')
  int get exactPredictions;
  @override
  @JsonKey(name: 'osadia_bazas_won')
  int get osadiaBazasWon;
  @override
  @JsonKey(name: 'requested_bazas')
  int? get requestedBazas;
  @override
  @JsonKey(name: 'position_in_match')
  int get positionInMatch;
  @override
  @JsonKey(name: 'low_confidence')
  bool get lowConfidence;
  @override
  String? get explanation;
  @override
  @JsonKey(ignore: true)
  _$$PlayerScanResultImplCopyWith<_$PlayerScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScanResultModel _$ScanResultModelFromJson(Map<String, dynamic> json) {
  return _ScanResultModel.fromJson(json);
}

/// @nodoc
mixin _$ScanResultModel {
  List<PlayerScanResult> get players => throw _privateConstructorUsedError;
  @JsonKey(name: 'played_at')
  DateTime? get playedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_rounds')
  int? get totalRounds => throw _privateConstructorUsedError;
  String? get warning => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanResultModelCopyWith<ScanResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanResultModelCopyWith<$Res> {
  factory $ScanResultModelCopyWith(
          ScanResultModel value, $Res Function(ScanResultModel) then) =
      _$ScanResultModelCopyWithImpl<$Res, ScanResultModel>;
  @useResult
  $Res call(
      {List<PlayerScanResult> players,
      @JsonKey(name: 'played_at') DateTime? playedAt,
      @JsonKey(name: 'total_rounds') int? totalRounds,
      String? warning});
}

/// @nodoc
class _$ScanResultModelCopyWithImpl<$Res, $Val extends ScanResultModel>
    implements $ScanResultModelCopyWith<$Res> {
  _$ScanResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? players = null,
    Object? playedAt = freezed,
    Object? totalRounds = freezed,
    Object? warning = freezed,
  }) {
    return _then(_value.copyWith(
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as List<PlayerScanResult>,
      playedAt: freezed == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalRounds: freezed == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int?,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanResultModelImplCopyWith<$Res>
    implements $ScanResultModelCopyWith<$Res> {
  factory _$$ScanResultModelImplCopyWith(_$ScanResultModelImpl value,
          $Res Function(_$ScanResultModelImpl) then) =
      __$$ScanResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PlayerScanResult> players,
      @JsonKey(name: 'played_at') DateTime? playedAt,
      @JsonKey(name: 'total_rounds') int? totalRounds,
      String? warning});
}

/// @nodoc
class __$$ScanResultModelImplCopyWithImpl<$Res>
    extends _$ScanResultModelCopyWithImpl<$Res, _$ScanResultModelImpl>
    implements _$$ScanResultModelImplCopyWith<$Res> {
  __$$ScanResultModelImplCopyWithImpl(
      _$ScanResultModelImpl _value, $Res Function(_$ScanResultModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? players = null,
    Object? playedAt = freezed,
    Object? totalRounds = freezed,
    Object? warning = freezed,
  }) {
    return _then(_$ScanResultModelImpl(
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<PlayerScanResult>,
      playedAt: freezed == playedAt
          ? _value.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalRounds: freezed == totalRounds
          ? _value.totalRounds
          : totalRounds // ignore: cast_nullable_to_non_nullable
              as int?,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanResultModelImpl implements _ScanResultModel {
  const _$ScanResultModelImpl(
      {required final List<PlayerScanResult> players,
      @JsonKey(name: 'played_at') this.playedAt,
      @JsonKey(name: 'total_rounds') this.totalRounds,
      this.warning})
      : _players = players;

  factory _$ScanResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanResultModelImplFromJson(json);

  final List<PlayerScanResult> _players;
  @override
  List<PlayerScanResult> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  @JsonKey(name: 'played_at')
  final DateTime? playedAt;
  @override
  @JsonKey(name: 'total_rounds')
  final int? totalRounds;
  @override
  final String? warning;

  @override
  String toString() {
    return 'ScanResultModel(players: $players, playedAt: $playedAt, totalRounds: $totalRounds, warning: $warning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanResultModelImpl &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.totalRounds, totalRounds) ||
                other.totalRounds == totalRounds) &&
            (identical(other.warning, warning) || other.warning == warning));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_players),
      playedAt,
      totalRounds,
      warning);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanResultModelImplCopyWith<_$ScanResultModelImpl> get copyWith =>
      __$$ScanResultModelImplCopyWithImpl<_$ScanResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanResultModelImplToJson(
      this,
    );
  }
}

abstract class _ScanResultModel implements ScanResultModel {
  const factory _ScanResultModel(
      {required final List<PlayerScanResult> players,
      @JsonKey(name: 'played_at') final DateTime? playedAt,
      @JsonKey(name: 'total_rounds') final int? totalRounds,
      final String? warning}) = _$ScanResultModelImpl;

  factory _ScanResultModel.fromJson(Map<String, dynamic> json) =
      _$ScanResultModelImpl.fromJson;

  @override
  List<PlayerScanResult> get players;
  @override
  @JsonKey(name: 'played_at')
  DateTime? get playedAt;
  @override
  @JsonKey(name: 'total_rounds')
  int? get totalRounds;
  @override
  String? get warning;
  @override
  @JsonKey(ignore: true)
  _$$ScanResultModelImplCopyWith<_$ScanResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
