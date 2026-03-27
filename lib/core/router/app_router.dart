import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importaciones de características
import 'package:bazas/features/auth/presentation/screens/login_screen.dart';
import 'package:bazas/features/auth/presentation/screens/register_screen.dart';
import 'package:bazas/features/auth/presentation/screens/player_profile_screen.dart';
import 'package:bazas/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:bazas/features/groups/presentation/screens/home_screen.dart';
import 'package:bazas/features/groups/presentation/screens/create_group_screen.dart';
import 'package:bazas/features/groups/presentation/screens/join_group_screen.dart';
import 'package:bazas/features/groups/presentation/screens/group_dashboard_screen.dart';
import 'package:bazas/features/groups/data/models/group_model.dart';
import 'package:bazas/features/groups/data/repositories/groups_repository.dart';
import 'package:bazas/features/groups/presentation/screens/settings_screen.dart';
import 'package:bazas/features/scan/presentation/screens/scan_camera_screen.dart';
import 'package:bazas/features/scan/presentation/screens/scan_loading_screen.dart';
import 'package:bazas/features/scan/presentation/screens/scan_verify_screen.dart';
import 'package:bazas/features/scan/presentation/screens/scan_confirm_screen.dart';
import 'package:bazas/features/scan/presentation/screens/manual_registration_screen.dart';

import 'package:bazas/core/theme/app_theme.dart';

part 'app_router.g.dart';

// ============================================================
// RUTAS NOMBRADAS
// ============================================================
abstract class AppRoutes {
  static const String splash       = '/';
  static const String login        = '/login';
  static const String register     = '/register';
  static const String home         = '/home';
  static const String createGroup  = '/groups/create';
  static const String joinGroup    = '/groups/join';
  static const String editGroup    = '/groups/edit/:groupId';
  static const String groupDashboard = '/groups/:groupId';
  static const String playerProfile  = '/profile/:userId';
  static const String editProfile    = '/profile/edit/:userId';
  static const String scanCamera     = '/scan/camera';
  static const String scanLoading    = '/scan/loading';
  static const String scanVerify     = '/scan/verify';
  static const String scanConfirm    = '/scan/confirm';
  static const String scanManual     = '/scan/manual';
  static const String settings       = '/settings';
}

// ============================================================
// PROVIDER DEL ROUTER
// ============================================================
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) {
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }
      
      if (!isAuthenticated && !isAuthRoute) {
        if (state.matchedLocation == AppRoutes.home) return null;
        return AppRoutes.login;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    // Eliminamos el refreshListenable para evitar bucles infinitos en debug
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home — Mis Ligas
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Rutas de Creación y Unión (fuera de home para evitar '/home/groups/create')
      GoRoute(
        path: AppRoutes.createGroup,
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: AppRoutes.editGroup,
        builder: (context, state) {
          final group = state.extra as GroupModel?;
          if (group == null) {
            final groupId = state.pathParameters['groupId'];
            if (groupId != null) {
              return FutureBuilder<GroupModel>(
                future: ref.read(groupsRepositoryProvider).fetchGroupById(groupId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) return CreateGroupScreen(group: snapshot.data);
                  if (snapshot.hasError) return const HomeScreen();
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                },
              );
            }
            return const HomeScreen();
          }
          return CreateGroupScreen(group: group);
        },
      ),
      GoRoute(
        path: AppRoutes.joinGroup,
        builder: (context, state) => const JoinGroupScreen(),
      ),

      // Dashboard del Grupo
      GoRoute(
        path: AppRoutes.groupDashboard,
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDashboardScreen(groupId: groupId);
        },
      ),

      // Perfil del Jugador
      GoRoute(
        path: AppRoutes.playerProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return PlayerProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return EditProfileScreen(userId: userId);
        },
      ),

      // Flujo de Escaneo
      GoRoute(
        path: AppRoutes.scanCamera,
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId']!;
          final dateStr = state.uri.queryParameters['date'];
          return ScanCameraScreen(groupId: groupId, date: dateStr);
        },
      ),
      GoRoute(
        path: AppRoutes.scanLoading,
        builder: (context, state) => const ScanLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanVerify,
        builder: (context, state) => const ScanVerifyScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanConfirm,
        builder: (context, state) => const ScanConfirmScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanManual,
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId']!;
          final dateStr = state.uri.queryParameters['date']!;
          final matchId = state.uri.queryParameters['matchId'];
          final date = DateTime.parse(dateStr);
          return ManualRegistrationScreen(
            groupId: groupId, 
            playedAt: date,
            matchId: matchId,
          );
        },
      ),

      // Configuración
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Text(
          'Ruta no encontrada: ${state.uri}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

// Splash Screen simple ya que se usa inicialmente
// Splash Screen simple ya que se usa inicialmente
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

// Clase utilitaria para refrescar GoRouter con un Stream (Supabase Auth)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
