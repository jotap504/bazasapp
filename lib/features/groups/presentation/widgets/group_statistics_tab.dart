import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';
import 'package:bazas/features/matches/data/repositories/matches_repository.dart';

import 'points_evolution_chart.dart';
import 'podium_distribution_chart.dart';
import 'player_trivia_cards.dart';

class GroupStatisticsTab extends ConsumerWidget {
  const GroupStatisticsTab({
    super.key,
    required this.groupId,
    this.group,
  });

  final String groupId;
  final GroupModel? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final matchesAsync = ref.watch(groupMatchesProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error cargando miembros: $err')),
      data: (members) {
        return matchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error cargando partidas: $err')),
          data: (matches) {
            if (matches.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No hay suficientes partidas registradas para calcular estadísticas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return _GroupStatisticsContent(
              groupId: groupId,
              group: group,
              members: members,
              matches: matches,
              currentUserId: currentUser?.id,
            );
          },
        );
      },
    );
  }
}

class _GroupStatisticsContent extends ConsumerStatefulWidget {
  const _GroupStatisticsContent({
    required this.groupId,
    this.group,
    required this.members,
    required this.matches,
    this.currentUserId,
  });

  final String groupId;
  final GroupModel? group;
  final List<GroupMemberModel> members;
  final List<MatchModel> matches;
  final String? currentUserId;

  @override
  ConsumerState<_GroupStatisticsContent> createState() => _GroupStatisticsContentState();
}

class _GroupStatisticsContentState extends ConsumerState<_GroupStatisticsContent> {
  bool _isLoadingResults = true;
  final Map<String, List<MatchResultModel>> _matchResultsMap = {};

  @override
  void initState() {
    super.initState();
    _loadAllMatchResults();
  }

  Future<void> _loadAllMatchResults() async {
    final repo = ref.read(matchesRepositoryProvider);
    final officialMatches = widget.matches.where((m) => m.isOfficial).toList();

    for (final match in officialMatches) {
      try {
        final results = await repo.fetchMatchResults(match.id);
        _matchResultsMap[match.id] = results;
      } catch (e) {
        debugPrint('Error cargando resultados de partida ${match.id}: $e');
      }
    }

    if (mounted) {
      setState(() => _isLoadingResults = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingResults) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.neonCyan),
            SizedBox(height: 16),
            Text(
              'PROCESANDO TELEMETRÍA DE LA LIGA...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5),
            ),
          ],
        ),
      );
    }

    // Filtrar admin de las estadísticas
    final activeMembers = widget.members.where((m) => m.userId != widget.currentUserId).toList();

    // Calcular estadísticas resumidas de la liga
    final totalMatches = widget.matches.length;
    final mostWinsMember = _getMostWinsMember(activeMembers);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoadingResults = true);
        ref.invalidate(groupMatchesProvider(widget.groupId));
        ref.invalidate(groupMembersProvider(widget.groupId));
        await _loadAllMatchResults();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETAS DE MÉTRICAS GLOBALES DE LA LIGA
            Row(
              children: [
                Expanded(
                  child: _StatOverviewCard(
                    title: 'PARTIDAS OFICIALES',
                    value: '$totalMatches',
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: AppColors.neonCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatOverviewCard(
                    title: 'MÁS VICTORIAS',
                    value: mostWinsMember != null ? '${mostWinsMember.totalWins} WINS' : '0',
                    subtitle: mostWinsMember?.displayName ?? 'N/A',
                    icon: HugeIcons.strokeRoundedChampion,
                    color: AppColors.neonOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // GRÁFICO DE EVOLUCIÓN TEMPORAL (PUNTOS Y POSICIONES)
            PointsEvolutionChart(
              members: activeMembers,
              matches: widget.matches,
              matchResultsMap: _matchResultsMap,
              currentUserId: widget.currentUserId,
            ),

            const SizedBox(height: 32),

            // GRÁFICO DE DISTRIBUCIÓN DE PODIOS (ORO, PLATA, BRONCE)
            PodiumDistributionChart(
              members: activeMembers,
              matchResultsMap: _matchResultsMap,
              currentUserId: widget.currentUserId,
            ),

            const SizedBox(height: 32),

            // DATOS CURIOSOS & RÉCORDS DE JUGADORES
            PlayerTriviaCards(
              members: activeMembers,
              matches: widget.matches,
              matchResultsMap: _matchResultsMap,
              currentUserId: widget.currentUserId,
            ),
          ],
        ),
      ),
    );
  }

  GroupMemberModel? _getMostWinsMember(List<GroupMemberModel> members) {
    if (members.isEmpty) return null;
    final sorted = List<GroupMemberModel>.from(members)
      ..sort((a, b) => b.totalWins.compareTo(a.totalWins));
    return sorted.first.totalWins > 0 ? sorted.first : null;
  }
}

class _StatOverviewCard extends StatelessWidget {
  const _StatOverviewCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final dynamic icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.rajdhani(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              HugeIcon(icon: icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.rajdhani(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
