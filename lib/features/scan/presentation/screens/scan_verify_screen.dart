import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/scan/presentation/controllers/scan_controller.dart';
import 'package:bazas/features/scan/data/models/scan_result_model.dart';

class ScanVerifyScreen extends ConsumerWidget {
  const ScanVerifyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scanControllerProvider);
    final r = s.result;
    if (r == null) return const Scaffold(body: Center(child: Text('Sin datos')));
    return Scaffold(
      appBar: AppBar(title: const Text('VERIFICACIÓN')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: Column(children: [
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: r.players.length,
            itemBuilder: (c, i) => _PlayerEditCard(p: r.players[i], onC: (up) => ref.read(scanControllerProvider.notifier).updatePlayerResult(i, up))
          )),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
                print('[NAV] Navegando a Confirma (Verify -> Confirm)');
                context.push(AppRoutes.scanConfirm);
              }, 
              child: const Text('CONTINUAR')
            )
          )
        ])
      )
    );
  }
}

class _PlayerEditCard extends StatelessWidget {
  final PlayerScanResult p;
  final ValueChanged<PlayerScanResult> onC;
  const _PlayerEditCard({required this.p, required this.onC});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(p.playerName.toUpperCase(), style: AppTextStyles.rajdhani(fontWeight: FontWeight.bold, fontSize: 16))),
            if(p.lowConfidence) const Tooltip(message: 'IA con baja confianza', child: HugeIcon(icon: HugeIcons.strokeRoundedView, color: Colors.orange, size: 18)),
          ]),
          const Divider(height: 24, color: Colors.white10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TextFormField(
                  initialValue: p.rawPoints.toString(),
                  decoration: const InputDecoration(
                    labelText: 'PUNTOS',
                    labelStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onC(p.copyWith(rawPoints: int.tryParse(v) ?? 0)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: TextFormField(
                  initialValue: p.exactPredictions.toString(),
                  decoration: const InputDecoration(
                    labelText: 'PROMESAS',
                    labelStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onC(p.copyWith(exactPredictions: int.tryParse(v) ?? 0)),
                ),
              ),
              Flexible(
                flex: 1,
                child: TextFormField(
                  initialValue: p.requestedBazas?.toString() ?? '0',
                  decoration: const InputDecoration(
                    labelText: 'SOLICIT.',
                    labelStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onC(p.copyWith(requestedBazas: int.tryParse(v) ?? 0)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: TextFormField(
                  initialValue: p.osadiaBazasWon.toString(),
                  decoration: const InputDecoration(
                    labelText: 'GANADAS',
                    labelStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onC(p.copyWith(osadiaBazasWon: int.tryParse(v) ?? 0)),
                ),
              ),
            ],
          ),
          if (p.explanation != null && p.explanation!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.neonCyan),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.explanation!,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ])
      )
    );
  }
}
