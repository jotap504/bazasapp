-- ============================================================
-- LA PODRIDA - SCHEMA COMPLETO SUPABASE
-- FASE 1: Tablas, RLS, Triggers y Funciones
-- ============================================================

-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLA: profiles
-- Se sincroniza con auth.users mediante trigger
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT '',
    avatar_url  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'Perfil público de cada usuario registrado';

-- ============================================================
-- TABLA: groups (Ligas/Grupos de juego)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.groups (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                    TEXT NOT NULL,
    description             TEXT,
    created_by              UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    min_quorum              INTEGER NOT NULL DEFAULT 5 CHECK (min_quorum >= 2),
    f1_points_system        JSONB NOT NULL DEFAULT '[25, 18, 15, 12, 10, 8, 6, 4, 2, 1]'::JSONB,
    osadia_multiplier       DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    efectividad_multiplier  DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    invite_code             TEXT UNIQUE DEFAULT upper(substring(md5(random()::text), 1, 8)),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.groups IS 'Ligas o grupos de juego, con configuración de puntuación F1';
COMMENT ON COLUMN public.groups.f1_points_system IS 'Array JSON con puntos por posición [1°,2°,3°...]. Ej: [25,18,15,12,10,8,6]';
COMMENT ON COLUMN public.groups.min_quorum IS 'Mínimo de jugadores para que una partida sea oficial';
COMMENT ON COLUMN public.groups.invite_code IS 'Código de invitación único para unirse al grupo';

-- ============================================================
-- TABLA: group_members (Miembros de un grupo y sus acumulados)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.group_members (
    group_id                    UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id                     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role                        TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    total_championship_points   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_matches_played        INTEGER NOT NULL DEFAULT 0,
    total_osadia_points         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_efectividad_points    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_wins                  INTEGER NOT NULL DEFAULT 0,
    current_position            INTEGER,
    previous_position           INTEGER,
    joined_at                   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (group_id, user_id)
);

COMMENT ON TABLE public.group_members IS 'Relación usuario-grupo con acumulados del campeonato';

-- ============================================================
-- TABLA: matches (Partidas registradas)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.matches (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id            UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    played_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scoresheet_image_url TEXT,
    is_official         BOOLEAN NOT NULL DEFAULT FALSE,
    notes               TEXT,
    players_count       INTEGER NOT NULL DEFAULT 0,
    created_by          UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.matches IS 'Registro de partidas. is_official=true si jugaron >= min_quorum';

-- ============================================================
-- TABLA: match_results (Resultados individuales por partida)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.match_results (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id                    UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    user_id                     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    position_in_match           INTEGER NOT NULL CHECK (position_in_match >= 1),
    raw_points                  INTEGER NOT NULL DEFAULT 0,
    exact_predictions           INTEGER NOT NULL DEFAULT 0 CHECK (exact_predictions >= 0),
    osadia_bazas_won            INTEGER NOT NULL DEFAULT 0 CHECK (osadia_bazas_won >= 0),
    earned_championship_points  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (match_id, user_id),
    UNIQUE (match_id, position_in_match)
);

COMMENT ON TABLE public.match_results IS 'Resultado de cada jugador en una partida, con puntos de campeonato calculados';
COMMENT ON COLUMN public.match_results.exact_predictions IS 'Cantidad de rondas donde predijo exactamente las bazas (Efectividad)';
COMMENT ON COLUMN public.match_results.osadia_bazas_won IS 'Bazas ganadas en rondas donde pidió >1 baza (Osadía)';

-- ============================================================
-- FUNCIÓN: Calcular earned_championship_points
-- ============================================================
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
    SELECT f1_points_system, osadia_multiplier, efectividad_multiplier
    INTO v_group
    FROM public.groups
    WHERE id = p_group_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    -- Puntos F1 por posición (el array es 0-indexed, posición 1 = índice 0)
    v_points_array := v_group.f1_points_system;
    v_array_length := jsonb_array_length(v_points_array);

    IF p_position >= 1 AND p_position <= v_array_length THEN
        v_f1_points := (v_points_array -> (p_position - 1))::DECIMAL;
    END IF;

    -- Puntos por Efectividad
    v_efectividad_pts := p_exact_predictions * v_group.efectividad_multiplier;

    -- Puntos por Osadía
    v_osadia_pts := p_osadia_bazas_won * v_group.osadia_multiplier;

    RETURN v_f1_points + v_efectividad_pts + v_osadia_pts;
END;
$$;

-- ============================================================
-- FUNCIÓN: Actualizar acumulados en group_members tras insertar match_results
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_group_member_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_group_id UUID;
    v_is_official BOOLEAN;
BEGIN
    -- Obtener el group_id y si es oficial desde matches
    SELECT group_id, is_official
    INTO v_group_id, v_is_official
    FROM public.matches
    WHERE id = NEW.match_id;

    -- Calcular los puntos de campeonato
    NEW.earned_championship_points := public.calculate_championship_points(
        v_group_id,
        NEW.position_in_match,
        NEW.exact_predictions,
        NEW.osadia_bazas_won
    );

    -- Actualizar acumulados en group_members (solo si es oficial)
    INSERT INTO public.group_members (group_id, user_id)
    VALUES (v_group_id, NEW.user_id)
    ON CONFLICT (group_id, user_id) DO NOTHING;

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
    WHERE group_id = v_group_id AND user_id = NEW.user_id
      AND v_is_official = TRUE;

    RETURN NEW;
END;
$$;

-- Trigger en match_results (BEFORE INSERT para calcular puntos)
DROP TRIGGER IF EXISTS trg_match_results_update_stats ON public.match_results;
CREATE TRIGGER trg_match_results_update_stats
    BEFORE INSERT ON public.match_results
    FOR EACH ROW
    EXECUTE FUNCTION public.update_group_member_stats();

-- ============================================================
-- FUNCIÓN: Recalcular posiciones del ranking del grupo
-- ============================================================
CREATE OR REPLACE FUNCTION public.recalculate_group_positions(p_group_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Guardar posición anterior
    UPDATE public.group_members
    SET previous_position = current_position
    WHERE group_id = p_group_id;

    -- Recalcular posición actual basada en puntos totales
    WITH ranked AS (
        SELECT
            user_id,
            ROW_NUMBER() OVER (ORDER BY total_championship_points DESC, total_wins DESC) AS new_pos
        FROM public.group_members
        WHERE group_id = p_group_id
    )
    UPDATE public.group_members gm
    SET current_position = ranked.new_pos
    FROM ranked
    WHERE gm.group_id = p_group_id AND gm.user_id = ranked.user_id;
END;
$$;

-- ============================================================
-- FUNCIÓN: Trigger para updated_at automático
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Triggers updated_at para cada tabla
DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_groups_updated_at ON public.groups;
CREATE TRIGGER trg_groups_updated_at
    BEFORE UPDATE ON public.groups
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_group_members_updated_at ON public.group_members;
CREATE TRIGGER trg_group_members_updated_at
    BEFORE UPDATE ON public.group_members
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_matches_updated_at ON public.matches;
CREATE TRIGGER trg_matches_updated_at
    BEFORE UPDATE ON public.matches
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- FUNCIÓN: Auto-crear profile cuando se registra un usuario
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$;

-- Trigger en auth.users
DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- FUNCIÓN: is_group_member (helper para RLS)
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_group_member(p_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.group_members
        WHERE group_id = p_group_id AND user_id = auth.uid()
    );
$$;

-- ============================================================
-- FUNCIÓN: is_group_admin (helper para RLS)
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_group_admin(p_group_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.group_members
        WHERE group_id = p_group_id
          AND user_id = auth.uid()
          AND role IN ('owner', 'admin')
    );
$$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
ALTER TABLE public.profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_results   ENABLE ROW LEVEL SECURITY;

-- ---- PROFILES ----
-- Cualquier usuario autenticado puede leer perfiles (para mostrar nombres)
CREATE POLICY "profiles_select_authenticated"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (TRUE);

-- Solo el propio usuario puede actualizar su perfil
CREATE POLICY "profiles_update_own"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- ---- GROUPS ----
-- Solo miembros del grupo ven el grupo
CREATE POLICY "groups_select_member"
    ON public.groups FOR SELECT
    TO authenticated
    USING (public.is_group_member(id));

-- Cualquier autenticado puede crear un grupo
CREATE POLICY "groups_insert_authenticated"
    ON public.groups FOR INSERT
    TO authenticated
    WITH CHECK (created_by = auth.uid());

-- Solo admin/owner puede actualizar el grupo
CREATE POLICY "groups_update_admin"
    ON public.groups FOR UPDATE
    TO authenticated
    USING (public.is_group_admin(id))
    WITH CHECK (public.is_group_admin(id));

-- Solo el owner puede eliminar el grupo
CREATE POLICY "groups_delete_owner"
    ON public.groups FOR DELETE
    TO authenticated
    USING (created_by = auth.uid());

-- ---- GROUP_MEMBERS ----
-- Miembros del grupo ven a los demás miembros
CREATE POLICY "group_members_select_member"
    ON public.group_members FOR SELECT
    TO authenticated
    USING (public.is_group_member(group_id));

-- Admin puede insertar miembros (invitaciones)
CREATE POLICY "group_members_insert_admin"
    ON public.group_members FOR INSERT
    TO authenticated
    WITH CHECK (public.is_group_admin(group_id) OR user_id = auth.uid());

-- Admin puede actualizar roles/stats
CREATE POLICY "group_members_update_admin"
    ON public.group_members FOR UPDATE
    TO authenticated
    USING (public.is_group_admin(group_id));

-- Admin puede eliminar miembros
CREATE POLICY "group_members_delete_admin"
    ON public.group_members FOR DELETE
    TO authenticated
    USING (public.is_group_admin(group_id) OR user_id = auth.uid());

-- ---- MATCHES ----
-- Miembros del grupo ven sus partidas
CREATE POLICY "matches_select_member"
    ON public.matches FOR SELECT
    TO authenticated
    USING (public.is_group_member(group_id));

-- Miembros pueden registrar partidas
CREATE POLICY "matches_insert_member"
    ON public.matches FOR INSERT
    TO authenticated
    WITH CHECK (public.is_group_member(group_id) AND created_by = auth.uid());

-- Admin puede actualizar partidas
CREATE POLICY "matches_update_admin"
    ON public.matches FOR UPDATE
    TO authenticated
    USING (public.is_group_admin(group_id));

-- Admin puede eliminar partidas
CREATE POLICY "matches_delete_admin"
    ON public.matches FOR DELETE
    TO authenticated
    USING (public.is_group_admin(group_id));

-- ---- MATCH_RESULTS ----
-- Miembros del grupo ven los resultados
CREATE POLICY "match_results_select_member"
    ON public.match_results FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = match_id AND public.is_group_member(m.group_id)
        )
    );

-- Solo quienes crearon la partida o admins pueden insertar resultados
CREATE POLICY "match_results_insert_member"
    ON public.match_results FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = match_id
              AND public.is_group_member(m.group_id)
              AND (m.created_by = auth.uid() OR public.is_group_admin(m.group_id))
        )
    );

-- ============================================================
-- STORAGE: Bucket para planillas de puntaje
-- (Ejecutar desde Supabase Dashboard o API de Storage)
-- ============================================================
-- INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- VALUES ('scoresheets', 'scoresheets', FALSE, 10485760, ARRAY['image/jpeg','image/png','image/webp']);

-- Política de storage: solo miembros del grupo pueden subir/leer su scoresheet
-- (Configurar desde Dashboard > Storage > Policies)

-- ============================================================
-- ÍNDICES para performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON public.group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON public.group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_group_members_points ON public.group_members(group_id, total_championship_points DESC);
CREATE INDEX IF NOT EXISTS idx_matches_group_id ON public.matches(group_id);
CREATE INDEX IF NOT EXISTS idx_matches_played_at ON public.matches(group_id, played_at DESC);
CREATE INDEX IF NOT EXISTS idx_match_results_match_id ON public.match_results(match_id);
CREATE INDEX IF NOT EXISTS idx_match_results_user_id ON public.match_results(user_id);
