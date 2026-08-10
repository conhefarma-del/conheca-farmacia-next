-- =====================================================================
-- 103 — Explicações fármaco-fármaco dos pares moderados da AMIODARONA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 18 pares moderados da amiodarona que os tinham vazios —
-- quarto lote dos pares moderados sem explicação (319 → 275 → 253 → 235).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK, OMS/WHO).
-- Mecanismos centrais: amiodarona é inibidora do CYP3A4/CYP2C9/CYP2D6 e
-- da glicoproteína-P, prolonga o intervalo QT e tem semivida muito longa.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/18 — ADRENALINA + AMIODARONA (arritmias ventriculares)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Adrenalina + amiodarona: risco aumentado de arritmias ventriculares e taquicardia (a amiodarona prolonga o QT e a adrenalina aumenta a automaticidade). Usar com precaução e vigiar ECG.',
  summary_pro_en = 'Epinephrine + amiodarone: increased risk of ventricular arrhythmias and tachycardia (amiodarone prolongs QT and epinephrine increases automaticity). Use with caution and monitor ECG.',
  explanation_pt = 'A amiodarona prolonga o intervalo QT e a repolarização ventricular, e a adrenalina, ao estimular os recetores beta e alfa, aumenta a automaticidade e o consumo de oxigénio do miocárdio. Em conjunto, o risco de taquicardias ventriculares e de extrassistolia aumenta, sobretudo em contexto de emergência (paragem cardiorrespiratória, anafilaxia) ou de cardiopatia isquémica. A hipocaliemia favorece ainda mais as arritmias. Recomenda-se monitorizar o ECG, corrigir eletrólitos (potássio e magnésio) e usar as menores doses eficazes de adrenalina.',
  explanation_en = 'Amiodarone prolongs the QT interval and ventricular repolarisation, and epinephrine, by stimulating beta and alpha receptors, increases automaticity and myocardial oxygen demand. Together they raise the risk of ventricular tachycardias and extrasystoles, especially in emergencies (cardiac arrest, anaphylaxis) or ischaemic heart disease. Hypokalaemia further favours arrhythmias. Monitor the ECG, correct electrolytes (potassium and magnesium) and use the lowest effective epinephrine doses.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'amiodarona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'amiodarona'));

-- 2/18 — AMIODARONA + ARTEMÉTER+LUMEFANTRINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Arteméter+lumefantrina + amiodarona: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação ou vigiar ECG de forma apertada.',
  summary_pro_en = 'Artemether+lumefantrine + amiodarone: additive QT prolongation with risk of torsades de pointes. Avoid the combination or monitor the ECG closely.',
  explanation_pt = 'A amiodarona e o lumefantrina prolongam ambos o intervalo QT através de bloqueio de canais de potássio (IKr). O efeito aditivo aumenta o risco de torsades de pointes e de morte súbita, sobretudo em doentes com QT basal prolongado, hipocaliemia, bradicardia ou cardiopatia estrutural. Sempre que possível, preferir um antimalárico sem efeito no QT (ex.: atovaquona+proguanil). Se a associação for inevitável, vigiar ECG e eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Both amiodarone and lumefantrine prolong the QT interval by blocking potassium channels (IKr). The additive effect increases the risk of torsades de pointes and sudden death, especially in patients with a prolonged baseline QT, hypokalaemia, bradycardia or structural heart disease. Whenever possible, prefer an antimalarial without QT effects (e.g. atovaquone+proguanil). If the combination is unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'));

-- 3/18 — AMIODARONA + ARTESUNATO+AMODIAQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Artesunato+amodiaquina + amiodarona: prolongamento aditivo do QT (amodiaquina). Evitar ou vigiar ECG se inevitável.',
  summary_pro_en = 'Artesunate+amodiaquine + amiodarone: additive QT prolongation (amodiaquine). Avoid, or monitor ECG if unavoidable.',
  explanation_pt = 'A amodiaquina bloqueia o canal IKr e prolonga o intervalo QT; associada à amiodarona (que também prolonga o QT e inibe o CYP3A4, podendo elevar os níveis da amodiaquina), o risco de arritmias ventriculares, incluindo torsades de pointes, aumenta de forma aditiva. Em doentes em terapêutica crónica com amiodarona, preferir um antimalárico sem efeito no QT. Se a associação for inevitável, vigiar ECG e eletrólitos e corrigir hipocaliemia.',
  explanation_en = 'Amodiaquine blocks the IKr channel and prolongs the QT interval; combined with amiodarone (which also prolongs QT and inhibits CYP3A4, potentially raising amodiaquine levels), the risk of ventricular arrhythmias, including torsades de pointes, increases additively. In patients on chronic amiodarone, prefer an antimalarial without QT effects. If the combination is unavoidable, monitor the ECG and electrolytes and correct hypokalaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'));

