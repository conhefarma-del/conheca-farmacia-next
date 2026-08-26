-- =====================================================================
-- 222 — Explicações longas dos pares Anti-asma/COPD
--
-- 3 critical + 7 moderate = 10 pares
-- =====================================================================

-- ═══════════════════════════════════════════════════════════════════
-- CRITICAL
-- ═══════════════════════════════════════════════════════════════════

-- 1. Teofilina × Fluconazol (CRITICAL)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Fluconazol inibe CYP1A2, aumentando níveis de teofilina 30-50%. Risco de toxicidade (convulsões, arritmias).',
  summary_pro_en = 'Fluconazole inhibits CYP1A2, increasing theophylline levels 30-50%. Risk of toxicity (seizures, arrhythmias).',
  explanation_pt = 'A teofilina tem índice terapêutico estreito (10-20 μg/mL) e é metabolizada principalmente por CYP1A2 (70%). O fluconazol inibe CYP1A2 moderadamente, aumentando os níveis de teofilina 30-50%. Acima de 20 μg/mL, risco de náusea, vómitos e taquicardia. Acima de 30 μg/mL, risco de convulsões e arritmias ventriculares potencialmente fatais. O Prontuário Terapêutico recomenda: reduzir dose de teofilina 25-50%, monitorizar níveis semanalmente, e suspender se >20 μg/mL. Alternativa: trocar fluconazol por voriconazol (menos inibição CYP1A2) ou itraconazol.',
  explanation_en = 'Theophylline has a narrow therapeutic index (10-20 μg/mL) and is primarily metabolised by CYP1A2 (70%). Fluconazole moderately inhibits CYP1A2, increasing theophylline levels 30-50%. Above 20 μg/mL, risk of nausea, vomiting, and tachycardia. Above 30 μg/mL, risk of seizures and potentially fatal ventricular arrhythmias. The Prontuário Terapêutico recommends: reduce theophylline dose by 25-50%, monitor levels weekly, and discontinue if >20 μg/mL. Alternative: switch fluconazole to voriconazole (less CYP1A2 inhibition) or itraconazole.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fluconazol'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fluconazol'))
  AND drug_a_id != drug_b_id;

-- 2. Teofilina × Ritonavir (CRITICAL)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Ritonavir inibe CYP3A4/1A2 — efeito imprevisível sobre níveis de teofilina. Evitar combinação.',
  summary_pro_en = 'Ritonavir inhibits CYP3A4/1A2 — unpredictable effect on theophylline levels. Avoid combination.',
  explanation_pt = 'O ritonavir é um inibidor potente de CYP3A4 e pode inibir CYP1A2. A teofilina é substrato de CYP1A2 (70%) e CYP3A4 (15%). O efeito resultante é imprevisível — depende do fenótipo CYP do doente e das doses. Casos de toxicidade teofilina com ritonavir foram documentados. Não há guidelines específicas para esta combinação. Recomendação: evitar. Se inevitável, reduzir teofilina 50%, monitorizar níveis 2x/semana, e ter theophylline IV disponível para emergências.',
  explanation_en = 'Ritonavir is a potent CYP3A4 inhibitor and may inhibit CYP1A2. Theophylline is a CYP1A2 (70%) and CYP3A4 (15%) substrate. The resulting effect is unpredictable — depends on the patient''s CYP phenotype and doses. Cases of theophylline toxicity with ritonavir have been documented. There are no specific guidelines for this combination. Recommendation: avoid. If unavoidable, reduce theophylline by 50%, monitor levels 2x/week, and have IV theophylline available for emergencies.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'ritonavir'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'ritonavir'))
  AND drug_a_id != drug_b_id;

