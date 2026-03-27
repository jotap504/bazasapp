import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGroupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS LIGAS'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: Colors.white, size: 24),
          ),
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: Container(
        decoration: AppDecorations.background,
        child: myGroupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Error al cargar ligas: $err', style: const TextStyle(color: Colors.red)),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return _EmptyGroupsState();
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(myGroupsProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _GroupCard(group: group)
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideY(begin: 0.1, curve: Curves.easeOut);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupOptions(context),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  void _showAddGroupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: AppColors.neonGreen, size: 24),
              title: const Text('CREAR LIGA'),
              subtitle: const Text('Configura tu propio campeonato de Bazas'),
              onTap: () {
                context.pop();
                context.push(AppRoutes.createGroup);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedTicket01, color: AppColors.neonCyan, size: 24),
              title: const Text('UNIRSE A LIGA'),
              subtitle: const Text('Ingresa un código de invitación'),
              onTap: () {
                context.pop();
                context.push(AppRoutes.joinGroup);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/groups/${group.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name.toUpperCase(),
                      style: AppTextStyles.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreenDim,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.neonGreen, width: 0.5),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (group.description != null)
                Text(
                  group.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'QUORUM',
                    value: '${group.minQuorum}',
                    icon: HugeIcons.strokeRoundedUserGroup,
                  ),
                  _StatItem(
                    label: 'PARTIDAS',
                    value: '${group.matchCount ?? 0}',
                    icon: HugeIcons.strokeRoundedGame,
                  ),
                  _StatItem(
                    label: 'MULT.',
                    value: 'x${group.osadiaMultiplier}',
                    icon: HugeIcons.strokeRoundedFlash,
                    color: AppColors.neonOrange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.neonCyan,
  });

  final String label;
  final String value;
  final List<List<dynamic>> icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HugeIcon(icon: icon, size: 16, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.inter(
            fontSize: 9,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedChampion,
            size: 80,
            color: AppColors.borderSubtle,
          ),
          const SizedBox(height: 24),
          Text(
            'SIN COMPETICIÓN ACTIVA',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          const Text('Crea o únete a una liga para empezar.'),
        ],
      ),
    );
  }
}
