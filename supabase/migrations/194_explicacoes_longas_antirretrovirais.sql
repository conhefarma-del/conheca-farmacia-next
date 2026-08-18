-- =====================================================================
-- 194 — Explicações longas (Fluxo 4) dos 13 pares de antirretrovirais
--
-- Preenche summary_pro_pt/en e explanation_pt/en dos pares criados na 192
-- Fontes: DailyMed/FDA (NIH/NLM) — rótulos aprovados
-- Padrão: 7.1 (UPDATE com LEAST/GREATEST canónico)
-- =====================================================================

-- =====================================================================
-- 1. DOLUTEGRAVIR × RIFAMPICINA (critical)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dolutegravir + rifampicina: redução de ~54% nos níveis de dolutegravir por indução do UGT1A1. Aumentar dose para 50 mg 2x/dia.',
  summary_pro_en = 'Dolutegravir + rifampicin: ~54% reduction in dolutegravir levels via UGT1A1 induction. Increase dose to 50 mg twice daily.',
  explanation_pt = 'A rifampicina é um dos indutores enzimáticos mais potentes, atuando principalmente sobre o UGT1A1 (enzima de glucuronização do dolutegravir) e secundariamente sobre o CYP3A4. Estudos farmacocinéticos demonstraram que a coadministração reduz a AUC do dolutegravir em 54% e a Cmáx em 36%, comprometendo significativamente a supressão viral. A OMS e os rótulos FDA recomendam o aumento da dose de dolutegravir para 50 mg duas vezes ao dia quando coadministrado com rifampicina, mantendo a eficácia antirretroviral. Esta ajuste deve ser mantido durante toda a duração do tratamento com rifampicina e 2 semanas após a sua suspensão. Alternativa: rifabutina (indução mais fraca, dose de 150 mg/dia com dolutegravir 50 mg 1x/dia).',
  explanation_en = 'Rifampicin is one of the most potent enzyme inducers, acting primarily on UGT1A1 (the glucuronidation enzyme for dolutegravir) and secondarily on CYP3A4. Pharmacokinetic studies demonstrated that coadministration reduces dolutegravir AUC by 54% and Cmax by 36%, significantly compromising viral suppression. WHO and FDA labels recommend increasing dolutegravir dose to 50 mg twice daily when coadministered with rifampicin, maintaining antiretroviral efficacy. This adjustment should be maintained throughout rifampicin treatment and for 2 weeks after discontinuation. Alternative: rifabutin (weaker induction, 150 mg/day with dolutegravir 50 mg once daily).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- =====================================================================
