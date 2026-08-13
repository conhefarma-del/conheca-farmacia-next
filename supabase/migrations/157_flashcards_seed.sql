-- =====================================================================
-- 157 — Flashcards: seed de decks (por prefixo ATC) + cartões gerados
-- ---------------------------------------------------------------------
-- Decisão 2A (híbrido): decks automáticos por grupo ATC com edição no
-- admin. Decisão 3A: cartões gerados a partir dos dados REAIS do banco
-- (drugs.class_pt, drug_pharmacology.mechanism_pt, drug_profiles
-- .overview_public_pt, drug_interactions.summary_pt).
--
-- Regenerável: ON CONFLICT pelo índice parcial (deck_id, drug_id,
-- card_type) — reaplicar a migração atualiza os cartões sem duplicar.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DECKS — um por grupo ATC com fármacos publicados
-- ---------------------------------------------------------------------
INSERT INTO public.flashcard_decks (slug, name_pt, name_en, description_pt, atc_prefix, color, sort_order, status) VALUES
  ('anti-infeciosos',      'Anti-infeciosos',        'Anti-infectives',       'Mecanismo, espectro, interações-chave e monitorização dos antibióticos, antituberculosos e antivíricos do banco.',       'J', '#0a844f', 0,  'published'),
  ('alimentar-metabolismo','Alimentar e Metabolismo','Alimentary and Metabolism','Antidiabéticos, vitaminas, eletrólitos e suplementos com perfil completo no banco.',                                  'A', '#b7791f', 1,  'published'),
  ('cardiovascular',       'Cardiovascular',          'Cardiovascular',        'Anti-hipertensores, antiarrítmicos, anticoagulantes e o que vigiar em cada classe.',                                 'C', '#c0392b', 2,  'published'),
  ('sistema-nervoso',      'Sistema Nervoso Central', 'Central Nervous System', 'Ansiolíticos, antipsicóticos, antiepiléticos e antiparkinsónicos: mecanismos e interações frequentes.',              'N', '#2b6cb0', 3,  'published'),
  ('respiratorio',         'Respiratório',            'Respiratory',            'Broncodilatadores, corticoides inalados e antialérgicos do banco.',                                                  'R', '#00838f', 4,  'published'),
  ('sangue',               'Sangue',                  'Blood',                  'Anticoagulantes, antiagregantes, ferro e fatores de crescimento hematopoiético.',                                    'B', '#6a1b9a', 5,  'published'),
  ('antiparasitarios',     'Antiparasitários',        'Antiparasitics',         'Antimaláricos, anti-helmínticos e antiprotozoários — com as associações usadas em Angola.',                           'P', '#d2452b', 6,  'published'),
  ('geniturinario',        'Génito-urinário e Hormonas', 'Genito-urinary and Hormones', 'Contraceção, hormonas sexuais e fármacos do aparelho urinário.',                                                  'G', '#4a7c59', 7,  'published'),
  ('musculoesqueletico',   'Musculoesquelético',      'Musculoskeletal',        'Anti-inflamatórios, relaxantes musculares e fármacos do metabolismo ósseo.',                                         'M', '#8d6e63', 8,  'published'),
  ('oncologia',            'Oncologia e Imunossupressão', 'Oncology and Immunosuppression', 'Citotóxicos, hormonoterapia e imunossupressores do banco.',                                          'L', '#37474f', 9,  'published'),
  ('hormonas-sistemicas',  'Hormonas sistémicas',     'Systemic Hormones',      'Corticosteroides sistémicos e hormonas hipofisárias/corticais.',                                                   'H', '#5d4037', 10, 'published'),
  ('orgaos-sentidos',      'Órgãos dos sentidos',     'Sensory Organs',          'Oftalmológicos e otológicos do banco.',                                                                            'S', '#00695c', 11, 'published')
ON CONFLICT (slug) DO UPDATE SET
  name_pt = EXCLUDED.name_pt,
  name_en = EXCLUDED.name_en,
  description_pt = EXCLUDED.description_pt,
  atc_prefix = EXCLUDED.atc_prefix,
  color = EXCLUDED.color,
  sort_order = EXCLUDED.sort_order,
  status = EXCLUDED.status;

-- ---------------------------------------------------------------------
-- 2. CARTÕES GERADOS — mecanismo de ação
--    Front: "Qual é o mecanismo de ação de {fármaco}?"
--    Back:  drug_pharmacology.mechanism_pt (fonte da própria farmacologia)
-- ---------------------------------------------------------------------
INSERT INTO public.flashcards (deck_id, drug_id, card_type, front_pt, back_pt, source_note, status)
SELECT d.id, dr.id, 'mecanismo',
       'Qual é o mecanismo de ação de ' || dr.name_pt || '?',
       ph.mechanism_pt,
       COALESCE(NULLIF(btrim(ph.source_pt), ''), 'Farmacologia interna'),
       'published'
FROM public.drugs dr
JOIN public.flashcard_decks d
  ON d.status = 'published'
 AND ((d.atc_prefix IS NOT NULL AND dr.atc_code LIKE d.atc_prefix || '%')
   OR (d.atc_prefix = 'OTHERS' AND LEFT(dr.atc_code, 1) NOT IN ('J','A','C','N','R','B','P','G','M','L','H','S')))
JOIN public.drug_pharmacology ph
  ON ph.drug_id = dr.id AND ph.status = 'published' AND ph.is_archived = false
WHERE dr.status = 'published' AND dr.is_archived = false
  AND length(btrim(ph.mechanism_pt)) > 20
ON CONFLICT (deck_id, drug_id, card_type) WHERE card_type <> 'manual' AND drug_id IS NOT NULL
DO UPDATE SET front_pt = EXCLUDED.front_pt, back_pt = EXCLUDED.back_pt,
              source_note = EXCLUDED.source_note, status = 'published', updated_at = now();

