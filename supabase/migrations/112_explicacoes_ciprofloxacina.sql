-- =====================================================================
-- 112 — Explicações fármaco-fármaco dos pares moderados da CIPROFLOXACINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 11 pares moderados da ciprofloxacina que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA, EMA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais da ciprofloxacina (fluoroquinolona):
--   1. Prolongamento do QT (classe) — risco aditivo com antimaláricos
--      (arteméter+lumefantrina, diidroartemisinina+piperaquina, mefloquina,
--      quinina), cloroquina, bedaquilina e domperidona;
--   2. Quelação com catiões (ferro, sucralfato) — absorção reduzida;
--   3. Inibição do CYP1A2 (teofilina) e redução da depuração renal do
--      metotrexato.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/11 — ARTEMÉTER + LUMEFANTRINA + CIPROFLOXACINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Arteméter+lumefantrina + ciprofloxacina: ambos prolongam o intervalo QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Artemether+lumefantrine + ciprofloxacin: both prolong the QT interval. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'Tanto a combinação arteméter+lumefantrina como a ciprofloxacina podem prolongar o intervalo QT, e a associação soma o risco de arritmias ventriculares, incluindo torsade de pointes. O risco é maior em doentes com QT longo congénito, hipocaliemia, bradicardia, doença cardíaca ou com outros fármacos que prolonguem o QT. Sempre que possível, evitar a associação; se inevitável (malária em doente que necessita de antibiótico), monitorizar o ECG e os eletrólitos, corrigir hipocaliemia/hipomagnesemia e usar a menor duração possível de ciprofloxacina.',
  explanation_en = 'Both the artemether+lumefantrine combination and ciprofloxacin can prolong the QT interval, and the combination adds up the risk of ventricular arrhythmias, including torsade de pointes. The risk is higher in patients with congenital long QT, hypokalaemia, bradycardia, cardiac disease or taking other QT-prolonging drugs. Whenever possible, avoid the combination; if unavoidable (malaria in a patient needing an antibiotic), monitor the ECG and electrolytes, correct hypokalaemia/hypomagnesaemia and use the shortest possible ciprofloxacin course.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 2/11 — BEDAQUILINA + CIPROFLOXACINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Bedaquilina + ciprofloxacina: risco aditivo de prolongamento do QT. Evitar; se inevitável, monitorizar ECG.',
  summary_pro_en = 'Bedaquiline + ciprofloxacin: additive risk of QT prolongation. Avoid; if unavoidable, monitor the ECG.',
  explanation_pt = 'A bedaquilina, usada na tuberculose multirresistente, prolonga o intervalo QT de forma dose-dependente, e a ciprofloxacina acrescenta o mesmo efeito da classe das fluoroquinolonas. A associação aumenta o risco de torsade de pointes, sobretudo em doentes com fatores de risco (QT longo, hipocaliemia, insuficiência renal, outros fármacos QT-prolongantes). O rótulo da bedaquilina desaconselha a coadministração com fármacos que prolonguem o QT. Na prática, preferir um antibiótico sem efeito no QT quando possível; se a ciprofloxacina for inevitável, monitorizar o ECG no início e durante o tratamento e corrigir eletrólitos.',
  explanation_en = 'Bedaquiline, used in multidrug-resistant tuberculosis, prolongs the QT interval in a dose-dependent manner, and ciprofloxacin adds the same fluoroquinolone class effect. The combination increases the risk of torsade de pointes, especially in patients with risk factors (long QT, hypokalaemia, renal impairment, other QT-prolonging drugs). The bedaquiline label advises against co-administration with QT-prolonging drugs. In practice, prefer an antibiotic without QT effect when possible; if ciprofloxacin is unavoidable, monitor the ECG at start and during treatment and correct electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 3/11 — CIPROFLOXACINA + CLOROQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + cloroquina: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Ciprofloxacin + chloroquine: additive risk of QT prolongation. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'A cloroquina, antimalárico e imunomodulador, prolonga o intervalo QT e pode causar torsade de pointes; a ciprofloxacina pertence à classe das fluoroquinolonas, também associada a prolongamento do QT. A associação soma o risco, sobretudo em doentes com QT longo, hipocaliemia, doença cardíaca ou com outros fármacos QT-prolongantes. Sempre que possível, evitar a associação ou escolher um antibiótico alternativo; se inevitável, monitorizar o ECG e os eletrólitos e usar a menor duração de tratamento possível.',
  explanation_en = 'Chloroquine, an antimalarial and immunomodulator, prolongs the QT interval and can cause torsade de pointes; ciprofloxacin belongs to the fluoroquinolone class, also associated with QT prolongation. The combination adds up the risk, especially in patients with long QT, hypokalaemia, cardiac disease or taking other QT-prolonging drugs. Whenever possible, avoid the combination or choose an alternative antibiotic; if unavoidable, monitor the ECG and electrolytes and use the shortest treatment duration possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'cloroquina'));

