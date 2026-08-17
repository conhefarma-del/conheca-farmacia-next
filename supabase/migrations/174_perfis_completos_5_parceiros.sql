-- =====================================================================
-- 174: Perfis completos dos 5 fármacos novos da 173 (parceiros fora da
--      BD) — probenecida, colestiramina, tizanidina, amantadina, cetamina
-- ---------------------------------------------------------------------
-- Objetivo: fechar a lacuna dos fármacos adicionados na 173 (aumento do
-- catálogo) com o padrão de perfil completo (mesmas 5 tabelas da 171):
--   * drug_profiles (overview público/pro, indicações, efeitos,
--     precauções);
--   * drug_pharmacology (mecanismo, metabolismo, absorção, meia-vida);
--   * drug_pregnancy_info (sempre preenchida);
--   * drug_disease_interactions (só as documentadas);
--   * drug_food_interactions (só as documentadas).
--
-- Fontes: rótulos aprovados FDA/DailyMed (NIH/NLM) — setIDs já validados
-- na 173 (a 2026-08-17); secções 7/8/12 lidas via drugInfo.cfm:
--   * Probenecida   (MARLEX)    5d552de5-2d18-4464-bcaf-0311fa3f080d
--   * Colestiramina (ASCEND)    430ac07e-8524-4dec-a599-b7ebc56d9563
--   * Tizanidina    (PREFERRED) 8d0b2b22-e1df-4ad5-92e6-f9a369108e4b
--   * Amantadina    (GOCOVRI)   2bee0631-0028-1314-e063-6394a90aaaed
--   * Cetamina      (KETALAR)   14e8f864-8b8a-4e7e-8439-e510d3107063
--
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING (e (drug_id,
-- condition_slug)/(drug_id, entity_slug) nas dimensões). Aplicar na
-- ordem: fármacos (173) → perfis/farmacologia → dimensões. Reaplicar é
-- seguro.
-- =====================================================================

