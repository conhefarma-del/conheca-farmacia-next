-- =====================================================================
-- 294 — SEC-ATH-06: o segundo factor conta também na BASE
--
-- A verificação de admin passou a exigir `role` em `admin_users` e a
-- sessão `aal2` no servidor. Esta migração põe a mesma regra onde ela
-- sobrevive a um erro de aplicação: nas policies.
--
-- PORQUE SÓ ESCRITAS NAS TABELAS DE CONTEÚDO
--   `articles`, `events`, `drugs`, … são LIDAS por qualquer pessoa (e por
--   qualquer sessão) no site. Uma policy restritiva `for all` exigiria
--   `aal2` também ao SELECT e partia o site para quem tem sessão de
--   estudante. Nessas tabelas a exigência é só para INSERT/UPDATE/DELETE —
--   escritas que, sem exceção, são de administração.
--
--   As tabelas que só a administração lê (`audit_logs`, `auth_attempts`,
--   `translation_logs`, `admin_access_questions`) levam a exigência também
--   ao SELECT.
--
-- NOTA: várias Server Actions escrevem com service-role (que ignora RLS de
-- propósito). Esta migração não substitui o guard da aplicação — é a
-- segunda camada, para o dia em que uma action nova escrever com o cliente
-- da sessão.
--
-- Idempotente: apaga e recria as policies com o mesmo nome.
-- =====================================================================

do $$
declare
  t text;
  -- Escrita de administração (leitura continua livre: o site público lê).
  escritas text[] := array[
    'articles', 'article_translations', 'lives', 'live_translations',
    'events', 'event_translations',
    'interviews', 'interview_categories', 'interview_people', 'interview_person_links',
    'scientific_articles', 'scientific_article_authors', 'scientific_article_translations',
    'scientific_authors', 'scientific_categories',
    'clinical_protocols', 'clinical_protocol_categories', 'clinical_protocol_steps',
    'clinical_protocol_references', 'clinical_protocol_quizzes',
    'drugs', 'drug_classes', 'drug_profiles', 'drug_pharmacology', 'drug_interactions',
    'drug_food_interactions', 'drug_disease_interactions', 'drug_pregnancy_info',
    'drug_target_roles', 'molecular_targets',
    'faq_tabs', 'faq_questions',
    'guide_books', 'guide_courses', 'guide_disciplines', 'guide_universities',
    'guide_resources',
    'flashcard_decks', 'flashcards',
    'classes', 'schools', 'privacy_sections', 'terms_sections',
    'email_logs'
  ];
  -- Tabelas que só a administração lê.
  internas text[] := array[
    'audit_logs', 'auth_attempts', 'translation_logs', 'admin_access_questions'
  ];
begin
  foreach t in array escritas loop
    execute format('drop policy if exists %I on public.%I', 'aal2: escrita ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for insert to authenticated '
      || 'with check ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: escrita ' || t, t
    );
    execute format('drop policy if exists %I on public.%I', 'aal2: alteracao ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for update to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'') '
      || 'with check ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: alteracao ' || t, t
    );
    execute format('drop policy if exists %I on public.%I', 'aal2: remocao ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for delete to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: remocao ' || t, t
    );
  end loop;

  foreach t in array internas loop
    execute format('drop policy if exists %I on public.%I', 'aal2: leitura ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for select to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: leitura ' || t, t
    );
    execute format('drop policy if exists %I on public.%I', 'aal2: escrita ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for all to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'') '
      || 'with check ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: escrita ' || t, t
    );
  end loop;

  -- `newsletter`: os leitores subscrevem (INSERT público) mas só a equipa
  -- altera ou apaga linhas.
  foreach t in array array['newsletter'] loop
    execute format('drop policy if exists %I on public.%I', 'aal2: alteracao ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for update to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'') '
      || 'with check ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: alteracao ' || t, t
    );
    execute format('drop policy if exists %I on public.%I', 'aal2: remocao ' || t, t);
    execute format(
      'create policy %I on public.%I as restrictive for delete to authenticated '
      || 'using ((select auth.jwt() ->> ''aal'') = ''aal2'')',
      'aal2: remocao ' || t, t
    );
  end loop;
end $$;
