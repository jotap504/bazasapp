-- ============================================================
-- MIGRACIÓN 015: PERMITIR EMPATES EN POSICIONES
-- ============================================================

-- 1. Eliminar la restricción de unicidad de posición en una partida
-- Intentamos con el nombre estándar que genera Supabase/Postgres
ALTER TABLE public.match_results 
DROP CONSTRAINT IF EXISTS match_results_match_id_position_in_match_key;

-- Por seguridad, si el nombre fuera distinto (creado manualmente antes),
-- este bloque anónimo lo busca y lo elimina basado en las columnas.
DO $$ 
DECLARE 
    r_name TEXT;
BEGIN
    SELECT conname INTO r_name
    FROM pg_constraint 
    WHERE conrelid = 'public.match_results'::regclass 
      AND contype = 'u' 
      AND confkey IS NULL 
      AND substring(pg_get_constraintdef(oid) from '\((.*)\)') = 'match_id, position_in_match';

    IF r_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE public.match_results DROP CONSTRAINT ' || r_name;
    END IF;
END $$;
