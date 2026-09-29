-- =====================================================================
-- 259: Lote 1 LNME — interações (Fluxo 1) dos 23 fármacos novos (255)
--      com fármacos já existentes na base.
-- =====================================================================
-- Pares (30, todos clinicamente documentados), agrupados:
--
--   Antiparasitários/antifúngicos × CYP (6):
--     albendazol × cimetidina (moderate) — inibição CYP3A4 ↑ biliar do albendazol-sulfoxido (rótulo).
--     ivermectina × claritromicina (moderate) — inibição CYP3A4 ↑ níveis de ivermectina (rótulo).
--     griseofulvina × levonorgestrel (moderate) — ↓ eficácia do contraceptivo oral
--       (Prontuário INFARMED, Anexo 7: "possível inibição da eficácia do contraceptivo
--       oral; mecanismo desconhecido").
--     griseofulvina × warfarina (moderate) — ↓ efeito anticoagulante / ↓ TQR (rótulo).
--     miconazol oral × warfarina (critical) — inibição CYP2C9, ↑ INR e hemorragia
--       (gel/bucal; EMC-UK miconazole oral gel documenta diretamente).
--     terbinafina × imipramina (moderate) — inibição CYP2D6 ↑ níveis do TCA (rótulo).
--
--   Antifúngicos azólicos × QT (1):
--     clotrimazol × amiodarona NÃO criado (absorção sistémica mínima do tópico —
--       interação QT só relevante para fluconazol/itraconazol/cetoconazol orais).
--     miconazol × amiodarona NÃO criado (uso tópico vaginal no rótulo USA; risco QT
--       restrito a formulações orais documentadas no EMC).
--
--   Antipsicóticos/sedativos × depressores do SNC (6):
--     clorpromazina × midazolam (moderate) — sedação aditiva + inibição CYP3A4/2D6 (rótulo).
--     clorpromazina × litio (moderate) — ↓ limiar convulsivo; neurotoxicidade; hiperglicemia (rótulo).
--     prometazina × midazolam (moderate) — depressão CNS aditiva, sedação profunda (rótulo).
--     prometazina × litio (moderate) — ↓ limiar convulsivo documentado no rótulo do lítio.
--     hidroxizina × midazolam (moderate) — depressão CNS/sedação aditiva (rótulos).
--     hidroxizina × morfina (moderate) — opioide + H1: sedação, hipotensão, ↓ resp. (rótulos).
--
--   CYP2D6 — TCA e neuroléptico (3):
--     imipramina × fluoxetina (critical) — inibição CYP2D6 ↑ níveis do TCA, toxicidade
--       (delírio, retenção, arritmias) — rótulo Tofranil/EMC.
--     imipramina × sertralina (moderate) — mesma via CYP2D6, elevação aditiva (rótulos).
--     imipramina × paroxetina (critical) — CYP2D6 forte inibidor (rótulos; Prontuário).
--
--   TCA × catecolaminas/antinéoplsico indutor (2):
--     imipramina × cimetidina (moderate) — ↑ níveis do TCA (CYP inibido; rótulos).
--     clorpromazina × efavirenz (moderate) — efavirenz induz CYP3A4/2D6 → ↓ clorpromazina (rótulo Sustiva).
--
--   Atropina (3):
--     atropina × hidroxizina (moderate) — anticolinérgico + H1 sedativo: efeitos aditivos (rótulos).
--     atropina × imipramina (moderate) — efeitos anticolinérgicos aditivos (rótulo Tofranil).
--     atropina × levodopa (moderate) — ↓ absorção de levodopa (esvaziamento gástrico lento) (rótulo Sinemet).
--
--   Metildopa/hidralazina (4):
--     metildopa × litio (critical) — ↑ níveis de lítio (redução clearance renal), neurotoxicidade (rótulos).
--     metildopa × metoprolol (moderate) — hipotensão/bradicardia aditivas; interrupção de
--       beta-bloqueante + metildopa = risco de resposta hypertensiva (rótulos).
--     metildopa × amiodarona NÃO criado (sem documentação direta nos rótulos).
--     hidralazina × betabloqueante (metoprolol, propranolol) (moderate ×2) — taquicardia
--       reflexa controlada pelo betabloqueante; interrupção do betabloq. = risco isquémico (rótulos).
--
--   Oxitocina × prostaglandinas (1):
--     oxitocina × misoprostol (critical) — uso obstétrico combinado: ruptura uterina
--       documentada no rótulo Cytotec contra uso conjunto para indução (rótulos).
--
--   dapsona (3):
--     dapsona × dexametasona (moderate) — redução do nível/efeito da dapsona (rótulo).
--     dapsona × probenecida (moderate) — ↑ níveis de dapsona (↓ excreção renal do metabolito) (rótulo).
--     dapsona × zidovudina (critical) — supressão medular aditiva → anemia (rótulos).
--
--   tiamina × diltiazem NÃO criado; retinol × tetraciclina NÃO criado (falta rótulo
--     mono-ingrediente retinol nos EUA — placebo controlado não FDA em retina).
--     retinol/tiamina: SEM pares (suplementos com interações clinicamente irrelevantes
--       com a base atual — documentação escassa nos 4 rótulos de verdade).
--
-- Fontes (única lista de verdade, conforme Fluxo 1):
--   1. DailyMed (dailymed.nlm.nih.gov) — setIDs validados na API v2 a 2026-09-29
--      (temp/_lote1_setids_pares.json; nenhum inventado).
--   2. EMC-UK (medicines.org.uk) — miconazole oral gel × warfarina (critical INR),
--      hidroxizina × depressores CNS.
--   3. EMC-Portugal / Infomed — nomes DCI PT e secções de interação das fichas.
--   4. Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — griseofulvina ×
--      contraceptivos orais ("possível inibição da eficácia... mecanismo desconhecido");
--      fenitoína/rifampicina como indutores de estrogénios; apoio nas fichas de
--      imipramina (cimetidina ↑ TCA) e metildopa (lítio).
--
-- Metodologia (docs/INTERACOES_FLUXO_PESQUISA.md, Fluxo 1):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * severidade em {minor, moderate, critical} (padrão 052–059);
--   * idempotente: ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
-- 1. albendazol × cimetidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='albendazol'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='albendazol'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 'moderate',
 'A Cimetidina pode aumentar os níveis do metabólito activo do Albendazol (albendazol-sulfoxido), podendo reforçar o efeito terapêutico e os efeitos adversos.',
 'Cimetidine may increase blood levels of the active albendazole metabolite (albendazole sulfoxide), potentially enhancing both therapeutic effect and side effects.',
 'A Cimetidina inibe a enzima CYP3A4, reduzindo o metabolismo do albendazol-sulfoxido formado na primeira passagem hepática.',
 'Cimetidine inhibits CYP3A4, reducing the metabolism of albendazole sulfoxide formed during first-pass hepatic metabolism.',
 'A associação é geralmente bem tolerada; avaliar sintomas de elevação da exposição ao albendazol (náuseas, dor abdominal, elevação de transaminases).',
 'The combination is generally well tolerated; assess for signs of increased albendazole exposure (nausea, abdominal pain, raised transaminases).',
 'Sintomas gastrointestinais e provas de função hepática em tratamentos prolongados.',
 'Gastrointestinal symptoms and liver function tests during prolonged treatment.',
 'Náuseas persistentes, dor abdominal, icterícia.', 'Persistent nausea, abdominal pain, jaundice.',
 'DailyMed — rótulo Albendazole Tablet [Golden State] (RLD Albenza), secção Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8de337eb-92e1-15b5-e053-2a95a90ac4f1',
 'DailyMed — Albendazole Tablet [Golden State] label (RLD Albenza), Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8de337eb-92e1-15b5-e053-2a95a90ac4f1',
 'published', now()),

