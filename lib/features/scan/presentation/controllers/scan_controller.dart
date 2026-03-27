import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bazas/features/scan/data/models/scan_result_model.dart';
import 'package:bazas/features/scan/data/repositories/scan_repository.dart';
import 'package:bazas/features/scan/data/services/gemini_scan_service.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/matches/data/repositories/matches_repository.dart';
import 'package:bazas/features/auth/data/repositories/auth_repository.dart';

import 'package:bazas/core/utils/debug_logger.dart';

part 'scan_controller.freezed.dart';
part 'scan_controller.g.dart';

@freezed
class ScanState with _$ScanState {
  const factory ScanState({
    @Default(false) bool isLoading,
    String? groupId,
    File? imageFile,
    String? tempImageUrl,
    ScanResultModel? result,
    DateTime? playedAt,
    String? error,
  }) = _ScanState;
}

@Riverpod(keepAlive: true)
class ScanController extends _$ScanController {
  @override
  ScanState build() => const ScanState();

  void setGroupId(String id) {
    state = state.copyWith(groupId: id);
  }

  void setPlayedAt(DateTime date) {
    state = state.copyWith(playedAt: date);
  }

  void setCapturedImage(File file) {
    state = state.copyWith(imageFile: file, error: null);
  }

  void setPickedImage(XFile file) {
    state = state.copyWith(imageFile: File(file.path), error: null);
  }

