-- ============================================================
-- MIGRACIÓN 018: Refactorización Total de Lógica de Puntos
-- ============================================================

-- 1. Redefinir cálculo de puntos de campeonato (Solo Posición F1)
CREATE OR REPLACE FUNCTION public.calculate_championship_points_v2(
    p_group_id UUID,
    p_position INTEGER
)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
STABLE
AS $$
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

-- 2. Redefinir TRIGGER de inserción con la nueva lógica (Efectividad % y Osadía Won*Mult)
CREATE OR REPLACE FUNCTION public.update_group_member_stats_v2()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
    v_target_member_id UUID;
    v_total_rounds INTEGER;
    v_osadia_mult DECIMAL(10,2);
BEGIN
    -- A. Obtener datos de la partida y configuración del grupo
    SELECT g.id, m.is_official, g.osadia_multiplier
    INTO v_group_id, v_is_official, v_osadia_mult
    FROM public.matches m
    JOIN public.groups g ON g.id = m.group_id
    WHERE m.id = NEW.match_id;

    v_total_rounds := COALESCE(NEW.total_match_rounds, 10);

    -- B. Cálculos Individuales (SQL UPDATES de la fila NEW)
    -- 1. Puntos Campeonato: Solo Posición
    NEW.earned_championship_points := public.calculate_championship_points_v2(v_group_id, NEW.position_in_match);

    -- 2. Efectividad %: (Acertadas / Total Rondas) * 100
    IF v_total_rounds > 0 THEN
        NEW.accuracy_percent := (NEW.exact_predictions::DECIMAL / v_total_rounds::DECIMAL) * 100;
    ELSE
        NEW.accuracy_percent := 0;
    END IF;

    -- 3. Puntos Osadía: Bazas Ganadas * Multiplicador (Se suma al ranking de osadía)
    NEW.osadia_points := (NEW.osadia_bazas_won::DECIMAL * v_osadia_mult::DECIMAL)::INTEGER;

    -- C. Identificar miembro
    IF NEW.user_id IS NOT NULL THEN
        SELECT id INTO v_target_member_id FROM public.group_members 
        WHERE group_id = v_group_id AND user_id = NEW.user_id;
    ELSE
        v_target_member_id := NEW.guest_member_id;
    END IF;

    -- D. Actualizar Ranking (solo si es oficial)
    IF v_is_official AND v_target_member_id IS NOT NULL THEN
        UPDATE public.group_members
        SET
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

-- 3. Redefinir Función de Sanación (Heal) para aplicar las nuevas reglas a datos viejos
CREATE OR REPLACE FUNCTION public.recalculate_all_group_stats(p_group_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_osadia_mult DECIMAL(10,2);
BEGIN
    SELECT osadia_multiplier INTO v_osadia_mult FROM public.groups WHERE id = p_group_id;

    -- A. Reset total
    UPDATE public.group_members
    SET
        total_championship_points = 0,
        total_matches_played = 0,
        total_osadia_points = 0,
        total_wins = 0,
        sum_accuracy_percent = 0,
        count_accuracy_matches = 0,
        effective_avg_percent = 0,
        updated_at = NOW()
    WHERE group_id = p_group_id;

    -- B. Recalcular cada resultado según las nuevas reglas
    -- Primero actualizamos el campo osadia_points en cada match_result basándonos en la nueva lógica
    UPDATE public.match_results res
    SET osadia_points = (res.osadia_bazas_won::DECIMAL * v_osadia_mult::DECIMAL)::INTEGER,
        earned_championship_points = public.calculate_championship_points_v2(p_group_id, res.position_in_match)
    FROM public.matches m
    WHERE m.id = res.match_id AND m.group_id = p_group_id;

    -- C. Sumar estadísticas oficiales al ranking
    UPDATE public.group_members gm
    SET
        total_championship_points = sub.sum_points,
        total_matches_played = sub.count_matches,
        total_osadia_points = sub.sum_osadia,
        sum_accuracy_percent = sub.sum_accuracy,
        count_accuracy_matches = sub.count_matches,
        effective_avg_percent = CASE WHEN sub.count_matches > 0 THEN sub.sum_accuracy / sub.count_matches ELSE 0 END,
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

    -- D. Sincronizar match_count
    UPDATE public.groups
    SET match_count = (SELECT COUNT(*) FROM public.matches WHERE group_id = p_group_id AND is_official = TRUE),
        updated_at = NOW()
    WHERE id = p_group_id;

    -- E. Recalcular posiciones
    PERFORM public.recalculate_group_positions(p_group_id);
END;
$$;
