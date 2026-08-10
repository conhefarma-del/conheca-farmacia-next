-- =====================================================================
-- 132 — Perfil + farmacologia dos 2 fármacos em falta (correção da 096)
-- ---------------------------------------------------------------------
-- A migração 096 usou slugs com underscore ('benzilpenicilina_benzatina',
-- 'piperacilina_tazobactam') mas a BD tem slugs com hífen
-- ('benzilpenicilina-benzatina', 'piperacilina-tazobactam'). O JOIN
-- ON d.slug = v.slug falhou silenciosamente para estes 2 fármacos,
-- deixando-os sem perfil nem farmacologia (lição 7.6 do
-- docs/INTERACOES_FLUXO_PESQUISA.md). Esta migração repete o mesmo
-- conteúdo da 096 com os slugs corretos.
-- Conteúdo autoral (não copiado), ancorado nos rótulos aprovados
-- DailyMed (Bicillin L-A, Pfizer; Piperacillin and Tazobactam
-- Injection). Idempotente: ON CONFLICT (drug_id) DO NOTHING.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 079 → 132.
-- =====================================================================

-- =====================================================================
-- Perfis (drug_profiles)
-- =====================================================================

INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en, side_effects_pt, side_effects_en,
   precautions_pt, precautions_en, source_pt, source_en)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.indications_pt, v.indications_en, v.side_effects_pt, v.side_effects_en,
       v.precautions_pt, v.precautions_en, v.source_pt, v.source_en
