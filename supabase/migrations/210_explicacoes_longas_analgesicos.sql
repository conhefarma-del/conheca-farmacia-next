-- =====================================================================
-- 210 — Explicações longas dos pares críticos/moderados de Analgésicos
--
-- Formato: UPDATE de summary_pro + explanation PT/EN nos pares existentes
-- Executar APÓS a migração 209
-- =====================================================================

-- =====================================================================
-- PAR 1: Indometacina × Lítio (CRITICAL)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + lítio: níveis de lítio aumentados 15-30%. Risco de toxicidade por lítio (tremor, confusão, convulsões). Monitorizar níveis de lítio semanalmente.',
  summary_pro_en = 'NSAID + lithium: lithium levels increased 15-30%. Risk of lithium toxicity (tremor, confusion, seizures). Monitor lithium levels weekly.',
  explanation_pt = 'A indometacina é o AINE com maior efeito sobre os níveis de lítio. O mecanismo principal é a redução da clearance renal do lítio via inibição da prostaglandina E2 no rim. As prostaglandinas regulam o fluxo sanguíneo renal e a reabsorção tubular — a sua inibição reduz a excreção de lítio em 15-30%. O efeito é dose-dependente e mais pronunciado nos primeiros 5-7 dias de tratamento concomitante. Outros AINE (ibuprofeno, naproxeno) também aumentam os níveis de lítio, mas em menor grau (5-15%). A toxicidade por lítio manifesta-se inicialmente com tremor fino, náusea e diarreia, progredindo para confusão, ataxia e convulsões. O intervalo terapêutico do lítio é estreito (0,6-1,2 mEq/L), pelo que pequenas alterações podem ter consequências clínicas significativas.',
  explanation_en = 'Indomethacin has the greatest effect on lithium levels among NSAIDs. The main mechanism is reduced renal lithium clearance via inhibition of prostaglandin E2 in the kidney. Prostaglandins regulate renal blood flow and tubular reabsorption — their inhibition reduces lithium excretion by 15-30%. The effect is dose-dependent and most pronounced during the first 5-7 days of concomitant treatment. Other NSAIDs (ibuprofen, naproxen) also increase lithium levels, but to a lesser degree (5-15%). Lithium toxicity initially manifests with fine tremor, nausea, and diarrhoea, progressing to confusion, ataxia, and seizures. The therapeutic window of lithium is narrow (0.6-1.2 mEq/L), so small changes can have significant clinical consequences.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'indometacina')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'litio');

-- =====================================================================
-- PAR 2: Ritonavir × Metadona (CRITICAL)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor de CYP3A4 potente + opioide: níveis de metadona aumentados 2-4x. Risco de sedação excessiva, depressão respiratória e prolongamento do QTc.',
  summary_pro_en = 'Potent CYP3A4 inhibitor + opioid: methadone levels increased 2-4-fold. Risk of excessive sedation, respiratory depression, and QTc prolongation.',
  explanation_pt = 'O ritonavir é um inibidor potente de CYP3A4 e CYP2B6, as principais enzimas metabolizadoras da metadona. O CYP2B6 é responsável por ~70% do metabolismo da metadona, e o CYP3A4 contribui com ~20%. A coadministração com ritonavir pode aumentar os níveis de metadona em 2-4x, dependendo da dose de ritonavir e do polimorfismo genético do CYP2B6. Metabolizadores lentos de CYP2B6 (frequência ~2-5% em populações africanas) têm risco ainda maior. A metadona prolonga o QTc — o aumento dos níveis pode causar torsades de pointes. Monitorizar QTc antes e durante a coadministração. Se QTc >500 ms, considerar alternativa ao ritonavir ou reduzir dose de metadona.',
  explanation_en = 'Ritonavir is a potent inhibitor of CYP3A4 and CYP2B6, the main enzymes metabolising methadone. CYP2B6 is responsible for ~70% of methadone metabolism, and CYP3A4 contributes ~20%. Co-administration with ritonavir can increase methadone levels 2-4-fold, depending on ritonavir dose and CYP2B6 genetic polymorphism. CYP2B6 poor metabolisers (frequency ~2-5% in African populations) have even higher risk. Methadone prolongs QTc — increased levels may cause torsades de pointes. Monitor QTc before and during co-administration. If QTc >500 ms, consider ritonavir alternative or reduce methadone dose.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'ritonavir')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'metadona');

