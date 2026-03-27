import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bazas/features/auth/data/models/profile_model.dart';

part 'group_member_model.freezed.dart';
part 'group_member_model.g.dart';

@freezed
class GroupMemberModel with _$GroupMemberModel {
  const factory GroupMemberModel({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'guest_full_name') String? guestFullName,
    @JsonKey(name: 'guest_nickname') String? guestNickname,
    @Default('member') String role,
    @JsonKey(name: 'total_championship_points') @Default(0.0) double totalChampionshipPoints,
    @JsonKey(name: 'total_matches_played') @Default(0) int totalMatchesPlayed,
    @JsonKey(name: 'total_osadia_points') @Default(0.0) double totalOsadiaPoints,
    @JsonKey(name: 'sum_accuracy_percent') @Default(0.0) double sumAccuracyPercent,
    @JsonKey(name: 'count_accuracy_matches') @Default(0) int countAccuracyMatches,
    @JsonKey(name: 'effective_avg_percent') @Default(0.0) double effectiveAvgPercent,
    @JsonKey(name: 'total_wins') @Default(0) int totalWins,
    @JsonKey(name: 'total_failed_osadia') @Default(0) int totalFailedOsadia,
    @JsonKey(name: 'total_chamullero_score') @Default(0) int totalChamulleroScore,
    @JsonKey(name: 'current_position') int? currentPosition,
    @JsonKey(name: 'previous_position') int? previousPosition,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // JOIN con profiles
    ProfileModel? profile,
  }) = _GroupMemberModel;

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberModelFromJson(json);
}

extension GroupMemberModelX on GroupMemberModel {
  /// Diferencia de posición respecto a la ronda anterior.
  /// Positivo = subió, negativo = bajó, null = sin cambio o sin datos.
  int? get positionDelta {
    if (currentPosition == null || previousPosition == null) return null;
    return previousPosition! - currentPosition!;
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'owner' || role == 'admin';
}