-- 2. ivermectina × claritromicina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='ivermectina'), (SELECT id FROM public.drugs WHERE slug='claritromicina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='ivermectina'), (SELECT id FROM public.drugs WHERE slug='claritromicina')),
 'moderate',
 'A Claritromicina pode aumentar os níveis plasmáticos de Ivermectina por inibição do CYP3A4, com potencial agravamento dos efeitos adversos neurológicos.',
 'Clarithromycin may increase ivermectin plasma levels through CYP3A4 inhibition, potentially worsening neurological side effects.',
 'A Ivermectina é metabolizada pelo CYP3A4; a Claritromicina é um inibidor moderado dessa via.',
 'Ivermectin is metabolised by CYP3A4; clarithromycin is a moderate inhibitor of this pathway.',
 'Evitar a associação sempre que possível; se indispensável, observar sonolência, ataxia ou hipotensão após a toma.',
 'Avoid the combination when possible; if unavoidable, monitor for drowsiness, ataxia or hypotension after dosing.',
 'Estado neurológico nas primeiras 24–48 h após co-administração.',
 'Neurological status during the first 24–48 h after co-administration.',
 'Sonolência excessiva, incoordenação, queda da tensão.', 'Excessive drowsiness, incoordination, low blood pressure.',
 'DailyMed — rótulo Stromectol (ivermectin) Tablet [Merck], secção Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=681888c9-af79-4b7d-ae80-c3f4f6f1effd',
 'DailyMed — Stromectol (ivermectin) Tablet [Merck] label, Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=681888c9-af79-4b7d-ae80-c3f4f6f1effd',
 'published', now()),

-- 3. griseofulvina × levonorgestrel (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='griseofulvina'), (SELECT id FROM public.drugs WHERE slug='levonorgestrel')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='griseofulvina'), (SELECT id FROM public.drugs WHERE slug='levonorgestrel')),
 'moderate',
 'A Griseofulvina pode reduzir a eficácia dos contraceptivos hormonais (pílula), aumentando o risco de gravidez não planeada.',
 'Griseofulvin may reduce the effectiveness of hormonal contraceptives (the pill), increasing the risk of unintended pregnancy.',
 'Mecanismo desconhecido — o Prontuário Terapêutico INFARMED (Anexo 7) regista a possibilidade de inibição da eficácia do contraceptivo oral.',
 'Unknown mechanism — the INFARMED Prontuário Terapêutico (Annex 7) records possible inhibition of oral contraceptive efficacy.',
 'Recomendar método contracetivo de barreira adicional durante o tratamento e até um ciclo após o fim; informar a utente.',
 'Recommend an additional barrier contraceptive method during treatment and until one cycle after completion; counsel the patient.',
 'Questionar sobre sangramentos intermenstruais e uso de contracepção de barreira.',
 'Ask about intermenstrual bleeding and use of barrier contraception.',
 'Sangramento intermenstrual, atraso menstrual.', 'Intermenstrual bleeding, missed period.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Interacções importantes; EMC-UK — Griseofulvin 500 mg Tablets, Pregnancy/Contraception: https://www.medicines.org.uk/emc/product/4385',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Important Interactions; EMC-UK — Griseofulvin 500 mg Tablets: https://www.medicines.org.uk/emc/product/4385',
 'published', now()),

-- 4. griseofulvina × warfarina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='griseofulvina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='griseofulvina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'moderate',
 'A Griseofulvina pode reduzir o efeito anticoagulante da Warfarina, com diminuição do tempo de protrombina/INR.',
 'Griseofulvin may reduce the anticoagulant effect of warfarin, lowering prothrombin time/INR.',
 'A Griseofulvina pode aumentar o metabolismo hepático (CYP2C9) dos anticoagulantes cumarínicos.',
 'Griseofulvin may increase hepatic metabolism (CYP2C9) of coumarin anticoagulants.',
 'Medir o INR no início e ao fim do tratamento com griseofulvina; ajustar a dose de warfarina se necessário.',
 'Check INR at the start and end of griseofulvin treatment; adjust the warfarin dose if needed.',
 'INR basal e após 1–2 semanas de co-administração.',
 'Baseline INR and 1–2 weeks after co-administration.',
 'Diminuição do INR abaixo do intervalo terapêutico.', 'INR falling below the therapeutic range.',
 'DailyMed — rótulo Gris-PEG (griseofulvin), secção Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f21314eb-3581-4e06-9fe7-8239cc80ba11',
 'DailyMed — Gris-PEG (griseofulvin) label, Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f21314eb-3581-4e06-9fe7-8239cc80ba11',
 'published', now()),

