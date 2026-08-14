import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

class PodiumDistributionChart extends StatelessWidget {
  const PodiumDistributionChart({
    super.key,
    required this.members,
    required this.matchResultsMap,
    this.currentUserId,
  });

  final List<GroupMemberModel> members;
  final Map<String, List<MatchResultModel>> matchResultsMap;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    // Excluir al administrador de los datos
    final activeMembers = members.where((m) => m.userId != currentUserId).toList();

    if (activeMembers.isEmpty || matchResultsMap.isEmpty) {
      return const SizedBox();
    }

    // Mapear podios por jugador: member.id -> { 1: count, 2: count, 3: count }
    final Map<String, Map<int, int>> podiumCounts = {};
    for (final m in activeMembers) {
      podiumCounts[m.id] = {1: 0, 2: 0, 3: 0};
    }

    // Lookup table
    final Map<String, String> userToMemberMap = {};
    for (final m in activeMembers) {
      if (m.userId != null) userToMemberMap[m.userId!] = m.id;
      userToMemberMap[m.id] = m.id;
    }

    // Contar 1º, 2º y 3º puestos
    for (final results in matchResultsMap.values) {
      for (final res in results) {
        final pos = res.positionInMatch;
        if (pos >= 1 && pos <= 3) {
          final targetId = (res.userId != null ? userToMemberMap[res.userId] : null) ?? res.guestMemberId;
          if (targetId != null && podiumCounts.containsKey(targetId)) {
            podiumCounts[targetId]![pos] = (podiumCounts[targetId]![pos] ?? 0) + 1;
          }
        }
      }
    }

    // Ordenar jugadores por número total de podios descendente
    final sortedMembers = List<GroupMemberModel>.from(activeMembers)
      ..sort((a, b) {
        final totalA = (podiumCounts[a.id]?[1] ?? 0) * 3 + (podiumCounts[a.id]?[2] ?? 0) * 2 + (podiumCounts[a.id]?[3] ?? 0);
        final totalB = (podiumCounts[b.id]?[1] ?? 0) * 3 + (podiumCounts[b.id]?[2] ?? 0) * 2 + (podiumCounts[b.id]?[3] ?? 0);
        return totalB.compareTo(totalA);
      });

    // Calcular máximo para escala de Y
    int maxPodiums = 1;
    for (final counts in podiumCounts.values) {
      final total = (counts[1] ?? 0) + (counts[2] ?? 0) + (counts[3] ?? 0);
      if (total > maxPodiums) maxPodiums = total;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DISTRIBUCIÓN DE PODIOS',
              style: AppTextStyles.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            const Row(
              children: [
                _PodiumLegendDot(color: Color(0xFFFFD700), label: '1º'),
                SizedBox(width: 8),
                _PodiumLegendDot(color: Color(0xFFC0C0C0), label: '2º'),
                SizedBox(width: 8),
                _PodiumLegendDot(color: Color(0xFFCD7F32), label: '3º'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxPodiums * 1.2).clamp(3.0, 50.0),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceElevated,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final member = sortedMembers[groupIndex];
                    final p1 = podiumCounts[member.id]?[1] ?? 0;
                    final p2 = podiumCounts[member.id]?[2] ?? 0;
                    final p3 = podiumCounts[member.id]?[3] ?? 0;
                    return BarTooltipItem(
                      '${member.displayName}\n🥇 $p1 | 🥈 $p2 | 🥉 $p3',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < sortedMembers.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            sortedMembers[idx].shortName,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(sortedMembers.length, (index) {
                final m = sortedMembers[index];
                final p1 = (podiumCounts[m.id]?[1] ?? 0).toDouble();
                final p2 = (podiumCounts[m.id]?[2] ?? 0).toDouble();
                final p3 = (podiumCounts[m.id]?[3] ?? 0).toDouble();

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: p1 + p2 + p3,
                      color: Colors.transparent,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                      rodStackItems: [
                        BarChartRodStackItem(0, p1, const Color(0xFFFFD700)),
                        BarChartRodStackItem(p1, p1 + p2, const Color(0xFFC0C0C0)),
                        BarChartRodStackItem(p1 + p2, p1 + p2 + p3, const Color(0xFFCD7F32)),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumLegendDot extends StatelessWidget {
  const _PodiumLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
