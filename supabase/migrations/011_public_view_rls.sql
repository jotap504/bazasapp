-- ============================================================
-- MIGRACIÓN 011: HABILITAR LECTURA PÚBLICA PARA VISOR WEB
-- ============================================================

-- 1. Permitir lectura de grupos por cualquier persona (anon)
-- Esto es necesario para que el visor web encuentre la liga por invite_code
DROP POLICY IF EXISTS "groups_public_read" ON public.groups;
CREATE POLICY "groups_public_read"
    ON public.groups FOR SELECT
    TO anon
    USING (true);

-- 2. Permitir lectura de miembros del grupo por cualquier persona (anon)
DROP POLICY IF EXISTS "group_members_public_read" ON public.group_members;
CREATE POLICY "group_members_public_read"
    ON public.group_members FOR SELECT
    TO anon
    USING (true);

-- 3. Permitir lectura de partidas por cualquier persona (anon)
DROP POLICY IF EXISTS "matches_public_read" ON public.matches;
CREATE POLICY "matches_public_read"
    ON public.matches FOR SELECT
    TO anon
    USING (true);

-- 4. Permitir lectura de resultados por cualquier persona (anon)
DROP POLICY IF EXISTS "match_results_public_read" ON public.match_results;
CREATE POLICY "match_results_public_read"
    ON public.match_results FOR SELECT
    TO anon
    USING (true);

-- 5. Permitir lectura de perfiles públicos por cualquier persona (anon)
DROP POLICY IF EXISTS "profiles_public_read" ON public.profiles;
CREATE POLICY "profiles_public_read"
    ON public.profiles FOR SELECT
    TO anon
    USING (true);

-- NOTA: Estas políticas son de SÓLO LECTURA (SELECT). 
-- No permiten modificar, insertar ni borrar ningún dato.
