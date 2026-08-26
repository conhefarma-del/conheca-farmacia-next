-- =====================================================================
-- 218 — Explicações longas dos pares Antiepilépticos
--
-- 2 critical + 13 moderate = 15 pares
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
-- =====================================================================

-- ═══════════════════════════════════════════════════════════════════
-- CRITICAL PAIRS
-- ═══════════════════════════════════════════════════════════════════

-- 1. Lamotrigina × Valproato (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Valproato duplica níveis de lamotrigina via inibição UGT2B7. Risco de SJS/TEN especialmente em dose inicial alta.',
  summary_pro_en = 'Valproate doubles lamotrigine levels via UGT2B7 inhibition. Risk of SJS/TEN especially at high initial doses.',
  explanation_pt = 'A lamotrigina é metabolizada principalmente por glucuronidação via UGT2B7 (e UGT1A4). O valproato inibe potentes estas enzimas, aumentando a meia-vida de lamotrigina de 25 h para 60 h e duplicando os níveis em estado estacionário. O risco mais grave é síndrome de Stevens-Johnson (SJS) e necrólise epidérmica tóxica (TEN), especialmente quando a dose inicial é alta ou o aumento é rápido. O Prontuário Terapêutico português recomenda: dose inicial 12,5 mg/dia (em vez de 25 mg), aumentos de 25 mg a cada 2 semanas (em vez de semanais), e suspensão imediata perante qualquer erupção cutânea. Monitorizar erupções cutâneas diariamente nas primeiras 8 semanas.',
  explanation_en = 'Lamotrigine is primarily metabolised by glucuronidation via UGT2B7 (and UGT1A4). Valproate potently inhibits these enzymes, increasing lamotrigine half-life from 25 h to 60 h and doubling steady-state levels. The most serious risk is Stevens-Johnson syndrome (SJS) and toxic epidermal necrolysis (TEN), especially when the initial dose is high or titration is rapid. The Portuguese Prontuário Terapêutico recommends: initial dose 12.5 mg/day (instead of 25 mg), increases of 25 mg every 2 weeks (instead of weekly), and immediate discontinuation at any skin rash. Monitor for skin rashes daily during the first 8 weeks.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('lamotrigina', 'valproato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('lamotrigina', 'valproato'))
  AND drug_a_id != drug_b_id;

-- 2. Fenobarbital × Primidona (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Primidona = pro-fármaco de fenobarbital (50-60%). Efeito aditivo depressor SNC perigoso.',
  summary_pro_en = 'Primidone = phenobarbital prodrug (50-60%). Dangerous additive CNS depressant effect.',
  explanation_pt = 'A primidona é metabolizada a fenobarbital (50-60%, meia-vida 80-120 h) e feniletilmalonamida (25-30%). A coadministração com fenobarbital resulta em níveis aditivos de fenobarbital, multiplicando o risco de depressão respiratória, sedação profunda e coma. Esta combinação é clinicamente redundante — ambos actuam via potenciação GABA-A. Se primidona é essencial (raro), reduzir fenobarbital 50% e monitorizar níveis de fenobarbital (alvo: 15-40 μg/mL). Alternativa: trocar primidona por fenobarbital directamente.',
  explanation_en = 'Primidone is metabolised to phenobarbital (50-60%, half-life 80-120 h) and phenylethylmalonamide (25-30%). Co-administration with phenobarbital results in additive phenobarbital levels, multiplying the risk of respiratory depression, profound sedation, and coma. This combination is clinically redundant — both act via GABA-A potentiation. If primidone is essential (rare), reduce phenobarbital by 50% and monitor phenobarbital levels (target: 15-40 μg/mL). Alternative: switch primidone directly to phenobarbital.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fenobarbital', 'primidona'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fenobarbital', 'primidona'))
  AND drug_a_id != drug_b_id;

-- ═══════════════════════════════════════════════════════════════════
-- MODERATE PAIRS
-- ═══════════════════════════════════════════════════════════════════

-- 3. Topiramato × Valproato (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ambos inibem anidrase carbonica. Risco aditivo de pedras renais e acidose metabólica.',
  summary_pro_en = 'Both inhibit carbonic anhydrase. Additive risk of renal stones and metabolic acidosis.',
  explanation_pt = 'O topiramato inibe a anidrase carbonica (isoenzimas II e IV), causando acidose metabólica hiperclorémica (5-10% dos doentes) e pedras renais (1-2%). O valproato também inibe a anidrase carbonica fracamente. A combinação aumenta significativamente estes riscos. Monitorizar bicarbonato sérico trimestralmente, TFG e considerar ecografia renal anual. Manter hidratação adequada (>2 L/dia). Suplementar citrato de potássio se bicarbonato <20 mEq/L.',
  explanation_en = 'Topiramate inhibits carbonic anhydrase (isoenzymes II and IV), causing hyperchloraemic metabolic acidosis (5-10% of patients) and renal stones (1-2%). Valproate also weakly inhibits carbonic anhydrase. The combination significantly increases these risks. Monitor serum bicarbonate quarterly, GFR, and consider annual renal ultrasound. Maintain adequate hydration (>2 L/day). Supplement potassium citrate if bicarbonate <20 mEq/L.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'valproato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'valproato'))
  AND drug_a_id != drug_b_id;

