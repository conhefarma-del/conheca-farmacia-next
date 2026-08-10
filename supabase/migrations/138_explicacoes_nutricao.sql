-- =====================================================================
-- 138 — Explicações fármaco-fármaco dos 33 pares da nutrição/electrólitos
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 33 pares publicados sem explicação: 1 critical (espironolactona
-- × cloreto de potássio) + 32 moderate. São os pares das migrações 069
-- (nutrição: vitamina C, cálcio, potássio, vitamina D3, magnésio, zinco,
-- ferro, glicose) e 134 (benzilpenicilina-benzatina).
-- Padrão da 089/100/119: UPDATE com LEAST/GREATEST canónico + updated_at.
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados já citados
-- no campo source_pt de cada par (DailyMed/FDA) + Prontuário Terapêutico.
-- Mecanismos centrais:
--   1. Hipercaliemia aditiva (espironolactona, IECA, KCl);
--   2. Quelação/redução de absorção (cálcio/magnésio/zinco × quinolonas,
--      tetraciclinas, ferro, levotiroxina, sucralfato, alendronato, IBP);
--   3. Hipercalcemia aditiva e toxicidade digitálica (vitamina D3, cálcio,
--      calcitriol, tiazida) + indutores que aceleram o metabolismo da D3;
--   4. Eletrólitos: hipocaliemia (β2 + magnésio), perda renal de magnésio
--      (furosemida), bloqueio neuromuscular (aminoglicosídeo), arritmias;
--   5. Varfarina: vitamina K dos lípidos, vitamina C em doses altas e
--      antibióticos β-lactâmicos; metotrexato + penicilinas.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- =====================================================================
-- 1. HIPERCALIEMIA ADITIVA
-- =====================================================================

-- 1/33 — ESPIRONOLACTONA + CLORETO DE POTÁSSIO (critical)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Espironolactona + potássio: risco de hipercaliemia grave, potencialmente fatal. Evitar a associação; se inevitável, monitorizar a potassemia e o ECG.',
  summary_pro_en = 'Spironolactone + potassium: risk of severe, potentially fatal hyperkalaemia. Avoid the combination; if unavoidable, monitor serum potassium and ECG.',
  explanation_pt = 'A espironolactona é um diurético poupador de potássio que antagoniza a aldosterona no túbulo contornado distal, reduzindo a excreção renal de potássio. A administração concomitante de suplementos de potássio (cloreto de potássio) aumenta de forma aditiva o risco de hipercaliemia, que pode ser grave e potencialmente fatal (arritmias ventriculares, paragem cardíaca). O risco é ainda maior em doentes com insuficiência renal, diabetes ou idade avançada, e com outros fármacos que elevam o potássio (IECA, ARA II, outros poupadores de potássio). Em geral a associação deve ser evitada; se for clinicamente inevitável (ex.: hipocaliemia grave em doente já medicado), usar a menor dose de potássio, monitorizar a potassemia com frequência e vigiar o ECG, alertando o doente para sintomas como fraqueza muscular, palpitações ou parestesias.',
  explanation_en = 'Spironolactone is a potassium-sparing diuretic that antagonises aldosterone in the distal convoluted tubule, reducing renal potassium excretion. Concomitant potassium supplements (potassium chloride) additively increase the risk of hyperkalaemia, which can be severe and potentially fatal (ventricular arrhythmias, cardiac arrest). The risk is even higher in patients with renal impairment, diabetes or advanced age, and with other potassium-raising drugs (ACE inhibitors, ARBs, other potassium-sparing agents). The combination should generally be avoided; if clinically unavoidable (e.g., severe hypokalaemia in an already treated patient), use the lowest potassium dose, monitor serum potassium frequently and watch the ECG, warning the patient about symptoms such as muscle weakness, palpitations or paraesthesias.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'cloreto_potassio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'cloreto_potassio'));

-- 2/33 — CLORETO DE POTÁSSIO + ENALAPRIL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'IECA + potássio: risco de hipercaliemia, sobretudo na insuficiência renal ou diabetes. Monitorizar a potassemia.',
  summary_pro_en = 'ACE inhibitor + potassium: risk of hyperkalaemia, especially in renal impairment or diabetes. Monitor serum potassium.',
  explanation_pt = 'Os inibidores da enzima de conversão da angiotensina (IECA), como o enalapril, reduzem a secreção de aldosterona e, com ela, a excreção renal de potássio. A toma concomitante de suplementos de potássio (cloreto de potássio) pode resultar em hipercaliemia, sobretudo em doentes com insuficiência renal, diabetes, idade avançada ou com outros fármacos hipercaliemiantes (ARA II, diuréticos poupadores de potássio, AINEs). Recomenda-se iniciar o potássio com cautela, monitorizar a potassemia e a função renal após o início ou ajuste de dose, e alertar para sintomas de hipercaliemia (fraqueza muscular, fadiga, palpitações, parestesias).',
  explanation_en = 'Angiotensin-converting enzyme inhibitors (ACEIs) such as enalapril reduce aldosterone secretion and, with it, renal potassium excretion. Concomitant potassium supplements (potassium chloride) can lead to hyperkalaemia, especially in patients with renal impairment, diabetes, advanced age or taking other potassium-raising drugs (ARBs, potassium-sparing diuretics, NSAIDs). Potassium should be started cautiously, with monitoring of serum potassium and renal function after initiation or dose adjustment, and patients warned about hyperkalaemia symptoms (muscle weakness, fatigue, palpitations, paraesthesias).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloreto_potassio'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloreto_potassio'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'));

-- 3/33 — SULFATO DE MAGNÉSIO + SALBUTAMOL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Salbutamol + magnésio: hipocaliemia aditiva (o β2-agonista baixa o potássio). Monitorizar a potassemia e o ECG.',
  summary_pro_en = 'Salbutamol + magnesium: additive hypokalaemia (the β2-agonist lowers potassium). Monitor serum potassium and ECG.',
  explanation_pt = 'Os β2-agonistas, como o salbutamol, ativam a bomba Na⁺/K⁺-ATPase e promovem a entrada de potássio nas células, causando hipocaliemia transitória. O sulfato de magnésio também pode reduzir o potássio sérico e, em concentrações elevadas, deprime a condução neuromuscular e cardíaca. Em conjunto (situação frequente na crise de asma grave, onde ambos se usam), a hipocaliemia pode ser mais acentuada e aumentar o risco de arritmias, sobretudo em doentes com doença cardiovascular ou digitalizados. Recomenda-se monitorizar a potassemia e o ECG durante a perfusão de magnésio em doentes a receber β2-agonistas em doses elevadas, e corrigir a hipocaliemia se necessário.',
  explanation_en = 'β2-agonists such as salbutamol activate the Na⁺/K⁺-ATPase pump and promote intracellular potassium uptake, causing transient hypokalaemia. Magnesium sulfate can also lower serum potassium and, at high concentrations, depresses neuromuscular and cardiac conduction. Together (a common situation in severe acute asthma, where both are used), hypokalaemia can be more pronounced and increase the risk of arrhythmias, especially in patients with cardiovascular disease or on digoxin. Serum potassium and ECG should be monitored during magnesium infusion in patients receiving high-dose β2-agonists, correcting hypokalaemia if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'salbutamol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'salbutamol'));

