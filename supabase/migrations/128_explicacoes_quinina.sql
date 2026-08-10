-- =====================================================================
-- 128 — Explicações fármaco-fármaco dos pares moderados da QUININA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 3 pares moderados da quinina que os tinham vazios
-- (cloroquina e fluconazol já cobertos nas 123 e 124; amiodarona,
-- claritromicina, ciprofloxacina, digoxina e warfarina já tinham
-- explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + EMA (EPAR Eurartesim) para a
-- diidroartemisinina-piperaquina.
-- Mecanismos centrais:
--   1. Quinina + arteméter-lumefantrina — QT aditivo ("Some antimalarials
--      (e.g. quinine, quinidine) including Coartem® have been associated
--      with prolongation of the QT interval"; "QT prolonging drugs,
--      including quinine... should be used cautiously following Coartem");
--   2. Quinina + diidroartemisinina-piperaquina — QT aditivo (a piperaquina
--      prolonga o QT; o EPAR Eurartesim contraindica a associação com
--      QT-prolongantes como quinina, cloroquina, amodiaquina);
--   3. Quinina + voriconazol — QT aditivo (o voriconazol prolonga o QT)
--      + inibição do CYP3A4 (a quinina é metabolizada pelo CYP3A4; o
--      rótulo da quinina: "CYP3A4 inhibitors... alteration in plasma
--      quinine concentration. Monitor").
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/3 — QUININA + ARTEMÉTER-LUMEFANTRINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Quinina + arteméter-lumefantrina: QT aditivo (ambos os antimaláricos prolongam o QT). Usar com precaução e vigiar ECG se associados.',
  summary_pro_en = 'Quinine + artemether-lumefantrine: additive QT (both antimalarials prolong the QT). Use cautiously and monitor the ECG if combined.',
  explanation_pt = 'Ambos os fármacos são antimaláricos que prolongam o intervalo QT: o rótulo do arteméter-lumefantrina refere que "alguns antimaláricos (ex.: quinina, quinidina), incluindo o arteméter-lumefantrina, foram associados a prolongamento do intervalo QT no ECG" e que "os fármacos que prolongam o QT, incluindo a quinina e a quinidina, devem ser usados com precaução após o arteméter-lumefantrina"; o rótulo da quinina documenta prolongamento consistente e dose-dependente do QT, com arritmias ventriculares potencialmente fatais, e recomenda evitar a associação com outros QT-prolongantes. Na prática, estas combinações de antimaláricos não se usam em conjunto (a quinina é alternativa ao arteméter-lumefantrina no tratamento da malária), mas podem sobrepor-se em doentes com falência terapêutica ou malária grave. Se a associação for necessária, monitorizar o ECG, os eletrólitos (corrigir hipocaliemia/hipomagnesemia) e os sinais de arritmia.',
  explanation_en = 'Both drugs are antimalarials that prolong the QT interval: the artemether-lumefantrine label states that "some antimalarials (e.g. quinine, quinidine), including artemether-lumefantrine, have been associated with prolongation of the QT interval on the ECG" and that "QT prolonging drugs, including quinine and quinidine, should be used cautiously following artemether-lumefantrine"; the quinine label documents consistent, dose-dependent QT prolongation with potentially fatal ventricular arrhythmias, and recommends avoiding other QT-prolonging drugs. In practice, these antimalarial combinations are not used together (quinine is an alternative to artemether-lumefantrine for malaria treatment), but they can overlap in patients with therapeutic failure or severe malaria. If the combination is needed, monitor the ECG, electrolytes (correct hypokalaemia/hypomagnesaemia) and signs of arrhythmia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'));

-- 2/3 — QUININA + DIIDROARTEMISININA-PIPERAQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Quinina + diidroartemisinina-piperaquina: QT aditivo (a piperaquina prolonga o QT). Evitar a associação; ECG se inevitável.',
  summary_pro_en = 'Quinine + dihydroartemisinin-piperaquine: additive QT (piperaquine prolongs the QT). Avoid the combination; ECG if unavoidable.',
  explanation_pt = 'A piperaquina (componente da diidroartemisinina-piperaquina, Eurartesim) prolonga o intervalo QT de forma dose-dependente e o EPAR da EMA contraindica a coadministração com outros fármacos que prolongam o QT, incluindo a quinina, a cloroquina e a amodiaquina; o rótulo da quinina documenta, por seu lado, prolongamento consistente e dose-dependente do QT com arritmias ventriculares potencialmente fatais (torsade de pointes, fibrilhação ventricular), recomendando evitar outros QT-prolongantes. A associação não é usada na prática antimalárica (a quinina é alternativa aos derivados da artemisinina), mas pode ocorrer sobreposição em doentes com falência terapêutica ou malária grave, sobretudo com hipocaliemia, hipomagnesemia, bradicardia ou doença cardíaca. Evitar; se inevitável, monitorizar o ECG e os eletrólitos antes e durante a terapêutica e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Piperaquine (the dihydroartemisinin-piperaquine component, Eurartesim) prolongs the QT interval in a dose-dependent way and the EMA EPAR contraindicates co-administration with other QT-prolonging drugs, including quinine, chloroquine and amodiaquine; the quinine label, in turn, documents consistent, dose-dependent QT prolongation with potentially fatal ventricular arrhythmias (torsade de pointes, ventricular fibrillation), recommending avoiding other QT-prolonging drugs. The combination is not used in antimalarial practice (quinine is an alternative to the artemisinin derivatives), but overlap can occur in patients with therapeutic failure or severe malaria, especially with hypokalaemia, hypomagnesaemia, bradycardia or cardiac disease. Avoid; if unavoidable, monitor the ECG and electrolytes before and during therapy and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'));

