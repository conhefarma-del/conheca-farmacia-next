-- =====================================================================
-- 105 — Explicações fármaco-fármaco dos pares moderados da CLARITROMICINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 16 pares moderados da claritromicina que os tinham vazios —
-- sexto lote dos pares moderados sem explicação (319 → 218 → 202).
-- Padrão da 089/100/103/104: UPDATE com LEAST/GREATEST canónico +
-- updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK, OMS/WHO).
-- Mecanismos centrais: a claritromicina é inibidora do CYP3A4 e da
-- glicoproteína-P e prolonga o intervalo QT.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/16 — ALPRAZOLAM + CLARITROMICINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Alprazolam + claritromicina: a claritromicina inibe o CYP3A4 e pode duplicar os níveis de alprazolam, com sedação e depressão respiratória. Vigiar e reduzir a dose de alprazolam.',
  summary_pro_en = 'Alprazolam + clarithromycin: clarithromycin inhibits CYP3A4 and may double alprazolam levels, with sedation and respiratory depression. Monitor and reduce the alprazolam dose.',
  explanation_pt = 'O alprazolam é metabolizado pelo CYP3A4; a claritromicina, inibidora potente desta enzima, pode aumentar as suas concentrações e potenciar a sedação, a ataxia e o risco de depressão respiratória, sobretudo em idosos e em doentes com doença respiratória ou hepática. Recomenda-se reduzir a dose de alprazolam (até 50%) durante a associação, evitar em doentes com apneia do sono ou DPOC grave e vigiar sedação; preferir um antibiótico sem interação (ex.: azitromicina, que tem menor efeito) quando possível.',
  explanation_en = 'Alprazolam is metabolised by CYP3A4; clarithromycin, a potent inhibitor of this enzyme, can raise its concentrations and potentiate sedation, ataxia and the risk of respiratory depression, especially in the elderly and in patients with respiratory or liver disease. Reduce the alprazolam dose (up to 50%) during the combination, avoid it in patients with sleep apnoea or severe COPD and monitor sedation; prefer a non-interacting antibiotic (e.g. azithromycin, which has less effect) when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 2/16 — ARTEMÉTER+LUMEFANTRINA + CLARITROMICINA (inibição do CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Arteméter+lumefantrina + claritromicina: a claritromicina eleva os níveis de lumefantrina (inibição do CYP3A4) e ambos prolongam o QT. Vigiar ECG ou preferir outro antibiótico.',
  summary_pro_en = 'Artemether+lumefantrine + clarithromycin: clarithromycin raises lumefantrine levels (CYP3A4 inhibition) and both prolong the QT. Monitor ECG or prefer another antibiotic.',
  explanation_pt = 'A claritromicina inibe o CYP3A4, via que metaboliza o arteméter e o lumefantrina, podendo aumentar as concentrações do antimalárico; ambos os fármacos prolongam o intervalo QT, pelo que o risco de torsades de pointes aumenta de forma aditiva. Em doentes a tratar malária com arteméter+lumefantrina, preferir um antibiótico sem efeito no QT (ex.: beta-lactâmicos) se houver infeção bacteriana concomitante; se a associação for inevitável, vigiar ECG e eletrólitos.',
  explanation_en = 'Clarithromycin inhibits CYP3A4, the pathway that metabolises artemether and lumefantrine, potentially raising antimalarial concentrations; both drugs prolong the QT interval, so the torsades de pointes risk increases additively. In patients treated for malaria with artemether+lumefantrine, prefer an antibiotic without QT effects (e.g. beta-lactams) if a bacterial infection coexists; if the combination is unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 3/16 — ARTESUNATO+AMODIAQUINA + CLARITROMICINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Artesunato+amodiaquina + claritromicina: a claritromicina eleva os níveis de amodiaquina (inibição do CYP3A4) e ambas prolongam o QT. Evitar se possível.',
  summary_pro_en = 'Artesunate+amodiaquine + clarithromycin: clarithromycin raises amodiaquine levels (CYP3A4 inhibition) and both prolong the QT. Avoid if possible.',
  explanation_pt = 'A amodiaquina é metabolizada em parte pelo CYP3A4; a claritromicina inibe esta enzima e pode aumentar as suas concentrações, elevando o risco de hepatotoxicidade e de prolongamento do QT (ambos os fármacos prolongam o intervalo QT). Preferir um antibiótico alternativo durante o tratamento antimalárico com artesunato+amodiaquina e, se a associação for inevitável, vigiar ECG, transaminases e eletrólitos.',
  explanation_en = 'Amodiaquine is partly metabolised by CYP3A4; clarithromycin inhibits this enzyme and can raise its concentrations, increasing the risk of hepatotoxicity and QT prolongation (both drugs prolong the QT interval). Prefer an alternative antibiotic during artesunate+amodiaquine antimalarial treatment and, if the combination is unavoidable, monitor the ECG, transaminases and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 4/16 — ATORVASTATINA + CLARITROMICINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + claritromicina: a claritromicina inibe o CYP3A4 e pode aumentar marcadamente os níveis de atorvastatina, com risco de miopatia/rabdomiólise. Suspender a estatina durante o antibiótico.',
  summary_pro_en = 'Atorvastatin + clarithromycin: clarithromycin inhibits CYP3A4 and can markedly raise atorvastatin levels, with risk of myopathy/rhabdomyolysis. Hold the statin during the antibiotic.',
  explanation_pt = 'A atorvastatina é metabolizada pelo CYP3A4; a claritromicina, inibidora potente, pode aumentar as suas concentrações várias vezes, com risco de miopatia, rabdomiólise e insuficiência renal. Recomenda-se suspender a atorvastatina durante o ciclo de claritromicina (e alguns dias após) ou substituir por uma estatina menos dependente do CYP3A4 (ex.: pravastatina); vigiar mialgias, fraqueza e CPK em doentes que mantenham a associação.',
  explanation_en = 'Atorvastatin is metabolised by CYP3A4; clarithromycin, a potent inhibitor, can raise its concentrations several-fold, with risk of myopathy, rhabdomyolysis and renal failure. Hold atorvastatin during the clarithromycin course (and a few days after) or switch to a statin less dependent on CYP3A4 (e.g. pravastatin); monitor myalgia, weakness and CPK in patients who keep the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 5/16 — BEDAQUILINA + CLARITROMICINA (inibição do CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Bedaquilina + claritromicina: a claritromicina eleva os níveis de bedaquilina (inibição do CYP3A4) e ambas prolongam o QT. Evitar a associação.',
  summary_pro_en = 'Bedaquiline + clarithromycin: clarithromycin raises bedaquiline levels (CYP3A4 inhibition) and both prolong the QT. Avoid the combination.',
  explanation_pt = 'A bedaquilina é metabolizada pelo CYP3A4 e a claritromicina inibe esta enzima, podendo aumentar substancialmente as suas concentrações; ambos os fármacos prolongam o intervalo QT, com risco aditivo de torsades de pointes. Em esquemas de tuberculose multirresistente com bedaquilina, evitar macrólidos; se um macrólido for necessário, preferir a azitromicina (menor interação) e vigiar ECG e eletrólitos.',
  explanation_en = 'Bedaquiline is metabolised by CYP3A4 and clarithromycin inhibits this enzyme, potentially raising its concentrations substantially; both drugs prolong the QT interval, with an additive torsades de pointes risk. In multidrug-resistant tuberculosis regimens containing bedaquiline, avoid macrolides; if a macrolide is needed, prefer azithromycin (less interaction) and monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 6/16 — BUDESONIDA + CLARITROMICINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Budesonida + claritromicina: a claritromicina aumenta a exposição sistémica à budesonida (inibição do CYP3A4), com risco de efeitos corticoides. Vigiar sinais de excesso de corticoide.',
  summary_pro_en = 'Budesonide + clarithromycin: clarithromycin increases systemic budesonide exposure (CYP3A4 inhibition), with risk of corticosteroid effects. Monitor for corticosteroid excess signs.',
  explanation_pt = 'A budesonida (inalada ou oral) é metabolizada no fígado pelo CYP3A4; a claritromicina, inibidora potente, pode aumentar a sua exposição sistémica e potenciar os efeitos corticoides (síndrome de Cushing, hiperglicemia, supressão suprarrenal, osteoporose), sobretudo com uso prolongado e doses elevadas de corticoide inalado. Recomenda-se vigiar sinais de excesso corticosteroide, considerar reduzir a dose de budesonida e preferir outro antibiótico quando possível.',
  explanation_en = 'Budesonide (inhaled or oral) is metabolised in the liver by CYP3A4; clarithromycin, a potent inhibitor, can increase its systemic exposure and potentiate corticosteroid effects (Cushing''s syndrome, hyperglycaemia, adrenal suppression, osteoporosis), especially with prolonged use and high inhaled doses. Monitor for corticosteroid excess signs, consider reducing the budesonide dose and prefer another antibiotic when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'budesonida'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'budesonida'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 7/16 — CLARITROMICINA + CLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cloroquina + claritromicina: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação ou vigiar ECG.',
  summary_pro_en = 'Chloroquine + clarithromycin: additive QT prolongation with risk of torsades de pointes. Avoid the combination or monitor the ECG.',
  explanation_pt = 'A cloroquina e a claritromicina prolongam ambas o intervalo QT (bloqueio do hERG); o efeito é aditivo e o risco de torsades de pointes aumenta, sobretudo com hipocaliemia, bradicardia, insuficiência renal ou cardiopatia. Em doentes a receber cloroquina (malária, lúpus), preferir um antibiótico sem efeito no QT; se a associação for inevitável, vigiar ECG e eletrólitos e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Both chloroquine and clarithromycin prolong the QT interval (hERG blockade); the effect is additive and the torsades de pointes risk increases, especially with hypokalaemia, bradycardia, renal impairment or heart disease. In patients receiving chloroquine (malaria, lupus), prefer an antibiotic without QT effects; if the combination is unavoidable, monitor the ECG and electrolytes and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'));

