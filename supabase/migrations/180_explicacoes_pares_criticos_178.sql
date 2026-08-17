-- =====================================================================
-- 180: Fluxo 4 — Explicações longas dos 10 pares críticos da migração 178
--      (QUADRO 2, Anexo 7 do Prontuário)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en +
-- explanation_pt/en) dos 10 pares com severity 'critical' criados na 178.
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos
--     de risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado no QUADRO 2 do Anexo 7 (as mesmas
--     fontes citadas na 178 — Prontuário Terapêutico do INFARMED,
--     11.ª ed., 2012), complementado por rótulos FDA quando o par
--     envolve fármacos com contraindicação documentada de interação.
--
-- Critério: os 10 pares 'critical' da 178 — risco hemorrágico grave,
-- arritmias ventriculares (QT), bradicardia extrema, perda de controlo
-- de crises, mielossupressão e imunossupressão grave:
--   1. Clopidogrel × Varfarina        (hemorragia — evitar)
--   2. Varfarina × Cotrimoxazol       (INR marcadamente elevado)
--   3. Amiodarona × Sotalol           (QT aditivo — torsades)
--   4. Amiodarona × Levofloxacina     (QT aditivo)
--   5. Ivabradina × Claritromicina    (CYP3A4 — bradicardia extrema)
--   6. Cetoconazol × Pimozida         (CYP3A4 + QT — torsades)
--   7. Ertapenem × Valproato          (perda de controlo de crises)
--   8. Metotrexato × Aspirina         (mielossupressão/nefrotoxicidade)
--   9. Metotrexato × Diclofenac       (mielossupressão/nefrotoxicidade)
--  10. Alopurinol × Azatioprina       (mielossupressão grave — evitar)
--
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug —
-- reaplicar é seguro. Aplicar na ordem 173 → 178 → 180 (depende dos
-- pares da 178).
-- =====================================================================