-- =====================================================================
-- 2. QUELAÇÃO / REDUÇÃO DE ABSORÇÃO (cálcio, magnésio, zinco)
-- =====================================================================

-- 4/33 — CARBONATO DE CÁLCIO + CIPROFLOXACINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cálcio + ciprofloxacina: quelação com redução da absorção da fluoroquinolona. Separar a toma por 2–6 h.',
  summary_pro_en = 'Calcium + ciprofloxacin: chelation with reduced fluoroquinolone absorption. Separate administration by 2–6 h.',
  explanation_pt = 'Os catiões divalentes e trivalentes (cálcio, magnésio, alumínio, ferro, zinco) formam quelatos insolúveis com as fluoroquinolonas no trato gastrointestinal, reduzindo a sua biodisponibilidade oral e comprometendo potencialmente o tratamento antibacteriano. O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois de antiácidos contendo magnésio ou alumínio e de suplementos de cálcio, ferro ou zinco. Esta precaução é especialmente relevante em doentes a fazer suplementação de cálcio durante um antibiótico (ex.: osteoporose) — verificar os horários na prescrição e, se possível, administrar o cálcio com a refeição mais distante da toma do antibiótico.',
  explanation_en = 'Divalent and trivalent cations (calcium, magnesium, aluminium, iron, zinc) form insoluble chelates with fluoroquinolones in the gastrointestinal tract, reducing oral bioavailability and potentially compromising antibacterial treatment. The ciprofloxacin label recommends giving the antibiotic 2 hours before or 6 hours after magnesium- or aluminium-containing antacids and calcium, iron or zinc supplements. This precaution is especially relevant in patients taking calcium supplements during an antibiotic course (e.g., osteoporosis) — check the timing on the prescription and, if possible, give calcium with the meal furthest from the antibiotic dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 5/33 — CARBONATO DE CÁLCIO + DOXICICLINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cálcio + doxiciclina: quelação com redução da absorção da tetraciclina. Separar a toma por 2–3 h.',
  summary_pro_en = 'Calcium + doxycycline: chelation with reduced tetracycline absorption. Separate administration by 2–3 h.',
  explanation_pt = 'As tetraciclinas, incluindo a doxiciclina, formam quelatos insolúveis com catiões di e trivalentes (cálcio, magnésio, alumínio, ferro, zinco) no trato gastrointestinal, reduzindo a absorção oral e as concentrações plasmáticas — com risco de falência terapêutica em infeções como brucelose, rickettsioses ou doença de Lyme. O rótulo da doxiciclina recomenda separar a administração de antiácidos, suplementos de cálcio e laticínios por pelo menos 2–3 horas. Alertar o doente para não tomar o antibiótico com leite, iogurte ou o suplemento de cálcio, e ajustar os horários para manter a eficácia.',
  explanation_en = 'Tetracyclines, including doxycycline, form insoluble chelates with divalent and trivalent cations (calcium, magnesium, aluminium, iron, zinc) in the gastrointestinal tract, reducing oral absorption and plasma concentrations — with risk of therapeutic failure in infections such as brucellosis, rickettsioses or Lyme disease. The doxycycline label recommends separating antacids, calcium supplements and dairy products by at least 2–3 hours. Warn the patient not to take the antibiotic with milk, yoghurt or the calcium supplement, and adjust timing to maintain efficacy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

-- 6/33 — CARBONATO DE CÁLCIO + FERRO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cálcio + ferro: o cálcio inibe a absorção do ferro oral. Separar a toma por 2 h.',
  summary_pro_en = 'Calcium + iron: calcium inhibits oral iron absorption. Separate administration by 2 h.',
  explanation_pt = 'O cálcio reduz a absorção do ferro não-heme no trato gastrointestinal, tanto por competição por transportadores comuns como pela formação de complexos no lúmen. Em doentes com anemia ferropénica a fazer suplementação de ferro e, em simultâneo, suplementos de cálcio (frequente em mulheres e idosos), a absorção do ferro pode ficar comprometida e atrasar a correção da anemia. Recomenda-se separar as tomas por pelo menos 2 horas (por exemplo, ferro ao pequeno-almoço e cálcio ao jantar), e considerar a vitamina C (que aumenta a absorção do ferro) na mesma toma do ferro.',
  explanation_en = 'Calcium reduces the absorption of non-haem iron in the gastrointestinal tract, both by competing for shared transporters and by forming complexes in the lumen. In patients with iron-deficiency anaemia taking iron supplements and, simultaneously, calcium supplements (common in women and older people), iron absorption can be impaired and delay correction of the anaemia. Separate the doses by at least 2 hours (e.g., iron at breakfast and calcium at dinner), and consider vitamin C (which enhances iron absorption) with the iron dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'ferro'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'ferro'));

-- 7/33 — CARBONATO DE CÁLCIO + ALENDRONATO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cálcio + alendronato: o cálcio liga-se ao bisfosfonato e impede a sua absorção. Separar por ≥ 30–60 min (jejum).',
  summary_pro_en = 'Calcium + alendronate: calcium binds the bisphosphonate and prevents its absorption. Separate by ≥ 30–60 min (fasting).',
  explanation_pt = 'O alendronato e os restantes bisfosfonatos orais têm uma biodisponibilidade muito baixa que depende de serem tomados em jejum, com água simples, e de não haver alimentos, bebidas ou outros medicamentos no estômago que se liguem ao fármaco. O cálcio (e outros catiões) forma complexos com o bisfosfonato no trato gastrointestinal, impedindo a sua absorção e anulando o efeito antirreabsortivo. Na prática, o alendronato deve ser tomado ao acordar, em jejum, com um copo de água, esperando pelo menos 30–60 minutos antes de comer ou tomar o suplemento de cálcio (idealmente o cálcio à refeição seguinte).',
  explanation_en = 'Alendronate and other oral bisphosphonates have a very low bioavailability that depends on being taken fasting, with plain water, and on having no food, drinks or other medicines in the stomach that can bind the drug. Calcium (and other cations) forms complexes with the bisphosphonate in the gastrointestinal tract, preventing its absorption and abolishing the antiresorptive effect. In practice, alendronate should be taken on waking, fasting, with a glass of water, waiting at least 30–60 minutes before eating or taking the calcium supplement (ideally calcium with the next meal).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'alendronato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'alendronato'));

