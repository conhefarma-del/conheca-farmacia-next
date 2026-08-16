-- 160: Grupo 7 do Prontuário Terapêutico — Aparelho Geniturinário
-- Adiciona 7 pares de interação medicamento-medicamento para fármacos que já
-- existem em public.drugs (inibidores da fosfodiesterase-5, tansulosina,
-- dutasterida). Nenhum fármaco novo é inserido.
--
-- Fármacos do grupo 7 já presentes na BD e respetivos pares:
--   sildenafil × eritromicina  [moderate]  — rótulo do sildenafil (secção 7.4)
--   tadalafil × eritromicina   [moderate]  — rótulo do tadalafil (secção 7.2)
--   tadalafil × ritonavir      [moderate]  — rótulo do tadalafil (secção 7.2)
--   vardenafil × eritromicina  [moderate]  — rótulo do vardenafil (secção 7.2)
--   vardenafil × ritonavir     [critical]  — rótulo do vardenafil (secção 7.2)
--   tansulosina × eritromicina [moderate]  — rótulo da tansulosina (secção 7.1)
--   dutasterida × ritonavir    [moderate]  — rótulo da dutasterida (secção 7)
--
-- Fontes: rótulos aprovados pela FDA/DailyMed — DailyMed/FDA (NIH/NLM);
-- setIDs obtidos na API pública v2 (spls.json?drug_name=...) e revalidados
-- pelo endpoint XML (spls/{setid}.xml) com confirmação do nome do produto
-- a 2026-08-17. As palavras-chave de cada interação (erythromycin, ritonavir,
-- CYP3A4 inhibitor, dose adjustment) foram confirmadas no texto dos rótulos.
--
-- Omissões documentadas (honestidade das fontes):
--   * Finasterida: o rótulo afirma explicitamente que NÃO foram identificadas
--     interações de importância clínica (não afeta o sistema CYP450; testado
--     com digoxina, propranolol, teofilina, varfarina — sem efeito relevante).
--     Não se criou nenhum par (evita pares artificiais).
--   * Dutasterida × verapamilo/diltiazem: o rótulo documenta diminuição da
--     depuração com aumento da exposição, mas considera-a clinicamente não
--     significativa e não recomenda ajuste de dose. Não se criou par.
--   * Nitrofurantoína × quinolonas: antagonismo demonstrado apenas in vitro,
--     com significado clínico desconhecido (rótulo). Não se criou par.
--
-- Metodologia (ver docs/INTERACOES_FLUXO_PESQUISA.md):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * sem pares artificiais: só pares documentados nos rótulos aprovados;
--   * idempotente (UNIQUE (drug_a_id, drug_b_id), ON CONFLICT DO NOTHING).
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'),
        (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'),
            (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   'critical',
   'O Ritonavir aumenta fortemente a exposição ao Vardenafil (AUC até 49×), com risco de hipotensão grave, síncope e priapismo. Não exceder uma dose única de 2,5 mg de Vardenafil em 72 horas durante o uso concomitante.',
   'Ritonavir greatly increases exposure to Vardenafil (up to 49-fold AUC), with a risk of severe hypotension, syncope and priapism. Do not exceed a single 2.5 mg dose of Vardenafil within 72 hours during concomitant use.',
   'O ritonavir é um inibidor potente do CYP3A4 (e também do CYP2C9) e bloqueia o metabolismo hepático do vardenafil, prolongando a sua semivida para cerca de 26 horas e elevando de forma marcada a sua concentração plasmática.',
   'Ritonavir is a potent CYP3A4 inhibitor (and also inhibits CYP2C9) and blocks the hepatic metabolism of vardenafil, prolonging its half-life to about 26 hours and markedly raising its plasma concentration.',
   'Evitar a associação sempre que possível. Se for inevitável, não exceder uma dose única de 2,5 mg de vardenafil num período de 72 horas e vigiar sintomas de hipotensão.',
   'Avoid the combination whenever possible. If unavoidable, do not exceed a single 2.5 mg dose of vardenafil within a 72-hour period and monitor for symptoms of hypotension.',
   'Vigiar pressão arterial, tonturas, cefaleias e sinais de ereção prolongada.',
   'Monitor blood pressure, dizziness, headache and signs of prolonged erection.',
   'Hipotensão grave, síncope, ereção prolongada ou priapismo.',
   'Severe hypotension, syncope, prolonged erection or priapism.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Ritonavir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Ritonavir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'),
        (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'),
            (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   'moderate',
   'A Eritromicina, inibidor moderado do CYP3A4, pode reduzir a depuração do Vardenafil e aumentar a sua exposição, potenciando efeitos adversos como hipotensão e cefaleias.',
   'Erythromycin, a moderate CYP3A4 inhibitor, may reduce Vardenafil clearance and increase its exposure, potentiating adverse effects such as hypotension and headache.',
   'O vardenafil é metabolizado sobretudo pelas isoenzimas CYP3A4/5 (e, em menor grau, pela CYP2C9); os inibidores destas enzimas, como a eritromicina, reduzem a sua depuração e aumentam as concentrações plasmáticas.',
   'Vardenafil is metabolized primarily by CYP3A4/5 isoforms (and to a lesser extent by CYP2C9); inhibitors of these enzymes, such as erythromycin, reduce its clearance and increase plasma concentrations.',
   'Usar com precaução; considerar iniciar com a menor dose de vardenafil e vigiar efeitos adversos. Nos inibidores fortes do CYP3A4, a dose máxima é inferior.',
   'Use with caution; consider starting with the lowest vardenafil dose and monitor for adverse effects. With strong CYP3A4 inhibitors the maximum dose is lower.',
   'Vigiar pressão arterial, tonturas e cefaleias após a toma.',
   'Monitor blood pressure, dizziness and headache after dosing.',
   'Hipotensão ortostática, tonturas intensas ou síncope.',
   'Orthostatic hypotension, severe dizziness or syncope.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vardenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; rótulo aprovado Eritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'DailyMed/FDA (NIH/NLM) — approved Vardenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2782efed-6198-47b9-81ac-3e255e2ab7f6 ; approved Erythromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'),
        (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'),
            (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   'moderate',
   'A Eritromicina aumenta a exposição ao Sildenafil (Cmax +160%, AUC +182%), com maior risco de hipotensão, rubor e cefaleias. Considerar iniciar com dose de 25 mg.',
   'Erythromycin increases Sildenafil exposure (Cmax +160%, AUC +182%), with a higher risk of hypotension, flushing and headache. Consider a starting dose of 25 mg.',
   'A eritromicina é um inibidor moderado do CYP3A4; como o sildenafil é metabolizado por esta isoenzima, a sua administração concomitante aumenta a concentração máxima e a exposição total ao sildenafil.',
   'Erythromycin is a moderate CYP3A4 inhibitor; since sildenafil is metabolized by this isoenzyme, concomitant administration increases sildenafil peak concentration and total exposure.',
   'Considerar uma dose inicial de 25 mg de sildenafil quando usado com eritromicina e vigiar efeitos adversos.',
   'Consider a starting sildenafil dose of 25 mg when used with erythromycin and monitor for adverse effects.',
   'Vigiar pressão arterial e sintomas de vasodilatação (rubor, cefaleia, congestão nasal).',
   'Monitor blood pressure and symptoms of vasodilation (flushing, headache, nasal congestion).',
   'Hipotensão sintomática, tonturas ou síncope.',
   'Symptomatic hypotension, dizziness or syncope.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1b1ab00d-de9c-4614-e063-6394a90afcde ; rótulo aprovado Eritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1b1ab00d-de9c-4614-e063-6394a90afcde ; approved Erythromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'),
        (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'),
            (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   'moderate',
   'O Ritonavir aumenta a exposição ao Tadalafil (AUC até +124%), com maior risco de hipotensão e cefaleias. Em uso ocasional, não exceder 10 mg a cada 72 horas; em uso diário, não exceder 2,5 mg.',
   'Ritonavir increases Tadalafil exposure (up to 124% AUC), with a higher risk of hypotension and headache. For as-needed use, do not exceed 10 mg every 72 hours; for once-daily use, do not exceed 2.5 mg.',
   'O tadalafil é predominantemente metabolizado pelo CYP3A4; o ritonavir, inibidor desta isoenzima (e de outras), aumenta a exposição ao tadalafil em função da dose de ritonavir (32% com 500–600 mg 2×/dia; 124% com 200 mg 2×/dia).',
   'Tadalafil is predominantly metabolized by CYP3A4; ritonavir, an inhibitor of this isoenzyme (and others), increases tadalafil exposure depending on the ritonavir dose (32% with 500–600 mg twice daily; 124% with 200 mg twice daily).',
   'Ajustar a dose de tadalafil: uso ocasional — máximo 10 mg a cada 72 horas; uso diário — máximo 2,5 mg.',
   'Adjust the tadalafil dose: as-needed use — maximum 10 mg every 72 hours; once-daily use — maximum 2.5 mg.',
   'Vigiar pressão arterial, cefaleias, tonturas e rubor.',
   'Monitor blood pressure, headache, dizziness and flushing.',
   'Hipotensão sintomática, síncope ou cefaleias intensas.',
   'Symptomatic hypotension, syncope or severe headache.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c3409762-3b2b-1cfc-e053-2995a90ab91b ; rótulo aprovado Ritonavir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c3409762-3b2b-1cfc-e053-2995a90ab91b ; approved Ritonavir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'),
        (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'),
            (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   'moderate',
   'A Eritromicina, inibidor do CYP3A4, aumenta previsivelmente a exposição ao Tadalafil, com maior risco de hipotensão, rubor e cefaleias.',
   'Erythromycin, a CYP3A4 inhibitor, predictably increases Tadalafil exposure, with a higher risk of hypotension, flushing and headache.',
   'O tadalafil é substrato e predominantemente metabolizado pelo CYP3A4; os inibidores desta isoenzima, como a eritromicina, aumentam a sua exposição (o rótulo indica que inibidores do CYP3A4 como a eritromicina aumentariam previsivelmente a exposição).',
   'Tadalafil is a substrate predominantly metabolized by CYP3A4; inhibitors of this isoenzyme, such as erythromycin, increase its exposure (the label states that CYP3A4 inhibitors such as erythromycin would likely increase exposure).',
   'Usar com precaução; considerar redução da dose de tadalafil e vigiar efeitos adversos.',
   'Use with caution; consider reducing the tadalafil dose and monitor for adverse effects.',
   'Vigiar pressão arterial, cefaleias, tonturas e rubor.',
   'Monitor blood pressure, headache, dizziness and flushing.',
   'Hipotensão sintomática, tonturas ou síncope.',
   'Symptomatic hypotension, dizziness or syncope.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tadalafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c3409762-3b2b-1cfc-e053-2995a90ab91b ; rótulo aprovado Eritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'DailyMed/FDA (NIH/NLM) — approved Tadalafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c3409762-3b2b-1cfc-e053-2995a90ab91b ; approved Erythromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'tansulosina'),
        (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'tansulosina'),
            (SELECT id FROM public.drugs WHERE slug = 'eritromicina')),
   'moderate',
   'A Eritromicina, inibidor moderado do CYP3A4, pode aumentar a exposição à Tansulosina, com maior risco de hipotensão ortostática. Usar com precaução, sobretudo em doses superiores a 0,4 mg.',
   'Erythromycin, a moderate CYP3A4 inhibitor, may increase Tamsulosin exposure, with a higher risk of orthostatic hypotension. Use with caution, particularly at doses higher than 0.4 mg.',
   'A tansulosina é extensamente metabolizada pelo CYP3A4 e CYP2D6; os inibidores destas isoenzimas aumentam as suas concentrações plasmáticas (o rótulo recomenda precaução com inibidores moderados do CYP3A4 como a eritromicina).',
   'Tamsulosin is extensively metabolized by CYP3A4 and CYP2D6; inhibitors of these isoenzymes increase its plasma concentrations (the label advises caution with moderate CYP3A4 inhibitors such as erythromycin).',
   'Usar com precaução; vigiar hipotensão ortostática, sobretudo no início do tratamento ou ao subir a dose acima de 0,4 mg.',
   'Use with caution; monitor for orthostatic hypotension, especially at treatment initiation or when increasing the dose above 0.4 mg.',
   'Vigiar tonturas, queda da pressão arterial ao levantar e síncope.',
   'Monitor dizziness, blood pressure drop on standing and syncope.',
   'Síncope, hipotensão ortostática sintomática ou queda.',
   'Syncope, symptomatic orthostatic hypotension or falls.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tansulosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e4202c52-be9d-41d9-b5ff-122740298544 ; rótulo aprovado Eritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'DailyMed/FDA (NIH/NLM) — approved Tamsulosin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e4202c52-be9d-41d9-b5ff-122740298544 ; approved Erythromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0c05e1f7-a3d4-8e69-e063-6394a90aecc3',
   'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'dutasterida'),
        (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'dutasterida'),
            (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   'moderate',
   'O Ritonavir, inibidor potente do CYP3A4, pode aumentar a exposição à Dutasterida. Usar com precaução em doentes que tomam inibidores potentes do CYP3A4 de forma crónica.',
   'Ritonavir, a potent CYP3A4 inhibitor, may increase Dutasteride exposure. Use with caution in patients taking potent CYP3A4 inhibitors on a chronic basis.',
   'A dutasterida é extensamente metabolizada no homem pelas isoenzimas CYP3A4 e CYP3A5; os inibidores potentes destas enzimas (como o ritonavir) podem reduzir a sua depuração e aumentar as concentrações plasmáticas.',
   'Dutasteride is extensively metabolized in humans by the CYP3A4 and CYP3A5 isoenzymes; potent inhibitors of these enzymes (such as ritonavir) may reduce its clearance and increase plasma concentrations.',
   'Usar com precaução; vigiar efeitos adversos da dutasterida (ginecomastia, diminuição da libido) em doentes em terapêutica crónica com ritonavir.',
   'Use with caution; monitor dutasteride adverse effects (gynecomastia, decreased libido) in patients on chronic ritonavir therapy.',
   'Vigiar sinais de exposição aumentada à dutasterida em tratamentos prolongados.',
   'Monitor for signs of increased dutasteride exposure during prolonged treatment.',
   'Ginecomastia ou outros efeitos adversos da dutasterida de novo ou agravados.',
   'New or worsening gynecomastia or other dutasteride adverse effects.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dutasterida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; rótulo aprovado Ritonavir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'DailyMed/FDA (NIH/NLM) — approved Dutasteride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=947644ea-bc35-41df-8a7a-874360c90192 ; approved Ritonavir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2849298e-de6e-47bb-8194-56e075b33fc3',
   'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
