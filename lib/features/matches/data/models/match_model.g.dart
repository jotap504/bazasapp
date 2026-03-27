// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchModelImpl _$$MatchModelImplFromJson(Map<String, dynamic> json) =>
    _$MatchModelImpl(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      playedAt: DateTime.parse(json['played_at'] as String),
      scoresheetImageUrl: json['scoresheet_image_url'] as String?,
      isOfficial: json['is_official'] as bool? ?? false,
      notes: json['notes'] as String?,
      playersCount: (json['players_count'] as num?)?.toInt() ?? 0,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$MatchModelImplToJson(_$MatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'played_at': instance.playedAt.toIso8601String(),
      'scoresheet_image_url': instance.scoresheetImageUrl,
      'is_official': instance.isOfficial,
      'notes': instance.notes,
      'players_count': instance.playersCount,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
