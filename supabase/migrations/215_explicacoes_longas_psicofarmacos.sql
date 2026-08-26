-- =====================================================================
-- 215 — Explicações longas dos pares Antipsicóticos/Antidepressivos
--
-- 4 critical + 16 moderate = 20 pares
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
-- =====================================================================

-- ═══════════════════════════════════════════════════════════════════
-- CRITICAL PAIRS
-- ═══════════════════════════════════════════════════════════════════

-- 1. Fluoxetina × Risperidona (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS inibidor CYP2D6 + antipsicótico: níveis de risperidona aumentados 2-4x. Risco de EEP e síndrome neuroléptica maligna.',
  summary_pro_en = 'CYP2D6 inhibitor SSRI + antipsychotic: risperidone levels increased 2-4-fold. Risk of EPS and neuroleptic malignant syndrome.',
  explanation_pt = 'A fluoxetina é um potente inibidor de CYP2D6 (Ki ~0,2 μM), a principal via metabolizadora da risperidona (70% da clearance). A coadministração aumenta os níveis de risperidona em 2-4x, dependendo do fenótipo CYP2D6 do doente. O risco de efeitos extrapiramidais (tremor, rigidez, parkinsonismo) aumenta significativamente. Em casos graves, pode ocorrer síndrome neuroléptica maligna (hipertermia >40°C, rigidez muscular, inconsciência, instabilidade autonómica). A fluoxetina tem meia-vida longa (2-6 dias) e o seu metabolito activo (norfluoxetina) inibe CYP2D6 durante 2-3 semanas após suspensão. O Prontuário Terapêutico português recomenda reduzir a dose de risperidona 50% ou trocar para antipsicótico não metabolizado por CYP2D6 (ex: aripiprazol, quetiapina).',
  explanation_en = 'Fluoxetine is a potent CYP2D6 inhibitor (Ki ~0.2 μM), the main metabolic pathway for risperidone (70% of clearance). Co-administration increases risperidone levels 2-4-fold, depending on the patient''s CYP2D6 phenotype. The risk of extrapyramidal effects (tremor, rigidity, parkinsonism) increases significantly. In severe cases, neuroleptic malignant syndrome may occur (hyperthermia >40°C, muscular rigidity, unconsciousness, autonomic instability). Fluoxetine has a long half-life (2-6 days) and its active metabolite (norfluoxetine) inhibits CYP2D6 for 2-3 weeks after discontinuation. The Portuguese Prontuário Terapêutico recommends reducing risperidone dose by 50% or switching to an antipsychotic not metabolised by CYP2D6 (e.g. aripiprazole, quetiapine).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'risperidona'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'risperidona'))
  AND drug_a_id != drug_b_id;

-- 2. Fluoxetina × Amitriptilina (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS inibidor CYP2D6 + TCA: níveis de amitriptilina aumentados 2-4x. Risco de toxicidade cardiaca (prolongamento QTc, arritmias).',
  summary_pro_en = 'CYP2D6 inhibitor SSRI + TCA: amitriptyline levels increased 2-4-fold. Risk of cardiac toxicity (QTc prolongation, arrhythmias).',
  explanation_pt = 'A fluoxetina inibe o CYP2D6, a principal via metabolizadora da amitriptilina (N-desmetilação). Os níveis de TCA podem aumentar 2-4x, com risco de toxicidade cardiaca: prolongamento do QTc >500 ms, arritmias ventriculares (torsades de pointes), convulsões e depressão do SNC. A amitriptilina tem índice terapêutico estreito (nível tóxico: >250 ng/mL). Monitorizar ECG e níveis de TCA se coadministração inevitável. Reduzir dose de TCA 50% e manter dose baixa. Considerar trocar fluoxetina por ISRS com menor inibição CYP2D6 (sertralina, citalopram).',
  explanation_en = 'Fluoxetine inhibits CYP2D6, the main metabolic pathway for amitriptyline (N-demethylation). TCA levels may increase 2-4-fold, with risk of cardiac toxicity: QTc prolongation >500 ms, ventricular arrhythmias (torsades de pointes), seizures, and CNS depression. Amitriptyline has a narrow therapeutic index (toxic level: >250 ng/mL). Monitor ECG and TCA levels if co-administration is unavoidable. Reduce TCA dose by 50% and maintain low dose. Consider switching fluoxetine to an SSRI with less CYP2D6 inhibition (sertraline, citalopram).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'amitriptilina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'amitriptilina'))
  AND drug_a_id != drug_b_id;

