import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

class PlayerTriviaCards extends StatelessWidget {
  const PlayerTriviaCards({
    super.key,
    required this.members,
    required this.matches,
    required this.matchResultsMap,
    this.currentUserId,
    this.onPlayerTap,
  });

  final List<GroupMemberModel> members;
  final List<MatchModel> matches;
  final Map<String, List<MatchResultModel>> matchResultsMap;
  final String? currentUserId;
  final void Function(GroupMemberModel)? onPlayerTap;

  @override
  Widget build(BuildContext context) {
    // Excluir al admin de la trivia
    final activeMembers = members.where((m) => m.userId != currentUserId).toList();

    if (activeMembers.isEmpty || matches.isEmpty) {
      return const SizedBox();
    }

    final triviaList = _calculateTriviaList(activeMembers, matches, matchResultsMap, onPlayerTap);

    if (triviaList.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.white10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'DATOS CURIOSOS & RÉCORDS DE LA LIGA',
                  style: AppTextStyles.rajdhani(
                    color: AppColors.neonOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: triviaList.length,
          itemBuilder: (context, index) {
            final trivia = triviaList[index];
            return _TriviaTile(trivia: trivia, onTap: trivia.onTap)
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 60).ms)
                .slideX(begin: 0.05, end: 0);
          },
        ),
      ],
    );
  }

  List<_TriviaData> _calculateTriviaList(
    List<GroupMemberModel> activeMembers,
    List<MatchModel> matches,
    Map<String, List<MatchResultModel>> matchResultsMap,
    void Function(GroupMemberModel)? onPlayerTap,
  ) {
    final List<_TriviaData> list = [];

    // Mapeo user_id / guest_member_id -> member.id
    final Map<String, GroupMemberModel> memberMap = {};
    for (final m in activeMembers) {
      if (m.userId != null) memberMap[m.userId!] = m;
      memberMap[m.id] = m;
    }

    // 1. 👑 EL REY DEL PODIO (Más veces en 1º, 2º o 3º puesto)
    final Map<String, int> podiumCount = {};
    for (final results in matchResultsMap.values) {
      for (final r in results) {
        if (r.positionInMatch <= 3) {
          final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
          if (target != null) {
            podiumCount[target.id] = (podiumCount[target.id] ?? 0) + 1;
          }
        }
      }
    }
    if (podiumCount.isNotEmpty) {
      final maxP = podiumCount.values.reduce((a, b) => a > b ? a : b);
      final winners = activeMembers.where((m) => podiumCount[m.id] == maxP).toList();
      if (winners.isNotEmpty && maxP > 0) {
        list.add(_TriviaData(
          title: 'EL REY DEL PODIO',
          subtitle: 'Más veces finalizando en el Top 3 de las partidas',
          players: winners.map((w) => w.displayName).toList(),
          highlightValue: '$maxP podios',
          icon: HugeIcons.strokeRoundedChampion,
          color: const Color(0xFFFFD700), // Gold
          onTap: onPlayerTap != null ? () => onPlayerTap(winners.first) : null,
        ));
      }
    }

    // 2. 🎯 EL FRANCOTIRADOR (Partida perfecta o mayor efectividad en una fecha)
    MatchResultModel? bestSinglePerf;
    GroupMemberModel? bestSniperPlayer;

    for (final results in matchResultsMap.values) {
      for (final r in results) {
        if (r.accuracyPercent >= 99.9) {
          final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
          if (target != null) {
            if (bestSinglePerf == null || r.totalMatchRounds > bestSinglePerf.totalMatchRounds) {
              bestSinglePerf = r;
              bestSniperPlayer = target;
            }
          }
        }
      }
    }
    if (bestSniperPlayer != null && bestSinglePerf != null) {
      final sniperRef = bestSniperPlayer!;
      list.add(_TriviaData(
        title: 'EL FRANCOTIRADOR',
        subtitle: '100% de efectividad exacta en una partida de ${bestSinglePerf.totalMatchRounds} rondas',
        players: [sniperRef.displayName],
        highlightValue: '100% acierto',
        icon: HugeIcons.strokeRoundedTarget02,
        color: AppColors.neonCyan,
        onTap: onPlayerTap != null ? () => onPlayerTap(sniperRef) : null,
      ));
    }

    // 3. 🔥 EL REY DE LA OSADÍA (Más puntos acumulados por arriesgar bazas)
    if (activeMembers.isNotEmpty) {
      final sortedByOsadia = List<GroupMemberModel>.from(activeMembers)
        ..sort((a, b) => b.totalOsadiaPoints.compareTo(a.totalOsadiaPoints));
      final topOsadia = sortedByOsadia.first;
      if (topOsadia.totalOsadiaPoints > 0) {
        list.add(_TriviaData(
          title: 'REYS DE LA OSADÍA',
          subtitle: 'Jugador que más puntos ha ganado apostando y arriesgando bazas',
          players: [topOsadia.displayName],
          highlightValue: '${topOsadia.totalOsadiaPoints.toInt()} pts osadía',
          icon: HugeIcons.strokeRoundedZap,
          color: AppColors.neonOrange,
          onTap: onPlayerTap != null ? () => onPlayerTap(topOsadia) : null,
        ));
      }
    }

    // 4. ⚡ RACHA DE FUEGO (Mayor racha de partidas consecutivas en el podio)
    final sortedMatches = List<MatchModel>.from(matches)
      ..sort((a, b) => a.playedAt.compareTo(b.playedAt));

    Map<String, int> maxStreak = {};
    Map<String, int> currentStreak = {};
    for (final m in activeMembers) {
      maxStreak[m.id] = 0;
      currentStreak[m.id] = 0;
    }

    for (final match in sortedMatches) {
      final results = matchResultsMap[match.id] ?? [];
      final Set<String> matchPodiumMembers = {};

      for (final r in results) {
        if (r.positionInMatch <= 3) {
          final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
          if (target != null) matchPodiumMembers.add(target.id);
        }
      }

      for (final m in activeMembers) {
        if (matchPodiumMembers.contains(m.id)) {
          currentStreak[m.id] = (currentStreak[m.id] ?? 0) + 1;
          if ((currentStreak[m.id] ?? 0) > (maxStreak[m.id] ?? 0)) {
            maxStreak[m.id] = currentStreak[m.id]!;
          }
        } else {
          currentStreak[m.id] = 0;
        }
      }
    }

    if (maxStreak.isNotEmpty) {
      final maxS = maxStreak.values.reduce((a, b) => a > b ? a : b);
      final winnersStreak = activeMembers.where((m) => maxStreak[m.id] == maxS).toList();
      if (winnersStreak.isNotEmpty && maxS >= 2) {
        list.add(_TriviaData(
          title: 'RACHA DE FUEGO',
          subtitle: 'Mayor cantidad de partidas consecutivas terminando en el Podio',
          players: winnersStreak.map((w) => w.displayName).toList(),
          highlightValue: '$maxS fechas seguidas',
          icon: HugeIcons.strokeRoundedFlash,
          color: const Color(0xFFFF007F), // Neon Pink
        ));
      }
    }

    // 5. 🧱 EL MURO DE PIEDRA (Mayor regularidad - menor promedio de posición)
    final Map<String, List<int>> playerPositions = {};
    for (final results in matchResultsMap.values) {
      for (final r in results) {
        final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
        if (target != null) {
          playerPositions.putIfAbsent(target.id, () => []).add(r.positionInMatch);
        }
      }
    }

    GroupMemberModel? regularPlayer;
    double minAvgPos = 99.0;

    playerPositions.forEach((mId, posList) {
      if (posList.length >= 2) {
        final avg = posList.reduce((a, b) => a + b) / posList.length.toDouble();
        if (avg < minAvgPos) {
          minAvgPos = avg;
          regularPlayer = memberMap[mId];
        }
      }
    });

    if (regularPlayer != null) {
      list.add(_TriviaData(
        title: 'EL MURO DE PIEDRA (REGULARIDAD)',
        subtitle: 'Promedio de puesto más alto a lo largo de las fechas disputadas',
        players: [regularPlayer!.displayName],
        highlightValue: 'Promedió Puesto #${minAvgPos.toStringAsFixed(1)}',
        icon: HugeIcons.strokeRoundedShield01,
        color: AppColors.neonGreen,
      ));
    }

    // 6. 🔴 EL FAROL ROJO (Más veces en el último puesto)
    final Map<String, int> lastCounts = {};
    for (final results in matchResultsMap.values) {
      final totalPlayersInMatch = results.length;
      for (final r in results) {
        if (r.positionInMatch == totalPlayersInMatch) {
          final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
          if (target != null) {
            lastCounts[target.id] = (lastCounts[target.id] ?? 0) + 1;
          }
        }
      }
    }
    if (lastCounts.isNotEmpty) {
      final maxLast = lastCounts.values.reduce((a, b) => a > b ? a : b);
      final worstPlayers = activeMembers.where((m) => lastCounts[m.id] == maxLast).toList();
      if (worstPlayers.isNotEmpty && maxLast > 0) {
        list.add(_TriviaData(
          title: 'EL FAROL ROJO',
          subtitle: 'Jugador que más veces terminó en la última posición de una partida',
          players: worstPlayers.map((w) => w.displayName).toList(),
          highlightValue: '$maxLast veces último',
          icon: HugeIcons.strokeRoundedAlertCircle,
          color: Colors.redAccent,
        ));
      }
    }

    // 7. 🔻 ZONA DE DESCENSO (Más veces en los últimos 3 puestos)
    final Map<String, int> bottom3Counts = {};
    for (final results in matchResultsMap.values) {
      final totalPlayersInMatch = results.length;
      for (final r in results) {
        if (r.positionInMatch > totalPlayersInMatch - 3) {
          final target = (r.userId != null ? memberMap[r.userId] : null) ?? memberMap[r.guestMemberId];
          if (target != null) {
            bottom3Counts[target.id] = (bottom3Counts[target.id] ?? 0) + 1;
          }
        }
      }
    }
    if (bottom3Counts.isNotEmpty) {
      final maxBottom3 = bottom3Counts.values.reduce((a, b) => a > b ? a : b);
      final bottom3Players = activeMembers.where((m) => bottom3Counts[m.id] == maxBottom3).toList();
      if (bottom3Players.isNotEmpty && maxBottom3 > 0) {
        list.add(_TriviaData(
          title: 'ZONA DE DESCENSO',
          subtitle: 'Jugador con más caídas en los últimos 3 puestos de las partidas',
          players: bottom3Players.map((w) => w.displayName).toList(),
          highlightValue: '$maxBottom3 veces en el fondo',
          icon: HugeIcons.strokeRoundedArrowDown01,
          color: Colors.orangeAccent,
        ));
      }
    }

    // 8. ⚔️ LA FECHA MÁS REÑIDA (Partida con menor diferencia entre 1º y último puesto)
    double minGap = 999.0;
    MatchModel? closestMatch;

    for (final match in sortedMatches) {
      final results = matchResultsMap[match.id] ?? [];
      if (results.length >= 4) {
        final sortedR = List<MatchResultModel>.from(results)
          ..sort((a, b) => a.positionInMatch.compareTo(b.positionInMatch));

        final p1Points = sortedR.first.earnedChampionshipPoints + sortedR.first.osadiaPoints;
        final pLastPoints = sortedR.last.earnedChampionshipPoints + sortedR.last.osadiaPoints;
        final gap = (p1Points - pLastPoints).abs();

        if (gap < minGap) {
          minGap = gap;
          closestMatch = match;
        }
      }
    }

    if (closestMatch != null) {
      final dateStr = DateFormat('dd/MM/yyyy').format(closestMatch.playedAt);
      list.add(_TriviaData(
        title: 'LA FECHA MÁS REÑIDA',
        subtitle: 'Partida donde la diferencia de puntos entre el 1º y último puesto fue mínima',
        players: ['Fecha $dateStr (${closestMatch.playersCount} jugadores)'],
        highlightValue: '${minGap.toInt()} pts dif.',
        icon: HugeIcons.strokeRoundedTarget02,
        color: Colors.purpleAccent,
      ));
    }

    return list;
  }
}

class _TriviaData {
  _TriviaData({
    required this.title,
    required this.subtitle,
    required this.players,
    required this.highlightValue,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<String> players;
  final String highlightValue;
  final dynamic icon;
  final Color color;
  final VoidCallback? onTap;
}

class _TriviaTile extends StatelessWidget {
  const _TriviaTile({required this.trivia, this.onTap});
  final _TriviaData trivia;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final namesStr = trivia.players.join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: trivia.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: trivia.color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: trivia.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: trivia.icon, color: trivia.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trivia.title,
                    style: AppTextStyles.rajdhani(
                      color: trivia.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    namesStr,
                    style: AppTextStyles.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trivia.subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: trivia.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: trivia.color.withOpacity(0.4)),
                  ),
                  child: Text(
                    trivia.highlightValue,
                    style: TextStyle(
                      color: trivia.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('👆 Ver ficha', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