  // ── Paso 2: Procesar con IA ───────────────────────────────
  Future<bool> processImage() async {
    if (state.imageFile == null) {
      state = state.copyWith(error: 'Falta la imagen de la planilla');
      return false;
    }
    if (state.groupId == null) {
      state = state.copyWith(error: 'Falta el ID del grupo');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    print('[SCAN] Iniciando proceso de imagen...');

    try {
      // 1. Subir a temporal (En segundo plano)
      print('[SCAN] Subiendo imagen a storage (bg)...');
      ref.read(scanRepositoryProvider).uploadTempImage(
            groupId: state.groupId!,
            imageFile: state.imageFile!,
          ).then((url) => print('[SCAN] Upload OK: $url'))
           .catchError((e) => print('[SCAN] Upload Error: $e'));

      // 2. Obtener nombres de jugadores
      print('[SCAN] Obteniendo miembros...');
      final members = await ref.read(groupsRepositoryProvider).fetchGroupMembers(state.groupId!);
      final playerNames = members.map((m) {
        if (m.profile != null) return m.profile!.displayName;
        return m.guestFullName ?? 'Jugador';
      }).toList();

      // 3. Llamar a Gemini
      print('[SCAN] Llamando a Gemini AI...');
      final geminiData = await ref.read(geminiScanServiceProvider).processScoresheet(
            imageFile: state.imageFile!,
            playerNames: playerNames,
            groupId: state.groupId!,
          );
      print('[SCAN] Gemini respondió OK');

      // 4. Parsear y mapear IDs de miembros
      final rawResult = ScanResultModel.fromJson(geminiData);
      
      // Mapear los nombres extraídos por la IA a los IDs de miembros reales del grupo
      final mappedPlayers = rawResult.players.map((p) {
        // Buscar el miembro cuyo nombre coincida mejor
        final matchingMember = members.firstWhere(
          (m) {
            final displayName = m.profile?.displayName?.toLowerCase().trim() ?? '';
            final guestName = m.guestFullName?.toLowerCase().trim() ?? '';
            final aiName = p.playerName.toLowerCase().trim();
            return displayName == aiName || guestName == aiName;
          },
          orElse: () => members.first, // Fallback (mejorable con logeo o aviso)
        );
        
        return p.copyWith(userId: matchingMember.id);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        result: rawResult.copyWith(players: mappedPlayers),
      );
      return true;
    } catch (e) {
      print('[SCAN] ERROR FATAL: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Paso 2.5: Carga Manual (Fallback) ──────────────────────
  Future<bool> startManualEntry() async {
    if (state.groupId == null) {
      state = state.copyWith(error: 'Falta el ID del grupo para la carga manual');
      return false;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final members = await ref.read(groupsRepositoryProvider).fetchGroupMembers(state.groupId!);
      
      final manualPlayers = members.map((m) {
        String name;
        if (m.profile != null) {
          final p = m.profile!;
          name = (p.nickname != null && p.nickname!.isNotEmpty)
              ? '${p.displayName} (Apodo: ${p.nickname})'
              : p.displayName;
        } else {
          name = (m.guestNickname != null && m.guestNickname!.isNotEmpty)
              ? '${m.guestFullName ?? "Invitado"} (Apodo: ${m.guestNickname})'
              : m.guestFullName ?? 'Jugador Desconocido';
        }
        
        return PlayerScanResult(
          playerName: name,
          userId: m.id,
          rawPoints: 0,
          exactPredictions: 0,
          osadiaBazasWon: 0,
          positionInMatch: 1, // Se recalcula al final
          lowConfidence: false,
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        result: ScanResultModel(
          players: manualPlayers,
          playedAt: state.playedAt ?? DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar miembros: $e');
      return false;
    }
  }

  // ── Paso 3: Editar resultados (corrección manual) ──────────
  void updatePlayerResult(int index, PlayerScanResult updatedPlayer) {
    if (state.result == null) return;
    
    final newPlayers = List<PlayerScanResult>.from(state.result!.players);
    newPlayers[index] = updatedPlayer;
    
    state = state.copyWith(
      result: state.result!.copyWith(players: newPlayers),
    );
  }

  // ── Paso 4: Submit Final ──────────────────────────────────
  Future<bool> submitMatch() async {
    if (state.result == null || state.groupId == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('[SUBMIT] Iniciando sumisión...');
      final user = ref.read(authRepositoryProvider).currentUser;
      final group = await ref.read(groupsRepositoryProvider).fetchGroupById(state.groupId!);
      
      print('[SUBMIT] Usuario: ${user?.id}, Grupo: ${group.id}');

      // 1. Recalcular posiciones basadas en puntaje (descendente)
      final sortedPlayers = List<PlayerScanResult>.from(state.result!.players);
      sortedPlayers.sort((a, b) => b.rawPoints.compareTo(a.rawPoints));
      
      final resultsJson = state.result!.players.map((p) {
        // Encontrar posición del jugador en la lista ordenada
        final pos = sortedPlayers.indexWhere((sp) => sp.playerName == p.playerName) + 1;
        
        print('[SUBMIT] Jugador: ${p.playerName}, ID: ${p.userId}, Puntos: ${p.rawPoints}, Pos: $pos');
        return {
          'guest_member_id': p.userId,
          'position_in_match': pos, // Usamos la posición calculada
          'raw_points': p.rawPoints,
          'exact_predictions': p.exactPredictions,
          'osadia_bazas_won': p.osadiaBazasWon,
          'requested_bazas': p.requestedBazas,
          'total_match_rounds': state.result?.totalRounds ?? 10,
        };
      }).toList();

      final match = await ref.read(matchesRepositoryProvider).submitMatch(
        groupId: state.groupId!,
        createdBy: user!.id,
        scoresheetImageUrl: null, // Se actualiza después
        playedAt: state.playedAt ?? state.result!.playedAt ?? DateTime.now(),
        playersCount: state.result!.players.length,
        minQuorum: group.minQuorum,
        results: resultsJson,
      );

      // 2. Mover imagen de temp a final
      if (state.tempImageUrl != null) {
        final finalUrl = await ref.read(scanRepositoryProvider).finalizeImage(
          groupId: state.groupId!,
          matchId: match.id,
          tempUrl: state.tempImageUrl!,
        );

        // Guardar la URL final en la partida
        await ref.read(matchesRepositoryProvider).updateMatch(match.id, {
          'scoresheet_image_url': finalUrl,
        });
      }

      state = const ScanState(); // Reset
      return true;
    } catch (e) {
      print('[SUBMIT] ERROR FATAL: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    if (state.tempImageUrl != null) {
      ref.read(scanRepositoryProvider).deleteTempImage(state.tempImageUrl!);
    }
    state = const ScanState();
  }
}
