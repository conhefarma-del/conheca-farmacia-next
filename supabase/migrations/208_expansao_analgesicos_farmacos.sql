-- =====================================================================
-- 208 — Expansão Analgésicos/Anti-inflamatórios: fármacos + perfis + farmacologia
--
-- Fármacos novos: ketorolaco, piroxicam, meloxicam, metadona, naloxona, indometacina
-- Fontes: DailyMed/FDA, EMC-UK, Health Canada
-- =====================================================================

-- =====================================================================
-- 1. Fármacos novos (public.drugs)
-- =====================================================================
INSERT INTO public.drugs
  (slug, name_pt, name_en, class_pt, class_en, aliases, status)
VALUES
  ('ketorolaco', 'Ketorolaco', 'Ketorolac', 'AINE injectável', 'Injectable NSAID', '{"ketorolac tromethamine","toradol"}', 'published'),
  ('piroxicam', 'Piroxicam', 'Piroxicam', 'AINE', 'NSAID', '{"feldene"}', 'published'),
  ('meloxicam', 'Meloxicam', 'Meloxicam', 'AINE', 'NSAID', '{"mobic","aeirox"}', 'published'),
  ('metadona', 'Metadona', 'Methadone', 'Opioide sintético', 'Synthetic opioid', '{"methadone","dolophine","metadone cloridrato"}', 'published'),
  ('naloxona', 'Naloxona', 'Naloxone', 'Antagonista opioide', 'Opioid antagonist', '{"narcan","nyxoid"}', 'published'),
  ('indometacina', 'Indometacina', 'Indomethacin', 'AINE', 'NSAID', '{"indometacin","indocin","indomethacin"}', 'published')
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 2. Perfis (drug_profiles) — overview público + profissional
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)
SELECT d.id,
  v.overview_public_pt, v.overview_public_en,
  v.overview_pro_pt, v.overview_pro_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('ketorolaco',
   'O ketorolaco é um medicamento anti-inflamatório não esteroide (AINE) usado para aliviar dores moderadas a graves, geralmente depois de cirurgias ou procedimentos dentários. É administrado por injecção ou via oral por curtos períodos.',
   'Ketorolac is a non-steroidal anti-inflammatory drug (NSAID) used to relieve moderate to severe pain, usually after surgery or dental procedures. It is given by injection or orally for short periods.',
   'AINE potente com actividade analgésica superior à maioria dos AINE orais. Inibe COX-1 e COX-2. Dose máxima: 40 mg/dia (IM/IV) ou 20 mg/dia (oral). Duração máxima de tratamento: 5 dias (parenteral), 7 dias (oral). Risco significativo de toxicidade GI e renal.',
   'Potent NSAID with analgesic activity superior to most oral NSAIDs. Inhibits COX-1 and COX-2. Maximum dose: 40 mg/day (IM/IV) or 20 mg/day (oral). Maximum treatment duration: 5 days (parenteral), 7 days (oral). Significant GI and renal toxicity risk.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  ('piroxicam',
   'O piroxicam é um anti-inflamatório não esteroide (AINE) usado para tratar dor e inflamação causadas por artrite reumatoide e osteoartrite. Tem uma meia-vida longa, permitindo administração uma vez por dia.',
   'Piroxicam is a non-steroidal anti-inflammatory drug (NSAID) used to treat pain and inflammation caused by rheumatoid arthritis and osteoarthritis. It has a long half-life, allowing once-daily dosing.',
   'AINE com meia-vida muito longa (50 h). Inibe COX-1 e COX-2. Risco elevado de úlceras GI e hemorragias. Evitar em idosos. Dose: 10-20 mg/dia. Não é de primeira linha para dor aguda.',
   'NSAID with very long half-life (50 h). Inhibits COX-1 and COX-2. High risk of GI ulcers and bleeding. Avoid in the elderly. Dose: 10-20 mg/day. Not first-line for acute pain.',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  ),
  ('meloxicam',
   'O meloxicam é um anti-inflamatório não esteroide (AINE) usado para tratar a dor e a inflamação da artrite reumatoide e osteoartrite. É mais selectivo para COX-2, com menor risco gastrointestinal que outros AINE.',
   'Meloxicam is a non-steroidal anti-inflammatory drug (NSAID) used to treat pain and inflammation from rheumatoid arthritis and osteoarthritis. It is more COX-2 selective, with lower gastrointestinal risk than other NSAIDs.',
   'AINE com preferência por COX-2 (selectividade relativa). Meia-vida: 15-20 h. Dose: 7,5-15 mg/dia. Menor risco GI que piroxicam/indometacina, mas risco cardiovascular presente. Ajustar em insuficiência renal.',
   'NSAID with COX-2 preference (relative selectivity). Half-life: 15-20 h. Dose: 7.5-15 mg/day. Lower GI risk than piroxicam/indomethacin, but cardiovascular risk present. Adjust in renal impairment.',
   'DailyMed/FDA — rótulo aprovado Meloxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'DailyMed/FDA — approved Meloxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727'
  ),
  ('metadona',
   'A metadona é um opioide sintético usado para tratar a dor moderada a grave e para a substituição de opioides (programas de manutenção com metadona). Requer monitorização especial devido ao risco de acumulação e prolongamento do intervalo QT.',
   'Methadone is a synthetic opioid used to treat moderate to severe pain and for opioid substitution (methadone maintenance programmes). Requires special monitoring due to accumulation risk and QT prolongation.',
   'Opioide sintético com meia-vida muito variável (8-59 h). Agonista μ e antagonista NMDA. Usado em substituição de opioides (MMT) e dor crónica. Risco de prolongamento do QTc e torsades de pointes. Inibe CYP2B6, CYP3A4, CYP2C19. Ajustar dose lentamente.',
   'Synthetic opioid with highly variable half-life (8-59 h). Mu agonist and NMDA antagonist. Used in opioid substitution (MMT) and chronic pain. Risk of QTc prolongation and torsades de pointes. Inhibits CYP2B6, CYP3A4, CYP2C19. Titrate dose slowly.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  ('naloxona',
   'A naloxona é um antagonista dos receptores opioides usado para reverter rapidamente a depressão respiratória causada por overdose de opioides. Pode ser administrada por injecção (IM, IV, SC) ou spray nasal.',
   'Naloxone is an opioid receptor antagonist used to rapidly reverse respiratory depression caused by opioid overdose. It can be given by injection (IM, IV, SC) or nasal spray.',
   'Antagonista puro dos receptores opioides (μ, κ, δ). Meia-vida: 30-90 min (mais curta que a maioria dos opioides — risco de re-sedação). Dose: 0,04-2 mg IV/IM, repetir a cada 2-3 min. Usado em emergência por overdose de opioides. Não tem efeito em não-utilizadores de opioides.',
   'Pure opioid receptor antagonist (μ, κ, δ). Half-life: 30-90 min (shorter than most opioids — risk of re-sedation). Dose: 0.04-2 mg IV/IM, repeat every 2-3 min. Used in opioid overdose emergencies. No effect in non-opioid users.',
   'DailyMed/FDA — rótulo aprovado Naloxona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72',
   'DailyMed/FDA — approved Naloxone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72'
  ),
  ('indometacina',
   'A indometacina é um anti-inflamatório não esteroide (AINE) potente usado para tratar artrite reumatoide, osteoartrite, gota aguda e febre. Tem um perfil de efeitos adversos mais pronunciado que outros AINE.',
   'Indomethacin is a potent non-steroidal anti-inflammatory drug (NSAID) used to treat rheumatoid arthritis, osteoarthritis, acute gout, and fever. It has a more pronounced adverse effect profile than other NSAIDs.',
   'AINE muito potente (inibe COX-1 e COX-2). Meia-vida: 4-5 h (cápsulas) / 1-2 h (suspenção). Usado em gota aguda, bursite, tendinite. Risco elevado de cefaleia (10-25%), toxicidade GI, nefrotoxicidade. Não é de primeira linha. Dose: 25-50 mg 2-3x/dia.',
   'Very potent NSAID (inhibits COX-1 and COX-2). Half-life: 4-5 h (capsules) / 1-2 h (suspension). Used in acute gout, bursitis, tendinitis. High risk of headache (10-25%), GI toxicity, nephrotoxicity. Not first-line. Dose: 25-50 mg 2-3x/day.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  )
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 3. Farmacologia (drug_pharmacology)
-- =====================================================================
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en,
   mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en,
   absorption_pt, absorption_en,
   half_life_pt, half_life_en,
   source_pt, source_en, status)
