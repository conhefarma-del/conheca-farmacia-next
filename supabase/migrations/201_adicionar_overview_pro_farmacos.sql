-- =====================================================================
-- 201 — Adicionar overview_pro_pt/en aos perfis das migrações 191 e 195
--
-- Os perfis de antirretrovirais (191) e antituberculares (195) foram
-- criados sem overview_pro_pt/en. Este UPDATE adiciona os textos
-- profissionais a cada perfil existente.
-- =====================================================================

-- =====================================================================
-- 1. Antirretrovirais (migração 191)
-- =====================================================================
UPDATE public.drug_profiles SET
  overview_pro_pt = 'NtRTI oral. Excreção renal 100% inalterado. Não é metabolizado. Risco de nefrotoxicidade e redução da densidade óssea. Ajustar em insuficiência renal.',
  overview_pro_en = 'Oral NtRTI. 100% renal excretion unchanged. Not metabolised. Risk of nephrotoxicity and bone density loss. Adjust in renal impairment.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'tenofovir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NRTI oral. Excreção renal 86% inalterado. Baixo potencial de interações (não inibe CYP). Meia-vida intracelular longa permite dose diária.',
  overview_pro_en = 'Oral NRTI. 86% renal excretion unchanged. Low interaction potential (does not inhibit CYP). Long intracellular half-life allows once-daily dosing.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'emtricitabina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'INSTI oral. Metabolismo via UGT1A1 e CYP3A4. Alta barreira genética à resistência. Induzido por rifampicina (dose dupla). Não requer potenciador.',
  overview_pro_en = 'Oral INSTI. Metabolised by UGT1A1 and CYP3A4. High genetic barrier to resistance. Induced by rifampicin (double dose). Does not require booster.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'dolutegravir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'PI/r. Ritonavir inibe CYP3A4, elevando lopinavir ~100x. Metabolismo extenso via CYP3A4. Aproveitamento oral aumentado por alimentos.',
  overview_pro_en = 'PI/r. Ritonavir inhibits CYP3A4, raising lopinavir ~100-fold. Extensive CYP3A4 metabolism. Oral bioavailability increased by food.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'lopinavir-ritonavir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'PI de segunda geração. Potenciado por ritonavir ou cobicistat. Elevada barreira genética à resistência. Metabolismo via CYP3A4.',
  overview_pro_en = 'Second-generation PI. Boosted by ritonavir or cobicistat. High genetic barrier to resistance. CYP3A4 metabolism.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'darunavir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NRTI. Metabolismo via álcool desidrogenase e UGT1A1. Teste HLA-B*5701 obrigatório antes de iniciar. Reação de hipersensibilidade potencialmente fatal.',
  overview_pro_en = 'NRTI. Metabolised by alcohol dehydrogenase and UGT1A1. Mandatory HLA-B*5701 testing before initiation. Potentially fatal hypersensitivity reaction.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'abacavir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'INSTI. Metabolismo via UGT1A1 (não CYP3A4). Elevação de creatinina (inibe secreção tubular — sem efeito na TFG real). Induzido por rifampicina.',
  overview_pro_en = 'INSTI. UGT1A1 metabolism (not CYP3A4). Creatinine elevation (inhibits tubular secretion — no effect on actual GFR). Induced by rifampicin.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'raltegravir');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NNRTI de segunda geração. Metabolismo via CYP3A4, CYP2C9, CYP2C19. Atividade contra mutações K103N e Y181C. Comprimidos devem ser mastigados.',
  overview_pro_en = 'Second-generation NNRTI. Metabolised by CYP3A4, CYP2C9, CYP2C19. Active against K103N and Y181C mutations. Tablets should be chewed.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'etravirina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NNRTI de nova geração. Metabolismo via CYP3A4. Requer carga viral baixa (<100.000). Absorção aumentada por alimentos — DEVE ser tomado com refeição.',
  overview_pro_en = 'Next-generation NNRTI. CYP3A4 metabolism. Requires low viral load (<100,000). Absorption increased by food — MUST be taken with a meal.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'rilpivirina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NRTI de primeira geração. Fosforilação intracelular ao trifosfato ativo. Meia-vida curta (0,6-1,6h) — dose duas vezes ao dia. Neuropatia periférica comum.',
  overview_pro_en = 'First-generation NRTI. Intracellular phosphorylation to active triphosphate. Short half-life (0.6-1.6h) — twice-daily dosing. Peripheral neuropathy common.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'estavudina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'NRTI de primeira geração. Raramente utilizado. Pancreatite, neuropatia, acidose láctica. Tomar em jejum. Substituída por fármacos mais modernos.',
  overview_pro_en = 'First-generation NRTI. Rarely used. Pancreatitis, neuropathy, lactic acidosis. Take on empty stomach. Replaced by newer drugs.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'didanosina');