-- 8/33 — CARBONATO DE CÁLCIO + LEVOTIROXINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levotiroxina + cálcio: o cálcio reduz a absorção da levotiroxina. Separar por ≥ 4 h.',
  summary_pro_en = 'Levothyroxine + calcium: calcium reduces levothyroxine absorption. Separate by ≥ 4 h.',
  explanation_pt = 'O carbonato de cálcio (e outros sais de cálcio) liga-se à levotiroxina no trato gastrointestinal e reduz a sua absorção, podendo diminuir o efeito da terapêutica e aumentar o TSH em doentes com hipotiroidismo. O rótulo da levotiroxina recomenda separar a administração de suplementos de cálcio por pelo menos 4 horas. A levotiroxina deve continuar a ser tomada em jejum, de preferência 30–60 minutos antes do pequeno-almoço, e o cálcio noutra altura do dia; quando se inicia ou suspende o cálcio, vigiar o TSH e ajustar a dose se necessário.',
  explanation_en = 'Calcium carbonate (and other calcium salts) binds levothyroxine in the gastrointestinal tract and reduces its absorption, potentially decreasing the effect of therapy and raising TSH in patients with hypothyroidism. The levothyroxine label recommends separating calcium supplements by at least 4 hours. Levothyroxine should continue to be taken fasting, preferably 30–60 minutes before breakfast, with calcium at another time of day; when calcium is started or stopped, monitor TSH and adjust the dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'));

-- 9/33 — CARBONATO DE CÁLCIO + SUCRALFATO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sucralfato + cálcio: o sucralfato liga-se ao cálcio e reduz a sua absorção. Separar por 2 h.',
  summary_pro_en = 'Sucralfate + calcium: sucralfate binds calcium and reduces its absorption. Separate by 2 h.',
  explanation_pt = 'O sucralfato, um polímero de sacarose sulfatada com hidróxido de alumínio, forma uma camada aderente sobre a mucosa gástrica e liga-se a vários fármacos e catiões no trato gastrointestinal, reduzindo a sua absorção. A toma concomitante com suplementos de cálcio diminui a biodisponibilidade do cálcio. Recomenda-se separar a administração por pelo menos 2 horas (idealmente o sucralfato 1 hora antes das refeições e o cálcio noutra altura), e espaçar também de outros medicamentos orais, já que o sucralfato interfere com muitos deles.',
  explanation_en = 'Sucralfate, a polymer of sulfated sucrose with aluminium hydroxide, forms an adherent layer over the gastric mucosa and binds various drugs and cations in the gastrointestinal tract, reducing their absorption. Concomitant calcium supplements decrease calcium bioavailability. Administration should be separated by at least 2 hours (ideally sucralfate 1 hour before meals and calcium at another time), also spacing other oral medicines, since sucralfate interferes with many of them.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'));

-- 10/33 — CARBONATO DE CÁLCIO + OMEPRAZOL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'IBP + cálcio: o omeprazol reduz a absorção do carbonato de cálcio. Considerar citrato de cálcio ou monitorizar.',
  summary_pro_en = 'PPI + calcium: omeprazole reduces calcium carbonate absorption. Consider calcium citrate or monitor.',
  explanation_pt = 'O carbonato de cálcio necessita de pH gástrico ácido para se dissociar e ser absorvido; os inibidores da bomba de protões (IBP), como o omeprazol, elevam o pH gástrico e reduzem a absorção do cálcio do carbonato. Em doentes a fazer IBP prolongado com suplementação de cálcio (frequente na prevenção da osteoporose), a eficácia da suplementação pode ficar comprometida. Alternativas: usar citrato de cálcio (absorção independente do pH), aumentar a dose sob monitorização da calcemia, ou considerar o impacto clínico. A associação é de relevância moderada — não suspender os IBP sem indicação, mas ponderar a forma de cálcio mais adequada.',
  explanation_en = 'Calcium carbonate requires an acidic gastric pH to dissolve and be absorbed; proton pump inhibitors (PPIs) such as omeprazole raise gastric pH and reduce calcium absorption from carbonate. In patients on long-term PPIs taking calcium supplements (common in osteoporosis prevention), the efficacy of supplementation can be compromised. Alternatives: use calcium citrate (pH-independent absorption), increase the dose under serum calcium monitoring, or consider the clinical impact. The interaction is of moderate relevance — do not stop PPIs without indication, but consider the most appropriate calcium salt.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 11/33 — SULFATO DE MAGNÉSIO + CIPROFLOXACINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Magnésio + ciprofloxacina: quelação com redução da absorção. Separar por 2–6 h.',
  summary_pro_en = 'Magnesium + ciprofloxacin: chelation with reduced absorption. Separate by 2–6 h.',
  explanation_pt = 'O magnésio, catião divalente, forma quelatos insolúveis com as fluoroquinolonas no trato gastrointestinal, reduzindo a biodisponibilidade oral da ciprofloxacina e o risco de falência terapêutica em infeções graves. O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois de antiácidos ou suplementos contendo magnésio (incluindo laxantes com magnésio). Em doentes hospitalizados a receber sulfato de magnésio oral ou entérico e ciprofloxacina, verificar os horários de administração de ambos para garantir a eficácia do antibacteriano.',
  explanation_en = 'Magnesium, a divalent cation, forms insoluble chelates with fluoroquinolones in the gastrointestinal tract, reducing the oral bioavailability of ciprofloxacin and the risk of therapeutic failure in serious infections. The ciprofloxacin label recommends giving the antibiotic 2 hours before or 6 hours after magnesium-containing antacids or supplements (including magnesium laxatives). In hospitalised patients receiving oral/enteral magnesium sulfate and ciprofloxacin, check the administration times of both to ensure antibacterial efficacy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 12/33 — ZINCO + CIPROFLOXACINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Zinco + ciprofloxacina: quelação com redução da absorção. Separar por 2–6 h.',
  summary_pro_en = 'Zinc + ciprofloxacin: chelation with reduced absorption. Separate by 2–6 h.',
  explanation_pt = 'O zinco, catião divalente, forma quelatos insolúveis com as fluoroquinolonas no trato gastrointestinal, reduzindo a biodisponibilidade oral da ciprofloxacina — com risco de falência terapêutica em infeções como as do trato urinário ou respiratórias. O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois de suplementos de zinco, ferro ou cálcio e de antiácidos. Em doentes a fazer suplementação de zinco (frequente em diarreia aguda pediátrica, feridas ou carências), separar as tomas e, se possível, administrar o zinco com a refeição mais distante do antibiótico.',
  explanation_en = 'Zinc, a divalent cation, forms insoluble chelates with fluoroquinolones in the gastrointestinal tract, reducing the oral bioavailability of ciprofloxacin — with risk of therapeutic failure in infections such as urinary or respiratory tract infections. The ciprofloxacin label recommends giving the antibiotic 2 hours before or 6 hours after zinc, iron or calcium supplements and antacids. In patients taking zinc supplements (common in acute paediatric diarrhoea, wounds or deficiency), separate the doses and, if possible, give zinc with the meal furthest from the antibiotic.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'zinco'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'zinco'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 13/33 — ZINCO + DOXICICLINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Zinco + doxiciclina: quelação com redução da absorção. Separar por 2–3 h.',
  summary_pro_en = 'Zinc + doxycycline: chelation with reduced absorption. Separate by 2–3 h.',
  explanation_pt = 'As tetraciclinas, incluindo a doxiciclina, formam quelatos insolúveis com catiões di e trivalentes (zinco, cálcio, magnésio, ferro, alumínio) no trato gastrointestinal, reduzindo a absorção oral e as concentrações plasmáticas do antibiótico. O rótulo da doxiciclina recomenda separar a administração de suplementos de zinco (e de outros catiões) por pelo menos 2–3 horas. Alertar o doente para o espaçamento das tomas e verificar os horários na prescrição, sobretudo em doentes com suplementação de zinco durante o antibiótico.',
  explanation_en = 'Tetracyclines, including doxycycline, form insoluble chelates with divalent and trivalent cations (zinc, calcium, magnesium, iron, aluminium) in the gastrointestinal tract, reducing the oral absorption and plasma concentrations of the antibiotic. The doxycycline label recommends separating zinc supplements (and other cations) by at least 2–3 hours. Warn the patient about the spacing of doses and check the times on the prescription, especially in patients taking zinc supplements during the antibiotic course.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'zinco'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'zinco'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

