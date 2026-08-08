-- =====================================================================
-- 083 — Secção 7 do Prontuário Terapêutico (geniturinário)
-- ---------------------------------------------------------------------
-- 7 fármacos novos da secção 7 (7.3 anti-infecciosos/anti-sépticos
-- urinários e 7.4 outros medicamentos usados em disfunções
-- geniturinárias), com as 4 dimensões de interação e perfil de fármaco:
--   • nitrofurantoina   (7.3)
--   • tadalafil         (7.4 — PDE5)
--   • vardenafil        (7.4 — PDE5)
--   • tansulosina       (7.4 — alfa-bloqueante α1 seletivo)
--   • doxazosina        (7.4 — alfa-bloqueante α1)
--   • finasterida       (7.4 — inibidor da 5-alfa-redutase)
--   • dutasterida       (7.4 — inibidor da 5-alfa-redutase)
-- Além disso, COMPLETA o sildenafil (já existente) nas 3 dimensões
-- (alimento, doença, gestação) e cria-lhe o perfil — até aqui só tinha
-- o par com nitroglicerina.
--
-- Fontes (método do docs/INTERACOES_FLUXO_PESQUISA.md):
--   • DailyMed/FDA (NIH/NLM) — rótulos aprovados, setIDs obtidos via API
--     e extração das secções INDICATIONS, CONTRAINDICATIONS, WARNINGS,
--     ADVERSE REACTIONS e DRUG INTERACTIONS;
--   • EMC-UK (MHRA) — SmPC aprovadas, secções 4.3–4.6 (contraindicações,
--     precauções, interações, gravidez/lactação); URLs verificadas (HTTP
--     200) em 2026-08;
--   • PubMed — apoio bibliográfico dos pares (URLs pubmed.ncbi.nlm.nih.gov);
--   • Prontuário Terapêutico do INFARMED (11.ª ed., 2012, ficheiro
--     offline fontes_interacoes/prontuario_utf8.txt) — corroboração
--     clínica (secções 7.3 e 7.4).
-- Conteúdo autoral (resumido/adaptado, nunca copiado).
-- Idempotente: reaplicar é seguro (ON CONFLICT ... DO NOTHING).
-- Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fármacos novos
-- ---------------------------------------------------------------------
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order) VALUES
  ('nitrofurantoina', 'Nitrofurantoína', 'Nitrofurantoin', 'Nitrofurano (antibacteriano urinário)', 'Nitrofuran (urinary antibacterial)', ARRAY['Furadantina', 'Macrodantina'], 'published', 176),
  ('tadalafil', 'Tadalafil', 'Tadalafil', 'Inibidor da fosfodiesterase-5 (PDE5)', 'PDE-5 inhibitor', ARRAY['Cialis'], 'published', 177),
  ('vardenafil', 'Vardenafil', 'Vardenafil', 'Inibidor da fosfodiesterase-5 (PDE5)', 'PDE-5 inhibitor', ARRAY['Levitra'], 'published', 178),
  ('tansulosina', 'Tansulosina', 'Tamsulosin', 'Alfabloqueante α1 seletivo', 'Selective alpha-1 blocker', ARRAY['Omnic', 'Flomax'], 'published', 179),
  ('doxazosina', 'Doxazosina', 'Doxazosin', 'Alfabloqueante α1', 'Alpha-1 blocker', ARRAY['Cardura', 'Carduran'], 'published', 180),
  ('finasterida', 'Finasterida', 'Finasteride', 'Inibidor da 5-alfa-redutase', '5-alpha reductase inhibitor', ARRAY['Proscar', 'Propecia'], 'published', 181),
  ('dutasterida', 'Dutasterida', 'Dutasteride', 'Inibidor da 5-alfa-redutase', '5-alpha reductase inhibitor', ARRAY['Avodart'], 'published', 182);

-- ---------------------------------------------------------------------
-- 2. Pares fármaco-fármaco (novos)
--    Padrão 079: LEAST/GREATEST canónico + ON CONFLICT DO NOTHING,
--    com summary_pro_* e explanation_* (colunas da 079).
-- ---------------------------------------------------------------------