-- 2. DOLUTEGRAVIR × CARBAMAZEPINA (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dolutegravir + carbamazepina: redução dos níveis de dolutegravir por indução do UGT1A1/CYP3A4. Considerar aumento de dose ou alternativa.',
  summary_pro_en = 'Dolutegravir + carbamazepine: reduced dolutegravir levels via UGT1A1/CYP3A4 induction. Consider dose increase or alternative.',
  explanation_pt = 'A carbamazepina induz o UGT1A1 e o CYP3A4, enzimas envolvidas no metabolismo do dolutegravir. Embora a indução seja menos potente que a da rifampicina, a redução dos níveis pode ser clinicamente significativa, especialmente em doentes com carga viral alta ou resistência pré-existente. O rótulo do dolutegravir (Tivicay) recomenda o aumento da dose para 50 mg duas vezes ao dia quando coadministrado com indutores moderados do UGT1A1 como a carbamazepina. Alternativa: considerar trocar a carbamazepina por um antiepiléptico sem indução enzimática significativa (ex.: levetiracetam, lamotrigina) ou usar raltegravir (não metabolizado pelo CYP3A4) como alternativa INSTI.',
  explanation_en = 'Carbamazepine induces UGT1A1 and CYP3A4, enzymes involved in dolutegravir metabolism. Although the induction is less potent than rifampicin, the reduction in levels may be clinically significant, especially in patients with high viral load or pre-existing resistance. The dolutegravir label (Tivicay) recommends increasing the dose to 50 mg twice daily when coadministered with moderate UGT1A1 inducers such as carbamazepine. Alternative: consider switching carbamazepine to an antiepileptic without significant enzyme induction (e.g. levetiracetam, lamotrigine) or use raltegravir (not metabolised by CYP3A4) as an alternative INSTI.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

-- =====================================================================
-- 3. DOLUTEGRAVIR × FENITOÍNA (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dolutegravir + fenitoína: redução dos níveis de dolutegravir por indução do UGT1A1. Considerar aumento de dose.',
  summary_pro_en = 'Dolutegravir + phenytoin: reduced dolutegravir levels via UGT1A1 induction. Consider dose increase.',
  explanation_pt = 'A fenitoína induz o UGT1A1, enzima responsável pela glucuronização do dolutegravir, reduzindo os seus níveis plasmáticos. O rótulo do dolutegravir recomenda o aumento da dose para 50 mg duas vezes ao dia quando coadministrado com indutores do UGT1A1. A monitorização da carga viral é essencial. Alternativa: considerar trocar a fenitoína por levetiracetam ou lamotrigina (sem indução enzimática significativa) ou usar raltegravir como alternativa INSTI.',
  explanation_en = 'Phenytoin induces UGT1A1, the enzyme responsible for dolutegravir glucuronidation, reducing its plasma levels. The dolutegravir label recommends increasing the dose to 50 mg twice daily when coadministered with UGT1A1 inducers. Viral load monitoring is essential. Alternative: consider switching phenytoin to levetiracetam or lamotrigine (without significant enzyme induction) or use raltegravir as an alternative INSTI.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'fenitoína'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dolutegravir'), (SELECT id FROM public.drugs WHERE slug = 'fenitoína'));

