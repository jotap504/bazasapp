-- ============================================================
-- MIGRACIÓN 004: Añadir apodo a los perfiles de usuario
-- ============================================================

-- Añadir columna nickname a la tabla profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS nickname TEXT;

-- Comentario para documentación
COMMENT ON COLUMN public.profiles.nickname IS 'Apodo o nickname opcional del usuario para mostrar en las ligas';

-- Actualizar la función handle_new_user para que considere el nickname si viene en el metadato (opcional)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, nickname, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'nickname',
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$;