-- 4/11 — CIPROFLOXACINA + DIIDROARTEMISININA-PIPERAQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + diidroartemisinina+piperaquina: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG.',
  summary_pro_en = 'Ciprofloxacin + dihydroartemisinin+piperaquine: additive risk of QT prolongation. Avoid or monitor the ECG.',
  explanation_pt = 'A piperaquina (componente da combinação diidroartemisinina+piperaquina, usada na malária) prolonga significativamente o intervalo QT, e a ciprofloxacina acrescenta o efeito da classe das fluoroquinolonas. A associação aumenta o risco de torsade de pointes, sobretudo em doentes com QT longo, hipocaliemia ou com outros fármacos QT-prolongantes. O EPAR europeu do Eurartesim recomenda precaução com fármacos que prolonguem o QT. Se a combinação for inevitável, monitorizar o ECG e os eletrólitos e evitar outros fatores de risco.',
  explanation_en = 'Piperaquine (component of the dihydroartemisinin+piperaquine combination used in malaria) significantly prolongs the QT interval, and ciprofloxacin adds the fluoroquinolone class effect. The combination increases the risk of torsade de pointes, especially in patients with long QT, hypokalaemia or taking other QT-prolonging drugs. The European EPAR for Eurartesim recommends caution with QT-prolonging drugs. If the combination is unavoidable, monitor the ECG and electrolytes and avoid other risk factors.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'));

-- 5/11 — CIPROFLOXACINA + DOMPERIDONA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + domperidona: risco aditivo de prolongamento do QT. Evitar em doentes de risco.',
  summary_pro_en = 'Ciprofloxacin + domperidone: additive risk of QT prolongation. Avoid in at-risk patients.',
  explanation_pt = 'A domperidona, antiemético procinético, prolonga o intervalo QT e está associada a torsade de pointes, sobretudo em doses elevadas ou com fatores de risco; a ciprofloxacina pertence à classe das fluoroquinolonas com o mesmo efeito. A associação soma o risco de arritmias ventriculares, particularmente em idosos, doentes com doença cardíaca, hipocaliemia ou com outros fármacos QT-prolongantes. Sempre que possível, escolher um antibiótico sem efeito no QT ou um antiemético alternativo; se inevitável, monitorizar o ECG e os eletrólitos.',
  explanation_en = 'Domperidone, a prokinetic antiemetic, prolongs the QT interval and is associated with torsade de pointes, especially at high doses or with risk factors; ciprofloxacin belongs to the fluoroquinolone class with the same effect. The combination adds up the risk of ventricular arrhythmias, particularly in the elderly, patients with cardiac disease, hypokalaemia or taking other QT-prolonging drugs. Whenever possible, choose an antibiotic without QT effect or an alternative antiemetic; if unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'domperidona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'domperidona'));

