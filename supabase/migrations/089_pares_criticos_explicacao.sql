-- =====================================================================
-- 089 — Explicações dos 18 pares críticos fármaco-fármaco
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos pares com severidade 'critical' que os tinham vazios, seguindo
-- o padrão de UPDATE da 079 (WHERE independente da ordem — regra de ouro
-- do documento de fluxo: LEAST/GREATEST canónico).
--
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMC-UK, PubMed e
-- Prontuário Terapêutico do INFARMED). Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/18 — ALPRAZOLAM + MORFINA (depressão respiratória, boxed warning)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Benzodiazepina + opioide: depressão aditiva do SNC e da respiração, com risco de sedação profunda, coma e morte. Evitar a associação; se inevitável, usar as menores doses eficazes e vigiar de perto a sedação e a respiração.',
  summary_pro_en = 'Benzodiazepine + opioid: additive CNS and respiratory depression, with risk of deep sedation, coma and death. Avoid the combination; if unavoidable, use the lowest effective doses and monitor sedation and breathing closely.',
  explanation_pt = 'A morfina e o alprazolam deprimem o sistema nervoso central e o centro respiratório por mecanismos complementares (agonismo dos recetores opioides mu e potenciação do GABA no recetor GABA-A). A FDA emitiu um aviso em caixa (boxed warning) para a associação de opioides com benzodiazepinas: uma fração substancial das mortes por overdose envolve os dois grupos em simultâneo. Sempre que possível, evitar a coadministração; se for clinicamente inevitável, usar as menores doses eficazes pelo menor tempo, informar o doente e os familiares e vigiar a sedação, a frequência respiratória e a saturação de oxigénio. Deve estar disponível naloxona quando o opioide é usado em dose relevante.',
  explanation_en = 'Morphine and alprazolam depress the central nervous system and the respiratory centre through complementary mechanisms (mu opioid receptor agonism and GABA potentiation at the GABA-A receptor). The FDA issued a boxed warning for the combination of opioids with benzodiazepines: a substantial proportion of overdose deaths involves both groups together. Whenever possible, avoid co-administration; if clinically unavoidable, use the lowest effective doses for the shortest time, inform the patient and family, and monitor sedation, respiratory rate and oxygen saturation. Naloxone should be available when the opioid is used at a relevant dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'morfina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'morfina'));

-- 2/18 — ALPRAZOLAM + CODEÍNA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Benzodiazepina + opioide: depressão aditiva do SNC e da respiração. A codeína é um pró-fármaco da morfina (CYP2D6) e em crianças está contraindicada. Evitar; se inevitável, menores doses e vigilância apertada.',
  summary_pro_en = 'Benzodiazepine + opioid: additive CNS and respiratory depression. Codeine is a prodrug of morphine (CYP2D6) and is contraindicated in children. Avoid; if unavoidable, lowest doses and close monitoring.',
  explanation_pt = 'A codeína é convertida em morfina pelo CYP2D6 e, com o alprazolam, os dois fármacos somam os seus efeitos depressores do sistema nervoso central e da respiração, com risco de sedação profunda, coma e morte — o mesmo aviso em caixa da FDA que se aplica a todos os opioides com benzodiazepinas. Nos metabolizadores ultrarrápidos do CYP2D6, a conversão em morfina é exagerada e o risco aumenta ainda mais; por isso a codeína é contraindicada em crianças e deve ser evitada durante a amamentação. A gestão é igual à dos restantes opioides: evitar a associação sempre que possível, e se inevitável, doses mínimas, duração curta e vigilância da sedação, frequência respiratória e saturação de oxigénio.',
  explanation_en = 'Codeine is converted to morphine by CYP2D6 and, together with alprazolam, the two drugs add their central nervous system and respiratory depressant effects, with risk of deep sedation, coma and death — the same FDA boxed warning that applies to all opioids with benzodiazepines. In ultrarapid CYP2D6 metabolisers, conversion to morphine is exaggerated and the risk is even higher; codeine is therefore contraindicated in children and should be avoided during breastfeeding. Management is the same as for other opioids: avoid the combination whenever possible, and if unavoidable, minimal doses, short duration and monitoring of sedation, respiratory rate and oxygen saturation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'codeina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'codeina'));

