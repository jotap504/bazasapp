-- ============================================================
-- MIGRACIÓN 008: Configuración de Osadía Avanzada y Carga Manual
-- ============================================================

-- 1. Añadir columnas necesarias
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS osadia_config JSONB DEFAULT '[{"min": 6, "max": 10, "pts": 2}, {"min": 11, "max": 20, "pts": 5}, {"min": 21, "max": null, "pts": 7}]'::JSONB;

ALTER TABLE public.match_results 
ADD COLUMN IF NOT EXISTS requested_bazas INTEGER;

COMMENT ON COLUMN public.groups.osadia_config IS 'Tramos de puntos para Osadía. Ej: [{"min": 6, "max": 10, "pts": 2}, ...]';
COMMENT ON COLUMN public.match_results.requested_bazas IS 'Total de bazas solicitadas por el jugador en la partida (usado para Osadía)';

-- 2. Actualizar función de cálculo de puntos para usar los tramos de osadia_config
CREATE OR REPLACE FUNCTION public.calculate_championship_points(
    p_group_id UUID,
    p_position INTEGER,
    p_exact_predictions INTEGER,
    p_osadia_bazas_won INTEGER,
    p_requested_bazas INTEGER DEFAULT NULL
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
    v_tier              JSONB;
BEGIN
    SELECT f1_points_system, pts_per_promise, pts_per_trick, osadia_config
    INTO v_group
    FROM public.groups
    WHERE id = p_group_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    -- A. Puntos F1 por posición
    v_points_array := v_group.f1_points_system;
    v_array_length := jsonb_array_length(v_points_array);

    IF p_position >= 1 AND p_position <= v_array_length THEN
        v_f1_points := (v_points_array -> (p_position - 1))::DECIMAL;
    END IF;

    -- B. Puntos por Efectividad (Promesas cumplidas)
    v_efectividad_pts := p_exact_predictions * v_group.pts_per_promise;

    -- C. Puntos por Osadía (NUEVA LÓGICA DE TRAMOS)
    -- Si se provee p_requested_bazas y hay config, usamos tramos.
    -- Si no, caemos en el multiplicador tradicional (pts_per_trick por bazas ganadas).
    IF p_requested_bazas IS NOT NULL AND v_group.osadia_config IS NOT NULL THEN
        FOR v_tier IN SELECT * FROM jsonb_array_elements(v_group.osadia_config)
        LOOP
            IF p_requested_bazas >= (v_tier->>'min')::INTEGER AND 
               ((v_tier->>'max') IS NULL OR p_requested_bazas <= (v_tier->>'max')::INTEGER) THEN
               v_osadia_pts := (v_tier->>'pts')::DECIMAL;
               EXIT; -- Tomamos el primer tramo que coincida
            END IF;
        END LOOP;
    ELSE
        -- Lógica tradicional
        v_osadia_pts := p_osadia_bazas_won * v_group.pts_per_trick;
    END IF;
    
    RETURN v_f1_points + v_efectividad_pts + v_osadia_pts;
END;
$$;