-- 14/33 — ZINCO + SUCRALFATO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sucralfato + zinco: o sucralfato liga-se ao zinco e reduz a sua absorção. Separar por 2 h.',
  summary_pro_en = 'Sucralfate + zinc: sucralfate binds zinc and reduces its absorption. Separate by 2 h.',
  explanation_pt = 'O sucralfato liga-se a catiões e a vários fármacos no trato gastrointestinal, formando complexos que reduzem a absorção. A toma concomitante com suplementos de zinco diminui a biodisponibilidade do zinco. Recomenda-se separar a administração por pelo menos 2 horas (o sucralfato habitualmente 1 hora antes das refeições), e espaçar também os outros medicamentos orais, já que o sucralfato interfere com muitos deles.',
  explanation_en = 'Sucralfate binds cations and various drugs in the gastrointestinal tract, forming complexes that reduce absorption. Concomitant zinc supplements decrease zinc bioavailability. Administration should be separated by at least 2 hours (sucralfate usually 1 hour before meals), also spacing other oral medicines, since sucralfate interferes with many of them.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sucralfato'), (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sucralfato'), (SELECT id FROM public.drugs WHERE slug = 'zinco'));

-- 15/33 — ZINCO + LEVOTIROXINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levotiroxina + zinco: o zinco pode reduzir a absorção da levotiroxina. Separar por ≥ 4 h.',
  summary_pro_en = 'Levothyroxine + zinc: zinc may reduce levothyroxine absorption. Separate by ≥ 4 h.',
  explanation_pt = 'O zinco, tal como o cálcio e o ferro, pode ligar-se à levotiroxina no trato gastrointestinal e reduzir a sua absorção, com potencial aumento do TSH em doentes com hipotiroidismo. Recomenda-se separar a administração por pelo menos 4 horas: a levotiroxina em jejum 30–60 minutos antes do pequeno-almoço, e o suplemento de zinco noutra altura do dia. Ao iniciar ou suspender a suplementação de zinco, vigiar o TSH e ajustar a dose de levotiroxina se necessário.',
  explanation_en = 'Zinc, like calcium and iron, can bind levothyroxine in the gastrointestinal tract and reduce its absorption, potentially raising TSH in patients with hypothyroidism. Administration should be separated by at least 4 hours: levothyroxine fasting 30–60 minutes before breakfast, and the zinc supplement at another time of day. When zinc supplementation is started or stopped, monitor TSH and adjust the levothyroxine dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'));

-- 16/33 — FERRO + ZINCO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ferro + zinco: competem pela absorção intestinal. Separar as tomas.',
  summary_pro_en = 'Iron + zinc: compete for intestinal absorption. Separate the doses.',
  explanation_pt = 'O ferro e o zinco partilham transportadores intestinais comuns (ex.: DMT1, transportadores de metais divalentes) e competem entre si pela absorção quando administrados em simultâneo, sobretudo em doses elevadas. Em doentes a fazer suplementação conjunta de ferro e zinco (frequente em carências múltiplas, gravidez ou má absorção), a absorção de ambos pode diminuir. Recomenda-se separar as tomas (por exemplo, ferro ao pequeno-almoço e zinco ao jantar) ou administrá-los em alturas diferentes do dia; a toma com alimentos pode ainda reduzir a competição, embora também diminua a absorção de ambos.',
  explanation_en = 'Iron and zinc share common intestinal transporters (e.g., DMT1, divalent metal transporters) and compete with each other for absorption when given simultaneously, especially at high doses. In patients taking combined iron and zinc supplementation (common in multiple deficiencies, pregnancy or malabsorption), absorption of both can decrease. Separate the doses (e.g., iron at breakfast and zinc at dinner) or give them at different times of day; taking them with food may reduce competition but also decreases absorption of both.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'zinco'));