-- 2.1 TADALAFIL + NITROGLICERINA (critical — nitratos, contraindicação absoluta)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'Nunca tomar tadalafil com nitratos (como a nitroglicerina). A associação pode provocar uma descida súbita e perigosa da tensão arterial, com risco de desmaio ou enfarte.',
  'Never take tadalafil with nitrates (such as nitroglycerin). The combination can cause a sudden, dangerous drop in blood pressure, with a risk of fainting or heart attack.',
  'PDE5 + nitrato: contraindicação absoluta. Ambos aumentam o GMPc na musculatura vascular — vasodilatação aditiva com hipotensão profunda potencialmente fatal. Não coadministrar; respeitar a janela de 48–72 h (meia-vida longa do tadalafil).',
  'PDE5 + nitrate: absolute contraindication. Both raise cGMP in vascular smooth muscle — additive vasodilation with potentially fatal profound hypotension. Do not co-administer; respect the 48–72 h window (long tadalafil half-life).',
  'O tadalafil potencia o efeito hipotensor dos nitratos: ambos atuam na via do óxido nítrico/GMPc, e a sua ação conjugada provoca vasodilatação arterial e venosa marcada, com queda acentuada e potencialmente grave da pressão arterial (hipotensão sintomática, síncope, e nos casos extremos eventos isquémicos). A contraindicação é absoluta em qualquer forma de nitrato, incluindo o uso intermitente para angina. Como o tadalafil tem uma meia-vida longa (cerca de 17,5 h; efeito até 36 h), a janela de segurança antes de administrar um nitrato é maior do que com o sildenafil — não há intervalo seguro documentado, pelo que a associação deve simplesmente ser evitada. Se surgir dor torácica, o doente deve procurar assistência médica imediata e informar que tomou tadalafil.',
  'Tadalafil potentiates the hypotensive effect of nitrates: both act on the nitric oxide/cGMP pathway, and their combined action causes marked arterial and venous vasodilation with a pronounced and potentially severe fall in blood pressure (symptomatic hypotension, syncope and, in extreme cases, ischaemic events). The contraindication is absolute with any nitrate form, including intermittent use for angina. Because tadalafil has a long half-life (about 17.5 h; effect up to 36 h), the safety window before giving a nitrate is longer than with sildenafil — no safe interval is documented, so the combination should simply be avoided. If chest pain occurs, the patient should seek immediate medical help and report tadalafil use.',
  'Ambos aumentam o GMPc na musculatura lisa vascular, causando vasodilatação aditiva e hipotensão profunda.',
  'Both raise cGMP in vascular smooth muscle, causing additive vasodilation and profound hypotension.',
  'Contraindicação absoluta. Não iniciar tadalafil em doentes a tomar nitratos; se um nitrato for necessário por angina, fazê-lo apenas após intervalo prolongado e em ambiente vigiado.',
  'Absolute contraindication. Do not start tadalafil in patients taking nitrates; if a nitrate becomes necessary for angina, do so only after a prolonged interval and in a monitored setting.',
  'Tensão arterial e sintomas de hipotensão; estado hemodinâmico se ocorrer dor torácica.',
  'Blood pressure and hypotension symptoms; haemodynamic status if chest pain occurs.',
  'Síncope, tonturas graves, hipotensão acentuada, dor torácica — assistência imediata.',
  'Syncope, severe dizziness, marked hypotension, chest pain — seek immediate care.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; rótulo aprovado Nitroglicerina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16884667/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; approved Nitroglycerin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16884667/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'nitroglicerina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.2 VARDENAFIL + NITROGLICERINA (critical — nitratos, contraindicação absoluta)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'Nunca tomar vardenafil com nitratos (como a nitroglicerina). A associação pode provocar uma descida súbita e perigosa da tensão arterial, com risco de desmaio ou enfarte.',
  'Never take vardenafil with nitrates (such as nitroglycerin). The combination can cause a sudden, dangerous drop in blood pressure, with a risk of fainting or heart attack.',
  'PDE5 + nitrato: contraindicação absoluta. Vasodilatação aditiva via GMPc com hipotensão profunda potencialmente fatal; janela de segurança de 24 h após a última dose de vardenafil.',
  'PDE5 + nitrate: absolute contraindication. Additive GMPc-mediated vasodilation with potentially fatal profound hypotension; 24 h safety window after the last vardenafil dose.',
  'O vardenafil potencia a ação vasodilatadora dos nitratos pela mesma via do óxido nítrico/GMPc. A combinação, em qualquer forma de nitrato (incluindo uso intermitente para angina ou dadores de NO), causa vasodilatação aditiva com hipotensão profunda, síncope e risco de eventos isquémicos. Está contraindicada em absoluto. Se um nitrato se tornar clinicamente indispensável, recomenda-se aguardar pelo menos 24 horas após a última dose de vardenafil; doentes com dor torácica devem procurar assistência médica imediata.',
  'Vardenafil potentiates the vasodilator action of nitrates through the same nitric oxide/cGMP pathway. The combination, with any nitrate form (including intermittent use for angina or NO donors), causes additive vasodilation with profound hypotension, syncope and a risk of ischaemic events. It is absolutely contraindicated. If a nitrate becomes clinically essential, wait at least 24 hours after the last vardenafil dose; patients with chest pain should seek immediate medical care.',
  'Vasodilatação aditiva via GMPc (nitrato + PDE5), com queda acentuada da pressão arterial.',
  'Additive GMPc-mediated vasodilation (nitrate + PDE5), with a marked fall in blood pressure.',
  'Contraindicação absoluta; não iniciar vardenafil em doentes sob nitratos. Se necessário, intervalo mínimo de 24 h após a última dose, em ambiente vigiado.',
  'Absolute contraindication; do not start vardenafil in patients on nitrates. If needed, at least 24 h after the last dose, in a monitored setting.',
  'Tensão arterial e sintomas de hipotensão.',
  'Blood pressure and hypotension symptoms.',
  'Síncope, tonturas graves, hipotensão acentuada, dor torácica — assistência imediata.',
  'Syncope, severe dizziness, marked hypotension, chest pain — seek immediate care.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Nitroglicerina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16884667/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Nitroglycerin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16884667/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'vardenafil' AND b.slug = 'nitroglicerina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.3 SILDENAFIL + DOXAZOSINA (moderate — PDE5 + alfa-bloqueante)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar sildenafil com doxazosina pode baixar demasiado a tensão arterial, sobretudo ao levantar (hipotensão ortostática), com tonturas e risco de desmaio.',
  'Combining sildenafil with doxazosin can lower blood pressure too much, especially on standing (orthostatic hypotension), with dizziness and a risk of fainting.',
  'PDE5 + alfa-bloqueante: efeito vasodilatador aditivo. Estabilizar o alfa-bloqueante antes de iniciar o PDE5 e usar a menor dose inicial; doxazosina tem maior interação hemodinâmica do que tansulosina.',
  'PDE5 + alpha-blocker: additive vasodilator effect. Stabilise the alpha-blocker before starting the PDE5 and use the lowest starting dose; doxazosin has a greater haemodynamic interaction than tamsulosin.',
  'Ambas as classes causam vasodilatação; em conjunto podem produzir hipotensão ortostática sintomática, sobretudo no início do tratamento com o alfa-bloqueante ou se as doses forem altas. Em estudos, o sildenafil e o tadalafil aumentaram o efeito hipotensor da doxazosina. Recomenda-se que o doente esteja estável no alfa-bloqueante antes de iniciar o PDE5, com dose inicial baixa e avaliação da tolerância.',
  'Both classes cause vasodilation; together they can produce symptomatic orthostatic hypotension, especially when the alpha-blocker is started or at high doses. In studies, sildenafil and tadalafil increased the hypotensive effect of doxazosin. The patient should be stabilised on the alpha-blocker before starting the PDE5, with a low starting dose and tolerability assessment.',
  'Efeito vasodilatador aditivo entre PDE5 e alfa-bloqueante α1.',
  'Additive vasodilator effect between PDE5 and alpha-1 blocker.',
  'Estabilizar o alfa-bloqueante antes de iniciar o PDE5; iniciar com a menor dose do PDE5; advertir para levantar lentamente.',
  'Stabilise the alpha-blocker before starting the PDE5; start with the lowest PDE5 dose; advise standing up slowly.',
  'Tensão arterial ortostática e sintomas no início da associação.',
  'Orthostatic blood pressure and symptoms when starting the combination.',
  'Tonturas ao levantar, síncope, hipotensão sintomática.',
  'Dizziness on standing, syncope, symptomatic hypotension.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Doxazosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Doxazosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'sildenafil' AND b.slug = 'doxazosina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.4 SILDENAFIL + TANSULOSINA (moderate — PDE5 + alfa-bloqueante)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar sildenafil com tansulosina pode baixar a tensão arterial e causar tonturas ou desmaio, sobretudo ao levantar.',
  'Combining sildenafil with tamsulosin can lower blood pressure and cause dizziness or fainting, especially on standing.',
  'PDE5 + tansulosina: risco de hipotensão sintomática documentado nos rótulos. A tansulosina tem menor interação hemodinâmica do que outros alfa-bloqueantes, mas a cautela mantém-se; estabilizar e usar dose inicial baixa.',
  'PDE5 + tamsulosin: risk of symptomatic hypotension documented in labels. Tamsulosin has less haemodynamic interaction than other alpha-blockers, but caution remains; stabilise and use a low starting dose.',
  'A coadministração de inibidores da PDE5 com tansulosina pode causar hipotensão sintomática em alguns doentes, pelo efeito vasodilatador conjunto. Embora a tansulosina seja mais seletiva e com menor interação hemodinâmica do que outros alfa-bloqueantes (a doxazosina, por exemplo, mostrou maior efeito aditivo em estudos), o rótulo da tansulosina recomenda prudência.',
  'Co-administration of PDE5 inhibitors with tamsulosin can cause symptomatic hypotension in some patients, due to the combined vasodilator effect. Although tamsulosin is more selective and has less haemodynamic interaction than other alpha-blockers (doxazosin, for example, showed a greater additive effect in studies), the tamsulosin label advises caution.',
  'Efeito vasodilatador aditivo (PDE5 + antagonista α1).',
  'Additive vasodilator effect (PDE5 + alpha-1 antagonist).',
  'Estabilizar a tansulosina antes de iniciar o PDE5; iniciar com dose baixa e avaliar tolerância.',
  'Stabilise tamsulosin before starting the PDE5; start low and assess tolerability.',
  'Tensão arterial ortostática e sintomas no início da associação.',
  'Orthostatic blood pressure and symptoms when starting the combination.',
  'Tonturas ao levantar, síncope.',
  'Dizziness on standing, syncope.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'sildenafil' AND b.slug = 'tansulosina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.5 TADALAFIL + DOXAZOSINA (moderate)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar tadalafil com doxazosina pode baixar demasiado a tensão arterial, sobretudo ao levantar, com tonturas e risco de desmaio.',
  'Combining tadalafil with doxazosin can lower blood pressure too much, especially on standing, with dizziness and a risk of fainting.',
  'PDE5 + alfa-bloqueante: o tadalafil aumentou o efeito hipotensor da doxazosina em estudos; estabilizar o alfa-bloqueante e iniciar o PDE5 com a menor dose.',
  'PDE5 + alpha-blocker: tadalafil augmented doxazosin hypotensive effect in studies; stabilise the alpha-blocker and start the PDE5 at the lowest dose.',
  'Em estudo controlado, o tadalafil aumentou os efeitos hipotensores da doxazosina, mas teve pouca interação hemodinâmica com a tansulosina. A combinação deve ser iniciada com precaução: doente estável no alfa-bloqueante, menor dose de tadalafil e advertência para hipotensão ortostática.',
  'In a controlled study, tadalafil augmented the hypotensive effects of doxazosin but had little haemodynamic interaction with tamsulosin. The combination should be started with caution: patient stable on the alpha-blocker, lowest tadalafil dose and warning about orthostatic hypotension.',
  'Efeito vasodilatador aditivo (PDE5 + antagonista α1).',
  'Additive vasodilator effect (PDE5 + alpha-1 antagonist).',
  'Estabilizar o alfa-bloqueante; iniciar tadalafil na menor dose; monitorizar sintomas ortostáticos.',
  'Stabilise the alpha-blocker; start tadalafil at the lowest dose; monitor orthostatic symptoms.',
  'Tensão arterial ortostática no início da associação.',
  'Orthostatic blood pressure when starting the combination.',
  'Tonturas ao levantar, síncope, hipotensão sintomática.',
  'Dizziness on standing, syncope, symptomatic hypotension.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/15540759/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/15540759/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'doxazosina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.6 VARDENAFIL + DOXAZOSINA (moderate)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar vardenafil com doxazosina pode baixar demasiado a tensão arterial, sobretudo ao levantar, com tonturas e risco de desmaio.',
  'Combining vardenafil with doxazosin can lower blood pressure too much, especially on standing, with dizziness and a risk of fainting.',
  'PDE5 + alfa-bloqueante: efeito hipotensor aditivo documentado; estabilizar o alfa-bloqueante e iniciar o vardenafil com 5 mg.',
  'PDE5 + alpha-blocker: documented additive hypotensive effect; stabilise the alpha-blocker and start vardenafil at 5 mg.',
  'A coadministração de vardenafil com alfa-bloqueantes (doxazosina) pode causar hipotensão sintomática pela vasodilatação aditiva. Em doentes estáveis em alfa-bloqueante, o rótulo recomenda iniciar o vardenafil com a dose de 5 mg e monitorizar a tolerância.',
  'Co-administration of vardenafil with alpha-blockers (doxazosin) can cause symptomatic hypotension through additive vasodilation. In patients stable on an alpha-blocker, the label recommends starting vardenafil at 5 mg and monitoring tolerability.',
  'Efeito vasodilatador aditivo (PDE5 + antagonista α1).',
  'Additive vasodilator effect (PDE5 + alpha-1 antagonist).',
  'Estabilizar o alfa-bloqueante; iniciar vardenafil 5 mg; monitorizar sintomas ortostáticos.',
  'Stabilise the alpha-blocker; start vardenafil 5 mg; monitor orthostatic symptoms.',
  'Tensão arterial ortostática no início da associação.',
  'Orthostatic blood pressure when starting the combination.',
  'Tonturas ao levantar, síncope.',
  'Dizziness on standing, syncope.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Doxazosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Doxazosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/16387566/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'vardenafil' AND b.slug = 'doxazosina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.7 TADALAFIL + TANSULOSINA (moderate)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar tadalafil com tansulosina pode baixar a tensão arterial e causar tonturas ou desmaio, sobretudo ao levantar.',
  'Combining tadalafil with tamsulosin can lower blood pressure and cause dizziness or fainting, especially on standing.',
  'PDE5 + tansulosina: o rótulo do tadalafil desaconselha a associação para HPB e aconselha cautela na disfunção erétil; estudo mostrou pouca interação hemodinâmica com a tansulosina.',
  'PDE5 + tamsulosin: the tadalafil label advises against the combination for BPH and advises caution in erectile dysfunction; a study showed little haemodynamic interaction with tamsulosin.',
  'A associação de tadalafil com alfa-bloqueantes pode causar hipotensão sintomática. O rótulo do tadalafil não recomenda a combinação com alfa-bloqueantes no tratamento da HPB (eficácia não estudada e risco de descida da tensão arterial) e aconselha cautela quando usado para disfunção erétil. Em estudo, o tadalafil teve pouca interação hemodinâmica com a tansulosina, mas a precaução mantém-se.',
  'Combining tadalafil with alpha-blockers can cause symptomatic hypotension. The tadalafil label does not recommend combining with alpha-blockers for BPH treatment (efficacy not studied and risk of blood pressure lowering) and advises caution when used for erectile dysfunction. In a study, tadalafil had little haemodynamic interaction with tamsulosin, but caution remains.',
  'Efeito vasodilatador aditivo (PDE5 + antagonista α1).',
  'Additive vasodilator effect (PDE5 + alpha-1 antagonist).',
  'Usar com cautela; considerar dose inicial baixa; monitorizar sintomas ortostáticos.',
  'Use with caution; consider a low starting dose; monitor orthostatic symptoms.',
  'Tensão arterial ortostática no início da associação.',
  'Orthostatic blood pressure when starting the combination.',
  'Tonturas ao levantar, síncope.',
  'Dizziness on standing, syncope.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/15540759/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/15540759/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'tansulosina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.8 TADALAFIL + CETOCONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol pode aumentar os níveis de tadalafil no sangue (o cetoconazol 400 mg/dia pode quadruplicar a exposição), com maior risco de efeitos secundários.',
  'Ketoconazole can raise tadalafil blood levels (ketoconazole 400 mg/day can quadruple exposure), with a higher risk of side effects.',
  'CYP3A4: o cetoconazol (inibidor forte) aumentou a AUC do tadalafil 2–4x. Ajustar a dose: tadalafil ocasional máx. 10 mg a cada 72 h; uso diário máx. 2,5 mg.',
  'CYP3A4: ketoconazole (strong inhibitor) increased tadalafil AUC 2–4-fold. Adjust the dose: as-needed tadalafil max. 10 mg every 72 h; daily use max. 2.5 mg.',
  'O tadalafil é metabolizado principalmente pelo CYP3A4. O cetoconazol (200 mg/dia) aumentou a exposição (AUC) do tadalafil 2 vezes; com 400 mg/dia, 4 vezes. Aumenta a incidência de efeitos adversos (cefaleia, dispepsia, mialgia, rubor, congestão nasal). Outros inibidores fortes do CYP3A4 (ritonavir, itraconazol, claritromicina) têm efeito semelhante esperado.',
  'Tadalafil is mainly metabolised by CYP3A4. Ketoconazole (200 mg/day) increased tadalafil exposure (AUC) 2-fold; at 400 mg/day, 4-fold. This increases adverse reactions (headache, dyspepsia, myalgia, flushing, nasal congestion). Other strong CYP3A4 inhibitors (ritonavir, itraconazole, clarithromycin) are expected to have a similar effect.',
  'Inibição do CYP3A4 pelo cetoconazol, reduzindo o clearance do tadalafil.',
  'CYP3A4 inhibition by ketoconazole, reducing tadalafil clearance.',
  'Ajustar a dose conforme o rótulo (ocasional: máx. 10 mg/72 h; diário: máx. 2,5 mg) e vigiar efeitos adversos.',
  'Adjust the dose per the label (as-needed: max. 10 mg/72 h; daily: max. 2.5 mg) and watch for adverse effects.',
  'Efeitos adversos do tadalafil (cefaleia, rubor, mialgia, dispepsia).',
  'Tadalafil adverse effects (headache, flushing, myalgia, dyspepsia).',
  'Cefaleia intensa, hipotensão sintomática, priapismo.',
  'Severe headache, symptomatic hypotension, priapism.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.9 VARDENAFIL + CETOCONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol aumenta muito os níveis de vardenafil no sangue (até 10 vezes), com risco elevado de efeitos secundários. A associação deve ser evitada, sobretudo em homens com mais de 75 anos.',
  'Ketoconazole greatly raises vardenafil blood levels (up to 10-fold), with a high risk of side effects. The combination should be avoided, especially in men over 75.',
  'CYP3A4: o cetoconazol aumentou a AUC do vardenafil ~10x. Evitar a associação; se inevitável, dose máx. de vardenafil 2,5 mg/24 h (ou 5 mg com cetoconazol 200 mg); contraindicada em >75 anos.',
  'CYP3A4: ketoconazole increased vardenafil AUC ~10-fold. Avoid the combination; if unavoidable, max vardenafil 2.5 mg/24 h (or 5 mg with ketoconazole 200 mg); contraindicated over 75 years.',
  'O vardenafil é metabolizado pelo CYP3A4. O cetoconazol (200 mg) aumentou a AUC do vardenafil cerca de 10 vezes e a Cmax 4 vezes. O uso concomitante com cetoconazol ou itraconazol (orais) deve ser evitado; em homens com mais de 75 anos é contraindicado. Aumenta o risco de cefaleia, rubor, dispepsia, congestão nasal e hipotensão.',
  'Vardenafil is metabolised by CYP3A4. Ketoconazole (200 mg) increased vardenafil AUC about 10-fold and Cmax 4-fold. Concomitant use with ketoconazole or itraconazole (oral) should be avoided; it is contraindicated in men over 75. It increases the risk of headache, flushing, dyspepsia, nasal congestion and hypotension.',
  'Inibição do CYP3A4, reduzindo o clearance do vardenafil.',
  'CYP3A4 inhibition, reducing vardenafil clearance.',
  'Evitar a associação; se inevitável, reduzir a dose de vardenafil conforme o rótulo.',
  'Avoid the combination; if unavoidable, reduce the vardenafil dose per the label.',
  'Efeitos adversos do vardenafil e sintomas de hipotensão.',
  'Vardenafil adverse effects and hypotension symptoms.',
  'Cefaleia intensa, hipotensão sintomática, priapismo.',
  'Severe headache, symptomatic hypotension, priapism.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — SmPC aprovada Vardenafil: https://www.medicines.org.uk/emc/product/11394/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — approved Vardenafil SmPC: https://www.medicines.org.uk/emc/product/11394/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'vardenafil' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.10 TADALAFIL + CLARITROMICINA (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A claritromicina pode aumentar os níveis de tadalafil no sangue, com maior risco de efeitos secundários. Vigiar e considerar ajuste de dose.',
  'Clarithromycin can raise tadalafil blood levels, with a higher risk of side effects. Monitor and consider dose adjustment.',
  'CYP3A4: a claritromicina (inibidor) aumenta a exposição do tadalafil; ajustar como com outros inibidores fortes (ocasional máx. 10 mg/72 h; diário máx. 2,5 mg).',
  'CYP3A4: clarithromycin (inhibitor) increases tadalafil exposure; adjust as with other strong inhibitors (as-needed max. 10 mg/72 h; daily max. 2.5 mg).',
  'O tadalafil é metabolizado pelo CYP3A4; inibidores desta enzima, como a claritromicina, aumentam as concentrações plasmáticas e a incidência de efeitos adversos. O rótulo recomenda os mesmos ajustes de dose que para o cetoconazol.',
  'Tadalafil is metabolised by CYP3A4; inhibitors of this enzyme, such as clarithromycin, raise plasma concentrations and the incidence of adverse effects. The label recommends the same dose adjustments as for ketoconazole.',
  'Inibição do CYP3A4 pela claritromicina.',
  'CYP3A4 inhibition by clarithromycin.',
  'Ajustar a dose do tadalafil conforme o rótulo durante o curso de claritromicina.',
  'Adjust the tadalafil dose per the label during the clarithromycin course.',
  'Efeitos adversos do tadalafil.',
  'Tadalafil adverse effects.',
  'Cefaleia intensa, hipotensão sintomática, priapismo.',
  'Severe headache, symptomatic hypotension, priapism.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; rótulo aprovado Claritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; approved Clarithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'claritromicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.11 VARDENAFIL + CLARITROMICINA (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A claritromicina pode aumentar os níveis de vardenafil no sangue, com maior risco de efeitos secundários. Ajustar a dose (máx. 2,5 mg/24 h durante o curso).',
  'Clarithromycin can raise vardenafil blood levels, with a higher risk of side effects. Adjust the dose (max. 2.5 mg/24 h during the course).',
  'CYP3A4: a claritromicina é inibidora moderada/forte do CYP3A4; o rótulo limita o vardenafil a 2,5 mg/24 h com claritromicina.',
  'CYP3A4: clarithromycin is a moderate/strong CYP3A4 inhibitor; the label limits vardenafil to 2.5 mg/24 h with clarithromycin.',
  'A claritromicina inibe o CYP3A4, aumentando a exposição ao vardenafil. O rótulo do vardenafil define, para inibidores como claritromicina e cetoconazol, dose máxima de 2,5 mg em 24 horas durante a coadministração.',
  'Clarithromycin inhibits CYP3A4, increasing vardenafil exposure. The vardenafil label sets, for inhibitors such as clarithromycin and ketoconazole, a maximum dose of 2.5 mg in 24 hours during co-administration.',
  'Inibição do CYP3A4 pela claritromicina.',
  'CYP3A4 inhibition by clarithromycin.',
  'Limitar a dose de vardenafil a 2,5 mg/24 h durante o curso de claritromicina.',
  'Limit vardenafil to 2.5 mg/24 h during the clarithromycin course.',
  'Efeitos adversos do vardenafil.',
  'Vardenafil adverse effects.',
  'Cefaleia intensa, hipotensão sintomática.',
  'Severe headache, symptomatic hypotension.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Claritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Clarithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'vardenafil' AND b.slug = 'claritromicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.12 TADALAFIL + RIFAMPICINA (moderate — CYP3A4 indutor)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina reduz muito os níveis de tadalafil no sangue (até 88% de redução da exposição), podendo diminuir a eficácia do tratamento.',
  'Rifampicin greatly reduces tadalafil blood levels (up to 88% reduction in exposure), which may reduce treatment effectiveness.',
  'CYP3A4 indutor: a rifampicina reduziu a AUC do tadalafil em 88%; a eficácia pode diminuir. Considerar alternativa ou ajuste.',
  'CYP3A4 inducer: rifampicin reduced tadalafil AUC by 88%; efficacy may decrease. Consider an alternative or adjustment.',
  'A rifampicina é um indutor potente do CYP3A4 e reduziu a exposição (AUC) ao tadalafil em 88%. Outros indutores (fenobarbital, fenitoína, carbamazepina) têm efeito semelhante esperado. A eficácia do tadalafil pode ficar comprometida.',
  'Rifampicin is a potent CYP3A4 inducer and reduced tadalafil exposure (AUC) by 88%. Other inducers (phenobarbital, phenytoin, carbamazepine) are expected to act similarly. Tadalafil efficacy may be compromised.',
  'Indução do CYP3A4 pela rifampicina, acelerando o clearance do tadalafil.',
  'CYP3A4 induction by rifampicin, accelerating tadalafil clearance.',
  'Vigiar a resposta clínica; considerar alternativa ao tadalafil durante o curso de rifampicina.',
  'Monitor clinical response; consider an alternative to tadalafil during the rifampicin course.',
  'Resposta clínica ao tadalafil.',
  'Clinical response to tadalafil.',
  'Falta de efeito terapêutico.',
  'Lack of therapeutic effect.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tadalafil' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.13 VARDENAFIL + RIFAMPICINA (moderate — CYP3A4 indutor)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina reduz os níveis de vardenafil no sangue, podendo diminuir a eficácia do tratamento.',
  'Rifampicin reduces vardenafil blood levels, which may reduce treatment effectiveness.',
  'CYP3A4 indutor: a rifampicina acelera o clearance do vardenafil (metabolizado pelo CYP3A4); vigiar a resposta clínica.',
  'CYP3A4 inducer: rifampicin accelerates vardenafil clearance (CYP3A4 substrate); monitor clinical response.',
  'O vardenafil é metabolizado predominantemente pelo CYP3A4; a rifampicina, indutora potente desta enzima, reduz as concentrações plasmáticas e pode comprometer a eficácia.',
  'Vardenafil is predominantly metabolised by CYP3A4; rifampicin, a potent inducer of this enzyme, reduces plasma concentrations and may compromise efficacy.',
  'Indução do CYP3A4 pela rifampicina.',
  'CYP3A4 induction by rifampicin.',
  'Vigiar a resposta clínica; considerar alternativa durante o curso de rifampicina.',
  'Monitor clinical response; consider an alternative during the rifampicin course.',
  'Resposta clínica ao vardenafil.',
  'Clinical response to vardenafil.',
  'Falta de efeito terapêutico.',
  'Lack of therapeutic effect.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'vardenafil' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.14 TANSULOSINA + CETOCONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol aumenta os níveis de tansulosina no sangue (até ~2,8 vezes), com maior risco de hipotensão e tonturas.',
  'Ketoconazole raises tamsulosin blood levels (up to ~2.8-fold), with a higher risk of hypotension and dizziness.',
  'CYP3A4: o cetoconazol aumentou a AUC da tansulosina ~2,8x. Não usar com inibidores fortes do CYP3A4 em doentes metabolizadores lentos de CYP2D6; usar com cautela nos restantes.',
  'CYP3A4: ketoconazole increased tamsulosin AUC ~2.8-fold. Do not use with strong CYP3A4 inhibitors in CYP2D6 poor metabolisers; use with caution in others.',
  'A tansulosina é metabolizada pelo CYP3A4 e CYP2D6. O cetoconazol (400 mg/dia) aumentou a Cmax 2,2x e a AUC 2,8x da tansulosina. A associação com inibidores fortes do CYP3A4 deve ser evitada em doentes metabolizadores lentos de CYP2D6 e usada com cautela nos demais, pelo risco de hipotensão e efeitos adversos.',
  'Tamsulosin is metabolised by CYP3A4 and CYP2D6. Ketoconazole (400 mg/day) increased tamsulosin Cmax 2.2-fold and AUC 2.8-fold. Combining with strong CYP3A4 inhibitors should be avoided in CYP2D6 poor metabolisers and used with caution in others, due to the risk of hypotension and adverse effects.',
  'Inibição do CYP3A4, reduzindo o clearance da tansulosina.',
  'CYP3A4 inhibition, reducing tamsulosin clearance.',
  'Evitar a associação em metabolizadores lentos de CYP2D6; nos restantes, usar com cautela e vigiar hipotensão.',
  'Avoid the combination in CYP2D6 poor metabolisers; in others, use with caution and watch for hypotension.',
  'Tensão arterial ortostática e efeitos adversos da tansulosina.',
  'Orthostatic blood pressure and tamsulosin adverse effects.',
  'Tonturas, hipotensão sintomática, síncope.',
  'Dizziness, symptomatic hypotension, syncope.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — SmPC aprovada Tansulosina: https://www.medicines.org.uk/emc/product/102038/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — approved Tamsulosin SmPC: https://www.medicines.org.uk/emc/product/102038/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tansulosina' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.15 DOXAZOSINA + CETOCONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol pode aumentar os níveis de doxazosina no sangue, com maior risco de hipotensão. Usar com cautela.',
  'Ketoconazole can raise doxazosin blood levels, with a higher risk of hypotension. Use with caution.',
  'CYP3A4: a doxazosina é substrato do CYP3A4; inibidores fortes (cetoconazol, itraconazol, claritromicina) aumentam a exposição e o risco de hipotensão.',
  'CYP3A4: doxazosin is a CYP3A4 substrate; strong inhibitors (ketoconazole, itraconazole, clarithromycin) increase exposure and the risk of hypotension.',
  'A doxazosina é metabolizada pelo CYP3A4. Inibidores fortes desta enzima (cetoconazol, itraconazol, claritromicina, indinavir, ritonavir, saquinavir) aumentam as concentrações plasmáticas e o risco de hipotensão postural.',
  'Doxazosin is metabolised by CYP3A4. Strong inhibitors of this enzyme (ketoconazole, itraconazole, clarithromycin, indinavir, ritonavir, saquinavir) raise plasma concentrations and the risk of postural hypotension.',
  'Inibição do CYP3A4, reduzindo o clearance da doxazosina.',
  'CYP3A4 inhibition, reducing doxazosin clearance.',
  'Usar com cautela e monitorizar a tensão arterial, sobretudo no início.',
  'Use with caution and monitor blood pressure, especially at initiation.',
  'Tensão arterial ortostática.',
  'Orthostatic blood pressure.',
  'Tonturas ao levantar, hipotensão sintomática, síncope.',
  'Dizziness on standing, symptomatic hypotension, syncope.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Doxazosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — SmPC aprovada Doxazosina: https://www.medicines.org.uk/emc/product/102410/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Doxazosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — approved Doxazosin SmPC: https://www.medicines.org.uk/emc/product/102410/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'doxazosina' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.16 DUTASTERIDA + CETOCONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol (ou outros inibidores fortes do CYP3A4) pode aumentar os níveis de dutasterida no sangue. Usar com cautela e vigiar efeitos secundários.',
  'Ketoconazole (or other strong CYP3A4 inhibitors) can raise dutasteride blood levels. Use with caution and watch for side effects.',
  'CYP3A4: a dutasterida é eliminada por metabolismo CYP3A4/3A5; inibidores fortes (cetoconazol, itraconazol, ritonavir) aumentam as concentrações séricas. Em uso prolongado, considerar reduzir a frequência de dose.',
  'CYP3A4: dutasteride is eliminated by CYP3A4/3A5 metabolism; strong inhibitors (ketoconazole, itraconazole, ritonavir) raise serum concentrations. In long-term use, consider reducing dose frequency.',
  'A dutasterida é eliminada principalmente por metabolismo hepático (CYP3A4/3A5). Inibidores potentes desta enzima aumentam as concentrações séricas; em estudos populacionais, inibidores moderados (verapamil, diltiazem) aumentaram as concentrações 1,6–1,8x. A meia-vida longa pode prolongar-se ainda mais, demorando mais de 6 meses a atingir novo estado estacionário.',
  'Dutasteride is eliminated mainly by hepatic metabolism (CYP3A4/3A5). Potent inhibitors of this enzyme raise serum concentrations; in population studies, moderate inhibitors (verapamil, diltiazem) increased concentrations 1.6–1.8-fold. The long half-life may be further prolonged, taking more than 6 months to reach a new steady state.',
  'Inibição do CYP3A4/3A5, reduzindo a eliminação da dutasterida.',
  'CYP3A4/3A5 inhibition, reducing dutasteride elimination.',
  'Usar com cautela; em uso prolongado com inibidores fortes, considerar reduzir a frequência de dose; vigiar efeitos adversos.',
  'Use with caution; in long-term use with strong inhibitors, consider reducing dose frequency; watch for adverse effects.',
  'Efeitos adversos da dutasterida (diminuição da líbido, disfunção erétil, distúrbios da ejaculação, ginecomastia).',
  'Dutasteride adverse effects (decreased libido, erectile dysfunction, ejaculation disorders, gynaecomastia).',
  'Ginecomastia, disfunção sexual persistente.',
  'Gynaecomastia, persistent sexual dysfunction.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — SmPC aprovada Dutasterida: https://www.medicines.org.uk/emc/product/102479/smpc ; PubMed — https://pubmed.ncbi.nlm.nih.gov/31835695/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — approved Dutasteride SmPC: https://www.medicines.org.uk/emc/product/102479/smpc ; PubMed — https://pubmed.ncbi.nlm.nih.gov/31835695/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'dutasterida' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.17 DUTASTERIDA + ITRACONAZOL (moderate — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O itraconazol pode aumentar os níveis de dutasterida no sangue. Usar com cautela e vigiar efeitos secundários.',
  'Itraconazole can raise dutasteride blood levels. Use with caution and watch for side effects.',
  'CYP3A4: o itraconazol (inibidor forte) aumenta as concentrações de dutasterida, com meia-vida potencialmente prolongada; monitorizar tolerância.',
  'CYP3A4: itraconazole (strong inhibitor) raises dutasteride concentrations, with a potentially prolonged half-life; monitor tolerability.',
  'O itraconazol inibe o CYP3A4, enzima responsável pela eliminação da dutasterida. A exposição aumentada e a meia-vida longa do fármaco justificam cautela; em uso prolongado, considerar reduzir a frequência de dose.',
  'Itraconazole inhibits CYP3A4, the enzyme responsible for dutasteride elimination. Increased exposure and the drug long half-life justify caution; in long-term use, consider reducing dose frequency.',
  'Inibição do CYP3A4, reduzindo a eliminação da dutasterida.',
  'CYP3A4 inhibition, reducing dutasteride elimination.',
  'Usar com cautela; vigiar efeitos adversos; considerar reduzir a frequência de dose em uso prolongado.',
  'Use with caution; watch for adverse effects; consider reducing dose frequency in long-term use.',
  'Efeitos adversos da dutasterida.',
  'Dutasteride adverse effects.',
  'Ginecomastia, disfunção sexual persistente.',
  'Gynaecomastia, persistent sexual dysfunction.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; rótulo aprovado Itraconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 ; EMC-UK (MHRA) — SmPC aprovada Dutasterida: https://www.medicines.org.uk/emc/product/102479/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; approved Itraconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 ; EMC-UK (MHRA) — approved Dutasteride SmPC: https://www.medicines.org.uk/emc/product/102479/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'dutasterida' AND b.slug = 'itraconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.18 FINASTERIDA + CETOCONAZOL (minor — CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'minor',
  'O cetoconazol pode aumentar ligeiramente os níveis de finasterida no sangue, mas o impacto clínico é considerado pouco significativo.',
  'Ketoconazole may slightly raise finasteride blood levels, but the clinical impact is considered of little significance.',
  'CYP3A4: a finasterida é metabolizada pelo CYP3A4, mas o rótulo indica que qualquer aumento por inibidores é pouco provável de ter significado clínico (margens de segurança alargadas).',
  'CYP3A4: finasteride is metabolised by CYP3A4, but the label states that any increase from inhibitors is unlikely to be clinically significant (wide safety margins).',
  'A finasterida é metabolizada principalmente pelo CYP3A4, mas não afeta significativamente este sistema. Inibidores e indutores do CYP3A4 podem alterar as suas concentrações plasmáticas; contudo, com base nas margens de segurança estabelecidas, é pouco provável que tenham significado clínico.',
  'Finasteride is mainly metabolised by CYP3A4 but does not significantly affect this system. CYP3A4 inhibitors and inducers may alter its plasma concentrations; however, based on established safety margins, they are unlikely to be clinically significant.',
  'Metabolismo CYP3A4 da finasterida, com impacto clínico pouco provável.',
  'Finasteride CYP3A4 metabolism, with clinical impact unlikely.',
  'Não é necessária precaução especial; manter vigilância habitual.',
  'No special precaution needed; maintain usual surveillance.',
  'Sem monitorização específica.',
  'No specific monitoring.',
  'Sem sinais de alarme específicos.',
  'No specific red flags.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Finasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — SmPC aprovada Finasterida: https://www.medicines.org.uk/emc/product/100132/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Finasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; EMC-UK (MHRA) — approved Finasteride SmPC: https://www.medicines.org.uk/emc/product/100132/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'finasterida' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.19 NITROFURANTOINA + ANTIACIDOS (moderate — absorção)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Os antiácidos com silicato de magnésio reduzem a absorção da nitrofurantoína e podem diminuir a eficácia do antibiótico.',
  'Antacids containing magnesium trisilicate reduce nitrofurantoin absorption and may decrease antibiotic effectiveness.',
  'Absorção: o silicato de magnésio diminui a absorção da nitrofurantoína. Separar as tomas (pelo menos 2–3 h) ou evitar a associação durante o tratamento.',
  'Absorption: magnesium trisilicate decreases nitrofurantoin absorption. Separate the doses (at least 2–3 h) or avoid the combination during treatment.',
  'A SmPC da nitrofurantoína documenta diminuição da absorção com silicato de magnésio (presente em alguns antiácidos). A redução da absorção pode comprometer a eficácia antibacteriana numa infeção urinária. Aconselha-se separar as tomas ou evitar antiácidos durante o tratamento.',
  'The nitrofurantoin SmPC documents decreased absorption with magnesium trisilicate (present in some antacids). Reduced absorption may compromise antibacterial efficacy in a urinary infection. Advise separating doses or avoiding antacids during treatment.',
  'Quelação/adsorção do fármaco pelo antiácido no trato gastrointestinal.',
  'Chelation/adsorption of the drug by the antacid in the gastrointestinal tract.',
  'Separar as tomas (mínimo 2–3 h) ou suspender o antiácido durante o tratamento.',
  'Separate the doses (minimum 2–3 h) or stop the antacid during treatment.',
  'Resposta clínica à antibioterapia.',
  'Clinical response to antibiotic therapy.',
  'Persistência de sintomas de infeção urinária.',
  'Persisting urinary infection symptoms.',
  'EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc ; PubMed — https://pubmed.ncbi.nlm.nih.gov/6995091/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc ; PubMed — https://pubmed.ncbi.nlm.nih.gov/6995091/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'nitrofurantoina' AND b.slug = 'antiacidos'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.20 TANSULOSINA + VARFARINA (moderate)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A tansulosina e a varfarina podem interferir uma com a outra (metabolismo hepático). O rótulo da tansulosina recomenda cautela com a varfarina.',
  'Tamsulosin and warfarin may interfere with each other (hepatic metabolism). The tamsulosin label advises caution with warfarin.',
  'Farmacocinética: alteração mútua do metabolismo hepático documentada (diclofenac e varfarina podem aumentar a taxa de eliminação da tansulosina). Vigiar o INR.',
  'Pharmacokinetics: documented mutual change in hepatic metabolism (diclofenac and warfarin may increase tamsulosin elimination rate). Monitor INR.',
  'O rótulo da tansulosina refere que a varfarina pode aumentar a taxa de eliminação da tansulosina; o Prontuário Terapêutico descreve alteração mútua do metabolismo hepático. O significado clínico é variável, pelo que se recomenda vigilância do INR quando se inicia ou suspende a tansulosina em doentes anticoagulados.',
  'The tamsulosin label states that warfarin may increase the tamsulosin elimination rate; the Prontuário Terapêutico describes a mutual change in hepatic metabolism. The clinical significance is variable, so INR surveillance is recommended when starting or stopping tamsulosin in anticoagulated patients.',
  'Alteração mútua do metabolismo hepático (CYP-dependente).',
  'Mutual change in hepatic metabolism (CYP-dependent).',
  'Vigiar o INR ao iniciar ou suspender a tansulosina; ajustar a varfarina se necessário.',
  'Monitor INR when starting or stopping tamsulosin; adjust warfarin if needed.',
  'INR e sinais de hemorragia.',
  'INR and bleeding signs.',
  'Sangramento, equimoses espontâneas, fezes escuras.',
  'Bleeding, spontaneous bruising, dark stools.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tansulosina' AND b.slug = 'varfarina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 3. Alimento / Bebida (drug_food_interactions)
-- ---------------------------------------------------------------------
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ---------- Nitrofurantoína ----------
  ('nitrofurantoina', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Os alimentos aumentam a absorção da nitrofurantoína e reduzem o desconforto gastrointestinal (náuseas e vómitos).',
   'Food increases nitrofurantoin absorption and reduces gastrointestinal discomfort (nausea and vomiting).',
   'Tomar as cápsulas com alimentos ou leite para melhorar a tolerância gastrointestinal.',
   'Take the capsules with food or milk to improve gastrointestinal tolerability.',
   'EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc',
   'EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc', 1),

  -- ---------- Tadalafil ----------
  ('tadalafil', 'alcool', 'Álcool (consumo elevado)', 'Alcohol (substantial intake)', 'moderate',
   'O consumo elevado de álcool (≥5 unidades) em conjunto com o tadalafil pode potenciar a descida da tensão arterial (efeito vasodilatador aditivo).',
   'Substantial alcohol intake (≥5 units) together with tadalafil can potentiate the blood pressure fall (additive vasodilator effect).',
   'Evitar o consumo elevado de álcool no período de ação do tadalafil; o consumo moderado tem efeito limitado.',
   'Avoid substantial alcohol intake during the tadalafil effect period; moderate intake has a limited effect.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895', 1),
  ('tadalafil', 'refeicao_gordurosa', 'Refeição rica em gordura', 'High-fat meal', 'minor',
   'O tadalafil pode ser tomado com ou sem alimentos; a refeição rica em gordura não altera significativamente a sua absorção.',
   'Tadalafil may be taken with or without food; a high-fat meal does not significantly change its absorption.',
   'Tomar com ou sem alimentos, conforme a preferência — não é necessária restrição alimentar.',
   'Take with or without food, as preferred — no dietary restriction is needed.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895', 2),

  -- ---------- Vardenafil ----------
  ('vardenafil', 'refeicao_gordurosa', 'Refeição rica em gordura', 'High-fat meal', 'minor',
   'Uma refeição rica em gordura pode atrasar o início do efeito do vardenafil (absorção mais lenta).',
   'A high-fat meal may delay the onset of vardenafil effect (slower absorption).',
   'Se o efeito rápido for desejado, tomar o vardenafil com o estômago vazio ou longe de refeições ricas em gordura.',
   'If rapid onset is desired, take vardenafil on an empty stomach or away from high-fat meals.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6', 1),

  -- ---------- Tansulosina ----------
  ('tansulosina', 'toma_apos_refeicao', 'Tomar após a mesma refeição diária', 'Take after the same daily meal', 'minor',
   'A tansulosina deve ser tomada aproximadamente 30 minutos após a mesma refeição, todos os dias, para manter concentrações estáveis e reduzir a variação da exposição.',
   'Tamsulosin should be taken about 30 minutes after the same meal every day to maintain stable concentrations and reduce exposure variability.',
   'Tomar a cápsula 30 minutos após a mesma refeição diária; não esmagar, mastigar ou abrir a cápsula.',
   'Take the capsule 30 minutes after the same daily meal; do not crush, chew or open the capsule.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240',
   'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240', 1),

  -- ---------- Doxazosina ----------
  ('doxazosina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'Não estão documentadas interações alimentares relevantes com a doxazosina.',
   'No relevant food interactions are documented with doxazosin.',
   'Pode ser tomada com ou sem alimentos; manter a mesma rotina de toma.',
   'May be taken with or without food; keep the same dosing routine.',
   'EMC-UK (MHRA) — SmPC aprovada Doxazosina: https://www.medicines.org.uk/emc/product/102410/smpc',
   'EMC-UK (MHRA) — approved Doxazosin SmPC: https://www.medicines.org.uk/emc/product/102410/smpc', 1),

  -- ---------- Finasterida ----------
  ('finasterida', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A finasterida pode ser tomada com ou sem alimentos, sem interações alimentares relevantes documentadas.',
   'Finasteride may be taken with or without food, with no relevant documented food interactions.',
   'Tomar com ou sem alimentos, conforme a preferência.',
   'Take with or without food, as preferred.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Finasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400',
   'DailyMed/FDA (NIH/NLM) — approved Finasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400', 1),

  -- ---------- Dutasterida ----------
  ('dutasterida', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A dutasterida pode ser tomada com ou sem alimentos, sem interações alimentares relevantes documentadas.',
   'Dutasteride may be taken with or without food, with no relevant documented food interactions.',
   'Engolir a cápsula inteira; pode ser tomada com ou sem alimentos.',
   'Swallow the capsule whole; may be taken with or without food.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192',
   'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192', 1),

  -- ---------- Sildenafil (completar) ----------
  ('sildenafil', 'refeicao_gordurosa', 'Refeição rica em gordura', 'High-fat meal', 'minor',
   'Uma refeição rica em gordura atrasa o início do efeito do sildenafil (menor e mais tardia concentração máxima).',
   'A high-fat meal delays the onset of sildenafil effect (lower and later peak concentration).',
   'Se o efeito rápido for desejado, tomar o sildenafil com o estômago vazio.',
   'If rapid onset is desired, take sildenafil on an empty stomach.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('sildenafil', 'alcool', 'Álcool (consumo elevado)', 'Alcohol (substantial intake)', 'moderate',
   'O consumo elevado de álcool com sildenafil pode potenciar a descida da tensão arterial e os efeitos vasodilatadores.',
   'Substantial alcohol intake with sildenafil can potentiate the blood pressure fall and vasodilator effects.',
   'Evitar o consumo elevado de álcool no período de ação do sildenafil.',
   'Avoid substantial alcohol intake during the sildenafil effect period.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b', 2)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
       mechanism_pt, mechanism_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. Doença / Condição (drug_disease_interactions)
-- ---------------------------------------------------------------------
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ---------- Nitrofurantoína ----------
  ('nitrofurantoina', 'insuficiencia_renal_grave', 'Insuficiência renal grave', 'Severe renal impairment', 'contraindication', 'critical',
   'A nitrofurantoína está contraindicada com clearance de creatinina inferior a 45–60 ml/min (ou anúria/oligúria): a excreção está comprometida, com risco de toxicidade (sobretudo neuropatia periférica) e ineficácia.',
   'Nitrofurantoin is contraindicated with creatinine clearance below 45–60 ml/min (or anuria/oliguria): excretion is impaired, with a risk of toxicity (especially peripheral neuropathy) and inefficacy.',
   'Não utilizar em doentes com clearance de creatinina <45 ml/min; nos casos com clearance 30–44 ml/min, usar apenas em cursos curtos para infeção urinária baixa não complicada por patogénios resistentes, quando o benefício supera o risco.',
   'Do not use in patients with creatinine clearance <45 ml/min; in cases with clearance 30–44 ml/min, use only short courses for uncomplicated lower urinary tract infection due to resistant pathogens, when benefit outweighs risk.',
   'EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('nitrofurantoina', 'deficiencia_g6pd', 'Défice de G6PD', 'G6PD deficiency', 'contraindication', 'critical',
   'O défice de glucose-6-fosfato desidrogenase (G6PD) predispõe a anemia hemolítica com a nitrofurantoína.',
   'Glucose-6-phosphate dehydrogenase (G6PD) deficiency predisposes to haemolytic anaemia with nitrofurantoin.',
   'Contraindicada em doentes com défice de G6PD; considerar alternativa antibacteriana.',
   'Contraindicated in patients with G6PD deficiency; consider an alternative antibacterial.',
   'EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 2),
  ('nitrofurantoina', 'doenca_pulmonar', 'Doença pulmonar', 'Pulmonary disease', 'precaution', 'moderate',
   'Reações pulmonares agudas, subagudas e crónicas (incluindo fibrose) foram observadas com a nitrofurantoína, sobretudo em tratamentos prolongados.',
   'Acute, subacute and chronic pulmonary reactions (including fibrosis) have been observed with nitrofurantoin, especially in long-term treatment.',
   'Usar com cautela em doentes com doença pulmonar; suspender o fármaco ao primeiro sinal de sintomas respiratórios ou parestesias.',
   'Use with caution in patients with pulmonary disease; stop the drug at the first sign of respiratory symptoms or paraesthesias.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Nitrofurantoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55c75f27-b5fc-4f19-8607-08f8ec0c69ec ; EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc',
   'DailyMed/FDA (NIH/NLM) — approved Nitrofurantoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55c75f27-b5fc-4f19-8607-08f8ec0c69ec ; EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc', 3),

  -- ---------- Tadalafil ----------
  ('tadalafil', 'doenca_cardiovascular_recente', 'Doença cardiovascular recente', 'Recent cardiovascular disease', 'contraindication', 'critical',
   'Contraindicado em doentes com enfarte do miocárdio nos últimos 90 dias, angina instável, insuficiência cardíaca NYHA ≥2 nos últimos 6 meses, arritmias não controladas ou AVC nos últimos 6 meses.',
   'Contraindicated in patients with myocardial infarction within the last 90 days, unstable angina, NYHA class ≥2 heart failure within the last 6 months, uncontrolled arrhythmias or stroke within the last 6 months.',
   'Não utilizar; avaliar previamente o risco cardiovascular associado à atividade sexual.',
   'Do not use; assess the cardiovascular risk associated with sexual activity beforehand.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('tadalafil', 'hipotensao_nao_controlada', 'Hipotensão não controlada', 'Uncontrolled hypotension', 'contraindication', 'critical',
   'Contraindicado em doentes com hipotensão não controlada (pressão arterial <90/50 mmHg) pelo risco de agravamento da descida tensional.',
   'Contraindicated in patients with uncontrolled hypotension (blood pressure <90/50 mmHg) due to the risk of worsening the blood pressure fall.',
   'Não utilizar; corrigir a hipotensão antes de considerar o tratamento.',
   'Do not use; correct hypotension before considering treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895', 2),
  ('tadalafil', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'contraindication', 'critical',
   'O tadalafil não é recomendado em doentes com insuficiência hepática grave (o metabolismo hepático está comprometido).',
   'Tadalafil is not recommended in patients with severe hepatic impairment (hepatic metabolism is compromised).',
   'Não utilizar em insuficiência hepática grave; em insuficiência moderada, ajustar a dose conforme o rótulo.',
   'Do not use in severe hepatic impairment; in moderate impairment, adjust the dose per the label.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895', 3),

  -- ---------- Vardenafil ----------
  ('vardenafil', 'doenca_cardiovascular_grave', 'Doença cardiovascular grave', 'Severe cardiovascular disease', 'contraindication', 'critical',
   'Contraindicado em doentes com angina instável, insuficiência cardíaca grave (NYHA III–IV), história recente (6 meses) de AVC ou enfarte do miocárdio e hipotensão (<90/50 mmHg).',
   'Contraindicated in patients with unstable angina, severe heart failure (NYHA III–IV), recent (6 months) history of stroke or myocardial infarction and hypotension (<90/50 mmHg).',
   'Não utilizar nestes doentes; avaliar o risco cardiovascular associado à atividade sexual.',
   'Do not use in these patients; assess the cardiovascular risk associated with sexual activity.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('vardenafil', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave (Child-Pugh C)', 'Severe hepatic impairment (Child-Pugh C)', 'contraindication', 'critical',
   'O vardenafil está contraindicado na insuficiência hepática grave (Child-Pugh C); em insuficiência moderada, a dose máxima é 10 mg.',
   'Vardenafil is contraindicated in severe hepatic impairment (Child-Pugh C); in moderate impairment, the maximum dose is 10 mg.',
   'Não utilizar em Child-Pugh C; em Child-Pugh B, iniciar com 5 mg e não exceder 10 mg.',
   'Do not use in Child-Pugh C; in Child-Pugh B, start at 5 mg and do not exceed 10 mg.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6', 2),
  ('vardenafil', 'sindrome_qt_congenito', 'Síndrome QT congénito ou fármacos que prolongam o QT', 'Congenital QT syndrome or QT-prolonging drugs', 'contraindication', 'critical',
   'O vardenafil prolonga o intervalo QT; deve ser evitado em doentes com síndrome QT congénito ou a tomar antiarrítmicos classe IA ou III.',
   'Vardenafil prolongs the QT interval; it should be avoided in patients with congenital QT syndrome or taking class IA or III antiarrhythmics.',
   'Evitar o vardenafil nestes doentes; considerar alternativa PDE5 sem efeito QT relevante.',
   'Avoid vardenafil in these patients; consider an alternative PDE5 without relevant QT effect.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6', 3),

  -- ---------- Tansulosina ----------
  ('tansulosina', 'hipotensao_ortostatica_prev', 'Hipotensão ortostática prévia', 'History of orthostatic hypotension', 'contraindication', 'moderate',
   'A tansulosina está contraindicada em doentes com história de hipotensão ortostática, pelo risco de síncope.',
   'Tamsulosin is contraindicated in patients with a history of orthostatic hypotension, due to the risk of syncope.',
   'Não utilizar; se ocorrer tontura ou fraqueza ao iniciar, sentar ou deitar e contactar o médico.',
   'Do not use; if dizziness or weakness occurs when starting, sit or lie down and contact the doctor.',
   'EMC-UK (MHRA) — SmPC aprovada Tansulosina: https://www.medicines.org.uk/emc/product/102038/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Tamsulosin SmPC: https://www.medicines.org.uk/emc/product/102038/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('tansulosina', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'contraindication', 'moderate',
   'A tansulosina está contraindicada na insuficiência hepática grave.',
   'Tamsulosin is contraindicated in severe hepatic impairment.',
   'Não utilizar em insuficiência hepática grave; em insuficiência moderada, usar com cautela.',
   'Do not use in severe hepatic impairment; in moderate impairment, use with caution.',
   'EMC-UK (MHRA) — SmPC aprovada Tansulosina: https://www.medicines.org.uk/emc/product/102038/smpc',
   'EMC-UK (MHRA) — approved Tamsulosin SmPC: https://www.medicines.org.uk/emc/product/102038/smpc', 2),
  ('tansulosina', 'cirurgia_catarata', 'Cirurgia de catarata (síndrome IFIS)', 'Cataract surgery (IFIS syndrome)', 'precaution', 'moderate',
   'A tansulosina está associada à síndrome da íris flácida intraoperatória (IFIS) durante a cirurgia de catarata ou glaucoma.',
   'Tamsulosin is associated with intraoperative floppy iris syndrome (IFIS) during cataract or glaucoma surgery.',
   'Informar o oftalmologista antes da cirurgia; a suspensão prévia pode ser considerada, embora o benefício não esteja estabelecido.',
   'Inform the ophthalmologist before surgery; prior discontinuation may be considered, although the benefit is not established.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240',
   'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240', 3),

  -- ---------- Doxazosina ----------
  ('doxazosina', 'hipotensao_ortostatica_prev', 'Hipotensão ortostática prévia', 'History of orthostatic hypotension', 'contraindication', 'moderate',
   'A doxazosina está contraindicada em doentes com história de hipotensão ortostática, pelo risco de síncope nas primeiras tomas.',
   'Doxazosin is contraindicated in patients with a history of orthostatic hypotension, due to the risk of syncope with the first doses.',
   'Não utilizar; ao iniciar, monitorizar a tensão arterial e aconselhar a levantar lentamente.',
   'Do not use; at initiation, monitor blood pressure and advise standing up slowly.',
   'EMC-UK (MHRA) — SmPC aprovada Doxazosina: https://www.medicines.org.uk/emc/product/102410/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Doxazosin SmPC: https://www.medicines.org.uk/emc/product/102410/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('doxazosina', 'estenose_aortica', 'Estenose aórtica / obstrução da via de saída do ventrículo esquerdo', 'Aortic stenosis / left ventricular outflow obstruction', 'precaution', 'moderate',
   'Os doentes com obstrução da via de saída do ventrículo esquerdo podem ser sensíveis ao efeito vasodilatador da doxazosina.',
   'Patients with left ventricular outflow obstruction may be sensitive to the vasodilator effect of doxazosin.',
   'Usar com cautela; monitorizar a pressão arterial, sobretudo no início do tratamento.',
   'Use with caution; monitor blood pressure, especially at treatment initiation.',
   'EMC-UK (MHRA) — SmPC aprovada Doxazosina: https://www.medicines.org.uk/emc/product/102410/smpc',
   'EMC-UK (MHRA) — approved Doxazosin SmPC: https://www.medicines.org.uk/emc/product/102410/smpc', 2),

  -- ---------- Finasterida ----------
  ('finasterida', 'cancro_prostata_psa', 'Cancro da próstata / vigilância do PSA', 'Prostate cancer / PSA surveillance', 'precaution', 'moderate',
   'A finasterida reduz o PSA sérico em cerca de 50% e pode aumentar o risco de cancro da próstata de alto grau; não está aprovada para prevenção do cancro da próstata.',
   'Finasteride reduces serum PSA by about 50% and may increase the risk of high-grade prostate cancer; it is not approved for prostate cancer prevention.',
   'Fazer rastreio do cancro da próstata (toque retal e PSA) antes e periodicamente durante o tratamento; interpretar o PSA com o fator de ajuste (dobrar o valor após 6 meses de tratamento).',
   'Screen for prostate cancer (digital rectal examination and PSA) before and periodically during treatment; interpret PSA with the adjustment factor (double the value after 6 months of treatment).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Finasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Finasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),

  -- ---------- Dutasterida ----------
  ('dutasterida', 'cancro_prostata_psa', 'Cancro da próstata / vigilância do PSA', 'Prostate cancer / PSA surveillance', 'precaution', 'moderate',
   'A dutasterida reduz o PSA sérico em cerca de 50% e pode aumentar o risco de cancro da próstata de alto grau; não está aprovada para prevenção do cancro da próstata.',
   'Dutasteride reduces serum PSA by about 50% and may increase the risk of high-grade prostate cancer; it is not approved for prostate cancer prevention.',
   'Estabelecer novo valor basal de PSA após 6 meses de tratamento e vigiar regularmente; avaliar qualquer aumento confirmado do PSA.',
   'Establish a new PSA baseline after 6 months of treatment and monitor regularly; evaluate any confirmed PSA rise.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),

  -- ---------- Sildenafil (completar) ----------
  ('sildenafil', 'doenca_cardiovascular_recente', 'Doença cardiovascular recente', 'Recent cardiovascular disease', 'contraindication', 'critical',
   'Contraindicado em doentes em que a atividade sexual é desaconselhada pelo risco cardiovascular (doença cardíaca grave, angina instável, história recente de AVC ou enfarte).',
   'Contraindicated in patients in whom sexual activity is inadvisable due to cardiovascular risk (severe heart disease, unstable angina, recent stroke or myocardial infarction).',
   'Não utilizar; avaliar o risco cardiovascular antes de iniciar o tratamento.',
   'Do not use; assess cardiovascular risk before starting treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('sildenafil', 'hipotensao_nao_controlada', 'Hipotensão não controlada', 'Uncontrolled hypotension', 'contraindication', 'critical',
   'Contraindicado em doentes com hipotensão (<90/50 mmHg) pelo risco de descida tensional adicional.',
   'Contraindicated in patients with hypotension (<90/50 mmHg) due to the risk of an additional blood pressure fall.',
   'Não utilizar; corrigir a hipotensão antes de considerar o tratamento.',
   'Do not use; correct hypotension before considering treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 2),
  ('sildenafil', 'retinite_pigmentar', 'Retinite pigmentar', 'Retinitis pigmentosa', 'contraindication', 'moderate',
   'O sildenafil está contraindicado em doentes com doenças degenerativas hereditárias da retina, como a retinite pigmentar, pela falta de dados de segurança.',
   'Sildenafil is contraindicated in patients with hereditary degenerative retinal disorders, such as retinitis pigmentosa, due to a lack of safety data.',
   'Não utilizar nestes doentes.',
   'Do not use in these patients.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 3)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- 5. Gestação / Lactação (drug_pregnancy_info, 1:1 por fármaco)
-- ---------------------------------------------------------------------
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('nitrofurantoina', 'caution',
   'A nitrofurantoína tem uso extenso documentado na gravidez, sem evidência de teratogenicidade; é, no entanto, contraindicada no termo (38–42 semanas), durante o trabalho de parto e no recém-nascido com menos de 3 meses, pela possibilidade de anemia hemolítica por imaturidade dos sistemas enzimáticos eritrocitários.',
   'Nitrofurantoin has extensive documented use in pregnancy, with no evidence of teratogenicity; it is, however, contraindicated at term (38–42 weeks), during labour and delivery and in infants under 3 months, due to the possibility of haemolytic anaemia from immature erythrocyte enzyme systems.',
   'Utilizável no 1.º e 2.º trimestres quando indicado (infeção urinária baixa não complicada); contraindicada a partir do termo e durante o trabalho de parto.',
   'Usable in the 1st and 2nd trimesters when indicated (uncomplicated lower urinary tract infection); contraindicated from term onwards and during labour.',
   'Excretada em pequenas quantidades no leite; evitar temporariamente a amamentação se o lactente tiver défice de G6PD ou suspeita de deficiência enzimática eritrocitária.',
   'Excreted in small amounts into breast milk; temporarily avoid breastfeeding if the infant has G6PD deficiency or a suspected erythrocyte enzyme deficiency.',
   'Não é necessária contraceção específica.',
   'No specific contraception needed.',
   'EMC-UK (MHRA) — SmPC aprovada Nitrofurantoína: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Nitrofurantoin SmPC: https://www.medicines.org.uk/emc/product/100018/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('tadalafil', 'no_data',
   'O tadalafil não é indicado para uso em mulheres; os dados em grávidas são limitados.',
   'Tadalafil is not indicated for use in women; data in pregnant women are limited.',
   'Não indicado em mulheres; não existem dados adequados na gravidez.',
   'Not indicated in women; no adequate data in pregnancy.',
   'A excreção no leite humano não é conhecida; não é indicado em mulheres.',
   'Excretion into human milk is unknown; not indicated in women.',
   'Não aplicável (fármaco masculino).',
   'Not applicable (male-only drug).',
   'EMC-UK (MHRA) — SmPC aprovada Tadalafil: https://www.medicines.org.uk/emc/product/100210/smpc',
   'EMC-UK (MHRA) — approved Tadalafil SmPC: https://www.medicines.org.uk/emc/product/100210/smpc'),

  ('vardenafil', 'no_data',
   'O vardenafil não é indicado para uso em mulheres; não existem estudos em grávidas.',
   'Vardenafil is not indicated for use in women; no studies in pregnant women are available.',
   'Não indicado em mulheres; sem dados na gravidez.',
   'Not indicated in women; no data in pregnancy.',
   'Não é indicado em mulheres; sem dados de excreção no leite.',
   'Not indicated in women; no data on milk excretion.',
   'Não aplicável (fármaco masculino).',
   'Not applicable (male-only drug).',
   'EMC-UK (MHRA) — SmPC aprovada Vardenafil: https://www.medicines.org.uk/emc/product/11394/smpc',
   'EMC-UK (MHRA) — approved Vardenafil SmPC: https://www.medicines.org.uk/emc/product/11394/smpc'),

  ('tansulosina', 'no_data',
   'A tansulosina não é indicada para uso em mulheres; não existem dados de gravidez.',
   'Tamsulosin is not indicated for use in women; no pregnancy data are available.',
   'Não indicado em mulheres; sem dados na gravidez.',
   'Not indicated in women; no data in pregnancy.',
   'Não é indicado em mulheres.',
   'Not indicated in women.',
   'Não aplicável (fármaco masculino).',
   'Not applicable (male-only drug).',
   'EMC-UK (MHRA) — SmPC aprovada Tansulosina: https://www.medicines.org.uk/emc/product/102038/smpc',
   'EMC-UK (MHRA) — approved Tamsulosin SmPC: https://www.medicines.org.uk/emc/product/102038/smpc'),

  ('doxazosina', 'caution',
   'Não existem estudos controlados em grávidas; a doxazosina deve ser usada na gravidez apenas se o benefício esperado superar o risco.',
   'No controlled studies in pregnant women are available; doxazosin should be used in pregnancy only if the expected benefit outweighs the risk.',
   'Usar apenas se o benefício superar o risco; sem dados suficientes por trimestre.',
   'Use only if benefit outweighs risk; insufficient data by trimester.',
   'A excreção no leite é muito baixa (dose relativa <1%), mas os dados humanos são limitados; usar apenas se o benefício superar o risco.',
   'Milk excretion is very low (relative infant dose <1%), but human data are limited; use only if benefit outweighs risk.',
   'Não é necessária contraceção específica.',
   'No specific contraception needed.',
   'EMC-UK (MHRA) — SmPC aprovada Doxazosina: https://www.medicines.org.uk/emc/product/102410/smpc',
   'EMC-UK (MHRA) — approved Doxazosin SmPC: https://www.medicines.org.uk/emc/product/102410/smpc'),

  ('finasterida', 'contraindicated',
   'Contraindicada em mulheres grávidas ou que possam engravidar: os inibidores da 5-alfa-redutase tipo II podem causar anomalias dos genitais externos do feto masculino.',
   'Contraindicated in pregnant women or those who may become pregnant: type II 5-alpha reductase inhibitors can cause abnormalities of the external genitalia of a male fetus.',
   'Contraindicada em qualquer fase da gravidez; mulheres grávidas ou que possam engravidar não devem manusear comprimidos esmagados ou partidos.',
   'Contraindicated at any stage of pregnancy; pregnant women or those who may become pregnant must not handle crushed or broken tablets.',
   'Não é indicada em mulheres; sem dados de excreção no leite.',
   'Not indicated in women; no data on milk excretion.',
   'Mulheres em idade fértil devem utilizar contraceção eficaz; os homens não têm restrição específica de contraceção.',
   'Women of child-bearing age must use effective contraception; men have no specific contraception restriction.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Finasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Finasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('dutasterida', 'contraindicated',
   'Contraindicada em mulheres e em mulheres com potencial para engravidar: a dutasterida pode inibir o desenvolvimento dos genitais externos do feto masculino.',
   'Contraindicated in women and in women of child-bearing potential: dutasteride can inhibit the development of the external genitalia of a male fetus.',
   'Contraindicada na gravidez; mulheres grávidas ou que possam engravidar não devem manusear as cápsulas.',
   'Contraindicated in pregnancy; pregnant women or those who may become pregnant must not handle the capsules.',
   'Não é indicada em mulheres; sem dados de excreção no leite.',
   'Not indicated in women; no data on milk excretion.',
   'Quando a parceira está ou pode estar grávida, recomenda-se o uso de preservativo (dutasterida detetada no sémen); não doar sangue até 6 meses após a última dose.',
   'When the partner is or may be pregnant, condom use is recommended (dutasteride detected in semen); do not donate blood until 6 months after the last dose.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; EMC-UK (MHRA) — SmPC aprovada Dutasterida: https://www.medicines.org.uk/emc/product/102479/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; EMC-UK (MHRA) — approved Dutasteride SmPC: https://www.medicines.org.uk/emc/product/102479/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('sildenafil', 'no_data',
   'O sildenafil não é indicado para uso em mulheres; não existem estudos adequados em grávidas.',
   'Sildenafil is not indicated for use in women; no adequate studies in pregnant women are available.',
   'Não indicado em mulheres; sem dados adequados na gravidez.',
   'Not indicated in women; no adequate data in pregnancy.',
   'Não é indicado em mulheres; sem dados de excreção no leite.',
   'Not indicated in women; no data on milk excretion.',
   'Não aplicável (fármaco masculino).',
   'Not applicable (male-only drug).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 6. Perfis de fármaco (drug_profiles) — 8 fármacos
--    (7 novos + sildenafil, que não tinha perfil)
-- ---------------------------------------------------------------------
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en, side_effects_pt, side_effects_en,
   precautions_pt, precautions_en, source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.indications_pt, v.indications_en, v.side_effects_pt, v.side_effects_en,
       v.precautions_pt, v.precautions_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('nitrofurantoina',
   'A nitrofurantoína é um antibiótico usado no tratamento de infeções urinárias baixas não complicadas (cistite aguda). É eficaz contra muitas bactérias comuns da urina e é tomada por via oral, geralmente 3 a 4 vezes por dia.',
   'Nitrofurantoin is an antibiotic used to treat uncomplicated lower urinary tract infections (acute cystitis). It is effective against many common urinary bacteria and is taken orally, usually 3 to 4 times a day.',
   'Nitrofurano bacteriostático de uso urinário. Indicado apenas na infeção urinária baixa não complicada (cistite aguda) por estirpes suscetíveis (E. coli, S. saprophyticus). Não indicada na pielonefrite. Contraindicações: IR (CrCl <45–60 ml/min), défice de G6PD, porfiria aguda; reações pulmonares e neuropatia periférica exigem suspensão imediata.',
   'Urinary bacteriostatic nitrofuran. Indicated only for uncomplicated lower urinary tract infection (acute cystitis) due to susceptible strains (E. coli, S. saprophyticus). Not indicated in pyelonephritis. Contraindications: renal impairment (CrCl <45–60 ml/min), G6PD deficiency, acute porphyria; pulmonary reactions and peripheral neuropathy require immediate discontinuation.',
   E'Tratamento da cistite aguda não complicada (infeção urinária baixa) causada por bactérias suscetíveis.\\nProfilaxia de infeções urinárias recorrentes (uso prolongado).',
   E'Treatment of acute uncomplicated cystitis (lower urinary tract infection) caused by susceptible bacteria.\\nProphylaxis of recurrent urinary tract infections (long-term use).',
   E'Náuseas, vómitos ou desconforto abdominal (mais frequentes; melhoram com a toma junto das refeições).\\nDor de cabeça e gases.\\nUrina de cor amarela ou castanha (efeito benigno e esperado).\\nRaramente: reações pulmonares (tosse, falta de ar), neuropatia periférica (formigueiro, dormência), reações alérgicas ou problemas hepáticos.\\nProcure ajuda médica imediata se tiver falta de ar, tosse nova, formigueiro persistente, febre ou erupção cutânea.',
   E'Nausea, vomiting or abdominal discomfort (most common; improve when taken with meals).\\nHeadache and flatulence.\\nYellow or brown urine (benign and expected).\\nRarely: pulmonary reactions (cough, shortness of breath), peripheral neuropathy (tingling, numbness), allergic reactions or liver problems.\\nSeek immediate medical help if you have shortness of breath, a new cough, persistent tingling, fever or a skin rash.',
   E'Tome as cápsulas com alimentos ou leite para reduzir as náuseas.\\nNão use se tiver doença renal grave, défice de G6PD, porfiria ou alergia a nitrofuranos.\\nSuspenda e procure ajuda se surgirem falta de ar, tosse, formigueiro ou dormência.\\nNão é indicada para tratar pielonefrite nem em bebés com menos de 3 meses.\\nSiga o ciclo completo prescrito, mesmo que se sinta melhor.',
   E'Take the capsules with food or milk to reduce nausea.\\nDo not use if you have severe kidney disease, G6PD deficiency, porphyria or nitrofuran allergy.\\nStop and seek help if shortness of breath, cough, tingling or numbness occurs.\\nNot indicated for pyelonephritis nor in infants under 3 months.\\nComplete the prescribed course, even if you feel better.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Nitrofurantoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55c75f27-b5fc-4f19-8607-08f8ec0c69ec — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Nitrofurantoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55c75f27-b5fc-4f19-8607-08f8ec0c69ec — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('tadalafil',
   'O tadalafil é um medicamento usado no tratamento da disfunção erétil e dos sintomas da próstata aumentada (hiperplasia benigna da próstata). A sua ação pode durar até 36 horas. Não deve ser tomado com nitratos (como a nitroglicerina).',
   'Tadalafil is a medicine used to treat erectile dysfunction and the symptoms of an enlarged prostate (benign prostatic hyperplasia). Its effect can last up to 36 hours. It must not be taken with nitrates (such as nitroglycerin).',
   'Inibidor da fosfodiesterase-5 (PDE5). Indicado na disfunção erétil, nos sintomas da HPB e na associação das duas condições. Meia-vida longa (~17,5 h; efeito até 36 h). Contraindicação absoluta com nitratos e estimuladores da guanilato ciclase (riociguat); precaução com alfa-bloqueantes, inibidores do CYP3A4 e álcool em excesso.',
   'Phosphodiesterase-5 (PDE5) inhibitor. Indicated for erectile dysfunction, benign prostatic hyperplasia (BPH) symptoms and the combination of both. Long half-life (~17.5 h; effect up to 36 h). Absolute contraindication with nitrates and guanylate cyclase stimulators (riociguat); caution with alpha-blockers, CYP3A4 inhibitors and excess alcohol.',
   E'Disfunção erétil (uso ocasional 10–20 mg ou diário 2,5–5 mg).\\nSinais e sintomas da hiperplasia benigna da próstata (5 mg/dia).\\nDisfunção erétil com sintomas de HPB (5 mg/dia).',
   E'Erectile dysfunction (as-needed 10–20 mg or daily 2.5–5 mg).\\nSigns and symptoms of benign prostatic hyperplasia (5 mg/day).\\nErectile dysfunction with BPH symptoms (5 mg/day).',
   E'Dor de cabeça, indigestão (dispepsia), dor nas costas e dores musculares (as mais comuns).\\nRubor facial, congestão nasal e dor nos braços ou pernas.\\nTonturas.\\nProcure ajuda imediata se tiver ereção prolongada (>4 horas), perda súbita de visão num olho, perda súbita de audição, dor no peito ou falta de ar.',
   E'Headache, indigestion (dyspepsia), back pain and muscle aches (most common).\\nFacial flushing, nasal congestion and pain in the arms or legs.\\nDizziness.\\nSeek immediate help if you have a prolonged erection (>4 hours), sudden vision loss in one eye, sudden hearing loss, chest pain or shortness of breath.',
   E'Nunca tomar com nitratos (nitroglicerina, dinitrato de isossorbida, etc.) — contraindicação absoluta.\\nInforme o médico se tem doença cardíaca, tensão arterial baixa ou alta, doença hepática ou renal.\\nEvite o consumo elevado de álcool durante o efeito.\\nSe toma alfa-bloqueantes (para a próstata), o médico deve avaliar o risco de descida da tensão arterial.\\nProcure ajuda imediata para ereções com mais de 4 horas.',
   E'Never take with nitrates (nitroglycerin, isosorbide dinitrate, etc.) — absolute contraindication.\\nTell your doctor if you have heart disease, low or high blood pressure, liver or kidney disease.\\nAvoid substantial alcohol intake during the effect.\\nIf you take alpha-blockers (for the prostate), the doctor must assess the risk of a blood pressure fall.\\nSeek immediate help for erections lasting more than 4 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=bcd8f8ab-81a2-4891-83db-24a0b0e25895 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('vardenafil',
   'O vardenafil é um medicamento usado no tratamento da disfunção erétil. A sua ação começa cerca de 30 a 60 minutos após a toma. Não deve ser tomado com nitratos (como a nitroglicerina).',
   'Vardenafil is a medicine used to treat erectile dysfunction. Its effect starts about 30 to 60 minutes after taking it. It must not be taken with nitrates (such as nitroglycerin).',
   'Inibidor da fosfodiesterase-5 (PDE5). Indicado na disfunção erétil. Metabolizado pelo CYP3A4 (interações relevantes com cetoconazol, itraconazol, ritonavir, claritromicina). Prolonga o intervalo QT (evitar na síndrome QT congénita e com antiarrítmicos IA/III). Contraindicado com nitratos e em IH grave (Child-Pugh C) ou IR terminal em diálise.',
   'Phosphodiesterase-5 (PDE5) inhibitor. Indicated for erectile dysfunction. Metabolised by CYP3A4 (relevant interactions with ketoconazole, itraconazole, ritonavir, clarithromycin). Prolongs the QT interval (avoid in congenital QT syndrome and with class IA/III antiarrhythmics). Contraindicated with nitrates and in severe hepatic impairment (Child-Pugh C) or end-stage renal disease on dialysis.',
   'Tratamento da disfunção erétil.',
   'Treatment of erectile dysfunction.',
   E'Dor de cabeça (a mais comum), rubor facial, congestão nasal e indigestão.\\nTonturas, náuseas, dores nas costas e sintomas gripais.\\nAlterações visuais (visão turva ou colorida) pouco frequentes.\\nProcure ajuda imediata se tiver ereção prolongada (>4 horas), perda súbita de visão, perda súbita de audição, dor no peito ou falta de ar.',
   E'Headache (most common), facial flushing, nasal congestion and indigestion.\\nDizziness, nausea, back pain and flu-like symptoms.\\nVisual changes (blurred or coloured vision) uncommon.\\nSeek immediate help if you have a prolonged erection (>4 hours), sudden vision loss, sudden hearing loss, chest pain or shortness of breath.',
   E'Nunca tomar com nitratos — contraindicação absoluta.\\nEvitar em doentes com síndrome QT congénita ou a tomar antiarrítmicos classe IA/III.\\nInforme o médico se tem doença cardíaca, hepática ou renal, tensão arterial baixa ou alterações da retina.\\nEm idosos ou com doença hepática, a dose deve ser reduzida.\\nProcure ajuda imediata para ereções com mais de 4 horas.',
   E'Never take with nitrates — absolute contraindication.\\nAvoid in patients with congenital QT syndrome or taking class IA/III antiarrhythmics.\\nTell your doctor if you have heart, liver or kidney disease, low blood pressure or retinal disorders.\\nIn the elderly or with liver disease, the dose should be reduced.\\nSeek immediate help for erections lasting more than 4 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('tansulosina',
   'A tansulosina é um medicamento usado nos sintomas da próstata aumentada (hiperplasia benigna da próstata), como dificuldade em urinar ou jato fraco. Relaxa os músculos da próstata e da bexiga, facilitando a urina.',
   'Tamsulosin is a medicine used for the symptoms of an enlarged prostate (benign prostatic hyperplasia), such as difficulty urinating or a weak stream. It relaxes the muscles of the prostate and bladder, making urination easier.',
   'Antagonista α1-adrenérgico seletivo. Indicado nos sintomas da HPB; não indicado na hipertensão. Seletividade α1A com menor hipotensão ortostática do que outros alfa-bloqueantes. Associado a IFIS na cirurgia de catarata; cautela com inibidores do CYP3A4/CYP2D6 e com a varfarina.',
   'Selective alpha-1 adrenergic antagonist. Indicated for BPH symptoms; not indicated for hypertension. Alpha-1A selectivity with less orthostatic hypotension than other alpha-blockers. Associated with IFIS in cataract surgery; caution with CYP3A4/CYP2D6 inhibitors and warfarin.',
   'Tratamento dos sintomas da hiperplasia benigna da próstata.',
   'Treatment of the symptoms of benign prostatic hyperplasia.',
   E'Tonturas, dor de cabeça e cansaço.\\nEjaculação retrógrada ou alterações da ejaculação.\\nRinite (nariz entupido) e dores articulares.\\nRaramente: desmaio (síncope) nas primeiras tomas ou reações alérgicas.\\nInforme o oftalmologista antes de uma cirurgia de catarata — a tansulosina pode complicar a operação.',
   E'Dizziness, headache and tiredness.\\nRetrograde ejaculation or ejaculation changes.\\nRhinitis (stuffy nose) and joint pain.\\nRarely: fainting (syncope) with the first doses or allergic reactions.\\nTell the ophthalmologist before cataract surgery — tamsulosin can complicate the operation.',
   E'Tome a cápsula 30 minutos após a mesma refeição, todos os dias, e engula-a inteira.\\nLevante-se lentamente ao iniciar o tratamento — pode causar tonturas ao levantar.\\nNão use se teve hipotensão ortostática ou doença hepática grave.\\nAntes de iniciar, o médico deve excluir outras causas dos sintomas e fazer rastreio de cancro da próstata.\\nAvise o oftalmologista antes de cirurgia de catarata.',
   E'Take the capsule 30 minutes after the same meal every day and swallow it whole.\\nStand up slowly when starting treatment — it can cause dizziness on standing.\\nDo not use if you have had orthostatic hypotension or severe liver disease.\\nBefore starting, the doctor should rule out other causes of the symptoms and screen for prostate cancer.\\nTell the ophthalmologist before cataract surgery.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ed219aa-cf65-457f-8570-d26b48edb240 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('doxazosina',
   'A doxazosina é um medicamento usado nos sintomas da próstata aumentada (hiperplasia benigna da próstata) e na tensão arterial alta. Relaxa os vasos sanguíneos e os músculos da próstata, mas pode causar tonturas, sobretudo ao levantar.',
   'Doxazosin is a medicine used for the symptoms of an enlarged prostate (benign prostatic hyperplasia) and for high blood pressure. It relaxes blood vessels and prostate muscles, but can cause dizziness, especially on standing.',
   'Antagonista α1-adrenérgico. Indicado na HPB e na hipertensão. Efeito de primeira dose com hipotensão ortostática (monitorizar no início). Substrato do CYP3A4 (cautela com inibidores fortes). Associação com PDE5 pode causar hipotensão sintomática. Associado a IFIS na cirurgia de catarata.',
   'Alpha-1 adrenergic antagonist. Indicated for BPH and hypertension. First-dose effect with orthostatic hypotension (monitor at initiation). CYP3A4 substrate (caution with strong inhibitors). Combination with PDE5 can cause symptomatic hypotension. Associated with IFIS in cataract surgery.',
   E'Tratamento dos sintomas da hiperplasia benigna da próstata.\\nTratamento da hipertensão arterial.',
   E'Treatment of benign prostatic hyperplasia symptoms.\\nTreatment of hypertension.',
   E'Tonturas, fadiga, mal-estar e hipotensão (as mais comuns).\\nCongestão nasal, sonolência e inchaço.\\nRaramente: desmaio (síncope), sobretudo nas primeiras tomas ou com aumento de dose.\\nProcure ajuda se tiver batimento cardíaco rápido, inchaço das pernas, dor no peito ou falta de ar.',
   E'Dizziness, fatigue, malaise and hypotension (most common).\\nNasal congestion, drowsiness and swelling.\\nRarely: fainting (syncope), especially with the first doses or dose increases.\\nSeek help if you have a fast heartbeat, leg swelling, chest pain or shortness of breath.',
   E'Ao iniciar, o médico pode recomendar a primeira toma à noite e monitorizar a tensão arterial.\\nLevante-se lentamente e evite mudanças bruscas de posição.\\nNunca pare o tratamento de forma abrupta.\\nInforme o médico se toma medicamentos para a tensão, nitratos ou inibidores da fosfodiesterase-5.\\nAvise o oftalmologista antes de cirurgia de catarata.',
   E'At initiation, the doctor may recommend the first dose at bedtime and blood pressure monitoring.\\nStand up slowly and avoid sudden position changes.\\nNever stop treatment abruptly.\\nTell your doctor if you take blood pressure medicines, nitrates or PDE-5 inhibitors.\\nTell the ophthalmologist before cataract surgery.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Doxazosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Doxazosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5e1f5e49-2da1-43ab-9795-228a8bcc5a82 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('finasterida',
   'A finasterida é um medicamento usado nos sintomas da próstata aumentada (hiperplasia benigna da próstata). Reduz o tamanho da próstata ao bloquear a conversão da testosterona na sua forma mais ativa. Os efeitos demoram vários meses a aparecer.',
   'Finasteride is a medicine used for the symptoms of an enlarged prostate (benign prostatic hyperplasia). It shrinks the prostate by blocking the conversion of testosterone to its more active form. Effects take several months to appear.',
   'Inibidor da 5-alfa-redutase tipo II. Indicado na HPB sintomática (melhora os sintomas e reduz o risco de retenção urinária aguda e de cirurgia). Reduz o PSA em ~50% (ajustar a interpretação). Não aprovado para prevenção do cancro da próstata. Contraindicado em mulheres grávidas ou que possam engravidar.',
   'Type II 5-alpha reductase inhibitor. Indicated for symptomatic BPH (improves symptoms and reduces the risk of acute urinary retention and surgery). Reduces PSA by ~50% (adjust interpretation). Not approved for prostate cancer prevention. Contraindicated in pregnant women or those who may become pregnant.',
   E'Tratamento dos sintomas da hiperplasia benigna da próstata em homens com próstata aumentada.\\nRedução do risco de retenção urinária aguda e da necessidade de cirurgia (incluindo RTU e prostatectomia).',
   E'Treatment of benign prostatic hyperplasia symptoms in men with an enlarged prostate.\\nReduction of the risk of acute urinary retention and of the need for surgery (including TURP and prostatectomy).',
   E'Diminuição da líbido, disfunção erétil e diminuição do volume do ejaculado (os mais comuns; podem persistir após a suspensão).\\nAumento ou sensibilidade das mamas.\\nErupção cutânea.\\nProcure ajuda se tiver inchaço da face ou lábios (angioedema) ou sintomas depressivos.',
   E'Decreased libido, erectile dysfunction and decreased ejaculate volume (most common; may persist after stopping).\\nBreast enlargement or tenderness.\\nSkin rash.\\nSeek help if you have facial or lip swelling (angioedema) or depressive symptoms.',
   E'O efeito nos sintomas demora 3 a 6 meses — não suspenda precocemente.\\nO médico deve fazer rastreio de cancro da próstata (toque retal e PSA) antes e durante o tratamento.\\nMulheres grávidas ou que possam engravidar não devem manusear comprimidos esmagados ou partidos.\\nInforme o médico se tem doença hepática.\\nNão é indicado para mulheres nem crianças.',
   E'The effect on symptoms takes 3 to 6 months — do not stop early.\\nThe doctor should screen for prostate cancer (digital rectal examination and PSA) before and during treatment.\\nPregnant women or those who may become pregnant must not handle crushed or broken tablets.\\nTell your doctor if you have liver disease.\\nNot indicated for women or children.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Finasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Finasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=350b2bdb-84a1-4465-b0ad-175b8f720400 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('dutasterida',
   'A dutasterida é um medicamento usado nos sintomas da próstata aumentada (hiperplasia benigna da próstata). Bloqueia a conversão da testosterona na sua forma mais ativa, reduzindo o tamanho da próstata. Os efeitos demoram vários meses a aparecer.',
   'Dutasteride is a medicine used for the symptoms of an enlarged prostate (benign prostatic hyperplasia). It blocks the conversion of testosterone to its more active form, shrinking the prostate. Effects take several months to appear.',
   'Inibidor duplo da 5-alfa-redutase (tipo I e II). Indicado na HPB sintomática (monoterapia ou em associação com tansulosina). Reduz o PSA em ~50% (nova basal após 6 meses). Não aprovado para prevenção do cancro da próstata. Meia-vida muito longa; interação com inibidores do CYP3A4; não doar sangue até 6 meses após a última dose.',
   'Dual 5-alpha reductase inhibitor (type I and II). Indicated for symptomatic BPH (monotherapy or combined with tamsulosin). Reduces PSA by ~50% (new baseline after 6 months). Not approved for prostate cancer prevention. Very long half-life; interaction with CYP3A4 inhibitors; do not donate blood until 6 months after the last dose.',
   E'Tratamento dos sintomas da hiperplasia benigna da próstata em homens com próstata aumentada (monoterapia).\\nEm associação com tansulosina, no tratamento da HPB sintomática.\\nRedução do risco de retenção urinária aguda e de cirurgia relacionada com a HPB.',
   E'Treatment of benign prostatic hyperplasia symptoms in men with an enlarged prostate (monotherapy).\\nCombined with tamsulosin, for symptomatic BPH.\\nReduction of the risk of acute urinary retention and BPH-related surgery.',
   E'Diminuição da líbido, disfunção erétil, distúrbios da ejaculação e alterações das mamas (os mais comuns).\\nTonturas, dor de cabeça, cansaço, rinite e dores articulares.\\nOs efeitos sexuais podem persistir após a suspensão.\\nProcure ajuda se tiver inchaço da face ou lábios (angioedema) ou sintomas depressivos.',
   E'Decreased libido, erectile dysfunction, ejaculation disorders and breast changes (most common).\\nDizziness, headache, tiredness, rhinitis and joint pain.\\nSexual effects may persist after stopping.\\nSeek help if you have facial or lip swelling (angioedema) or depressive symptoms.',
   E'Engolir a cápsula inteira; pode ser tomada com ou sem alimentos.\\nO efeito demora 3 a 6 meses — não suspenda precocemente.\\nO médico deve fazer rastreio de cancro da próstata (PSA) antes e durante o tratamento.\\nMulheres grávidas ou que possam engravidar não devem manusear as cápsulas.\\nNão doar sangue até 6 meses após a última dose.',
   E'Swallow the capsule whole; may be taken with or without food.\\nThe effect takes 3 to 6 months — do not stop early.\\nThe doctor should screen for prostate cancer (PSA) before and during treatment.\\nPregnant women or those who may become pregnant must not handle the capsules.\\nDo not donate blood until 6 months after the last dose.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)'),

  ('sildenafil',
   'O sildenafil é um medicamento usado no tratamento da disfunção erétil. A sua ação começa cerca de 30 a 60 minutos após a toma e dura até 4 a 6 horas. Não deve ser tomado com nitratos (como a nitroglicerina).',
   'Sildenafil is a medicine used to treat erectile dysfunction. Its effect starts about 30 to 60 minutes after taking it and lasts up to 4 to 6 hours. It must not be taken with nitrates (such as nitroglycerin).',
   'Inibidor da fosfodiesterase-5 (PDE5). Indicado na disfunção erétil. Contraindicação absoluta com nitratos ou dadores de NO (hipotensão grave). Cautela com alfa-bloqueantes e com inibidores/indutores do CYP3A4. Contraindicado na doença cardiovascular em que a atividade sexual é desaconselhada, hipotensão não controlada e retinite pigmentar.',
   'Phosphodiesterase-5 (PDE5) inhibitor. Indicated for erectile dysfunction. Absolute contraindication with nitrates or NO donors (severe hypotension). Caution with alpha-blockers and CYP3A4 inhibitors/inducers. Contraindicated in cardiovascular disease where sexual activity is inadvisable, uncontrolled hypotension and retinitis pigmentosa.',
   'Tratamento da disfunção erétil (dose inicial habitual 50 mg, 30 a 60 minutos antes da atividade sexual; ajuste 25–100 mg).',
   'Treatment of erectile dysfunction (usual starting dose 50 mg, 30 to 60 minutes before sexual activity; adjust 25–100 mg).',
   E'Dor de cabeça, rubor facial, indigestão e congestão nasal (as mais comuns).\\nTonturas, alterações visuais (visão azulada ou turva) e dores musculares.\\nProcure ajuda imediata se tiver ereção prolongada (>4 horas), perda súbita de visão, perda súbita de audição, dor no peito ou falta de ar.',
   E'Headache, facial flushing, indigestion and nasal congestion (most common).\\nDizziness, visual changes (blue or blurred vision) and muscle aches.\\nSeek immediate help if you have a prolonged erection (>4 hours), sudden vision loss, sudden hearing loss, chest pain or shortness of breath.',
   E'Nunca tomar com nitratos (nitroglicerina, etc.) — contraindicação absoluta; se tomou sildenafil, aguarde pelo menos 24 horas antes de um nitrato.\\nUma refeição rica em gordura atrasa o início do efeito.\\nInforme o médico se tem doença cardíaca, tensão arterial baixa, doença hepática ou renal ou retinite pigmentar.\\nProcure ajuda imediata para ereções com mais de 4 horas.',
   E'Never take with nitrates (nitroglycerin, etc.) — absolute contraindication; if you took sildenafil, wait at least 24 hours before a nitrate.\\nA high-fat meal delays the onset of effect.\\nTell your doctor if you have heart disease, low blood pressure, liver or kidney disease or retinitis pigmentosa.\\nSeek immediate help for erections lasting more than 4 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
       indications_pt, indications_en, side_effects_pt, side_effects_en,
       precautions_pt, precautions_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