-- 8/16 — CLARITROMICINA + DEXAMETASONA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + claritromicina: a claritromicina eleva os níveis de dexametasona (inibição do CYP3A4), potenciando os efeitos do corticosteroide. Vigiar efeitos corticoides.',
  summary_pro_en = 'Dexamethasone + clarithromycin: clarithromycin raises dexamethasone levels (CYP3A4 inhibition), potentiating corticosteroid effects. Monitor corticosteroid effects.',
  explanation_pt = 'A dexametasona é metabolizada pelo CYP3A4; a claritromicina inibe esta enzima e pode aumentar as suas concentrações, potenciando os efeitos anti-inflamatórios, a hiperglicemia e o risco de supressão suprarrenal em tratamentos prolongados. Em doentes com corticoterapia e infeção tratada com claritromicina, vigiar glicemia e sinais de excesso de corticoide e considerar reduzir a dose de dexametasona durante a associação.',
  explanation_en = 'Dexamethasone is metabolised by CYP3A4; clarithromycin inhibits this enzyme and can raise its concentrations, potentiating anti-inflammatory effects, hyperglycaemia and the risk of adrenal suppression in prolonged courses. In patients on corticosteroid therapy and a clarithromycin-treated infection, monitor blood glucose and corticosteroid excess signs and consider reducing the dexamethasone dose during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'));

