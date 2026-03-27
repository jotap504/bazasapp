-- ============================================================
-- FINAL UPGRADE: Bazas App
-- Este script consolida las migraciones 012, 013, 014 y 015.
-- Ejecutar en el SQL Editor de Supabase.
-- ============================================================

-- 1. INFRAESTRUCTURA DE CIERRE Y CONTEO (Migraciones 012 y 014)
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS match_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.group_members 
ADD COLUMN IF NOT EXISTS total_failed_osadia INTEGER NOT NULL DEFAULT 0;

-- 2. SOPORTE PARA EMPATES (Migración 015)
-- Eliminar la restricción que impedía posicionar a dos personas en el mismo lugar
DO $$ 
DECLARE r_name TEXT;
BEGIN
    SELECT conname INTO r_name FROM pg_constraint 
    WHERE conrelid = 'public.match_results'::regclass AND contype = 'u' 
      AND substring(pg_get_constraintdef(oid) from '\((.*)\)') = 'match_id, position_in_match';
    IF r_name IS NOT NULL THEN EXECUTE 'ALTER TABLE public.match_results DROP CONSTRAINT ' || r_name; END IF;
EXCEPTION WHEN OTHERS THEN 
    -- Si falla, intentamos por nombre estándar
    ALTER TABLE public.match_results DROP CONSTRAINT IF EXISTS match_results_match_id_position_in_match_key;
END $$;
-- 3. FUNCIONES DE CÓMPUTO Y TRIGGERS (Refactorizado Migración 018)

-- Función para puntos de campeonato (Solo Posición)
CREATE OR REPLACE FUNCTION public.calculate_championship_points_v2(
    p_group_id UUID,
    p_position INTEGER
)
RETURNS DECIMAL(10,2) LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_points_array JSONB;
BEGIN
    SELECT f1_points_system INTO v_points_array FROM public.groups WHERE id = p_group_id;
    IF v_points_array IS NOT NULL AND p_position >= 1 AND p_position <= jsonb_array_length(v_points_array) THEN
        RETURN (v_points_array -> (p_position - 1))::DECIMAL;
    END IF;
    RETURN 0;
END;
$$;

-- Función para actualizar acumulados (INSERT)
CREATE OR REPLACE FUNCTION public.update_group_member_stats_v2()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
    v_target_member_id UUID;
    v_total_rounds INTEGER;
    v_osadia_mult DECIMAL(10,2);
BEGIN
    SELECT g.id, m.is_official, g.osadia_multiplier
    INTO v_group_id, v_is_official, v_osadia_mult
    FROM public.matches m JOIN public.groups g ON g.id = m.group_id WHERE m.id = NEW.match_id;

    v_total_rounds := COALESCE(NEW.total_match_rounds, 10);

    -- Cálculos
    NEW.earned_championship_points := public.calculate_championship_points_v2(v_group_id, NEW.position_in_match);
    NEW.accuracy_percent := CASE WHEN v_total_rounds > 0 THEN (NEW.exact_predictions::DECIMAL / v_total_rounds::DECIMAL) * 100 ELSE 0 END;
    NEW.osadia_points := (NEW.osadia_bazas_won::DECIMAL * v_osadia_mult::DECIMAL)::INTEGER;

    IF NEW.user_id IS NOT NULL THEN
        SELECT id INTO v_target_member_id FROM public.group_members WHERE group_id = v_group_id AND user_id = NEW.user_id;
    ELSE
        v_target_member_id := NEW.guest_member_id;
    END IF;

    IF v_is_official AND v_target_member_id IS NOT NULL THEN
        UPDATE public.group_members SET
            total_championship_points = total_championship_points + NEW.earned_championship_points,
            sum_accuracy_percent = sum_accuracy_percent + NEW.accuracy_percent,
            count_accuracy_matches = count_accuracy_matches + 1,
            effective_avg_percent = (sum_accuracy_percent + NEW.accuracy_percent) / (count_accuracy_matches + 1),
            total_osadia_points = total_osadia_points + NEW.osadia_points,
            total_matches_played = total_matches_played + 1,
            total_wins = total_wins + CASE WHEN NEW.position_in_match = 1 THEN 1 ELSE 0 END,
            updated_at = NOW()
        WHERE id = v_target_member_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_match_results_update_stats ON public.match_results;
CREATE TRIGGER trg_match_results_update_stats
    BEFORE INSERT ON public.match_results
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_stats_v2();