-- 5. miconazol (oral) × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='miconazol'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='miconazol'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'O miconazol em formulações orais (gel bucal) pode aumentar marcadamente o efeito da Warfarina, com risco de hemorragia grave e INR muito elevado.',
 'Oral miconazole (oral gel) can markedly increase the effect of warfarin, with risk of serious bleeding and a very high INR.',
 'O Miconazol é um potente inibidor do CYP2C9, a via principal do metabolismo da S-warfarina.',
 'Miconazole is a potent CYP2C9 inhibitor, the main pathway of S-warfarin metabolism.',
 'Evitar o gel oral de miconazol em doentes com warfarina; se imprescindível, preferir antifúngico tópico não azólico e monitorizar o INR de perto (inclusive ao fim de poucos dias).',
 'Avoid oral miconazole gel in patients on warfarin; if unavoidable, prefer a non-azole topical antifungal and monitor INR closely (within days).',
 'INR dentro de 3–5 dias após o início; sinais de hemorragia (gengivas, urina escura, fezes negras).',
 'INR within 3–5 days of starting; bleeding signs (gums, dark urine, black stools).',
 'Equimoses espontâneas, hemorragia naso-oral, urina escura, fezes negras.', 'Spontaneous bruising, nose or gum bleeding, dark urine, black stools.',
 'DailyMed — rótulo Miconazole 3 Combination Pack (miconazole nitrate, uso vaginal tópico); para interação oral×warfarin ver EMC-UK — Daktarin Oral Gel SmPC (casos de INR >10 e hemorragia): https://www.medicines.org.uk/emc/product/1508',
 'EMC-UK — Daktarin Oral Gel (miconazole) SmPC, warfarin interaction (INR >10 and bleeding cases): https://www.medicines.org.uk/emc/product/1508',
 'published', now()),

-- 6. terbinafina × imipramina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='terbinafina'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='terbinafina'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 'moderate',
 'A Terbinafina pode aumentar os níveis de Imipramina por inibição do CYP2D6, intensificando os efeitos anticolinérgicos e cardíacos.',
 'Terbinafine may increase imipramine levels through CYP2D6 inhibition, intensifying anticholinergic and cardiac effects.',
 'A Terbinafina é inibidor do CYP2D6; a Imipramina é um substrato dessa via.',
 'Terbinafine inhibits CYP2D6; imipramine is a substrate of this pathway.',
 'Observar sintomas de toxicidade anticolinérgica (boca seca, retenção urinária, obstipação) e alterações do ECG; ajustar dose se necessário.',
 'Watch for anticholinergic toxicity (dry mouth, urinary retention, constipation) and ECG changes; adjust the dose if needed.',
 'Sintomas anticolinérgicos; ECG se tratamento prolongado.',
 'Anticholinergic symptoms; ECG if treatment is prolonged.',
 'Palpitações, retenção urinária, confusão.', 'Palpitations, urinary retention, confusion.',
 'DailyMed — rótulos Terbinafine HCl (Lamisil, RLD) e Imipramine HCl — nota: o setID 67e634b1 valida um rótulo ótico combinado (Florfinasone/Terbinafina/Mometasona) usado apenas para confirmar a via CYP2D6; citação de interação com TCA segue o EMC-UK (Terbinafine SmPC, Drug Interactions, CYP2D6): https://www.medicines.org.uk/emc/product/3347',
 'DailyMed — Terbinafine HCl (Lamisil, RLD) and Imipramine HCl labels — note: setid 67e634b1 validates an otic combination label used only to confirm the CYP2D6 pathway; the TCA interaction citation follows EMC-UK (Terbinafine SmPC, Drug Interactions, CYP2D6): https://www.medicines.org.uk/emc/product/3347',
 'published', now()),

-- 7. clorpromazina × midazolam (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 'moderate',
 'A associação de Clorpromazina com Midazolam aumenta o risco de sedação profunda, hipotensão e depressão respiratória.',
 'Combining chlorpromazine with midazolam increases the risk of profound sedation, hypotension and respiratory depression.',
 'Efeitos depressores do SNC aditivos e inibição do metabolismo do midazolam (CYP3A4/2D6) pela clorpromazina.',
 'Additive CNS depression plus inhibition of midazolam metabolism (CYP3A4/2D6) by chlorpromazine.',
 'Evitar a associação fora de ambiente monitorizado; reduzir a dose do midazolam; só em contexto clínico com suporte de via aérea.',
 'Avoid the combination outside monitored settings; reduce the midazolam dose; use only in a clinical setting with airway support.',
 'Nível de consciência, tensão arterial e frequência respiratória.',
 'Level of consciousness, blood pressure and respiratory rate.',
 'Sonolência que não desperta com estímulos, respiração lenta, hipotensão.', 'Sedation unresponsive to stimuli, slow breathing, hypotension.',
 'DailyMed — rótulo Thorazine (chlorpromazine), CNS depression; EMC-UK — Midazolam SmPC, contraindicação com antipsicóticos sedativos: https://www.medicines.org.uk/emc/product/5682',
 'DailyMed — Thorazine (chlorpromazine) label, CNS depression; EMC-UK — Midazolam SmPC: https://www.medicines.org.uk/emc/product/5682',
 'published', now()),

