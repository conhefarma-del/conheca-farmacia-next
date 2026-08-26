-- =====================================================================
-- 219 — Atualizar Indicações, Efeitos Secundários e Precauções
-- para 20 fármacos das migrações recentes
--
-- Campos: indications_pt/en, side_effects_pt/en, precautions_pt/en
-- =====================================================================

-- ═══════════════════════════════════════════════════════════════════
-- PSICOFARMACOS (migração 213)
-- ═══════════════════════════════════════════════════════════════════

-- 1. Amitriptilina
UPDATE public.drug_profiles SET
  indications_pt = 'Depressão major, neuropatia diabética, enxaqueca profiláctica, dor crónica, incontinência nocturna, síndrome do intestino irritável.',
  indications_en = 'Major depression, diabetic neuropathy, migraine prophylaxis, chronic pain, nocturnal enuresis, irritable bowel syndrome.',
  side_effects_pt = 'Boca seca, sonolência, tonturas, obstipação, retenção urinária, visão turva, ganho de peso, hipotensão ortostática, prolongamento QTc.',
  side_effects_en = 'Dry mouth, somnolence, dizziness, constipation, urinary retention, blurred vision, weight gain, orthostatic hypotension, QTc prolongation.',
  precautions_pt = 'Evitar em bloqueio AV, epilepsia, glaucoma de ângulo estreito, hipertrofia prostática. Risco suicida nos primeiros 2-4 semanas. Síndrome serotoninérgica se combinado com ISRS/IMAO.',
  precautions_en = 'Avoid in AV block, epilepsy, narrow-angle glaucoma, prostatic hypertrophy. Suicide risk in first 2-4 weeks. Serotonin syndrome if combined with SSRIs/MAOIs.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'amitriptilina');

-- 2. Risperidona
UPDATE public.drug_profiles SET
  indications_pt = 'Esquizofrenia, perturbação bipolar (mania), irritabilidade autista, psicose aguda.',
  indications_en = 'Schizophrenia, bipolar disorder (mania), autistic irritability, acute psychosis.',
  side_effects_pt = 'Efeitos extrapiramidais (parkinsonismo, acatisia, distonia), hiperprolactinemia, ganho de peso, sonolência, hipotensão ortostática.',
  side_effects_en = 'Extrapyramidal effects (parkinsonism, akathisia, dystonia), hyperprolactinaemia, weight gain, somnolence, orthostatic hypotension.',
  precautions_pt = 'Monitorizar efeitos extrapiramidais e níveis de prolactina. Risco de síndrome neuroléptica maligna. Cuidado em doentes cardíacos (prolongamento QTc).',
  precautions_en = 'Monitor extrapyramidal effects and prolactin levels. Risk of neuroleptic malignant syndrome. Caution in cardiac patients (QTc prolongation).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'risperidona');

-- 3. Olanzapina
UPDATE public.drug_profiles SET
  indications_pt = 'Esquizofrenia, perturbação bipolar (mania aguda e manutenção), combinação com fluoxetina para depressão resistente.',
  indications_en = 'Schizophrenia, bipolar disorder (acute mania and maintenance), combination with fluoxetine for treatment-resistant depression.',
  side_effects_pt = 'Ganho de peso significativo, sedação, hiperglicemia, dislipidemia, hipotensão ortostática, efeitos extrapiramidais (menos que típicos), elevação de transaminases.',
  side_effects_en = 'Significant weight gain, sedation, hyperglycaemia, dyslipidaemia, orthostatic hypotension, extrapyramidal effects (less than typicals), transaminase elevation.',
  precautions_pt = 'Risco elevado de síndrome metabólica (peso, glicemia, lipídios). Monitorizar peso mensal, glicemia e perfil lipídico trimestralmente. Contraindicado em demência (risco cardiovascular).',
  precautions_en = 'High risk of metabolic syndrome (weight, glucose, lipids). Monitor weight monthly, glucose and lipid profile quarterly. Contraindicated in dementia (cardiovascular risk).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'olanzapina');

