-- =====================================================================
-- 270 — Lote 4 (3/3): farmacologia em public.drug_pharmacology
-- ---------------------------------------------------------------------
-- 6 fármacos do Lote 4 (insulinas + excluídos DailyMed). Conteúdo
-- autoral PT/EN ancorado em EMC-UK (fonte primária), DailyMed e
-- Prontuário INFARMED (8.4.1 Insulinas).
-- Padrão 7.6: JOIN (VALUES) ON d.slug = v.slug + ON CONFLICT DO NOTHING.
-- Idempotente. Companheiras: 268 (drugs), 269 (perfis).
-- =====================================================================

INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en, half_life_pt, half_life_en,
   source_pt, source_en, status)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('insulina-regular',
   E'↓ glicemia por ↑ captação periférica de glicose e ↓ produção hepática; início 30 min, pico 1,5–3,5 h, duração 7–8 h (SC).',
   E'↓ blood glucose via ↑ peripheral glucose uptake and ↓ hepatic production; onset 30 min, peak 1.5–3.5 h, duration 7–8 h (SC).',
   E'Agonista do recetor de insulina (RTK): fosforila substratos IRS → PI3K/Akt → translocação de GLUT4 à membrana; também ativa a via MAPK (mitogénica).',
   E'Insulin receptor agonist (RTK): phosphorylates IRS substrates → PI3K/Akt → GLUT4 membrane translocation; also activates the MAPK (mitogenic) pathway.',
   E'Degradação proteolítica por insulina-degradante-enzima (IDE) hepática, renal e muscular; ~ 50% eliminado pela primeira passagem hepática endógena (não aplicável à exógena SC).',
   E'Proteolytic degradation by insulin-degrading enzyme (IDE) in liver, kidney and muscle; ~ 50% cleared by endogenous hepatic first pass (not applicable to SC exogenous).',
   E'SC: absorção rápida e variável (pico 1,5–3,5 h; influencede dose, local, fluxo sanguíneo); IV: biodisponibilidade 100%, ação imediata (cetoacidose).',
   E'SC: rapid and variable absorption (peak 1.5–3.5 h; influenced by dose, site, blood flow); IV: 100% bioavailability, immediate action (ketoacidosis).',
   E'~ 5–10 min (IV); ~ 1–1,5 h (SC; duração de efeito 7–8 h pela absorção).',
   E'~ 5–10 min (IV); ~ 1–1.5 h (SC; 7–8 h duration of effect from absorption).',
   E'EMC-UK — Actrapid 100 IU/ml SmPC (Novo Nordisk): https://www.medicines.org.uk/emc/product/3849/smpc — Prontuário Terapêutico do INFARMED (11.ª ed., 2012), 8.4.1: "início de acção 30 a 45 minutos"',   E'EMC-UK — Actrapid 100 IU/ml SmPC (Novo Nordisk): https://www.medicines.org.uk/emc/product/3849/smpc — Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012), 8.4.1: "onset of action 30 to 45 minutes"',
   'published'),

  ('insulina-nph',
   E'↓ glicemia de perfil basal; início 1–2 h, pico 4–12 h, duração 18–24 h (SC).',
   E'Basal-profile blood glucose lowering; onset 1–2 h, peak 4–12 h, duration 18–24 h (SC).',
   E'Mesmo recetor da insulina regular; a associação iónica com protamina retarda a dissociação e difusão no tecido subcutâneo, prolongando a absorção (depósito de cristais de isofano).',
   E'Same receptor as regular insulin; ionic binding to protamine delays dissociation and diffusion in subcutaneous tissue, prolonging absorption (isophane crystal depot).',
   E'Idêntica à insulina regular (degradação por IDE); a protamina é degradada por peptidases.',
   E'Identical to regular insulin (IDE degradation); protamine is degraded by peptidases.',
   E'SC exclusivo: absorção prolongada e variável pelo depósito de cristais (nunca IV — risco de hipoglicemia grave e embolização).',
   E'SC only: prolonged and variable absorption from crystal depot (never IV — risk of severe hypoglycaemia and embolisation).',
   E'~ 12–18 h (SC; dependente da absorção do depósito isofânico).',
   E'~ 12–18 h (SC; dependent on isophane depot absorption).',
   E'EMC-UK — Insulatard 100 IU/ml SmPC (Novo Nordisk): https://www.medicines.org.uk/emc/product/3848/smpc — Prontuário Terapêutico do INFARMED (11.ª ed., 2012), 8.4.1: protamina "retarda a sua absorção"',
   E'EMC-UK — Insulatard 100 IU/ml SmPC (Novo Nordisk): https://www.medicines.org.uk/emc/product/3848/smpc — Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012), 8.4.1: protamine "delays its absorption"',
   'published'),

  ('flucloxacilina',
   E'Bactericida contra S. aureus sensível (incluindo β-lactamase+); picos de TGI/TSS > 0,5 mg/L mantêm atividade em infeção profunda.',
   E'Bactericidal against sensitive S. aureus (including β-lactamase+); tissue peaks > 0.5 mg/L maintain deep-infection activity.',
   E'Inibição das proteínas de ligação à penicilina (PBPs) → bloqueio da transpeptidação da parede peptidoglicana; resistência à estafilococina β-lactamase por bloqueio estérico do substituinte isoxazol.',
   E'Inhibition of penicillin-binding proteins (PBPs) → block of peptidoglycan wall transpeptidation; resistance to staphylococcal β-lactamase via steric shielding by the isoxazol substituent.',
   E'Hepático: hidroxilação e desacetilação a metabolitos inativos; excreção biliar e renal (tubular).',
   E'Hepatic: hydroxylation and deacetylation to inactive metabolites; biliary and renal (tubular) excretion.',
   E'Oral: absorção rápida mas reduzida por alimento (jejum recomendado); IM: 100%; ligação proteica elevada (> 90%).',
   E'Oral: rapid absorption but reduced by food (fasting recommended); IM: 100%; high protein binding (> 90%).',
   E'~ 0,75–1 h (prolongado em insuficiência renal grave).',
   E'~ 0.75–1 h (prolonged in severe renal impairment).',
   E'EMC-UK — Flucloxacillin 500 mg Capsules SmPC (Brown & Burk): https://www.medicines.org.uk/emc/product/12636/smpc — sem rótulo DailyMed (regra 13.1)',
   E'EMC-UK — Flucloxacillin 500 mg Capsules SmPC (Brown & Burk): https://www.medicines.org.uk/emc/product/12636/smpc — no DailyMed label (rule 13.1)',
   'published'),

  ('espectinomicina',
   E'Bactericida contra N. gonorrhoeae ( CIM90 ≤ 32 µg/ml historicamente); atividade reduzida contra N. meningitidis e Treponema.',
   E'Bactericidal against N. gonorrhoeae (historical MIC90 ≤ 32 µg/ml); reduced activity against N. meningitidis and Treponema.',
   E'Ligação à proteína S12 da subunidade 30S do ribossoma (sítio distinto da estreptomicina) → inibição da iniciação da tradução; não provoca leitura errática do mRNA (diferente dos aminoglicosídeos clássicos).',
   E'Binding to the S12 protein of the 30S ribosomal subunit (site distinct from streptomycin) → inhibition of translation initiation; does not cause mRNA misreading (unlike classical aminoglycosides).',
   E'Mínimo metabolismo; excreção renal inalterada (~ 100% por filtração glomerular).',
   E'Minimal metabolism; ~ 100% unchanged renal excretion (glomerular filtration).',
   E'IM: biodisponibilidade 100%; pico plasmático ~ 1 h (dose 2 g); não penetra bem no LCR.',
   E'IM: 100% bioavailability; plasma peak ~ 1 h (2 g dose); poor CSF penetration.',
   E'~ 2,5 h (normal); prolongado em insuficiência renal.',
   E'~ 2.5 h (normal); prolonged in renal impairment.',
   E'Sem rótulo humano DailyMed/EMC — fonte primária: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) e protocolos OMS de ITS; contexto: EMC-UK — Gentamicin SmPC (classe aminoglicosídeo): https://www.medicines.org.uk/emc/product/3892/smpc',
   E'No human DailyMed/EMC label — primary source: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012) and WHO STI protocols; context: EMC-UK — Gentamicin SmPC (aminoglycoside class): https://www.medicines.org.uk/emc/product/3892/smpc',
   'published'),

  ('permanganato-potassio',
   E'Antisséptico/astringente tópico: oxidação de estruturas bacterianas/fúngicas e precipitação de proteínas superficiais; efeito deodorizante.',
   E'Topical antiseptic/astringent: oxidation of bacterial/fungal structures and precipitation of surface proteins; deodorising effect.',
   E'Oxidante forte (Mn7+ → Mn4+): oxida ligações dissulfureto e grupamentos proteicos de microrganismos; precipitação de proteínas da exsudação seca a superfície lesada.',
   E'Strong oxidant (Mn7+ → Mn4+): oxidises disulphide bonds and protein groups of microorganisms; precipitation of exudate proteins dries the lesion surface.',
   E'Não aplicável (uso tópico); redução do Mn7+ a MnO2 (castanho) na pele; ingerido: oxidação tissular grave (metemoglobinemia, necrose GI).',
   E'Not applicable (topical use); Mn7+ reduced to MnO2 (brown) on skin; if ingested: severe tissue oxidation (methaemoglobinaemia, GI necrosis).',
   E'Sem absorção sistémica significativa pela pele intacta; absorção aumentada em mucosas e pele lesada extensiva.',
   E'No significant systemic absorption through intact skin; increased absorption via mucosae and extensive broken skin.',
   E'Não aplicável (uso tópico localizado).',
   E'Not applicable (localised topical use).',
   E'BNF — Potassium permanganate: https://bnf.nice.org.uk/drugs/potassium-permanganate/ — SPS NHS: https://www.sps.nhs.uk/articles/using-potassium-permanganate-for-skin-conditions-or-wound-care/ — Prontuário Terapêutico do INFARMED (11.ª ed., 2012): solução 1:10.000 em eczema exsudativo',
   E'BNF — Potassium permanganate: https://bnf.nice.org.uk/drugs/potassium-permanganate/ — NHS SPS: https://www.sps.nhs.uk/articles/using-potassium-permanganate-for-skin-conditions-or-wound-care/ — Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012): 1:10,000 solution in weeping eczema',
   'published'),

  ('ciproterona',
   E'↓ androgénios efetivos: antiandrogénio periférico + progestagénio central; ↓ sebo, ↓ hirsutismo progressivo, ↓ crescimento prostático.',
   E'↓ effective androgens: peripheral antiandrogen + central progestogen; ↓ sebum, progressive ↓ hirsutism, ↓ prostate growth.',
   E'Antagonista competitivo do recetor de androgénios (AR) nos tecidos-alvo; adicionalmente efeito progestagénico central (↓ GnRH → ↓ LH → ↓ testosterona testicular/ovárica).',
   E'Competitive antagonist of the androgen receptor (AR) in target tissues; additionally central progestogenic effect (↓ GnRH → ↓ LH → ↓ testicular/ovarian testosterone).',
   E'Hepático extenso: sulfoxidação e hidroxilação a metabolitos ativos/inativos; excreção biliar/renal; circulação enterohepática.',
   E'Extensive hepatic: sulfoxidation and hydroxylation to active/inactive metabolites; biliary/renal excretion; enterohepatic circulation.',
   E'Oral: absorção rápida (> 70%); pico 3–4 h; ligação proteica > 96%; absorção destruída por alimento (efecto do metabolito ~ dose).',
   E'Oral: rapid absorption (> 70%); peak 3–4 h; protein binding > 96%; food does not significantly affect absorption.',
   E'~ 36–39 h (sulfoxido ativo; ação farmacológica sustentada no intervalo de dose).',
   E'~ 36–39 h (active sulfoxide; sustained pharmacological action between doses).',
   E'EMC-UK — Co-cyprindiol 2000/35 microgram Tablets SmPC (Morningside Healthcare): https://www.medicines.org.uk/emc/product/9760/smpc — sem rótulo DailyMed (regra 13.1)',
   E'EMC-UK — Co-cyprindiol 2000/35 microgram Tablets SmPC (Morningside Healthcare): https://www.medicines.org.uk/emc/product/9760/smpc — no DailyMed label (rule 13.1)',
   'published')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
       metabolism_pt, metabolism_en, absorption_pt, absorption_en, half_life_pt, half_life_en,
       source_pt, source_en, status)
  ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
