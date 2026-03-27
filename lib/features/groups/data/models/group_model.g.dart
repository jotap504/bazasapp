// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupModelImpl _$$GroupModelImplFromJson(Map<String, dynamic> json) =>
    _$GroupModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      minQuorum: (json['min_quorum'] as num?)?.toInt() ?? 5,
      f1PointsSystem: (json['f1_points_system'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      minAttendancePct: (json['min_attendance_pct'] as num?)?.toInt() ?? 50,
      osadiaMultiplier: (json['osadia_multiplier'] as num?)?.toDouble() ?? 1.0,
      efectividadMultiplier:
          (json['efectividad_multiplier'] as num?)?.toDouble() ?? 1.0,
      ptsPerPromise: (json['pts_per_promise'] as num?)?.toInt() ?? 10,
      ptsPerTrick: (json['pts_per_trick'] as num?)?.toInt() ?? 1,
      osadiaConfig: (json['osadia_config'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      inviteCode: json['invite_code'] as String?,
      status: json['status'] as String? ?? 'open',
      closedAt: json['closed_at'] == null
          ? null
          : DateTime.parse(json['closed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      memberCount: (json['member_count'] as num?)?.toInt(),
      matchCount: (json['match_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GroupModelImplToJson(_$GroupModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_by': instance.createdBy,
      'min_quorum': instance.minQuorum,
      'f1_points_system': instance.f1PointsSystem,
      'min_attendance_pct': instance.minAttendancePct,
      'osadia_multiplier': instance.osadiaMultiplier,
      'efectividad_multiplier': instance.efectividadMultiplier,
      'pts_per_promise': instance.ptsPerPromise,
      'pts_per_trick': instance.ptsPerTrick,
      'osadia_config': instance.osadiaConfig,
      'invite_code': instance.inviteCode,
      'status': instance.status,
      'closed_at': instance.closedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'member_count': instance.memberCount,
      'match_count': instance.matchCount,
    };