-- =====================================================================
-- PAR 3: Ketorolaco × Warfarina (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE injectável potente + anticoagulante: risco aumentado de hemorragia. Inibição plaquetária + efeito anticoagulante. Duração máxima: 5 dias.',
  summary_pro_en = 'Potent injectable NSAID + anticoagulant: increased bleeding risk. Platelet inhibition + anticoagulant effect. Maximum duration: 5 days.',
  explanation_pt = 'O ketorolaco é o AINE com maior actividade antiagregante plaquetária entre os administrados por via parenteral. Inibe fortemente COX-1 plaquetário, reduzindo a agregação durante toda a vida da plaqueta (7-10 dias). A warfarina anticoagula via inibição dos factores de coagulação dependentes de vitamina K. A combinação de inibição plaquetária + anticoagulação multiplica o risco de hemorragia, especialmente gastrointestinal. Estudos observacionais mostram um risco relativo de 2-4x para hemorragia GI com AINE + anticoagulantes. O ketorolaco tem a restrição de duração máxima de 5 dias (parenteral) precisamente devido ao elevado risco de toxicidade.',
  explanation_en = 'Ketorolac has the highest platelet antiaggregant activity among parenterally administered NSAIDs. It strongly inhibits platelet COX-1, reducing aggregation for the entire platelet lifespan (7-10 days). Warfarin anticoagulates via inhibition of vitamin K-dependent coagulation factors. The combination of platelet inhibition + anticoagulation multiplies the bleeding risk, especially gastrointestinal. Observational studies show a relative risk of 2-4x for GI bleeding with NSAIDs + anticoagulants. Ketorolac has a maximum duration restriction of exactly 5 days (parenteral) due to its high toxicity risk.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'ketorolaco')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'warfarina');

-- =====================================================================
-- PAR 4: Piroxicam × Warfarina (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE de meia-vida longa + anticoagulante: risco aumentado de hemorragia. Meia-vida de 50 h prolonga exposição. Preferir AINE curto.',
  summary_pro_en = 'Long half-life NSAID + anticoagulant: increased bleeding risk. 50 h half-life prolongs exposure. Prefer short NSAID.',
  explanation_pt = 'A meia-vida extremamente longa do piroxicam (50-100 h) resulta em exposição prolongada ao efeito antiagregante plaquetário. Ao contrário de AINE de meia-vida curta (ibuprofeno: 2 h), o piroxicam mantém a inibição plaquetária durante dias após a última dose. Em doentes anticoagulados com warfarina, isto significa um período prolongado de risco hemorrágico. O risco relativo de hemorragia GI é superior ao de outros AINE. Recomendação: se um AINE for necessário em doentes warfarinizados, preferir ibuprofeno (meia-vida curta, inibição plaquetária reversível mais rápida) ou naproxeno com monitorização.',
  explanation_en = 'The extremely long half-life of piroxicam (50-100 h) results in prolonged exposure to the platelet antiaggregant effect. Unlike short half-life NSAIDs (ibuprofen: 2 h), piroxicam maintains platelet inhibition for days after the last dose. In patients anticoagulated with warfarin, this means a prolonged bleeding risk period. The relative risk of GI bleeding is higher than with other NSAIDs. Recommendation: if an NSAID is needed in warfarinised patients, prefer ibuprofen (short half-life, faster reversible platelet inhibition) or naproxen with monitoring.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'piroxicam')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'warfarina');

-- =====================================================================
-- PAR 5: Indometacina × Metotrexato (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE potente + antimetabolito: clearance renal do metotrexato reduzido. Risco de toxicidade (mielossupressão, mucosite, hepatotoxicidade).',
  summary_pro_en = 'Potent NSAID + antimetabolite: methotrexate renal clearance reduced. Risk of toxicity (myelosuppression, mucositis, hepatotoxicity).',
  explanation_pt = 'A indometacina reduz o fluxo sanguíneo renal e a secreção tubular do metotrexato, que é maioritariamente excretado por via renal (80-90% inalterado). A redução da clearance pode aumentar os níveis de metotrexato em 20-50%, dependendo da dose e função renal. O metotrexato em doses elevadas (>100 mg/m²) é especialmente perigoso com AINE — o risco de pancitopenia, mucosite grave e hepatotoxicidade aumenta significativamente. Em doses baixas (10-25 mg/semana para artrite), o risco é menor mas permanece relevante. Monitorizar hemograma (leucócitos, plaquetas) e enzimas hepáticas.',
  explanation_en = 'Indomethacin reduces renal blood flow and tubular secretion of methotrexate, which is primarily excreted renally (80-90% unchanged). Reduced clearance can increase methotrexate levels by 20-50%, depending on dose and renal function. High-dose methotrexate (>100 mg/m²) is especially dangerous with NSAIDs — the risk of pancytopenia, severe mucositis, and hepatotoxicity increases significantly. At low doses (10-25 mg/week for arthritis), the risk is lower but remains relevant. Monitor blood count (leukocytes, platelets) and hepatic enzymes.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'indometacina')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'metotrexato');

-- =====================================================================
-- PAR 6: Fluconazol × Metadona (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor de CYP3A4 + opioide: níveis de metadona aumentados 1,5-2x. Risco de sedação e depressão respiratória.',
  summary_pro_en = 'CYP3A4 inhibitor + opioid: methadone levels increased 1.5-2-fold. Risk of sedation and respiratory depression.',
  explanation_pt = 'O fluconazol inibe moderadamente o CYP3A4, uma das vias metabolizadoras da metadona (responsável por ~20% do metabolismo). O efeito é menos pronunciado que com ritonavir ou cetoconazol, mas clinicamente significativo. Os níveis de metadona podem aumentar 1,5-2x, especialmente em metabolizadores lentos de CYP2D6 que dependem mais do CYP3A4. A monitorização deve incluir sedação, frequência respiratória e ECG (QTc). O efeito é mais pronunciado com doses elevadas de fluconazol (>200 mg/dia) e tratamentos prolongados.',
  explanation_en = 'Fluconazole moderately inhibits CYP3A4, one of the metabolic pathways for methadone (responsible for ~20% of metabolism). The effect is less pronounced than with ritonavir or ketoconazole, but clinically significant. Methadone levels may increase 1.5-2-fold, especially in CYP2D6 poor metabolisers who depend more on CYP3A4. Monitoring should include sedation, respiratory rate, and ECG (QTc). The effect is more pronounced with high fluconazole doses (>200 mg/day) and prolonged treatments.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'fluconazol')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'metadona');

-- =====================================================================
-- PAR 7: Ketorolaco × Metotrexato (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE injectável + antimetabolito: clearance renal do metotrexato reduzido. Risco de toxicidade em doses altas.',
  summary_pro_en = 'Injectable NSAID + antimetabolite: methotrexate renal clearance reduced. Risk of toxicity at high doses.',
  explanation_pt = 'O ketorolaco, como outros AINE, reduz o fluxo sanguíneo renal e a secreção tubular do metotrexato. O efeito é mais relevante em doses altas de metotrexato (>100 mg/m²) onde a clearance renal é crítica. Em doses baixas (10-25 mg/semana), o impacto é menor. A administração parenteral do ketorolaco (como frequentemente utilizado em dor aguda) pode coincidir com tratamento com metotrexato — verificar sempre a medicação concomitante antes de administrar ketorolaco.',
  explanation_en = 'Ketorolac, like other NSAIDs, reduces renal blood flow and tubular secretion of methotrexate. The effect is more relevant at high methotrexate doses (>100 mg/m²) where renal clearance is critical. At low doses (10-25 mg/week), the impact is smaller. Parenteral ketorolac administration (as frequently used in acute pain) may coincide with methotrexate treatment — always check concomitant medication before administering ketorolac.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'ketorolaco')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'metotrexato');

-- =====================================================================
-- PAR 8: Meloxicam × Warfarina (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE selectivo COX-2 + anticoagulante: risco aumentado de hemorragia, mas inferior a AINE não selectivos.',
  summary_pro_en = 'COX-2 selective NSAID + anticoagulant: increased bleeding risk, but lower than non-selective NSAIDs.',
  explanation_pt = 'O meloxicam tem preferência por COX-2 (selectividade ~10:1 em doses de 7,5 mg), o que resulta em menor inibição da COX-1 plaquetária comparado com AINE não selectivos (ibuprofeno, piroxicam). No entanto, a selectividade não é absoluta — em doses de 15 mg, o efeito sobre COX-1 aumenta significativamente. O risco de hemorragia GI permanece presente, especialmente em doses elevadas e em doentes de risco. Monitorizar INR e sinais de hemorragia. Considerar dose baixa (7,5 mg/dia) para minimizar risco.',
  explanation_en = 'Meloxicam has COX-2 preference (selectivity ~10:1 at 7.5 mg doses), resulting in less platelet COX-1 inhibition compared to non-selective NSAIDs (ibuprofen, piroxicam). However, selectivity is not absolute — at 15 mg doses, the COX-1 effect increases significantly. GI bleeding risk remains present, especially at higher doses and in at-risk patients. Monitor INR and signs of bleeding. Consider low dose (7.5 mg/day) to minimise risk.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'meloxicam')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'warfarina');

-- =====================================================================
-- PAR 9: Indometacina × Vancomicina (MODERATE)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + glicopeptídeo: nefrotoxicidade aditiva. Ambos são potencialmente nefrotóxicos.',
  summary_pro_en = 'NSAID + glycopeptide: additive nephrotoxicity. Both are potentially nephrotoxic.',
  explanation_pt = 'A indometacina reduz o fluxo sanguíneo renal via inibição de prostaglandinas, enquanto a vancomicina é directamente nefrotóxica (necrose tubular aguda). A combinação pode causar insuficiência renal agida, especialmente em doentes idosos, desidratados ou com função renal basal comprometida. O risco é maior com doses elevadas de vancomicina (AUC/MIC >400) e tratamentos prolongados (>7 dias). Monitorizar creatinina, TFG e volume urinário. Se creatinina aumentar >30% basal, considerar interromper um dos fármacos.',
  explanation_en = 'Indomethacin reduces renal blood flow via prostaglandin inhibition, while vancomycin is directly nephrotoxic (acute tubular necrosis). The combination may cause acute renal failure, especially in elderly, dehydrated patients, or those with compromised baseline renal function. Risk is higher with high vancomycin doses (AUC/MIC >400) and prolonged treatment (>7 days). Monitor creatinine, GFR, and urine output. If creatinine increases >30% from baseline, consider discontinuing one of the drugs.'
WHERE drug_a_id = (SELECT id FROM drugs WHERE slug = 'indometacina')
  AND drug_b_id = (SELECT id FROM drugs WHERE slug = 'vancomicina');
