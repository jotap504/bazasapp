import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/matches/data/repositories/matches_repository.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/core/widgets/points_detail_dialog.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

class ManualRegistrationScreen extends ConsumerStatefulWidget {
  const ManualRegistrationScreen({
    super.key,
    required this.groupId,
    required this.playedAt,
    this.matchId,
  });

  final String groupId;
  final DateTime playedAt;
  final String? matchId;

  @override
  ConsumerState<ManualRegistrationScreen> createState() => _ManualRegistrationScreenState();
}

class _ManualRegistrationScreenState extends ConsumerState<ManualRegistrationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Paso 0: Config Global
  int _totalRounds = 10;
  bool _useOsadia = true;

  // Paso 1: Resultados
  final List<Map<String, dynamic>> _playerResults = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final allMembers = await ref.read(groupsRepositoryProvider).fetchGroupMembers(widget.groupId);
    final user = ref.read(currentUserProvider);
    
    // Excluir al administrador (Jota) de la lista de selección, según lo solicitado
    final members = allMembers.where((m) => m.userId != user?.id).toList();
    
    List<MatchResultModel> existingResults = [];
    if (widget.matchId != null) {
      existingResults = await ref.read(matchesRepositoryProvider).fetchMatchResults(widget.matchId!);
      // Cargar config global de la partida si se puede (ej. total rounds)
      final match = await ref.read(matchesRepositoryProvider).fetchMatchById(widget.matchId!);
      if (mounted) {
        setState(() {
          _totalRounds = match.playersCount; // O sacar de notes si lo guardamos ahí
          // Fallback: si guardamos rounds en notes "Carga manual - X rondas", podemos parsear
          if (match.notes != null && match.notes!.contains('rondas')) {
             final parts = match.notes!.split(' ');
             final rIdx = parts.indexOf('rondas');
             if (rIdx > 0) _totalRounds = int.tryParse(parts[rIdx-1]) ?? 10;
          }
        });
      }
    }

    if (mounted) {
      setState(() {
        for (var m in members) {
          final existing = existingResults.where((r) => 
            (r.userId != null && r.userId == m.userId) || 
            (r.guestMemberId != null && r.guestMemberId == m.id)
          ).firstOrNull;
          
          _playerResults.add({
            'memberId': m.id,
            'userId': m.userId,
            'name': m.profile?.nickname ?? m.profile?.displayName ?? m.guestNickname ?? m.guestFullName ?? 'Invitado',
            'participates': existing != null,
            'position': existing?.positionInMatch ?? 1,
            'exactPredictions': existing?.exactPredictions ?? 0,
            'requestedBazas': existing?.requestedBazas ?? 0,
            'bazasWon': existing?.osadiaBazasWon ?? 0,
            'isGuest': m.userId == null,
          });
        }
      });
    }
  }

  double _calculatePreviewPoints(Map<String, dynamic> res, dynamic group) {
    if (group == null) return 0;
    
    // 1. Puntos Campeonato (Solo Posición)
    int pos = res['position'];
    double f1 = 0;
    if (pos >= 1 && pos <= group.f1PointsSystem.length) {
      f1 = group.f1PointsSystem[pos - 1].toDouble();
    }

    // 2. Puntos Osadía: Bazas Ganadas * Multiplicador
    double osadia = 0;
    if (_useOsadia) {
      final won = res['bazasWon'] ?? 0;
      osadia = (won * group.osadiaMultiplier).toDouble();
    }

    // Suma total para la previa
    return f1 + osadia;
  }

  Future<void> _submit() async {
    // Guard para evitar doble-envío por doble tap
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      final group = await ref.read(groupByIdProvider(widget.groupId).future);
      
      final participatingResults = _playerResults.where((p) => p['participates'] == true).toList();
      
      if (participatingResults.length < group.minQuorum) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('QUÓRUM INSUFICIENTE'),
            content: Text('Solo hay ${participatingResults.length} jugadores activos. El mínimo para esta liga es ${group.minQuorum}.\n\nPara evitar errores en el ranking, debes completar los participantes requeridos.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ENTENDIDO')),
            ],
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final resultsToSend = participatingResults.map((p) => {
        'user_id': p['userId'],
        'guest_member_id': p['userId'] == null ? p['memberId'] : null,
        'position_in_match': p['position'],
        'exact_predictions': p['exactPredictions'],
        'requested_bazas': _useOsadia ? (p['requestedBazas'] ?? 0) : null,
        'osadia_bazas_won': _useOsadia ? (p['bazasWon'] ?? 0) : 0,
        'total_match_rounds': _totalRounds,
      }).toList();

      if (widget.matchId != null) {
        await ref.read(matchesRepositoryProvider).submitMatchUpdate(
          matchId: widget.matchId!,
          groupId: widget.groupId,
          playedAt: widget.playedAt,
          playersCount: participatingResults.length,
          minQuorum: group.minQuorum,
          results: resultsToSend,
          notes: 'Editado - $_totalRounds rondas',
        );
      } else {
        await ref.read(matchesRepositoryProvider).submitMatch(
          groupId: widget.groupId,
          createdBy: user!.id,
          scoresheetImageUrl: null,
          playedAt: widget.playedAt,
          playersCount: participatingResults.length,
          minQuorum: group.minQuorum,
          results: resultsToSend,
          notes: 'Carga manual - $_totalRounds rondas',
        );
      }

      if (mounted) {
        context.go('/groups/${widget.groupId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partida registrada con éxito'), backgroundColor: AppColors.neonGreen),
        );
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
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchId != null ? 'EDITAR PARTIDA' : 'CARGA MANUAL'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: groupAsync.when(
          data: (group) => _buildContent(group),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(),
    );
  }

  Widget _buildContent(dynamic group) {
    if (_currentStep == 0) return _buildStep0();
    return _buildStep1(group);
  }

  Widget _buildStep0() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PASO 1: DETALLES DE LA PARTIDA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neonOrange)),
        const SizedBox(height: 32),
        
        // FECHA
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('FECHA SELECCIONADA', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(widget.playedAt), style: AppTextStyles.rajdhani(fontSize: 24, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.calendar_today, color: AppColors.neonOrange),
        ),
        const Divider(height: 48),

        // RONDAS
        Text('¿CUÁNTAS RONDAS SE DISPUTARON?', style: AppTextStyles.inter(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _RoundChip(val: 10, current: _totalRounds, onTap: (v) => setState(() => _totalRounds = v)),
            _RoundChip(val: 12, current: _totalRounds, onTap: (v) => setState(() => _totalRounds = v)),
            _RoundChip(val: 15, current: _totalRounds, onTap: (v) => setState(() => _totalRounds = v)),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Otra...', isDense: true),
                onChanged: (v) => setState(() => _totalRounds = int.tryParse(v) ?? _totalRounds),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 48),

        // OSADIA TOGGLE
        SwitchListTile(
          title: const Text('HABILITAR PUNTOS DE OSADÍA', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Si se jugó con la regla de tramos de bazas solicitadas.'),
          value: _useOsadia,
          activeColor: AppColors.neonCyan,
          onChanged: (v) => setState(() => _useOsadia = v),
        ),
      ],
    );
  }

  Widget _buildStep1(dynamic group) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _playerResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text('PASO 2: RESULTADOS POR JUGADOR', style: AppTextStyles.inter(fontWeight: FontWeight.bold, color: AppColors.neonCyan)),
          );
        }
        
        final res = _playerResults[index - 1];
        final pts = _calculatePreviewPoints(res, group);

        return Card(
          color: AppColors.surfaceElevated,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        res['name'].toUpperCase(), 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: res['participates'] ? Colors.white : Colors.white38,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: res['participates'],
                      activeColor: AppColors.neonCyan,
                      onChanged: (v) => setState(() => res['participates'] = v),
                    ),
                    if (res['participates']) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showPointsDetail(context, res, group),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${pts.toInt()} PTS', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 4),
                              const Icon(Icons.info_outline, size: 14, color: AppColors.neonCyan),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (res['participates']) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // PUESTO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PUESTO', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            DropdownButton<int>(
                              value: res['position'],
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: AppColors.surfaceElevated,
                              items: List.generate(group.f1PointsSystem.length, (i) => i + 1)
                                  .map((i) => DropdownMenuItem(value: i, child: Text('$i º')))
                                  .toList(),
                              onChanged: (v) => setState(() => res['position'] = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // ACERTADAS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ACERTADAS', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            TextFormField(
                              initialValue: res['exactPredictions'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                              onChanged: (v) => setState(() => res['exactPredictions'] = int.tryParse(v) ?? 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_useOsadia) ...[
                    const Divider(height: 24, color: Colors.white12),
                    Row(
                      children: [
                        // SOLICITADAS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SOLICITADAS', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              TextFormField(
                                initialValue: res['requestedBazas'].toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                onChanged: (v) => setState(() => res['requestedBazas'] = int.tryParse(v) ?? 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // GANADAS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('GANADAS', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              TextFormField(
                                initialValue: res['bazasWon'].toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                                onChanged: (v) => setState(() => res['bazasWon'] = int.tryParse(v) ?? 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPointsDetail(BuildContext context, Map<String, dynamic> res, dynamic group) {
    final pos = res['position'];
    final accuracy = _totalRounds > 0 ? (res['exactPredictions'] / _totalRounds) * 100 : 0.0;
    
    PointsDetailDialog.show(
      context,
      playerName: res['name'].toString(),
      position: pos,
      championshipPoints: (pos >= 1 && pos <= group.f1PointsSystem.length) ? group.f1PointsSystem[pos - 1].toDouble() : 0.0,
      osadiaPoints: ((res['bazasWon'] ?? 0) * group.osadiaMultiplier).toDouble(),
      accuracyPercent: accuracy,
      exactPredictions: res['exactPredictions'] ?? 0,
      totalRounds: _totalRounds,
      useOsadia: _useOsadia,
      osadiaMultiplier: group.osadiaMultiplier,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('ATRÁS'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 0 
                ? () => setState(() => _currentStep++) 
                : _submit,
              child: Text(_currentStep == 0 ? 'SIGUIENTE: JUGADORES' : 'FINALIZAR REGISTRO'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundChip extends StatelessWidget {
  const _RoundChip({required this.val, required this.current, required this.onTap});
  final int val;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = val == current;
    return GestureDetector(
      onTap: () => onTap(val),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonOrange : Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$val', style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
