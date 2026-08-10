-- =====================================================================
-- 108 — Explicações fármaco-fármaco dos pares moderados dos ANTIÁCIDOS
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 14 pares moderados dos antiácidos que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Mecanismos centrais dos antiácidos (hidróxidos de Al/Mg/Ca):
--   1. Quelação/adsorção dos catiões com fármacos coadministrados, com
--      redução da absorção (fluoroquinolonas, tetraciclinas, bisfosfonatos,
--      levotiroxina);
--   2. Elevação do pH gástrico, que reduz a absorção de fármacos que exigem
--      meio ácido (azóis cetoconazol/itraconazol, atazanavir);
--   3. Redução da absorção de outros fármacos (cloroquina, etambutol,
--      fosfomicina);
--   4. Interferência local com sucralfato (ativação pH-dependente) e toma
--      simultânea com omeprazol.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/14 — ALENDRONATO + ANTIÁCIDOS (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Alendronato + antiácidos: os catiões (cálcio, magnésio, alumínio) quelam o alendronato e reduzem a sua absorção. Separar a toma por pelo menos 30 minutos, idealmente 2 horas.',
  summary_pro_en = 'Alendronate + antacids: cations (calcium, magnesium, aluminium) chelate alendronate and reduce its absorption. Separate administration by at least 30 minutes, ideally 2 hours.',
  explanation_pt = 'Os antiácidos contendo cálcio, magnésio ou alumínio formam quelatos insolúveis com os bisfosfonatos orais, como o alendronato, reduzindo marcadamente a sua absorção e eficácia (risco de falência terapêutica na osteoporose). O alendronato deve ser tomado em jejum, com água, pelo menos 30 minutos antes do primeiro alimento ou medicamento do dia. Quando é necessário usar um antiácido, a toma deve ser espaçada o máximo possível (idealmente 2 horas), e o doente deve ser instruído a manter o esquema habitual do alendronato para não comprometer a adesão.',
  explanation_en = 'Antacids containing calcium, magnesium or aluminium form insoluble chelates with oral bisphosphonates such as alendronate, markedly reducing their absorption and efficacy (risk of therapeutic failure in osteoporosis). Alendronate should be taken on an empty stomach, with water, at least 30 minutes before the first food or medicine of the day. When an antacid is needed, administration should be separated as much as possible (ideally 2 hours), and the patient should be instructed to keep the usual alendronate schedule so adherence is not compromised.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

-- 2/14 — ANTIÁCIDOS + ATAZANAVIR (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + atazanavir: a elevação do pH gástrico reduz a solubilidade e a absorção do atazanavir. Administrar o atazanavir 2 horas antes ou 1 hora depois dos antiácidos.',
  summary_pro_en = 'Antacids + atazanavir: raised gastric pH reduces atazanavir solubility and absorption. Administer atazanavir 2 hours before or 1 hour after antacids.',
  explanation_pt = 'O atazanavir é um inibidor da protease do VIH cuja absorção depende de um pH gástrico ácido: os antiácidos, ao neutralizarem o ácido, reduzem a solubilidade e a concentração plasmática do fármaco, com risco de perda de eficácia antirretrovírica e de resistência viral. O rótulo do atazanavir recomenda administrar o fármaco 2 horas antes ou 1 hora depois dos antiácidos (e de medicamentos tamponados). Em doentes em terapêutica antirretrovírica, qualquer fármaco que eleve o pH gástrico (antiácidos, antagonistas H2, inibidores da bomba de protões) deve ser gerido com precaução e com o espaçamento indicado.',
  explanation_en = 'Atazanavir is an HIV protease inhibitor whose absorption depends on an acidic gastric pH: antacids, by neutralising the acid, reduce the drug solubility and plasma concentration, with a risk of loss of antiretroviral efficacy and viral resistance. The atazanavir label recommends administering the drug 2 hours before or 1 hour after antacids (and buffered medications). In patients on antiretroviral therapy, any drug that raises gastric pH (antacids, H2 antagonists, proton pump inhibitors) must be managed with caution and with the recommended spacing.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'atazanavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'atazanavir'));

