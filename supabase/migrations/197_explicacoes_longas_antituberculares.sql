-- =====================================================================
-- 197 — Explicações longas (Fluxo 4) dos 8 pares de antituberculares
--
-- Fontes: DailyMed/FDA (NIH/NLM), EMC-UK (MHRA)
-- Padrão: 7.1 (UPDATE com LEAST/GREATEST canónico)
-- =====================================================================

-- 1. Cicloserina × Fenitoína (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cicloserina + fenitoína: competição renal pode elevar níveis de cicloserina. Risco de efeitos neuropsiquiátricos.',
  summary_pro_en = 'Cycloserine + phenytoin: renal competition may raise cycloserine levels. Risk of neuropsychiatric effects.',
  explanation_pt = 'A cicloserina e a fenitoína são ambos eliminados por secreção tubular renal. A coadministração pode competir pelo mesmo transportador, elevando os níveis plasmáticos da cicloserina. Como a cicloserina tem margem terapêutica estreita e efeitos neuropsiquiátricos significativos (confusão, psicose, convulsões), a acumulação é clinicamente preocupante. Monitorizar sintomas neurológicos e considerar redução de dose de cicloserina.',
  explanation_en = 'Cycloserine and phenytoin are both eliminated by renal tubular secretion. Coadministration may compete for the same transporter, raising cycloserine plasma levels. As cycloserine has a narrow therapeutic margin and significant neuropsychiatric effects (confusion, psychosis, seizures), accumulation is clinically concerning. Monitor neurological symptoms and consider cycloserine dose reduction.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cicloserina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoína'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cicloserina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoína'));

-- 2. Clofazimina × Rifampicina (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clofazimina + rifampicina: indução enzimática pode reduzir níveis de clofazimina. Monitorizar resposta.',
  summary_pro_en = 'Clofazimine + rifampicin: enzyme induction may reduce clofazimine levels. Monitor response.',
  explanation_pt = 'A rifampicina induz enzimas hepáticas (CYP3A4, CYP2C8) que metabolizam a clofazimina, potencialmente reduzindo os seus níveis. Embora a clofazimina tenha uma meia-vida extremamente longa (70 dias) devido à acumulação tecidular, a indução enzimática da rifampicina pode significativamente reduzir esta acumulação ao longo do tempo. Em regimes de TB-MDR que combinam rifampicina e clofazimina (esquema B), monitorizar a resposta clínica e a coloração da pele (indicador visual de acumulação).',
  explanation_en = 'Rifampicin induces hepatic enzymes (CYP3A4, CYP2C8) that metabolise clofazimine, potentially reducing its levels. Although clofazimine has an extremely long half-life (70 days) due to tissue accumulation, rifampicin enzyme induction may significantly reduce this accumulation over time. In MDR-TB regimens combining rifampicin and clofazimine (regimen B), monitor clinical response and skin discoloration (visual indicator of accumulation).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clofazimina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clofazimina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 3. Amicacina × Furosemida (critical)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amicacina + furosemida: ototoxicidade aditiva. Risco elevado de surdez. Evitar sempre que possível.',
  summary_pro_en = 'Amikacin + furosemide: additive ototoxicity. High risk of deafness. Avoid whenever possible.',
  explanation_pt = 'A amicacina é um aminoglicosídeo ototóxico que destrói as células ciliadas cocleares e vestibulares. A furosemida, embora não seja ototóxica por si só, potencia significativamente a ototoxicidade dos aminoglicosídeos — o mecanismo proposto inclui competição pela secreção tubular (elevar os níveis de amicacina) e efeito na microcirculação coclear (isquemia das células ciliadas). Estudos demonstraram que a coadministração aumenta a incidência de perda auditiva de 5-10% (monoterapia) para 15-30%. A perda auditiva pode ser irreversível. Se a coadministração for inevitável (ex.: edema pulmonar agudo em doente com TB), monitorizar audiograma semanalmente e suspender imediatamente se houver deterioração auditiva.',
  explanation_en = 'Amikacin is an ototoxic aminoglycoside that destroys cochlear and vestibular hair cells. Furosemide, although not ototoxic on its own, significantly potentiates aminoglycoside ototoxicity — the proposed mechanism includes competition for tubular secretion (raising amikacin levels) and effect on cochlear microcirculation (hair cell ischaemia). Studies demonstrated that coadministration increases hearing loss incidence from 5-10% (monotherapy) to 15-30%. Hearing loss may be irreversible. If coadministration is unavoidable (e.g. pulmonary oedema in TB patient), monitor audiogram weekly and discontinue immediately if auditory deterioration occurs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 4. Amicacina × Estreptomicina (critical)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amicacina + estreptomicina: dois aminoglicosídeos = toxicidade aditiva. CONTRAINDICADO.',
  summary_pro_en = 'Amikacin + streptomycin: two aminoglycosides = additive toxicity. CONTRAINDICATED.',
  explanation_pt = 'A amicacina e a estreptomicina são ambos aminoglicosídeos com o mesmo mecanismo de ototoxicidade (destruição de células ciliadas cocleares e vestibulares) e nefrotoxicidade (dano tubular proximal). A coadministração causa toxicidade aditiva com risco muito elevado de surdez bilateral e insuficiência renal aguda. Não existe cenário clínico justificável para associar dois aminoglicosídeos — a OMS e os guidelines internacionais proíbem explicitamente esta combinação.',
  explanation_en = 'Amikacin and streptomycin are both aminoglycosides with the same mechanism of ototoxicity (cochlear and vestibular hair cell destruction) and nephrotoxicity (proximal tubular damage). Coadministration causes additive toxicity with very high risk of bilateral deafness and acute renal failure. There is no justifiable clinical scenario for combining two aminoglycosides — WHO and international guidelines explicitly prohibit this combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'estreptomicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'estreptomicina'));