-- 3/18 — ALPRAZOLAM + HIDROMORFONA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Benzodiazepina + opioide: depressão aditiva do SNC e da respiração, com risco de sedação profunda, coma e morte. Evitar; se inevitável, menores doses e vigilância apertada da respiração.',
  summary_pro_en = 'Benzodiazepine + opioid: additive CNS and respiratory depression, with risk of deep sedation, coma and death. Avoid; if unavoidable, lowest doses and close monitoring of breathing.',
  explanation_pt = 'A hidromorfona é um opioide potente (agonista mu) e o alprazolam uma benzodiazepina: os efeitos depressores do sistema nervoso central e do centro respiratório somam-se, e o risco de sedação profunda, coma e morte por depressão respiratória é substancial — o motivo do aviso em caixa da FDA para opioides com benzodiazepinas. A associação deve ser evitada sempre que possível; se for clinicamente indispensável, usar as menores doses eficazes, limitar a duração, informar o doente e os familiares e vigiar a sedação, a frequência respiratória e a saturação de oxigénio, com naloxona disponível.',
  explanation_en = 'Hydromorphone is a potent opioid (mu agonist) and alprazolam a benzodiazepine: their central nervous system and respiratory centre depressant effects add up, and the risk of deep sedation, coma and death from respiratory depression is substantial — the reason for the FDA boxed warning for opioids with benzodiazepines. The combination should be avoided whenever possible; if clinically indispensable, use the lowest effective doses, limit the duration, inform the patient and family, and monitor sedation, respiratory rate and oxygen saturation, with naloxone available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'hidromorfona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'hidromorfona'));

-- 4/18 — AZATIOPRINA + ALOPURINOL (mielossupressão grave)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor da xantina oxidase + azatioprina: o alopurinol bloqueia o metabolismo da azatioprina e eleva muito os seus níveis, com risco de mielossupressão grave e infeções. Se inevitável, reduzir a azatioprina para cerca de 25% da dose e monitorizar o hemograma.',
  summary_pro_en = 'Xanthine oxidase inhibitor + azathioprine: allopurinol blocks azathioprine metabolism and greatly raises its levels, with risk of severe myelosuppression and infections. If unavoidable, reduce azathioprine to about 25% of the dose and monitor the blood count.',
  explanation_pt = 'A azatioprina é um pró-fármaco inativo convertido em 6-mercaptopurina, que é depois metabolizada pela xantina oxidase em ácido tioúrico inativo. O alopurinol inibe a xantina oxidase e desvia o metabolismo para os nucleótidos 6-tioguanina citotóxicos: a consequência é a acumulação de metabolitos ativos com mielossupressão grave, por vezes fatal. O rótulo aprovado da azatioprina recomenda reduzir a dose para um quarto da habitual quando se associa alopurinol. Monitorizar o hemograma com frequência (nas primeiras semanas, semanalmente) e ajustar a dose com base nos neutrófilos e plaquetas; vigiar também função hepática.',
  explanation_en = 'Azathioprine is an inactive prodrug converted to 6-mercaptopurine, which is then metabolised by xanthine oxidase to inactive thiouric acid. Allopurinol inhibits xanthine oxidase and shifts metabolism towards cytotoxic 6-thioguanine nucleotides: the consequence is accumulation of active metabolites with severe, sometimes fatal, myelosuppression. The approved azathioprine label recommends reducing the dose to one quarter of the usual dose when allopurinol is added. Monitor the blood count frequently (weekly in the first weeks) and adjust the dose based on neutrophils and platelets; also monitor liver function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'azatioprina'), (SELECT id FROM public.drugs WHERE slug = 'alopurinol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'azatioprina'), (SELECT id FROM public.drugs WHERE slug = 'alopurinol'));