-- 9/16 — CLARITROMICINA + DIIDROARTEMISININA+PIPERAQUINA (inibição do CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diidroartemisinina+piperaquina + claritromicina: a claritromicina eleva os níveis de piperaquina e ambas prolongam o QT. Evitar a associação.',
  summary_pro_en = 'Dihydroartemisinin+piperaquine + clarithromycin: clarithromycin raises piperaquine levels and both prolong the QT. Avoid the combination.',
  explanation_pt = 'A piperaquina é metabolizada em parte pelo CYP3A4; a claritromicina inibe esta enzima e pode aumentar as suas concentrações, e ambas prolongam o intervalo QT — o risco de torsades de pointes é aditivo e potencialmente grave. Durante o tratamento antimalárico com diidroartemisinina+piperaquina, preferir um antibiótico sem efeito no QT; se a associação for inevitável, vigiar ECG e eletrólitos.',
  explanation_en = 'Piperaquine is partly metabolised by CYP3A4; clarithromycin inhibits this enzyme and can raise its concentrations, and both prolong the QT interval — the torsades de pointes risk is additive and potentially severe. During antimalarial treatment with dihydroartemisinin+piperaquine, prefer an antibiotic without QT effects; if the combination is unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'));

-- 10/16 — CLARITROMICINA + EFAVIRENZ (indução vs inibição)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Efavirenz + claritromicina: o efavirenz reduz os níveis de claritromicina (indução do CYP3A4) e aumenta os do metabolito ativo; o QT pode prolongar-se. Vigiar resposta e ECG.',
  summary_pro_en = 'Efavirenz + clarithromycin: efavirenz lowers clarithromycin levels (CYP3A4 induction) and raises the active metabolite; the QT may prolong. Monitor response and ECG.',
  explanation_pt = 'O efavirenz induz o CYP3A4 e reduz as concentrações de claritromicina em cerca de 40%, ao mesmo tempo que aumenta as do seu metabolito ativo (14-hidroxiclaritromicina); o significado clínico é variável, mas a eficácia antibiótica pode ficar comprometida e o risco de prolongamento do QT aumenta. Em doentes com VIH a receber claritromicina, considerar alternativa (ex.: azitromicina, com menor interação) e vigiar a resposta clínica.',
  explanation_en = 'Efavirenz induces CYP3A4 and lowers clarithromycin concentrations by about 40%, while raising its active metabolite (14-hydroxyclarithromycin); the clinical significance is variable, but antibiotic efficacy may be compromised and the QT prolongation risk increases. In HIV patients receiving clarithromycin, consider an alternative (e.g. azithromycin, with less interaction) and monitor the clinical response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'efavirenz'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'efavirenz'));

