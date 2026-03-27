import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result_model.freezed.dart';
part 'scan_result_model.g.dart';

@freezed
class PlayerScanResult with _$PlayerScanResult {
  const factory PlayerScanResult({
    @JsonKey(name: 'player_name') required String playerName,
    String? userId,
    @JsonKey(name: 'raw_points') required int rawPoints,
    @JsonKey(name: 'exact_predictions') @Default(0) int exactPredictions,
    @JsonKey(name: 'osadia_bazas_won') @Default(0) int osadiaBazasWon,
    @JsonKey(name: 'requested_bazas') int? requestedBazas,
    @JsonKey(name: 'position_in_match') required int positionInMatch,
    @JsonKey(name: 'low_confidence') @Default(false) bool lowConfidence,
    String? explanation,
  }) = _PlayerScanResult;

  factory PlayerScanResult.fromJson(Map<String, dynamic> json) => _$PlayerScanResultFromJson(json);
}

@freezed
class ScanResultModel with _$ScanResultModel {
  const factory ScanResultModel({
    required List<PlayerScanResult> players,
    @JsonKey(name: 'played_at') DateTime? playedAt,
    @JsonKey(name: 'total_rounds') int? totalRounds,
    String? warning,
  }) = _ScanResultModel;

  factory ScanResultModel.fromJson(Map<String, dynamic> json) => _$ScanResultModelFromJson(json);
}