-- 17/33 — FERRO + ÁCIDO ASCÓRBICO (moderate — interação favorável)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ferro + vitamina C: a vitamina C aumenta a absorção do ferro oral — associação útil, não prejudicial.',
  summary_pro_en = 'Iron + vitamin C: vitamin C increases oral iron absorption — a useful, not harmful, association.',
  explanation_pt = 'O ácido ascórbico (vitamina C) reduz o ferro férrico (Fe³⁺) a ferroso (Fe²⁺) no lúmen intestinal e mantém-no solúvel, aumentando a absorção do ferro não-heme — o Prontuário Terapêutico regista que 30 mg de vitamina C potenciam a absorção de 200 mg de ferro. Esta é uma interação clinicamente favorável, frequentemente usada para melhorar a resposta à suplementação de ferro na anemia ferropénica; não representa risco se as doses forem as habituais. Recomenda-se tomá-los na mesma toma (ou com o sumo de citrinos) para aproveitar o benefício, evitando, em contrapartida, a toma simultânea com cálcio, chá ou café, que reduzem a absorção do ferro.',
  explanation_en = 'Ascorbic acid (vitamin C) reduces ferric iron (Fe³⁺) to ferrous (Fe²⁺) in the intestinal lumen and keeps it soluble, increasing absorption of non-haem iron — the Prontuário Terapêutico records that 30 mg of vitamin C enhance the absorption of 200 mg of iron. This is a clinically favourable interaction, often used to improve the response to iron supplementation in iron-deficiency anaemia; it poses no risk at usual doses. Take them together (or with citrus juice) to gain the benefit, while avoiding simultaneous intake with calcium, tea or coffee, which reduce iron absorption.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'acido_ascorbico'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'acido_ascorbico'));

-- =====================================================================
-- 3. HIPERCALCEMIA / VITAMINA D / TOXICIDADE DIGITÁLICA
-- =====================================================================

-- 18/33 — CALCITRIOL + COLECALCIFEROL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Calcitriol + vitamina D3: efeito vitamina D aditivo com risco de hipercalcemia. Monitorizar a calcemia.',
  summary_pro_en = 'Calcitriol + vitamin D3: additive vitamin D effect with risk of hypercalcaemia. Monitor serum calcium.',
  explanation_pt = 'O calcitriol (1,25-di-hidroxicolecalciferol) é a forma ativa da vitamina D; o colecalciferol (D3) é convertido no organismo em calcitriol. A toma concomitante soma os efeitos sobre a absorção intestinal de cálcio e pode causar hipercalcemia, hipercalciúria e, em casos prolongados, nefrocalcinose e insuficiência renal. Em doentes a receber ambas (ex.: doença renal crónica com D3 de manutenção e calcitriol ativo), monitorizar a calcemia, a calciúria e a função renal, e reduzir ou suspender uma das formas se a calcemia subir acima do limite.',
  explanation_en = 'Calcitriol (1,25-dihydroxycholecalciferol) is the active form of vitamin D; cholecalciferol (D3) is converted in the body to calcitriol. Concomitant use sums the effects on intestinal calcium absorption and can cause hypercalcaemia, hypercalciuria and, if prolonged, nephrocalcinosis and renal impairment. In patients receiving both (e.g., chronic kidney disease with maintenance D3 and active calcitriol), monitor serum calcium, urinary calcium and renal function, and reduce or stop one form if serum calcium rises above the limit.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'colecalciferol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'colecalciferol'));

-- 19/33 — CARBONATO DE CÁLCIO + CALCITRIOL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cálcio + calcitriol: hipercalcemia aditiva. Monitorizar a calcemia e a função renal.',
  summary_pro_en = 'Calcium + calcitriol: additive hypercalcaemia. Monitor serum calcium and renal function.',
  explanation_pt = 'O calcitriol aumenta a absorção intestinal do cálcio; a toma concomitante com suplementos de cálcio (carbonato) soma-se a este efeito e aumenta o risco de hipercalcemia, com anorexia, náuseas, obstipação, fraqueza, poliúria e, em casos graves, nefrocalcinose, arritmias e coma. Esta associação é frequente e intencional na doença renal crónica e no hipoparatiroidismo, mas exige monitorização da calcemia e da função renal, com ajuste da dose de cálcio e de calcitriol conforme os valores; vigiar também a interação com tiazidas, que reduzem a excreção renal de cálcio.',
  explanation_en = 'Calcitriol increases intestinal calcium absorption; concomitant calcium supplements (carbonate) add to this effect and increase the risk of hypercalcaemia, with anorexia, nausea, constipation, weakness, polyuria and, in severe cases, nephrocalcinosis, arrhythmias and coma. This combination is common and intentional in chronic kidney disease and hypoparathyroidism, but requires monitoring of serum calcium and renal function, adjusting the calcium and calcitriol doses according to the values; also watch the interaction with thiazides, which reduce renal calcium excretion.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'calcitriol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'calcitriol'));

-- 20/33 — CARBONATO DE CÁLCIO + HIDROCLOROTIAZIDA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tiazida + cálcio: a tiazida reduz a excreção renal de cálcio — risco de hipercalcemia.',
  summary_pro_en = 'Thiazide + calcium: the thiazide reduces renal calcium excretion — risk of hypercalcaemia.',
  explanation_pt = 'As tiazidas (hidroclorotiazida) aumentam a reabsorção tubular de cálcio e reduzem a sua excreção urinária, elevando a calcemia. Em doentes a fazer suplementos de cálcio (carbonato) e vitamina D, a associação pode causar hipercalcemia — o Prontuário Terapêutico regista mesmo a contraindicação das tiazidas na hipercalcemia por este mecanismo. Recomenda-se monitorizar a calcemia em doentes em suplementação de cálcio a iniciar uma tiazida, e considerar a redução da dose de cálcio; a interação pode, no entanto, ser usada favoravelmente na litíase renal por hipercalciúria.',
  explanation_en = 'Thiazides (hydrochlorothiazide) increase tubular calcium reabsorption and reduce its urinary excretion, raising serum calcium. In patients taking calcium supplements (carbonate) and vitamin D, the combination can cause hypercalcaemia — the Prontuário Terapêutico even records thiazides as contraindicated in hypercalcaemia by this mechanism. Monitor serum calcium in patients on calcium supplementation starting a thiazide, and consider reducing the calcium dose; the interaction can, however, be used favourably in renal stone disease due to hypercalciuria.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

