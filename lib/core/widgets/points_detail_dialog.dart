import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PointsDetailDialog extends StatelessWidget {
  final String playerName;
  final int position;
  final double championshipPoints;
  final double osadiaPoints;
  final double accuracyPercent;
  final int exactPredictions;
  final int totalRounds;
  final bool useOsadia;
  final double osadiaMultiplier;

  const PointsDetailDialog({
    super.key,
    required this.playerName,
    required this.position,
    required this.championshipPoints,
    required this.osadiaPoints,
    required this.accuracyPercent,
    required this.exactPredictions,
    required this.totalRounds,
    this.useOsadia = true,
    this.osadiaMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(playerName.toUpperCase(), style: AppTextStyles.neonLabel.copyWith(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Posición ${position}º', '${championshipPoints.toInt()} pts'),
          if (useOsadia) ...[
            const SizedBox(height: 8),
            _detailRow('Osadía (Bazas ganadas * $osadiaMultiplier)', '${osadiaPoints.toInt()} pts'),
          ],
          const Divider(color: Colors.white12, height: 32),
          _detailRow('Total Campeonato', '${championshipPoints.toInt()} pts'),
          _detailRow('Total Osadía', '${osadiaPoints.toInt()} pts'),
          const SizedBox(height: 24),
          Text('ESTADÍSTICAS', style: AppTextStyles.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          _detailRow('Efectividad', '${accuracyPercent.toStringAsFixed(1)}% ($exactPredictions/$totalRounds)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CERRAR', style: TextStyle(color: AppColors.neonCyan)),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String playerName,
    required int position,
    required double championshipPoints,
    required double osadiaPoints,
    required double accuracyPercent,
    required int exactPredictions,
    required int totalRounds,
    bool useOsadia = true,
    double osadiaMultiplier = 1.0,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PointsDetailDialog(
        playerName: playerName,
        position: position,
        championshipPoints: championshipPoints,
        osadiaPoints: osadiaPoints,
        accuracyPercent: accuracyPercent,
        exactPredictions: exactPredictions,
        totalRounds: totalRounds,
        useOsadia: useOsadia,
        osadiaMultiplier: osadiaMultiplier,
      ),
    );
  }
}
