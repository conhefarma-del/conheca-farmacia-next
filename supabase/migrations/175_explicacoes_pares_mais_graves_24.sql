-- =====================================================================
-- 175: Fluxo 4 — Explicações longas dos pares de maior relevância clínica
--      da migração 173 (24 fármacos sem pares + 5 parceiros novos)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en +
-- explanation_pt/en) dos 12 pares com maior potencial de dano clínico
-- entre os 36 criados na 173.
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos
--     de risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nos rótulos citados na migração 173
--     (setIDs validados na API DailyMed a 2026-08-17) e no Prontuário
--     Terapêutico do INFARMED.
--
-- Critério de seleção (todos os 36 pares da 173 são severity 'moderate';
-- estes 12 foram escolhidos pelo potencial de dano clínico — hemorragia,
-- nefro/ototoxicidade, hipoglicemia, hepatotoxicidade, arritmias,
-- depressão do SNC, inibição de transportadores e antagonismo aditivo):
--   1. Fondaparinux × Warfarina      (hemorragia aditiva)
--   2. Fondaparinux × Aspirina       (hemorragia aditiva)
--   3. Fondaparinux × Diclofenac     (hemorragia aditiva)
--   4. Cefepima × Gentamicina        (nefro/ototoxicidade)
--   5. Cefepima × Furosemida         (nefrotoxicidade)
--   6. Cefalexina × Metformina       (exposição aumentada → hipoglicemia)
--   7. Tafenoquina × Metformina      (OCT2/MATE — evitar)
--   8. Tizanidina × Famotidina       (CYP1A2 — hipotensão/bradicardia)
--   9. Pirazinamida × Isoniazida     (hepatotoxicidade aditiva)
--  10. Etilefrina × Adrenalina       (simpaticomimético aditivo)
--  11. Memantina × Amantadina        (NMDA aditivo — evitar)
--  12. Ipratrópio × Tiotrópio        (anticolinérgico aditivo)
--
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug —
-- reaplicar é seguro. Aplicar na ordem 173 → 175 (não depende de 174).
-- =====================================================================

