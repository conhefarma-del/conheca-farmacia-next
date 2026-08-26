-- =====================================================================
-- 204 — Explicações longas dos pares antidiabéticos (Fluxo 4)
--
-- Pares: critical (1) + moderate (2) da migração 203
-- Formato: summary_pro (resumo técnico) + explanation PT/EN
-- Fontes: DailyMed/FDA, EMC-UK
-- =====================================================================

-- =====================================================================
-- 1. Pares CRÍTICOS
-- =====================================================================

-- 1.1 furosemida × empagliflozina
UPDATE public.drug_interactions
SET summary_pro_pt = 'SGLT2 + diurético de alça: desidratação severa e hipotensão. Efeito diurético aditivo — glicosúria osmótica + natriurese. Reduzir diurético e monitorizar eletrólitos.',
    summary_pro_en = 'SGLT2 + loop diuretic: severe dehydration and hypotension. Additive diuretic effect — osmotic glycosuria + natriuresis. Reduce diuretic and monitor electrolytes.',
    explanation_pt = 'O SGLT2 provoca glicosúria (~70 g/dia), que arrasta sódio e água por osmose. A furosemida inibe o cotransportador Na-K-2Cl no alça de Henle, bloqueando a reabsorção de sódio. A combinação sinérgica pode causar: (1) perda de volume extracelular severa, (2) hipotensão ortostática com risco de síncope, (3) desidratação com elevação de creatinina, (4) hipercalemia paradoxal (por hipoperfusão renal). Estratégia: reduzir a dose do diurético 24-48h antes de iniciar o SGLT2, monitorizar peso diário, eletrólitos semanalmente e TA em pé/deitado.',
    explanation_en = 'SGLT2 causes glycosuria (~70 g/day), which drags sodium and water by osmosis. Furosemide inhibits the Na-K-2Cl cotransporter in the loop of Henle, blocking sodium reabsorption. The synergistic combination can cause: (1) severe extracellular volume depletion, (2) orthostatic hypotension with syncope risk, (3) dehydration with creatinine elevation, (4) paradoxical hyperkalaemia (from renal hypoperfusion). Strategy: reduce diuretic dose 24-48h before starting SGLT2, monitor daily weight, weekly electrolytes, and standing/supine BP.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Empagliflozina (Jardiance): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Empagliflozin (Jardiance) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'furosemida')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'empagliflozina');

-- =====================================================================
-- 2. Pares MODERADOS
-- =====================================================================

-- 2.1 metformina × canagliflozina
UPDATE public.drug_interactions
SET summary_pro_pt = 'SGLT2 + biguanida: risco de desidratação e acidose láctica. Metformina requer hidratação adequada. Monitorizar TFG e eletrólitos.',
    summary_pro_en = 'SGLT2 + biguanide: risk of dehydration and lactic acidosis. Metformin requires adequate hydration. Monitor GFR and electrolytes.',
    explanation_pt = 'A metformina é excretada renalmente e requer uma TFG >30 mL/min para prevenir acumulação e acidose láctica. A canagliflozina provoca perda de volume (glicosúria + diurese osmótica) que pode reduzir a TFG e aumentar os níveis de metformina. Risco particularmente elevado em: (1) idosos, (2) doentes com TFG limítrofe (30-45), (3) uso concomitante de diuréticos, (4) desidratação por doença aguda. Estratégia: verificar TFG antes e 3 meses após iniciar SGLT2. Suspender SGLT2 se desidratado ou TFG <45.',
    explanation_en = 'Metformin is renally excreted and requires eGFR >30 mL/min to prevent accumulation and lactic acidosis. Canagliflozin causes volume loss (glycosuria + osmotic diuresis) that may reduce eGFR and increase metformin levels. Particularly elevated risk in: (1) elderly, (2) patients with borderline eGFR (30-45), (3) concomitant diuretic use, (4) dehydration from acute illness. Strategy: check eGFR before and 3 months after starting SGLT2. Discontinue SGLT2 if dehydrated or eGFR <45.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Canagliflozina (Invokana): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b9057d3b-b104-4f09-8a61-c61ef9d4a3f3',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Canagliflozin (Invokana) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b9057d3b-b104-4f09-8a61-c61ef9d4a3f3'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'metformina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'canagliflozina');

-- 2.2 saxagliptina × cetoconazol
UPDATE public.drug_interactions
SET summary_pro_pt = 'DPP-4 + antifúngico azólico: CYP3A4 inibido, níveis de saxagliptina aumentados ~2,5x. Reduzir dose para 2,5 mg/dia.',
    summary_pro_en = 'DPP-4 + azole antifungal: CYP3A4 inhibited, saxagliptin levels increased ~2.5-fold. Reduce dose to 2.5 mg/day.',
    explanation_pt = 'A saxagliptina é metabolizada pelo CYP3A4 ao metabolito ativo 5-hidrox.saxagliptina (contribui ~50% da atividade). O cetoconazol inibe potente o CYP3A4, aumentando os níveis de saxagliptina em ~2,5 vezes e reduzindo a formação do metabolito ativo. A AUC total de atividade aumenta moderadamente. A FDA recomenda reduzir a dose para 2,5 mg/dia quando coadministrada com inibidores fortes de CYP3A4 (cetoconazol, itraconazol, claritromicina).',
    explanation_en = 'Saxagliptin is metabolised by CYP3A4 to the active metabolite 5-hydroxy saxagliptin (~50% of activity). Ketoconazole potently inhibits CYP3A4, increasing saxagliptin levels ~2.5-fold and reducing active metabolite formation. Total activity AUC increases moderately. The FDA recommends reducing dose to 2.5 mg/day when coadministered with strong CYP3A4 inhibitors (ketoconazole, itraconazole, clarithromycin).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Saxagliptina (Onglyza): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c5116390-e0fe-4969-94cb-e9de5165fbab',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Saxagliptin (Onglyza) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c5116390-e0fe-4969-94cb-e9de5165fbab'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'saxagliptina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'cetoconazol');
