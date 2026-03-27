-- ============================================================
-- MIGRACIÓN 007: Permitir eliminación de partidas por creador
-- ============================================================

-- Actualmente solo los admins pueden borrar. Añadimos política para el creador.
DROP POLICY IF EXISTS "matches_delete_creator" ON public.matches;

CREATE POLICY "matches_delete_creator"
    ON public.matches FOR DELETE
    TO authenticated
    USING (created_by = auth.uid());

-- Asegurar que match_results se borre (si no tiene ON DELETE CASCADE, aunque en 001 lo tiene)
-- Recordatorio: El recalculate_group_positions se llama desde el repositorio en Flutter
