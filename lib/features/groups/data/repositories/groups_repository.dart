import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazas/core/providers/supabase_client_provider.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';
import 'package:bazas/features/groups/data/models/group_member_model.dart';

part 'groups_repository.g.dart';

class GroupsRepository {
  GroupsRepository(this._client);
  final SupabaseClient _client;

  // ── Listar grupos del usuario ──────────────────────────────
  Future<List<GroupModel>> fetchMyGroups(String userId) async {
    // JOIN implícito: grupos donde soy miembro
    final data = await _client.rpc('get_my_groups', params: {'p_user_id': userId});
    if (data == null) return [];
    return (data as List).map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Alternativa directa sin RPC (si no se quiere agregar función extra)
  Future<List<GroupModel>> fetchMyGroupsDirect(String userId) async {
    final memberRows = await _client
        .from('group_members')
        .select('group_id')
        .eq('user_id', userId);

    final groupIds = (memberRows as List).map((r) => r['group_id'] as String).toList();
    if (groupIds.isEmpty) return [];

    final data = await _client
        .from('groups')
        .select()
        .inFilter('id', groupIds)
        .order('created_at', ascending: false);

    return (data as List).map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Obtener un grupo por ID ────────────────────────────────
  Future<GroupModel> fetchGroupById(String groupId) async {
    final data = await _client
        .from('groups')
        .select()
        .eq('id', groupId)
        .single();
    
    return GroupModel.fromJson(data);
  }

  // ── Crear grupo ────────────────────────────────────────────
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    required String createdBy,
    int minQuorum = 5,
    List<int>? f1PointsSystem,
    double osadiaMultiplier = 1.0,
    double efectividadMultiplier = 1.0,
    int ptsPerPromise = 10,
    int ptsPerTrick = 1,
    int minAttendancePct = 50,
    List<Map<String, dynamic>>? osadiaConfig,
    List<Map<String, String>> guests = const [],
  }) async {
    final insertMap = {
      'name': name,
      'created_by': createdBy,
      'min_quorum': minQuorum,
      'f1_points_system': f1PointsSystem ?? [25, 18, 15, 12, 10, 8, 6, 4, 2, 1],
      'osadia_multiplier': osadiaMultiplier,
      'efectividad_multiplier': efectividadMultiplier,
      'pts_per_promise': ptsPerPromise,
      'pts_per_trick': ptsPerTrick,
      'min_attendance_pct': minAttendancePct,
      'osadia_config': osadiaConfig ?? [
        {'min': 6, 'max': 10, 'pts': 2},
        {'min': 11, 'max': 20, 'pts': 5},
        {'min': 21, 'max': null, 'pts': 7},
      ],
    };
    if (description != null && description.trim().isNotEmpty) {
      insertMap['description'] = description.trim();
    }

    final data = await _client
        .from('groups')
        .insert(insertMap)
        .select()
        .single();

    final group = GroupModel.fromJson(data);

    // Preparar lista de miembros a insertar (creador + invitados)
    final membersToInsert = <Map<String, dynamic>>[
      {
        'group_id': group.id,
        'user_id': createdBy,
        'role': 'owner',
      }
    ];

    for (final guest in guests) {
      membersToInsert.add({
        'group_id': group.id,
        'guest_full_name': guest['fullName'],
        'guest_nickname': guest['nickname']?.isEmpty == true ? null : guest['nickname'],
        'role': 'member',
      });
    }

    // Insertar todos los miembros en lote
    await _client.from('group_members').insert(membersToInsert);

    return group;
  }

  // ── Unirse por código ──────────────────────────────────────
  Future<GroupModel> joinByInviteCode({
    required String inviteCode,
    required String userId,
  }) async {
    final data = await _client
        .from('groups')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .single();

    final group = GroupModel.fromJson(data);

    // Insertar como miembro (ON CONFLICT DO NOTHING manejado por Supabase)
    await _client.from('group_members').upsert({
      'group_id': group.id,
      'user_id': userId,
      'role': 'member',
    }, onConflict: 'group_id,user_id');

    return group;
  }