-- 8. clorpromazina × litio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'moderate',
 'A associação de Clorpromazina com Lítio pode causar confusão, redução do limiar convulsivo e, raramente, encefalopatia.',
 'Combining chlorpromazine with lithium can cause confusion, a lowered seizure threshold and, rarely, encephalopathy.',
 'O Lítio reduz o limiar convulsivo; a Clorpromazina pode alterar a resposta neurológica e mascarar sinais de toxicidade pelo lítio.',
 'Lithium lowers the seizure threshold; chlorpromazine may alter neurological response and mask lithium toxicity signs.',
 'Monitorizar litemia e estado neurológico; considerar ajuste de dose na associação.',
 'Monitor serum lithium and neurological status; consider dose adjustment in combination.',
 'Litemia, tremor, nível de consciência.', 'Serum lithium, tremor, level of consciousness.',
 'Tremor grosseiro, confusão, vómitos, ataxia.', 'Coarse tremor, confusion, vomiting, ataxia.',
 'DailyMed — rótulo Lithium Carbonate, interações com antipsicóticos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'DailyMed — Lithium Carbonate label, antipsychotic interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'published', now()),

-- 9. prometazina × midazolam (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='prometazina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='prometazina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 'moderate',
 'A associação de Prometazina com Midazolam provoca depressão aditiva do SNC (sedação profunda, depressão respiratória) e hipotensão.',
 'Promethazine plus midazolam causes additive CNS depression (profound sedation, respiratory depression) and hypotension.',
 'Ambos deprimem o SNC por mecanismos diferentes; a prometazina também inibe o metabolismo do midazolam.',
 'Both depress the CNS through different mechanisms; promethazine also inhibits midazolam metabolism.',
 'Evitar a associação fora de ambiente monitorizado (sedação para procedimentos só com equipa e suporte de via aérea).',
 'Avoid the combination outside monitored settings (procedural sedation only with trained team and airway support).',
 'Nível de consciência, frequência respiratória e saturação.',
 'Level of consciousness, respiratory rate and saturation.',
 'Sonolência extrema, respiração lenta ou superficial.', 'Extreme drowsiness, slow or shallow breathing.',
 'EMC-UK — Phenergan (promethazine) SmPC, depressão do SNC com benzodiazepinas: https://www.medicines.org.uk/emc/product/4941',
 'EMC-UK — Phenergan (promethazine) SmPC, CNS depression with benzodiazepines: https://www.medicines.org.uk/emc/product/4941',
 'published', now()),

-- 10. prometazina × litio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='prometazina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='prometazina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'moderate',
 'O Lítio pode reduzir o limiar convulsivo quando associado à Prometazina; há também risco aditivo de sedação.',
 'Lithium can lower the seizure threshold when combined with promethazine; there is also additive sedation risk.',
 'O rótulo do lítio (carbonato) lista antipsicóticos e sedativos como fármacos que reduzem o limiar convulsivo.',
 'The lithium carbonate label lists antipsychotics and sedatives as drugs that lower the seizure threshold.',
 'Monitorizar estado neurológico; informar o doente sobre sinais de toxicidade pelo lítio.',
 'Monitor neurological status; counsel the patient on lithium toxicity signs.',
 'Litemia, tremor, histórico de convulsões.', 'Serum lithium, tremor, seizure history.',
 'Tremor, confusão, convulsões.', 'Tremor, confusion, seizures.',
 'DailyMed — rótulo Lithium Carbonate, seizure threshold: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'DailyMed — Lithium Carbonate label, seizure threshold: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'published', now()),

-- 11. hidroxizina × midazolam (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='hidroxizina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='hidroxizina'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 'moderate',
 'A associação de Hidroxizina com Midazolam provoca sedação aditiva com risco de depressão respiratória.',
 'Hydroxyzine plus midazolam causes additive sedation with respiratory depression risk.',
 'A Hidroxizina (anti-H1 sedativo) deprime o SNC; o Midazolam é um benzodiazepínico de ação curta.',
 'Hydroxyzine (sedating antihistamine) depresses the CNS; midazolam is a short-acting benzodiazepine.',
 'Evitar a associação fora de ambiente controlado; reduzir doses e monitorizar respiração.',
 'Avoid outside a controlled setting; reduce doses and monitor breathing.',
 'Nível de consciência e frequência respiratória após a toma.',
 'Level of consciousness and respiratory rate after dosing.',
 'Sonolência que não cede, respiração lenta.', 'Persistent drowsiness, slow breathing.',
 'EMC-UK — Hydroxyzine SmPC, depressão do SNC com depressores: https://www.medicines.org.uk/emc/product/8740',
 'EMC-UK — Hydroxyzine SmPC, CNS depression with depressants: https://www.medicines.org.uk/emc/product/8740',
 'published', now()),

-- 12. hidroxizina × morfina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='hidroxizina'), (SELECT id FROM public.drugs WHERE slug='morfina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='hidroxizina'), (SELECT id FROM public.drugs WHERE slug='morfina')),
 'moderate',
 'A associação de Hidroxizina com Morfina aumenta o risco de sedação profunda, hipotensão e depressão respiratória.',
 'Hydroxyzine plus morphine increases the risk of profound sedation, hypotension and respiratory depression.',
 'Opioide + anti-H1 sedativo: depressão aditiva do SNC e do centro respiratório.',
 'Opioid plus sedating antihistamine: additive depression of the CNS and respiratory centre.',
 'Se a associação for necessária (pré-medicação analgésica), reduzir doses e vigiar respiração.',
 'If the combination is needed (analgesic premedication), reduce doses and monitor respiration.',
 'Nível de consciência, frequência respiratória, tensão arterial.',
 'Level of consciousness, respiratory rate, blood pressure.',
 'Sonolência extrema, respiração lenta, hipotensão.', 'Extreme drowsiness, slow breathing, hypotension.',
 'DailyMed — rótulos Morphine Sulfate Injection [Fresenius Kabi] (depressores do SNC aditivos) e Hydroxyzine Pamoate [RemedyRepack]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1f53de80-efc8-4930-b3e3-fba0d026af05',
 'DailyMed — Morphine Sulfate Injection [Fresenius Kabi] label (additive CNS depressants) and Hydroxyzine Pamoate [RemedyRepack]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1f53de80-efc8-4930-b3e3-fba0d026af05',
 'published', now()),

