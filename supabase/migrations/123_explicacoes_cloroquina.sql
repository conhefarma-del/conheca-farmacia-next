-- =====================================================================
-- 123 — Explicações fármaco-fármaco dos pares moderados da CLOROQUINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 5 pares moderados da cloroquina que os tinham vazios
-- (amiodarona, claritromicina, antiácidos, ciprofloxacina, omeprazol,
-- warfarina e digoxina já tinham explicação nas 103/105/108/112/113/
-- 097/100).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismo central: QT aditivo — a cloroquina prolonga o QT (torsade de
-- pointes reportada) e o rótulo alerta para o risco com outros
-- QT-prolongantes: mefloquina, quinina, hidroxicloroquina, fluconazol
-- e moxifloxacina.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/5 — CLOROQUINA + FLUCONAZOL (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + fluconazol: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Chloroquine + fluconazole: additive risk of QT prolongation. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'A cloroquina prolonga o intervalo QT (torsade de pointes e arritmias ventriculares reportadas, com risco maior em doses elevadas e com QT-prolongantes concomitantes — o rótulo da cloroquina alerta explicitamente para esse risco), e o fluconazol pode também prolongar o QT (o rótulo contraindica a associação de fluconazol com fármacos QT-prolongantes metabolizados pelo CYP3A4). A associação soma o risco de arritmias ventriculares, sobretudo em doentes com QT longo, hipocaliemia, hipomagnesemia, bradicardia ou doença cardíaca. Sempre que possível, evitar ou escolher um antifúngico alternativo; se inevitável, monitorizar o ECG e os eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Chloroquine prolongs the QT interval (torsade de pointes and ventricular arrhythmias reported, with a higher risk at high doses and with concomitant QT-prolonging drugs — the chloroquine label explicitly warns about this risk), and fluconazole can also prolong the QT (the label contraindicates fluconazole with QT-prolonging CYP3A4-metabolised drugs). The combination adds up the risk of ventricular arrhythmias, especially in patients with long QT, hypokalaemia, hypomagnesaemia, bradycardia or cardiac disease. Whenever possible, avoid or choose an alternative antifungal; if unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'));

-- 2/5 — CLOROQUINA + HIDROXICLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + hidroxicloroquina: QT aditivo e cardiotoxicidade cumulativa. Evitar a associação (fármacos da mesma classe).',
  summary_pro_en = 'Chloroquine + hydroxychloroquine: additive QT and cumulative cardiotoxicity. Avoid the combination (same class).',
  explanation_pt = 'A cloroquina e a hidroxicloroquina são antimaláricos da mesma classe (4-aminoquinolinas), ambos associados a prolongamento do QT, arritmias ventriculares e, com uso prolongado, cardiomiopatia (o rótulo da hidroxicloroquina descreve cardiomiopatia e arritmias ventriculares fatais ou potencialmente fatais; o da cloroquina, prolongamento do QT, torsade de pointes e risco maior com outros QT-prolongantes). A associação não traz benefício adicional e soma o risco cardíaco e de retinopatia. Evitar; se por algum motivo forem coadministrados (não recomendado), monitorizar ECG, eletrólitos e sinais de cardiotoxicidade.',
  explanation_en = 'Chloroquine and hydroxychloroquine are antimalarials of the same class (4-aminoquinolines), both associated with QT prolongation, ventricular arrhythmias and, with prolonged use, cardiomyopathy (the hydroxychloroquine label describes fatal or potentially fatal cardiomyopathy and ventricular arrhythmias; the chloroquine label, QT prolongation, torsade de pointes and a higher risk with other QT-prolonging drugs). The combination adds no benefit and adds cardiac and retinopathy risk. Avoid; if for any reason they are co-administered (not recommended), monitor the ECG, electrolytes and signs of cardiotoxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'));