-- 11/16 — CLARITROMICINA + HIDROXICLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroxicloroquina + claritromicina: prolongamento aditivo do QT com risco de torsades de pointes. Evitar a associação ou vigiar ECG.',
  summary_pro_en = 'Hydroxychloroquine + clarithromycin: additive QT prolongation with risk of torsades de pointes. Avoid the combination or monitor the ECG.',
  explanation_pt = 'A hidroxicloroquina e a claritromicina prolongam ambas o intervalo QT; o efeito aditivo aumenta o risco de torsades de pointes, sobretudo em doentes com QT basal prolongado, hipocaliemia, insuficiência renal ou cardiopatia. Em doentes com lúpus ou artrite reumatoide em hidroxicloroquina que necessitem de antibiótico, preferir um macrólido com menor efeito no QT ou outra classe; se a associação for inevitável, vigiar ECG e eletrólitos.',
  explanation_en = 'Both hydroxychloroquine and clarithromycin prolong the QT interval; the additive effect increases the torsades de pointes risk, especially in patients with a prolonged baseline QT, hypokalaemia, renal impairment or heart disease. In patients with lupus or rheumatoid arthritis on hydroxychloroquine who need an antibiotic, prefer a macrolide with less QT effect or another class; if the combination is unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'));

-- 12/16 — CLARITROMICINA + LOPERAMIDA (inibição do CYP3A4/P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Loperamida + claritromicina: a claritromicina eleva os níveis de loperamida (inibição do CYP3A4/P-gp), com risco de efeitos no SNC e no QT. Usar a menor dose eficaz.',
  summary_pro_en = 'Loperamide + clarithromycin: clarithromycin raises loperamide levels (CYP3A4/P-gp inhibition), with risk of CNS and QT effects. Use the lowest effective dose.',
  explanation_pt = 'A loperamida é substrato do CYP3A4 e da glicoproteína-P; a claritromicina inibe ambas as vias e pode aumentar substancialmente as suas concentrações, potenciando a depressão do SNC (sonolência, obstipação grave) e o prolongamento do QT (doses altas de loperamida). Recomenda-se usar a menor dose eficaz, evitar doses elevadas e vigiar sonolência, obstipação e palpitações durante a associação.',
  explanation_en = 'Loperamide is a substrate of CYP3A4 and P-glycoprotein; clarithromycin inhibits both pathways and can substantially raise its concentrations, potentiating CNS depression (drowsiness, severe constipation) and QT prolongation (high loperamide doses). Use the lowest effective dose, avoid high doses and monitor drowsiness, constipation and palpitations during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'loperamida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'loperamida'));