-- 4/18 — AMIODARONA + BEDAQUILINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Bedaquilina + amiodarona: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação; se inevitável, vigiar ECG semanalmente.',
  summary_pro_en = 'Bedaquiline + amiodarone: additive QT prolongation with risk of torsades de pointes. Avoid the combination; if unavoidable, monitor the ECG weekly.',
  explanation_pt = 'A bedaquilina prolonga o intervalo QT (bloqueio do hERG) e a amiodarona prolonga-o também; o efeito é aditivo e o risco de torsades de pointes aumenta, sobretudo com hipocaliemia, hipomagnesemia ou em doentes com cardiopatia. A amiodarona inibe ainda o CYP3A4, via pela qual a bedaquilina é metabolizada, podendo elevar os seus níveis e agravar o prolongamento do QT. Recomenda-se evitar a associação em doentes com tuberculose multirresistente sempre que exista alternativa; se inevitável, vigiar ECG (idealmente semanal) e eletrólitos.',
  explanation_en = 'Bedaquiline prolongs the QT interval (hERG blockade) and amiodarone prolongs it too; the effect is additive and the risk of torsades de pointes increases, especially with hypokalaemia, hypomagnesaemia or heart disease. Amiodarone also inhibits CYP3A4, the pathway by which bedaquiline is metabolised, potentially raising its levels and worsening QT prolongation. Avoid the combination in multidrug-resistant tuberculosis whenever an alternative exists; if unavoidable, monitor the ECG (ideally weekly) and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'bedaquilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'bedaquilina'));

-- 5/18 — AMIODARONA + CETOCONAZOL (inibição CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + amiodarona: o cetoconazol inibe o CYP3A4 e pode elevar os níveis de amiodarona, aumentando o risco de QT/arritmias. Evitar a associação.',
  summary_pro_en = 'Ketoconazole + amiodarone: ketoconazole inhibits CYP3A4 and may raise amiodarone levels, increasing the QT/arrhythmia risk. Avoid the combination.',
  explanation_pt = 'A amiodarona é metabolizada pelo CYP3A4 e pela CYP2C8; o cetoconazol é um inibidor potente do CYP3A4 e reduz a clearance da amiodarona, podendo duplicar as suas concentrações. Como ambos também prolongam o intervalo QT, o risco de torsades de pointes e de toxicidade (pulmonar, hepática, tiroideia, neuropatia) aumenta. Deve evitar-se a associação; se for inevitável, reduzir a dose de amiodarona, vigiar ECG e níveis plasmáticos (se disponíveis) e monitorizar efeitos adversos.',
  explanation_en = 'Amiodarone is metabolised by CYP3A4 and CYP2C8; ketoconazole is a potent CYP3A4 inhibitor and reduces amiodarone clearance, potentially doubling its concentrations. Since both also prolong the QT interval, the risk of torsades de pointes and of toxicity (pulmonary, hepatic, thyroid, neuropathy) increases. The combination should be avoided; if unavoidable, reduce the amiodarone dose, monitor the ECG and plasma levels (if available) and watch for adverse effects.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 6/18 — AMIODARONA + CLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + amiodarona: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação ou vigiar ECG.',
  summary_pro_en = 'Chloroquine + amiodarone: additive QT prolongation with risk of torsades de pointes. Avoid the combination or monitor the ECG.',
  explanation_pt = 'A cloroquina bloqueia os canais de potássio e sódio cardíacos e prolonga o intervalo QT; com a amiodarona, o efeito é aditivo e o risco de arritmias ventriculares aumenta, sobretudo com hipocaliemia, bradicardia ou cardiopatia. Em doentes crónicos com amiodarona (ex.: FA), preferir outro antimalárico para o tratamento da malária aguda. Se a associação for inevitável, vigiar ECG e eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Chloroquine blocks cardiac potassium and sodium channels and prolongs the QT interval; with amiodarone the effect is additive and the risk of ventricular arrhythmias increases, especially with hypokalaemia, bradycardia or heart disease. In patients on chronic amiodarone (e.g. AF), prefer another antimalarial for acute malaria. If the combination is unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'));

