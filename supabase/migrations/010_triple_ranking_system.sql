-- ============================================================
-- MIGRACIÓN 010: Rediseño Total - Triple Ranking System
-- ============================================================

-- 1. Actualizar tabla groups
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS min_attendance_pct INTEGER DEFAULT 50;

-- 2. Actualizar tabla match_results con nuevos campos de cómputo
ALTER TABLE public.match_results 
ADD COLUMN IF NOT EXISTS accuracy_percent DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS osadia_points INTEGER DEFAULT 0,
-- Guardamos el total de rondas del partido para trazabilidad
ADD COLUMN IF NOT EXISTS total_match_rounds INTEGER DEFAULT 10;

-- 3. Actualizar tabla group_members para los nuevos acumulados
ALTER TABLE public.group_members 
ADD COLUMN IF NOT EXISTS sum_accuracy_percent DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS count_accuracy_matches INTEGER DEFAULT 0,
-- El campo total_osadia_points ya existe de migraciones previas, lo resetearemos si es necesario.
-- El campo total_championship_points ya existe.
-- El campo total_efectividad_points lo dejaremos (obsoleto o para compatibilidad interna).
-- Añadimos un campo para el promedio calculado (opcional, mejor calcular en lectura o trigger)
ADD COLUMN IF NOT EXISTS effective_avg_percent DECIMAL(10,2) DEFAULT 0;

-- 4. Redefinir función de cálculo de puntos por puesto (Solo Posición F1)
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

-- 5. Redefinir el TRIGGER principal de cómputo
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
BEGIN
    -- A. Obtener datos de la partida
    SELECT group_id, is_official, notes
    INTO v_group_id, v_is_official
    FROM public.matches
    WHERE id = NEW.match_id;

    -- Extraer total_rounds de notes si es posible (formato "Carga manual - X rondas")
    -- O usar el nuevo campo total_match_rounds si viene en el INSERT
    v_total_rounds := COALESCE(NEW.total_match_rounds, 10);

    -- B. Cálculos Individuales del Resultado
    -- 1. Puntos por Puesto (F1)
    NEW.earned_championship_points := public.calculate_championship_points_v2(v_group_id, NEW.position_in_match);

    -- 2. Porcentaje de Efectividad: (aciertos / total_rondas) * 100
    IF v_total_rounds > 0 THEN
        NEW.accuracy_percent := (NEW.exact_predictions::DECIMAL / v_total_rounds::DECIMAL) * 100;
    ELSE
        NEW.accuracy_percent := 0;
    END IF;

    -- 3. Puntos de Osadía: Si Pide X y Trae X, gana X. Si no, 0.
    -- IMPORTANTE: Usamos osadia_bazas_won como "bazas traídas"
    IF NEW.requested_bazas IS NOT NULL AND NEW.requested_bazas = NEW.osadia_bazas_won THEN
        NEW.osadia_points := NEW.requested_bazas;
    ELSE
        NEW.osadia_points := 0;
    END IF;

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
            -- 1. Ranking Puntos (Suma lineal)
            total_championship_points = total_championship_points + NEW.earned_championship_points,
            
            -- 2. Ranking Efectividad (Para promedio futuro)
            sum_accuracy_percent = sum_accuracy_percent + NEW.accuracy_percent,
            count_accuracy_matches = count_accuracy_matches + 1,
            effective_avg_percent = (sum_accuracy_percent + NEW.accuracy_percent) / (count_accuracy_matches + 1),
            
            -- 3. Ranking Osadía (Suma lineal)
            total_osadia_points = total_osadia_points + NEW.osadia_points,
            
            -- Estadísticas generales
            total_matches_played = total_matches_played + 1,
            total_wins = total_wins + CASE WHEN NEW.position_in_match = 1 THEN 1 ELSE 0 END,
            updated_at = NOW()
        WHERE id = v_target_member_id;
    END IF;

    RETURN NEW;
END;
$$;

-- 6. Re-vincular el TRIGGER
DROP TRIGGER IF EXISTS trigger_update_member_stats ON public.match_results;
CREATE TRIGGER trigger_update_member_stats
BEFORE INSERT ON public.match_results
FOR EACH ROW EXECUTE FUNCTION public.update_group_member_stats_v2();

-- 7. (Opcional) Borrar datos actuales si el usuario lo desea manualmente
-- DELETE FROM public.matches; 
-- El usuario dijo que él lo haría borrando las ligas.