-- =====================================================================
-- 4. RILPIVIRINA × OMEPRAZOL (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rilpivirina + omeprazol: PPI reduz absorção da rilpivirina em ~40-50%. Evitar coadministração ou usar H2B com intervalo.',
  summary_pro_en = 'Rilpivirine + omeprazole: PPI reduces rilpivirine absorption by ~40-50%. Avoid coadministration or use H2B with interval.',
  explanation_pt = 'A rilpivirina é uma base fraca que requer pH gástrico ácido (pH <3) para dissolução e absorção adequadas. Os inibidores da bomba de protões como o omeprazol elevam o pH gástrico para >4, reduzindo significativamente a biodisponibilidade oral da rilpivirina (~40-50% de redução na AUC). O rótulo da rilpivirina (Edurant) lista os PPIs como contraindicação relativa. Alternativa: se um antiácido for necessário, usar um antagonista H2 (ranitidina 150 mg) com pelo menos 12 horas de intervalo, ou antiácidos de alumínio/magnésio com 4 horas de intervalo. Monitorizar carga viral se PPI for inevitável.',
  explanation_en = 'Rilpivirine is a weak base that requires acidic gastric pH (pH <3) for adequate dissolution and absorption. Proton pump inhibitors like omeprazole raise gastric pH to >4, significantly reducing rilpivirine oral bioavailability (~40-50% reduction in AUC). The rilpivirine label (Edurant) lists PPIs as a relative contraindication. Alternative: if an antacid is needed, use an H2-receptor antagonist (ranitidine 150 mg) with at least 12 hours apart, or aluminium/magnesium antacids with 4 hours apart. Monitor viral load if PPI is unavoidable.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rilpivirina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rilpivirina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- =====================================================================
-- 5. RILPIVIRINA × ANTIÁCIDOS (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rilpivirina + antiácidos: catiões polivalentes (Al³⁺/Mg²⁺) reduzem absorção. Intervalo de 4 horas.',
  summary_pro_en = 'Rilpivirine + antacids: polyvalent cations (Al³⁺/Mg²⁺) reduce absorption. 4-hour interval.',
  explanation_pt = 'Os antiácidos contendo catiões polivalentes (hidróxido de alumínio, hidróxido de magnésio) podem formar complexos insolúveis com a rilpivirina no tracto gastrointestinal, reduzindo a sua absorção. O efeito é menos marcado que o dos PPIs, mas clinicamente relevante se os antiácidos forem usados regularmente. O rótulo da rilpivirina recomenda um intervalo de pelo menos 4 horas entre a toma de antiácidos e rilpivirina. Para doentes que necessitam de antiácidos frequentes, considerar alternativas como ranitidina (H2B) ou omeprazol (com as restrições acima).',
  explanation_en = 'Antacids containing polyvalent cations (aluminium hydroxide, magnesium hydroxide) may form insoluble complexes with rilpivirine in the gastrointestinal tract, reducing its absorption. The effect is less marked than PPIs but clinically relevant if antacids are used regularly. The rilpivirine label recommends an interval of at least 4 hours between antacid and rilpivirine administration. For patients requiring frequent antacids, consider alternatives such as ranitidine (H2B) or omeprazole (with the restrictions above).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rilpivirina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rilpivirina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

-- =====================================================================
-- 6. TENOFOVIR × METFORMINA (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tenofovir + metformina: ambos eliminados renalmente. Risco de toxicidade aditiva e acidose láctica. Monitorizar função renal.',
  summary_pro_en = 'Tenofovir + metformine: both renally eliminated. Risk of additive toxicity and lactic acidosis. Monitor renal function.',
  explanation_pt = 'Tenofovir e metformina são ambos eliminados essencialmente por via renal — o tenofovir por filtração glomerular e secreção tubular, e a metformina por secreção tubular via OCT2. A coadministração pode competir pela secreção tubular, potencialmente elevando os níveis de ambos. O risco principal é a nefrotoxicidade aditiva: o tenofovir pode causar nephrotoxicity tubular proximal (síndrome de Fanconi), enquanto a metformina requer função renal adequada para prevenir acumulação e acidose láctica. Recomendação: avaliar TFG antes de iniciar e monitorizar periodicamente (creatinina, eletrólitos, proteinúria). Ajustar dose de metformina se TFG <30 mL/min. Considerar alternativa ao tenofovir (entecavir) se houver deterioração renal.',
  explanation_en = 'Tenofovir and metformine are both essentially eliminated renally — tenofovir by glomerular filtration and tubular secretion, metformine by tubular secretion via OCT2. Coadministration may compete for tubular secretion, potentially elevating levels of both. The main risk is additive nephrotoxicity: tenofovir may cause proximal tubular nephrotoxicity (Fanconi syndrome), while metformine requires adequate renal function to prevent accumulation and lactic acidosis. Recommendation: assess GFR before initiation and monitor periodically (creatinine, electrolytes, proteinuria). Adjust metformine dose if GFR <30 mL/min. Consider alternative to tenofovir (entecavir) if renal deterioration occurs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tenofovir'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tenofovir'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- =====================================================================
-- 7. LOPINAVIR/RITONAVIR × ATORVASTATINA (critical)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Lopinavir/r + atorvastatina: inibição CYP3A4 → níveis de atorvastatina elevados 4-8x. Risco de miopatia/rabdomiólise. Evitar ou limitar a 10 mg/dia.',
  summary_pro_en = 'Lopinavir/r + atorvastatin: CYP3A4 inhibition → atorvastatin levels elevated 4-8x. Risk of myopathy/rhabdomyolysis. Avoid or limit to 10 mg/day.',
  explanation_pt = 'O ritonavir (potenciador do lopinavir) é um inibidor potente e irreversível do CYP3A4, enzima principal do metabolismo da atorvastatina. Estudos farmacocinéticos demonstraram que a coadministração com ritonavir (400 mg 2x/dia) eleva a AUC da atorvastatina em 4-8 vezes e a Cmáx em 3-5 vezes. Esta acumulação significativa aumenta drasticamente o risco de miopatia (dor muscular, fraqueza, elevação de CK) e rabdomiólise (degradação muscular com risco de insuficiência renal aguda e hipercalemia potencialmente fatal). O rótulo do lopinavir/ritonavir (Kaletra) e da atorvastatina recomendam limitar a atorvastatina a 10 mg/dia quando coadministrado com inibidores potentes do CYP3A4. Alternativa preferencial: pravastatina ou rosuvastatina (não dependem de CYP3A4 para metabolismo). Se atorvastatina for inevitável, monitorizar CK semanalmente nos primeiros meses.',
  explanation_en = 'Ritonavir (lopinavir booster) is a potent and irreversible CYP3A4 inhibitor, the main enzyme of atorvastatin metabolism. Pharmacokinetic studies demonstrated that coadministration with ritonavir (400 mg twice daily) elevates atorvastatin AUC by 4-8 fold and Cmax by 3-5 fold. This significant accumulation drastically increases the risk of myopathy (muscle pain, weakness, CK elevation) and rhabdomyolysis (muscle breakdown with risk of acute renal failure and potentially fatal hyperkalaemia). The lopinavir/ritonavir (Kaletra) and atorvastatin labels recommend limiting atorvastatin to 10 mg/day when coadministered with potent CYP3A4 inhibitors. Preferred alternative: pravastatin or rosuvastatin (CYP3A4-independent metabolism). If atorvastatin is unavoidable, monitor CK weekly during the first months.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'lopinavir-ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'lopinavir-ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'));

-- =====================================================================
-- 8. ETRAVIRINA × RIFAMPICINA (critical)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Etravirina + rifampicina: contraindicada. Redução de ~80% nos níveis de etravirina por indução potente do CYP3A4/CYP2C19.',
  summary_pro_en = 'Etravirine + rifampicin: contraindicated. ~80% reduction in etravirine levels via potent CYP3A4/CYP2C19 induction.',
  explanation_pt = 'A rifampicina é o indutor enzimático mais potente disponível, atuando sobre múltiplas enzimas incluindo CYP3A4, CYP2C19, CYP2C9 e UGT1A1. A etravirina é metabolizada principalmente pelo CYP3A4 e CYP2C19. Estudos farmacocinéticos demonstraram que a rifampicina reduz a AUC da etravirina em ~80% e a Cmáx em ~70%, praticamente anulando a sua atividade antirretroviral. O rótulo da etravirina (Intelence) lista a rifampicina como contraindicação absoluta. A coadministração quase garantiria falha virológica e seleção de resistência. Alternativa: rifabutina (indução mais fraca) com ajuste de dose de etravirina para 400 mg duas vezes ao dia, ou usar outro regime antirretroviral que não dependa de etravirina.',
  explanation_en = 'Rifampicin is the most potent enzyme inducer available, acting on multiple enzymes including CYP3A4, CYP2C19, CYP2C9 and UGT1A1. Etravirine is metabolised primarily by CYP3A4 and CYP2C19. Pharmacokinetic studies demonstrated that rifampicin reduces etravirine AUC by ~80% and Cmax by ~70%, virtually abolishing its antiretroviral activity. The etravirine label (Intelence) lists rifampicin as an absolute contraindication. Coadministration would almost certainly lead to virological failure and resistance selection. Alternative: rifabutin (weaker induction) with etravirine dose adjustment to 400 mg twice daily, or use another antiretroviral regimen that does not depend on etravirine.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'etravirina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'etravirina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- =====================================================================
-- 9. ABACAVIR × LAMIVUDINA (none — combinação intencional)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Abacavir + lamivudina: combinação intencional de 1ª linha (2 NRTIs). Sem interação adversa — sinergia terapêutica.',
  summary_pro_en = 'Abacavir + lamivudine: intentional first-line combination (2 NRTIs). No adverse interaction — therapeutic synergy.',
  explanation_pt = 'Abacavir e lamivudina são frequentemente associados como backbone NRTI em regimes de primeira linha para HIV (ex.: ABC + 3TC + DTG, ou ABC + 3TC + EFV). Ambos atuam como análogos de nucleosídeos/nucleotídeos da transcriptase reversa, mas não competem significativamente pelas mesmas vias metabólicas — o abacavir é metabolizado pelo álcool deshidrogenase e UGT1A1, enquanto a lamivudina é excretada essencialmente inalterada por via renal. A combinação é sinérgica e bem tolerada, com perfil de efeitos colaterais complementar. A dose padrão é abacavir 600 mg + lamivudina 300 mg, uma vez ao dia (formulação fixa disponível). O único requisito prévio é o teste HLA-B*5701 antes de iniciar abacavir.',
  explanation_en = 'Abacavir and lamivudine are frequently combined as the NRTI backbone in first-line HIV regimens (e.g. ABC + 3TC + DTG, or ABC + 3TC + EFV). Both act as nucleoside/nucleotide reverse transcriptase analogues, but do not significantly compete for the same metabolic pathways — abacavir is metabolised by alcohol dehydrogenase and UGT1A1, while lamivudine is excreted essentially unchanged renally. The combination is synergistic and well tolerated, with a complementary side effect profile. The standard dose is abacavir 600 mg + lamivudine 300 mg, once daily (fixed-dose combination available). The only prerequisite is HLA-B*571 testing before starting abacavir.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'abacavir'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'abacavir'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'));

