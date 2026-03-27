import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazas/core/providers/supabase_client_provider.dart';
import 'package:bazas/features/auth/data/models/profile_model.dart';
import 'package:bazas/core/utils/debug_logger.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._client, this._ref);
  final SupabaseClient _client;
  final Ref _ref;

  // ── Auth getters ──────────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Registro ──────────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
  }

  // ── Login ─────────────────────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final logger = _ref.read(debugLoggerProvider.notifier);
    logger.addLog('Intentando Login: $email', level: LogLevel.debug);
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      logger.addLog('Login exitoso para: ${res.user?.email}', level: LogLevel.info);
      return res;
    } catch (e) {
      logger.addLog('Error en signIn: $e', level: LogLevel.error);
      rethrow;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> signOut() => _client.auth.signOut();

  // ── Reset contraseña ──────────────────────────────────────
  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  // ── Perfil actual ─────────────────────────────────────────
  Future<ProfileModel> fetchCurrentProfile() async {
    final uid = currentUser!.id;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> fetchProfileById(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return ProfileModel.fromJson(data);
  }

  // ── Actualizar perfil ─────────────────────────────────────
  Future<ProfileModel> updateProfile({
    required String displayName,
    String? nickname,
    String? avatarUrl,
  }) async {
    final uid = currentUser!.id;
    final data = await _client
        .from('profiles')
        .update({
          'display_name': displayName,
          if (nickname != null) 'nickname': nickname,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        })
        .eq('id', uid)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  // ── Subir avatar ──────────────────────────────────────────
  Future<String> uploadAvatar(String filePath) async {
    final uid = currentUser!.id;
    final fileName = 'avatars/$uid.jpg';
    await _client.storage.from('avatars').upload(
          fileName,
          filePath as dynamic,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(fileName);
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client, ref);
}

/// Provider del usuario actual
@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(authRepositoryProvider).currentUser;
}

/// Stream de cambios de autenticación para redirigir con GoRouter
@riverpod
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
@riverpod
Future<ProfileModel> profile(ProfileRef ref, String userId) {
  return ref.watch(authRepositoryProvider).fetchProfileById(userId);
}
