import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    // Cargar datos iniciales
    Future.microtask(() async {
      final profile = await ref.read(authRepositoryProvider).fetchProfileById(widget.userId);
      _nameController.text = profile.displayName;
      _nicknameController.text = profile.nickname ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
        displayName: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado'), backgroundColor: AppColors.neonGreen),
        );
        ref.invalidate(profileProvider(widget.userId));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EDITAR PERFIL')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surfaceElevated,
                        child: Icon(Icons.person, size: 60, color: AppColors.textMuted),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text('DATOS DEL JUGADOR', style: AppTextStyles.neonLabel),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'NOMBRE DE USUARIO / NOMBRE REAL',
                    prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white, size: 20),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  autofillHints: const [AutofillHints.nickname],
                  decoration: const InputDecoration(
                    labelText: 'APODO / NICKNAME (OPCIONAL)',
                    prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text('GUARDAR CAMBIOS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
