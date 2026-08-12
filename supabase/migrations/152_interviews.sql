-- ============================================================================
-- 152_interviews.sql — Módulo de Entrevistas
--
-- Tabela interviews + RLS (padrão das outras entidades de conteúdo) + seed
-- de 4 entrevistas FICTÍCIAS (demonstração, substituíveis pelo admin).
-- Implementação Next.js (2026) do plano docs/superpowers/plans/2026-05-23-
-- entrevistas-modulo.md, atualizado da arquitetura Vite para App Router.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.interviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  excerpt TEXT,
  category TEXT NOT NULL,
  category_label TEXT NOT NULL,
  interviewee JSONB NOT NULL DEFAULT '{}',
  interviewer JSONB DEFAULT '{}',
  date DATE,
  read_time INTEGER,
  video_duration TEXT,
  thumbnail_url TEXT,
  video_id TEXT,
  audio_url TEXT,
  executive_summary TEXT,
  pull_quotes TEXT[] DEFAULT '{}',
  qa JSONB DEFAULT '[]',
  content TEXT,
  references_arr TEXT[] DEFAULT '{}',
  related TEXT[] DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  featured BOOLEAN DEFAULT false,
  meta_description TEXT,
  view_count INTEGER DEFAULT 0,
  is_archived BOOLEAN DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS (padrão 144: DROP IF EXISTS + CREATE com TO anon/authenticated)
ALTER TABLE public.interviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_interviews" ON public.interviews;
CREATE POLICY "anon_read_interviews" ON public.interviews
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

DROP POLICY IF EXISTS "admin_insert_interviews" ON public.interviews;
CREATE POLICY "admin_insert_interviews" ON public.interviews
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_update_interviews" ON public.interviews;
CREATE POLICY "admin_update_interviews" ON public.interviews
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

DROP POLICY IF EXISTS "admin_delete_interviews" ON public.interviews;
CREATE POLICY "admin_delete_interviews" ON public.interviews
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- Indexes
CREATE INDEX IF NOT EXISTS idx_interviews_status ON public.interviews(status);
CREATE INDEX IF NOT EXISTS idx_interviews_category ON public.interviews(category);
CREATE INDEX IF NOT EXISTS idx_interviews_featured ON public.interviews(featured) WHERE featured = true;

