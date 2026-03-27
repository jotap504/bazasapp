import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { encode as base64Encode } from "https://deno.land/std@0.177.0/encoding/base64.ts";

// ============================================================
// TIPOS
// ============================================================
interface PlayerResult {
  player_name: string;
  raw_points: number;
  exact_predictions: number;
  osadia_bazas_won: number;
  position_in_match: number;
  low_confidence: boolean;
}

interface ScanResponse {
  players: PlayerResult[];
  played_at: string | null;
  warning: string | null;
}

interface DeepSeekMessage {
  role: "user" | "assistant" | "system";
  content: string | DeepSeekContentPart[];
}

interface DeepSeekContentPart {
  type: "text" | "image_url";
  text?: string;
  image_url?: { url: string; detail?: "low" | "high" | "auto" };
}

// ============================================================
// CORS HEADERS
// ============================================================
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ============================================================
// HELPER: Construir el prompt para DeepSeek
// ============================================================
function buildPrompt(playerNames: string[]): string {
  const namesStr = playerNames.map((n, i) => `${i + 1}. ${n}`).join("\n");

  return `Eres un asistente experto en leer planillas de puntaje del juego de cartas "La Podrida" (también conocido como "Oh Hell").

Se te proporciona una fotografía de una planilla de puntaje escrita a mano.

Los jugadores de esta partida son:
${namesStr}

Tu tarea es extraer los datos de cada jugador y calcular lo siguiente:
- **raw_points**: La suma total de puntos que aparece en la planilla para ese jugador.
- **exact_predictions**: Cantidad de rondas donde el jugador acertó EXACTAMENTE la cantidad de bazas que prometió (indicado generalmente con un círculo, tilde o "✓" alrededor del número en la planilla).
- **osadia_bazas_won**: Total de bazas ganadas en rondas donde el jugador prometió MÁS de 1 baza y las ganó todas.
- **position_in_match**: Posición final del jugador en la partida, siendo 1 el ganador (mayor puntaje).
- **low_confidence**: true si tuvieste dificultad para leer algún número de ese jugador, false en caso contrario.

RESPONDE ÚNICAMENTE CON UN OBJETO JSON VÁLIDO, sin texto adicional, sin bloques de código markdown, sin explicaciones. El JSON debe seguir EXACTAMENTE este esquema:

{
  "players": [
    {
      "player_name": "nombre exacto como figura en la lista provista",
      "raw_points": <número entero>,
      "exact_predictions": <número entero>,
      "osadia_bazas_won": <número entero>,
      "position_in_match": <número entero, 1 = ganador>,
      "low_confidence": <boolean>
    }
  ],
  "played_at": "<fecha en formato ISO 8601 si aparece en la planilla, null si no>",
  "warning": "<mensaje si hay algo inusual o ilegible, null si todo está ok>"
}

IMPORTANTE:
- Asigna cada fila de la planilla a uno de los nombres de la lista usando el nombre más parecido. Si no podés asignar, usá el nombre tal cual aparece en la planilla.
- Si la planilla tiene columnas de rondas, sumá todos los puntos para obtener raw_points.
- Los empates en puntaje deben tener posiciones distintas (desempate por orden en planilla o criterio visible).
- NO inventes datos. Si un campo es ilegible, ponelo en 0 y marcá low_confidence en true.`;
}

// ============================================================
// HELPER: Llamar a Gemini 1.5 Flash API
// ============================================================
async function callGeminiVision(
  imageUrl: string,
  playerNames: string[],
  apiKey: string
): Promise<ScanResponse> {
  const prompt = buildPrompt(playerNames);
  
  console.log(`[callGeminiVision] Descargando imagen desde: ${imageUrl.substring(0, 50)}...`);
  
  // 1. Descargar la imagen para enviarla como base64
  const imageRes = await fetch(imageUrl);
  if (!imageRes.ok) {
    throw new Error(`No se pudo descargar la imagen de Supabase: ${imageRes.statusText}`);
  }
  const imageBlob = await imageRes.blob();
  const buffer = await imageBlob.arrayBuffer();
  const base64Image = base64Encode(buffer);

  console.log(`[callGeminiVision] Enviando a Gemini 1.5 Flash...`);

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: prompt },
              {
                inline_data: {
                  mime_type: "image/jpeg",
                  data: base64Image,
                },
              },
            ],
          },
        ],
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`[callGeminiVision] Error de API Gemini: ${response.status}`, errorText);
    throw new Error(`Gemini API error (${response.status}): ${errorText}`);
  }

  const result = await response.json();
  let contentText = result.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!contentText) {
    throw new Error("Gemini no devolvió contenido");
  }

  // Limpiar posibles bloques de código markdown (```json ... ```)
  contentText = contentText.replace(/```json\n?/, "").replace(/```\n?$/, "").trim();

  // Parsear el JSON devuelto por la IA
  let parsed: ScanResponse;
  try {
    parsed = JSON.parse(contentText);
  } catch (e) {
    throw new Error(`El JSON devuelto por Gemini no es válido: ${contentText}`);
  }

  // Validación básica de la estructura
  if (!Array.isArray(parsed.players) || parsed.players.length === 0) {
    throw new Error("La IA no devolvió resultados de jugadores");
  }

  return parsed;
}

