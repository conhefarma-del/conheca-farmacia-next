-- 251: Fix RLS policy "anon_read_interview_people"
--
-- Bug: dentro do EXISTS, `ipl.person_id = id` resolvia `id` para
-- interviews.id (tabela do JOIN, que também tem coluna `id`) em vez de
-- interview_people.id exterior — person_id = interviews.id nunca bate,
-- logo a policy filtrava TODAS as pessoas para visitantes anónimos.
-- Sintoma: /entrevistas/entrevistados vazio (admin era imune — usava a
-- policy admin_read_* sem EXISTS).
--
-- Correcção: qualificar explicitamente a coluna exterior
-- (interview_people.id) para eliminar a ambiguidade.
-- Idempotente: DROP POLICY IF EXISTS antes do CREATE.

DROP POLICY IF EXISTS "anon_read_interview_people" ON public.interview_people;
CREATE POLICY "anon_read_interview_people" ON public.interview_people
  FOR SELECT TO anon, authenticated
  USING (EXISTS (
    SELECT 1
    FROM public.interview_person_links ipl
    JOIN public.interviews i ON i.id = ipl.interview_id
    WHERE ipl.person_id = interview_people.id
      AND i.status = 'published'
      AND i.is_archived = false
  ));