-- 5/18 — AZATIOPRINA + FEBUXOSTAT
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor da xantina oxidase + azatioprina: risco de mielossupressão grave e potencialmente fatal. O febuxostat está contraindicado com a azatioprina — não associar; escolher alternativa hipouricemiante.',
  summary_pro_en = 'Xanthine oxidase inhibitor + azathioprine: risk of severe and potentially fatal myelosuppression. Febuxostat is contraindicated with azathioprine — do not combine; choose an alternative urate-lowering agent.',
  explanation_pt = 'Tal como o alopurinol, o febuxostat inibe a xantina oxidase e bloqueia a inativação da 6-mercaptopurina derivada da azatioprina, aumentando de forma acentuada os metabolitos citotóxicos 6-tioguanina — o rótulo aprovado do febuxostat contraindica formalmente a coadministração com azatioprina ou mercaptopurina pelo risco de mielossupressão grave e potencialmente fatal. Não existe dose segura documentada; se a terapêutica com azatioprina for indispensável, deve escolher-se outro hipouricemiante e, na impossibilidade, discutir redução marcada da dose de azatioprina com monitorização hematológica muito apertada.',
  explanation_en = 'Like allopurinol, febuxostat inhibits xanthine oxidase and blocks the inactivation of 6-mercaptopurine derived from azathioprine, markedly increasing the cytotoxic 6-thioguanine metabolites — the approved febuxostat label formally contraindicates co-administration with azathioprine or mercaptopurine due to the risk of severe and potentially fatal myelosuppression. There is no documented safe dose; if azathioprine therapy is indispensable, another urate-lowering agent should be chosen and, failing that, a marked azathioprine dose reduction with very close haematological monitoring should be discussed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'azatioprina'), (SELECT id FROM public.drugs WHERE slug = 'febuxostat'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'azatioprina'), (SELECT id FROM public.drugs WHERE slug = 'febuxostat'));

-- 6/18 — CLARITROMICINA + CARBAMAZEPINA (toxicidade por inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A claritromicina inibe o CYP3A4 e aumenta muito as concentrações de carbamazepina, com risco de toxicidade (diplopia, ataxia, sedação, náuseas). Preferir alternativa antibiótica; se inevitável, reduzir a dose de carbamazepina e monitorizar.',
  summary_pro_en = 'Clarithromycin inhibits CYP3A4 and greatly increases carbamazepine concentrations, with risk of toxicity (diplopia, ataxia, sedation, nausea). Prefer an alternative antibiotic; if unavoidable, reduce the carbamazepine dose and monitor.',
  explanation_pt = 'A carbamazepina é extensamente metabolizada pelo CYP3A4 e a claritromicina é um inibidor potente desta isoenzima e da glicoproteína P. A associação pode duplicar ou mais do que duplicar os níveis séricos de carbamazepina, com sintomas de toxicidade como diplopia, nistagmo, ataxia, sedação e náuseas; em casos graves podem ocorrer convulsões ou coma. Sempre que possível, deve escolher-se um antibiótico alternativo que não iniba o CYP3A4 (ex.: azitromicina); se a associação for necessária, reduzir a dose de carbamazepina, monitorizar os níveis séricos e os sinais clínicos de toxicidade.',
  explanation_en = 'Carbamazepine is extensively metabolised by CYP3A4 and clarithromycin is a potent inhibitor of this isoenzyme and of P-glycoprotein. The combination can double or more than double serum carbamazepine levels, with toxicity symptoms such as diplopia, nystagmus, ataxia, sedation and nausea; severe cases may progress to seizures or coma. Whenever possible, an alternative antibiotic that does not inhibit CYP3A4 should be chosen (e.g. azithromycin); if the combination is necessary, reduce the carbamazepine dose, monitor serum levels and clinical signs of toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

-- 7/18 — CLARITROMICINA + DOMPERIDONA (contraindicação — QT)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Contraindicação: a claritromicina inibe o CYP3A4 e eleva as concentrações de domperidona, aumentando o risco de prolongamento do QT e de torsades de pointes. Não associar; escolher alternativa.',
  summary_pro_en = 'Contraindication: clarithromycin inhibits CYP3A4 and raises domperidone concentrations, increasing the risk of QT prolongation and torsades de pointes. Do not combine; choose an alternative.',
  explanation_pt = 'A domperidona prolonga o intervalo QT e é metabolizada pelo CYP3A4; a claritromicina, inibidora potente desta isoenzima, aumenta as suas concentrações e o risco de arritmias ventriculares malignas (torsades de pointes). Por este motivo, a associação é formalmente contraindicada. O risco é maior em doentes com cardiopatia, hipocaliemia, bradicardia ou a tomar outros fármacos que prolonguem o QT; deve escolher-se um procinético ou antibiótico alternativo.',
  explanation_en = 'Domperidone prolongs the QT interval and is metabolised by CYP3A4; clarithromycin, a potent inhibitor of this isoenzyme, raises its concentrations and the risk of malignant ventricular arrhythmias (torsades de pointes). For this reason, the combination is formally contraindicated. The risk is higher in patients with heart disease, hypokalaemia, bradycardia or taking other QT-prolonging drugs; an alternative prokinetic or antibiotic should be chosen.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'domperidona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'domperidona'));

