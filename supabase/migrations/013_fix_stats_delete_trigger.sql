-- ============================================================
-- MIGRACIÓN 013: ACTIVAR TRIGGERS DE BORRADO Y CORRECCIÓN DE ACUMULADOS
-- ============================================================

-- 1. Activar el trigger de decremento en match_results (Faltaba en la 012)
DROP TRIGGER IF EXISTS trg_match_results_delete_stats ON public.match_results;
CREATE TRIGGER trg_match_results_delete_stats
    AFTER DELETE ON public.match_results
    FOR EACH ROW
    EXECUTE FUNCTION public.update_group_member_stats_on_delete();

-- 2. Función para decremento de match_count en la tabla groups
CREATE OR REPLACE FUNCTION public.update_group_match_count_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_official THEN
        UPDATE public.groups 
        SET match_count = GREATEST(0, match_count - 1),
            updated_at = NOW()
        WHERE id = OLD.group_id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Activar el trigger de decremento en matches
DROP TRIGGER IF EXISTS trg_matches_delete_count ON public.matches;
CREATE TRIGGER trg_matches_delete_count
    AFTER DELETE ON public.matches
    FOR EACH ROW 
    EXECUTE FUNCTION public.update_group_match_count_on_delete();

-- 4. Mejora de reset_group_stats para ser más profundo
CREATE OR REPLACE FUNCTION public.reset_group_stats(p_group_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Limpiar acumulados de miembros
    UPDATE public.group_members
    SET
        total_championship_points = 0,
        total_matches_played = 0,
        total_osadia_points = 0,
        total_efectividad_points = 0,
        total_wins = 0,
        sum_accuracy_percent = 0,
        count_accuracy_matches = 0,
        effective_avg_percent = 0,
        total_failed_osadia = 0,
        current_position = NULL,
        previous_position = NULL,
        updated_at = NOW()
    WHERE group_id = p_group_id;

    -- Reiniciar contador de partidas en el grupo
    UPDATE public.groups
    SET match_count = 0,
        updated_at = NOW()
    WHERE id = p_group_id;
END;
$$;
