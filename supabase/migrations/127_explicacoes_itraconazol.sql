-- =====================================================================
-- 127 — Explicações fármaco-fármaco dos pares moderados do ITRACONAZOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 5 pares moderados do itraconazol que os tinham vazios
-- (amiodarona, antiácidos, atorvastatina, carbamazepina, digoxina,
-- omeprazol, rifampicina e warfarina já tinham explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismo central: o itraconazol é um inibidor potente do CYP3A4 —
-- todos os pares são substratos do CYP3A4 cujos níveis sobem:
--   fentanilo ("Not recommended during and 2 weeks after SPORANOX®
--   treatment"; o rótulo do fentanilo: CYP3A4 inhibitors "can result in a
--   fatal overdose"), buprenorfina (IV e sublingual — monitorizar
--   depressão respiratória), donepezilo (inibido in vitro por
--   cetoconazol/quinidina), amlodipina ("Co-administration with CYP3A
--   inhibitors... may require dose reduction"), sildenafil (dose inicial
--   de 25 mg com inibidores fortes; HI não recomendado durante e 2
--   semanas após o itraconazol).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/5 — FENTANILO + ITRACONAZOL (CYP3A4 — depressão respiratória)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fentanilo + itraconazol: o itraconazol inibe o CYP3A4 e aumenta os níveis de fentanilo, com risco de depressão respiratória fatal. Evitar (não recomendado durante e 2 semanas após o itraconazol).',
  summary_pro_en = 'Fentanyl + itraconazole: itraconazole inhibits CYP3A4 and raises fentanyl levels, with a risk of fatal respiratory depression. Avoid (not recommended during and 2 weeks after itraconazole).',
  explanation_pt = 'O fentanilo é metabolizado pelo CYP3A4 e o itraconazol é um inibidor potente desta enzima: o rótulo do itraconazol classifica o fentanilo como "não recomendado durante e 2 semanas após o tratamento com itraconazol", e o rótulo do fentanilo adverte que a coadministração com inibidores do CYP3A4 (como os azóis) "pode resultar numa sobredosagem fatal de fentanilo", com depressão respiratória prolongada ou retardada. Evitar a associação sempre que possível; se for inevitável, reduzir a dose de fentanilo, monitorizar de perto a sedação e a frequência respiratória (sobretudo nos primeiros dias e em doentes com apneia do sono, obesidade ou doença pulmonar) e ter naloxona disponível.',
  explanation_en = 'Fentanyl is metabolised by CYP3A4 and itraconazole is a potent inhibitor of this enzyme: the itraconazole label classifies fentanyl as "not recommended during and 2 weeks after treatment with itraconazole", and the fentanyl label warns that co-administration with CYP3A4 inhibitors (such as the azoles) "can result in a fatal overdose of fentanyl", with prolonged or delayed respiratory depression. Avoid the combination whenever possible; if unavoidable, reduce the fentanyl dose, closely monitor sedation and respiratory rate (especially in the first days and in patients with sleep apnoea, obesity or lung disease) and keep naloxone available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fentanilo'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fentanilo'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 2/5 — BUPRENORFINA + ITRACONAZOL (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Buprenorfina + itraconazol: o itraconazol inibe o CYP3A4 e aumenta os níveis de buprenorfina. Vigiar sedação e depressão respiratória.',
  summary_pro_en = 'Buprenorphine + itraconazole: itraconazole inhibits CYP3A4 and raises buprenorphine levels. Watch for sedation and respiratory depression.',
  explanation_pt = 'A buprenorfina é metabolizada pelo CYP3A4, e o itraconazol (inibidor potente do CYP3A4) pode aumentar as suas concentrações plasmáticas: o rótulo do itraconazol lista a buprenorfina (IV e sublingual) entre os fármacos com interação farmacocinética documentada com o itraconazol, e o rótulo da buprenorfina adverte que os inibidores do CYP3A4 aumentam os níveis de buprenorfina, recomendando monitorizar e, quando o inibidor for descontinuado, considerar o ajuste da dose. A associação (ex.: doente em terapêutica de substituição opioide que inicia um antifúngico oral) requer vigilância de sedação, sonolência, confusão e depressão respiratória, especialmente no início; reduzir a dose de buprenorfina se necessário.',
  explanation_en = 'Buprenorphine is metabolised by CYP3A4, and itraconazole (a potent CYP3A4 inhibitor) can raise its plasma concentrations: the itraconazole label lists buprenorphine (IV and sublingual) among the drugs with documented pharmacokinetic interaction with itraconazole, and the buprenorphine label warns that CYP3A4 inhibitors increase buprenorphine levels, recommending monitoring and, when the inhibitor is discontinued, considering dose adjustment. The combination (e.g. an opioid substitution patient starting an oral antifungal) requires vigilance for sedation, drowsiness, confusion and respiratory depression, especially at initiation; reduce the buprenorphine dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'buprenorfina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'buprenorfina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 3/5 — DONEPEZILO + ITRACONAZOL (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Donepezilo + itraconazol: o itraconazol inibe o CYP3A4 e aumenta os níveis de donepezilo. Vigiar efeitos colinérgicos e bradicardia.',
  summary_pro_en = 'Donepezil + itraconazole: itraconazole inhibits CYP3A4 and raises donepezil levels. Watch for cholinergic effects and bradycardia.',
  explanation_pt = 'O donepezilo é metabolizado pelas isoenzimas CYP3A4 e CYP2D6, e o rótulo do donepezilo refere que o cetoconazol e a quinidina, inibidores fortes do CYP3A4 e do CYP2D6, respetivamente, inibem o metabolismo do donepezilo in vitro (o cetoconazol é da mesma classe dos azóis que o itraconazol, também inibidor forte do CYP3A4). Níveis aumentados de donepezilo podem potenciar os efeitos colinérgicos (náuseas, diarreia, vómitos, bradicardia, síncope — o rótulo alerta para efeitos vagotónicos no nó sinusal e auriculoventricular, com bradicardia ou bloqueio cardíaco). Em idosos com doença de Alzheimer, vigiar frequência cardíaca, sintomas gastrointestinais e sinais de bradicardia/síncope quando o itraconazol é iniciado; considerar reduzir a dose de donepezilo nos doentes suscetíveis.',
  explanation_en = 'Donepezil is metabolised by the CYP3A4 and CYP2D6 isoenzymes, and the donepezil label states that ketoconazole and quinidine, strong inhibitors of CYP3A4 and CYP2D6, respectively, inhibit donepezil metabolism in vitro (ketoconazole is from the same azole class as itraconazole, also a strong CYP3A4 inhibitor). Increased donepezil levels can potentiate the cholinergic effects (nausea, diarrhoea, vomiting, bradycardia, syncope — the label warns about vagotonic effects on the sinoatrial and atrioventricular nodes, with bradycardia or heart block). In elderly Alzheimer patients, monitor heart rate, gastrointestinal symptoms and signs of bradycardia/syncope when itraconazole is started; consider reducing the donepezil dose in susceptible patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'donepezilo'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'donepezilo'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 4/5 — ITRACONAZOL + AMLODIPINA (CYP3A4 — hipotensão/edema)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol + amlodipina: o itraconazol inibe o CYP3A4 e aumenta os níveis de amlodipina. Vigiar hipotensão, edema e tonturas; considerar reduzir a dose.',
  summary_pro_en = 'Itraconazole + amlodipine: itraconazole inhibits CYP3A4 and raises amlodipine levels. Watch for hypotension, oedema and dizziness; consider a dose reduction.',
  explanation_pt = 'A amlodipina é metabolizada pelo CYP3A4 e o rótulo refere que "a coadministração com inibidores do CYP3A (moderados e fortes) resulta num aumento da exposição sistémica à amlodipina e pode exigir redução da dose" (por exemplo, com diltiazem — um inibidor moderado — a exposição aumentou 60%). O itraconazol é um inibidor potente do CYP3A4, pelo que a associação aumenta os níveis de amlodipina e os seus efeitos dose-dependentes: hipotensão, edema periférico, rubor, cefaleia e tonturas, sobretudo em idosos. Vigiar a pressão arterial e os sinais de sobredosagem relativa; se a associação for necessária, considerar iniciar com dose mais baixa de amlodipina ou reduzir a dose, monitorizando o doente nas primeiras semanas.',
  explanation_en = 'Amlodipine is metabolised by CYP3A4 and the label states that "co-administration with CYP3A inhibitors (moderate and strong) results in increased systemic exposure to amlodipine and may require dose reduction" (for example, with diltiazem — a moderate inhibitor — exposure increased by 60%). Itraconazole is a potent CYP3A4 inhibitor, so the combination raises amlodipine levels and its dose-dependent effects: hypotension, peripheral oedema, flushing, headache and dizziness, especially in the elderly. Monitor blood pressure and signs of relative overdose; if the combination is needed, consider starting with a lower amlodipine dose or reducing it, monitoring the patient in the first weeks.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'));