-- =====================================================================
-- 2. Antituberculares (migração 195)
-- =====================================================================
UPDATE public.drug_profiles SET
  overview_pro_pt = 'Antibiótico tuberculostático de segunda linha. Mecanismo: antagonista da D-alanina. Penetração SNC excelente. Efeitos neuropsiquiátricos comuns (convulsões, psicose).',
  overview_pro_en = 'Second-line tuberculostatic antibiotic. Mechanism: D-alanine antagonist. Excellent CNS penetration. Neuropsychiatric effects common (seizures, psychosis).'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'cicloserina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Riminofenilazina com atividade tuberculostática e anti-inflamatória. Meia-vida extremamente longa (70 dias). Acumulação tecidular (pele, fígado).',
  overview_pro_en = 'Rimino-phenazine with tuberculostatic and anti-inflammatory activity. Extremely long half-life (70 days). Tissue accumulation (skin, liver).'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'clofazimina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Aminoglicosídeo parenteral. Atividade bactericida potente contra M. tuberculosis. Nefrotoxicidade e ototoxicidade — monitorizar TFG e audiograma. Reservado para TBRM.',
  overview_pro_en = 'Parenteral aminoglycoside. Potent bactericidal activity against M. tuberculosis. Nephrotoxicity and ototoxicity — monitor GFR and audiogram. Reserved for MDR-TB.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'amicacina');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Pró-fármaco ativado pela LiuA micobacteriana. Inibe síntese de ácidos micólicos. Hepatotoxicidade — monitorizar ALT. Absorção melhorada com alimentos.',
  overview_pro_en = 'Prodrug activated by mycobacterial LiuA. Inhibits mycolic acid synthesis. Hepatotoxicity — monitor ALT. Absorption improved with food.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'etionamida');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Análogo da etionamida com mecanismo idêntico. Pró-fármaco ativado pela LiuA. Hepatotoxicidade e efeitos gastrointestinais comuns.',
  overview_pro_en = 'Ethionamide analogue with identical mechanism. Prodrug activated by LiuA. Hepatotoxicity and gastrointestinal effects common.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'protionamida');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Oxazolidinona com atividade tuberculostática. Inibe síntese proteica bacteriana (ligação à subunidade 50S). Efeitos neuropsiquiátricos (convulsões).',
  overview_pro_en = 'Oxazolidinone with tuberculostatic activity. Inhibits bacterial protein synthesis (50S subunit binding). Neuropsychiatric effects (seizures).'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'terizidona');

UPDATE public.drug_profiles SET
  overview_pro_pt = 'Peptídeo cíclico parenteral. Mecanismo semelhante aos aminoglicosídeos. Ototoxicidade e nefrotoxicidade — EVITAR combinação com outros ototóxicos.',
  overview_pro_en = 'Parenteral cyclic peptide. Mechanism similar to aminoglycosides. Ototoxicity and nephrotoxicity — AVOID combination with other ototoxic agents.'
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'capreomicina');
