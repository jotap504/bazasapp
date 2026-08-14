import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

enum EvolutionMetric { points, ranking }

class PointsEvolutionChart extends StatefulWidget {
  const PointsEvolutionChart({
    super.key,
    required this.members,
    required this.matches,
    required this.matchResultsMap,
    this.currentUserId,
    this.onPlayerTap,
  });

  final List<GroupMemberModel> members;
  final List<MatchModel> matches;

  /// Mapa de match_id -> lista de MatchResultModel
  final Map<String, List<MatchResultModel>> matchResultsMap;
  final String? currentUserId;
  final void Function(GroupMemberModel)? onPlayerTap;

  @override
  State<PointsEvolutionChart> createState() => _PointsEvolutionChartState();
}

class _PointsEvolutionChartState extends State<PointsEvolutionChart> {
  EvolutionMetric _selectedMetric = EvolutionMetric.points;

  /// IDs de los miembros visibles/seleccionados para filtrar en el gráfico
  final Set<String> _hiddenMemberIds = {};

  /// Paleta de colores neón coordinada para jugadores
  static const List<Color> _neonPalette = [
    AppColors.neonCyan,
    AppColors.neonOrange,
    AppColors.neonGreen,
    Color(0xFFFF007F), // Neon Pink
    Color(0xFFFFD700), // Gold
    Color(0xFF9D4EDD), // Electric Purple
    Color(0xFF00F5D4), // Teal
    Color(0xFFFF5722), // Crimson
    Color(0xFF7000FF), // Deep Violet
    Color(0xFFFF9E00), // Amber
  ];

  Color _getMemberColor(int index) {
    return _neonPalette[index % _neonPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty || widget.members.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text(
          'Se necesitan al menos 2 partidas para mostrar la evolución.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    // Filtrar al admin de la gráfica
    final activeMembers = widget.members.where((m) => m.userId != widget.currentUserId).toList();

    // Ordenar partidas por fecha ascendente para la serie temporal
    final sortedMatches = List<MatchModel>.from(widget.matches)
      ..sort((a, b) => a.playedAt.compareTo(b.playedAt));

    // Construir la serie de datos acumulada por jugador
    final playerSeries = _computePlayerSeries(activeMembers, sortedMatches);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CONTROLES DE MÉTRICA (PUNTOS VS POSICIÓN)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EVOLUCIÓN EN EL TIEMPO',
              style: AppTextStyles.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  _MetricToggleButton(
                    label: 'PUNTOS',
                    isSelected: _selectedMetric == EvolutionMetric.points,
                    color: AppColors.neonCyan,
                    onTap: () => setState(() => _selectedMetric = EvolutionMetric.points),
                  ),
                  _MetricToggleButton(
                    label: 'RANKING',
                    isSelected: _selectedMetric == EvolutionMetric.ranking,
                    color: AppColors.neonOrange,
                    onTap: () => setState(() => _selectedMetric = EvolutionMetric.ranking),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // GRÁFICO PRINCIPAL
        Container(
          height: 260,
          padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: LineChart(
            _buildChartData(activeMembers, sortedMatches, playerSeries),
          ),
        ),

        const SizedBox(height: 12),

        // LEYENDA INTERACTIVA DE JUGADORES
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(activeMembers.length, (index) {
            final member = activeMembers[index];
            final isHidden = _hiddenMemberIds.contains(member.id);
            final color = _getMemberColor(index);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isHidden) {
                    _hiddenMemberIds.remove(member.id);
                  } else {
                    // Permitir ocultar, manteniendo al menos uno visible
                    if (_hiddenMemberIds.length < activeMembers.length - 1) {
                      _hiddenMemberIds.add(member.id);
                    }
                  }
                });
              },
              onLongPress: () => widget.onPlayerTap?.call(member),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHidden ? Colors.transparent : color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHidden ? Colors.white10 : color.withOpacity(0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHidden ? Colors.white24 : color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member.shortName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isHidden ? AppColors.textMuted : Colors.white,
                        decoration: isHidden ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Calcula para cada jugador una lista de FlSpot(x: index_partida, y: puntos_o_posicion)
  Map<String, List<FlSpot>> _computePlayerSeries(
    List<GroupMemberModel> members,
    List<MatchModel> sortedMatches,
  ) {
    final Map<String, List<FlSpot>> series = {};
    final Map<String, double> accumPoints = {};
    
    // Mapeo user_id / guest_member_id -> member.id
    final Map<String, String> memberIdLookup = {};
    for (final m in members) {
      if (m.userId != null) memberIdLookup[m.userId!] = m.id;
      memberIdLookup[m.id] = m.id;
      accumPoints[m.id] = 0.0;
      series[m.id] = [];
    }

    if (_selectedMetric == EvolutionMetric.points) {
      // 1. PUNTOS ACUMULADOS
      for (int i = 0; i < sortedMatches.length; i++) {
        final match = sortedMatches[i];
        final results = widget.matchResultsMap[match.id] ?? [];

        for (final res in results) {
          final targetId = (res.userId != null ? memberIdLookup[res.userId] : null) ?? res.guestMemberId;
          if (targetId != null && accumPoints.containsKey(targetId)) {
            accumPoints[targetId] = (accumPoints[targetId] ?? 0.0) + res.earnedChampionshipPoints;
          }
        }

        // Agregar punto para cada miembro en el step i
        for (final m in members) {
          final currentTotal = accumPoints[m.id] ?? 0.0;
          series[m.id]?.add(FlSpot(i.toDouble(), currentTotal));
        }
      }
    } else {
      // 2. POSICIÓN ACUMULADA EN CADA FECHA (Evolución de puestos)
      // Recalcular tabla acumulada en cada fecha para saber el puesto relativo
      for (int i = 0; i < sortedMatches.length; i++) {
        final match = sortedMatches[i];
        final results = widget.matchResultsMap[match.id] ?? [];

        for (final res in results) {
          final targetId = (res.userId != null ? memberIdLookup[res.userId] : null) ?? res.guestMemberId;
          if (targetId != null && accumPoints.containsKey(targetId)) {
            accumPoints[targetId] = (accumPoints[targetId] ?? 0.0) + res.earnedChampionshipPoints;
          }
        }

        // Ordenar miembros por puntos acumulados en la fecha i para calcular su posición
        final currentRanking = List<GroupMemberModel>.from(members);
        currentRanking.sort((a, b) => (accumPoints[b.id] ?? 0.0).compareTo(accumPoints[a.id] ?? 0.0));

        for (int rank = 0; rank < currentRanking.length; rank++) {
          final mId = currentRanking[rank].id;
          // Puesto #1 arriba = valor mayor (members.length - rank)
          series[mId]?.add(FlSpot(i.toDouble(), (members.length - rank).toDouble()));
        }
      }
    }

    return series;
  }

  LineChartData _buildChartData(
    List<GroupMemberModel> members,
    List<MatchModel> sortedMatches,
    Map<String, List<FlSpot>> series,
  ) {
    final lineBarsData = <LineChartBarData>[];

    for (int idx = 0; idx < members.length; idx++) {
      final member = members[idx];
      if (_hiddenMemberIds.contains(member.id)) continue;

      final spots = series[member.id] ?? [];
      final color = _getMemberColor(idx);

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 15,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 1.5,
                strokeColor: AppColors.surfaceElevated,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.04),
          ),
        ),
      );
    }

