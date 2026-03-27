// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerScanResultImpl _$$PlayerScanResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PlayerScanResultImpl(
      playerName: json['player_name'] as String,
      userId: json['userId'] as String?,
      rawPoints: (json['raw_points'] as num).toInt(),
      exactPredictions: (json['exact_predictions'] as num?)?.toInt() ?? 0,
      osadiaBazasWon: (json['osadia_bazas_won'] as num?)?.toInt() ?? 0,
      requestedBazas: (json['requested_bazas'] as num?)?.toInt(),
      positionInMatch: (json['position_in_match'] as num).toInt(),
      lowConfidence: json['low_confidence'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$$PlayerScanResultImplToJson(
        _$PlayerScanResultImpl instance) =>
    <String, dynamic>{
      'player_name': instance.playerName,
      'userId': instance.userId,
      'raw_points': instance.rawPoints,
      'exact_predictions': instance.exactPredictions,
      'osadia_bazas_won': instance.osadiaBazasWon,
      'requested_bazas': instance.requestedBazas,
      'position_in_match': instance.positionInMatch,
      'low_confidence': instance.lowConfidence,
      'explanation': instance.explanation,
    };

_$ScanResultModelImpl _$$ScanResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScanResultModelImpl(
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerScanResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      playedAt: json['played_at'] == null
          ? null
          : DateTime.parse(json['played_at'] as String),
      totalRounds: (json['total_rounds'] as num?)?.toInt(),
      warning: json['warning'] as String?,
    );

Map<String, dynamic> _$$ScanResultModelImplToJson(
        _$ScanResultModelImpl instance) =>
    <String, dynamic>{
      'players': instance.players.map((e) => e.toJson()).toList(),
      'played_at': instance.playedAt?.toIso8601String(),
      'total_rounds': instance.totalRounds,
      'warning': instance.warning,
    };