-- 4. Topiramato × Carbamazepina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina induz CYP3A4/UGT, reduzindo níveis de topiramato ~40%. Risco de perda de controlo de crises.',
  summary_pro_en = 'Carbamazepine induces CYP3A4/UGT, reducing topiramate levels ~40%. Risk of loss of seizure control.',
  explanation_pt = 'A carbamazepina é um potente indutor de CYP3A4 e UGT. O topiramato é parcialmente metabolizado por CYP3A4 (40%) e glucuronidado (50%). A coadministração reduz os níveis de topiramato em ~40%, podendo comprometer o controlo de crises. Ajustar dose de topiramato conforme resposta clínica. Em alguns casos, pode ser necessário duplicar a dose de topiramato.',
  explanation_en = 'Carbamazepine is a potent inducer of CYP3A4 and UGT. Topiramate is partially metabolised by CYP3A4 (40%) and glucuronidated (50%). Co-administration reduces topiramate levels by ~40%, potentially compromising seizure control. Adjust topiramate dose based on clinical response. In some cases, it may be necessary to double the topiramate dose.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'carbamazepina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'carbamazepina'))
  AND drug_a_id != drug_b_id;

-- 5. Topiramato × Fenitoína (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fenitoína induz CYP3A4/2C9, reduzindo topiramato 30-40%. Ajustar dose conforme resposta.',
  summary_pro_en = 'Phenytoin induces CYP3A4/2C9, reducing topiramate 30-40%. Adjust dose based on response.',
  explanation_pt = 'A fenitoína induz CYP3A4 e CYP2C9, acelerando o metabolismo do topiramato. Os níveis podem reduzir 30-40%. O efeito é dose-dependente — doses elevadas de fenitoína causam maior redução. Monitorizar controlo de crises e ajustar dose de topiramato.',
  explanation_en = 'Phenytoin induces CYP3A4 and CYP2C9, accelerating topiramate metabolism. Levels may decrease 30-40%. The effect is dose-dependent — higher phenytoin doses cause greater reduction. Monitor seizure control and adjust topiramate dose.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'fenitoina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'fenitoina'))
  AND drug_a_id != drug_b_id;

-- 6. Oxcarbazepina × Fenitoína (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Oxcarbazepina (MHD) reduz fenitoína 20-30%. Monitorizar níveis de fenitoína.',
  summary_pro_en = 'Oxcarbazepine (MHD) reduces phenytoin 20-30%. Monitor phenytoin levels.',
  explanation_pt = 'O MHD (metabolito activo da oxcarbazepina) pode competir pela ligação a proteínas plasmáticas e induzir CYP levemente, reduzindo os níveis de fenitoína 20-30%. O efeito é mais pronunciado em doses elevadas de oxcarbazepina (>1200 mg/dia). Monitorizar níveis de fenitoína (alvo: 10-20 μg/mL) e sinais de toxicidade.',
  explanation_en = 'MHD (active metabolite of oxcarbazepine) may compete for plasma protein binding and weakly induce CYP, reducing phenytoin levels 20-30%. The effect is more pronounced at higher oxcarbazepine doses (>1200 mg/day). Monitor phenytoin levels (target: 10-20 μg/mL) and signs of toxicity.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'fenitoina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'fenitoina'))
  AND drug_a_id != drug_b_id;

-- 7. Gabapentina × Valproato (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Efeito aditivo sobre tremor e sedação. Sem interação farmacocinética significativa.',
  summary_pro_en = 'Additive effect on tremor and sedation. No significant pharmacokinetic interaction.',
  explanation_pt = 'Ambos podem causar tremor e sedação como efeitos adversos. O efeito é aditivo mas não há interação farmacocinética — a gabapentina não é metabolizada por CYP e o valproato não afecta a excreção renal da gabapentina. Monitorizar sedação e tremor, especialmente em idosos.',
  explanation_en = 'Both can cause tremor and sedation as adverse effects. The effect is additive but there is no pharmacokinetic interaction — gabapentin is not metabolised by CYP and valproate does not affect gabapentin renal excretion. Monitor sedation and tremor, especially in the elderly.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('gabapentina', 'valproato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('gabapentina', 'valproato'))
  AND drug_a_id != drug_b_id;