-- 4. Quetiapina
UPDATE public.drug_profiles SET
  indications_pt = 'Esquizofrenia, perturbação bipolar (mania, depressão bipolar), terapia adjuvante na depressão major.',
  indications_en = 'Schizophrenia, bipolar disorder (mania, bipolar depression), adjunctive therapy in major depression.',
  side_effects_pt = 'Sonolência (dose-dependente), tonturas, boca seca, ganho de peso, hipotensão ortostática, constipação, elevação de transaminases.',
  side_effects_en = 'Somnolence (dose-dependent), dizziness, dry mouth, weight gain, orthostatic hypotension, constipation, transaminase elevation.',
  precautions_pt = 'Evitar em comboio de QTc >500 ms. Monitorizar glicemia em diabéticos. Sonolência marcante — evitar conduzir. Risco de cataratas com uso prolongado.',
  precautions_en = 'Avoid in QTc >500 ms. Monitor glucose in diabetics. Pronounced somnolence — avoid driving. Risk of cataracts with prolonged use.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'quetiapina');

-- 5. Aripiprazol
UPDATE public.drug_profiles SET
  indications_pt = 'Esquizofrenia, perturbação bipolar (mania), terapia adjuvante na depressão major, irritabilidade autista.',
  indications_en = 'Schizophrenia, bipolar disorder (mania), adjunctive therapy in major depression, autistic irritability.',
  side_effects_pt = 'Náusea, insomnia, akatisia, cefaleia, tonturas, sonolência (menos que outros antipsicóticos), ganho de peso mínimo.',
  side_effects_en = 'Nausea, insomnia, akathisia, headache, dizziness, somnolence (less than other antipsychotics), minimal weight gain.',
  precautions_pt = 'Monitorizar movimentos involuntários (diskinesia tardia). Agitação/insomnia no início. Discreto efeito sobre prolactina (menos que risperidona/olanzapina).',
  precautions_en = 'Monitor for involuntary movements (tardive dyskinesia). Agitation/insomnia at initiation. Minimal effect on prolactin (less than risperidone/olanzapine).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'aripiprazol');

-- 6. Paroxetina
UPDATE public.drug_profiles SET
  indications_pt = 'Depressão major, perturbação de ansiedade generalizada, perturbação obsessivo-compulsiva, perturbação de pânico, ansiedade social, TEPT.',
  indications_en = 'Major depression, generalised anxiety disorder, obsessive-compulsive disorder, panic disorder, social anxiety, PTSD.',
  side_effects_pt = 'Náusea, sonolência, insónia, tonturas, boca seca, obstipação, disfunção sexual, síndrome de descontinuação (importante).',
  side_effects_en = 'Nausea, somnolence, insomnia, dizziness, dry mouth, constipation, sexual dysfunction, discontinuation syndrome (significant).',
  precautions_pt = 'Síndrome de descontinuação grave — reduzir gradualmente (mínimo 4 semanas). Aumento suicida inicial em jovens <25 anos. Interacção com IMAO (contraindicado).',
  precautions_en = 'Severe discontinuation syndrome — taper gradually (minimum 4 weeks). Initial suicide increase in youth <25 years. MAOI interaction (contraindicated).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'paroxetina');

-- 7. Venlafaxina
UPDATE public.drug_profiles SET
  indications_pt = 'Depressão major, perturbação de ansiedade generalizada, perturbação de pânico, ansiedade social, TEPT.',
  indications_en = 'Major depression, generalised anxiety disorder, panic disorder, social anxiety, PTSD.',
  side_effects_pt = 'Náusea, cefaleia, insomnia, sonolência, boca seca, hipertensão dose-dependente (>150 mg), suores, disfunção sexual, síndrome de descontinuação.',
  side_effects_en = 'Nausea, headache, insomnia, somnolence, dry mouth, dose-dependent hypertension (>150 mg), sweating, sexual dysfunction, discontinuation syndrome.',
  precautions_pt = 'Monitorizar PA — hipertensão dose-dependente (>150 mg). Síndrome de descontinuação significativa. Evitar em hipertensão não controlada.',
  precautions_en = 'Monitor blood pressure — dose-dependent hypertension (>150 mg). Significant discontinuation syndrome. Avoid in uncontrolled hypertension.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'venlafaxina');