-- 8/18 — COLCHICINA + CLARITROMICINA (toxicidade da colchicina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A claritromicina (inibidor do CYP3A4 e da P-gp) aumenta muito os níveis de colchicina, com risco de toxicidade grave e potencialmente fatal (diarreia, mielossupressão, rabdomiólise). Não associar; usar alternativa.',
  summary_pro_en = 'Clarithromycin (CYP3A4 and P-gp inhibitor) greatly increases colchicine levels, with risk of severe and potentially fatal toxicity (diarrhoea, myelosuppression, rhabdomyolysis). Do not combine; use an alternative.',
  explanation_pt = 'A colchicina é substrato do CYP3A4 e da glicoproteína P; a claritromicina inibe ambas as vias e pode multiplicar a exposição à colchicina, provocando toxicidade grave: sintomas gastrointestinais intensos, pancitopenia, neuropatia e rabdomiólise, por vezes fatais. O rótulo aprovado da colchicina contraindica a associação com inibidores potentes do CYP3A4/P-gp em doentes com insuficiência renal ou hepática e, nos restantes, exige redução da dose — na prática, a combinação deve ser evitada sempre que possível, escolhendo um antibiótico alternativo (ex.: azitromicina).',
  explanation_en = 'Colchicine is a substrate of CYP3A4 and P-glycoprotein; clarithromycin inhibits both pathways and can multiply colchicine exposure, causing severe toxicity: intense gastrointestinal symptoms, pancytopenia, neuropathy and rhabdomyolysis, sometimes fatal. The approved colchicine label contraindicates the combination with potent CYP3A4/P-gp inhibitors in patients with renal or hepatic impairment and, in the others, requires dose reduction — in practice, the combination should be avoided whenever possible, choosing an alternative antibiotic (e.g. azithromycin).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'colchicina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colchicina'), (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 9/18 — ESPIRONOLACTONA + ENALAPRIL (hipercaliemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'IECA + antagonista da aldosterona: efeito aditivo na retenção de potássio, com risco de hipercaliemia, sobretudo com TFG reduzida, diabetes ou idade avançada. Monitorizar potássio e creatinina cerca de 1 semana após iniciar ou ajustar.',
  summary_pro_en = 'ACE inhibitor + aldosterone antagonist: additive potassium retention, with risk of hyperkalaemia, especially with reduced GFR, diabetes or advanced age. Monitor potassium and creatinine about 1 week after starting or adjusting.',
  explanation_pt = 'O enalapril reduz a produção de aldosterona e a espironolactona bloqueia o recetor da aldosterona no túbulo distal: o efeito combinado é a redução marcada da excreção de potássio. A hipercaliemia é mais frequente em doentes com insuficiência renal, diabetes, idade avançada ou a tomar suplementos de potássio, e pode manifestar-se por fraqueza muscular, parestesias e arritmias. A associação é válida e frequente na insuficiência cardíaca com fração de ejeção reduzida, onde o benefício está comprovado — o que se exige é vigilância: potássio e creatinina cerca de 1 semana após iniciar ou ajustar a dose e reavaliação se houver piora renal.',
  explanation_en = 'Enalapril reduces aldosterone production and spironolactone blocks the aldosterone receptor in the distal tubule: the combined effect is a marked reduction in potassium excretion. Hyperkalaemia is more frequent in patients with renal impairment, diabetes, advanced age or taking potassium supplements, and may present with muscle weakness, paraesthesias and arrhythmias. The combination is valid and common in heart failure with reduced ejection fraction, where benefit is proven — what is required is surveillance: potassium and creatinine about 1 week after starting or adjusting the dose, and reassessment if renal function worsens.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'));

