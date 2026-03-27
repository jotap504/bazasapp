import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(authRepositoryProvider).currentUser?.id;
      if (userId == null) return;
      await ref.read(groupsRepositoryProvider).joinByInviteCode(inviteCode: code, userId: userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Te has unido a la liga exitosamente!'), backgroundColor: AppColors.neonCyan),
        );
        ref.invalidate(myGroupsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('not found')) msg = 'Código de invitación no válido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $msg'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ENTRAR A PITS')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedTicket01,
                color: AppColors.neonCyan,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'CÓDIGO DE INVITACIÓN',
                style: AppTextStyles.rajdhani(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa el código que te pasó el admin de la liga.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                style: AppTextStyles.rajdhani(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8.0,
                  color: AppColors.neonCyan,
                ),
                decoration: const InputDecoration(
                  hintText: 'XYZ-123',
                  hintStyle: TextStyle(color: Colors.white24),
                  counterText: '',
                ),
                maxLength: 7,
                textCapitalization: TextCapitalization.characters,
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black) 
                    : const Text('JOIN COMPETITION', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
