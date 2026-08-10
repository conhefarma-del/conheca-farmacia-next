-- =====================================================================
-- 134 — Interações fármaco-fármaco da benzilpenicilina-benzatina
-- ---------------------------------------------------------------------
-- A benzilpenicilina-benzatina (Bicillin L-A) tinha 0 pares de interação
-- fármaco-fármaco na BD, apesar de o rótulo documentar interações. Esta
-- migração cria os pares com as fontes reais:
--   • benzilpenicilina-benzatina × warfarina — o rótulo da warfarina
--     (secção 7.4 Antibiotics and Antifungals) documenta relatos de
--     alteração do INR com antibióticos e recomenda monitorização
--     apertada ao iniciar/suspender; a Bicillin L-A documenta também a
--     tetraciclina (antagonismo do efeito bactericida — par não criado,
--     fora do pedido).
--   • benzilpenicilina-benzatina × metotrexato — o rótulo do metotrexato
--     (secção 7.1 Effects of Other Drugs on Methotrexate) lista as
--     penicilinas orais ou IV entre os fármacos que aumentam a exposição
--     ao metotrexato ("Oral or intravenous penicillin or sulfonamide
--     antibiotics"), com monitorização apertada.
--   • probenecida × benzilpenicilina — documentada no rótulo (aumento
--     dos níveis séricos de penicilina por inibição da secreção tubular
--     renal), MAS a probenecida não existe na BD (182 fármacos) — par
--     não criado.
-- Fontes: rótulos aprovados DailyMed (setIDs 012d46f1-d0a0-4676-a879-
-- cd320297ab16 Bicillin L-A; 541c9a70-adaf-4ef3-94ba-ad4e70dfa057
-- warfarina; 04a95db9-a124-4b97-bd71-1c37a6b3b0c8 metotrexato), palavras-
-- chave confirmadas no texto dos rótulos descarregados a 2026-08-10.
-- Severidade moderate (padrão das restantes penicilinas × warfarina na
-- 056). Idempotente (UNIQUE drug_a_id/drug_b_id + canónico LEAST/
-- GREATEST). Aplicar na ordem 079 → 134.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'),
        (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'),
            (SELECT id FROM public.drugs WHERE slug = 'warfarina')),
   'moderate',
   'A benzilpenicilina-benzatina (antibiótico β-lactâmico) pode alterar o INR em doentes anticoagulados com varfarina, com risco hemorrágico durante o tratamento antibiótico.',
   'Penicillin G benzathine (a β-lactam antibiotic) may alter the INR in patients anticoagulated with warfarin, with a bleeding risk during antibiotic therapy.',
   'Há relatos de alterações do INR em doentes a tomar varfarina e antibióticos; os estudos farmacocinéticos não mostram efeitos consistentes nas concentrações plasmáticas da varfarina, pelo que o mecanismo é multifatorial (possível redução da flora produtora de vitamina K e alteração da hemostase).',
   'There have been reports of changes in INR in patients taking warfarin and antibiotics; pharmacokinetic studies have not shown consistent effects on plasma warfarin concentrations, so the mechanism is multifactorial (possible reduction of vitamin-K-producing gut flora and altered haemostasis).',
   'Monitorizar o INR de perto ao iniciar e ao suspender o antibiótico; ajustar a dose de varfarina conforme necessário durante a terapêutica antibiótica.',
   'Closely monitor the INR when starting and stopping the antibiotic; adjust the warfarin dose as needed during antibiotic therapy.',
   'INR, sinais de hemorragia (gengivas, equimoses, melenas, hematúria).',
   'INR, signs of bleeding (gums, bruising, melena, haematuria).',
   'Hemorragia inexplicada, hematúria, melenas, INR acima do intervalo terapêutico.',
   'Unexplained bleeding, haematuria, melena, INR above the therapeutic range.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina (secção 7.4 Antibiotics and Antifungals): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; rótulo aprovado Bicillin L-A: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=012d46f1-d0a0-4676-a879-cd320297ab16',
   'DailyMed/FDA (NIH/NLM) — approved Warfarin label (section 7.4 Antibiotics and Antifungals): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; approved Bicillin L-A label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=012d46f1-d0a0-4676-a879-cd320297ab16',
   'published', '2026-08-10 12:00:00+00'),
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'),
        (SELECT id FROM public.drugs WHERE slug = 'metotrexato')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'benzilpenicilina-benzatina'),
            (SELECT id FROM public.drugs WHERE slug = 'metotrexato')),
   'moderate',
   'A benzilpenicilina-benzatina pode aumentar as concentrações plasmáticas de metotrexato, com risco de toxicidade acrescida (mielossupressão, hepatotoxicidade).',
   'Penicillin G benzathine may increase plasma methotrexate concentrations, with an increased risk of toxicity (myelosuppression, hepatotoxicity).',
   'As penicilinas orais ou intravenosas estão listadas no rótulo do metotrexato entre os fármacos que podem aumentar a exposição ao metotrexato (possível redução da secreção tubular renal do metotrexato e deslocamento da ligação proteica).',
   'Oral or intravenous penicillins are listed in the methotrexate label among drugs that may increase methotrexate exposure (possible reduced renal tubular secretion of methotrexate and protein-binding displacement).',
   'Monitorizar de perto os sinais de toxicidade do metotrexato quando a associação não puder ser evitada; considerar ajuste de dose do metotrexato.',
   'Monitor closely for methotrexate toxicity when coadministration cannot be avoided; consider methotrexate dose adjustment.',
   'Hemograma (mielossupressão), função hepática e renal, sinais de mucosite, estomatite ou hemorragia.',
   'Blood count (myelosuppression), liver and renal function, signs of mucositis, stomatitis or bleeding.',
   'Toxicidade hematológica ou hepática, pancitopenia, mucosite grave.',
   'Haematological or hepatic toxicity, pancytopenia, severe mucositis.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metotrexato (secção 7.1 Effects of Other Drugs on Methotrexate): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; rótulo aprovado Bicillin L-A: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=012d46f1-d0a0-4676-a879-cd320297ab16',
   'DailyMed/FDA (NIH/NLM) — approved Methotrexate label (section 7.1 Effects of Other Drugs on Methotrexate): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04a95db9-a124-4b97-bd71-1c37a6b3b0c8 ; approved Bicillin L-A label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=012d46f1-d0a0-4676-a879-cd320297ab16',
   'published', '2026-08-10 12:00:00+00');

-- =====================================================================
-- FIM — 134: 2 pares (warfarina, metotrexato); probenecida não existe na
-- BD (par documentado no rótulo mas não criado)
-- =====================================================================