-- =====================================================================
-- 10. DIDANOSINA × ESTAVUDINA (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Didanosina + estavudina: toxicidade mitocondrial aditiva. Risco aumentado de neuropatia, pancreatite e acidose láctica. Evitar.',
  summary_pro_en = 'Didanosine + stavudine: additive mitochondrial toxicity. Increased risk of neuropathy, pancreatitis and lactic acidosis. Avoid.',
  explanation_pt = 'Didanosina e estavudina são ambos NRTIs que inibem a ADN polimerase mitocondrial (DNA polimerase gama), causando depleção de ADN mitocondrial e disfunção celular. A associação potencia esta toxicidade de forma aditiva: estudos demonstraram que a coadministração aumenta a incidência de neuropatia periférica de 15-20% (monoterapia) para 30-40%, e o risco de pancreatite e acidose láctica também é significativamente elevado. A neuropatia periférica manifesta-se por formigueiro, dormência e dor nos pés e mãos, progredindo para fraqueza motora. A pancreatite pode ser fulminante. A acidose láctica é potencialmente fatal. Recomendação: EVITAR a coadministração. Se ambos forem necessários (regime de resgate), usar a menor dose possível de cada e monitorar atentamente sintomas, amilase, lipase e ácido láctico.',
  explanation_en = 'Didanosine and stavudine are both NRTIs that inhibit mitochondrial DNA polymerase (DNA polymerase gamma), causing mitochondrial DNA depletion and cellular dysfunction. The combination potentiates this toxicity additively: studies demonstrated that coadministration increases the incidence of peripheral neuropathy from 15-20% (monotherapy) to 30-40%, and the risk of pancreatitis and lactic acidosis is also significantly elevated. Peripheral neuropathy manifests as tingling, numbness and pain in the feet and hands, progressing to motor weakness. Pancreatitis can be fulminant. Lactic acidosis is potentially fatal. Recommendation: AVOID coadministration. If both are required (rescue regimen), use the lowest possible dose of each and closely monitor symptoms, amylase, lipase and lactic acid.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'didanosina'), (SELECT id FROM public.drugs WHERE slug = 'estavudina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'didanosina'), (SELECT id FROM public.drugs WHERE slug = 'estavudina'));