-- Función para descontar acumulados de una partida completa (Mover a Matches para fiabilidad)
CREATE OR REPLACE FUNCTION public.discount_match_results_stats(p_match_id UUID, p_group_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    r RECORD;
    v_target_member_id UUID;
BEGIN
    FOR r IN (SELECT * FROM public.match_results WHERE match_id = p_match_id) LOOP
        IF r.user_id IS NOT NULL THEN
            SELECT id INTO v_target_member_id FROM public.group_members WHERE group_id = p_group_id AND user_id = r.user_id;
        ELSE
            v_target_member_id := r.guest_member_id;
        END IF;

        IF v_target_member_id IS NOT NULL THEN
            UPDATE public.group_members SET
                total_championship_points = total_championship_points - r.earned_championship_points,
                sum_accuracy_percent = sum_accuracy_percent - r.accuracy_percent,
                count_accuracy_matches = count_accuracy_matches - 1,
                effective_avg_percent = CASE WHEN (count_accuracy_matches - 1) > 0 THEN (sum_accuracy_percent - r.accuracy_percent) / (count_accuracy_matches - 1) ELSE 0 END,
                total_osadia_points = total_osadia_points - r.osadia_points,
                total_matches_played = total_matches_played - 1,
                total_wins = total_wins - CASE WHEN r.position_in_match = 1 THEN 1 ELSE 0 END,
                updated_at = NOW()
            WHERE id = v_target_member_id;
        END IF;
    END LOOP;
END;
$$;

-- 4. GESTIÓN DE MATCH_COUNT Y ESTADÍSTICAS EN MATCHES
CREATE OR REPLACE FUNCTION public.sync_group_match_count_v2()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_official THEN
        UPDATE public.groups SET match_count = match_count + 1 WHERE id = NEW.group_id;
    ELSIF TG_OP = 'DELETE' AND OLD.is_official THEN
        PERFORM public.discount_match_results_stats(OLD.id, OLD.group_id);
        UPDATE public.groups SET match_count = GREATEST(0, match_count - 1) WHERE id = OLD.group_id;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_matches_sync_count ON public.matches;
DROP TRIGGER IF EXISTS trg_matches_sync_count_insert ON public.matches;
DROP TRIGGER IF EXISTS trg_matches_sync_count_delete ON public.matches;

CREATE TRIGGER trg_matches_sync_count_insert
    AFTER INSERT ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

CREATE TRIGGER trg_matches_sync_count_delete
    BEFORE DELETE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count_v2();

-- Eliminar trigger redundante si existía
DROP TRIGGER IF EXISTS trg_match_results_delete_stats ON public.match_results;

-- 5. FUNCIONES DE UTILIDAD (Cerrar Liga y Reset)
CREATE OR REPLACE FUNCTION public.close_group(p_group_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.groups
    SET status = 'closed', closed_at = NOW(), updated_at = NOW()
    WHERE id = p_group_id AND status != 'closed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.reset_group_stats(p_group_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.group_members
    SET total_championship_points = 0, total_matches_played = 0, total_osadia_points = 0,
        total_efectividad_points = 0, total_wins = 0, sum_accuracy_percent = 0,
        count_accuracy_matches = 0, effective_avg_percent = 0, total_failed_osadia = 0,
        current_position = NULL, previous_position = NULL, updated_at = NOW()
    WHERE group_id = p_group_id;

    UPDATE public.groups SET match_count = 0, updated_at = NOW() WHERE id = p_group_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Sincronización inicial de contadores
UPDATE public.groups g SET match_count = (SELECT count(*) FROM public.matches m WHERE m.group_id = g.id AND m.is_official = TRUE);

-- 6. SEGURIDAD RLS
ALTER TABLE public.match_results ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "match_results_owner_all" ON public.match_results;
CREATE POLICY "match_results_owner_all" ON public.match_results FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.matches WHERE id = match_id AND created_by = auth.uid()));
DROP POLICY IF EXISTS "match_results_admin_all" ON public.match_results;
CREATE POLICY "match_results_admin_all" ON public.match_results FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.group_members gm JOIN public.matches m ON m.group_id = gm.group_id WHERE m.id = match_results.match_id AND gm.user_id = auth.uid() AND gm.role = 'admin'));

-- 7. FUNCIÓN DE SANACIÓN GLOBAL (Heal)
CREATE OR REPLACE FUNCTION public.recalculate_all_group_stats(p_group_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_osadia_mult DECIMAL(10,2);
BEGIN
    SELECT osadia_multiplier INTO v_osadia_mult FROM public.groups WHERE id = p_group_id;

    UPDATE public.group_members SET
        total_championship_points = 0, total_matches_played = 0, total_osadia_points = 0,
        total_wins = 0, sum_accuracy_percent = 0,
        count_accuracy_matches = 0, effective_avg_percent = 0, updated_at = NOW()
    WHERE group_id = p_group_id;

    UPDATE public.groups SET match_count = (SELECT COUNT(*) FROM public.matches WHERE group_id = p_group_id AND is_official = TRUE), updated_at = NOW() WHERE id = p_group_id;

    -- Actualizar resultados individuales con las nuevas reglas antes de sumar
    UPDATE public.match_results res
    SET osadia_points = (res.osadia_bazas_won::DECIMAL * v_osadia_mult::DECIMAL)::INTEGER,
        earned_championship_points = public.calculate_championship_points_v2(p_group_id, res.position_in_match)
    FROM public.matches m WHERE m.id = res.match_id AND m.group_id = p_group_id;

    UPDATE public.group_members gm SET
        total_championship_points = sub.sum_points, total_matches_played = sub.count_matches,
        total_osadia_points = sub.sum_osadia, sum_accuracy_percent = sub.sum_accuracy,
        count_accuracy_matches = sub.count_matches,
        effective_avg_percent = CASE WHEN sub.count_matches > 0 THEN sub.sum_accuracy / sub.count_matches ELSE 0 END,
        total_wins = sub.sum_wins, updated_at = NOW()
    FROM (
        SELECT res.user_id, res.guest_member_id, SUM(res.earned_championship_points) as sum_points,
               SUM(res.osadia_points) as sum_osadia, SUM(res.accuracy_percent) as sum_accuracy,
               COUNT(*) as count_matches,
               SUM(CASE WHEN res.position_in_match = 1 THEN 1 ELSE 0 END) as sum_wins
        FROM public.match_results res JOIN public.matches m ON m.id = res.match_id
        WHERE m.group_id = p_group_id AND m.is_official = TRUE
        GROUP BY res.user_id, res.guest_member_id
    ) sub
    WHERE gm.group_id = p_group_id AND ((gm.user_id = sub.user_id AND sub.user_id IS NOT NULL) OR (gm.id = sub.guest_member_id AND sub.guest_member_id IS NOT NULL));

    PERFORM public.recalculate_group_positions(p_group_id);
END;
$$;