-- 1. Clopidogrel × Varfarina (hemorragia — QUADRO 2: Clopidogrel)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clopidogrel + varfarina: risco hemorrágico aditivo grave — o QUADRO 2 recomenda evitar o uso concomitante; se inevitável (ex.: prótese metálica + stent), usar pelo menor tempo possível com vigilância apertada.',
  summary_pro_en = 'Clopidogrel + warfarin: severe additive bleeding risk — QUADRO 2 recommends avoiding concomitant use; if unavoidable (e.g. metallic valve + stent), use for the shortest possible time with close surveillance.',
  explanation_pt = 'O clopidogrel inibe irreversivelmente a agregação plaquetária (P2Y12) e a varfarina reduz a síntese dos fatores de coagulação dependentes da vitamina K: os dois mecanismos são complementares e o efeito na hemostase é aditivo. O QUADRO 2 do Anexo 7 regista o clopidogrel entre os fármacos que aumentam o risco de hemorragia quando associados aos anticoagulantes orais, recomendando evitar o uso concomitante. Na prática, a dupla antiagregação com anticoagulação só se justifica em situações específicas (ex.: prótese mecânica com stent recente), e a duração deve ser a mínima possível. Os doentes de maior risco são os idosos, os com insuficiência renal ou hepática e os com história de hemorragia digestiva. Se a associação for inevitável, o INR deve ser mantido no limite inferior do intervalo terapêutico e o doente orientado para sinais de alarme (melena, equimoses espontâneas, hematúria).',
  explanation_en = 'Clopidogrel irreversibly inhibits platelet aggregation (P2Y12) and warfarin reduces the synthesis of vitamin K-dependent clotting factors: the two mechanisms are complementary and the effect on haemostasis is additive. QUADRO 2 of Annex 7 lists clopidogrel among the drugs that increase bleeding risk when combined with oral anticoagulants, recommending avoidance of concomitant use. In practice, dual antiplatelet therapy with anticoagulation is only justified in specific situations (e.g. mechanical valve with recent stent), and the duration should be the shortest possible. Higher-risk patients are the elderly, those with renal or hepatic impairment, and those with a history of GI bleeding. If the combination is unavoidable, INR should be kept at the lower end of the therapeutic range and the patient instructed on alarm signs (melena, spontaneous bruising, haematuria).',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Clopidogrel)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Clopidogrel)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 2. Varfarina × Cotrimoxazol (INR elevado — QUADRO 2: Anticoagulantes orais)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Varfarina + cotrimoxazol: o sulfametoxazol+trimetoprim aumenta marcadamente o INR e o risco hemorrágico — preferir antibiótico alternativo; se necessário, reduzir a dose de varfarina e controlar o INR diariamente.',
  summary_pro_en = 'Warfarin + co-trimoxazole: sulfamethoxazole+trimethoprim markedly increases INR and bleeding risk — prefer an alternative antibiotic; if required, reduce the warfarin dose and monitor INR daily.',
  explanation_pt = 'O sulfametoxazol inibe o metabolismo hepático da varfarina (S-varfarina, CYP2C9) e o trimetoprim desloca-a das proteínas plasmáticas: o resultado é um aumento rápido e por vezes acentuado do INR nos primeiros dias de antibiótico. O QUADRO 2 do Anexo 7 regista o cotrimoxazol entre os fármacos que aumentam o efeito dos anticoagulantes orais, e a associação é uma das causas clássicas de hemorragia grave por varfarina (digestiva, urinária, intracraniana). Sempre que houver alternativa, deve preferir-se outro antibiótico; se o cotrimoxazol for indispensável, a dose de varfarina deve ser reduzida de forma preventiva (tipicamente 25-50%) e o INR controlado diariamente ou em dias alternados durante o tratamento. O risco persiste enquanto durar o antibiótico e nos dias seguintes, pelo que a monitorização deve continuar após a suspensão.',
  explanation_en = 'Sulfamethoxazole inhibits the hepatic metabolism of warfarin (S-warfarin, CYP2C9) and trimethoprim displaces it from plasma proteins: the result is a rapid and sometimes marked INR increase within the first days of the antibiotic. QUADRO 2 of Annex 7 lists co-trimoxazole among the drugs that increase the effect of oral anticoagulants, and the combination is one of the classic causes of severe warfarin bleeding (GI, urinary, intracranial). Whenever an alternative exists, another antibiotic should be preferred; if co-trimoxazole is essential, the warfarin dose should be preventively reduced (typically 25-50%) and INR monitored daily or on alternate days during treatment. The risk persists for as long as the antibiotic is given and in the following days, so monitoring should continue after discontinuation.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Oral anticoagulants)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'),
                        (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'),
                           (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'));

-- 3. Amiodarona × Sotalol (QT aditivo — QUADRO 2: Amiodarona)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amiodarona + sotalol: associação de dois antiarrítmicos que prolongam o QT — risco elevado de arritmias ventriculares; evitar e preferir monoterapia.',
  summary_pro_en = 'Amiodarone + sotalol: combination of two QT-prolonging antiarrhythmics — high risk of ventricular arrhythmias; avoid and prefer monotherapy.',
  explanation_pt = 'A amiodarona e o sotalol prolongam o intervalo QT por mecanismos diferentes e o efeito é aditivo: a amiodarona bloqueia múltiplas correntes de potássio e o sotalol bloqueia a corrente IKr, ambos aumentando o risco de torsades de pointes e de fibrilhação ventricular. O QUADRO 2 do Anexo 7 assinala a amiodarona na lista de fármacos que aumentam o risco de arritmias quando combinada com outros antiarrítmicos. A associação surge sobretudo na cardiopatia estrutural, onde qualquer pró-arrítmia é particularmente perigosa. Sempre que possível deve manter-se apenas um dos fármacos; se a associação for clínica e absolutamente necessária, o ECG deve ser monitorizado (intervalo QTc), bem como o potássio e o magnésio, e os fatores de risco corrigíveis (hipocaliemia, bradicardia, fármacos que prolongam o QT) eliminados. A amiodarona tem semivida muito longa, pelo que o risco persiste semanas após a suspensão.',
  explanation_en = 'Amiodarone and sotalol prolong the QT interval by different mechanisms and the effect is additive: amiodarone blocks multiple potassium currents and sotalol blocks the IKr current, both increasing the risk of torsades de pointes and ventricular fibrillation. QUADRO 2 of Annex 7 flags amiodarone on the list of drugs that increase arrhythmia risk when combined with other antiarrhythmics. The combination arises mainly in structural heart disease, where any proarrhythmia is particularly dangerous. Whenever possible only one of the drugs should be maintained; if the combination is clinically and absolutely necessary, the ECG should be monitored (QTc interval), as well as potassium and magnesium, and correctable risk factors (hypokalaemia, bradycardia, QT-prolonging drugs) eliminated. Amiodarone has a very long half-life, so the risk persists for weeks after discontinuation.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Amiodarona)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Amiodarone)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                        (SELECT id FROM public.drugs WHERE slug = 'sotalol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                           (SELECT id FROM public.drugs WHERE slug = 'sotalol'));

-- 4. Amiodarona × Levofloxacina (QT aditivo — QUADRO 2: Amiodarona)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amiodarona + levofloxacina: prolongamento aditivo do QT com risco de arritmias ventriculares — evitar a associação e escolher antibiótico alternativo.',
  summary_pro_en = 'Amiodarone + levofloxacin: additive QT prolongation with risk of ventricular arrhythmias — avoid the combination and choose an alternative antibiotic.',
  explanation_pt = 'A levofloxacina (fluoroquinolona) prolonga o intervalo QT por bloqueio da corrente IKr, e a amiodarona prolonga-o por múltiplos mecanismos: a associação é aditiva e pode precipitar torsades de pointes, sobretudo em doentes com cardiopatia, hipocaliemia ou bradicardia. O QUADRO 2 do Anexo 7 regista a levofloxacina na lista de fármacos que aumentam o risco de arritmias em doentes a tomar amiodarona. A levofloxacina é frequentemente usada em infeções respiratórias e urinárias, onde outras classes (beta-lactâmicos, macrólidos com menor risco, nitrofurantoína) podem ser alternativas seguras. Se não houver alternativa, o ECG deve ser monitorizado durante o antibiótico, com correção atempada de eletrólitos; a amiodarona acumula-se no tecido e o risco mantém-se por semanas após a suspensão da levofloxacina.',
  explanation_en = 'Levofloxacin (fluoroquinolone) prolongs the QT interval by blocking the IKr current, and amiodarone prolongs it by multiple mechanisms: the combination is additive and may precipitate torsades de pointes, especially in patients with heart disease, hypokalaemia or bradycardia. QUADRO 2 of Annex 7 lists levofloxacin among the drugs that increase arrhythmia risk in patients taking amiodarone. Levofloxacin is often used in respiratory and urinary infections, where other classes (beta-lactams, lower-risk macrolides, nitrofurantoin) may be safe alternatives. If no alternative exists, the ECG should be monitored during the antibiotic with prompt electrolyte correction; amiodarone accumulates in tissue and the risk persists for weeks after levofloxacin discontinuation.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Amiodarona)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Amiodarone)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                        (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                           (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'));

