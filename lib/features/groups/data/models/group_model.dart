import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'min_quorum') @Default(5) int minQuorum,
    @JsonKey(name: 'f1_points_system') required List<int> f1PointsSystem,
    @JsonKey(name: 'min_attendance_pct') @Default(50) int minAttendancePct,
    @JsonKey(name: 'osadia_multiplier') @Default(1.0) double osadiaMultiplier,
    @JsonKey(name: 'efectividad_multiplier') @Default(1.0) double efectividadMultiplier,
    @JsonKey(name: 'pts_per_promise') @Default(10) int ptsPerPromise,
    @JsonKey(name: 'pts_per_trick') @Default(1) int ptsPerTrick,
    @JsonKey(name: 'osadia_config') List<Map<String, dynamic>>? osadiaConfig,
    @JsonKey(name: 'invite_code') String? inviteCode,
    @Default('open') String status,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Relaciones opcionales (JOIN)
    @JsonKey(name: 'member_count') int? memberCount,
    @JsonKey(name: 'match_count') int? matchCount,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
