-- =====================================================================
-- 126 — Explicações fármaco-fármaco dos pares moderados da ISONIAZIDA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 3 pares moderados da isoniazida que os tinham vazios
-- (sertralina e tramadol já cobertos nas 120 e 121; carbamazepina e
-- warfarina já tinham explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais:
--   1. Isoniazida + fenitoína — inibição do metabolismo da fenitoína
--      ("isoniazid may increase serum levels of phenytoin. To avoid
--      phenytoin intoxication, appropriate adjustment...");
--   2. Isoniazida + fluoxetina — a isoniazida tem atividade inibidora da
--      MAO ("isoniazid has some monoamine oxidase inhibiting activity")
--      somada ao ISRS (fluoxetina: MAOI contraindicados pelo risco de
--      síndrome serotoninérgica) → risco serotoninérgico;
--   3. Isoniazida + paracetamol — a isoniazida induz o P-450IIE1 (CYP2E1),
--      aumentando a conversão do paracetamol nos metabolitos tóxicos
--      (relato de hepatotoxicidade grave; potenciação em ratos).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/3 — ISONIAZIDA + FENITOÍNA (inibição do metabolismo — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + fenitoína: a isoniazida inibe o metabolismo da fenitoína e aumenta os seus níveis. Monitorizar e ajustar a dose do anticonvulsivante.',
  summary_pro_en = 'Isoniazid + phenytoin: isoniazid inhibits phenytoin metabolism and raises its levels. Monitor and adjust the anticonvulsant dose.',
  explanation_pt = 'A isoniazida interfere com o metabolismo da fenitoína (inibição das enzimas que a metabolizam, nomeadamente o CYP2C19), e o rótulo da isoniazida refere explicitamente que "a isoniazida pode aumentar os níveis séricos de fenitoína" e que, "para evitar a intoxicação por fenitoína, deve ser feito o ajuste adequado do anticonvulsivante"; o rótulo repete a precaução na secção de sobredosagem ("a fenitoína deve ser usada com precaução, porque a isoniazida interfere com o metabolismo da fenitoína"). A fenitoína tem cinética não linear e janela terapêutica estreita: o aumento dos níveis pode causar nistagmo, ataxia, disartria, sonolência e, em casos graves, convulsões ou coma. Quando a associação é necessária (ex.: tuberculose em doente epilético), monitorizar os níveis séricos de fenitoína e os sinais clínicos de toxicidade no início e sempre que a dose de isoniazida mudar, ajustando a dose do anticonvulsivante; considerar a monitorização das transaminases, dado que ambos os fármacos são hepatotóxicos.',
  explanation_en = 'Isoniazid interferes with phenytoin metabolism (inhibition of the enzymes that metabolise it, namely CYP2C19), and the isoniazid label explicitly states that "isoniazid may increase serum levels of phenytoin" and that "to avoid phenytoin intoxication, appropriate adjustment of the anticonvulsant should be made"; the label repeats the caution in the overdosage section ("phenytoin should be used cautiously, because isoniazid interferes with the metabolism of phenytoin"). Phenytoin has non-linear kinetics and a narrow therapeutic window: raised levels can cause nystagmus, ataxia, dysarthria, drowsiness and, in severe cases, seizures or coma. When the combination is needed (e.g. tuberculosis in an epileptic patient), monitor phenytoin serum levels and clinical signs of toxicity at initiation and whenever the isoniazid dose changes, adjusting the anticonvulsant dose; consider transaminase monitoring, since both drugs are hepatotoxic.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- 2/3 — ISONIAZIDA + FLUOXETINA (serotonina — atividade MAO da isoniazida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + fluoxetina: a isoniazida tem atividade inibidora da MAO — risco de síndrome serotoninérgica com o ISRS. Vigiar sintomas.',
  summary_pro_en = 'Isoniazid + fluoxetine: isoniazid has MAO-inhibiting activity — risk of serotonin syndrome with the SSRI. Watch for symptoms.',
  explanation_pt = 'A isoniazida tem alguma atividade inibidora da monoamina oxidase (o rótulo refere que "a isoniazida tem alguma atividade inibidora da MAO", com interação com alimentos ricos em tiramina, e alerta para o risco de interação com inibidores da MAO), e a fluoxetina é um inibidor seletivo da recaptação da serotonina (ISRS) cujo rótulo contraindica a associação com inibidores da MAO "porque há um risco aumentado de síndrome serotoninérgica". A associação de um ISRS com um fármaco com atividade MAO pode causar síndrome serotoninérgica (agitação, confusão, hipertermia, hiperreflexia, mioclonias, diaforese, taquicardia) ou crise hipertensiva. Evitar sempre que possível; se a associação for inevitável (ex.: tuberculose em doente com depressão), usar a dose eficaz mais baixa, vigiar ativamente os sinais de serotonina e de toxicidade neurológica e instruir o doente a procurar ajuda imediata perante agitação, febre ou rigidez.',
  explanation_en = 'Isoniazid has some monoamine oxidase inhibiting activity (the label states that "isoniazid has some monoamine oxidase inhibiting activity", with an interaction with tyramine-rich foods, and warns about the risk of interaction with MAO inhibitors), and fluoxetine is a selective serotonin reuptake inhibitor (SSRI) whose label contraindicates the combination with MAO inhibitors "because of an increased risk of serotonin syndrome". Combining an SSRI with a drug with MAO activity can cause serotonin syndrome (agitation, confusion, hyperthermia, hyperreflexia, myoclonus, diaphoresis, tachycardia) or a hypertensive crisis. Avoid whenever possible; if the combination is unavoidable (e.g. tuberculosis in a patient with depression), use the lowest effective dose, actively watch for serotonin signs and neurological toxicity, and instruct the patient to seek immediate help with agitation, fever or rigidity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'));

-- 3/3 — ISONIAZIDA + PARACETAMOL (hepatotoxicidade — indução do CYP2E1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + paracetamol: a isoniazida induz o CYP2E1 e aumenta os metabolitos tóxicos do paracetamol. Vigiar função hepática e evitar sobredosagem.',
  summary_pro_en = 'Isoniazid + paracetamol: isoniazid induces CYP2E1 and increases toxic paracetamol metabolites. Monitor liver function and avoid overdose.',
  explanation_pt = 'O rótulo da isoniazida documenta um relato de hepatotoxicidade grave por paracetamol num doente a tomar isoniazida e propõe a base molecular: "a isoniazida induz o P-450IIE1, uma enzima oxidase de função mista que parece gerar os metabolitos tóxicos no fígado", fazendo com que uma maior proporção do paracetamol ingerido seja convertida no metabolito tóxico (NAPQI); estudos em ratos demonstraram que o pré-tratamento com isoniazida potencia a hepatotoxicidade do paracetamol. A associação é muito comum (a isoniazida é usada em tuberculose e o paracetamol é o analgésico/antipirético de primeira linha), e o risco é sobretudo de hepatotoxicidade aditiva em doentes com doença hepática, alcoólicos ou com doses altas/prolongadas de paracetamol. Recomendações: usar a dose eficaz mais baixa de paracetamol, evitar o álcool, vigiar transaminases nos doentes de risco e estar atento a sinais de lesão hepática (náuseas, anorexia, icterícia, dor no hipocôndrio direito).',
  explanation_en = 'The isoniazid label documents a report of severe paracetamol (acetaminophen) toxicity in a patient taking isoniazid and proposes the molecular basis: "isoniazid induces P-450IIE1, a mixed-function oxidase enzyme that appears to generate the toxic metabolites in the liver", causing a greater proportion of ingested paracetamol to be converted into the toxic metabolite (NAPQI); rat studies demonstrated that isoniazid pretreatment potentiates paracetamol hepatotoxicity. The combination is very common (isoniazid is used in tuberculosis and paracetamol is the first-line analgesic/antipyretic), and the risk is mainly of additive hepatotoxicity in patients with liver disease, alcohol users or with high/prolonged paracetamol doses. Recommendations: use the lowest effective paracetamol dose, avoid alcohol, monitor transaminases in at-risk patients and watch for signs of liver injury (nausea, anorexia, jaundice, right upper quadrant pain).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'));
