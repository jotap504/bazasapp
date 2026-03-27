-- ============================================================
-- MIGRACIÓN 021: El Chamullero - Hall of Fame
-- ============================================================
-- "El Chamullero" es el jugador con mayor acumulado de bazas
-- solicitadas menos bazas ganadas: SUM(requested_bazas - osadia_bazas_won)

-- 1. Agregar columna a group_members
ALTER TABLE public.group_members
ADD COLUMN IF NOT EXISTS total_chamullero_score INTEGER NOT NULL DEFAULT 0;

-- 2. Actualizar la función de INSERT para acumular el score
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
            -- El Chamullero: acumula la diferencia (pedidas - ganadas)
            total_chamullero_score = total_chamullero_score + GREATEST(0, COALESCE(NEW.requested_bazas, 0) - COALESCE(NEW.osadia_bazas_won, 0)),
            updated_at = NOW()
        WHERE id = v_target_member_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 3. Actualizar la función de descuento (DELETE) para restar el score
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
                total_chamullero_score = GREATEST(0, total_chamullero_score - GREATEST(0, COALESCE(r.requested_bazas, 0) - COALESCE(r.osadia_bazas_won, 0))),
                updated_at = NOW()
            WHERE id = v_target_member_id;
        END IF;
    END LOOP;
END;
$$;

-- 4. Actualizar la función de sanación para recalcular el score
CREATE OR REPLACE FUNCTION public.recalculate_all_group_stats(p_group_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_osadia_mult DECIMAL(10,2);
BEGIN
    SELECT osadia_multiplier INTO v_osadia_mult FROM public.groups WHERE id = p_group_id;

    UPDATE public.group_members
    SET total_championship_points = 0, total_matches_played = 0, total_osadia_points = 0,
        total_wins = 0, sum_accuracy_percent = 0, count_accuracy_matches = 0,
        effective_avg_percent = 0, total_chamullero_score = 0, updated_at = NOW()
    WHERE group_id = p_group_id;

    UPDATE public.match_results res
    SET osadia_points = (res.osadia_bazas_won::DECIMAL * v_osadia_mult::DECIMAL)::INTEGER,
        earned_championship_points = public.calculate_championship_points_v2(p_group_id, res.position_in_match)
    FROM public.matches m WHERE m.id = res.match_id AND m.group_id = p_group_id;

    UPDATE public.group_members gm
    SET
        total_championship_points = sub.sum_points,
        total_matches_played = sub.count_matches,
        total_osadia_points = sub.sum_osadia,
        sum_accuracy_percent = sub.sum_accuracy,
        count_accuracy_matches = sub.count_matches,
        effective_avg_percent = CASE WHEN sub.count_matches > 0 THEN sub.sum_accuracy / sub.count_matches ELSE 0 END,
        total_wins = sub.sum_wins,
        total_chamullero_score = sub.sum_chamullero,
        updated_at = NOW()
    FROM (
        SELECT
            res.user_id, res.guest_member_id,
            SUM(res.earned_championship_points) as sum_points,
            SUM(res.osadia_points) as sum_osadia,
            SUM(res.accuracy_percent) as sum_accuracy,
            COUNT(*) as count_matches,
            SUM(CASE WHEN res.position_in_match = 1 THEN 1 ELSE 0 END) as sum_wins,
            SUM(GREATEST(0, COALESCE(res.requested_bazas, 0) - COALESCE(res.osadia_bazas_won, 0))) as sum_chamullero
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

    UPDATE public.groups SET match_count = (SELECT COUNT(*) FROM public.matches WHERE group_id = p_group_id AND is_official = TRUE), updated_at = NOW() WHERE id = p_group_id;
    PERFORM public.recalculate_group_positions(p_group_id);
END;
$$;