  // ── Actualizar grupo ───────────────────────────────────────
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
    int? minQuorum,
    List<int>? f1PointsSystem,
    double? osadiaMultiplier,
    double? efectividadMultiplier,
    int? ptsPerPromise,
    int? ptsPerTrick,
    int? minAttendancePct,
    List<Map<String, dynamic>>? osadiaConfig,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (minQuorum != null) 'min_quorum': minQuorum,
      if (f1PointsSystem != null) 'f1_points_system': f1PointsSystem,
      if (osadiaMultiplier != null) 'osadia_multiplier': osadiaMultiplier,
      if (efectividadMultiplier != null) 'efectividad_multiplier': efectividadMultiplier,
      if (ptsPerPromise != null) 'pts_per_promise': ptsPerPromise,
      if (ptsPerTrick != null) 'pts_per_trick': ptsPerTrick,
      if (minAttendancePct != null) 'min_attendance_pct': minAttendancePct,
      if (osadiaConfig != null) 'osadia_config': osadiaConfig,
    };

    final data = await _client
        .from('groups')
        .update(updates)
        .eq('id', groupId)
        .select()
        .single();

    return GroupModel.fromJson(data);
  }

  // ── Miembros del grupo ─────────────────────────────────────
  Future<List<GroupMemberModel>> fetchGroupMembers(String groupId) async {
    final data = await _client
        .from('group_members')
        .select('*, profile:profiles(*)')
        .eq('group_id', groupId)
        .order('current_position', ascending: true, nullsFirst: false);

    return (data as List).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      // Supabase devuelve el JOIN como 'profile' (singular)
      if (json['profile'] != null) {
        json['profile'] = json['profile'];
      }
      return GroupMemberModel.fromJson(json);
    }).toList();
  }

  // ── Recalcular posiciones (llama a función SQL) ────────────
  Future<void> recalculatePositions(String groupId) async {
    await _client.rpc('recalculate_group_positions', params: {'p_group_id': groupId});
  }

  // ── Finalizar Torneo (Cerrar Liga) ──────────────────────────
  Future<void> closeGroup(String groupId) async {
    await _client.rpc('close_group', params: {'p_group_id': groupId});
  }

  // ── Cambiar rol de miembro ─────────────────────────────────
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required String role,
  }) async {
    await _client
        .from('group_members')
        .update({'role': role})
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  // ── Eliminar miembro ───────────────────────────────────────
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  // ── Reemplazar miembros (solo si no hay partidas) ──────────
  Future<void> replaceGroupGuests(String groupId, List<Map<String, String>> guests) async {
    // Solo eliminamos a los invitados (guest players), que son los que tienen user_id NULL.
    // NUNCA debemos borrar a los usuarios registrados aquí, especialmente al dueño.
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .isFilter('user_id', null);

    // 2. Insertar nuevos invitados
    if (guests.isNotEmpty) {
      final guestData = guests.map((g) => {
        'group_id': groupId,
        'guest_full_name': g['fullName'],
        'guest_nickname': g['nickname'],
        'role': 'member',
      }).toList();
      await _client.from('group_members').insert(guestData);
    }
  }

  // ── Eliminar grupo ─────────────────────────────────────────
  Future<void> deleteGroup(String groupId) async {
    await _client.from('groups').delete().eq('id', groupId);
  }

  // ── Stream en tiempo real del ranking ─────────────────────
  Stream<List<GroupMemberModel>> watchGroupRanking(String groupId) {
    return _client
        .from('group_members')
        .stream(primaryKey: ['group_id', 'user_id'])
        .eq('group_id', groupId)
        .order('total_championship_points', ascending: false)
        .map((rows) => rows
            .map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }
}

// ── Riverpod Providers ─────────────────────────────────────
@riverpod
GroupsRepository groupsRepository(GroupsRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return GroupsRepository(client);
}

@riverpod
Future<List<GroupModel>> myGroups(MyGroupsRef ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(groupsRepositoryProvider).fetchMyGroupsDirect(userId);
}

@riverpod
Future<GroupModel> groupById(GroupByIdRef ref, String groupId) async {
  return ref.watch(groupsRepositoryProvider).fetchGroupById(groupId);
}

@riverpod
Future<List<GroupMemberModel>> groupMembers(GroupMembersRef ref, String groupId) async {
  return ref.watch(groupsRepositoryProvider).fetchGroupMembers(groupId);
}

@riverpod
Stream<List<GroupMemberModel>> groupRankingStream(
  GroupRankingStreamRef ref,
  String groupId,
) {
  return ref.watch(groupsRepositoryProvider).watchGroupRanking(groupId);
}