-- =====================================================================
-- 11. DARUNAVIR × CETOCONAZOL (moderate)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Darunavir + cetoconazol: inibição CYP3A4 pode elevar níveis de darunavir. Limitar cetoconazol a 200 mg/dia.',
  summary_pro_en = 'Darunavir + ketoconazole: CYP3A4 inhibition may raise darunavir levels. Limit ketoconazole to 200 mg/day.',
  explanation_pt = 'O cetoconazol é um inibidor potente do CYP3A4. O darunavir, quando potenciado pelo ritonavir ou cobicistat, já tem níveis plasmáticos significativamente elevados. A adição de cetoconazol pode causar acumulação excessiva, aumentando o risco de efeitos colaterais (náuseas, hepatotoxicidade, prolongamento do QT). O rótulo do darunavir (Prezista) recomenda limitar a dose de cetoconazol a 200 mg/dia quando coadministrado. Alternativa preferencial: itraconazol (metabolizado de forma diferente) ou antifúngicos tópicos. Se cetoconazol for necessário, monitorizar transaminases e sinais de toxicidade.',
  explanation_en = 'Ketoconazole is a potent CYP3A4 inhibitor. Darunavir, when boosted by ritonavir or cobicistat, already has significantly elevated plasma levels. Adding ketoconazole may cause excessive accumulation, increasing the risk of side effects (nausea, hepatotoxicity, QT prolongation). The darunavir label (Prezista) recommends limiting ketoconazole dose to 200 mg/day when coadministered. Preferred alternative: itraconazole (different metabolism) or topical antifungals. If ketoconazole is necessary, monitor transaminases and signs of toxicity.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'darunavir'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'darunavir'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- =====================================================================
