-- Migration 014: Security fixes — RLS policies + CHECK constraints
-- Applied: 2026-06-02

-- 1. CHECK constraints em inscricoes
ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_nome_length CHECK (length(nome) >= 3 AND length(nome) <= 255);

ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND length(email) <= 254);

ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_telefone_format CHECK (telefone ~ '^\+?\d{4,15}$');

ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_profissao_check CHECK (profissao IN ('farmaceutico','enfermeiro','medico','estudante-saude','tecnico-medio-saude','tecnico-radiologia','tecnico-analises-clinicas','medico-dentista','biologo-analista','psicologo','nutricionista','fisioterapeuta','outro'));

ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_origem_check CHECK (origem_evento IN ('instagram','whatsapp','facebook','tiktok','linkedin','amigo-indicacao','outro'));

-- 2. Reforcar INSERT policy em inscricoes
DROP POLICY IF EXISTS allow_anon_insert ON public.inscricoes;
DROP POLICY IF EXISTS "Public can insert inscricoes" ON public.inscricoes;
CREATE POLICY "Public can insert inscricoes" ON public.inscricoes
  FOR INSERT TO public
  WITH CHECK (email IS NOT NULL AND length(email) <= 254 AND nome IS NOT NULL AND length(nome) >= 3);

-- 3. page_views: restringir SELECT a admins
DROP POLICY IF EXISTS "Allow authenticated page view reads" ON public.page_views;
CREATE POLICY "Admins can read page views" ON public.page_views
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

-- 4. email_logs: restringir SELECT a admins
DROP POLICY IF EXISTS "Admin users can read email_logs" ON public.email_logs;
CREATE POLICY "Admins can read email logs" ON public.email_logs
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

-- 5. audit_logs: restringir SELECT a admins
DROP POLICY IF EXISTS "Users can read own audit logs" ON public.audit_logs;
CREATE POLICY "Admins can read audit logs" ON public.audit_logs
  FOR SELECT TO public
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

-- 6. newsletter: corrigir policy admin com with_check explicito
DROP POLICY IF EXISTS "Admins have full access to newsletter" ON public.newsletter;
CREATE POLICY "Admins can manage newsletter" ON public.newsletter
  FOR ALL TO public
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));
