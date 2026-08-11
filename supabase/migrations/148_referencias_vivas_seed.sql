-- =====================================================================
-- 148 — Referências vivas: marcadores [n] no conteúdo dos 5 artigos seed
-- ---------------------------------------------------------------------
-- Ativa o sistema de citações numeradas no corpo (ScientificArticleContent
-- converte [n]/[1,2]/[1-3] em links para #ref-n). Cada artigo seed é um
-- resumo estruturado fiel à sua fonte: as frases-chave de Resultados e
-- Conclusão citam a referência [1] (o próprio artigo). Exceção: o artigo
-- de farmacovigilância compara com a revisão de 2009 (Lopez-Gonzalez et
-- al., a sua referência [2]) — a Conclusão cita [2].
-- Idempotente (replace só altera se a sentença existir sem o marcador).
-- =====================================================================

-- 1. Farmacologia clínica — Cattaneo 2022
UPDATE public.scientific_articles
SET content = replace(content,
  'A maioria envolve antibióticos mais antigos; as moléculas mais recentes apresentam baixo potencial de interação, com duas exceções: a oritavancina (potencial causadora de interação) e a eravaciclina (vítima de indutores fortes do CYP3A).',
  'A maioria envolve antibióticos mais antigos; as moléculas mais recentes apresentam baixo potencial de interação, com duas exceções: a oritavancina (potencial causadora de interação) e a eravaciclina (vítima de indutores fortes do CYP3A) [1].'),
  updated_at = now()
WHERE slug = 'interacoes-farmacocineticas-antibioticos';

UPDATE public.scientific_articles
SET content = replace(content,
  'Esquemas terapêuticos personalizados, apoiados em verificadores de interações fármaco-fármaco disponíveis na web e eventualmente combinados com monitorização terapêutica de fármacos, têm potencial para melhorar a resposta dos doentes em UCI à antibioterapia.',
  'Esquemas terapêuticos personalizados, apoiados em verificadores de interações fármaco-fármaco disponíveis na web e eventualmente combinados com monitorização terapêutica de fármacos, têm potencial para melhorar a resposta dos doentes em UCI à antibioterapia [1].'),
  updated_at = now()
WHERE slug = 'interacoes-farmacocineticas-antibioticos';

-- 2. Saúde pública — Burson 2016
UPDATE public.scientific_articles
SET content = replace(content,
  'Contudo, barreiras políticas e organizacionais limitam a sua viabilidade e eficácia.',
  'Contudo, barreiras políticas e organizacionais limitam a sua viabilidade e eficácia [1].'),
  updated_at = now()
WHERE slug = 'farmacias-comunitarias-vacinacao-adultos';

UPDATE public.scientific_articles
SET content = replace(content,
  'A evidência recolhida informa políticas e esforços organizacionais que promovam a eficácia e a sustentabilidade dos serviços de imunização em farmácia comunitária.',
  'A evidência recolhida informa políticas e esforços organizacionais que promovam a eficácia e a sustentabilidade dos serviços de imunização em farmácia comunitária [1].'),
  updated_at = now()
WHERE slug = 'farmacias-comunitarias-vacinacao-adultos';

-- 3. Farmacovigilância — García-Abeijon 2023 ([1]) vs revisão de 2009 ([2])
UPDATE public.scientific_articles
SET content = replace(content,
  'A não obrigatoriedade da notificação e a confidencialidade emergem como novos motivos de subnotificação.',
  'A não obrigatoriedade da notificação e a confidencialidade emergem como novos motivos de subnotificação [1].'),
  updated_at = now()
WHERE slug = 'subnotificacao-reacoes-adversas-medicamentos';

UPDATE public.scientific_articles
SET content = replace(content,
  'Embora sejam fatores potencialmente modificáveis por intervenções educativas, observaram-se mudanças mínimas desde 2009.',
  'Embora sejam fatores potencialmente modificáveis por intervenções educativas, observaram-se mudanças mínimas desde 2009 [2].'),
  updated_at = now()
WHERE slug = 'subnotificacao-reacoes-adversas-medicamentos';

-- 4. Educação farmacêutica — Foucault-Fruchard 2024
UPDATE public.scientific_articles
SET content = replace(content,
  'A aprendizagem por simulação — frequentemente com doentes simulados e em contextos interprofissionais, com doentes e famílias — melhorou as competências de comunicação, a perceção da sua importância e a confiança.',
  'A aprendizagem por simulação — frequentemente com doentes simulados e em contextos interprofissionais, com doentes e famílias — melhorou as competências de comunicação, a perceção da sua importância e a confiança [1].'),
  updated_at = now()
WHERE slug = 'simulacao-comunicacao-farmacia';

UPDATE public.scientific_articles
SET content = replace(content,
  'O desenvolvimento de orientações claras e de instrumentos de avaliação normalizados melhoraria substancialmente a validade e a fiabilidade da investigação futura.',
  'O desenvolvimento de orientações claras e de instrumentos de avaliação normalizados melhoraria substancialmente a validade e a fiabilidade da investigação futura [1].'),
  updated_at = now()
WHERE slug = 'simulacao-comunicacao-farmacia';

-- 5. Fitoterapia — Ge 2014
UPDATE public.scientific_articles
SET content = replace(content,
  'O mecanismo geral das interações ervas–varfarina permanece em grande parte desconhecido, embora se estimem fatores farmacocinéticos e farmacodinâmicos a influenciar o efeito da varfarina.',
  'O mecanismo geral das interações ervas–varfarina permanece em grande parte desconhecido, embora se estimem fatores farmacocinéticos e farmacodinâmicos a influenciar o efeito da varfarina [1].'),
  updated_at = now()
WHERE slug = 'interacoes-ervas-varfarina';

UPDATE public.scientific_articles
SET content = replace(content,
  'As interações ervas–varfarina, em especial os efeitos clínicos das plantas na terapêutica com varfarina, devem ser investigadas em estudos multicêntricos com amostras maiores.',
  'As interações ervas–varfarina, em especial os efeitos clínicos das plantas na terapêutica com varfarina, devem ser investigadas em estudos multicêntricos com amostras maiores [1].'),
  updated_at = now()
WHERE slug = 'interacoes-ervas-varfarina';

-- =====================================================================
-- FIM — 148: marcadores de citação no seed
-- =====================================================================