-- 8. Topiramato × Zonisamida (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois inibidores de anidrase carbonica: risco significativo de acidose metabólica e pedras renais.',
  summary_pro_en = 'Two carbonic anhydrase inhibitors: significant risk of metabolic acidosis and renal stones.',
  explanation_pt = 'Ambos inibem a anidrase carbonica (isoenzimas II e IV). A combinação multiplica o risco de acidose metabólica hiperclorémica (pode atingir 10-15% dos doentes), hipocalemia e nefrolitíase. Evitar esta combinação. Se inevitável, monitorizar bicarbonato, electrolitos e TFG quinzenalmente nos primeiros 3 meses, depois mensalmente.',
  explanation_en = 'Both inhibit carbonic anhydrase (isoenzymes II and IV). The combination multiplies the risk of hyperchloraemic metabolic acidosis (may reach 10-15% of patients), hypokalaemia, and nephrolithiasis. Avoid this combination. If unavoidable, monitor bicarbonate, electrolytes, and GFR fortnightly for the first 3 months, then monthly.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'zonisamida'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('topiramato', 'zonisamida'))
  AND drug_a_id != drug_b_id;

-- 9. Carbamazepina × Primidona (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois potentes indutores CYP/UGT: reduzem drasticamente níveis de outros fármacos.',
  summary_pro_en = 'Two potent CYP/UGT inducers: drastically reduce levels of other drugs.',
  explanation_pt = 'Ambos são potentes indutores de CYP3A4, CYP2C9, CYP2C19 e UGT. A combinação pode reduzir os níveis de warfarina, contracetivos orais, anticoagulantes e outros fármacos em >50%. Esta combinação é clinicamente redundante (ambos tratam epilepsia) e perigosa. Evitar. Se necessária, ajustar todas as medicações concomitantes e monitorizar níveis.',
  explanation_en = 'Both are potent inducers of CYP3A4, CYP2C9, CYP2C19, and UGT. The combination may reduce levels of warfarin, oral contraceptives, anticoagulants, and other drugs by >50%. This combination is clinically redundant (both treat epilepsy) and dangerous. Avoid. If necessary, adjust all concomitant medications and monitor levels.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('carbamazepina', 'primidona'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('carbamazepina', 'primidona'))
  AND drug_a_id != drug_b_id;

-- 10. Oxcarbazepina × Ritonavir (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Oxcarbazepina induz CYP3A4 moderadamente. Efeito oposto ao ritonavir. Resultado imprevisível.',
  summary_pro_en = 'Oxcarbazepine moderately induces CYP3A4. Opposing effect to ritonavir. Unpredictable outcome.',
  explanation_pt = 'A oxcarbazepina (MHD) induz CYP3A4 moderadamente, enquanto o ritonavir inibe CYP3A4 potentes. O resultado depende da dose e timing — geralmente o efeito inibidor do ritonavir domina. No entanto, a oxcarbazepina pode comprometer a profilaxia pré-exposição (PrEP) ou regimes ARV baseados em inibidores de integrase. Considerar trocar oxcarbazepina por levetiracetam (não induz CYP) em doentes VIH.',
  explanation_en = 'Oxcarbazepine (MHD) moderately induces CYP3A4, while ritonavir potently inhibits CYP3A4. The outcome depends on dose and timing — generally ritonavir''s inhibitory effect predominates. However, oxcarbazepine may compromise pre-exposure prophylaxis (PrEP) or integrase inhibitor-based ARV regimens. Consider switching oxcarbazepine to levetiracetam (does not induce CYP) in HIV patients.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'ritonavir'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'ritonavir'))
  AND drug_a_id != drug_b_id;

-- 11. Warfarina × Oxcarbazepina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Oxcarbazepina induz CYP3A4/2C9, reduzindo efeito da warfarina. Monitorizar INR.',
  summary_pro_en = 'Oxcarbazepine induces CYP3A4/2C9, reducing warfarin effect. Monitor INR.',
  explanation_pt = 'A oxcarbazepina induz CYP3A4 e CYP2C9, as vias metabolizadoras da warfarina (S e R enantiómeros). A coadministração pode reduzir o INR significativamente, aumentando risco tromboembólico. Monitorizar INR semanalmente durante as primeiras 4 semanas após início ou alteração de dose.',
  explanation_en = 'Oxcarbazepine induces CYP3A4 and CYP2C9, metabolic pathways for warfarin (S and R enantiomers). Co-administration may significantly reduce INR, increasing thromboembolic risk. Monitor INR weekly during the first 4 weeks after initiation or dose change.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'warfarina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('oxcarbazepina', 'warfarina'))
  AND drug_a_id != drug_b_id;

-- 12. Gabapentina × Pregabalina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois gabapentinoides: efeito aditivo depressor SNC sem benefício terapêutico adicional.',
  summary_pro_en = 'Two gabapentinoids: additive CNS depressant effect without additional therapeutic benefit.',
  explanation_pt = 'Ambos actuam sobre a subunidade α2δ dos canais de cálcio voltagem-dependentes. A combinação não oferece benefício terapêutico adicional (mesmo mecanismo) e aumenta significativamente o risco de sedação, tonturas, ataxia e dificuldade respiratória. Não combinar dois gabapentinoides — escolher um consoante a indicação.',
  explanation_en = 'Both act on the α2δ subunit of voltage-gated calcium channels. The combination offers no additional therapeutic benefit (same mechanism) and significantly increases the risk of sedation, dizziness, ataxia, and respiratory difficulty. Do not combine two gabapentinoids — choose one based on the indication.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('gabapentina', 'pregabalina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('gabapentina', 'pregabalina'))
  AND drug_a_id != drug_b_id;

-- 13. Metformina × Topiramato (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Biguanida + inibidor anidrase carbonica: risco aditivo de acidose metabólica.',
  summary_pro_en = 'Biguanide + carbonic anhydrase inhibitor: additive risk of metabolic acidosis.',
  explanation_pt = 'O topiramato inibe a anidrase carbonica, causando acidose metabólica hiperclorémica (5-10%). A metformina pode causar acidose láctica (raro mas grave). Embora os mecanismos sejam diferentes, a acidose metabólica por topiramato pode mascarar os sinais iniciais de acidose láctica por metformina. Monitorizar bicarbonato sérico e TFG regularmente.',
  explanation_en = 'Topiramate inhibits carbonic anhydrase, causing hyperchloraemic metabolic acidosis (5-10%). Metformine may cause lactic acidosis (rare but serious). Although the mechanisms differ, topiramate-induced metabolic acidosis may mask early signs of metformine-induced lactic acidosis. Monitor serum bicarbonate and GFR regularly.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('metformina', 'topiramato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('metformina', 'topiramato'))
  AND drug_a_id != drug_b_id;

-- 14. Carbamazepina × Fluconazol (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol inibe CYP3A4, aumentando níveis de carbamazepina 20-40%. Risco de toxicidade.',
  summary_pro_en = 'Fluconazole inhibits CYP3A4, increasing carbamazepine levels 20-40%. Risk of toxicity.',
  explanation_pt = 'O fluconazol é um inibidor moderado de CYP3A4. A carbamazepina é metabolizada principalmente por CYP3A4. A coadministração pode aumentar os níveis de carbamazepina 20-40%, com risco de toxicidade (náusea, diplopia, ataxia, nistagmo). Monitorizar níveis de carbamazepina (alvo: 4-12 μg/mL) e sinais de toxicidade semanalmente durante a coadministração.',
  explanation_en = 'Fluconazole is a moderate CYP3A4 inhibitor. Carbamazepine is mainly metabolised by CYP3A4. Co-administration may increase carbamazepine levels 20-40%, with risk of toxicity (nausea, diplopia, ataxia, nystagmus). Monitor carbamazepine levels (target: 4-12 μg/mL) and signs of toxicity weekly during co-administration.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('carbamazepina', 'fluconazol'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('carbamazepina', 'fluconazol'))
  AND drug_a_id != drug_b_id;

-- 15. Fenitoína × Valproato (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Valproato desloca fenitoína de albumina, aumentando fração livre. Monitorizar níveis livres.',
  summary_pro_en = 'Valproate displaces phenytoin from albumin, increasing free fraction. Monitor free levels.',
  explanation_pt = 'O valproato pode deslocar a fenitoína da albumina plasmática, aumentando a fração livre de 10% para 20-30%. O efeito é complexo: os níveis totais de fenitoína podem diminuir (metabolismo de primeira ordem da fração livre aumentada), mas os níveis livres (farmacologicamente activos) podem aumentar. Medir níveis LIVRES de fenitoína, não apenas totais. Ajustar dose conforme níveis livres (alvo: 1-2 μg/mL livres).',
  explanation_en = 'Valproate may displace phenytoin from plasma albumin, increasing the free fraction from 10% to 20-30%. The effect is complex: total phenytoin levels may decrease (first-order metabolism of the increased free fraction), but free (pharmacologically active) levels may increase. Measure FREE phenytoin levels, not just total. Adjust dose based on free levels (target: 1-2 μg/mL free).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fenitoina', 'valproato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fenitoina', 'valproato'))
  AND drug_a_id != drug_b_id;