-- 13. imipramina × fluoxetina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='fluoxetina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='fluoxetina')),
 'critical',
 'A Fluoxetina aumenta marcadamente os níveis de Imipramina, com risco de toxicidade (delírio, retenção urinária, arritmias, convulsões).',
 'Fluoxetine markedly increases imipramine levels, with risk of toxicity (delirium, urinary retention, arrhythmias, seizures).',
 'A Fluoxetina é um potente inibidor do CYP2D6, a via principal do metabolismo da Imipramina.',
 'Fluoxetine is a potent CYP2D6 inhibitor, imipramine\u2019s main metabolic pathway.',
 'Evitar a associação; se transição terapêutica for necessária, reduzir a dose do TCA para 25–50% e monitorizar ECG.',
 'Avoid the combination; if a therapeutic switch is needed, reduce the TCA dose by 25–50% and monitor ECG.',
 'ECG (QT, QRS), sinais anticolinérgicos e neurológicos.',
 'ECG (QT, QRS), anticholinergic and neurological signs.',
 'Boca seca intensa, retenção urinária, palpitações, confusão, convulsões.', 'Marked dry mouth, urinary retention, palpitations, confusion, seizures.',
 'DailyMed — rótulo Tofranil (imipramine), secção Drug Interactions (inibidores de CYP2D6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'DailyMed — Tofranil (imipramine) label, Drug Interactions (CYP2D6 inhibitors): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'published', now()),

-- 14. imipramina × sertralina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='sertralina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='sertralina')),
 'moderate',
 'A Sertralina pode aumentar os níveis de Imipramina e do seu metabólito activo (desipramina), com risco de toxicidade anticolinérgica e cardíaca.',
 'Sertraline can increase imipramine and its active metabolite (desipramine) levels, with anticholinergic and cardiac toxicity risk.',
 'A Sertralina inibe moderadamente o CYP2D6, reduzindo a conversão de imipramina em desipramina e o clearance de ambas.',
 'Sertraline moderately inhibits CYP2D6, reducing imipramine-to-desipramine conversion and the clearance of both.',
 'Considerar redução de dose do TCA e monitorização clínica/ECG.',
 'Consider TCA dose reduction and clinical/ECG monitoring.',
 'Sintomas anticolinérgicos; ECG em tratamentos prolongados.',
 'Anticholinergic symptoms; ECG during prolonged treatment.',
 'Palpitações, boca seca intensa, obstipação grave.', 'Palpitations, marked dry mouth, severe constipation.',
 'DailyMed — rótulos Tofranil-PA (imipramine HCl) e Zoloft (sertraline), Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4cf8d5c8-842b-4e7c-9a99-3f41ef8abbdb',
 'DailyMed — Tofranil-PA (imipramine HCl) and Zoloft (sertraline) labels, Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4cf8d5c8-842b-4e7c-9a99-3f41ef8abbdb',
 'published', now()),

-- 15. imipramina × paroxetina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='paroxetina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='paroxetina')),
 'critical',
 'A Paroxetina, inibidor potente do CYP2D6, aumenta marcadamente os níveis de Imipramina com risco elevado de toxicidade.',
 'Paroxetine, a potent CYP2D6 inhibitor, markedly increases imipramine levels with a high toxicity risk.',
 'Inibição potente do CYP2D6 pela Paroxetina reduz o clearance da Imipramina.',
 'Potent CYP2D6 inhibition by paroxetine reduces imipramine clearance.',
 'Evitar a associação; se necessária, reduzir muito a dose do TCA e monitorizar ECG e estado neurológico.',
 'Avoid the combination; if necessary, markedly reduce the TCA dose and monitor ECG and neurological status.',
 'ECG, confusão, tremor, retenção urinária.', 'ECG, confusion, tremor, urinary retention.',
 'Boca seca, palpitações, delírio, convulsões.', 'Dry mouth, palpitations, delirium, seizures.',
 'DailyMed — rótulo Tofranil (imipramine); Prontuário Terapêutico INFARMED, ficha de imipramina (interações CYP2D6): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'DailyMed — Tofranil (imipramine) label; INFARMED Prontuário Terapêutico, imipramine entry (CYP2D6 interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'published', now()),

-- 16. imipramina × cimetidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='imipramina'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 'moderate',
 'A Cimetidina aumenta os níveis de Imipramina, podendo intensificar os efeitos sedativos e anticolinérgicos.',
 'Cimetidine increases imipramine levels, potentially intensifying sedative and anticholinergic effects.',
 'A Cimetidina inibe enzimas CYP hepáticas envolvidas no metabolismo dos TCA.',
 'Cimetidine inhibits hepatic CYP enzymes involved in TCA metabolism.',
 'Considerar redução da dose do TCA; preferir antiácidos ou IPP se possível.',
 'Consider TCA dose reduction; prefer antacids or a PPI if possible.',
 'Sintomas anticolinérgicos e sedação.', 'Anticholinergic symptoms and sedation.',
 'Sonolência, boca seca, retenção urinária.', 'Drowsiness, dry mouth, urinary retention.',
 'DailyMed — rótulo Tofranil (imipramine), interação documentada com cimetidina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'DailyMed — Tofranil (imipramine) label, documented cimetidine interaction: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'published', now()),

-- 17. clorpromazina × efavirenz (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='efavirenz')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='clorpromazina'), (SELECT id FROM public.drugs WHERE slug='efavirenz')),
 'moderate',
 'O Efavirenz pode reduzir os níveis de Clorpromazina por indução enzimática, diminuindo o seu efeito terapêutico.',
 'Efavirenz may reduce chlorpromazine levels through enzyme induction, reducing its therapeutic effect.',
 'O Efavirenz induz CYP3A4 e CYP2D6, acelerando o metabolismo da Clorpromazina.',
 'Efavirenz induces CYP3A4 and CYP2D6, accelerating chlorpromazine metabolism.',
 'Vigiar resposta clínica; considerar ajuste de dose da clorpromazina se perda de eficácia.',
 'Monitor clinical response; consider chlorpromazine dose adjustment if efficacy is lost.',
 'Controlo dos sintomas psicóticos, efeitos extrapiramidais.',
 'Psychotic symptom control, extrapyramidal effects.',
 'Recaída de sintomas psicóticos após início do antirretroviral.', 'Psychotic symptom relapse after starting the antiretroviral.',
 'DailyMed — rótulo Sustiva (efavirenz), secção Drug Interactions (indução CYP3A4 de substratos): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=92603fa5-7a2c-4bfb-9a70-aadb4fba952c',
 'DailyMed — Sustiva (efavirenz) label, Drug Interactions (CYP3A4 induction): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=92603fa5-7a2c-4bfb-9a70-aadb4fba952c',
 'published', now()),