-- 7/18 — AMIODARONA + DIIDROARTEMISININA+PIPERAQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diidroartemisinina+piperaquina + amiodarona: prolongamento aditivo do QT (piperaquina). Evitar a associação ou vigiar ECG.',
  summary_pro_en = 'Dihydroartemisinin+piperaquine + amiodarone: additive QT prolongation (piperaquine). Avoid the combination or monitor the ECG.',
  explanation_pt = 'A piperaquina prolonga de forma marcada o intervalo QT (bloqueio do hERG) e tem sido associada a torsades de pointes, sobretudo em combinação com outros fármacos que prolongam o QT como a amiodarona. O risco é maior com QT basal prolongado, hipocaliemia, hipomagnesemia ou cardiopatia. Em doentes em amiodarona crónica, preferir um antimalárico sem efeito no QT. Se a associação for inevitável, vigiar ECG e eletrólitos e evitar outros fatores de risco.',
  explanation_en = 'Piperaquine markedly prolongs the QT interval (hERG blockade) and has been associated with torsades de pointes, especially in combination with other QT-prolonging drugs such as amiodarone. The risk is higher with a prolonged baseline QT, hypokalaemia, hypomagnesaemia or heart disease. In patients on chronic amiodarone, prefer an antimalarial without QT effects. If the combination is unavoidable, monitor the ECG and electrolytes and avoid other risk factors.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'));

-- 8/18 — AMIODARONA + FENITOÍNA (interação bidirecional CYP)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fenitoína + amiodarona: a fenitoína reduz os níveis de amiodarona (indução do CYP3A4) e a amiodarona eleva os níveis de fenitoína (inibição do CYP2C9). Vigiar ambos.',
  summary_pro_en = 'Phenytoin + amiodarone: phenytoin lowers amiodarone levels (CYP3A4 induction) and amiodarone raises phenytoin levels (CYP2C9 inhibition). Monitor both.',
  explanation_pt = 'A interação é bidirecional: a fenitoína induz o CYP3A4 e reduz as concentrações de amiodarona (e do seu metabolito ativo), podendo diminuir o efeito antiarrítmico; por outro lado, a amiodarona inibe a CYP2C9 e a epóxido-hidrolase, podendo duplicar os níveis de fenitoína e causar toxicidade (nistagmo, ataxia, letargia). As alterações surgem ao longo de semanas devido à semivida muito longa da amiodarona. Recomenda-se vigiar os níveis plasmáticos de fenitoína, ajustar a dose e monitorizar a eficácia da amiodarona.',
  explanation_en = 'The interaction is bidirectional: phenytoin induces CYP3A4 and lowers amiodarone (and active metabolite) concentrations, potentially reducing the antiarrhythmic effect; conversely, amiodarone inhibits CYP2C9 and epoxide hydrolase, potentially doubling phenytoin levels and causing toxicity (nystagmus, ataxia, lethargy). Changes develop over weeks because of the very long amiodarone half-life. Monitor phenytoin plasma levels, adjust the dose and watch for amiodarone efficacy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- 9/18 — AMIODARONA + FLECAINIDA (inibição CYP2D6 + efeito aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Flecainida + amiodarona: a amiodarona inibe o CYP2D6 e pode duplicar os níveis de flecainida (risco de proarritmia). Reduzir a dose de flecainida em 50% e vigiar ECG.',
  summary_pro_en = 'Flecainide + amiodarone: amiodarone inhibits CYP2D6 and may double flecainide levels (proarrhythmia risk). Reduce the flecainide dose by 50% and monitor the ECG.',
  explanation_pt = 'A flecainida é metabolizada pela CYP2D6; a amiodarona inibe esta enzima e também a CYP2C9 e a glicoproteína-P, podendo aumentar as concentrações de flecainida em 50–100%. Como ambos os fármacos deprimem a condução (alargam o QRS) e a amiodarona prolonga o QT, o risco de proarritmia (taquicardia ventricular, bloqueios) aumenta. Quando a associação é necessária (ex.: FA), recomenda-se reduzir a dose de flecainida para metade, monitorizar ECG (QRS, QT) e os níveis plasmáticos de flecainida se disponíveis.',
  explanation_en = 'Flecainide is metabolised by CYP2D6; amiodarone inhibits this enzyme and also CYP2C9 and P-glycoprotein, potentially increasing flecainide concentrations by 50–100%. As both drugs depress conduction (widen QRS) and amiodarone prolongs QT, the proarrhythmia risk (ventricular tachycardia, blocks) increases. When the combination is needed (e.g. AF), reduce the flecainide dose by half, monitor the ECG (QRS, QT) and flecainide plasma levels if available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'flecainida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'flecainida'));