    // Determinar límites de Y
    double minY = 0;
    double maxY = 100;

    if (_selectedMetric == EvolutionMetric.points) {
      double maxP = 0;
      for (final sList in series.values) {
        for (final spot in sList) {
          if (spot.y > maxP) maxP = spot.y;
        }
      }
      maxY = (maxP * 1.15).clamp(20.0, 1000.0);
    } else {
      minY = 1;
      maxY = members.length.toDouble().clamp(1.0, 20.0);
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _selectedMetric == EvolutionMetric.points ? 36 : 28,
            getTitlesWidget: (value, meta) {
              if (_selectedMetric == EvolutionMetric.ranking) {
                final displayRank = (members.length - value + 1).toInt();
                if (displayRank >= 1 && displayRank <= members.length && value % 1 == 0) {
                  return Text(
                    '#$displayRank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: displayRank == 1 ? AppColors.neonOrange : AppColors.textMuted,
                    ),
                  );
                }
                return const SizedBox();
              } else {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                );
              }
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < sortedMatches.length) {
                // Mostrar solo algunas fechas para evitar encimamiento
                final step = (sortedMatches.length / 5).ceil().clamp(1, 10);
                if (idx % step == 0 || idx == sortedMatches.length - 1) {
                  final dt = sortedMatches[idx].playedAt;
                  return Text(
                    DateFormat('dd/MM').format(dt),
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (sortedMatches.length - 1).toDouble().clamp(0.0, 100.0),
      minY: minY,
      maxY: maxY,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.surfaceElevated,
          tooltipRoundedRadius: 12,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final barIndex = spot.barIndex;
              final visibleMembers = members.where((m) => !_hiddenMemberIds.contains(m.id)).toList();
              final member = barIndex < visibleMembers.length ? visibleMembers[barIndex] : null;

              if (member == null) return null;

              final actualRank = (members.length - spot.y + 1).toInt();
              final valStr = _selectedMetric == EvolutionMetric.points
                  ? '${spot.y.toInt()} Pts'
                  : 'Puesto #$actualRank';

              return LineTooltipItem(
                '${member.displayName}: $valStr',
                TextStyle(
                  color: _getMemberColor(members.indexOf(member)),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: lineBarsData,
    );
  }
}

class _MetricToggleButton extends StatelessWidget {
  const _MetricToggleButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.rajdhani(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isSelected ? Colors.black : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