-- 3. Ritonavir × Carbamazepina (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor CYP3A4 potente + indutor CYP3A4: níveis de ritonavir reduzidos 50-90%. Risco de falha terapêutica do antirretroviral.',
  summary_pro_en = 'Potent CYP3A4 inhibitor + CYP3A4 inducer: ritonavir levels reduced 50-90%. Risk of antiretroviral therapeutic failure.',
  explanation_pt = 'A carbamazepina é um indutor potente de CYP3A4, CYP1A2 e UGT. O ritonavir é metabolizado por CYP3A4 e é ele próprio inibidor de CYP3A4. A coadministração reduz os níveis de ritonavir em 50-90%, comprometendo a eficácia do regime antirretroviral. A carbamazepina pode também induzir a P-glicoproteína, acelerando a eliminação do ritonavir. Esta combinação é CONTRAINDICADA pelas guidelines EACS/BHIVA. Alternativas: trocar carbamazepina por valproato (não indutor) ou por lamotrigina (indutor fraco). Se carbamazepina for essencial, usar regime ARV sem ritonavir (ex: dolutegravir + tenofovir + lamotrigina).',
  explanation_en = 'Carbamazepine is a potent inducer of CYP3A4, CYP1A2, and UGT. Ritonavir is metabolised by CYP3A4 and is itself a CYP3A4 inhibitor. Co-administration reduces ritonavir levels by 50-90%, compromising antiretroviral efficacy. Carbamazepine may also induce P-glycoprotein, accelerating ritonavir elimination. This combination is CONTRAINDICATED by EACS/BHIVA guidelines. Alternatives: switch carbamazepine to valproate (non-inducer) or lamotrigine (weak inducer). If carbamazepine is essential, use a ritonavir-free ARV regimen (e.g. dolutegravir + tenofovir + lamotrigine).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'carbamazepina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'carbamazepina'))
  AND drug_a_id != drug_b_id;

-- 4. Ritonavir × Fluoxetina (CRITICAL)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor CYP3A4/CYP2D6 + ISRS metabolizado por CYP2D6: níveis de fluoxetina aumentados 2-3x. Risco de síndrome serotoninérgica.',
  summary_pro_en = 'CYP3A4/CYP2D6 inhibitor + SSRI metabolised by CYP2D6: fluoxetine levels increased 2-3-fold. Risk of serotonin syndrome.',
  explanation_pt = 'O ritonavir inibe CYP3A4 e CYP2C19, e a fluoxetina é metabolizada por CYP2D6 e CYP3A4. A coadministração pode aumentar os níveis de fluoxetina em 2-3x. O risco principal é síndrome serotoninérgica (agitação, hiperreflexia, diaforese, hipertermia, rigidez), especialmente se combinada com outros fármacos serotoninérgicos. O ritonavir pode também inibir o metabolismo da norfluoxetina (metabolito activo), prolongando o efeito. Monitorizar sinais serotoninérgicos. Reduzir dose de ISRS 50% ou trocar por citalopram (metabolizado por CYP3A4/2C19, menos suscetível).',
  explanation_en = 'Ritonavir inhibits CYP3A4 and CYP2C19, and fluoxetine is metabolised by CYP2D6 and CYP3A4. Co-administration may increase fluoxetine levels 2-3-fold. The main risk is serotonin syndrome (agitation, hyperreflexia, diaphoresis, hyperthermia, rigidity), especially when combined with other serotonergic drugs. Ritonavir may also inhibit norfluoxetine (active metabolite) metabolism, prolonging the effect. Monitor for serotonergic signs. Reduce SSRI dose by 50% or switch to citalopram (metabolised by CYP3A4/2C19, less susceptible).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'fluoxetina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'fluoxetina'))
  AND drug_a_id != drug_b_id;

