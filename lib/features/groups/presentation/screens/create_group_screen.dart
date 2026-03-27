import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key, this.group});
  final GroupModel? group;

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  double _minQuorum = 2;
  double _osadiaMult = 1.0;
  double _efectividadMult = 1.0;
  double _ptsPromise = 10;
  double _ptsTrick = 1;
  double _minAttendance = 50;

  // Nuevas configuraciones avanzadas
  late List<int> _f1Points;
  bool _isLoading = false;

  // Lista para jugadores invitados
  final List<Map<String, TextEditingController>> _guestControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _descController.text = widget.group!.description ?? '';
      _minQuorum = widget.group!.minQuorum.toDouble();
      _osadiaMult = widget.group!.osadiaMultiplier;
      _efectividadMult = widget.group!.efectividadMultiplier;
      _ptsPromise = widget.group!.ptsPerPromise.toDouble();
      _ptsTrick = widget.group!.ptsPerTrick.toDouble();
      _minAttendance = widget.group!.minAttendancePct.toDouble();
      _f1Points = List.from(widget.group!.f1PointsSystem);

      if ((widget.group!.matchCount ?? 0) == 0) {
        _loadMembers();
      }
    } else {
      // VALORES POR DEFECTO PARA NUEVO GRUPO
      _f1Points = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await ref.read(groupsRepositoryProvider).fetchGroupMembers(widget.group!.id);
      if (mounted) {
        setState(() {
          for (var m in members) {
            if (m.profile == null) { // Es un invitado
              _guestControllers.add({
                'fullName': TextEditingController(text: m.guestFullName),
                'nickname': TextEditingController(text: m.guestNickname),
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando miembros: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (var gc in _guestControllers) {
      gc['fullName']?.dispose();
      gc['nickname']?.dispose();
    }
    super.dispose();
  }

  void _addGuest() {
    setState(() {
      _guestControllers.add({
        'fullName': TextEditingController(),
        'nickname': TextEditingController(),
      });
    });
  }

  void _removeGuest(int index) {
    setState(() {
      _guestControllers[index]['fullName']?.dispose();
      _guestControllers[index]['nickname']?.dispose();
      _guestControllers.removeAt(index);
    });
  }

  Future<void> _create() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;
      final profile = await authRepo.fetchCurrentProfile();
      
      final myName = profile.displayName.toLowerCase().trim();
      final myNick = profile.nickname?.toLowerCase().trim();

      // Recolectar invitados
      final guests = _guestControllers.map((g) {
        return {
          'fullName': g['fullName']!.text.trim(),
          'nickname': g['nickname']!.text.trim(),
        };
      }).where((g) {
        final gName = g['fullName']!.toLowerCase().trim();
        final gNick = g['nickname']?.toLowerCase().trim();
        
        // Si el invitado tiene el mismo nombre o apodo que el dueño, lo filtramos
        // para evitar duplicados, ya que el dueño se incluye siempre por defecto.
        final matchesOwner = gName == myName || 
                            (myNick != null && gNick == myNick) ||
                            (myNick != null && gName == myNick);
        
        return g['fullName']!.isNotEmpty && !matchesOwner;
      }).toList();

      if (widget.group == null) {
        // CREAR NUEVO
        await ref.read(groupsRepositoryProvider).createGroup(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          createdBy: user!.id,
          minQuorum: _minQuorum.toInt(),
          osadiaMultiplier: _osadiaMult,
          efectividadMultiplier: _efectividadMult,
          ptsPerPromise: _ptsPromise.toInt(),
          ptsPerTrick: _ptsTrick.toInt(),
          minAttendancePct: _minAttendance.toInt(),
          f1PointsSystem: _f1Points,
          osadiaConfig: null,
          guests: guests,
        );
      } else {
        // ACTUALIZAR EXISTENTE
        await ref.read(groupsRepositoryProvider).updateGroup(
          groupId: widget.group!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          minQuorum: _minQuorum.toInt(),
          ptsPerPromise: _ptsPromise.toInt(),
          ptsPerTrick: _ptsTrick.toInt(),
          minAttendancePct: _minAttendance.toInt(),
          f1PointsSystem: _f1Points,
          osadiaConfig: null,
        );
        
        // Si no hay partidas, permitir actualizar invitados
        if ((widget.group!.matchCount ?? 0) == 0) {
          await ref.read(groupsRepositoryProvider).replaceGroupGuests(
            widget.group!.id,
            guests,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liga creada exitosamente'), backgroundColor: AppColors.neonGreen),
        );
        ref.invalidate(myGroupsProvider);
        context.pop();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'NUEVA LIGA' : 'EDITAR LIGA'),
        actions: [
          if (widget.group != null)
            IconButton(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: AppColors.error),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DATOS GENERALES', style: AppTextStyles.neonLabel),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'NOMBRE DE LA LIGA', hintText: 'Ej: Los Pibes de los Jueves'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'DESCRIPCIÓN (OPCIONAL)'),
                ),
                
                const SizedBox(height: 32),
                if (widget.group == null || (widget.group!.matchCount ?? 0) == 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('JUGADORES INVITADOS', style: AppTextStyles.neonLabel),
                      TextButton.icon(
                        onPressed: _addGuest,
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, color: AppColors.neonCyan),
                        label: const Text('Añadir Jugador'),
                      ),
                    ],
                  ),
                  const Text(
                    'Añade a tus amigos para que la IA los reconozca. No necesitan cuenta de app.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista dinámica de invitados
                  ...List.generate(_guestControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _guestControllers[index]['fullName'],
                              decoration: const InputDecoration(labelText: 'Nombre Completo', hintText: 'Ej: Juan Pérez', isDense: true),
                              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _guestControllers[index]['nickname'],
                              decoration: const InputDecoration(labelText: 'Apodo (Opc.)', hintText: 'Ej: Juancho', isDense: true),
                            ),
                          ),
                          IconButton(
                            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: AppColors.error),
                            onPressed: () => _removeGuest(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                
                const SizedBox(height: 32),
                Text('REGLAS DE COMPETICIÓN', style: AppTextStyles.neonLabel),
                const SizedBox(height: 16),
                
                // QUORUM
                _SliderSetting(
                  label: 'QUORUM MÍNIMO (JUGADORES)',
                  value: _minQuorum,
                  min: 2,
                  max: 10,
                  divisions: 8,
                  onChanged: (v) => setState(() => _minQuorum = v),
                ),
                
                _SliderSetting(
                  label: 'MULTIPLICADOR OSADÍA',
                  subtitle: 'Puntos por cada baza ganada',
                  value: _osadiaMult,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) => setState(() => _osadiaMult = v),
                ),


                _SliderSetting(
                  label: 'ASISTENCIA MÍNIMA (%)',
                  subtitle: 'Para aparecer en ranking de Efectividad',
                  value: _minAttendance,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => setState(() => _minAttendance = v),
                ),

                const SizedBox(height: 24),
                _AdvancedScoringSection(
                  f1Points: _f1Points,
                  onF1Changed: (newList) => setState(() => _f1Points = newList),
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _create,
                    child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : Text(widget.group == null ? 'FUNDAR COMPETICIÓN' : 'GUARDAR CAMBIOS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('¿ELIMINAR LIGA?'),
        content: const Text('Esta acción no se puede deshacer y se borrarán todos los resultados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(groupsRepositoryProvider).deleteGroup(widget.group!.id);
              if (mounted) {
                Navigator.pop(context); // Dialog
                Navigator.pop(context); // Screen
                ref.invalidate(myGroupsProvider);
              }
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            Text(
              value == value.toInt() ? '${value.toInt()}' : value.toStringAsFixed(1),
              style: AppTextStyles.statNumber.copyWith(fontSize: 20, color: AppColors.neonCyan),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.neonCyan,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _AdvancedScoringSection extends StatefulWidget {
  const _AdvancedScoringSection({
    required this.f1Points,
    required this.onF1Changed,
  });

  final List<int> f1Points;
  final ValueChanged<List<int>> onF1Changed;

  @override
  State<_AdvancedScoringSection> createState() => _AdvancedScoringSectionState();
}

class _AdvancedScoringSectionState extends State<_AdvancedScoringSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedSettings03, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 12),
                Text('CONFIGURACIÓN AVANZADA', style: AppTextStyles.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neonCyan)),
                const Spacer(),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.neonCyan),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          // F1 POINTS
          Text('TABLA DE PUNTOS POR PUESTO (F1)', style: AppTextStyles.inter(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.f1Points.join(', '),
            decoration: const InputDecoration(
              hintText: 'Ej: 25, 18, 15, 12...',
              helperText: 'Separa los puntos por comas (1º, 2º, 3º...)',
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) {
              final list = v.split(',')
                .map((e) => int.tryParse(e.trim()))
                .whereType<int>()
                .toList();
              if (list.isNotEmpty) widget.onF1Changed(list);
            },
          ),
        ],
      ],
    );
  }
}
