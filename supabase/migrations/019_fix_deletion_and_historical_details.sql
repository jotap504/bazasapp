-- ============================================================
-- MIGRACIÓN 019: Corrección de Borrado y Soporte Histórico
-- ============================================================

-- 1. Eliminar el trigger problemático en match_results
DROP TRIGGER IF EXISTS trg_match_results_delete_stats ON public.match_results;

-- 2. Crear función robusta para descontar estadísticas de una partida completa
CREATE OR REPLACE FUNCTION public.discount_match_results_stats(p_match_id UUID, p_group_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    r RECORD;
    v_target_member_id UUID;
BEGIN
    -- Iterar sobre cada resultado de la partida antes de que se borren (o usando el OLD de matches)
    -- Pero como se borran en cascada, necesitamos capturarlos ANTES.
    -- La mejor forma es llamar a esto desde un trigger BEFORE DELETE en matches.
    
    FOR r IN (SELECT * FROM public.match_results WHERE match_id = p_match_id) LOOP
        -- Identificar miembro de forma segura con el group_id garantizado
        IF r.user_id IS NOT NULL THEN
            SELECT id INTO v_target_member_id FROM public.group_members 
            WHERE group_id = p_group_id AND user_id = r.user_id;
        ELSE
            v_target_member_id := r.guest_member_id;
        END IF;

        IF v_target_member_id IS NOT NULL THEN
            UPDATE public.group_members SET
                total_championship_points = total_championship_points - r.earned_championship_points,
                sum_accuracy_percent = sum_accuracy_percent - r.accuracy_percent,
                count_accuracy_matches = count_accuracy_matches - 1,
                effective_avg_percent = CASE 
                    WHEN (count_accuracy_matches - 1) > 0 
                    THEN (sum_accuracy_percent - r.accuracy_percent) / (count_accuracy_matches - 1)
                    ELSE 0 END,
                total_osadia_points = total_osadia_points - r.osadia_points,
                total_matches_played = total_matches_played - 1,
                total_wins = total_wins - CASE WHEN r.position_in_match = 1 THEN 1 ELSE 0 END,
                updated_at = NOW()
            WHERE id = v_target_member_id;
        END IF;
    END LOOP;
END;
$$;

-- 3. Actualizar el trigger de matches para incluir el descuento de estadísticas
CREATE OR REPLACE FUNCTION public.sync_group_match_count_v2()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_official THEN
        UPDATE public.groups SET match_count = match_count + 1 WHERE id = NEW.group_id;
    ELSIF TG_OP = 'DELETE' AND OLD.is_official THEN
        -- 1. Descontar puntos de todos los jugadores de esta partida
        PERFORM public.discount_match_results_stats(OLD.id, OLD.group_id);
        
        -- 2. Decrementar el contador global
        UPDATE public.groups SET match_count = GREATEST(0, match_count - 1) WHERE id = OLD.group_id;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Reemplazar trigger trg_matches_sync_count (Separados por sintaxis de PG)
DROP TRIGGER IF EXISTS trg_matches_sync_count ON public.matches;
DROP TRIGGER IF EXISTS trg_matches_sync_count_insert ON public.matches;
DROP TRIGGER IF EXISTS trg_matches_sync_count_delete ON public.matches;

CREATE TRIGGER trg_matches_sync_count_insert
    AFTER INSERT ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

CREATE TRIGGER trg_matches_sync_count_delete
    BEFORE DELETE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

-- 5. Sincronización Final: Saneamiento para Jota (o cualquier error previo)
-- Si ya hubo borrados fallidos, ejecutamos el recalculate global para el grupo afectado (si supiéramos el ID)
-- Pero por ahora, el usuario puede ejecutar RECALCULATE_ALL_GROUP_STATS desde la app si lo desea.
