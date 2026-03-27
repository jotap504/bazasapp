import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/core/widgets/points_detail_dialog.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/repositories/matches_repository.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bazas/features/scan/presentation/controllers/scan_controller.dart';

class GroupDashboardScreen extends ConsumerWidget {
  const GroupDashboardScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupByIdProvider(groupId));
    final rankingAsync = ref.watch(groupMembersProvider(groupId));
    final group = groupAsync.maybeWhen(data: (g) => g, orElse: () => null);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: groupAsync.when(
            data: (g) => Text(g.name.toUpperCase()),
            loading: () => const Text('CARGANDO...'),
            error: (_, __) => const Text('ERROR'),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.refresh(groupMembersProvider(groupId));
                ref.refresh(groupMatchesProvider(groupId));
              },
              icon: const Icon(Icons.refresh),
            ),
            groupAsync.when(
              data: (group) => IconButton(
                onPressed: () => context.push(AppRoutes.editGroup.replaceFirst(':groupId', group.id), extra: group),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01, color: Colors.white, size: 24),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            groupAsync.when(
              data: (group) => IconButton(
                onPressed: () => _showInviteDialog(context, group),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, color: Colors.white, size: 24),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            groupAsync.when(
              data: (group) {
                final user = ref.watch(currentUserProvider);
                if (group.createdBy != user?.id || group.status == 'closed') return const SizedBox();
                return IconButton(
                  onPressed: () => _confirmCloseGroup(context, ref, group),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedChampion, color: AppColors.neonOrange, size: 24),
                  tooltip: 'FINALIZAR TORNEO',
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.neonCyan,
            labelStyle: AppTextStyles.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            unselectedLabelStyle: AppTextStyles.rajdhani(),
            tabs: const [
              Tab(text: 'RANKING'),
              Tab(text: 'PARTIDAS'),
            ],
          ),
        ),
      body: Container(
        decoration: AppDecorations.background,
        child: TabBarView(
          children: [
            // PANEL 1: RANKING
            groupAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (group) => RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(groupMembersProvider(groupId));
                  return ref.refresh(groupMatchesProvider(groupId).future);
                },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: rankingAsync.when(
                          loading: () => const SizedBox(height: 200),
                          error: (_, __) => const SizedBox(),
                          data: (members) {
                            return const SizedBox();
                          },
                        ),
                      ),
                      rankingAsync.when(
                        loading: () => const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
                        data: (allMembers) {
                          if (allMembers.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(child: Text('Sin datos de competencia todavía.')),
                            );
                          }

                          // 0. Excluir al administrador (Jota) de toda la competencia UI
                          final currentUser = ref.watch(currentUserProvider);
                          final members = allMembers.where((m) => m.userId != currentUser?.id).toList();

                          if (members.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(child: Text('Sin datos de competencia todavía.')),
                            );
                          }

                          // 1. Preparar las 3 listas ordenadas de forma independiente
                          
                          // LISTA 🏆 PUNTOS
                          final pointsList = List<GroupMemberModel>.from(members);
                          pointsList.sort((a, b) => b.totalChampionshipPoints.compareTo(a.totalChampionshipPoints));

                          // LISTA 🎯 EFECTIVIDAD
                          // Obtenemos el grupo para saber la asistencia mínima
                          final totalLeagueMatches = group.matchCount ?? 0;
                          final minReq = totalLeagueMatches * ((group.minAttendancePct ?? 50) / 100.0);

                          final qualifiedEff = members.where((m) => m.totalMatchesPlayed >= minReq).toList();
                          qualifiedEff.sort((a, b) => b.effectiveAvgPercent.compareTo(a.effectiveAvgPercent));
                          
                          final unqualifiedEff = members.where((m) => m.totalMatchesPlayed < minReq).toList();
                          unqualifiedEff.sort((a, b) => b.totalMatchesPlayed.compareTo(a.totalMatchesPlayed));
                          
                          final effList = [...qualifiedEff, ...unqualifiedEff];

                          // LISTA ⚡ OSADIA
                          final osadiaList = List<GroupMemberModel>.from(members);
                          osadiaList.sort((a, b) => b.totalOsadiaPoints.compareTo(a.totalOsadiaPoints));

                          return SliverMainAxisGroup(
                            slivers: [
                              // HEADER DE RANKING Triple
                              SliverToBoxAdapter(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(width: 40, child: Text('POS', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                                      Expanded(child: _TripleHeaderCell(icon: HugeIcons.strokeRoundedChampion, label: 'PUNTOS', color: AppColors.neonCyan)),
                                      Expanded(child: _TripleHeaderCell(icon: HugeIcons.strokeRoundedTarget02, label: 'EFECT.', color: AppColors.neonGreen)),
                                      Expanded(child: _TripleHeaderCell(icon: HugeIcons.strokeRoundedZap, label: 'OSADÍA', color: AppColors.neonOrange)),
                                    ],
                                  ),
                                ),
                              ),

                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final pMem = index < pointsList.length ? pointsList[index] : null;
                                      final eMem = index < effList.length ? effList[index] : null;
                                      final oMem = index < osadiaList.length ? osadiaList[index] : null;

                                      bool isEQualified = true;
                                      if (eMem != null) {
                                        isEQualified = eMem.totalMatchesPlayed >= minReq;
                                      }

                                      return _TripleRankingRow(
                                        pos: index + 1,
                                        pMember: pMem,
                                        eMember: eMem,
                                        isEQualified: isEQualified,
                                        oMember: oMem,
                                      );
                                    },
                                    childCount: members.length,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(child: _HallOfFameSection(members: members)),
                              const SliverToBoxAdapter(child: SizedBox(height: 100)),
                            ],
                          );
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),

              // PANEL 2: PARTIDAS
              _MatchHistorySection(groupId: groupId, group: group),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: groupAsync.maybeWhen(
          data: (g) => g.status == 'closed' ? null : FloatingActionButton(
            onPressed: () => _startMatchRegistration(context, groupId),
            backgroundColor: AppColors.neonOrange,
            child: const Icon(Icons.add, color: Colors.black, size: 32),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
          orElse: () => null,
        ),
      ),
    );
  }

  Future<void> _startMatchRegistration(BuildContext context, String groupId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MatchRegistrationSheet(groupId: groupId),
    );
  }

  Future<void> _confirmCloseGroup(BuildContext context, WidgetRef ref, GroupModel group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿FINALIZAR TORNEO?'),
        content: const Text('Esto cerrará la liga permanentemente. No se podrán agregar más partidas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonOrange),
            child: const Text('FINALIZAR', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(groupsRepositoryProvider).closeGroup(group.id);
        ref.refresh(groupByIdProvider(group.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Torneo finalizado con éxito! 🏆')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showInviteDialog(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.neonCyan, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedTicket01, color: AppColors.neonCyan, size: 48),
            const SizedBox(height: 16),
            Text(
              'CÓDIGO DE INVITACIÓN',
              style: AppTextStyles.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                group.inviteCode?.toUpperCase() ?? 'N/A',
                style: AppTextStyles.rajdhani(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8.0,
                  color: AppColors.neonCyan,
                ),
              ),
            ).animate().shimmer(duration: 2000.ms),
            const SizedBox(height: 32),
            const Text(
              'Comparte este código con los otros jugadores para que se unan a la competencia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share API
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan),
                icon: const Icon(Icons.share, color: Colors.black, size: 20),
                label: const Text('COMPARTIR CÓDIGO', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MatchHistorySection extends ConsumerWidget {
  const _MatchHistorySection({required this.groupId, this.group});
  final String groupId;
  final GroupModel? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(groupMatchesProvider(groupId));

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('No hay partidas registradas aún.'));
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(groupMatchesProvider(groupId).future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length + 1,
            itemBuilder: (context, index) {
              if (index == matches.length) return const SizedBox(height: 100);
              return _MatchTile(match: matches[index], group: group);
            },
          ),
        );
      },
    );
  }
}

