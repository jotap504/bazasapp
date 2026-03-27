-- ============================================================
-- SCRIPT DE RESET MAESTRO (BORRADO TOTAL DE COMPETENCIA)
-- ============================================================
-- ATENCIÓN: Este script borra TODAS las partidas y resultados de TODAS las ligas.
-- Úsalo para empezar de cero con el sistema de puntuación corregido.

-- 1. Borrar todas las partidas (esto borrará resultados por CASCADE si está configurado)
TRUNCATE public.match_results CASCADE;
TRUNCATE public.matches CASCADE;

-- 2. Resetear todos los contadores de los miembros (Ranking a 0)
UPDATE public.group_members 
SET 
    total_championship_points = 0,
    total_matches_played = 0,
    total_osadia_points = 0,
    total_wins = 0,
    sum_accuracy_percent = 0,
    count_accuracy_matches = 0,
    effective_avg_percent = 0,
    total_failed_osadia = 0,
    current_position = NULL,
    previous_position = NULL,
    updated_at = NOW();

-- 3. Resetear contadores de las ligas
UPDATE public.groups 
SET 
    match_count = 0,
    status = 'open',
    closed_at = NULL,
    updated_at = NOW();

-- 4. Limpiar almacenamiento (Opcional, si quieres borrar fotos de planillas)
-- Solo se puede hacer desde el Dashboard de Supabase (Storage > buckets > scoresheets).