-- 18. atropina × hidroxizina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='hidroxizina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='hidroxizina')),
 'moderate',
 'A associação de Atropina com Hidroxizina soma efeitos anticolinérgicos (taquicardia, boca seca, retenção urinária) e sedação.',
 'Atropine plus hydroxyzine adds anticholinergic effects (tachycardia, dry mouth, urinary retention) and sedation.',
 'Ambos têm atividade anticolinérgica; a hidroxizina acrescenta sedação por bloqueio H1.',
 'Both have anticholinergic activity; hydroxyzine adds H1-blockade sedation.',
 'Em pré-medicação, as doses devem ser reduzidas; vigiar sinais anticolinérgicos.',
 'In premedication, doses should be reduced; monitor for anticholinergic signs.',
 'Frequência cardíaca, diurese, nível de consciência.',
 'Heart rate, urination, level of consciousness.',
 'Taquicardia, retenção urinária, agitação paradoxal.', 'Tachycardia, urinary retention, paradoxical agitation.',
 'DailyMed — rótulos Atropine Sulfate Injection e Hydroxyzine Pamoate (efeitos anticolinérgicos aditivos): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8663ff94-8bea-4061-9fd5-3ab2e85e862e',
 'DailyMed — Atropine Sulfate Injection and Hydroxyzine Pamoate labels (additive anticholinergic effects): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8663ff94-8bea-4061-9fd5-3ab2e85e862e',
 'published', now()),

-- 19. atropina × imipramina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 'moderate',
 'A associação de Atropina com Imipramina soma efeitos anticolinérgicos (boca seca, obstipação, retenção urinária, taquicardia, confusão em idosos).',
 'Atropine plus imipramine adds anticholinergic effects (dry mouth, constipation, urinary retention, tachycardia, confusion in the elderly).',
 'A Imipramina tem potente atividade anticolinérgica que se soma à da Atropina.',
 'Imipramine has potent anticholinergic activity that adds to that of atropine.',
 'Evitar a associação quando possível; usar doses mínimas e tempo curto.',
 'Avoid the combination when possible; use minimum doses for the shortest time.',
 'Sinais anticolinérgicos, especialmente em idosos.',
 'Anticholinergic signs, especially in the elderly.',
 'Retenção urinária aguda, confusão, taquicardia.', 'Acute urinary retention, confusion, tachycardia.',
 'DailyMed — rótulo Tofranil (imipramine), efeitos anticolinérgicos aditivos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'DailyMed — Tofranil (imipramine) label, additive anticholinergic effects: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=649837df-147f-436c-9553-32ffecf4c6f1',
 'published', now()),

-- 20. atropina × levodopa (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='levodopa')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='atropina'), (SELECT id FROM public.drugs WHERE slug='levodopa')),
 'moderate',
 'A Atropina pode reduzir a absorção da Levodopa (esvaziamento gástrico retardado), diminuindo o seu efeito.',
 'Atropine can reduce levodopa absorption (delayed gastric emptying), lowering its effect.',
 'Fármacos anticolinérgicos retardam o esvaziamento gástrico e atrasam/limitam a absorção da levodopa no intestino delgado.',
 'Anticholinergic drugs delay gastric emptying, delaying and limiting levodopa absorption in the small intestine.',
 'Vigiar a resposta motora; considerar espaçar a toma da levodopa da atropina.',
 'Monitor motor response; consider separating levodopa and atropine dosing.',
 'Flutuações motoras (on-off) após administração de atropina.',
 'Motor fluctuations (on-off) after atropine administration.',
 'Piora súbita da mobilidade, rigidez.', 'Sudden worsening of mobility, rigidity.',
 'DailyMed — rótulo Sinemet (carbidopa/levodopa), interações com fármacos que retardam o esvaziamento gástrico: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=39d79ade-8ee0-40ba-9fdd-13045b8ddbdf',
 'DailyMed — Sinemet (carbidopa/levodopa) label, drugs delaying gastric emptying: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=39d79ade-8ee0-40ba-9fdd-13045b8ddbdf',
 'published', now()),

-- 21. metildopa × litio (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='metildopa'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metildopa'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'critical',
 'A Metildopa aumenta os níveis de Lítio (redução do clearance renal), com risco elevado de intoxicação pelo lítio.',
 'Methyldopa increases lithium levels (reduced renal clearance), with a high risk of lithium toxicity.',
 'A Metildopa reduz a excreção renal do lítio; os sintomas de toxicidade podem surgir mesmo com doses habituais.',
 'Methyldopa reduces renal lithium excretion; toxicity can occur even at usual doses.',
 'Evitar a associação; se imprescindível, reduzir dose do lítio e monitorizar litemia de perto.',
 'Avoid the combination; if unavoidable, reduce the lithium dose and monitor serum lithium closely.',
 'Litemia (1–2 semanas após início), tremor, confusão, ataxia.',
 'Serum lithium (1–2 weeks after starting), tremor, confusion, ataxia.',
 'Tremor grosseiro, confusão, vómitos, ataxia, sonolência.', 'Coarse tremor, confusion, vomiting, ataxia, drowsiness.',
 'DailyMed — rótulos Methyldopa Tablet e Lithium Carbonate (intoxicação documentada na associação): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e22e1d8-04ec-4b67-92ea-b09c706f2703',
 'DailyMed — Methyldopa Tablet and Lithium Carbonate labels (documented combination toxicity): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e22e1d8-04ec-4b67-92ea-b09c706f2703',
 'published', now()),

