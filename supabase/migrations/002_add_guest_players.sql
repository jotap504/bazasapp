-- ============================================================
-- MIGRACIÓN: Añadir soporte para Jugadores Invitados
-- ============================================================

-- 1. Modificar group_members para permitir user_id nulo y añadir campos de invitado
ALTER TABLE public.group_members DROP CONSTRAINT group_members_pkey;
ALTER TABLE public.group_members ADD COLUMN id UUID PRIMARY KEY DEFAULT uuid_generate_v4();

ALTER TABLE public.group_members ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.group_members ADD COLUMN guest_full_name TEXT;
ALTER TABLE public.group_members ADD COLUMN guest_nickname TEXT;

-- Constraint para asegurar que si no hay user_id, debe haber guest_name
ALTER TABLE public.group_members ADD CONSTRAINT chk_user_or_guest CHECK (
    (user_id IS NOT NULL) OR (guest_full_name IS NOT NULL)
);

-- Asegurar que usuarios registrados no se repitan en el mismo grupo
CREATE UNIQUE INDEX idx_group_members_unique_user ON public.group_members(group_id, user_id) WHERE user_id IS NOT NULL;

-- 2. Modificar match_results para vincularlo a group_members en lugar de solo user_id
ALTER TABLE public.match_results ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE public.match_results ADD COLUMN group_member_id UUID REFERENCES public.group_members(id) ON DELETE CASCADE;

-- Recrear unique constraint para resultados
ALTER TABLE public.match_results DROP CONSTRAINT IF EXISTS match_results_match_id_user_id_key;
CREATE UNIQUE INDEX idx_match_results_unique_member ON public.match_results(match_id, group_member_id) WHERE group_member_id IS NOT NULL;

-- 3. Actualizar la función de estadísticas para usar group_member_id en lugar de user_id
CREATE OR REPLACE FUNCTION public.update_group_member_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
BEGIN
    SELECT group_id, is_official
    INTO v_group_id, v_is_official
    FROM public.matches
    WHERE id = NEW.match_id;

    NEW.earned_championship_points := public.calculate_championship_points(
        v_group_id,
        NEW.position_in_match,
        NEW.exact_predictions,
        NEW.osadia_bazas_won
    );

    IF v_is_official = TRUE THEN
        UPDATE public.group_members
        SET
            total_championship_points = total_championship_points + NEW.earned_championship_points,
            total_matches_played      = total_matches_played + 1,
            total_osadia_points       = total_osadia_points + (NEW.osadia_bazas_won * (
                SELECT osadia_multiplier FROM public.groups WHERE id = v_group_id
            )),
            total_efectividad_points  = total_efectividad_points + (NEW.exact_predictions * (
                SELECT efectividad_multiplier FROM public.groups WHERE id = v_group_id
            )),
            total_wins                = total_wins + CASE WHEN NEW.position_in_match = 1 THEN 1 ELSE 0 END,
            updated_at                = NOW()
        WHERE id = NEW.group_member_id;
    END IF;

    RETURN NEW;
END;
$$;