-- 3. Ritonavir × Roflumilast (CRITICAL)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Ritonavir inibe CYP3A4 — aumenta níveis de roflumilast e metabolito activo. CONTRAINDICADO.',
  summary_pro_en = 'Ritonavir inhibits CYP3A4 — increases roflumilast and active metabolite levels. CONTRAINDICATED.',
  explanation_pt = 'O roflumilast é metabolizado por CYP3A4 e CYP1A2 a roflumilast N-óxido (metabolito activo, 3-5x mais potente). O ritonavir inibe potente CYP3A4, aumentando drasticamente a exposição tanto ao roflumilast como ao N-óxido. A combinação está contraindicada nas guidelines EMA/FDA. Risco de toxicidade GI severa (diarreia, náusea), hepatotoxicidade e perda de peso excessiva. Alternativa em doentes VIH: montelucaste (não metabolizado por CYP) ou corticosteroide inalatório.',
  explanation_en = 'Roflumilast is metabolised by CYP3A4 and CYP1A2 to roflumilast N-oxide (active metabolite, 3-5x more potent). Ritonavir potently inhibits CYP3A4, drastically increasing exposure to both roflumilast and N-oxide. The combination is contraindicated in EMA/FDA guidelines. Risk of severe GI toxicity (diarrhoea, nausea), hepatotoxicity, and excessive weight loss. Alternative in HIV patients: montelukast (not CYP-metabolised) or inhaled corticosteroid.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'roflumilast'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'roflumilast'))
  AND drug_a_id != drug_b_id;

-- ═══════════════════════════════════════════════════════════════════
-- MODERATE
-- ═══════════════════════════════════════════════════════════════════

-- 4. Teofilina × Carbamazepina (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Carbamazepina induz CYP1A2, reduzindo teofilina 20-40%. Ajustar dose conforme níveis.',
  summary_pro_en = 'Carbamazepine induces CYP1A2, reducing theophylline 20-40%. Adjust dose based on levels.',
  explanation_pt = 'A carbamazepina é um potente indutor de CYP1A2, CYP3A4 e UGT. A teofilina é substrato de CYP1A2 (70%). A coadministração reduz os níveis de teofilina 20-40%, podendo comprometer o controlo de asma/COPD. Ajustar dose de teofilina conforme níveis (alvo: 10-20 μg/mL). Monitorizar mensalmente. A carbamazepina também pode induzir o metabolismo de outros fármacos concomitantes.',
  explanation_en = 'Carbamazepine is a potent inducer of CYP1A2, CYP3A4, and UGT. Theophylline is a CYP1A2 substrate (70%). Co-administration reduces theophylline levels 20-40%, potentially compromising asthma/COPD control. Adjust theophylline dose based on levels (target: 10-20 μg/mL). Monitor monthly. Carbamazepine may also induce metabolism of other concomitant drugs.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'carbamazepina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'carbamazepina'))
  AND drug_a_id != drug_b_id;

-- 5. Teofilina × Fenitoína (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Fenitoína induz CYP1A2, reduzindo teofilina 20-30%. Ajustar dose conforme níveis.',
  summary_pro_en = 'Phenytoin induces CYP1A2, reducing theophylline 20-30%. Adjust dose based on levels.',
  explanation_pt = 'A fenitoína induz CYP1A2 moderadamente, reduzindo os níveis de teofilina 20-30%. O efeito é menor que com carbamazepina. Ajustar dose de teofilina conforme níveis.',
  explanation_en = 'Phenytoin moderately induces CYP1A2, reducing theophylline levels 20-30%. The effect is less than with carbamazepine. Adjust theophylline dose based on levels.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fenitoina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fenitoina'))
  AND drug_a_id != drug_b_id;

