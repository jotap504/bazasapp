-- ============================================================
-- MIGRACIÓN 020: Fix Double Trigger y Exclusión de Admin
-- ============================================================

-- 1. Eliminar triggers redundantes que causan duplicación de puntos
DROP TRIGGER IF EXISTS trigger_update_member_stats ON public.match_results;
DROP TRIGGER IF EXISTS trg_update_member_stats ON public.match_results;
DROP TRIGGER IF EXISTS trg_match_results_insert ON public.match_results;

-- 2. Asegurar que SOLO exista trg_match_results_update_stats (de migración 018/FINAL)
-- Si no existe, lo recreamos (copiado de FINAL_UPGRADE.sql por seguridad)
DROP TRIGGER IF EXISTS trg_match_results_update_stats ON public.match_results;
CREATE TRIGGER trg_match_results_update_stats
    BEFORE INSERT ON public.match_results
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_stats_v2();

-- 3. Limpiar cualquier trigger de borrado viejo en match_results
DROP TRIGGER IF EXISTS trg_match_results_delete_stats ON public.match_results;
DROP TRIGGER IF EXISTS trigger_delete_member_stats ON public.match_results;

-- 4. Asegurar que el trigger de borrado de matches sea el correcto
DROP TRIGGER IF EXISTS trg_matches_sync_count_delete ON public.matches;
CREATE TRIGGER trg_matches_sync_count_delete
    BEFORE DELETE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

-- NOTA: Se recomienda ejecutar 'SELECT recalculate_all_group_stats(group_id)' 
-- manualment para cada liga después de esto para normalizar los puntos duplicados.
