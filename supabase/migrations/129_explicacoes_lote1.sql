-- =====================================================================
-- 129 — Explicações fármaco-fármaco dos pares moderados restantes (lote 1)
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) de 19 pares moderados sem explicação: ritonavir (5), voriconazol
-- restantes (3), clopidogrel/anticoagulação (5), praziquantel/efavirenz,
-- clozapina/fluoxetina, dexametasona/fenitoína e antimaláricos (3).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED / EMA (EPAR Eurartesim) para a diidroartemisinina-piperaquina.
-- Mecanismos centrais:
--   CYP3A4 potente (ritonavir, voriconazol): sildenafil, praziquantel,
--   dexametasona, amlodipina; CYP2C9 (voriconazol+glibenclamida);
--   hemorragia aditiva (clopidogrel + enoxaparina/DOACs, ácido
--   tranexâmico + enoxaparina); indução do CYP3A4 (efavirenz+prazi-
--   quantel, fenitoína+dexametasona); serotonina/CYP (clozapina+
--   fluoxetina); QT aditivo (arteméter-lumefantrina e diidroartemisinin-
--   piperaquina + mefloquina); hipoglicemia aditiva (hidroxicloroquina+
--   metformina).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/19 — RITONAVIR + SILDENAFIL (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ritonavir + sildenafil: o ritonavir inibe o CYP3A4 e aumenta muito os níveis de sildenafil. DE: dose inicial 25 mg/48h; HP: contraindicado.',
  summary_pro_en = 'Ritonavir + sildenafil: ritonavir inhibits CYP3A4 and greatly raises sildenafil levels. ED: 25 mg starting dose every 48h; PH: contraindicated.',
  explanation_pt = 'O sildenafil é metabolizado pelo CYP3A4, e o ritonavir (inibidor potente) aumenta as suas concentrações de forma marcada: o rótulo do ritonavir recomenda para a disfunção erétil "sildenafil 25 mg a cada 48 horas" e contraindica o sildenafil (Revatio) na hipertensão pulmonar; o rótulo lista os eventos adversos associados ao sildenafil — anomalias visuais, hipotensão, ereção prolongada e síncope. O aumento dos níveis de sildenafil potenciar o risco de hipotensão, cefaleia, rubor, dispepsia, priapismo e alterações visuais. Na disfunção erétil, nunca exceder 25 mg a cada 48 horas; na hipertensão pulmonar, a associação é contraindicada — procurar alternativa.',
  explanation_en = 'Sildenafil is metabolised by CYP3A4, and ritonavir (a potent inhibitor) markedly raises its concentrations: the ritonavir label recommends for erectile dysfunction "sildenafil 25 mg every 48 hours" and contraindicates sildenafil (Revatio) in pulmonary hypertension; the label lists the sildenafil-associated adverse events — visual abnormalities, hypotension, prolonged erection and syncope. Raised sildenafil levels potentiate the risk of hypotension, headache, flushing, dyspepsia, priapism and visual disturbances. For erectile dysfunction, never exceed 25 mg every 48 hours; for pulmonary hypertension, the combination is contraindicated — seek an alternative.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'));

