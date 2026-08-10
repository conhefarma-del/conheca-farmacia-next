-- =====================================================================
-- 124 — Explicações fármaco-fármaco dos pares moderados do FLUCONAZOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 3 pares moderados do fluconazol que os tinham vazios
-- (cloroquina e prednisolona já cobertos nas 123 e 119; atorvastatina,
-- carbamazepina, gliclazida, glimepirida, rifampicina e warfarina já
-- tinham explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA).
-- Mecanismos centrais:
--   1. Fluconazol + glibenclamida — inibição do CYP2C9: AUC da glibenclamida
--      +44% (estudo em 20 voluntários; 5 precisaram de glucose oral), com
--      monitorização da glicemia e ajuste da dose da sulfonilureia;
--   2. Fluconazol + quinina — QT aditivo + inibição do CYP3A4 (a quinina é
--      metabolizada sobretudo pelo CYP3A4; o rótulo da quinina contraindica
--      QT-prolongantes e alerta para os inibidores do CYP3A4, que elevam a
--      quinina — ex.: cetoconazol, AUC +45%);
--   3. Fluconazol + mefloquina — QT aditivo (o rótulo da mefloquina
--      contraindica a associação com fármacos que prolongam o QTc; o do
--      fluconazol associa QT/torsade de pointes).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/3 — FLUCONAZOL + GLIBENCLAMIDA (CYP2C9 — hipoglicemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + glibenclamida: o fluconazol inibe o CYP2C9 e aumenta os níveis da glibenclamida (AUC +44%), com risco de hipoglicemia. Monitorizar glicemia e ajustar a dose da sulfonilureia.',
  summary_pro_en = 'Fluconazole + glyburide: fluconazole inhibits CYP2C9 and raises glyburide levels (AUC +44%), with a risk of hypoglycaemia. Monitor glycaemia and adjust the sulfonylurea dose.',
  explanation_pt = 'O fluconazol é um inibidor do CYP2C9 e do CYP3A4, enzimas que metabolizam a glibenclamida (sulfonilureia); no estudo farmacocinético do rótulo do fluconazol com 20 voluntários, a AUC e a Cmax da glibenclamida (5 mg em dose única) aumentaram significativamente após a administração de fluconazol — AUC +44% ± 29% e Cmax +19% ± 19% — e 5 dos 20 voluntários precisaram de glucose oral após a toma de glibenclamida aos 7 dias de fluconazol. Nos três estudos com sulfonilureias (tolbutamida, glipizida, glibenclamida), 47,8% dos doentes tratados com fluconazol tiveram sintomas compatíveis com hipoglicemia. O rótulo recomenda monitorizar cuidadosamente a glicemia e ajustar a dose da sulfonilureia conforme necessário. Na prática, avisar o doente para os sinais de hipoglicemia (sudorese, tremor, palpitações, confusão) e considerar reduzir a dose da glibenclamida ou preferir uma sulfonilureia menos dependente do CYP2C9 enquanto durar o antifúngico.',
  explanation_en = 'Fluconazole inhibits CYP2C9 and CYP3A4, the enzymes that metabolise glyburide (a sulfonylurea); in the pharmacokinetic study of the fluconazole label with 20 volunteers, glyburide (5 mg single dose) AUC and Cmax increased significantly after fluconazole administration — AUC +44% ± 29% and Cmax +19% ± 19% — and 5 of the 20 volunteers required oral glucose after glyburide ingestion at 7 days of fluconazole. Across the three sulfonylurea studies (tolbutamide, glipizide, glyburide), 47.8% of fluconazole-treated patients experienced symptoms consistent with hypoglycaemia. The label recommends carefully monitoring blood glucose and adjusting the sulfonylurea dose as necessary. In practice, warn the patient about hypoglycaemia signs (sweating, tremor, palpitations, confusion) and consider reducing the glyburide dose or preferring a sulfonylurea less dependent on CYP2C9 for the duration of the antifungal.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'glibenclamida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'glibenclamida'));

