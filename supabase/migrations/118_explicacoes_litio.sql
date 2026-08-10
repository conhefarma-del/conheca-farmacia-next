-- =====================================================================
-- 118 — Explicações fármaco-fármaco dos pares moderados do LÍTIO
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 8 pares moderados do lítio que os tinham vazios
-- (lítio+ibuprofeno já tinha explicação na 107).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais do lítio (janela terapêutica estreita, eliminação
-- renal que acompanha o sódio):
--   1. AINEs (diclofenac, naproxeno) — redução da depuração renal do lítio
--      por inibição das prostaglandinas renais (litemia ↑ ~15%, depuração ↓
--      ~20% — rótulos dos AINEs);
--   2. Diuréticos tiazídicos (hidroclorotiazida) — perda de sódio reduz a
--      depuração do lítio ("generally should not be given with diuretics");
--   3. IECA (enalapril, captopril) — toxicidade do lítio reportada;
--   4. Metronidazol — elevação da litemia em doentes estabilizados;
--   5. Fluoxetina (serotonérgico) — risco de síndrome serotoninérgica;
--   6. Haloperidol — síndrome encefalopática/neurotoxicidade.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/8 — CAPTOPRIL + LÍTIO (IECA — litemia ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Captopril + lítio: o IECA pode aumentar a litemia e causar toxicidade. Usar com precaução e monitorizar níveis de lítio com frequência.',
  summary_pro_en = 'Captopril + lithium: the ACE inhibitor can raise lithium levels and cause toxicity. Use with caution and monitor lithium levels frequently.',
  explanation_pt = 'Os inibidores da enzima de conversão da angiotensina (IECA), como o captopril, podem aumentar os níveis séricos de lítio e causar sinais de toxicidade do lítio em doentes a fazer lítio concomitantemente; o rótulo do captopril recomenda coadministrar com precaução e monitorizar os níveis séricos de lítio com frequência, referindo ainda que, se for usado também um diurético, o risco de toxicidade do lítio aumenta. A monitorização é especialmente importante no início do IECA e em qualquer alteração de dose, e deve incluir os sinais de toxicidade do lítio (tremor, confusão, ataxia, disartria, diarreia).',
  explanation_en = 'Angiotensin-converting enzyme (ACE) inhibitors such as captopril can raise serum lithium levels and cause signs of lithium toxicity in patients on concomitant lithium; the captopril label recommends co-administering with caution and monitoring serum lithium levels frequently, noting that if a diuretic is also used, the risk of lithium toxicity increases. Monitoring is especially important when starting the ACE inhibitor and at any dose change, and should include signs of lithium toxicity (tremor, confusion, ataxia, dysarthria, diarrhoea).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 2/8 — DICLOFENAC + LÍTIO (AINE — depuração renal do lítio ↓)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diclofenac + lítio: o AINE reduz a depuração renal do lítio e aumenta a litemia. Monitorizar níveis e sinais de toxicidade.',
  summary_pro_en = 'Diclofenac + lithium: the NSAID reduces renal lithium clearance and raises lithium levels. Monitor levels and signs of toxicity.',
  explanation_pt = 'Os AINEs, incluindo o diclofenac, reduzem a depuração renal do lítio por inibição da síntese de prostaglandinas renais: o rótulo do diclofenac documenta elevações da concentração plasmática mínima de lítio em cerca de 15% e redução da depuração renal em aproximadamente 20%. O aumento da litemia pode precipitar toxicidade do lítio (tremor, confusão, ataxia, disartria), sobretudo em idosos, com desidratação ou insuficiência renal. Recomenda-se monitorizar a litemia quando se inicia, ajusta ou suspende o AINE, usar a menor dose eficaz e vigiar sinais de toxicidade.',
  explanation_en = 'NSAIDs, including diclofenac, reduce renal lithium clearance by inhibiting renal prostaglandin synthesis: the diclofenac label documents increases in the mean minimum plasma lithium concentration of about 15% and a reduction in renal clearance of approximately 20%. The rise in lithium levels can precipitate lithium toxicity (tremor, confusion, ataxia, dysarthria), especially in the elderly, with dehydration or renal impairment. Monitor lithium levels when starting, adjusting or stopping the NSAID, use the lowest effective dose and watch for signs of toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 3/8 — ENALAPRIL + LÍTIO (IECA — toxicidade do lítio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Enalapril + lítio: toxicidade do lítio reportada com IECA. Monitorizar a litemia com frequência durante a associação.',
  summary_pro_en = 'Enalapril + lithium: lithium toxicity reported with ACE inhibitors. Monitor lithium levels frequently during the combination.',
  explanation_pt = 'A toxicidade do lítio foi reportada em doentes a receber lítio concomitantemente com fármacos que causam eliminação de sódio, incluindo os IECA; o rótulo do enalapril descreve casos de toxicidade do lítio em doentes com enalapril e lítio, reversíveis após a suspensão de ambos, e recomenda monitorizar os níveis séricos de lítio com frequência se o enalapril for administrado com lítio. O mecanismo envolve a redução da eliminação renal do lítio associada à depleção de sódio. Monitorizar a litemia no início e durante a associação e vigiar sinais de toxicidade (tremor, confusão, ataxia, diarreia).',
  explanation_en = 'Lithium toxicity has been reported in patients receiving lithium concomitantly with drugs that cause sodium elimination, including ACE inhibitors; the enalapril label describes cases of lithium toxicity in patients on enalapril and lithium, reversible after discontinuation of both, and recommends monitoring serum lithium levels frequently if enalapril is given with lithium. The mechanism involves reduced renal lithium elimination associated with sodium depletion. Monitor lithium levels at the start and during the combination and watch for signs of toxicity (tremor, confusion, ataxia, diarrhoea).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 4/8 — FLUOXETINA + LÍTIO (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluoxetina + lítio: risco de síndrome serotoninérgica. Informar o doente e monitorizar sintomas, sobretudo no início e em aumentos de dose.',
  summary_pro_en = 'Fluoxetine + lithium: risk of serotonin syndrome. Inform the patient and monitor symptoms, especially at initiation and dose increases.',
  explanation_pt = 'O lítio pode precipitar síndrome serotoninérgica, potencialmente fatal, e o risco aumenta com o uso concomitante de outros fármacos serotonérgicos, incluindo os ISRS como a fluoxetina; os rótulos do lítio e da fluoxetina recomendam informar o doente do risco aumentado e monitorizar sintomas (agitação, alucinações, delírio, taquicardia, hipertermia, tremor, rigidez, mioclonias, hiperreflexia, convulsões, sintomas gastrointestinais), sobretudo na iniciação e em aumentos de dose. Se surgirem sintomas, suspender o lítio e os serotonérgicos e iniciar tratamento de suporte.',
  explanation_en = 'Lithium can precipitate serotonin syndrome, potentially life-threatening, and the risk increases with concomitant use of other serotonergic drugs, including SSRIs such as fluoxetine; the lithium and fluoxetine labels recommend informing the patient of the increased risk and monitoring symptoms (agitation, hallucinations, delirium, tachycardia, hyperthermia, tremor, rigidity, myoclonus, hyperreflexia, seizures, gastrointestinal symptoms), especially at initiation and dose increases. If symptoms arise, stop lithium and the serotonergic agents and start supportive treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 5/8 — HALOPERIDOL + LÍTIO (neurotoxicidade/encefalopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Haloperidol + lítio: síndrome encefalopática/neurotoxicidade descrita. Monitorizar de perto sinais neurológicos precoces.',
  summary_pro_en = 'Haloperidol + lithium: encephalopathic syndrome/neurotoxicity described. Monitor closely for early neurological signs.',
  explanation_pt = 'Foi descrita uma síndrome encefalopática (fraqueza, letargia, febre, tremores, confusão, sintomas extrapiramidais, leucocitose, elevação de enzimas séricas) seguida de lesão cerebral irreversível em alguns doentes tratados com lítio mais haloperidol, embora não tenha sido estabelecida uma relação causal; o rótulo do haloperidol recomenda que os doentes com esta combinação sejam monitorizados de perto para evidência precoce de toxicidade neurológica e que o tratamento seja suspenso prontamente se esses sinais aparecerem. Usar as menores doses eficazes de ambos, vigiar sinais neurológicos e litemia, e reavaliar a associação se surgirem sintomas.',
  explanation_en = 'An encephalopathic syndrome (weakness, lethargy, fever, tremulousness, confusion, extrapyramidal symptoms, leukocytosis, elevated serum enzymes) followed by irreversible brain damage has occurred in a few patients treated with lithium plus haloperidol, although a causal relationship has not been established; the haloperidol label recommends monitoring patients on this combination closely for early evidence of neurological toxicity and discontinuing treatment promptly if such signs appear. Use the lowest effective doses of both, monitor neurological signs and lithium levels, and reassess the combination if symptoms arise.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'haloperidol'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'haloperidol'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 6/8 — HIDROCLOROTIAZIDA + LÍTIO (tiazida — depuração do lítio ↓)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroclorotiazida + lítio: as tiazidas reduzem a depuração renal do lítio e aumentam muito o risco de toxicidade. Evitar; se inevitável, monitorizar litemia.',
  summary_pro_en = 'Hydrochlorothiazide + lithium: thiazides reduce renal lithium clearance and greatly increase the risk of toxicity. Avoid; if unavoidable, monitor lithium levels.',
  explanation_pt = 'As tiazidas, como a hidroclorotiazida, reduzem a depuração renal do lítio: a perda de sódio induzida pelo diurético diminui a eliminação do lítio e aumenta de forma marcada o risco de toxicidade. O rótulo da hidroclorotiazida indica que o lítio geralmente não deve ser administrado com diuréticos e remete para o folheto do lítio; o rótulo do lítio confirma que a perda de sódio induzida pelos diuréticos pode reduzir a depuração do lítio e aumentar a litemia. Se a associação for inevitável, reduzir a dose do lítio, monitorizar a litemia com frequência e vigiar sinais de toxicidade (tremor, confusão, ataxia, disartria); assegurar ingestão adequada de sódio.',
  explanation_en = 'Thiazides such as hydrochlorothiazide reduce renal lithium clearance: diuretic-induced sodium loss decreases lithium elimination and markedly increases the risk of toxicity. The hydrochlorothiazide label states that lithium generally should not be given with diuretics and refers to the lithium package insert; the lithium label confirms that diuretic-induced sodium loss can reduce lithium clearance and raise lithium levels. If the combination is unavoidable, reduce the lithium dose, monitor lithium levels frequently and watch for signs of toxicity (tremor, confusion, ataxia, dysarthria); ensure adequate sodium intake.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 7/8 — LÍTIO + METRONIDAZOL (litemia ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Lítio + metronidazol: pode elevar a litemia e causar toxicidade. Obter litemia e creatinina alguns dias após iniciar o metronidazol.',
  summary_pro_en = 'Lithium + metronidazole: can raise lithium levels and cause toxicity. Check lithium and creatinine a few days after starting metronidazole.',
  explanation_pt = 'Em doentes estabilizados com doses relativamente altas de lítio, a terapêutica de curta duração com metronidazol foi associada a elevação do lítio sérico e, em alguns casos, a sinais de toxicidade do lítio; o rótulo do metronidazol recomenda obter os níveis séricos de lítio e de creatinina alguns dias após iniciar o metronidazol, para detetar qualquer aumento que possa preceder os sintomas clínicos de intoxicação pelo lítio. O rótulo do lítio inclui o metronidazol entre os fármacos que podem aumentar a litemia, com recomendação de monitorização frequente e ajuste da dose.',
  explanation_en = 'In patients stabilised on relatively high lithium doses, short-term metronidazole therapy has been associated with elevation of serum lithium and, in a few cases, signs of lithium toxicity; the metronidazole label recommends obtaining serum lithium and creatinine levels a few days after starting metronidazole, to detect any increase that may precede clinical symptoms of lithium intoxication. The lithium label includes metronidazole among the drugs that can raise lithium levels, with a recommendation for frequent monitoring and dose adjustment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'litio'), (SELECT id FROM public.drugs WHERE slug = 'metronidazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'litio'), (SELECT id FROM public.drugs WHERE slug = 'metronidazol'));