-- ═══════════════════════════════════════════════════════════════════
-- MODERATE PAIRS
-- ═══════════════════════════════════════════════════════════════════

-- 5. Fluoxetina × Metformina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + biguanida: ISRS pode reduzir TFG via efeito sobre prostaglandinas renais. Risco teórico de acumulação de metformina.',
  summary_pro_en = 'SSRI + biguanide: SSRI may reduce GFR via renal prostaglandin effect. Theoretical risk of metformin accumulation.',
  explanation_pt = 'A fluoxetina pode reduzir ligeiramente o fluxo sanguíneo renal via inibição de prostaglandinas, mas o efeito é significativamente menor que com AINE. O risco de acumulação de metformina é baixo em doentes com função renal normal. Em doentes com TFG borderline (45-60), considerar monitorizar TFG. Não há evidência de interação clinicamente significativa na maioria dos doentes.',
  explanation_en = 'Fluoxetine may slightly reduce renal blood flow via prostaglandin inhibition, but the effect is significantly less than with NSAIDs. The risk of metformin accumulation is low in patients with normal renal function. In patients with borderline GFR (45-60), consider monitoring GFR. There is no evidence of clinically significant interaction in most patients.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'metformina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'metformina'))
  AND drug_a_id != drug_b_id;

-- 6. Fluoxetina × Cimetidina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + bloqueador H2: cimetidina pode aumentar ligeiramente níveis de fluoxetina (inibição CYP). Efeito geralmente mínimo.',
  summary_pro_en = 'SSRI + H2 blocker: cimetidine may slightly increase fluoxetine levels (CYP inhibition). Effect generally minimal.',
  explanation_pt = 'A cimetidina inibe moderadamente CYP1A2, CYP2D6 e CYP3A4. A fluoxetina é metabolizada por CYP2D6 e CYP3A4. A coadministração pode aumentar os níveis de fluoxetina em 10-20%, mas o efeito é geralmente clinicamente insignificante. Em doentes idosos ou com polifarmácia, considerar trocar cimetidina por ranitidina/famotidina (não inibem CYP significativamente). Não requer ajuste de dose routine.',
  explanation_en = 'Cimetidine moderately inhibits CYP1A2, CYP2D6, and CYP3A4. Fluoxetine is metabolised by CYP2D6 and CYP3A4. Co-administration may increase fluoxetine levels by 10-20%, but the effect is generally clinically insignificant. In elderly patients or with polypharmacy, consider switching cimetidine to ranitidine/famotidine (do not significantly inhibit CYP). No routine dose adjustment required.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'cimetidina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'cimetidina'))
  AND drug_a_id != drug_b_id;

