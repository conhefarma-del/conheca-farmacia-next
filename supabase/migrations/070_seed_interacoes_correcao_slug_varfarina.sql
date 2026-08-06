-- =====================================================================
-- 070 — Correção de slug 'varfarina' → 'warfarina' em 3 pares (062/066)
-- ---------------------------------------------------------------------
-- As migrações 062 (metamizol) e 066 (orlistat, omeprazol) usaram o slug
-- 'varfarina' em 3 pares fármaco-fármaco, mas o fármaco na BD é
-- 'warfarina'. Como o INSERT usa JOIN (a.slug = v.slug_a / b.slug =
-- v.slug_b), essas 3 linhas foram descartadas silenciosamente quando as
-- migrações foram aplicadas. Esta migração garante (idempotente, ON
-- CONFLICT DO NOTHING) que os 3 pares existem com o slug correto.
-- As fontes são as das migrações originais (DailyMed/FDA; EMA como
-- referência adicional no par metamizol).
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), v.severity, v.summary_pt, v.summary_en,
       v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
       v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
       v.source_pt, v.source_en, 'published'
FROM (VALUES
  ('metamizol', 'warfarina', 'moderate',
   'O metamizol pode potenciar o efeito dos anticoagulantes orais, aumentando o risco hemorrágico.',
   'Metamizole may potentiate the effect of oral anticoagulants, increasing bleeding risk.',
   'Mecanismo não totalmente esclarecido; o metamizol pode potenciar o efeito dos cumarínicos e aumentar o risco de hemorragia gastrointestinal.',
   'Mechanism not fully established; metamizole may enhance coumarin anticoagulants and increase gastrointestinal bleeding risk.',
   'Monitorizar o INR e sinais de hemorragia; se possível, preferir paracetamol como analgésico.',
   'Monitor INR and signs of bleeding; where possible prefer paracetamol as analgesic.',
   'INR, equimoses, hemorragias, queda do valor de hemoglobina.',
   'INR, bruising, bleeding and fall in haemoglobin.',
   'INR acima do alvo ou hemorragia ativa exigem ajuste do anticoagulante.',
   'INR above target or active bleeding require anticoagulant adjustment.',
   'EMA — Metamizole (referência Article 31): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) e SmPC nacional Analgin 500 mg (HALMED)',
   'EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — with additional references: Prontuário Terapêutico do INFARMED (11th ed., 2012) and national Analgin 500 mg SmPC (HALMED)'),
  ('orlistat', 'warfarina', 'moderate',
   'O orlistato pode reduzir a absorção da vitamina K e alterar o INR em doentes a tomar varfarina.',
   'Orlistat may reduce vitamin K absorption and alter the INR in patients taking warfarin.',
   'A diminuição da absorção de vitamina K lipossolúvel interfere com a síntese dos fatores de coagulação dependentes da vitamina K.',
   'Reduced fat-soluble vitamin K absorption interferes with synthesis of vitamin K-dependent clotting factors.',
   'Monitorizar o INR com maior frequência ao iniciar, ajustar ou suspender o orlistato.',
   'Monitor the INR more frequently when starting, adjusting or stopping orlistat.',
   'Vigiar sinais de hemorragia e o INR.',
   'Monitor bleeding signs and INR.',
   'Hemorragia ou eventos trombóticos por INR instável.',
   'Bleeding or thrombotic events from unstable INR.',
   'DailyMed (FDA) — rótulo aprovado Orlistato: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a2d3bd73-f3af-4ea5-a57c-66b0004cfe4f ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed (FDA) — approved Orlistat label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a2d3bd73-f3af-4ea5-a57c-66b0004cfe4f ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('omeprazol', 'warfarina', 'moderate',
   'O omeprazol pode aumentar ligeiramente o efeito da varfarina, com risco de elevação do INR.',
   'Omeprazole may slightly increase the effect of warfarin, with a risk of INR elevation.',
   'O omeprazol inibe o CYP2C19 e pode alterar o metabolismo da varfarina (isómero R).',
   'Omeprazole inhibits CYP2C19 and may alter warfarin metabolism (R-isomer).',
   'Monitorizar o INR ao iniciar ou suspender o omeprazol.',
   'Monitor the INR when starting or stopping omeprazole.',
   'Monitorizar INR com maior frequência.',
   'Monitor the INR more frequently.',
   'Hemorragia por INR supraterapêutico.',
   'Bleeding from supratherapeutic INR.',
   'DailyMed (FDA) — rótulo aprovado Omeprazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6ea9a6f3-b756-4cdf-b3db-f666a2c17d66 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed (FDA) — approved Omeprazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6ea9a6f3-b756-4cdf-b3db-f666a2c17d66 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
       management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
