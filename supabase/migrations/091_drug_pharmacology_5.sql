-- =====================================================================
-- 091 — Farmacologia do fármaco (drug_pharmacology) — 5 fármacos sem
--        perfil (drug_profiles) com mais pares de interações na BD.
-- ---------------------------------------------------------------------
-- Complementa a 086 (tabela + seed piloto) e a 088 (30 fármacos com
-- perfil). Conteúdo autoral, ancorado nas fontes citadas em cada linha:
--   • claritromicina, rifampicina, cetoconazol, itraconazol: secção 12
--     CLINICAL PHARMACOLOGY dos rótulos aprovados DailyMed (setIDs
--     validados — os mesmos citados nos perfis da migração 090);
--   • aspirina: os rótulos OTC DailyMed não incluem a secção 12, pelo
--     que a farmacologia usa a revisão clássica de farmacocinética dos
--     salicilatos (Levy G. Clin Pharmacokinet 1985, PMID 3888490).
-- Depende da 086 (tabela drug_pharmacology). Idempotente:
-- ON CONFLICT (drug_id) DO NOTHING — reaplicar é seguro.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 079 → 091.
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
  ('claritromicina',
   'Macrólido antibacteriano. Distribui-se amplamente pelos tecidos e fluidos, atingindo concentrações tecidulares superiores às séricas (ex.: amígdala 1,6 mcg/g, pulmão 8,8 mcg/g após 250 mg de 12/12h). O metabolito ativo 14-OH-claritromicina contribui para a atividade antimicrobiana. Inibidor potente do CYP3A4 e da glicoproteína-P — muitas interações clinicamente relevantes.',
   'Macrolide antibacterial agent. It distributes widely into tissues and fluids, reaching tissue concentrations higher than serum (e.g. tonsil 1.6 mcg/g, lung 8.8 mcg/g after 250 mg every 12 h). The active metabolite 14-OH-clarithromycin contributes to antimicrobial activity. Potent inhibitor of CYP3A4 and P-glycoprotein — many clinically relevant interactions.',
   'Exerce a ação antibacteriana por ligação à subunidade ribossómica 50S das bactérias suscetíveis, com inibição da síntese proteica. As principais vias de resistência são a modificação do rRNA 23S (insensibilidade da subunidade 50S) e as bombas de efluxo.',
   'Exerts its antibacterial action by binding to the 50S ribosomal subunit of susceptible bacteria, inhibiting protein synthesis. The main routes of resistance are modification of the 23S rRNA (insensitivity of the 50S subunit) and efflux pumps.',
   'Metabolizada no fígado, sobretudo pelo CYP3A4, com formação do metabolito ativo 14-OH-claritromicina. A eliminação é biliar e renal; na insuficiência hepática a formação de 14-OH diminui, parcialmente compensada pelo aumento da depuração renal de claritromicina.',
   'Metabolised in the liver, mainly by CYP3A4, with formation of the active metabolite 14-OH-clarithromycin. Elimination is biliary and renal; in hepatic impairment the formation of 14-OH decreases, partially offset by increased renal clearance of clarithromycin.',
   'Bem absorvida por via oral. Na formulação de libertação prolongada (1000 mg 1x/dia), os picos plasmáticos de estado estacionário (2–3 mcg/mL) ocorrem 5 a 8 horas após a toma. Tomar com alimentos: em jejum a AUC da claritromicina é cerca de 30% menor.',
   'Well absorbed orally. With the extended-release formulation (1000 mg once daily), steady-state peak plasma concentrations (2–3 mcg/mL) occur 5 to 8 hours after dosing. Take with food: on an empty stomach the clarithromycin AUC is about 30% lower.',
   'A semivida de eliminação da claritromicina é de 3 a 4 horas e a do metabolito ativo 14-OH-claritromicina de 5 a 7 horas.',
   'The elimination half-life of clarithromycin is 3 to 4 hours and that of the active metabolite 14-OH-clarithromycin 5 to 7 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Claritromicina, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5be5f12-6392-4d7d-ab23-ebc205ac1a85',
   'DailyMed/FDA (NIH/NLM) — approved Clarithromycin label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d5be5f12-6392-4d7d-ab23-ebc205ac1a85'),

  ('rifampicina',
   'Rifamicina bactericida de largo espetro. Distribui-se amplamente pelo organismo, atingindo concentrações eficazes em muitos órgãos e fluidos, incluindo o líquido cefalorraquidiano. Cerca de 80% liga-se às proteínas plasmáticas. Indutor potente de múltiplos enzimas e transportadores (CYP1A2, 2B6, 2C8, 2C9, 2C19, 3A4, UGT, P-gp, MRP2) — reduz a exposição de inúmeros fármacos.',
   'Broad-spectrum bactericidal rifamycin. Distributes widely throughout the body, reaching effective concentrations in many organs and body fluids, including cerebrospinal fluid. About 80% is bound to plasma proteins. Potent inducer of multiple enzymes and transporters (CYP1A2, 2B6, 2C8, 2C9, 2C19, 3A4, UGT, P-gp, MRP2) — reduces exposure of numerous drugs.',
   'Inibe a atividade da RNA-polimerase dependente de ADN das bactérias suscetíveis, nomeadamente Mycobacterium tuberculosis; não inibe o enzima dos mamíferos. A resistência surge por mutações de um só passo na RNA-polimerase, pelo que nunca se usa em monoterapia na tuberculose.',
   'Inhibits DNA-dependent RNA polymerase activity in susceptible bacteria, namely Mycobacterium tuberculosis; it does not inhibit the mammalian enzyme. Resistance arises by single-step mutations of the RNA polymerase, so it is never used as monotherapy in tuberculosis.',
   'Após absorção, é rapidamente eliminada na biliar, com circulação entero-hepática e desacetilação progressiva (o metabolito desacetilado mantém atividade antibacteriana). Até 30% da dose é excretada na urina, cerca de metade como fármaco inalterado.',
   'After absorption it is rapidly eliminated in the bile, with enterohepatic circulation and progressive deacetylation (the deacetylated metabolite retains antibacterial activity). Up to 30% of a dose is excreted in the urine, about half as unchanged drug.',
   'Bem absorvida pelo trato gastrointestinal: após 600 mg orais o pico sérico médio é de 7 mcg/mL (variação 4–32 mcg/mL), atingido 1 a 2 horas após a toma. Os alimentos reduzem a absorção em cerca de 30%.',
   'Well absorbed from the gastrointestinal tract: after 600 mg orally the mean peak serum concentration is 7 mcg/mL (range 4–32 mcg/mL), reached 1 to 2 hours after dosing. Food reduces absorption by about 30%.',
   'A semivida biológica média é de 3,35 ± 0,66 horas após 600 mg orais (5,08 ± 2,45 h após 900 mg); com administração repetida diminui para cerca de 2 a 3 horas. Aumenta na insuficiência renal grave: até 11 horas em doentes anúricos (a 900 mg).',
   'The mean biological half-life is 3.35 ± 0.66 hours after 600 mg orally (5.08 ± 2.45 h after 900 mg); with repeated administration it falls to about 2 to 3 hours. It increases in severe renal failure: up to 11 hours in anuric patients (at 900 mg).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rifampicina, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b',
   'DailyMed/FDA (NIH/NLM) — approved Rifampicin label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b'),

  ('cetoconazol',
   'Antifúngico azólico oral para infeções fúngicas sistémicas graves (blastomicose, coccidioidomicose, histoplasmose, paracoccidioidomicose) quando não há alternativa. Inibidor potente do CYP3A4 e da glicoproteína-P; prolonga o intervalo QT e pode suprimir a secreção de corticosteroides adrenais em doses ≥400 mg.',
   'Oral azole antifungal for severe systemic fungal infections (blastomycosis, coccidioidomycosis, histoplasmosis, paracoccidioidomycosis) when no alternative exists. Potent CYP3A4 and P-glycoprotein inhibitor; prolongs the QT interval and can suppress adrenal corticosteroid secretion at doses ≥400 mg.',
   'Bloqueia a síntese de ergosterol, componente essencial da membrana fúngica, por inibição da enzima dependente do citocromo P450 lanosterol-14α-desmetilase, que converte o lanosterol em ergosterol. A depleção de ergosterol enfraquece a estrutura e a função da membrana fúngica.',
   'Blocks the synthesis of ergosterol, an essential component of the fungal cell membrane, by inhibiting the cytochrome P450-dependent enzyme lanosterol 14α-demethylase, which converts lanosterol into ergosterol. Ergosterol depletion weakens the structure and function of the fungal cell membrane.',
   'Após absorção gastrointestinal é convertido em vários metabolitos inativos; o CYP3A4 é o principal enzima envolvido (oxidação e degradação dos anéis imidazol e piperazina). Cerca de 13% da dose é excretada na urina (2–4% inalterado); a via principal é biliar, com cerca de 57% excretado nas fezes.',
   'After gastrointestinal absorption it is converted into several inactive metabolites; CYP3A4 is the major enzyme involved (oxidation and degradation of the imidazole and piperazine rings). About 13% of the dose is excreted in the urine (2–4% unchanged); the main route is biliary, with about 57% excreted in the faeces.',
   'Base fraca dibásica: requer acidez gástrica para dissolução e absorção. O pico plasmático (~3,5 mcg/mL após 200 mg com refeição) ocorre em 1 a 2 horas. Antiácidos e inibidores da secreção ácida reduzem muito a absorção (com omeprazol, a biodisponibilidade cai para 17%); uma bebida ácida (ex.: cola) melhora a absorção.',
   'Weak dibasic agent: requires gastric acidity for dissolution and absorption. Peak plasma concentrations (~3.5 mcg/mL after 200 mg with a meal) occur in 1 to 2 hours. Antacids and acid-suppressing drugs greatly reduce absorption (with omeprazole, bioavailability falls to 17%); an acidic drink (e.g. cola) improves absorption.',
   'Eliminação bifásica: semivida de 2 horas nas primeiras 10 horas e de 8 horas a partir daí.',
   'Biphasic elimination: a half-life of 2 hours during the first 10 hours and 8 hours thereafter.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetoconazol, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0',
   'DailyMed/FDA (NIH/NLM) — approved Ketoconazole label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f162e616-21b4-49b1-b437-15e21001a6f0'),

  ('itraconazol',
   'Antifúngico triazólico de largo espetro (dermatófitos, Candida, Aspergillus, blastomicose, histoplasmose). Acumula-se extensamente nos tecidos — concentrações 2 a 3 vezes superiores às plasmáticas em pulmão, rim, fígado e osso, e até 4 vezes na pele; nas unhas persiste até 6 meses após o fim do tratamento. Inibidor potente do CYP3A4.',
   'Broad-spectrum triazole antifungal (dermatophytes, Candida, Aspergillus, blastomycosis, histoplasmosis). It accumulates extensively in tissues — concentrations 2 to 3 times higher than plasma in lung, kidney, liver and bone, and up to 4 times in skin; it persists in nails for up to 6 months after the end of treatment. Potent CYP3A4 inhibitor.',
   'Inibe a síntese de ergosterol, componente vital da membrana fúngica, por bloqueio da enzima dependente do citocromo P450 (14α-desmetilase). O metabolito ativo hidroxi-itraconazol tem atividade antifúngica comparável à do composto original.',
   'Inhibits the synthesis of ergosterol, a vital component of the fungal cell membrane, by blocking the cytochrome P450-dependent enzyme (14α-demethylase). The active metabolite hydroxy-itraconazole has antifungal activity comparable to the parent compound.',
   'Extensamente metabolizado no fígado (CYP3A4 é o principal enzima), com formação do metabolito ativo hidroxi-itraconazol. É excretado sobretudo como metabolitos inativos: 35% na urina e 54% nas fezes na primeira semana. A depuração diminui em doses altas (metabolismo hepático saturável — farmacocinética não linear).',
   'Extensively metabolised in the liver (CYP3A4 is the main enzyme), with formation of the active metabolite hydroxy-itraconazole. It is excreted mainly as inactive metabolites: 35% in urine and 54% in faeces within the first week. Clearance decreases at high doses (saturable hepatic metabolism — non-linear pharmacokinetics).',
   'Rapidamente absorvido após administração oral: pico plasmático em 2 a 5 horas, biodisponibilidade oral absoluta de cerca de 55% (cápsulas). A absorção é máxima quando as cápsulas são tomadas imediatamente após uma refeição completa e reduzida com acidez gástrica baixa (bebida ácida melhora).',
   'Rapidly absorbed after oral administration: peak plasma concentrations in 2 to 5 hours, absolute oral bioavailability of about 55% (capsules). Absorption is maximal when the capsules are taken immediately after a full meal and reduced with low gastric acidity (an acidic drink improves it).',
   'A semivida terminal varia de 16 a 28 horas após dose única e aumenta para 34 a 42 horas com administração repetida; as concentrações plasmáticas tornam-se quase indetetáveis 7 a 14 dias após a suspensão.',
   'The terminal half-life ranges from 16 to 28 hours after a single dose and increases to 34 to 42 hours with repeated dosing; plasma concentrations become almost undetectable 7 to 14 days after discontinuation.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Itraconazol, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=68165d90-953c-e2f5-e053-2a91aa0ada25',
   'DailyMed/FDA (NIH/NLM) — approved Itraconazole label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=68165d90-953c-e2f5-e053-2a91aa0ada25'),

  ('aspirina',
   'AINE com efeito antiagregante plaquetário irreversível e dose-dependente: em dose baixa (75–100 mg/dia) inibe a produção de tromboxano A2 plaquetário, prevenindo eventos trombóticos; em doses mais altas tem efeito analgésico, antipirético e anti-inflamatório. Liga-se à albumina sérica (aspirina e ácido salicílico) e distribui-se pela cavidade sinovial, SNC e saliva.',
   'NSAID with irreversible, dose-dependent antiplatelet effect: at low dose (75–100 mg/day) it inhibits platelet thromboxane A2 production, preventing thrombotic events; at higher doses it has analgesic, antipyretic and anti-inflammatory effects. It binds to serum albumin (aspirin and salicylic acid) and distributes into the synovial cavity, CNS and saliva.',
   'Acetila de forma irreversível a ciclo-oxigenase (COX-1 e COX-2), inibindo a síntese de prostaglandinas e tromboxano A2. Como as plaquetas não têm núcleo, não sintetizam novas enzimas — o efeito antiagregante persiste durante toda a vida da plaqueta (7–10 dias).',
   'Irreversibly acetylates cyclo-oxygenase (COX-1 and COX-2), inhibiting the synthesis of prostaglandins and thromboxane A2. Since platelets have no nucleus and cannot synthesise new enzyme, the antiplatelet effect lasts for the life of the platelet (7–10 days).',
   'A aspirina é extensamente hidrolisada em ácido salicílico por esterases inespecíficas no fígado e, em menor grau, no estômago. O ácido salicílico é conjugado (ácido salicilúrico por glicina; glucuronídeos), oxidado a ácido gentísico e excretado em parte inalterado pelos rins; a eliminação renal depende do pH urinário, do fluxo urinário e da presença de ácidos orgânicos.',
   'Aspirin is extensively hydrolysed to salicylic acid by non-specific esterases in the liver and, to a lesser extent, the stomach. Salicylic acid is conjugated (salicyluric acid via glycine; glucuronides), oxidised to gentisic acid and partly excreted unchanged by the kidneys; renal elimination depends on urinary pH, urine flow and the presence of organic acids.',
   'Em solução aquosa, a aspirina é rapidamente absorvida no estômago (pH baixo); nos comprimidos a absorção é limitada pela desintegração. A absorção segue cinética de primeira ordem com semivida de absorção de 5 a 16 minutos; apenas cerca de 68% da dose atinge a circulação sistémica como aspirina.',
   'In aqueous solution aspirin is rapidly absorbed in the stomach (low pH); with tablets absorption is limited by disintegration. Absorption follows first-order kinetics with an absorption half-life of 5 to 16 minutes; only about 68% of a dose reaches the systemic circulation as aspirin.',
   'A semivida sérica da aspirina é de cerca de 20 minutos; a do ácido salicílico é dependente da dose — cerca de 2 a 3 horas em doses baixas, prolongando-se para 15 a 30 horas em doses anti-inflamatórias altas (saturação das vias metabólicas).',
   'The serum half-life of aspirin is about 20 minutes; that of salicylic acid is dose-dependent — about 2 to 3 hours at low doses, extending to 15 to 30 hours at high anti-inflammatory doses (saturation of metabolic pathways).',
   'Levy G. Clinical pharmacokinetics of the salicylates: a critical review. Clin Pharmacokinet 1985 (PMID 3888490) — https://pubmed.ncbi.nlm.nih.gov/3888490/ (os rótulos OTC DailyMed da aspirina não incluem a secção 12 Clinical Pharmacology)',
   'Levy G. Clinical pharmacokinetics of the salicylates: a critical review. Clin Pharmacokinet 1985 (PMID 3888490) — https://pubmed.ncbi.nlm.nih.gov/3888490/ (OTC DailyMed aspirin labels do not include section 12 Clinical Pharmacology)')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
       metabolism_pt, metabolism_en, absorption_pt, absorption_en,
       half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