-- 5. Ivabradina × Claritromicina (CYP3A4 — QUADRO 2: Ivabradina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ivabradina + claritromicina: a claritromicina (inibidor forte do CYP3A4) aumenta a concentração da ivabradina — bradicardia extrema e arritmias; evitar a associação.',
  summary_pro_en = 'Ivabradine + clarithromycin: clarithromycin (strong CYP3A4 inhibitor) increases ivabradine concentration — extreme bradycardia and arrhythmias; avoid the combination.',
  explanation_pt = 'A ivabradina é metabolizada predominantemente pelo CYP3A4 e a claritromicina é um inibidor forte desse enzima: a associação aumenta de forma significativa a concentração plasmática da ivabradina, com bradicardia acentuada, bloqueio auriculoventricular e risco de arritmias ventriculares (incluindo torsades de pointes em doentes predispostos). O QUADRO 2 do Anexo 7 recomenda explicitamente evitar o uso concomitante. A contraindicação consta também do rótulo da ivabradina, que proíbe a associação com inibidores fortes do CYP3A4. Em infeções respiratórias onde a claritromicina seria usada, devem preferir-se alternativas (azitromicina tem menor inibição do CYP3A4, ou beta-lactâmicos). Se a associação for inevitável (situação não recomendada), a frequência cardíaca e o ECG devem ser monitorizados e a dose de ivabradina ajustada — na prática, a contraindicação torna esta monitorização insuficiente, pelo que se deve mudar o antibiótico.',
  explanation_en = 'Ivabradine is metabolised predominantly by CYP3A4 and clarithromycin is a strong inhibitor of that enzyme: the combination significantly increases ivabradine plasma concentration, with marked bradycardia, atrioventricular block and risk of ventricular arrhythmias (including torsades de pointes in predisposed patients). QUADRO 2 of Annex 7 explicitly recommends avoiding concomitant use. The contraindication is also in the ivabradine label, which prohibits combination with strong CYP3A4 inhibitors. In respiratory infections where clarithromycin would be used, alternatives should be preferred (azithromycin has weaker CYP3A4 inhibition, or beta-lactams). If the combination is unavoidable (a non-recommended situation), heart rate and ECG should be monitored and the ivabradine dose adjusted — in practice, the contraindication makes this monitoring insufficient, so the antibiotic should be changed.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ivabradina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Ivabradine)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ivabradina'),
                        (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ivabradina'),
                           (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- 6. Cetoconazol × Pimozida (CYP3A4 + QT — QUADRO 2: Pimozida; Antifúngicos Azol)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + pimozida: o cetoconazol (inibidor forte do CYP3A4) aumenta os níveis de pimozida — risco elevado de torsades de pointes; associação contraindicada.',
  summary_pro_en = 'Ketoconazole + pimozide: ketoconazole (strong CYP3A4 inhibitor) increases pimozide levels — high risk of torsades de pointes; contraindicated combination.',
  explanation_pt = 'A pimozida é metabolizada pelo CYP3A4 e prolonga o intervalo QT; o cetoconazol, inibidor forte desse enzima, aumenta de forma marcada a sua concentração plasmática, com risco elevado de arritmias ventriculares graves, incluindo torsades de pointes. O QUADRO 2 do Anexo 7 assinala a associação na lista de interações que aumentam o risco de arritmias, e a combinação está contraindicada nos rótulos de ambos os fármacos. A pimozida é usada em síndromes com tiques e em perturbações psicóticas resistentes, e o cetoconazol oral em micoses sistémicas — situações onde a alternativa é obrigatória: outro antipsicótico sem interação relevante ou outro antifúngico (fluconazol tem menor inibição do CYP3A4, mas requer avaliação). Não existe dose segura documentada para a associação; perante exposição acidental, monitorizar ECG (QTc), potássio e magnésio.',
  explanation_en = 'Pimozide is metabolised by CYP3A4 and prolongs the QT interval; ketoconazole, a strong inhibitor of that enzyme, markedly increases its plasma concentration, with a high risk of severe ventricular arrhythmias, including torsades de pointes. QUADRO 2 of Annex 7 flags the combination on the list of interactions increasing arrhythmia risk, and the combination is contraindicated in the labels of both drugs. Pimozide is used in tic disorders and resistant psychotic disorders, and oral ketoconazole in systemic mycoses — situations where an alternative is mandatory: another antipsychotic without relevant interaction or another antifungal (fluconazole has weaker CYP3A4 inhibition, but requires evaluation). No safe dose is documented for the combination; after accidental exposure, monitor ECG (QTc), potassium and magnesium.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Pimozida; Antifúngicos Azol)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Pimozide; Azole antifungals)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'),
                        (SELECT id FROM public.drugs WHERE slug = 'pimozida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'),
                           (SELECT id FROM public.drugs WHERE slug = 'pimozida'));

