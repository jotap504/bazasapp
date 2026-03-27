-- ============================================================
-- FASE 16: Corrección de RLS para Storage (Bucket scoresheets)
-- ============================================================

-- Asegurar que RLS esté habilitado en la tabla de objetos de storage (si falla, ignorar)
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 1. Permitir que cualquier usuario autenticado suba fotos al bucket 'scoresheets'
-- Nota: En una fase más avanzada se podría restringir a que solo suban a su propia carpeta /temp/ o /matches/
CREATE POLICY "Permitir subida a usuarios autenticados en scoresheets"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'scoresheets');

-- 2. Permitir que los usuarios autenticados vean las fotos del bucket 'scoresheets'
CREATE POLICY "Permitir lectura a usuarios autenticados en scoresheets"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'scoresheets');

-- 3. Permitir que los usuarios autenticados borren sus propios archivos (necesario para la limpieza de temporales)
-- Para simplificar durante el desarrollo, permitiremos borrar cualquier objeto en scoresheets si está autenticado
CREATE POLICY "Permitir borrado a usuarios autenticados en scoresheets"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'scoresheets');