-- 2/3 — FLUCONAZOL + QUININA (QT aditivo + inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + quinina: QT aditivo e níveis de quinina ↑ (inibição do CYP3A4). Evitar; se inevitável, ECG e monitorização.',
  summary_pro_en = 'Fluconazole + quinine: additive QT and increased quinine levels (CYP3A4 inhibition). Avoid; if unavoidable, ECG and monitoring.',
  explanation_pt = 'A quinina prolonga o intervalo QT de forma consistente e dose-dependente, com risco de arritmias ventriculares potencialmente fatais (torsade de pointes, fibrilhação ventricular), e o rótulo contraindica o uso em doentes com QT prolongado e recomenda evitar a associação com outros fármacos que prolonguem o QT. A quinina é metabolizada sobretudo pelo CYP3A4, e os inibidores desta enzima elevam as suas concentrações — o rótulo documenta cetoconazol a aumentar a AUC da quinina em 45% e associa a inibição do CYP3A4 a um caso fatal de torsade de pointes (eritromicina+quinina). O fluconazol combina os dois riscos: prolonga o QT (torsade de pointes na experiência pós-comercialização) e inibe o CYP3A4, potenciando a toxicidade da quinina (cinconismo, cardiotoxicidade, hipoglicemia). Sempre que possível, evitar a associação; se inevitável, monitorizar o ECG, os eletrólitos (corrigir hipocaliemia/hipomagnesemia) e os sinais de toxicidade da quinina.',
  explanation_en = 'Quinine prolongs the QT interval consistently and in a dose-dependent way, with a risk of potentially fatal ventricular arrhythmias (torsade de pointes, ventricular fibrillation), and the label contraindicates its use in patients with QT prolongation and recommends avoiding other QT-prolonging drugs. Quinine is predominantly metabolised by CYP3A4, and inhibitors of this enzyme raise its concentrations — the label documents ketoconazole increasing quinine AUC by 45% and links CYP3A4 inhibition to a fatal torsade de pointes case (erythromycin+quinine). Fluconazole combines both risks: it prolongs the QT (torsade de pointes in post-marketing experience) and inhibits CYP3A4, potentiating quinine toxicity (cinchonism, cardiotoxicity, hypoglycaemia). Whenever possible, avoid the combination; if unavoidable, monitor the ECG, electrolytes (correct hypokalaemia/hypomagnesaemia) and signs of quinine toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'quinina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'quinina'));

-- 3/3 — FLUCONAZOL + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + mefloquina: risco aditivo de prolongamento do QT. Evitar a associação; monitorizar ECG se inevitável.',
  summary_pro_en = 'Fluconazole + mefloquine: additive risk of QT prolongation. Avoid the combination; monitor the ECG if unavoidable.',
  explanation_pt = 'A mefloquina pode prolongar o intervalo QTc, sobretudo quando associada a outros fármacos que alteram a condução cardíaca ou prolongam o QT — o rótulo contraindica explicitamente a halofantrina e o cetoconazol (risco de QT prolongation potencialmente fatal) e desaconselha a quinina/quinidina; o guia do doente recomenda não tomar com fármacos que prolongam o QT. O fluconazol também prolonga o QT (torsade de pointes na experiência pós-comercialização) e, como inibidor do CYP3A4, pode ainda elevar os níveis da mefloquina. A associação deve ser evitada (na prática, a profilaxia antimalárica e o tratamento antifúngico não costumam sobrepor-se, mas podem ocorrer em doentes com infeções fúngicas invasivas); se inevitável, monitorizar o ECG, os eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Mefloquine can prolong the QTc interval, especially when combined with other drugs that alter cardiac conduction or prolong the QT — the label explicitly contraindicates halofantrine and ketoconazole (risk of potentially fatal QT prolongation) and advises against quinine/quinidine; the patient guide recommends not taking it with QT-prolonging drugs. Fluconazole also prolongs the QT (torsade de pointes in post-marketing experience) and, as a CYP3A4 inhibitor, may also raise mefloquine levels. The combination should be avoided (in practice, antimalarial prophylaxis and antifungal treatment rarely overlap, but they can occur in patients with invasive fungal infections); if unavoidable, monitor the ECG, electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'mefloquina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'mefloquina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'));