-- 3/14 — ANTIÁCIDOS + CETOCONAZOL (pH gástrico elevado — absorção muito reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + cetoconazol: a absorção do cetoconazol comprimido depende de pH ácido; os antiácidos reduzem-na drasticamente. Evitar a toma simultânea e separar por pelo menos 2 horas.',
  summary_pro_en = 'Antacids + ketoconazole: ketoconazole tablet absorption depends on acidic pH; antacids reduce it dramatically. Avoid simultaneous administration and separate by at least 2 hours.',
  explanation_pt = 'O cetoconazol (comprimido) é um antifúngico azólico cuja absorção oral é fortemente dependente do pH gástrico ácido — o fármaco é uma base fraca que só se dissolve bem em meio ácido. Os antiácidos, ao elevarem o pH, podem reduzir as concentrações plasmáticas do cetoconazol de forma clinicamente significativa, comprometendo o tratamento de infeções fúngicas sistémicas. O rótulo do cetoconazol e o Prontuário Terapêutico recomendam evitar a associação ou separar a toma por pelo menos 2 horas (idealmente mais), e considerar monitorizar a resposta clínica ao antifúngico.',
  explanation_en = 'Ketoconazole (tablet) is an azole antifungal whose oral absorption is strongly dependent on an acidic gastric pH — the drug is a weak base that only dissolves well in an acidic medium. Antacids, by raising the pH, can reduce ketoconazole plasma concentrations in a clinically significant way, compromising the treatment of systemic fungal infections. The ketoconazole label and the Portuguese Prontuário Terapêutico recommend avoiding the combination or separating administration by at least 2 hours (ideally more), and considering monitoring the clinical response to the antifungal.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 4/14 — ANTIÁCIDOS + CIPROFLOXACINA (quelação — absorção muito reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + ciprofloxacina: os catiões (Al, Mg, Ca) quelam a ciprofloxacina e reduzem a absorção até ~90%. Administrar a ciprofloxacina 2 horas antes ou 6 horas depois dos antiácidos.',
  summary_pro_en = 'Antacids + ciprofloxacin: cations (Al, Mg, Ca) chelate ciprofloxacin and reduce absorption by up to ~90%. Administer ciprofloxacin 2 hours before or 6 hours after antacids.',
  explanation_pt = 'A ciprofloxacina forma quelatos insolúveis com catiões di e trivalentes (alumínio, magnésio, cálcio) presentes nos antiácidos, com redução da biodisponibilidade oral de até 90% e risco de falência terapêutica em infeções graves (p. ex., neutropenia febril, infeções urinárias complicadas). O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois dos antiácidos contendo magnésio ou alumínio, e o mesmo cuidado se aplica a suplementos de cálcio, ferro e zinco e a sucralfato. Em doentes hospitalizados, verificar o horário de administração de ambos.',
  explanation_en = 'Ciprofloxacin forms insoluble chelates with di- and trivalent cations (aluminium, magnesium, calcium) present in antacids, reducing oral bioavailability by up to 90% and risking therapeutic failure in serious infections (e.g., febrile neutropenia, complicated urinary tract infections). The ciprofloxacin label recommends administering the antibiotic 2 hours before or 6 hours after antacids containing magnesium or aluminium; the same care applies to calcium, iron and zinc supplements and to sucralfate. In hospitalised patients, check the administration schedule of both.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 5/14 — ANTIÁCIDOS + CLOROQUINA (adsorção — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + cloroquina: os antiácidos (caulim, magnésio, alumínio) reduzem a absorção da cloroquina. Separar a toma por pelo menos 4 horas.',
  summary_pro_en = 'Antacids + chloroquine: antacids (kaolin, magnesium, aluminium) reduce chloroquine absorption. Separate administration by at least 4 hours.',
  explanation_pt = 'Os antiácidos contendo caulim, magnésio ou alumínio adsorvem a cloroquina no lúmen gastrointestinal e reduzem a sua absorção, podendo diminuir as concentrações plasmáticas e comprometer o tratamento ou a profilaxia antimalárica. O rótulo da cloroquina recomenda separar a administração por pelo menos 4 horas quando é necessário usar um antiácido. Esta precaução é especialmente relevante em doentes a fazer profilaxia de malária ou tratamento de doenças autoimunes (lúpus, artrite reumatoide), onde a adesão ao esquema e a eficácia são críticas.',
  explanation_en = 'Antacids containing kaolin, magnesium or aluminium adsorb chloroquine in the gastrointestinal lumen and reduce its absorption, potentially lowering plasma concentrations and compromising antimalarial treatment or prophylaxis. The chloroquine label recommends separating administration by at least 4 hours when an antacid is needed. This precaution is especially relevant in patients on malaria prophylaxis or treatment of autoimmune diseases (lupus, rheumatoid arthritis), where adherence and efficacy are critical.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'));