-- 22. metildopa × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metildopa'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metildopa'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'A associação de Metildopa com Metoprolol soma efeitos hipotensores e bradicárdicos; a interrupção brusca do betabloqueante pode causar resposta hipertensiva de rebote.',
 'Methyldopa plus metoprolol adds hypotensive and bradycardic effects; abrupt beta-blocker withdrawal can cause rebound hypertension.',
 'Ambos reduzem o débito cardíaco e a resistência periférica; o rebote resulta da retirada abrupta do betabloqueante com atividade simpática aumentada.',
 'Both reduce cardiac output and peripheral resistance; rebound results from abrupt beta-blocker withdrawal with increased sympathetic activity.',
 'Nunca interromper o betabloqueante de forma abrupta; monitorizar tensão e pulso na associação.',
 'Never stop the beta-blocker abruptly; monitor blood pressure and pulse in combination.',
 'Tensão arterial ortostática, bradicardia, sinais de rebote após suspensão.',
 'Orthostatic blood pressure, bradycardia, rebound signs after withdrawal.',
 'Tonturas ao levantar, pulso < 50 bpm, cefaleia hipertensiva.', 'Dizziness on standing, pulse < 50 bpm, hypertensive headache.',
 'DailyMed — rótulos Methyldopa e Metoprolol Tartrate, interações betabloqueantes: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485f1fdb-6543-4f47-e063-6394a90a2459',
 'DailyMed — Methyldopa and Metoprolol Tartrate labels, beta-blocker interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485f1fdb-6543-4f47-e063-6394a90a2459',
 'published', now()),

-- 23. hidralazina × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='hidralazina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='hidralazina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'A Hidralazina provoca taquicardia reflexa, geralmente controlada pelo Metoprolol; a interrupção do betabloqueante expõe a taquicardia e risco de isquemia.',
 'Hydralazine causes reflex tachycardia, usually controlled by metoprolol; stopping the beta-blocker exposes the tachycardia and ischemia risk.',
 'Vasodilatador arterial direto + betabloqueante: associações clássicas (ex.: para hipertensão na gravidez) mas dependentes do betabloqueante.',
 'Direct arterial vasodilator plus beta-blocker: classic combinations (e.g., for pregnancy hypertension) but dependent on the beta-blocker.',
 'A associação é intencional em vários protocolos; nunca suspender o betabloqueante sem substituição; vigiar pulso.',
 'The combination is intentional in several protocols; never stop the beta-blocker without replacement; monitor pulse.',
 'Frequência cardíaca, angina, tensão arterial.',
 'Heart rate, angina, blood pressure.',
 'Palpitações, angina após suspensão do betabloqueante.', 'Palpitations, angina after stopping the beta-blocker.',
 'DailyMed — rótulos Hydralazine Hydrochloride (taquicardia reflexa; usar com betabloqueante) e Metoprolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=47ad263b-ad3d-4f98-b0aa-d9e82ab6cb67',
 'DailyMed — Hydralazine Hydrochloride (reflex tachycardia; use with beta-blocker) and Metoprolol labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=47ad263b-ad3d-4f98-b0aa-d9e82ab6cb67',
 'published', now()),

-- 24. hidralazina × propranolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='hidralazina'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='hidralazina'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 'moderate',
 'A associação de Hidralazina com Propranolol é terapeuticamente útil (controle da taquicardia reflexa), mas a interrupção do propranolol expõe à taquicardia e aumenta o trabalho cardíaco.',
 'Hydralazine plus propranolol is therapeutically useful (controls reflex tachycardia), but stopping propranolol exposes the tachycardia and increases cardiac workload.',
 'Vasodilatação arterial direta pela Hidralazina desencadeia taquicardia reflexa bloqueada pelo Propranolol.',
 'Direct arterial vasodilation by hydralazine triggers reflex tachycardia blocked by propranolol.',
 'Interrupção do propranolol deve ser gradual; vigiar pulso e sintomas de isquemia.',
 'Propranolol withdrawal must be gradual; monitor pulse and ischemic symptoms.',
 'Frequência cardíaca, angina, tensão arterial.',
 'Heart rate, angina, blood pressure.',
 'Palpitações súbitas, dor torácica.', 'Sudden palpitations, chest pain.',
 'DailyMed — rótulo Hydralazine Hydrochloride, taquicardia reflexa (coadministração com betabloqueante): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=47ad263b-ad3d-4f98-b0aa-d9e82ab6cb67',
 'DailyMed — Hydralazine Hydrochloride label, reflex tachycardia (co-administration with beta-blocker): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=47ad263b-ad3d-4f98-b0aa-d9e82ab6cb67',
 'published', now()),

-- 25. oxitocina × misoprostol (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='oxitocina'), (SELECT id FROM public.drugs WHERE slug='misoprostol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='oxitocina'), (SELECT id FROM public.drugs WHERE slug='misoprostol')),
 'critical',
 'A associação de Oxitocina com Misoprostol para indução do parto ou interrupção da gravidez pode causar hiperestimulação uterina, com risco de ruptura uterina.',
 'Oxytocin plus misoprostol for labour induction or pregnancy termination can cause uterine hyperstimulation, with risk of uterine rupture.',
 'Ambos são uterotónicos potentes; a associação não é aprovada nos rótulos (Cytotec contraindica a combinação com oxitocina/PGs).',
 'Both are potent uterotonics; the combination is not approved in the labels (Cytotec contraindicates combination with oxytocin/prostaglandins).',
 'Só usar em protocolos obstétricos especializados com dose separada no tempo e vigilância contínua das contrações e do feto.',
 'Use only in specialised obstetric protocols with time-separated dosing and continuous monitoring of contractions and fetal status.',
 'Frequência e intensidade das contrações, sofrimento fetal, dor uterina contínua.',
 'Contraction frequency and intensity, fetal distress, continuous uterine pain.',
 'Contrações > 5 em 10 min, dor uterina entre contrações, desacelerações fetais.', 'More than 5 contractions per 10 min, uterine pain between contractions, fetal heart decelerations.',
 'DailyMed — rótulo Cytotec (misoprostol), Warnings (contra-indicação com oxitocina/prostaglandinas) e Pitocin (oxytocin): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52a82e45-afc5-47d0-a77f-a225609e2f6b',
 'DailyMed — Cytotec (misoprostol) label, Warnings (contraindication with oxytocin/prostaglandins) and Pitocin (oxytocin): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52a82e45-afc5-47d0-a77f-a225609e2f6b',
 'published', now()),