-- 7. Ertapenem × Valproato (perda de controlo de crises — QUADRO 2: Ertapenem)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ertapenem + valproato: o ertapenem reduz os níveis plasmáticos de ácido valproico — risco de crises epiléticas; evitar a associação e monitorizar níveis.',
  summary_pro_en = 'Ertapenem + valproate: ertapenem reduces valproic acid plasma levels — risk of seizures; avoid the combination and monitor levels.',
  explanation_pt = 'Os carbapenemos, incluindo o ertapenem, reduzem de forma rápida e por vezes acentuada as concentrações plasmáticas de ácido valproico/valproato, mesmo após poucas doses; o mecanismo não está totalmente esclarecido (redução da reabsorção intestinal e da hidrólise do glicurónido com menor reciclagem). O resultado é a perda de controlo das crises epiléticas em doentes tratados com valproato, e o QUADRO 2 do Anexo 7 regista explicitamente o ertapenem. A associação deve ser evitada; se o carbapenemo for indispensável (infeção grave por Gram-negativos resistentes), deve considerar-se terapêutica antiepilética alternativa e monitorizar os níveis de valproato. O efeito pode persistir vários dias após a suspensão do antibiótico, pelo que a vigilância das crises deve continuar nesse período.',
  explanation_en = 'Carbapenems, including ertapenem, rapidly and sometimes markedly reduce plasma concentrations of valproic acid/valproate, even after a few doses; the mechanism is not fully clarified (reduced intestinal reabsorption and reduced hydrolysis of the glucuronide with less recycling). The result is loss of seizure control in patients treated with valproate, and QUADRO 2 of Annex 7 explicitly lists ertapenem. The combination should be avoided; if the carbapenem is essential (severe resistant Gram-negative infection), alternative antiepileptic therapy should be considered and valproate levels monitored. The effect may persist for several days after antibiotic discontinuation, so seizure vigilance should continue in that period.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ertapenem)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Ertapenem)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ertapenem'),
                        (SELECT id FROM public.drugs WHERE slug = 'valproato'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ertapenem'),
                           (SELECT id FROM public.drugs WHERE slug = 'valproato'));

