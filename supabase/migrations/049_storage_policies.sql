-- Migration 049: versionar policies de storage (auditoria "O Sentinela" #6)
--
-- Estado verificado na DB (2026-08-03) — era drift do dashboard:
--   - storage.buckets: 3 buckets públicos (article-images, event-images,
--     live-images) com file_size_limit=5242880 e allowed_mime_types
--     ['image/jpeg','image/png','image/webp','image/gif'] → a validação
--     server-side de tamanho/MIME já existe ao nível do bucket.
--   - storage.objects: 6 policies de escrita para {authenticated} +
--     3 de leitura para {public}. SEM escrita anónima.
--   - storage.buckets: 0 policies (metadata não listável por anon).
--
-- Objectivo:
--   1) Versionar as policies (reproduzir exactamente o que está em prod).
--   2) Endurecer a escrita: INSERT/DELETE passam a exigir
--      public.is_current_user_admin(). Hoje o efeito é neutro (só admins têm
--      contas auth), mas fica defesa em profundidade para o dia em que existir
--      signup público — um utilizador autenticado qualquer não poderá carregar
--      nem apagar ficheiros.
--   3) Leitura pública mantém-se inalterada (buckets públicos).
--
-- Idempotente. Sem alterações ao contrato da app (ImageUpload.jsx usa os
-- mesmos buckets com a sessão do admin autenticado).

-- ============================================================
-- INSERT (upload) — authenticated + admin + bucket
-- ============================================================

DROP POLICY IF EXISTS "Authenticated upload article-images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated upload event-images"   ON storage.objects;
DROP POLICY IF EXISTS "Authenticated upload live-images"    ON storage.objects;

CREATE POLICY "Authenticated upload article-images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'article-images'::text AND public.is_current_user_admin());

CREATE POLICY "Authenticated upload event-images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'event-images'::text AND public.is_current_user_admin());

CREATE POLICY "Authenticated upload live-images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'live-images'::text AND public.is_current_user_admin());

-- ============================================================
-- DELETE — authenticated + admin + bucket
-- ============================================================

DROP POLICY IF EXISTS "Authenticated delete article-images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated delete event-images"   ON storage.objects;
DROP POLICY IF EXISTS "Authenticated delete live-images"    ON storage.objects;

CREATE POLICY "Authenticated delete article-images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'article-images'::text AND public.is_current_user_admin());

CREATE POLICY "Authenticated delete event-images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'event-images'::text AND public.is_current_user_admin());

CREATE POLICY "Authenticated delete live-images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'live-images'::text AND public.is_current_user_admin());

-- ============================================================
-- SELECT (leitura pública) — inalterado vs. estado actual
-- ============================================================

DROP POLICY IF EXISTS "Public read article-images" ON storage.objects;
DROP POLICY IF EXISTS "Public read event-images"   ON storage.objects;
DROP POLICY IF EXISTS "Public read live-images"    ON storage.objects;

CREATE POLICY "Public read article-images" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'article-images'::text);

CREATE POLICY "Public read event-images" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'event-images'::text);

CREATE POLICY "Public read live-images" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'live-images'::text);

COMMENT ON POLICY "Authenticated upload article-images" ON storage.objects IS 'Upload de imagens: authenticated + admin (migration 049). Bucket valida tamanho/MIME server-side.';
COMMENT ON POLICY "Authenticated upload event-images" ON storage.objects   IS 'Upload de imagens: authenticated + admin (migration 049). Bucket valida tamanho/MIME server-side.';
COMMENT ON POLICY "Authenticated upload live-images" ON storage.objects    IS 'Upload de imagens: authenticated + admin (migration 049). Bucket valida tamanho/MIME server-side.';