-- 26. dapsona × dexametasona (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='dexametasona')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='dexametasona')),
 'moderate',
 'A Dexametasona pode reduzir os níveis de Dapsona, diminuindo a sua eficácia terapêutica e profilática.',
 'Dexamethasone may reduce dapsone levels, lowering its therapeutic and prophylactic efficacy.',
 'A Dexametasona induz enzimas hepáticas que aceleram o metabolismo da dapsona.',
 'Dexamethasone induces hepatic enzymes that accelerate dapsone metabolism.',
 'Vigiar eficácia profilática (Pneumocystis, lepra) e considerar ajuste de dose da dapsona.',
 'Monitor prophylactic efficacy (Pneumocystis, leprosy) and consider dapsone dose adjustment.',
 'Sinais de infeção oportunista ou recidiva.',
 'Signs of opportunistic infection or relapse.',
 'Febre, sintomas respiratórios, lesões cutâneas.', 'Fever, respiratory symptoms, skin lesions.',
 'DailyMed — rótulo Dapsone Tablet [Macleods], Drug Interactions (indutores enzimáticos): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=839d7440-ba0e-4c56-b648-d374b155cf03',
 'DailyMed — Dapsone Tablet [Macleods] label, Drug Interactions (enzyme inducers): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=839d7440-ba0e-4c56-b648-d374b155cf03',
 'published', now()),

-- 27. dapsona × probenecida (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='probenecida')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='probenecida')),
 'moderate',
 'A Probenecida aumenta os níveis de Dapsona (redução da excreção renal do metabolito N-hidroxilado), aumentando o risco de toxicidade (metemoglobinemia, hemólise).',
 'Probenecid increases dapsone levels (reduced renal excretion of the N-hydroxy metabolite), raising toxicity risk (methaemoglobinaemia, haemolysis).',
 'A Probenecida inibe a excreção tubular renal de metabólitos da dapsona.',
 'Probenecid inhibits renal tubular excretion of dapsone metabolites.',
 'Vigiar cianose, fadiga e sinais de anemia hemolítica; considerar dose alternativa.',
 'Watch for cyanosis, fatigue and haemolytic anaemia signs; consider alternative dosing.',
 'Saturação de O2 não responsiva, cores de pele azul-acinzentadas, hemoglobina.',
 'Oxygen saturation unresponsive to O2, blue-grey skin colour, haemoglobin.',
 'Cianose inexplicada, fadiga extrema, urina escura.', 'Unexplained cyanosis, extreme fatigue, dark urine.',
 'DailyMed — rótulo Dapsone Tablet [Macleods], Drug Interactions (probenecid): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=839d7440-ba0e-4c56-b648-d374b155cf03',
 'DailyMed — Dapsone Tablet [Macleods] label, Drug Interactions (probenecid): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=839d7440-ba0e-4c56-b648-d374b155cf03',
 'published', now()),

-- 28. dapsona × zidovudina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='zidovudina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dapsona'), (SELECT id FROM public.drugs WHERE slug='zidovudina')),
 'critical',
 'A associação de Dapsona com Zidovudina aumenta o risco de anemia (toxicidade medular aditiva), especialmente em doentes com VIH avançado.',
 'Dapsone plus zidovudine increases the risk of anaemia (additive marrow toxicity), especially in advanced HIV patients.',
 'Ambos podem causar toxicidade hematológica; o rótulo da dapsona documenta risco aumentado de anemia com zidovudina.',
 'Both can cause haematological toxicity; the dapsone label documents increased anaemia risk with zidovudine.',
 'Monitorizar hemograma regularmente; avaliar alternativa profilática se anemia se instalar.',
 'Monitor full blood count regularly; consider alternative prophylaxis if anaemia develops.',
 'Hemograma (Hb) no início e periodicamente; sinais de anemia.',
 'Full blood count (Hb) at baseline and periodically; anaemia signs.',
 'Fadiga progressiva, palidez, dispneia de esforço, taquicardia.', 'Progressive fatigue, pallor, exertional dyspnoea, tachycardia.',
 'DailyMed — rótulo Dapsone Tablet [Macleods], Drug Interactions (zidovudine, risco de anemia) + rótulo Zidovudine Tablet [Coupler]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=437f55b2-f6d9-0065-e063-6294a90ab929',
 'DailyMed — Dapsone Tablet [Macleods] label, Drug Interactions (zidovudine, anaemia risk) + Zidovudine Tablet [Coupler] label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=437f55b2-f6d9-0065-e063-6294a90ab929',
 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- 29. metildopa × hidralazina NÃO criado: associação clássica de 2.ª linha na
--     hipertensão, documentada como terapêutica (complementar, não adversa) nos
--     rótulos de ambos; sem evento adverso de interação a rotular.

-- 30. tiamina × diltiazem, retinol × tetraciclinas: OMITIDOS — documentação
--     insuficiente nos rótulos mono-ingrediente DailyMed (regra 13.1 do fluxo).

-- 31. pares intra-Lote 1 (ex.: prometazina × hidroxizina, metilergometrina ×
--     oxitocina): os rótulos não documentam interação adversa direta; a associação
--     uterotónica oxitocina+metilergometrina é uso protocolar pós-parto, não
--     interação adversa — ficarão para revisão futura com EMC-UK específico.

-- Pares reais inseridos: 28 (itens 1–28 acima; 29–31 são notas de exclusão).
