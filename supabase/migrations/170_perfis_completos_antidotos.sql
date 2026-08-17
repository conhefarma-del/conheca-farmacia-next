-- =====================================================================
-- 170 — Perfil completo + farmacologia + 3 dimensões dos 2 fármacos
--        do grupo 17 (Antídotos) criados na 168
-- ---------------------------------------------------------------------
-- Completa a camada editorial dos fármacos novos da 168 (folinato de
-- cálcio, penicilamina): drug_profiles, drug_pharmacology,
-- drug_food_interactions, drug_disease_interactions e
-- drug_pregnancy_info — o mesmo pacote das migrações 137/164/167.
--
-- Fontes (citadas por linha): rótulos aprovados DailyMed/FDA (NIH/NLM),
-- setIDs obtidos e revalidados na API durante a 168 (a 2026-08-17):
--   - Folinato de cálcio (Leading Pharma)  c8102043-79f2-421a-b849-94bac19007a6
--   - Penicilamina (CUPRIMINE, Bausch)     80e736d3-2017-4d68-94b4-38255c3c59c6
-- Números/factos ancorados no texto dos rótulos (ex.: biodisponibilidade
-- oral da levoleucovorina "97% for 25 mg, 75% for 50 mg, and 37% for
-- 100 mg" e Tmax "1.7 hours" após 15 mg; penicilamina "absorbed rapidly
-- but incompletely (40-70%)", pico "1 to 3 hours" e "More than 80% of
-- plasma penicillamine is bound to proteins"). As indicações seguem o
-- Prontuário Terapêutico (INFARMED, 11.ª ed., 2012; secção 17) e os
-- rótulos. Conteúdo autoral (nunca copiado), conforme a metodologia de
-- docs/INTERACOES_FLUXO_PESQUISA.md.
--
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING — reaplicar é seguro.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 168 → 170.
-- =====================================================================

-- =====================================================================
-- Perfis (drug_profiles)
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en, side_effects_pt, side_effects_en,
   precautions_pt, precautions_en, source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.indications_pt, v.indications_en, v.side_effects_pt, v.side_effects_en,
       v.precautions_pt, v.precautions_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('folinato_calcio',
   E'O folinato de cálcio (leucovorina) é uma forma de folato reduzido usado sobretudo como antídoto: protege as células dos efeitos tóxicos do metotrexato e de outros antagonistas do ácido fólico (usados na quimioterapia e em algumas infeções). Também é usado no défice de transporte cerebral de folato (FOLR1-CFTD). É administrado por via oral e só sob orientação médica.',
   E'Calcium folinate (leucovorin) is a reduced folate used mainly as an antidote: it protects cells from the toxic effects of methotrexate and other folic acid antagonists (used in chemotherapy and some infections). It is also used in cerebral folate transport deficiency (FOLR1-CFTD). It is given orally and only under medical supervision.',
   E'Análogo do folato (5-formil-tetrahidrofolato, mistura racémica de levoleucovorina e dextroleucovorina) que contorna o bloqueio da di-hidrofolato reductase (DHFR): permite repor o tetrahidrofolato essencial à síntese de ADN quando o metotrexato ou outros antagonistas do ácido fólico inibem a DHFR. Uso clínico: resgate do metotrexato em doses altas (\"To reduce the toxicity of methotrexate in adult patients with impaired methotrexate elimination\"), toxicidade por antagonistas do ácido fólico/inibidores da DHFR após sobredosagem, e FOLR1-CFTD (\"confirmed variant in the folate receptor 1 gene\"). Rótulo atual (2026) com indicações e secção de interações (7.1/7.2) bem documentadas.',
   E'A folate analogue (5-formyl-tetrahydrofolate, racemic mixture of levoleucovorin and dextroleucovorin) that bypasses dihydrofolate reductase (DHFR) blockade: it restores the tetrahydrofolate essential for DNA synthesis when methotrexate or other folic acid antagonists inhibit DHFR. Clinical use: high-dose methotrexate rescue (\"To reduce the toxicity of methotrexate in adult patients with impaired methotrexate elimination\"), folic acid antagonist/DHFR inhibitor toxicity following overdose, and FOLR1-CFTD (\"confirmed variant in the folate receptor 1 gene\"). Current (2026) label with well-documented indications and interactions section (7.1/7.2).',
   E'• Resgate do metotrexato em doentes adultos com eliminação do metotrexato comprometida (reduz a toxicidade) — rótulo FDA (1.1)\\\\n• Toxicidade por antagonistas do ácido fólico ou inibidores da DHFR após sobredosagem em adultos (1.1)\\\\n• Défice de transporte cerebral de folato com variante confirmada no gene do recetor de folato 1 (FOLR1-CFTD), em adultos e crianças (1.2)\\\\n• Prontuário Terapêutico (secção 17): prevenção e tratamento da toxicidade do metotrexato e de outros antagonistas do ácido fólico',
   E'• Methotrexate rescue in adult patients with impaired methotrexate elimination (reduces toxicity) — FDA label (1.1)\\\\n• Folic acid antagonist or DHFR inhibitor toxicity following overdose in adults (1.1)\\\\n• Cerebral folate transport deficiency with confirmed folate receptor 1 gene variant (FOLR1-CFTD), in adults and children (1.2)\\\\n• Prontuário Terapêutico (section 17): prevention and treatment of methotrexate and other folic acid antagonist toxicity',
   E'• Reações de hipersensibilidade (incluindo reações anafiláticas) — suspender conforme a gravidade\\\\n• Com fluorouracilo: o folinato pode potenciar a toxicidade (enterocolite grave, diarreia e desidratação — mortes relatadas em idosos)\\\\n• Em doentes com défice de meteniltetrahidrofolato sintetase (MTHFS): não recomendado (enzima primária no metabolismo do folinato)',
   E'• Hypersensitivity reactions (including anaphylactic reactions) — discontinue according to severity\\\\n• With fluorouracil: folinate may enhance toxicity (severe enterocolitis, diarrhoea and dehydration — deaths reported in the elderly)\\\\n• In patients with methenyltetrahydrofolate synthetase (MTHFS) deficiency: not recommended (primary enzyme in folinate metabolism)',
   E'• Contraindicado na hipersensibilidade ao folinato (ácido folínico), levoleucovorina, ácido fólico ou qualquer componente\\\\n• NÃO indicado para anemia perniciosa ou outras anemias megaloblásticas por défice de vitamina B12 — risco de progressão neurológica apesar da remissão hematológica (rótulo 1.3)\\\\n• Evitar com trimetoprim-sulfametoxazol (rótulo 7.1)\\\\n• Gravidez: dados não identificaram risco com uso intermitente; a quimioterapia associada pode causar dano fetal\\\\n• Interações: antiepiléticos podem reduzir a eficácia (ver pares)',
   E'• Contraindicated in hypersensitivity to folinate (folinic acid), levoleucovorin, folic acid or any component\\\\n• NOT indicated for pernicious anaemia or other megaloblastic anaemias due to vitamin B12 deficiency — risk of neurological progression despite haematological remission (label 1.3)\\\\n• Avoid with trimethoprim-sulfamethoxazole (label 7.1)\\\\n• Pregnancy: data did not identify risk with intermittent use; associated chemotherapy may cause fetal harm\\\\n• Interactions: antiepileptics may reduce effectiveness (see pairs)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Folinato de cálcio, 17',
   'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium folinate, 17'),

  ('penicilamina',
   E'A penicilamina é um quelante oral usado na doença de Wilson (excesso de cobre), na cistinúria (pedras de cistina) e na artrite reumatóide grave não responsiva à terapêutica convencional. Liga-se aos metais (cobre, ferro, zinco) e à cistina, promovendo a sua eliminação. É um fármaco de vigilância apertada: requer monitorização regular (hemograma, urina, função renal) e nunca deve ser usado na gravidez, exceto em casos muito específicos.',
   E'Penicillamine is an oral chelator used in Wilson disease (copper overload), cystinuria (cystine stones) and severe active rheumatoid arthritis unresponsive to conventional therapy. It binds metals (copper, iron, zinc) and cystine, promoting their elimination. It is a closely monitored drug: it requires regular monitoring (blood count, urine, renal function) and must never be used in pregnancy, except in very specific cases.',
   E'Quelante (3-mercapto-D-valina, \"a chelating agent used in the treatment of Wilson\'s disease\") que forma complexos solúveis com metais pesados e com a cistina, aumentando a sua excreção urinária. Uso clínico: doença de Wilson (\"used in the treatment of Wilson\'s disease\"), cistinúria (\"reduce cystine excretion in cystinuria\") e artrite reumatóide ativa grave não responsiva à terapêutica convencional. Farmacocinética: \"absorbed rapidly but incompletely (40-70%) from the gastrointestinal tract\"; \"peak plasma concentration... occurs 1 to 3 hours after ingestion\"; \"More than 80% of plasma penicillamine is bound to proteins\"; eliminação lenta \"lasting 4 to 6 days\" após paragem; excreção principalmente renal.',
   E'Chelator (3-mercapto-D-valine, \"a chelating agent used in the treatment of Wilson\'s disease\") that forms soluble complexes with heavy metals and with cystine, increasing their urinary excretion. Clinical use: Wilson disease (\"used in the treatment of Wilson\'s disease\"), cystinuria (\"reduce cystine excretion in cystinuria\") and severe active rheumatoid arthritis unresponsive to conventional therapy. Pharmacokinetics: \"absorbed rapidly but incompletely (40-70%) from the gastrointestinal tract\"; \"peak plasma concentration... occurs 1 to 3 hours after ingestion\"; \"More than 80% of plasma penicillamine is bound to proteins\"; slow elimination \"lasting 4 to 6 days\" after discontinuation; mainly renal excretion.',
   E'• Doença de Wilson (excreção do excesso de cobre) — indicação principal do rótulo (\"used in the treatment of Wilson\'s disease\")\\\\n• Cistinúria: reduzir a excreção de cistina e a formação de cálculos (\"reduce cystine excretion in cystinuria\")\\\\n• Artrite reumatóide ativa grave não responsiva à terapêutica convencional\\\\n• Prontuário Terapêutico (secção 17): quelante nas intoxicações por metais pesados (chumbo, mercúrio) e na doença de Wilson',
   E'• Wilson disease (excretion of excess copper) — main label indication (\"used in the treatment of Wilson\'s disease\")\\\\n• Cystinuria: reduce cystine excretion and stone formation (\"reduce cystine excretion in cystinuria\")\\\\n• Severe active rheumatoid arthritis unresponsive to conventional therapy\\\\n• Prontuário Terapêutico (section 17): chelator in heavy metal poisonings (lead, mercury) and Wilson disease',
   E'• Reações de hipersensibilidade (rash, febre, artralgia — síndrome de hipersensibilidade)\\\\n• Anemia aplástica e agranulocitose (potencialmente fatais; não reiniciar após episódio)\\\\n• Danos renais (proteinúria, síndrome nefrótica) e síndrome de Goodpasture (rara)\\\\n• Reações autoimunes: miastenia gravis, lupus eritematoso sistémico induzido, pênfigo\\\\n• Défices nutricionais: pode agravar défices de ferro e de outros metais (quelação)',
   E'• Hypersensitivity reactions (rash, fever, arthralgia — hypersensitivity syndrome)\\\\n• Aplastic anaemia and agranulocytosis (potentially fatal; do not restart after an episode)\\\\n• Renal damage (proteinuria, nephrotic syndrome) and Goodpasture syndrome (rare)\\\\n• Autoimmune reactions: myasthenia gravis, drug-induced systemic lupus erythematosus, pemphigus\\\\n• Nutritional deficiencies: may worsen iron and other metal deficiencies (chelation)',
   E'• Contraindicado na gravidez, exceto doença de Wilson ou cistinúria selecionadas (rótulo: \"Except for the treatment of Wilson\'s disease or certain patients with cystinuria, use of penicillamine during pregnancy is contraindicated\")\\\\n• Não reiniciar em doentes com história de anemia aplástica ou agranulocitose relacionada com penicilamina\\\\n• Não administrar a doentes com artrite reumatóide com história ou evidência de insuficiência renal\\\\n• Lactação: mães em terapêutica não devem amamentar\\\\n• Alimentos, antiácidos e ferro reduzem a absorção — administrar em jejum e separar (ver pares)',
   E'• Contraindicated in pregnancy, except for selected Wilson disease or cystinuria (label: \"Except for the treatment of Wilson\'s disease or certain patients with cystinuria, use of penicillamine during pregnancy is contraindicated\")\\\\n• Do not restart in patients with a history of penicillamine-related aplastic anaemia or agranulocytosis\\\\n• Do not give to rheumatoid arthritis patients with a history or other evidence of renal insufficiency\\\\n• Lactation: mothers on therapy should not nurse\\\\n• Food, antacids and iron reduce absorption — give on an empty stomach and separate (see pairs)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Penicilamina, 17',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Penicillamine, 17')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
        indications_pt, indications_en, side_effects_pt, side_effects_en,
        precautions_pt, precautions_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- Farmacologia (drug_pharmacology)
-- =====================================================================
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en,
   half_life_pt, half_life_en, source_pt, source_en, status)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('folinato_calcio',
   E'Análogo do folato reduzido que repõe o tetrahidrofolato intracelular, permitindo a síntese de ADN e ARN quando a di-hidrofolato reductase está bloqueada por antagonistas do ácido fólico (metotrexato, trimetoprim). A levoleucovorina é o isómero farmacologicamente ativo.',
   E'Reduced folate analogue that restores intracellular tetrahydrofolate, enabling DNA and RNA synthesis when dihydrofolate reductase is blocked by folic acid antagonists (methotrexate, trimethoprim). Levoleucovorin is the pharmacologically active isomer.',
   E'A levoleucovorina, folato reduzido e isómero ativo do folinato (5-formil-tetrahidrofolato), contorna a inibição da DHFR: \"can mitigate the toxic effects of folate antagonists, including methotrexate and other agents that inhibit dihydrofolate reductase (DHFR). Inhibition of DHFR blocks the formation of tetrahydrofolate, an essential cofactor for DNA synthesis and repair\" (rótulo). Na FOLR1-CFTD, aumenta os níveis de 5-MTHF (metabolito ativo do folato).',
   E'Levoleucovorin, a reduced folate and the pharmacologically active isomer of folinate (5-formyl-tetrahydrofolate), bypasses DHFR inhibition: \"can mitigate the toxic effects of folate antagonists, including methotrexate and other agents that inhibit dihydrofolate reductase (DHFR). Inhibition of DHFR blocks the formation of tetrahydrofolate, an essential cofactor for DNA synthesis and repair\" (label). In FOLR1-CFTD it increases 5-MTHF levels (active folate metabolite).',
   E'O folinato é metabolizado a derivados do folato ativos (incluindo 5-MTHF); a levoleucovorina é o isómero ativo e a dextroleucovorina é metabolizada e eliminada. A via metabólica principal envolve a meteniltetrahidrofolato sintetase (MTHFS) — daí a contraindicação relativa na deficiência desta enzima.',
   E'Folinate is metabolised to active folate derivatives (including 5-MTHF); levoleucovorin is the active isomer and dextroleucovorin is metabolised and eliminated. The main metabolic pathway involves methenyltetrahydrofolate synthetase (MTHFS) — hence the relative contraindication in deficiency of this enzyme.',
   E'Após administração oral, a biodisponibilidade aparente da levoleucovorina é de 97% (25 mg), 75% (50 mg) e 37% (100 mg); a da dextroleucovorina é de ~19% (25 mg), 20% (50 mg) e 7% (100 mg). O pico da concentração sérica de folato ocorre em 1,7 horas após uma dose oral de 15 mg (\"time to peak serum folate concentration is 1.7 hours\"). O efeito dos alimentos não foi avaliado; fármaco altamente solúvel e bem absorvido.',
   E'After oral administration, the apparent bioavailability of levoleucovorin is 97% (25 mg), 75% (50 mg) and 37% (100 mg); dextroleucovorin is ~19% (25 mg), 20% (50 mg) and 7% (100 mg). Peak serum folate concentration occurs 1.7 hours after a single oral 15 mg dose (\"time to peak serum folate concentration is 1.7 hours\"). The effect of food has not been evaluated; highly soluble and well absorbed drug.',
   E'Não há meia-vida única documentada no rótulo; o folinato é um pró-folato cuja atividade depende da conversão celular em derivados ativos (levoleucovorina, 5-MTHF), com exposição dose-proporcional até 25 mg e menos que proporcional acima disso.',
   E'No single half-life is documented in the label; folinate is a pro-folate whose activity depends on cellular conversion to active derivatives (levoleucovorin, 5-MTHF), with dose-proportional exposure up to 25 mg and less than proportional above that.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6',
   'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6'),

  ('penicilamina',
   E'Quelante oral que forma complexos solúveis com metais pesados (cobre, chumbo, mercúrio) e com a cistina, aumentando a sua excreção urinária; na artrite reumatóide tem efeito imunomodulador (redução dos reagentes de fase aguda) de mecanismo não totalmente esclarecido.',
   E'Oral chelator that forms soluble complexes with heavy metals (copper, lead, mercury) and with cystine, increasing their urinary excretion; in rheumatoid arthritis it has an immunomodulatory effect (reduction of acute-phase reactants) of not fully clarified mechanism.',
   E'Quelante (\"3-mercapto-D-valine\") cujo grupo tiol liga-se a metais divalentes e trivalentes (cobre na doença de Wilson, chumbo/mercúrio nas intoxicações) e à cistina (formando penicilamina-cisteína dissulfureto mais solúvel, \"penicillamine-cysteine disulfide\"), promovendo a excreção renal. Na artrite reumatóide, modula a resposta imune, reduzindo a atividade da doença.',
   E'Chelator (\"3-mercapto-D-valine\") whose thiol group binds divalent and trivalent metals (copper in Wilson disease, lead/mercury in poisonings) and cystine (forming the more soluble penicillamine-cysteine disulfide), promoting renal excretion. In rheumatoid arthritis it modulates the immune response, reducing disease activity.',
   E'Uma pequena fração da dose é metabolizada no fígado em S-metil-D-penicilamina (\"A small fraction of the dose is metabolized in the liver to S-methyl-D-penicillamine\"); a excreção é principalmente renal, sobretudo como dissulfuretos. Após paragem do tratamento prolongado, há uma fase de eliminação lenta que dura 4 a 6 dias.',
   E'A small fraction of the dose is metabolised in the liver to S-methyl-D-penicillamine (\"A small fraction of the dose is metabolized in the liver to S-methyl-D-penicillamine\"); excretion is mainly renal, chiefly as disulfides. After stopping prolonged treatment there is a slow elimination phase lasting 4 to 6 days.',
   E'Absorção rápida mas incompleta (40–70%) do trato gastrointestinal (\"absorbed rapidly but incompletely (40-70%) from the gastrointestinal tract\"), com grande variação interindividual. O pico plasmático ocorre 1 a 3 horas após a ingestão (~1–2 mg/L após 250 mg orais). Alimentos, antiácidos e ferro reduzem a absorção.',
   E'Rapid but incomplete absorption (40–70%) from the GI tract (\"absorbed rapidly but incompletely (40-70%) from the gastrointestinal tract\"), with wide inter-individual variation. Peak plasma concentration occurs 1 to 3 hours after ingestion (~1–2 mg/L after an oral 250 mg dose). Food, antacids and iron reduce absorption.',
   E'Mais de 80% da penicilamina plasmática liga-se a proteínas (\"More than 80% of plasma penicillamine is bound to proteins, especially albumin and ceruloplasmin\"); liga-se também a eritrócitos e macrófagos. Não há meia-vida plasmática única — a eliminação é bifásica, com fase terminal lenta de 4 a 6 dias.',
   E'More than 80% of plasma penicillamine is bound to proteins (\"More than 80% of plasma penicillamine is bound to proteins, especially albumin and ceruloplasmin\"); it also binds erythrocytes and macrophages. There is no single plasma half-life — elimination is biphasic, with a slow terminal phase of 4 to 6 days.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
        metabolism_pt, metabolism_en, absorption_pt, absorption_en,
        half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- Alimento / Bebida (drug_food_interactions)
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('folinato_calcio', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   E'O rótulo indica que o efeito dos alimentos na farmacocinética do folinato não foi avaliado; sendo um fármaco altamente solúvel e bem absorvido, não estão documentadas interações alimentares relevantes.',
   E'The label states that the effect of food on folinate pharmacokinetics has not been evaluated; as a highly soluble and well absorbed drug, no relevant food interactions are documented.',
   E'Pode ser tomado com ou sem alimentos; manter a mesma rotina de toma.',
   E'May be taken with or without food; keep the same dosing routine.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 1),
  ('penicilamina', 'toma_em_jejum', 'Toma em jejum', 'Empty-stomach intake', 'moderate',
   E'O rótulo FDA documenta: \"Food, antacids, and iron reduce absorption of the drug\" — a toma com alimentos reduz a absorção da penicilamina (40–70% sem alimentos, com variação interindividual).',
   E'The FDA label documents: \"Food, antacids, and iron reduce absorption of the drug\" — taking with food reduces penicillamine absorption (40–70% without food, with inter-individual variation).',
   E'Administrar a penicilamina em jejum, 1 hora antes ou 2 horas depois das refeições, e separar dos antiácidos e do ferro por pelo menos 2 horas.',
   E'Give penicillamine on an empty stomach, 1 hour before or 2 hours after meals, and separate from antacids and iron by at least 2 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
        mechanism_pt, mechanism_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- Doença / Condição (drug_disease_interactions)
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
  ('folinato_calcio', 'gravidez', 'Gravidez', 'Pregnancy', 'precaution', 'moderate',
   E'O rótulo indica que os dados disponíveis sobre o uso intermitente do folinato na gravidez não identificaram risco associado de malformações major ou aborto; contudo, a quimioterapia administrada em associação pode causar dano fetal (\"Risks with Concomitant Use of leucovorin and Chemotherapy Drugs administered in combination with leucovorin may cause fetal harm\").',
   E'The label states that available data on the intermittent use of folinate during pregnancy have not identified an associated risk of major birth defects or miscarriage; however, chemotherapy administered in combination may cause fetal harm (\"Risks with Concomitant Use of leucovorin and Chemotherapy Drugs administered in combination with leucovorin may cause fetal harm\").',
   E'Usar apenas quando o benefício justifica o risco; considerar os riscos da quimioterapia associada (consultar a informação de prescrição do citotóxico).',
   E'Use only when the benefit justifies the risk; consider the risks of the associated chemotherapy (consult the cytotoxic prescribing information).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 1),
  ('folinato_calcio', 'anemia_nao_diagnosticada', 'Anemia sem diagnóstico etiológico', 'Anaemia without etiologic diagnosis', 'contraindication', 'moderate',
   E'O rótulo é explícito: o folinato \"is not indicated for the treatment of pernicious anemia or other megaloblastic anemias, due to the lack of vitamin B12, because of the risk of progression of neurologic manifestations despite hematologic remission\" — usar em anemia megaloblástica por défice de B12 mascararia a remissão hematológica e permitiria a progressão neurológica.',
   E'The label is explicit: folinate \"is not indicated for the treatment of pernicious anemia or other megaloblastic anemias, due to the lack of vitamin B12, because of the risk of progression of neurologic manifestations despite hematologic remission\" — using it in B12-deficient megaloblastic anaemia would mask haematological remission and allow neurological progression.',
   E'Excluir défice de vitamina B12 antes de usar folinato em anemias megaloblásticas; não usar como terapêutica da anemia perniciosa.',
   E'Exclude vitamin B12 deficiency before using folinate in megaloblastic anaemias; do not use as therapy for pernicious anaemia.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6', 2),
  ('penicilamina', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'Teratogénica — \"Penicillamine can cause fetal harm when administered to a pregnant woman... teratogenic in rats... Skeletal defects, cleft palates, and fetal toxicity (resorptions) have been reported\" e cutis laxa congénita em recém-nascidos de mães tratadas. Exceção: doença de Wilson ou cistinúria selecionadas (\"Except for the treatment of Wilson\'s disease or certain patients with cystinuria, use of penicillamine during pregnancy is contraindicated\").',
   E'Teratogenic — \"Penicillamine can cause fetal harm when administered to a pregnant woman... teratogenic in rats... Skeletal defects, cleft palates, and fetal toxicity (resorptions) have been reported\" and congenital cutis laxa in infants of treated mothers. Exception: selected Wilson disease or cystinuria (\"Except for the treatment of Wilson\'s disease or certain patients with cystinuria, use of penicillamine during pregnancy is contraindicated\").',
   E'Contraindicada na gravidez, exceto doença de Wilson/cistinúria selecionadas; informar a doente do risco, pedir relato imediato de atraso menstrual e seguir de perto para reconhecimento precoce da gravidez.',
   E'Contraindicated in pregnancy, except selected Wilson disease/cystinuria; inform the patient of the risk, request immediate reporting of missed menses and follow closely for early pregnancy recognition.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 1),
  ('penicilamina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal insufficiency', 'contraindication', 'moderate',
   E'O rótulo: \"Because of its potential for causing renal damage, penicillamine should not be administered to rheumatoid arthritis patients with a history or other evidence of renal insufficiency\" — risco de lesão renal adicional e excreção comprometida do fármaco e dos complexos quelados.',
   E'The label: \"Because of its potential for causing renal damage, penicillamine should not be administered to rheumatoid arthritis patients with a history or other evidence of renal insufficiency\" — risk of additional renal injury and impaired excretion of the drug and chelated complexes.',
   E'Não administrar a doentes com artrite reumatóide com insuficiência renal (história ou evidência); avaliar função renal antes e periodicamente durante o tratamento.',
   E'Do not give to rheumatoid arthritis patients with renal insufficiency (history or evidence); assess renal function before and periodically during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 2),
  ('penicilamina', 'agranulocitose_historico', 'Agranulocitose prévia', 'Previous agranulocytosis', 'contraindication', 'critical',
   E'O rótulo: \"Patients with a history of penicillamine-related aplastic anemia or agranulocytosis should not be restarted on penicillamine\" — reiniciar após anemia aplástica ou agranulocitose relacionada com penicilamina é contraindicado pelo risco de recorrência fatal.',
   E'The label: \"Patients with a history of penicillamine-related aplastic anemia or agranulocytosis should not be restarted on penicillamine\" — restarting after penicillamine-related aplastic anaemia or agranulocytosis is contraindicated due to the risk of fatal recurrence.',
   E'Não reiniciar penicilamina após episódio de anemia aplástica ou agranulocitose relacionada; monitorizar hemograma regularmente durante o tratamento.',
   E'Do not restart penicillamine after an episode of related aplastic anaemia or agranulocytosis; monitor blood count regularly during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6', 3)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- Gestação / Lactação (drug_pregnancy_info, 1:1 por fármaco)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('folinato_calcio', 'caution',
   E'Dados sobre o uso intermitente na gravidez não identificaram risco associado de malformações major, aborto ou resultados materno-fetais adversos; não há dados adequados para o uso na FOLR1-CFTD em grávidas e não foram conduzidos estudos reprodutivos animais adequados (rótulo, secção 8.1). A quimioterapia associada pode causar dano fetal.',
   E'Data on intermittent use during pregnancy have not identified an associated risk of major birth defects, miscarriage or adverse maternal or fetal outcomes; there are no adequate data on use for FOLR1-CFTD in pregnant women and adequate animal reproductive studies have not been conducted (label, section 8.1). Associated chemotherapy may cause fetal harm.',
   E'Sem risco documentado com o uso intermitente; avaliar o risco-benefício, considerando a quimioterapia associada.',
   E'No documented risk with intermittent use; assess risk-benefit, considering the associated chemotherapy.',
   E'Sem dados sobre a presença na leite materno, efeitos no lactente ou na produção de leite (\"There are no data on the presence of leucovorin in human milk\") — ponderar benefícios da amamentação e necessidade clínica da mãe.',
   E'No data on presence in breast milk, effects on the breastfed infant or on milk production (\"There are no data on the presence of leucovorin in human milk\") — weigh breastfeeding benefits and the mother\'s clinical need.',
   E'No contexto oncológico, seguir as recomendações de contraceção do esquema de quimioterapia associado.',
   E'In the oncology setting, follow the contraception recommendations of the associated chemotherapy regimen.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6',
   'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6'),

  ('penicilamina', 'contraindicated',
   E'Teratogénica — \"Penicillamine can cause fetal harm when administered to a pregnant woman\" (rótulo): teratogénica em ratos (doses 6× superiores às recomendadas), defeitos esqueléticos, fenda palatina, toxicidade fetal (reabsorções) e cutis laxa congénita com malformações associadas em recém-nascidos de mães tratadas. Exceção: doença de Wilson ou cistinúria selecionadas (rótulo).',
   E'Teratogenic — \"Penicillamine can cause fetal harm when administered to a pregnant woman\" (label): teratogenic in rats (doses 6× the highest recommended human dose), skeletal defects, cleft palates, fetal toxicity (resorptions) and congenital cutis laxa with associated birth defects in infants of treated mothers. Exception: selected Wilson disease or cystinuria (label).',
   E'Contraindicada na gravidez, exceto doença de Wilson/cistinúria selecionadas; em mulheres em idade fértil, usar apenas quando o benefício esperado supera os riscos.',
   E'Contraindicated in pregnancy, except selected Wilson disease/cystinuria; in women of childbearing potential use only when the expected benefit outweighs the possible hazards.',
   E'Mães em terapêutica com penicilamina não devem amamentar (\"mothers on therapy with penicillamine should not nurse their infants\").',
   E'Mothers on penicillamine therapy should not nurse their infants (\"mothers on therapy with penicillamine should not nurse their infants\").',
   E'Em mulheres em idade fértil: informar do risco, aconselhar relato imediato de atraso menstrual e considerar teste de gravidez; seguir de perto para reconhecimento precoce.',
   E'In women of childbearing potential: inform of the risk, advise immediate reporting of missed menses and consider pregnancy testing; follow closely for early recognition.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
        lactation_pt, lactation_en, contraception_pt, contraception_en,
        source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
