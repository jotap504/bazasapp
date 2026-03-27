import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:bazas/core/services/preferences_service.dart';

class AiScanService {
  final Ref _ref;
  AiScanService(this._ref);

  Future<Map<String, dynamic>> processScoresheet({
    required File imageFile,
    required List<String> playerNames,
    required String groupId,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    final customDirectives = _ref.read(customAiPromptProvider);
    print('[AI] Procesando imagen con OpenAI (gpt-4o-mini)...');
    
    const url = 'https://api.openai.com/v1/chat/completions';

    Uint8List imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes().timeout(const Duration(seconds: 15));
    } catch (e) {
      print('[AI] Error leyendo archivo: $e');
      rethrow;
    }
    
    final base64Image = base64Encode(imageBytes);
    print('[AI] Imagen codificada. Enviando peticion a OpenAI...');

    final playerNamesStr = playerNames.join(', ');
    final prompt = '''
Analizá esta imagen de una planilla de puntuación del juego de cartas "La Podrida" (también llamada "Bazas").

Los jugadores de este grupo son: $playerNamesStr

Para CADA jugador, extraé:
1. player_name: El nombre del jugador (debe coincidir exactamente con uno de la lista)
2. raw_points: Los puntos totales acumulados en la planilla
3. exact_predictions: Cantidad de rondas donde predijo exactamente sus bazas (Efectividad)
4. osadia_bazas_won: Total de bazas GANADAS en rondas de Osadía.
5. requested_bazas: Total de bazas SOLICITADAS en rondas de Osadía.
6. position_in_match: Posición final (1=ganador, 2=segundo, etc.)
7. explanation: Una explicación breve paso a paso de qué números viste en la planilla para este jugador y cómo los sumaste (ej: "R1:10+R2:5=15").

Respondé ÚNICAMENTE con un objeto JSON con el siguiente formato:
{
  "total_rounds": 10,
  "players": [
    {
      "player_name": "NOMBRE",
      "raw_points": 0,
      "exact_predictions": 0,
      "requested_bazas": 0,
      "osadia_bazas_won": 0,
      "position_in_match": 1,
      "low_confidence": false,
      "explanation": "R1:10 + R2:5 = 15 total"
    }
  ]
}

Si no podés leer algún dato con claridad, ponelo en 0 y marcá "low_confidence": true. Analizá también el encabezado para ver cuántas rondas totales se jugaron (ej: de la 1 a la 10).

DIRECTRICES ADICIONALES DEL USUARIO:
$customDirectives
''';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': [
              { 'type': 'text', 'text': prompt },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                }
              }
            ]
          }
        ],
        'response_format': { 'type': 'json_object' },
        'max_tokens': 1000,
      }),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      print('[AI] Error OpenAI (${response.statusCode}): ${response.body}');
      throw Exception('Error en OpenAI API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final responseText = data['choices'][0]['message']['content'] as String;
    
    print('[AI] Respuesta recibida: ${responseText.length} caracteres');

    return jsonDecode(responseText) as Map<String, dynamic>;
  }
}

// Mantenemos el nombre del provider para no romper el resto de la app por ahora
// pero apuntando al nuevo servicio
final geminiScanServiceProvider = Provider<AiScanService>((ref) {
  return AiScanService(ref);
});