-- 7. Escitalopram × Ritonavir (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + inibidor CYP: ritonavir pode aumentar níveis de escitalopram. Risco de síndrome serotoninérgica.',
  summary_pro_en = 'SSRI + CYP inhibitor: ritonavir may increase escitalopram levels. Risk of serotonin syndrome.',
  explanation_pt = 'A escitalopram é metabolizada por CYP2C19 e CYP3A4. O ritonavir inibe CYP3A4 e CYP2C19. A coadministração pode aumentar os níveis de escitalopram em 1,5-2x. O risco de síndrome serotoninérgica é moderado. Monitorizar sinais serotoninérgicos (agitação, tremor, diaforese). Reduzir dose de escitalopram 50% se necessário. Alternativa: citalopram (metabolizado por CYP3A4, menos suscetível a ritonavir).',
  explanation_en = 'Escitalopram is metabolised by CYP2C19 and CYP3A4. Ritonavir inhibits CYP3A4 and CYP2C19. Co-administration may increase escitalopram levels 1.5-2-fold. The risk of serotonin syndrome is moderate. Monitor for serotonergic signs (agitation, tremor, diaphoresis). Reduce escitalopram dose by 50% if necessary. Alternative: citalopram (metabolised by CYP3A4, less susceptible to ritonavir).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('escitalopram', 'ritonavir'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('escitalopram', 'ritonavir'))
  AND drug_a_id != drug_b_id;

-- 8. Fluoxetina × Diazepam (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + benzodiazepina: fluoxetina pode inibir metabolismo de diazepam (CYP2C19/3A4). Sedação prolongada.',
  summary_pro_en = 'SSRI + benzodiazepine: fluoxetine may inhibit diazepam metabolism (CYP2C19/3A4). Prolonged sedation.',
  explanation_pt = 'A fluoxetina inibe moderadamente CYP2C19 e CYP3A4, vias metabolizadoras do diazepam. Os níveis de diazepam podem aumentar ligeiramente, prolongando a sedação. O efeito é geralmente modesto. Monitorizar sedação e função respiratória, especialmente em idosos. Considerar trocar diazepam por lorazepam (não metabolizado por CYP) ou alprazolam (metabolizado por CYP3A4 mas com meia-vida curta).',
  explanation_en = 'Fluoxetine moderately inhibits CYP2C19 and CYP3A4, metabolic pathways for diazepam. Diazepam levels may increase slightly, prolonging sedation. The effect is generally modest. Monitor sedation and respiratory function, especially in the elderly. Consider switching diazepam to lorazepam (not metabolised by CYP) or alprazolam (metabolised by CYP3A4 but with short half-life).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'diazepam'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'diazepam'))
  AND drug_a_id != drug_b_id;

-- 9. Venlafaxina × Ritonavir (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'SNRI + inibidor CYP3A4: ritonavir pode aumentar níveis de venlafaxina. Risco de hipertensão e síndrome serotoninérgica.',
  summary_pro_en = 'SNRI + CYP3A4 inhibitor: ritonavir may increase venlafaxine levels. Risk of hypertension and serotonin syndrome.',
  explanation_pt = 'A venlafaxina é metabolizada por CYP2D6 (desmetilvenlafaxina activa) e CYP3A4. O ritonavir inibe CYP3A4. A coadministração pode aumentar os níveis de venlafaxina em 1,5-2x. Risco adicional: venlafaxina pode causar hipertensão dose-dependente (>150 mg/dia), e níveis elevados aumentam este risco. Monitorizar PA e sinais serotoninérgicos. Reduzir dose de venlafaxina se necessário.',
  explanation_en = 'Venlafaxine is metabolised by CYP2D6 (active desvenlafaxine) and CYP3A4. Ritonavir inhibits CYP3A4. Co-administration may increase venlafaxine levels 1.5-2-fold. Additional risk: venlafaxine may cause dose-dependent hypertension (>150 mg/day), and elevated levels increase this risk. Monitor blood pressure and serotonergic signs. Reduce venlafaxine dose if necessary.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('venlafaxina', 'ritonavir'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('venlafaxina', 'ritonavir'))
  AND drug_a_id != drug_b_id;

-- 10. Duloxetina × Fluconazol (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'SNRI + inibidor CYP2C19: fluconazol pode aumentar níveis de duloxetina. Risco de hepatotoxicidade e síndrome serotoninérgica.',
  summary_pro_en = 'SNRI + CYP2C19 inhibitor: fluconazole may increase duloxetine levels. Risk of hepatotoxicity and serotonin syndrome.',
  explanation_pt = 'A duloxetina é metabolizada por CYP1A2 e CYP2C19. O fluconazol é um inibidor potente de CYP2C19. A coadministração pode aumentar os níveis de duloxetina em 2-3x. Ambos os fármacos têm potencial hepatotóxico, e a combinação aumenta o risco. Monitorizar função hepática (AST/ALT) e sinais serotoninérgicos. Reduzir dose de duloxetina 50% ou trocar por venlafaxina (menos dependente de CYP2C19).',
  explanation_en = 'Duloxetine is metabolised by CYP1A2 and CYP2C19. Fluconazole is a potent CYP2C19 inhibitor. Co-administration may increase duloxetine levels 2-3-fold. Both drugs have hepatotoxic potential, and the combination increases the risk. Monitor liver function (AST/ALT) and serotonergic signs. Reduce duloxetine dose by 50% or switch to venlafaxine (less dependent on CYP2C19).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('duloxetina', 'fluconazol'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('duloxetina', 'fluconazol'))
  AND drug_a_id != drug_b_id;

-- 11. Fluconazol × Olanzapina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor CYP1A2 + antipsicótico: fluconazol pode aumentar ligeiramente níveis de olanzapina. Efeito geralmente mínimo.',
  summary_pro_en = 'CYP1A2 inhibitor + antipsychotic: fluconazole may slightly increase olanzapine levels. Effect generally minimal.',
  explanation_pt = 'A olanzapina é metabolizada principalmente por CYP1A2 e UGT. O fluconazol inibe fracamente CYP1A2. O efeito sobre os níveis de olanzapina é geralmente mínimo (<20%). Não requer ajuste de dose routine. Monitorizar efeitos extrapiramidais se doente sensível.',
  explanation_en = 'Olanzapine is mainly metabolised by CYP1A2 and UGT. Fluconazole weakly inhibits CYP1A2. The effect on olanzapine levels is generally minimal (<20%). No routine dose adjustment required. Monitor for extrapyramidal effects if the patient is sensitive.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'olanzapina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'olanzapina'))
  AND drug_a_id != drug_b_id;

-- 12. Fluoxetina × Carbamazepina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + indutor CYP: carbamazepina pode reduzir níveis de fluoxetina 30-40%. Risco de perda de eficácia antidepressiva.',
  summary_pro_en = 'SSRI + CYP inducer: carbamazepine may reduce fluoxetine levels by 30-40%. Risk of loss of antidepressant efficacy.',
  explanation_pt = 'A carbamazepina induz CYP3A4 e CYP2C9, vias metabolizadoras parciais da fluoxetina. A coadministração pode reduzir os níveis de fluoxetina em 30-40%, diminuindo a eficácia antidepressiva. Pode ser necessário aumentar a dose de fluoxetina 20-50%. Monitorizar resposta antidepressiva. Alternativa: trocar carbamazepina por valproato ou lamotrigina (indutores fracos).',
  explanation_en = 'Carbamazepine induces CYP3A4 and CYP2C9, partial metabolic pathways for fluoxetine. Co-administration may reduce fluoxetine levels by 30-40%, decreasing antidepressant efficacy. It may be necessary to increase fluoxetine dose by 20-50%. Monitor antidepressant response. Alternative: switch carbamazepine to valproate or lamotrigine (weak inducers).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'carbamazepina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'carbamazepina'))
  AND drug_a_id != drug_b_id;