-- 8. Duloxetina
UPDATE public.drug_profiles SET
  indications_pt = 'Depressão major, perturbação de ansiedade generalizada, neuropatia diabética, fibromialgia, dor crónica musculoesquelética.',
  indications_en = 'Major depression, generalised anxiety disorder, diabetic neuropathy, fibromyalgia, chronic musculoskeletal pain.',
  side_effects_pt = 'Náusea (transitória), boca seca, sonolência, insónia, constipação, sudorese, hipertensão ligeira, disfunção sexual, hepatotoxicidade rara.',
  side_effects_en = 'Nausea (transient), dry mouth, somnolence, insomnia, constipation, sweating, mild hypertension, sexual dysfunction, rare hepatotoxicity.',
  precautions_pt = 'Evitar em insuficiência hepática grave (Clearance Child-Pugh C). Monitorizar PA. Suspender se sinais de hepatotoxicidade. Síndrome de descontinuação.',
  precautions_en = 'Avoid in severe hepatic impairment (Child-Pugh C). Monitor blood pressure. Discontinue if signs of hepatotoxicity. Discontinuation syndrome.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'duloxetina');

-- 9. Mirtazapina
UPDATE public.drug_profiles SET
  indications_pt = 'Depressão major (especialmente com insónia e perda de apetite).',
  indications_en = 'Major depression (especially with insomnia and appetite loss).',
  side_effects_pt = 'Sonolência (dose-inversa — menos em doses altas), ganho de peso, boca seca, aumento de apetite, tonturas.',
  side_effects_en = 'Somnolence (inverse dose — less at higher doses), weight gain, dry mouth, increased appetite, dizziness.',
  precautions_pt = 'Sonolência marcante nas primeiras 2 semanas. Ganho de peso — considerar alternativa se significativo. Evitar com IMAO (síndrome serotoninérgica).',
  precautions_en = 'Pronounced somnolence in first 2 weeks. Weight gain — consider alternative if significant. Avoid with MAOIs (serotonin syndrome).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'mirtazapina');

-- ═══════════════════════════════════════════════════════════════════
-- ANALGESICOS (migração 208)
-- ═══════════════════════════════════════════════════════════════════

-- 10. Ketorolaco
UPDATE public.drug_profiles SET
  indications_pt = 'Dor aguda moderada a severa (uso parentérico, máx. 5 dias). Dor pós-operatória.',
  indications_en = 'Moderate to severe acute pain (parenteral use, max 5 days). Post-operative pain.',
  side_effects_pt = 'Toxicidade GI (úlcera, hemorragia), nefrotoxicidade, aumento tempo de sangramento, cefaleia, tonturas, edema.',
  side_effects_en = 'GI toxicity (ulcer, bleeding), nephrotoxicity, increased bleeding time, headache, dizziness, oedema.',
  precautions_pt = 'MÁXIMO 5 dias de uso. Contraindicado em insuficiência renal, hemorragia activa, pré-cirurgia. Risco cardiovascular elevado.',
  precautions_en = 'MAXIMUM 5 days use. Contraindicated in renal impairment, active bleeding, pre-surgery. High cardiovascular risk.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'ketorolaco');

-- 11. Piroxicam
UPDATE public.drug_profiles SET
  indications_pt = 'Artrite reumatoide, osteoartrite, dor aguda (curta duração).',
  indications_en = 'Rheumatoid arthritis, osteoarthritis, acute pain (short duration).',
  side_effects_pt = 'Toxicidade GI significativa (meia-vida longa), úlcera, hemorragia, nefrotoxicidade, reacções cutâneas (SJS raro).',
  side_effects_en = 'Significant GI toxicity (long half-life), ulcer, bleeding, nephrotoxicity, skin reactions (rare SJS).',
  precautions_pt = 'Meia-vida longa (50 h) — toxicidade acumulada. Evitar em idosos. Usar dose mínima e duração curta. Risco GI > outros AINE.',
  precautions_en = 'Long half-life (50 h) — accumulated toxicity. Avoid in the elderly. Use minimum dose and short duration. GI risk > other NSAIDs.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'piroxicam');

