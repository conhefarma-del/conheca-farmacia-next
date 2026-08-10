-- =====================================================================
-- 120 — Explicações fármaco-fármaco dos pares moderados da SERTRALINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 6 pares moderados da sertralina que os tinham vazios
-- (tamoxifeno+sertralina já tinha explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismo central da sertralina (ISRS):
--   1. Síndrome serotoninérgica com serotonérgicos/opioides — tramadol,
--      codeína, fentanilo, buprenorfina, dextrometorfano ("The risk is
--      increased with concomitant use of other serotonergic drugs
--      (including... fentanyl, lithium, tramadol...)" — rótulo da
--      sertralina);
--   2. Isoniazida — a isoniazida tem atividade inibidora da MAO ("isoniazid
--      has some monoamine oxidase inhibiting activity" — rótulo da
--      isoniazida) + o ISRS eleva a serotonina → risco serotoninérgico.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/6 — BUPRENORFINA + SERTRALINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Buprenorfina + sertralina: risco de síndrome serotoninérgica (opioide + ISRS). Vigiar sintomas, sobretudo no início e em ajustes de dose.',
  summary_pro_en = 'Buprenorphine + sertraline: risk of serotonin syndrome (opioid + SSRI). Monitor symptoms, especially at initiation and dose adjustments.',
  explanation_pt = 'A administração concomitante de opioides com fármacos que afetam o sistema serotoninérgico, como os ISRS (sertralina), pode resultar em síndrome serotoninérgica, potencialmente fatal; o rótulo da buprenorfina refere casos de síndrome serotoninérgica com o uso concomitante de opioides e fármacos serotonérgicos e recomenda observar cuidadosamente o doente, sobretudo no início do tratamento e em ajustes de dose, e suspender a buprenorfina se a síndrome for suspeitada. Os sintomas incluem alterações do estado mental (agitação, alucinações, coma), instabilidade autonómica (taquicardia, variação da pressão arterial, hipertermia) e alterações neuromusculares (hiperreflexia, incoordenação, rigidez).',
  explanation_en = 'Concomitant use of opioids with drugs that affect the serotonergic system, such as SSRIs (sertraline), can result in serotonin syndrome, potentially life-threatening; the buprenorphine label reports cases of serotonin syndrome with concomitant opioids and serotonergic drugs and recommends carefully observing the patient, especially at treatment initiation and dose adjustments, and discontinuing buprenorphine if the syndrome is suspected. Symptoms include mental status changes (agitation, hallucinations, coma), autonomic instability (tachycardia, blood pressure lability, hyperthermia) and neuromuscular aberrations (hyperreflexia, incoordination, rigidity).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'buprenorfina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'buprenorfina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 2/6 — CODEÍNA + SERTRALINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Codeína + sertralina: risco de síndrome serotoninérgica (opioide + ISRS). Vigiar sintomas, sobretudo no início e em ajustes de dose.',
  summary_pro_en = 'Codeine + sertraline: risk of serotonin syndrome (opioid + SSRI). Monitor symptoms, especially at initiation and dose adjustments.',
  explanation_pt = 'O uso concomitante de opioides com fármacos que afetam o sistema serotoninérgico, como os ISRS (sertralina), pode resultar em síndrome serotoninérgica; o rótulo da codeína identifica explicitamente os ISRS entre os fármacos serotonérgicos cuja associação com opioides resultou em síndrome serotoninérgica, e recomenda avaliar com frequência o doente, sobretudo no início do tratamento e em ajustes de dose, e suspender imediatamente se a síndrome for suspeitada. Informar o doente dos sintomas (agitação, alucinações, taquicardia, hipertermia, hiperreflexia, rigidez) e da necessidade de procurar ajuda médica.',
  explanation_en = 'Concomitant use of opioids with drugs that affect the serotonergic system, such as SSRIs (sertraline), can result in serotonin syndrome; the codeine label explicitly identifies SSRIs among the serotonergic drugs whose combination with opioids has resulted in serotonin syndrome, and recommends frequently evaluating the patient, especially at treatment initiation and dose adjustments, and discontinuing immediately if the syndrome is suspected. Inform the patient of the symptoms (agitation, hallucinations, tachycardia, hyperthermia, hyperreflexia, rigidity) and the need to seek medical help.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'codeina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'codeina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 3/6 — DEXTROMETORFANO + SERTRALINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dextrometorfano + sertralina: risco de síndrome serotoninérgica (antitússico serotonérgico + ISRS). Evitar ou vigiar de perto.',
  summary_pro_en = 'Dextromethorphan + sertraline: risk of serotonin syndrome (serotonergic antitussive + SSRI). Avoid or monitor closely.',
  explanation_pt = 'O dextrometorfano tem ação serotoninérgica (inibição da recaptação de serotonina) e é também substrato do CYP2D6, enzima que a sertralina inibe; a associação com ISRS como a sertralina aumenta o risco de síndrome serotoninérgica, potencialmente fatal, com sintomas como agitação, alucinações, taquicardia, hipertermia, hiperreflexia, mioclonias e rigidez. O rótulo da sertralina lista os fármacos serotonérgicos cujo uso concomitante aumenta o risco de síndrome serotoninérgica, e o rótulo do dextrometorfano alerta para a interação com inibidores da MAO. Em doentes a tomar ISRS, preferir antitússicos alternativos ou usar com precaução, vigiando sintomas de serotonina.',
  explanation_en = 'Dextromethorphan has serotonergic action (serotonin reuptake inhibition) and is also a CYP2D6 substrate, an enzyme inhibited by sertraline; the combination with SSRIs such as sertraline increases the risk of serotonin syndrome, potentially life-threatening, with symptoms such as agitation, hallucinations, tachycardia, hyperthermia, hyperreflexia, myoclonus and rigidity. The sertraline label lists serotonergic drugs whose concomitant use increases the risk of serotonin syndrome, and the dextromethorphan label warns about interaction with MAO inhibitors. In patients on SSRIs, prefer alternative antitussives or use with caution, monitoring for serotonin symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 4/6 — FENTANILO + SERTRALINA (síndrome serotoninérgica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fentanilo + sertralina: risco de síndrome serotoninérgica (opioide + ISRS). Vigiar sintomas; suspender o fentanilo se suspeitada.',
  summary_pro_en = 'Fentanyl + sertraline: risk of serotonin syndrome (opioid + SSRI). Monitor symptoms; stop fentanyl if suspected.',
  explanation_pt = 'O rótulo da sertralina lista explicitamente o fentanilo entre os fármacos serotonérgicos cujo uso concomitante aumenta o risco de síndrome serotoninérgica; o rótulo do fentanilo refere casos de síndrome serotoninérgica, potencialmente fatal, com o uso concomitante de fármacos serotonérgicos, incluindo os ISRS, e recomenda suspender imediatamente o fentanilo se a síndrome for suspeitada. Os sintomas surgem habitualmente algumas horas a dias após o início da associação: alterações do estado mental (agitação, alucinações, coma), instabilidade autonómica (taquicardia, variação da pressão arterial, hipertermia) e alterações neuromusculares (hiperreflexia, incoordenação, rigidez).',
  explanation_en = 'The sertraline label explicitly lists fentanyl among the serotonergic drugs whose concomitant use increases the risk of serotonin syndrome; the fentanyl label reports cases of serotonin syndrome, potentially life-threatening, with concomitant use of serotonergic drugs, including SSRIs, and recommends immediately discontinuing fentanyl if the syndrome is suspected. Symptoms usually appear within hours to a few days of starting the combination: mental status changes (agitation, hallucinations, coma), autonomic instability (tachycardia, blood pressure lability, hyperthermia) and neuromuscular aberrations (hyperreflexia, incoordination, rigidity).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fentanilo'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fentanilo'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 5/6 — ISONIAZIDA + SERTRALINA (serotonina — atividade MAO da isoniazida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + sertralina: risco de síndrome serotoninérgica (a isoniazida tem atividade inibidora da MAO). Vigiar sintomas.',
  summary_pro_en = 'Isoniazid + sertraline: risk of serotonin syndrome (isoniazid has MAO-inhibiting activity). Monitor symptoms.',
  explanation_pt = 'A isoniazida tem alguma atividade inibidora da monoamina oxidase (o rótulo da isoniazida indica que tem atividade inibidora da MAO, com interação com alimentos ricos em tiramina), e os ISRS como a sertralina aumentam a disponibilidade de serotonina; em conjunto, a associação pode aumentar o risco de síndrome serotoninérgica. O rótulo da sertralina alerta para o risco aumentado com fármacos serotonérgicos e com fármacos que prejudicam o metabolismo da serotonina (como os inibidores da MAO). Vigiar sintomas de serotonina (agitação, taquicardia, hipertermia, hiperreflexia, mioclonias, rigidez), sobretudo no início do tratamento ou em aumentos de dose, e considerar alternativas se necessário.',
  explanation_en = 'Isoniazid has some monoamine oxidase inhibiting activity (the isoniazid label states it has MAO-inhibiting activity, with interaction with tyramine-rich foods), and SSRIs such as sertraline increase serotonin availability; together, the combination may increase the risk of serotonin syndrome. The sertraline label warns about the increased risk with serotonergic drugs and with drugs that impair serotonin metabolism (such as MAO inhibitors). Monitor for serotonin symptoms (agitation, tachycardia, hyperthermia, hyperreflexia, myoclonus, rigidity), especially at treatment initiation or dose increases, and consider alternatives if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 6/6 — SERTRALINA + TRAMADOL (síndrome serotoninérgica + CYP2D6)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sertralina + tramadol: risco de síndrome serotoninérgica e de convulsões (tramadol + ISRS). Vigiar de perto; considerar alternativas.',
  summary_pro_en = 'Sertraline + tramadol: risk of serotonin syndrome and seizures (tramadol + SSRI). Monitor closely; consider alternatives.',
  explanation_pt = 'O rótulo da sertralina lista o tramadol entre os serotonérgicos cujo uso concomitante aumenta o risco de síndrome serotoninérgica, e o rótulo do tramadol indica que o uso concomitante com inibidores do CYP2D6 (a sertralina inibe o CYP2D6) pode aumentar os níveis de tramadol e diminuir o metabolito ativo M1, com risco aumentado de eventos adversos graves, incluindo convulsões e síndrome serotoninérgica. A associação deve ser evitada sempre que possível; se inevitável, usar a menor dose eficaz, vigiar sintomas de serotonina (agitação, taquicardia, hipertermia, hiperreflexia) e sinais de convulsões, e reavaliar a necessidade do opioide.',
  explanation_en = 'The sertraline label lists tramadol among the serotonergic drugs whose concomitant use increases the risk of serotonin syndrome, and the tramadol label states that concomitant use with CYP2D6 inhibitors (sertraline inhibits CYP2D6) can raise tramadol levels and lower the active metabolite M1, with an increased risk of serious adverse events, including seizures and serotonin syndrome. The combination should be avoided whenever possible; if unavoidable, use the lowest effective dose, monitor for serotonin symptoms (agitation, tachycardia, hyperthermia, hyperreflexia) and signs of seizures, and reassess the need for the opioid.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));
