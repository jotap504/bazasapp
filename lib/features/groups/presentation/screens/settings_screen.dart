import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/core/services/preferences_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('CONFIGURACIÓN')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // PERFIL RESUMEN
            if (user != null)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surfaceElevated,
                  child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.white, size: 30),
                ),
                title: Text(user.email ?? 'Invitado', style: AppTextStyles.inter(fontWeight: FontWeight.bold)),
                subtitle: const Text('JUGADOR ACTIVO'),
                trailing: TextButton(
                  onPressed: () => context.push('/profile/${user.id}'),
                  child: const Text('VER PERFIL'),
                ),
              ),
            
            const Divider(),
            const SizedBox(height: 16),

            // CONFIGURACIÓN IA
            Text('INTELIGENCIA ARTIFICIAL', 
              style: AppTextStyles.inter(fontSize: 12, color: AppColors.neonCyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Añade instrucciones específicas para que la IA interprete mejor tu planilla.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: ref.watch(customAiPromptProvider),
              maxLines: 5,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ej: "Sumar 10 puntos extra si el jugador acertó su predicción exacta..."',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (v) => ref.read(customAiPromptProvider.notifier).setPrompt(v),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // SECCIONES
            const _SettingsTile(
              icon: HugeIcons.strokeRoundedNotification01,
              title: 'NOTIFICACIONES',
              subtitle: 'Alertas de nuevas partidas y ranking',
            ),
            const _SettingsTile(
              icon: HugeIcons.strokeRoundedSecurity,
              title: 'PRIVACIDAD',
              subtitle: 'Gestión de datos y visibilidad',
            ),
            _SettingsTile(
              icon: HugeIcons.strokeRoundedInformationCircle,
              title: 'REGLAMENTO "LA PODRIDA"',
              subtitle: 'Cómo se calculan los puntos de Osadía y Bazas',
              onTap: () {
                // TODO: Mostrar diálogo con las reglas
              },
            ),
            
            const SizedBox(height: 48),

            // BOTONES DE ACCIÓN
            OutlinedButton.icon(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, size: 20, color: AppColors.error),
              label: const Text('CERRAR SESIÓN (PIT STOP)'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            ),
            
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'VERSIÓN 1.0.0 — BAZAS',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: HugeIcon(icon: icon, color: AppColors.neonCyan, size: 20),
      ),
      title: Text(title, style: AppTextStyles.inter(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: AppTextStyles.inter(fontSize: 11, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
    );
  }
}