-- 12. Meloxicam
UPDATE public.drug_profiles SET
  indications_pt = 'Osteoartrite, artrite reumatoide, dor musculoesquelética aguda.',
  indications_en = 'Osteoarthritis, rheumatoid arthritis, acute musculoskeletal pain.',
  side_effects_pt = 'Toxicidade GI (menos que piroxicam, mais que celecoxibe), cefaleia, tonturas, edema, elevação de transaminases.',
  side_effects_en = 'GI toxicity (less than piroxicam, more than celecoxib), headache, dizziness, oedema, transaminase elevation.',
  precautions_pt = 'Selecoxib parcial — maior seletividade COX-2 mas não selectivo. Monitorizar função GI e renal. Risco CV intermediário.',
  precautions_en = 'Partial COX-2 selective — higher COX-2 selectivity but not selective. Monitor GI and renal function. Intermediate CV risk.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'meloxicam');

-- 13. Metadona
UPDATE public.drug_profiles SET
  indications_pt = 'Dor crónica (com opioides), manutenção em dependência de opiáceos, dor neuropática refractária.',
  indications_en = 'Chronic pain (with opioids), maintenance in opioid dependence, refractory neuropathic pain.',
  side_effects_pt = 'Depressão respiratória (retardada), constipação, náusea, sonolência, hipotensão, retenção urinária, prolongamento QTc.',
  side_effects_en = 'Respiratory depression (delayed), constipation, nausea, somnolence, hypotension, urinary retention, QTc prolongation.',
  precautions_pt = 'Meia-vida variável (8-59 h) — risco de acumulação. Prolongamento QTc — ECG antes de iniciar. Risco elevado de overdose fatal.',
  precautions_en = 'Variable half-life (8-59 h) — accumulation risk. QTc prolongation — ECG before starting. High risk of fatal overdose.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'metadona');

-- 14. Naloxona
UPDATE public.drug_profiles SET
  indications_pt = 'Reversão de overdose de opiáceos (emergência).',
  indications_en = 'Reversal of opioid overdose (emergency).',
  side_effects_pt = 'Náusea, vómitos, sudorese, taquicardia, hipertensão, reacção de abstinência em opioides dependentes.',
  side_effects_en = 'Nausea, vomiting, sweating, tachycardia, hypertension, withdrawal reaction in opioid-dependent patients.',
  precautions_pt = 'Duração de acção curta (30-90 min) — pode necessitar de repetição. Risco de reacção de abstinência aguda. Não é substituto para tratamento de dependência.',
  precautions_en = 'Short duration of action (30-90 min) — may require repetition. Risk of acute withdrawal. Not a substitute for dependence treatment.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'naloxona');

-- 15. Indometacina
UPDATE public.drug_profiles SET
  indications_pt = 'Artrite reumatoide, espondilite anquilosante, gota aguda, dor pós-operatória (uso parentérico).',
  indications_en = 'Rheumatoid arthritis, ankylosing spondylitis, acute gout, post-operative pain (parenteral use).',
  side_effects_pt = 'Toxicidade GI elevada, cefaleia (frequente), tonturas, nefrotoxicidade, hemorragia, prolongamento tempo de sangramento.',
  side_effects_en = 'High GI toxicity, frequent headache, dizziness, nephrotoxicity, bleeding, increased bleeding time.',
  precautions_pt = 'AINE mais tóxico GI. Usar apenas para condições onde outros AINE são ineficazes. Monitorizar função renal e GI. Evitar em idosos.',
  precautions_en = 'Most GI toxic NSAID. Use only when other NSAIDs are ineffective. Monitor renal and GI function. Avoid in the elderly.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'indometacina');

-- ═══════════════════════════════════════════════════════════════════
-- NIMESULIDA (migração 211)
-- ═══════════════════════════════════════════════════════════════════

-- 16. Nimesulida
UPDATE public.drug_profiles SET
  indications_pt = 'Dor e inflamação (curta duração, máx. 15 dias). Dor musculoesquelética, dismenorreia, dor pós-operatória.',
  indications_en = 'Pain and inflammation (short duration, max 15 days). Musculoskeletal pain, dysmenorrhoea, post-operative pain.',
  side_effects_pt = 'Desconforto GI, náusea, diarreia, erupção cutânea, hepatotoxicidade idiossincrásica rara mas potencialmente grave.',
  side_effects_en = 'GI discomfort, nausea, diarrhoea, skin rash, rare but potentially serious idiosyncratic hepatotoxicity.',
  precautions_pt = 'CONTRAINDICADO em insuficiência hepática. Máx. 15 dias. Suspender se sinais de hepatotoxicidade. Não usar em crianças <12 anos.',
  precautions_en = 'CONTRAINDICATED in hepatic impairment. Max 15 days. Discontinue if signs of hepatotoxicity. Do not use in children <12 years.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'nimesulida');