-- 13. Valproato × Carbamazepina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiepiléptico + indutor CYP: carbamazepina pode reduzir níveis de valproato 20-30%. Monitorizar níveis de valproato.',
  summary_pro_en = 'Antiepileptic + CYP inducer: carbamazepine may reduce valproate levels by 20-30%. Monitor valproate levels.',
  explanation_pt = 'A carbamazepina induz UGT, aumentando a glucuronidação do valproato. Os níveis de valproato podem reduzir 20-30%. O efeito é clínico significativo em epilepsia (risco de crises). Monitorizar níveis de valproato (alvo: 50-100 μg/mL). Pode ser necessário aumentar a dose de valproato. Alternativa: lamotrigina (não induz UGT significativamente).',
  explanation_en = 'Carbamazepine induces UGT, increasing valproate glucuronidation. Valproate levels may decrease by 20-30%. The effect is clinically significant in epilepsy (risk of seizures). Monitor valproate levels (target: 50-100 μg/mL). It may be necessary to increase the valproate dose. Alternative: lamotrigine (does not significantly induce UGT).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('valproato', 'carbamazepina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('valproato', 'carbamazepina'))
  AND drug_a_id != drug_b_id;

-- 14. Fluoxetina × Mirtazapina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + NaSSA: efeito aditivo serotoninérgico. Risco moderado de síndrome serotoninérgica.',
  summary_pro_en = 'SSRI + NaSSA: additive serotonergic effect. Moderate risk of serotonin syndrome.',
  explanation_pt = 'A mirtazapina é um NaSSA (antidepressivo noradrenérgico e serotoninérgico específico) que aumenta a libertação de serotonina via bloqueio α2. A combinação com fluoxetina (ISRS) aumenta a disponibilidade sináptica de serotonina de forma aditiva. O risco de síndrome serotoninérgica é moderado (maior que com dois ISRS). Monitorizar sinais: agitação, tremor, diaforese, hipertermia. Esta combinação é usada clinicamente em depressão resistente, mas requer vigilância.',
  explanation_en = 'Mirtazapine is a NaSSA (noradrenergic and specific serotonergic antidepressant) that increases serotonin release via α2 blockade. Combined with fluoxetine (SSRI), it increases synaptic serotonin availability additively. The risk of serotonin syndrome is moderate (higher than with two SSRIs). Monitor signs: agitation, tremor, diaphoresis, hyperthermia. This combination is used clinically in treatment-resistant depression, but requires vigilance.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'mirtazapina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'mirtazapina'))
  AND drug_a_id != drug_b_id;