-- 6/11 — CIPROFLOXACINA + FERRO (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + ferro: os catiões de ferro quelam a ciprofloxacina e reduzem a absorção. Administrar 2 horas antes ou 6 horas depois do ferro.',
  summary_pro_en = 'Ciprofloxacin + iron: iron cations chelate ciprofloxacin and reduce absorption. Administer 2 hours before or 6 hours after iron.',
  explanation_pt = 'Os sais de ferro (ferroso/ferroso fumarato, etc.) libertam catiões divalentes que quelam a ciprofloxacina no trato gastrointestinal, reduzindo a sua biodisponibilidade oral e comprometendo potencialmente o tratamento antibacteriano. O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois de suplementos de ferro (o mesmo se aplica a antiácidos, cálcio e zinco). Esta precaução é especialmente relevante em doentes com anemia a fazer suplementação durante um antibiótico — verificar os horários na prescrição.',
  explanation_en = 'Iron salts (ferrous, ferrous fumarate, etc.) release divalent cations that chelate ciprofloxacin in the gastrointestinal tract, reducing its oral bioavailability and potentially compromising antibacterial treatment. The ciprofloxacin label recommends administering the antibiotic 2 hours before or 6 hours after iron supplements (the same applies to antacids, calcium and zinc). This precaution is especially relevant in anaemic patients taking iron supplements during an antibiotic — check the schedules at prescription.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'));

-- 7/11 — CIPROFLOXACINA + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + mefloquina: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Ciprofloxacin + mefloquine: additive risk of QT prolongation. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'A mefloquina, usada na profilaxia e tratamento da malária, prolonga o intervalo QT e pode causar arritmias; a ciprofloxacina acrescenta o efeito da classe das fluoroquinolonas. A associação soma o risco de torsade de pointes, sobretudo em doentes com QT longo, hipocaliemia, bradicardia ou com outros fármacos QT-prolongantes. Sempre que possível, evitar a associação ou escolher um antibiótico alternativo; se inevitável, monitorizar o ECG e os eletrólitos e usar a menor duração de tratamento possível.',
  explanation_en = 'Mefloquine, used for malaria prophylaxis and treatment, prolongs the QT interval and can cause arrhythmias; ciprofloxacin adds the fluoroquinolone class effect. The combination adds up the risk of torsade de pointes, especially in patients with long QT, hypokalaemia, bradycardia or taking other QT-prolonging drugs. Whenever possible, avoid the combination or choose an alternative antibiotic; if unavoidable, monitor the ECG and electrolytes and use the shortest treatment duration possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 8/11 — CIPROFLOXACINA + METOTREXATO (redução da depuração renal do metotrexato)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + metotrexato: o antibiótico pode reduzir a depuração renal do metotrexato e aumentar a toxicidade. Vigiar de perto.',
  summary_pro_en = 'Ciprofloxacin + methotrexate: the antibiotic can reduce renal methotrexate clearance and increase toxicity. Monitor closely.',
  explanation_pt = 'O metotrexato é eliminado maioritariamente por secreção tubular renal, e as penicilinas e, sobretudo, os AINEs e alguns antibióticos como a ciprofloxacina podem reduzir essa depuração (por competição no túbulo renal), aumentando as concentrações do metotrexato e o risco de mielossupressão, mucosite e nefrotoxicidade. O risco é maior com doses elevadas de metotrexato (quimioterapia) — onde a associação deve ser evitada — e com doses baixas (artrite reumatoide) deve vigiar-se hemograma, função renal e mucosite, sobretudo em idosos.',
  explanation_en = 'Methotrexate is eliminated mainly by renal tubular secretion, and penicillins and, above all, NSAIDs and some antibiotics such as ciprofloxacin can reduce that clearance (by competition in the renal tubule), raising methotrexate concentrations and the risk of myelosuppression, mucositis and nephrotoxicity. The risk is higher with high-dose methotrexate (chemotherapy) — where the combination should be avoided — and with low doses (rheumatoid arthritis) blood count, renal function and mucositis should be monitored, especially in the elderly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

-- 9/11 — CIPROFLOXACINA + QUININA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + quinina: risco aditivo de prolongamento do QT. Evitar ou vigiar ECG em doentes de risco.',
  summary_pro_en = 'Ciprofloxacin + quinine: additive risk of QT prolongation. Avoid or monitor the ECG in at-risk patients.',
  explanation_pt = 'A quinina, usada na malária grave e em cãibras, prolonga o intervalo QT e pode causar torsade de pointes, sobretudo em doses elevadas ou com hipocaliemia; a ciprofloxacina acrescenta o efeito da classe das fluoroquinolonas. A associação soma o risco de arritmias ventriculares, particularmente em doentes com QT longo, doença cardíaca ou com outros fármacos QT-prolongantes. Sempre que possível, evitar a associação ou escolher um antibiótico alternativo; se inevitável, monitorizar o ECG e os eletrólitos.',
  explanation_en = 'Quinine, used in severe malaria and cramps, prolongs the QT interval and can cause torsade de pointes, especially at high doses or with hypokalaemia; ciprofloxacin adds the fluoroquinolone class effect. The combination adds up the risk of ventricular arrhythmias, particularly in patients with long QT, cardiac disease or taking other QT-prolonging drugs. Whenever possible, avoid the combination or choose an alternative antibiotic; if unavoidable, monitor the ECG and electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'quinina'));

