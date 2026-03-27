-- ============================================================
-- SCRIPT NUCLEAR: ELIMINA ABSOLUTAMENTE TODOS LOS TRIGGERS
-- EN match_results Y RECREA SOLO EL CORRECTO.
-- ============================================================

-- PASO 1: Ver todos los triggers activos (para diagnóstico)
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE event_object_table = 'match_results'
   OR event_object_table = 'matches';

-- ============================================================
-- PASO 2: Eliminar TODOS los triggers en match_results
-- independientemente del nombre
-- ============================================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT trigger_name 
        FROM information_schema.triggers 
        WHERE event_object_schema = 'public' 
          AND event_object_table = 'match_results'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON public.match_results CASCADE';
        RAISE NOTICE 'Eliminado trigger: %', r.trigger_name;
    END LOOP;
END $$;

-- PASO 3: Eliminar todos los triggers en matches (para match_count)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT trigger_name 
        FROM information_schema.triggers 
        WHERE event_object_schema = 'public' 
          AND event_object_table = 'matches'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON public.matches CASCADE';
        RAISE NOTICE 'Eliminado trigger en matches: %', r.trigger_name;
    END LOOP;
END $$;

-- ============================================================
-- PASO 4: Recrear SOLO el trigger de INSERT correcto
-- ============================================================
CREATE TRIGGER trg_match_results_update_stats
    BEFORE INSERT ON public.match_results
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_stats_v2();

-- PASO 5: Recrear el trigger de DELETE correcto en matches
CREATE TRIGGER trg_matches_sync_count_insert
    AFTER INSERT ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

CREATE TRIGGER trg_matches_sync_count_delete
    BEFORE DELETE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

-- ============================================================
-- PASO 6: Resetear todos los datos
-- ============================================================
TRUNCATE public.match_results CASCADE;
TRUNCATE public.matches CASCADE;

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

UPDATE public.groups 
SET 
    match_count = 0,
    status = 'open',
    closed_at = NULL,
    updated_at = NOW();

-- PASO 7: Confirmar triggers activos después del fix
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE event_object_table IN ('match_results', 'matches');