-- 6/14 — ANTIÁCIDOS + DOXICICLINA (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + doxiciclina: os catiões (Al, Mg, Ca) quelam as tetraciclinas e reduzem a absorção. Separar a toma por pelo menos 2–3 horas.',
  summary_pro_en = 'Antacids + doxycycline: cations (Al, Mg, Ca) chelate tetracyclines and reduce absorption. Separate administration by at least 2–3 hours.',
  explanation_pt = 'A doxiciclina, como as restantes tetraciclinas, forma quelatos insolúveis com catiões di e trivalentes (cálcio, magnésio, alumínio, ferro, zinco), reduzindo a sua absorção oral e as concentrações plasmáticas — com risco de falência terapêutica em infeções como brucelose, rickettsioses, doença de Lyme ou acne grave. O rótulo da doxiciclina e o Prontuário Terapêutico recomendam separar a administração de antiácidos (e de suplementos de cálcio/ferro e laticínios) por pelo menos 2–3 horas. Alertar o doente para não tomar o antibiótico com leite ou com o antiácido.',
  explanation_en = 'Doxycycline, like other tetracyclines, forms insoluble chelates with di- and trivalent cations (calcium, magnesium, aluminium, iron, zinc), reducing its oral absorption and plasma concentrations — with a risk of therapeutic failure in infections such as brucellosis, rickettsioses, Lyme disease or severe acne. The doxycycline label and the Portuguese Prontuário Terapêutico recommend separating antacids (and calcium/iron supplements and dairy products) by at least 2–3 hours. Warn the patient not to take the antibiotic with milk or with the antacid.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

-- 7/14 — ANTIÁCIDOS + ETAMBUTOL (adsorção — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + etambutol: o hidróxido de alumínio reduz a absorção do etambutol. Separar a toma por pelo menos 4 horas.',
  summary_pro_en = 'Antacids + ethambutol: aluminium hydroxide reduces ethambutol absorption. Separate administration by at least 4 hours.',
  explanation_pt = 'O rótulo do etambutol refere que o hidróxido de alumínio, presente em muitos antiácidos, reduz a absorção do etambutol, podendo diminuir as concentrações plasmáticas do fármaco e comprometer o tratamento antituberculoso. Recomenda-se separar a administração do etambutol e do antiácido por pelo menos 4 horas. A adesão e a eficácia do esquema antituberculoso são críticas, pelo que esta precaução deve ser transmitida ao doente, sobretudo em esquemas de combinação fixa onde o horário já é exigente.',
  explanation_en = 'The ethambutol label states that aluminium hydroxide, present in many antacids, reduces ethambutol absorption, potentially lowering plasma concentrations and compromising antituberculosis treatment. Separate ethambutol and antacid administration by at least 4 hours. Adherence and efficacy of the antituberculosis regimen are critical, so this precaution should be passed on to the patient, especially in fixed-dose combination regimens where the schedule is already demanding.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'etambutol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'etambutol'));

-- 8/14 — ANTIÁCIDOS + FOSFOMICINA (pH/absorção — tomar em jejum, espaçado)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + fosfomicina: tomar a fosfomicina em jejum e separar dos antiácidos para não reduzir a sua absorção.',
  summary_pro_en = 'Antacids + fosfomycin: take fosfomycin on an empty stomach and separate from antacids to avoid reducing its absorption.',
  explanation_pt = 'A fosfomicina trometamol, usada em dose única nas infeções urinárias não complicadas, tem absorção oral reduzida quando tomada com alimentos; a coadministração com antiácidos ou outros fármacos que alterem o pH ou a motilidade gástrica pode reduzir ainda mais a sua biodisponibilidade e comprometer a eficácia. O rótulo recomenda tomar o fármaco com o estômago vazio e o Prontuário Terapêutico aconselha separar de antiácidos. Na prática, orientar o doente a tomar a fosfomicina isolada, em jejum, e a espaçar qualquer antiácido por 2–3 horas.',
  explanation_en = 'Fosfomycin trometamol, used as a single dose in uncomplicated urinary tract infections, has reduced oral absorption when taken with food; co-administration with antacids or other drugs that change gastric pH or motility can further reduce its bioavailability and compromise efficacy. The label recommends taking the drug on an empty stomach and the Portuguese Prontuário Terapêutico advises separating from antacids. In practice, instruct the patient to take fosfomycin alone, on an empty stomach, and to space any antacid by 2–3 hours.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'fosfomicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'fosfomicina'));