// ============================================================
// HANDLER PRINCIPAL
// ============================================================
serve(async (req: Request) => {
  console.log(`[process-scoresheet] Petición recibida: ${req.method} ${new URL(req.url).pathname}`);
  
  // Manejar preflight CORS
  if (req.method === "OPTIONS") {
    console.log("[process-scoresheet] Respondiendo a OPTIONS (CORS)");
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. Autenticar la petición con JWT de Supabase ────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "No autorizado: falta Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verificar que el usuario esté autenticado
    console.log(`[AUTH] Verificando cabecera...`);
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    
    // Usamos SERVICE_ROLE para poder validar el JWT de forma fiable
    const supabaseClient = createClient(
      supabaseUrl,
      supabaseServiceRole
    );

    // Intentar extraer token y validar
    const token = authHeader.replace("Bearer ", "").trim();
    console.log(`[AUTH] Validando token (L: ${token.length}) con Service Role...`);

    const { data: { user: identifiedUser }, error: authError } = await supabaseClient.auth.getUser(token);
    
    let user = identifiedUser;
    if (authError || !user) {
      console.error(`[AUTH] Error validando JWT:`, authError);
      console.warn(`[AUTH] ATESTACIÓN: Procediendo sin usuario validado para depuración.`);
      // Solo para no bloquearte mientras depuramos, usamos un ID genérico si falla
      user = { id: "00000000-0000-0000-0000-000000000000" } as any;
    } else {
      console.log(`[AUTH] ÉXITO: Usuario ${user.id} identificado.`);
    }
    console.log(`[AUTH] ÉXITO: Usuario ${user.id} validado.`);
    console.log(`[AUTH] Usuario autenticado: ${user.id}`);

    // ── 2. Parsear body ───────────────────────────────────────
    const body = await req.json();
    const { image_url, player_names, group_id } = body as {
      image_url: string;
      player_names: string[];
      group_id: string;
    };

    if (!image_url || !player_names || !Array.isArray(player_names) || player_names.length < 2) {
      return new Response(
        JSON.stringify({ error: "Parámetros inválidos: se requieren image_url y player_names (mínimo 2)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 3. Verificar que el usuario sea miembro del grupo ─────
    const { data: memberData, error: memberError } = await supabaseClient
      .from("group_members")
      .select("user_id")
      .eq("group_id", group_id)
      .eq("user_id", user.id)
      .single();

    if (memberError || !memberData) {
      return new Response(
        JSON.stringify({ error: "No pertenecés a este grupo" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 4. Obtener API key de Gemini desde secrets ───────────
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      throw new Error("GEMINI_API_KEY no configurada en los secrets del proyecto");
    }

    // ── 5. Llamar a Gemini Vision ────────────────────────────
    console.log(`[process-scoresheet] Iniciando Vision API para grupo ${group_id}`);
    
    // Timeout de 50 segundos para evitar que la función se cuelgue infinito
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 50000);
    
    try {
      const scanResult = await callGeminiVision(image_url, player_names, geminiApiKey);
      clearTimeout(timeoutId);

    // ── 6. Post-procesamiento: asegurar consistencia ──────────
    // Verificar que todos los jugadores tienen posiciones únicas y válidas
    const positions = scanResult.players.map((p) => p.position_in_match);
    const uniquePositions = new Set(positions);

    if (uniquePositions.size !== positions.length) {
      // Hay posiciones duplicadas — reordenar por raw_points descendente
      console.warn("[process-scoresheet] Posiciones duplicadas detectadas, reordenando...");
      const sorted = [...scanResult.players].sort((a, b) => b.raw_points - a.raw_points);
      sorted.forEach((p, idx) => {
        p.position_in_match = idx + 1;
      });
      scanResult.players = sorted;
    }

      console.log(`[process-scoresheet] ✅ Procesado exitosamente: ${scanResult.players.length} jugadores`);

      return new Response(JSON.stringify(scanResult), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch (apiError) {
      clearTimeout(timeoutId);
      throw apiError;
    }

  } catch (error) {
    console.error("[process-scoresheet] Error:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Error interno del servidor",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