-- 10/18 — FLUOXETINA + SERTRALINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois ISRS em simultâneo: risco de síndrome serotoninérgica (agitação, tremor, hipertermia, rigidez, diarreia) e efeitos aditivos. Evitar; ao mudar de ISRS, respeitar o período de washout (a fluoxetina tem semivida longa).',
  summary_pro_en = 'Two SSRIs simultaneously: risk of serotonin syndrome (agitation, tremor, hyperthermia, rigidity, diarrhoea) and additive effects. Avoid; when switching SSRIs, respect the washout period (fluoxetine has a long half-life).',
  explanation_pt = 'A fluoxetina e a sertralina aumentam a serotonina sináptica pelo mesmo mecanismo (bloqueio do transportador SERT); em associação, o risco de síndrome serotoninérgica aumenta, sobretudo com doses elevadas ou com outros fármacos serotoninérgicos. A fluoxetina tem semivida longa (1 a 3 dias; 4 a 16 dias para a norfluoxetina), pelo que o washout ao mudar de fármaco deve ser maior. Na prática, dois ISRS não devem ser usados em simultâneo; a combinação só se justifica em transições muito curtas e supervisionadas, e os sintomas de alerta (agitação, tremor, hiperreflexia, hipertermia, diarreia) devem levar à suspensão imediata.',
  explanation_en = 'Fluoxetine and sertraline increase synaptic serotonin through the same mechanism (blockade of the SERT transporter); in combination, the risk of serotonin syndrome increases, especially at high doses or with other serotonergic drugs. Fluoxetine has a long half-life (1 to 3 days; 4 to 16 days for norfluoxetine), so the washout when switching drugs must be longer. In practice, two SSRIs should not be used simultaneously; the combination is only justified in very short, supervised transitions, and warning symptoms (agitation, tremor, hyperreflexia, hyperthermia, diarrhoea) should lead to immediate discontinuation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 11/18 — IBUPROFENO + VARFARINA (risco hemorrágico)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + cumarínico: risco hemorrágico acentuado (hemorragia gastrointestinal e aumento variável do INR). Preferir paracetamol; se o AINE for inevitável, dose mínima, curso curto e proteção gástrica; vigiar sinais de hemorragia.',
  summary_pro_en = 'NSAID + coumarin: markedly increased bleeding risk (gastrointestinal bleeding and variable INR increase). Prefer paracetamol; if the NSAID is unavoidable, minimal dose, short course and gastric protection; watch for bleeding signs.',
  explanation_pt = 'O ibuprofeno aumenta o risco hemorrágico em doentes anticoagulados por dois mecanismos: lesão direta da mucosa gastrointestinal e inibição reversível da COX-1, que reduz o tromboxano A2 e prejudica a agregação plaquetária. O efeito sobre o INR é variável, mas o aumento do risco de hemorragia — em particular hemorragia gastrointestinal alta — está bem documentado mesmo com doses ocasionais de AINE. Em doentes a tomar varfarina, o paracetamol é a analgesia de primeira linha; se um AINE for indispensável, usar a menor dose eficaz pelo menor tempo, considerar proteção gástrica com inibidor da bomba de protões e manter vigilância de sinais de hemorragia (fezes escuras, equimoses espontâneas, hemorragias).',
  explanation_en = 'Ibuprofen increases the bleeding risk in anticoagulated patients through two mechanisms: direct injury to the gastrointestinal mucosa and reversible COX-1 inhibition, which reduces thromboxane A2 and impairs platelet aggregation. The effect on the INR is variable, but the increase in bleeding risk — particularly upper gastrointestinal bleeding — is well documented even with occasional NSAID doses. In patients taking warfarin, paracetamol is the first-line analgesic; if an NSAID is indispensable, use the lowest effective dose for the shortest time, consider gastric protection with a proton pump inhibitor, and remain vigilant for bleeding signs (dark stools, spontaneous bruising, bleeding).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 12/18 — LINEZOLIDA + FLUOXETINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Linezolida (inibidor da MAO) + ISRS: risco de síndrome serotoninérgica potencialmente fatal. Evitar; se inevitável, vigilância apertada dos sintomas serotoninérgicos.',
  summary_pro_en = 'Linezolid (MAO inhibitor) + SSRI: risk of potentially fatal serotonin syndrome. Avoid; if unavoidable, close monitoring of serotonergic symptoms.',
  explanation_pt = 'A linezolida é um inibidor reversível e não seletivo da monoamina oxidase e a fluoxetina bloqueia a recaptação da serotonina: o efeito combinado pode causar síndrome serotoninérgica grave — agitação, tremor, hipertermia, rigidez, hiperreflexia e diarreia, e nos casos graves convulsões, rabdomiólise e morte. Os rótulos aprovados da linezolida e da fluoxetina alertam para este risco. A associação deve ser evitada sempre que possível; se for clinicamente indispensável, usar a menor dose eficaz, vigiar de forma apertada os sintomas serotoninérgicos e suspender imediatamente se surgirem sinais.',
  explanation_en = 'Linezolid is a reversible, non-selective monoamine oxidase inhibitor and fluoxetine blocks serotonin reuptake: the combined effect can cause severe serotonin syndrome — agitation, tremor, hyperthermia, rigidity, hyperreflexia and diarrhoea, and in severe cases seizures, rhabdomyolysis and death. The approved labels of linezolid and fluoxetine warn of this risk. The combination should be avoided whenever possible; if clinically indispensable, use the lowest effective dose, closely monitor for serotonergic symptoms and discontinue immediately if signs appear.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'));