-- 21/33 — HIDROCLOROTIAZIDA + COLECALCIFEROL (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tiazida + vitamina D3: hipercalcemia aditiva. Monitorizar a calcemia.',
  summary_pro_en = 'Thiazide + vitamin D3: additive hypercalcaemia. Monitor serum calcium.',
  explanation_pt = 'A hidroclorotiazida reduz a excreção renal de cálcio e a vitamina D3 aumenta a absorção intestinal do cálcio; em conjunto, os dois efeitos somam-se e podem causar hipercalcemia, sobretudo em doentes com insuficiência renal, imobilização prolongada ou suplementação adicional de cálcio. O risco é particularmente relevante quando se inicia a vitamina D em doentes já medicados com tiazidas, ou quando se aumenta a dose. Recomenda-se monitorizar a calcemia (e a calciúria) após iniciar ou ajustar a dose de vitamina D em doentes com tiazidas, e reduzir a suplementação se a calcemia subir.',
  explanation_en = 'Hydrochlorothiazide reduces renal calcium excretion and vitamin D3 increases intestinal calcium absorption; together the two effects add up and can cause hypercalcaemia, especially in patients with renal impairment, prolonged immobilisation or additional calcium supplementation. The risk is particularly relevant when starting vitamin D in patients already on thiazides, or when increasing the dose. Monitor serum calcium (and urinary calcium) after starting or adjusting vitamin D in patients on thiazides, and reduce supplementation if serum calcium rises.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'colecalciferol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'colecalciferol'));

-- 22/33 — COLECALCIFEROL + DIGOXINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Digoxina + vitamina D3: a hipercalcemia induzida pela vitamina D pode aumentar a toxicidade digitálica.',
  summary_pro_en = 'Digoxin + vitamin D3: vitamin D-induced hypercalcaemia may increase digitalis toxicity.',
  explanation_pt = 'A toxicidade digitálica é potenciada por distúrbios eletrolíticos, incluindo a hipercalcemia (e a hipocaliemia e a hipomagnesemia). A vitamina D3, sobretudo em doses elevadas ou com suplementação simultânea de cálcio, pode elevar a calcemia e aumentar a sensibilidade do miocárdio à digoxina, com risco de arritmias. Em doentes digitalizados a iniciar vitamina D (ou a aumentar a dose), monitorizar a calcemia e os sinais de toxicidade digitálica (náuseas, bradicardia, arritmias, alterações visuais) e considerar a medição da digoxinemia; corrigir prontamente qualquer hipercalcemia.',
  explanation_en = 'Digitalis toxicity is potentiated by electrolyte disturbances, including hypercalcaemia (and hypokalaemia and hypomagnesaemia). Vitamin D3, especially at high doses or with simultaneous calcium supplementation, can raise serum calcium and increase myocardial sensitivity to digoxin, with risk of arrhythmias. In digitalised patients starting vitamin D (or increasing the dose), monitor serum calcium and signs of digitalis toxicity (nausea, bradycardia, arrhythmias, visual disturbances) and consider measuring digoxin levels; correct any hypercalcaemia promptly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 23/33 — CARBONATO DE CÁLCIO + DIGOXINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Digoxina + cálcio: a hipercalcemia potencia a toxicidade digitálica. Monitorizar o ECG.',
  summary_pro_en = 'Digoxin + calcium: hypercalcaemia potentiates digitalis toxicity. Monitor ECG.',
  explanation_pt = 'O cálcio aumenta a contratilidade miocárdica e, em concentrações elevadas, sensibiliza o coração à digoxina, aumentando o risco de arritmias (incluindo extra-sístoles e taquicardias ventriculares). A administração intravenosa rápida de cálcio em doentes digitalizados é particularmente perigosa. Em doentes com digoxina a fazer suplementos orais de cálcio, monitorizar a calcemia e o ECG, usar a menor dose eficaz de cálcio e corrigir qualquer hipercalcemia; vigiar também os sinais de toxicidade digitálica. A associação é segura com calcemia normal, mas o limiar de toxicidade baixa com a hipercalcemia.',
  explanation_en = 'Calcium increases myocardial contractility and, at high concentrations, sensitises the heart to digoxin, increasing the risk of arrhythmias (including premature beats and ventricular tachycardias). Rapid intravenous calcium administration in digitalised patients is particularly dangerous. In patients on digoxin taking oral calcium supplements, monitor serum calcium and ECG, use the lowest effective calcium dose and correct any hypercalcaemia; also watch for signs of digitalis toxicity. The combination is safe with normal serum calcium, but the toxicity threshold falls with hypercalcaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 24/33 — COLECALCIFEROL + FENITOINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fenitoína + vitamina D3: a fenitoína acelera o metabolismo da vitamina D — risco de deficiência e osteomalacia.',
  summary_pro_en = 'Phenytoin + vitamin D3: phenytoin accelerates vitamin D metabolism — risk of deficiency and osteomalacia.',
  explanation_pt = 'A fenitoína (e outros indutores enzimáticos, como a carbamazepina e o fenobarbital) induz as enzimas hepáticas do citocromo P450 (CYP3A4, CYP2C9) que hidroxilam a vitamina D, acelerando o seu catabolismo e reduzindo os níveis de 25-hidroxivitamina D. A longo prazo, esta perda pode causar hipocalcemia, hiperparatiroidismo secundário, redução da densidade óssea e osteomalacia em doentes epiléticos em terapêutica prolongada. Recomenda-se monitorizar os níveis de vitamina D e a calcemia, considerar suplementação preventiva de vitamina D (e cálcio) e avaliar a densidade óssea nos doentes em tratamento crónico com fenitoína.',
  explanation_en = 'Phenytoin (and other enzyme inducers such as carbamazepine and phenobarbital) induces hepatic cytochrome P450 enzymes (CYP3A4, CYP2C9) that hydroxylate vitamin D, accelerating its catabolism and reducing 25-hydroxyvitamin D levels. Long-term, this loss can cause hypocalcaemia, secondary hyperparathyroidism, reduced bone density and osteomalacia in epileptic patients on prolonged therapy. Monitor vitamin D levels and serum calcium, consider preventive vitamin D (and calcium) supplementation and assess bone density in patients on chronic phenytoin.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- 25/33 — COLECALCIFEROL + CARBAMAZEPINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + vitamina D3: a carbamazepina acelera o metabolismo da vitamina D — risco de deficiência.',
  summary_pro_en = 'Carbamazepine + vitamin D3: carbamazepine accelerates vitamin D metabolism — risk of deficiency.',
  explanation_pt = 'A carbamazepina é um indutor enzimático (CYP3A4 e outras) que acelera o catabolismo da vitamina D, reduzindo os níveis de 25-hidroxivitamina D e, a longo prazo, a calcemia e a densidade óssea — com risco de osteomalacia e fraturas em doentes em terapêutica antiepilética prolongada. Recomenda-se monitorizar a vitamina D e a calcemia, suplementar preventivamente vitamina D (e cálcio quando indicado) e considerar a avaliação da densidade óssea nos doentes crónicos com carbamazepina, sobretudo nos idosos e nas mulheres pós-menopáusicas.',
  explanation_en = 'Carbamazepine is an enzyme inducer (CYP3A4 and others) that accelerates vitamin D catabolism, reducing 25-hydroxyvitamin D levels and, long-term, serum calcium and bone density — with risk of osteomalacia and fractures in patients on prolonged antiepileptic therapy. Monitor vitamin D and serum calcium, supplement vitamin D preventively (and calcium when indicated) and consider bone density assessment in chronic carbamazepine patients, especially older people and postmenopausal women.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colecalciferol'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