-- 2/19 — PRAZIQUANTEL + RITONAVIR (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Praziquantel + ritonavir: o ritonavir inibe o CYP3A4 e aumenta os níveis de praziquantel. Vigiar efeitos adversos (cefaleia, tonturas, convulsões).',
  summary_pro_en = 'Praziquantel + ritonavir: ritonavir inhibits CYP3A4 and raises praziquantel levels. Watch for adverse effects (headache, dizziness, seizures).',
  explanation_pt = 'O praziquantel é rapidamente metabolizado pelo sistema enzimático do citocromo P450 (CYP3A4) e sofre efeito de primeira passagem; o rótulo do praziquantel refere explicitamente que "os inibidores do CYP450, por exemplo cimetidina, cetoconazol, itraconazol, eritromicina e ritonavir, podem aumentar as concentrações plasmáticas de praziquantel". Níveis aumentados potenciam os efeitos adversos (cefaleia, tonturas, desconforto abdominal, náuseas, urticária e, em doentes suscetíveis, convulsões ou arritmias — bradicardia, fibrilhação ventricular e bloqueios AV foram observados). Monitorizar o doente durante o tratamento (geralmente 1 dia de terapêutica) e ponderar dose mais baixa em doentes com doença hepática, onde a exposição já está aumentada.',
  explanation_en = 'Praziquantel is rapidly metabolised by the cytochrome P450 enzyme system (CYP3A4) and undergoes first-pass effect; the praziquantel label explicitly states that "CYP450 inhibitors, for example cimetidine, ketoconazole, itraconazole, erythromycin and ritonavir, may increase praziquantel plasma concentrations". Raised levels potentiate the adverse effects (headache, dizziness, abdominal discomfort, nausea, urticaria and, in susceptible patients, seizures or arrhythmias — bradycardia, ventricular fibrillation and AV blocks have been observed). Monitor the patient during treatment (usually 1 day of therapy) and consider a lower dose in patients with liver disease, where exposure is already increased.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'praziquantel'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'praziquantel'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 3/19 — DEXAMETASONA + RITONAVIR (CYP3A4 — corticosteroides ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + ritonavir: o ritonavir inibe o CYP3A4 e aumenta os níveis de dexametasona. Vigiar excesso de corticoide (Cushing, supressão adrenal).',
  summary_pro_en = 'Dexamethasone + ritonavir: ritonavir inhibits CYP3A4 and raises dexamethasone levels. Watch for corticosteroid excess (Cushing, adrenal suppression).',
  explanation_pt = 'A dexametasona é metabolizada pelo CYP3A4, e o ritonavir é um inibidor potente desta enzima: a associação aumenta a exposição ao corticoide, com risco de excesso de corticosteroide — síndrome de Cushing, supressão adrenal, hiperglicemia, retenção de sódio e líquidos, perda de potássio e imunossupressão (o rótulo da dexametasona lista perda de potássio, alcalose hipocaliémica e supressão do eixo adrenal entre as reações adversas). A associação ocorre sobretudo em doentes com VIH que necessitam de corticosteroides; usar a menor dose eficaz, vigiar sinais de excesso de corticoide e a função adrenal, e considerar a redução da dose de dexametasona. Nota: a dexametasona também induz o CYP3A4 — em regimes potenciados com ritonavir, avaliar o impacto nos inibidores da protease.',
  explanation_en = 'Dexamethasone is metabolised by CYP3A4, and ritonavir is a potent inhibitor of this enzyme: the combination raises corticosteroid exposure, with a risk of corticosteroid excess — Cushing syndrome, adrenal suppression, hyperglycaemia, sodium and fluid retention, potassium loss and immunosuppression (the dexamethasone label lists potassium loss, hypokalaemic alkalosis and adrenal axis suppression among the adverse reactions). The combination occurs mainly in HIV patients needing corticosteroids; use the lowest effective dose, watch for signs of corticosteroid excess and adrenal function, and consider reducing the dexamethasone dose. Note: dexamethasone also induces CYP3A4 — in ritonavir-boosted regimens, evaluate the impact on the protease inhibitors.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 4/19 — LEVOCETIRIZINA + RITONAVIR (sedação aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levocetirizina + ritonavir: risco aditivo de sedação/sonolência. Vigiar, sobretudo em doentes com compromisso renal ou hepático.',
  summary_pro_en = 'Levocetirizine + ritonavir: additive risk of sedation/drowsiness. Monitor, especially with renal or hepatic impairment.',
  explanation_pt = 'A levocetirizina é eliminada predominantemente por via renal (sem metabolismo hepático significativo), pelo que a interação farmacocinética com o ritonavir é limitada; o risco clínico é a sedação aditiva — o rótulo da levocetirizina adverte para a sonolência e para o aumento do efeito com álcool, sedativos e tranquilizantes, e o ritonavir também causa fadiga e sintomas do SNC. Em doentes com compromisso renal ou hepático (nos quais a levocetirizina acumula e a dose deve ser reduzida) e em idosos, a associação exige vigilância: monitorizar sonolência, tonturas e capacidade de conduzir, e usar a menor dose eficaz de levocetirizina.',
  explanation_en = 'Levocetirizine is predominantly eliminated renally (without significant hepatic metabolism), so the pharmacokinetic interaction with ritonavir is limited; the clinical risk is additive sedation — the levocetirizine label warns about drowsiness and the increased effect with alcohol, sedatives and tranquillisers, and ritonavir also causes fatigue and CNS symptoms. In patients with renal or hepatic impairment (in whom levocetirizine accumulates and the dose should be reduced) and in the elderly, the combination requires vigilance: monitor drowsiness, dizziness and driving ability, and use the lowest effective levocetirizine dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'levocetirizina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levocetirizina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 5/19 — CETIRIZINA + RITONAVIR (sedação aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetirizina + ritonavir: risco aditivo de sedação/sonolência. Vigiar, sobretudo em doentes com compromisso renal ou hepático.',
  summary_pro_en = 'Cetirizine + ritonavir: additive risk of sedation/drowsiness. Monitor, especially with renal or hepatic impairment.',
  explanation_pt = 'A cetirizina é eliminada predominantemente por via renal, com metabolismo hepático mínimo, pelo que a interação farmacocinética com o ritonavir é limitada; o risco clínico é a sedação aditiva — o rótulo da cetirizina adverte para a sonolência e para o aumento do efeito com álcool, sedativos e tranquilizantes, e o ritonavir também causa fadiga e sintomas do SNC. Em doentes com compromisso renal ou hepático (nos quais a cetirizina acumula e a dose deve ser reduzida — o rótulo recomenda consultar o médico) e em idosos, a associação exige vigilância: monitorizar sonolência, tonturas e capacidade de conduzir, e usar a menor dose eficaz de cetirizina.',
  explanation_en = 'Cetirizine is predominantly eliminated renally, with minimal hepatic metabolism, so the pharmacokinetic interaction with ritonavir is limited; the clinical risk is additive sedation — the cetirizine label warns about drowsiness and the increased effect with alcohol, sedatives and tranquillisers, and ritonavir also causes fatigue and CNS symptoms. In patients with renal or hepatic impairment (in whom cetirizine accumulates and the dose should be reduced — the label recommends asking a doctor) and in the elderly, the combination requires vigilance: monitor drowsiness, dizziness and driving ability, and use the lowest effective cetirizine dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetirizina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetirizina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 6/19 — SILDENAFIL + VORICONAZOL (QT + CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sildenafil + voriconazol: o voriconazol inibe o CYP3A4 e aumenta os níveis de sildenafil. Considerar dose inicial de 25 mg; vigiar hipotensão e QT.',
  summary_pro_en = 'Sildenafil + voriconazole: voriconazole inhibits CYP3A4 and raises sildenafil levels. Consider a 25 mg starting dose; watch hypotension and QT.',
  explanation_pt = 'O sildenafil é metabolizado pelo CYP3A4, e o voriconazol é um inibidor forte desta enzima: o rótulo do sildenafil recomenda "considerar uma dose inicial de 25 mg em doentes tratados com inibidores fortes do CYP3A4 (ex.: cetoconazol, itraconazol, saquinavir) ou eritromicina". O voriconazol também prolonga o QT (o rótulo refere que "alguns azóis, incluindo o voriconazol, foram associados a prolongamento do intervalo QT" e recomenda corrigir potássio, magnésio e cálcio antes do uso), e o sildenafil em níveis elevados pode causar hipotensão, cefaleia, rubor e alterações visuais. Usar a dose eficaz mais baixa de sildenafil (não exceder 25 mg), espaçar as tomas, vigiar a pressão arterial e os sinais de hipotensão.',
  explanation_en = 'Sildenafil is metabolised by CYP3A4, and voriconazole is a strong inhibitor of this enzyme: the sildenafil label recommends "considering a starting dose of 25 mg in patients treated with strong CYP3A4 inhibitors (e.g. ketoconazole, itraconazole, saquinavir) or erythromycin". Voriconazole also prolongs the QT (the label states that "some azoles, including voriconazole, have been associated with prolongation of the QT interval" and recommends correcting potassium, magnesium and calcium before use), and sildenafil at high levels can cause hypotension, headache, flushing and visual disturbances. Use the lowest effective sildenafil dose (not exceeding 25 mg), space the doses, monitor blood pressure and signs of hypotension.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));

-- 7/19 — GLIBENCLAMIDA + VORICONAZOL (CYP2C9 — hipoglicemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Glibenclamida + voriconazol: o voriconazol inibe o CYP2C9 e aumenta os níveis da glibenclamida. Monitorizar glicemia e ajustar a dose da sulfonilureia.',
  summary_pro_en = 'Glyburide + voriconazole: voriconazole inhibits CYP2C9 and raises glyburide levels. Monitor glycaemia and adjust the sulfonylurea dose.',
  explanation_pt = 'A glibenclamida é metabolizada pelo CYP2C9 (e CYP3A4), e o voriconazol é um inibidor do CYP2C9 e do CYP3A4: a associação aumenta as concentrações da sulfonilureia e o risco de hipoglicemia — mecanismo análogo ao documentado com o fluconazol (AUC da glibenclamida +44% e 5 de 20 voluntários a precisarem de glucose oral no estudo do rótulo do fluconazol). O voriconazol também prolonga o QT e pode causar hepatotoxicidade. Monitorizar a glicemia de perto no início da associação e sempre que a dose do antifúngico mudar, avisar o doente para os sinais de hipoglicemia (sudorese, tremor, palpitações, confusão) e considerar reduzir a dose da glibenclamida.',
  explanation_en = 'Glyburide is metabolised by CYP2C9 (and CYP3A4), and voriconazole inhibits CYP2C9 and CYP3A4: the combination raises the sulfonylurea concentrations and the risk of hypoglycaemia — a mechanism analogous to that documented with fluconazole (glyburide AUC +44% and 5 of 20 volunteers requiring oral glucose in the fluconazole label study). Voriconazole also prolongs the QT and can cause hepatotoxicity. Monitor glycaemia closely at the start of the combination and whenever the antifungal dose changes, warn the patient about hypoglycaemia signs (sweating, tremor, palpitations, confusion) and consider reducing the glyburide dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));

-- 8/19 — AMLODIPINA + VORICONAZOL (CYP3A4 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amlodipina + voriconazol: o voriconazol inibe o CYP3A4 e aumenta os níveis de amlodipina. Vigiar hipotensão e edema; considerar reduzir a dose.',
  summary_pro_en = 'Amlodipine + voriconazole: voriconazole inhibits CYP3A4 and raises amlodipine levels. Watch hypotension and oedema; consider a dose reduction.',
  explanation_pt = 'A amlodipina é metabolizada pelo CYP3A4 e o rótulo refere que "a coadministração com inibidores do CYP3A (moderados e fortes) resulta num aumento da exposição sistémica à amlodipina e pode exigir redução da dose" (com diltiazem, um inibidor moderado, a exposição aumentou 60%). O voriconazol é um inibidor forte do CYP3A4, pelo que a associação aumenta os níveis de amlodipina e os seus efeitos dose-dependentes: hipotensão, edema periférico, rubor, cefaleia e tonturas, sobretudo em idosos. Vigiar a pressão arterial e os sinais de sobredosagem relativa; se a associação for necessária, considerar iniciar com dose mais baixa de amlodipina ou reduzir a dose, monitorizando o doente nas primeiras semanas.',
  explanation_en = 'Amlodipine is metabolised by CYP3A4 and the label states that "co-administration with CYP3A inhibitors (moderate and strong) results in increased systemic exposure to amlodipine and may require dose reduction" (with diltiazem, a moderate inhibitor, exposure increased by 60%). Voriconazole is a strong CYP3A4 inhibitor, so the combination raises amlodipine levels and its dose-dependent effects: hypotension, peripheral oedema, flushing, headache and dizziness, especially in the elderly. Monitor blood pressure and signs of relative overdose; if the combination is needed, consider starting with a lower amlodipine dose or reducing it, monitoring the patient in the first weeks.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));

-- 9/19 — CLOPIDOGREL + ENOXAPARINA (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clopidogrel + enoxaparina: hemorragia aditiva (antiagregante + anticoagulante). Vigiar sinais de hemorragia; usar com precaução extrema.',
  summary_pro_en = 'Clopidogrel + enoxaparina: additive bleeding (antiplatelet + anticoagulant). Watch for bleeding signs; use with extreme caution.',
  explanation_pt = 'O clopidogrel (inibidor do P2Y12) e a enoxaparina (heparina de baixo peso molecular) atuam em vias diferentes da hemostase e o risco de hemorragia é aditivo: o rótulo do clopidogrel refere que "os inibidores do P2Y12, incluindo o clopidogrel, aumentam o risco de hemorragia" e que o risco aumenta "com o uso concomitante de outros fármacos que aumentam o risco de hemorragia"; o da enoxaparina adverte que o risco de hematomas epidurais aumenta com "o uso concomitante de outros fármacos que afetam a hemostase, como AINEs, inibidores plaquetários e outros anticoagulantes" e recomenda precaução extrema com inibidores plaquetários. A associação é usada em contextos específicos (ex.: síndromes coronárias agudas sob intervenção, durante curto período de transição), mas exige: vigiar hemorragias (incluindo retroperitoneais e intracranianas), monitorizar o hemograma, e cumprir os intervalos recomendados entre doses em procedimentos (ex.: retirada do cateter epidural 12–24h após a dose de enoxaparina).',
  explanation_en = 'Clopidogrel (a P2Y12 inhibitor) and enoxaparin (a low molecular weight heparin) act on different haemostasis pathways and the bleeding risk is additive: the clopidogrel label states that "P2Y12 inhibitors, including clopidogrel, increase the risk of bleeding" and that the risk increases "with the concomitant use of other drugs that increase the risk of bleeding"; the enoxaparin label warns that the risk of epidural haematomas increases with "the concomitant use of other drugs that affect haemostasis, such as NSAIDs, platelet inhibitors and other anticoagulants" and recommends extreme caution with platelet inhibitors. The combination is used in specific settings (e.g. acute coronary syndromes under intervention, during a short transition period), but requires: monitoring for bleeding (including retroperitoneal and intracranial), blood count monitoring, and respecting the recommended intervals between doses around procedures (e.g. epidural catheter removal 12–24h after the enoxaparin dose).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'));

-- 10/19 — CLOPIDOGREL + DABIGATRANO (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clopidogrel + dabigatrano: hemorragia aditiva (antiagregante + anticoagulante). Vigiar hemorragia e função renal.',
  summary_pro_en = 'Clopidogrel + dabigatran: additive bleeding (antiplatelet + anticoagulant). Watch bleeding and renal function.',
  explanation_pt = 'O clopidogrel inibe a agregação plaquetária e o dabigatrano inibe diretamente a trombina; a combinação soma os efeitos anticoagulantes e aumenta o risco de hemorragia major, incluindo hemorragia intracraniana e gastrointestinal. O rótulo do dabigatrano refere que o risco de hemorragia aumenta com o uso concomitante de "outros medicamentos que afetam a hemostase, incluindo agentes antiplaquetários" e adverte para o risco acrescido em doentes idosos, com insuficiência renal ou com baixo peso; o do clopidogrel refere que o risco de hemorragia aumenta com "o uso concomitante de outros fármacos que aumentam o risco de hemorragia". A associação é evitada na prática (a dupla/tríplice terapêutica em fibrilhação auricular usa-se por períodos curtos e com critérios restritos — ex.: após stent). Se utilizada, vigiar sinais de hemorragia, a função renal (o dabigatrano é eliminado por via renal) e considerar redução de dose do dabigatrano.',
  explanation_en = 'Clopidogrel inhibits platelet aggregation and dabigatran directly inhibits thrombin; the combination adds up the anticoagulant effects and increases the risk of major bleeding, including intracranial and gastrointestinal bleeding. The dabigatran label states that the bleeding risk increases with the concomitant use of "other drugs affecting haemostasis, including antiplatelet agents" and warns about the added risk in elderly patients, with renal impairment or low body weight; the clopidogrel label states that the bleeding risk increases with "the concomitant use of other drugs that increase the risk of bleeding". The combination is avoided in practice (dual/triple therapy in atrial fibrillation is used for short periods and with restricted criteria — e.g. after stenting). If used, monitor for bleeding signs, renal function (dabigatran is renally eliminated) and consider a dabigatran dose reduction.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'dabigatrano'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'dabigatrano'));

-- 11/19 — CLOPIDOGREL + RIVAROXABANO (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clopidogrel + rivaroxabano: hemorragia aditiva (antiagregante + anticoagulante). Vigiar hemorragia; combinação de curta duração em contextos restritos.',
  summary_pro_en = 'Clopidogrel + rivaroxaban: additive bleeding (antiplatelet + anticoagulant). Watch bleeding; short-duration combination in restricted settings.',
  explanation_pt = 'O clopidogrel inibe a agregação plaquetária e o rivaroxabano inibe o fator Xa; a associação soma os efeitos na hemostase e aumenta o risco de hemorragia major. O rótulo do rivaroxabano refere explicitamente que "o clopidogrel e o uso crónico de AINEs podem aumentar o risco de hemorragia" e recomenda precaução com o uso concomitante de "antiagregantes, outros antitrombóticos, fibrinolíticos e AINEs"; o do clopidogrel refere que o risco aumenta com "o uso concomitante de outros fármacos que aumentam o risco de hemorragia". A dupla terapêutica rivaroxabano 2,5 mg + aspirina/clopidogrel está aprovada em contextos específicos (doença arterial coronária/periférica com CAD/PAD) por períodos definidos, mas a associação com clopidogrel em geral deve ser evitada. Vigiar sinais de hemorragia (incluindo intracraniana e GI) e a função renal.',
  explanation_en = 'Clopidogrel inhibits platelet aggregation and rivaroxaban inhibits factor Xa; the combination adds up the effects on haemostasis and increases the risk of major bleeding. The rivaroxaban label explicitly states that "clopidogrel and chronic NSAID use may increase the risk of bleeding" and recommends caution with the concomitant use of "antiplatelet agents, other antithrombotics, fibrinolytics and NSAIDs"; the clopidogrel label states that the risk increases with "the concomitant use of other drugs that increase the risk of bleeding". Dual therapy rivaroxaban 2.5 mg + aspirin/clopidogrel is approved in specific settings (coronary/peripheral artery disease with CAD/PAD) for defined periods, but the combination with clopidogrel in general should be avoided. Monitor for bleeding signs (including intracranial and GI) and renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'));

-- 12/19 — APIXABANO + CLOPIDOGREL (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Apixabano + clopidogrel: hemorragia aditiva (anticoagulante + antiagregante). Vigiar hemorragia; associação de curta duração em contextos restritos.',
  summary_pro_en = 'Apixaban + clopidogrel: additive bleeding (anticoagulant + antiplatelet). Watch bleeding; short-duration combination in restricted settings.',
  explanation_pt = 'O apixabano inibe o fator Xa e o clopidogrel inibe a agregação plaquetária: o rótulo do apixabano refere que "a coadministração com agentes antiplaquetários, fibrinolíticos, heparina, aspirina e uso crónico de AINEs aumenta o risco de hemorragia" e documenta um ensaio com clopidogrel "terminado precocemente devido a uma taxa mais elevada de hemorragia com o apixabano comparado com placebo"; o do clopidogrel refere que o risco aumenta com "o uso concomitante de outros fármacos que aumentam o risco de hemorragia". A associação só deve ser usada em contextos restritos (ex.: curta duração após síndrome coronária aguda com fibrilhação auricular) e com vigilância apertada: monitorizar hemorragias (incluindo GI e intracranianas), hemograma e função renal, e reavaliar a duração da terapêutica combinada.',
  explanation_en = 'Apixaban inhibits factor Xa and clopidogrel inhibits platelet aggregation: the apixaban label states that "co-administration with antiplatelet agents, fibrinolytics, heparin, aspirin and chronic NSAID use increases the risk of bleeding" and documents a trial with clopidogrel "terminated early due to a higher rate of bleeding with apixaban compared to placebo"; the clopidogrel label states that the risk increases with "the concomitant use of other drugs that increase the risk of bleeding". The combination should only be used in restricted settings (e.g. short duration after acute coronary syndrome with atrial fibrillation) and with close monitoring: watch for bleeding (including GI and intracranial), blood count and renal function, and reassess the duration of the combined therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'clopidogrel'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'clopidogrel'));

-- 13/19 — ÁCIDO TRANEXÂMICO + ENOXAPARINA (hemostase oposta)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ácido tranexâmico + enoxaparina: antifibrinolítico + anticoagulante — mecanismos opostos na hemostase. Avaliar risco/benefício e vigiar trombose/hemorragia.',
  summary_pro_en = 'Tranexamic acid + enoxaparin: antifibrinolytic + anticoagulant — opposing haemostasis mechanisms. Assess risk/benefit and watch thrombosis/bleeding.',
  explanation_pt = 'Não existe interação farmacocinética documentada entre o ácido tranexâmico (antifibrinolítico — inibe a dissolução da fibrina pela plasmina) e a enoxaparina (anticoagulante); o problema é a combinação de mecanismos opostos na hemostase: o rótulo do ácido tranexâmico contraindica o fármaco em doentes com doença tromboembólica ativa ou risco intrínseco de trombose, e o da enoxaparina adverte para o risco hemorrágico com fármacos que afetam a hemostase. A associação ocorre em situações de hemorragia aguda em doentes anticoagulados (ex.: trauma, hemorragia major) onde o antifibrinolítico é usado para controlo hemorrágico — decisão clínica de risco/benefício. Durante a associação, vigiar sinais de hemorragia e de trombose (TVP, TEP, oclusão vascular) e monitorizar o hemograma; o ácido tranexâmico deve ser suspenso se surgirem sintomas visuais ou suspeita de oclusão retiniana.',
  explanation_en = 'There is no documented pharmacokinetic interaction between tranexamic acid (an antifibrinolytic — it inhibits fibrin dissolution by plasmin) and enoxaparin (an anticoagulant); the problem is the combination of opposing haemostasis mechanisms: the tranexamic acid label contraindicates the drug in patients with active thromboembolic disease or an intrinsic risk of thrombosis, and the enoxaparin label warns about the bleeding risk with drugs that affect haemostasis. The combination occurs in acute bleeding situations in anticoagulated patients (e.g. trauma, major haemorrhage) where the antifibrinolytic is used for bleeding control — a clinical risk/benefit decision. During the combination, watch for bleeding and thrombosis signs (DVT, PE, vascular occlusion) and monitor the blood count; tranexamic acid should be stopped if visual symptoms or suspected retinal occlusion occur.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acido_tranexamico'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acido_tranexamico'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'));

-- 14/19 — EFAVIRENZ + PRAZIQUANTEL (indução do CYP3A4 — eficácia ↓)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Efavirenz + praziquantel: o efavirenz induz o CYP3A4 e reduz muito os níveis de praziquantel (AUC −77%). Evitar; monitorizar eficácia.',
  summary_pro_en = 'Efavirenz + praziquantel: efavirenz induces CYP3A4 and greatly reduces praziquantel levels (AUC −77%). Avoid; monitor efficacy.',
  explanation_pt = 'O praziquantel é metabolizado pelo CYP3A4 e o efavirenz é um indutor moderado do CYP3A4: o rótulo do praziquantel documenta o estudo com 20 voluntários em que o efavirenz (400 mg/dia durante 13 dias) reduziu a AUC média do praziquantel em 77% (IC 95%: 38–91%) e a Cmax em 79% (IC 95%: 41–92%), e classifica a associação como "evitar, a menos que o benefício supere os riscos, devido ao risco de diminuição clinicamente significativa das concentrações plasmáticas de praziquantel que pode levar à redução do efeito terapêutico". Se o tratamento não puder ser adiado, considerar interromper o efavirenz 2–4 semanas antes do praziquantel (se possível) e monitorizar a eficácia anti-helmíntica; na prática, preferir alternativa ao efavirenz ou outro anti-helmíntico.',
  explanation_en = 'Praziquantel is metabolised by CYP3A4 and efavirenz is a moderate CYP3A4 inducer: the praziquantel label documents the study with 20 volunteers in which efavirenz (400 mg/day for 13 days) reduced the mean praziquantel AUC by 77% (95% CI: 38–91%) and Cmax by 79% (95% CI: 41–92%), and classifies the combination as "avoid, unless the benefit outweighs the risks, due to the risk of a clinically significant decrease in praziquantel plasma concentrations which may lead to reduced therapeutic effect". If treatment cannot be delayed, consider stopping efavirenz 2–4 weeks before praziquantel (if possible) and monitor the anthelmintic efficacy; in practice, prefer an efavirenz alternative or another anthelmintic.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'efavirenz'), (SELECT id FROM public.drugs WHERE slug = 'praziquantel'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'efavirenz'), (SELECT id FROM public.drugs WHERE slug = 'praziquantel'));

-- 15/19 — CLOZAPINA + FLUOXETINA (CYP1A2/2D6 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clozapina + fluoxetina: a fluoxetina inibe o CYP1A2/2D6 e aumenta os níveis de clozapina. Monitorizar níveis e efeitos adversos.',
  summary_pro_en = 'Clozapine + fluoxetine: fluoxetine inhibits CYP1A2/2D6 and raises clozapine levels. Monitor levels and adverse effects.',
  explanation_pt = 'A clozapina é metabolizada pelo CYP1A2 e CYP2D6, e a fluoxetina é um inibidor destas enzimas: o rótulo da clozapina refere explicitamente que "a fluoxetina, a quinidina, a duloxetina, a terbinafina ou a sertralina podem aumentar os níveis de clozapina e levar a reações adversas". Níveis aumentados de clozapina potenciam os efeitos dose-dependentes: sedação, sialorreia, obstipação, taquicardia, hipotensão, convulsões e, sobretudo, agranulocitose/neutropenia e miocardite (reações graves que exigem monitorização do hemograma). A associação exige: monitorizar os níveis plasmáticos de clozapina (ou reduzir a dose em 30–50% na prática clínica), vigiar sedação, sintomas anticolinérgicos e o hemograma, e reavaliar quando a fluoxetina for descontinuada (os níveis descem).',
  explanation_en = 'Clozapine is metabolised by CYP1A2 and CYP2D6, and fluoxetine inhibits these enzymes: the clozapine label explicitly states that "fluoxetine, quinidine, duloxetine, terbinafine or sertraline can increase clozapine levels and lead to adverse reactions". Raised clozapine levels potentiate the dose-dependent effects: sedation, sialorrhoea, constipation, tachycardia, hypotension, seizures and, above all, agranulocytosis/neutropenia and myocarditis (serious reactions requiring blood count monitoring). The combination requires: monitoring clozapine plasma levels (or reducing the dose by 30–50% in clinical practice), watching sedation, anticholinergic symptoms and the blood count, and reassessing when fluoxetine is discontinued (levels fall).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clozapina'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clozapina'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'));

-- 16/19 — DEXAMETASONA + FENITOÍNA (indução do CYP3A4 — corticoide ↓)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + fenitoína: a fenitoína induz o CYP3A4 e reduz a eficácia da dexametasona. Vigiar resposta e considerar aumentar a dose do corticoide.',
  summary_pro_en = 'Dexamethasone + phenytoin: phenytoin induces CYP3A4 and reduces dexamethasone efficacy. Monitor response and consider raising the corticosteroid dose.',
  explanation_pt = 'A fenitoína é um indutor potente das enzimas hepáticas (o rótulo refere que "a fenitoína é um indutor potente das enzimas metabolizadoras de fármacos" e que induz as enzimas hepáticas, aumentando o metabolismo de vários fármacos), e a dexametasona é metabolizada pelo CYP3A4: a associação aumenta a depuração do corticoide e reduz o seu efeito terapêutico — com relevância clínica em doentes epiléticos tratados com fenitoína que necessitam de corticosteroides (ex.: asma grave, patologia autoimune, edema cerebral). O rótulo da fenitoína refere ainda a interferência com os testes de supressão com dexametasona. Monitorizar a resposta clínica ao corticoide e considerar aumentar a dose de dexametasona; se a fenitoína for descontinuada, reavaliar (a dose de corticoide pode precisar de ser reduzida para evitar excesso).',
  explanation_en = 'Phenytoin is a potent inducer of hepatic enzymes (the label states that "phenytoin is a potent inducer of hepatic drug-metabolising enzymes" and that it induces hepatic enzymes, increasing the metabolism of several drugs), and dexamethasone is metabolised by CYP3A4: the combination increases corticosteroid clearance and reduces its therapeutic effect — clinically relevant in epileptic patients treated with phenytoin who need corticosteroids (e.g. severe asthma, autoimmune disease, cerebral oedema). The phenytoin label also mentions interference with dexamethasone suppression tests. Monitor the clinical response to the corticosteroid and consider increasing the dexamethasone dose; if phenytoin is discontinued, reassess (the corticosteroid dose may need to be reduced to avoid excess).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- 17/19 — ARTEMÉTER-LUMEFANTRINA + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Arteméter-lumefantrina + mefloquina: QT aditivo (antimaláricos). Evitar a associação; ECG e eletrólitos se inevitável.',
  summary_pro_en = 'Artemether-lumefantrine + mefloquine: additive QT (antimalarials). Avoid the combination; ECG and electrolytes if unavoidable.',
  explanation_pt = 'Ambos os fármacos são antimaláricos associados a prolongamento do QT: o rótulo do arteméter-lumefantrina refere que "alguns antimaláricos (ex.: quinina, quinidina), incluindo o arteméter-lumefantrina, foram associados a prolongamento do intervalo QT no ECG" e recomenda usar com precaução outros fármacos que prolongam o QT; o rótulo da mefloquina documenta prolongamento do QTc e desaconselha a associação com fármacos que alteram a condução cardíaca (a quinina e a quinidina são contraindicadas, e a halofantrina e o cetoconazol pelo risco de QT potencialmente fatal). A associação destes antimaláricos não é usada na prática (são alternativas entre si), mas pode ocorrer sobreposição em doentes com falência terapêutica. Se associados, monitorizar o ECG, os eletrólitos (corrigir hipocaliemia/hipomagnesemia) e os sinais de arritmia.',
  explanation_en = 'Both drugs are antimalarials associated with QT prolongation: the artemether-lumefantrine label states that "some antimalarials (e.g. quinine, quinidine), including artemether-lumefantrine, have been associated with prolongation of the QT interval on the ECG" and recommends using other QT-prolonging drugs with caution; the mefloquine label documents QTc prolongation and advises against drugs that alter cardiac conduction (quinine and quinidine are contraindicated, and halofantrine and ketoconazole because of the potentially fatal QT risk). Combining these antimalarials is not used in practice (they are alternatives to each other), but overlap can occur in patients with therapeutic failure. If combined, monitor the ECG, electrolytes (correct hypokalaemia/hypomagnesaemia) and signs of arrhythmia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 18/19 — DIIDROARTEMISININA-PIPERAQUINA + MEFLOQUINA (QT aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diidroartemisinina-piperaquina + mefloquina: QT aditivo. Evitar a associação (EMA contraindica QT-prolongantes); ECG se inevitável.',
  summary_pro_en = 'Dihydroartemisinin-piperaquine + mefloquine: additive QT. Avoid the combination (EMA contraindicates QT-prolonging drugs); ECG if unavoidable.',
  explanation_pt = 'A piperaquina (componente da diidroartemisinina-piperaquina, Eurartesim) prolonga o intervalo QT de forma dose-dependente e o EPAR da EMA contraindica a coadministração com outros fármacos que prolongam o QT; o rótulo da mefloquina documenta, por seu lado, prolongamento do QTc e desaconselha a associação com fármacos que alteram a condução cardíaca. A associação destes antimaláricos não é usada na prática (são alternativas entre si), mas pode ocorrer sobreposição em doentes com falência terapêutica ou malária grave, sobretudo com hipocaliemia, hipomagnesemia, bradicardia ou doença cardíaca. Evitar; se inevitável, monitorizar o ECG e os eletrólitos antes e durante a terapêutica e corrigir hipocaliemia/hipomagnesemia.',
  explanation_en = 'Piperaquine (the dihydroartemisinin-piperaquine component, Eurartesim) prolongs the QT interval in a dose-dependent way and the EMA EPAR contraindicates co-administration with other QT-prolonging drugs; the mefloquine label, in turn, documents QTc prolongation and advises against drugs that alter cardiac conduction. Combining these antimalarials is not used in practice (they are alternatives to each other), but overlap can occur in patients with therapeutic failure or severe malaria, especially with hypokalaemia, hypomagnesaemia, bradycardia or cardiac disease. Avoid; if unavoidable, monitor the ECG and electrolytes before and during therapy and correct hypokalaemia/hypomagnesaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 19/19 — HIDROXICLOROQUINA + METFORMINA (hipoglicemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroxicloroquina + metformina: hipoglicemia aditiva. Monitorizar glicemia e considerar reduzir a dose do antidiabético.',
  summary_pro_en = 'Hydroxychloroquine + metformin: additive hypoglycaemia. Monitor glycaemia and consider reducing the antidiabetic dose.',
  explanation_pt = 'A hidroxicloroquina pode causar hipoglicemia grave e potencialmente fatal, "na presença ou ausência de antidiabéticos" (o rótulo refere explicitamente que "pode potenciar os efeitos da insulina e dos antidiabéticos e, consequentemente, aumentar o risco de hipoglicemia — pode ser necessário reduzir a dose de insulina e de outros antidiabéticos", e recomenda monitorizar a glicemia nos doentes diabéticos). A associação com metformina soma os efeitos hipoglicemiantes. Nota: o rótulo da hidroxicloroquina indica que esta não inibe o OCT2 in vitro, pelo que o mecanismo é essencialmente farmacodinâmico. Monitorizar a glicemia no início da associação e sempre que a dose de hidroxicloroquina mudar, avisar o doente para os sinais de hipoglicemia (sudorese, tremor, palpitações, confusão) e considerar reduzir a dose de metformina ou de outros antidiabéticos.',
  explanation_en = 'Hydroxychloroquine can cause severe and potentially fatal hypoglycaemia, "in the presence or absence of antidiabetic agents" (the label explicitly states that it "may enhance the effects of insulin and antidiabetic drugs and, consequently, increase the hypoglycaemic risk — a decrease in the dosage of insulin and other antidiabetic drugs may be necessary", and recommends monitoring blood glucose in diabetic patients). The combination with metformin adds up the hypoglycaemic effects. Note: the hydroxychloroquine label indicates it does not inhibit OCT2 in vitro, so the mechanism is essentially pharmacodynamic. Monitor glycaemia at the start of the combination and whenever the hydroxychloroquine dose changes, warn the patient about hypoglycaemia signs (sweating, tremor, palpitations, confusion) and consider reducing the metformin or other antidiabetic dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));