-- =====================================================================
-- 1. Perfis (drug_profiles) — padrão 7.6
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en, side_effects_pt, side_effects_en,
   precautions_pt, precautions_en, source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.indications_pt, v.indications_en, v.side_effects_pt, v.side_effects_en,
       v.precautions_pt, v.precautions_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('probenecida',
   E'A probenecida é um fármaco uricosúrico usado na gota para reduzir os níveis de ácido úrico no sangue, aumentando a sua eliminação pela urina. Também é usada como adjuvante de certos antibióticos (penicilinas e outras), pois atrasa a sua eliminação e prolonga os níveis no sangue, aumentando a eficácia do antibiótico.',
   E'Probenecid is a uricosuric drug used in gout to lower blood uric acid levels by increasing its elimination in the urine. It is also used as an adjuvant to certain antibiotics (penicillins and others), as it delays their elimination and prolongs blood levels, increasing antibiotic efficacy.',
   E'Uricosúrico e bloqueador do transporte tubular renal. Inibe a reabsorção tubular do urato, aumentando a excreção urinária de ácido úrico e reduzindo os níveis séricos; inibe também a secreção tubular das penicilinas, elevando os níveis plasmáticos destas 2 a 4 vezes por qualquer via de administração. O rótulo FDA regista que pode não ser eficaz na insuficiência renal crónica quando a TFG é ≤ 30 ml/min, e não é recomendado em associação com penicilinas na presença de compromisso renal conhecido (secção PRECAUTIONS).',
   E'Uricosuric and renal tubular transport blocking agent. Inhibits tubular reabsorption of urate, increasing urinary uric acid excretion and lowering serum levels; it also inhibits tubular secretion of penicillins, raising their plasma levels 2- to 4-fold by any route of administration. The FDA label notes it may not be effective in chronic renal insufficiency when GFR is ≤ 30 mL/min, and it is not recommended in conjunction with a penicillin in the presence of known renal impairment (PRECAUTIONS section).',
   E'• Hiperuricemia associada à gota e artrite gotosa (rótulo FDA INDICATIONS AND USAGE)\\n• Adjuvante da terapêutica com penicilina, ampicilina, meticilina, oxacilina, cloxacilina ou nafcilina, para elevar e prolongar os níveis plasmáticos por qualquer via de administração',
   E'• Hyperuricemia associated with gout and gouty arthritis (FDA label INDICATIONS AND USAGE)\\n• Adjuvant to therapy with penicillin, ampicillin, methicillin, oxacillin, cloxacillin or nafcillin, to elevate and prolong plasma levels by whatever route the antibiotic is given',
   E'• Cefaleias e tonturas (SNC)\\n• Precipitação de artrite gotosa aguda (metabólico)\\n• Necrose hepática, vómitos, náuseas, anorexia, dor gengival (GI)\\n• Síndrome nefrótico, pedras de ácido úrico com ou sem hematúria, cólica renal, dor costovertebral, aumento da frequência urinária (geniturinário)\\n• Anafilaxia, febre, urticária, prurido (hipersensibilidade)\\n• Anemia aplástica, leucopenia, anemia hemolítica, anemia (hematológico)\\n• Dermatite, alopecia, rubor (tegumentar) — rótulo FDA ADVERSE REACTIONS',
   E'• Headache, dizziness (CNS)\\n• Precipitation of acute gouty arthritis (metabolic)\\n• Hepatic necrosis, vomiting, nausea, anorexia, sore gums (GI)\\n• Nephrotic syndrome, uric acid stones with or without haematuria, renal colic, costovertebral pain, urinary frequency (genitourinary)\\n• Anaphylaxis, fever, urticaria, pruritus (hypersensitivity)\\n• Aplastic anaemia, leukopenia, haemolytic anaemia, anaemia (haematologic)\\n• Dermatitis, alopecia, flushing (integumentary) — FDA label ADVERSE REACTIONS',
   E'• Não iniciar durante uma crise aguda de gota; tratar a crise primeiro (rótulo FDA)\\n• Salicilatos (mesmo em doses baixas) estão contraindicados em doentes em probenecida — antagonizam a ação uricosúrica (WARNINGS)\\n• Aumenta as concentrações plasmáticas de metotrexato — reduzir a dose deste e monitorizar níveis séricos (WARNINGS)\\n• Reações alérgicas graves e anafilaxia podem ocorrer horas após a re-administração após uso prévio — suspender perante hipersensibilidade\\n• Ineficaz na insuficiência renal crónica com TFG ≤ 30 ml/min; não recomendado com penicilinas em compromisso renal (PRECAUTIONS)\\n• Alcalinizar a urina e ingerir líquidos em abundância para prevenir pedras de ácido úrico (DOSAGE AND ADMINISTRATION)',
   E'• Do not start during an acute gout attack; treat the attack first (FDA label)\\n• Salicylates (even at low doses) are contraindicated in patients on probenecid — they antagonise the uricosuric action (WARNINGS)\\n• Increases plasma methotrexate concentrations — reduce methotrexate dose and monitor serum levels (WARNINGS)\\n• Severe allergic reactions and anaphylaxis may occur hours after re-administration following prior use — discontinue upon hypersensitivity\\n• Ineffective in chronic renal insufficiency with GFR ≤ 30 mL/min; not recommended with penicillins in renal impairment (PRECAUTIONS)\\n• Alkalinise the urine and maintain liberal fluid intake to prevent uric acid stones (DOSAGE AND ADMINISTRATION)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida (MARLEX PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label (MARLEX PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'),

  ('colestiramina',
   E'A colestiramina é um medicamento usado para baixar o colesterol, indicado quando a dieta não é suficiente. Atua no intestino: liga-se aos ácidos biliares e impede a sua reabsorção, o que leva o fígado a consumir mais colesterol para produzir novos ácidos biliares, baixando o colesterol no sangue. Não é absorvida pelo organismo.',
   E'Cholestyramine is a medicine used to lower cholesterol, indicated when diet alone is not enough. It acts in the gut: it binds bile acids and prevents their reabsorption, which leads the liver to use more cholesterol to make new bile acids, lowering blood cholesterol. It is not absorbed by the body.',
   E'Resina de permuta aniónica (cloreto) não absorvida, hipolipemiante. Adsorve e combina-se com os ácidos biliares no intestino, formando um complexo insolúvel excretado nas fezes; o aumento da perda fecal de ácidos biliares estimula a oxidação do colesterol em ácidos biliares e reduz os níveis plasmáticos de LDL (estudo LRC-CPPT: redução de 7,2% no colesterol total e 10,4% no LDL face a dieta/placebo; −19% na taxa combinada de morte coronária + IAM não fatal em 7 anos).',
   E'Non-absorbed anion exchange resin (chloride), lipid-lowering. Adsorbs and combines with bile acids in the intestine, forming an insoluble complex excreted in the faeces; the increased faecal loss of bile acids drives oxidation of cholesterol to bile acids and lowers plasma LDL levels (LRC-CPPT study: 7.2% reduction in total and 10.4% in LDL cholesterol over diet/placebo; 19% reduction in combined coronary heart disease death plus non-fatal MI over 7 years).',
   E'• Terapêutica adjuvante da dieta para redução do colesterol sérico elevado na hipercolesterolemia primária (LDL elevado) que não responde adequadamente à dieta (rótulo FDA INDICATIONS AND USAGE)\\n• Alívio do prurido associado à obstrução biliar parcial (colestase com prurido)',
   E'• Adjunctive therapy to diet for the reduction of elevated serum cholesterol in patients with primary hypercholesterolaemia (elevated LDL) who do not respond adequately to diet (FDA label INDICATIONS AND USAGE)\\n• Relief of pruritus associated with partial biliary obstruction',
   E'• Obstipação — a reação adversa mais comum (rótulo FDA ADVERSE REACTIONS)\\n• Desconforto/dor abdominal, flatulência, náuseas, vómitos, diarreia, eructação, anorexia, esteatorreia\\n• Tendência hemorrágica por hipoprotrombinemia (deficiência de vitamina K); deficiências de vitaminas A e D\\n• Acidose hiperclorémica em crianças, osteoporose, erupção e irritação da pele, língua e região perianal\\n• Raros relatos de obstrução intestinal (incluindo duas mortes) em doentes pediátricos',
   E'• Constipation — the most common adverse reaction (FDA label ADVERSE REACTIONS)\\n• Abdominal discomfort/pain, flatulence, nausea, vomiting, diarrhoea, eructation, anorexia, steatorrhoea\\n• Bleeding tendency due to hypoprothrombinaemia (vitamin K deficiency); vitamins A and D deficiencies\\n• Hyperchloraemic acidosis in children, osteoporosis, rash and irritation of the skin, tongue and perianal area\\n• Rare reports of intestinal obstruction (including two deaths) in paediatric patients',
   E'• Contraindicada na obstrução biliar completa (sem secreção de bílis para o intestino) e na hipersensibilidade a qualquer componente (CONTRAINDICATIONS)\\n• Não tomar em pó seco — misturar sempre com água ou outro líquido antes de ingerir (DOSAGE AND ADMINISTRATION)\\n• Pode interferir com a absorção de vitaminas lipossolúveis (A, D, E, K) em uso prolongado — considerar suplementação (PRECAUTIONS, Drug Interactions)\\n• Tomar outros medicamentos pelo menos 1 hora antes ou 4-6 horas depois da colestiramina (PRECAUTIONS, Drug Interactions)',
   E'• Contraindicated in complete biliary obstruction (no bile secreted into the intestine) and in hypersensitivity to any component (CONTRAINDICATIONS)\\n• Do not take as dry powder — always mix with water or other fluid before ingesting (DOSAGE AND ADMINISTRATION)\\n• May interfere with absorption of fat-soluble vitamins (A, D, E, K) in long-term use — consider supplementation (PRECAUTIONS, Drug Interactions)\\n• Take other medicines at least 1 hour before or 4-6 hours after cholestyramine (PRECAUTIONS, Drug Interactions)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Colestiramina (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
   'DailyMed/FDA (NIH/NLM) — approved Cholestyramine label (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563'),

  ('tizanidina',
   E'A tizanidina é um relaxante muscular de ação central, usado para aliviar a espasticidade (rigidez e espasmos musculares) em adultos. Atua no sistema nervoso central, reduzindo os sinais que causam o excesso de tensão muscular. Pode causar sonolência, boca seca e tonturas.',
   E'Tizanidine is a centrally acting muscle relaxant, used to relieve spasticity (muscle stiffness and spasms) in adults. It acts on the central nervous system, reducing the signals that cause excessive muscle tension. It can cause drowsiness, dry mouth and dizziness.',
   E'Agonista alfa-2 adrenérgico central que reduz a espasticidade ao aumentar a inibição pré-sináptica dos neurónios motores; o efeito é maior nas vias polissinápticas e a ação global reduz a facilitação dos neurónios motores espinais. É contraindicado com inibidores fortes do CYP1A2 (ex.: fluvoxamina, ciprofloxacina) — associação reduz a tensão arterial, aumenta a sonolência e o compromisso psicomotor. A biodisponibilidade oral é de aproximadamente 40% (metabolismo hepático de primeira passagem extenso).',
   E'Central alpha-2 adrenergic agonist that reduces spasticity by increasing presynaptic inhibition of motor neurons; the effect is greatest on polysynaptic pathways and the overall action reduces facilitation of spinal motor neurons. It is contraindicated with strong CYP1A2 inhibitors (e.g., fluvoxamine, ciprofloxacin) — the combination lowers blood pressure and increases drowsiness and psychomotor impairment. Oral bioavailability is approximately 40% (extensive first-pass hepatic metabolism).',
   E'• Tratamento da espasticidade em adultos (rótulo FDA INDICATIONS AND USAGE)',
   E'• Treatment of spasticity in adults (FDA label INDICATIONS AND USAGE)',
   E'• Boca seca, sonolência, astenia e tonturas — as mais comuns (> 10% e superiores ao placebo) (rótulo FDA ADVERSE REACTIONS)\\n• Hipotensão e síncope (5.1)\\n• Lesão hepática — monitorizar aminotransferases no início e 1 mês após a dose máxima (5.2)\\n• Sedação — efeitos aditivos com álcool e outros depressores do SNC (5.3)\\n• Alucinações (5.4)',
   E'• Dry mouth, somnolence, asthenia and dizziness — the most common (> 10% and greater than placebo) (FDA label ADVERSE REACTIONS)\\n• Hypotension and syncope (5.1)\\n• Liver injury — monitor aminotransferases at baseline and 1 month after maximum dose (5.2)\\n• Sedation — additive effects with alcohol and other CNS depressants (5.3)\\n• Hallucinations (5.4)',
   E'• Contraindicada com inibidores fortes do CYP1A2 (ex.: fluvoxamina, ciprofloxacina) e em doentes com hipersensibilidade à tizanidina (CONTRAINDICATIONS)\\n• Monitorizar sinais de hipotensão, sobretudo com anti-hipertensores concomitantes; não usar com outros agonistas alfa-2 adrenérgicos (5.1)\\n• Reduzir a dose na insuficiência renal (clearance de creatinina < 25 ml/min) e na insuficiência hepática (8.6, 8.7)\\n• Suspender gradualmente (redução de 2-4 mg/dia) para minimizar reações de privação (2.5)',
   E'• Contraindicated with strong CYP1A2 inhibitors (e.g., fluvoxamine, ciprofloxacin) and in patients with hypersensitivity to tizanidine (CONTRAINDICATIONS)\\n• Monitor for signs of hypotension, especially with concomitant antihypertensives; do not use with other alpha-2 adrenergic agonists (5.1)\\n• Reduce dose in renal impairment (creatinine clearance < 25 mL/min) and in hepatic impairment (8.6, 8.7)\\n• Discontinue gradually (reduction of 2-4 mg/day) to minimise withdrawal reactions (2.5)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina (PREFERRED PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label (PREFERRED PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b'),

  ('amantadina',
   E'A amantadina é um medicamento usado na doença de Parkinson, nomeadamente para tratar as discinesias (movimentos involuntários) em doentes tratados com levodopa e os episódios de "off" (retorno dos sintomas entre doses). Tem também atividade antiviral (influenza A), embora a sua utilização atual se foque no Parkinson.',
   E'Amantadine is a medicine used in Parkinson disease, notably to treat dyskinesias (involuntary movements) in patients treated with levodopa and "off" episodes (return of symptoms between doses). It also has antiviral activity (influenza A), although current use focuses on Parkinson disease.',
   E'Antagonista fraco e não competitivo do recetor NMDA (mecanismo da eficácia nas discinesias não é totalmente conhecido); sem atividade anticolinérgica direta em estudos animais, mas com efeitos secundários tipo-anticolinérgicos (boca seca, retenção urinária, obstipação) e efeitos tipo-dopaminérgicos (alucinações, tonturas) em humanos. É excretado essencialmente inalterado na urina — a insuficiência renal acumula o fármaco e a doença renal terminal é contraindicação. Forma de libertação prolongada (GOCOVRI): pico plasmático mediano ~12 h após a dose ao deitar; estado estacionário ao 4.º dia.',
   E'Weak uncompetitive antagonist of the NMDA receptor (mechanism of efficacy in dyskinesias not fully known); no direct anticholinergic activity in animal studies, but anticholinergic-like side effects (dry mouth, urinary retention, constipation) and dopaminergic-like effects (hallucinations, dizziness) in humans. It is excreted essentially unchanged in the urine — renal impairment accumulates the drug and end-stage renal disease is a contraindication. Extended-release formulation (GOCOVRI): median peak plasma concentration ~12 h after bedtime dose; steady state by day 4.',
   E'• Discinesias em doentes com doença de Parkinson em terapêutica baseada em levodopa, com ou sem outros dopaminérgicos (rótulo FDA GOCOVRI INDICATIONS AND USAGE)\\n• Tratamento adjuvante da levodopa/carbidopa em doentes com episódios de "off"',
   E'• Dyskinesia in patients with Parkinson disease receiving levodopa-based therapy, with or without concomitant dopaminergic medications (FDA label GOCOVRI INDICATIONS AND USAGE)\\n• Adjunctive treatment to levodopa/carbidopa in patients experiencing "off" episodes',
   E'• Alucinações, tonturas, boca seca, edema periférico, obstipação, quedas e hipotensão ortostática — > 10% e superiores ao placebo (rótulo FDA ADVERSE REACTIONS)\\n• Sonolência e episódios de adormecimento súbito em atividades da vida diária (5.1)\\n• Suicidabilidade e depressão — monitorizar (5.2)\\n• Comportamentos compulsivos/impulso (5.7)',
   E'• Hallucinations, dizziness, dry mouth, peripheral oedema, constipation, falls and orthostatic hypotension — > 10% and greater than placebo (FDA label ADVERSE REACTIONS)\\n• Somnolence and sudden sleep episodes during activities of daily living (5.1)\\n• Suicidality and depression — monitor (5.2)\\n• Compulsive/impulse behaviours (5.7)',
   E'• Contraindicada na doença renal terminal (clearance de creatinina < 15 ml/min/1,73 m²) (CONTRAINDICATIONS)\\n• Evitar o álcool — pode aumentar o potencial de efeitos no SNC (tonturas, confusão, hipotensão ortostática) e causar dose-dumping (7.4)\\n• Reduzir a dose de anticolinérgicos ou da amantadina se surgirem efeitos tipo-atropina (7.1)\\n• Não suspender bruscamente — redução gradual para evitar hiperpirexia e confusão (5.5)\\n• Não recomendada com vacinas vivas atenuadas da gripe (7.3)',
   E'• Contraindicated in end-stage renal disease (creatinine clearance < 15 mL/min/1.73 m²) (CONTRAINDICATIONS)\\n• Avoid alcohol — may increase the potential for CNS effects (dizziness, confusion, orthostatic hypotension) and cause dose-dumping (7.4)\\n• Reduce the dose of anticholinergics or amantadine if atropine-like effects appear (7.1)\\n• Do not stop abruptly — taper to avoid hyperpyrexia and confusion (5.5)\\n• Not recommended with live attenuated influenza vaccines (7.3)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amantadina (GOCOVRI, SUPER NUS PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
   'DailyMed/FDA (NIH/NLM) — approved Amantadine label (GOCOVRI, SUPER NUS PHARMACEUTICALS): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed'),

  ('cetamina',
   E'A cetamina é um anestésico geral usado em procedimentos diagnósticos e cirúrgicos que não exigem relaxamento muscular, para indução da anestesia antes de outros anestésicos e como complemento de outros agentes anestésicos. Atua rapidamente e é usada em ambiente hospitalar, sob supervisão de profissionais experientes.',
   E'Ketamine is a general anaesthetic used for diagnostic and surgical procedures that do not require skeletal muscle relaxation, for induction of anaesthesia before other anaesthetics and as a supplement to other anaesthetic agents. It acts rapidly and is used in the hospital setting, under the supervision of experienced professionals.',
   E'Anestésico dissociativo: mistura racémica, antagonista não seletivo e não competitivo do recetor NMDA (recetor ionotrópico do glutamato); o metabolito principal (norketamina) tem atividade no mesmo recetor com menor afinidade (~1/3 da atividade da cetamina). Administração iv: fase alfa de ~45 min com meia-vida de 10-15 min (corresponde ao efeito anestésico), seguida de redistribuição do SNC para tecidos periféricos (fase beta, meia-vida de 2,5 h).',
   E'Dissociative anaesthetic: racemic mixture, non-selective non-competitive antagonist of the NMDA receptor (an ionotropic glutamate receptor); the main metabolite (norketamine) has activity at the same receptor with lower affinity (~1/3 of ketamine activity). IV administration: alpha phase of ~45 min with a half-life of 10-15 min (corresponding to the anaesthetic effect), followed by redistribution from the CNS to peripheral tissues (beta phase, half-life 2.5 h).',
   E'• Único agente anestésico em procedimentos diagnósticos e cirúrgicos que não requerem relaxamento muscular esquelético (rótulo FDA INDICATIONS AND USAGE)\\n• Indução da anestesia antes da administração de outros anestésicos gerais\\n• Complemento de outros agentes anestésicos',
   E'• Sole anaesthetic agent for diagnostic and surgical procedures that do not require skeletal muscle relaxation (FDA label INDICATIONS AND USAGE)\\n• Induction of anaesthesia prior to administration of other general anaesthetics\\n• Supplement to other anaesthetic agents',
   E'• Reações de emergência (estados confusionais pós-operatórios) — as mais comuns (rótulo FDA ADVERSE REACTIONS)\\n• Elevação da tensão arterial e da frequência cardíaca\\n• Depressão respiratória (com sobredosagem ou administração demasiado rápida)\\n• Disfunção hepatobiliar com uso recorrente (padrão colestático, colangite esclerosante em uso prolongado) (5.6)',
   E'• Emergence reactions (postoperative confusional states) — the most common (FDA label ADVERSE REACTIONS)\\n• Elevated blood pressure and pulse\\n• Respiratory depression (with overdosage or too rapid administration)\\n• Hepatobiliary dysfunction with recurrent use (cholestatic pattern, sclerosing cholangitis in long-term use) (5.6)',
   E'• Contraindicada em doentes em quem uma elevação significativa da tensão arterial seria um perigo grave e na hipersensibilidade à cetamina (CONTRAINDICATIONS)\\n• Monitorizar sinais vitais e função cardíaca durante a administração (5.1)\\n• Minimizar estímulos verbais, táteis e visuais para reduzir reações de emergência (5.2)\\n• Não usar como único agente em cirurgia/procedimentos da faringe, laringe ou árvore brônquica (5.4)\\n• Neurotoxicidade pediátrica: défices cognitivos a longo prazo com uso > 3 h em crianças ≤ 3 anos (5.5)\\n• Obter LFTs basais (incluindo FA e GGT) em doentes com doses recorrentes (5.6)',
   E'• Contraindicated in patients for whom a significant elevation of blood pressure would be a serious hazard and in hypersensitivity to ketamine (CONTRAINDICATIONS)\\n• Monitor vital signs and cardiac function during administration (5.1)\\n• Minimise verbal, tactile and visual stimulation to reduce emergence reactions (5.2)\\n• Do not use as sole agent in surgery/procedures of the pharynx, larynx or bronchial tree (5.4)\\n• Paediatric neurotoxicity: long-term cognitive deficits with use > 3 h in children ≤ 3 years (5.5)\\n• Obtain baseline LFTs (including ALP and GGT) in patients receiving recurrent doses (5.6)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetamina (KETALAR, PAR HEALTH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine label (KETALAR, PAR HEALTH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
        indications_pt, indications_en, side_effects_pt, side_effects_en,
        precautions_pt, precautions_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 2. Farmacologia (drug_pharmacology) — padrão 7.6
-- =====================================================================
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en,
   half_life_pt, half_life_en, source_pt, source_en, status)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('probenecida',
   E'Uricosúrico: reduz a reabsorção tubular do urato, aumentando a excreção urinária de ácido úrico e baixando os níveis séricos; a uricosúria eficaz reduz o pool de urato miscível e promove a reabsorção de depósitos de urato. Adjuvante de antibióticos: inibe a secreção tubular das penicilinas, elevando os níveis plasmáticos 2 a 4 vezes (rótulo FDA CLINICAL PHARMACOLOGY).',
   E'Uricosuric: reduces tubular reabsorption of urate, increasing urinary uric acid excretion and lowering serum levels; effective uricosuria reduces the miscible urate pool and promotes resorption of urate deposits. Antibiotic adjuvant: inhibits tubular secretion of penicillins, raising plasma levels 2- to 4-fold (FDA label CLINICAL PHARMACOLOGY).',
   E'Bloqueador do transporte tubular renal: inibe competitivamente a reabsorção tubular do urato e a secreção tubular de vários compostos (penicilinas, PAH, PAS, indometacina, sulfonamidas, sulfonilureias, entre outros), aumentando a sua excreção ou os seus níveis plasmáticos.',
   E'Renal tubular transport blocker: competitively inhibits tubular reabsorption of urate and tubular secretion of several compounds (penicillins, PAH, PAS, indomethacin, sulfonamides, sulfonylureas, among others), increasing their excretion or plasma levels.',
   E'O rótulo não detalha o metabolismo; o fármaco e os metabolitos (incluindo o glucurónido acil) são eliminados por via renal, com reabsorção tubular — a excreção é dependente da função renal (ineficaz com TFG ≤ 30 ml/min).',
   E'The label does not detail metabolism; the drug and metabolites (including the acyl glucuronide) are eliminated renally, with tubular reabsorption — excretion is dependent on renal function (ineffective with GFR ≤ 30 mL/min).',
   E'Rótulo não quantifica a absorção oral; fármaco bem absorvido por via oral (descrição de uso oral em comprimidos de 500 mg). A eficácia uricosúrica requer função renal preservada.',
   E'The label does not quantify oral absorption; the drug is well absorbed orally (oral tablet use, 500 mg). Uricosuric efficacy requires preserved renal function.',
   E'Rótulo não documenta a meia-vida da probenecida; regista que a probenecida aumenta a meia-vida plasmática média de vários fármacos (indometacina, paracetamol, naproxeno, cetoprofeno, lorazepam, rifampicina) por inibição do transporte renal.',
   E'The label does not document probenecid half-life; it records that probenecid increases the mean plasma elimination half-life of several drugs (indomethacin, acetaminophen, naproxen, ketoprofen, lorazepam, rifampin) by inhibiting renal transport.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida, secção CLINICAL PHARMACOLOGY: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label, CLINICAL PHARMACOLOGY section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'),

  ('colestiramina',
   E'Hipolipemiante por sequestração de ácidos biliares: a perda fecal de ácidos biliares leva ao aumento da oxidação do colesterol em ácidos biliares, com redução do beta-lipoproteína/LDL e do colesterol sérico (rótulo FDA CLINICAL PHARMACOLOGY). Em obstrução biliar parcial, reduz os níveis séricos de ácidos biliares e o prurido.',
   E'Lipid-lowering by bile acid sequestration: the faecal loss of bile acids leads to increased oxidation of cholesterol to bile acids, with reduction of beta-lipoprotein/LDL and serum cholesterol (FDA label CLINICAL PHARMACOLOGY). In partial biliary obstruction, it reduces serum bile acid levels and pruritus.',
   E'A resina adsorve e combina-se com os ácidos biliares no intestino, formando um complexo insolúvel excretado nas fezes — interrompe parcialmente a circulação entero-hepática dos ácidos biliares. Não é absorvida do trato digestivo.',
   E'The resin adsorbs and combines with bile acids in the intestine, forming an insoluble complex excreted in the faeces — partially interrupting the enterohepatic circulation of bile acids. It is not absorbed from the digestive tract.',
   E'Não é metabolizada — atua no lúmen intestinal sem absorção sistémica.',
   E'Not metabolised — acts in the gut lumen with no systemic absorption.',
   E'Absorção: nula — \"Cholestyramine resin is not absorbed from the digestive tract\" (DESCRIPTION). Por isso o perfil é exclusivamente local/intestinal.',
   E'Absorption: none — \"Cholestyramine resin is not absorbed from the digestive tract\" (DESCRIPTION). The profile is therefore exclusively local/intestinal.',
   E'Meia-vida não aplicável (fármaco não absorvido; sem exposição sistémica).',
   E'Half-life not applicable (non-absorbed drug; no systemic exposure).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Colestiramina, secções DESCRIPTION/CLINICAL PHARMACOLOGY: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
   'DailyMed/FDA (NIH/NLM) — approved Cholestyramine label, DESCRIPTION/CLINICAL PHARMACOLOGY sections: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563'),

  ('tizanidina',
   E'Relaxante muscular de ação central: agonista alfa-2 adrenérgico central que aumenta a inibição pré-sináptica dos neurónios motores, com efeito máximo nas vias polissinápticas e redução da facilitação dos neurónios motores espinais (rótulo FDA 12.1). Os efeitos depressores do SNC são aditivos com o álcool (12.2).',
   E'Centrally acting muscle relaxant: central alpha-2 adrenergic agonist that increases presynaptic inhibition of motor neurons, with maximal effect on polysynaptic pathways and reduced facilitation of spinal motor neurons (FDA label 12.1). CNS depressant effects are additive with alcohol (12.2).',
   E'Agonista alfa-2 adrenérgico central: a redução da espasticidade resulta do aumento da inibição pré-sináptica dos neurónios motores (predominantemente nas vias polissinápticas).',
   E'Central alpha-2 adrenergic agonist: the reduction of spasticity results from increased presynaptic inhibition of motor neurons (predominantly on polysynaptic pathways).',
   E'Metabolismo hepático extenso de primeira passagem (por isso a biodisponibilidade oral é de ~40%); metabolizado sobretudo pelo CYP1A2 — os inibidores fortes do CYP1A2 estão contraindicados.',
   E'Extensive first-pass hepatic metabolism (hence oral bioavailability of ~40%); metabolised mainly by CYP1A2 — strong CYP1A2 inhibitors are contraindicated.',
   E'Absorção oral essencialmente completa; biodisponibilidade sistémica absoluta de aproximadamente 40% (CV = 24%) devido ao extenso metabolismo hepático de primeira passagem (12.3). Com alimentos: aumento de ~30% no Cmax e na extensão de absorção (comprimidos); Tmax de ~1 h em jejum.',
   E'Oral absorption essentially complete; absolute systemic bioavailability of approximately 40% (CV = 24%) due to extensive first-pass hepatic metabolism (12.3). With food: ~30% increase in Cmax and extent of absorption (tablets); Tmax ~1 h fasting.',
   E'Meia-vida de eliminação de aproximadamente 2 horas em jejum (Tmax 1,0 h); com alimentos, o Tmax mediano aumenta 25 min (para 1 h 25 min).',
   E'Elimination half-life of approximately 2 hours fasting (Tmax 1.0 h); with food, median Tmax increases by 25 min (to 1 h 25 min).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b'),

  ('amantadina',
   E'Antiparkinsónico/antidiscinético: a eficácia nas discinesias da doença de Parkinson e nos episódios de \"off\" não tem mecanismo totalmente esclarecido; a amantadina é um antagonista fraco e não competitivo do recetor NMDA, sem atividade anticolinérgica direta em animais, mas com efeitos secundários tipo-anticolinérgicos e tipo-dopaminérgicos em humanos (rótulo FDA 12.1).',
   E'Antiparkinsonian/antidyskinetic: the efficacy in Parkinson disease dyskinesias and \"off\" episodes has no fully clarified mechanism; amantadine is a weak uncompetitive antagonist of the NMDA receptor, with no direct anticholinergic activity in animals, but with anticholinergic-like and dopaminergic-like side effects in humans (FDA label 12.1).',
   E'Antagonismo fraco e não competitivo do recetor NMDA (glutamato); efeitos indiretos sobre os neurónios dopaminérgicos. A inibição de transportadores (OCT2/MATE) justifica o aumento da exposição a substratos como a metformina (ver 173).',
   E'Weak uncompetitive antagonism of the NMDA receptor (glutamate); indirect effects on dopaminergic neurons. Inhibition of transporters (OCT2/MATE) explains the increased exposure to substrates such as metformin (see 173).',
   E'Oito metabolitos identificados na urina; o N-acetilado quantificado representa 0-15% da dose administrada; a contribuição para eficácia/toxicidade é desconhecida (12.3).',
   E'Eight metabolites identified in urine; the quantified N-acetylated compound accounts for 0-15% of the administered dose; contribution to efficacy/toxicity is unknown (12.3).',
   E'Forma de libertação prolongada (GOCOVRI): Tmax mediano ~12 h (intervalo 6-20 h) após dose ao deitar; estado estacionário ao 4.º dia; razão de acumulação 1,2-1,3. A refeição rica em gordura/calorias não afeta a farmacocinética; sem efeito da suspensão sobre molho de maçã (12.3).',
   E'Extended-release form (GOCOVRI): median Tmax ~12 h (range 6-20 h) after bedtime dose; steady state by day 4; accumulation ratio 1.2-1.3. High-fat, high-calorie meal does not affect pharmacokinetics; no effect of sprinkling on applesauce (12.3).',
   E'Meia-vida plasmática média no estado estacionário de aproximadamente 16 horas; volume de distribuição iv de 3-8 L/kg; ligação às proteínas ~67% (0,1-2,0 µg/ml).',
   E'Mean plasma half-life at steady state of approximately 16 hours; IV volume of distribution 3-8 L/kg; protein binding ~67% (0.1-2.0 µg/mL).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amantadina (GOCOVRI), secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
   'DailyMed/FDA (NIH/NLM) — approved Amantadine label (GOCOVRI), section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed'),

  ('cetamina',
   E'Anestésico geral dissociativo de ação rápida: induz anestesia cirúrgica em 5-10 min após injeção iv (2 mg/kg em ~30 s) ou em 3-4 min após via im; o efeito anestésico dura tipicamente 12-25 min (im). Provoca elevação da tensão arterial e da frequência cardíaca (rótulo FDA 2.2).',
   E'Rapid-acting dissociative general anaesthetic: produces surgical anaesthesia within 5-10 min after IV injection (2 mg/kg within ~30 s) or within 3-4 min after IM; the anaesthetic effect typically lasts 12-25 min (IM). It raises blood pressure and heart rate (FDA label 2.2).',
   E'Antagonista não seletivo e não competitivo do recetor NMDA (recetor ionotrópico do glutamato); o metabolito principal, a norketamina, tem atividade no mesmo recetor com menor afinidade (~1/3 da atividade da cetamina na redução do MAC em ratos).',
   E'Non-selective, non-competitive antagonist of the NMDA receptor (ionotropic glutamate receptor); the main metabolite, norketamine, has activity at the same receptor with lower affinity (~1/3 of ketamine activity in reducing MAC in rats).',
   E'Metabolizada por N-desalquilação em norketamina (ativa), sobretudo pelo CYP2B6 e CYP3A4; a norketamina sofre hidroxilação e conjugação com ácido glucurónico (12.3).',
   E'Metabolised by N-dealkylation to norketamine (active), mainly by CYP2B6 and CYP3A4; norketamine undergoes hydroxylation and glucuronic acid conjugation (12.3).',
   E'Distribuição rápida após administração iv (fase alfa ~45 min); redistribuição do SNC para tecidos periféricos mais lentos (fase beta). Uso clínico hospitalar (iv/im); sem relevância de absorção oral para uso anestésico.',
   E'Rapid distribution after IV administration (alpha phase ~45 min); redistribution from the CNS to slower equilibrating peripheral tissues (beta phase). Hospital clinical use (IV/IM); oral absorption not relevant for anaesthetic use.',
   E'Meia-vida da fase alfa (efeito anestésico): 10-15 min; meia-vida de redistribuição (fase beta): 2,5 horas.',
   E'Alpha-phase half-life (anaesthetic effect): 10-15 min; redistribution half-life (beta phase): 2.5 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetamina (KETALAR), secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine label (KETALAR), section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
        metabolism_pt, metabolism_en, absorption_pt, absorption_en,
        half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 3. Gravidez (drug_pregnancy_info) — sempre preenchida (17.3)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('probenecida', 'caution',
   E'Rótulo FDA (Use in Pregnancy): \"Probenecid crosses the placenta barrier and appears in cord blood. The use of any drug in women of childbearing potential requires that the anticipated benefit be weighed against the possible hazards.\" Sem estudos adequados e bem controlados em grávidas.',
   E'FDA label (Use in Pregnancy): \"Probenecid crosses the placenta barrier and appears in cord blood. The use of any drug in women of childbearing potential requires that the anticipated benefit be weighed against the possible hazards.\" No adequate and well-controlled studies in pregnant women.',
   E'Atravessa a placenta e aparece no sangue do cordão; usar apenas se o benefício antecipado justificar o risco.',
   E'Crosses the placenta and appears in cord blood; use only if the anticipated benefit justifies the risk.',
   E'Sem dados no rótulo sobre excreção no leite materno; o perfil de segurança em lactentes não está estabelecido.',
   E'No label data on excretion in breast milk; the safety profile in breastfed infants is not established.',
   E'Ponderar benefício/risco em mulheres em idade fértil (rótulo não exige contraceção específica).',
   E'Weigh benefit/risk in women of childbearing potential (label does not require specific contraception).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida, secção WARNINGS (Use in Pregnancy): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label, WARNINGS section (Use in Pregnancy): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'),

  ('colestiramina', 'caution',
   E'Rótulo FDA (Pregnancy Category C): sem estudos adequados e bem controlados em grávidas. Não é absorvida sistemicamente, mas interfere com a absorção de vitaminas lipossolúveis — a suplementação pré-natal regular pode não ser adequada durante o uso.',
   E'FDA label (Pregnancy Category C): no adequate and well-controlled studies in pregnant women. Not systemically absorbed, but interferes with absorption of fat-soluble vitamins — regular prenatal supplementation may not be adequate during use.',
   E'Categoria C: usar apenas se o benefício justificar o risco; garantir suplementação de vitaminas lipossolúveis.',
   E'Category C: use only if benefit justifies risk; ensure fat-soluble vitamin supplementation.',
   E'Cautela no aleitamento: a possível má absorção de vitaminas (secção Pregnancy) pode afetar os lactentes.',
   E'Caution in breastfeeding: the possible poor vitamin absorption (Pregnancy section) may affect nursing infants.',
   E'Não aplicável (sem contraceção específica documentada).',
   E'Not applicable (no specific contraception documented).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Colestiramina, secção Pregnancy/Nursing Mothers: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
   'DailyMed/FDA (NIH/NLM) — approved Cholestyramine label, Pregnancy/Nursing Mothers section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563'),

  ('tizanidina', 'caution',
   E'Rótulo FDA (8.1): sem dados adequados sobre o risco do desenvolvimento em grávidas; em estudos animais, a tizanidina na gravidez resultou em toxicidade do desenvolvimento (mortalidade embriofetal e pós-natal da descendência, défices de crescimento) em doses inferiores às clínicas.',
   E'FDA label (8.1): no adequate data on the developmental risk in pregnant women; in animal studies, tizanidine during pregnancy resulted in developmental toxicity (embryofetal and postnatal offspring mortality, growth deficits) at doses lower than clinical.',
   E'Risco potencial de dano fetal com base em dados animais; usar apenas se o benefício justificar o risco.',
   E'Potential risk of fetal harm based on animal data; use only if benefit justifies risk.',
   E'Sem dados sobre a presença no leite humano, efeitos no lactente ou produção de leite; estudos animais reportaram presença no leite de animais lactantes (8.2).',
   E'No data on presence in human milk, effects on the breastfed infant or milk production; animal studies reported presence in the milk of lactating animals (8.2).',
   E'Não documentada especificamente no rótulo (sem secção 8.3 com requisitos).',
   E'Not specifically documented in the label (no 8.3 section with requirements).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina, secção 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label, section 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b'),

  ('amantadina', 'caution',
   E'Rótulo FDA (GOCOVRI, 8.1): sem dados adequados sobre o risco do desenvolvimento em grávidas; estudos em animais sugerem risco potencial de dano fetal — efeitos adversos do desenvolvimento (embriotoxicidade, aumento de malformações, redução do peso fetal) em doses clinicamente relevantes em ratos e murganhos.',
   E'FDA label (GOCOVRI, 8.1): no adequate data on the developmental risk in pregnant women; animal studies suggest a potential risk of fetal harm — adverse developmental effects (embryolethality, increased malformations, reduced fetal weight) at clinically relevant doses in rats and mice.',
   E'Risco potencial de dano fetal com base em dados animais; usar apenas se o benefício justificar o risco.',
   E'Potential risk of fetal harm based on animal data; use only if benefit justifies risk.',
   E'A amantadina é excretada no leite humano (quantidade não quantificada) e pode alterar a produção/excreção de leite (8.2).',
   E'Amantadine is excreted into human milk (amounts not quantified) and may alter milk production or excretion (8.2).',
   E'Não documentada especificamente no rótulo (sem secção 8.3 com requisitos).',
   E'Not specifically documented in the label (no 8.3 section with requirements).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amantadina (GOCOVRI), secção 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
   'DailyMed/FDA (NIH/NLM) — approved Amantadine label (GOCOVRI), section 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed'),

  ('cetamina', 'caution',
   E'Rótulo FDA (KETALAR, 8.1): dados disponíveis descrevem sobretudo o uso na cesariana, sem risco identificado de desfechos maternos ou fetais adversos; em estudos animais, atrasos do desenvolvimento (hipoplasia de tecidos esqueléticos) a 0,3× a dose humana im; em primatas, anestésicos que bloqueiam NMDA durante o pico de desenvolvimento cerebral aumentam a apoptose neuronal quando usados > 3 h.',
   E'FDA label (KETALAR, 8.1): available data mostly describe use at caesarean section, with no identified risk of adverse maternal or fetal outcomes; in animal studies, developmental delays (hypoplasia of skeletal tissues) at 0.3× the human IM dose; in primates, anaesthetics blocking NMDA during peak brain development increase neuronal apoptosis when used > 3 h.',
   E'Usar se o benefício justificar o risco; equilibrar o benefício da anestesia adequada com o risco potencial sugerido pelos dados não clínicos.',
   E'Use if benefit justifies risk; balance the benefit of adequate anaesthesia with the potential risk suggested by nonclinical data.',
   E'Publicações descrevem a presença da cetamina e do seu metabolito no leite humano; monitorizar o lactente para sedação, depressão respiratória e aumento do tónus muscular/espasmos; limitar o uso a anestesia em mulheres lactantes (8.2).',
   E'Literature describes the presence of ketamine and its metabolite in human milk; monitor the infant for sedation, respiratory depression and increased muscle tone/spasms; limit use to anaesthesia in lactating women (8.2).',
   E'Não documentada especificamente no rótulo (sem secção 8.3 com requisitos).',
   E'Not specifically documented in the label (no 8.3 section with requirements).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetamina (KETALAR), secção 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine label (KETALAR), section 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
        lactation_pt, lactation_en, contraception_pt, contraception_en,
        source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 4. Doença (drug_disease_interactions) — só as documentadas
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- Probenecida × insuficiência renal (rótulo FDA PRECAUTIONS)
  ('probenecida', 'insuficiencia_renal', 'Insuficiência renal', 'Renal insufficiency', 'precaution', 'moderate',
   E'Rótulo FDA (PRECAUTIONS): a probenecida pode não ser eficaz na insuficiência renal crónica, sobretudo quando a TFG é ≤ 30 ml/min; por mecanismo de ação, não é recomendada com uma penicilina na presença de compromisso renal conhecido. A eficácia uricosúrica depende da função tubular renal.',
   E'FDA label (PRECAUTIONS): probenecid may not be effective in chronic renal insufficiency, particularly when GFR is ≤ 30 mL/min; because of its mechanism of action, it is not recommended in conjunction with a penicillin in the presence of known renal impairment. Uricosuric efficacy depends on renal tubular function.',
   E'Considerar alternativa terapêutica na insuficiência renal (TFG ≤ 30 ml/min); avaliar a necessidade da associação com penicilinas no doente renal.',
   E'Consider a therapeutic alternative in renal impairment (GFR ≤ 30 mL/min); assess the need for the combination with penicillins in the renal patient.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida, secção PRECAUTIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label, PRECAUTIONS section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d', 1),

  -- Probenecida × litíase renal (pedras de ácido úrico — CONTRAINDICATIONS)
  ('probenecida', 'litase_renal', 'Litíase renal (pedras de ácido úrico)', 'Renal lithiasis (uric acid stones)', 'contraindication', 'critical',
   E'Rótulo FDA (CONTRAINDICATIONS): a probenecida não é recomendada em pessoas com pedras renais de ácido úrico conhecidas. A uricosúria aumenta a excreção urinária de ácido úrico, o que pode precipitar cristalização e formação de pedras na urina ácida.',
   E'FDA label (CONTRAINDICATIONS): probenecid is not recommended in persons with known uric acid kidney stones. Uricosuria increases urinary uric acid excretion, which may precipitate crystallisation and stone formation in acidic urine.',
   E'Contraindicada na litíase renal de ácido úrico; se usada, alcalinizar a urina e manter ingestão hídrica abundante.',
   E'Contraindicated in uric acid renal lithiasis; if used, alkalinise the urine and maintain liberal fluid intake.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida, secção CONTRAINDICATIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label, CONTRAINDICATIONS section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d', 2),

  -- Probenecida × úlcera péptica (PRECAUTIONS)
  ('probenecida', 'ulcera_peptica', 'Úlcera péptica', 'Peptic ulcer', 'precaution', 'moderate',
   E'Rótulo FDA (PRECAUTIONS): \"Use with caution in patients with a history of peptic ulcer.\" O mecanismo não é totalmente esclarecido, mas a precaução está registada no rótulo.',
   E'FDA label (PRECAUTIONS): \"Use with caution in patients with a history of peptic ulcer.\" The mechanism is not fully clarified, but the caution is recorded in the label.',
   E'Usar com precaução em doentes com história de úlcera péptica; vigiar sintomas gastrointestinais.',
   E'Use with caution in patients with a history of peptic ulcer; monitor gastrointestinal symptoms.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida, secção PRECAUTIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid label, PRECAUTIONS section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d', 3),

  -- Colestiramina × obstrução biliar completa (CONTRAINDICATIONS)
  ('colestiramina', 'colestase_obstrutiva', 'Colestase obstrutiva (obstrução biliar completa)', 'Obstructive cholestasis (complete biliary obstruction)', 'contraindication', 'critical',
   E'Rótulo FDA (CONTRAINDICATIONS): a colestiramina é contraindicada em doentes com obstrução biliar completa, em que a bílis não é secretada para o intestino — sem ácidos biliares no lúmen, o mecanismo de ação do fármaco não se aplica.',
   E'FDA label (CONTRAINDICATIONS): cholestyramine is contraindicated in patients with complete biliary obstruction where bile is not secreted into the intestine — without bile acids in the lumen, the drug mechanism of action does not apply.',
   E'Contraindicada na obstrução biliar completa; a indicação de prurido limita-se à obstrução biliar parcial.',
   E'Contraindicated in complete biliary obstruction; the pruritus indication is limited to partial biliary obstruction.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Colestiramina, secção CONTRAINDICATIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
   'DailyMed/FDA (NIH/NLM) — approved Cholestyramine label, CONTRAINDICATIONS section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563', 1),

  -- Tizanidina × insuficiência renal (8.6)
  ('tizanidina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal insufficiency', 'precaution', 'moderate',
   E'Rótulo FDA (8.6): na insuficiência renal (clearance de creatinina < 25 ml/min), o clearance da tizanidina está reduzido — a redução da dose é recomendada e o risco de reações adversas pode ser maior.',
   E'FDA label (8.6): in renal insufficiency (creatinine clearance < 25 mL/min), tizanidine clearance is reduced — dose reduction is recommended and the risk of adverse reactions may be greater.',
   E'Reduzir a dose na insuficiência renal (CrCl < 25 ml/min); aumentar doses individuais em vez da frequência; monitorizar de perto (sonolência, hipotensão).',
   E'Reduce dose in renal impairment (CrCl < 25 mL/min); increase individual doses rather than dosing frequency; monitor closely (somnolence, hypotension).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina, secção 8.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label, section 8.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b', 1),

  -- Tizanidina × insuficiência hepática (8.7)
  ('tizanidina', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic insufficiency', 'precaution', 'moderate',
   E'Rótulo FDA (8.7): usar com precaução na insuficiência hepática — o metabolismo hepático extenso do fármaco faz esperar efeitos significativos na farmacocinética; redução da dose recomendada (2.4).',
   E'FDA label (8.7): use with caution in hepatic impairment — the extensive hepatic metabolism of the drug is expected to significantly affect pharmacokinetics; dose reduction recommended (2.4).',
   E'Reduzir a dose na insuficiência hepática e monitorizar aminotransferases (risco de lesão hepática — 5.2).',
   E'Reduce dose in hepatic impairment and monitor aminotransferases (risk of liver injury — 5.2).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina, secção 8.7: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label, section 8.7: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b', 2),

  -- Amantadina × doença renal terminal (CONTRAINDICATIONS)
  ('amantadina', 'insuficiencia_renal_grave', 'Insuficiência renal grave / doença renal terminal', 'Severe renal insufficiency / end-stage renal disease', 'contraindication', 'critical',
   E'Rótulo FDA (GOCOVRI, 4/8.6): contraindicada na doença renal terminal (clearance de creatinina < 15 ml/min/1,73 m²). A amantadina é excretada essencialmente inalterada na urina — a insuficiência renal acumula o fármaco e aumenta o risco de toxicidade.',
   E'FDA label (GOCOVRI, 4/8.6): contraindicated in end-stage renal disease (creatinine clearance < 15 mL/min/1.73 m²). Amantadine is excreted essentially unchanged in the urine — renal impairment accumulates the drug and increases the risk of toxicity.',
   E'Contraindicada na doença renal terminal; na insuficiência renal moderada/grave (CrCl 15-59 ml/min), reduzir a dose (68,5 mg/dia na grave).',
   E'Contraindicated in end-stage renal disease; in moderate/severe renal impairment (CrCl 15-59 mL/min), reduce the dose (68.5 mg/day in severe).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amantadina (GOCOVRI), secções 4/8.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
   'DailyMed/FDA (NIH/NLM) — approved Amantadine label (GOCOVRI), sections 4/8.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed', 1),

  -- Cetamina × hipertensão não controlada (CONTRAINDICATIONS)
  ('cetamina', 'hipertensao_nao_controlada', 'Hipertensão não controlada', 'Uncontrolled hypertension', 'contraindication', 'critical',
   E'Rótulo FDA (KETALAR, 4): contraindicada em doentes para quem uma elevação significativa da tensão arterial seria um perigo grave. A cetamina eleva a tensão arterial e a frequência cardíaca (efeito simpaticomimético direto).',
   E'FDA label (KETALAR, 4): contraindicated in patients for whom a significant elevation of blood pressure would be a serious hazard. Ketamine raises blood pressure and heart rate (direct sympathomimetic effect).',
   E'Contraindicada em doentes com hipertensão não controlada ou em que a elevação da TA seria um perigo grave; monitorizar sinais vitais durante a administração.',
   E'Contraindicated in patients with uncontrolled hypertension or in whom blood pressure elevation would be a serious hazard; monitor vital signs during administration.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetamina (KETALAR), secção 4 CONTRAINDICATIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine label (KETALAR), section 4 CONTRAINDICATIONS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063', 1),

  -- Cetamina × doença hepática (uso recorrente — 5.6)
  ('cetamina', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'precaution', 'moderate',
   E'Rótulo FDA (KETALAR, 5.6): a administração de cetamina está associada a disfunção hepatobiliar (sobretudo padrão colestático) com uso recorrente (abuso ou indicações não aprovadas); colangite esclerosante reportada em terapêutica prolongada, potencialmente reversível com a suspensão.',
   E'FDA label (KETALAR, 5.6): ketamine administration is associated with hepatobiliary dysfunction (most often a cholestatic pattern) with recurrent use (misuse/abuse or unapproved indications); sclerosing cholangitis reported in long-term therapy, potentially reversible on discontinuation.',
   E'Obter LFTs basais (incluindo FA e GGT) em doentes com doses recorrentes e monitorizar periodicamente; suspender perante sinais de colangite esclerosante.',
   E'Obtain baseline LFTs (including ALP and GGT) in patients receiving recurrent doses and monitor periodically; discontinue upon signs of sclerosing cholangitis.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetamina (KETALAR), secção 5.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine label (KETALAR), section 5.6: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063', 2)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 5. Alimentos (drug_food_interactions) — só as documentadas
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- Colestiramina × vitaminas lipossolúveis (PRECAUTIONS, Drug Interactions)
  ('colestiramina', 'vitaminas_lipossoliveis', 'Vitaminas lipossolúveis (A, D, E, K)', 'Fat-soluble vitamins (A, D, E, K)', 'moderate',
   E'Rótulo FDA (PRECAUTIONS, Drug Interactions): porque a colestiramina liga os ácidos biliares, pode interferir com a digestão/absorção normal das gorduras e impedir a absorção das vitaminas lipossolúveis (A, D, E, K) — com uso prolongado, considerar suplementação com formas hidrossolúveis (ou parentéricas).',
   E'FDA label (PRECAUTIONS, Drug Interactions): because cholestyramine binds bile acids, it may interfere with normal fat digestion and absorption and prevent absorption of fat-soluble vitamins (A, D, E, K) — in long-term use, consider supplementation with water-miscible (or parenteral) forms.',
   E'Com uso prolongado, considerar suplementação de vitaminas lipossolúveis (A, D, E, K); separar a toma de suplementos vitamínicos da colestiramina.',
   E'In long-term use, consider supplementation of fat-soluble vitamins (A, D, E, K); separate vitamin supplements from cholestyramine dosing.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Colestiramina, secção PRECAUTIONS/Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
   'DailyMed/FDA (NIH/NLM) — approved Cholestyramine label, PRECAUTIONS/Drug Interactions section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563', 1),

  -- Tizanidina × álcool (7.4)
  ('tizanidina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   E'Rótulo FDA (7.4): o álcool aumenta a exposição à tizanidina (associado ao aumento de reações adversas) e o uso concomitante com outros depressores do SNC pode causar efeitos depressores aditivos, incluindo sedação. Os efeitos depressores do SNC da tizanidina e do álcool são aditivos (12.2).',
   E'FDA label (7.4): alcohol increases tizanidine exposure (associated with increased adverse reactions) and concomitant use with other CNS depressants may cause additive CNS depressant effects, including sedation. The CNS depressant effects of tizanidine and alcohol are additive (12.2).',
   E'Evitar o álcool durante o tratamento; monitorizar sintomas de sedação excessiva em doentes que tomam tizanidina com outro depressor do SNC.',
   E'Avoid alcohol during treatment; monitor for symptoms of excess sedation in patients taking tizanidine with another CNS depressant.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tizanidina, secção 7.4: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b',
   'DailyMed/FDA (NIH/NLM) — approved Tizanidine label, section 7.4: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8d0b2b22-e1df-4ad5-92e6-f9a369108e4b', 1),

  -- Amantadina × álcool (7.4)
  ('amantadina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   E'Rótulo FDA (GOCOVRI, 7.4): o uso concomitante com álcool não é recomendado, pois pode aumentar o potencial de efeitos no SNC (tonturas, confusão, sensação de desmaio, hipotensão ortostática) e pode resultar em dose-dumping (libertação rápida da formulação de libertação prolongada).',
   E'FDA label (GOCOVRI, 7.4): concomitant use with alcohol is not recommended, as it may increase the potential for CNS effects (dizziness, confusion, lightheadedness, orthostatic hypotension) and may result in dose-dumping (rapid release of the extended-release formulation).',
   E'Evitar o álcool durante o tratamento com amantadina (libertação prolongada).',
   E'Avoid alcohol during treatment with amantadine (extended-release).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amantadina (GOCOVRI), secção 7.4: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed',
   'DailyMed/FDA (NIH/NLM) — approved Amantadine label (GOCOVRI), section 7.4: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bee0631-0028-1314-e063-6394a90aaaed', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
        mechanism_pt, mechanism_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;