-- ============================================================================
-- Seed — 4 entrevistas fictícias de demonstração (a substituir pelo admin)
-- ============================================================================
INSERT INTO public.interviews (
  slug, title, excerpt, category, category_label, interviewee, interviewer,
  date, read_time, video_duration, executive_summary, pull_quotes, qa, content,
  references_arr, related, status, featured, meta_description, view_count
) VALUES
(
  'o-farmaceutico-e-a-ultima-linha-de-defesa-do-doente',
  'O farmacêutico é a última linha de defesa do doente',
  'Dra. Ana Silva (Hospital Nacional) sobre o papel da farmácia clínica na segurança dos doentes.',
  'profissionais', 'Profissionais',
  '{"name":"Dra. Ana Silva","role":"Farmacêutica Clínica · Hospital Nacional","bio":"15 anos de experiência em farmácia hospitalar.","avatar":"AS","avatarBg":"#ff6c23"}',
  '{"name":"João Santos","role":"Editor · Conheça Farmácia","avatar":"JS","avatarBg":"#0a844f"}',
  '2026-05-12', 24, '24:18',
  'Nesta entrevista, a Dra. Ana Silva explica como a farmácia clínica evoluiu nos últimos 15 anos, o papel crescente do farmacêutico na equipa multidisciplinar, e os desafios que ainda persistem na segurança da medicação em Angola.',
  ARRAY['A farmácia deixou de ser o lugar onde se entrega uma caixa de comprimidos. Hoje, o farmacêutico intervém no processo terapêutico inteiro.'],
  '[{"question":"Qual foi o momento que mais marcou a sua prática clínica?","answer":"Uma interação medicamentosa grave detetada antes da administração. O doente teria tido uma hemorragia interna. A partir daí percebi que a nossa revisão é uma questão de segurança, não de burocracia."},{"question":"Que mudanças vê na formação de novos farmacêuticos?","answer":"Os estudantes saem das faculdades com mais ferramentas digitais, mas menos experiência prática com doentes. É fundamental garantir que a componente assistencial não se perde na pressa para aprender sistemas de informação."},{"question":"Como vê a integração de dados entre hospital e farmácia comunitária?","answer":"Estamos a caminho. O protocolo de partilha eletrónica já existe, mas a adesão não é total. Precisamos de normas comuns e de confiança entre instituições."}]',
  E'A primeira vez que a Dra. Ana Silva questionou uma prescrição, tinha quatro anos de experiência e muita insegurança. Hoje, à frente do Serviço de Farmácia Clínica do Hospital Nacional, olha para esse momento como a viragem que definiu a sua carreira.\n\n"Na altura tive o apoio do diretor clínico, que me disse: se tens uma dúvida, a tua obrigação é perguntar. Isso ficou comigo. Hoje ensino o mesmo aos internos."\n\nA conversa aborda a implementação de protocolos de reconciliação medicamentosa, a resistência que ainda existe em algumas equipas, e por que a digitalização dos processos é só parte da solução.',
  ARRAY['Infarmed — Boletim de Farmacovigilância 2025', 'OMS — Política de Medicamentos para a África (2024)', 'Hospital Nacional — Relatório de Gestão 2025'],
  ARRAY['liderar-na-incerteza-a-gestao-hospitalar-em-tempo-de-crise'],
  'published', true,
  'Dra. Ana Silva explica como a farmácia clínica evoluiu e o papel do farmacêutico na segurança da medicação em Angola.',
  128
),
(
  'liderar-na-incerteza-a-gestao-hospitalar-em-tempo-de-crise',
  'Liderar na incerteza: a gestão hospitalar em tempo de crise',
  'Dr. Carlos Mendes (Diretor Clínico) sobre tomada de decisão sob pressão em saúde pública.',
  'lideres', 'Líderes',
  '{"name":"Dr. Carlos Mendes","role":"Diretor Clínico · Hospital Central","bio":"Gestão hospitalar e saúde pública há 20 anos.","avatar":"CM","avatarBg":"#0a844f"}',
  '{"name":"João Santos","role":"Editor · Conheça Farmácia","avatar":"JS","avatarBg":"#0a844f"}',
  '2026-04-28', 20, NULL,
  'Uma conversa sobre como as decisões clínicas e de gestão são tomadas sob pressão, a comunicação de risco em saúde pública e o papel da liderança na preparação para emergências.',
  ARRAY['Gerir uma crise não é ter todas as respostas. É saber quem deve responder, quando e com que informação.'],
  '[{"question":"O que muda na tomada de decisão em contexto de crise?","answer":"O tempo de deliberação comprime-se e a informação é incompleta. Passamos a decidir com o que temos, comunicando o que não sabemos. A transparência sobre a incerteza é parte da liderança."},{"question":"Como preparar uma equipa para emergências?","answer":"Simulações regulares, circuitos de decisão claros e uma cultura onde os profissionais se sentem seguros para falar cedo, antes de o problema escalar."}]',
  E'Liderar um hospital em tempo de crise exige um conjunto de competências que poucas salas de aula ensinam. O Dr. Carlos Mendes passou os últimos anos a construir equipas capazes de responder com rapidez sem perder a segurança clínica.\n\n"O que treinamos todos os dias é a previsibilidade dos processos. Depois, quando o imprevisto chega, a equipa já sabe onde procurar o seu lugar."\n\nEsta entrevista percorre os bastidores da gestão hospitalar: da alocação de camas à comunicação com o público, passando pela relação com os profissionais de saúde na linha da frente.',
  ARRAY['OMS — Preparação e Resposta a Emergências', 'Ministério da Saúde — Plano de Contingência 2025'],
  ARRAY['o-farmaceutico-e-a-ultima-linha-de-defesa-do-doente'],
  'published', true,
  'Dr. Carlos Mendes sobre tomada de decisão sob pressão e liderança em saúde pública.',
  86
),
(
  'ensinar-farmacia-no-seculo-xxi',
  'Ensinar farmácia no século XXI: entre o livro e o paciente',
  'Profa. Marta Lopes sobre a renovação pedagógica nos cursos de ciências farmacêuticas em Angola.',
  'educadores', 'Educadores',
  '{"name":"Profa. Marta Lopes","role":"Docente · Instituto Superior de Farmácia","bio":"Pedagogia e ciências farmacêuticas.","avatar":"ML","avatarBg":"#002a32"}',
  '{"name":"João Santos","role":"Editor · Conheça Farmácia","avatar":"JS","avatarBg":"#0a844f"}',
  '2026-03-14', 18, NULL,
  'A professora Marta Lopes fala da renovação pedagógica nos cursos de ciências farmacêuticas: aprendizagem por casos, contacto precoce com o doente e o papel das metodologias ativas.',
  ARRAY['O currículo não pode ser uma lista de disciplinas. Tem de ser um percurso que aproxima o estudante da prática desde o primeiro ano.'],
  '[{"question":"O que está a mudar no ensino da farmácia?","answer":"A passagem de aulas expositivas para aprendizagem baseada em casos e problemas. O estudante aprende a resolver situações reais, não apenas a memorizar a matéria."},{"question":"Qual é o papel do contacto precoce com a prática?","answer":"É o que dá sentido ao estudo. Quando o estudante vê um doente na farmácia comunitária no segundo ano, toda a teoria passa a ter contexto."}]',
  E'A formação de novos farmacêuticos está a atravessar uma transformação profunda. A professora Marta Lopes tem estado no centro dessa mudança, liderando a revisão curricular do Instituto Superior de Farmácia.\n\n"Durante décadas formámos para um papel que já não existe. Hoje formamos para a prática clínica, para a gestão e para a relação com o doente."\n\nA entrevista explora o equilíbrio entre o rigor científico e as competências humanas, e o que as faculdades angolanas podem aprender com a experiência internacional.',
  ARRAY['FIP — Pharmacy Education Taskforce', 'UNESCO — Educação para a Saúde'],
  ARRAY['investigacao-translacional-do-laboratorio-a-politica-de-saude'],
  'published', true,
  'Profa. Marta Lopes sobre a renovação pedagógica nos cursos de ciências farmacêuticas.',
  74
),
(
  'investigacao-translacional-do-laboratorio-a-politica-de-saude',
  'Investigação translacional: do laboratório à política de saúde',
  'Dr. Paulo Andrade sobre o percurso da descoberta científica até à sua aplicação no sistema nacional de saúde.',
  'investigadores', 'Investigadores',
  '{"name":"Dr. Paulo Andrade","role":"Investigador · Centro de Investigação Biomédica","bio":"Investigação translacional e políticas de saúde.","avatar":"PA","avatarBg":"#006171"}',
  '{"name":"João Santos","role":"Editor · Conheça Farmácia","avatar":"JS","avatarBg":"#0a844f"}',
  '2026-02-02', 22, NULL,
  'O investigador Paulo Andrade explica o percurso da descoberta científica até à sua aplicação no sistema nacional de saúde, e os desafios de transformar resultados de laboratório em políticas públicas.',
  ARRAY['Uma descoberta só muda a saúde das pessoas quando atravessa a fronteira do laboratório. E essa travessia é feita por pessoas, não por artigos.'],
  '[{"question":"Porque é que tantas descobertas ficam no laboratório?","answer":"Falta a ponte entre a ciência e os decisores. O investigador tem de aprender a traduzir os resultados em linguagem útil para a política de saúde."},{"question":"Como se mede o impacto da investigação translacional?","answer":"Para além das publicações, mede-se o que mudou na prática: um protocolo adotado, um medicamento disponível, uma diretriz atualizada."}]',
  E'A investigação translacional vive na fronteira entre o laboratório e a sociedade. O Dr. Paulo Andrade dedica-se a essa travessia há mais de uma década.\n\n"Os resultados científicos têm um prazo de validade: se não chegarem aos decisores a tempo, perdem-se."\n\nNesta entrevista, fala dos fatores que aproximam a ciência da política de saúde em Angola, dos financiamentos aos mecanismos de transferência de conhecimento.',
  ARRAY['Pubmed — Translational Research Review', 'OMS — Aplicação da Ciência às Políticas de Saúde'],
  ARRAY['ensinar-farmacia-no-seculo-xxi'],
  'published', true,
  'Dr. Paulo Andrade sobre o percurso da descoberta científica até à política de saúde.',
  59
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================================
-- Sanity check final
-- ============================================================================
DO $$
DECLARE
  seed_count INT;
  has_rls BOOLEAN;
BEGIN
  SELECT COUNT(*) INTO seed_count FROM public.interviews;
  SELECT relrowsecurity INTO has_rls FROM pg_class WHERE oid = 'public.interviews'::regclass;
  RAISE NOTICE '152: % entrevistas semeadas, RLS ativa: % (esperado: 4, true)', seed_count, has_rls;
END;
$$;
