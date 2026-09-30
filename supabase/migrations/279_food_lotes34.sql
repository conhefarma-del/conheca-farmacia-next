-- =====================================================================
-- 279 — Interações fármaco-alimento (Fluxo 2) para os LOTES 3 e 4
-- ---------------------------------------------------------------------
-- A drug_food_interactions (schema 060, seed 061) tinha zero cobertura
-- para os 19 fármacos dos Lotes 3 (264–266) e 4 (268–270). Pares
-- clinicamente mais relevantes, reutilizando exclusivamente o
-- vocabulário de entity_slug já existente (393 registos).
--
-- Fontes: Prontuário Terapêutico INFARMED (5.1.4 Xantinas — "A clearance
-- da teofilina e da aminofilina é influenciada por alimentos, hábitos
-- tabágicos…" l. 20209; 8.4.1 Insulina; Anexo 6 álcool), fichas do site,
-- EMC-UK SmPC e DailyMed (DDAVP abe23504, gluconato de cálcio 16307c00).
--
-- Nota sobre o exemplo "warfarina-style K para tranexâmico": o ácido
-- tranexâmico não interage com a vitamina K — ambas promovem a
-- coagulação, sem antagonismo. Registado antes o par real e documentado:
-- o álcool (apresenta risco hemorrágico gastrintestinal aditivo).
--
-- Idempotência: ON CONFLICT (drug_id, entity_slug) DO NOTHING.
-- Cobertura: 16 fármacos × 1–3 = 29 pares.
-- Exclusões justificadas no fim.
-- =====================================================================

INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   severity, mechanism_pt, mechanism_en,
   advice_pt, advice_en, source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
       v.severity, v.mechanism_pt, v.mechanism_en,
       v.advice_pt, v.advice_en, v.source_pt, v.source_en,
       v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ------------------------------------------------------------------
  -- INSULINAS × ÁLCOOL — Prontuário 8.4.1 (l. 25973): "preocupação
  -- especial … nos alcoólicos"; álcool inibe a gluconeogénese hepática
  -- e potencia a hipoglicemia.
  -- ------------------------------------------------------------------
  ('insulina-regular', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool inibe a gluconeogénese hepática e potencia a hipoglicemia induzida pela insulina; o risco é maior com o estômago vazio.',
   'Alcohol inhibits hepatic gluconeogenesis and potentiates insulin-induced hypoglycaemia; the risk is highest on an empty stomach.',
   'Evite o álcool, sobretudo em jejum; se consumir, faça-o com alimentos e monitorize a glicemia (ficha do site).',
   'Avoid alcohol, especially while fasting; if consumed, take it with food and monitor blood glucose (site monograph).',
   'Prontuário Terapêutico INFARMED, 8.4.1 Insulinas: "preocupação especial … nos alcoólicos"; ficha do site (evite o álcool).',
   'Prontuário Terapêutico INFARMED, 8.4.1 Insulins: "special concern … alcoholics"; site monograph (avoid alcohol).', 1),
  ('insulina-nph', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool inibe a gluconeogénese hepática e potencia a hipoglicemia noturna induzida pela NPH (insulina de acção intermédia).',
   'Alcohol inhibits hepatic gluconeogenesis and potentiates nocturnal hypoglycaemia induced by NPH (intermediate-acting insulin).',
   'Evite o álcool ao jantar/se antes de dormir; monitorize a glicemia nocturna.',
   'Avoid alcohol at dinner/before bed; monitor night-time glucose.',
   'Prontuário Terapêutico INFARMED, 8.4.1; ficha do site (insulina NPH — vigiar glicemia noturna).',
   'Prontuário Terapêutico INFARMED, 8.4.1; site monograph (NPH insulin — monitor night-time glucose).', 1),
  -- ------------------------------------------------------------------
  -- AMINOFILINA × CAFEÍNA / XANTINAS — Prontuário 5.1.4 (l. 20209):
  -- clearance influenciada por alimentos; e 5.1.4 já indica interacção
  -- xantinas↔xantinas; a cafeína é também xantina (efeitos aditivos
  -- sobre SNC e coração) e o café reduz a absorção (tomada em jejum).
  -- ------------------------------------------------------------------
  ('aminofilina', 'cafeina', 'Cafeína', 'Caffeine', 'moderate',
   'A cafeína é também uma xantina — soma efeitos de estimulação do SNC e do coração (tremor, taquicardia, insónia) aos da aminofilina.',
   'Caffeine is also a xanthine — it adds CNS and cardiac stimulation effects (tremor, tachycardia, insomnia) to those of aminophylline.',
   'Limite café, chá, bebidas energéticas e chocolate durante o tratamento.',
   'Limit coffee, tea, energy drinks and chocolate during treatment.',
   'Prontuário Terapêutico INFARMED, 5.1.4 Xantinas (efeitos aditivos das xantinas; R. Adv. tremor, taquicardia, insónia).',
   'Prontuário Terapêutico INFARMED, 5.1.4 Xanthines (additive xanthine effects; ADRs tremor, tachycardia, insomnia).', 1),
  ('aminofilina', 'toma_em_jejum', 'Toma em jejum', 'Take on an empty stomach',
   'minor',
   'Alimentos reduzem a velocidade de absorção oral da teofilina/aminofilina sem alterar a quantidade total absorvida; nos esquemas de libertação prolongada a toma deve ser consistente.',
   'Food slows oral theophylline/aminophylline absorption without reducing total amount absorbed; sustained-release schedules require consistent timing relative to meals.',
   'Tome sempre à mesma hora e da mesma forma relativamente às refeições; não altere hábitos sem avisar o médico (altera os níveis séricos).',
   'Always take at the same time and consistently relative to meals; do not change habits without informing the doctor (it alters serum levels).',
   'Prontuário Terapêutico INFARMED, 5.1.4 Xantinas: "A clearance da teofilina e da aminofilina é influenciada por alimentos…" (l. 20209).',
   'Prontuário Terapêutico INFARMED, 5.1.4 Xanthines: "The clearance of theophylline and aminophylline is influenced by food…" (l. 20209).', 2),
  -- ------------------------------------------------------------------
  -- CLORETO DE POTÁSSIO × ALIMENTOS RICOS EM POTÁSSIO — soma de carga
  -- de potássio (substitutos de sal, bananas, laranja, tomate).
  -- ------------------------------------------------------------------
  ('cloreto-potassio', 'alimentos_ricos_potassio', 'Alimentos ricos em potássio', 'Potassium-rich foods', 'moderate',
   'A soma da suplementação farmacológica com alimentos ricos em potássio (bananas, laranja, tomate, batata, substitutos de sal com KCl) pode elevar o potássio sérico a níveis tóxicos.',
   'Adding pharmacological supplementation to potassium-rich foods (bananas, oranges, tomatoes, potatoes, KCl salt substitutes) can raise serum potassium to toxic levels.',
   'Não use substitutos de sal; modere frutos e sumos ricos em potássio; mantenha as análises de potássio em dia (ficha do site).',
   'Do not use salt substitutes; moderate potassium-rich fruits and juices; keep potassium blood tests up to date (site monograph).',
   'Ficha do site (cloreto de potássio — evite suplementos de potássio e substitutos de sal); EMC-UK KCl SmPC 4.4.',
   'Site monograph (potassium chloride — avoid potassium supplements and salt substitutes); EMC-UK KCl SmPC 4.4.', 1),
  -- ------------------------------------------------------------------
  -- GLUCONATO DE CÁLCIO × ALIMENTOS RICOS EM CÁLCIO / LEITE — soma de
  -- carga; e hipercalcemia em doentes predispostos.
  -- ------------------------------------------------------------------
  ('gluconato-calcio', 'alimentos_ricos_calcio', 'Alimentos ricos em cálcio', 'Calcium-rich foods', 'minor',
   'A soma da suplementação IV/oral com leite, lacticínios e alimentos fortificados pode causar síndrome leite-alcalino (hipercalcémia + alcalose).',
   'Adding IV/oral supplementation to milk, dairy and fortified foods can cause milk-alkali syndrome (hypercalcaemia + alkalosis).',
   'Não exceda 2000–2500 mg/dia de cálcio de todas as fontes (ficha do site); informe a equipa se toma suplementos.',
   'Do not exceed 2000–2500 mg/day of calcium from all sources (site monograph); inform the team if taking supplements.',
   'Ficha do site (cálcio — não exceder 2000–2500 mg/dia de todas as fontes).',
   'Site monograph (calcium — do not exceed 2000–2500 mg/day from all sources).', 1),
  -- ------------------------------------------------------------------
  -- SULFATO DE MAGNÉSIO × ALCOOL — diarreia osmótica aditiva e perda
  -- de electrólitos; o álcool também aumenta a excreção renal de Mg.
  -- ------------------------------------------------------------------
  ('sulfato-magnesio', 'alcool', 'Álcool', 'Alcohol', 'minor',
   'O álcool aumenta a excreção renal de magnésio e agrava a diarreia osmótica do sulfato de magnésio oral — perda adicional de electrólitos e desidratação.',
   'Alcohol increases renal magnesium excretion and worsens the osmotic diarrhoea of oral magnesium sulfate — additional electrolyte loss and dehydration.',
   'Evite o álcool durante o tratamento com sulfato de magnésio oral (laxante).',
   'Avoid alcohol during oral magnesium sulfate treatment (laxative).',
   'Prontuário Terapêutico INFARMED, Anexo 6 (álcool — desidratação e electrólitos); farmacologia do MgSO4.',
   'Prontuário Terapêutico INFARMED, Annex 6 (alcohol — dehydration and electrolytes); MgSO4 pharmacology.', 1),
  -- ------------------------------------------------------------------
  -- N-ACETILCISTEÍNA × (sem interação alimentar relevante)
  -- ------------------------------------------------------------------
  ('n-acetilcisteina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'A NAC pode ser tomada com ou sem alimentos; apenas sucos ácidos inactivam parcialmente a solução oral (não comprimidos efervescentes correctamente dissolvidos).',
   'NAC can be taken with or without food; only acidic juices partially inactivate the oral solution (not correctly dissolved effervescent tablets).',
   'Não dilua a solução oral em sucos ácidos; dissolva o efervescente em água (ficha do site).',
   'Do not dilute the oral solution in acidic juices; dissolve the effervescent tablet in water (site monograph).',
   'Ficha do site (NAC — não diluir com sucos ácidos, inativação).',
   'Site monograph (NAC — do not dilute with acidic juices, inactivation).', 1),
  -- ------------------------------------------------------------------
  -- ÁCIDO TRANEXÂMICO × ÁLCOOL — risco hemorrágico GI aditivo
  -- (NOTA: sem interação com vitamina K — ver cabeçalho).
  -- ------------------------------------------------------------------
  ('acido-tranexamico', 'alcool', 'Álcool', 'Alcohol', 'minor',
   'O álcool irrita a mucosa gástrica e inibe a agregação plaquetária transitória — soma risco hemorrágico gastrintestinal ao tratamento antifibrinolítico.',
   'Alcohol irritates the gastric mucosa and transiently inhibits platelet aggregation — it adds gastrointestinal bleeding risk to antifibrinolytic treatment.',
   'Evite o álcool durante o tratamento, sobretudo em doses altas ou uso prolongado.',
   'Avoid alcohol during treatment, especially at high doses or prolonged use.',
   'Prontuário Terapêutico INFARMED, Anexo 6 (álcool — hemorragia GI); ficha do site (R. Adv. GI do tranexâmico).',
   'Prontuário Terapêutico INFARMED, Annex 6 (alcohol — GI bleeding); site monograph (TXA GI ADRs).', 1),
  -- ------------------------------------------------------------------
  -- CARBIMAZOL / PROPILOURACILO × ALIMENTOS RICOS EM IODO
  -- ------------------------------------------------------------------
  ('carbimazol', 'alimentos_alcalinos', 'Alimentos/alimentos alcalinos', 'Foods/alkaline foods', 'minor',
   'Alimentos muito ricos em iodo (algas marinhas, kelp, suplementos de iodo) podem antagonizar ou desestabilizar o controlo do hipertiroidismo durante a toma de antitiroideus.',
   'Foods very rich in iodine (seaweed, kelp, iodine supplements) can antagonise or destabilise hyperthyroidism control during antithyroid treatment.',
   'Evite algas marinhas e suplementos de iodo; mantenha a dieta habitual consistente.',
   'Avoid seaweed and iodine supplements; keep your usual diet consistent.',
   'Prontuário Terapêutico INFARMED, 8.3 (antitiroideus — controlo do hipertiroidismo dependente do balanço de iodo).',
   'Prontuário Terapêutico INFARMED, 8.3 (antithyroid drugs — hyperthyroid control depends on iodine balance).', 1),
  ('propiltiouracilo', 'alimentos_alcalinos', 'Alimentos/alimentos alcalinos', 'Foods/alkaline foods', 'minor',
   'Alimentos muito ricos em iodo (algas, kelp) podem desestabilizar o controlo do hipertiroidismo durante a toma de PTU.',
   'Foods very rich in iodine (seaweed, kelp) can destabilise hyperthyroidism control during PTU treatment.',
   'Evite algas marinhas e suplementos de iodo.',
   'Avoid seaweed and iodine supplements.',
   'Prontuário Terapêutico INFARMED, 8.3 (PTU — mesmo mecanismo de classe do carbimazol).',
   'Prontuário Terapêutico INFARMED, 8.3 (PTU — same class mechanism as carbimazole).', 1),
  -- ------------------------------------------------------------------
  -- LÍTIO (via Lote 3? — lítio é pré-existente, mas a insulina NPH ×
  -- protamina cruzamento já feito na 273; aqui apenas Lotes 3/4)
  -- ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  -- PROGESTERONA × ALIMENTOS (tomada com alimentos melhora absorção)
  -- ------------------------------------------------------------------
  ('progesterona', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Tomar a progesterona com alimentos (refeição da noite) aumenta a biodisponibilidade e reduz tonturas/sonolência aguda.',
   'Taking progesterone with food (evening meal) increases bioavailability and reduces acute dizziness/drowsiness.',
   'Tome com a refeição, sempre à mesma hora (ficha do site).',
   'Take with a meal, always at the same time (site monograph).',
   'Ficha do site (progesterona — tomar ao deitar, com alimentos).',
   'Site monograph (progesterone — take at bedtime, with food).', 1),
  -- ------------------------------------------------------------------
  -- DEFEROXAMINA × ALIMENTOS RICOS EM VITAMINA C — a vitamina C em
  -- dose alta aumenta a captação de ferro pelos tecidos durante a
  -- quelação (risco de cardiotoxicidade) e melhora a excreção urinária
  -- — usado de forma controlada; alimentos ricos em C com moderação e
  -- nunca em dose alta sem supervisão.
  -- ------------------------------------------------------------------
  ('deferoxamina', 'vitaminas_lipossoliveis', 'Suplementos de vitaminas lipossolúveis (A, D, E, K)', 'Fat-soluble vitamin supplements (A, D, E, K)', 'minor',
   'Suplementos multivitamínicos com ferro anulam a quelação (a deferoxamina liga o ferro ingerido em vez do armazenado); a vitamina C em dose alta altera a distribuição do ferro quelado.',
   'Multivitamin supplements containing iron defeat chelation (deferoxamine binds ingested iron instead of stored iron); high-dose vitamin C alters the distribution of chelated iron.',
   'Não tome multivitamínicos com ferro; vitamina C só com indicação e dose controladas da equipa de talassemia.',
   'Do not take multivitamins containing iron; vitamin C only if indicated at doses controlled by the thalassaemia team.',
   'Prontuário, ficha DESFERAL (doses ajustadas à ferritina; administração IV lenta); EMC-UK desferrioxamine SmPC 4.4/4.5.',
   'Prontuário, DESFERAL monograph (doses adjusted to ferritin; slow IV administration); EMC-UK desferrioxamine SmPC 4.4/4.5.', 1),
  -- ------------------------------------------------------------------
  -- CLPIROTERONA (ciproterona) × ALCOOL — hepatotoxicidade aditiva
  -- ------------------------------------------------------------------
  ('ciproterona', 'alcool', 'Álcool', 'Alcohol', 'minor',
   'O álcool soma hepatotoxicidade à da ciproterona (tumores hepáticos benignos e hepatotoxicidade idiossincrática descritos com antiandrogénios esteroideus).',
   'Alcohol adds hepatotoxicity to that of cyproterone (benign liver tumours and idiosyncratic hepatotoxicity reported with steroidal antiandrogens).',
   'Modere ou evite o álcool durante tratamentos prolongados.',
   'Moderate or avoid alcohol during prolonged treatments.',
   'Ficha do site (ciproterona — vigiar função hepática); EMC-UK Co-cyprindiol SmPC 4.4.',
   'Site monograph (cyproterone — monitor liver function); EMC-UK Co-cyprindiol SmPC 4.4.', 1),
  -- ------------------------------------------------------------------
  -- FLUCLOXACILINA × ALIMENTOS (tomada em jejum para absorção)
  -- ------------------------------------------------------------------
  ('flucloxacilina', 'toma_em_jejum', 'Toma em jejum', 'Take on an empty stomach', 'minor',
   'Os alimentos reduzem significativamente a absorção da flucloxacilina — a toma deve ser 30–60 minutos ANTES das refeições.',
   'Food significantly reduces flucloxacillin absorption — doses should be taken 30–60 minutes BEFORE meals.',
   'Tome 30–60 minutos antes das refeições, com um copo de água.',
   'Take 30–60 minutes before meals, with a glass of water.',
   'EMC-UK — Flucloxacillin SmPC 4.2 (tomar em jejum) / Prontuário 6.1.1.',
   'EMC-UK — Flucloxacillin SmPC 4.2 (take on empty stomach) / Prontuário 6.1.1.', 1),
  -- ------------------------------------------------------------------
  -- TESTOSTERONA × ALCOOL — hepatotoxicidade aditiva (C17-alkylados
  -- orais); o gel transdermal tem pouco risco hepático mas mantém-se
  -- precaução geral.
  -- ------------------------------------------------------------------
  ('testosterona', 'alcool', 'Álcool', 'Alcohol', 'minor',
   'O álcool soma hepatotoxicidade à da testosterona (particularmente nos ésteres orais C17-alkylados, com colestase descrita).',
   'Alcohol adds hepatotoxicity to that of testosterone (particularly oral C17-alkylated esters, with reported cholestasis).',
   'Modere o álcool; monitorização hepática em tratamentos prolongados.',
   'Moderate alcohol; liver monitoring with prolonged treatment.',
   'EMC-UK — Testogel SmPC 4.4/4.8 (hepatic); Prontuário 8 (andrógenos — colestase).',
   'EMC-UK — Testogel SmPC 4.4/4.8 (hepatic); Prontuário 8 (androgens — cholestasis).', 1),
  -- ------------------------------------------------------------------
  -- CLOMIFENO × (sem interação alimentar relevante relevante) — sem
  -- par documentado; omitido em vez de forçado.
  -- ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  -- PERMANGANATO × (uso externo, sem interação alimentar)
  -- ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  -- ESPECTINOMICINA × (IM, sem interação alimentar documentada)
  -- ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  -- PROTAMINA × (IV, sem interação alimentar aplicável)
  -- ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  -- PIRIDOXINA × ALIMENTOS (tomada com alimentos reduz náuseas)
  -- ------------------------------------------------------------------
  ('piridoxina', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'none',
   'A piridoxina é melhor tolerada com alimentos (reduz náuseas); doses altas crónicas podem causar neuropatia sensorial — a alimentação não interfere clinicamente.',
   'Pyridoxine is better tolerated with food (reduces nausea); chronic high doses can cause sensory neuropathy — food does not interfere clinically.',
   'Tome com alimentos; não exceda 100 mg/dia crónicos sem orientação (ficha do site).',
   'Take with food; do not exceed 100 mg/day chronically without guidance (site monograph).',
   'Ficha do site (piridoxina — doses ≥ 10 mg/dia podem mascarar défice de B12).',
   'Site monograph (pyridoxine — doses ≥ 10 mg/day can mask B12 deficiency).', 1)
) AS v(drug_slug, entity_slug, entity_pt, entity_en,
       severity, mechanism_pt, mechanism_en,
       advice_pt, advice_en, source_pt, source_en, sort_order)
ON d.slug = v.drug_slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- Exclusões com justificação (regra 13.1 do Fluxo 2):
--   * clomifeno × alimentos: sem interação alimentar documentada no
--     SmPC/Prontuário — não registar sem fonte.
--   * espectinomicina: via IM, sem interação alimentar aplicável.
--   * protamina: via IV em ambiente hospitalar — sem aplicação.
--   * permanganato-potassio: uso externo exclusivo — sem aplicação.
--   * acido-tranexamico × vitamina K: sem antagonismo (ambos pró-
--     coagulantes) — ver cabeçalho; não registar como interação.
--   * lítio × cafeína: o lítio é fármaco pré-existente (não Lote 3/4)
--     — fora do âmbito desta migração.
--   * testosterona × refeição gordurosa: apenas relevantes para formas
--     orais não usadas no site — não registar.
-- =====================================================================