-- 13/16 — CLARITROMICINA + MEFLOQUINA (QT aditivo + CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Mefloquina + claritromicina: prolongamento aditivo do QT e aumento dos níveis de mefloquina (inibição do CYP3A4). Evitar a associação.',
  summary_pro_en = 'Mefloquine + clarithromycin: additive QT prolongation and raised mefloquine levels (CYP3A4 inhibition). Avoid the combination.',
  explanation_pt = 'A mefloquina é metabolizada em parte pelo CYP3A4 e prolonga o intervalo QT; a claritromicina inibe o CYP3A4 (elevando os níveis de mefloquina) e também prolonga o QT, pelo que o risco de arritmias ventriculares é aditivo. Em doentes a receber mefloquina, preferir outro antibiótico e outro antimalárico quando possível; se a associação for inevitável, vigiar ECG e eletrólitos.',
  explanation_en = 'Mefloquine is partly metabolised by CYP3A4 and prolongs the QT interval; clarithromycin inhibits CYP3A4 (raising mefloquine levels) and also prolongs the QT, so the ventricular arrhythmia risk is additive. In patients receiving mefloquine, prefer another antibiotic and another antimalarial when possible; if the combination is unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 14/16 — CLARITROMICINA + QUININA (inibição do CYP3A4 + QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Quinina + claritromicina: a claritromicina eleva os níveis de quinina (inibição do CYP3A4) e ambas prolongam o QT. Evitar a associação.',
  summary_pro_en = 'Quinine + clarithromycin: clarithromycin raises quinine levels (CYP3A4 inhibition) and both prolong the QT. Avoid the combination.',
  explanation_pt = 'A quinina é metabolizada pelo CYP3A4 e prolonga o intervalo QT; a claritromicina inibe o CYP3A4, podendo aumentar as concentrações de quinina (com risco de cinconismo e toxicidade cardíaca), e prolonga também o QT — o risco de torsades de pointes é aditivo. Durante o tratamento da malária com quinina, preferir um antibiótico sem interação; se a associação for inevitável, vigiar ECG, níveis de quinina e sinais de toxicidade.',
  explanation_en = 'Quinine is metabolised by CYP3A4 and prolongs the QT interval; clarithromycin inhibits CYP3A4, potentially raising quinine concentrations (with risk of cinchonism and cardiac toxicity), and also prolongs the QT — the torsades de pointes risk is additive. During quinine malaria treatment, prefer a non-interacting antibiotic; if the combination is unavoidable, monitor the ECG, quinine levels and toxicity signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'));

-- 15/16 — CLARITROMICINA + RIFABUTINA (interação bidirecional CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rifabutina + claritromicina: a rifabutina reduz os níveis de claritromicina e a claritromicina eleva os de rifabutina (risco de uveíte, neutropenia). Vigiar ambos.',
  summary_pro_en = 'Rifabutin + clarithromycin: rifabutin lowers clarithromycin levels and clarithromycin raises rifabutin levels (risk of uveitis, neutropenia). Monitor both.',
  explanation_pt = 'A interação é bidirecional: a rifabutina induz o CYP3A4 e reduz as concentrações de claritromicina (comprometendo a eficácia), enquanto a claritromicina inibe o CYP3A4 e aumenta os níveis de rifabutina, elevando o risco de uveíte, neutropenia e artralgias. Em esquemas de micobacteriose (ex.: complexo Mycobacterium avium) com os dois fármacos, recomenda-se reduzir a dose de rifabutina (frequentemente para metade), vigiar hemograma, sintomas oculares e a resposta clínica.',
  explanation_en = 'The interaction is bidirectional: rifabutin induces CYP3A4 and lowers clarithromycin concentrations (compromising efficacy), while clarithromycin inhibits CYP3A4 and raises rifabutin levels, increasing the risk of uveitis, neutropenia and arthralgia. In mycobacterial regimens (e.g. Mycobacterium avium complex) with both drugs, reduce the rifabutin dose (often by half), monitor the blood count, ocular symptoms and the clinical response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'));

-- 16/16 — CLARITROMICINA + TEOFILINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Teofilina + claritromicina: a claritromicina inibe o metabolismo da teofilina e pode elevar os seus níveis, com risco de toxicidade. Vigiar níveis de teofilina.',
  summary_pro_en = 'Theophylline + clarithromycin: clarithromycin inhibits theophylline metabolism and may raise its levels, with risk of toxicity. Monitor theophylline levels.',
  explanation_pt = 'A teofilina é metabolizada pelo CYP1A2 e CYP3A4; a claritromicina inibe o CYP3A4 e pode aumentar as suas concentrações, com risco de toxicidade (náuseas, vómitos, taquicardia, tremores e, em casos graves, convulsões e arritmias). A teofilina tem janela terapêutica estreita, pelo que se recomenda vigiar os seus níveis plasmáticos e reduzir a dose se necessário durante a associação.',
  explanation_en = 'Theophylline is metabolised by CYP1A2 and CYP3A4; clarithromycin inhibits CYP3A4 and can raise its concentrations, with risk of toxicity (nausea, vomiting, tachycardia, tremor and, in severe cases, seizures and arrhythmias). Theophylline has a narrow therapeutic window, so monitor its plasma levels and reduce the dose if needed during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'));
