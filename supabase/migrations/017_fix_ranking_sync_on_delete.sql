    -- ============================================================
    -- MIGRACIÓN 017: Corrección de Sincronización de Ranking al Borrar
    -- ============================================================

    -- 0. Normalización de nombres de columnas (Estandarizar a guest_member_id)
    DO $$ 
    BEGIN 
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'match_results' AND column_name = 'group_member_id'
        ) THEN
            ALTER TABLE public.match_results RENAME COLUMN group_member_id TO guest_member_id;
        END IF;
    END $$;

    -- 1. Redefinir función de descuento (DELETE)
CREATE OR REPLACE FUNCTION public.update_group_member_stats_on_delete()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
    v_target_member_id UUID;
    v_failed_dec INTEGER := 0;
BEGIN
    SELECT group_id, is_official INTO v_group_id, v_is_official
    FROM public.matches WHERE id = OLD.match_id;

    IF v_group_id IS NULL AND OLD.guest_member_id IS NOT NULL THEN
        SELECT group_id INTO v_group_id FROM public.group_members WHERE id = OLD.guest_member_id;
    END IF;

    IF (v_is_official IS NOT FALSE) AND v_group_id IS NOT NULL THEN
        IF OLD.requested_bazas > 0 AND OLD.requested_bazas != OLD.osadia_bazas_won THEN
            v_failed_dec := 1;
        END IF;

        IF OLD.user_id IS NOT NULL THEN
            SELECT id INTO v_target_member_id FROM public.group_members 
            WHERE group_id = v_group_id AND user_id = OLD.user_id;
        ELSE
            v_target_member_id := OLD.guest_member_id;
        END IF;

        IF v_target_member_id IS NOT NULL THEN
            UPDATE public.group_members SET
                total_championship_points = total_championship_points - OLD.earned_championship_points,
                sum_accuracy_percent = sum_accuracy_percent - OLD.accuracy_percent,
                count_accuracy_matches = count_accuracy_matches - 1,
                effective_avg_percent = CASE WHEN (count_accuracy_matches - 1) > 0 THEN (sum_accuracy_percent - OLD.accuracy_percent) / (count_accuracy_matches - 1) ELSE 0 END,
                total_osadia_points = total_osadia_points - OLD.osadia_points,
                total_failed_osadia = total_failed_osadia - v_failed_dec,
                total_matches_played = total_matches_played - 1,
                total_wins = total_wins - CASE WHEN OLD.position_in_match = 1 THEN 1 ELSE 0 END,
                updated_at = NOW()
            WHERE id = v_target_member_id;
        END IF;
    END IF;
    RETURN OLD;
END;
$$;

-- 1.5 Redefinir función de incremento (INSERT) - ARREGLA ERROR "group_member_id"
CREATE OR REPLACE FUNCTION public.update_group_member_stats_v2()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
    v_target_member_id UUID;
    v_total_rounds INTEGER;
    v_failed_inc INTEGER := 0;
BEGIN
    SELECT group_id, is_official INTO v_group_id, v_is_official
    FROM public.matches WHERE id = NEW.match_id;

    v_total_rounds := COALESCE(NEW.total_match_rounds, 10);
    NEW.earned_championship_points := public.calculate_championship_points_v2(v_group_id, NEW.position_in_match);

    IF v_total_rounds > 0 THEN
        NEW.accuracy_percent := (NEW.exact_predictions::DECIMAL / v_total_rounds::DECIMAL) * 100;
    ELSE
        NEW.accuracy_percent := 0;
    END IF;

    IF NEW.requested_bazas IS NOT NULL AND NEW.requested_bazas = NEW.osadia_bazas_won THEN
        NEW.osadia_points := NEW.requested_bazas;
    ELSIF NEW.requested_bazas > 0 THEN
        NEW.osadia_points := 0;
        v_failed_inc := 1;
    ELSE
        NEW.osadia_points := 0;
    END IF;

    IF NEW.user_id IS NOT NULL THEN
        SELECT id INTO v_target_member_id FROM public.group_members 
        WHERE group_id = v_group_id AND user_id = NEW.user_id;
    ELSE
        -- USAMOS EL NUEVO NOMBRE DE COLUMNA
        v_target_member_id := NEW.guest_member_id;
    END IF;

    IF v_is_official AND v_target_member_id IS NOT NULL THEN
        UPDATE public.group_members SET
            total_championship_points = total_championship_points + NEW.earned_championship_points,
            sum_accuracy_percent = sum_accuracy_percent + NEW.accuracy_percent,
            count_accuracy_matches = count_accuracy_matches + 1,
            effective_avg_percent = (sum_accuracy_percent + NEW.accuracy_percent) / (count_accuracy_matches + 1),
            total_osadia_points = total_osadia_points + NEW.osadia_points,
            total_failed_osadia = total_failed_osadia + v_failed_inc,
            total_matches_played = total_matches_played + 1,
            total_wins = total_wins + CASE WHEN NEW.position_in_match = 1 THEN 1 ELSE 0 END,
            updated_at = NOW()
        WHERE id = v_target_member_id;
    END IF;
    RETURN NEW;
END;
$$;

    -- 2. Cambiar el trigger de AFTER a BEFORE DELETE
    DROP TRIGGER IF EXISTS trg_match_results_delete_stats ON public.match_results;
    CREATE TRIGGER trg_match_results_delete_stats
        BEFORE DELETE ON public.match_results
        FOR EACH ROW
        EXECUTE FUNCTION public.update_group_member_stats_on_delete();

    -- 3. Función de SANACIÓN PROFUNDA (Heal)
    CREATE OR REPLACE FUNCTION public.recalculate_all_group_stats(p_group_id UUID)
    RETURNS VOID
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS $$
    BEGIN
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

        UPDATE public.groups
        SET match_count = (SELECT COUNT(*) FROM public.matches WHERE group_id = p_group_id AND is_official = TRUE),
            updated_at = NOW()
        WHERE id = p_group_id;

        UPDATE public.group_members gm
        SET
            total_championship_points = sub.sum_points,
            total_matches_played = sub.count_matches,
            total_osadia_points = sub.sum_osadia,
            sum_accuracy_percent = sub.sum_accuracy,
            count_accuracy_matches = sub.count_matches,
            effective_avg_percent = CASE WHEN sub.count_matches > 0 THEN sub.sum_accuracy / sub.count_matches ELSE 0 END,
            total_failed_osadia = sub.sum_failed_osadia,
            total_wins = sub.sum_wins,
            updated_at = NOW()
        FROM (
            SELECT 
                res.user_id,
                res.guest_member_id,
                SUM(res.earned_championship_points) as sum_points,
                SUM(res.osadia_points) as sum_osadia,
                SUM(res.accuracy_percent) as sum_accuracy,
                COUNT(*) as count_matches,
                SUM(CASE WHEN res.requested_bazas > 0 AND res.requested_bazas != res.osadia_bazas_won THEN 1 ELSE 0 END) as sum_failed_osadia,
                SUM(CASE WHEN res.position_in_match = 1 THEN 1 ELSE 0 END) as sum_wins
            FROM public.match_results res
            JOIN public.matches m ON m.id = res.match_id
            WHERE m.group_id = p_group_id AND m.is_official = TRUE
            GROUP BY res.user_id, res.guest_member_id
        ) sub
        WHERE gm.group_id = p_group_id 
        AND (
            (gm.user_id = sub.user_id AND sub.user_id IS NOT NULL) OR 
            (gm.id = sub.guest_member_id AND sub.guest_member_id IS NOT NULL)
        );

        PERFORM public.recalculate_group_positions(p_group_id);
    END;
    $$;
