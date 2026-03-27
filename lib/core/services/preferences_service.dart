import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  static const _aiPromptKey = 'custom_ai_prompt';

  String getCustomAiPrompt() {
    return _prefs.getString(_aiPromptKey) ?? '';
  }

  Future<void> setCustomAiPrompt(String value) async {
    await _prefs.setString(_aiPromptKey, value);
  }
}

// Provider para SharedPreferences (se inicializa en main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe inicializarse en el main');
});

// Provider para el servicio de preferencias
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
});

// Provider para el prompt personalizado (lectura/escritura reactiva)
final customAiPromptProvider = StateNotifierProvider<CustomAiPromptNotifier, String>((ref) {
  final service = ref.watch(preferencesServiceProvider);
  return CustomAiPromptNotifier(service);
});

class CustomAiPromptNotifier extends StateNotifier<String> {
  final PreferencesService _service;
  
  CustomAiPromptNotifier(this._service) : super(_service.getCustomAiPrompt());

  Future<void> setPrompt(String value) async {
    await _service.setCustomAiPrompt(value);
    state = value;
  }
}