-- 5. Etionamida × Isoniazida (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Etionamida + isoniazida: hepatotoxicidade aditiva. Monitorizar transaminases semanalmente.',
  summary_pro_en = 'Ethionamide + isoniazid: additive hepatotoxicity. Monitor transaminases weekly.',
  explanation_pt = 'A isoniazida causa hepatotoxicidade por metabolitos reativos (hidrazina, acetil-hidrazina) que formam aductos com proteínas hepáticas. A etionamida causa hepatotoxicidade por metabolitos sulfóxidos que induzem estresse oxidativo. Embora os mecanismos sejam diferentes, o resultado final é hepatocelular aditivo. Estudos demonstraram que a incidência de hepatotoxicidade grave (ALT >5x ULN) é de ~5% com isoniazida isolada, mas pode atingir 10-15% com a associação. Monitorização obrigatória: ALT/AST semanalmente nos primeiros 2 meses, depois mensalmente. Suspender se ALT >5x ULN ou se surgirem sintomas (náuseas, icterícia, dor no hipocôndrio direito).',
  explanation_en = 'Isoniazid causes hepatotoxicity via reactive metabolites (hydrazine, acetylhydrazine) that form adducts with hepatic proteins. Ethionamide causes hepatotoxicity via sulfoxide metabolites that induce oxidative stress. Although the mechanisms differ, the final result is additive hepatocellular damage. Studies demonstrated that severe hepatotoxicity incidence (ALT >5x ULN) is ~5% with isoniazid alone, but may reach 10-15% with the combination. Mandatory monitoring: ALT/AST weekly for the first 2 months, then monthly. Discontinue if ALT >5x ULN or if symptoms develop (nausea, jaundice, right hypochondrial pain).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'etionamida'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'etionamida'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'));

-- 6. Capreomicina × Amicacina (critical)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Capreomicina + amicacina: ototoxicidade e nefrotoxicidade aditivas. Evitar sempre.',
  summary_pro_en = 'Capreomycin + amikacin: additive ototoxicity and nephrotoxicity. Always avoid.',
  explanation_pt = 'A capreomicina e a amicacina são ambos fármacos injetáveis de segunda linha com o mesmo perfil de toxicidade: ototoxicidade (coclear e vestibular) e nefrotoxicidade tubular. A coadministração causa toxicidade aditiva significativa — estudos em regimes de TB-MDR demonstraram que a combinação de dois injetáveis aumenta a incidência de perda auditiva para >20% e nefrotoxicidade para >15%. A OMS recomenda usar apenas um injetável de segunda linha por vez. Se a substituição de um injetável for necessária, interromper o primeiro antes de iniciar o segundo (período de washout de 1-2 semanas para permitir eliminação).',
  explanation_en = 'Capreomycin and amikacin are both second-line injectable drugs with the same toxicity profile: ototoxicity (cochlear and vestibular) and tubular nephrotoxicity. Coadministration causes significant additive toxicity — studies in MDR-TB regimens demonstrated that combining two injectables increases hearing loss incidence to >20% and nephrotoxicity to >15%. WHO recommends using only one second-line injectable at a time. If switching between injectables is necessary, discontinue the first before starting the second (1-2 week washout period to allow elimination).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'capreomicina'), (SELECT id FROM public.drugs WHERE slug = 'amicacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'capreomicina'), (SELECT id FROM public.drugs WHERE slug = 'amicacina'));

-- 7. Terizidona × Linezolida (moderate)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Terizidona + linezolida: ambas oxazolidinonas — duplicação de toxicidade sem benefício. Não coadministrar.',
  summary_pro_en = 'Terizidone + linezolid: both oxazolidinones — toxicity duplication without benefit. Do not coadminister.',
  explanation_pt = 'A terizidona e a linezolida são ambas oxazolidinonas que atuam na subunidade 50S do ribossoma bacteriano, inibindo a iniciação da síntese proteica. Não existe sinergia entre oxazolidinonas — apenas duplicação de efeitos colaterais. A linezolida é conhecida por causar neuropatia periférica (com uso >2 semanas), mielossupressão (trombocitopenia) e ácido lático. A terizidona, sendo estruturalmente similar, partilha estes riscos. A coadministração não aumenta a eficácia mas potencia a toxicidade. Na prática, apenas uma oxazolidinona é escolhida para o regime.',
  explanation_en = 'Terizidone and linezolid are both oxazolidinones that act on the 50S ribosomal subunit, inhibiting protein synthesis initiation. There is no synergy between oxazolidinones — only duplication of side effects. Linezolid is known to cause peripheral neuropathy (with use >2 weeks), myelosuppression (thrombocytopenia) and lactic acidosis. Terizidone, being structurally similar, shares these risks. Coadministration does not increase efficacy but potentiates toxicity. In practice, only one oxazolidinone is chosen for the regimen.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'terizidona'), (SELECT id FROM public.drugs WHERE slug = 'linezolida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'terizidona'), (SELECT id FROM public.drugs WHERE slug = 'linezolida'));