FROM (VALUES
  ('benzilpenicilina-benzatina',
   E'Tratamento de infeções por microrganismos sensíveis à penicilina G que requerem níveis séricos prolongados, incluindo sífilis (todas as fases), profilaxia da febre reumática, escarlatina, erisipela e faringite estreptocócica.',
   E'Treatment of infections due to penicillin G-sensitive microorganisms requiring prolonged serum levels, including syphilis (all stages), prophylaxis of rheumatic fever, scarlet fever, erysipelas and streptococcal pharyngitis.',
   E'Sal de benzatina da penicilina G de solubilidade extremamente baixa, o que resulta em libertação lenta a partir do local de injeção intramuscular e níveis séricos baixos mas prolongados (até 4 semanas após 1,2 milhões de unidades). Hidrolisa-se em penicilina G, que inibe a síntese da parede celular bacteriana.',
   E'Benzathine salt of penicillin G with extremely low solubility, resulting in slow release from the intramuscular injection site and low but prolonged serum levels (up to 4 weeks after 1.2 million units). It is hydrolyzed to penicillin G, which inhibits bacterial cell-wall synthesis.',
   E'• Sífilis (todas as fases, incluindo sífilis latente e neurosífilis)\n• Profilaxia da febre reumática\n• Infeções estreptocócicas (faringite, escarlatina, erisipela)\n• Outras infeções por microrganismos sensíveis que beneficiam de níveis séricos prolongados',
   E'• Syphilis (all stages, including latent syphilis and neurosyphilis)\n• Prophylaxis of rheumatic fever\n• Streptococcal infections (pharyngitis, scarlet fever, erysipelas)\n• Other infections due to susceptible organisms benefiting from prolonged serum levels',
   E'• Reações de hipersensibilidade (erupções, urticária, anafilaxia)\n• Reação de Jarisch-Herxheimer no tratamento da sífilis\n• Síndrome de Stevens-Johnson e DRESS (pós-comercialização)\n• Isquemia miocárdica aguda com ou sem enfarte como parte de reação alérgica\n• Dor e inflamação no local de injeção',
   E'• Hypersensitivity reactions (rash, urticaria, anaphylaxis)\n• Jarisch-Herxheimer reaction during syphilis treatment\n• Stevens-Johnson syndrome and DRESS (postmarketing)\n• Acute myocardial ischemia with or without infarction as part of an allergic reaction\n• Pain and inflammation at the injection site',
   E'• NUNCA administrar por via intravenosa (risco de paragem cardiorrespiratória e morte) — exclusivamente intramuscular profunda\n• Indagar sobre história de hipersensibilidade a penicilinas antes de iniciar\n• Vigiar reação de Jarisch-Herxheimer no tratamento da sífilis',
   E'• NEVER administer intravenously (risk of cardiorespiratory arrest and death) — deep intramuscular injection only\n• Inquire about penicillin hypersensitivity before starting\n• Watch for Jarisch-Herxheimer reaction during syphilis treatment',
   'Rótulo aprovado DailyMed (Bicillin L-A, Pfizer; setID 012d46f1-d0a0-4676-a879-cd320297ab16).',
   'DailyMed approved label (Bicillin L-A, Pfizer; setID 012d46f1-d0a0-4676-a879-cd320297ab16).'),
  ('piperacilina-tazobactam',
   E'Associação de penicilina de largo espectro com inibidor de beta-lactamases, indicada em infeções intra-abdominais (apendicite complicada, peritonite), pneumonia nosocomial e outras infeções graves por microrganismos produtores de beta-lactamase, em adultos e crianças ≥ 2 meses.',
   E'Broad-spectrum penicillin plus beta-lactamase inhibitor combination indicated for intra-abdominal infections (complicated appendicitis, peritonitis), nosocomial pneumonia and other serious infections due to beta-lactamase-producing organisms, in adults and children ≥ 2 months.',
   E'A piperacilina é uma penicilina de largo espectro que inibe a síntese da parede celular bacteriana; o tazobactam, inibidor de beta-lactamases, protege a piperacilina da hidrólise pelas beta-lactamases de muitos microrganismos resistentes. O parâmetro farmacodinâmico preditivo de eficácia é o tempo acima da CMI.',
   E'Piperacillin is a broad-spectrum penicillin that inhibits bacterial cell-wall synthesis; tazobactam, a beta-lactamase inhibitor, protects piperacillin from hydrolysis by beta-lactamases of many resistant organisms. The pharmacodynamic parameter predictive of efficacy is time above the MIC.',
   E'• Infeções intra-abdominais (apendicite complicada por rutura ou abcesso, peritonite) por E. coli e grupo Bacteroides fragilis\n• Pneumonia nosocomial (moderada a grave)\n• Infeções graves da pele, urinárias, sépsis e neutropenia febril (conforme indicações aprovadas)',
   E'• Intra-abdominal infections (appendicitis complicated by rupture or abscess, peritonitis) due to E. coli and the Bacteroides fragilis group\n• Nosocomial pneumonia (moderate to severe)\n• Serious skin, urinary infections, septicemia and febrile neutropenia (per approved indications)',
   E'• Diarreia (incluindo colite por Clostridioides difficile)\n• Náuseas, vómitos, obstipação\n• Cefaleias, insónia, febre\n• Erupções cutâneas, prurido, anafilaxia\n• Elevação das transaminases, disfunção renal, trombocitopenia, leucopenia, neutropenia\n• Rabdomiólise (rara) e síndrome de ativação macrofágica (muito rara)',
   E'• Diarrhea (including Clostridioides difficile-associated colitis)\n• Nausea, vomiting, constipation\n• Headache, insomnia, fever\n• Rash, pruritus, anaphylaxis\n• Transaminase elevations, renal dysfunction, thrombocytopenia, leukopenia, neutropenia\n• Rhabdomyolysis (rare) and hemophagocytic lymphohistiocytosis (very rare)',
   E'• Indagar sobre hipersensibilidade a penicilinas, cefalosporinas e inibidores de beta-lactamase\n• Ajustar dose na insuficiência renal\n• Vigiar diarreia associada a Clostridioides difficile, discrasias sanguíneas e sinais de rabdomiólise\n• Monitorizar função renal e eletrólitos (hipocalémia) em tratamentos prolongados',
   E'• Inquire about hypersensitivity to penicillins, cephalosporins and beta-lactamase inhibitors\n• Adjust dose in renal impairment\n• Watch for Clostridioides difficile-associated diarrhea, blood dyscrasias and signs of rhabdomyolysis\n• Monitor renal function and electrolytes (hypokalemia) in prolonged therapy',
   'Rótulo aprovado DailyMed (Piperacillin and Tazobactam Injection; setID 4d3f4b69-b0b9-494f-9cda-4537fa420d47).',
   'DailyMed approved label (Piperacillin and Tazobactam Injection; setID 4d3f4b69-b0b9-494f-9cda-4537fa420d47).')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
        indications_pt, indications_en, side_effects_pt, side_effects_en,
        precautions_pt, precautions_en, source_pt, source_en)
JOIN public.drugs d ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- Farmacologia (drug_pharmacology)
-- =====================================================================

INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en,
   half_life_pt, half_life_en, source_pt, source_en)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en