-- =====================================================================
-- 4. ELETRÓLITOS: MAGNÉSIO (perda renal, bloqueio neuromuscular, arritmias)
-- =====================================================================

-- 26/33 — FUROSEMIDA + SULFATO DE MAGNÉSIO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Furosemida + magnésio: a furosemida aumenta a perda renal de magnésio — risco de hipomagnesemia.',
  summary_pro_en = 'Furosemide + magnesium: furosemide increases renal magnesium loss — risk of hypomagnesaemia.',
  explanation_pt = 'Os diuréticos de ansa (furosemida) aumentam a excreção renal de magnésio (e de potássio), podendo causar hipomagnesemia em doentes em tratamento prolongado ou com doses elevadas. A hipomagnesemia é clinicamente relevante por si (fraqueza, tetania, arritmias) e por potenciar a toxicidade digitálica e a hipocaliemia. Em doentes a receber sulfato de magnésio (perfusão ou reposição oral) com furosemida, monitorizar a magnesemia e a potassemia, corrigir os défices e reavaliar periodicamente a necessidade do diurético e da reposição.',
  explanation_en = 'Loop diuretics (furosemide) increase renal excretion of magnesium (and potassium), potentially causing hypomagnesaemia in patients on prolonged or high-dose treatment. Hypomagnesaemia is clinically relevant in itself (weakness, tetany, arrhythmias) and because it potentiates digitalis toxicity and hypokalaemia. In patients receiving magnesium sulfate (infusion or oral replacement) with furosemide, monitor serum magnesium and potassium, correct deficits and periodically reassess the need for the diuretic and the replacement.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'));

-- 27/33 — SULFATO DE MAGNÉSIO + DIGOXINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Digoxina + magnésio: desequilíbrio eletrolítico (hipomagnesemia/hipermagnesemia) com risco de arritmias.',
  summary_pro_en = 'Digoxin + magnesium: electrolyte imbalance (hypo/hypermagnesaemia) with risk of arrhythmias.',
  explanation_pt = 'A toxicidade digitálica é potenciada pela hipomagnesemia (e hipocaliemia); inversamente, a hipermagnesemia — que pode ocorrer com perfusão rápida ou insuficiência renal — deprime a condução cardíaca e pode agravar o bloqueio atrioventricular em doentes com digoxina. Em doentes digitalizados, manter a magnesemia e a potassemia em valores normais, corrigir défices (o magnésio é mesmo usado no tratamento da toxicidade digitálica com hipomagnesemia) e, se for administrado magnésio IV, infundir lentamente com monitorização do ECG e da função renal.',
  explanation_en = 'Digitalis toxicity is potentiated by hypomagnesaemia (and hypokalaemia); conversely, hypermagnesaemia — which can occur with rapid infusion or renal impairment — depresses cardiac conduction and can worsen atrioventricular block in patients on digoxin. In digitalised patients, keep serum magnesium and potassium in the normal range, correct deficits (magnesium is even used in the treatment of digitalis toxicity with hypomagnesaemia) and, if IV magnesium is given, infuse slowly with ECG and renal function monitoring.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 28/33 — GENTAMICINA + SULFATO DE MAGNÉSIO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aminoglicosídeo + magnésio: risco de bloqueio neuromuscular e nefrotoxicidade aditiva.',
  summary_pro_en = 'Aminoglycoside + magnesium: risk of neuromuscular blockade and additive nephrotoxicity.',
  explanation_pt = 'Os aminoglicosídeos (gentamicina) podem causar bloqueio neuromuscular, sobretudo em doentes com miastenia gravis, botulismo ou hipocalcemia; o magnésio em concentrações elevadas também deprime a transmissão neuromuscular. Em conjunto, o risco de fraqueza muscular e depressão respiratória aumenta. Além disso, ambos podem lesar o rim: a nefrotoxicidade é aditiva, e a função renal comprometida reduz a depuração de ambos, elevando ainda mais os níveis. Em doentes a receber gentamicina e sulfato de magnésio IV (ex.: pré-eclâmpsia com infeção), monitorizar a função renal, a magnesemia e os níveis do aminoglicosídeo, e vigiar a força muscular e a ventilação.',
  explanation_en = 'Aminoglycosides (gentamicin) can cause neuromuscular blockade, especially in patients with myasthenia gravis, botulism or hypocalcaemia; magnesium at high concentrations also depresses neuromuscular transmission. Together, the risk of muscle weakness and respiratory depression increases. In addition, both can damage the kidney: nephrotoxicity is additive, and impaired renal function reduces clearance of both, raising levels even further. In patients receiving gentamicin and IV magnesium sulfate (e.g., pre-eclampsia with infection), monitor renal function, serum magnesium and aminoglycoside levels, and watch muscle strength and ventilation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'gentamicina'), (SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'gentamicina'), (SELECT id FROM public.drugs WHERE slug = 'sulfato_magnesio'));