-- 8/8 — LÍTIO + NAPROXENO (AINE — depuração renal do lítio ↓)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Lítio + naproxeno: o AINE reduz a depuração renal do lítio e aumenta a litemia. Monitorizar níveis e sinais de toxicidade.',
  summary_pro_en = 'Lithium + naproxen: the NSAID reduces renal lithium clearance and raises lithium levels. Monitor levels and signs of toxicity.',
  explanation_pt = 'Os AINEs, incluindo o naproxeno, reduzem a depuração renal do lítio por inibição da síntese de prostaglandinas renais: o rótulo do naproxeno documenta elevações da concentração plasmática mínima de lítio em cerca de 15% e redução da depuração renal em aproximadamente 20%. O aumento da litemia pode precipitar toxicidade do lítio (tremor, confusão, ataxia, disartria), sobretudo em idosos, com desidratação ou insuficiência renal. Recomenda-se monitorizar a litemia quando se inicia, ajusta ou suspende o AINE, usar a menor dose eficaz e vigiar sinais de toxicidade.',
  explanation_en = 'NSAIDs, including naproxen, reduce renal lithium clearance by inhibiting renal prostaglandin synthesis: the naproxen label documents increases in the mean minimum plasma lithium concentration of about 15% and a reduction in renal clearance of approximately 20%. The rise in lithium levels can precipitate lithium toxicity (tremor, confusion, ataxia, dysarthria), especially in the elderly, with dehydration or renal impairment. Monitor lithium levels when starting, adjusting or stopping the NSAID, use the lowest effective dose and watch for signs of toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'litio'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'litio'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'));