-- 10/18 — AMIODARONA + HIDROXICLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroxicloroquina + amiodarona: prolongamento aditivo do QT com risco de arritmias ventriculares. Evitar ou vigiar ECG.',
  summary_pro_en = 'Hydroxychloroquine + amiodarone: additive QT prolongation with risk of ventricular arrhythmias. Avoid or monitor the ECG.',
  explanation_pt = 'A hidroxicloroquina bloqueia os canais de potássio (hERG) e prolonga o intervalo QT; associada à amiodarona, o efeito é aditivo e o risco de torsades de pointes aumenta, sobretudo com hipocaliemia, bradicardia, insuficiência renal ou cardiopatia. Em doentes em amiodarona crónica (ex.: FA) que necessitem de hidroxicloroquina (lúpus, artrite reumatoide, malária), recomenda-se preferir alternativa ou vigiar ECG antes e durante o tratamento, corrigindo eletrólitos.',
  explanation_en = 'Hydroxychloroquine blocks potassium channels (hERG) and prolongs the QT interval; with amiodarone the effect is additive and the risk of torsades de pointes increases, especially with hypokalaemia, bradycardia, renal impairment or heart disease. In patients on chronic amiodarone (e.g. AF) who need hydroxychloroquine (lupus, rheumatoid arthritis, malaria), prefer an alternative or monitor the ECG before and during treatment, correcting electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'));

-- 11/18 — AMIODARONA + ITRACONAZOL (inibição CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol + amiodarona: o itraconazol inibe o CYP3A4 e pode elevar os níveis de amiodarona, com risco de QT/arritmias. Evitar a associação.',
  summary_pro_en = 'Itraconazole + amiodarone: itraconazole inhibits CYP3A4 and may raise amiodarone levels, with QT/arrhythmia risk. Avoid the combination.',
  explanation_pt = 'O itraconazol é um inibidor potente do CYP3A4, a principal via de metabolização da amiodarona; a sua coadministração pode aumentar substancialmente as concentrações de amiodarona. Como ambos prolongam o intervalo QT, o risco de torsades de pointes e de toxicidade da amiodarona (pulmonar, hepática, tiroideia) aumenta. Deve evitar-se a associação; se for inevitável, reduzir a dose de amiodarona, vigiar ECG e monitorizar efeitos adversos durante o tratamento antifúngico e após a sua suspensão.',
  explanation_en = 'Itraconazole is a potent CYP3A4 inhibitor, the main pathway of amiodarone metabolism; coadministration can substantially raise amiodarone concentrations. As both prolong the QT interval, the risk of torsades de pointes and of amiodarone toxicity (pulmonary, hepatic, thyroid) increases. The combination should be avoided; if unavoidable, reduce the amiodarone dose, monitor the ECG and watch for adverse effects during antifungal treatment and after its discontinuation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 12/18 — AMIODARONA + LEVOFLOXACINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levofloxacina + amiodarona: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação ou vigiar ECG.',
  summary_pro_en = 'Levofloxacin + amiodarone: additive QT prolongation with risk of torsades de pointes. Avoid the combination or monitor the ECG.',
  explanation_pt = 'A levofloxacina prolonga o intervalo QT (bloqueio do hERG) e a amiodarona também; o efeito é aditivo e o risco de torsades de pointes aumenta, sobretudo em mulheres, idosos, com hipocaliemia, bradicardia ou cardiopatia. Em doentes em amiodarona crónica, preferir um antibiótico sem efeito no QT (ex.: beta-lactâmicos) quando a cobertura for adequada. Se a associação for inevitável, vigiar ECG e eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Levofloxacin prolongs the QT interval (hERG blockade) and amiodarone does too; the effect is additive and the torsades de pointes risk increases, especially in women, the elderly, and with hypokalaemia, bradycardia or heart disease. In patients on chronic amiodarone, prefer an antibiotic without QT effects (e.g. beta-lactams) when coverage is adequate. If the combination is unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'));

