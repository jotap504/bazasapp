import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:bazas/core/constants/app_constants.dart';
import 'package:bazas/core/providers/supabase_client_provider.dart';
import 'package:bazas/features/scan/data/models/scan_result_model.dart';

part 'scan_repository.g.dart';

class ScanRepository {
  ScanRepository(this._client);
  final SupabaseClient _client;

  static const _uuid = Uuid();

  // ── 1. Subir imagen al bucket (temporal, antes de tener matchId) ──
  Future<String> uploadTempImage({
    required String groupId,
    required File imageFile,
  }) async {
    final tempId = _uuid.v4();
    final fileName = '$groupId/temp_$tempId.jpg';

    await _client.storage.from(AppConstants.storageBucket).uploadBinary(
          fileName,
          await imageFile.readAsBytes(),
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // URL firmada válida 15 minutos (suficiente para el flujo de escaneo)
    return _client.storage
        .from(AppConstants.storageBucket)
        .createSignedUrl(fileName, 900);
  }

  // ── 2. Llamar a la Edge Function process-scoresheet ───────
  Future<ScanResultModel> processScoresheet({
    required String imageUrl,
    required List<String> playerNames,
    required String groupId,
  }) async {
    final response = await _client.functions.invoke(
      AppConstants.edgeFnProcessScoresheet,
      headers: {
        'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
      },
      body: {
        'image_url': imageUrl,
        'player_names': playerNames,
        'group_id': groupId,
      },
    );

    if (response.status != 200) {
      throw Exception(
        'Error en Edge Function (${response.status}): ${response.data}',
      );
    }

    final data = response.data as Map<String, dynamic>;
    return ScanResultModel.fromJson(data);
  }

  // ── 3. Mover imagen temporal a ubicación final ─────────────
  Future<String> finalizeImage({
    required String groupId,
    required String matchId,
    required String tempUrl,
  }) async {
    // Extraer nombre del archivo temp de la URL firmada
    final uri = Uri.parse(tempUrl);
    final pathSegments = uri.pathSegments;
    final tempFileName = pathSegments
        .skipWhile((s) => s != AppConstants.storageBucket)
        .skip(1)
        .join('/');

    final finalFileName = '$groupId/$matchId.jpg';

    await _client.storage.from(AppConstants.storageBucket).move(
          tempFileName,
          finalFileName,
        );

    return _client.storage
        .from(AppConstants.storageBucket)
        .createSignedUrl(finalFileName, 3600 * 24 * 30); // 30 días
  }

  // ── Limpiar imagen temporal (si el usuario cancela) ────────
  Future<void> deleteTempImage(String tempUrl) async {
    try {
      final uri = Uri.parse(tempUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments
          .skipWhile((s) => s != AppConstants.storageBucket)
          .skip(1)
          .join('/');
      await _client.storage.from(AppConstants.storageBucket).remove([fileName]);
    } catch (_) {
      // Ignorar errores de limpieza
    }
  }
}

// ── Riverpod Provider ──────────────────────────────────────
@riverpod
ScanRepository scanRepository(ScanRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return ScanRepository(client);
}
