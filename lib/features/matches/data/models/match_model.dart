import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'played_at') required DateTime playedAt,
    @JsonKey(name: 'scoresheet_image_url') String? scoresheetImageUrl,
    @JsonKey(name: 'is_official') @Default(false) bool isOfficial,
    String? notes,
    @JsonKey(name: 'players_count') @Default(0) int playersCount,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _MatchModel;

  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);
}