-- ---------------------------------------------------------------------
-- 3. CARTÕES GERADOS — classe terapêutica
-- ---------------------------------------------------------------------
INSERT INTO public.flashcards (deck_id, drug_id, card_type, front_pt, back_pt, source_note, status)
SELECT d.id, dr.id, 'classe',
       dr.name_pt || ' — a que classe terapêutica pertence?',
       dr.class_pt,
       'Classificação interna (drugs.class_pt)',
       'published'
FROM public.drugs dr
JOIN public.flashcard_decks d
  ON d.status = 'published'
 AND ((d.atc_prefix IS NOT NULL AND dr.atc_code LIKE d.atc_prefix || '%')
   OR (d.atc_prefix = 'OTHERS' AND LEFT(dr.atc_code, 1) NOT IN ('J','A','C','N','R','B','P','G','M','L','H','S')))
WHERE dr.status = 'published' AND dr.is_archived = false
  AND length(btrim(dr.class_pt)) > 3
ON CONFLICT (deck_id, drug_id, card_type) WHERE card_type <> 'manual' AND drug_id IS NOT NULL
DO UPDATE SET front_pt = EXCLUDED.front_pt, back_pt = EXCLUDED.back_pt,
              source_note = EXCLUDED.source_note, status = 'published', updated_at = now();

-- ---------------------------------------------------------------------
-- 4. CARTÕES GERADOS — perfil / visão geral (drug_profiles)
-- ---------------------------------------------------------------------
INSERT INTO public.flashcards (deck_id, drug_id, card_type, front_pt, back_pt, source_note, status)
SELECT d.id, dr.id, 'perfil',
       'Qual é a visão geral / indicação de ' || dr.name_pt || '?',
       pf.overview_public_pt,
       'Perfil do medicamento (drug_profiles)',
       'published'
FROM public.drugs dr
JOIN public.flashcard_decks d
  ON d.status = 'published'
 AND ((d.atc_prefix IS NOT NULL AND dr.atc_code LIKE d.atc_prefix || '%')
   OR (d.atc_prefix = 'OTHERS' AND LEFT(dr.atc_code, 1) NOT IN ('J','A','C','N','R','B','P','G','M','L','H','S')))
JOIN public.drug_profiles pf
  ON pf.drug_id = dr.id AND pf.status = 'published'
WHERE dr.status = 'published' AND dr.is_archived = false
  AND length(btrim(pf.overview_public_pt)) > 40
ON CONFLICT (deck_id, drug_id, card_type) WHERE card_type <> 'manual' AND drug_id IS NOT NULL
DO UPDATE SET front_pt = EXCLUDED.front_pt, back_pt = EXCLUDED.back_pt,
              source_note = EXCLUDED.source_note, status = 'published', updated_at = now();

-- ---------------------------------------------------------------------
-- 5. CARTÕES GERADOS — interações fármaco-fármaco (críticas/moderadas)
--    Um cartão por par (drug_a, drug_b), colocado no deck do fármaco A.
--    Deduplica por (deck_id, drug_a_id) pegando a interação mais severa
--    (critical > moderate) para evitar "ON CONFLICT ... second time".
-- ---------------------------------------------------------------------
WITH ranked_interactions AS (
  SELECT
    d_a.id AS deck_id,
    di.drug_a_id AS drug_id,
    'interacao'::text AS card_type,
    dr_a.name_pt || ' + ' || dr_b.name_pt || ' — que interação existe?' AS front_pt,
    di.summary_pt || E'\n\nGrau: ' ||
      CASE di.severity WHEN 'critical' THEN 'Crítico' WHEN 'moderate' THEN 'Moderado' ELSE 'Menor' END AS back_pt,
    COALESCE(NULLIF(btrim(di.source_pt), ''), 'Banco de interações') AS source_note,
    'published'::text AS status,
    ROW_NUMBER() OVER (
      PARTITION BY d_a.id, di.drug_a_id
      ORDER BY CASE di.severity WHEN 'critical' THEN 1 WHEN 'moderate' THEN 2 ELSE 3 END
    ) AS rn
  FROM public.drug_interactions di
  JOIN public.drugs dr_a
    ON dr_a.id = di.drug_a_id
   AND dr_a.status = 'published' AND dr_a.is_archived = false
  JOIN public.drugs dr_b
    ON dr_b.id = di.drug_b_id
   AND dr_b.status = 'published' AND dr_b.is_archived = false
  JOIN public.flashcard_decks d_a
    ON d_a.status = 'published'
   AND ((d_a.atc_prefix IS NOT NULL AND dr_a.atc_code LIKE d_a.atc_prefix || '%')
     OR (d_a.atc_prefix = 'OTHERS' AND LEFT(dr_a.atc_code, 1) NOT IN ('J','A','C','N','R','B','P','G','M','L','H','S')))
  WHERE di.status = 'published' AND di.is_archived = false
    AND di.severity IN ('critical','moderate')
    AND length(btrim(di.summary_pt)) > 10
)
INSERT INTO public.flashcards (deck_id, drug_id, card_type, front_pt, back_pt, source_note, status)
SELECT deck_id, drug_id, card_type, front_pt, back_pt, source_note, status
FROM ranked_interactions
WHERE rn = 1
ON CONFLICT (deck_id, drug_id, card_type) WHERE card_type <> 'manual' AND drug_id IS NOT NULL
DO UPDATE SET front_pt = EXCLUDED.front_pt, back_pt = EXCLUDED.back_pt,
              source_note = EXCLUDED.source_note, status = 'published', updated_at = now();

-- =====================================================================
-- FIM — 157: seed de flashcards
-- =====================================================================
