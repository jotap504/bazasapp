-- ============================================================
-- MIGRACIÓN 005: Parámetros de puntuación personalizados y gestión de ligas
-- ============================================================

-- 1. Añadir columnas de puntos a la tabla groups (si no existen)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='groups' AND column_name='pts_per_promise') THEN
        ALTER TABLE public.groups ADD COLUMN pts_per_promise INTEGER NOT NULL DEFAULT 10;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='groups' AND column_name='pts_per_trick') THEN
        ALTER TABLE public.groups ADD COLUMN pts_per_trick INTEGER NOT NULL DEFAULT 1;
    END IF;
END $$;

COMMENT ON COLUMN public.groups.pts_per_promise IS 'Puntos fijos otorgados por cumplir una promesa (exact_predictions)';
COMMENT ON COLUMN public.groups.pts_per_trick IS 'Puntos otorgados por cada baza ganada (tricks) en manos donde se cumplió la promesa o en total';

-- 2. Actualizar la función de cálculo de puntos (se mantiene igual)
CREATE OR REPLACE FUNCTION public.calculate_championship_points(
    p_group_id UUID,
    p_position INTEGER,
    p_exact_predictions INTEGER,
    p_osadia_bazas_won INTEGER
)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_group             RECORD;
    v_f1_points         DECIMAL(10,2) := 0;
    v_efectividad_pts   DECIMAL(10,2) := 0;
    v_osadia_pts        DECIMAL(10,2) := 0;
    v_points_array      JSONB;
    v_array_length      INTEGER;
BEGIN
    SELECT f1_points_system, osadia_multiplier, efectividad_multiplier, pts_per_promise, pts_per_trick
    INTO v_group
    FROM public.groups
    WHERE id = p_group_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    -- A. Puntos F1 por posición (opcional, si el array tiene datos)
    v_points_array := v_group.f1_points_system;
    v_array_length := jsonb_array_length(v_points_array);

    IF p_position >= 1 AND p_position <= v_array_length THEN
        v_f1_points := (v_points_array -> (p_position - 1))::DECIMAL;
    END IF;

    -- B. Puntos por cumplimiento de promesa
    v_efectividad_pts := p_exact_predictions * v_group.pts_per_promise;

    -- C. Puntos por cada baza ganada
    v_osadia_pts := p_osadia_bazas_won * v_group.pts_per_trick;
    
    RETURN v_f1_points + v_efectividad_pts + v_osadia_pts;
END;
$$;

-- 3. Asegurar RLS para eliminar ligas
DROP POLICY IF EXISTS "groups_delete_owner" ON public.groups;
CREATE POLICY "groups_delete_owner" ON public.groups
    FOR DELETE
    TO authenticated
    USING (created_by = auth.uid());

-- 4. REPARACIÓN DE DATOS: Re-insertar al dueño si fue eliminado accidentalmente de group_members
INSERT INTO public.group_members (group_id, user_id, role)
SELECT id, created_by, 'owner'
FROM public.groups g
WHERE NOT EXISTS (
    SELECT 1 FROM public.group_members gm 
    WHERE gm.group_id = g.id AND gm.user_id = g.created_by
)
ON CONFLICT DO NOTHING;

