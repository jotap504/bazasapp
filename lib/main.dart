import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/debug_console_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Capturar errores globales de Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print('!!! GLOBAL FLUTTER ERROR: ${details.exception}');
  };

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  print('!!! ENV LOADED. Gemini Key starts with: ${dotenv.env['GEMINI_API_KEY']?.substring(0, 5)}...');

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Forzar orientación portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de sistema transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BazasApp(),
    ),
  );
}

class BazasApp extends ConsumerWidget {
  const BazasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Bazas — La Podrida',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) => DebugConsoleOverlay(child: child!),
    );
  }
}