-- 1. Fondaparinux × Warfarina (hemorragia aditiva — rótulo FDA 7)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fondaparinux + varfarina: risco hemorrágico aditivo — monitorizar de perto quando a sobreposição de anticoagulantes for necessária.',
  summary_pro_en = 'Fondaparinux + warfarin: additive bleeding risk — monitor closely when anticoagulant overlap is necessary.',
  explanation_pt = 'O rótulo FDA do fondaparinux documenta o aumento do risco hemorrágico quando associado a fármacos que afetam a hemostase (incluindo varfarina, AINEs e antiagregantes). O fondaparinux é um inibidor seletivo do fator Xa e a varfarina antagoniza a síntese dos fatores dependentes da vitamina K: os mecanismos são complementares, pelo que o risco de hemorragia major (incluindo intracraniana e retroperitoneal) é aditivo. A sobreposição é frequente na ponte terapêutica para a varfarina (ex.: TVP/EP), mas exige vigilância ativa: monitorizar sinais de hemorragia, hemoglobina e, na sobreposição prolongada, o INR até atingir o intervalo terapêutico. Os doentes de maior risco são os idosos, os de baixo peso e os com insuficiência renal, que acumulam o fondaparinux. Não há contraindicação absoluta — a combinação é padronizada em protocolos —, mas a dupla anticoagulação deve ser limitada à ponte e monitorizada.',
  explanation_en = 'The FDA fondaparinux label documents the increased bleeding risk when combined with drugs affecting haemostasis (including warfarin, NSAIDs and antiplatelets). Fondaparinux is a selective factor Xa inhibitor and warfarin antagonises the synthesis of vitamin K-dependent factors: the mechanisms are complementary, so the risk of major bleeding (including intracranial and retroperitoneal) is additive. Overlap is common in the therapeutic bridge to warfarin (e.g., DVT/PE), but requires active vigilance: monitor for signs of bleeding, haemoglobin and, during prolonged overlap, INR until the therapeutic range is reached. Higher-risk patients are the elderly, low body weight and renal impairment, which accumulate fondaparinux. There is no absolute contraindication — the combination is standardised in protocols — but dual anticoagulation should be limited to the bridge period and monitored.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fondaparinux (secção 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5c29b4b1-e7e0-4b28-8ea9-e2b103d3d85e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Fondaparinux label (section 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5c29b4b1-e7e0-4b28-8ea9-e2b103d3d85e'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 2. Fondaparinux × Aspirina (hemorragia aditiva — rótulo FDA 7)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fondaparinux + aspirina: risco hemorrágico aditivo (AINEs/antiagregantes) — limitar a associação e vigiar hemorragia.',
  summary_pro_en = 'Fondaparinux + aspirin: additive bleeding risk (NSAIDs/antiplatelets) — limit the combination and monitor for bleeding.',
  explanation_pt = 'O rótulo FDA do fondaparinux adverte que o uso concomitante com fármacos que afetam a hemostase — incluindo AINEs, inibidores da agregação plaquetária e outros anticoagulantes — aumenta o risco de hemorragia. A aspirina inibe irreversivelmente a COX-1 plaquetária e compromete a agregação, enquanto o fondaparinux inibe o fator Xa: a associação soma mecanismos independentes de hemostase e eleva o risco de hemorragia gastrointestinal e de outros locais. Nos doentes com indicação dupla (ex.: síndrome coronária aguda + profilaxia/tromboembolismo), a combinação é por vezes inevitável e é usada com duração limitada. A orientação prática é vigiar sinais de hemorragia (melena, hematúria, queda da hemoglobina) e considerar proteção gástrica no doente de risco, sem suspender o antiagregante sem avaliação cardiovascular.',
  explanation_en = 'The FDA fondaparinux label warns that concomitant use with drugs affecting haemostasis — including NSAIDs, platelet aggregation inhibitors and other anticoagulants — increases the risk of bleeding. Aspirin irreversibly inhibits platelet COX-1 and impairs aggregation, while fondaparinux inhibits factor Xa: the combination adds independent haemostasis mechanisms and raises the risk of gastrointestinal and other-site bleeding. In patients with a dual indication (e.g., acute coronary syndrome + prophylaxis/thromboembolism), the combination is sometimes unavoidable and is used for a limited duration. The practical guidance is to monitor for signs of bleeding (melena, haematuria, haemoglobin drop) and consider gastric protection in at-risk patients, without stopping the antiplatelet without cardiovascular assessment.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fondaparinux (secção 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; rótulo aprovado Aspirina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ac7de91-7d38-4c1d-9c49-b08307b4ecc1',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Fondaparinux label (section 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ac7de91-7d38-4c1d-9c49-b08307b4ecc1'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                        (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                           (SELECT id FROM public.drugs WHERE slug = 'aspirina'));

-- 3. Fondaparinux × Diclofenac (hemorragia aditiva — rótulo FDA 7)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fondaparinux + diclofenac: risco hemorrágico aditivo (AINE) — evitar ou limitar a associação.',
  summary_pro_en = 'Fondaparinux + diclofenac: additive bleeding risk (NSAID) — avoid or limit the combination.',
  explanation_pt = 'O rótulo FDA do fondaparinux inclui explicitamente os AINEs entre os fármacos que aumentam o risco hemorrágico quando usados em concomitância. O diclofenac inibe a COX-1 e a COX-2, reduz a agregação plaquetária e lesa a mucosa gástrica, enquanto o fondaparinux inibe o fator Xa: os mecanismos de hemostase afetados são complementares e o risco de hemorragia gastrointestinal e de outros locais é aditivo. Nos doentes anticoagulados com necessidade de analgesia, devem preferir-se alternativas com menor impacto na hemostase (ex.: paracetamol em doses adequadas) sempre que possível. Se o AINE for inevitável, usar a menor dose e a menor duração, com proteção gástrica no doente de risco e vigilância de sinais de hemorragia.',
  explanation_en = 'The FDA fondaparinux label explicitly includes NSAIDs among the drugs that increase bleeding risk when used concomitantly. Diclofenac inhibits COX-1 and COX-2, reduces platelet aggregation and damages the gastric mucosa, while fondaparinux inhibits factor Xa: the haemostasis mechanisms affected are complementary and the risk of gastrointestinal and other-site bleeding is additive. In anticoagulated patients requiring analgesia, alternatives with less impact on haemostasis (e.g., adequate-dose paracetamol) should be preferred whenever possible. If the NSAID is unavoidable, use the lowest dose and shortest duration, with gastric protection in at-risk patients and monitoring for signs of bleeding.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fondaparinux (secção 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; rótulo aprovado Diclofenac: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=97bd5a1e-5c20-4a1b-9cd1-ccf55b1bf7ce',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Fondaparinux label (section 7 Drug Interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41a37a19-1bf8-4ba0-a12d-dbb6cc8c295c ; approved Diclofenac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=97bd5a1e-5c20-4a1b-9cd1-ccf55b1bf7ce'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                        (SELECT id FROM public.drugs WHERE slug = 'diclofenac'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fondaparinux'),
                           (SELECT id FROM public.drugs WHERE slug = 'diclofenac'));

