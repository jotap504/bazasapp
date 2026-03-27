// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchResultModelImpl _$$MatchResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchResultModelImpl(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      userId: json['user_id'] as String?,
      guestMemberId: json['guest_member_id'] as String?,
      positionInMatch: (json['position_in_match'] as num).toInt(),
      rawPoints: (json['raw_points'] as num?)?.toInt() ?? 0,
      exactPredictions: (json['exact_predictions'] as num?)?.toInt() ?? 0,
      requestedBazas: (json['requested_bazas'] as num?)?.toInt(),
      osadiaBazasWon: (json['osadia_bazas_won'] as num?)?.toInt() ?? 0,
      accuracyPercent: (json['accuracy_percent'] as num?)?.toDouble() ?? 0.0,
      totalMatchRounds: (json['total_match_rounds'] as num?)?.toInt() ?? 10,
      earnedChampionshipPoints:
          (json['earned_championship_points'] as num?)?.toDouble() ?? 0.0,
      osadiaPoints: (json['osadia_points'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      profile: json['profile'] == null
          ? null
          : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MatchResultModelImplToJson(
        _$MatchResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'match_id': instance.matchId,
      'user_id': instance.userId,
      'guest_member_id': instance.guestMemberId,
      'position_in_match': instance.positionInMatch,
      'raw_points': instance.rawPoints,
      'exact_predictions': instance.exactPredictions,
      'requested_bazas': instance.requestedBazas,
      'osadia_bazas_won': instance.osadiaBazasWon,
      'accuracy_percent': instance.accuracyPercent,
      'total_match_rounds': instance.totalMatchRounds,
      'earned_championship_points': instance.earnedChampionshipPoints,
      'osadia_points': instance.osadiaPoints,
      'created_at': instance.createdAt.toIso8601String(),
      'profile': instance.profile?.toJson(),
    };
