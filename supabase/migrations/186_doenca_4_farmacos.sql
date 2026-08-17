-- =====================================================================
-- 186: Dimensão doença/condição (drug_disease_interactions) para os 4
--      fármacos da BD sem nenhuma condição registada (auditoria de
--      cobertura por vertente — docs/INTERACOES_FLUXO_PESQUISA.md):
--      tacrolimus, sirolimus, indacaterol, azelastina
--
-- Âncoras (nunca inventar fontes ou conteúdo):
--   * Tacrolimus  — DailyMed Prograf (Astellas): secções "Dosage
--     Modification for Patients with Renal/Hepatic Impairment"
--   * Sirolimus   — DailyMed/Rapamune: "reduce the maintenance dose
--     by approximately one third in mild or moderate hepatic impairment
--     and by approximately one half in severe hepatic impairment"
--   * Indacaterol — EMC-UK Onbrez Breezhaler SmPC: sem dados em IH
--     grave; efeitos cardiovasculares beta2-agonistas (taquicardia,
--     arritmias); hipocaliemia
--   * Azelastina  — DailyMed Astelin: "renal insufficiency (creatinine
--     clearance <50 mL/min) resulted in a 70-75% higher Cmax and AUC";
--     farmacocinética não influenciada pela IH
--
-- condition_slug usa o vocabulário existente (insuficiencia_renal,
-- insuficiencia_hepatica, insuficiencia_hepatica_grave,
-- doenca_cardiovascular_grave, hipocaliemia). Idempotente:
-- ON CONFLICT (drug_id, condition_slug) DO NOTHING. Não depende de
-- migrações novas (todos os fármacos já existem na BD).
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
  -- =====================================================================
  -- TACROLIMUS (2) — DailyMed Prograf: ajuste de dose na IH e IR
  -- =====================================================================
  ('tacrolimus', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'Rótulo Prograf: "Dosage Modification for Patients with Renal Impairment". O tacrolimus é nefrotóxico e a disfunção renal prévia aumenta o risco de lesão renal adicional e de toxicidade por acumulação.',
   E'Prograf label: "Dosage Modification for Patients with Renal Impairment". Tacrolimus is nephrotoxic and pre-existing renal dysfunction increases the risk of further renal injury and accumulation-related toxicity.',
   E'Avaliar a função renal antes de iniciar e monitorizar durante o tratamento; considerar redução da dose em doentes com insuficiência renal e monitorizar níveis de tacrolimus quando disponível.',
   E'Assess renal function before starting and monitor during treatment; consider dose reduction in patients with renal impairment and monitor tacrolimus levels when available.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Prograf (tacrolimus, Astellas), secção Dosage Modification for Patients with Renal Impairment: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7f667de1-9dfa-4bd6-8ba0-15ee2d78873b', E'DailyMed/FDA (NIH/NLM) — approved Prograf (tacrolimus, Astellas) label, Dosage Modification for Patients with Renal Impairment section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7f667de1-9dfa-4bd6-8ba0-15ee2d78873b', 1),

  ('tacrolimus', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment', 'precaution', 'moderate',
   E'Rótulo Prograf: "Dosage Modification for Patients with Hepatic Impairment". O metabolismo hepático do tacrolimus está reduzido na IH, aumentando as concentrações e o risco de toxicidade (nefrotoxicidade, neurotoxicidade, hiperglicemia).',
   E'Prograf label: "Dosage Modification for Patients with Hepatic Impairment". Hepatic metabolism of tacrolimus is reduced in hepatic impairment, raising concentrations and the risk of toxicity (nephrotoxicity, neurotoxicity, hyperglycaemia).',
   E'Reduzir a dose em doentes com insuficiência hepática (em especial na IH grave) e monitorizar níveis de tacrolimus quando disponível.',
   E'Reduce the dose in patients with hepatic impairment (especially severe) and monitor tacrolimus levels when available.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Prograf (tacrolimus, Astellas), secção Dosage Modification for Patients with Hepatic Impairment: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7f667de1-9dfa-4bd6-8ba0-15ee2d78873b', E'DailyMed/FDA (NIH/NLM) — approved Prograf (tacrolimus, Astellas) label, Dosage Modification for Patients with Hepatic Impairment section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7f667de1-9dfa-4bd6-8ba0-15ee2d78873b', 2),

  -- =====================================================================
  -- SIROLIMUS (2) — DailyMed/Rapamune: redução de dose na IH
  -- =====================================================================
  ('sirolimus', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment', 'precaution', 'moderate',
   E'Rótulo Rapamune: "It is recommended that the maintenance dose of sirolimus tablets be reduced by approximately one third in patients with mild or moderate hepatic impairment". O metabolismo do sirolimus é hepático (CYP3A4) e a IH aumenta a exposição.',
   E'Rapamune label: "It is recommended that the maintenance dose of sirolimus tablets be reduced by approximately one third in patients with mild or moderate hepatic impairment". Sirolimus metabolism is hepatic (CYP3A4) and hepatic impairment increases exposure.',
   E'Reduzir a dose de manutenção em cerca de um terço na IH leve a moderada; monitorizar níveis quando disponível.',
   E'Reduce the maintenance dose by approximately one third in mild to moderate hepatic impairment; monitor levels when available.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sirolimus/Rapamune, secção Patients with Hepatic Impairment (8.6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57fb4d90-3ccb-4a69-af1e-53be83f7a504', E'DailyMed/FDA (NIH/NLM) — approved Sirolimus/Rapamune label, Patients with Hepatic Impairment section (8.6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57fb4d90-3ccb-4a69-af1e-53be83f7a504', 1),

  ('sirolimus', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'precaution', 'moderate',
   E'Rótulo Rapamune: "by approximately one half in patients with severe hepatic impairment". Na IH grave a redução recomendada é de cerca de metade da dose de manutenção.',
   E'Rapamune label: "by approximately one half in patients with severe hepatic impairment". In severe hepatic impairment the recommended reduction is about half of the maintenance dose.',
   E'Reduzir a dose de manutenção em cerca de metade na IH grave; monitorizar níveis e função hepática.',
   E'Reduce the maintenance dose by approximately half in severe hepatic impairment; monitor levels and liver function.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sirolimus/Rapamune, secção Patients with Hepatic Impairment (8.6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57fb4d90-3ccb-4a69-af1e-53be83f7a504', E'DailyMed/FDA (NIH/NLM) — approved Sirolimus/Rapamune label, Patients with Hepatic Impairment section (8.6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57fb4d90-3ccb-4a69-af1e-53be83f7a504', 2),

  -- =====================================================================
  -- INDACATEROL (3) — EMC-UK Onbrez Breezhaler SmPC
  -- =====================================================================
  ('indacaterol', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'precaution', 'moderate',
   E'SmPC Onbrez: "There are no data available for use of Onbrez Breezhaler in patients with severe hepatic impairment". Sem dados de segurança na IH grave.',
   E'Onbrez SmPC: "There are no data available for use of Onbrez Breezhaler in patients with severe hepatic impairment". No safety data in severe hepatic impairment.',
   E'Usar com precaução na IH grave, dada a ausência de dados; sem ajuste de dose na IH leve a moderada.',
   E'Use with caution in severe hepatic impairment given the lack of data; no dose adjustment in mild to moderate hepatic impairment.',
   E'EMC-UK (MHRA) — SmPC aprovada Onbrez Breezhaler (indacaterol, Novartis), secção 4.2 Special populations: https://www.medicines.org.uk/emc/product/7794/smpc', E'EMC-UK (MHRA) — approved Onbrez Breezhaler (indacaterol, Novartis) SmPC, section 4.2 Special populations: https://www.medicines.org.uk/emc/product/7794/smpc', 1),

  ('indacaterol', 'doenca_cardiovascular_grave', 'Doença cardiovascular grave', 'Severe cardiovascular disease', 'precaution', 'moderate',
   E'SmPC Onbrez: "Effects on the cardiovascular system attributable to the beta2-agonistic properties of indacaterol included tachycardia, arrhythmias and...". Os beta2-agonistas de longa ação podem causar taquicardia e arritmias, sobretudo em doentes com doença cardiovascular.',
   E'Onbrez SmPC: "Effects on the cardiovascular system attributable to the beta2-agonistic properties of indacaterol included tachycardia, arrhythmias and...". Long-acting beta2-agonists may cause tachycardia and arrhythmias, especially in patients with cardiovascular disease.',
   E'Usar com precaução em doentes com doença cardiovascular grave (cardiopatia isquémica, arritmias, insuficiência cardíaca); vigiar sintomas.',
   E'Use with caution in patients with severe cardiovascular disease (ischaemic heart disease, arrhythmias, heart failure); monitor symptoms.',
   E'EMC-UK (MHRA) — SmPC aprovada Onbrez Breezhaler (indacaterol, Novartis), secção 4.4 Special warnings: https://www.medicines.org.uk/emc/product/7794/smpc', E'EMC-UK (MHRA) — approved Onbrez Breezhaler (indacaterol, Novartis) SmPC, section 4.4 Special warnings: https://www.medicines.org.uk/emc/product/7794/smpc', 2),

  ('indacaterol', 'hipocaliemia', 'Hipocaliemia', 'Hypokalaemia', 'precaution', 'moderate',
   E'SmPC Onbrez: os beta2-agonistas podem causar hipocaliemia, potencialmente grave; o risco aumenta com a associação a derivados da metilxantina, corticosteroides e diuréticos não poupadores de potássio.',
   E'Onbrez SmPC: beta2-agonists may cause potentially serious hypokalaemia; the risk increases with methylxanthine derivatives, corticosteroids and non-potassium-sparing diuretics.',
   E'Monitorizar o potássio sérico em doentes de risco (hipocaliemia prévia, uso de diuréticos ou corticosteroides).',
   E'Monitor serum potassium in at-risk patients (previous hypokalaemia, use of diuretics or corticosteroids).',
   E'EMC-UK (MHRA) — SmPC aprovada Onbrez Breezhaler (indacaterol, Novartis), secção 4.4 Special warnings: https://www.medicines.org.uk/emc/product/7794/smpc', E'EMC-UK (MHRA) — approved Onbrez Breezhaler (indacaterol, Novartis) SmPC, section 4.4 Special warnings: https://www.medicines.org.uk/emc/product/7794/smpc', 3),

  -- =====================================================================
  -- AZELASTINA (1) — DailyMed Astelin: IR aumenta exposição
  -- =====================================================================
  ('azelastina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'Rótulo Astelin: "renal insufficiency (creatinine clearance <50 mL/min) resulted in a 70-75% higher Cmax and AUC compared to normal subjects". A insuficiência renal aumenta a exposição à azelastina e ao seu metabolito ativo.',
   E'Astelin label: "renal insufficiency (creatinine clearance <50 mL/min) resulted in a 70-75% higher Cmax and AUC compared to normal subjects". Renal insufficiency increases exposure to azelastine and its active metabolite.',
   E'Vigiar efeitos sedativos/adversos em doentes com insuficiência renal (clearance <50 mL/min); considerar precaução reforçada na condução e uso de máquinas.',
   E'Watch for sedative/adverse effects in patients with renal insufficiency (clearance <50 mL/min); consider extra caution with driving and machinery.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Astelin (azelastina, spray nasal), secção Special Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=944349ca-7cdb-441a-8fd0-b8616857d338', E'DailyMed/FDA (NIH/NLM) — approved Astelin (azelastine, nasal spray) label, Special Populations section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=944349ca-7cdb-441a-8fd0-b8616857d338', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- FIM — 8 entradas doença (tacrolimus ×2, sirolimus ×2, indacaterol ×3,
-- azelastina ×1). Aplicar no Supabase e depois ./revalidar.sh
-- =====================================================================
