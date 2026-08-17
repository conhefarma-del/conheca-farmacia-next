-- =====================================================================
-- 172: Fluxo 4 — Explicações longas das dimensões dos fármacos tópicos
--      do grupo 14 (lote piloto do Fluxo 6)
-- ---------------------------------------------------------------------
-- Contexto: o Fluxo 6 (migração 171) não cria pares em drug_interactions
-- (regra anti-invenção — nada de pares artificiais para fármacos tópicos),
-- pelo que a camada editorial de profundidade do Fluxo 4 aplica-se às
-- dimensões documentadas (drug_disease_interactions). Esta migração
-- adiciona as dimensões de doença que os rótulos documentam e que a 171
-- não cobriu, com reason/advice longos (3-5 frases, padrão do Fluxo 4).
--
-- Fontes (DailyMed/FDA — NIH/NLM), setIDs validados a 2026-08-17:
--   Mupirocina (KESIN PHARMA)    b8e115ce-c8ff-4d08-b865-71dc4d0e51a1
--   Budesonida nasal (RHINOCORT) ffca32a2-fbef-40bb-b0f0-73f63e18e747
--
-- Âncoras confirmadas no texto dos rótulos:
--   * Mupirocina × insuficiência renal (5.7 Risk of Polyethylene Glycol
--     Absorption): "Mupirocin ointment should not be used where absorption
--     of large quantities of polyethylene glycol is possible, especially if
--     there is evidence of moderate or severe renal impairment."
--   * Budesonida nasal × glaucoma/cataratas (5.7): "Glaucoma and cataracts:
--     Close monitoring is warranted."
--   * Budesonida nasal × infeção ativa (5.3 Immunosuppression): "Potential
--     worsening of infections (e.g., existing tuberculosis, fungal, bacterial,
--     viral, or parasitic infections; or ocular herpes simplex). Use with
--     caution in patients with these infections."
--
-- Nota: a budesonida já tem a dimensão tuberculose (migração anterior) — a
-- dimensão infeccao_ativa cobre o resto das infeções do rótulo (fúngicas,
-- bacterianas, virais, parasitárias e herpes ocular), sem duplicar.
--
-- Idempotente: ON CONFLICT (drug_id, condition_slug) DO NOTHING — reaplicar
-- é seguro. Aplicar na ordem 171 → 172.
-- =====================================================================

