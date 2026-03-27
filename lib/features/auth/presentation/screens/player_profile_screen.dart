import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('PILOT PROFILE'),
        actions: [
          if (userId == ref.watch(currentUserProvider)?.id)
            IconButton(
              onPressed: () => context.push(AppRoutes.editProfile.replaceFirst(':userId', userId)),
              icon: const Icon(Icons.edit, color: AppColors.neonGreen),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // AVATAR & NAME
                _ProfileHeader(profile: profile),
                
                const SizedBox(height: 32),
                
                // RADAR CHART (Stats)
                const Text('TELEMETRÍA DE RENDIMIENTO', style: TextStyle(letterSpacing: 1.5, fontSize: 10, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                _PerformanceRadar(),

                const SizedBox(height: 32),

                // GRID DE ESTADÍSTICAS
                const Row(
                  children: [
                    Expanded(child: _ProfileStatCard(label: 'VICTORIAS', value: '12', icon: HugeIcons.strokeRoundedChampion)),
                    SizedBox(width: 16),
                    Expanded(child: _ProfileStatCard(label: 'PARTIDAS', value: '45', icon: HugeIcons.strokeRoundedChampion)),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: _ProfileStatCard(label: 'OSADÍA PROMEDIO', value: '4.2', icon: HugeIcons.strokeRoundedFlash, color: AppColors.neonOrange)),
                    SizedBox(width: 16),
                    Expanded(child: _ProfileStatCard(label: 'EFECTIVIDAD', value: '85%', icon: HugeIcons.strokeRoundedTarget02, color: AppColors.neonCyan)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.neonGreen, width: 2)),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl) : null,
            child: profile.avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          profile.displayName.toUpperCase(),
          style: AppTextStyles.headlineMedium,
        ),
        Text(
          'JUGADOR',
          style: AppTextStyles.neonLabel.copyWith(color: AppColors.neonGreen),
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.label, required this.value, required this.icon, this.color = AppColors.neonGreen});
  final String label;
  final String value;
  final List<List<dynamic>> icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.rajdhani(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTextStyles.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRadar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: AppColors.borderSubtle, width: 1),
          gridBorderData: const BorderSide(color: AppColors.borderSubtle, width: 1),
          tickBorderData: const BorderSide(color: AppColors.borderSubtle, width: 1),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.neonGreen.withOpacity(0.2),
              borderColor: AppColors.neonGreen,
              entryRadius: 3,
              dataEntries: [
                const RadarEntry(value: 80), // Consistencia
                const RadarEntry(value: 60), // Osadía
                const RadarEntry(value: 90), // Efectividad
                const RadarEntry(value: 70), // Puntos
                const RadarEntry(value: 50), // Victorias
              ],
            ),
          ],
          getTitle: (index, _) {
            switch (index) {
              case 0: return const RadarChartTitle(text: 'CONSIST.', angle: 0);
              case 1: return const RadarChartTitle(text: 'OSADÍA', angle: 0);
              case 2: return const RadarChartTitle(text: 'EFECT.', angle: 0);
              case 3: return const RadarChartTitle(text: 'PUNTOS', angle: 0);
              case 4: return const RadarChartTitle(text: 'WINS', angle: 0);
              default: return const RadarChartTitle(text: '');
            }
          },
        ),
      ),
    );
  }
}