-- 13/18 — LINEZOLIDA + SERTRALINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Linezolida (inibidor da MAO) + ISRS: risco de síndrome serotoninérgica potencialmente fatal. Evitar; se inevitável, vigilância apertada e suspensão imediata perante sintomas.',
  summary_pro_en = 'Linezolid (MAO inhibitor) + SSRI: risk of potentially fatal serotonin syndrome. Avoid; if unavoidable, close monitoring and immediate discontinuation if symptoms occur.',
  explanation_pt = 'A sertralina aumenta a serotonina sináptica por bloqueio da recaptação e a linezolida inibe a monoamina oxidase: a combinação das duas ações pode precipitar síndrome serotoninérgica grave (agitação, tremor, hipertermia, rigidez, hiperreflexia) com risco de morte. O rótulo aprovado da linezolida alerta para o risco acrescido com fármacos serotoninérgicos, incluindo os ISRS. Sempre que possível, escolher um antibiótico alternativo; se a associação for inevitável, usar a menor dose eficaz, vigiar os sintomas serotoninérgicos e suspender de imediato se surgirem.',
  explanation_en = 'Sertraline increases synaptic serotonin by blocking reuptake and linezolid inhibits monoamine oxidase: the combination of the two actions can precipitate severe serotonin syndrome (agitation, tremor, hyperthermia, rigidity, hyperreflexia) with risk of death. The approved linezolid label warns of the increased risk with serotonergic drugs, including SSRIs. Whenever possible, choose an alternative antibiotic; if the combination is unavoidable, use the lowest effective dose, monitor for serotonergic symptoms and discontinue immediately if they occur.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 14/18 — LINEZOLIDA + TRAMADOL (serotonina + convulsões)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Linezolida (inibidor da MAO) + tramadol: risco de síndrome serotoninérgica e de convulsões. Evitar a associação; vigiar sintomas serotoninérgicos e neurológicos.',
  summary_pro_en = 'Linezolid (MAO inhibitor) + tramadol: risk of serotonin syndrome and seizures. Avoid the combination; monitor serotonergic and neurological symptoms.',
  explanation_pt = 'O tramadol aumenta a serotonina sináptica (bloqueio da recaptação) e reduz o limiar convulsivo; a linezolida inibe a monoamina oxidase. A associação pode precipitar síndrome serotoninérgica e convulsões, ambas potencialmente graves; o rótulo aprovado do tramadol contraindica o uso com inibidores da MAO (a linezolida funciona como tal). Evitar a combinação sempre que possível; se for clinicamente indispensável, usar a menor dose eficaz, vigiar sintomas serotoninérgicos e neurológicos e suspender perante qualquer sinal de alerta.',
  explanation_en = 'Tramadol increases synaptic serotonin (reuptake blockade) and lowers the seizure threshold; linezolid inhibits monoamine oxidase. The combination can precipitate serotonin syndrome and seizures, both potentially severe; the approved tramadol label contraindicates use with MAO inhibitors (linezolid acts as one). Avoid the combination whenever possible; if clinically indispensable, use the lowest effective dose, monitor serotonergic and neurological symptoms and discontinue at any warning sign.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