-- =====================================================================
-- 1. Mupirocina × insuficiência renal grave — risco de absorção de PEG
--    (rótulo FDA 5.7)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('mupirocina', 'insuficiencia_renal_grave', 'Insuficiência renal grave', 'Severe renal impairment', 'precaution', 'moderate',
   E'O rótulo FDA da pomada de mupirocina documenta na secção 5.7 (Risk of Polyethylene Glycol Absorption) que o produto não deve ser usado em situações em que seja possível a absorção de grandes quantidades de polietilenoglicol (PEG), especialmente se houver evidência de insuficiência renal moderada ou grave: "Mupirocin ointment should not be used where absorption of large quantities of polyethylene glycol is possible, especially if there is evidence of moderate or severe renal impairment". A base da pomada contém PEG, que é eliminado por via renal; em doentes com insuficiência renal moderada a grave e aplicação em áreas extensas ou sob condições que aumentem a absorção, o PEG pode acumular-se e causar toxicidade sistémica (hiperosmolaridade, acidose metabólica e insuficiência renal aguda são complicações descritas com a absorção de PEG).',
   E'The FDA mupirocin ointment label documents in section 5.7 (Risk of Polyethylene Glycol Absorption) that the product should not be used where absorption of large quantities of polyethylene glycol (PEG) is possible, especially if there is evidence of moderate or severe renal impairment: "Mupirocin ointment should not be used where absorption of large quantities of polyethylene glycol is possible, especially if there is evidence of moderate or severe renal impairment". The ointment base contains PEG, which is renally eliminated; in patients with moderate to severe renal impairment and application over large areas or under conditions that increase absorption, PEG may accumulate and cause systemic toxicity (hyperosmolality, metabolic acidosis and acute renal failure are described complications of PEG absorption).',
   E'Evitar a pomada de mupirocina (base com PEG) em doentes com insuficiência renal moderada ou grave, especialmente em áreas extensas de pele ou queimaduras; se o uso for imprescindível, optar por formulações sem PEG e vigiar a função renal e sinais de toxicidade sistémica.',
   E'Avoid mupirocin ointment (PEG-containing base) in patients with moderate or severe renal impairment, especially over large skin areas or burns; if use is essential, choose PEG-free formulations and monitor renal function and signs of systemic toxicity.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Mupirocina pomada (KESIN PHARMA), secção 5.7 Risk of Polyethylene Glycol Absorption: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1',
   'DailyMed/FDA (NIH/NLM) — approved Mupirocin ointment label (KESIN PHARMA), section 5.7 Risk of Polyethylene Glycol Absorption: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 2. Budesonida nasal × glaucoma — monitorização apertada (rótulo FDA 5.7)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('budesonida', 'glaucoma', 'Glaucoma', 'Glaucoma', 'precaution', 'moderate',
   E'O rótulo FDA do RHINOCORT AQUA (budesonida nasal) documenta na secção 5.7: "Glaucoma and cataracts: Close monitoring is warranted". Os corticosteróides intranasais podem aumentar a pressão intraocular em doentes suscetíveis, incluindo doentes com glaucoma de ângulo aberto pré-existente; o aumento da pressão intraocular pode não ser detetado sem tonometria, pelo que a monitorização oftalmológica periódica é recomendada durante o uso prolongado, especialmente em doentes com história de glaucoma ou cataratas.',
   E'The FDA RHINOCORT AQUA label (nasal budesonide) documents in section 5.7: "Glaucoma and cataracts: Close monitoring is warranted". Intranasal corticosteroids may increase intraocular pressure in susceptible patients, including those with pre-existing open-angle glaucoma; the rise in intraocular pressure may go undetected without tonometry, so periodic ophthalmological monitoring is recommended during prolonged use, especially in patients with a history of glaucoma or cataracts.',
   E'Monitorização oftalmológica periódica (pressão intraocular e cristalino) em doentes com glaucoma ou cataratas em uso prolongado de budesonida nasal; vigiar sintomas como dor ocular, visão desfocada ou alterações da visão.',
   E'Periodic ophthalmological monitoring (intraocular pressure and lens) in patients with glaucoma or cataracts on prolonged nasal budesonide; watch for symptoms such as eye pain, blurred vision or visual changes.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Budesonida spray nasal RHINOCORT AQUA (Physicians Total Care), secção 5.7 Glaucoma and cataracts: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ffca32a2-fbef-40bb-b0f0-73f63e18e747',
   'DailyMed/FDA (NIH/NLM) — approved Budesonide nasal spray RHINOCORT AQUA label (Physicians Total Care), section 5.7 Glaucoma and cataracts: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ffca32a2-fbef-40bb-b0f0-73f63e18e747', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 3. Budesonida nasal × infeção ativa — imunossupressão (rótulo FDA 5.3)
--    (a dimensão tuberculose já existe — esta cobre as restantes)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('budesonida', 'infeccao_ativa', 'Infeção ativa', 'Active infection', 'precaution', 'moderate',
   E'O rótulo FDA do RHINOCORT AQUA documenta na secção 5.3 (Immunosuppression) o potencial agravamento de infeções: "Potential worsening of infections (e.g., existing tuberculosis, fungal, bacterial, viral, or parasitic infections; or ocular herpes simplex). Use with caution in patients with these infections". Os corticosteróides nasais podem suprimir a resposta imunitária local e sistémica, favorecendo a propagação de infeções ativas; doentes com infeções fúngicas, bacterianas, virais ou parasitárias não tratadas (e herpes ocular simples) devem usar o fármaco com precaução. A tuberculose ativa ou latente já é objeto da dimensão própria (tuberculose) — esta dimensão cobre as restantes infeções.',
   E'The FDA RHINOCORT AQUA label documents in section 5.3 (Immunosuppression) the potential worsening of infections: "Potential worsening of infections (e.g., existing tuberculosis, fungal, bacterial, viral, or parasitic infections; or ocular herpes simplex). Use with caution in patients with these infections". Nasal corticosteroids may suppress local and systemic immune responses, favouring the spread of active infections; patients with untreated fungal, bacterial, viral or parasitic infections (and ocular herpes simplex) should use the drug with caution. Active or latent tuberculosis is already covered by its own dimension (tuberculose) — this dimension covers the remaining infections.',
   E'Usar com precaução em doentes com infeção ativa (fúngica, bacteriana, viral, parasitária ou herpes ocular simples); tratar a infeção antes de iniciar ou durante o uso de budesonida nasal e vigiar o agravamento.',
   E'Use with caution in patients with active infection (fungal, bacterial, viral, parasitic or ocular herpes simplex); treat the infection before starting or during nasal budesonide use and monitor for worsening.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Budesonida spray nasal RHINOCORT AQUA (Physicians Total Care), secção 5.3 Immunosuppression: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ffca32a2-fbef-40bb-b0f0-73f63e18e747',
   'DailyMed/FDA (NIH/NLM) — approved Budesonide nasal spray RHINOCORT AQUA label (Physicians Total Care), section 5.3 Immunosuppression: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ffca32a2-fbef-40bb-b0f0-73f63e18e747', 2)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;
