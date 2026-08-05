-- 061: Seed das novas dimensões de interações (Fluxo 2)
-- Conteúdo clínico autorado PT/EN para 5 fármacos piloto nas 3 dimensões:
--   drug_food_interactions    (alimento/bebida)
--   drug_disease_interactions (doença/condição)
--   drug_pregnancy_info       (gestação/lactação, 1:1)
--
-- Fonte canónica: EMC-UK (MHRA) SmPC — corroborada por Health Canada Product
-- Monograph quando o EMC-UK não documenta (ver docs/INTERACOES_FLUXO_PESQUISA.md).
-- URLs verificadas (HTTP 200) em 2026-08. Depende da migração 060 (schema).
-- Reexecução segura: ON CONFLICT ... DO NOTHING.
--
-- NOTA PARA O UTILIZADOR: aplicar manualmente no Supabase (o agente nunca executa).

-- ============================================================
-- 1. Alimento / Bebida (drug_food_interactions)
-- ============================================================

INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ---------- Varfarina ----------
  ('warfarina', 'vitamina_k', 'Vitamina K (alimentar)', 'Vitamin K (dietary)', 'moderate',
   'Alimentos ricos em vitamina K (brócolos, couves, espinafres, fígado) antagonizam o efeito da varfarina na síntese dos fatores de coagulação dependentes da vitamina K, alterando o INR conforme varia a ingestão alimentar.',
   'Foods rich in vitamin K (broccoli, leafy greens, spinach, liver) counteract warfarin''s effect on vitamin K-dependent clotting factor synthesis, shifting the INR as dietary intake varies.',
   'Manter uma ingestão alimentar de vitamina K estável e consistente; procurar orientação profissional antes de alterações alimentares significativas; monitorizar o INR após qualquer mudança.',
   'Keep dietary vitamin K intake stable and consistent; seek professional guidance before significant dietary changes; monitor INR after any change.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 1),
  ('warfarina', 'cranberry', 'Cranberry (oxicoco)', 'Cranberry', 'moderate',
   'Casos descritos associam o consumo de cranberry ao aumento do INR e ao risco hemorrágico; o mecanismo não está totalmente esclarecido.',
   'Case reports associate cranberry intake with INR elevation and bleeding risk; the mechanism is not fully established.',
   'Recomendar a evicção de produtos de cranberry; se o consumo regular for mantido, reforçar a monitorização do INR.',
   'Advise avoiding cranberry products; if regular intake continues, reinforce INR monitoring.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 2),
  ('warfarina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O consumo agudo elevado de álcool pode inibir o metabolismo da varfarina e aumentar o INR, enquanto o consumo crónico elevado pode induzir o metabolismo e reduzir o efeito anticoagulante.',
   'Acute heavy alcohol intake may inhibit warfarin metabolism and raise INR, while chronic heavy intake may induce metabolism and reduce the anticoagulant effect.',
   'Aconselhar contra o consumo excessivo ou em padrão binge; o consumo moderado é aceitável desde que estável, com monitorização do INR se os hábitos mudarem.',
   'Advise against heavy or binge drinking; moderate intake is acceptable if consistent, with INR monitoring if drinking habits change.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 3),

  -- ---------- Atorvastatina ----------
  ('atorvastatina', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'A atorvastatina é metabolizada pelo CYP3A4; o sumo de toranja inibe esta enzima e aumenta a exposição ao fármaco (grandes quantidades podem aumentar a AUC até cerca de 2,5 vezes).',
   'Atorvastatin is metabolised by CYP3A4; grapefruit juice inhibits this enzyme and increases drug exposure (large amounts may raise AUC by up to around 2.5-fold).',
   'Evitar grandes quantidades de sumo de toranja durante o tratamento; pequenas quantidades ocasionais têm efeito limitado.',
   'Avoid large amounts of grapefruit juice during treatment; occasional small amounts have a limited effect.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 1),
  ('atorvastatina', 'alcool', 'Álcool (consumo substancial)', 'Alcohol (substantial intake)', 'moderate',
   'O consumo substancial de álcool, sobretudo com doença hepática prévia, aumenta o risco de elevação das transaminases e é fator predisponente de rabdomiólise.',
   'Substantial alcohol intake, especially with pre-existing liver disease, increases the risk of transaminase elevation and is a predisposing factor for rhabdomyolysis.',
   'Usar com precaução em doentes com consumo substancial de álcool; avaliar enzimas hepáticas e CK antes do início e periodicamente.',
   'Use with caution in patients with substantial alcohol intake; check liver enzymes and CK before initiation and periodically.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 2),

  -- ---------- Carbamazepina ----------
  ('carbamazepina', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O sumo de toranja inibe o CYP3A4, reduz a metabolização da carbamazepina e aumenta as concentrações plasmáticas, elevando o risco de efeitos adversos.',
   'Grapefruit juice inhibits CYP3A4, reduces carbamazepine metabolism and raises plasma concentrations, increasing the risk of adverse effects.',
   'Recomendar a evicção do sumo de toranja; se consumido, monitorizar as concentrações plasmáticas e os sinais de toxicidade (tonturas, sonolência, ataxia, diplopia).',
   'Advise avoiding grapefruit juice; if consumed, monitor plasma levels and signs of toxicity (dizziness, drowsiness, ataxia, diplopia).',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 1),

  -- ---------- Levotiroxina ----------
  ('levotiroxina', 'soja', 'Soja', 'Soy', 'moderate',
   'A farinha de soja (incluindo fórmulas infantis à base de soja) e outros alimentos podem reduzir a absorção gastrointestinal da levotiroxina, diminuindo a exposição à hormona tiroideia.',
   'Soybean flour (including soy-based infant formulas) and other foods can reduce gastrointestinal absorption of levothyroxine, lowering thyroid hormone exposure.',
   'Administrar a levotiroxina em jejum, separada de alimentos ou fórmulas à base de soja; nos lactentes, dispersar o comprimido em água ou numa fórmula sem soja.',
   'Give levothyroxine on an empty stomach, separated from soy-based foods or formulas; in infants, disperse the tablet in water or a soy-free formula.',
   'Health Canada — Monografia do Produto Eltroxin (levotiroxina): https://pdf.hres.ca/dpd_pm/00071854.PDF',
   'Health Canada — Eltroxin (levothyroxine) Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF', 1),
  ('levotiroxina', 'fibra_alimentar', 'Fibra alimentar', 'Dietary fibre', 'moderate',
   'A fibra alimentar reduz a absorção gastrointestinal da levotiroxina, podendo diminuir os níveis séricos da hormona e exigir ajuste de dose.',
   'Dietary fibre reduces gastrointestinal absorption of levothyroxine, potentially lowering serum hormone levels and requiring dose adjustment.',
   'Manter uma rotina consistente de toma em jejum, separando a dose de refeições ricas em fibra para evitar flutuações da função tiroideia.',
   'Keep a consistent empty-stomach routine, separating the dose from high-fibre meals to avoid thyroid function fluctuations.',
   'Health Canada — Monografia do Produto Eltroxin (levotiroxina): https://pdf.hres.ca/dpd_pm/00071854.PDF',
   'Health Canada — Eltroxin (levothyroxine) Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF', 2),
  ('levotiroxina', 'toma_em_jejum', 'Toma em jejum', 'Empty-stomach intake', 'moderate',
   'Alimentos e bebidas alteram significativamente a absorção da levotiroxina; a toma em jejum reduz a variabilidade da absorção e dos níveis hormonais.',
   'Food and drink significantly alter levothyroxine absorption; empty-stomach intake reduces variability in absorption and hormone levels.',
   'Administrar uma dose diária em jejum, cerca de 30 a 60 minutos antes do pequeno-almoço, sempre à mesma hora, e separar pelo menos 4 horas de fármacos que interferem na absorção.',
   'Give a single daily dose on an empty stomach, about 30 to 60 minutes before breakfast, at the same time, and separate by at least 4 hours from drugs that interfere with absorption.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc — corroboração: Health Canada Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc — corroborated by Health Canada Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF', 3),

  -- ---------- Metformina ----------
  ('metformina', 'alcool', 'Álcool (excesso)', 'Alcohol (excess)', 'critical',
   'A intoxicação alcoólica aguda aumenta o risco de acidose láctica, especialmente em jejum, desnutrição ou insuficiência hepática; o alcoolismo é contraindicação.',
   'Acute alcohol intoxication increases the risk of lactic acidosis, especially during fasting, malnutrition or hepatic impairment; alcoholism is a contraindication.',
   'Evitar o consumo excessivo de álcool e qualquer estado de intoxicação alcoólica aguda durante o tratamento com metformina.',
   'Avoid excessive alcohol intake and any acute alcohol intoxication during metformin treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
       mechanism_pt, mechanism_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- ============================================================
-- 2. Doença / Condição (drug_disease_interactions)
-- ============================================================

INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ---------- Varfarina ----------
  ('warfarina', 'avc_hemorragico', 'AVC hemorrágico', 'Haemorrhagic stroke', 'contraindication', 'critical',
   'A varfarina é contraindicada em doentes com hemorragia cerebral, pois o risco de novo sangramento excede qualquer benefício anticoagulante.',
   'Warfarin is contraindicated in patients with cerebral haemorrhage because the risk of further bleeding outweighs any anticoagulant benefit.',
   'Não utilizar varfarina após AVC hemorrágico; após AVC isquémico, a reintrodução deve ser ponderada com base no tamanho do enfarte e no controlo tensional.',
   'Do not use warfarin after haemorrhagic stroke; after ischaemic stroke, reintroduction must balance infarct size and blood pressure control.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 1),
  ('warfarina', 'hemorragia_significativa', 'Hemorragia clinicamente significativa', 'Clinically significant bleeding', 'contraindication', 'critical',
   'Qualquer situação de hemorragia clinicamente significativa, ou condição em que o risco hemorrágico exceda o benefício clínico, contraindica a anticoagulação.',
   'Any clinically significant bleeding, or a condition where bleeding risk outweighs clinical benefit, contraindicates anticoagulation.',
   'Não iniciar varfarina em doentes com hemorragia ativa ou risco hemorrágico elevado; reavaliar periodicamente a necessidade de anticoagulação.',
   'Do not start warfarin in actively bleeding patients or those at high bleeding risk; reassess the need for anticoagulation regularly.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 2),
  ('warfarina', 'deficiencia_proteina_c', 'Défice de proteína C ou S', 'Protein C or S deficiency', 'precaution', 'moderate',
   'O défice de proteína C ou S predispõe a necrose cutânea durante o início do tratamento com varfarina.',
   'Protein C or S deficiency predisposes to skin necrosis during warfarin initiation.',
   'Introduzir a varfarina sem dose de ataque nestes doentes e com monitorização próxima.',
   'Start warfarin without a loading dose in these patients, with close monitoring.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 3),
  ('warfarina', 'ulcera_peptica_ativa', 'Úlcera péptica ativa', 'Active peptic ulceration', 'precaution', 'moderate',
   'A úlcera péptica ativa confere risco elevado de hemorragia gastrointestinal grave durante a anticoagulação.',
   'Active peptic ulceration carries a high risk of serious gastrointestinal bleeding during anticoagulation.',
   'Ponderar o risco-benefício, educar o doente para os sinais de hemorragia e manter o INR dentro do intervalo terapêutico.',
   'Weigh risk-benefit, educate the patient on bleeding signs and keep INR within the therapeutic range.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc', 4),

  -- ---------- Atorvastatina ----------
  ('atorvastatina', 'doenca_hepatica_ativa', 'Doença hepática ativa', 'Active liver disease', 'contraindication', 'critical',
   'A atorvastatina está contraindicada na doença hepática ativa ou em elevações persistentes das transaminases acima de 3 vezes o limite superior do normal.',
   'Atorvastatin is contraindicated in active liver disease or persistent transaminase elevations above 3 times the upper limit of normal.',
   'Não iniciar o fármaco nestas situações; se a elevação se mantiver durante o tratamento, reduzir a dose ou suspender.',
   'Do not start the drug in these cases; if elevation persists during therapy, reduce the dose or discontinue.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 1),
  ('atorvastatina', 'historia_doenca_hepatica', 'História de doença hepática', 'History of liver disease', 'precaution', 'moderate',
   'A história de doença hepática e o consumo substancial de álcool aumentam o risco de elevação das enzimas hepáticas e de rabdomiólise.',
   'A history of liver disease and substantial alcohol intake increase the risk of liver enzyme elevation and rhabdomyolysis.',
   'Monitorizar a função hepática antes e durante o tratamento e medir a CK antes de iniciar.',
   'Monitor liver function before and during treatment and measure CK before starting.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 2),
  ('atorvastatina', 'avc_hemorragico_previo', 'AVC hemorrágico prévio', 'Prior haemorrhagic stroke', 'precaution', 'moderate',
   'No estudo SPARCL, a atorvastatina 80 mg associou-se a maior incidência de AVC hemorrágico, sobretudo em doentes com AVC hemorrágico ou enfarte lacunar prévios.',
   'In the SPARCL trial, atorvastatin 80 mg was associated with a higher incidence of haemorrhagic stroke, particularly in patients with prior haemorrhagic stroke or lacunar infarct.',
   'Ponderar cuidadosamente o risco-benefício antes de iniciar atorvastatina 80 mg nestes doentes.',
   'Carefully weigh risk-benefit before starting atorvastatin 80 mg in these patients.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 3),
  ('atorvastatina', 'fatores_rabdomiolise', 'Fatores predisponentes de rabdomiólise', 'Predisposing factors for rhabdomyolysis', 'precaution', 'moderate',
   'A insuficiência renal, o hipotiroidismo, as miopatias hereditárias, a idade superior a 70 anos e a toxicidade muscular prévia com estatinas predispõem à rabdomiólise.',
   'Renal impairment, hypothyroidism, hereditary muscle disorders, age over 70 and prior statin muscle toxicity predispose to rhabdomyolysis.',
   'Medir a CK antes de iniciar; orientar o doente a reportar dor, cãibras ou fraqueza muscular e suspender o fármaco em caso de elevação clinicamente relevante.',
   'Measure CK before starting; instruct the patient to report muscle pain, cramps or weakness and stop the drug if a clinically significant elevation occurs.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc', 4),

  -- ---------- Carbamazepina ----------
  ('carbamazepina', 'bloqueio_av', 'Bloqueio auriculoventricular', 'Atrioventricular block', 'contraindication', 'critical',
   'A carbamazepina tem efeitos na condução cardíaca; o bloqueio auriculoventricular é uma contraindicação absoluta.',
   'Carbamazepine affects cardiac conduction; atrioventricular block is an absolute contraindication.',
   'Não prescrever a doentes com bloqueio AV; considerar terapêutica antiepilética alternativa.',
   'Do not prescribe to patients with AV block; consider alternative antiepileptic therapy.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 1),
  ('carbamazepina', 'depressao_medula_ossea', 'Depressão da medula óssea (história)', 'History of bone marrow depression', 'contraindication', 'critical',
   'A carbamazepina está contraindicada em doentes com história de depressão da medula óssea; podem ocorrer agranulocitose e anemia aplástica.',
   'Carbamazepine is contraindicated in patients with a history of bone marrow depression; agranulocytosis and aplastic anaemia may occur.',
   'Não utilizar nestes doentes; durante o tratamento, vigiar o hemograma e suspender em caso de leucopenia grave ou progressiva.',
   'Do not use in these patients; during therapy, monitor the blood count and stop if severe or progressive leucopenia develops.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 2),
  ('carbamazepina', 'porfiria_hepatica', 'Porfiria hepática', 'Hepatic porphyria', 'contraindication', 'critical',
   'As porfirias hepáticas (intermitente aguda, variegata e cutânea tardia) contraindicam a carbamazepina.',
   'Hepatic porphyrias (acute intermittent, variegate and cutanea tarda) contraindicate carbamazepine.',
   'Não prescrever a doentes com história de porfiria hepática.',
   'Do not prescribe to patients with a history of hepatic porphyria.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 3),
  ('carbamazepina', 'hiponatremia', 'Hiponatremia / baixa de sódio', 'Hyponatraemia / low sodium', 'precaution', 'moderate',
   'A carbamazepina pode causar hiponatremia, com risco aumentado em doentes com doença renal, utilização de diuréticos ou em idosos.',
   'Carbamazepine can cause hyponatraemia, with increased risk in renal disease, diuretic use or elderly patients.',
   'Medir o sódio sérico antes do início, às 2 semanas e depois mensalmente nos primeiros meses; instituir restrição hídrica se ocorrer hiponatremia.',
   'Check serum sodium before start, at 2 weeks and then monthly for the first months; institute fluid restriction if hyponatraemia occurs.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 4),
  ('carbamazepina', 'hla_b1502', 'Alelo HLA-B*1502 (populações asiáticas)', 'HLA-B*1502 carrier (Asian populations)', 'precaution', 'moderate',
   'O alelo HLA-B*1502 associa-se fortemente ao risco de síndrome de Stevens-Johnson com carbamazepina em populações han chinesas, tailandesas e malaias.',
   'The HLA-B*1502 allele is strongly associated with Stevens-Johnson syndrome risk with carbamazepine in Han Chinese, Thai and Malay populations.',
   'Rastrear o alelo antes do início sempre que possível; se positivo, não iniciar o fármaco salvo ausência de alternativa.',
   'Screen for the allele before starting whenever possible; if positive, do not start the drug unless no alternative exists.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc', 5),

  -- ---------- Levotiroxina ----------
  ('levotiroxina', 'tireotoxicose', 'Tireotoxicose não tratada', 'Untreated thyrotoxicosis', 'contraindication', 'critical',
   'A levotiroxina está contraindicada na tireotoxicose não tratada, pois pode agravar o estado hipermetabólico.',
   'Levothyroxine is contraindicated in untreated thyrotoxicosis, as it can worsen the hypermetabolic state.',
   'Não iniciar a terapêutica em doentes com TSH suprimido não tratado; confirmar o estado tiroideu antes do início.',
   'Do not start therapy in patients with untreated suppressed TSH; confirm thyroid status before starting.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc', 1),
  ('levotiroxina', 'insuficiencia_adrenal', 'Insuficiência suprarrenal não corrigida', 'Uncorrected adrenal insufficiency', 'contraindication', 'critical',
   'As hormonas tiroideias aumentam a depuração metabólica dos glucocorticoides e podem precipitar crise adrenal na insuficiência suprarrenal não corrigida.',
   'Thyroid hormones increase the metabolic clearance of glucocorticoids and may precipitate adrenal crisis in uncorrected adrenal insufficiency.',
   'Corrigir a insuficiência suprarrenal e iniciar o corticoide antes da levotiroxina, sobretudo no hipopituitarismo.',
   'Correct adrenal insufficiency and start corticosteroid before levothyroxine, especially in hypopituitarism.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc', 2),
  ('levotiroxina', 'enfarte_agudo_miocardio', 'Enfarte agudo do miocárdio', 'Acute myocardial infarction', 'contraindication', 'critical',
   'A hormona tiroideia aumenta o trabalho cardíaco; a levotiroxina está contraindicada durante o enfarte agudo do miocárdio, miocardite e pancardite agudas.',
   'Thyroid hormone increases cardiac work; levothyroxine is contraindicated during acute myocardial infarction, myocarditis and acute pancarditis.',
   'Não iniciar na fase aguda destas condições; estabilizar o estado cardíaco antes do tratamento.',
   'Do not start during the acute phase of these conditions; stabilise cardiac status before treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc', 3),
  ('levotiroxina', 'doenca_cardiovascular', 'Doença cardiovascular', 'Cardiovascular disease', 'precaution', 'moderate',
   'O excesso de tratamento pode agravar angina ou arritmias; a doença cardíaca oculta é mais provável nos idosos.',
   'Overtreatment can worsen angina or arrhythmias; occult cardiac disease is more likely in the elderly.',
   'Iniciar com doses baixas e titular gradualmente, com ECG nos doentes de risco e monitorização do TSH.',
   'Start at low doses and titrate gradually, with ECG in at-risk patients and TSH monitoring.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc', 4),

  -- ---------- Metformina ----------
  ('metformina', 'insuficiencia_renal_grave', 'Insuficiência renal grave', 'Severe renal impairment', 'contraindication', 'critical',
   'A metformina está contraindicada quando a TFG < 30 mL/min; a acumulação do fármaco aumenta o risco de acidose láctica.',
   'Metformin is contraindicated when eGFR < 30 mL/min; drug accumulation increases the risk of lactic acidosis.',
   'Não prescrever com TFG < 30 mL/min; ajustar a dose entre 30 e 89 mL/min e suspender temporariamente em situações agudas que alterem a função renal.',
   'Do not prescribe when eGFR < 30 mL/min; adjust the dose between 30 and 89 mL/min and stop temporarily in acute conditions altering renal function.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 1),
  ('metformina', 'acidose_metabolica', 'Acidose metabólica aguda', 'Acute metabolic acidosis', 'contraindication', 'critical',
   'A acidose metabólica aguda (láctica, cetoacidose diabética) e o pré-coma diabético são contraindicações absolutas.',
   'Acute metabolic acidosis (lactic, diabetic ketoacidosis) and diabetic pre-coma are absolute contraindications.',
   'Não utilizar em doentes com acidose; se houver suspeita de acidose láctica, suspender e procurar avaliação médica urgente.',
   'Do not use in patients with acidosis; if lactic acidosis is suspected, stop and seek urgent medical evaluation.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 2),
  ('metformina', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic insufficiency', 'contraindication', 'critical',
   'A insuficiência hepática reduz a depuração do lactato e predispõe à acidose láctica.',
   'Hepatic insufficiency reduces lactate clearance and predisposes to lactic acidosis.',
   'Evitar a metformina em doentes com insuficiência hepática ou alcoolismo.',
   'Avoid metformin in patients with hepatic insufficiency or alcoholism.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 3),
  ('metformina', 'hipoxia_tecidual', 'Condições com hipóxia tecidual', 'Conditions causing tissue hypoxia', 'contraindication', 'critical',
   'A insuficiência cardíaca descompensada, a insuficiência respiratória, o enfarte do miocárdio recente e o choque aumentam o risco de acidose láctica.',
   'Decompensated heart failure, respiratory failure, recent myocardial infarction and shock increase the risk of lactic acidosis.',
   'Não iniciar durante estados hipóxicos agudos; suspender durante esses episódios e reavaliar após estabilização.',
   'Do not start during acute hypoxic states; stop during such episodes and reassess after stabilisation.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 4),
  ('metformina', 'melas_midd', 'Doenças mitocondriais (MELAS, MIDD)', 'Mitochondrial diseases (MELAS, MIDD)', 'precaution', 'moderate',
   'Em doentes com MELAS ou MIDD, a metformina não é recomendada pelo risco de exacerbação da acidose láctica e de complicações neurológicas.',
   'In patients with MELAS or MIDD, metformin is not recommended due to the risk of worsening lactic acidosis and neurological complications.',
   'Evitar a metformina nestes doentes; suspender e avaliar de imediato se surgirem sinais sugestivos.',
   'Avoid metformin in these patients; stop and evaluate promptly if suggestive signs appear.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 5),
  ('metformina', 'contraste_iodado', 'Contraste iodado intravascular', 'Intravascular iodinated contrast', 'precaution', 'moderate',
   'O contraste iodado pode causar nefropatia induzida por contraste, com acumulação da metformina e risco de acidose láctica.',
   'Iodinated contrast can cause contrast-induced nephropathy, with metformin accumulation and lactic acidosis risk.',
   'Suspender a metformina no momento do exame e retomar apenas 48 horas depois, se a função renal se mantiver estável.',
   'Stop metformin at the time of the scan and resume only 48 hours later if renal function remains stable.',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc', 6)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- ============================================================
-- 3. Gestação / Lactação (drug_pregnancy_info, 1:1 por fármaco)
-- ============================================================

INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('warfarina', 'contraindicated',
   'A varfarina é teratogénica (síndrome do feto varfarínico no 1.º trimestre) e está associada a hemorragia fetal ou morte fetal no 3.º trimestre.',
   'Warfarin is teratogenic (fetal warfarin syndrome in the 1st trimester) and is associated with fetal bleeding or fetal death in the 3rd trimester.',
   'Contraindicada no 1.º e no 3.º trimestres; está também contraindicada nas 48 horas após o parto.',
   'Contraindicated in the 1st and 3rd trimesters; also contraindicated within 48 hours after delivery.',
   'A varfarina é excretada no leite em pequenas quantidades e, em doses terapêuticas, não demonstrou efeitos adversos no lactente.',
   'Warfarin is excreted into breast milk in small amounts and, at therapeutic doses, has shown no adverse effects in the infant.',
   'Mulheres em idade fértil devem utilizar contraceção eficaz durante o tratamento.',
   'Women of child-bearing age must use effective contraception during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Varfarina: https://www.medicines.org.uk/emc/product/2803/smpc',
   'EMC-UK (MHRA) — approved Warfarin SmPC: https://www.medicines.org.uk/emc/product/2803/smpc'),

  ('atorvastatina', 'contraindicated',
   'Contraindicada na gravidez: a segurança não está estabelecida e existem relatos de anomalias congénitas após exposição intrauterina às estatinas.',
   'Contraindicated in pregnancy: safety is not established and congenital anomalies have been reported after intrauterine statin exposure.',
   'Suspender o tratamento durante a gravidez ou até se confirmar que a doente não está grávida.',
   'Discontinue treatment during pregnancy or until it is confirmed that the woman is not pregnant.',
   'Contraindicada na amamentação pela possibilidade de reações adversas graves no lactente.',
   'Contraindicated during breastfeeding due to the potential for serious adverse reactions in the infant.',
   'Mulheres em idade fértil devem utilizar medidas contracetivas adequadas durante o tratamento; sem contraceção eficaz, o fármaco está contraindicado.',
   'Women of child-bearing potential must use appropriate contraceptive measures during treatment; without effective contraception, the drug is contraindicated.',
   'EMC-UK (MHRA) — SmPC aprovada Atorvastatina: https://www.medicines.org.uk/emc/product/13672/smpc',
   'EMC-UK (MHRA) — approved Atorvastatin SmPC: https://www.medicines.org.uk/emc/product/13672/smpc'),

  ('carbamazepina', 'caution',
   'A exposição no 1.º trimestre aumenta o risco de malformações major (defeitos do tubo neural, fissuras orofaciais, malformações cardiovasculares), com risco dependente da dose.',
   'First-trimester exposure increases the risk of major malformations (neural tube defects, orofacial clefts, cardiovascular malformations), with a dose-dependent risk.',
   'Utilizar apenas se o benefício exceder claramente o risco, em monoterapia na dose mínima eficaz e com vigilância pré-natal especializada; não suspender abruptamente. Recomenda-se suplementação de ácido fólico antes e durante a gravidez e vitamina K1 no final da gravidez.',
   'Use only if benefit clearly outweighs risk, as monotherapy at the lowest effective dose and with specialised antenatal surveillance; do not stop abruptly. Folate supplementation is recommended before and during pregnancy and vitamin K1 at the end of pregnancy.',
   'A amamentação é possível se os benefícios forem ponderados; observar o lactente quanto a reações adversas, incluindo efeitos hepatobiliares.',
   'Breastfeeding is possible if benefits are weighed; observe the infant for adverse reactions, including hepatobiliary effects.',
   'A carbamazepina induz enzimas e pode falhar a contraceção hormonal; utilizar contraceção altamente eficaz (ex.: DIU) ou métodos complementares, com pelo menos 50 µg de estrogénio se hormonal.',
   'Carbamazepine induces enzymes and can fail hormonal contraception; use highly effective contraception (e.g. IUD) or complementary methods, with at least 50 µg of oestrogen if hormonal.',
   'EMC-UK (MHRA) — SmPC aprovada Carbamazepina: https://www.medicines.org.uk/emc/product/1040/smpc',
   'EMC-UK (MHRA) — approved Carbamazepine SmPC: https://www.medicines.org.uk/emc/product/1040/smpc'),

  ('levotiroxina', 'compatible',
   'Os estudos não demonstraram aumento do risco de malformações fetais; a hipotiroidia materna não tratada associa-se a aborto espontâneo, pré-eclâmpsia e parto prematuro.',
   'Studies have not shown an increased risk of fetal malformations; untreated maternal hypothyroidism is associated with miscarriage, pre-eclampsia and preterm delivery.',
   'Não suspender o tratamento durante a gravidez; monitorizar o TSH cerca de 4 em 4 semanas na primeira metade e pelo menos uma vez entre as 26 e 32 semanas, ajustando a dose.',
   'Do not discontinue treatment during pregnancy; monitor TSH every 4 weeks in the first half and at least once between 26 and 32 weeks, adjusting the dose.',
   'A levotiroxina em doses adequadas é geralmente compatível com a amamentação; quantidades mínimas são excretadas no leite.',
   'Levothyroxine at adequate doses is generally compatible with breastfeeding; minimal amounts are excreted into milk.',
   'Sem dados específicos; manter a monitorização habitual da função tiroideia em mulheres em idade fértil.',
   'No specific data; keep routine thyroid function monitoring in women of child-bearing age.',
   'EMC-UK (MHRA) — SmPC aprovada Levotiroxina: https://www.medicines.org.uk/emc/product/12781/smpc — corroboração: Health Canada Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF',
   'EMC-UK (MHRA) — approved Levothyroxine SmPC: https://www.medicines.org.uk/emc/product/12781/smpc — corroborated by Health Canada Product Monograph: https://pdf.hres.ca/dpd_pm/00071854.PDF'),

  ('metformina', 'caution',
   'Dados extensos (mais de 1000 gravidezes) não indicam aumento do risco de malformações congénitas nem de toxicidade fetal-neonatal com a metformina.',
   'Extensive data (over 1000 pregnancies) indicate no increased risk of congenital malformations or feto-neonatal toxicity with metformin.',
   'O uso pode ser considerado na gravidez e na fase periconcecional como alternativa ou adição à insulina, se clinicamente necessário.',
   'Use can be considered during pregnancy and in the periconceptional phase as an alternative or addition to insulin, if clinically needed.',
   'A metformina é excretada no leite; sem efeitos adversos observados, mas com dados limitados — a amamentação não é recomendada durante o tratamento.',
   'Metformin is excreted into breast milk; no adverse effects observed but data are limited — breastfeeding is not recommended during treatment.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC aprovada Metformina: https://www.medicines.org.uk/emc/product/987/smpc',
   'EMC-UK (MHRA) — approved Metformin SmPC: https://www.medicines.org.uk/emc/product/987/smpc')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
