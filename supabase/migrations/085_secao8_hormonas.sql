-- =====================================================================
-- 085 — Secção 8 do Prontuário Terapêutico (hormonas)
-- ---------------------------------------------------------------------
-- 8 fármacos novos da secção 8 (8.3 antitiroideus, 8.4 antidiabéticos
-- orais, 8.5 hormonas sexuais e 8.7 anti-hormonas), com as 4 dimensões
-- de interação e perfil de fármaco:
--   • tiamazol       (8.3 — antitiroideu)
--   • glimepirida    (8.4 — sulfonilureia)
--   • gliclazida     (8.4 — sulfonilureia)
--   • pioglitazona   (8.4 — tiazolidinediona)
--   • levonorgestrel (8.5 — progestagénio)
--   • estradiol      (8.5 — estrogénio)
--   • tamoxifeno     (8.7 — anti-estrogénio)
--   • anastrozol     (8.7 — inibidor da aromatase)
-- Além disso, COMPLETA a prednisolona (8.2 — glucocorticóide, já
-- existente com pares e dimensão alimento) e a glibenclamida (8.4 —
-- sulfonilureia, já existente com pares) nas dimensões em falta
-- (doença, gestação) e cria-lhes o perfil.
--
-- Fontes (método do docs/INTERACOES_FLUXO_PESQUISA.md):
--   • DailyMed/FDA (NIH/NLM) — rótulos aprovados, setIDs obtidos via API
--     e extração das secções INDICATIONS, CONTRAINDICATIONS, WARNINGS,
--     ADVERSE REACTIONS e DRUG INTERACTIONS;
--   • EMC-UK (MHRA) — SmPC aprovadas, secções 4.3–4.6; URLs verificadas
--     (HTTP 200) em 2026-08 (a gliclazida não é comercializada nos EUA —
--     fonte primária EMC-UK);
--   • PubMed — apoio bibliográfico dos pares (URLs pubmed.ncbi.nlm.nih.gov);
--   • Prontuário Terapêutico do INFARMED (11.ª ed., 2012, ficheiro
--     offline fontes_interacoes/prontuario_utf8.txt) — corroboração
--     clínica (secções 8.2, 8.3, 8.4 e 8.5).
-- Conteúdo autoral (resumido/adaptado, nunca copiado).
-- Idempotente: reaplicar é seguro (ON CONFLICT ... DO NOTHING).
-- Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fármacos novos
-- ---------------------------------------------------------------------
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order) VALUES
  ('tiamazol', 'Tiamazol', 'Methimazole', 'Antitiroideu (tionamida)', 'Antithyroid agent (thionamide)', ARRAY['Tapazole'], 'published', 183),
  ('glimepirida', 'Glimepirida', 'Glimepiride', 'Sulfonilureia (antidiabético oral)', 'Sulfonylurea (oral antidiabetic)', ARRAY['Amaryl'], 'published', 184),
  ('gliclazida', 'Gliclazida', 'Gliclazide', 'Sulfonilureia (antidiabético oral)', 'Sulfonylurea (oral antidiabetic)', ARRAY['Diamicron'], 'published', 185),
  ('pioglitazona', 'Pioglitazona', 'Pioglitazone', 'Tiazolidinediona (antidiabético oral)', 'Thiazolidinedione (oral antidiabetic)', ARRAY['Actos'], 'published', 186),
  ('levonorgestrel', 'Levonorgestrel', 'Levonorgestrel', 'Progestagénio (contraceção hormonal)', 'Progestogen (hormonal contraception)', ARRAY['Levonelle', 'Postinor'], 'published', 187),
  ('estradiol', 'Estradiol', 'Estradiol', 'Estrogénio (terapêutica hormonal)', 'Oestrogen (hormone therapy)', ARRAY['Estrace', 'Evorel'], 'published', 188),
  ('tamoxifeno', 'Tamoxifeno', 'Tamoxifen', 'Modulador seletivo do recetor de estrogénio (SERM)', 'Selective oestrogen receptor modulator (SERM)', ARRAY['Nolvadex'], 'published', 189),
  ('anastrozol', 'Anastrozol', 'Anastrozole', 'Inibidor da aromatase (anti-hormona)', 'Aromatase inhibitor (anti-hormonal)', ARRAY['Arimidex'], 'published', 190);

-- ---------------------------------------------------------------------
-- 2. Pares fármaco-fármaco (novos)
--    Padrão 079: LEAST/GREATEST canónico + ON CONFLICT DO NOTHING,
--    com summary_pro_* e explanation_* (colunas da 079).
-- ---------------------------------------------------------------------