-- 13/18 — AMIODARONA + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Mefloquina + amiodarona: prolongamento aditivo do QT com risco de arritmias ventriculares. Evitar a associação.',
  summary_pro_en = 'Mefloquine + amiodarone: additive QT prolongation with risk of ventricular arrhythmias. Avoid the combination.',
  explanation_pt = 'A mefloquina prolonga o intervalo QT e associa-se a arritmias ventriculares e bloqueios de condução; com a amiodarona o efeito é aditivo. Além disso, ambos têm efeitos sobre a condução AV. Em doentes em amiodarona crónica que necessitem de profilaxia ou tratamento da malária, preferir atovaquona+proguanil ou doxiciclina. Se a associação for inevitável, vigiar ECG e eletrólitos e monitorizar sinais de proarritmia.',
  explanation_en = 'Mefloquine prolongs the QT interval and is associated with ventricular arrhythmias and conduction blocks; with amiodarone the effect is additive. Both also affect AV conduction. In patients on chronic amiodarone needing malaria prophylaxis or treatment, prefer atovaquone+proguanil or doxycycline. If the combination is unavoidable, monitor the ECG and electrolytes and watch for proarrhythmia signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 14/18 — AMIODARONA + PSEUDOEFEDRINA (simpaticomimético + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Pseudoefedrina + amiodarona: o efeito simpaticomimético da pseudoefedrina aumenta o risco de arritmias em doentes com amiodarona. Evitar ou usar com precaução.',
  summary_pro_en = 'Pseudoephedrine + amiodarone: the sympathomimetic effect of pseudoephedrine increases the arrhythmia risk in patients on amiodarone. Avoid or use with caution.',
  explanation_pt = 'A pseudoefedrina é um simpaticomimético que aumenta a frequência cardíaca e a automaticidade; em doentes tratados com amiodarona (que prolonga o QT e está associada a cardiopatia subjacente frequente), o risco de taquicardias e extrassistolia ventricular aumenta. Deve evitar-se a pseudoefedrina em doentes com arritmias conhecidas ou cardiopatia isquémica; se for usada, limitar a duração, vigiar sintomas (palpitações, dor torácica) e preferir alternativas não simpaticomiméticas (ex.: corticosteroides nasais, anti-histamínicos) para a congestão nasal.',
  explanation_en = 'Pseudoephedrine is a sympathomimetic that increases heart rate and automaticity; in patients treated with amiodarone (which prolongs QT and is frequently associated with underlying heart disease), the risk of tachycardias and ventricular extrasystoles increases. Pseudoephedrine should be avoided in patients with known arrhythmias or ischaemic heart disease; if used, limit the duration, watch for symptoms (palpitations, chest pain) and prefer non-sympathomimetic alternatives (e.g. nasal corticosteroids, antihistamines) for nasal congestion.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'));

-- 15/18 — AMIODARONA + QUININA (QT aditivo + CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Quinina + amiodarona: prolongamento aditivo do QT e inibição do CYP3A4 pela quinina (níveis de amiodarona ↑). Evitar a associação.',
  summary_pro_en = 'Quinine + amiodarone: additive QT prolongation and CYP3A4 inhibition by quinine (amiodarone levels ↑). Avoid the combination.',
  explanation_pt = 'A quinina prolonga o intervalo QT e inibe o CYP3A4, a principal via de metabolização da amiodarona, podendo elevar os seus níveis; o efeito no QT é aditivo e o risco de torsades de pointes aumenta de forma marcada. Em doentes em amiodarona crónica, preferir outro antimalárico (atovaquona+proguanil, doxiciclina). Se a associação for inevitável, vigiar ECG e eletrólitos e reduzir a dose de amiodarona se necessário.',
  explanation_en = 'Quinine prolongs the QT interval and inhibits CYP3A4, the main pathway of amiodarone metabolism, potentially raising its levels; the QT effect is additive and the torsades de pointes risk increases markedly. In patients on chronic amiodarone, prefer another antimalarial (atovaquone+proguanil, doxycycline). If the combination is unavoidable, monitor the ECG and electrolytes and reduce the amiodarone dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'quinina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'quinina'));