-- 8. Metotrexato × Aspirina (mielossupressão/nefrotoxicidade — QUADRO 2: Salicilatos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Metotrexato + aspirina: os salicilatos reduzem a excreção renal e deslocam o metotrexato — risco de mielossupressão e nefrotoxicidade; evitar em doses altas de metotrexato.',
  summary_pro_en = 'Methotrexate + aspirin: salicylates reduce renal excretion and displace methotrexate — risk of myelosuppression and nephrotoxicity; avoid with high-dose methotrexate.',
  explanation_pt = 'Os salicilatos (incluindo a aspirina em doses analgésicas) reduzem a secreção tubular renal do metotrexato e deslocam-no das proteínas plasmáticas, aumentando a sua fração livre e a exposição sistémica. O QUADRO 2 do Anexo 7 regista o metotrexato entre os fármacos cuja toxicidade é aumentada pelos salicilatos e pelos AINEs. A consequência clínica é a mielossupressão (pancitopenia), mucosite, hepatotoxicidade e nefrotoxicidade, sobretudo com metotrexato em doses altas (oncologia) ou na insuficiência renal. Na artrite reumatoide, doses baixas e estáveis de metotrexato com aspirina em dose antiagregante exigem monitorização periódica de hemograma e função renal; doses analgésicas devem ser evitadas. Durante esquemas de metotrexato em dose alta, os AINEs e salicilatos devem ser suspensos e a hidratação alcalina mantida.',
  explanation_en = 'Salicylates (including aspirin at analgesic doses) reduce the renal tubular secretion of methotrexate and displace it from plasma proteins, increasing its free fraction and systemic exposure. QUADRO 2 of Annex 7 lists methotrexate among the drugs whose toxicity is increased by salicylates and NSAIDs. The clinical consequence is myelosuppression (pancytopenia), mucositis, hepatotoxicity and nephrotoxicity, especially with high-dose methotrexate (oncology) or in renal impairment. In rheumatoid arthritis, low stable doses of methotrexate with aspirin at antiplatelet dose require periodic monitoring of blood count and renal function; analgesic doses should be avoided. During high-dose methotrexate regimens, NSAIDs and salicylates should be withheld and alkaline hydration maintained.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Salicilatos)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Salicylates)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                        (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                           (SELECT id FROM public.drugs WHERE slug = 'aspirina'));

-- 9. Metotrexato × Diclofenac (mielossupressão/nefrotoxicidade — QUADRO 2: AINEs)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Metotrexato + diclofenac: os AINEs reduzem a excreção renal do metotrexato — risco de pancitopenia e insuficiência renal; evitar, sobretudo em doses altas.',
  summary_pro_en = 'Methotrexate + diclofenac: NSAIDs reduce methotrexate renal excretion — risk of pancytopenia and renal failure; avoid, especially at high doses.',
  explanation_pt = 'Os AINEs, incluindo o diclofenac, inibem a secreção tubular renal de ácidos orgânicos e podem reduzir o clearance do metotrexato, além de causarem redução do fluxo renal em doentes suscetíveis: ambos os mecanismos aumentam a exposição ao metotrexato. O QUADRO 2 do Anexo 7 regista a associação dos AINEs com o metotrexato como de risco acrescido de mielossupressão e nefrotoxicidade. A interação é mais perigosa com metotrexato em doses altas, na insuficiência renal, na desidratação e nos idosos. Na prática, os AINEs devem ser evitados durante a terapêutica com metotrexato; quando o alívio analgésico é necessário, preferir paracetamol. Se a associação for inevitável, monitorizar hemograma, função renal e sinais de mucosite, e garantir hidratação adequada.',
  explanation_en = 'NSAIDs, including diclofenac, inhibit the renal tubular secretion of organic acids and may reduce methotrexate clearance, in addition to reducing renal flow in susceptible patients: both mechanisms increase methotrexate exposure. QUADRO 2 of Annex 7 lists the combination of NSAIDs with methotrexate as carrying an increased risk of myelosuppression and nephrotoxicity. The interaction is more dangerous with high-dose methotrexate, renal impairment, dehydration and in the elderly. In practice, NSAIDs should be avoided during methotrexate therapy; when analgesic relief is needed, paracetamol should be preferred. If the combination is unavoidable, monitor blood count, renal function and signs of mucositis, and ensure adequate hydration.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (AINEs)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (NSAIDs)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                        (SELECT id FROM public.drugs WHERE slug = 'diclofenac'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                           (SELECT id FROM public.drugs WHERE slug = 'diclofenac'));

-- 10. Alopurinol × Azatioprina (mielossupressão grave — QUADRO 2: Alopurinol)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Alopurinol + azatioprina: o alopurinol inibe a xantina oxidase que metaboliza a azatioprina — mielossupressão grave e potencialmente fatal; associação contraindicada ou com redução de 75% da dose.',
  summary_pro_en = 'Allopurinol + azathioprine: allopurinol inhibits the xanthine oxidase that metabolises azathioprine — severe and potentially fatal myelosuppression; contraindicated or requires a 75% dose reduction.',
  explanation_pt = 'A azatioprina é convertida no metabolito ativo 6-mercaptopurina, que é inativado pela xantina oxidase; o alopurinol inibe essa enzima e aumenta de forma acentuada as concentrações de 6-mercaptopurina, com risco de mielossupressão grave (pancitopenia), febre, infeções graves e, em casos extremos, morte. O QUADRO 2 do Anexo 7 regista o alopurinol entre os fármacos que aumentam a toxicidade da azatioprina, e os rótulos de ambos os fármacos desaconselham fortemente a associação. Quando a associação é clinicamente indispensável (ex.: gota em doente transplantado ou com doença inflamatória intestinal), a dose de azatioprina deve ser reduzida para cerca de 25% da dose habitual, com monitorização muito apertada do hemograma nas primeiras semanas. Deve também evitar-se iniciar alopurinol em doentes estabilizados com azatioprina sem reavaliar a dose.',
  explanation_en = 'Azathioprine is converted to the active metabolite 6-mercaptopurine, which is inactivated by xanthine oxidase; allopurinol inhibits that enzyme and markedly increases 6-mercaptopurine concentrations, with a risk of severe myelosuppression (pancytopenia), fever, serious infections and, in extreme cases, death. QUADRO 2 of Annex 7 lists allopurinol among the drugs that increase azathioprine toxicity, and the labels of both drugs strongly discourage the combination. When the combination is clinically essential (e.g. gout in a transplant patient or with inflammatory bowel disease), the azathioprine dose should be reduced to about 25% of the usual dose, with very close blood count monitoring in the first weeks. Starting allopurinol in patients stabilised on azathioprine without reassessing the dose should also be avoided.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Alopurinol)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Allopurinol)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'),
                        (SELECT id FROM public.drugs WHERE slug = 'azatioprina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'),
                           (SELECT id FROM public.drugs WHERE slug = 'azatioprina'));
