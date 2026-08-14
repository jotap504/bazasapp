import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

class PlayerHistorySheet extends StatelessWidget {
  const PlayerHistorySheet({
    super.key,
    required this.member,
    required this.matches,
    required this.matchResultsMap,
  });

  final GroupMemberModel member;
  final List<MatchModel> matches;
  final Map<String, List<MatchResultModel>> matchResultsMap;

  static void show(
    BuildContext context, {
    required GroupMemberModel member,
    required List<MatchModel> matches,
    required Map<String, List<MatchResultModel>> matchResultsMap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return PlayerHistorySheet(
            member: member,
            matches: matches,
            matchResultsMap: matchResultsMap,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Buscar los resultados del jugador en todas las partidas
    final List<_PlayerMatchRecord> history = [];
    int totalExactPredictions = 0;
    int totalFailedRounds = 0;
    int totalPodiums = 0;

    // Ordenar partidas cronológicamente descendente
    final sortedMatches = List<MatchModel>.from(matches)
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

    for (final match in sortedMatches) {
      final results = matchResultsMap[match.id] ?? [];
      for (final res in results) {
        final matchesUser = (res.userId != null && res.userId == member.userId);
        final matchesGuest = (res.guestMemberId != null && res.guestMemberId == member.id);

        if (matchesUser || matchesGuest) {
          final exact = res.exactPredictions;
          final rounds = res.totalMatchRounds;
          final failed = (rounds - exact).clamp(0, 100);

          totalExactPredictions += exact;
          totalFailedRounds += failed;
          if (res.positionInMatch <= 3) totalPodiums++;

          history.add(_PlayerMatchRecord(
            match: match,
            result: res,
            exact: exact,
            failed: failed,
          ));
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.neonCyan, width: 2)),
      ),
      child: Column(
        children: [
          // INDICADOR DE ARRASTRE
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ENCABEZADO CON NOMBRE Y AVATAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonCyan, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                    child: Text(
                      member.shortName.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.rajdhani(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName.toUpperCase(),
                        style: AppTextStyles.rajdhani(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'FICHA TÉCNICA Y RENDIMIENTO',
                        style: AppTextStyles.inter(
                          fontSize: 10,
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // TARJETAS DE RESUMEN DE ACIERTOS VS FALLOS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _MiniSummaryCard(
                    title: 'ACERTADAS',
                    value: '$totalExactPredictions',
                    subtitle: 'Bazas/Rondas ok',
                    icon: HugeIcons.strokeRoundedTarget02,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniSummaryCard(
                    title: 'FALLADAS',
                    value: '$totalFailedRounds',
                    subtitle: 'Bazas/Rondas erradas',
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.neonOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniSummaryCard(
                    title: 'PODIOS',
                    value: '$totalPodiums',
                    subtitle: 'Top 3 alcanzados',
                    icon: HugeIcons.strokeRoundedChampion,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HISTORIAL FECHA POR FECHA (${history.length})',
                  style: AppTextStyles.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'EFECT. PROM: ${member.effectiveAvgPercent.toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),

          // LISTADO DESGLOSADO DE PARTIDAS
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Sin registro de partidas para este jugador.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final dateStr = DateFormat('dd/MM/yyyy').format(item.match.playedAt);
                      final isWinner = item.result.positionInMatch == 1;

                      Color posColor = AppColors.textMuted;
                      if (item.result.positionInMatch == 1) posColor = const Color(0xFFFFD700);
                      else if (item.result.positionInMatch == 2) posColor = const Color(0xFFC0C0C0);
                      else if (item.result.positionInMatch == 3) posColor = const Color(0xFFCD7F32);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWinner ? AppColors.neonOrange.withOpacity(0.4) : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            // INSIGNIA DE PUESTO
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: posColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: posColor.withOpacity(0.5)),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.result.positionInMatch}º',
                                  style: TextStyle(
                                    color: posColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // DETALLES FECHA Y PUNTOS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dateStr,
                                        style: AppTextStyles.rajdhani(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.neonCyan.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${(item.result.earnedChampionshipPoints + item.result.osadiaPoints).toInt()} Pts',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.neonCyan,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 13, color: AppColors.neonGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.exact} acertadas',
                                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.highlight_off, size: 13, color: AppColors.neonOrange),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.failed} falladas',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // PORCENTAJE DE EFECTIVIDAD DE LA FECHA
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.result.accuracyPercent.toInt()}%',
                                  style: AppTextStyles.rajdhani(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neonGreen,
                                  ),
                                ),
                                Text(
                                  '${item.result.exactPredictions}/${item.result.totalMatchRounds} rondas',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMatchRecord {
  _PlayerMatchRecord({
    required this.match,
    required this.result,
    required this.exact,
    required this.failed,
  });

  final MatchModel match;
  final MatchResultModel result;
  final int exact;
  final int failed;
}

class _MiniSummaryCard extends StatelessWidget {
  const _MiniSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final dynamic icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
              HugeIcon(icon: icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