-- 3/5 — CLOROQUINA + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + mefloquina: risco aditivo de prolongamento do QT. Evitar a associação; monitorizar ECG se inevitável.',
  summary_pro_en = 'Chloroquine + mefloquine: additive risk of QT prolongation. Avoid the combination; monitor the ECG if unavoidable.',
  explanation_pt = 'Tanto a cloroquina como a mefloquina prolongam o intervalo QT e podem causar arritmias ventriculares; o rótulo da cloroquina alerta para o risco aumentado durante a administração concomitante com QT-prolongantes, e o rótulo da mefloquina tem uma secção dedicada ao prolongamento do QTc e às interações (desaconselhando, por exemplo, a halofantrina e o cetoconazol pelo risco de prolongamento potencialmente fatal). A associação cloroquina+mefloquina deve ser evitada (não são usadas em conjunto na prática antimalárica); se inevitável, monitorizar o ECG e os eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Both chloroquine and mefloquine prolong the QT interval and can cause ventricular arrhythmias; the chloroquine label warns about the increased risk during concomitant administration with QT-prolonging drugs, and the mefloquine label has a dedicated section on QTc prolongation and interactions (advising against, for example, halofantrine and ketoconazole because of the risk of potentially fatal prolongation). The chloroquine+mefloquine combination should be avoided (they are not used together in antimalarial practice); if unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 4/5 — CLOROQUINA + MOXIFLOXACINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + moxifloxacina: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Chloroquine + moxifloxacin: additive risk of QT prolongation. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'A cloroquina prolonga o intervalo QT (torsade de pointes e arritmias ventriculares reportadas, com risco maior com QT-prolongantes concomitantes — rótulo da cloroquina), e a moxifloxacina também prolonga o QT, com casos de torsade de pointes; o rótulo da moxifloxacina recomenda evitar o uso em doentes com prolongamento conhecido, condições pró-arrítmicas (bradicardia clinicamente significativa, isquemia miocárdica aguda), hipocaliemia, hipomagnesemia e com fármacos que prolonguem o QT. A associação deve ser evitada sempre que possível; se inevitável, monitorizar o ECG e os eletrólitos e usar a menor duração de antibiótico possível.',
  explanation_en = 'Chloroquine prolongs the QT interval (torsade de pointes and ventricular arrhythmias reported, with a higher risk with concomitant QT-prolonging drugs — chloroquine label), and moxifloxacin also prolongs the QT, with cases of torsade de pointes; the moxifloxacin label recommends avoiding use in patients with known prolongation, proarrhythmic conditions (clinically significant bradycardia, acute myocardial ischaemia), hypokalaemia, hypomagnesaemia and with drugs that prolong the QT. The combination should be avoided whenever possible; if unavoidable, monitor the ECG and electrolytes and use the shortest antibiotic course possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'));

-- 5/5 — CLOROQUINA + QUININA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + quinina: risco aditivo de prolongamento do QT. Evitar a associação; monitorizar ECG se inevitável.',
  summary_pro_en = 'Chloroquine + quinine: additive risk of QT prolongation. Avoid the combination; monitor the ECG if unavoidable.',
  explanation_pt = 'Tanto a cloroquina como a quinina prolongam o intervalo QT e podem causar torsade de pointes e arritmias ventriculares; o rótulo da quinina contraindica o uso em doentes com prolongamento do QT e descreve um caso fatal de arritmia ventricular em doente com QT prolongado, e o rótulo da cloroquina alerta para o risco aumentado com QT-prolongantes concomitantes. A associação cloroquina+quinina deve ser evitada (são alternativas antimaláricas, não complementares); se inevitável, monitorizar o ECG e os eletrólitos, corrigir hipocaliemia/hipomagnesemia e vigiar sinais de cardiotoxicidade.',
  explanation_en = 'Both chloroquine and quinine prolong the QT interval and can cause torsade de pointes and ventricular arrhythmias; the quinine label contraindicates its use in patients with QT prolongation and describes a fatal ventricular arrhythmia case in a patient with prolonged QT, and the chloroquine label warns about the increased risk with concomitant QT-prolonging drugs. The chloroquine+quinine combination should be avoided (they are antimalarial alternatives, not complementary); if unavoidable, monitor the ECG and electrolytes, correct hypokalaemia/hypomagnesaemia and watch for signs of cardiotoxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'));