-- 4. Cefepima × Gentamicina (nefro/ototoxicidade — rótulo FDA 7.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefepima + gentamicina: nefrotoxicidade e ototoxicidade aditivas — monitorizar função renal e sintomas auditivos/vestibulares.',
  summary_pro_en = 'Cefepime + gentamicin: additive nephrotoxicity and ototoxicity — monitor renal function and auditory/vestibular symptoms.',
  explanation_pt = 'O rótulo FDA da cefepima documenta na secção de interações que os aminoglicosídeos aumentam o potencial de nefrotoxicidade e ototoxicidade, com recomendação de monitorização da função renal. A gentamicina acumula-se no córtex renal e no ouvido interno; a associação com uma cefalosporina de 4.ª geração é frequente na terapêutica empírica de infeções graves (ex.: neutropenia febril, sépsis), pelo que o risco aditivo é clinicamente comum. A monitorização deve incluir creatinina e débito urinário, e vigilância de tinitus, hipoacusia e vertigem — sinais de ototoxicidade por vezes irreversíveis. No idoso e no doente renal, considerar a redução do intervalo da gentamicina e, quando disponível, monitorização de níveis séricos do aminoglicosídeo.',
  explanation_en = 'The FDA cefepime label documents in the interactions section that aminoglycosides increase the potential for nephrotoxicity and ototoxicity, with a recommendation to monitor renal function. Gentamicin accumulates in the renal cortex and the inner ear; combining it with a fourth-generation cephalosporin is common in empirical therapy of severe infections (e.g., febrile neutropenia, sepsis), so the additive risk is clinically frequent. Monitoring should include creatinine and urine output, and watch for tinnitus, hearing loss and vertigo — signs of sometimes irreversible ototoxicity. In the elderly and renally impaired, consider extending the gentamicin interval and, when available, monitoring aminoglycoside serum levels.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefepima (secção 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; rótulo aprovado Gentamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=441b6232-bb60-40ad-85ec-7c41ba43fd5f',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefepime label (section 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; approved Gentamicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=441b6232-bb60-40ad-85ec-7c41ba43fd5f'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                        (SELECT id FROM public.drugs WHERE slug = 'gentamicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                           (SELECT id FROM public.drugs WHERE slug = 'gentamicina'));

-- 5. Cefepima × Furosemida (nefrotoxicidade — rótulo FDA 7.3)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefepima + furosemida: nefrotoxicidade reportada com diuréticos potentes — monitorizar função renal.',
  summary_pro_en = 'Cefepime + furosemide: nephrotoxicity reported with potent diuretics — monitor renal function.',
  explanation_pt = 'O rótulo FDA da cefepima documenta que foi reportada nefrotoxicidade após administração concomitante de outras cefalosporinas com diuréticos potentes como a furosemida, com recomendação de monitorização da função renal. O mecanismo é multifatorial: a depleção volémica induzida pelo diurético reduz a perfusão renal e a autorregulação glomerular, aumentando a exposição tubular à cefalosporina. O risco é maior no idoso, no doente desidratado e no internado, sobretudo com doses elevadas do diurético. A monitorização deve incluir creatinina, débito urinário e balanço hídrico; manter hidratação adequada reduz o risco de lesão renal associada.',
  explanation_en = 'The FDA cefepime label documents that nephrotoxicity has been reported after concomitant administration of other cephalosporins with potent diuretics such as furosemide, with a recommendation to monitor renal function. The mechanism is multifactorial: diuretic-induced volume depletion reduces renal perfusion and glomerular autoregulation, increasing tubular exposure to the cephalosporin. The risk is higher in the elderly, dehydrated and hospitalised patients, especially with high diuretic doses. Monitoring should include creatinine, urine output and fluid balance; maintaining adequate hydration reduces the risk of associated renal injury.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefepima (secção 7.3): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; rótulo aprovado Furosemida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefepime label (section 7.3): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; approved Furosemide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                        (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                           (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 6. Cefalexina × Metformina (exposição aumentada → hipoglicemia — rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefalexina + metformina: a cefalexina aumenta as concentrações de metformina — vigiar hipoglicemia no doente diabético.',
  summary_pro_en = 'Cephalexin + metformin: cephalexin increases metformin concentrations — monitor for hypoglycaemia in the diabetic patient.',
  explanation_pt = 'O rótulo FDA da cefalexina documenta: "Metformin: increased metformin concentrations. Monitor for hypoglycemia" (secção 7.1). A cefalexina compete com a metformina pela secreção tubular renal através do transportador OCT2, reduzindo a eliminação da metformina e aumentando a sua exposição sistémica. No doente diabético em metformina, uma antibioterapia com cefalexina pode traduzir-se em níveis mais elevados do antidiabético e risco aumentado de hipoglicemia — sobretudo em doentes com função renal limítrofe ou jejuns prolongados. A orientação prática é advertir para os sintomas de hipoglicemia (sudorese, tremor, confusão) e considerar monitorização glicémica mais frequente durante a antibioterapia.',
  explanation_en = 'The FDA cephalexin label documents: "Metformin: increased metformin concentrations. Monitor for hypoglycemia" (section 7.1). Cephalexin competes with metformin for renal tubular secretion via the OCT2 transporter, reducing metformin elimination and increasing its systemic exposure. In the diabetic patient on metformin, cephalexin antibiotic therapy may translate into higher antidiabetic levels and increased risk of hypoglycaemia — especially in patients with borderline renal function or prolonged fasting. The practical guidance is to warn about hypoglycaemia symptoms (sweating, tremor, confusion) and consider more frequent glucose monitoring during antibiotic therapy.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefalexina (secção 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=553485f8-890d-4929-a6bb-905221cf411d ; rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=34496b43-05a2-45fb-a769-52b12e099341',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cephalexin label (section 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=553485f8-890d-4929-a6bb-905221cf411d ; approved Metformin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=34496b43-05a2-45fb-a769-52b12e099341'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefalexina'),
                        (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefalexina'),
                           (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- 7. Tafenoquina × Metformina (OCT2/MATE — rótulo FDA 7.1, evitar)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tafenoquina + metformina: a tafenoquina inibe OCT2/MATE e aumenta a exposição à metformina — evitar a associação.',
  summary_pro_en = 'Tafenoquine + metformin: tafenoquine inhibits OCT2/MATE and increases metformin exposure — avoid the combination.',
  explanation_pt = 'O rótulo FDA da tafenoquina documenta que deve ser evitada a co-administração com substratos dos transportadores OCT2/MATE (ex.: dofetilida, metformina); se inevitável, monitorizar toxicidades relacionadas e considerar redução da dose (secção 7.1). A metformina depende da secreção tubular via OCT2 e MATE para a sua eliminação; a inibição destes transportadores pela tafenoquina eleva as concentrações plasmáticas da metformina. O risco clínico é o da toxicidade da metformina — sintomas gastrointestinais, função renal e, em casos raros, acidose láctica, sobretudo se já existir compromisso renal. Como a tafenoquina se usa em esquema curto (dose única na profilaxia da malária), o ideal é evitar a associação no dia da toma; se inevitável, monitorizar e considerar ajuste.',
  explanation_en = 'The FDA tafenoquine label documents that co-administration with OCT2/MATE transporter substrates (e.g., dofetilide, metformin) should be avoided; if unavoidable, monitor for related toxicities and consider dose reduction (section 7.1). Metformin depends on tubular secretion via OCT2 and MATE for its elimination; inhibition of these transporters by tafenoquine raises metformin plasma concentrations. The clinical risk is metformin toxicity — gastrointestinal symptoms, renal function and, in rare cases, lactic acidosis, especially if renal impairment already exists. As tafenoquine is used in a short regimen (single dose in malaria prophylaxis), the ideal is to avoid the combination on the day of administration; if unavoidable, monitor and consider adjustment.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tafenoquina (ARAKODA, secção 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=299e49d8-470f-4779-a010-4a1ee0e0c6cd ; rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=34496b43-05a2-45fb-a769-52b12e099341',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Tafenoquine label (ARAKODA, section 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=299e49d8-470f-4779-a010-4a1ee0e0c6cd ; approved Metformin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=34496b43-05a2-45fb-a769-52b12e099341'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'tafenoquina'),
                        (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tafenoquina'),
                           (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- 8. Tizanidina × Famotidina (CYP1A2 — rótulo FDA 7.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tizanidina + famotidina: inibição do CYP1A2 pela famotidina pode aumentar a exposição à tizanidina — vigiar hipotensão, bradicardia e sonolência.',
  summary_pro_en = 'Tizanidine + famotidine: CYP1A2 inhibition by famotidine may increase tizanidine exposure — monitor for hypotension, bradycardia and drowsiness.',
  explanation_pt = 'O rótulo FDA da tizanidina documenta que os inibidores moderados ou fracos do CYP1A2 devem ser evitados em concomitância (secção 7.2), podendo causar hipotensão, bradicardia ou sonolência excessiva; a famotidina é um inibidor conhecido do CYP1A2. A tizanidina é metabolizada predominantemente por esta enzima (biodisponibilidade oral de ~40% por efeito de primeira passagem): a inibição do CYP1A2 eleva as concentrações plasmáticas do relaxante muscular e potencia os seus efeitos adversos centrais e cardiovasculares. A associação é frequente em doentes com espasticidade e dispepsia/DRGE, pelo que a vigilância clínica é importante nas primeiras semanas. Se surgirem reações adversas, reduzir a dose da tizanidina ou suspender um dos fármacos; evitar a associação sempre que houver alternativa.',
  explanation_en = 'The FDA tizanidine label documents that moderate or weak CYP1A2 inhibitors should be avoided concomitantly (section 7.2), as they may cause hypotension, bradycardia or excessive drowsiness; famotidine is a known CYP1A2 inhibitor. Tizanidine is metabolised predominantly by this enzyme (oral bioavailability of ~40% due to first-pass effect): CYP1A2 inhibition raises plasma concentrations of the muscle relaxant and potentiates its central and cardiovascular adverse effects. The combination is common in patients with spasticity and dyspepsia/GERD, so clinical vigilance is important in the first weeks. If adverse reactions occur, reduce the tizanidine dose or stop one of the drugs; avoid the combination whenever there is an alternative.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina (secção 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b ; rótulo aprovado Famotidina (TEVA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Tizanidine label (section 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b ; approved Famotidine label (TEVA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'tizanidina'),
                        (SELECT id FROM public.drugs WHERE slug = 'famotidina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tizanidina'),
                           (SELECT id FROM public.drugs WHERE slug = 'famotidina'));

-- 9. Pirazinamida × Isoniazida (hepatotoxicidade aditiva — Prontuário 1.1.12)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Pirazinamida + isoniazida: hepatotoxicidade aditiva — monitorizar função hepática e sinais de lesão.',
  summary_pro_en = 'Pyrazinamide + isoniazid: additive hepatotoxicity — monitor liver function and signs of injury.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da pirazinamida que a associação com a isoniazida potencia o risco de hepatotoxicidade (secção 1.1.12). Ambos os fármacos são hepatotóxicos — a isoniazida por metabolitos reativos do CYP2E1/NAT2 e a pirazinamida por mecanismo dose-dependente — e a associação é o regime de primeira linha da tuberculose, pelo que o risco aditivo é uma preocupação clínica central no tratamento. A vigilância inclui a monitorização de aminotransferases (basal e periódica), especialmente nas primeiras semanas e no doente com fatores de risco (idade avançada, álcool, doença hepática prévia, hepatite B/C). Perante sintomas (náuseas, icterícia, fadiga) ou elevação de transaminases, suspender os hepatotóxicos e reavaliar. A tuberculose é tratável e o regime não deve ser interrompido sem orientação especializada.',
  explanation_en = 'The Prontuário Terapêutico documents in the pyrazinamide monograph that the combination with isoniazid potentiates the risk of hepatotoxicity (section 1.1.12). Both drugs are hepatotoxic — isoniazid via reactive CYP2E1/NAT2 metabolites and pyrazinamide by a dose-dependent mechanism — and the combination is the first-line tuberculosis regimen, so the additive risk is a central clinical concern in treatment. Surveillance includes monitoring of aminotransferases (baseline and periodic), especially in the first weeks and in patients with risk factors (advanced age, alcohol, prior liver disease, hepatitis B/C). In the presence of symptoms (nausea, jaundice, fatigue) or transaminase elevation, stop the hepatotoxic drugs and reassess. Tuberculosis is treatable and the regimen should not be interrupted without specialist guidance.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Pirazinamida, 1.1.12 ; rótulo aprovado Isoniazida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=93252cc8-c8d4-401b-bde5-ca8a3b57651e',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Pyrazinamide, 1.1.12 ; approved Isoniazid label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=93252cc8-c8d4-401b-bde5-ca8a3b57651e'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'pirazinamida'),
                        (SELECT id FROM public.drugs WHERE slug = 'isoniazida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'pirazinamida'),
                           (SELECT id FROM public.drugs WHERE slug = 'isoniazida'));

-- 10. Etilefrina × Adrenalina (simpaticomimético aditivo — Prontuário 3.2.4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Etilefrina + adrenalina: potenciação simpaticomimética — risco de taquiarritmias e hipertensão.',
  summary_pro_en = 'Etilefrine + epinephrine: sympathomimetic potentiation — risk of tachyarrhythmias and hypertension.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da etilefrina que a administração simultânea com outras substâncias simpaticomiméticas pode potenciar o efeito (secção 3.2.4). A etilefrina é um simpaticomimético de ação direta e indireta (agonista beta-1 com componente alfa) e a adrenalina estimula recetores alfa e beta: a associação aditiva aumenta o risco de taquicardia, arritmias, hipertensão e isquemia miocárdica. O cenário de risco é sobretudo a administração de adrenalina durante anestesia ou ressuscitação em doentes que tomaram etilefrina (frequentemente usada como descongestionante ou no choque). A orientação prática é evitar a associação de simpaticomiméticos; se inevitável, monitorizar tensão arterial, frequência cardíaca e ritmo, e usar a menor dose eficaz de adrenalina.',
  explanation_en = 'The Prontuário Terapêutico documents in the etilefrine monograph that simultaneous administration with other sympathomimetic substances may potentiate the effect (section 3.2.4). Etilefrine is a direct and indirect sympathomimetic (beta-1 agonist with an alpha component) and epinephrine stimulates alpha and beta receptors: the additive combination increases the risk of tachycardia, arrhythmias, hypertension and myocardial ischaemia. The risk scenario is mainly the administration of epinephrine during anaesthesia or resuscitation in patients who took etilefrine (often used as a decongestant or in shock). The practical guidance is to avoid combining sympathomimetics; if unavoidable, monitor blood pressure, heart rate and rhythm, and use the lowest effective epinephrine dose.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Etilefrina, 3.2.4 ; rótulo aprovado Adrenalina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d75fc4-c386-4c26-8c35-339e5fa2a1e3',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Etilefrine, 3.2.4 ; approved Epinephrine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d75fc4-c386-4c26-8c35-339e5fa2a1e3'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'etilefrina'),
                        (SELECT id FROM public.drugs WHERE slug = 'adrenalina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'etilefrina'),
                           (SELECT id FROM public.drugs WHERE slug = 'adrenalina'));

-- 11. Memantina × Amantadina (NMDA aditivo — rótulo FDA 7.1, evitar)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Memantina + amantadina: antagonismo NMDA aditivo — evitar a associação (risco de toxicidade central).',
  summary_pro_en = 'Memantine + amantadine: additive NMDA antagonism — avoid the combination (risk of central toxicity).',
  explanation_pt = 'O rótulo FDA da memantina documenta que a associação com outros antagonistas NMDA (amantadina, cetamina, dextrometorfano) deve ser evitada (secção 7.1), dado o risco de efeitos aditivos sobre o sistema glutamatérgico. A memantina é um antagonista NMDA de afinidade moderada usado na doença de Alzheimer; a amantadina é um antagonista NMDA fraco e não competitivo usado no Parkinson — a soma dos dois pode potenciar efeitos adversos centrais como confusão, alucinações, sonolência e compromisso psicomotor. A associação é possível em doentes com demência e Parkinson sobrepostos, mas deve ser evitada ou usada com monitorização ativa. Perante sinais de toxicidade central, reduzir ou suspender um dos fármacos.',
  explanation_en = 'The FDA memantine label documents that the combination with other NMDA antagonists (amantadine, ketamine, dextromethorphan) should be avoided (section 7.1), given the risk of additive effects on the glutamatergic system. Memantine is a moderate-affinity NMDA antagonist used in Alzheimer disease; amantadine is a weak non-competitive NMDA antagonist used in Parkinson disease — the sum of the two may potentiate central adverse effects such as confusion, hallucinations, drowsiness and psychomotor impairment. The combination is possible in patients with overlapping dementia and Parkinson, but should be avoided or used with active monitoring. In the presence of signs of central toxicity, reduce or stop one of the drugs.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Memantina (secção 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3350f7d-2e51-4e1a-a6d0-c4f87ea99a56 ; rótulo aprovado Amantadina (GOCOVRI): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Memantine label (section 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3350f7d-2e51-4e1a-a6d0-c4f87ea99a56 ; approved Amantadine label (GOCOVRI): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                        (SELECT id FROM public.drugs WHERE slug = 'amantadina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                           (SELECT id FROM public.drugs WHERE slug = 'amantadina'));

-- 12. Ipratrópio × Tiotrópio (anticolinérgico aditivo — rótulos FDA 7.1/7.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ipratrópio + tiotrópio: efeito anticolinérgico aditivo — evitar a associação de dois anticolinérgicos inalados.',
  summary_pro_en = 'Ipratropium + tiotropium: additive anticholinergic effect — avoid combining two inhaled anticholinergics.',
  explanation_pt = 'Os rótulos FDA do ipratrópio (secção 7.1) e do tiotrópio (secção 7.2) documentam que os anticolinérgicos interagem de forma aditiva com outros medicamentos anticolinérgicos e recomendam evitar a administração com outros fármacos contendo anticolinérgicos. A associação de dois anticolinérgicos inalados (LAMA + SAMA) não acrescenta benefício broncodilatador comprovado e aumenta o risco de efeitos sistémicos anticolinérgicos — boca seca, obstipação, retenção urinária, taquicardia e glaucoma de ângulo fechado, sobretudo no idoso com hipertrofia prostática ou obstipação prévia. A orientação prática é usar apenas um anticolinérgico inalado, escolhendo o mais adequado ao doente; se a associação for inevitável, vigiar os sintomas sistémicos e a função urinária.',
  explanation_en = 'The FDA labels of ipratropium (section 7.1) and tiotropium (section 7.2) document that anticholinergics interact additively with other anticholinergic medications and recommend avoiding administration with other anticholinergic-containing drugs. Combining two inhaled anticholinergics (LAMA + SAMA) adds no proven bronchodilator benefit and increases the risk of systemic anticholinergic effects — dry mouth, constipation, urinary retention, tachycardia and angle-closure glaucoma, especially in the elderly with prostatic hypertrophy or prior constipation. The practical guidance is to use only one inhaled anticholinergic, choosing the most appropriate for the patient; if the combination is unavoidable, monitor systemic symptoms and urinary function.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ipratrópio (secção 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=133cc2ed-f018-4295-b84e-b24382299360 ; rótulo aprovado Tiotrópio (secção 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=496b38ee-45b6-4bb2-a35e-9023c3b73719',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ipratropium label (section 7.1): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=133cc2ed-f018-4295-b84e-b24382299360 ; approved Tiotropium label (section 7.2): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=496b38ee-45b6-4bb2-a35e-9023c3b73719'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ipratropio'),
                        (SELECT id FROM public.drugs WHERE slug = 'tiotropio'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ipratropio'),
                           (SELECT id FROM public.drugs WHERE slug = 'tiotropio'));