-- 5/5 — ITRACONAZOL + SILDENAFIL (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol + sildenafil: o itraconazol inibe o CYP3A4 e aumenta os níveis de sildenafil. Considerar dose inicial de 25 mg; HI: não recomendado durante e 2 semanas após o itraconazol.',
  summary_pro_en = 'Itraconazole + sildenafil: itraconazole inhibits CYP3A4 and raises sildenafil levels. Consider a 25 mg starting dose; PH: not recommended during and 2 weeks after itraconazole.',
  explanation_pt = 'O sildenafil é metabolizado pelo CYP3A4, e o rótulo do sildenafil recomenda "considerar uma dose inicial de 25 mg em doentes tratados com inibidores fortes do CYP3A4 (ex.: cetoconazol, itraconazol, saquinavir) ou eritromicina"; o rótulo do itraconazol distingue as indicações: para a hipertensão pulmonar, o sildenafil é "não recomendado durante e 2 semanas após o tratamento com itraconazol", enquanto para a disfunção erétil recomenda "monitorizar reações adversas". O aumento dos níveis de sildenafil potenciar o risco de hipotensão, cefaleia, rubor, dispepsia e, raramente, priapismo ou alterações visuais. Na disfunção erétil, usar a dose eficaz mais baixa (nunca exceder 25 mg) e espaçar as tomas; na hipertensão pulmonar, evitar a associação e procurar alternativa.',
  explanation_en = 'Sildenafil is metabolised by CYP3A4, and the sildenafil label recommends "considering a starting dose of 25 mg in patients treated with strong CYP3A4 inhibitors (e.g. ketoconazole, itraconazole, saquinavir) or erythromycin"; the itraconazole label distinguishes the indications: for pulmonary hypertension, sildenafil is "not recommended during and 2 weeks after treatment with itraconazole", while for erectile dysfunction it recommends "monitoring for adverse reactions". Raised sildenafil levels potentiate the risk of hypotension, headache, flushing, dyspepsia and, rarely, priapism or visual disturbances. For erectile dysfunction, use the lowest effective dose (never exceeding 25 mg) and space the doses; for pulmonary hypertension, avoid the combination and seek an alternative.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'));
