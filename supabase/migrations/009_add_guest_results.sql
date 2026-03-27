-- ============================================================
-- MIGRACIÓN 009: Soporte para Invitados en Resultados de Partida (V2)
-- ============================================================

-- 1. Modificar tabla match_results
ALTER TABLE public.match_results 
ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE public.match_results 
ADD COLUMN IF NOT EXISTS guest_member_id UUID REFERENCES public.group_members(id) ON DELETE CASCADE;

-- 2. Restricciones de unicidad condicionales
ALTER TABLE public.match_results DROP CONSTRAINT IF EXISTS match_results_match_id_user_id_key;
ALTER TABLE public.match_results DROP CONSTRAINT IF EXISTS match_results_user_id_match_id_key;

CREATE UNIQUE INDEX IF NOT EXISTS idx_match_results_user_unique 
ON public.match_results (match_id, user_id) 
WHERE user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_match_results_guest_unique 
ON public.match_results (match_id, guest_member_id) 
WHERE guest_member_id IS NOT NULL;

-- 3. Actualizar la función del TRIGGER para manejar invitados y nuevas reglas
CREATE OR REPLACE FUNCTION public.update_group_member_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
    v_target_member_id UUID;
BEGIN
    -- A. Obtener datos de la partida
    SELECT group_id, is_official
    INTO v_group_id, v_is_official
    FROM public.matches
    WHERE id = NEW.match_id;

    -- B. Calcular los puntos de campeonato usando la versión de la Migración 008
    -- Incluímos NEW.requested_bazas para la nueva lógica de tramos
    NEW.earned_championship_points := public.calculate_championship_points(
        v_group_id,
        NEW.position_in_match,
        NEW.exact_predictions,
        NEW.osadia_bazas_won,
        NEW.requested_bazas
    );

    -- C. Identificar la fila de group_members a actualizar
    IF NEW.user_id IS NOT NULL THEN
        -- Es un usuario registrado
        SELECT id INTO v_target_member_id 
        FROM public.group_members 
        WHERE group_id = v_group_id AND user_id = NEW.user_id;
    ELSE
        -- Es un invitado (usamos el guest_member_id directamente)
        v_target_member_id := NEW.guest_member_id;
    END IF;

    -- D. Actualizar acumulados si la partida es oficial y el miembro existe
    IF v_is_official AND v_target_member_id IS NOT NULL THEN
        UPDATE public.group_members
        SET
            total_championship_points = total_championship_points + NEW.earned_championship_points,
            total_matches_played      = total_matches_played + 1,
            -- Nota: La lógica de Osadía ahora está en earned_championship_points si se usa requested_bazas,
            -- pero mantenemos estos contadores para estadísticas históricas.
            total_osadia_points       = total_osadia_points + (NEW.osadia_bazas_won * (
                SELECT osadia_multiplier FROM public.groups WHERE id = v_group_id
            )),
            total_efectividad_points  = total_efectividad_points + (NEW.exact_predictions * (
                SELECT efectividad_multiplier FROM public.groups WHERE id = v_group_id
            )),
            total_wins                = total_wins + CASE WHEN NEW.position_in_match = 1 THEN 1 ELSE 0 END,
            updated_at                = NOW()
        WHERE id = v_target_member_id;
    END IF;

    RETURN NEW;
END;
$$;