SELECT d.id,
  v.pharmacodynamics_pt, v.pharmacodynamics_en,
  v.mechanism_pt, v.mechanism_en,
  v.metabolism_pt, v.metabolism_en,
  v.absorption_pt, v.absorption_en,
  v.half_life_pt, v.half_life_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('ketorolaco',
   'Inibição não selectiva de COX-1 e COX-2, reduzindo a síntese de prostaglandinas. Actividade analgésica superior à maioria dos AINE orais. Actividade anti-inflamatória e antipirética moderada.',
   'Non-selective inhibition of COX-1 and COX-2, reducing prostaglandin synthesis. Analgesic activity superior to most oral NSAIDs. Moderate anti-inflammatory and antipyretic activity.',
   'Inibição competitiva e reversível de COX-1 e COX-2, bloqueando a conversão de ácido araquidónico em prostaglandinas e tromboxanos.',
   'Competitive and reversible inhibition of COX-1 and COX-2, blocking the conversion of arachidonic acid to prostaglandins and thromboxanes.',
   'Metabolizado no fígado por CYP2C9 e CYP3A4. Metabolitos inactivos. Excreção renal (60%) e biliar (40%).',
   'Metabolised in the liver by CYP2C9 and CYP3A4. Inactive metabolites. Renal excretion (60%) and biliary (40%).',
   'Absorção oral: biodisponibilidade ~100%. IM: absorção rápida (pico em 30-60 min). Alimentos reduzem velocidade mas não extensão da absorção.',
   'Oral absorption: ~100% bioavailability. IM: rapid absorption (peak in 30-60 min). Food reduces rate but not extent of absorption.',
   '2,5-8,6 h (dose única). Não se acumula significativamente com doses curtas.',
   '2.5-8.6 h (single dose). Does not accumulate significantly with short-term use.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  ('piroxicam',
   'Inibição não selectiva de COX-1 e COX-2. Actividade anti-inflamatória e analgésica prolongada devido à meia-vida longa. Risco elevado de efeitos gastrointestinais.',
   'Non-selective inhibition of COX-1 and COX-2. Prolonged anti-inflammatory and analgesic activity due to long half-life. High risk of gastrointestinal effects.',
   'Inibição competitiva de COX-1 e COX-2. Ligação elevada a proteínas plasmáticas (99%). Actua principalmente por inibição periférica da síntese de prostaglandinas.',
   'Competitive inhibition of COX-1 and COX-2. High plasma protein binding (99%). Acts primarily by peripheral inhibition of prostaglandin synthesis.',
   'Metabolizado no fígado por CYP2C9 e CYP3A4. Metabolitos inactivos. Pouco ou nenhum metabolismo por CYP2C19.',
   'Metabolised in the liver by CYP2C9 and CYP3A4. Inactive metabolites. Little or no CYP2C19 metabolism.',
   'Absorção oral lenta mas completa. Biodisponibilidade: 90%. Alimentos não afectam significativamente a absorção. Pico: 3-5 h.',
   'Slow but complete oral absorption. Bioavailability: 90%. Food does not significantly affect absorption. Peak: 3-5 h.',
   '50 h (média). Pode atingir 100 h em idosos. Acumulação significativa.',
   '50 h (mean). May reach 100 h in the elderly. Significant accumulation.',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  ),
  ('meloxicam',
   'AINE com preferência por COX-2 (selectividade relativa ~10:1 em doses baixas). Actividade anti-inflamatória e analgésica com menor toxicidade GI que AINE não selectivos.',
   'NSAID with COX-2 preference (relative selectivity ~10:1 at low doses). Anti-inflammatory and analgesic activity with lower GI toxicity than non-selective NSAIDs.',
   'Inibição preferencial de COX-2 em doses baixas (7,5 mg). Em doses mais altas (15 mg), perde selectividade e inibe também COX-1.',
   'Preferential COX-2 inhibition at low doses (7.5 mg). At higher doses (15 mg), loses selectivity and also inhibits COX-1.',
   'Metabolizado no fígado por CYP2C9 e CYP3A4. Metabolitos inactivos. Excreção equally dividida entre urina e fezes.',
   'Metabolised in the liver by CYP2C9 and CYP3A4. Inactive metabolites. Excretion equally divided between urine and faeces.',
   'Absorção oral completa e lenta. Biodisponibilidade: 89%. Alimentos não afectam absorção. Pico: 5-6 h.',
   'Complete but slow oral absorption. Bioavailability: 89%. Food does not affect absorption. Peak: 5-6 h.',
   '15-20 h. Permite administração uma vez por dia.',
   '15-20 h. Allows once-daily dosing.',
   'DailyMed/FDA — rótulo aprovado Meloxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'DailyMed/FDA — approved Meloxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727'
  ),
  ('metadona',
   'Agonista dos receptores opioides μ (analgesia) e antagonista dos receptores NMDA (tolerância à dor). Usado em substituição de opioides e dor crónica. Efeito longo e imprevisível.',
   'Mu opioid receptor agonist (analgesia) and NMDA receptor antagonist (pain tolerance). Used in opioid substitution and chronic pain. Long and unpredictable effect.',
   'Agonista μ-opioide com actividade antagonista NMDA e activação de receptores σ. Inibe a recaptação de serotonina e noradrenalina (acção antidepressante adjuvante).',
   'Mu-opioid agonist with NMDA antagonist activity and sigma receptor activation. Inhibits serotonin and noradrenaline reuptake (adjunct antidepressant action).',
   'Metabolizado por CYP2B6 (principal), CYP3A4 e CYP2C19. Metabolitos activos. Variabilidade genética significativa em CYP2B6 afecta níveis.',
   'Metabolised by CYP2B6 (major), CYP3A4, and CYP2C19. Active metabolites. Significant genetic variability in CYP2B6 affects levels.',
   'Absorção oral quase completa (80-90%). Biodisponibilidade: 70-80%. Pico: 1-6 h. Variável entre indivíduos.',
   'Almost complete oral absorption (80-90%). Bioavailability: 70-80%. Peak: 1-6 h. Variable between individuals.',
   '8-59 h (muito variável). Média: 25 h. Efeito cumulativo — ajustar dose lentamente.',
   '8-59 h (highly variable). Mean: 25 h. Cumulative effect — titrate dose slowly.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  ('naloxona',
   'Antagonista puro dos receptores opioides μ, κ e δ. Reverte rapidamente a depressão respiratória causada por opioides. Não tem actividade agonista própria.',
   'Pure opioid receptor antagonist (μ, κ, δ). Rapidly reverses respiratory depression caused by opioids. No intrinsic agonist activity.',
   'Compete directamente com os opioides pela ligação aos receptores μ. Efeito onset rápido (1-3 min IV) mas curto — pode ser necessário repetir.',
   'Directly competes with opioids for mu receptor binding. Rapid onset (1-3 min IV) but short duration — may need repeat dosing.',
   'Metabolizado no fígado por glucuronidação (UGT2B7). Metabolitos inactivos excretados renalmente.',
   'Metabolised in the liver by glucuronidation (UGT2B7). Inactive metabolites excreted renally.',
   'IV: onset 1-3 min, duração 30-90 min. IM/SC: onset 2-5 min, duração 30-90 min. Spray nasal: onset 2-3 min.',
   'IV: onset 1-3 min, duration 30-90 min. IM/SC: onset 2-5 min, duration 30-90 min. Nasal spray: onset 2-3 min.',
   '30-90 min (IV). Mais curta que a maioria dos opioides — risco de re-sedação.',
   '30-90 min (IV). Shorter than most opioids — risk of re-sedation.',
   'DailyMed/FDA — rótulo aprovado Naloxona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72',
   'DailyMed/FDA — approved Naloxone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72'
  ),
  ('indometacina',
   'AINE muito potente. Inibe COX-1 e COX-2 não selectivamente. Actividade anti-inflamatória, analgésica e antipirética. Usado em gota aguda e condições inflamatórias.',
   'Very potent NSAID. Non-selectively inhibits COX-1 and COX-2. Anti-inflammatory, analgesic, and antipyretic activity. Used in acute gout and inflammatory conditions.',
   'Inibição não selectiva e competitiva de COX-1 e COX-2. Potência anti-inflamatória superior à maioria dos AINE. Actua também inibindo a motilidade dos polimorfonucleares.',
   'Non-selective and competitive inhibition of COX-1 and COX-2. Anti-inflammatory potency superior to most NSAIDs. Also acts by inhibiting polymorphonuclear motility.',
   'Metabolizado no fígado por CYP2C9 e desmetilação (CYP para metabolitos). Metabolitos activos (indometacina e ácido indometacina). Excreção renal (60%) e biliar (33%).',
   'Metabolised in the liver by CYP2C9 and demethylation (CYP to metabolites). Active metabolites (indometacin and indomethacin acid). Renal excretion (60%) and biliary (33%).',
   'Absorção oral rápida e quase completa. Biodisponibilidade: 100%. Pico: 1-2 h (cápsulas), 2-4 h (suspenção). Alimentos retardam absorção.',
   'Rapid and almost complete oral absorption. Bioavailability: 100%. Peak: 1-2 h (capsules), 2-4 h (suspension). Food delays absorption.',
   '4,5 h (cápsulas). Metabolitos activos prolongam efeito (meia-vida efectiva: 10-11 h).',
   '4.5 h (capsules). Active metabolites prolong effect (effective half-life: 10-11 h).',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  )
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
       metabolism_pt, metabolism_en, absorption_pt, absorption_en,
       half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