-- 15/18 — NITROGLICERINA + SILDENAFIL (contraindicação absoluta)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Contraindicação absoluta: nitratos + inibidores da PDE5 provocam hipotensão grave potencialmente fatal. Não associar; após sildenafil, não administrar nitratos nas 24 horas seguintes.',
  summary_pro_en = 'Absolute contraindication: nitrates + PDE5 inhibitors cause severe, potentially fatal hypotension. Do not combine; after sildenafil, do not give nitrates within the following 24 hours.',
  explanation_pt = 'O sildenafil inibe a PDE5 e potencia de forma marcada o efeito vasodilatador e hipotensor dos nitratos (doadores de óxido nítrico): a combinação pode causar hipotensão grave, síncope, enfarte do miocárdio e morte. O rótulo aprovado do sildenafil contraindica formalmente o uso com nitratos, em qualquer forma (sublingual, oral, tópica, transdérmica) e a qualquer momento. Se o doente tomou sildenafil, deve aguardar-se pelo menos 24 horas antes de administrar um nitrato (48 horas para o tadalafil, de semivida mais longa); em caso de angina após sildenafil, contactar de imediato o serviço de urgência.',
  explanation_en = 'Sildenafil inhibits PDE5 and markedly potentiates the vasodilating and hypotensive effect of nitrates (nitric oxide donors): the combination can cause severe hypotension, syncope, myocardial infarction and death. The approved sildenafil label formally contraindicates use with nitrates, in any form (sublingual, oral, topical, transdermal) and at any time. If the patient took sildenafil, at least 24 hours should elapse before giving a nitrate (48 hours for tadalafil, which has a longer half-life); in the event of angina after sildenafil, the emergency department should be contacted immediately.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'));

-- 16/18 — RIFAMPICINA + ARTEMÉTER-LUMEFANTRINA (falência do tratamento da malária)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A rifampicina (indutor potente do CYP3A4) reduz drasticamente os níveis de arteméter e lumefantrina — risco de falência do tratamento da malária. Evitar a associação; se inevitável, considerar alternativa antimalárica.',
  summary_pro_en = 'Rifampicin (potent CYP3A4 inducer) drastically reduces artemether and lumefantrine levels — risk of malaria treatment failure. Avoid the combination; if unavoidable, consider an alternative antimalarial.',
  explanation_pt = 'O arteméter e a lumefantrina são metabolizados pelo CYP3A4; a rifampicina é um indutor potente desta isoenzima e pode reduzir a exposição à lumefantrina em mais de 90% (AUC), com perda de eficácia antimalárica e risco de recidiva ou falência terapêutica. O rótulo aprovado da associação arteméter-lumefantrina contraindica a coadministração com rifampicina. Sempre que possível, deve escolher-se outro antimalárico ou ajustar a estratégia terapêutica; se a associação for inevitável, monitorizar de perto a resposta clínica e a parasitemia.',
  explanation_en = 'Artemether and lumefantrine are metabolised by CYP3A4; rifampicin is a potent inducer of this isoenzyme and can reduce lumefantrine exposure by more than 90% (AUC), with loss of antimalarial efficacy and risk of relapse or treatment failure. The approved artemether-lumefantrine label contraindicates co-administration with rifampicin. Whenever possible, another antimalarial or an adjusted therapeutic strategy should be chosen; if the combination is unavoidable, monitor clinical response and parasitaemia closely.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'));

