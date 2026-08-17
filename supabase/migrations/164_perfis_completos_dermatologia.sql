-- =====================================================================
-- 164 — Perfil completo + farmacologia + 3 dimensões dos 4 fármacos
--        do grupo 13 (Dermatologia) criados na 162
-- ---------------------------------------------------------------------
-- Completa a camada editorial dos fármacos novos da 162 (isotretinoína,
-- acitretina, tetraciclina, minociclina): drug_profiles (perfil público +
-- pro), drug_pharmacology (farmacologia), drug_food_interactions,
-- drug_disease_interactions e drug_pregnancy_info — o mesmo pacote que as
-- migrações 137/099–110 entregam para os restantes fármacos. Com esta
-- migração, os 195 fármacos ativos ficam todos com perfil + farmacologia
-- + as 3 dimensões.
--
-- Fontes (citadas por linha): rótulos aprovados DailyMed/FDA (NIH/NLM),
-- setIDs obtidos e revalidados na API durante a 162 (a 2026-08-17):
--   - Isotretinoína (Sotret)  d5a26c5e-9c3e-4781-8c08-62b91d21a68d
--   - Acitretina (USP)        a6546625-acb8-460e-b34e-f795bfb3680a
--   - Tetraciclina (USP)      02e88b4a-57ae-4ef6-ba48-97c657202b94
--   - Minociclina (HCl)       a5fc4d50-50b2-46e0-b722-4c6b2ec47d06
-- Números/factos ancorados no texto dos rótulos (ex.: "half-life of 90
-- hours" da isotretinoína; "elimination half-life of 49 hours" e "3 years
-- following discontinuation" da acitretina; "11 to 16 hours" da
-- minociclina; "permanent discoloration of the teeth... to the age of 8
-- years" das tetraciclinas). Conteúdo autoral (nunca copiado), conforme
-- a metodologia de docs/INTERACOES_FLUXO_PESQUISA.md.
--
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING — reaplicar é seguro.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 162 → 164.
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
  ('isotretinoina',
   E'A isotretinoína é um retinóide oral usado apenas na acne nodular grave que não respondeu a outros tratamentos. Atua reduzindo a produção de sebo e o tamanho das glândulas sebáceas, secando a pele de dentro para fora. É um medicamento com efeitos adversos significativos — sobretudo teratogenicidade grave — pelo que exige acompanhamento médico apertado e, em mulheres em idade fértil, programa de prevenção de gravidez obrigatório.',
   E'Isotretinoin is an oral retinoid reserved for severe nodular acne that has not responded to other treatments. It works by reducing sebum production and sebaceous gland size, drying the skin from within. It is a medicine with significant adverse effects — above all severe teratogenicity — so it requires close medical supervision and, in women of childbearing potential, a mandatory pregnancy prevention programme.',
   E'Retinóide sistémico derivado da vitamina A (ácido 13-cis-retinóico) indicado na acne nodular recalcitrante grave ("severe recalcitrant nodular acne"), reservado a doentes sem resposta à terapêutica convencional. Reduz a atividade das glândulas sebáceas (tamanho e produção de sebo), normaliza a queratinização folicular e tem ação anti-inflamatória. Altamente teratogénico — "extremely high risk that severe birth defects will result if pregnancy occurs" (rótulo) — e por isso comercializado sob programa restrito de distribuição.',
   E'Systemic retinoid derived from vitamin A (13-cis-retinoic acid) indicated for severe recalcitrant nodular acne, reserved for patients unresponsive to conventional therapy. Reduces sebaceous gland activity (size and sebum production), normalises follicular keratinisation and has anti-inflammatory action. Highly teratogenic — "extremely high risk that severe birth defects will result if pregnancy occurs" (label) — hence marketed under a restricted distribution programme.',
   E'• Acne nodular grave recalcitrante (nódulos ≥ 5 mm, muitos, não responsivos à terapêutica convencional)',
   E'• Severe recalcitrant nodular acne (nodules ≥ 5 mm, numerous, unresponsive to conventional therapy)',
   E'• Pele e mucosas secas (queilite, xerose, epistaxe, olhos secos) — os mais frequentes\\n• Aumento de triglicerídeos e colesterol (vigiar perfil lipídico)\\n• Alterações hepáticas (transaminases)\\n• Dores musculares e articulares\\n• Fotossensibilidade\\n• Risco de depressão, ideação suicida e alterações de humor — vigiar\\n• Pseudotumor cerebri (hipertensão intracraneana benigna) — sobretudo com tetraciclinas concomitantes',
   E'• Dry skin and mucous membranes (cheilitis, xerosis, epistaxis, dry eyes) — most common\\n• Raised triglycerides and cholesterol (monitor lipid profile)\\n• Hepatic changes (transaminases)\\n• Muscle and joint pain\\n• Photosensitivity\\n• Risk of depression, suicidal ideation and mood changes — monitor\\n• Pseudotumor cerebri (benign intracranial hypertension) — especially with concomitant tetracyclines',
   E'• CONTRAINDICADO na gravidez e em mulheres que possam engravidar sem contraceção fiável (teratogenicidade grave — "severe birth defects")\\n• Evitar associação com tetraciclinas (risco de pseudotumor cerebri — "concomitant use of tetracyclines should therefore be avoided")\\n• Evitar suplementos de vitamina A (efeitos aditivos)\\n• Doação de sangue proibida durante o tratamento e 1 mês após\\n• Vigiar triglicerídeos, transaminases e humor; usar contraceção eficaz 1 mês antes, durante e 1 mês após (programa iPledge nos EUA)',
   E'• CONTRAINDICATED in pregnancy and in women who may become pregnant without reliable contraception (severe teratogenicity — "severe birth defects")\\n• Avoid combination with tetracyclines (risk of pseudotumor cerebri — "concomitant use of tetracyclines should therefore be avoided")\\n• Avoid vitamin A supplements (additive effects)\\n• Blood donation prohibited during treatment and for 1 month after\\n• Monitor triglycerides, transaminases and mood; use effective contraception 1 month before, during and 1 month after (iPledge programme in the US)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d',
   'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d'),

  ('acitretina',
   E'A acitretina é um retinóide oral usado na psoríase grave em adultos. Normaliza o crescimento e a maturação das células da pele, reduzindo as placas. Tem efeitos adversos importantes e, tal como os outros retinóides, é altamente teratogénica: não pode ser usada na gravidez nem nos 3 anos seguintes à suspensão do tratamento.',
   E'Acitretin is an oral retinoid used for severe psoriasis in adults. It normalises the growth and maturation of skin cells, reducing plaques. It has important adverse effects and, like other retinoids, is highly teratogenic: it cannot be used in pregnancy nor for 3 years after stopping treatment.',
   E'Retinóide sistémico (derivado da vitamina A) indicado na psoríase grave do adulto ("severe psoriasis in adults"), reservado a prescritores com experiência no uso sistémico de retinóides. Normaliza a proliferação e diferenciação dos queratinócitos e tem atividade anti-inflamatória e imunomoduladora. Metabolito do etretinato; teratogénico em coelhos, ratos e murganhos — contraceção obrigatória durante e 3 anos após o tratamento (meia-vida de eliminação de 49 h, com metabolitos de meia-vida prolongada).',
   E'Systemic retinoid (vitamin A derivative) indicated for severe psoriasis in adults, reserved for prescribers experienced in systemic retinoid use. Normalises keratinocyte proliferation and differentiation and has anti-inflammatory and immunomodulatory activity. A metabolite of etretinate; teratogenic in rabbits, mice and rats — contraception mandatory during and for 3 years after treatment (elimination half-life of 49 h, with long-lived metabolites).',
   E'• Psoríase grave no adulto (incluindo eritrodérmica e pustulosa), quando outras terapêuticas não são adequadas',
   E'• Severe psoriasis in adults (including erythrodermic and pustular forms), when other therapies are not appropriate',
   E'• Queilite e secura das mucosas e da pele (os mais frequentes)\\n• Alopecia, descamação palmoplantar, unhas frágeis\\n• Aumento de triglicerídeos e colesterol\\n• Alterações hepáticas (transaminases) — risco de hepatotoxicidade\\n• Dores musculares e articulares, rigidez\\n• Fotossensibilidade\\n• Cefaleias (incluindo sinais de pseudotumor cerebri)',
   E'• Cheilitis and dryness of mucous membranes and skin (most common)\\n• Alopecia, palmoplantar peeling, brittle nails\\n• Raised triglycerides and cholesterol\\n• Hepatic changes (transaminases) — risk of hepatotoxicity\\n• Muscle and joint pain, stiffness\\n• Photosensitivity\\n• Headache (including signs of pseudotumor cerebri)',
   E'• CONTRAINDICADO na gravidez e em mulheres que possam engravidar — contraceção fiável durante e pelo menos 3 anos após a suspensão ("at least 3 years following discontinuation of therapy")\\n• CONTRAINDICADO com metotrexato (risco de hepatite — "combined use of methotrexate and etretinate... contraindicated")\\n• CONTRAINDICADO com tetraciclinas (pressão intracraneana aumentada)\\n• Evitar álcool (aumenta o risco de teratogenicidade — converte-se em etretinato)\\n• Vigiar transaminases e perfil lipídico; não doar sangue durante e 3 anos após',
   E'• CONTRAINDICATED in pregnancy and in women who may become pregnant — reliable contraception during and for at least 3 years after stopping ("at least 3 years following discontinuation of therapy")\\n• CONTRAINDICATED with methotrexate (risk of hepatitis — "combined use of methotrexate and etretinate... contraindicated")\\n• CONTRAINDICATED with tetracyclines (raised intracranial pressure)\\n• Avoid alcohol (increases teratogenicity risk — converts to etretinate)\\n• Monitor transaminases and lipid profile; do not donate blood during and for 3 years after',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a',
   'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a'),

  ('tetraciclina',
   E'A tetraciclina é um antibiótico oral usado em várias infeções bacterianas (respiratórias, urinárias, acne e outras). Pertence à classe das tetraciclinas, que não devem ser usadas na gravidez nem em crianças até aos 8 anos porque mancham os dentes de forma permanente. Deve ser tomada em jejum, longe de leite, antiácidos, ferro e zinco, que reduzem a sua absorção.',
   E'Tetracycline is an oral antibiotic used for several bacterial infections (respiratory, urinary, acne and others). It belongs to the tetracycline class, which must not be used in pregnancy nor in children up to 8 years of age because it permanently stains teeth. It should be taken on an empty stomach, away from milk, antacids, iron and zinc, which reduce its absorption.',
   E'Antibiótico bacteriostático da classe das tetraciclinas (bacteriostático de largo espectro: Gram-positivos e Gram-negativos, riquétsias, micoplasmas, clamídias). Inibe a síntese proteica bacteriana por ligação reversível à subunidade ribossómica 30S. "Absorption of tetracycline is impaired by antacids containing aluminum, calcium or magnesium and preparations containing iron, zinc or sodium bicarbonate" (rótulo) — quelação com catiões divalentes; "Food and some dairy products also interfere with absorption".',
   E'Bacteriostatic antibiotic of the tetracycline class (broad-spectrum: Gram-positive and Gram-negative, rickettsiae, mycoplasmas, chlamydiae). Inhibits bacterial protein synthesis by reversible binding to the 30S ribosomal subunit. "Absorption of tetracycline is impaired by antacids containing aluminum, calcium or magnesium and preparations containing iron, zinc or sodium bicarbonate" (label) — chelation with divalent cations; "Food and some dairy products also interfere with absorption".',
   E'• Infeções por microrganismos sensíveis: respiratórias, urinárias, pele e tecidos moles, brucelose, cólera, peste, antraz, acne (uso sistémico)\\n• Alternativa em doentes alérgicos a penicilinas (infeções selecionadas)',
   E'• Infections due to susceptible organisms: respiratory, urinary, skin and soft tissue, brucellosis, cholera, plague, anthrax, acne (systemic use)\\n• Alternative in penicillin-allergic patients (selected infections)',
   E'• Perturbações gastrointestinais (náuseas, vómitos, diarreia)\\n• Fotossensibilidade (reação cutânea ao sol)\\n• Coloração amarelo-castanha permanente dos dentes (durante o desenvolvimento dentário)\\n• Candidíase oral/vaginal\\n• Raro: hipertensão intracraneana benigna (pseudotumor cerebri)',
   E'• Gastrointestinal upset (nausea, vomiting, diarrhoea)\\n• Photosensitivity (skin reaction to sun)\\n• Permanent yellow-grey-brown tooth discoloration (during tooth development)\\n• Oral/vaginal candidiasis\\n• Rare: benign intracranial hypertension (pseudotumor cerebri)',
   E'• Contraindicado na gravidez (2.ª metade), na infância até aos 8 anos e na hipersensibilidade às tetraciclinas\\n• "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure" (rótulo)\\n• Não tomar com leite/laticínios, antiácidos, ferro, zinco ou cálcio — separar a toma\\n• Evitar exposição solar prolongada (fotossensibilidade)\\n• Usar com precaução na insuficiência renal (acumulação)',
   E'• Contraindicated in pregnancy (second half), in childhood up to 8 years and in hypersensitivity to tetracyclines\\n• "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure" (label)\\n• Do not take with milk/dairy, antacids, iron, zinc or calcium — separate administration\\n• Avoid prolonged sun exposure (photosensitivity)\\n• Use with caution in renal impairment (accumulation)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94',
   'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94'),

  ('minociclina',
   E'A minociclina é uma tetraciclina semissintética de largo espectro, usada sobretudo na acne moderada a grave e em algumas infeções (respiratórias, urinárias, da pele). Tal como as outras tetraciclinas, não deve ser usada na gravidez nem em crianças até aos 8 anos, e pode causar tonturas, pigmentação e reações de fotossensibilidade.',
   E'Minocycline is a semisynthetic broad-spectrum tetracycline used mainly for moderate to severe acne and some infections (respiratory, urinary, skin). Like other tetracyclines, it must not be used in pregnancy nor in children up to 8 years, and may cause dizziness, pigmentation and photosensitivity reactions.',
   E'Antibiótico da classe das tetraciclinas (semissintético, lipofílico, de largo espectro: Gram-positivos e Gram-negativos, incluindo MRSA e antraz). Inibe a síntese proteica bacteriana por ligação à subunidade ribossómica 30S. A absorção oral é quase completa ("absorption... unchanged compared to dosing under fasting conditions" — alimentos não a reduzem de forma relevante), mas "is impaired by antacids containing aluminum, calcium, or magnesium, and iron-containing preparations" (quelação). Meia-vida de 11–16 h em voluntários normais ("half-life ranged from 11 to 16 hours"), prolongada na disfunção renal (18–69 h).',
   E'Antibiotic of the tetracycline class (semisynthetic, lipophilic, broad-spectrum: Gram-positive and Gram-negative, including MRSA and anthrax). Inhibits bacterial protein synthesis by binding to the 30S ribosomal subunit. Oral absorption is almost complete ("absorption... unchanged compared to dosing under fasting conditions" — food does not reduce it meaningfully), but "is impaired by antacids containing aluminum, calcium, or magnesium, and iron-containing preparations" (chelation). Half-life of 11–16 h in normal volunteers ("half-life ranged from 11 to 16 hours"), prolonged in renal dysfunction (18–69 h).',
   E'• Acne vulgar moderada a grave (uso prolongado)\\n• Infeções respiratórias, urinárias, da pele e tecidos moles por microrganismos sensíveis\\n• Alternativa em infeções selecionadas (ex.: MRSA, antraz) quando indicado',
   E'• Moderate to severe acne vulgaris (long-term use)\\n• Respiratory, urinary, skin and soft-tissue infections due to susceptible organisms\\n• Alternative in selected infections (e.g., MRSA, anthrax) when indicated',
   E'• Tonturas e vertigens (frequentes — por vezes limitam o uso)\\n• Náuseas e perturbações gastrointestinais\\n• Pigmentação cutânea, ungueal, oral e ocular (dose-dependente)\\n• Fotossensibilidade\\n• Coloração dos dentes em crianças até 8 anos\\n• Raro: síndrome de hipersensibilidade (erupção, eosinofilia, envolvimento visceral), hepatite autoimune, pseudotumor cerebri, lúpus induzido por fármaco',
   E'• Dizziness and vertigo (common — sometimes dose-limiting)\\n• Nausea and gastrointestinal upset\\n• Skin, nail, oral and ocular pigmentation (dose-dependent)\\n• Photosensitivity\\n• Tooth discoloration in children up to 8 years\\n• Rare: hypersensitivity syndrome (rash, eosinophilia, visceral involvement), autoimmune hepatitis, pseudotumor cerebri, drug-induced lupus',
   E'• Contraindicado na gravidez (lesão fetal — "can cause fetal harm when administered to a pregnant woman"), na infância até aos 8 anos e na hipersensibilidade às tetraciclinas\\n• "Administration of isotretinoin should be avoided... during... minocycline therapy" (pseudotumor cerebri — rótulo)\\n• Não tomar com antiácidos, ferro, zinco ou cálcio — separar a toma\\n• Precaução na insuficiência renal (acumulação — meia-vida até 69 h) e na doença hepática\\n• Vigiar tonturas (não conduzir se afetado) e pigmentação em tratamentos prolongados',
   E'• Contraindicated in pregnancy (fetal harm — "can cause fetal harm when administered to a pregnant woman"), in childhood up to 8 years and in hypersensitivity to tetracyclines\\n• "Administration of isotretinoin should be avoided... during... minocycline therapy" (pseudotumor cerebri — label)\\n• Do not take with antacids, iron, zinc or calcium — separate administration\\n• Caution in renal impairment (accumulation — half-life up to 69 h) and hepatic disease\\n• Monitor dizziness (do not drive if affected) and pigmentation in long-term treatment',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06',
   'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06')
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
  ('isotretinoina',
   E'Retinóide que reduz a atividade das glândulas sebáceas (tamanho e produção de sebo), normaliza a queratinização folicular e tem efeito anti-inflamatório; é o único fármaco que modifica a doença de base na acne nodular grave.',
   E'Retinoid that reduces sebaceous gland activity (size and sebum production), normalises follicular keratinisation and has anti-inflammatory effect; it is the only drug that modifies the underlying disease in severe nodular acne.',
   E'Atua por ligação aos recetores nucleares do ácido retinóico (RAR), modulando a expressão génica dos queratinócitos e sebócitos: reduz a proliferação e diferenciação dos sebócitos, a produção de sebo e a hiperqueratose folicular, e inibe a quimiotaxia dos neutrófilos.',
   E'Acts through binding to retinoic acid nuclear receptors (RAR), modulating gene expression in keratinocytes and sebocytes: reduces sebocyte proliferation and differentiation, sebum production and follicular hyperkeratosis, and inhibits neutrophil chemotaxis.',
   E'Metabolizado no fígado (isoenzimas do CYP450 — "metabolism are 2C8, 2C9, 3A4, and 2B6") em metabolitos ativos (4-oxo-isotretinoína); a eliminação é hepática e renal, sem acumulação relevante com a dose repetida.',
   E'Metabolised in the liver (CYP450 isoenzymes — "metabolism are 2C8, 2C9, 3A4, and 2B6") to active metabolites (4-oxo-isotretinoin); elimination is hepatic and renal, without relevant accumulation on repeated dosing.',
   E'A absorção oral é aumentada com refeições ricas em gordura (lipofilicidade elevada — "oral absorption of isotretinoin is enhanced when given with a high-fat meal"); a biodisponibilidade é cerca de 25% em jejum, aumentando com a toma após refeição.',
   E'Oral absorption is enhanced with high-fat meals (high lipophilicity — "oral absorption of isotretinoin is enhanced when given with a high-fat meal"); bioavailability is about 25% fasting, increasing when taken after a meal.',
   E'Meia-vida de eliminação de cerca de 21 horas ("elimination half-lives (t 1/2 ) of isotretinoin and 4-oxo-isotretinoin were 21... hours"); o metabolito 4-oxo tem meia-vida de cerca de 90 horas.',
   E'Elimination half-life of about 21 hours ("elimination half-lives (t 1/2 ) of isotretinoin and 4-oxo-isotretinoin were 21... hours"); the 4-oxo metabolite has a half-life of about 90 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d',
   'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d'),

  ('acitretina',
   E'Normaliza a proliferação e diferenciação dos queratinócitos epidérmicos (hiperproliferação da psoríase) e modula a resposta inflamatória cutânea; induz a diferenciação terminal das células epidérmicas.',
   E'Normalises epidermal keratinocyte proliferation and differentiation (psoriatic hyperproliferation) and modulates cutaneous inflammatory response; induces terminal differentiation of epidermal cells.',
   E'Retinóide aromático que se liga aos recetores nucleares do ácido retinóico (RAR), regulando a transcrição de genes envolvidos no crescimento, diferenciação e queratinização celular; reduz a proliferação dos queratinócitos e a inflamação.',
   E'Aromatic retinoid that binds to retinoic acid nuclear receptors (RAR), regulating transcription of genes involved in cell growth, differentiation and keratinisation; reduces keratinocyte proliferation and inflammation.',
   E'Metabolizado por isomerização simples em 13-cis-acitretina ("metabolism and interconversion by simple isomerization to its 13-cis form (cis-acitretin)"); o etretinato (metabolito de meia-vida muito longa — 120 dias) pode formar-se com o álcool — daí a proibição de álcool durante o tratamento.',
   E'Metabolised by simple isomerisation to 13-cis-acitretin ("metabolism and interconversion by simple isomerization to its 13-cis form (cis-acitretin)"); etretinate (a very long-lived metabolite — 120 days) may form with alcohol — hence the prohibition of alcohol during treatment.',
   E'A absorção oral é ótima com alimentos ("Oral absorption of acitretin is optimal when given with food") e é linear e proporcional para doses de 25 a 100 mg; a biodisponibilidade é de cerca de 60–70%.',
   E'Oral absorption is optimal with food ("Oral absorption of acitretin is optimal when given with food") and is linear and proportional for doses of 25 to 100 mg; bioavailability is about 60–70%.',
   E'Meia-vida de eliminação de cerca de 49 horas ("elimination half-life of 49 hours"); o metabolito cis-acitretina tem meia-vida semelhante, e o etretinato (quando formado) de 120 dias ("half-life of 120 days").',
   E'Elimination half-life of about 49 hours ("elimination half-life of 49 hours"); the cis-acitretin metabolite has a similar half-life, and etretinate (when formed) of 120 days ("half-life of 120 days").',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a',
   'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a'),

  ('tetraciclina',
   E'Antibiótico bacteriostático de largo espectro ativo contra bactérias Gram-positivas e Gram-negativas, riquétsias, micoplasmas e clamídias; útil em doentes alérgicos a penicilinas.',
   E'Broad-spectrum bacteriostatic antibiotic active against Gram-positive and Gram-negative bacteria, rickettsiae, mycoplasmas and chlamydiae; useful in penicillin-allergic patients.',
   E'Inibe a síntese proteica bacteriana por ligação reversível à subunidade ribossómica 30S, bloqueando a ligação do aminoacil-tRNA ao complexo mRNA-ribossoma (efeito bacteriostático).',
   E'Inhibits bacterial protein synthesis by reversible binding to the 30S ribosomal subunit, blocking aminoacyl-tRNA binding to the mRNA-ribosome complex (bacteriostatic effect).',
   E'Metabolizada de forma mínima; eliminada sobretudo na urina por filtração glomerular (cerca de 60% em 24 h na função renal normal).',
   E'Minimally metabolised; eliminated mainly in urine by glomerular filtration (about 60% in 24 h with normal renal function).',
   E'A absorção oral é incompleta e muito reduzida por quelação: "impaired by antacids containing aluminum, calcium or magnesium and preparations containing iron, zinc or sodium bicarbonate"; "Food and some dairy products also interfere with absorption" — tomar em jejum, 1 h antes ou 2 h após as refeições.',
   E'Oral absorption is incomplete and greatly reduced by chelation: "impaired by antacids containing aluminum, calcium or magnesium and preparations containing iron, zinc or sodium bicarbonate"; "Food and some dairy products also interfere with absorption" — take on an empty stomach, 1 h before or 2 h after meals.',
   E'Meia-vida de cerca de 6–11 horas na função renal normal (eliminação renal); prolongada na insuficiência renal — pode acumular.',
   E'Half-life of about 6–11 hours with normal renal function (renal elimination); prolonged in renal impairment — may accumulate.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94',
   'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94'),

  ('minociclina',
   E'Antibiótico de largo espectro da classe das tetraciclinas (semissintético, lipofílico); ativo contra Gram-positivos e Gram-negativos, incluindo Staphylococcus aureus resistente (MRSA) e Bacillus anthracis.',
   E'Broad-spectrum antibiotic of the tetracycline class (semisynthetic, lipophilic); active against Gram-positive and Gram-negative organisms, including resistant Staphylococcus aureus (MRSA) and Bacillus anthracis.',
   E'Inibe a síntese proteica bacteriana por ligação à subunidade ribossómica 30S (bacteriostático); a lipofilia elevada favorece a penetração tecidular e a atividade na acne.',
   E'Inhibits bacterial protein synthesis by binding to the 30S ribosomal subunit (bacteriostatic); high lipophilicity favours tissue penetration and activity in acne.',
   E'Metabolizada parcialmente no fígado; eliminada na urina e nas fezes, com metabolitos ativos. A meia-vida prolonga-se na disfunção renal (18–69 h em doentes renais) e, em menor grau, na hepática.',
   E'Partially metabolised in the liver; eliminated in urine and faeces, with active metabolites. Half-life is prolonged in renal dysfunction (18–69 h in renal patients) and, to a lesser extent, in hepatic impairment.',
   E'A absorção oral é rápida e quase completa, sem redução relevante com alimentos ("absorption of minocycline hydrochloride capsules was unchanged compared to dosing under fasting conditions"); reduzida por antiácidos e preparações com ferro, zinco ou cálcio (quelação).',
   E'Oral absorption is rapid and almost complete, without meaningful reduction with food ("absorption of minocycline hydrochloride capsules was unchanged compared to dosing under fasting conditions"); reduced by antacids and iron, zinc or calcium preparations (chelation).',
   E'Meia-vida de 11–16 horas em voluntários normais ("half-life in the normal volunteers ranged from 11... to 16 hours"), de 18–69 horas na disfunção renal e de 11–16 horas (até mais) na disfunção hepática.',
   E'Half-life of 11–16 hours in normal volunteers ("half-life in the normal volunteers ranged from 11... to 16 hours"), of 18–69 hours in renal dysfunction and of 11–16 hours (or more) in hepatic dysfunction.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06',
   'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06')
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
  ('isotretinoina', 'refeicoes_gordurosas', 'Refeições ricas em gordura', 'High-fat meals', 'moderate',
   E'A absorção oral da isotretinoína é aumentada por refeições ricas em gordura (lipofilicidade elevada) — "oral absorption of isotretinoin is enhanced when given with a high-fat meal".',
   E'Oral isotretinoin absorption is enhanced by high-fat meals (high lipophilicity) — "oral absorption of isotretinoin is enhanced when given with a high-fat meal".',
   E'Tomar com uma refeição rica em gordura para maximizar a absorção.',
   E'Take with a high-fat meal to maximise absorption.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('isotretinoina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   E'O álcool aumenta o risco de hipertrigliceridemia e de alterações hepáticas durante o tratamento com isotretinoína, e pode agravar a secura e os efeitos no sistema nervoso central.',
   E'Alcohol increases the risk of hypertriglyceridaemia and hepatic changes during isotretinoin treatment, and may worsen dryness and central nervous system effects.',
   E'Evitar ou limitar fortemente o consumo de álcool durante o tratamento.',
   E'Avoid or strongly limit alcohol intake during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('acitretina', 'refeicoes_gordurosas', 'Refeições ricas em gordura', 'High-fat meals', 'minor',
   E'A absorção oral da acitretina é ótima quando tomada com alimentos — "Oral absorption of acitretin is optimal when given with food".',
   E'Oral acitretin absorption is optimal when taken with food — "Oral absorption of acitretin is optimal when given with food".',
   E'Tomar com as refeições para otimizar a absorção.',
   E'Take with meals to optimise absorption.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 1),
  ('acitretina', 'alcool', 'Álcool', 'Alcohol', 'critical',
   E'O álcool converte a acitretina em etretinato, um metabolito com meia-vida muito longa (cerca de 120 dias), prolongando o risco teratogénico muito para além dos 3 anos previstos e aumentando a hepatotoxicidade.',
   E'Alcohol converts acitretin into etretinate, a metabolite with a very long half-life (about 120 days), extending the teratogenic risk well beyond the expected 3 years and increasing hepatotoxicity.',
   E'Proibido consumir álcool (incluindo vinho e cerveja) durante o tratamento e nas 2 semanas após a suspensão; evitar também medicamentos que contenham álcool.',
   E'Do not drink alcohol (including wine and beer) during treatment and for 2 weeks after stopping; also avoid alcohol-containing medicines.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 1),
  ('tetraciclina', 'leite_lacticinios', 'Leite e laticínios', 'Milk and dairy products', 'moderate',
   E'O cálcio dos laticínios quelata a tetraciclina no lúmen gastrointestinal e reduz marcadamente a sua absorção — "Food and some dairy products also interfere with absorption" (rótulo).',
   E'Calcium in dairy products chelates tetracycline in the GI lumen and markedly reduces its absorption — "Food and some dairy products also interfere with absorption" (label).',
   E'Não tomar com leite, iogurte ou derivados; tomar em jejum, 1 hora antes ou 2 horas depois das refeições.',
   E'Do not take with milk, yoghurt or dairy; take on an empty stomach, 1 hour before or 2 hours after meals.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 1),
  ('minociclina', 'leite_lacticinios', 'Leite e laticínios', 'Milk and dairy products', 'moderate',
   E'O cálcio dos laticínios pode quelatar a minociclina e reduzir a sua absorção; o efeito é menor do que noutras tetraciclinas, mas a separação continua recomendada.',
   E'Calcium in dairy products may chelate minocycline and reduce its absorption; the effect is smaller than with other tetracyclines, but separation is still recommended.',
   E'Preferir tomar a minociclina com água, 1 hora antes ou 2 horas depois dos laticínios.',
   E'Prefer taking minocycline with water, 1 hour before or 2 hours after dairy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1),
  ('minociclina', 'alcool', 'Álcool', 'Alcohol', 'minor',
   E'O álcool pode agravar as tonturas e a intolerância gastrointestinal associadas à minociclina.',
   E'Alcohol may worsen the dizziness and gastrointestinal intolerance associated with minocycline.',
   E'Limitar o consumo de álcool durante o tratamento, sobretudo se ocorrerem tonturas.',
   E'Limit alcohol intake during treatment, especially if dizziness occurs.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1)
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
  ('isotretinoina', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'Teratogenicidade grave e bem documentada — "There is an extremely high risk that severe birth defects will result if pregnancy occurs while taking isotretinoin capsules in any amount, even for short periods of time" (rótulo).',
   E'Severe, well-documented teratogenicity — "There is an extremely high risk that severe birth defects will result if pregnancy occurs while taking isotretinoin capsules in any amount, even for short periods of time" (label).',
   E'Contraindicado na gravidez e em mulheres que possam engravidar sem contraceção fiável; exigir teste de gravidez negativo e contraceção eficaz 1 mês antes, durante e 1 mês após.',
   E'Contraindicated in pregnancy and in women who may become pregnant without reliable contraception; require a negative pregnancy test and effective contraception 1 month before, during and 1 month after.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('isotretinoina', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'precaution', 'moderate',
   E'Risco de elevação das transaminases e de hepatotoxicidade durante o tratamento com isotretinoína; a doença hepática prévia aumenta o risco.',
   E'Risk of transaminase elevation and hepatotoxicity during isotretinoin treatment; pre-existing hepatic disease increases the risk.',
   E'Vigiar transaminases antes e durante o tratamento (basal e periódica); usar com precaução na doença hepática.',
   E'Monitor transaminases before and during treatment (baseline and periodic); use with caution in hepatic disease.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('isotretinoina', 'doenca_psiquiatrica', 'Doença psiquiátrica', 'Psychiatric disease', 'precaution', 'moderate',
   E'Risco de depressão, ideação suicida, agressividade e alterações de humor associado à isotretinoína — vigiar em todos os doentes, sobretudo com história psiquiátrica.',
   E'Risk of depression, suicidal ideation, aggression and mood changes associated with isotretinoin — monitor all patients, especially those with psychiatric history.',
   E'Informar o doente e a família para vigiar alterações de humor; suspender e avaliar se surgirem sintomas depressivos.',
   E'Inform the patient and family to watch for mood changes; discontinue and evaluate if depressive symptoms appear.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('isotretinoina', 'hipertrigliceridemia', 'Hipertrigliceridemia', 'Hypertriglyceridaemia', 'precaution', 'moderate',
   E'A isotretinoína aumenta os triglicerídeos e o colesterol; doentes com dislipidemia prévia têm risco acrescido de pancreatite.',
   E'Isotretinoin raises triglycerides and cholesterol; patients with pre-existing dyslipidaemia have an increased risk of pancreatitis.',
   E'Vigiar o perfil lipídico em jejum antes e durante o tratamento; se triglicerídeos elevados, considerar dose menor ou suspensão.',
   E'Monitor fasting lipid profile before and during treatment; if triglycerides are raised, consider dose reduction or discontinuation.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('isotretinoina', 'osteoporose', 'Osteoporose', 'Osteoporosis', 'precaution', 'moderate',
   E'Risco de perda óssea com o uso prolongado ou repetido de isotretinoína — os rótulos documentam que o uso concomitante de fármacos que afetam o metabolismo ósseo (fenitoína, corticosteróides) "may weaken your bones".',
   E'Risk of bone loss with prolonged or repeated isotretinoin use — labels document that concomitant drugs affecting bone metabolism (phenytoin, corticosteroids) "may weaken your bones".',
   E'Considerar vigilância da densidade mineral óssea em tratamentos prolongados ou repetidos e em doentes de risco.',
   E'Consider bone mineral density monitoring in prolonged or repeated treatment and in at-risk patients.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d', 1),
  ('acitretina', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'Teratogénico — "Acitretin must not be used by females who are pregnant, or who intend to become pregnant during therapy or at any time for at least 3 years following discontinuation of therapy" (rótulo); o álcool prolonga o risco (formação de etretinato).',
   E'Teratogenic — "Acitretin must not be used by females who are pregnant, or who intend to become pregnant during therapy or at any time for at least 3 years following discontinuation of therapy" (label); alcohol extends the risk (etretinate formation).',
   E'Contraindicado na gravidez; contraceção fiável durante e pelo menos 3 anos após a suspensão; excluir gravidez antes de iniciar.',
   E'Contraindicated in pregnancy; reliable contraception during and for at least 3 years after stopping; exclude pregnancy before starting.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 1),
  ('acitretina', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'precaution', 'moderate',
   E'Risco de hepatotoxicidade (elevação de transaminases) associado à acitretina; usar com precaução na doença hepática e vigiar a função hepática.',
   E'Risk of hepatotoxicity (transaminase elevation) associated with acitretin; use with caution in hepatic disease and monitor liver function.',
   E'Vigiar transaminases antes e durante o tratamento; precaução na doença hepática e associação com álcool ou fármacos hepatotóxicos.',
   E'Monitor transaminases before and during treatment; caution in hepatic disease and with alcohol or hepatotoxic drugs.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 1),
  ('acitretina', 'hipertrigliceridemia', 'Hipertrigliceridemia', 'Hypertriglyceridaemia', 'precaution', 'moderate',
   E'A acitretina pode aumentar os triglicerídeos e o colesterol; risco de pancreatite em doentes com hipertrigliceridemia grave.',
   E'Acitretin may raise triglycerides and cholesterol; risk of pancreatitis in patients with severe hypertriglyceridaemia.',
   E'Vigiar o perfil lipídico em jejum antes e durante o tratamento.',
   E'Monitor fasting lipid profile before and during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a', 1),
  ('tetraciclina', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'"The use of drugs of the tetracycline-class during tooth development (last half of pregnancy, infancy and childhood to the age of 8 years) may cause permanent discoloration of the teeth" (rótulo); "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure".',
   E'"The use of drugs of the tetracycline-class during tooth development (last half of pregnancy, infancy and childhood to the age of 8 years) may cause permanent discoloration of the teeth" (label); "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure".',
   E'Contraindicado na 2.ª metade da gravidez e em crianças até aos 8 anos; evitar sempre que possível durante a gravidez.',
   E'Contraindicated in the second half of pregnancy and in children up to 8 years; avoid whenever possible during pregnancy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 1),
  ('tetraciclina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'A tetraciclina elimina-se sobretudo por via renal; na insuficiência renal pode acumular-se e agravar a azotemia — e o rótulo associa falência hepática em grávidas com doença renal.',
   E'Tetracycline is eliminated mainly renally; in renal impairment it may accumulate and worsen azotaemia — and the label associates liver failure in pregnant women with renal disease.',
   E'Usar com precaução e reduzir a dose ou intervalo na insuficiência renal; monitorizar a função renal.',
   E'Use with caution and reduce dose or interval in renal impairment; monitor renal function.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 1),
  ('tetraciclina', 'fotossensibilidade', 'Fotossensibilidade', 'Photosensitivity', 'precaution', 'moderate',
   E'As tetraciclinas causam reações de fotossensibilidade cutânea — queimadura solar exagerada e erupções com exposição solar ou luz ultravioleta.',
   E'Tetracyclines cause cutaneous photosensitivity reactions — exaggerated sunburn and rashes with sun or ultraviolet light exposure.',
   E'Evitar exposição solar prolongada e luz ultravioleta (incluindo solários); usar protetor solar e roupa protetora.',
   E'Avoid prolonged sun exposure and ultraviolet light (including tanning beds); use sunscreen and protective clothing.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94', 1),
  ('minociclina', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'"Minocycline, like other tetracycline-class antibiotics, can cause fetal harm when administered to a pregnant woman" (rótulo); a classe causa descoloração permanente dos dentes durante o desenvolvimento dentário.',
   E'"Minocycline, like other tetracycline-class antibiotics, can cause fetal harm when administered to a pregnant woman" (label); the class causes permanent tooth discoloration during tooth development.',
   E'Contraindicado na gravidez e em crianças até aos 8 anos; informar a doente do risco fetal se engravidar durante o tratamento.',
   E'Contraindicated in pregnancy and in children up to 8 years; inform the patient of the fetal risk if she becomes pregnant during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1),
  ('minociclina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'A minociclina acumula-se na insuficiência renal — meia-vida prolongada de 18 a 69 horas em doentes renais ("half-life ranged from 11 to 16 hours in 7 patients with hepatic dysfunction, and from 18 to 69 hours in 5 patients with renal dysfunction").',
   E'Minocycline accumulates in renal impairment — prolonged half-life of 18 to 69 hours in renal patients ("half-life ranged from 11 to 16 hours in 7 patients with hepatic dysfunction, and from 18 to 69 hours in 5 patients with renal dysfunction").',
   E'Usar com precaução e reduzir a dose ou o intervalo na insuficiência renal; monitorizar.',
   E'Use with caution and reduce dose or interval in renal impairment; monitor.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1),
  ('minociclina', 'fotossensibilidade', 'Fotossensibilidade', 'Photosensitivity', 'precaution', 'moderate',
   E'A minociclina causa fotossensibilidade cutânea (reação exagerada ao sol e luz ultravioleta).',
   E'Minocycline causes cutaneous photosensitivity (exaggerated reaction to sun and ultraviolet light).',
   E'Evitar exposição solar prolongada e luz ultravioleta; usar protetor solar.',
   E'Avoid prolonged sun exposure and ultraviolet light; use sunscreen.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1),
  ('minociclina', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'precaution', 'moderate',
   E'Risco de hepatotoxicidade (incluindo hepatite autoimune e falência hepática) associado à minociclina; a doença hepática prévia aumenta o risco.',
   E'Risk of hepatotoxicity (including autoimmune hepatitis and liver failure) associated with minocycline; pre-existing hepatic disease increases the risk.',
   E'Vigiar sintomas e função hepática; suspender se sinais de lesão hepática.',
   E'Monitor symptoms and liver function; discontinue if signs of liver injury.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06', 1)
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
  ('isotretinoina', 'contraindicated',
   E'Teratogenicidade grave — "extremely high risk that severe birth defects will result if pregnancy occurs while taking isotretinoin capsules in any amount, even for short periods of time"; qualquer feto exposto pode ser afetado.',
   E'Severe teratogenicity — "extremely high risk that severe birth defects will result if pregnancy occurs while taking isotretinoin capsules in any amount, even for short periods of time"; any exposed fetus may be affected.',
   E'Contraindicado em qualquer trimestre; nunca usar durante a gravidez.',
   E'Contraindicated in any trimester; never use during pregnancy.',
   E'Desconhecido se é excretado no leite; o perfil de segurança não permite a amamentação durante o tratamento.',
   E'Unknown whether it is excreted in breast milk; the safety profile does not allow breastfeeding during treatment.',
   E'Contraceção fiável (idealmente dupla) obrigatória 1 mês antes, durante e 1 mês após o tratamento; teste de gravidez negativo antes de iniciar.',
   E'Reliable contraception (ideally dual) mandatory 1 month before, during and 1 month after treatment; negative pregnancy test before starting.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isotretinoína (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d',
   'DailyMed/FDA (NIH/NLM) — approved Isotretinoin label (Sotret): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5a26c5e-9c3e-4781-8c08-62b91d21a68d'),

  ('acitretina', 'contraindicated',
   E'Teratogénico — "Acitretin must not be used by females who are pregnant, or who intend to become pregnant during therapy or at any time for at least 3 years following discontinuation of therapy".',
   E'Teratogenic — "Acitretin must not be used by females who are pregnant, or who intend to become pregnant during therapy or at any time for at least 3 years following discontinuation of therapy".',
   E'Contraindicado em qualquer trimestre; nunca usar durante a gravidez.',
   E'Contraindicated in any trimester; never use during pregnancy.',
   E'Contraindicado durante a amamentação ("do not breast feed or take acitretin capsules, but not both") — excreção no leite.',
   E'Contraindicated during breastfeeding ("do not breast feed or take acitretin capsules, but not both") — excretion in milk.',
   E'Contraceção fiável obrigatória durante e pelo menos 3 anos após a suspensão; excluir gravidez antes de iniciar.',
   E'Reliable contraception mandatory during and for at least 3 years after stopping; exclude pregnancy before starting.',

   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acitretina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a',
   'DailyMed/FDA (NIH/NLM) — approved Acitretin label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a6546625-acb8-460e-b34e-f795bfb3680a'),

  ('tetraciclina', 'contraindicated',
   E'Descoloração permanente dos dentes durante o desenvolvimento (2.ª metade da gravidez); "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure".',
   E'Permanent tooth discoloration during development (second half of pregnancy); "Pregnant women with renal disease may be more prone to develop tetracycline-associated liver failure".',
   E'Evitar na 2.ª metade da gravidez; usar apenas se absolutamente necessário.',
   E'Avoid in the second half of pregnancy; use only if absolutely necessary.',
   E'As tetraciclinas são excretadas no leite; risco de descoloração dentária no lactente — evitar durante a amamentação.',
   E'Tetracyclines are excreted in breast milk; risk of tooth discoloration in the infant — avoid during breastfeeding.',
   E'Não requer contraceção específica (sem efeito teratogénico no 1.º trimestre documentado para o feto, mas evitar na gravidez).',
   E'No specific contraception required (no documented teratogenic effect on the fetus in the first trimester, but avoid in pregnancy).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tetraciclina (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94',
   'DailyMed/FDA (NIH/NLM) — approved Tetracycline label (USP): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=02e88b4a-57ae-4ef6-ba48-97c657202b94'),

  ('minociclina', 'contraindicated',
   E'"Minocycline, like other tetracycline-class antibiotics, can cause fetal harm when administered to a pregnant woman"; a classe causa descoloração permanente dos dentes durante o desenvolvimento dentário.',
   E'"Minocycline, like other tetracycline-class antibiotics, can cause fetal harm when administered to a pregnant woman"; the class causes permanent tooth discoloration during tooth development.',
   E'Contraindicado na gravidez (risco fetal e descoloração dentária).',
   E'Contraindicated in pregnancy (fetal risk and tooth discoloration).',
   E'As tetraciclinas são excretadas no leite; risco de descoloração dentária no lactente — evitar durante a amamentação.',
   E'Tetracyclines are excreted in breast milk; risk of tooth discoloration in the infant — avoid during breastfeeding.',
   E'Não requer contraceção específica; informar a doente do risco fetal se engravidar durante o tratamento.',
   E'No specific contraception required; inform the patient of the fetal risk if she becomes pregnant during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Minociclina (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06',
   'DailyMed/FDA (NIH/NLM) — approved Minocycline label (HCl): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5fc4d50-50b2-46e0-b722-4c6b2ec47d06')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
        lactation_pt, lactation_en, contraception_pt, contraception_en,
        source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
