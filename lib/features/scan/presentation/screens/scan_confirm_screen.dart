import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/scan/presentation/controllers/scan_controller.dart';
class ScanConfirmScreen extends ConsumerStatefulWidget {
  const ScanConfirmScreen({super.key});
  @override
  ConsumerState<ScanConfirmScreen> createState() => _ScanConfirmScreenState();
}
class _ScanConfirmScreenState extends ConsumerState<ScanConfirmScreen> {
  bool _sub = false;
  Future<void> _go() async {
    setState(() => _sub = true);
    final ok = await ref.read(scanControllerProvider.notifier).submitMatch();
    if (mounted) {
      if (ok) {
        context.go('/home');
      } else {
        final error = ref.read(scanControllerProvider).error ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error'), backgroundColor: Colors.red),
        );
        setState(() => _sub = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    print('[RENDER] Construyendo ScanConfirmScreen');
    final r = ref.watch(scanControllerProvider).result;
    return Scaffold(
      appBar: AppBar(title: const Text('RESUMEN')),
      body: r == null ? const SizedBox() : Column(children: [
        const SizedBox(height: 24),
        const HugeIcon(icon: HugeIcons.strokeRoundedChampion, color: AppColors.gold, size: 60),
        const SizedBox(height: 24),
        Expanded(child: ListView.builder(
          itemCount: r.players.length,
          itemBuilder: (c, i) => ListTile(
            title: Text(r.players[i].playerName),
            trailing: Text('${r.players[i].rawPoints} PTS'),
          )
        )),
        Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(onPressed: _sub ? null : _go, child: _sub ? const CircularProgressIndicator() : const Text('CONFIRMAR'))
        )
      ])
    );
  }
}