-- 10/11 — CIPROFLOXACINA + SUCRALFATO (quelação — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + sucralfato: o sucralfato reduz marcadamente a absorção da ciprofloxacina. Administrar 2 horas antes ou 6 horas depois.',
  summary_pro_en = 'Ciprofloxacin + sucralfate: sucralfate markedly reduces ciprofloxacin absorption. Administer 2 hours before or 6 hours after.',
  explanation_pt = 'O sucralfato, citoprotetor gástrico, forma quelatos com as fluoroquinolonas no trato gastrointestinal e reduz a absorção oral da ciprofloxacina de forma clinicamente significativa (o rótulo do sucralfato documenta redução da biodisponibilidade das fluoroquinolonas; reduções de até 90% são descritas para os antiácidos de magnésio/alumínio no rótulo da ciprofloxacina). O rótulo da ciprofloxacina recomenda administrar o antibiótico 2 horas antes ou 6 horas depois do sucralfato (o mesmo se aplica a antiácidos, ferro, cálcio e zinco). Esta precaução é importante em doentes com úlcera a fazer sucralfato que necessitam de antibiótico — verificar os horários na prescrição.',
  explanation_en = 'Sucralfate, a gastric cytoprotective agent, forms chelates with fluoroquinolones in the gastrointestinal tract and reduces ciprofloxacin oral absorption in a clinically significant way (the sucralfate label documents reduced fluoroquinolone bioavailability; reductions of up to 90% are described for magnesium/aluminium antacids in the ciprofloxacin label). The ciprofloxacin label recommends administering the antibiotic 2 hours before or 6 hours after sucralfate (the same applies to antacids, iron, calcium and zinc). This precaution is important in ulcer patients taking sucralfate who need an antibiotic — check the schedules at prescription.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'sucralfato'));

-- 11/11 — CIPROFLOXACINA + TEOFILINA (inibição do CYP1A2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciprofloxacina + teofilina: a ciprofloxacina inibe o CYP1A2 e pode elevar a teofilina (~40%), com risco de toxicidade. Monitorizar níveis.',
  summary_pro_en = 'Ciprofloxacin + theophylline: ciprofloxacin inhibits CYP1A2 and can raise theophylline (~40%), with a risk of toxicity. Monitor levels.',
  explanation_pt = 'A ciprofloxacina é um inibidor do CYP1A2, a enzima que metaboliza a teofilina, podendo aumentar as concentrações séricas da teofilina em cerca de 40% (conforme o rótulo da teofilina) e precipitar toxicidade (náuseas, vómitos, taquicardia, tremores, convulsões, arritmias). O rótulo da teofilina recomenda monitorizar os níveis séricos e ajustar a dose quando se inicia ou suspende a ciprofloxacina, e vigiar sinais de toxicidade (o rótulo da ciprofloxacina relata reações graves e fatais com a associação). A interação é particularmente relevante em doentes com DPOC/asma em uso crónico de teofilina.',
  explanation_en = 'Ciprofloxacin is an inhibitor of CYP1A2, the enzyme that metabolises theophylline, and can raise theophylline serum concentrations by about 40% (per the theophylline label) and precipitate toxicity (nausea, vomiting, tachycardia, tremor, seizures, arrhythmias). The theophylline label recommends monitoring serum levels and adjusting the dose when ciprofloxacin is started or stopped, and watching for signs of toxicity (the ciprofloxacin label reports serious and fatal reactions with the combination). The interaction is particularly relevant in COPD/asthma patients on chronic theophylline.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'));