-- 15. Diazepam × Ritonavir (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Benzodiazepina + inibidor CYP3A4: ritonavir pode aumentar níveis de diazepam. Sedação prolongada.',
  summary_pro_en = 'Benzodiazepine + CYP3A4 inhibitor: ritonavir may increase diazepam levels. Prolonged sedation.',
  explanation_pt = 'O ritonavir inibe CYP3A4, a principal via metabolizadora do diazepam. Os níveis podem aumentar significativamente, prolongando a sedação. Monitorizar sedação e função respiratória. Reduzir dose de diazepam 50%. Considerar trocar por lorazepam (não metabolizado por CYP) ou midazolam (curta acção).',
  explanation_en = 'Ritonavir inhibits CYP3A4, the main metabolic pathway for diazepam. Levels may increase significantly, prolonging sedation. Monitor sedation and respiratory function. Reduce diazepam dose by 50%. Consider switching to lorazepam (not metabolised by CYP) or midazolam (short-acting).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('diazepam', 'ritonavir'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('diazepam', 'ritonavir'))
  AND drug_a_id != drug_b_id;

-- 16. Litio × Risperidona (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Estabilizador de humor + antipsicótico: risco aumentado de EEP e neurotoxicidade. Monitorizar sinais de síndrome neuroléptica maligna.',
  summary_pro_en = 'Mood stabiliser + antipsychotic: increased risk of EPS and neurotoxicity. Monitor for neuroleptic malignant syndrome.',
  explanation_pt = 'A combinação é usada terapeuticamente na mania aguda e manutenção. No entanto, o risco de efeitos extrapiramidais e neurotoxicidade é aditivo. O lítio pode potenciar os EEP dos antipsicóticos. Monitorizar sinais de síndrome neuroléptica maligna (hipertermia, rigidez, inconsciência). Manter níveis de lítio dentro da faixa terapêutica (0,6-1,0 mEq/L). Ajustar doses conforme necessário.',
  explanation_en = 'The combination is used therapeutically in acute mania and maintenance. However, the risk of extrapyramidal effects and neurotoxicity is additive. Lithium may potentiate EPS from antipsychotics. Monitor for neuroleptic malignant syndrome (hyperthermia, rigidity, unconsciousness). Maintain lithium levels within therapeutic range (0.6-1.0 mEq/L). Adjust doses as needed.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('litio', 'risperidona'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('litio', 'risperidona'))
  AND drug_a_id != drug_b_id;

-- 17. Litio × Olanzapina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Estabilizador de humor + antipsicótico: efeito aditivo sobre sintomas maníacos. Risco aumentado de síndrome metabólica.',
  summary_pro_en = 'Mood stabiliser + antipsychotic: additive effect on manic symptoms. Increased risk of metabolic syndrome.',
  explanation_pt = 'A combinação é usada terapeuticamente na mania aguda. A olanzapina pode causar síndrome metabólica (ganho de peso, dislipidemia, hiperglicemia), e o lítio pode adicionar ganho de peso. Monitorizar peso, glicemia, perfil lipídico e EEP. Manter níveis de lítio na faixa terapêutica. Considerar metformina se síndrome metabólica se desenvolver.',
  explanation_en = 'The combination is used therapeutically in acute mania. Olanzapine may cause metabolic syndrome (weight gain, dyslipidaemia, hyperglycaemia), and lithium may add weight gain. Monitor weight, blood glucose, lipid profile, and EPS. Maintain lithium levels within therapeutic range. Consider metformin if metabolic syndrome develops.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('litio', 'olanzapina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('litio', 'olanzapina'))
  AND drug_a_id != drug_b_id;

-- 18. Warfarina × Fluoxetina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + anticoagulante: ISRS inibe recaptação de serotonina plaquetária, aumentando risco de hemorragia. Efeito aditivo com warfarina.',
  summary_pro_en = 'SSRI + anticoagulant: SSRI inhibits platelet serotonin reuptake, increasing bleeding risk. Additive effect with warfarin.',
  explanation_pt = 'Os ISRS inibem a recaptação de serotonina plaquetária, reduzindo a agregação plaquetária. Em combinação com warfarina (anticoagulante), o risco de hemorragia aumenta moderadamente (OR 1,5-2x). O mecanismo é aditivo (placa + coagulação). Monitorizar INR e sinais de hemorragia. A fluoxetina pode também inibir CYP2C9, aumentando ligeiramente os níveis de warfarina S-enantiómero. Manter dose baixa de warfarina se possível.',
  explanation_en = 'SSRIs inhibit platelet serotonin reuptake, reducing platelet aggregation. Combined with warfarin (anticoagulant), bleeding risk increases moderately (OR 1.5-2x). The mechanism is additive (platelet + coagulation). Monitor INR and signs of bleeding. Fluoxetine may also inhibit CYP2C9, slightly increasing S-warfarin levels. Maintain low warfarin dose if possible.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'fluoxetina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'fluoxetina'))
  AND drug_a_id != drug_b_id;

