-- 056: Família Antibacterianos β-lactâmicos — Penicilinas e Cefalosporinas
-- Adiciona 12 fármacos (5 penicilinas + 7 cefalosporinas) e 7 pares de interação,
-- todos de severidade 'moderate'. Total após 055: 71 fármacos e 153 pares.
--
-- Fármacos:
--   Penicilinas: ampicilina, benzilpenicilina benzatínica, fenoximetilpenicilina,
--     amoxicilina + ácido clavulânico, piperacilina + tazobactam.
--   Cefalosporinas: cefalexina (1.ª), cefazolina (1.ª), cefuroxima (2.ª), ceftriaxona,
--     cefotaxima, ceftazidima (3.ª) e cefepima (4.ª).
--   A amoxicilina já existia (044); são criados os pares amoxicilina × alopurinol.
--   A flucloxacilina foi OMITIDA: não tem rótulo aprovado pela FDA (não comercializada
--     nos EUA) nem fonte central EMA/OMS — fora do critério de fontes validadas.
--
-- Fontes: rótulos aprovados pela FDA/DailyMed — DailyMed/FDA (NIH/NLM); setIDs validados
-- na API pública v2 (spls.json?drug_name=...) e confirmados n=1 a 2026-08-04. As palavras-
-- chave de cada interação (warfarin/prothrombin, allopurinol rash, aminoglycoside
-- nephrotoxicity) foram confirmadas no texto dos rótulos (drugInfo.cfm). Referência
-- clínica adicional (apenas onde o livro documenta): Prontuário Terapêutico do INFARMED
-- (11.ª ed., 2012), secção 1.1.7 (Aminoglicosídeos) para ceftazidima × estreptomicina.
--
-- Metodologia (ver docs/INTERACOES_FLUXO_PESQUISA.md):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * sem pares artificiais: os β-lactâmicos têm poucas interações medicamentosas
--     clinicamente significativas (o próprio Prontuário destaca macrólidos, rifampicina
--     e azóis como os grupos com interações relevantes); os pares criados são os
--     documentados nos rótulos (varfarina com β-lactâmicos de largo espetro; rash com
--     alopurinol + aminopenicilinas; nefro/ototoxicidade com aminoglicosídeos);
--   * idempotente (UNIQUE (drug_a_id, drug_b_id)).
--
-- Nota clínica: a associação penicilina + aminoglicosídeo é sinérgica e intencional em
--   endocardites (não documentada como interação adversa — não criado par). A interação
--   ceftriaxona + soluções contendo cálcio (precipitação) é fármaco-solução IV e não
--   fármaco-fármaco — fora do âmbito da calculadora.
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order) VALUES
  ('ampicilina', 'Ampicilina', 'Ampicillin', 'Penicilina semissintética (aminopenicilina; antibacteriano β-lactâmico)', 'Semisynthetic penicillin (aminopenicillin; β-lactam antibacterial)', ARRAY['Ampicilina', 'Amplital'], 'published', 60),
  ('benzilpenicilina-benzatina', 'Benzilpenicilina benzatínica', 'Penicillin G Benzathine', 'Penicilina natural de ação prolongada (benzilpenicilina, via IM)', 'Natural long-acting penicillin (benzylpenicillin, IM)', ARRAY['Benzetacil', 'Penicilina G benzatínica'], 'published', 61),
  ('fenoximetilpenicilina', 'Fenoximetilpenicilina', 'Penicillin V Potassium', 'Penicilina natural oral (penicilina V)', 'Natural oral penicillin (penicillin V)', ARRAY['Penicilina V', 'Fenoximetilpenicilina'], 'published', 62),
  ('amoxicilina-clavulanato', 'Amoxicilina + Ácido Clavulânico', 'Amoxicillin and Clavulanate', 'Aminopenicilina + inibidor de β-lactamase (ácido clavulânico)', 'Aminopenicillin + β-lactamase inhibitor (clavulanate)', ARRAY['Amoxicilina/Ácido clavulânico', 'Co-amoxiclav'], 'published', 63),
  ('piperacilina-tazobactam', 'Piperacilina + Tazobactam', 'Piperacillin and Tazobactam', 'Penicilina anti-Pseudomonas + inibidor de β-lactamase (tazobactam)', 'Anti-Pseudomonas penicillin + β-lactamase inhibitor (tazobactam)', ARRAY['Piperacilina/Tazobactam'], 'published', 64),
  ('cefalexina', 'Cefalexina', 'Cephalexin', 'Cefalosporina de 1.ª geração (oral)', 'First-generation cephalosporin (oral)', ARRAY['Cefalexina', 'Keflex'], 'published', 65),
  ('cefazolina', 'Cefazolina', 'Cefazolin', 'Cefalosporina de 1.ª geração (injetável)', 'First-generation cephalosporin (injectable)', ARRAY['Cefazolina', 'Cefazolin'], 'published', 66),
  ('cefuroxima', 'Cefuroxima', 'Cefuroxime', 'Cefalosporina de 2.ª geração', 'Second-generation cephalosporin', ARRAY['Cefuroxima', 'Zinnat'], 'published', 67),
  ('ceftriaxona', 'Ceftriaxona', 'Ceftriaxone', 'Cefalosporina de 3.ª geração', 'Third-generation cephalosporin', ARRAY['Ceftriaxona', 'Rocephin'], 'published', 68),
  ('cefotaxima', 'Cefotaxima', 'Cefotaxime', 'Cefalosporina de 3.ª geração', 'Third-generation cephalosporin', ARRAY['Cefotaxima', 'Claforan'], 'published', 69),
  ('ceftazidima', 'Ceftazidima', 'Ceftazidime', 'Cefalosporina de 3.ª geração (anti-Pseudomonas)', 'Third-generation cephalosporin (anti-Pseudomonas)', ARRAY['Ceftazidima', 'Fortaz'], 'published', 70),
  ('cefepima', 'Cefepima', 'Cefepime', 'Cefalosporina de 4.ª geração', 'Fourth-generation cephalosporin', ARRAY['Cefepima', 'Maxipime'], 'published', 71);

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina-clavulanato'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina-clavulanato'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'A Amoxicilina + Ácido Clavulânico (antibiótico de largo espetro) pode potenciar o efeito anticoagulante da Varfarina, com aumento do INR e risco hemorrágico.',
'Amoxicillin + Clavulanate (a broad-spectrum antibiotic) may potentiate the anticoagulant effect of Warfarin, raising the INR and the bleeding risk.',
'Redução da flora intestinal produtora de vitamina K e alteração da hemostase, aumentando a resposta ao anticoagulante.',
'Reduction of vitamin-K-producing gut flora and altered haemostasis increase the response to the anticoagulant.',
'Monitorizar o INR ao iniciar e ao suspender o antibiótico; ajustar a dose de varfarina conforme necessário.',
'Monitor the INR when starting and stopping the antibiotic; adjust the warfarin dose as needed.',
'INR, sinais de hemorragia (gengivas, equimoses, melenas).',
'INR, signs of bleeding (gums, bruising, melena).',
'Hemorragia inexplicada, hematúria, melena.',
'Unexplained bleeding, haematuria, melena.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amoxicilina + Ácido Clavulânico: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5250085e-5509-c577-e063-6294a90a9b87 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
'DailyMed/FDA (NIH/NLM) — approved Amoxicillin + Clavulanate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5250085e-5509-c577-e063-6294a90a9b87 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'piperacilina-tazobactam'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'piperacilina-tazobactam'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'A Piperacilina + Tazobactam pode potenciar o efeito da Varfarina e interferir na hemostase, com risco hemorrágico.',
'Piperacillin + Tazobactam may potentiate Warfarin and interfere with haemostasis, with a bleeding risk.',
'Redução da flora produtora de vitamina K e disfunção plaquetar (a piperacilina pode prolongar o tempo de hemorragia), sobretudo em doses elevadas e na insuficiência renal.',
'Reduction of vitamin-K-producing flora and platelet dysfunction (piperacillin may prolong bleeding time), especially at high doses and in renal impairment.',
'Monitorizar o INR e os sinais de hemorragia; considerar ajuste da varfarina e precaução em doentes renais ou com doses elevadas.',
'Monitor the INR and bleeding signs; consider warfarin adjustment and caution in renal patients or at high doses.',
'INR, função renal, contagem plaquetar, sinais de hemorragia.',
'INR, renal function, platelet count, signs of bleeding.',
'Hemorragia ativa, equimoses extensas, hemoptise/melena.',
'Active bleeding, extensive bruising, haemoptysis/melena.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Piperacilina + Tazobactam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7aebc0e6-89db-4ef0-b5ab-d6b3199bcfc4 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
'DailyMed/FDA (NIH/NLM) — approved Piperacillin + Tazobactam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7aebc0e6-89db-4ef0-b5ab-d6b3199bcfc4 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'A Ampicilina (antibiótico de largo espetro) pode potenciar o efeito anticoagulante da Varfarina, com aumento do INR.',
'Ampicillin (a broad-spectrum antibiotic) may potentiate the anticoagulant effect of Warfarin, raising the INR.',
'Redução da flora intestinal produtora de vitamina K, aumentando a resposta ao anticoagulante.',
'Reduction of vitamin-K-producing gut flora increases the response to the anticoagulant.',
'Monitorizar o INR ao iniciar/suspender a ampicilina; ajustar a dose de varfarina conforme necessário.',
'Monitor the INR when starting/stopping ampicillin; adjust the warfarin dose as needed.',
'INR, sinais de hemorragia.',
'INR, signs of bleeding.',
'Hemorragia inexplicada, melena.',
'Unexplained bleeding, melena.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ampicilina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=402e7cc7-5ae8-c113-e063-6394a90aa54a ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
'DailyMed/FDA (NIH/NLM) — approved Ampicillin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=402e7cc7-5ae8-c113-e063-6394a90aa54a ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'ceftriaxona'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'ceftriaxona'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'A Ceftriaxona pode prolongar o tempo de protrombina e potenciar o efeito anticoagulante da Varfarina, sobretudo em tratamentos prolongados.',
'Ceftriaxone may prolong prothrombin time and potentiate the anticoagulant effect of Warfarin, especially during prolonged therapy.',
'Risco de deficiência de vitamina K e alteração da síntese de fatores de coagulação com o uso prolongado; efeito aditivo com o anticoagulante.',
'Risk of vitamin K deficiency and altered clotting-factor synthesis with prolonged use; additive effect with the anticoagulant.',
'Monitorizar PT/INR; considerar suplementação de vitamina K em utilização prolongada ou no idoso.',
'Monitor PT/INR; consider vitamin K supplementation with prolonged use or in the elderly.',
'Tempo de protrombina/INR, sinais de hemorragia.',
'Prothrombin time/INR, signs of bleeding.',
'Hemorragia inexplicada, equimoses extensas, melena.',
'Unexplained bleeding, extensive bruising, melena.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ceftriaxona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9efed4c4-72a7-4669-88ae-c80e882c1b37 ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
'DailyMed/FDA (NIH/NLM) — approved Ceftriaxone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9efed4c4-72a7-4669-88ae-c80e882c1b37 ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
        (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
            (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   'moderate',
   'A associação de Ampicilina e Alopurinol aumenta a incidência de erupções cutâneas (rash).',
'Combining Ampicillin and Allopurinol increases the incidence of skin rashes.',
'Mecanismo não totalmente esclarecido; aumento da reatividade cutânea de hipersensibilidade quando coadministrados.',
'Mechanism not fully established; increased cutaneous hypersensitivity reactivity when coadministered.',
'Vigiar o aparecimento de rash; considerar antibiótico alternativo ou suspender o alopurinol se a erupção for extensa ou pruriginosa; valorizar reação cruzada com penicilinas.',
'Watch for a rash; consider an alternative antibiotic or stop allopurinol if the eruption is extensive or pruritic; assess penicillin cross-reactivity.',
'Estado da pele (erupção, extensão, prurido), sinais de hipersensibilidade.',
'Skin status (eruption, extent, pruritus), signs of hypersensitivity.',
'Rash generalizado, febre, envolvimento de mucosas (síndrome de hipersensibilidade).',
'Generalized rash, fever, mucosal involvement (hypersensitivity syndrome).',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ampicilina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=402e7cc7-5ae8-c113-e063-6394a90aa54a ; rótulo aprovado Alopurinol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300',
'DailyMed/FDA (NIH/NLM) — approved Ampicillin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=402e7cc7-5ae8-c113-e063-6394a90aa54a ; approved Allopurinol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina'),
        (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina'),
            (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   'moderate',
   'A associação de Amoxicilina e Alopurinol aumenta a incidência de erupções cutâneas (rash).',
'Combining Amoxicillin and Allopurinol increases the incidence of skin rashes.',
'Aumento da reatividade cutânea de hipersensibilidade quando coadministrados; mecanismo não totalmente esclarecido.',
'Increased cutaneous hypersensitivity reactivity when coadministered; mechanism not fully established.',
'Vigiar o aparecimento de rash; considerar alternativa antibiótica ou ajuste do alopurinol se a erupção for relevante.',
'Watch for a rash; consider an antibiotic alternative or adjust allopurinol if the eruption is significant.',
'Estado da pele, sinais de hipersensibilidade.',
'Skin status, signs of hypersensitivity.',
'Rash generalizado, febre, envolvimento de mucosas.',
'Generalized rash, fever, mucosal involvement.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amoxicilina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57e56202-950b-10f6-e063-6394a90a4912 ; rótulo aprovado Alopurinol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300',
'DailyMed/FDA (NIH/NLM) — approved Amoxicillin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57e56202-950b-10f6-e063-6394a90a4912 ; approved Allopurinol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300',
   'published', '2026-08-04 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'ceftazidima'),
        (SELECT id FROM public.drugs WHERE slug = 'estreptomicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'ceftazidima'),
            (SELECT id FROM public.drugs WHERE slug = 'estreptomicina')),
   'moderate',
   'A associação de Ceftazidima e Estreptomicina (aminoglicosídeo) aumenta o risco de nefrotoxicidade e ototoxicidade.',
'Combining Ceftazidime and Streptomycin (an aminoglycoside) increases the risk of nephrotoxicity and ototoxicity.',
'Efeito nefrotóxico e ototóxico aditivo dos aminoglicosídeos e das cefalosporinas, sobretudo na insuficiência renal ou com doses elevadas.',
'Additive nephrotoxic and ototoxic effect of aminoglycosides and cephalosporins, especially in renal impairment or at high doses.',
'Monitorizar a função renal (creatinina) e a função auditiva; ajustar as doses pela depuração de creatinina; evitar associação prolongada.',
'Monitor renal function (creatinine) and auditory function; adjust doses for creatinine clearance; avoid prolonged combination.',
'Creatinina/urose, diurese, audição (tinnitus, hipoacusia), equilíbrio.',
'Creatinine/urinalysis, diuresis, hearing (tinnitus, hearing loss), balance.',
'Aumento da creatinina, oligúria/insuficiência renal, tinnitus ou perda auditiva.',
'Rising creatinine, oliguria/renal failure, tinnitus or hearing loss.',
'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ceftazidima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=78982c98-7866-49f1-989f-a289c4242358 ; rótulo aprovado Estreptomicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abd1f64e-4283-4370-aae8-3666316aa36e — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
'DailyMed/FDA (NIH/NLM) — approved Ceftazidime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=78982c98-7866-49f1-989f-a289c4242358 ; approved Streptomycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abd1f64e-4283-4370-aae8-3666316aa36e — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
   'published', '2026-08-04 12:00:00+00');