-- =====================================================================
-- 121 — Explicações fármaco-fármaco dos pares moderados do TRAMADOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 5 pares moderados do tramadol que os tinham vazios e não
-- foram cobertos noutras migrações (sertralina+tramadol já está na 120;
-- linezolida+tramadol, fluoxetina+linezolida, etc. já cobertos na 089).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais do tramadol (opioide atípico — inibidor fraco da
-- recaptação de serotonina/noradrenalina + pró-fármaco do CYP2D6):
--   1. Síndrome serotoninérgica com serotonérgicos — fluoxetina,
--      ondansetron (5-HT3), isoniazida (atividade MAO);
--   2. Sedação/SNC aditivo com anti-histamínicos — difenidramina;
--   3. CYP2D6/CYP3A4 (o rótulo alerta para os efeitos complexos dos
--      inibidores/indutores nos níveis de tramadol e do metabolito M1).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/5 — DIFENIDRAMINA + TRAMADOL (sedação aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Difenidramina + tramadol: sedação aditiva e risco de depressão do SNC. Evitar em idosos ou vigiar de perto.',
  summary_pro_en = 'Diphenhydramine + tramadol: additive sedation and CNS depression risk. Avoid in the elderly or monitor closely.',
  explanation_pt = 'A difenidramina (anti-histamínico de primeira geração) e o tramadol (opioide) têm ambos efeito depressor do sistema nervoso central; o rótulo da difenidramina alerta que os anti-histamínicos são mais propensos a causar tonturas, sedação e hipotensão em idosos, e a associação soma esse efeito ao do opioide, com risco de sedação excessiva, sonolência, confusão e queda. Recomenda-se evitar a associação sempre que possível (sobretudo em idosos), usar as menores doses eficazes, vigiar a sedação e informar o doente para não conduzir nem operar máquinas durante a associação.',
  explanation_en = 'Diphenhydramine (first-generation antihistamine) and tramadol (opioid) both depress the central nervous system; the diphenhydramine label warns that antihistamines are most likely to cause dizziness, sedation and hypotension in elderly patients, and the combination adds this effect to that of the opioid, with a risk of excessive sedation, drowsiness, confusion and falls. Avoid the combination whenever possible (especially in the elderly), use the lowest effective doses, monitor sedation and advise the patient not to drive or operate machinery during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'difenidramina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'difenidramina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

-- 2/5 — FLUOXETINA + TRAMADOL (síndrome serotoninérgica + CYP2D6)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluoxetina + tramadol: risco de síndrome serotoninérgica e de convulsões (ISRS + tramadol, inibição do CYP2D6). Vigiar de perto.',
  summary_pro_en = 'Fluoxetine + tramadol: risk of serotonin syndrome and seizures (SSRI + tramadol, CYP2D6 inhibition). Monitor closely.',
  explanation_pt = 'O rótulo da fluoxetina lista o tramadol entre os fármacos serotonérgicos cujo uso concomitante aumenta o risco de síndrome serotoninérgica, potencialmente fatal, sobretudo no início do tratamento e em aumentos de dose; o rótulo do tramadol indica que o uso concomitante com inibidores do CYP2D6 (a fluoxetina é um inibidor potente do CYP2D6) tem efeitos complexos nos níveis de tramadol e do metabolito ativo M1, com risco aumentado de eventos adversos graves, incluindo convulsões e síndrome serotoninérgica. Sempre que possível, evitar a associação ou usar a menor dose eficaz, vigiar sintomas de serotonina (agitação, taquicardia, hipertermia, hiperreflexia) e sinais de convulsões.',
  explanation_en = 'The fluoxetine label lists tramadol among the serotonergic drugs whose concomitant use increases the risk of serotonin syndrome, potentially life-threatening, especially at treatment initiation and dose increases; the tramadol label states that concomitant use with CYP2D6 inhibitors (fluoxetine is a potent CYP2D6 inhibitor) has complex effects on tramadol and active metabolite M1 levels, with an increased risk of serious adverse events, including seizures and serotonin syndrome. Whenever possible, avoid the combination or use the lowest effective dose, monitor for serotonin symptoms (agitation, tachycardia, hyperthermia, hyperreflexia) and signs of seizures.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

-- 3/5 — ISONIAZIDA + TRAMADOL (serotonina — atividade MAO da isoniazida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + tramadol: risco de síndrome serotoninérgica (a isoniazida tem atividade inibidora da MAO). Vigiar sintomas.',
  summary_pro_en = 'Isoniazid + tramadol: risk of serotonin syndrome (isoniazid has MAO-inhibiting activity). Monitor symptoms.',
  explanation_pt = 'A isoniazida tem alguma atividade inibidora da monoamina oxidase (o rótulo da isoniazida indica que tem atividade inibidora da MAO, com interação com alimentos ricos em tiramina), e o tramadol é um inibidor fraco da recaptação de serotonina e noradrenalina; em conjunto, a associação pode aumentar o risco de síndrome serotoninérgica, potencialmente fatal. O rótulo do tramadol alerta para a síndrome serotoninérgica com fármacos serotonérgicos e com fármacos que prejudicam o metabolismo da serotonina ou do tramadol (como os inibidores da MAO). Vigiar sintomas de serotonina (agitação, taquicardia, hipertermia, hiperreflexia, mioclonias, rigidez), sobretudo no início do tratamento, e considerar alternativas se necessário.',
  explanation_en = 'Isoniazid has some monoamine oxidase inhibiting activity (the isoniazid label states it has MAO-inhibiting activity, with interaction with tyramine-rich foods), and tramadol is a weak serotonin and norepinephrine reuptake inhibitor; together, the combination may increase the risk of serotonin syndrome, potentially life-threatening. The tramadol label warns about serotonin syndrome with serotonergic drugs and with drugs that impair the metabolism of serotonin or tramadol (such as MAO inhibitors). Monitor for serotonin symptoms (agitation, tachycardia, hyperthermia, hyperreflexia, myoclonus, rigidity), especially at treatment initiation, and consider alternatives if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

-- 4/5 — DEXTROMETORFANO + TRAMADOL (serotonina aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dextrometorfano + tramadol: risco de síndrome serotoninérgica (dois serotonérgicos). Evitar ou vigiar de perto.',
  summary_pro_en = 'Dextromethorphan + tramadol: risk of serotonin syndrome (two serotonergic drugs). Avoid or monitor closely.',
  explanation_pt = 'O dextrometorfano e o tramadol têm ambos ação serotoninérgica (inibição da recaptação de serotonina), e a associação soma o risco de síndrome serotoninérgica, potencialmente fatal, com sintomas como agitação, alucinações, taquicardia, hipertermia, hiperreflexia, mioclonias e rigidez. O rótulo do tramadol alerta para a síndrome serotoninérgica com o uso concomitante de fármacos serotonérgicos, e a associação de antitússico com opioide deve ser evitada sempre que possível. Se inevitável, usar as menores doses, vigiar sintomas de serotonina e considerar alternativas (ex.: antitússico não serotonérgico).',
  explanation_en = 'Both dextromethorphan and tramadol have serotonergic action (serotonin reuptake inhibition), and the combination adds up the risk of serotonin syndrome, potentially life-threatening, with symptoms such as agitation, hallucinations, tachycardia, hyperthermia, hyperreflexia, myoclonus and rigidity. The tramadol label warns about serotonin syndrome with concomitant use of serotonergic drugs, and the combination of an antitussive with an opioid should be avoided whenever possible. If unavoidable, use the lowest doses, monitor for serotonin symptoms and consider alternatives (e.g., a non-serotonergic antitussive).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

-- 5/5 — ONDANSETRON + TRAMADOL (serotonina 5-HT3 + uso aumentado de tramadol)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ondansetron + tramadol: risco de síndrome serotoninérgica (antagonista 5-HT3 + serotonérgico) e possível aumento do uso de tramadol. Vigiar analgesia e serotonina.',
  summary_pro_en = 'Ondansetron + tramadol: risk of serotonin syndrome (5-HT3 antagonist + serotonergic drug) and possible increased tramadol use. Monitor analgesia and serotonin.',
  explanation_pt = 'O rótulo do ondansetron indica que a síndrome serotoninérgica foi reportada com antagonistas dos recetores 5-HT3, na maioria dos casos com uso concomitante de fármacos serotonérgicos como o tramadol, e que o ondansetron pode aumentar a administração de tramadol pelo doente em analgesia controlada (PCA), pelo que se deve monitorizar a analgesia; o rótulo do tramadol inclui os antagonistas 5-HT3 entre os serotonérgicos com risco de síndrome serotoninérgica. Vigiar sintomas de serotonina (agitação, taquicardia, hipertermia, hiperreflexia) e garantir analgesia adequada; usar as menores doses eficazes.',
  explanation_en = 'The ondansetron label states that serotonin syndrome has been reported with 5-HT3 receptor antagonists, mostly with concomitant use of serotonergic drugs such as tramadol, and that ondansetron may increase patient-controlled administration of tramadol, so analgesia should be monitored; the tramadol label includes 5-HT3 receptor antagonists among the serotonergic drugs with a risk of serotonin syndrome. Monitor for serotonin symptoms (agitation, tachycardia, hyperthermia, hyperreflexia) and ensure adequate analgesia; use the lowest effective doses.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ondansetron'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ondansetron'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));