-- 19. Ritonavir × Sertralina (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor CYP + ISRS: ritonavir pode aumentar níveis de sertralina 1,5-2x. Risco de síndrome serotoninérgica.',
  summary_pro_en = 'CYP inhibitor + SSRI: ritonavir may increase sertraline levels 1.5-2-fold. Risk of serotonin syndrome.',
  explanation_pt = 'A sertralina é metabolizada por CYP2B6, CYP2C19, CYP2C9 e CYP3A4. O ritonavir inibe CYP3A4 e CYP2C19. A coadministração pode aumentar os níveis de sertralina em 1,5-2x. O risco de síndrome serotoninérgica é moderado. Monitorizar sinais serotoninérgicos. Reduzir dose de sertralina 50% se necessário. A sertralina é geralmente bem tolerada em doentes VIH, mas requer vigilância.',
  explanation_en = 'Sertraline is metabolised by CYP2B6, CYP2C19, CYP2C9, and CYP3A4. Ritonavir inhibits CYP3A4 and CYP2C19. Co-administration may increase sertraline levels 1.5-2-fold. The risk of serotonin syndrome is moderate. Monitor for serotonergic signs. Reduce sertraline dose by 50% if necessary. Sertraline is generally well tolerated in HIV patients, but requires vigilance.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'sertralina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'sertralina'))
  AND drug_a_id != drug_b_id;

-- 20. Fluoxetina × Metotrexato (MODERATE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'ISRS + antimetabolito: ISRS pode reduzir clearance renal do metotrexato. Risco de pancitopenia.',
  summary_pro_en = 'SSRI + antimetabolite: SSRI may reduce renal clearance of methotrexate. Risk of pancytopenia.',
  explanation_pt = 'Alguns ISRS podem reduzir a secreção tubular do metotrexato, aumentando os níveis. O efeito é menor que com AINE, mas clinicamente relevante em doses altas de metotrexato (>15 mg/semana). Monitorizar hemograma se tratamento concomitante. Em doses baixas de metotrexato (7,5-15 mg/semana para artrite reumatoide), o risco é menor.',
  explanation_en = 'Some SSRIs may reduce tubular secretion of methotrexate, increasing levels. The effect is less than with NSAIDs, but clinically relevant at high methotrexate doses (>15 mg/week). Monitor blood count if concomitant treatment. At low methotrexate doses (7.5-15 mg/week for rheumatoid arthritis), the risk is lower.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'metotrexato'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluoxetina', 'metotrexato'))
  AND drug_a_id != drug_b_id;