-- 9/14 — ANTIÁCIDOS + ITRACONAZOL (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + itraconazol (cápsulas): a absorção depende de pH ácido; os antiácidos reduzem-na. Separar por pelo menos 2 horas e, se possível, evitar a associação.',
  summary_pro_en = 'Antacids + itraconazole (capsules): absorption depends on acidic pH; antacids reduce it. Separate by at least 2 hours and, if possible, avoid the combination.',
  explanation_pt = 'As cápsulas de itraconazol necessitam de um meio gástrico ácido para dissolver e absorver o fármaco; os antiácidos, ao elevarem o pH, reduzem as concentrações plasmáticas do itraconazol e podem comprometer o tratamento de infeções fúngicas sistémicas ou a profilaxia em imunodeprimidos. O rótulo do itraconazol recomenda administrar as cápsulas após uma refeição completa (que promove a acidez) e separar de antiácidos por pelo menos 2 horas. Em alternativa, considerar formulações de itraconazol em solução oral (menos dependentes do pH) sob orientação médica.',
  explanation_en = 'Itraconazole capsules require an acidic gastric medium to dissolve and absorb the drug; antacids, by raising the pH, reduce itraconazole plasma concentrations and can compromise the treatment of systemic fungal infections or prophylaxis in immunocompromised patients. The itraconazole label recommends taking the capsules after a full meal (which promotes acidity) and separating from antacids by at least 2 hours. Alternatively, consider oral solution formulations of itraconazole (less pH-dependent) under medical guidance.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 10/14 — ANTIÁCIDOS + LEVOFLOXACINA (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + levofloxacina: os catiões (Al, Mg, Ca) quelam a levofloxacina e reduzem a absorção. Administrar a levofloxacina 2 horas antes ou 2 horas depois dos antiácidos.',
  summary_pro_en = 'Antacids + levofloxacin: cations (Al, Mg, Ca) chelate levofloxacin and reduce absorption. Administer levofloxacin 2 hours before or 2 hours after antacids.',
  explanation_pt = 'A levofloxacina, como as restantes fluoroquinolonas, forma quelatos insolúveis com catiões di e trivalentes (alumínio, magnésio, cálcio) dos antiácidos, com redução da biodisponibilidade oral e risco de falência terapêutica. O rótulo da levofloxacina recomenda administrar o antibiótico pelo menos 2 horas antes ou 2 horas depois dos antiácidos contendo magnésio ou alumínio (o mesmo se aplica a sucralfato, ferro e zinco). Este espaçamento deve ser verificado no momento da prescrição e da dispensa, sobretudo em ambulatório, para garantir a eficácia do antibiótico.',
  explanation_en = 'Levofloxacin, like other fluoroquinolones, forms insoluble chelates with di- and trivalent cations (aluminium, magnesium, calcium) of antacids, reducing oral bioavailability and risking therapeutic failure. The levofloxacin label recommends administering the antibiotic at least 2 hours before or 2 hours after antacids containing magnesium or aluminium (the same applies to sucralfate, iron and zinc). This spacing should be checked at prescription and dispensing, especially in outpatients, to ensure antibiotic efficacy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'));

-- 11/14 — ANTIÁCIDOS + LEVOTIROXINA (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + levotiroxina: os catiões (Al, Mg, Ca) reduzem a absorção da levotiroxina. Separar a toma por pelo menos 4 horas.',
  summary_pro_en = 'Antacids + levothyroxine: cations (Al, Mg, Ca) reduce levothyroxine absorption. Separate administration by at least 4 hours.',
  explanation_pt = 'A levotiroxina tem absorção gastrointestinal que é reduzida por vários fármacos e alimentos; os antiácidos contendo alumínio, magnésio ou cálcio quelam ou adsorvem a hormona, diminuindo a sua absorção e podendo descompensar o doente hipotiroideu (sinais de hipotiroidismo, TSH elevada). O rótulo da levotiroxina recomenda separar a administração de antiácidos por pelo menos 4 horas. A levotiroxina deve manter-se sempre em jejum, 30–60 minutos antes do pequeno-almoço, e o horário dos antiácidos ajustado em conformidade, com reavaliação da TSH se necessário.',
  explanation_en = 'Levothyroxine has gastrointestinal absorption that is reduced by several drugs and foods; antacids containing aluminium, magnesium or calcium chelate or adsorb the hormone, decreasing its absorption and potentially destabilising the hypothyroid patient (signs of hypothyroidism, raised TSH). The levothyroxine label recommends separating antacid administration by at least 4 hours. Levothyroxine should always be kept on an empty stomach, 30–60 minutes before breakfast, and the antacid schedule adjusted accordingly, with TSH reassessment if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'));