-- ═══════════════════════════════════════════════════════════════════
-- ANTIEPILEPTICOS (migração 216)
-- ═══════════════════════════════════════════════════════════════════

-- 17. Levetiracetam
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial (adjunto), crises generalizadas primárias, crises mioclónicas, estado epiléptico (IV).',
  indications_en = 'Partial epilepsy (adjunct), primary generalised seizures, myoclonic seizures, status epilepticus (IV).',
  side_effects_pt = 'Sonolência, irritabilidade, alterações comportamentais, astenia, cefaleia, tonturas. Risco de perturbações psiquiátricas (1-3%).',
  side_effects_en = 'Somnolence, irritability, behavioural changes, asthenia, headache, dizziness. Risk of psychiatric disturbances (1-3%).',
  precautions_pt = 'Monitorizar comportamento (risco de agressividade, depressão). Ajustar dose em insuficiência renal. Efeito mínimo sobre CYP.',
  precautions_en = 'Monitor behaviour (risk of aggression, depression). Adjust dose in renal impairment. Minimal CYP effect.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'levetiracetam');

-- 18. Gabapentina
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial (adjunto), dor neuropática, dor pós-herpética, fibromialgia.',
  indications_en = 'Partial epilepsy (adjunct), neuropathic pain, postherpetic pain, fibromyalgia.',
  side_effects_pt = 'Sonolência, tonturas, ataxia, edema periférico, ganho de peso, diplopia, fadiga.',
  side_effects_en = 'Somnolence, dizziness, ataxia, peripheral oedema, weight gain, diplopia, fatigue.',
  precautions_pt = 'Insuficiência renal: ajustar dose conforme TFG. Não repentinamente suspender. Evitar álcool. Risco de abuso (classificação scheduled em alguns países).',
  precautions_en = 'Renal impairment: adjust dose based on GFR. Do not abruptly discontinue. Avoid alcohol. Abuse potential (scheduled classification in some countries).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'gabapentina');

-- 19. Pregabalina
UPDATE public.drug_profiles SET
  indications_pt = 'Dor neuropática, epilepsia parcial (adjunto), fibromialgia, dor crónica musculoesquelética.',
  indications_en = 'Neuropathic pain, partial epilepsy (adjunct), fibromyalgia, chronic musculoskeletal pain.',
  side_effects_pt = 'Sonolência, tonturas, edema periférico, ganho de peso, visão turva, boca seca, ganho de apetite.',
  side_effects_en = 'Somnolence, dizziness, peripheral oedema, weight gain, blurred vision, dry mouth, increased appetite.',
  precautions_pt = 'Insuficiência renal: ajustar dose. Risco de abuso e dependência. Não suspender abruptamente. Pode causar angioedema.',
  precautions_en = 'Renal impairment: adjust dose. Abuse and dependence risk. Do not abruptly discontinue. May cause angioedema.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'pregabalina');

-- 20. Etossuximida
UPDATE public.drug_profiles SET
  indications_pt = 'Crises de ausência primárias (primeira linha).',
  indications_en = 'Primary absence seizures (first-line).',
  side_effects_pt = 'Náusea, dor abdominal, cefaleia, sonolência, tonturas, erupção cutânea, pancitopenia rara.',
  side_effects_en = 'Nausea, abdominal pain, headache, somnolence, dizziness, skin rash, rare pancytopenia.',
  precautions_pt = 'Activo apenas contra ausências. Monitorizar hemograma (risco de pancitopenia). Nível terapêutico: 40-100 μg/mL.',
  precautions_en = 'Active only against absences. Monitor blood count (risk of pancytopenia). Therapeutic level: 40-100 μg/mL.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'etossuximida');

