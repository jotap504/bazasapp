-- ============================================================
-- MIGRACIÓN 014: INFRAESTRUCTURA DE CONTEO DE PARTIDAS
-- ============================================================

-- 1. Añadir columna match_count a la tabla groups
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS match_count INTEGER NOT NULL DEFAULT 0;

-- 2. Función para sincronizar match_count (Insertar/Borrar)
CREATE OR REPLACE FUNCTION public.sync_group_match_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF NEW.is_official THEN
            UPDATE public.groups SET match_count = match_count + 1 WHERE id = NEW.group_id;
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        IF OLD.is_official THEN
            UPDATE public.groups SET match_count = GREATEST(0, match_count - 1) WHERE id = OLD.group_id;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Activar trigger en la tabla matches
DROP TRIGGER IF EXISTS trg_matches_sync_count ON public.matches;
CREATE TRIGGER trg_matches_sync_count
    AFTER INSERT OR DELETE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.sync_group_match_count();

-- 4. Función para inicializar los contadores actuales (Sincronización inicial)
CREATE OR REPLACE FUNCTION public.fix_all_match_counts()
RETURNS VOID AS $$
BEGIN
    UPDATE public.groups g
    SET match_count = (
        SELECT COUNT(*) 
        FROM public.matches m 
        WHERE m.group_id = g.id AND m.is_official = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejecutar sincronización inicial
SELECT public.fix_all_match_counts();