-- 12/14 — ANTIÁCIDOS + MOXIFLOXACINA (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + moxifloxacina: os catiões (Al, Mg, Ca) quelam a moxifloxacina e reduzem a absorção. Administrar a moxifloxacina 4 horas antes ou 8 horas depois dos antiácidos.',
  summary_pro_en = 'Antacids + moxifloxacin: cations (Al, Mg, Ca) chelate moxifloxacin and reduce absorption. Administer moxifloxacin 4 hours before or 8 hours after antacids.',
  explanation_pt = 'A moxifloxacina, fluoroquinolona de largo espetro, forma quelatos insolúveis com catiões di e trivalentes (alumínio, magnésio, cálcio) presentes nos antiácidos, com redução da biodisponibilidade oral e risco de falência terapêutica em infeções respiratórias ou pélvicas. O rótulo da moxifloxacina recomenda administrar o antibiótico 4 horas antes ou 8 horas depois de antiácidos contendo magnésio ou alumínio, sucralfato, ferro ou zinco. Este espaçamento largo deve ser claramente explicado ao doente, uma vez que a moxifloxacina se toma habitualmente uma vez por dia.',
  explanation_en = 'Moxifloxacin, a broad-spectrum fluoroquinolone, forms insoluble chelates with di- and trivalent cations (aluminium, magnesium, calcium) present in antacids, reducing oral bioavailability and risking therapeutic failure in respiratory or pelvic infections. The moxifloxacin label recommends administering the antibiotic 4 hours before or 8 hours after antacids containing magnesium or aluminium, sucralfate, iron or zinc. This wide spacing should be clearly explained to the patient, since moxifloxacin is usually taken once daily.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'));

-- 13/14 — ANTIÁCIDOS + OMEPRAZOL (toma simultânea — espaçar)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + omeprazol: geralmente compatíveis, mas separar a toma (pelo menos 1–2 horas) para não reduzir a absorção do omeprazol.',
  summary_pro_en = 'Antacids + omeprazole: generally compatible, but separate administration (at least 1–2 hours) to avoid reducing omeprazole absorption.',
  explanation_pt = 'O omeprazol é um inibidor da bomba de protões (IBP) que se toma habitualmente em jejum, 30–60 minutos antes do pequeno-almoço. Os antiácidos podem ser usados concomitantemente para alívio sintomático, mas a toma simultânea pode reduzir a absorção do omeprazol (que depende do revestimento entérico e do pH do meio) e diminuir a sua eficácia. O rótulo do omeprazol considera a associação aceitável, mas na prática recomenda-se separar a administração por 1–2 horas. Em doentes com sintomas refratários, avaliar a adesão e o horário antes de escalar a dose do IBP.',
  explanation_en = 'Omeprazole is a proton pump inhibitor (PPI) usually taken on an empty stomach, 30–60 minutes before breakfast. Antacids can be used concomitantly for symptomatic relief, but simultaneous administration can reduce omeprazole absorption (which depends on the enteric coating and the pH of the medium) and decrease its efficacy. The omeprazole label considers the combination acceptable, but in practice it is recommended to separate administration by 1–2 hours. In patients with refractory symptoms, assess adherence and timing before escalating the PPI dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 14/14 — ANTIÁCIDOS + SUCRALFATO (ativação pH-dependente do sucralfato)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antiácidos + sucralfato: os antiácidos reduzem a eficácia do sucralfato (ativação dependente de pH ácido). Não administrar nos 30 minutos antes nem depois do sucralfato.',
  summary_pro_en = 'Antacids + sucralfate: antacids reduce sucralfate efficacy (pH-dependent activation). Do not administer within 30 minutes before or after sucralfate.',
  explanation_pt = 'O sucralfato é um citoprotetor que forma uma barreira adesiva sobre a úlcera, mas a sua polimerização e ativação dependem de um meio gástrico ácido. Os antiácidos, ao neutralizarem o ácido, reduzem a formação dessa barreira e diminuem a eficácia do sucralfato; além disso, o sucralfato pode reduzir a absorção de outros fármacos coadministrados. O rótulo do sucralfato recomenda não administrar antiácidos nos 30 minutos antes nem depois do sucralfato. Na prática, orientar o doente a espaçar as tomas de forma consistente (por exemplo, sucralfato 1 hora antes das refeições e antiácido em horário separado).',
  explanation_en = 'Sucralfate is a cytoprotective agent that forms an adhesive barrier over the ulcer, but its polymerisation and activation depend on an acidic gastric medium. Antacids, by neutralising the acid, reduce the formation of that barrier and decrease sucralfate efficacy; additionally, sucralfate can reduce the absorption of co-administered drugs. The sucralfate label recommends not administering antacids within 30 minutes before or after sucralfate. In practice, instruct the patient to space the doses consistently (for example, sucralfate 1 hour before meals and the antacid at a separate time).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'));