-- 16/18 — AMIODARONA + RIFABUTINA (indução CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rifabutina + amiodarona: a rifabutina induz o CYP3A4 e reduz os níveis de amiodarona, podendo diminuir a eficácia antiarrítmica. Vigiar o efeito clínico.',
  summary_pro_en = 'Rifabutin + amiodarone: rifabutin induces CYP3A4 and lowers amiodarone levels, potentially reducing antiarrhythmic efficacy. Monitor the clinical effect.',
  explanation_pt = 'A rifabutina é um indutor do CYP3A4 e reduz as concentrações plasmáticas da amiodarona (e do seu metabolito ativo), podendo comprometer o controlo da arritmia. A interação desenvolve-se ao longo de dias a semanas e persiste após a suspensão da rifabutina (semivida longa da amiodarona). Recomenda-se monitorizar o ritmo e a resposta clínica, considerar o ajuste da dose de amiodarona e vigiar o ECG durante e após o tratamento com rifabutina.',
  explanation_en = 'Rifabutin induces CYP3A4 and lowers amiodarone plasma concentrations (and its active metabolite), potentially compromising arrhythmia control. The interaction develops over days to weeks and persists after rifabutin discontinuation (long amiodarone half-life). Monitor the rhythm and clinical response, consider adjusting the amiodarone dose and monitor the ECG during and after rifabutin treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'));

-- 17/18 — AMIODARONA + RIFAMPICINA (indução CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rifampicina + amiodarona: a rifampicina induz fortemente o CYP3A4 e pode reduzir os níveis de amiodarona para níveis subterapêuticos. Evitar ou vigiar de perto.',
  summary_pro_en = 'Rifampicin + amiodarone: rifampicin strongly induces CYP3A4 and can reduce amiodarone levels to subtherapeutic. Avoid or monitor closely.',
  explanation_pt = 'A rifampicina é um indutor potente do CYP3A4 e da glicoproteína-P e pode reduzir as concentrações de amiodarona (e do seu metabolito ativo) em mais de 50%, com perda do controlo antiarrítmico. O efeito persiste semanas após a suspensão da rifampicina dada a semivida muito longa da amiodarona (até 60 dias). Recomenda-se evitar a associação quando possível; se inevitável, monitorizar o ritmo, considerar o ajuste (frequentemente aumento) da dose de amiodarona e vigiar o ECG.',
  explanation_en = 'Rifampicin is a potent inducer of CYP3A4 and P-glycoprotein and can reduce amiodarone (and active metabolite) concentrations by more than 50%, with loss of antiarrhythmic control. The effect persists for weeks after rifampicin discontinuation given the very long amiodarone half-life (up to 60 days). Avoid the combination when possible; if unavoidable, monitor the rhythm, consider adjusting (often increasing) the amiodarone dose and monitor the ECG.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 18/18 — AMIODARONA + VORICONAZOL (inibição CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Voriconazol + amiodarona: o voriconazol inibe o CYP3A4 e pode elevar os níveis de amiodarona; ambos prolongam o QT. Evitar a associação.',
  summary_pro_en = 'Voriconazole + amiodarone: voriconazole inhibits CYP3A4 and may raise amiodarone levels; both prolong the QT. Avoid the combination.',
  explanation_pt = 'O voriconazol é um inibidor moderado a potente do CYP3A4 e reduz a clearance da amiodarona, podendo aumentar as suas concentrações; ambos os fármacos prolongam o intervalo QT, pelo que o risco de torsades de pointes aumenta de forma aditiva. Deve evitar-se a associação em doentes com FA ou outras arritmias; se for inevitável (aspergilose invasiva em doente com amiodarona), reduzir a dose de amiodarona, vigiar ECG e eletrólitos e monitorizar efeitos adversos durante e após o tratamento antifúngico.',
  explanation_en = 'Voriconazole is a moderate-to-potent CYP3A4 inhibitor and reduces amiodarone clearance, potentially raising its concentrations; both drugs prolong the QT interval, so the torsades de pointes risk increases additively. The combination should be avoided in patients with AF or other arrhythmias; if unavoidable (invasive aspergillosis in a patient on amiodarone), reduce the amiodarone dose, monitor the ECG and electrolytes and watch for adverse effects during and after antifungal treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