-- 12. RALTEGRAVIR × METFORMINA (minor)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Raltegravir + metformina: elevação aparente da creatinina (inibe secreção tubular). Sem efeito na TFG real — não requer ajuste.',
  summary_pro_en = 'Raltegravir + metformine: apparent creatinine elevation (inhibits tubular secretion). No effect on actual GFR — no adjustment needed.',
  explanation_pt = 'O raltegravir inibe o transportador OCT2/creatinina no rim tubular proximal, elevando a creatinina sérica em 0,1-0,3 mg/dL sem alteração da taxa de filtração glomerular (TFG) real. Esta elevação é aparente e não reflete disfunção renal. A metformina é eliminada por secreção tubular via OCT2, mas o efeito do raltegravir sobre a creatinina não se traduz em acumulação clinicamente significativa de metformina. Não é necessário ajustar a dose de metformina. No entanto, a interpretação da creatinina sérica deve ter em conta o efeito do raltegravir — usar a TFG calculada (eGFR) em vez da creatinina isolada para avaliar a função renal.',
  explanation_en = 'Raltegravir inhibits the OCT2/creatinine transporter in the proximal renal tubule, raising serum creatinine by 0.1-0.3 mg/dL without actual change in glomerular filtration rate (GFR). This elevation is apparent and does not reflect renal dysfunction. Metformine is eliminated by tubular secretion via OCT2, but the effect of raltegravir on creatinine does not translate to clinically significant metformine accumulation. No metformine dose adjustment is required. However, serum creatinine interpretation should account for the raltegravir effect — use calculated GFR (eGFR) instead of creatinine alone to assess renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'raltegravir'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'raltegravir'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- =====================================================================
-- 13. EMTRICITABINA × LAMIVUDINA (moderate — evitar duplicação)
-- =====================================================================
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Emtricitabina + lamivudina: mecanismo idêntico (análogos da citosina). Não coadministrar — sem benefício aditivo.',
  summary_pro_en = 'Emtricitabine + lamivudine: identical mechanism (cytosine analogues). Do not coadminister — no additive benefit.',
  explanation_pt = 'Emtricitabina e lamivudina são ambos análogos da citosina que atuam como terminadores de cadeia na transcriptase reversa do HIV. Têm mecanismo de ação idêntico, perfil de resistência cruzada e vias de eliminação similares (ambos eliminados essencialmente por via renal). A coadministração não oferece sinergia clinicamente significativa — apenas duplica os efeitos colaterais potenciais (náuseas, cefaleia, elevação de transaminases) sem benefício antirretroviral aditivo. Na prática clínica, apenas um dos dois é escolhido como backbone NRTI (geralmente lamivudina por ser mais estudado e com formulações de dose fixa mais disponíveis). A combinação FTC/TDF (Truvada) é uma opção, mas não com lamivudina.',
  explanation_en = 'Emtricitabine and lamivudine are both cytosine analogues that act as chain terminators on HIV reverse transcriptase. They have identical mechanisms of action, cross-resistance profiles and elimination pathways (both essentially renally eliminated). Coadministration does not offer clinically significant synergy — it only doubles potential side effects (nausea, headache, elevated transaminases) without additive antiretroviral benefit. In clinical practice, only one of the two is chosen as the NRTI backbone (usually lamivudine as it is better studied and has more available fixed-dose formulations). The FTC/TDF combination (Truvada) is an option, but not with lamivudine.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'emtricitabina'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'emtricitabina'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'));
