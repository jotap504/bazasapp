-- ============================================================
-- MIGRACIÓN 016: Habilitar Gestión de Resultados por Creador/Admin
-- ============================================================

-- Asegurar RLS en match_results
ALTER TABLE public.match_results ENABLE ROW LEVEL SECURITY;

-- 1. Permitir al creador de la PARTIDA borrar y editar sus resultados asociados
-- (Necesario para el flujo de 'borrar y re-insertar' en la edición)
DROP POLICY IF EXISTS "match_results_owner_all" ON public.match_results;
CREATE POLICY "match_results_owner_all" 
    ON public.match_results 
    FOR ALL 
    TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.matches 
            WHERE matches.id = match_results.match_id 
            AND matches.created_by = auth.uid()
        )
    );

-- 2. Permitir a los Admins del grupo gestionar resultados si no fueron los creadores
DROP POLICY IF EXISTS "match_results_admin_all" ON public.match_results;
CREATE POLICY "match_results_admin_all" 
    ON public.match_results 
    FOR ALL 
    TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.group_members gm
            JOIN public.matches m ON m.group_id = gm.group_id
            WHERE m.id = match_results.match_id
            AND gm.user_id = auth.uid()
            AND gm.role = 'admin'
        )
    );

-- Nota: La política SELECT ya existe por Migración 011.
