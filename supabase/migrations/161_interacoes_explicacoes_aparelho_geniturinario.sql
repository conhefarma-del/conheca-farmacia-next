-- 161: Fluxo 4 — Explicações longas dos pares do grupo 7 (aparelho geniturinário)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en + explanation_pt/en)
-- dos 7 pares criados na migração 160 (sildenafil, tadalafil, vardenafil ×
-- eritromicina/ritonavir; tansulosina × eritromicina; dutasterida × ritonavir).
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos de
--     risco e orientação prática (dose, monitorização); texto corrido, sem \n;
--   * conteúdo autorado a partir do conhecimento farmacológico estabelecido e
--     ancorado nos rótulos aprovados já citados na migração 160 (setIDs
--     validados na API DailyMed) — nunca cópia do texto da fonte.
--
-- Fontes (DailyMed/FDA — NIH/NLM), setIDs validados a 2026-08-17:
--   Sildenafil:     1b1ab00d-de9c-4614-e063-6394a90afcde
--   Tadalafil:      c3409762-3b2b-1cfc-e053-2995a90ab91b
--   Vardenafil:     2782efed-6198-47b9-81ac-3e255e2ab7f6
--   Dutasterida:    947644ea-bc35-41df-8a7a-874360c90192
--   Tansulosina:    e4202c52-be9d-41d9-b5ff-122740298544
--   Eritromicina:   0c05e1f7-a3d4-8e69-e063-6394a90aecc3
--   Ritonavir:      2849298e-de6e-47bb-8194-56e075b33fc3
--
-- Âncoras nos rótulos (palavras-chave confirmadas no texto):
--   * Vardenafil 7.2: ritonavir 600 mg 2×/dia → AUC +49×, Cmax +13×, t½ 26 h,
--     dose máx 2,5 mg/72 h; "inhibitors of these enzymes are expected to
--     reduce vardenafil clearance".
--   * Sildenafil 7.4: eritromicina → Cmax +160%, AUC +182%; "consider a
--     starting dose of 25 mg".
--   * Tadalafil 7.2: ritonavir 500–600 mg 2×/dia → AUC +32% (Cmax −30%);
--     ritonavir 200 mg 2×/dia → AUC +124%; ajuste de dose (ocasional 10 mg/72 h,
--     diário 2,5 mg); "other CYP3A4 inhibitors, such as erythromycin... would
--     likely increase tadalafil exposure".
--   * Tansulosina 7.1: "caution in combination with moderate inhibitors of
--     CYP3A4 (e.g., erythromycin), particularly at a dose higher than 0.4 mg";
--     cetoconazol → Cmax ×2,2, AUC ×2,8.
--   * Dutasterida 7/7.1: "use caution... in patients taking potent, chronic
--     CYP3A4 enzyme inhibitors (e.g., ritonavir)"; metabolizada por CYP3A4/3A5.
--
-- Idempotente: os UPDATEs usam o WHERE canónico LEAST/GREATEST independente da
-- ordem dos ids (lição 3). Aplicar após a migração 160.
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Vardenafil + ritonavir: o ritonavir, inibidor potente do CYP3A4/CYP2C9, aumenta a AUC do vardenafil até 49×. Não exceder 2,5 mg de vardenafil num período de 72 horas.',
  summary_pro_en = 'Vardenafil + ritonavir: ritonavir, a potent CYP3A4/CYP2C9 inhibitor, increases vardenafil AUC up to 49-fold. Do not exceed vardenafil 2.5 mg within a 72-hour period.',
  explanation_pt = 'O ritonavir é um inibidor potente do CYP3A4 e do CYP2C9, as enzimas responsáveis pela metabolização hepática do vardenafil. Em estudo clínico, a coadministração de ritonavir 600 mg duas vezes ao dia com vardenafil 5 mg aumentou a AUC do vardenafil em 49 vezes e a Cmax em 13 vezes, prolongando a semivida para cerca de 26 horas. Este aumento marca a exposição ao vardenafil e eleva o risco de hipotensão grave, síncope e ereção prolongada. Por isso, o rótulo recomenda não exceder uma dose única de 2,5 mg de vardenafil num período de 72 horas quando usado com ritonavir. Nos doentes que necessitem de ambas as terapêuticas, deve optar-se pela menor dose eficaz, vigiar a pressão arterial e instruir o doente para procurar ajuda imediata perante ereção prolongada ou sintomas de hipotensão.',
  explanation_en = 'Ritonavir is a potent inhibitor of CYP3A4 and CYP2C9, the enzymes responsible for the hepatic metabolism of vardenafil. In a clinical study, coadministration of ritonavir 600 mg twice daily with vardenafil 5 mg increased vardenafil AUC 49-fold and Cmax 13-fold, prolonging the half-life to about 26 hours. This marked increase in vardenafil exposure raises the risk of severe hypotension, syncope and prolonged erection. Therefore, the label recommends not exceeding a single 2.5 mg dose of vardenafil within a 72-hour period when used with ritonavir. In patients who need both therapies, the lowest effective dose should be chosen, blood pressure monitored, and the patient instructed to seek immediate help in case of prolonged erection or symptoms of hypotension.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Vardenafil + eritromicina: a eritromicina, inibidora moderada do CYP3A4, reduz a depuração do vardenafil e aumenta a exposição. Usar com precaução e considerar a menor dose.',
  summary_pro_en = 'Vardenafil + erythromycin: erythromycin, a moderate CYP3A4 inhibitor, reduces vardenafil clearance and increases exposure. Use with caution and consider the lowest dose.',
  explanation_pt = 'O vardenafil é metabolizado principalmente pelas isoenzimas CYP3A4/5 e, em menor grau, pela CYP2C9 do citocromo P450. A eritromicina, inibidora moderada do CYP3A4, reduz a depuração do vardenafil, aumentando as suas concentrações plasmáticas e potenciando os efeitos vasodilatadores e os efeitos adversos. O rótulo do vardenafil indica que os inibidores destas enzimas reduzem a depuração do fármaco, pelo que se espera um aumento da exposição. A associação deve ser usada com precaução, considerando iniciar com a menor dose de vardenafil e vigiar hipotensão, tonturas e cefaleias. Nos inibidores fortes do CYP3A4 (cetoconazol, ritonavir), a dose máxima permitida é substancialmente inferior.',
  explanation_en = 'Vardenafil is metabolized primarily by the CYP3A4/5 isoenzymes and, to a lesser extent, by CYP2C9 of the cytochrome P450 system. Erythromycin, a moderate CYP3A4 inhibitor, reduces vardenafil clearance, increasing its plasma concentrations and potentiating vasodilatory and adverse effects. The vardenafil label states that inhibitors of these enzymes reduce drug clearance, so an increase in exposure is expected. The combination should be used with caution, considering initiation at the lowest vardenafil dose and monitoring for hypotension, dizziness and headache. With strong CYP3A4 inhibitors (ketoconazole, ritonavir), the maximum permitted dose is substantially lower.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'vardenafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sildenafil + eritromicina: a eritromicina aumenta a Cmax (+160%) e a AUC (+182%) do sildenafil. Considerar dose inicial de 25 mg e vigiar hipotensão.',
  summary_pro_en = 'Sildenafil + erythromycin: erythromycin increases sildenafil Cmax (+160%) and AUC (+182%). Consider a 25 mg starting dose and monitor for hypotension.',
  explanation_pt = 'O sildenafil é metabolizado pelo CYP3A4 e, em menor grau, pelo CYP2C9. A eritromicina, inibidora moderada do CYP3A4, aumentou em estudo clínico a Cmax do sildenafil em 160% e a AUC em 182%, valores que elevam o risco de efeitos vasodilatadores como hipotensão, rubor, cefaleias e congestão nasal. O rótulo do sildenafil recomenda, por isso, considerar uma dose inicial de 25 mg quando administrado com eritromicina ou outros inibidores moderados do CYP3A4. Em doentes com doença cardiovascular, idosos ou polimedicados, deve reforçar-se a vigilância da pressão arterial e informar o doente sobre os sintomas a vigiar.',
  explanation_en = 'Sildenafil is metabolized by CYP3A4 and, to a lesser extent, by CYP2C9. In a clinical study, erythromycin, a moderate CYP3A4 inhibitor, increased sildenafil Cmax by 160% and AUC by 182%, values that raise the risk of vasodilatory effects such as hypotension, flushing, headache and nasal congestion. The sildenafil label therefore recommends considering a starting dose of 25 mg when given with erythromycin or other moderate CYP3A4 inhibitors. In patients with cardiovascular disease, the elderly or the poly-medicated, blood pressure monitoring should be reinforced and the patient informed of the symptoms to watch for.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tadalafil + ritonavir: o ritonavir aumenta a AUC do tadalafil (32–124%). Em uso ocasional, máximo 10 mg a cada 72 h; em uso diário, máximo 2,5 mg.',
  summary_pro_en = 'Tadalafil + ritonavir: ritonavir increases tadalafil AUC (32–124%). For as-needed use, maximum 10 mg every 72 h; for once-daily use, maximum 2.5 mg.',
  explanation_pt = 'O tadalafil é predominantemente metabolizado pelo CYP3A4. O ritonavir, inibidor do CYP3A4 (e também do CYP2C9, CYP2C19 e CYP2D6), aumenta a exposição ao tadalafil de forma dependente da dose: com ritonavir 500–600 mg duas vezes ao dia a AUC aumentou 32% (com redução de 30% da Cmax), e com ritonavir 200 mg duas vezes ao dia a AUC aumentou 124%. Este aumento potencia o efeito hipotensor do tadalafil e o risco de cefaleias e rubor. O rótulo recomenda ajuste da dose: em uso ocasional, não exceder 10 mg a cada 72 horas; em uso diário, não exceder 2,5 mg. A associação deve ser monitorizada, sobretudo em doentes com doença cardiovascular ou em terapêutica anti-hipertensora.',
  explanation_en = 'Tadalafil is predominantly metabolized by CYP3A4. Ritonavir, an inhibitor of CYP3A4 (and also of CYP2C9, CYP2C19 and CYP2D6), increases tadalafil exposure in a dose-dependent manner: with ritonavir 500–600 mg twice daily AUC increased by 32% (with a 30% reduction in Cmax), and with ritonavir 200 mg twice daily AUC increased by 124%. This increase potentiates the hypotensive effect of tadalafil and the risk of headache and flushing. The label recommends dose adjustment: for as-needed use, do not exceed 10 mg every 72 hours; for once-daily use, do not exceed 2.5 mg. The combination should be monitored, especially in patients with cardiovascular disease or on antihypertensive therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tadalafil + eritromicina: inibidor do CYP3A4 aumenta previsivelmente a exposição ao tadalafil. Usar com precaução e considerar redução da dose.',
  summary_pro_en = 'Tadalafil + erythromycin: a CYP3A4 inhibitor predictably increases tadalafil exposure. Use with caution and consider dose reduction.',
  explanation_pt = 'O tadalafil é substrato e predominantemente metabolizado pelo CYP3A4, pelo que os inibidores desta isoenzima aumentam a sua exposição. Embora não tenham sido realizados estudos específicos com eritromicina, o rótulo do tadalafil indica que inibidores do CYP3A4 como a eritromicina aumentariam previsivelmente a exposição ao fármaco, à semelhança do cetoconazol (que aumentou a AUC em 107–312% conforme a dose). O aumento da exposição potencia a hipotensão, o rubor e as cefaleias. Recomenda-se precaução, considerando a redução da dose de tadalafil, e vigilância dos efeitos vasodilatadores, particularmente em doentes com doença cardiovascular.',
  explanation_en = 'Tadalafil is a substrate predominantly metabolized by CYP3A4, so inhibitors of this isoenzyme increase its exposure. Although no specific studies were conducted with erythromycin, the tadalafil label states that CYP3A4 inhibitors such as erythromycin would likely increase exposure to the drug, similar to ketoconazole (which increased AUC by 107–312% depending on the dose). The increased exposure potentiates hypotension, flushing and headache. Caution is recommended, considering a reduction in the tadalafil dose, and monitoring of vasodilatory effects, particularly in patients with cardiovascular disease.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tadalafil'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tansulosina + eritromicina: precaução com inibidores moderados do CYP3A4 (aumento da exposição e risco de hipotensão ortostática), sobretudo em doses > 0,4 mg.',
  summary_pro_en = 'Tamsulosin + erythromycin: caution with moderate CYP3A4 inhibitors (increased exposure and risk of orthostatic hypotension), especially at doses > 0.4 mg.',
  explanation_pt = 'A tansulosina é extensamente metabolizada, principalmente pelo CYP3A4 e pelo CYP2D6. O rótulo recomenda precaução quando é usada com inibidores moderados do CYP3A4, como a eritromicina, particularmente em doses superiores a 0,4 mg (ex.: 0,8 mg), dado o risco de aumento da exposição. Com o cetoconazol, inibidor forte do CYP3A4, a Cmax e a AUC da tansulosina aumentaram 2,2 e 2,8 vezes, respetivamente, o que ilustra o efeito desta classe de fármacos. O risco clínico é a hipotensão ortostática, sobretudo no início do tratamento, com tonturas, sensação de desmaio e quedas. Nos doentes a tomar ambos os fármacos, deve vigiar-se a pressão arterial ao levantar e aconselhar o doente a levantar-se lentamente.',
  explanation_en = 'Tamsulosin is extensively metabolized, mainly by CYP3A4 and CYP2D6. The label recommends caution when it is used with moderate CYP3A4 inhibitors, such as erythromycin, particularly at doses higher than 0.4 mg (e.g., 0.8 mg), given the risk of increased exposure. With ketoconazole, a strong CYP3A4 inhibitor, tamsulosin Cmax and AUC increased 2.2- and 2.8-fold, respectively, illustrating the effect of this drug class. The clinical risk is orthostatic hypotension, especially at treatment initiation, with dizziness, lightheadedness and falls. In patients taking both drugs, blood pressure on standing should be monitored and the patient advised to rise slowly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tansulosina'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tansulosina'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dutasterida + ritonavir: precaução com inibidores potentes do CYP3A4 em uso crónico — possível aumento da exposição à dutasterida.',
  summary_pro_en = 'Dutasteride + ritonavir: caution with potent CYP3A4 inhibitors in chronic use — possible increased dutasteride exposure.',
  explanation_pt = 'A dutasterida é extensamente metabolizada no homem pelas isoenzimas CYP3A4 e CYP3A5. O rótulo recomenda precaução na prescrição a doentes que tomam inibidores potentes do CYP3A4 de forma crónica, como o ritonavir, uma vez que a inibição destas enzimas pode reduzir a depuração da dutasterida e aumentar as suas concentrações plasmáticas. Não foram realizados estudos específicos desta associação, mas o potencial de interação fármaco-fármaco justifica a cautela. Em tratamentos prolongados, deve vigiar-se o aparecimento de efeitos adversos da dutasterida, como ginecomastia, diminuição da libido ou disfunção erétil, e reavaliar a necessidade do fármaco nos doentes em terapêutica antirretroviral prolongada.',
  explanation_en = 'Dutasteride is extensively metabolized in humans by the CYP3A4 and CYP3A5 isoenzymes. The label recommends caution when prescribing to patients taking potent CYP3A4 inhibitors on a chronic basis, such as ritonavir, since inhibition of these enzymes may reduce dutasteride clearance and increase its plasma concentrations. No specific studies of this combination were conducted, but the potential for a drug-drug interaction justifies the caution. During prolonged treatment, the emergence of dutasteride adverse effects such as gynecomastia, decreased libido or erectile dysfunction should be monitored, and the need for the drug should be reassessed in patients on long-term antiretroviral therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dutasterida'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dutasterida'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));
