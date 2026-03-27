-- ============================================================
-- MIGRACIÓN 003: Reparar RLS de lectura en tabla groups
-- ============================================================

-- Eliminar la política anterior restrictiva
DROP POLICY IF EXISTS "groups_select_member" ON public.groups;

-- Crear la nueva política permitiendo al creador leer el grupo que acaba de insertar
CREATE POLICY "groups_select_member"
    ON public.groups FOR SELECT
    TO authenticated
    USING (public.is_group_member(id) OR created_by = auth.uid());

-- ---- REPARAR GROUP_MEMBERS ----

-- Permitir al creador del grupo insertar los miembros iniciales (especialmente invitados con user_id NULL)
DROP POLICY IF EXISTS "group_members_insert_admin" ON public.group_members;

CREATE POLICY "group_members_insert_creator"
    ON public.group_members FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid() 
        OR EXISTS (
            SELECT 1 FROM public.groups g 
            WHERE g.id = group_id AND g.created_by = auth.uid()
        )
    );
