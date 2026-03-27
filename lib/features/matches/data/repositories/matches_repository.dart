import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazas/core/providers/supabase_client_provider.dart';
import 'package:bazas/features/matches/data/models/match_model.dart';
import 'package:bazas/features/matches/data/models/match_result_model.dart';

part 'matches_repository.g.dart';

class MatchesRepository {
  MatchesRepository(this._client);
  final SupabaseClient _client;

  // ── Listar partidas de un grupo ────────────────────────────
  Future<List<MatchModel>> fetchGroupMatches(String groupId, {int limit = 20}) async {
    final data = await _client
        .from('matches')
        .select()
        .eq('group_id', groupId)
        .order('played_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Obtener una partida con sus resultados ─────────────────
  Future<MatchModel> fetchMatchById(String matchId) async {
    final data = await _client
        .from('matches')
        .select()
        .eq('id', matchId)
        .single();
    return MatchModel.fromJson(data);
  }

  Future<List<MatchResultModel>> fetchMatchResults(String matchId) async {
    final data = await _client
        .from('match_results')
        .select('*, profile:profiles(*)')
        .eq('match_id', matchId)
        .order('position_in_match', ascending: true);

    return (data as List)
        .map((e) => MatchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Crear partida + resultados (transacción lógica) ────────
  /// Crea la partida en `matches` y luego inserta los resultados
  /// en `match_results`. El trigger SQL calcula los puntos automáticamente.
  Future<MatchModel> submitMatch({
    required String groupId,
    required String createdBy,
    required String? scoresheetImageUrl,
    required DateTime playedAt,
    required int playersCount,
    required int minQuorum,
    required List<Map<String, dynamic>> results,
    String? notes,
  }) async {
    final isOfficial = playersCount >= minQuorum;

    // 1. Crear la partida
    final matchData = await _client
        .from('matches')
        .insert({
          'group_id': groupId,
          'created_by': createdBy,
          'scoresheet_image_url': scoresheetImageUrl,
          'played_at': playedAt.toIso8601String(),
          'players_count': playersCount,
          'is_official': isOfficial,
          'notes': notes,
        })
        .select()
        .single();

    final match = MatchModel.fromJson(matchData);

    // 2. Insertar resultados (el trigger en BD calcula earned_championship_points)
    final resultsWithMatchId = results.map((r) => {
      ...r,
      'match_id': match.id,
    }).toList();

    await _client.from('match_results').insert(resultsWithMatchId);

    // 3. Si es oficial, recalcular posiciones del ranking
    if (isOfficial) {
      await _client.rpc(
        'recalculate_group_positions',
        params: {'p_group_id': groupId},
      );
    }

    return match;
  }

  // ── Actualizar metadatos de partida ────────────────────────
  Future<void> updateMatch(String matchId, Map<String, dynamic> data) async {
    await _client.from('matches').update(data).eq('id', matchId);
  }

  // ── Actualizar partida + resultados ─────────────────────────
  Future<void> submitMatchUpdate({
    required String matchId,
    required String groupId,
    required DateTime playedAt,
    required int playersCount,
    required int minQuorum,
    required List<Map<String, dynamic>> results,
    String? notes,
  }) async {
    final isOfficial = playersCount >= minQuorum;

    // 1. Actualizar la partida (esto disparará el contador en groups si cambia is_official o similar)
    await _client.from('matches').update({
      'played_at': playedAt.toIso8601String(),
      'players_count': playersCount,
      'is_official': isOfficial,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', matchId);

    // 2. Borrar resultados anteriores (esto DISPARA EL TRIGGER de resta en BD automáticamente)
    await _client.from('match_results').delete().eq('match_id', matchId);

    // 3. Insertar nuevos resultados (esto DISPARA EL TRIGGER de suma en BD automáticamente)
    final resultsWithMatchId = results.map((r) => {
      ...r,
      'match_id': matchId,
    }).toList();

    await _client.from('match_results').insert(resultsWithMatchId);

    // 4. Recalcular posiciones del ranking
    await _client.rpc(
      'recalculate_group_positions',
      params: {'p_group_id': groupId},
    );
  }

  // ── Subir imagen al bucket de Supabase Storage ─────────────
  Future<String> uploadScoresheetImage({
    required String groupId,
    required String matchId,
    required String localFilePath,
  }) async {
    final fileName = 'scoresheets/$groupId/$matchId.jpg';

    await _client.storage.from('scoresheets').upload(
          fileName,
          localFilePath as dynamic,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // Devuelve URL firmada válida por 1 hora (bucket privado)
    return _client.storage
        .from('scoresheets')
        .createSignedUrl(fileName, 3600);
  }

  // ── Historial de resultados de un jugador en un grupo ──────
  Future<List<MatchResultModel>> fetchPlayerHistory({
    required String userId,
    required String groupId,
    int limit = 10,
  }) async {
    final data = await _client
        .from('match_results')
        .select('*, match:matches!inner(*)')
        .eq('user_id', userId)
        .eq('match.group_id', groupId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => MatchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Eliminar partida ───────────────────────────────────────
  Future<void> deleteMatch(String matchId, String groupId) async {
    // 1. Eliminar de match_results (cascada en BD usualmente, pero lo hacemos explícito si no)
    // En Supabase, si definimos ON DELETE CASCADE, esto borra los resultados de match_results automáticamente.
    await _client.from('matches').delete().eq('id', matchId);
    
    // 2. Recalcular posiciones del ranking
    await _client.rpc(
      'recalculate_group_positions',
      params: {'p_group_id': groupId},
    );
  }
}

// ── Riverpod Providers ─────────────────────────────────────
@riverpod
MatchesRepository matchesRepository(MatchesRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return MatchesRepository(client);
}

@riverpod
Future<List<MatchModel>> groupMatches(
  GroupMatchesRef ref,
  String groupId,
) async {
  return ref.watch(matchesRepositoryProvider).fetchGroupMatches(groupId);
}

@riverpod
Future<List<MatchResultModel>> matchResults(
  MatchResultsRef ref,
  String matchId,
) async {
  return ref.watch(matchesRepositoryProvider).fetchMatchResults(matchId);
}