-- 3/3 — QUININA + VORICONAZOL (QT aditivo + inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Quinina + voriconazol: QT aditivo e níveis de quinina ↑ (inibição do CYP3A4). Evitar; se inevitável, ECG e monitorização.',
  summary_pro_en = 'Quinine + voriconazole: additive QT and increased quinine levels (CYP3A4 inhibition). Avoid; if unavoidable, ECG and monitoring.',
  explanation_pt = 'O voriconazol é um antifúngico azólico associado a prolongamento do QT (o rótulo refere que "alguns azóis, incluindo o voriconazol, foram associados a prolongamento do intervalo QT no ECG" e recomenda corrigir potássio, magnésio e cálcio antes do uso) e é um inibidor do CYP3A4; a quinina é metabolizada sobretudo pelo CYP3A4 e o seu rótulo alerta que "os inibidores do CYP3A4 alteram a concentração plasmática de quinina — monitorizar para falta de eficácia ou aumento dos efeitos adversos da quinina" (a classe está documentada: cetoconazol aumentou a AUC da quinina em 45%). A associação soma os dois riscos: QT aditivo (arritmias ventriculares potencialmente fatais) e níveis aumentados de quinina (cinconismo, cardiotoxicidade, hipoglicemia). Evitar sempre que possível; se inevitável, monitorizar o ECG, os eletrólitos e os sinais de toxicidade da quinina.',
  explanation_en = 'Voriconazole is an azole antifungal associated with QT prolongation (the label states that "some azoles, including voriconazole, have been associated with prolongation of the QT interval on the ECG" and recommends correcting potassium, magnesium and calcium before use) and is a CYP3A4 inhibitor; quinine is predominantly metabolised by CYP3A4 and its label warns that "CYP3A4 inhibitors alter plasma quinine concentration — monitor for lack of efficacy or increased adverse events of quinine" (the class is documented: ketoconazole increased quinine AUC by 45%). The combination adds up the two risks: additive QT (potentially fatal ventricular arrhythmias) and increased quinine levels (cinchonism, cardiotoxicity, hypoglycaemia). Avoid whenever possible; if unavoidable, monitor the ECG, electrolytes and signs of quinine toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
