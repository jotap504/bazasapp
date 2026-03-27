import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bazas/features/auth/data/models/profile_model.dart';

part 'match_result_model.freezed.dart';
part 'match_result_model.g.dart';

@freezed
class MatchResultModel with _$MatchResultModel {
  const factory MatchResultModel({
    required String id,
    @JsonKey(name: 'match_id') required String matchId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'guest_member_id') String? guestMemberId,
    @JsonKey(name: 'position_in_match') required int positionInMatch,
    @JsonKey(name: 'raw_points') @Default(0) int rawPoints,
    @JsonKey(name: 'exact_predictions') @Default(0) int exactPredictions,
    @JsonKey(name: 'requested_bazas') int? requestedBazas,
    @JsonKey(name: 'osadia_bazas_won') @Default(0) int osadiaBazasWon,
    @JsonKey(name: 'accuracy_percent') @Default(0.0) double accuracyPercent,
    @JsonKey(name: 'total_match_rounds') @Default(10) int totalMatchRounds,
    @JsonKey(name: 'earned_championship_points') @Default(0.0) double earnedChampionshipPoints,
    @JsonKey(name: 'osadia_points') @Default(0.0) double osadiaPoints,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    ProfileModel? profile,
  }) = _MatchResultModel;

  factory MatchResultModel.fromJson(Map<String, dynamic> json) => _$MatchResultModelFromJson(json);
}