-- 6. Teofilina × Fluoxetina (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Fluoxetina inibe fracamente CYP1A2, aumentando teofilina 10-20%. Efeito geralmente modesto.',
  summary_pro_en = 'Fluoxetine weakly inhibits CYP1A2, increasing theophylline 10-20%. Effect generally modest.',
  explanation_pt = 'A fluoxetina inibe fracamente CYP1A2. O efeito sobre os níveis de teofilina é geralmente modesto (10-20%), clinicamente significativo apenas em doses elevadas de fluoxetina (>40 mg/dia) ou em metabolizadores lentos de CYP2D6. Monitorizar níveis se dose elevada.',
  explanation_en = 'Fluoxetine weakly inhibits CYP1A2. The effect on theophylline levels is generally modest (10-20%), clinically significant only at high fluoxetine doses (>40 mg/day) or in CYP2D6 poor metabolisers. Monitor levels if high dose.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fluoxetina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'fluoxetina'))
  AND drug_a_id != drug_b_id;

-- 7. Teofilina × Warfarina (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Teofilina pode aumentar ligeiramente efeito da warfarina. Monitorizar INR.',
  summary_pro_en = 'Theophylline may slightly potentiate warfarin effect. Monitor INR.',
  explanation_pt = 'A teofilina pode competir parcialmente pelo metabolismo CYP1A2/CYP2C9 da warfarina, aumentando ligeiramente o INR. O efeito é geralmente modesto mas clinicamente relevante em doentes com INR already no limite superior. Monitorizar INR nas primeiras 2-3 semanas.',
  explanation_en = 'Theophylline may partially compete for CYP1A2/CYP2C9 metabolism of warfarin, slightly increasing INR. The effect is generally modest but clinically relevant in patients with INR already at the upper limit. Monitor INR during the first 2-3 weeks.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'warfarina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('teofilina', 'warfarina'))
  AND drug_a_id != drug_b_id;

-- 8. Fluconazol × Roflumilast (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Fluconazol inibe CYP3A4, aumentando roflumilast 20-30%. Monitorizar efeitos adversos.',
  summary_pro_en = 'Fluconazole inhibits CYP3A4, increasing roflumilast 20-30%. Monitor adverse effects.',
  explanation_pt = 'O fluconazol inibe CYP3A4, uma das vias metabolizadoras do roflumilast. Os níveis de roflumilast e do metabolito N-óxido podem aumentar 20-30%. Monitorizar efeitos adversos GI (diarreia, náusea) e função hepática. Reduzir dose se necessário.',
  explanation_en = 'Fluconazole inhibits CYP3A4, one of the metabolic pathways for roflumilast. Roflumilast and N-oxide metabolite levels may increase 20-30%. Monitor GI adverse effects (diarrhoea, nausea) and liver function. Reduce dose if necessary.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'roflumilast'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'roflumilast'))
  AND drug_a_id != drug_b_id;

-- 9. Prednisolona × Warfarina (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Corticosteroide pode induzir CYP3A4, reduzindo efeito da warfarina. Monitorizar INR.',
  summary_pro_en = 'Corticosteroid may induce CYP3A4, reducing warfarin effect. Monitor INR.',
  explanation_pt = 'Os corticosteroides sistémicos podem induzir CYP3A4, acelerando o metabolismo da warfarina e reduzindo o INR. O efeito é dose-dependente e mais pronunciado com doses altas (>20 mg/dia de prednisolona) e tratamentos prolongados (>2 semanas). Monitorizar INR durante e após疗程.',
  explanation_en = 'Systemic corticosteroids may induce CYP3A4, accelerating warfarin metabolism and reducing INR. The effect is dose-dependent and more pronounced at high doses (>20 mg/day prednisolone) and prolonged treatments (>2 weeks). Monitor INR during and after course.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('prednisolona', 'warfarina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('prednisolona', 'warfarina'))
  AND drug_a_id != drug_b_id;

-- 10. Fluconazol × Prednisolona (MODERATE)
UPDATE public.drug_interactions SET
  summary_pro_pt = 'Fluconazol inibe CYP3A4, aumentando prednisolona. Risco de hipercortisolismo.',
  summary_pro_en = 'Fluconazole inhibits CYP3A4, increasing prednisolone. Risk of hypercortisolism.',
  explanation_pt = 'A prednisolona é metabolizada por CYP3A4. O fluconazol inibe CYP3A4, aumentando a exposição à prednisolona. O efeito pode ser significativo com doses elevadas. Monitorizar sinais de hipercortisolismo (glicemia elevada, ganho de peso, hipertensão, osteoporose). Considerar reduzir dose de prednisolona 25-50%.',
  explanation_en = 'Prednisolone is metabolised by CYP3A4. Fluconazole inhibits CYP3A4, increasing prednisolone exposure. The effect may be significant at high doses. Monitor for signs of hypercortisolism (elevated glucose, weight gain, hypertension, osteoporosis). Consider reducing prednisolone dose by 25-50%.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'prednisolona'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('fluconazol', 'prednisolona'))
  AND drug_a_id != drug_b_id;