-- 17/18 — SOTALOL + HIDROCLOROTIAZIDA (torsades de pointes)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tiazida + sotalol: a hipocaliemia (e hipomagnesiemia) induzida pelo diurético aumenta o risco de torsades de pointes. Corrigir eletrólitos antes e durante o tratamento e monitorizar o QT.',
  summary_pro_en = 'Thiazide + sotalol: diuretic-induced hypokalaemia (and hypomagnesaemia) increases the risk of torsades de pointes. Correct electrolytes before and during treatment and monitor the QT.',
  explanation_pt = 'O sotalol prolonga o intervalo QT (classe III) e o risco de torsades de pointes aumenta quando o potássio e o magnésio séricos descem. A hidroclorotiazida depleta estes eletrólitos e cria o ambiente eletrofisiológico para arritmias ventriculares polimórficas potencialmente fatais. A associação é frequente em doentes hipertensos e cardíacos, o que exige disciplina: manter o potássio sérico pelo menos em 4,0 mEq/L, corrigir a hipomagnesiemia, monitorizar o ECG (QT) e os eletrólitos durante o tratamento e evitar outros fármacos que prolonguem o QT.',
  explanation_en = 'Sotalol prolongs the QT interval (class III) and the risk of torsades de pointes rises as serum potassium and magnesium fall. Hydrochlorothiazide depletes these electrolytes and creates the electrophysiological environment for potentially fatal polymorphic ventricular arrhythmias. The combination is common in hypertensive and cardiac patients, which demands discipline: keep serum potassium at least at 4.0 mEq/L, correct hypomagnesaemia, monitor the ECG (QT) and electrolytes during treatment and avoid other QT-prolonging drugs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

-- 18/18 — VARFARINA + ÁCIDO ACETILSALICÍLICO (hemorragia major)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cumarínico + antiagregante: o risco de hemorragia major quase duplica (hemorragia intracraniana e gastrointestinal). Reservar a associação para indicações cardiológicas específicas; nos restantes, evitar.',
  summary_pro_en = 'Coumarin + antiplatelet agent: the risk of major bleeding nearly doubles (intracranial and gastrointestinal bleeding). Reserve the combination for specific cardiology indications; otherwise avoid.',
  explanation_pt = 'A aspirina inibe irreversivelmente a COX-1 plaquetária e a varfarina reduz os fatores de coagulação dependentes da vitamina K: os dois mecanismos somam-se e o risco de hemorragia major — incluindo hemorragia intracraniana e gastrointestinal — quase duplica em comparação com cada fármaco isolado. A associação só tem lugar em indicações específicas (ex.: síndrome coronária aguda com necessidade de anticoagulação, prótese valvular mecânica com doença aterosclerótica), sempre com o INR no limite inferior do intervalo alvo e proteção gástrica quando indicada. Fora dessas situações, a dupla terapêutica deve ser evitada, pesando sempre o risco hemorrágico individual.',
  explanation_en = 'Aspirin irreversibly inhibits platelet COX-1 and warfarin reduces the vitamin K-dependent clotting factors: the two mechanisms add up and the risk of major bleeding — including intracranial and gastrointestinal bleeding — nearly doubles compared with each drug alone. The combination is only indicated in specific situations (e.g. acute coronary syndrome requiring anticoagulation, mechanical valve prosthesis with atherosclerotic disease), always keeping the INR at the lower end of the target range and with gastric protection when indicated. Outside these situations, dual therapy should be avoided, always weighing the individual bleeding risk.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'));