-- 29/33 — DEXAMETASONA + GLICOSE (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Corticosteroide + glicose: hiperglicemia aditiva em doentes em nutrição. Monitorizar a glicemia.',
  summary_pro_en = 'Corticosteroid + glucose: additive hyperglycaemia in patients on nutrition. Monitor blood glucose.',
  explanation_pt = 'Os corticosteroides sistémicos (dexametasona) aumentam a glicemia por estimulação da gluconeogénese hepática, redução da captação periférica de glicose e aumento da resistência à insulina. Em doentes a receber glicose por perfusão (nutrição parentérica ou hidratação), o efeito hiperglicemiante soma-se à carga de glicose, podendo causar hiperglicemia significativa, sobretudo em diabéticos, mas também em doentes sem diabetes conhecida em doses elevadas de corticoide. Recomenda-se monitorizar a glicemia capilar (e a diurese), administrar insulina conforme necessário e ajustar a carga de glicose na nutrição quando possível.',
  explanation_en = 'Systemic corticosteroids (dexamethasone) raise blood glucose by stimulating hepatic gluconeogenesis, reducing peripheral glucose uptake and increasing insulin resistance. In patients receiving glucose infusion (parenteral nutrition or hydration), the hyperglycaemic effect adds to the glucose load, potentially causing significant hyperglycaemia, especially in diabetics, but also in patients without known diabetes on high corticosteroid doses. Monitor capillary glucose (and diuresis), give insulin as needed and adjust the glucose load in nutrition when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'glicose'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'glicose'));

-- =====================================================================
-- 5. VARFARINA (vitamina K, vitamina C, antibióticos) + METOTREXATO
-- =====================================================================

-- 30/33 — WARFARINA + EMULSÃO LIPÍDICA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Varfarina + emulsão lipídica: a vitamina K dos lípidos de soja pode reduzir o INR. Monitorizar o INR.',
  summary_pro_en = 'Warfarin + lipid emulsion: the vitamin K in soybean lipids may reduce INR. Monitor INR.',
  explanation_pt = 'As emulsões lipídicas à base de óleo de soja (como o Intralipid) contêm vitamina K, que é o antídoto natural da varfarina: a vitamina K alimentar/intravenosa reativa os fatores de coagulação dependentes dela e reduz o efeito anticoagulante, baixando o INR. Em doentes anticoagulados a receber nutrição parentérica com emulsão lipídica, o aporte de vitamina K pode tornar o INR mais baixo e variável, aumentando o risco trombótico se não for compensado. Recomenda-se monitorizar o INR com mais frequência após iniciar (ou alterar) a emulsão lipídica e ajustar a dose de varfarina conforme os valores.',
  explanation_en = 'Soybean oil-based lipid emulsions (such as Intralipid) contain vitamin K, the natural antidote to warfarin: dietary/intravenous vitamin K reactivates the vitamin K-dependent clotting factors and reduces the anticoagulant effect, lowering INR. In anticoagulated patients receiving parenteral nutrition with lipid emulsion, the vitamin K load can make INR lower and more variable, increasing thrombotic risk if not compensated. Monitor INR more frequently after starting (or changing) the lipid emulsion and adjust the warfarin dose according to the values.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'emulsao_lipidica'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'emulsao_lipidica'));

-- 31/33 — WARFARINA + ÁCIDO ASCÓRBICO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Varfarina + vitamina C: doses elevadas de vitamina C podem alterar o INR. Monitorizar o INR.',
  summary_pro_en = 'Warfarin + vitamin C: high-dose vitamin C may alter INR. Monitor INR.',
  explanation_pt = 'A vitamina C em doses elevadas (vários gramas por dia) tem sido associada a alterações do INR em doentes anticoagulados com varfarina — em geral redução do efeito anticoagulante, embora haja relatos variáveis. O mecanismo não está totalmente esclarecido (possível interferência na absorção ou no metabolismo da varfarina). Com doses habituais (até ~500 mg/dia) o risco é mínimo, mas em doentes a tomar megadoses de vitamina C recomenda-se monitorizar o INR após iniciar, alterar ou suspender a suplementação, e ajustar a dose de varfarina conforme necessário.',
  explanation_en = 'High-dose vitamin C (several grams per day) has been associated with changes in INR in patients anticoagulated with warfarin — generally a reduced anticoagulant effect, although reports vary. The mechanism is not fully clarified (possible interference with warfarin absorption or metabolism). With usual doses (up to ~500 mg/day) the risk is minimal, but in patients taking megadoses of vitamin C, monitor INR after starting, changing or stopping the supplement, and adjust the warfarin dose as needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'acido_ascorbico'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'acido_ascorbico'));

-- 32/33 — WARFARINA + BENZILPENICILINA-BENZATINA (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Varfarina + benzilpenicilina: os antibióticos podem alterar o INR (flora intestinal e enzimas). Monitorizar o INR.',
  summary_pro_en = 'Warfarin + benzylpenicillin: antibiotics may alter INR (gut flora and enzymes). Monitor INR.',
  explanation_pt = 'O rótulo da varfarina identifica os antibióticos, incluindo as penicilinas, como fármacos que podem alterar o INR em doentes anticoagulados. O mecanismo é múltiplo: redução da flora intestinal produtora de vitamina K, inibição metabólica, e a própria doença infeciosa que altera o estado de coagulação. Com a benzilpenicilina-benzatina (injeção IM de ação prolongada, ex.: profilaxia de febre reumática), o efeito sobre o INR pode ser menos previsível e mais tardio. Recomenda-se monitorizar o INR durante e após o tratamento antibiótico, vigiar sinais hemorrágicos e ajustar a dose de varfarina conforme os valores.',
  explanation_en = 'The warfarin label identifies antibiotics, including penicillins, as drugs that can alter INR in anticoagulated patients. The mechanism is multiple: reduction of vitamin K-producing gut flora, metabolic inhibition, and the infectious disease itself altering the coagulation state. With benzathine benzylpenicillin (long-acting IM injection, e.g., rheumatic fever prophylaxis), the effect on INR may be less predictable and more delayed. Monitor INR during and after the antibiotic course, watch for bleeding signs and adjust the warfarin dose according to the values.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'));

-- 33/33 — BENZILPENICILINA-BENZATINA + METOTREXATO (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Benzilpenicilina + metotrexato: as penicilinas reduzem a depuração renal do metotrexato — risco de toxicidade.',
  summary_pro_en = 'Benzylpenicillin + methotrexate: penicillins reduce renal methotrexate clearance — risk of toxicity.',
  explanation_pt = 'O rótulo do metotrexato identifica as penicilinas entre os fármacos que podem aumentar as concentrações plasmáticas de metotrexato: as penicilinas inibem a secreção tubular renal do metotrexato, reduzindo a sua depuração e elevando os níveis, com risco de toxicidade (mielossupressão, mucosite, hepatotoxicidade, nefrotoxicidade) — sobretudo com doses altas de metotrexato ou em doentes com função renal comprometida e desidratação. Em doentes a receber metotrexato e benzilpenicilina-benzatina, monitorizar a função renal e os sinais de toxicidade do metotrexato, e considerar a medição dos níveis séricos quando clinicamente indicado.',
  explanation_en = 'The methotrexate label identifies penicillins among the drugs that can increase plasma methotrexate concentrations: penicillins inhibit the renal tubular secretion of methotrexate, reducing its clearance and raising levels, with risk of toxicity (myelosuppression, mucositis, hepatotoxicity, nephrotoxicity) — especially with high-dose methotrexate or in patients with impaired renal function and dehydration. In patients receiving methotrexate and benzathine benzylpenicillin, monitor renal function and signs of methotrexate toxicity, and consider measuring serum levels when clinically indicated.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

-- =====================================================================
-- FIM — 138: 33 explicações (1 critical + 32 moderate)
-- =====================================================================