class _MatchTile extends ConsumerWidget {
  const _MatchTile({required this.match, this.group});
  final MatchModel match;
  final GroupModel? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(match.playedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        onTap: () => _showMatchResults(context, ref, match, group),
        onLongPress: () => _confirmDelete(context, ref, match),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: match.isOfficial ? AppColors.neonCyan.withOpacity(0.1) : AppColors.textMuted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            match.isOfficial ? Icons.verified : Icons.history,
            color: match.isOfficial ? AppColors.neonCyan : AppColors.textMuted,
          ),
        ),
        title: Text(
          dateStr,
          style: AppTextStyles.rajdhani(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${match.playersCount} JUGADORES • ${match.isOfficial ? "OFICIAL" : "RECREATIVA"}',
          style: AppTextStyles.inter(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (match.scoresheetImageUrl != null)
              IconButton(
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: AppColors.neonOrange, size: 20),
                onPressed: () => _viewScoresheet(context, match.scoresheetImageUrl!),
              ),
            IconButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedPencilEdit01, color: AppColors.neonCyan, size: 20),
              onPressed: () => _editMatch(context, match),
            ),
            IconButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: AppColors.error, size: 20),
              onPressed: () => _confirmDelete(context, ref, match),
            ),
          ],
        ),
      ),
    );
  }

  void _editMatch(BuildContext context, MatchModel match) {
    // Navegar a la pantalla de carga manual en modo edición usando la ruta correcta
    context.push(
      '${AppRoutes.scanManual}?groupId=${match.groupId}&date=${match.playedAt.toIso8601String()}&matchId=${match.id}',
    );
  }

  Future<void> _showMatchResults(BuildContext context, WidgetRef ref, MatchModel match, dynamic group) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('RESULTADOS: ${DateFormat('dd/MM/yyyy').format(match.playedAt)}', style: AppTextStyles.rajdhani(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<MatchResultModel>>(
            future: ref.read(matchesRepositoryProvider).fetchMatchResults(match.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              // 0. Excluir al administrador de los resultados individuales
              final currentUser = ref.watch(currentUserProvider);
              final results = (snapshot.data ?? []).where((r) => r.userId != currentUser?.id).toList();

              if (results.isEmpty) return const Text('No hay resultados grabados.');

              // Ordenar por puesto
              results.sort((a, b) => a.positionInMatch.compareTo(b.positionInMatch));

              return ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final r = results[i];
                  final name = r.profile?.nickname ?? r.profile?.displayName ?? 'Jugador';
                  final rounds = r.totalMatchRounds;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                      child: Text('${r.positionInMatch}', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(name.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('${(r.earnedChampionshipPoints + r.osadiaPoints).toInt()} PUNTOS', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    trailing: const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                    onTap: () {
                      PointsDetailDialog.show(
                        context,
                        playerName: name,
                        position: r.positionInMatch,
                        championshipPoints: r.earnedChampionshipPoints,
                        osadiaPoints: r.osadiaPoints,
                        accuracyPercent: r.accuracyPercent,
                        exactPredictions: r.exactPredictions,
                        totalRounds: rounds,
                        useOsadia: r.requestedBazas != null,
                        osadiaMultiplier: group.osadiaMultiplier,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, MatchModel match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿ELIMINAR PARTIDA?'),
        content: const Text('Esta acción quitará los puntos del ranking y es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(matchesRepositoryProvider).deleteMatch(match.id, match.groupId);
        // Refrescar ranking y partidas
        ref.refresh(groupMatchesProvider(match.groupId));
        ref.refresh(groupMembersProvider(match.groupId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Partida eliminada correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _viewScoresheet(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('Error cargando imagen'),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _TripleHeaderCell extends StatelessWidget {
  const _TripleHeaderCell({required this.icon, required this.label, required this.color});
  final dynamic icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HugeIcon(icon: icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.rajdhani(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _TripleRankingRow extends StatelessWidget {
  const _TripleRankingRow({
    required this.pos,
    this.pMember,
    this.eMember,
    required this.isEQualified,
    this.oMember,
  });

  final int pos;
  final GroupMemberModel? pMember;
  final GroupMemberModel? eMember;
  final bool isEQualified;
  final GroupMemberModel? oMember;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: Row(
        children: [
          // POSICIÓN
          SizedBox(
            width: 40,
            child: Text(
              '$pos',
              textAlign: TextAlign.center,
              style: AppTextStyles.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pos <= 3 ? AppColors.neonOrange : AppColors.textMuted,
              ),
            ),
          ),

          // PUNTOS
          Expanded(child: _RankCell(member: pMember, value: '${pMember?.totalChampionshipPoints.toInt() ?? 0}', color: AppColors.neonCyan)),
          
          // EFECTIVIDAD
          Expanded(
            child: _RankCell(
              member: eMember, 
              value: isEQualified ? '${eMember?.effectiveAvgPercent.toInt() ?? 0}%' : '-', 
              color: isEQualified ? AppColors.neonGreen : AppColors.textMuted,
              isQualified: isEQualified,
            ),
          ),

          // OSADIA
          Expanded(child: _RankCell(member: oMember, value: '${oMember?.totalOsadiaPoints.toInt() ?? 0}', color: AppColors.neonOrange)),
        ],
      ),
    );
  }
}

class _RankCell extends StatelessWidget {
  const _RankCell({this.member, required this.value, required this.color, this.isQualified = true});
  final GroupMemberModel? member;
  final String value;
  final Color color;
  final bool isQualified;

  @override
  Widget build(BuildContext context) {
    if (member == null) return const SizedBox();
    
    final name = member!.profile?.nickname ?? member!.profile?.displayName ?? member!.guestNickname ?? member!.guestFullName?.split(' ').first ?? 'Inv.';

    return Column(
      children: [
        Text(
          name,
          style: AppTextStyles.inter(
            fontSize: 13, 
            fontWeight: isQualified ? FontWeight.bold : FontWeight.normal,
            color: isQualified ? Colors.white : Colors.white38,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: AppTextStyles.rajdhani(
            fontSize: 11, 
            fontWeight: FontWeight.bold,
            color: color.withOpacity(isQualified ? 0.8 : 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MatchRegistrationSheet extends StatefulWidget {
  const _MatchRegistrationSheet({required this.groupId});
  final String groupId;

  @override
  State<_MatchRegistrationSheet> createState() => _MatchRegistrationSheetState();
}

class _MatchRegistrationSheetState extends State<_MatchRegistrationSheet> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'FECHA DE LA PARTIDA',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonOrange,
            onPrimary: Colors.black,
            surface: AppColors.surfaceElevated,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.neonOrange, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'REGISTRAR PARTIDA',
            style: AppTextStyles.rajdhani(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 32),
          
          // Selector de Fecha
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, color: AppColors.neonOrange, size: 24),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FECHA DE JUEGO', style: AppTextStyles.inter(fontSize: 10, color: AppColors.textMuted)),
                      Text(dateStr, style: AppTextStyles.rajdhani(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.edit, color: AppColors.textMuted, size: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Opciones de Origen
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  label: 'CÁMARA',
                  icon: HugeIcons.strokeRoundedCamera01,
                  color: AppColors.neonGreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      Uri(
                        path: AppRoutes.scanCamera,
                        queryParameters: {
                          'groupId': widget.groupId,
                          'date': _selectedDate.toIso8601String(),
                        },
                      ).toString(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) => _SourceButton(
                    label: 'GALERÍA',
                    icon: HugeIcons.strokeRoundedImage01,
                    color: AppColors.neonCyan,
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null && context.mounted) {
                        Navigator.pop(context);
                        ref.read(scanControllerProvider.notifier).setGroupId(widget.groupId);
                        ref.read(scanControllerProvider.notifier).setPlayedAt(_selectedDate);
                        ref.read(scanControllerProvider.notifier).setPickedImage(image);
                        context.push(AppRoutes.scanLoading);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  label: 'MANUAL',
                  icon: HugeIcons.strokeRoundedEdit02,
                  color: AppColors.neonOrange,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      Uri(
                        path: AppRoutes.scanManual,
                        queryParameters: {
                          'groupId': widget.groupId,
                          'date': _selectedDate.toIso8601String(),
                        },
                      ).toString(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.rajdhani(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HallOfFameSection extends StatelessWidget {
  const _HallOfFameSection({required this.members});
  final List<GroupMemberModel> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox();

    // 1. Asistencia Perfecta (Más partidas)
    final maxMatches = members.map((m) => m.totalMatchesPlayed).fold(0, (prev, curr) => curr > prev ? curr : prev);
    final mostPlayed = members.where((m) => m.totalMatchesPlayed == maxMatches && maxMatches > 0).toList();

    // 2. Puntería de Madera (Menos efectividad, min 3 partidas)
    final candidatesEff = members.where((m) => m.totalMatchesPlayed >= 3).toList();
    List<GroupMemberModel> leastAccurate = [];
    if (candidatesEff.isNotEmpty) {
      final minEff = candidatesEff.map((m) => m.effectiveAvgPercent).fold(100.0, (prev, curr) => curr < prev ? curr : prev);
      leastAccurate = candidatesEff.where((m) => m.effectiveAvgPercent == minEff).toList();
    }

    // 3. El Charlatán (Más osadías fallidas)
    final maxFailed = members.map((m) => m.totalFailedOsadia).fold(0, (prev, curr) => curr > prev ? curr : prev);
    final mostReckless = members.where((m) => m.totalFailedOsadia == maxFailed && maxFailed > 0).toList();

    // 4. El Chamullero (Más diferencia entre pedidas y ganadas)
    final maxChamullero = members.map((m) => m.totalChamulleroScore).fold(0, (prev, curr) => curr > prev ? curr : prev);
    final mostChamullero = members.where((m) => m.totalChamulleroScore == maxChamullero && maxChamullero > 0).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.white10)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('SALÓN DE LA FAMA (Y NO TANTO)', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
              Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
        ),
        
        _HofTile(
          title: 'ASISTENCIA PERFECTA',
          subtitle: 'Más partidas jugadas',
          icon: HugeIcons.strokeRoundedCalendar01,
          color: AppColors.neonCyan,
          winners: mostPlayed,
          stat: '$maxMatches partidas',
        ),
        
        if (leastAccurate.isNotEmpty)
          _HofTile(
            title: 'PUNTERÍA DE MADERA',
            subtitle: 'Menores aciertos (min. 3 partidas)',
            icon: HugeIcons.strokeRoundedTarget02,
            color: Colors.brown.shade300,
            winners: leastAccurate,
            stat: '${leastAccurate.first.effectiveAvgPercent.toInt()}% efec.',
          ),

        _HofTile(
          title: 'EL CHARLATÁN',
          subtitle: 'Más osadías pedidas y NO cumplidas',
          icon: HugeIcons.strokeRoundedMic01,
          color: AppColors.neonOrange,
          winners: mostReckless,
          stat: '$maxFailed fallidas',
        ),

        _HofTile(
          title: 'EL CHAMULLERO',
          subtitle: 'Vive del aire (pide y no gana)',
          icon: HugeIcons.strokeRoundedAiBrain01,
          color: Colors.blueGrey.shade300,
          winners: mostChamullero,
          stat: '$maxChamullero bazas',
        ),
      ],
    );
  }
}

class _HofTile extends StatelessWidget {
  const _HofTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.winners,
    required this.stat,
  });

  final String title;
  final String subtitle;
  final dynamic icon;
  final Color color;
  final List<GroupMemberModel> winners;
  final String stat;

  @override
  Widget build(BuildContext context) {
    if (winners.isEmpty) return const SizedBox();

    final names = winners.map((m) => m.profile?.nickname ?? m.profile?.displayName ?? m.guestNickname ?? m.guestFullName?.split(' ').first ?? 'Inv.').join(', ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: HugeIcon(icon: icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.rajdhani(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(names, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(stat, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
