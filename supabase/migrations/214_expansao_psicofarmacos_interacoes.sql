-- =====================================================================
-- 214 — Expansão Antipsicóticos/Antidepressivos: pares de interação + dimensões
--
-- Ordem canónica pré-verificada com UUIDs fixos
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
-- =====================================================================

-- =====================================================================
-- 1. Pares de interação (drug_interactions) — 16 colunas
-- =====================================================================
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, source_url, status)
SELECT a.id, b.id, v.severity, v.summary_pt, v.summary_en,
  v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
  v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
  v.source_pt, v.source_en, v.source_url, 'published'
FROM (VALUES
  -- ═══════════════════════════════════════════════════════════════
  -- CRITICAL PAIRS
  -- ═══════════════════════════════════════════════════════════════

  -- Fluoxetina × Risperidona (CYP2D6: fluoxetina inibe metabolismo de risperidona)
  ('fluoxetina', 'risperidona', 'critical',
   'ISRS inibidor CYP2D6 + antipsicótico: níveis de risperidona aumentados 2-4x. Risco de efeitos extrapiramidais.',
   'CYP2D6 inhibitor SSRI + antipsychotic: risperidone levels increased 2-4-fold. Risk of extrapyramidal effects.',
   'A fluoxetina é um potente inibidor de CYP2D6 (Ki ~0,2 μM), a principal via metabolizadora da risperidona. A coadministração pode aumentar os níveis de risperidona em 2-4x, aumentando o risco de efeitos extrapiramidais, parkinsonismo e síndrome neuroléptica maligna.',
   'Fluoxetine is a potent CYP2D6 inhibitor (Ki ~0.2 μM), the main metabolic pathway for risperidone. Co-administration may increase risperidone levels 2-4-fold, increasing the risk of extrapyramidal effects, parkinsonism, and neuroleptic malignant syndrome.',
   'Se possível, evitar. Se necessário, reduzir dose de risperidona 50% e monitorizar efeitos extrapiramidais.',
   'If possible, avoid. If necessary, reduce risperidone dose by 50% and monitor for extrapyramidal effects.',
   'Efeitos extrapiramidais, torquique, rigidez.',
   'Extrapyramidal effects, torticollis, rigidity.',
   'Síndrome neuroléptica maligna (hipertermia, rigidez, inconsciência).',
   'Neuroleptic malignant syndrome (hyperthermia, rigidity, unconsciousness).',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58b7504f-c4a3-ef1b-e063-6394a90ac0f3'
  ),

  -- Fluoxetina × Amitriptilina (CYP2D6: níveis de TCA aumentados)
  ('fluoxetina', 'amitriptilina', 'critical',
   'ISRS inibidor CYP2D6 + TCA: níveis de amitriptilina aumentados 2-4x. Risco de toxicidade cardiaca.',
   'CYP2D6 inhibitor SSRI + TCA: amitriptyline levels increased 2-4-fold. Risk of cardiac toxicity.',
   'A fluoxetina inibe o CYP2D6, a principal via metabolizadora da amitriptilina. Os níveis de TCA podem aumentar significativamente, com risco de prolongamento do QTc, arritmias e convulsões.',
   'Fluoxetine inhibits CYP2D6, the main metabolic pathway for amitriptyline. TCA levels may increase significantly, with risk of QTc prolongation, arrhythmias, and seizures.',
   'Evitar combinação se possível. Se necessário, reduzir dose de TCA 50% e monitorizar ECG e níveis de TCA.',
   'Avoid combination if possible. If necessary, reduce TCA dose by 50% and monitor ECG and TCA levels.',
   'ECG (QTc), níveis de TCA, sinais de toxicidade (boca seca, retenção urinária, confusão).',
   'ECG (QTc), TCA levels, signs of toxicity (dry mouth, urinary retention, confusion).',
   'QTc >500 ms, arritmias, convulsões.',
   'QTc >500 ms, arrhythmias, seizures.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abf6a3f5-0df9-4b23-995d-63b973ef80c1'
  ),

  -- Carbamazepina × Ritonavir (CYP3A4: ritonavir inibe carbamazepina — efeito paradoxal)
  ('ritonavir', 'carbamazepina', 'critical',
   'Indutor CYP3A4 + inibidor potente: níveis de carbamazepina podem aumentar ou diminuir. Risco de toxicidade ou perda de eficácia.',
   'CYP3A4 inducer + potent inhibitor: carbamazepine levels may increase or decrease. Risk of toxicity or loss of efficacy.',
   'A carbamazepina é um indutor de CYP3A4, mas o ritonavir é um inibidor potente. O resultado é imprevisível — os níveis de carbamazepina podem aumentar (toxicidade) ou diminuir (perda de eficácia). Monitorização estreita obrigatória.',
   'Carbamazepine is a CYP3A4 inducer, but ritonavir is a potent inhibitor. The result is unpredictable — carbamazepine levels may increase (toxicity) or decrease (loss of efficacy). Close monitoring mandatory.',
   'Evitar combinação. Se inevitável, monitorizar níveis de carbamazepina semanalmente e sinais de toxicidade.',
   'Avoid combination. If unavoidable, monitor carbamazepine levels weekly and signs of toxicity.',
   'Níveis de carbamazepina, sinais de toxicidade (tontura, ataxia, diplopia).',
   'Carbamazepine levels, signs of toxicity (dizziness, ataxia, diplopia).',
   'Toxicidade grave (convulsões, arritmias, depressão medular).',
   'Severe toxicity (seizures, arrhythmias, bone marrow suppression).',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fbdfffb2-5024-4bf7-8eb0-493288a7b22a'
  ),

  -- Fluoxetina × Ritonavir (CYP2D6/3A4: níveis de fluoxetina aumentados)
  ('ritonavir', 'fluoxetina', 'critical',
   'ISRS + inibidor CYP3A4: níveis de fluoxetina aumentados. Risco de síndrome serotoninérgica.',
   'SSRI + CYP3A4 inhibitor: fluoxetine levels increased. Risk of serotonin syndrome.',
   'O ritonavir inibe CYP3A4 e CYP2D6, as vias metabolizadoras da fluoxetina. Os níveis podem aumentar significativamente, com risco de síndrome serotoninérgica.',
   'Ritonavir inhibits CYP3A4 and CYP2D6, the metabolic pathways for fluoxetine. Levels may increase significantly, with risk of serotonin syndrome.',
   'Evitar combinação. Se necessário, reduzir dose de fluoxetina 50% e monitorizar sinais serotoninérgicos.',
   'Avoid combination. If necessary, reduce fluoxetine dose by 50% and monitor for serotonergic signs.',
   'Sinais serotoninérgicos (mioclónias, hiperreflexia, hipertermia, agitação).',
   'Serotonergic signs (myoclonus, hyperreflexia, hyperthermia, agitation).',
   'Síndrome serotoninérgica grave (hipertermia >41°C, convulsões, rabdomiólise).',
   'Severe serotonin syndrome (hyperthermia >41°C, seizures, rhabdomyolysis).',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5feb6aa4-6ceb-401b-9b70-c53bcda3b766'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- MODERATE PAIRS
  -- ═══════════════════════════════════════════════════════════════

  -- Fluoxetina × Metformina (fluoxetina pode potenciar hipoglicemia)
  ('fluoxetina', 'metformina', 'moderate',
   'ISRS + biguanida: ISRS pode potenciar efeito hipoglicemiante.',
   'SSRI + biguanide: SSRI may potentiate hypoglycaemic effect.',
   'A fluoxetina pode melhorar a sensibilidade à insulina e potenciar o efeito hipoglicemiante da metformina. Risco de hipoglicemia, especialmente em idosos.',
   'Fluoxetine may improve insulin sensitivity and potentiate the hypoglycaemic effect of metformin. Risk of hypoglycaemia, especially in the elderly.',
   'Monitorizar glicemia nas primeiras semanas. Ajustar dose de metformina se necessário.',
   'Monitor blood glucose during the first weeks. Adjust metformin dose if necessary.',
   'Glicemia, sinais de hipoglicemia (tremor, sudorese, confusão).',
   'Blood glucose, signs of hypoglycaemia (tremor, sweating, confusion).',
   'Hipoglicemia grave.',
   'Severe hypoglycaemia.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5feb6aa4-6ceb-401b-9b70-c53bcda3b766'
  ),

  -- Fluoxetina × Cimetidina (cimetidina inibe CYP2D6 — efeito aditivo)
  ('fluoxetina', 'cimetidina', 'moderate',
   'ISRS + inibidor CYP: cimetidina pode aumentar níveis de fluoxetina.',
   'SSRI + CYP inhibitor: cimetidine may increase fluoxetine levels.',
   'A cimetidina inibe moderadamente CYP2D6 e CYP3A4. O efeito sobre os níveis de fluoxetina é modesto mas clinicamente relevante em idosos.',
   'Cimetidine moderately inhibits CYP2D6 and CYP3A4. The effect on fluoxetine levels is modest but clinically relevant in the elderly.',
   'Monitorizar sinais de síndrome serotoninérgica. Considerar alternativa (ranitidina não inibe CYP).',
   'Monitor for serotonergic syndrome signs. Consider alternative (ranitidine does not inhibit CYP).',
   'Sinais serotoninérgicos.',
   'Serotonergic signs.',
   'Síndrome serotoninérgica.',
   'Serotonin syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5feb6aa4-6ceb-401b-9b70-c53bcda3b766'
  ),

  -- Escitalopram × Ritonavir (CYP2C19/3A4)
  ('ritonavir', 'escitalopram', 'moderate',
   'ISRS selectivo + inibidor CYP: níveis de escitalopram podem aumentar.',
   'Selective SSRI + CYP inhibitor: escitalopram levels may increase.',
   'O escitalopram é metabolizado por CYP2C19 e CYP3A4. O ritonavir inibe estas vias, aumentando os níveis de escitalopram.',
   'Escitalopram is metabolised by CYP2C19 and CYP3A4. Ritonavir inhibits these pathways, increasing escitalopram levels.',
   'Monitorizar sinais serotoninérgicos. Considerar reduzir dose 25-50%.',
   'Monitor for serotonergic signs. Consider reducing dose by 25-50%.',
   'Sinais serotoninérgicos.',
   'Serotonergic signs.',
   'Síndrome serotoninérgica.',
   'Serotonin syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2db02476-325f-ee47-a7e5-b5aed56c364c'
  ),

  -- Diazepam × Fluoxetina (CYP3A4: fluoxetina pode inibir metabolismo)
  ('fluoxetina', 'diazepam', 'moderate',
   'ISRS + benzodiazepina: efeito aditivo sedativo e risco de queda.',
   'SSRI + benzodiazepine: additive sedative effect and fall risk.',
   'Efeito aditivo sobre o SNC — sedação, comprometimento cognitivo, risco de quedas (especialmente idosos). A fluoxetina pode inibir o metabolismo do diazepam via CYP3A4.',
   'Additive CNS effect — sedation, cognitive impairment, fall risk (especially elderly). Fluoxetine may inhibit diazepam metabolism via CYP3A4.',
   'Iniciar com dose baixa de benzodiazepina. Reavaliar necessidade de combinação.',
   'Start with low benzodiazepine dose. Re-evaluate need for combination.',
   'Sedação, coordenação, queda.',
   'Sedation, coordination, falls.',
   'Quedas com fracturas em idosos.',
   'Falls with fractures in the elderly.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=260e2041-2bb3-482f-850e-b5d47a7bdbe6'
  ),

  -- Venlafaxina × Ritonavir (CYP3A4)
  ('ritonavir', 'venlafaxina', 'moderate',
   'IRSN + inibidor CYP3A4: níveis de venlafaxina podem aumentar.',
   'SNRI + CYP3A4 inhibitor: venlafaxine levels may increase.',
   'O ritonavir inibe CYP3A4, uma das vias metabolizadoras da venlafaxina. O efeito é moderado mas relevante.',
   'Ritonavir inhibits CYP3A4, one of the metabolic pathways for venlafaxine. The effect is moderate but relevant.',
   'Monitorizar sinais serotoninérgicos e hipertensão.',
   'Monitor for serotonergic signs and hypertension.',
   'PA, sinais serotoninérgicos.',
   'BP, serotonergic signs.',
   'Crise hipertensiva, síndrome serotoninérgica.',
   'Hypertensive crisis, serotonin syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3e51f786-3691-4ec4-836b-7f2c9a385aa7'
  ),

  -- Duloxetina × Fluconazol (CYP1A2/2D6)
  ('fluconazol', 'duloxetina', 'moderate',
   'IRSN + inibidor CYP: fluconazol pode aumentar níveis de duloxetina.',
   'SNRI + CYP inhibitor: fluconazole may increase duloxetine levels.',
   'O fluconazol inibe CYP2D6 e CYP3A4, vias metabolizadoras da duloxetina. Efeito clinicamente moderado.',
   'Fluconazole inhibits CYP2D6 and CYP3A4, metabolic pathways for duloxetine. Clinically moderate effect.',
   'Monitorizar sinais serotoninérgicos.',
   'Monitor for serotonergic signs.',
   'Sinais serotoninérgicos.',
   'Serotonergic signs.',
   'Síndrome serotoninérgica.',
   'Serotonin syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=461d769c-b787-4bc7-b4a6-7a5f33ae9d45'
  ),

  -- Olanzapina × Fluconazol (CYP1A2)
  ('fluconazol', 'olanzapina', 'moderate',
   'Inibidor CYP + antipsicótico: fluconazol pode aumentar níveis de olanzapina.',
   'CYP inhibitor + antipsychotic: fluconazole may increase olanzapine levels.',
   'O fluconazol inibe CYP3A4, uma das vias metabolizadoras da olanzapina. O efeito é moderado.',
   'Fluconazole inhibits CYP3A4, one of the metabolic pathways for olanzapine. The effect is moderate.',
   'Monitorizar sedação e efeitos extrapiramidais.',
   'Monitor for sedation and extrapyramidal effects.',
   'Sedação, EEP, sinais de síndrome metabólica.',
   'Sedation, EPS, metabolic syndrome signs.',
   'Sedação excessiva, EEP graves.',
   'Excessive sedation, severe EPS.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=709d79a1-2742-4629-af43-161be166833a'
  ),

  -- Carbamazepina × Fluoxetina (carbamazepina pode reduzir níveis de ISRS)
  ('fluoxetina', 'carbamazepina', 'moderate',
   'ISRS + indutor CYP3A4: carbamazepina pode reduzir níveis de fluoxetina.',
   'SSRI + CYP3A4 inducer: carbamazepine may reduce fluoxetine levels.',
   'A carbamazepina é um potente indutor de CYP3A4 e pode reduzir os níveis de fluoxetina em 20-30%. A eficácia antidepressiva pode ser comprometida.',
   'Carbamazepine is a potent CYP3A4 inducer and may reduce fluoxetine levels by 20-30%. Antidepressant efficacy may be compromised.',
   'Monitorizar eficácia antidepressiva. Considerar dose mais elevada de fluoxetina.',
   'Monitor antidepressant efficacy. Consider higher fluoxetine dose.',
   'Eficácia antidepressiva, sinais de depressão.',
   'Antidepressant efficacy, signs of depression.',
   'Recaída depressiva.',
   'Depressive relapse.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fbdfffb2-5024-4bf7-8eb0-493288a7b22a'
  ),

  -- Carbamazepina × Valproato (farmacocinética complexa)
  ('valproato', 'carbamazepina', 'moderate',
   'Anticonvulsivante + anticonvulsivante: interações farmacocinéticas mútuas.',
   'Anticonvulsant + anticonvulsant: mutual pharmacokinetic interactions.',
   'A carbamazepina pode aumentar o metabolismo do valproato (indução de glucuronidação). O valproato pode inibir o metabolismo do epóxido de carbamazepina. Monitorização estreita.',
   'Carbamazepine may increase valproate metabolism (glucuronidation induction). Valproate may inhibit carbamazepine epoxide metabolism. Close monitoring.',
   'Monitorizar níveis de ambos os fármacos. Ajustar doses conforme necessário.',
   'Monitor levels of both drugs. Adjust doses as needed.',
   'Níveis de carbamazepina e valproato, sinais de toxicidade.',
   'Carbamazepine and valproate levels, signs of toxicity.',
   'Toxicidade de ambos os fármacos.',
   'Toxicity of both drugs.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=fbdfffb2-5024-4bf7-8eb0-493288a7b22a'
  ),

  -- Mirtazapina × Fluoxetina (efeito aditivo serotoninérgico)
  ('fluoxetina', 'mirtazapina', 'moderate',
   'ISRS + NaSSA: efeito aditivo serotoninérgico. Combinado terapeuticamente para depressão resistente.',
   'SSRI + NaSSA: additive serotonergic effect. Combined therapeutically for treatment-resistant depression.',
   'A combinação é usada terapeuticamente ("dual reuptake inhibition") para depressão resistente. O risco de síndrome serotoninérgica existe mas é baixo com doses terapêuticas.',
   'The combination is used therapeutically ("dual reuptake inhibition") for treatment-resistant depression. The risk of serotonin syndrome exists but is low at therapeutic doses.',
   'Iniciar com doses baixas. Monitorizar sinais serotoninérgicos.',
   'Start with low doses. Monitor for serotonergic signs.',
   'Sinais serotoninérgicos.',
   'Serotonergic signs.',
   'Síndrome serotoninérgica (rara).',
   'Serotonin syndrome (rare).',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=89ae6a33-933f-47aa-a2de-2a71cd3f7d44'
  ),

  -- Diazepam × Ritonavir (CYP3A4)
  ('ritonavir', 'diazepam', 'moderate',
   'Benzodiazepina + inibidor CYP3A4: níveis de diazepam aumentados. Sedação prolongada.',
   'Benzodiazepine + CYP3A4 inhibitor: diazepam levels increased. Prolonged sedation.',
   'O ritonavir inibe CYP3A4, a principal via metabolizadora do diazepam. Os níveis podem aumentar significativamente, prolongando a sedação.',
   'Ritonavir inhibits CYP3A4, the main metabolic pathway for diazepam. Levels may increase significantly, prolonging sedation.',
   'Reduzir dose de diazepam 50%. Monitorizar sedação e função respiratória.',
   'Reduce diazepam dose by 50%. Monitor sedation and respiratory function.',
   'Sedação, frequência respiratória.',
   'Sedation, respiratory rate.',
   'Depressão respiratória.',
   'Respiratory depression.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=260e2041-2bb3-482f-850e-b5d47a7bdbe6'
  ),

  -- Risperidona × Litio (efeito aditivo — ambos causam EEP)
  ('litio', 'risperidona', 'moderate',
   'Estabilizador de humor + antipsicótico: risco aumentado de EEP e neurotoxicidade.',
   'Mood stabiliser + antipsychotic: increased risk of EPS and neurotoxicity.',
   'A combinação pode aumentar o risco de efeitos extrapiramidais e neurotoxicidade. Monitorizar sinais de síndrome neuroléptica maligna.',
   'The combination may increase the risk of extrapyramidal effects and neurotoxicity. Monitor for signs of neuroleptic malignant syndrome.',
   'Monitorizar EEP e sinais de neurotoxicidade (confusão, tremor, febre).',
   'Monitor for EPS and neurotoxicity signs (confusion, tremor, fever).',
   'EEP, sinais de neurotoxicidade.',
   'EPS, neurotoxicity signs.',
   'Síndrome neuroléptica maligna.',
   'Neuroleptic malignant syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58b7504f-c4a3-ef1b-e063-6394a90ac0f3'
  ),

  -- Olanzapina × Litio (efeito aditivo)
  ('litio', 'olanzapina', 'moderate',
   'Estabilizador de humor + antipsicótico: efeito aditivo sobre sintomas maníacos.',
   'Mood stabiliser + antipsychotic: additive effect on manic symptoms.',
   'A combinação é usada terapeuticamente na mania aguda. Risco aumentado de síndrome metabólica e EEP.',
   'The combination is used therapeutically in acute mania. Increased risk of metabolic syndrome and EPS.',
   'Monitorizar peso, glicemia, perfil lipídico e EEP.',
   'Monitor weight, blood glucose, lipid profile and EPS.',
   'Síndrome metabólica, EEP.',
   'Metabolic syndrome, EPS.',
   'Síndrome metabólica grave.',
   'Severe metabolic syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=709d79a1-2742-4629-af43-161be166833a'
  ),

  -- Fluoxetina × Warfarina (CYP2C9: pode potenciar anticoagulação)
  ('warfarina', 'fluoxetina', 'moderate',
   'ISRS + anticoagulante: ISRS pode potenciar efeito anticoagulante (inibição plaquetária).',
   'SSRI + anticoagulant: SSRI may potentiate anticoagulant effect (platelet inhibition).',
   'Os ISRS inibem a recaptação de serotonina plaquetária, reduzindo a agregação. Em combinação com warfarina, o risco de hemorragia aumenta moderadamente.',
   'SSRIs inhibit platelet serotonin reuptake, reducing aggregation. Combined with warfarin, bleeding risk increases moderately.',
   'Monitorizar INR e sinais de hemorragia.',
   'Monitor INR and signs of bleeding.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia significativa.',
   'Significant bleeding.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5feb6aa4-6ceb-401b-9b70-c53bcda3b766'
  ),

  -- Sertralina × Ritonavir (CYP2C19/3A4)
  ('ritonavir', 'sertralina', 'moderate',
   'Inibidor CYP + ISRS: ritonavir pode aumentar níveis de sertralina.',
   'CYP inhibitor + SSRI: ritonavir may increase sertraline levels.',
   'O ritonavir inibe CYP3A4 e CYP2C19, vias metabolizadoras da sertralina. Efeito moderado.',
   'Ritonavir inhibits CYP3A4 and CYP2C19, metabolic pathways for sertraline. Moderate effect.',
   'Monitorizar sinais serotoninérgicos.',
   'Monitor for serotonergic signs.',
   'Sinais serotoninérgicos.',
   'Serotonergic signs.',
   'Síndrome serotoninérgica.',
   'Serotonin syndrome.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d429bab3-2073-4f37-976a-b0911c39c4ab'
  ),

  -- Fluoxetina × Metotrexato (fluoxetina pode reduzir clearance)
  ('fluoxetina', 'metotrexato', 'moderate',
   'ISRS + antimetabolito: ISRS pode reduzir clearance renal do metotrexato.',
   'SSRI + antimetabolite: SSRI may reduce renal clearance of methotrexate.',
   'Alguns ISRS podem reduzir a secreção tubular do metotrexato. O efeito é menor que com AINE.',
   'Some SSRIs may reduce tubular secretion of methotrexate. The effect is less than with NSAIDs.',
   'Monitorizar hemograma se tratamento concomitante.',
   'Monitor blood count if concomitant treatment.',
   'Hemograma.',
   'Blood count.',
   'Pancitopenia.',
   'Pancytopenia.',
   'DailyMed/FDA', 'DailyMed/FDA',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5feb6aa4-6ceb-401b-9b70-c53bcda3b766'
  )
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