-- 21. Topiramato
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial, crises primárias generalizadas, enxaqueca profiláctica, perda de peso (adjunto).',
  indications_en = 'Partial epilepsy, primary generalised seizures, migraine prophylaxis, weight loss (adjunct).',
  side_effects_pt = 'Perturbações cognitivas (atenção, linguagem), parestesias, sonolência, perda de peso, acidose metabólica, pedras renais.',
  side_effects_en = 'Cognitive impairment (attention, language), paraesthesias, somnolence, weight loss, metabolic acidosis, renal stones.',
  precautions_pt = 'Monitorizar bicarbonato sérico. Evitar em pedras renais. Suplementar ácido fólico em mulheres em idade fértil. Pode causar glaucoma agudo.',
  precautions_en = 'Monitor serum bicarbonate. Avoid in renal stones. Supplement folic acid in women of childbearing age. May cause acute glaucoma.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'topiramato');

-- 22. Oxcarbazepina
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial (monoterapia ou adjunto).',
  indications_en = 'Partial epilepsy (monotherapy or adjunct).',
  side_effects_pt = 'Sonolência, tonturas, cefaleia, diplopia, náusea, hiponatremia (2-3%), erupção cutânea.',
  side_effects_en = 'Somnolence, dizziness, headache, diplopia, nausea, hyponatraemia (2-3%), skin rash.',
  precautions_pt = 'Monitorizar sódio (hiponatremia mais comum que carbamazepina). Risco de erupção cutânea grave (SJS) — menor que carbamazepina. Induz CYP3A4 (menos que carbamazepina).',
  precautions_en = 'Monitor sodium (hyponatraemia more common than carbamazepine). Risk of serious skin rash (SJS) — less than carbamazepine. Induces CYP3A4 (less than carbamazepine).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'oxcarbazepina');

-- 23. Zonisamida
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial (adjunto).',
  indications_en = 'Partial epilepsy (adjunct).',
  side_effects_pt = 'Sonolência, cefaleia, tonturas, anorexia, confusão, pedras renais, acidose metabólica, hipertermia em idosos.',
  side_effects_en = 'Somnolence, headache, dizziness, anorexia, confusion, renal stones, metabolic acidosis, hyperthermia in elderly.',
  precautions_pt = 'Evitar em alergia a sulfonamidas. Monitorizar bicarbonato e TFG. Risco de sudorese reduzida (hipertermia). Não usar em crianças <6 anos.',
  precautions_en = 'Avoid in sulphonamide allergy. Monitor bicarbonate and GFR. Risk of reduced sweating (hyperthermia). Do not use in children <6 years.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'zonisamida');

-- 24. Lacosamida
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial (adjunto ou monoterapia).',
  indications_en = 'Partial epilepsy (adjunct or monotherapy).',
  side_effects_pt = 'Náusea, tonturas, cefaleia, diplopia, fadiga, erupção cutânea.',
  side_effects_en = 'Nausea, dizziness, headache, diplopia, fatigue, skin rash.',
  precautions_pt = 'Poucas interações medicamentosas. Inibe fracamente CYP2C19. Monitorizar ECG (prolongamento PR em doses altas).',
  precautions_en = 'Few drug interactions. Weakly inhibits CYP2C19. Monitor ECG (PR prolongation at high doses).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'lacosamida');

-- 25. Primidona
UPDATE public.drug_profiles SET
  indications_pt = 'Epilepsia parcial e generalizada. Raramente usado actualmente (substituído por fenobarbital).',
  indications_en = 'Partial and generalised epilepsy. Rarely used now (replaced by phenobarbital).',
  side_effects_pt = 'Sonolência, fadiga, tonturas, náusea, perturbações comportamentais (crianças), anemia megaloblástica.',
  side_effects_en = 'Somnolence, fatigue, dizziness, nausea, behavioural disturbances (children), megaloblastic anaemia.',
  precautions_pt = 'Metabolizado a fenobarbital — mesmo perfil de interações. Induz CYP. Risco de depressão SNC. Usar raramente (preferir fenobarbital directamente).',
  precautions_en = 'Metabolised to phenobarbital — same interaction profile. Induces CYP. Risk of CNS depression. Use rarely (prefer phenobarbital directly).'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'primidona');
