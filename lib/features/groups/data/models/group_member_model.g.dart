// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMemberModelImpl _$$GroupMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupMemberModelImpl(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String?,
      guestFullName: json['guest_full_name'] as String?,
      guestNickname: json['guest_nickname'] as String?,
      role: json['role'] as String? ?? 'member',
      totalChampionshipPoints:
          (json['total_championship_points'] as num?)?.toDouble() ?? 0.0,
      totalMatchesPlayed: (json['total_matches_played'] as num?)?.toInt() ?? 0,
      totalOsadiaPoints:
          (json['total_osadia_points'] as num?)?.toDouble() ?? 0.0,
      sumAccuracyPercent:
          (json['sum_accuracy_percent'] as num?)?.toDouble() ?? 0.0,
      countAccuracyMatches:
          (json['count_accuracy_matches'] as num?)?.toInt() ?? 0,
      effectiveAvgPercent:
          (json['effective_avg_percent'] as num?)?.toDouble() ?? 0.0,
      totalWins: (json['total_wins'] as num?)?.toInt() ?? 0,
      totalFailedOsadia: (json['total_failed_osadia'] as num?)?.toInt() ?? 0,
      totalChamulleroScore:
          (json['total_chamullero_score'] as num?)?.toInt() ?? 0,
      currentPosition: (json['current_position'] as num?)?.toInt(),
      previousPosition: (json['previous_position'] as num?)?.toInt(),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profile: json['profile'] == null
          ? null
          : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GroupMemberModelImplToJson(
        _$GroupMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'user_id': instance.userId,
      'guest_full_name': instance.guestFullName,
      'guest_nickname': instance.guestNickname,
      'role': instance.role,
      'total_championship_points': instance.totalChampionshipPoints,
      'total_matches_played': instance.totalMatchesPlayed,
      'total_osadia_points': instance.totalOsadiaPoints,
      'sum_accuracy_percent': instance.sumAccuracyPercent,
      'count_accuracy_matches': instance.countAccuracyMatches,
      'effective_avg_percent': instance.effectiveAvgPercent,
      'total_wins': instance.totalWins,
      'total_failed_osadia': instance.totalFailedOsadia,
      'total_chamullero_score': instance.totalChamulleroScore,
      'current_position': instance.currentPosition,
      'previous_position': instance.previousPosition,
      'joined_at': instance.joinedAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'profile': instance.profile?.toJson(),
    };
