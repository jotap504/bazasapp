import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/scan/presentation/controllers/scan_controller.dart';
class ScanLoadingScreen extends ConsumerStatefulWidget {
  const ScanLoadingScreen({super.key});
  @override
  ConsumerState<ScanLoadingScreen> createState() => _ScanLoadingScreenState();
}
class _ScanLoadingScreenState extends ConsumerState<ScanLoadingScreen> {
  bool _showManualButton = false;

  @override
  void initState() {
    super.initState();
    // Ejecutar _start después del primer frame para evitar errores de Riverpod
    Future.microtask(() => _start());
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showManualButton = true);
    });
  }

  Future<void> _start() async {
    final ok = await ref.read(scanControllerProvider.notifier).processImage();
    if (mounted) {
      if (ok) {
        context.pushReplacement(AppRoutes.scanVerify);
      } else {
        final error = ref.read(scanControllerProvider).error ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error AI: $error'), backgroundColor: AppColors.error),
        );
        context.pop();
      }
    }
  }

  Future<void> _handleManual() async {
    final ok = await ref.read(scanControllerProvider.notifier).startManualEntry();
    if (mounted) {
      if (ok) {
        context.pushReplacement(AppRoutes.scanVerify);
      } else {
        final error = ref.read(scanControllerProvider).error ?? 'Error desconocido al cargar miembros';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAiBrain01, color: AppColors.neonCyan, size: 80)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1500.ms),
            const SizedBox(height: 24),
            const Text('PROCESANDO...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'La IA está analizando la planilla. Esto puede tardar unos segundos...',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            if (_showManualButton) ...[
              const SizedBox(height: 48),
              TextButton.icon(
                onPressed: _handleManual,
                icon: const Icon(Icons.edit_note, color: AppColors.neonOrange),
                label: const Text(
                  'SALTAR A CARGA MANUAL',
                  style: TextStyle(color: AppColors.neonOrange, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(),
            ],
          ]),
        ),
      ),
    );
  }
}

