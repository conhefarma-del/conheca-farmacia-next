-- =====================================================================
-- 141 — Versionar RLS das tabelas críticas (drift do dashboard)
-- ---------------------------------------------------------------------
-- Contexto (vistoria o-sentinela 2026-08-11, finding #3):
--   articles, events, lives, inscricoes, admin_users, page_views,
--   email_logs, audit_logs, admin_access_questions tinham RLS ATIVO e
--   policies em produção, mas NUNCA versionados em migrações (criados no
--   dashboard, como a newsletter antes da 047). Um `supabase db reset`
--   recriaria estas tabelas SEM RLS → exposição total via anon key
--   (admin_users, inscricoes com PII, email_logs).
--
-- Esta migração espelha o estado verificado em produção a 2026-08-11:
--   • RLS ativo confirmado empiricamente (anon key → 0 linhas em
--     admin_users/page_views/audit_logs/inscricoes/auth_attempts; apenas
--     conteúdo published legível em articles/events/lives);
--   • policies com definição exata retirada das migrações (014/015/020/031);
--   • policies sem versão reconstruídas a partir do comportamento observado
--     da app (INSERT de page_views via anon, INSERT/UPDATE admin, etc.);
--   • hardenings deltas documentados no fim.
--
-- Idempotente: ENABLE é no-op se já ativo; DROP POLICY IF EXISTS + CREATE.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. ENABLE ROW LEVEL SECURITY
--    (auth_attempts já está versionado na 031 — incluído por completude)
-- ---------------------------------------------------------------------
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inscricoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.page_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_access_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auth_attempts ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- 2. ARTICLES / EVENTS / LIVES
--    anon_read: mirror do comportamento observado (published legível;
--    os arquivados permanecem publicados — a app filtra is_archived=false
--    ao nível da query, por isso não aparecem no site).
--    admin INSERT/UPDATE/DELETE: INSERT reconstruído (a app cria conteúdo
--    com a sessão admin); UPDATE/DELETE exatos das 031/020.
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "anon_read_articles" ON public.articles;
CREATE POLICY "anon_read_articles" ON public.articles
  FOR SELECT TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "admin_insert_articles" ON public.articles;
CREATE POLICY "admin_insert_articles" ON public.articles
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admin users can update articles" ON public.articles;
CREATE POLICY "Admin users can update articles" ON public.articles
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_articles" ON public.articles;
CREATE POLICY "admin_delete_articles" ON public.articles
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

DROP POLICY IF EXISTS "anon_read_events" ON public.events;
CREATE POLICY "anon_read_events" ON public.events
  FOR SELECT TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "admin_insert_events" ON public.events;
CREATE POLICY "admin_insert_events" ON public.events
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admin users can update events" ON public.events;
CREATE POLICY "Admin users can update events" ON public.events
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_events" ON public.events;
CREATE POLICY "admin_delete_events" ON public.events
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

DROP POLICY IF EXISTS "anon_read_lives" ON public.lives;
CREATE POLICY "anon_read_lives" ON public.lives
  FOR SELECT TO anon, authenticated
  USING (status = 'published');

DROP POLICY IF EXISTS "admin_insert_lives" ON public.lives;
CREATE POLICY "admin_insert_lives" ON public.lives
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admin users can update lives" ON public.lives;
CREATE POLICY "Admin users can update lives" ON public.lives
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_lives" ON public.lives;
CREATE POLICY "admin_delete_lives" ON public.lives
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- ---------------------------------------------------------------------
-- 3. INSCRICOES (PII de participantes)
--    INSERT público: exato da 014. Leitura/atualização: apenas admin
--    (reconstruído — /admin/inscritos e /validar usam sessão admin).
--    Delta/hardening: são DROPPED as policies legacy do dashboard
--    ("Permitir leitura para autenticados" permitia a QUALQUER user
--    autenticado ler todas as inscrições — enumeração de PII).
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can insert inscricoes" ON public.inscricoes;
CREATE POLICY "Public can insert inscricoes" ON public.inscricoes
  FOR INSERT TO public
  WITH CHECK (email IS NOT NULL AND length(email) <= 254 AND nome IS NOT NULL AND length(nome) >= 3);

DROP POLICY IF EXISTS "admin_read_inscricoes" ON public.inscricoes;
CREATE POLICY "admin_read_inscricoes" ON public.inscricoes
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_inscricoes" ON public.inscricoes;
CREATE POLICY "admin_update_inscricoes" ON public.inscricoes
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Legacy do dashboard (SUPABASE_MIGRATION.sql) — substituídas pelas acima.
DROP POLICY IF EXISTS "Permitir inscrições de qualquer um" ON public.inscricoes;
DROP POLICY IF EXISTS "Permitir leitura para autenticados" ON public.inscricoes;

-- ---------------------------------------------------------------------
-- 4. ADMIN_USERS / ADMIN_ACCESS_QUESTIONS
--    Exatas das 015/020 (só faltava o ENABLE na 015 para access_questions).
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "admin_only_select_admin_users" ON public.admin_users;
CREATE POLICY "admin_only_select_admin_users" ON public.admin_users
  FOR SELECT TO authenticated
  USING (public.is_current_user_admin());

DROP POLICY IF EXISTS "superadmin_manage_admin_users" ON public.admin_users;
CREATE POLICY "superadmin_manage_admin_users" ON public.admin_users
  FOR ALL TO authenticated
  USING (public.is_current_user_superadmin())
  WITH CHECK (public.is_current_user_superadmin());

DROP POLICY IF EXISTS "admin_manage_access_questions" ON public.admin_access_questions;
CREATE POLICY "admin_manage_access_questions" ON public.admin_access_questions
  FOR ALL TO authenticated
  USING (public.is_current_user_admin())
  WITH CHECK (public.is_current_user_admin());

-- ---------------------------------------------------------------------
-- 5. PAGE_VIEWS / EMAIL_LOGS / AUDIT_LOGS
--    SELECT admin: exato da 014. INSERT: reconstruído do fluxo real —
--    page_views recebe INSERT anónimo (trackPageView), email_logs/audit_logs
--    recebem INSERT da sessão admin (sendContentAlert/logAudit).
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "Admins can read page views" ON public.page_views;
CREATE POLICY "Admins can read page views" ON public.page_views
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Public can insert page views" ON public.page_views;
CREATE POLICY "Public can insert page views" ON public.page_views
  FOR INSERT TO anon, authenticated
  WITH CHECK (page_path IS NOT NULL AND length(page_path) <= 500);

DROP POLICY IF EXISTS "Admins can read email logs" ON public.email_logs;
CREATE POLICY "Admins can read email logs" ON public.email_logs
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admin users can insert email logs" ON public.email_logs;
CREATE POLICY "Admin users can insert email logs" ON public.email_logs
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admins can read audit logs" ON public.audit_logs;
CREATE POLICY "Admins can read audit logs" ON public.audit_logs
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "Admin users can insert audit logs" ON public.audit_logs;
CREATE POLICY "Admin users can insert audit logs" ON public.audit_logs
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- ---------------------------------------------------------------------
-- 6. AUTH_ATTEMPTS — policies já versionadas na 031; aqui apenas o ENABLE
--    para a fonte única (sem alterações).
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- 7. GRANTS dos RPCs de rate limit (031) — os GRANT EXECUTE também eram
--    drift do dashboard; sem eles, um db reset deixa check_rate_limit e
--    log_auth_attempt sem EXECUTE para anon/authenticated e o rate
--    limiting DB-backed (login, inscrição, newsletter, analytics) deixa
--    de funcionar. GRANT é idempotente (no-op se já concedido).
-- ---------------------------------------------------------------------
GRANT EXECUTE ON FUNCTION public.check_rate_limit(inet, text, text, integer, integer) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.log_auth_attempt(inet, text, text, boolean, uuid) TO anon, authenticated, service_role;

-- =====================================================================
-- Nota de aplicação (verificar antes de aplicar em produção):
--   As policies reconstruídas usam o comportamento observado da app. Se
--   produção tiver policies com NOMES diferentes criadas no dashboard,
--   o CREATE adiciona as acima (RLS combina com OR para o mesmo comando —
--   sem alteração de comportamento onde as originais são igualmente
--   permissivas). Os únicos deltas de segurança são intencionais:
--     • inscricoes: removidas as legacy "Permitir leitura para
--       autenticados" (qualquer authenticated lia toda a tabela — PII)
--       e "Permitir inscrições de qualquer um" (WITH CHECK true);
--     • anon_read de articles/events/lives fica restrito a status='published'
--       (drafts escondidos de leitura anónima direta).
-- =====================================================================
-- FIM — 141: RLS versionado das tabelas críticas
-- =====================================================================
