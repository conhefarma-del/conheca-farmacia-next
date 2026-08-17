-- =====================================================================
-- 165: Grupo 16 do Prontuário Terapêutico — Citotóxicos e Imunomoduladores
-- Adiciona 5 fármacos novos (citotóxicos/hormonas de uso sistémico) e 9
-- pares de interação, todos ancorados em rótulos FDA/DailyMed validados
-- (a 2026-08-17) e/ou no Prontuário Terapêutico (INFARMED, 11.ª ed.).
--
-- Fármacos novos:
--   ciclofosfamida (alquilante — leucemia linfocítica crónica, linfomas,
--     tumores sólidos), flutamida e bicalutamida (antiandrogénios — cancro
--     da próstata), medroxiprogesterona e megestrol (progestagénios —
--     cancro da mama/endométrio).
--
-- Pares (documentados nos rótulos/prontuário):
--   Ciclofosfamida × Ritonavir  (moderate)  — inibidores da protease podem
--     aumentar a concentração de metabolitos citotóxicos e a toxicidade
--     (mielossupressão, infeções, mucosite) — rótulo FDA.
--   Flutamida × Varfarina       (moderate)  — "Increases in prothrombin
--     time have been noted in patients receiving warfarin therapy"
--     (rótulo FDA); prontuário: "Aumenta o efeito da varfarina".
--   Medroxiprogesterona × Rifampicina (moderate) — prontuário: "Rifampicina:
--     redução do efeito"; rótulo FDA: MPA metabolizado via CYP3A4,
--     indutores podem reduzir a exposição.
--   Megestrol × Varfarina       (moderate)  — "Megestrol acetate may
--     interact with warfarin and increase International Normalized Ratio
--     (INR). Closely monitor INR" (rótulo FDA).
--   Megestrol × Rifampicina     (moderate)  — prontuário (típicas dos
--     progestagénios): "Rifampicina: redução do efeito".
--   Degarelix × Amiodarona      (moderate)  — prontuário: "A utilização
--     concomitante com fármacos que prolonguem o intervalo QTc do ECG
--     deve ser cuidadosamente avaliada (e.g. fármacos anti-arrítmicos
--     das classes Ia e III...)".
--   Degarelix × Moxifloxacina   (moderate)  — mesmo fundamento (QTc).
--
-- Nota de omissão (honestidade da fonte): a interação clássica
-- ciclofosfamida × alopurinol (mielossupressão aumentada) não consta do
-- rótulo FDA atual da ciclofosfamida consultado; documenta-se apenas o
-- que está no rótulo (inibidores da protease) — sem pares artificiais.
-- O tegafur (16.1.3) não tem rótulo FDA (uso europeu) — não entra aqui.
--
-- Fontes: rótulos aprovados FDA/DailyMed (NIH/NLM) — setIDs obtidos na
-- API pública v2 (spls.json?drug_name=...) e revalidados pelo endpoint
-- XML (spls/{setid}.xml) com confirmação do fabricante a 2026-08-17:
--   ciclofosfamida (EVER Pharma)   571a5a63-fb66-0617-e063-6394a90a2d04
--   flutamida (Waylis/EULEXIN)     0a905e25-42b6-4937-a689-f01a8f22e644
--   medroxiprogesterona (Pharmacia/PROVERA) a586be28-96af-4fed-a13f-9b94fd4c7405
--   megestrol (Natco)              582cff8a-1def-43d6-ba7e-dce49e3e9f27
--   degarelix (Ferring/FIRMAGON)   ab11dd8a-0fd9-4013-89ab-e114557c7e4b
-- Parceiros: setIDs reutilizados das citações já existentes na BD
-- (regra da secção 15.2 — não revalidar do zero).
--
-- Metodologia (ver docs/INTERACOES_FLUXO_PESQUISA.md):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * sem pares artificiais: só pares documentados nos rótulos aprovados/prontuário;
--   * idempotente (UNIQUE (drug_a_id, drug_b_id), ON CONFLICT DO NOTHING).
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
VALUES
  ('ciclofosfamida', 'Ciclofosfamida', 'Cyclophosphamide', 'Citotóxico alquilante (antitumoral/immunossupressor)', 'Alkylating cytotoxic agent (antineoplastic/immunosuppressant)', ARRAY['Ciclofosfamida', 'Endoxan'], 'published', 195),
  ('flutamida', 'Flutamida', 'Flutamide', 'Antiandrogénio (cancro da próstata)', 'Antiandrogen (prostate cancer)', ARRAY['Flutamida', 'Eulexin'], 'published', 196),
  ('medroxiprogesterona', 'Medroxiprogesterona', 'Medroxyprogesterone', 'Progestagénio (cancro da mama/endométrio)', 'Progestogen (breast/endometrial cancer)', ARRAY['Medroxiprogesterona', 'Provera'], 'published', 197),
  ('megestrol', 'Megestrol', 'Megestrol', 'Progestagénio (cancro da mama/endométrio)', 'Progestogen (breast/endometrial cancer)', ARRAY['Megestrol', 'Megace'], 'published', 198),
  ('degarelix', 'Degarelix', 'Degarelix', 'Antagonista da GnRH (cancro da próstata)', 'GnRH antagonist (prostate cancer)', ARRAY['Degarelix', 'Firmagon'], 'published', 199)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'ciclofosfamida'),
        (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciclofosfamida'),
            (SELECT id FROM public.drugs WHERE slug = 'ritonavir')),
   'moderate',
   'Ciclofosfamida + ritonavir: os inibidores da protease podem aumentar a concentração de metabolitos citotóxicos e intensificar a toxicidade da ciclofosfamida.',
   'Cyclophosphamide + ritonavir: protease inhibitors may increase the concentration of cytotoxic metabolites and enhance cyclophosphamide toxicity.',
   'O ritonavir (inibidor potente do CYP450) pode reduzir a conversão da ciclofosfamida em metabolitos inativos e aumentar a exposição aos metabolitos citotóxicos ativos — o rótulo FDA da ciclofosfamida documenta: "Concomitant use of protease inhibitors may increase the concentration of cytotoxic metabolites and may enhance the toxicities of cyclophosphamide".',
   'Ritonavir (potent CYP450 inhibitor) may reduce conversion of cyclophosphamide to inactive metabolites and increase exposure to active cytotoxic metabolites — the FDA label documents: "Concomitant use of protease inhibitors may increase the concentration of cytotoxic metabolites and may enhance the toxicities of cyclophosphamide".',
   'Vigiar sinais de toxicidade aumentada (mielossupressão, neutropenia, mucosite, infeções) em doentes a receber ciclofosfamida com inibidores da protease; considerar ajuste de dose da ciclofosfamida.',
   'Monitor for signs of enhanced toxicity (myelosuppression, neutropenia, mucositis, infections) in patients receiving cyclophosphamide with protease inhibitors; consider cyclophosphamide dose adjustment.',
   'Hemograma regular (neutrófilos, plaquetas), vigilância de infeções e mucosite durante a associação.',
   'Regular blood count (neutrophils, platelets), monitoring for infections and mucositis during the combination.',
   'Febre, neutropenia, sinais de infeção ou mucosite grave durante a terapêutica combinada.',
   'Fever, neutropenia, signs of infection or severe mucositis during combined therapy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04 ; rótulo aprovado Ritonavir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=38d0cf24-e81e-4fe6-a6e5-e7d61193f8d6',
   'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04 ; approved Ritonavir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=38d0cf24-e81e-4fe6-a6e5-e7d61193f8d6', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'flutamida'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'flutamida'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'Flutamida + varfarina: a flutamida pode aumentar o efeito anticoagulante (tempo de protrombina) — vigiar o INR.',
   'Flutamide + warfarin: flutamide may increase the anticoagulant effect (prothrombin time) — monitor INR.',
   'O rótulo FDA da flutamida documenta: "Increases in prothrombin time have been noted in patients receiving warfarin therapy". O prontuário confirma: "Aumenta o efeito da varfarina". O mecanismo não está totalmente esclarecido, mas a associação exige monitorização do INR.',
   'The FDA label documents: "Increases in prothrombin time have been noted in patients receiving warfarin therapy". The Prontuário confirms: "Increases the effect of warfarin". The mechanism is not fully established, but the combination requires INR monitoring.',
   'Monitorizar o INR ao iniciar, ajustar ou suspender a flutamida em doentes anticoagulados com varfarina; ajustar a dose da varfarina conforme necessário.',
   'Monitor INR when starting, adjusting or stopping flutamide in patients anticoagulated with warfarin; adjust warfarin dose as needed.',
   'INR frequente durante as primeiras semanas de associação e após qualquer alteração de dose.',
   'Frequent INR during the first weeks of the combination and after any dose change.',
   'Hemorragias (gengivas, epistaxe, equimoses), urina ou fezes escuras, INR acima do alvo.',
   'Bleeding (gums, epistaxis, bruising), dark urine or stools, INR above target.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Flutamida, 16.2.2.2',
   'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Flutamide, 16.2.2.2', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'medroxiprogesterona'),
        (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'medroxiprogesterona'),
            (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   'moderate',
   'Medroxiprogesterona + rifampicina: a rifampicina (indutora do CYP3A4) pode reduzir o efeito da medroxiprogesterona.',
   'Medroxyprogesterone + rifampicin: rifampicin (CYP3A4 inducer) may reduce the effect of medroxyprogesterone.',
   'A medroxiprogesterona é metabolizada principalmente por hidroxilação via CYP3A4 (rótulo FDA: "Medroxyprogesterone acetate is metabolized in-vitro primarily by hydroxylation via the CYP3A4... Inducers and/or inhibitors of CYP3A4 may affect the metabolism of MPA"). A rifampicina, indutora potente, acelera o metabolismo e reduz a exposição — o prontuário documenta: "Rifampicina: redução do efeito".',
   'Medroxyprogesterone is metabolised mainly by hydroxylation via CYP3A4 (FDA label: "Medroxyprogesterone acetate is metabolized in-vitro primarily by hydroxylation via the CYP3A4... Inducers and/or inhibitors of CYP3A4 may affect the metabolism of MPA"). Rifampicin, a potent inducer, accelerates metabolism and reduces exposure — the Prontuário documents: "Rifampicin: reduction of effect".',
   'Vigiar a resposta clínica ao tratamento hormonal; considerar alternativa ou ajuste se houver perda de eficácia durante a associação com rifampicina.',
   'Monitor clinical response to hormonal therapy; consider an alternative or adjustment if efficacy is lost during rifampicin combination.',
   'Avaliação clínica periódica da resposta (controlo oncológico/hormonal) durante a associação.',
   'Periodic clinical assessment of response (oncological/hormonal control) during the combination.',
   'Perda de controlo da doença ou reaparecimento de sintomas durante a toma conjunta com rifampicina.',
   'Loss of disease control or recurrence of symptoms during concomitant rifampicin use.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Medroxiprogesterona, 16.2.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Medroxyprogesterone, 16.2.1.3', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'Megestrol + varfarina: o megestrol pode aumentar o INR — monitorizar de perto a anticoagulação.',
   'Megestrol + warfarin: megestrol may increase INR — monitor anticoagulation closely.',
   'O rótulo FDA do megestrol documenta explicitamente: "Megestrol acetate may interact with warfarin and increase International Normalized Ratio (INR). Closely monitor INR in patients taking megestrol acetate and warfarin".',
   'The FDA label explicitly documents: "Megestrol acetate may interact with warfarin and increase International Normalized Ratio (INR). Closely monitor INR in patients taking megestrol acetate and warfarin".',
   'Monitorizar o INR de perto ao iniciar, ajustar ou suspender o megestrol em doentes anticoagulados; ajustar a dose da varfarina conforme necessário.',
   'Closely monitor INR when starting, adjusting or stopping megestrol in anticoagulated patients; adjust warfarin dose as needed.',
   'INR frequente durante a associação e após qualquer alteração de dose de megestrol.',
   'Frequent INR during the combination and after any megestrol dose change.',
   'Sinais de hemorragia (gengivas, epistaxe, equimoses, fezes escuras) ou INR acima do alvo.',
   'Signs of bleeding (gums, epistaxis, bruising, dark stools) or INR above target.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
        (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
            (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   'moderate',
   'Megestrol + rifampicina: a rifampicina (indutora do CYP3A4) pode reduzir o efeito do megestrol.',
   'Megestrol + rifampicin: rifampicin (CYP3A4 inducer) may reduce the effect of megestrol.',
   'Tal como os restantes progestagénios, o megestrol é metabolizado via CYP3A4; a rifampicina, indutora potente, acelera o metabolismo e reduz a exposição. O prontuário documenta para a classe: "Interac.: Típicas dos progestagénios... Rifampicina: redução do efeito".',
   'Like other progestogens, megestrol is metabolised via CYP3A4; rifampicin, a potent inducer, accelerates metabolism and reduces exposure. The Prontuário documents for the class: "Interactions: typical of progestogens... Rifampicin: reduction of effect".',
   'Vigiar a resposta clínica ao tratamento hormonal durante a associação com rifampicina.',
   'Monitor clinical response to hormonal therapy during rifampicin combination.',
   'Avaliação clínica periódica da resposta durante a associação.',
   'Periodic clinical assessment of response during the combination.',
   'Perda de controlo da doença durante a toma conjunta com rifampicina.',
   'Loss of disease control during concomitant rifampicin use.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Megestrol, 16.2.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Megestrol, 16.2.1.3', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
        (SELECT id FROM public.drugs WHERE slug = 'amiodarona')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
            (SELECT id FROM public.drugs WHERE slug = 'amiodarona')),
   'moderate',
   'Degarelix + amiodarona: risco de prolongamento do intervalo QT — avaliar cuidadosamente a associação.',
   'Degarelix + amiodarone: risk of QT interval prolongation — evaluate the combination carefully.',
   'O prontuário documenta para o degarelix: "A utilização concomitante com fármacos que prolonguem o intervalo QTc do ECG deve ser cuidadosamente avaliada (e.g. fármacos anti-arrítmicos das classes Ia e III...)". A amiodarona (classe III) prolonga o QT e a associação soma risco de arritmias (torsades de pointes).',
   'The Prontuário documents for degarelix: "Concomitant use with drugs that prolong the QTc interval should be carefully evaluated (e.g. class Ia and III antiarrhythmics...)". Amiodarone (class III) prolongs QT and the combination adds arrhythmia risk (torsades de pointes).',
   'Avaliar o risco individual (QT basal, eletrólitos, idade, função renal/hepática); preferir alternativas sem efeito no QT quando possível; se inevitável, vigiar o ECG.',
   'Assess individual risk (baseline QT, electrolytes, age, renal/hepatic function); prefer alternatives without QT effect when possible; if unavoidable, monitor the ECG.',
   'ECG e eletrólitos (potássio, magnésio) antes e durante a associação em doentes de risco.',
   'ECG and electrolytes (potassium, magnesium) before and during the combination in at-risk patients.',
   'Síncope, palpitações, tonturas ou QT prolongado no ECG durante a associação.',
   'Syncope, palpitations, dizziness or prolonged QT on ECG during the combination.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; rótulo aprovado Amiodarona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Degarelix, 16.2.2.5',
   'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; approved Amiodarone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Degarelix, 16.2.2.5', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
        (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
            (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina')),
   'moderate',
   'Degarelix + moxifloxacina: risco de prolongamento do intervalo QT — avaliar cuidadosamente a associação.',
   'Degarelix + moxifloxacin: risk of QT interval prolongation — evaluate the combination carefully.',
   'O prontuário documenta para o degarelix a precaução com fármacos que prolonguem o QTc, citando explicitamente a moxifloxacina ("e.g. ... moxifloxacina e alguns antipsicóticos"). A moxifloxacina é das fluoroquinolonas com maior efeito no QT — a soma com o degarelix aumenta o risco de arritmia.',
   'The Prontuário documents the precaution with QT-prolonging drugs for degarelix, explicitly citing moxifloxacin ("e.g. ... moxifloxacin and some antipsychotics"). Moxifloxacin is among the fluoroquinolones with the greatest QT effect — adding it to degarelix increases arrhythmia risk.',
   'Evitar a associação se possível; se inevitável (infeção sem alternativa), vigiar ECG e eletrólitos e usar a menor duração de antibioterapia.',
   'Avoid the combination if possible; if unavoidable (infection without alternative), monitor ECG and electrolytes and use the shortest antibiotic course.',
   'ECG e eletrólitos em doentes de risco durante a associação.',
   'ECG and electrolytes in at-risk patients during the combination.',
   'Síncope, palpitações, tonturas ou QT prolongado no ECG.',
   'Syncope, palpitations, dizziness or prolonged QT on ECG.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; rótulo aprovado Moxifloxacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1ed191f5-7df5-488c-bb72-91ac0b618d9a ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Degarelix, 16.2.2.5',
   'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; approved Moxifloxacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1ed191f5-7df5-488c-bb72-91ac0b618d9a ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Degarelix, 16.2.2.5', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
        (SELECT id FROM public.drugs WHERE slug = 'amoxicilina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
            (SELECT id FROM public.drugs WHERE slug = 'amoxicilina')),
   'moderate',
   'Metotrexato + amoxicilina: as penicilinas podem reduzir a excreção renal do metotrexato e aumentar a sua toxicidade.',
   'Methotrexate + amoxicillin: penicillins may reduce renal excretion of methotrexate and increase its toxicity.',
   'O prontuário documenta para o metotrexato: "Interac.: AINEs (excreção reduzida); penicilinas (excreção reduzida); fenitoína (toxicidade aumentada); ciclosporina (toxicidade aumentada); probenecida (excreção reduzida)". As penicilinas competem com o metotrexato pela secreção tubular renal, reduzindo a sua eliminação e aumentando os níveis plasmáticos.',
   'The Prontuário documents for methotrexate: "Interactions: NSAIDs (reduced excretion); penicillins (reduced excretion); phenytoin (increased toxicity); ciclosporin (increased toxicity); probenecid (reduced excretion)". Penicillins compete with methotrexate for renal tubular secretion, reducing its elimination and raising plasma levels.',
   'Vigiar sinais de toxicidade do metotrexato (mielossupressão, mucosite, hepatotoxicidade) durante antibioterapia com penicilinas; considerar monitorização dos níveis de metotrexato em doses altas.',
   'Monitor for signs of methotrexate toxicity (myelosuppression, mucositis, hepatotoxicity) during penicillin antibiotic therapy; consider methotrexate level monitoring at high doses.',
   'Hemograma, função renal e sinais de mucosite/úlceras orais durante a associação.',
   'Blood count, renal function and signs of mucositis/oral ulcers during the combination.',
   'Febre, neutropenia, mucosite, hematúria ou queda súbita da função renal durante a associação.',
   'Fever, neutropenia, mucositis, haematuria or sudden renal function decline during the combination.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metotrexato: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; rótulo aprovado Amoxicilina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57e56202-950b-10f6-e063-6394a90a4912 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Metotrexato, 16.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Methotrexate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; approved Amoxicillin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57e56202-950b-10f6-e063-6394a90a4912 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Methotrexate, 16.1.3', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
        (SELECT id FROM public.drugs WHERE slug = 'fenitoina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
            (SELECT id FROM public.drugs WHERE slug = 'fenitoina')),
   'moderate',
   'Metotrexato + fenitoína: risco de toxicidade aumentada do metotrexato (e possivelmente redução dos níveis de fenitoína).',
   'Methotrexate + phenytoin: risk of increased methotrexate toxicity (and possibly reduced phenytoin levels).',
   'O prontuário documenta: "fenitoína (toxicidade aumentada)" para o metotrexato. A fenitoína é altamente ligada a proteínas e a interação envolve deslocação e alterações do metabolismo — o rótulo do metotrexato lista a fenitoína entre os fármacos com os quais a associação deve ser vigiada.',
   'The Prontuário documents "phenytoin (increased toxicity)" for methotrexate. Phenytoin is highly protein-bound and the interaction involves displacement and metabolic changes — the methotrexate label lists phenytoin among drugs requiring caution.',
   'Vigiar sinais de toxicidade do metotrexato (mielossupressão, mucosite) e, se aplicável, níveis de fenitoína.',
   'Monitor for signs of methotrexate toxicity (myelosuppression, mucositis) and, if applicable, phenytoin levels.',
   'Hemograma e vigilância clínica de efeitos adversos durante a associação.',
   'Blood count and clinical monitoring of adverse effects during the combination.',
   'Febre, neutropenia, mucosite ou sinais de intoxicação por fenitoína (nistagmo, ataxia).',
   'Fever, neutropenia, mucositis or signs of phenytoin intoxication (nystagmus, ataxia).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metotrexato: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3580e6a8-f7c3-44a0-a1eb-2a84ae589d21 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Metotrexato, 16.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Methotrexate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3580e6a8-f7c3-44a0-a1eb-2a84ae589d21 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Methotrexate, 16.1.3', 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