FROM (VALUES
  ('benzilpenicilina-benzatina',
   E'Antibiótico bactericida de ação prolongada: a baixa solubilidade do sal de benzatina assegura libertação lenta a partir do depósito intramuscular, mantendo níveis séricos baixos mas eficazes durante dias a semanas, o que permite esquemas terapêuticos com intervalos longos (ex.: sífilis).',
   E'Bactericidal antibiotic with prolonged action: the low solubility of the benzathine salt ensures slow release from the intramuscular depot, maintaining low but effective serum levels for days to weeks, allowing long-interval regimens (e.g. syphilis).',
   E'Inibe a síntese da parede celular bacteriana na fase de multiplicação ativa. A hidrólise do sal de benzatina liberta penicilina G de forma lenta e contínua, mantendo níveis séricos prolongados.',
   E'Inhibits bacterial cell-wall synthesis during active multiplication. Hydrolysis of the benzathine salt releases penicillin G slowly and continuously, maintaining prolonged serum levels.',
   E'Hidrolisado a penicilina G; aproximadamente 60% da penicilina G liga-se às proteínas séricas. Distribui-se amplamente pelos tecidos, com níveis mais altos no rim, fígado, pele e intestino; penetra pouco no LCR com meninges normais.',
   E'Hydrolyzed to penicillin G; approximately 60% of penicillin G is serum-protein bound. Widely distributed in tissues, with highest levels in kidney, liver, skin and intestines; poor CSF penetration with normal meninges.',
   E'Libertação lenta a partir do local de injeção IM: 300 000 U mantêm níveis de 0,03–0,05 U/mL por 4–5 dias; 1 200 000 U mantêm níveis detetáveis até 4 semanas.',
   E'Slow release from the IM injection site: 300,000 U maintain levels of 0.03–0.05 U/mL for 4–5 days; 1,200,000 U maintain detectable levels for up to 4 weeks.',
   E'Semivida de eliminação prolongada efetiva de dias a semanas, dependente da dose administrada (níveis detetáveis até 4 semanas após 1,2 milhões de unidades).',
   E'Effective elimination half-life of days to weeks, dose dependent (detectable levels up to 4 weeks after 1.2 million units).',
   'Rótulo aprovado DailyMed (Bicillin L-A, Pfizer; setID 012d46f1-d0a0-4676-a879-cd320297ab16).',
   'DailyMed approved label (Bicillin L-A, Pfizer; setID 012d46f1-d0a0-4676-a879-cd320297ab16).'),
  ('piperacilina-tazobactam',
   E'O parâmetro farmacodinâmico mais preditivo de eficácia clínica e microbiológica é o tempo acima da CMI. A associação cobre Gram-positivos e Gram-negativos, incluindo microrganismos produtores de beta-lactamase e Pseudomonas aeruginosa.',
   E'The pharmacodynamic parameter most predictive of clinical and microbiological efficacy is time above the MIC. The combination covers Gram-positives and Gram-negatives, including beta-lactamase-producing organisms and Pseudomonas aeruginosa.',
   E'A piperacilina inibe a síntese da parede celular bacteriana; o tazobactam protege a piperacilina da hidrólise pelas beta-lactamases (inibidor suicida de beta-lactamases).',
   E'Piperacillin inhibits bacterial cell-wall synthesis; tazobactam protects piperacillin from beta-lactamase hydrolysis (suicide beta-lactamase inhibitor).',
   E'A piperacilina é parcialmente metabolizada (desetilpiperacilina, inativa); o tazobactam é metabolizado num metabolito inativo. Ambos são excretados principalmente por via renal, inalterados.',
   E'Piperacillin is partially metabolized (inactive desethylpiperacillin); tazobactam is metabolized to an inactive metabolite. Both are excreted mainly unchanged by the renal route.',
   E'Administração exclusivamente IV; após dose IV, a distribuição é ampla (V ~15–17 L), com boa penetração tecidular.',
   E'Exclusively IV administration; after IV dosing, distribution is wide (V ~15–17 L), with good tissue penetration.',
   E'Semividas de ~0,7–0,9 h para a piperacilina e ~0,7–0,8 h para o tazobactam; prolongam-se na insuficiência renal.',
   E'Half-lives of ~0.7–0.9 h for piperacillin and ~0.7–0.8 h for tazobactam; prolonged in renal impairment.',
   'Rótulo aprovado DailyMed (Piperacillin and Tazobactam Injection; setID 4d3f4b69-b0b9-494f-9cda-4537fa420d47).',
   'DailyMed approved label (Piperacillin and Tazobactam Injection; setID 4d3f4b69-b0b9-494f-9cda-4537fa420d47).')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
        metabolism_pt, metabolism_en, absorption_pt, absorption_en,
        half_life_pt, half_life_en, source_pt, source_en)
JOIN public.drugs d ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- FIM — 132: 2 perfis + 2 farmacologias (182/182 fármacos completos)
-- =====================================================================