-- 2.1 TAMOXIFENO + FLUOXETINA (moderate — CYP2D6, endoxifeno)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A fluoxetina pode reduzir a eficácia do tamoxifeno no cancro da mama, porque bloqueia a enzima que o transforma na forma ativa do medicamento. Converse com o médico antes de tomar os dois juntos.',
  'Fluoxetine may reduce tamoxifen''s effectiveness in breast cancer by blocking the enzyme that converts it into the active form of the drug. Talk to your doctor before taking them together.',
  'Inibidores potentes do CYP2D6 (fluoxetina, paroxetina) reduzem 65–75% os níveis de endoxifeno (metabolito ativo do tamoxifeno), com possível perda de eficácia. Evitar a associação; preferir ISRS de menor inibição do CYP2D6 (ex.: citalopram, escitalopram, venlafaxina).',
  'Potent CYP2D6 inhibitors (fluoxetine, paroxetine) reduce endoxifen (tamoxifen''s active metabolite) levels by 65–75%, with possible loss of efficacy. Avoid the combination; prefer SSRIs with weaker CYP2D6 inhibition (e.g. citalopram, escitalopram, venlafaxine).',
  'O tamoxifeno é um pró-fármaco: a sua conversão em endoxifeno (metabolito com afinidade ~100x superior para o recetor de estrogénio) depende do CYP2D6. A fluoxetina é um inibidor potente desta isoenzima; estudos farmacocinéticos demonstram redução de 65–75% dos níveis de endoxifeno, e estudos observacionais associam o uso concomitante de ISRS inibidores do CYP2D6 a pior evolução do cancro da mama. A SmPC do tamoxifeno (EMC-UK) recomenda evitar sempre que possível a coadministração com inibidores potentes do CYP2D6 (paroxetina, fluoxetina, quinidina, cinacalcet, bupropiona). A sertralina inibe o CYP2D6 de forma moderada e dose-dependente. Se a doente precisar de antidepressivo, devem preferir-se agentes com menor impacto no CYP2D6.',
  'Tamoxifen is a prodrug: its conversion to endoxifen (a metabolite with ~100-fold higher affinity for the oestrogen receptor) depends on CYP2D6. Fluoxetine is a potent inhibitor of this isoenzyme; pharmacokinetic studies show a 65–75% reduction in endoxifen levels, and observational studies link the concomitant use of CYP2D6-inhibiting SSRIs to worse breast cancer outcomes. The tamoxifen SmPC (EMC-UK) recommends avoiding, whenever possible, co-administration with potent CYP2D6 inhibitors (paroxetine, fluoxetine, quinidine, cinacalcet, bupropion). Sertraline inhibits CYP2D6 moderately and in a dose-dependent manner. If an antidepressant is needed, agents with less CYP2D6 impact should be preferred.',
  'A fluoxetina inibe o CYP2D6, reduzindo a formação de endoxifeno (metabolito ativo do tamoxifeno).',
  'Fluoxetine inhibits CYP2D6, reducing the formation of endoxifen (the active tamoxifen metabolite).',
  'Evitar a associação; se for necessário um ISRS, escolher um com inibição fraca do CYP2D6 (citalopram, escitalopram, venlafaxina) e reavaliar a terapêutica com o oncologista.',
  'Avoid the combination; if an SSRI is needed, choose one with weak CYP2D6 inhibition (citalopram, escitalopram, venlafaxine) and reassess therapy with the oncologist.',
  'Aderência e resposta ao tamoxifeno; sintomas depressivos e efeitos adversos do ISRS.',
  'Tamoxifen adherence and response; depressive symptoms and SSRI adverse effects.',
  'Piora clínica do cancro da mama; síndrome serotoninérgica (rara nesta associação, mas vigiar tremor, agitação, hipertermia).',
  'Clinical worsening of breast cancer; serotonin syndrome (rare in this combination, but watch for tremor, agitation, hyperthermia).',
  'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluoxetina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/20141708/ e https://pubmed.ncbi.nlm.nih.gov/23760858/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — approved Fluoxetine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/20141708/ and https://pubmed.ncbi.nlm.nih.gov/23760858/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tamoxifeno' AND b.slug = 'fluoxetina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.2 TAMOXIFENO + SERTRALINA (moderate — CYP2D6)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A sertralina pode reduzir a eficácia do tamoxifeno no cancro da mama, ao diminuir a sua forma ativa. Informe sempre o seu médico se toma os dois medicamentos.',
  'Sertraline may reduce the effectiveness of tamoxifen in breast cancer by lowering its active form. Always tell your doctor if you take both medicines.',
  'A sertralina inibe o CYP2D6 de forma moderada e dose-dependente, reduzindo os níveis de endoxifeno. Se possível, preferir um ISRS com menor inibição do CYP2D6; se a associação for inevitável, vigiar a resposta.',
  'Sertraline inhibits CYP2D6 moderately and dose-dependently, reducing endoxifen levels. When possible, prefer an SSRI with weaker CYP2D6 inhibition; if the combination is unavoidable, monitor response.',
  'Tal como outros ISRS, a sertralina interfere na ativação do tamoxifeno pelo CYP2D6, com redução do endoxifeno. O efeito é menor do que com a fluoxetina ou a paroxetina (inibição moderada, mais evidente em doses elevadas de sertralina, acima de 100 mg/dia), mas a perda de eficácia é clinicamente relevante numa doença tão sensível ao tratamento adjuvante como o cancro da mama. A SmPC do tamoxifeno recomenda evitar inibidores potentes do CYP2D6 e ter precaução com os restantes.',
  'Like other SSRIs, sertraline interferes with CYP2D6-mediated activation of tamoxifen, lowering endoxifen. The effect is smaller than with fluoxetine or paroxetine (moderate inhibition, more evident at high sertraline doses, above 100 mg/day), but the loss of efficacy is clinically relevant in a disease as sensitive to adjuvant therapy as breast cancer. The tamoxifen SmPC recommends avoiding potent CYP2D6 inhibitors and exercising caution with the others.',
  'Inibição moderada do CYP2D6 pela sertralina, reduzindo a formação de endoxifeno.',
  'Moderate CYP2D6 inhibition by sertraline, reducing endoxifen formation.',
  'Preferir alternativas com menor impacto no CYP2D6 (citalopram, escitalopram, venlafaxina); se a sertralina for mantida, usar a dose mínima eficaz e informar o oncologista.',
  'Prefer alternatives with less CYP2D6 impact (citalopram, escitalopram, venlafaxine); if sertraline is kept, use the lowest effective dose and inform the oncologist.',
  'Resposta ao tamoxifeno e adesão; sinais de recidiva mamária.',
  'Tamoxifen response and adherence; signs of breast cancer recurrence.',
  'Novo nódulo mamário, dor óssea, agravamento clínico — reavaliação oncológica.',
  'New breast lump, bone pain, clinical worsening — oncology reassessment.',
  'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/20141708/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; PubMed — https://pubmed.ncbi.nlm.nih.gov/20141708/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tamoxifeno' AND b.slug = 'sertralina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.3 TAMOXIFENO + VARFARINA (moderate — aumento do efeito anticoagulante)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Tomar tamoxifeno com varfarina pode aumentar muito o efeito anticoagulante e o risco de hemorragia. O médico deve vigiar o INR com mais frequência.',
  'Taking tamoxifen with warfarin can greatly increase the anticoagulant effect and the risk of bleeding. Your doctor should check the INR more often.',
  'O tamoxifeno potencia significativamente o efeito dos anticoagulantes cumarínicos; na prevenção primária do cancro da mama a associação é contraindicada. Monitorizar INR no início e após qualquer alteração de dose.',
  'Tamoxifen significantly potentiates coumarin anticoagulants; in primary prevention of breast cancer the combination is contraindicated. Monitor INR on initiation and after any dose change.',
  'A SmPC do tamoxifeno (EMC-UK) refere um aumento significativo do efeito anticoagulante quando combinado com cumarínicos, e o rótulo DailyMed contraindica o uso em doentes que requeiram anticoagulação cumarínica concomitante (na indicação de redução de risco). O mecanismo envolve inibição do metabolismo dos cumarínicos e efeito aditivo sobre a hemostase. Na terapêutica adjuvante do cancro da mama, se a anticoagulação for indispensável, monitorizar o INR de forma apertada após o início do tamoxifeno (pode ser necessário reduzir a dose do anticoagulante).',
  'The tamoxifen SmPC (EMC-UK) reports a significant increase in anticoagulant effect when combined with coumarins, and the DailyMed label contraindicates use in patients requiring concomitant coumarin anticoagulation (in the risk-reduction indication). The mechanism involves inhibition of coumarin metabolism and an additive effect on haemostasis. In adjuvant breast cancer therapy, if anticoagulation is essential, monitor INR closely after starting tamoxifen (the anticoagulant dose may need to be reduced).',
  'Inibição do metabolismo dos cumarínicos e efeito aditivo na hemostase.',
  'Inhibition of coumarin metabolism and additive effect on haemostasis.',
  'Associar apenas se estritamente necessário; monitorizar INR 1–2 semanas após iniciar ou alterar o tamoxifeno e ajustar a dose do anticoagulante.',
  'Combine only if strictly necessary; check INR 1–2 weeks after starting or changing tamoxifen and adjust the anticoagulant dose.',
  'INR periódico; sintomas hemorrágicos.',
  'Periodic INR; bleeding symptoms.',
  'Melena, hematemese, equimoses espontâneas, hemorragia — assistência imediata.',
  'Melena, haematemesis, spontaneous bruising, bleeding — seek immediate care.',
  'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc ; DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tamoxifeno' AND b.slug = 'warfarina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.4 TAMOXIFENO + RIFAMPICINA (moderate — indução CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir bastante a quantidade de tamoxifeno no organismo, diminuindo o efeito do tratamento. Fale com o médico se precisar de tomar rifampicina.',
  'Rifampicin can markedly reduce the amount of tamoxifen in the body, lowering the effect of treatment. Talk to your doctor if you need to take rifampicin.',
  'Indutor potente do CYP3A4 (rifampicina) reduz a AUC do tamoxifeno em até 86%. Evitar a associação sempre que possível; se inevitável, considerar alternativa de tratamento do cancro da mama e monitorizar.',
  'Potent CYP3A4 inducer (rifampicin) reduces tamoxifen AUC by up to 86%. Avoid the combination whenever possible; if unavoidable, consider an alternative breast cancer treatment and monitor.',
  'O rótulo aprovado do tamoxifeno (DailyMed) documenta que a rifampicina, indutor do CYP3A4, reduz a AUC e a Cmax do tamoxifeno em 86% e 55%, respetivamente — uma perda de exposição que pode comprometer a eficácia antitumoral. A SmPC EMC-UK reforça a precaução com indutores do CYP3A4. Esta associação surge sobretudo no contexto de tuberculose ou profilaxia antibiótica; a gestão deve ser multidisciplinar.',
  'The approved tamoxifen label (DailyMed) documents that rifampicin, a CYP3A4 inducer, reduces tamoxifen AUC and Cmax by 86% and 55%, respectively — a loss of exposure that may compromise antitumour efficacy. The EMC-UK SmPC reinforces caution with CYP3A4 inducers. This combination arises mainly in tuberculosis or antibiotic prophylaxis; management should be multidisciplinary.',
  'Indução do CYP3A4 pela rifampicina, acelerando a eliminação do tamoxifeno.',
  'CYP3A4 induction by rifampicin, accelerating tamoxifen elimination.',
  'Evitar a associação; se a rifampicina for indispensável (tuberculose), reavaliar a terapêutica antineoplásica com o oncologista.',
  'Avoid the combination; if rifampicin is essential (tuberculosis), reassess antineoplastic therapy with the oncologist.',
  'Resposta ao tratamento e adesão; eventos adversos do tamoxifeno.',
  'Treatment response and adherence; tamoxifen adverse events.',
  'Agravamento clínico; sinais de progressão da doença.',
  'Clinical worsening; signs of disease progression.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tamoxifeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Tamoxifen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tamoxifeno' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.5 TAMOXIFENO + ANASTROZOL (moderate — evitar associação)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Não tomar anastrozol e tamoxifeno ao mesmo tempo: não há benefício adicional e a associação reduz os níveis de anastrozol no organismo.',
  'Do not take anastrozole and tamoxifen at the same time: there is no added benefit and the combination lowers anastrozole levels in the body.',
  'A coadministração de anastrozol e tamoxifeno reduziu a concentração plasmática de anastrozol em 27% no estudo ATAC, sem benefício adicional sobre a monoterapia. Evitar a associação (estudo ATAC não mostrou vantagem).',
  'Co-administration of anastrozole and tamoxifen reduced anastrozole plasma concentration by 27% in the ATAC trial, with no added benefit over monotherapy. Avoid the combination (the ATAC trial showed no advantage).',
  'No estudo ATAC, a combinação de anastrozol com tamoxifeno não melhorou a sobrevivência livre de doença face ao anastrozol isolado e reduziu a exposição ao anastrozol em cerca de 27%. A SmPC do anastrozol (EMC-UK) e o rótulo aprovado indicam explicitamente que não deve ser usado em combinação com tamoxifeno nem com terapêuticas contendo estrogénios, pois estas diminuem a sua atividade farmacológica.',
  'In the ATAC trial, combining anastrozole with tamoxifen did not improve disease-free survival over anastrozole alone and reduced anastrozole exposure by about 27%. The anastrozole SmPC (EMC-UK) and the approved label state explicitly that it must not be combined with tamoxifen or oestrogen-containing therapies, as these diminish its pharmacological activity.',
  'Efeito competitivo no recetor de estrogénio e redução da exposição ao anastrozol.',
  'Competitive effect at the oestrogen receptor and reduced anastrozole exposure.',
  'Usar um único agente hormonal adjuvante (tamoxifeno OU inibidor da aromatase), nunca em associação.',
  'Use a single adjuvant hormonal agent (tamoxifen OR aromatase inhibitor), never in combination.',
  'Resposta ao tratamento; densidade óssea e perfil lipídico conforme o agente usado.',
  'Treatment response; bone density and lipid profile according to the agent used.',
  'Progressão da doença; fraturas ou eventos cardiovasculares em terapêutica prolongada.',
  'Disease progression; fractures or cardiovascular events on long-term therapy.',
  'EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Tamoxifeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc ; DailyMed/FDA (NIH/NLM) — approved Tamoxifen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tamoxifeno' AND b.slug = 'anastrozol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.6 ANASTROZOL + ESTRADIOL (moderate — terapêuticas com estrogénios)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Não use estradiol (ou outros estrogénios) durante o tratamento com anastrozol — o estrogénio contraria o efeito do medicamento no cancro da mama.',
  'Do not use estradiol (or other oestrogens) during anastrozole treatment — oestrogen counteracts the medicine''s effect in breast cancer.',
  'Produtos contendo estrogénios (incluindo terapêutica hormonal de substituição) diminuem a atividade do anastrozol (inibidor da aromatase). Evitar a associação; a THS não é recomendada durante o tratamento adjuvante do cancro da mama.',
  'Oestrogen-containing products (including hormone replacement therapy) diminish the activity of anastrozole (aromatase inhibitor). Avoid the combination; HRT is not recommended during adjuvant breast cancer therapy.',
  'O anastrozol atua por inibição da aromatase, reduzindo a produção periférica de estrogénios. A administração concomitante de estrogénios exógenos (terapêutica hormonal de substituição, contraceção hormonal) reabastece o estrogénio que o fármaco pretende suprimir, anulando ou diminuindo o efeito antitumoral. O rótulo aprovado e a SmPC EMC-UK do anastrozol indicam que a combinação com terapêuticas contendo estrogénios deve ser evitada.',
  'Anastrozole acts by inhibiting aromatase, reducing peripheral oestrogen production. Concomitant administration of exogenous oestrogens (hormone replacement therapy, hormonal contraception) replenishes the oestrogen the drug aims to suppress, abolishing or diminishing the antitumour effect. The approved label and the EMC-UK SmPC for anastrozole state that combination with oestrogen-containing therapies should be avoided.',
  'Antagonismo farmacológico direto: estrogénio exógeno anula a supressão estrogénica.',
  'Direct pharmacological antagonism: exogenous oestrogen cancels oestrogen suppression.',
  'Não associar estrogénios ao anastrozol; discutir alternativas para sintomas vasomotores com o oncologista (não hormonais).',
  'Do not combine oestrogens with anastrozole; discuss non-hormonal options for vasomotor symptoms with the oncologist.',
  'Sinais/sintomas de recidiva; sintomas vasomotores e qualidade de vida.',
  'Signs/symptoms of recurrence; vasomotor symptoms and quality of life.',
  'Hemorragia vaginal, dor óssea nova, nódulo mamário — avaliação oncológica.',
  'Vaginal bleeding, new bone pain, breast lump — oncology assessment.',
  'EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc ; DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'anastrozol' AND b.slug = 'estradiol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.7 TIAMAZOL + VARFARINA (moderate — aumento do efeito anticoagulante)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O tiamazol pode aumentar o efeito da varfarina, elevando o risco de hemorragia. O INR deve ser vigiado com mais atenção durante o tratamento.',
  'Methimazole can increase the effect of warfarin, raising the risk of bleeding. The INR should be monitored more closely during treatment.',
  'O tiamazol pode inibir a atividade da vitamina K e potenciar os anticoagulantes orais; monitorizar PT/INR, sobretudo antes de procedimentos cirúrgicos.',
  'Methimazole may inhibit vitamin K activity and potentiate oral anticoagulants; monitor PT/INR, especially before surgical procedures.',
  'O rótulo aprovado do tiamazol (DailyMed) refere que, por potencial inibição da atividade da vitamina K, o fármaco pode aumentar a atividade dos anticoagulantes orais (ex.: varfarina), recomendando monitorização adicional da PT/INR, especialmente antes de procedimentos cirúrgicos. O efeito é mais relevante à medida que o hipertiroidismo é controlado, quando a clearance dos fármacos se altera.',
  'The approved methimazole label (DailyMed) states that, through potential inhibition of vitamin K activity, the drug may increase the activity of oral anticoagulants (e.g. warfarin), recommending additional PT/INR monitoring, especially before surgical procedures. The effect is more relevant as hyperthyroidism is controlled, when drug clearance changes.',
  'Inibição da atividade da vitamina K e alteração da clearance hepática à medida que o estado eutiroide é alcançado.',
  'Inhibition of vitamin K activity and altered hepatic clearance as the euthyroid state is reached.',
  'Monitorizar o INR após iniciar, ajustar ou suspender o tiamazol; considerar redução da dose do anticoagulante.',
  'Monitor INR after starting, adjusting or stopping methimazole; consider reducing the anticoagulant dose.',
  'INR periódico e sintomas hemorrágicos.',
  'Periodic INR and bleeding symptoms.',
  'Melena, hematemese, equimoses — assistência imediata.',
  'Melena, haematemesis, bruising — seek immediate care.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tiamazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Methimazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tiamazol' AND b.slug = 'warfarina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.8 TIAMAZOL + DIGOXINA (moderate — aumento dos níveis de digoxina)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Ao controlar o hipertiroidismo, o tiamazol pode aumentar os níveis de digoxina no sangue. O médico pode precisar de reduzir a dose de digoxina.',
  'As hyperthyroidism is controlled, methimazole can increase digoxin levels in the blood. Your doctor may need to reduce the digoxin dose.',
  'Os níveis séricos de digoxina podem aumentar quando o doente hipertiroideu estabilizado se torna eutiroideu; pode ser necessária redução da dose de digoxina.',
  'Serum digoxin levels may rise when a stabilised hyperthyroid patient becomes euthyroid; a digoxin dose reduction may be needed.',
  'O rótulo aprovado do tiamazol (DailyMed) documenta que os níveis séricos de digoxina podem aumentar quando o doente hipertiroideu em regime estável de digoxinase torna eutiroideu, recomendando redução da dose de digoxina. O hipertiroidismo aumenta a clearance renal e a distribuição da digoxina; com o controlo da tiróide, a clearance normaliza e os níveis sobem.',
  'The approved methimazole label (DailyMed) documents that serum digoxin levels may increase when a hyperthyroid patient on a stable digoxin regimen becomes euthyroid, recommending a digoxin dose reduction. Hyperthyroidism increases digoxin renal clearance and distribution; as the thyroid is controlled, clearance normalises and levels rise.',
  'Normalização da clearance da digoxina com o estado eutiroide, elevando os níveis séricos.',
  'Normalisation of digoxin clearance with the euthyroid state, raising serum levels.',
  'Vigiar níveis de digoxina e sinais de toxicidade (náuseas, visão a cores, arritmias) quando o doente atinge o estado eutiroide.',
  'Watch digoxin levels and signs of toxicity (nausea, colour vision, arrhythmias) as the patient reaches the euthyroid state.',
  'Digoxinemia, ECG e sintomas digestivos/visuais.',
  'Digoxin levels, ECG and digestive/visual symptoms.',
  'Náuseas persistentes, visão amarela/verde, palpitações, bradicardia — avaliar toxicidade digitálica.',
  'Persistent nausea, yellow/green vision, palpitations, bradycardia — assess digoxin toxicity.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tiamazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 ; rótulo aprovado Digoxina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Methimazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 ; approved Digoxin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tiamazol' AND b.slug = 'digoxina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.9 GLIMEPIRIDA + FLUCONAZOL (moderate — inibição CYP2C9)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Tomar fluconazol com glimepirida pode baixar demasiado o açúcar no sangue (hipoglicemia). Vigie os sinais e informe o médico.',
  'Taking fluconazole with glimepiride can lower blood sugar too much (hypoglycaemia). Watch for the signs and tell your doctor.',
  'O fluconazol (inibidor potente do CYP2C9) aumenta cerca de 2x a AUC da glimepirida, com risco de hipoglicemia grave. Se a associação for inevitável, vigiar a glicemia e considerar redução da dose da sulfonilureia.',
  'Fluconazole (a potent CYP2C9 inhibitor) increases glimepiride AUC by about 2-fold, with a risk of severe hypoglycaemia. If the combination is unavoidable, monitor blood glucose and consider reducing the sulfonylurea dose.',
  'A glimepirida é metabolizada pelo CYP2C9; o fluconazol é um dos inibidores mais potentes desta isoenzima. Um estudo in vivo citado na SmPC (EMC-UK) mostra aumento de aproximadamente 2x na AUC da glimepirida com fluconazol. A hipoglicemia resultante pode ser grave e prolongada, sobretudo em idosos e doentes com função renal comprometida. Esta é uma associação frequente em farmácia comunitária (candidíase vaginal/oral em doentes diabéticos).',
  'Glimepiride is metabolised by CYP2C9; fluconazole is one of the most potent inhibitors of this isoenzyme. An in vivo study cited in the SmPC (EMC-UK) shows an approximately 2-fold increase in glimepiride AUC with fluconazole. The resulting hypoglycaemia can be severe and prolonged, especially in the elderly and in patients with impaired renal function. This is a common combination in community pharmacy (vaginal/oral candidiasis in diabetic patients).',
  'Inibição do CYP2C9 pelo fluconazol, reduzindo o metabolismo da glimepirida.',
  'CYP2C9 inhibition by fluconazole, reducing glimepiride metabolism.',
  'Evitar se possível; se necessário, reduzir a dose da glimepirida e reforçar a automonitorização da glicemia durante e após o tratamento antifúngico.',
  'Avoid when possible; if needed, reduce the glimepiride dose and reinforce self-monitoring of blood glucose during and after antifungal treatment.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Sudorese, tremor, confusão, fome intensa, perda de consciência — tratar hipoglicemia de imediato.',
  'Sweating, tremor, confusion, intense hunger, loss of consciousness — treat hypoglycaemia immediately.',
  'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7961c029-746c-48c3-888b-8f8344102873 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Fluconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7961c029-746c-48c3-888b-8f8344102873 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glimepirida' AND b.slug = 'fluconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.10 GLIMEPIRIDA + CIPROFLOXACINA (moderate — disglicemia)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A ciprofloxacina pode baixar demasiado o açúcar no sangue em doentes que tomam glimepirida. Vigie a glicemia com atenção durante o antibiótico.',
  'Ciprofloxacin can lower blood sugar too much in patients taking glimepiride. Monitor blood glucose carefully during the antibiotic.',
  'As fluoroquinolonas podem causar disglicemia (hipo ou hiperglicemia) em doentes diabéticos, sobretudo idosos; com sulfonilureias há risco documentado de hipoglicemia grave e prolongada. Monitorizar glicemia durante o antibiótico.',
  'Fluoroquinolones can cause dysglycaemia (hypo- or hyperglycaemia) in diabetic patients, especially the elderly; with sulfonylureas there is a documented risk of severe, prolonged hypoglycaemia. Monitor blood glucose during the antibiotic.',
  'As fluoroquinolonas, incluindo a ciprofloxacina, alteram o controlo glicémico por mecanismos não totalmente esclarecidos (bloqueio dos canais de potássio ATP-dependentes das células beta e alterações da secreção de insulina). Existem casos documentados de hipoglicemia refratária com glibenclamida e ciprofloxacina, e a SmPC da gliclazida (EMC-UK) recomenda monitorização cuidada da glicemia em todos os doentes com sulfonilureias e fluoroquinolonas, com atenção especial aos idosos.',
  'Fluoroquinolones, including ciprofloxacin, alter glycaemic control through mechanisms that are not fully understood (blockade of ATP-dependent potassium channels in beta cells and altered insulin secretion). Documented cases of refractory hypoglycaemia with glyburide and ciprofloxacin exist, and the gliclazide SmPC (EMC-UK) recommends careful blood glucose monitoring in all patients on sulfonylureas and fluoroquinolones, with special attention to the elderly.',
  'Alteração da secreção de insulina pelas fluoroquinolonas, com risco aditivo nas sulfonilureias.',
  'Altered insulin secretion by fluoroquinolones, with additive risk with sulfonylureas.',
  'Reforçar a automonitorização da glicemia durante o antibiótico; informar o doente dos sinais de hipo e hiperglicemia.',
  'Reinforce self-monitoring of blood glucose during the antibiotic; educate the patient on the signs of hypo- and hyperglycaemia.',
  'Glicemia capilar diária durante o antibiótico.',
  'Daily capillary glucose during the antibiotic.',
  'Hipoglicemia grave ou prolongada; confusão, sudação, coma — assistência médica imediata.',
  'Severe or prolonged hypoglycaemia; confusion, sweating, coma — seek immediate medical care.',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/10918110/ e https://pubmed.ncbi.nlm.nih.gov/15362597/ ; EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciprofloxacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/10918110/ and https://pubmed.ncbi.nlm.nih.gov/15362597/ ; EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Ciprofloxacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glimepirida' AND b.slug = 'ciprofloxacina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.11 GLIMEPIRIDA + COTRIMOXAZOL (moderate — sulfonamidas)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cotrimoxazol pode potenciar o efeito da glimepirida e baixar demasiado o açúcar no sangue. Vigie a glicemia durante o tratamento.',
  'Co-trimoxazole can enhance the effect of glimepiride and lower blood sugar too much. Monitor blood glucose during treatment.',
  'As sulfonamidas (sulfametoxazol no cotrimoxazol) potenciam a hipoglicemia das sulfonilureias por deslocação proteica e redução da eliminação. Monitorizar glicemia e considerar redução da dose.',
  'Sulphonamides (sulfamethoxazole in co-trimoxazole) potentiate sulfonylurea hypoglycaemia through protein displacement and reduced elimination. Monitor blood glucose and consider a dose reduction.',
  'As sulfonamidas potenciam o efeito hipoglicemiante das sulfonilureias por múltiplos mecanismos: deslocação da ligação às proteínas plasmáticas, inibição do metabolismo e redução da excreção renal. A SmPC da glimepirida (EMC-UK) inclui as sulfonamidas de ação prolongada entre os fármacos que potenciam o efeito hipoglicemiante. Esta associação é comum (infeções urinárias e respiratórias em diabéticos).',
  'Sulphonamides potentiate the hypoglycaemic effect of sulfonylureas through multiple mechanisms: displacement from plasma protein binding, inhibition of metabolism and reduced renal excretion. The glimepiride SmPC (EMC-UK) lists long-acting sulphonamides among the drugs that potentiate the hypoglycaemic effect. This combination is common (urinary and respiratory infections in diabetics).',
  'Deslocação proteica e inibição do metabolismo da glimepirida pelas sulfonamidas.',
  'Protein displacement and inhibition of glimepiride metabolism by sulphonamides.',
  'Monitorizar glicemia durante o antibiótico; considerar redução temporária da dose da sulfonilureia.',
  'Monitor blood glucose during the antibiotic; consider a temporary sulfonylurea dose reduction.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Hipoglicemia grave — sudação, tremor, confusão, perda de consciência.',
  'Severe hypoglycaemia — sweating, tremor, confusion, loss of consciousness.',
  'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Cotrimoxazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Co-trimoxazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glimepirida' AND b.slug = 'cotrimoxazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.12 GLIMEPIRIDA + FLUOXETINA (moderate — potenciação da hipoglicemia)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A fluoxetina pode aumentar o efeito da glimepirida e baixar demasiado o açúcar no sangue. Vigie os sinais de hipoglicemia.',
  'Fluoxetine can increase the effect of glimepiride and lower blood sugar too much. Watch for the signs of hypoglycaemia.',
  'A SmPC da glimepirida (EMC-UK) inclui a fluoxetina entre os fármacos que potenciam o efeito hipoglicemiante. Monitorizar glicemia ao iniciar ou ajustar o ISRS.',
  'The glimepiride SmPC (EMC-UK) lists fluoxetine among the drugs that potentiate the hypoglycaemic effect. Monitor blood glucose when starting or adjusting the SSRI.',
  'A SmPC da glimepirida (EMC-UK) lista a fluoxetina e os IMAO entre os fármacos que podem potenciar o efeito hipoglicemiante das sulfonilureias, por mecanismos que envolvem inibição enzimática e alteração da insulinossensibilidade. A monitorização da glicemia é recomendada no início e durante o tratamento com o ISRS, particularmente nos primeiros dias.',
  'The glimepiride SmPC (EMC-UK) lists fluoxetine and MAOIs among the drugs that may potentiate the hypoglycaemic effect of sulfonylureas, through mechanisms involving enzyme inhibition and altered insulin sensitivity. Blood glucose monitoring is recommended at the start and during SSRI treatment, particularly in the first days.',
  'Inibição enzimática e alteração da insulinossensibilidade pela fluoxetina.',
  'Enzyme inhibition and altered insulin sensitivity by fluoxetine.',
  'Reforçar a automonitorização da glicemia ao iniciar a fluoxetina; ajustar a dose da sulfonilureia se necessário.',
  'Reinforce self-monitoring of blood glucose when starting fluoxetine; adjust the sulfonylurea dose if needed.',
  'Glicemia capilar no início do tratamento com o ISRS.',
  'Capillary glucose at the start of SSRI treatment.',
  'Hipoglicemia — tremor, sudação, confusão.',
  'Hypoglycaemia — tremor, sweating, confusion.',
  'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluoxetina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Fluoxetine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glimepirida' AND b.slug = 'fluoxetina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.13 GLIMEPIRIDA + PIOGLITAZONA (moderate — hipoglicemia aditiva)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar glimepirida com pioglitazona aumenta o risco de hipoglicemia. Se forem usadas juntas, o médico pode reduzir a dose de glimepirida.',
  'Combining glimepiride with pioglitazone increases the risk of hypoglycaemia. If used together, your doctor may reduce the glimepiride dose.',
  'A associação de uma tiazolidinediona a um secretagogo de insulina aumenta o risco de hipoglicemia; pode ser necessária redução da dose da sulfonilureia (e da pioglitazona se edema/IC).',
  'Combining a thiazolidinedione with an insulin secretagogue increases the risk of hypoglycaemia; the sulfonylurea dose may need to be reduced (and pioglitazone if oedema/heart failure).',
  'A pioglitazona sensibiliza os tecidos à insulina; quando associada a uma sulfonilureia (secretagogo), o efeito hipoglicemiante é aditivo. O rótulo aprovado da pioglitazona (DailyMed) refere que, quando usada com insulina ou secretagogos, pode ser necessária uma dose mais baixa destes para reduzir o risco de hipoglicemia. Esta associação é frequente na terapêutica combinada da diabetes tipo 2.',
  'Pioglitazone sensitises tissues to insulin; when combined with a sulfonylurea (secretagogue), the hypoglycaemic effect is additive. The approved pioglitazone label (DailyMed) states that, when used with insulin or secretagogues, a lower dose of these may be needed to reduce the risk of hypoglycaemia. This combination is common in type 2 diabetes combination therapy.',
  'Efeito hipoglicemiante aditivo da sensibilização insulínica com a estimulação da secreção.',
  'Additive hypoglycaemic effect of insulin sensitisation with secretion stimulation.',
  'Se a associação for necessária, reduzir a dose da sulfonilureia e monitorizar a glicemia, sobretudo nas primeiras semanas.',
  'If the combination is needed, reduce the sulfonylurea dose and monitor blood glucose, especially in the first weeks.',
  'Glicemia capilar; sinais de retenção hídrica/edema (efeito da pioglitazona).',
  'Capillary glucose; signs of fluid retention/oedema (pioglitazone effect).',
  'Hipoglicemia; edema súbito, falta de ar (IC) — assistência médica.',
  'Hypoglycaemia; sudden oedema, shortness of breath (heart failure) — medical attention.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glimepirida' AND b.slug = 'pioglitazona'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.14 GLICLAZIDA + FLUCONAZOL (moderate — inibição CYP2C9)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O fluconazol pode aumentar o efeito da gliclazida e baixar demasiado o açúcar no sangue. Vigie a glicemia durante o antifúngico.',
  'Fluconazole can increase the effect of gliclazide and lower blood sugar too much. Monitor blood glucose during the antifungal.',
  'O fluconazol potência o efeito hipoglicemiante da gliclazida (inibição do CYP2C9 e da eliminação). Precaução com monitorização da glicemia; pode ser necessário ajustar a dose.',
  'Fluconazole potentiates the hypoglycaemic effect of gliclazide (CYP2C9 inhibition and reduced elimination). Caution with blood glucose monitoring; a dose adjustment may be needed.',
  'A SmPC da gliclazida (EMC-UK) inclui o fluconazol entre os fármacos que potenciam o efeito hipoglicemiante das sulfonilureias, com possível hipoglicemia sintomática ou coma. O mecanismo envolve inibição do CYP2C9 (metabolismo da gliclazida) e da excreção. A monitorização da glicemia é obrigatória durante a associação.',
  'The gliclazide SmPC (EMC-UK) lists fluconazole among the drugs that potentiate the hypoglycaemic effect of sulfonylureas, with possible symptomatic hypoglycaemia or coma. The mechanism involves inhibition of CYP2C9 (gliclazide metabolism) and excretion. Blood glucose monitoring is mandatory during the combination.',
  'Inibição do CYP2C9 e da eliminação renal da gliclazida pelo fluconazol.',
  'CYP2C9 inhibition and reduced gliclazide elimination by fluconazole.',
  'Preferir antifúngico alternativo se possível; senão, monitorizar glicemia e considerar redução da dose da sulfonilureia.',
  'Prefer an alternative antifungal when possible; otherwise, monitor blood glucose and consider a sulfonylurea dose reduction.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Hipoglicemia grave — sudação, confusão, coma.',
  'Severe hypoglycaemia — sweating, confusion, coma.',
  'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7961c029-746c-48c3-888b-8f8344102873 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — approved Fluconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7961c029-746c-48c3-888b-8f8344102873 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'gliclazida' AND b.slug = 'fluconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.15 GLICLAZIDA + CIPROFLOXACINA (moderate — disglicemia por fluoroquinolonas)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A ciprofloxacina pode alterar o açúcar no sangue em doentes que tomam gliclazida, sobretudo idosos. Vigie a glicemia durante o antibiótico.',
  'Ciprofloxacin can alter blood sugar in patients taking gliclazide, especially the elderly. Monitor blood glucose during the antibiotic.',
  'A SmPC da gliclazida (EMC-UK) recomenda monitorização cuidada da glicemia com fluoroquinolonas (disglicemia, sobretudo em idosos). Vigiar sinais de hipo e hiperglicemia durante e após o antibiótico.',
  'The gliclazide SmPC (EMC-UK) recommends careful blood glucose monitoring with fluoroquinolones (dysglycaemia, especially in the elderly). Watch for hypo- and hyperglycaemia during and after the antibiotic.',
  'A SmPC da gliclazida (EMC-UK) refere explicitamente perturbações da glicemia, incluindo hipo e hiperglicemia, em doentes diabéticos tratados com fluoroquinolonas, sobretudo idosos, recomendando monitorização cuidada da glicemia em todos os doentes em associação. O mecanismo envolve alterações da secreção de insulina pelas fluoroquinolonas.',
  'The gliclazide SmPC (EMC-UK) explicitly mentions blood glucose disturbances, including hypo- and hyperglycaemia, in diabetic patients treated with fluoroquinolones, especially the elderly, recommending careful blood glucose monitoring in all patients on the combination. The mechanism involves fluoroquinolone-induced changes in insulin secretion.',
  'Alterações da secreção de insulina induzidas pelas fluoroquinolonas.',
  'Fluoroquinolone-induced changes in insulin secretion.',
  'Monitorizar a glicemia diariamente durante o antibiótico; instruir o doente sobre sinais de disglicemia.',
  'Monitor blood glucose daily during the antibiotic; instruct the patient on the signs of dysglycaemia.',
  'Glicemia capilar; sintomas de hipo/hiperglicemia.',
  'Capillary glucose; symptoms of hypo/hyperglycaemia.',
  'Confusão, sudação, poliúria, sede intensa, coma — assistência médica.',
  'Confusion, sweating, polyuria, intense thirst, coma — medical attention.',
  'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciprofloxacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — approved Ciprofloxacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'gliclazida' AND b.slug = 'ciprofloxacina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.16 GLICLAZIDA + VARFARINA (moderate — potenciação da anticoagulação)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A gliclazida pode aumentar o efeito da varfarina e o risco de hemorragia. O INR deve ser vigiado com mais frequência.',
  'Gliclazide can increase the effect of warfarin and the risk of bleeding. The INR should be checked more often.',
  'As sulfonilureias podem potenciar a anticoagulação durante o tratamento concomitante; pode ser necessário ajustar a dose do anticoagulante. Monitorizar INR.',
  'Sulfonylureas may potentiate anticoagulation during concurrent treatment; the anticoagulant dose may need adjustment. Monitor INR.',
  'A SmPC da gliclazida (EMC-UK) refere que as sulfonilureias podem potenciar a anticoagulação durante o tratamento concomitante com cumarínicos (ex.: varfarina), podendo ser necessário ajustar a dose do anticoagulante. O mecanismo envolve deslocação da ligação proteica e inibição do metabolismo dos cumarínicos. A associação é frequente (diabetes tipo 2 e fibrilhação auricular).',
  'The gliclazide SmPC (EMC-UK) states that sulfonylureas may potentiate anticoagulation during concurrent treatment with coumarins (e.g. warfarin), and the anticoagulant dose may need adjustment. The mechanism involves displacement from protein binding and inhibition of coumarin metabolism. The combination is common (type 2 diabetes and atrial fibrillation).',
  'Deslocação da ligação proteica e inibição do metabolismo dos cumarínicos.',
  'Displacement from protein binding and inhibition of coumarin metabolism.',
  'Monitorizar o INR ao iniciar, ajustar ou suspender a gliclazida e ajustar a dose do anticoagulante.',
  'Monitor INR when starting, adjusting or stopping gliclazide and adjust the anticoagulant dose.',
  'INR periódico e sintomas hemorrágicos.',
  'Periodic INR and bleeding symptoms.',
  'Melena, hematemese, equimoses — assistência imediata.',
  'Melena, haematemesis, bruising — seek immediate care.',
  'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc ; DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'gliclazida' AND b.slug = 'warfarina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.17 GLICLAZIDA + PIOGLITAZONA (moderate — hipoglicemia aditiva)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Combinar gliclazida com pioglitazona aumenta o risco de hipoglicemia. O médico pode reduzir a dose de gliclazida.',
  'Combining gliclazide with pioglitazone increases the risk of hypoglycaemia. Your doctor may reduce the gliclazide dose.',
  'Tiazolidinediona + sulfonilureia: efeito hipoglicemiante aditivo; pode ser necessária redução da dose da sulfonilureia. Vigiar também retenção hídrica/edema da pioglitazona.',
  'Thiazolidinedione + sulfonylurea: additive hypoglycaemic effect; a sulfonylurea dose reduction may be needed. Also watch for pioglitazone fluid retention/oedema.',
  'A pioglitazona melhora a sensibilidade à insulina; com sulfonilureias, o efeito sobre a glicemia é aditivo e o risco de hipoglicemia aumenta, exigindo redução da dose do secretagogo. O rótulo da pioglitazona (DailyMed) recomenda dose mais baixa de insulina ou secretagogos quando combinados. A associação é usada na diabetes tipo 2 mal controlada.',
  'Pioglitazone improves insulin sensitivity; with sulfonylureas, the effect on blood glucose is additive and the risk of hypoglycaemia increases, requiring a secretagogue dose reduction. The pioglitazone label (DailyMed) recommends a lower dose of insulin or secretagogues when combined. The combination is used in poorly controlled type 2 diabetes.',
  'Efeito hipoglicemiante aditivo da sensibilização insulínica com a estimulação da secreção.',
  'Additive hypoglycaemic effect of insulin sensitisation with secretion stimulation.',
  'Reduzir a dose da sulfonilureia ao iniciar a pioglitazona e monitorizar glicemia nas primeiras semanas.',
  'Reduce the sulfonylurea dose when starting pioglitazone and monitor blood glucose in the first weeks.',
  'Glicemia capilar; edema e sinais de insuficiência cardíaca.',
  'Capillary glucose; oedema and signs of heart failure.',
  'Hipoglicemia; edema súbito, dispneia.',
  'Hypoglycaemia; sudden oedema, dyspnoea.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'gliclazida' AND b.slug = 'pioglitazona'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.18 PIOGLITAZONA + RIFAMPICINA (moderate — indução CYP2C8)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir o efeito da pioglitazona, exigindo vigilância da glicemia e possível aumento de dose.',
  'Rifampicin can reduce the effect of pioglitazone, requiring blood glucose monitoring and a possible dose increase.',
  'A rifampicina (indutor do CYP2C8) reduz a AUC da pioglitazona em 54%; pode ser necessário aumentar a dose de pioglitazona com monitorização da glicemia.',
  'Rifampicin (a CYP2C8 inducer) reduces pioglitazone AUC by 54%; the pioglitazone dose may need to be increased with blood glucose monitoring.',
  'A pioglitazona é metabolizada principalmente pelo CYP2C8; a rifampicina, indutor potente desta isoenzima, reduz a AUC da pioglitazona em cerca de 54% (SmPC EMC-UK). A diminuição da exposição pode comprometer o controlo glicémico. Esta associação ocorre em doentes com tuberculose e diabetes.',
  'Pioglitazone is mainly metabolised by CYP2C8; rifampicin, a potent inducer of this isoenzyme, reduces pioglitazone AUC by about 54% (EMC-UK SmPC). The reduced exposure can compromise glycaemic control. This combination occurs in patients with tuberculosis and diabetes.',
  'Indução do CYP2C8 pela rifampicina, acelerando o metabolismo da pioglitazona.',
  'CYP2C8 induction by rifampicin, accelerating pioglitazone metabolism.',
  'Monitorizar glicemia e considerar aumento da dose de pioglitazona durante a rifampicina; reajustar no fim do antibiótico.',
  'Monitor blood glucose and consider increasing the pioglitazone dose during rifampicin; readjust at the end of the antibiotic.',
  'Glicemia capilar e HbA1c durante o tratamento concomitante.',
  'Capillary glucose and HbA1c during concurrent treatment.',
  'Hiperglicemia — sede, poliúria, fadiga.',
  'Hyperglycaemia — thirst, polyuria, fatigue.',
  'EMC-UK (MHRA) — SmPC aprovada Pioglitazona: https://www.medicines.org.uk/emc/product/12841/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Pioglitazone SmPC: https://www.medicines.org.uk/emc/product/12841/smpc ; DailyMed/FDA (NIH/NLM) — approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'pioglitazona' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;-- 2.19 LEVONORGESTREL + CARBAMAZEPINA (moderate — indutores enzimáticos)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A carbamazepina pode reduzir a eficácia do levonorgestrel (incluindo a contraceção de emergência). Se toma os dois, fale com o médico ou farmacêutico.',
  'Carbamazepine can reduce the effectiveness of levonorgestrel (including emergency contraception). If you take both, talk to your doctor or pharmacist.',
  'Indutores enzimáticos (carbamazepina, fenitoína, rifampicina, barbitúricos) aceleram o metabolismo dos progestagénios e reduzem a eficácia contracetiva. Na contraceção de emergência com levonorgestrel, considerar alternativa (acetato de ulipristal não é alternativa fiável com indutores; DIU de cobre).',
  'Enzyme inducers (carbamazepine, phenytoin, rifampicin, barbiturates) accelerate progestogen metabolism and reduce contraceptive effectiveness. For emergency contraception with levonorgestrel, consider an alternative (ulipristal acetate is not a reliable alternative with inducers; copper IUD).',
  'A carbamazepina induz o CYP3A4 e a glicuronidação, acelerando a eliminação do levonorgestrel e reduzindo a eficácia contracetiva — o rótulo OTC do levonorgestrel avisa explicitamente que medicamentos para epilepsia podem reduzir a eficácia, e o Prontuário refere que os indutores enzimáticos (barbitúricos, fenitoína, primidona, carbamazepina, rifampicina) reduzem a eficácia dos progestagénios. Em contraceção hormonal regular, recomenda-se método alternativo ou complementar; na contraceção de emergência, o DIU de cobre é a alternativa fiável.',
  'Carbamazepine induces CYP3A4 and glucuronidation, accelerating levonorgestrel elimination and reducing contraceptive effectiveness — the levonorgestrel OTC label explicitly warns that seizure medicines can reduce effectiveness, and the Prontuário states that enzyme inducers (barbiturates, phenytoin, primidone, carbamazepine, rifampicin) reduce the effectiveness of progestogens. In regular hormonal contraception, an alternative or complementary method is recommended; for emergency contraception, the copper IUD is the reliable alternative.',
  'Indução do CYP3A4, acelerando o metabolismo do levonorgestrel.',
  'CYP3A4 induction, accelerating levonorgestrel metabolism.',
  'Usar método contracetivo não hormonal (DIU de cobre) ou barreira adicional; na contraceção de emergência, preferir DIU de cobre.',
  'Use a non-hormonal contraceptive (copper IUD) or an additional barrier method; for emergency contraception, prefer the copper IUD.',
  'Eficácia contracetiva; ciclos irregulares podem indicar redução de exposição hormonal.',
  'Contraceptive effectiveness; irregular cycles may indicate reduced hormonal exposure.',
  'Gravidez não planeada; hemorragia irregular.',
  'Unplanned pregnancy; irregular bleeding.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; rótulo aprovado Carbamazepina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2 ; PubMed — https://pmc.ncbi.nlm.nih.gov/articles/PMC2848501/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; approved Carbamazepine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2 ; PubMed — https://pmc.ncbi.nlm.nih.gov/articles/PMC2848501/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'levonorgestrel' AND b.slug = 'carbamazepina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.20 LEVONORGESTREL + FENITOINA (moderate — indutores enzimáticos)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A fenitoína pode reduzir a eficácia do levonorgestrel. Se toma os dois, considere um método contracetivo adicional ou alternativo.',
  'Phenytoin can reduce the effectiveness of levonorgestrel. If you take both, consider an additional or alternative contraceptive method.',
  'Indutores enzimáticos (fenitoína) reduzem a eficácia dos progestagénios. Recomendar método não hormonal (DIU de cobre) ou barreira adicional; na contraceção de emergência, DIU de cobre.',
  'Enzyme inducers (phenytoin) reduce progestogen effectiveness. Recommend a non-hormonal method (copper IUD) or an additional barrier method; for emergency contraception, the copper IUD.',
  'A fenitoína é um indutor enzimático que acelera o metabolismo do levonorgestrel e de outros progestagénios, comprometendo a eficácia contracetiva. O Prontuário lista a fenitoína entre os indutores que reduzem a eficácia dos progestagénios, e o rótulo OTC do levonorgestrel avisa que medicamentos para epilepsia podem reduzir a eficácia. Em mulheres epiléticas em contraceção hormonal, recomenda-se um método não hormonal ou contraceção hormonal com dose elevada de estrogénio, conforme a orientação clínica.',
  'Phenytoin is an enzyme inducer that accelerates the metabolism of levonorgestrel and other progestogens, compromising contraceptive effectiveness. The Prontuário lists phenytoin among the inducers that reduce progestogen effectiveness, and the levonorgestrel OTC label warns that seizure medicines can reduce effectiveness. In women with epilepsy on hormonal contraception, a non-hormonal method or high-oestrogen hormonal contraception is recommended according to clinical guidance.',
  'Indução enzimática, acelerando o metabolismo do levonorgestrel.',
  'Enzyme induction, accelerating levonorgestrel metabolism.',
  'Usar DIU de cobre ou método de barreira adicional; reavaliar a contraceção com o médico.',
  'Use a copper IUD or an additional barrier method; reassess contraception with the doctor.',
  'Eficácia contracetiva e regularidade do ciclo.',
  'Contraceptive effectiveness and cycle regularity.',
  'Gravidez não planeada.',
  'Unplanned pregnancy.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'levonorgestrel' AND b.slug = 'fenitoina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.21 LEVONORGESTREL + RIFAMPICINA (moderate — indutores enzimáticos)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir a eficácia do levonorgestrel. O rótulo do próprio medicamento avisa para consultar o médico se toma rifampicina (tratamento da tuberculose).',
  'Rifampicin can reduce the effectiveness of levonorgestrel. The medicine label itself advises asking a doctor if you take rifampicin (tuberculosis treatment).',
  'O rótulo OTC do levonorgestrel avisa que a rifampicina pode reduzir a eficácia. Em doentes a tomar rifampicina, preferir DIU de cobre na contraceção de emergência e método não hormonal na contraceção regular.',
  'The levonorgestrel OTC label warns that rifampicin can reduce effectiveness. In patients taking rifampicin, prefer the copper IUD for emergency contraception and a non-hormonal method for regular contraception.',
  'O rótulo de venda livre do levonorgestrel (DailyMed) instrui explicitamente a consultar médico ou farmacêutico antes do uso se estiver a tomar efavirenz ou rifampicina (tratamento da tuberculose) ou medicamentos para epilepsia, pois estes podem reduzir a eficácia do levonorgestrel. A rifampicina induz o CYP3A4 e acelera a eliminação do progestagénio. Em doentes com tuberculose, a contraceção de emergência hormonal é pouco fiável — o DIU de cobre é a alternativa.',
  'The levonorgestrel over-the-counter label (DailyMed) explicitly instructs asking a doctor or pharmacist before use if taking efavirenz or rifampicin (tuberculosis treatment) or seizure medicines, as these can reduce the effectiveness of levonorgestrel. Rifampicin induces CYP3A4 and accelerates progestogen elimination. In patients with tuberculosis, hormonal emergency contraception is unreliable — the copper IUD is the alternative.',
  'Indução do CYP3A4 pela rifampicina, acelerando a eliminação do levonorgestrel.',
  'CYP3A4 induction by rifampicin, accelerating levonorgestrel elimination.',
  'Preferir DIU de cobre na contraceção de emergência; método não hormonal na contraceção regular durante a rifampicina.',
  'Prefer the copper IUD for emergency contraception; a non-hormonal method for regular contraception during rifampicin.',
  'Eficácia contracetiva.',
  'Contraceptive effectiveness.',
  'Gravidez não planeada.',
  'Unplanned pregnancy.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'levonorgestrel' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.22 ESTRADIOL + CARBAMAZEPINA (moderate — indutores do CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A carbamazepina pode reduzir o efeito do estradiol (terapêutica hormonal), diminuindo a eficácia e alterando o padrão de hemorragia. Informe o médico.',
  'Carbamazepine can reduce the effect of estradiol (hormone therapy), lowering effectiveness and changing the bleeding pattern. Tell your doctor.',
  'Indutores do CYP3A4 (carbamazepina, fenitoína, rifampicina) reduzem as concentrações de estrogénios, com diminuição do efeito terapêutico e alterações do padrão hemorrágico. Considerar ajuste de dose ou método alternativo.',
  'CYP3A4 inducers (carbamazepine, phenytoin, rifampicin) reduce oestrogen concentrations, decreasing the therapeutic effect and changing the bleeding pattern. Consider a dose adjustment or an alternative.',
  'O rótulo aprovado do estradiol (DailyMed) documenta que os estrogénios são parcialmente metabolizados pelo CYP3A4 e que indutores desta enzima — como carbamazepina, fenitoína, barbitúricos e rifampicina — podem reduzir as concentrações plasmáticas, diminuindo o efeito terapêutico e alterando o padrão de hemorragia uterina. Na terapêutica hormonal de substituição, pode ser necessário ajustar a dose ou considerar outra via de administração; nos anticoncecionais hormonais, a eficácia contracetiva pode estar comprometida.',
  'The approved estradiol label (DailyMed) documents that oestrogens are partially metabolised by CYP3A4 and that inducers of this enzyme — such as carbamazepine, phenytoin, barbiturates and rifampicin — can reduce plasma concentrations, decreasing the therapeutic effect and changing the uterine bleeding pattern. In hormone replacement therapy, a dose adjustment or another route may be needed; in hormonal contraceptives, contraceptive effectiveness may be compromised.',
  'Indução do CYP3A4, acelerando o metabolismo dos estrogénios.',
  'CYP3A4 induction, accelerating oestrogen metabolism.',
  'Monitorizar o efeito terapêutico; considerar ajuste de dose do estradiol ou contraceção não hormonal quando aplicável.',
  'Monitor the therapeutic effect; consider an estradiol dose adjustment or non-hormonal contraception when applicable.',
  'Sintomas vasomotores, padrão de hemorragia e eficácia contracetiva.',
  'Vasomotor symptoms, bleeding pattern and contraceptive effectiveness.',
  'Hemorragia irregular, retorno dos sintomas da menopausa, gravidez não planeada.',
  'Irregular bleeding, return of menopausal symptoms, unplanned pregnancy.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; rótulo aprovado Carbamazepina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; approved Carbamazepine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'estradiol' AND b.slug = 'carbamazepina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.23 ESTRADIOL + RIFAMPICINA (moderate — indutores do CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir o efeito do estradiol, diminuindo a eficácia da terapêutica hormonal. Informe o médico se vai tomar rifampicina.',
  'Rifampicin can reduce the effect of estradiol, lowering the effectiveness of hormone therapy. Tell your doctor if you are going to take rifampicin.',
  'A rifampicina (indutor potente do CYP3A4) reduz as concentrações de estrogénios; monitorizar o efeito e considerar ajuste de dose durante o antibiótico.',
  'Rifampicin (a potent CYP3A4 inducer) reduces oestrogen concentrations; monitor the effect and consider a dose adjustment during the antibiotic.',
  'O rótulo aprovado do estradiol (DailyMed) cita a rifampicina entre os indutores do CYP3A4 que reduzem as concentrações plasmáticas de estrogénios, com possível diminuição do efeito terapêutico e alterações do padrão hemorrágico. Em doentes a tomar rifampicina (ex.: tuberculose), o efeito da terapêutica hormonal de substituição pode ser insuficiente e a eficácia contracetiva hormonal fica comprometida.',
  'The approved estradiol label (DailyMed) cites rifampicin among the CYP3A4 inducers that reduce plasma oestrogen concentrations, with possible decreased therapeutic effect and changes in the bleeding pattern. In patients taking rifampicin (e.g. tuberculosis), hormone replacement therapy may be insufficient and hormonal contraceptive effectiveness is compromised.',
  'Indução do CYP3A4 pela rifampicina, acelerando a eliminação dos estrogénios.',
  'CYP3A4 induction by rifampicin, accelerating oestrogen elimination.',
  'Vigiar sintomas de retorno da menopausa e considerar ajuste de dose; usar contraceção não hormonal se aplicável.',
  'Watch for return of menopausal symptoms and consider a dose adjustment; use non-hormonal contraception if applicable.',
  'Sintomas vasomotores e padrão de hemorragia.',
  'Vasomotor symptoms and bleeding pattern.',
  'Retorno dos sintomas, hemorragia irregular.',
  'Return of symptoms, irregular bleeding.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'estradiol' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.24 ESTRADIOL + CLARITROMICINA (moderate — inibidores do CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A claritromicina pode aumentar os níveis de estradiol no sangue, com mais efeitos secundários. Informe o médico se notar algo de anormal.',
  'Clarithromycin can increase estradiol levels in the blood, with more side effects. Tell your doctor if you notice anything unusual.',
  'Inibidores do CYP3A4 (claritromicina, eritromicina, cetoconazol, itraconazol, sumo de toranja) aumentam as concentrações de estrogénios, com risco de efeitos adversos dependentes da dose. Monitorizar.',
  'CYP3A4 inhibitors (clarithromycin, erythromycin, ketoconazole, itraconazole, grapefruit juice) increase oestrogen concentrations, with a risk of dose-dependent adverse effects. Monitor.',
  'O rótulo aprovado do estradiol (DailyMed) documenta que inibidores do CYP3A4 — eritromicina, claritromicina, cetoconazol, itraconazol, ritonavir e sumo de toranja — podem aumentar as concentrações plasmáticas de estrogénios e causar efeitos secundários. A claritromicina é um macrólido inibidor potente do CYP3A4; durante a associação, podem surgir náuseas, sensibilidade mamária, retenção de líquidos e alterações do padrão hemorrágico.',
  'The approved estradiol label (DailyMed) documents that CYP3A4 inhibitors — erythromycin, clarithromycin, ketoconazole, itraconazole, ritonavir and grapefruit juice — can increase plasma oestrogen concentrations and cause side effects. Clarithromycin is a macrolide and potent CYP3A4 inhibitor; during the combination, nausea, breast tenderness, fluid retention and changes in the bleeding pattern may occur.',
  'Inibição do CYP3A4 pela claritromicina, reduzindo o metabolismo dos estrogénios.',
  'CYP3A4 inhibition by clarithromycin, reducing oestrogen metabolism.',
  'Vigiar efeitos adversos dependentes da dose durante o antibiótico; considerar ajuste da dose de estradiol se sintomas relevantes.',
  'Watch for dose-dependent adverse effects during the antibiotic; consider an estradiol dose adjustment if symptoms are relevant.',
  'Sintomas de excesso estrogénico: náuseas, mastalgia, edema, hemorragia irregular.',
  'Symptoms of oestrogen excess: nausea, breast pain, oedema, irregular bleeding.',
  'Mastalgia intensa, edema, hemorragia anormal — avaliação médica.',
  'Severe breast pain, oedema, abnormal bleeding — medical evaluation.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; rótulo aprovado Claritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; approved Clarithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'estradiol' AND b.slug = 'claritromicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.25 ESTRADIOL + CETOCONAZOL (moderate — inibidores do CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol pode aumentar os níveis de estradiol e os seus efeitos secundários. Vigie sinais como náuseas, sensibilidade mamária ou inchaço.',
  'Ketoconazole can increase estradiol levels and its side effects. Watch for signs such as nausea, breast tenderness or swelling.',
  'O cetoconazol (inibidor potente do CYP3A4) aumenta as concentrações de estrogénios; monitorizar efeitos dependentes da dose durante a associação.',
  'Ketoconazole (a potent CYP3A4 inhibitor) increases oestrogen concentrations; monitor dose-dependent effects during the combination.',
  'O rótulo aprovado do estradiol (DailyMed) lista o cetoconazol entre os inibidores do CYP3A4 que aumentam as concentrações plasmáticas de estrogénios. O uso sistémico de cetoconazol está hoje restrito, mas a associação pode ocorrer com antifúngicos tópicos de elevada absorção ou em esquemas antigos. Os sinais de excesso estrogénico devem ser vigiados durante o tratamento.',
  'The approved estradiol label (DailyMed) lists ketoconazole among the CYP3A4 inhibitors that increase plasma oestrogen concentrations. Systemic ketoconazole is now restricted, but the combination can occur with highly absorbed topical antifungals or in older regimens. Signs of oestrogen excess should be watched during treatment.',
  'Inibição do CYP3A4, reduzindo o metabolismo dos estrogénios.',
  'CYP3A4 inhibition, reducing oestrogen metabolism.',
  'Vigiar efeitos adversos durante o antifúngico; ajustar a dose de estradiol se necessário.',
  'Watch for adverse effects during the antifungal; adjust the estradiol dose if needed.',
  'Sintomas de excesso estrogénico.',
  'Symptoms of oestrogen excess.',
  'Mastalgia, edema, hemorragia irregular.',
  'Breast pain, oedema, irregular bleeding.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'estradiol' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.26 PREDNISOLONA + RIFAMPICINA (moderate — indução enzimática)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir muito o efeito da prednisolona (e de outros corticosteroides). Pode ser preciso aumentar a dose do corticoide — fale com o médico.',
  'Rifampicin can markedly reduce the effect of prednisolone (and other corticosteroids). The steroid dose may need to be increased — talk to your doctor.',
  'A rifampicina acelera o metabolismo dos corticosteroides (indução do CYP3A4): estudos mostram +45% de clearance da prednisolona. Pode ser necessário aumentar a dose do corticoide com monitorização clínica.',
  'Rifampicin accelerates corticosteroid metabolism (CYP3A4 induction): studies show +45% prednisolone clearance. The steroid dose may need to be increased with clinical monitoring.',
  'A rifampicina induz o CYP3A4 e reduz a biodisponibilidade e o efeito dos corticosteroides sistémicos. Estudos clássicos documentam aumento de 45% da clearance da prednisolona e redução da exposição com rifampicina, com necessidade de doses mais elevadas de corticoide para o mesmo efeito anti-inflamatório/imunossupressor. Esta interação é relevante em doentes com tuberculose (que aliás recebem frequentemente corticosteroides). O Prontuário refere expressamente que a rifampicina acelera o metabolismo dos corticosteroides com redução do efeito terapêutico.',
  'Rifampicin induces CYP3A4 and reduces the bioavailability and effect of systemic corticosteroids. Classic studies document a 45% increase in prednisolone clearance and reduced exposure with rifampicin, requiring higher steroid doses for the same anti-inflammatory/immunosuppressive effect. This interaction is relevant in patients with tuberculosis (who often receive corticosteroids). The Prontuário states explicitly that rifampicin accelerates corticosteroid metabolism with reduced therapeutic effect.',
  'Indução do CYP3A4, acelerando o metabolismo da prednisolona.',
  'CYP3A4 induction, accelerating prednisolone metabolism.',
  'Aumentar a dose do corticoide conforme a resposta clínica durante a rifampicina e reduzi-la quando esta for suspensa; monitorizar sinais de doença de base.',
  'Increase the steroid dose according to clinical response during rifampicin and reduce it when rifampicin is stopped; monitor the underlying disease.',
  'Resposta clínica (sintomas da doença de base); sinais de insuficiência suprarrenal se o corticoide for suspenso abruptamente.',
  'Clinical response (underlying disease symptoms); signs of adrenal insufficiency if the steroid is stopped abruptly.',
  'Perda de controlo da doença inflamatória; crise adrenal com suspensão abrupta.',
  'Loss of control of the inflammatory disease; adrenal crisis with abrupt withdrawal.',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/6403136/ ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2 ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/6403136/ ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2 ; DailyMed/FDA (NIH/NLM) — approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'prednisolona' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.27 PREDNISOLONA + METFORMINA (moderate — hiperglicemia por corticosteroides)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Os corticosteroides (como a prednisolona) podem aumentar o açúcar no sangue e reduzir o efeito da metformina. Vigie a glicemia durante o tratamento.',
  'Corticosteroids (such as prednisolone) can raise blood sugar and reduce the effect of metformin. Monitor blood glucose during treatment.',
  'Os glucocorticoides têm efeito hiperglicemiante e antagonizam os antidiabéticos; pode ser necessário ajustar a dose da metformina (ou acrescentar insulina) durante corticoterapia, com monitorização da glicemia.',
  'Glucocorticoids have a hyperglycaemic effect and antagonise antidiabetics; the metformin dose may need adjustment (or insulin added) during corticosteroid therapy, with blood glucose monitoring.',
  'Os corticosteroides sistémicos aumentam a resistência à insulina e a produção hepática de glucose, antagonizando o efeito dos antidiabéticos — o Prontuário refere expressamente que os antidiabéticos antagonizam os efeitos hiperglicemiantes dos corticosteroides e que nos diabéticos estes só devem ser usados em caso de absoluta necessidade. Em corticoterapia prolongada ou em doses elevadas, a glicemia deve ser monitorizada e a terapêutica antidiabética ajustada (frequentemente é necessário aumentar a dose da metformina ou associar insulina).',
  'Systemic corticosteroids increase insulin resistance and hepatic glucose production, antagonising the effect of antidiabetics — the Prontuário states explicitly that antidiabetics antagonise the hyperglycaemic effects of corticosteroids and that in diabetics these should only be used when strictly necessary. During prolonged or high-dose corticosteroid therapy, blood glucose must be monitored and antidiabetic therapy adjusted (often the metformin dose must be increased or insulin added).',
  'Efeito hiperglicemiante dos glucocorticoides (aumento da resistência à insulina e da gluconeogénese).',
  'Hyperglycaemic effect of glucocorticoids (increased insulin resistance and gluconeogenesis).',
  'Monitorizar a glicemia (e HbA1c em uso prolongado) durante a corticoterapia; ajustar a dose da metformina conforme necessário e reduzir quando o corticoide for suspenso.',
  'Monitor blood glucose (and HbA1c on prolonged use) during corticosteroid therapy; adjust the metformin dose as needed and reduce it when the steroid is stopped.',
  'Glicemia capilar; sintomas de hiperglicemia.',
  'Capillary glucose; symptoms of hyperglycaemia.',
  'Sede, poliúria, fadiga, visão turva — hiperglicemia descompensada.',
  'Thirst, polyuria, fatigue, blurred vision — decompensated hyperglycaemia.',
  'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2 ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 ; rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd',
  'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2 ; DailyMed/FDA (NIH/NLM) — approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 ; approved Metformin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'prednisolona' AND b.slug = 'metformina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.28 GLIBENCLAMIDA + CIPROFLOXACINA (moderate — disglicemia)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A ciprofloxacina pode causar hipoglicemia grave em doentes que tomam glibenclamida. Vigie a glicemia com atenção durante o antibiótico.',
  'Ciprofloxacin can cause severe hypoglycaemia in patients taking glyburide. Monitor blood glucose carefully during the antibiotic.',
  'Casos documentados de hipoglicemia refratária com glibenclamida + ciprofloxacina. Monitorizar glicemia durante o antibiótico e tratar prontamente qualquer hipoglicemia.',
  'Documented cases of refractory hypoglycaemia with glyburide + ciprofloxacin. Monitor blood glucose during the antibiotic and treat any hypoglycaemia promptly.',
  'Existem relatos de caso de hipoglicemia grave e prolongada (refratária à correção) em doentes diabéticos com glibenclamida que iniciaram ciprofloxacina, incluindo níveis séricos elevados de glibenclamida. As fluoroquinolonas interferem com a secreção de insulina; em associação com sulfonilureias, o risco de disglicemia é bem documentado. Recomenda-se monitorização apertada da glicemia durante e após o antibiótico, sobretudo em idosos e doentes com insuficiência renal.',
  'Case reports document severe, prolonged (correction-refractory) hypoglycaemia in diabetic patients on glyburide who started ciprofloxacin, including elevated serum glyburide levels. Fluoroquinolones interfere with insulin secretion; with sulfonylureas, the dysglycaemia risk is well documented. Close blood glucose monitoring is recommended during and after the antibiotic, especially in the elderly and in patients with renal impairment.',
  'Alteração da secreção de insulina pelas fluoroquinolonas, com risco aditivo nas sulfonilureias.',
  'Altered insulin secretion by fluoroquinolones, with additive risk with sulfonylureas.',
  'Reforçar a automonitorização da glicemia; tratar qualquer hipoglicemia de imediato e reavaliar a dose da sulfonilureia.',
  'Reinforce self-monitoring of blood glucose; treat any hypoglycaemia immediately and reassess the sulfonylurea dose.',
  'Glicemia capilar durante o antibiótico.',
  'Capillary glucose during the antibiotic.',
  'Hipoglicemia grave ou prolongada — sudação, confusão, coma.',
  'Severe or prolonged hypoglycaemia — sweating, confusion, coma.',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/10918110/ e https://pubmed.ncbi.nlm.nih.gov/15362597/ ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; rótulo aprovado Ciprofloxacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'PubMed — https://pubmed.ncbi.nlm.nih.gov/10918110/ and https://pubmed.ncbi.nlm.nih.gov/15362597/ ; DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; approved Ciprofloxacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glibenclamida' AND b.slug = 'ciprofloxacina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.29 GLIBENCLAMIDA + ASPIRINA (moderate — salicilatos)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A aspirina em doses elevadas pode aumentar o efeito da glibenclamida e baixar demasiado o açúcar no sangue. Vigie a glicemia.',
  'High-dose aspirin can increase the effect of glyburide and lower blood sugar too much. Monitor blood glucose.',
  'Os salicilatos em doses elevadas potenciam o efeito hipoglicemiante das sulfonilureias (deslocação proteica e efeito hipoglicemiante próprio). Vigiar glicemia; a aspirina em dose antiagregante baixa tem efeito mínimo.',
  'High-dose salicylates potentiate the hypoglycaemic effect of sulfonylureas (protein displacement and an intrinsic hypoglycaemic effect). Monitor blood glucose; low-dose antiplatelet aspirin has a minimal effect.',
  'A SmPC da glimepirida (EMC-UK) e o rótulo da glibenclamida listam os salicilatos entre os fármacos que potenciam o efeito hipoglicemiante das sulfonilureias, por deslocação da ligação às proteínas e por efeito hipoglicemiante próprio em doses elevadas. A aspirina em dose antiagregante (75–100 mg) tem impacto limitado, mas doses analgésicas/anti-inflamatórias exigem vigilância da glicemia.',
  'The glimepiride SmPC (EMC-UK) and the glyburide label list salicylates among the drugs that potentiate the hypoglycaemic effect of sulfonylureas, through displacement from protein binding and an intrinsic hypoglycaemic effect at high doses. Antiplatelet-dose aspirin (75–100 mg) has a limited impact, but analgesic/anti-inflammatory doses require blood glucose monitoring.',
  'Deslocação da ligação proteica e efeito hipoglicemiante próprio dos salicilatos em doses elevadas.',
  'Displacement from protein binding and an intrinsic hypoglycaemic effect of salicylates at high doses.',
  'Vigiar glicemia se doses elevadas de aspirina forem usadas; preferir dose antiagregante baixa se possível.',
  'Monitor blood glucose if high aspirin doses are used; prefer a low antiplatelet dose when possible.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Hipoglicemia — sudação, tremor, confusão.',
  'Hypoglycaemia — sweating, tremor, confusion.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; rótulo aprovado Aspirina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 ; EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 ; EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glibenclamida' AND b.slug = 'aspirina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.30 GLIBENCLAMIDA + IBUPROFENO (moderate — AINEs)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O ibuprofeno pode aumentar o efeito da glibenclamida e baixar demasiado o açúcar no sangue. Vigie a glicemia se tomar os dois.',
  'Ibuprofen can increase the effect of glyburide and lower blood sugar too much. Monitor blood glucose if you take both.',
  'Os AINEs potenciam o efeito hipoglicemiante das sulfonilureias. Vigiar glicemia durante o uso de ibuprofeno, sobretudo em doses elevadas ou uso prolongado.',
  'NSAIDs potentiate the hypoglycaemic effect of sulfonylureas. Monitor blood glucose during ibuprofen use, especially at high doses or with prolonged use.',
  'A SmPC da glimepirida (EMC-UK) inclui os anti-inflamatórios não esteróides entre os fármacos que potenciam o efeito hipoglicemiante das sulfonilureias. O mecanismo envolve deslocação da ligação proteica e inibição do metabolismo. Em doentes diabéticos, o uso de AINEs deve ser acompanhado de monitorização da glicemia, especialmente em cursos prolongados.',
  'The glimepiride SmPC (EMC-UK) includes non-steroidal anti-inflammatory drugs among the drugs that potentiate the hypoglycaemic effect of sulfonylureas. The mechanism involves displacement from protein binding and inhibition of metabolism. In diabetic patients, NSAID use should be accompanied by blood glucose monitoring, especially in prolonged courses.',
  'Deslocação da ligação proteica e inibição do metabolismo da sulfonilureia pelos AINEs.',
  'Displacement from protein binding and inhibition of sulfonylurea metabolism by NSAIDs.',
  'Monitorizar glicemia durante o uso de AINEs; usar a menor dose e duração possíveis.',
  'Monitor blood glucose during NSAID use; use the lowest dose and shortest duration possible.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Hipoglicemia — sudação, tremor, confusão.',
  'Hypoglycaemia — sweating, tremor, confusion.',
  'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glibenclamida' AND b.slug = 'ibuprofeno'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 2.31 GLIBENCLAMIDA + COTRIMOXAZOL (moderate — sulfonamidas)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cotrimoxazol pode potenciar o efeito da glibenclamida e baixar demasiado o açúcar no sangue. Vigie a glicemia durante o antibiótico.',
  'Co-trimoxazole can enhance the effect of glyburide and lower blood sugar too much. Monitor blood glucose during the antibiotic.',
  'As sulfonamidas (sulfametoxazol) potenciam a hipoglicemia das sulfonilureias. Monitorizar glicemia durante o antibiótico; considerar redução da dose da sulfonilureia.',
  'Sulphonamides (sulfamethoxazole) potentiate sulfonylurea hypoglycaemia. Monitor blood glucose during the antibiotic; consider a sulfonylurea dose reduction.',
  'O sulfametoxazol (componente do cotrimoxazol) é uma sulfonamida que potencia o efeito hipoglicemiante das sulfonilureias por deslocação da ligação proteica e inibição do metabolismo — interação clássica e bem documentada (a SmPC da glimepirida lista as sulfonamidas entre os fármacos que potenciam a hipoglicemia). Esta associação é comum (infeções urinárias em diabéticos) e exige vigilância da glicemia.',
  'Sulfamethoxazole (a component of co-trimoxazole) is a sulphonamide that potentiates the hypoglycaemic effect of sulfonylureas through protein displacement and inhibition of metabolism — a classic, well-documented interaction (the glimepiride SmPC lists sulphonamides among the drugs that potentiate hypoglycaemia). This combination is common (urinary infections in diabetics) and requires blood glucose monitoring.',
  'Deslocação proteica e inibição do metabolismo da sulfonilureia pela sulfonamida.',
  'Protein displacement and inhibition of sulfonylurea metabolism by the sulphonamide.',
  'Monitorizar glicemia durante o antibiótico; considerar redução temporária da dose da sulfonilureia.',
  'Monitor blood glucose during the antibiotic; consider a temporary sulfonylurea dose reduction.',
  'Glicemia capilar; sintomas de hipoglicemia.',
  'Capillary glucose; hypoglycaemia symptoms.',
  'Hipoglicemia grave — sudação, confusão, coma.',
  'Severe hypoglycaemia — sweating, confusion, coma.',
  'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; rótulo aprovado Cotrimoxazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; approved Co-trimoxazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0 ; Prontuário Terapêutico do INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'glibenclamida' AND b.slug = 'cotrimoxazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;-- ---------------------------------------------------------------------
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
  ('glimepirida', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool pode potenciar ou enfraquecer o efeito hipoglicemiante da glimepirida de forma imprevisível; o consumo associado a refeições falhadas aumenta o risco de hipoglicemia grave.',
   'Alcohol can potentiate or weaken the hypoglycaemic effect of glimepiride unpredictably; drinking with skipped meals increases the risk of severe hypoglycaemia.',
   'Limitar o consumo de álcool e nunca beber com o estômago vazio; reforçar a automonitorização da glicemia após ingestão de álcool.',
   'Limit alcohol intake and never drink on an empty stomach; reinforce self-monitoring of blood glucose after drinking alcohol.',
   'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc',
   'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc', 1),
  ('glimepirida', 'alimentos', 'Toma com a primeira refeição do dia', 'Intake with the first meal of the day', 'minor',
   'A glimepirida deve ser tomada imediatamente antes ou durante a primeira refeição principal; refeições irregulares ou saltadas aumentam o risco de hipoglicemia.',
   'Glimepiride should be taken immediately before or during the first main meal; irregular or skipped meals increase the risk of hypoglycaemia.',
   'Tomar a glimepirida com a primeira refeição do dia, sempre à mesma hora, e manter refeições regulares.',
   'Take glimepiride with the first meal of the day, always at the same time, and keep regular meals.',
   'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Glimepirida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29',
   'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc ; DailyMed/FDA (NIH/NLM) — approved Glimepiride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29', 2),
  ('gliclazida', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool aumenta a reação hipoglicemiante (ao inibir os mecanismos compensadores) e pode conduzir a coma hipoglicémico.',
   'Alcohol increases the hypoglycaemic reaction (by inhibiting compensatory mechanisms) and can lead to hypoglycaemic coma.',
   'Evitar o consumo de álcool e de medicamentos contendo álcool durante o tratamento com gliclazida.',
   'Avoid alcohol and alcohol-containing medicines during treatment with gliclazide.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc', 1),
  ('gliclazida', 'alimentos', 'Toma com o pequeno-almoço', 'Intake with breakfast', 'minor',
   'A toma com o pequeno-almoço reduz as perturbações gastrintestinais e é importante uma ingestão regular de hidratos de carbono (refeições atrasadas aumentam a hipoglicemia).',
   'Taking with breakfast reduces gastrointestinal disturbances, and regular carbohydrate intake is important (delayed meals increase hypoglycaemia).',
   'Tomar com o pequeno-almoço e manter refeições regulares com aporte adequado de hidratos de carbono.',
   'Take with breakfast and keep regular meals with an adequate carbohydrate intake.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc', 2),
  ('pioglitazona', 'alcool', 'Álcool (intoxicação aguda)', 'Alcohol (acute intoxication)', 'moderate',
   'A intoxicação alcoólica aguda é contraindicação à pioglitazona; o álcool aumenta o risco de acidose metabólica e de hipoglicemia quando associado a secretagogos.',
   'Acute alcohol intoxication is a contraindication to pioglitazone; alcohol increases the risk of metabolic acidosis and of hypoglycaemia when combined with secretagogues.',
   'Evitar a intoxicação alcoólica aguda e o consumo excessivo de álcool durante o tratamento.',
   'Avoid acute alcohol intoxication and excessive alcohol intake during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Pioglitazona: https://www.medicines.org.uk/emc/product/12841/smpc',
   'EMC-UK (MHRA) — approved Pioglitazone SmPC: https://www.medicines.org.uk/emc/product/12841/smpc', 1),
  ('estradiol', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O sumo de toranja inibe o CYP3A4 e pode aumentar as concentrações plasmáticas de estrogénios, com risco de efeitos adversos dependentes da dose.',
   'Grapefruit juice inhibits CYP3A4 and can increase plasma oestrogen concentrations, with a risk of dose-dependent adverse effects.',
   'Evitar grandes quantidades de sumo de toranja durante a terapêutica com estrogénios.',
   'Avoid large amounts of grapefruit juice during oestrogen therapy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef',
   'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef', 1),
  ('glibenclamida', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'A hipoglicemia é mais provável quando o álcool é ingerido (especialmente com jejum ou exercício intenso); o álcool também pode mascarar os sinais de alerta.',
   'Hypoglycaemia is more likely when alcohol is ingested (especially with fasting or strenuous exercise); alcohol can also mask the warning signs.',
   'Evitar o consumo de álcool, sobretudo em jejum; vigiar a glicemia após ingestão.',
   'Avoid alcohol, especially on an empty stomach; monitor blood glucose after intake.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab', 1)
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
  ('tamoxifeno', 'historico_tromboembolismo_venoso', 'Histórico de tromboembolismo venoso (TEV)', 'History of venous thromboembolism (VTE)', 'contraindication', 'critical',
   'O tamoxifeno aumenta 2–3x o risco de TEV; em mulheres com história de trombose venosa profunda ou embolia pulmonar está contraindicado (na indicação de prevenção primária) e exige ponderação cuidada no tratamento.',
   'Tamoxifen increases the risk of VTE 2–3-fold; in women with a history of deep vein thrombosis or pulmonary embolism it is contraindicated (in primary prevention) and requires careful consideration in treatment.',
   'Avaliar história pessoal e familiar de TEV antes de iniciar; se fator pró-trombótico, ponderar rastreio de trombofilia e o risco-benefício; interromper perante suspeita de TEV.',
   'Assess personal and family VTE history before starting; if a prothrombotic factor is present, consider thrombophilia screening and risk-benefit; stop if VTE is suspected.',
   'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc ; Prontuário Terapêutico do INFARMED (11th ed., 2012)', 1),
  ('tamoxifeno', 'doenca_hepatica', 'Doença hepática', 'Liver disease', 'precaution', 'moderate',
   'O tamoxifeno pode causar alterações das enzimas hepáticas, esteatose e, raramente, lesão hepática grave; em doentes com doença hepática prévia, o risco é maior.',
   'Tamoxifen can cause liver enzyme changes, fatty liver and, rarely, severe liver injury; the risk is higher in patients with pre-existing liver disease.',
   'Monitorizar a função hepática no início e periodicamente durante o tratamento; interromper perante evidência de lesão hepática significativa.',
   'Monitor liver function at baseline and periodically during treatment; stop if there is evidence of significant liver injury.',
   'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc',
   'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc', 2),
  ('anastrozol', 'osteoporose', 'Osteoporose', 'Osteoporosis', 'precaution', 'moderate',
   'O anastrozol reduz os estrogénios circulantes e pode causar diminuição da densidade mineral óssea com aumento do risco de fratura.',
   'Anastrozole lowers circulating oestrogens and can cause a decrease in bone mineral density with an increased risk of fracture.',
   'Avaliar a densidade óssea no início e periodicamente em doentes com osteoporose ou risco elevado; considerar bifosfonatos e suplementação de cálcio/vitamina D conforme as orientações.',
   'Assess bone density at baseline and periodically in patients with osteoporosis or high risk; consider bisphosphonates and calcium/vitamin D supplementation according to guidance.',
   'EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc',
   'EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc', 1),
  ('anastrozol', 'doenca_cardiovascular', 'Doença cardiovascular (isquémica)', 'Cardiovascular disease (ischaemic)', 'precaution', 'moderate',
   'Em mulheres com doença cardíaca isquémica pré-existente, o anastrozol associou-se a mais eventos cardiovasculares isquémicos do que o tamoxifeno.',
   'In women with pre-existing ischaemic heart disease, anastrozole was associated with more ischaemic cardiovascular events than tamoxifen.',
   'Ponderar o risco-benefício em doentes com doença cardíaca isquémica; monitorizar sinais e sintomas cardiovasculares.',
   'Weigh risk-benefit in patients with ischaemic heart disease; monitor cardiovascular signs and symptoms.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Anastrozol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=54da5c12-cfaf-7a14-e063-6394a90a3635',
   'DailyMed/FDA (NIH/NLM) — approved Anastrozole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=54da5c12-cfaf-7a14-e063-6394a90a3635', 2),
  ('anastrozol', 'doenca_hepatica', 'Insuficiência hepática', 'Hepatic impairment', 'precaution', 'moderate',
   'A exposição ao anastrozol pode aumentar em doentes com insuficiência hepática moderada a grave; não foi estudado nestas populações.',
   'Anastrozole exposure can increase in patients with moderate to severe hepatic impairment; it has not been studied in these populations.',
   'Usar com precaução na insuficiência hepática moderada/grave, com avaliação do risco-benefício individual.',
   'Use with caution in moderate/severe hepatic impairment, with an individual risk-benefit assessment.',
   'EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc',
   'EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc', 3),
  ('glimepirida', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   'A insuficiência renal eleva os níveis de glimepirida e aumenta o risco de hipoglicemia grave e prolongada.',
   'Renal impairment raises glimepiride levels and increases the risk of severe, prolonged hypoglycaemia.',
   'Iniciar com dose baixa (1 mg) e titular lentamente; monitorizar glicemia; na insuficiência renal grave, mudar para insulina.',
   'Start at a low dose (1 mg) and titrate slowly; monitor blood glucose; in severe renal impairment, switch to insulin.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glimepirida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29 ; EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc',
   'DailyMed/FDA (NIH/NLM) — approved Glimepiride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29 ; EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc', 1),
  ('glimepirida', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'contraindication', 'critical',
   'A insuficiência hepática grave altera a farmacocinética da glimepirida e diminui a capacidade de gluconeogénese, aumentando muito o risco de hipoglicemia; está indicada a mudança para insulina.',
   'Severe hepatic impairment alters glimepiride pharmacokinetics and reduces gluconeogenic capacity, greatly increasing the risk of hypoglycaemia; switching to insulin is indicated.',
   'Não usar glimepirida na insuficiência hepática grave; mudar para insulina.',
   'Do not use glimepiride in severe hepatic impairment; switch to insulin.',
   'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc',
   'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc', 2),
  ('glimepirida', 'deficiencia_g6pd', 'Défice de G6PD', 'G6PD deficiency', 'precaution', 'moderate',
   'As sulfonilureias podem causar anemia hemolítica em doentes com défice de G6PD.',
   'Sulfonylureas can cause haemolytic anaemia in patients with G6PD deficiency.',
   'Considerar uma alternativa não sulfonilureia em doentes com défice de G6PD; vigiar sinais de hemólise se o fármaco for mantido.',
   'Consider a non-sulfonylurea alternative in patients with G6PD deficiency; watch for signs of haemolysis if the drug is kept.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glimepirida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29',
   'DailyMed/FDA (NIH/NLM) — approved Glimepiride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29', 3),
  ('gliclazida', 'insuficiencia_renal_grave', 'Insuficiência renal grave', 'Severe renal impairment', 'contraindication', 'critical',
   'A insuficiência renal grave é contraindicação à gliclazida (recomenda-se insulina); uma hipoglicemia nestes doentes pode ser prolongada.',
   'Severe renal impairment is a contraindication to gliclazide (insulin is recommended); hypoglycaemia in these patients can be prolonged.',
   'Não usar gliclazida na insuficiência renal grave; mudar para insulina.',
   'Do not use gliclazide in severe renal impairment; switch to insulin.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc', 1),
  ('gliclazida', 'insuficiencia_hepatica_grave', 'Insuficiência hepática grave', 'Severe hepatic impairment', 'contraindication', 'critical',
   'A insuficiência hepática grave é contraindicação à gliclazida (recomenda-se insulina); o risco de hipoglicemia prolongada está aumentado.',
   'Severe hepatic impairment is a contraindication to gliclazide (insulin is recommended); the risk of prolonged hypoglycaemia is increased.',
   'Não usar gliclazida na insuficiência hepática grave; mudar para insulina.',
   'Do not use gliclazide in severe hepatic impairment; switch to insulin.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc', 2),
  ('pioglitazona', 'insuficiencia_cardiaca', 'Insuficiência cardíaca', 'Heart failure', 'contraindication', 'critical',
   'A pioglitazona causa retenção de líquidos que pode precipitar ou agravar a insuficiência cardíaca; está contraindicada na IC NYHA III–IV e deve ser usada com precaução na NYHA I–II.',
   'Pioglitazone causes fluid retention that can precipitate or worsen heart failure; it is contraindicated in NYHA III–IV heart failure and should be used with caution in NYHA I–II.',
   'Não iniciar em doentes com IC estabelecida (NYHA III–IV); na NYHA I–II, iniciar com dose baixa e vigiar edema, ganho de peso e dispneia.',
   'Do not start in patients with established heart failure (NYHA III–IV); in NYHA I–II, start at a low dose and watch for oedema, weight gain and dyspnoea.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — SmPC aprovada Pioglitazona: https://www.medicines.org.uk/emc/product/12841/smpc',
   'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — approved Pioglitazone SmPC: https://www.medicines.org.uk/emc/product/12841/smpc', 1),
  ('pioglitazona', 'cancro_bexiga', 'Cancro da bexiga (ativo ou história)', 'Bladder cancer (active or history)', 'contraindication', 'critical',
   'A pioglitazona pode aumentar o risco de cancro da bexiga; não usar em doentes com cancro da bexiga ativo ou com história da doença.',
   'Pioglitazone may increase the risk of bladder cancer; do not use in patients with active bladder cancer or a history of the disease.',
   'Não usar em doentes com cancro da bexiga ativo ou prévio; investigar hematúria macroscópica antes de iniciar e durante o tratamento.',
   'Do not use in patients with active or prior bladder cancer; investigate macroscopic haematuria before starting and during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d',
   'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d', 2),
  ('pioglitazona', 'doenca_hepatica', 'Insuficiência hepática', 'Hepatic impairment', 'contraindication', 'critical',
   'A pioglitazona está contraindicada na insuficiência hepática; foram notificados casos de falência hepática, por vezes fatais.',
   'Pioglitazone is contraindicated in hepatic impairment; cases of hepatic failure, sometimes fatal, have been reported.',
   'Não usar em doentes com insuficiência hepática; avaliar as provas hepáticas antes de iniciar e interromper perante lesão hepática.',
   'Do not use in patients with hepatic impairment; check liver tests before starting and stop if liver injury occurs.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d',
   'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d', 3),
  ('estradiol', 'historico_tromboembolismo_venoso', 'Histórico de tromboembolismo venoso (TEV)', 'History of venous thromboembolism (VTE)', 'contraindication', 'critical',
   'Os estrogénios aumentam o risco de TEV; a história prévia ou atual de trombose venosa profunda ou embolia pulmonar é contraindicação.',
   'Oestrogens increase the risk of VTE; previous or current deep vein thrombosis or pulmonary embolism is a contraindication.',
   'Não usar estrogénios em doentes com TEV prévio ou atual; avaliar fatores de risco trombóticos antes de iniciar.',
   'Do not use oestrogens in patients with previous or current VTE; assess thrombotic risk factors before starting.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; EMC-UK (MHRA) — SmPC aprovada Estradiol: https://www.medicines.org.uk/emc/product/101678/smpc',
   'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; EMC-UK (MHRA) — approved Estradiol SmPC: https://www.medicines.org.uk/emc/product/101678/smpc', 1),
  ('estradiol', 'cancro_mama', 'Cancro da mama (conhecido, suspeito ou história)', 'Breast cancer (known, suspected or history)', 'contraindication', 'critical',
   'Os estrogénios estão contraindicados no cancro da mama conhecido, suspeito ou com história (exceto doentes selecionadas em metastização).',
   'Oestrogens are contraindicated in known, suspected or historical breast cancer (except selected patients with metastatic disease).',
   'Não usar estrogénios em doentes com cancro da mama; antes de iniciar terapêutica hormonal, excluir doença mamária.',
   'Do not use oestrogens in patients with breast cancer; rule out breast disease before starting hormone therapy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef',
   'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef', 2),
  ('estradiol', 'doenca_hepatica', 'Doença hepática (aguda ou história com função não normalizada)', 'Liver disease (acute or history with unnormalised function)', 'contraindication', 'critical',
   'A doença hepática aguda ou a história de doença hepática enquanto as provas não normalizaram é contraindicação aos estrogénios.',
   'Acute liver disease or a history of liver disease while liver tests have not normalised is a contraindication to oestrogens.',
   'Não usar estrogénios em doentes com doença hepática ativa; interromper perante icterícia ou deterioração da função hepática.',
   'Do not use oestrogens in patients with active liver disease; stop if jaundice or deterioration of liver function occurs.',
   'EMC-UK (MHRA) — SmPC aprovada Estradiol: https://www.medicines.org.uk/emc/product/101678/smpc',
   'EMC-UK (MHRA) — approved Estradiol SmPC: https://www.medicines.org.uk/emc/product/101678/smpc', 3),
  ('prednisolona', 'diabetes_mellitus', 'Diabetes mellitus', 'Diabetes mellitus', 'precaution', 'moderate',
   'Os corticosteroides diminuem a tolerância à glucose e a sensibilidade à insulina, podendo descompensar a diabetes.',
   'Corticosteroids decrease glucose tolerance and insulin sensitivity, which can decompensate diabetes.',
   'Nos diabéticos usar apenas em caso de absoluta necessidade; monitorizar a glicemia e ajustar a terapêutica antidiabética durante e após a corticoterapia.',
   'In diabetics use only when strictly necessary; monitor blood glucose and adjust antidiabetic therapy during and after corticosteroid therapy.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2 ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2 ; DailyMed/FDA (NIH/NLM) — approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41', 1),
  ('prednisolona', 'ulcera_peptica', 'Úlcera péptica', 'Peptic ulcer', 'precaution', 'moderate',
   'Os corticosteroides aumentam a secreção ácida e a pepsina e, com os AINEs, o risco de úlcera e hemorragia digestiva.',
   'Corticosteroids increase acid and pepsin secretion and, with NSAIDs, the risk of ulcer and GI bleeding.',
   'Usar com precaução em doentes com úlcera péptica; considerar gastroprotecção e vigiar sinais de hemorragia digestiva.',
   'Use with caution in patients with peptic ulcer; consider gastroprotection and watch for signs of GI bleeding.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2', 2),
  ('prednisolona', 'osteoporose', 'Osteoporose', 'Osteoporosis', 'precaution', 'moderate',
   'Os corticosteroides causam perda óssea e osteoporose, com risco aumentado de fraturas por compressão vertebral e necrose assética.',
   'Corticosteroids cause bone loss and osteoporosis, with an increased risk of vertebral compression fractures and aseptic necrosis.',
   'Na corticoterapia prolongada, avaliar o risco de fratura, considerar suplementação de cálcio/vitamina D e, se indicado, bifosfonatos.',
   'In prolonged corticosteroid therapy, assess fracture risk, consider calcium/vitamin D supplementation and, if indicated, bisphosphonates.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41',
   'DailyMed/FDA (NIH/NLM) — approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41', 3),
  ('prednisolona', 'infeccao_fungica_sistemica', 'Infeção fúngica sistémica', 'Systemic fungal infection', 'contraindication', 'critical',
   'Os corticosteroides estão contraindicados nas infeções fúngicas sistémicas e podem agravar infeções por vários agentes (virais, bacterianas, fúngicas, protozoárias).',
   'Corticosteroids are contraindicated in systemic fungal infections and can worsen infections by several agents (viral, bacterial, fungal, protozoal).',
   'Não usar corticosteroides em infeções fúngicas sistémicas; em terapêutica prolongada, vigiar o aparecimento ou reativação de infeções (incluindo tuberculose latente).',
   'Do not use corticosteroids in systemic fungal infections; during prolonged therapy, watch for the onset or reactivation of infections (including latent tuberculosis).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41',
   'DailyMed/FDA (NIH/NLM) — approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41', 4),
  ('prednisolona', 'epilepsia', 'Epilepsia', 'Epilepsy', 'precaution', 'moderate',
   'Os corticosteroides podem baixar o limiar convulsivo, sobretudo em doentes com epilepsia mal controlada.',
   'Corticosteroids can lower the seizure threshold, especially in patients with poorly controlled epilepsy.',
   'Usar com precaução em doentes epiléticos; vigiar crises convulsivas durante a corticoterapia.',
   'Use with caution in patients with epilepsy; watch for seizures during corticosteroid therapy.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2', 5),
  ('prednisolona', 'hipertensao', 'Hipertensão', 'Hypertension', 'precaution', 'moderate',
   'Os corticosteroides com atividade mineralocorticóide causam retenção de sódio e água, com agravamento da hipertensão e possível ICC.',
   'Corticosteroids with mineralocorticoid activity cause sodium and water retention, worsening hypertension and potentially precipitating heart failure.',
   'Monitorizar a tensão arterial e o peso durante a corticoterapia; ajustar a terapêutica anti-hipertensora se necessário.',
   'Monitor blood pressure and weight during corticosteroid therapy; adjust antihypertensive therapy if needed.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2', 6),
  ('glibenclamida', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   'A insuficiência renal eleva os níveis de glibenclamida e aumenta o risco de hipoglicemia grave; a hipoglicemia pode ser difícil de reconhecer.',
   'Renal impairment raises glyburide levels and increases the risk of severe hypoglycaemia; hypoglycaemia may be difficult to recognise.',
   'Usar com precaução na insuficiência renal, iniciando com dose baixa e monitorizando a glicemia; considerar insulina na insuficiência renal significativa.',
   'Use with caution in renal impairment, starting at a low dose and monitoring blood glucose; consider insulin in significant renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab', 1),
  ('glibenclamida', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment', 'precaution', 'moderate',
   'A insuficiência hepática eleva os níveis de glibenclamida e reduz a capacidade de gluconeogénese, aumentando o risco de hipoglicemia grave.',
   'Hepatic impairment raises glyburide levels and reduces gluconeogenic capacity, increasing the risk of severe hypoglycaemia.',
   'Usar com precaução na insuficiência hepática; monitorizar glicemia e considerar insulina na doença hepática significativa.',
   'Use with caution in hepatic impairment; monitor blood glucose and consider insulin in significant liver disease.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab', 2),
  ('glibenclamida', 'deficiencia_g6pd', 'Défice de G6PD', 'G6PD deficiency', 'precaution', 'moderate',
   'O tratamento de doentes com défice de G6PD com sulfonilureias pode levar a anemia hemolítica.',
   'Treatment of patients with G6PD deficiency with sulfonylureas can lead to haemolytic anaemia.',
   'Considerar uma alternativa não sulfonilureia em doentes com défice de G6PD; vigiar sinais de hemólise.',
   'Consider a non-sulfonylurea alternative in patients with G6PD deficiency; watch for signs of haemolysis.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab', 3)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;-- ---------------------------------------------------------------------
-- 5. Gestação / Lactação (drug_pregnancy_info, 1:1)
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
  ('tamoxifeno', 'contraindicated',
   'O tamoxifeno está contraindicado na gravidez; há relatos de abortos espontâneos, defeitos congénitos e morte fetal após exposição.',
   'Tamoxifen is contraindicated in pregnancy; spontaneous abortions, birth defects and fetal deaths have been reported after exposure.',
   'Não administrar em qualquer trimestre; as mulheres devem usar contraceção não hormonal durante o tratamento e até 9 meses após a sua suspensão.',
   'Do not administer in any trimester; women must use non-hormonal contraception during treatment and for up to 9 months after stopping.',
   'O tamoxifeno e os seus metabolitos ativos são excretados no leite e acumulam-se; não é recomendado durante a amamentação.',
   'Tamoxifen and its active metabolites are excreted into milk and accumulate; it is not recommended during breastfeeding.',
   'Contraceção não hormonal obrigatória (barreira) durante o tratamento e até 9 meses após a suspensão.',
   'Non-hormonal contraception (barrier) is mandatory during treatment and up to 9 months after stopping.',
   'EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc',
   'EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc'),

  ('anastrozol', 'contraindicated',
   'O anastrozol está contraindicado na gravidez; os estudos em animais mostraram toxicidade reprodutiva e não há dados em humanos.',
   'Anastrozole is contraindicated in pregnancy; animal studies have shown reproductive toxicity and there are no human data.',
   'Não administrar em qualquer trimestre; antes de iniciar, excluir gravidez e usar contraceção eficaz.',
   'Do not administer in any trimester; before starting, rule out pregnancy and use effective contraception.',
   'Contraindicado na amamentação por ausência de dados sobre a excreção no leite.',
   'Contraindicated during breastfeeding due to the lack of data on excretion into milk.',
   'Usar contraceção eficaz; o anastrozol não é indicado em mulheres pré-menopáusicas.',
   'Use effective contraception; anastrozole is not indicated in premenopausal women.',
   'EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc',
   'EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc'),

  ('tiamazol', 'caution',
   'O tiamazol atravessa a placenta e pode causar malformações congénitas no 1.º trimestre (aplasia cutis, malformações craniofaciais e gastrintestinais, onfalocele).',
   'Methimazole crosses the placenta and can cause congenital malformations in the 1st trimester (aplasia cutis, craniofacial and GI malformations, omphalocele).',
   'Evitar no 1.º trimestre (preferir propiltiouracilo nesse período); usar a dose mínima eficaz e monitorizar a função tiroideia materna e fetal.',
   'Avoid in the 1st trimester (prefer propylthiouracil in that period); use the lowest effective dose and monitor maternal and fetal thyroid function.',
   'O tiamazol é excretado no leite em pequenas quantidades; estudos não mostraram toxicidade no lactente, mas a função tiroideia do lactente deve ser monitorizada.',
   'Methimazole is excreted into milk in small amounts; studies have shown no toxicity in the infant, but the infant''s thyroid function should be monitored.',
   'Sem necessidade específica além da monitorização habitual; o hipertiroidismo não tratado na gravidez é prejudicial para a mãe e o feto.',
   'No specific need beyond routine monitoring; untreated hyperthyroidism in pregnancy is harmful to both mother and fetus.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tiamazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5',
   'DailyMed/FDA (NIH/NLM) — approved Methimazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5'),

  ('glimepirida', 'contraindicated',
   'A glimepirida não deve ser usada durante a gravidez; a insulina é o fármaco de primeira linha no controlo da diabetes na gravidez.',
   'Glimepiride should not be used during pregnancy; insulin is the first-line drug for glycaemic control in pregnancy.',
   'Não usar em qualquer trimestre; se a gravidez for planeada ou detetada, mudar para insulina o mais cedo possível.',
   'Do not use in any trimester; if pregnancy is planned or detected, switch to insulin as early as possible.',
   'Como outras sulfonilureias, é excretada no leite e há risco de hipoglicemia no lactente — a amamentação não é recomendada durante o tratamento.',
   'Like other sulfonylureas, it is excreted into milk and there is a risk of hypoglycaemia in the infant — breastfeeding is not recommended during treatment.',
   'Sem dados específicos; a contraceção é recomendada se não houver desejo de gravidez, com planeamento da transição para insulina.',
   'No specific data; contraception is recommended if pregnancy is not desired, with planned transition to insulin.',
   'EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc',
   'EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc'),

  ('gliclazida', 'contraindicated',
   'Os antidiabéticos orais não são adequados na gravidez; a insulina é o fármaco de primeira escolha e a gliclazida deve ser substituída antes da conceção ou logo que a gravidez seja detetada.',
   'Oral antidiabetics are not suitable in pregnancy; insulin is the first-choice drug and gliclazide should be replaced before conception or as soon as pregnancy is detected.',
   'Não usar em qualquer trimestre; mudar para insulina antes da gravidez planeada ou assim que a gravidez seja descoberta.',
   'Do not use in any trimester; switch to insulin before a planned pregnancy or as soon as pregnancy is discovered.',
   'Desconhecida a excreção no leite; contraindicada na amamentação pelo risco de hipoglicemia neonatal.',
   'Excretion into milk is unknown; contraindicated during breastfeeding due to the risk of neonatal hypoglycaemia.',
   'Sem dados específicos; planeamento da gravidez com transição para insulina.',
   'No specific data; pregnancy planning with transition to insulin.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc'),

  ('pioglitazona', 'contraindicated',
   'A pioglitazona não deve ser usada na gravidez (dados inadequados em humanos; toxicidade fetossomática em animais).',
   'Pioglitazone should not be used in pregnancy (inadequate human data; foetotoxicity in animals).',
   'Não usar em qualquer trimestre; se ocorrer gravidez, suspender o tratamento.',
   'Do not use in any trimester; if pregnancy occurs, stop treatment.',
   'Não usar na amamentação (presença no leite em animais; desconhecido em humanos).',
   'Do not use during breastfeeding (present in milk in animals; unknown in humans).',
   'Não recomendado em mulheres em idade fértil sem contraceção eficaz; se desejar gravidez, suspender e mudar para insulina/metformina conforme orientação.',
   'Not recommended in women of childbearing potential without effective contraception; if pregnancy is desired, stop and switch to insulin/metformin as guided.',
   'EMC-UK (MHRA) — SmPC aprovada Pioglitazona: https://www.medicines.org.uk/emc/product/12841/smpc',
   'EMC-UK (MHRA) — approved Pioglitazone SmPC: https://www.medicines.org.uk/emc/product/12841/smpc'),

  ('levonorgestrel', 'caution',
   'A contraceção de emergência com levonorgestrel não é teratogénica (dados extensos não mostram aumento do risco de malformações), mas não deve ser usada como método regular.',
   'Emergency contraception with levonorgestrel is not teratogenic (extensive data show no increase in malformation risk), but it must not be used as a regular method.',
   'Não usar se a gravidez já estiver confirmada (não será eficaz); em gravidez inadvertida após uso, não há indicação para interromper a gravidez.',
   'Do not use if pregnancy is already confirmed (it will not be effective); after inadvertent use in pregnancy, there is no indication to terminate.',
   'O levonorgestrel é excretado no leite em pequenas quantidades; pode usar-se na amamentação como contraceção de emergência.',
   'Levonorgestrel is excreted into milk in small amounts; it can be used during breastfeeding for emergency contraception.',
   'Uso pontual como contraceção de emergência; não substitui a contraceção regular.',
   'Occasional use as emergency contraception; it does not replace regular contraception.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4',
   'DailyMed/FDA (NIH/NLM) — approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4'),

  ('estradiol', 'contraindicated',
   'O estradiol não é indicado na gravidez; os estudos epidemiológicos não indicaram efeito teratogénico com exposição inadvertida, mas o fármaco não deve ser usado.',
   'Estradiol is not indicated in pregnancy; epidemiological studies have not indicated a teratogenic effect with inadvertent exposure, but the drug must not be used.',
   'Suspender imediatamente se ocorrer gravidez durante o tratamento; não usar em qualquer trimestre.',
   'Stop immediately if pregnancy occurs during treatment; do not use in any trimester.',
   'Os estrogénios reduzem a produção de leite; a terapêutica hormonal não é indicada durante a amamentação.',
   'Oestrogens reduce milk production; hormone therapy is not indicated during breastfeeding.',
   'Em mulheres em idade fértil, usar contraceção eficaz se a terapêutica hormonal for iniciada (habitualmente pré-menopausa excluída).',
   'In women of childbearing age, use effective contraception if hormone therapy is started (usually premenopause is excluded).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef',
   'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef'),

  ('prednisolona', 'caution',
   'Os corticosteroides atravessam a placenta; a exposição no 1.º trimestre associa-se a um ligeiro aumento do risco de fenda palatina.',
   'Corticosteroids cross the placenta; first-trimester exposure is associated with a slight increase in the risk of cleft palate.',
   'Usar apenas se o benefício exceder claramente o risco, na dose mínima eficaz e com monitorização materna e fetal (crescimento, glicemia, tensão arterial).',
   'Use only if benefit clearly outweighs risk, at the lowest effective dose and with maternal and fetal monitoring (growth, blood glucose, blood pressure).',
   'As doses baixas/moderadas são geralmente compatíveis com a amamentação (excreção mínima no leite); doses elevadas devem ser espaçadas da mamada.',
   'Low/moderate doses are generally compatible with breastfeeding (minimal excretion into milk); high doses should be spaced from feeds.',
   'Sem necessidade específica além da monitorização habitual da corticoterapia.',
   'No specific need beyond the routine monitoring of corticosteroid therapy.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — secção 8.2.2',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — section 8.2.2'),

  ('glibenclamida', 'caution',
   'As sulfonilureias atravessam a placenta; a insulina é o fármaco de primeira linha na gravidez, mas a glibenclamida tem sido usada em alguns protocolos com monitorização.',
   'Sulfonylureas cross the placenta; insulin is the first-line drug in pregnancy, but glyburide has been used in some protocols with monitoring.',
   'Preferir insulina; se a glibenclamida for mantida (protocolos selecionados), monitorizar a glicemia materna e o crescimento fetal.',
   'Prefer insulin; if glyburide is kept (selected protocols), monitor maternal glucose and fetal growth.',
   'Há risco de hipoglicemia no lactente; usar com precaução na amamentação e monitorizar o lactente.',
   'There is a risk of hypoglycaemia in the infant; use with caution during breastfeeding and monitor the infant.',
   'Sem dados específicos; planeamento da gravidez com transição para insulina conforme orientação.',
   'No specific data; pregnancy planning with transition to insulin as guided.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;-- ---------------------------------------------------------------------
-- 6. Perfis de fármaco (drug_profiles) — 8 novos + 2 completados
--    (prednisolona, glibenclamida — fármacos já existentes sem perfil)
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
  ('tiamazol',
   'O tiamazol é um medicamento usado no tratamento do hipertiroidismo (produção excessiva de hormonas da tiróide), como na doença de Graves. É tomado por via oral, uma a três vezes por dia, e o efeito completo demora várias semanas.',
   'Methimazole is a medicine used to treat hyperthyroidism (overproduction of thyroid hormones), such as in Graves'' disease. It is taken orally, one to three times a day, and the full effect takes several weeks.',
   'Tionamida antitiroideia; inibe a síntese de hormonas tiroideias. Indicada no hipertiroidismo (doença de Graves, bócio multinodular tóxico) quando a cirurgia ou o iodo radioativo não são opção, e na preparação para tiroidectomia. Riscos graves: agranulocitose (febre/odinofagia exigem hemograma imediato) e hepatotoxicidade. Evitar no 1.º trimestre de gravidez.',
   'Antithyroid thionamide; inhibits thyroid hormone synthesis. Indicated in hyperthyroidism (Graves'' disease, toxic multinodular goitre) when surgery or radioactive iodine is not an option, and in preparation for thyroidectomy. Serious risks: agranulocytosis (fever/sore throat require an immediate blood count) and hepatotoxicity. Avoid in the 1st trimester of pregnancy.',
   E'Hipertiroidismo (doença de Graves, bócio multinodular tóxico) quando a cirurgia ou o iodo radioativo não são opção.\\nPreparação para tiroidectomia ou iodo radioativo (alívio dos sintomas do hipertiroidismo).',
   E'Hyperthyroidism (Graves'' disease, toxic multinodular goitre) when surgery or radioactive iodine is not an option.\\nPreparation for thyroidectomy or radioactive iodine (relief of hyperthyroidism symptoms).',
   E'Náuseas, perturbações gastrintestinais ligeiras e erupção cutânea com comichão (as mais frequentes).\\nDor de cabeça, tonturas e dores articulares.\\nRaramente mas grave: agranulocitose (febre, dor de garganta — procurar ajuda imediata), lesão hepática e vasculite.\\nPode causar perda de paladar, geralmente reversível.',
   E'Nausea, mild GI disturbances and itchy rash (most common).\\nHeadache, dizziness and joint pain.\\nRarely but serious: agranulocytosis (fever, sore throat — seek immediate help), liver injury and vasculitis.\\nMay cause taste loss, usually reversible.',
   E'Procure ajuda médica imediata se tiver febre, dor de garganta ou mal-estar súbito (possível agranulocitose — não espere por consulta).\\nInforme o médico se tiver doença hepática ou se ficar grávida (evitar no 1.º trimestre).\\nNão suspenda o tratamento sem orientação; o ajuste é feito com análises da tiróide.\\nComunique imediatamente erupção cutânea, icterícia, urina escura ou dores abdominais.',
   E'Seek immediate medical help if you have fever, sore throat or sudden malaise (possible agranulocytosis — do not wait for an appointment).\\nTell your doctor if you have liver disease or become pregnant (avoid in the 1st trimester).\\nDo not stop treatment without guidance; adjustment is done with thyroid tests.\\nReport immediately any rash, jaundice, dark urine or abdominal pain.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tiamazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Methimazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b53f84ac-4263-478c-883d-aca7ab44fef5 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('glimepirida',
   'A glimepirida é um medicamento oral usado no tratamento da diabetes tipo 2, para baixar o açúcar no sangue. É tomada uma vez por dia, com a primeira refeição. O efeito secundário mais importante é a hipoglicemia (açúcar demasiado baixo).',
   'Glimepiride is an oral medicine used to treat type 2 diabetes, to lower blood sugar. It is taken once a day with the first meal. The most important side effect is hypoglycaemia (blood sugar too low).',
   'Sulfonilureia de segunda geração; estimula a secreção de insulina pelas células beta. Indicada como adjuvante da dieta e exercício na diabetes tipo 2. Metabolizada pelo CYP2C9 (fluconazol aumenta ~2x a exposição). Risco principal: hipoglicemia grave, sobretudo em idosos, insuficiência renal e com álcool. Contraindicada na diabetes tipo 1 e na cetoadidose.',
   'Second-generation sulfonylurea; stimulates insulin secretion from beta cells. Indicated as an adjunct to diet and exercise in type 2 diabetes. Metabolised by CYP2C9 (fluconazole increases exposure ~2-fold). Main risk: severe hypoglycaemia, especially in the elderly, renal impairment and with alcohol. Contraindicated in type 1 diabetes and ketoacidosis.',
   E'Diabetes mellitus tipo 2, como adjuvante da dieta e do exercício, em monoterapia ou em associação com outros antidiabéticos.\\nNão indicada na diabetes tipo 1 nem na cetoadidose diabética.',
   E'Type 2 diabetes mellitus, as an adjunct to diet and exercise, as monotherapy or combined with other antidiabetics.\\nNot indicated in type 1 diabetes or diabetic ketoacidosis.',
   E'Hipoglicemia (açúcar no sangue demasiado baixo) — o efeito secundário mais importante.\\nDor de cabeça, náuseas e tonturas.\\nGanho de peso ligeiro.\\nRaramente: reações alérgicas graves, anemia hemolítica (défice de G6PD) e alterações do sangue.',
   E'Hypoglycaemia (blood sugar too low) — the most important side effect.\\nHeadache, nausea and dizziness.\\nSlight weight gain.\\nRarely: severe allergic reactions, haemolytic anaemia (G6PD deficiency) and blood disorders.',
   E'Tome com a primeira refeição do dia, sempre à mesma hora, e nunca salte refeições.\\nAprenda a reconhecer e tratar a hipoglicemia (sudorese, tremor, fome, confusão) — leve sempre açúcar consigo.\\nEvite o álcool, sobretudo em jejum.\\nInforme o médico se tem doença renal ou hepática; na insuficiência grave está indicada a insulina.',
   E'Take with the first meal of the day, always at the same time, and never skip meals.\\nLearn to recognise and treat hypoglycaemia (sweating, tremor, hunger, confusion) — always carry sugar with you.\\nAvoid alcohol, especially on an empty stomach.\\nTell your doctor if you have kidney or liver disease; in severe impairment, insulin is indicated.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glimepirida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29 ; EMC-UK (MHRA) — SmPC aprovada Glimepirida: https://www.medicines.org.uk/emc/product/10742/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Glimepiride label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fc9d8495-184c-3af1-e053-6394a90a5e29 ; EMC-UK (MHRA) — approved Glimepiride SmPC: https://www.medicines.org.uk/emc/product/10742/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('gliclazida',
   'A gliclazida é um medicamento oral usado no tratamento da diabetes tipo 2, para baixar o açúcar no sangue. É tomada com o pequeno-almoço. O efeito secundário mais importante é a hipoglicemia.',
   'Gliclazide is an oral medicine used to treat type 2 diabetes, to lower blood sugar. It is taken with breakfast. The most important side effect is hypoglycaemia.',
   'Sulfonilureia; estimula a secreção de insulina. Indicada na diabetes tipo 2 como adjuvante da dieta e exercício. Evitar com miconazol (contraindicado) e com cautela com fluconazol, claritromicina, AINEs, fluoroquinolonas (disglicemia) e álcool. Contraindicada na diabetes tipo 1, cetoadidose e insuficiência renal/ hepática grave.',
   'Sulfonylurea; stimulates insulin secretion. Indicated in type 2 diabetes as an adjunct to diet and exercise. Avoid with miconazole (contraindicated) and with caution with fluconazole, clarithromycin, NSAIDs, fluoroquinolones (dysglycaemia) and alcohol. Contraindicated in type 1 diabetes, ketoacidosis and severe renal/hepatic impairment.',
   E'Diabetes mellitus tipo 2, como adjuvante da dieta e do exercício, quando o controlo com estes não é suficiente.',
   E'Type 2 diabetes mellitus, as an adjunct to diet and exercise, when control with these alone is insufficient.',
   E'Hipoglicemia (açúcar no sangue demasiado baixo) — o efeito secundário mais importante.\\nPerturbações digestivas (náuseas, dor abdominal, diarreia) — melhoram com a toma às refeições.\\nRaramente: erupção cutânea, alterações do sangue e alterações hepáticas.',
   E'Hypoglycaemia (blood sugar too low) — the most important side effect.\\nDigestive disturbances (nausea, abdominal pain, diarrhoea) — improve when taken with meals.\\nRarely: skin rash, blood disorders and liver changes.',
   E'Tome com o pequeno-almoço e mantenha refeições regulares.\\nAprenda a reconhecer e tratar a hipoglicemia — leve sempre açúcar consigo.\\nEvite o álcool (pode causar hipoglicemia grave).\\nInforme o médico se tem doença renal ou hepática grave; não use em caso de alergia a sulfonamidas.',
   E'Take with breakfast and keep regular meals.\\nLearn to recognise and treat hypoglycaemia — always carry sugar with you.\\nAvoid alcohol (it can cause severe hypoglycaemia).\\nTell your doctor if you have severe kidney or liver disease; do not use if you are allergic to sulphonamides.',
   'EMC-UK (MHRA) — SmPC aprovada Gliclazida: https://www.medicines.org.uk/emc/product/1321/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'EMC-UK (MHRA) — approved Gliclazide SmPC: https://www.medicines.org.uk/emc/product/1321/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('pioglitazona',
   'A pioglitazona é um medicamento oral usado no tratamento da diabetes tipo 2, que ajuda o organismo a usar melhor a insulina. É tomada uma vez por dia, com ou sem alimentos.',
   'Pioglitazone is an oral medicine used to treat type 2 diabetes, which helps the body use insulin better. It is taken once a day, with or without food.',
   'Tiazolidinediona (agonista PPAR-gama); sensibilizador da insulina. Indicada na diabetes tipo 2, em monoterapia ou associação. Contraindicada na IC (NYHA III–IV), cancro da bexiga (ativo/história) e insuficiência hepática. Retenção de líquidos/edema e risco de fratura em mulheres. Metabolizada pelo CYP2C8 (gemfibrozil aumenta, rifampicina reduz a exposição).',
   'Thiazolidinedione (PPAR-gamma agonist); insulin sensitiser. Indicated in type 2 diabetes, as monotherapy or in combination. Contraindicated in heart failure (NYHA III–IV), bladder cancer (active/history) and hepatic impairment. Fluid retention/oedema and fracture risk in women. Metabolised by CYP2C8 (gemfibrozil increases, rifampicin reduces exposure).',
   E'Diabetes mellitus tipo 2, em monoterapia ou em associação com metformina, sulfonilureias ou insulina (sob orientação médica).',
   E'Type 2 diabetes mellitus, as monotherapy or combined with metformin, sulfonylureas or insulin (under medical guidance).',
   E'Infeções das vias respiratórias superiores, dor de cabeça e dores musculares.\\nEdema (inchaço dos pés/ tornozelos) e ganho de peso — retenção de líquidos.\\nAumento do risco de fraturas em mulheres.\\nRaramente: insuficiência cardíaca e doença hepática.\\nProcure ajuda se tiver inchaço súbito, falta de ar ou cansaço ao esforço.',
   E'Upper respiratory infections, headache and muscle pain.\\nOedema (swelling of the feet/ankles) and weight gain — fluid retention.\\nIncreased fracture risk in women.\\nRarely: heart failure and liver disease.\\nSeek help if you have sudden swelling, shortness of breath or fatigue on exertion.',
   E'Não use se tem insuficiência cardíaca, doença hepática ou cancro da bexiga (ativo ou prévio).\\nAvise o médico sobre inchaço, ganho de peso súbito, falta de ar ou urina com sangue.\\nEm mulheres, avaliar o risco de fratura (osteoporose).\\nCom insulina ou sulfonilureias, o risco de hipoglicemia aumenta.',
   E'Do not use if you have heart failure, liver disease or bladder cancer (active or previous).\\nTell your doctor about swelling, sudden weight gain, shortness of breath or blood in the urine.\\nIn women, assess the fracture risk (osteoporosis).\\nWith insulin or sulfonylureas, the risk of hypoglycaemia increases.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pioglitazona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — SmPC aprovada Pioglitazona: https://www.medicines.org.uk/emc/product/12841/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Pioglitazone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=31619517-a590-408a-ae9e-76c99f0a0a1d ; EMC-UK (MHRA) — approved Pioglitazone SmPC: https://www.medicines.org.uk/emc/product/12841/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('levonorgestrel',
   'O levonorgestrel é uma hormona (progestagénio) usada na contraceção de emergência (a “pílula do dia seguinte”) e em vários métodos contracetivos hormonais. Na contraceção de emergência, deve ser tomado o mais cedo possível após a relação sexual desprotegida.',
   'Levonorgestrel is a hormone (progestogen) used for emergency contraception (the “morning-after pill”) and in several hormonal contraceptive methods. For emergency contraception, it should be taken as soon as possible after unprotected sex.',
   'Progestagénio de segunda geração. Usado na contraceção de emergência (1,5 mg até 72 h; idealmente <24 h) e em contraceção hormonal combinada e só-progestagénio. A eficácia da contraceção de emergência é reduzida por indutores enzimáticos (carbamazepina, fenitoína, rifampicina, efavirenz, hipericão) — nesses casos preferir DIU de cobre.',
   'Second-generation progestogen. Used for emergency contraception (1.5 mg within 72 h; ideally <24 h) and in combined and progestogen-only hormonal contraception. Emergency contraception efficacy is reduced by enzyme inducers (carbamazepine, phenytoin, rifampicin, efavirenz, St John''s wort) — in these cases prefer the copper IUD.',
   E'Contraceção de emergência após relação sexual desprotegida ou falha do método contracetivo (até 72 horas; quanto mais cedo, mais eficaz).\\nComponente de contraceção hormonal combinada e só-progestagénio.',
   E'Emergency contraception after unprotected sex or contraceptive method failure (within 72 hours; the earlier, the more effective).\\nComponent of combined and progestogen-only hormonal contraception.',
   E'Alterações menstruais (hemorragia irregular ou antecipação do período).\\nNáuseas, dor abdominal, cansaço, dor de cabeça, sensibilidade mamária, tonturas e vómitos.\\nSe vomitar até 2 horas após a toma, contacte o profissional de saúde (pode ser necessário repetir a dose).',
   E'Menstrual changes (irregular bleeding or an earlier period).\\nNausea, abdominal pain, tiredness, headache, breast tenderness, dizziness and vomiting.\\nIf you vomit within 2 hours of taking it, contact a healthcare professional (the dose may need repeating).',
   E'Não use se já estiver grávida (não será eficaz) nem como contraceção regular.\\nNão protege contra VIH/SIDA nem outras infeções sexualmente transmissíveis.\\nSe toma medicamentos para epilepsia, rifampicina ou efavirenz, a eficácia pode estar reduzida — fale com o médico ou farmacêutico.',
   E'Do not use if you are already pregnant (it will not be effective) nor as regular contraception.\\nIt does not protect against HIV/AIDS or other sexually transmitted infections.\\nIf you take seizure medicines, rifampicin or efavirenz, effectiveness may be reduced — talk to your doctor or pharmacist.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('estradiol',
   'O estradiol é uma hormona (estrogénio) usada na terapêutica hormonal de substituição para aliviar os sintomas da menopausa, como afrontamentos. Está disponível em comprimidos, adesivos, géis e cremes.',
   'Estradiol is a hormone (oestrogen) used in hormone replacement therapy to relieve menopausal symptoms such as hot flushes. It is available as tablets, patches, gels and creams.',
   'Estrogénio natural (17-beta-estradiol). Usado na terapêutica hormonal de substituição (THS) da menopausa; em mulheres com útero, associar progestagénio para proteção endometrial. Contraindicado em TEV, doença tromboembólica arterial, cancro da mama e doença hepática. Interage com indutores (carbamazepina, rifampicina) e inibidores (claritromicina, cetoconazol) do CYP3A4.',
   'Natural oestrogen (17-beta-estradiol). Used in menopausal hormone replacement therapy (HRT); in women with a uterus, a progestogen must be added for endometrial protection. Contraindicated in VTE, arterial thromboembolic disease, breast cancer and liver disease. Interacts with CYP3A4 inducers (carbamazepine, rifampicin) and inhibitors (clarithromycin, ketoconazole).',
   E'Sintomas vasomotores da menopausa (afrontamentos, sudação noturna).\\nPrevenção da osteoporose pós-menopausa (após avaliação de alternativas).\\nAtrofia vulvovaginal (cremes/ óvulos).',
   E'Menopausal vasomotor symptoms (hot flushes, night sweats).\\nPrevention of postmenopausal osteoporosis (after assessment of alternatives).\\nVulvovaginal atrophy (creams/pessaries).',
   E'Sensibilidade mamária, náuseas e dor de cabeça (as mais frequentes, sobretudo no início).\\nHemorragia irregular ou manchas (spotting).\\nRetenção de líquidos e inchaço.\\nRiscos com uso prolongado: cancro da mama, TEV e eventos cardiovasculares — reavaliar anualmente com o médico.',
   E'Breast tenderness, nausea and headache (most common, especially at the start).\\nIrregular bleeding or spotting.\\nFluid retention and swelling.\\nRisks with prolonged use: breast cancer, VTE and cardiovascular events — reassess annually with your doctor.',
   E'Use a menor dose eficaz e durante o menor tempo possível; reavaliar anualmente.\\nProcure ajuda imediata para dor no peito, falta de ar, tosse com sangue, dor ou inchaço numa perna (possível coágulo).\\nNão use se tem história de trombose, cancro da mama ou doença hepática.\\nEm mulheres com útero, a associação com progestagénio é obrigatória.',
   E'Use the lowest effective dose for the shortest time possible; reassess annually.\\nSeek immediate help for chest pain, shortness of breath, coughing blood, or pain/swelling in one leg (possible clot).\\nDo not use if you have a history of thrombosis, breast cancer or liver disease.\\nIn women with a uterus, the combination with a progestogen is mandatory.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Estradiol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; EMC-UK (MHRA) — SmPC aprovada (estradiol+drospirenona): https://www.medicines.org.uk/emc/product/101678/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Estradiol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5718f042-e8c0-b721-e063-6294a90a5bef ; EMC-UK (MHRA) — approved SmPC (estradiol+drospirenone): https://www.medicines.org.uk/emc/product/101678/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('tamoxifeno',
   'O tamoxifeno é um medicamento usado no tratamento do cancro da mama com recetores hormonais positivos, e na prevenção em mulheres de alto risco. É tomado por via oral, geralmente 20 mg por dia, durante 5 anos.',
   'Tamoxifen is a medicine used to treat hormone-receptor-positive breast cancer, and for prevention in high-risk women. It is taken orally, usually 20 mg a day, for 5 years.',
   'Modulador seletivo do recetor de estrogénio (SERM) com ação antiestrogénica na mama. Adjuvante e metastático no cancro da mama RE-positivo, e na redução de risco em mulheres de alto risco. Pró-fármaco ativado pelo CYP2D6 (evitar fluoxetina/paroxetina). Aumenta o risco de TEV, cancro do endométrio e catarata; potencia anticoagulantes cumarínicos.',
   'Selective oestrogen receptor modulator (SERM) with anti-oestrogenic action in the breast. Adjuvant and metastatic use in ER-positive breast cancer, and risk reduction in high-risk women. Prodrug activated by CYP2D6 (avoid fluoxetine/paroxetine). Increases the risk of VTE, endometrial cancer and cataract; potentiates coumarin anticoagulants.',
   E'Tratamento adjuvante do cancro da mama com recetores hormonais positivos.\\nCancro da mama metastático (RE-positivo).\\nRedução do risco de cancro da mama em mulheres de alto risco (avaliação especializada).',
   E'Adjuvant treatment of hormone-receptor-positive breast cancer.\\nMetastatic breast cancer (ER-positive).\\nBreast cancer risk reduction in high-risk women (specialist assessment).',
   E'Afrontamentos, sudação noturna e fadiga (as mais frequentes).\\nHemorragias ou corrimento vaginal, irregularidade menstrual.\\nNáuseas e alterações digestivas.\\nRiscos: coágulos sanguíneos (TEV), cancro do endométrio e cataratas — procure ajuda perante dor/inchaço numa perna, falta de ar ou hemorragia vaginal anormal.',
   E'Hot flushes, night sweats and fatigue (most common).\\nVaginal bleeding or discharge, menstrual irregularity.\\nNausea and digestive changes.\\nRisks: blood clots (VTE), endometrial cancer and cataracts — seek help for leg pain/swelling, shortness of breath or abnormal vaginal bleeding.',
   E'Não use se está grávida ou planeia engravidar — use contraceção não hormonal durante e até 9 meses após o tratamento.\\nInforme o médico se toma anticoagulantes, ISRS (fluoxetina, paroxetina, sertralina) ou rifampicina.\\nComunique qualquer hemorragia vaginal anormal, dor ou inchaço numa perna, ou alterações visuais.',
   E'Do not use if you are pregnant or planning pregnancy — use non-hormonal contraception during and up to 9 months after treatment.\\nTell your doctor if you take anticoagulants, SSRIs (fluoxetine, paroxetine, sertraline) or rifampicin.\\nReport any abnormal vaginal bleeding, leg pain or swelling, or visual changes.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tamoxifeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; EMC-UK (MHRA) — SmPC aprovada Tamoxifeno: https://www.medicines.org.uk/emc/product/101398/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Tamoxifen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=509f8ba3-214d-aec8-e063-6294a90af498 ; EMC-UK (MHRA) — approved Tamoxifen SmPC: https://www.medicines.org.uk/emc/product/101398/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('anastrozol',
   'O anastrozol é um medicamento usado no tratamento do cancro da mama com recetores hormonais positivos em mulheres após a menopausa. Atua reduzindo a produção de estrogénio no organismo. É tomado por via oral, um comprimido por dia.',
   'Anastrozole is a medicine used to treat hormone-receptor-positive breast cancer in postmenopausal women. It works by reducing oestrogen production in the body. It is taken orally, one tablet a day.',
   'Inibidor não esteróide da aromatase; reduz a produção periférica de estrogénios. Adjuvante e primeira linha no cancro da mama RE-positivo pós-menopausa. Não usar em pré-menopausa nem com tamoxifeno ou estrogénios. Efeitos: perda de densidade óssea/fraturas, hipercolesterolemia e aumento do risco cardiovascular isquémico em doentes com doença prévia.',
   'Non-steroidal aromatase inhibitor; reduces peripheral oestrogen production. Adjuvant and first-line in postmenopausal ER-positive breast cancer. Do not use in premenopause nor with tamoxifen or oestrogens. Effects: bone density loss/fractures, hypercholesterolaemia and increased ischaemic cardiovascular risk in patients with prior disease.',
   E'Tratamento adjuvante do cancro da mama precoce RE-positivo em mulheres pós-menopáusicas.\\nPrimeira linha do cancro da mama avançado ou metastático RE-positivo em pós-menopausa.',
   E'Adjuvant treatment of early ER-positive breast cancer in postmenopausal women.\\nFirst-line treatment of advanced or metastatic ER-positive breast cancer in postmenopause.',
   E'Afrontamentos, dores articulares e rigidez (as mais frequentes).\\nNáuseas, dor de cabeça, cansaço e erupção cutânea.\\nPerda de densidade óssea com aumento do risco de fraturas.\\nAumento do colesterol e, em doentes com doença cardíaca, risco de eventos isquémicos.',
   E'Hot flushes, joint pain and stiffness (most common).\\nNausea, headache, fatigue and rash.\\nBone density loss with an increased risk of fractures.\\nRaised cholesterol and, in patients with heart disease, a risk of ischaemic events.',
   E'Não use se está grávida ou a amamentar, nem se é pré-menopáusica.\\nNão tome com tamoxifeno ou com terapêuticas contendo estrogénios.\\nFaça avaliação da densidade óssea e do perfil lipídico conforme recomendado; considere cálcio/vitamina D.',
   E'Do not use if you are pregnant or breastfeeding, nor if you are premenopausal.\\nDo not take with tamoxifen or oestrogen-containing therapies.\\nHave bone density and lipid profile assessment as recommended; consider calcium/vitamin D.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Anastrozol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=54da5c12-cfaf-7a14-e063-6394a90a3635 ; EMC-UK (MHRA) — SmPC aprovada Anastrozol: https://www.medicines.org.uk/emc/product/100971/smpc — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Anastrozole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=54da5c12-cfaf-7a14-e063-6394a90a3635 ; EMC-UK (MHRA) — approved Anastrozole SmPC: https://www.medicines.org.uk/emc/product/100971/smpc — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),

  ('prednisolona',
   'A prednisolona é um corticoide usado para reduzir a inflamação em muitas doenças, como asma, alergias, doenças reumáticas e intestinais. É tomado por via oral, geralmente de manhã, e a dose é reduzida gradualmente no fim do tratamento.',
   'Prednisolone is a corticosteroid used to reduce inflammation in many conditions, such as asthma, allergies, rheumatic and bowel diseases. It is taken orally, usually in the morning, and the dose is tapered gradually at the end of treatment.',
   'Glucocorticóide sistémico de ação intermédia; potente anti-inflamatório e imunossupressor. Indicado em doenças inflamatórias, alérgicas, autoimunes, respiratórias e hematológicas. Nunca suspender abruptamente (risco de insuficiência suprarrenal). Interações relevantes: AINEs (hemorragia GI), rifampicina/antiepilépticos (reduzem o efeito), diuréticos (hipocaliemia) e antidiabéticos (hiperglicemia).',
   'Intermediate-acting systemic glucocorticoid; potent anti-inflammatory and immunosuppressant. Indicated in inflammatory, allergic, autoimmune, respiratory and haematological diseases. Never stop abruptly (risk of adrenal insufficiency). Relevant interactions: NSAIDs (GI bleeding), rifampicin/antiepileptics (reduce the effect), diuretics (hypokalaemia) and antidiabetics (hyperglycaemia).',
   E'Doenças inflamatórias e alérgicas (asma, rinite, dermatites).\\nDoenças reumáticas (artrite reumatoide, polimialgia).\\nDoenças autoimunes, respiratórias, hematológicas e neoplásicas (paliarivas).\\nEstado asmático e reações alérgicas graves.',
   E'Inflammatory and allergic diseases (asthma, rhinitis, dermatitis).\\nRheumatic diseases (rheumatoid arthritis, polymyalgia).\\nAutoimmune, respiratory, haematological and neoplastic diseases (palliative).\\nStatus asthmaticus and severe allergic reactions.',
   E'Retenção de líquidos, aumento do apetite e do peso.\\nHiperglicemia e agravamento da diabetes.\\nInsónia, agitação e alterações do humor.\\nCom uso prolongado: osteoporose, cataratas, glaucoma e maior risco de infeções.\\nNunca suspenda bruscamente — a dose é reduzida gradualmente.',
   E'Fluid retention, increased appetite and weight gain.\\nHyperglycaemia and worsening of diabetes.\\nInsomnia, agitation and mood changes.\\nWith prolonged use: osteoporosis, cataracts, glaucoma and an increased risk of infections.\\nNever stop abruptly — the dose is tapered gradually.',
   E'Tome de manhã, com alimentos, e nunca salte doses nem suspenda sem orientação.\\nInforme o médico se tem diabetes, tensão alta, úlcera gástrica, osteoporose ou epilepsia.\\nAvise qualquer profissional de saúde que está a tomar corticosteroides (incluindo antes de cirurgias ou vacinas).\\nEvite contacto com pessoas com varicela ou sarampo se não estiver imune.',
   E'Take in the morning, with food, and never skip doses or stop without guidance.\\nTell your doctor if you have diabetes, high blood pressure, gastric ulcer, osteoporosis or epilepsy.\\nTell any healthcare professional that you take corticosteroids (including before surgery or vaccines).\\nAvoid contact with people with chickenpox or measles if you are not immune.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Prednisolona (solução oral): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012), secção 8.2.2',
   'DailyMed/FDA (NIH/NLM) — approved Prednisolone label (oral solution): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=757b41c4-a0fe-4a09-8816-a4cdb7558f41 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012), section 8.2.2'),

  ('glibenclamida',
   'A glibenclamida é um medicamento oral usado no tratamento da diabetes tipo 2, para baixar o açúcar no sangue. É tomada com as refeições. O efeito secundário mais importante é a hipoglicemia.',
   'Glyburide is an oral medicine used to treat type 2 diabetes, to lower blood sugar. It is taken with meals. The most important side effect is hypoglycaemia.',
   'Sulfonilureia de primeira geração; estimula a secreção de insulina. Indicada na diabetes tipo 2 como adjuvante da dieta e exercício. Risco elevado de hipoglicemia grave e prolongada em idosos e na insuficiência renal. Contraindicada na diabetes tipo 1, cetoadidose e com bosentano. Precaução com álcool, AINEs, sulfonamidas, fluoroquinolonas e beta-bloqueantes (mascaram sintomas).',
   'First-generation sulfonylurea; stimulates insulin secretion. Indicated in type 2 diabetes as an adjunct to diet and exercise. High risk of severe, prolonged hypoglycaemia in the elderly and in renal impairment. Contraindicated in type 1 diabetes, ketoacidosis and with bosentan. Caution with alcohol, NSAIDs, sulphonamides, fluoroquinolones and beta-blockers (which mask symptoms).',
   E'Diabetes mellitus tipo 2, como adjuvante da dieta e do exercício, quando o controlo com estes não é suficiente.',
   E'Type 2 diabetes mellitus, as an adjunct to diet and exercise, when control with these alone is insufficient.',
   E'Hipoglicemia (açúcar no sangue demasiado baixo) — o efeito secundário mais importante, pode ser grave e prolongada.\\nPerturbações digestivas e náuseas.\\nGanho de peso ligeiro.\\nRaramente: reações alérgicas, anemia hemolítica (défice de G6PD) e alterações do sangue.',
   E'Hypoglycaemia (blood sugar too low) — the most important side effect, can be severe and prolonged.\\nDigestive disturbances and nausea.\\nSlight weight gain.\\nRarely: allergic reactions, haemolytic anaemia (G6PD deficiency) and blood disorders.',
   E'Tome com as refeições e nunca salte refeições.\\nAprenda a reconhecer e tratar a hipoglicemia — leve sempre açúcar consigo.\\nEvite o álcool, sobretudo em jejum.\\nEm idosos e na insuficiência renal, o risco de hipoglicemia é maior — use com precaução e considere insulina.',
   E'Take with meals and never skip meals.\\nLearn to recognise and treat hypoglycaemia — always carry sugar with you.\\nAvoid alcohol, especially on an empty stomach.\\nIn the elderly and in renal impairment, the risk of hypoglycaemia is higher — use with caution and consider insulin.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Glyburide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
       indications_pt, indications_en, side_effects_pt, side_effects_en,
       precautions_pt, precautions_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
