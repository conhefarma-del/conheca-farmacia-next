-- =====================================================================
-- 205 — Expansão Antibióticos Comuns: 7 fármacos novos
--
-- Fármacos: penicilina-g, sulfametoxazol-trimetoprima, clindamicina,
--           aciclovir, cefixima, cefpodoxima, telitromicina
-- Fontes: DailyMed/FDA (NIH/NLM)
-- =====================================================================

-- =====================================================================
-- 1. Fármacos novos (public.drugs)
-- =====================================================================
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
VALUES
  ('penicilina-g', 'Penicilina G (Benzilpenicilina)', 'Penicillin G (Benzylpenicillin)', 'Antibiótico beta-lactâmico (penicilina)', 'Beta-lactam antibiotic (penicillin)', ARRAY['Benzylpenicillin', 'Penicilina Benzatina'], 'published', 142),
  ('sulfametoxazol-trimetoprima', 'Sulfametoxazol + Trimetoprima', 'Sulfamethoxazole + Trimethoprim', 'Antibiótico combinado (sulfonamida + diaminopirimidina)', 'Combined antibiotic (sulfonamide + diaminopyrimidine)', ARRAY['Cotrimoxazol', 'Bactrim', 'Septra', 'Co-trimoxazole'], 'published', 143),
  ('clindamicina', 'Clindamicina', 'Clindamycin', 'Antibiótico lincosamida', 'Lincosamide antibiotic', ARRAY['Cleocin', 'Dalacin'], 'published', 144),
  ('aciclovir', 'Aciclovir', 'Acyclovir', 'Antivírico (análogo nucleósido)', 'Antiviral (nucleoside analogue)', ARRAY['Zovirax', 'Aciclovir'], 'published', 145),
  ('cefixima', 'Cefixima', 'Cefixime', 'Cefalosporina de 3ª geração oral', 'Oral 3rd-generation cephalosporin', ARRAY['Suprax'], 'published', 146),
  ('cefpodoxima', 'Cefpodoxima', 'Cefpodoxime', 'Cefalosporina de 3ª geração oral', 'Oral 3rd-generation cephalosporin', ARRAY['Vantin'], 'published', 147),
  ('telitromicina', 'Telitromicina', 'Telithromycin', 'Cetolida (derivado da eritromicina)', 'Ketolide (erythromycin derivative)', ARRAY['Ketek'], 'published', 148)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 2. Perfis (drug_profiles)
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en,
   side_effects_pt, side_effects_en, precautions_pt, precautions_en, source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
  v.indications_pt, v.indications_en,
  v.side_effects_pt, v.side_effects_en,
  v.precautions_pt, v.precautions_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('penicilina-g',
   'A penicilina G é um antibiótico beta-lactâmico de amplo espectro, administrado por via parenteral. É o tratamento de eleição para sífilis, meningite por neisseria e endocardite infecciosa.',
   'Penicillin G is a broad-spectrum beta-lactam antibiotic administered parenterally. It is the treatment of choice for syphilis, meningococcal meningitis, and infective endocarditis.',
   'Benzilpenicilina: antibiótico bactericida que inibe a síntese da parede celular bacteriana via ligação às penicilina-binding proteins (PBPs). Atividade contra gram-positivos, anaeróbios e algumas gram-negativas. Meia-vida curta (~30 min) — exige administração frequente ou IV contínua.',
   'Benzylpenicillin: bactericidal antibiotic that inhibits bacterial cell wall synthesis via binding to penicillin-binding proteins (PBPs). Activity against gram-positives, anaerobes, and some gram-negatives. Short half-life (~30 min) — requires frequent dosing or continuous IV infusion.',
   'Sífilis (todas as fases), meningite por Neisseria, endocardite infecciosa, amigdalite/ faringite estreptocócica, pneumonia pneumocócica, síndrome de Lemierre.',
   'Syphilis (all stages), meningococcal meningitis, infective endocarditis, streptococcal tonsillitis/pharyngitis, pneumococcal pneumonia, Lemierre syndrome.',
   'Reações alérgicas (urticária a anafilaxia), neurotoxicidade (convulsões) com doses altas ou insuficiência renal, tromboflebite no local da injeção.',
   'Allergic reactions (urticaria to anaphylaxis), neurotoxicity (seizures) with high doses or renal impairment, injection site thrombophlebitis.',
   'Risco de reação anafilática — testar sensibilidade antes da primeira dose. Ajustar dose em insuficiência renal. Não misturar com soluções alcalinas.',
   'Risk of anaphylaxis — test sensitivity before first dose. Adjust dose in renal impairment. Do not mix with alkaline solutions.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G Potássica: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c',
   'DailyMed/FDA (NIH/NLM) — approved Potassium Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'
  ),
  ('sulfametoxazol-trimetoprima',
   'O cotrimoxazol é uma combinação de sulfametoxazol e trimetoprima que age bloqueando duas etapas sequenciais da síntese de folato bacteriano. É amplamente utilizado para infeções urinárias, respiratórias e profilaxia de PCP.',
   'Co-trimoxazole is a combination of sulfamethoxazole and trimethoprim that blocks two sequential steps in bacterial folate synthesis. It is widely used for urinary tract infections, respiratory infections, and PCP prophylaxis.',
   'Dupla inibição sequencial da síntese de folato: sulfametoxazol inibe a di-hidropteroato sintetase (DHPS), trimetoprima inibe a di-hidrofolato redutase (DHFR). Efeito bactericida sinérgico. Cobertura: Pneumocystis jirovecii, Staphylococcus, Streptococcus, Enterobacteriaceae.',
   'Dual sequential inhibition of folate synthesis: sulfamethoxazole inhibits dihydropteroate synthase (DHPS), trimethoprim inhibits dihydrofolate reductase (DHFR). Synergistic bactericidal effect. Coverage: Pneumocystis jirovecii, Staphylococcus, Streptococcus, Enterobacteriaceae.',
   'Infeções urinárias (cistite, pielonefrite), pneumonia por Pneumocystis jirovecii (tratamento e profilaxia em VIH), sinusite, otite média, bronquite, diarreia por Shigella/Salmonella.',
   'Urinary tract infections (cystitis, pyelonephritis), Pneumocystis jirovecii pneumonia (treatment and prophylaxis in HIV), sinusitis, otitis media, bronchitis, Shigella/Salmonella diarrhoea.',
   'Hipercalemia (especialmente com IECA/BRA/diuréticos poupadores de potássio), pancitopenia (megaloblastose por deficiência de folato), cristalúria, reações cutâneas graves (SJS/TEN).',
   'Hyperkalaemia (especially with ACE inhibitors/ARBs/potassium-sparing diuretics), pancytopenia (megaloblastic anaemia from folate deficiency), crystalluria, severe cutaneous reactions (SJS/TEN).',
   'Contraindicado em deficiência de G6PD (risco de hemólise), insuficiência renal grave (clearance <15 mL/min), gravidez ao termo (kernicterus). Aumentar ingestão de líquidos.',
   'Contraindicated in G6PD deficiency (haemolysis risk), severe renal impairment (clearance <15 mL/min), term pregnancy (kernicterus). Increase fluid intake.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim DS: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
   'DailyMed/FDA (NIH/NLM) — approved Bactrim DS label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
  ),
  ('clindamicina',
   'A clindamicina é um antibiótico lincosamida com excelência para infeções anaeróbias eGram-positivas. É amplamente utilizada em infeções dentárias, acne grave e profilaxia cirúrgica.',
   'Clindamycin is a lincosamide antibiotic with excellent activity against anaerobic and Gram-positive infections. It is widely used in dental infections, severe acne, and surgical prophylaxis.',
   'Inibe a síntese de proteínas bacterianas via ligação à subunidade 50S do ribossomo. Atividade notável contra anaeróbios (Bacteroides, Peptostreptococcus), Gram-positivos (Staphylococcus, Streptococcus) e Toxoplasma. Alta concentração em osso e tecido ósseo.',
   'Inhibits bacterial protein synthesis via binding to the 50S ribosomal subunit. Notable activity against anaerobes (Bacteroides, Peptostreptococcus), Gram-positives (Staphylococcus, Streptococcus), and Toxoplasma. High bone and osseous tissue concentration.',
   'Infeções dentárias/periodontais, acne vulgar grave (tópica e oral), abscesso, pneumonia aspirativa, osteomielite, profilaxia cirúrgica (procedimentos colorretais/vaginais).',
   'Dental/periodontal infections, severe acne vulgaris (topical and oral), abscess, aspiration pneumonia, osteomyelitis, surgical prophylaxis (colorectal/vaginal procedures).',
   'Colite por Clostridioides difficile (incluindo colite pseudomembranosa), reações cutâneas (SJS/TEN raro), hepatotoxicidade, neutropenia.',
   'Clostridioides difficile colitis (including pseudomembranous colitis), cutaneous reactions (rare SJS/TEN), hepatotoxicity, neutropenia.',
   'Risco de colite por C. difficile — suspender se diarreia persistente. Não usar em infeções virais. Pode potencializar efeitos de bloqueadores neuromusculares.',
   'Risk of C. difficile colitis — discontinue if persistent diarrhoea. Do not use in viral infections. May potentiate neuromuscular blocker effects.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina HCl: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd',
   'DailyMed/FDA (NIH/NLM) — approved Clindamycin HCl label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'
  ),
  ('aciclovir',
   'O aciclovir é um antivírico análogo de nucleósido, tratamento de eleição para infeções por herpesvírus (HSV-1, HSV-2, VZV). É amplamente utilizado para herpes genital, herpes zóster e profilaxia em imunocomprometidos.',
   'Acyclovir is a nucleoside analogue antiviral, the treatment of choice for herpesvirus infections (HSV-1, HSV-2, VZV). It is widely used for genital herpes, herpes zoster, and prophylaxis in immunocompromised patients.',
   'Fosforilado pela timidina quinase viral (HSV/VZV) ao trifosfato ativo, que inibe a DNA polimerase viral e termina a cadeia de DNA viral. Altamente seletivo — tem pouca atividade em células hóspede não infectadas. Meia-vida: 2-4 h (renal).',
   'Phosphorylated by viral thymidine kinase (HSV/VZV) to the active triphosphate, which inhibits viral DNA polymerase and terminates viral DNA chain. Highly selective — minimal activity in uninfected host cells. Half-life: 2-4 h (renal).',
   'Herpes genital (tratamento e supressão), herpes zóster, varicela, encefalite por HSV, profilaxia em transplantados/quimioterapia.',
   'Genital herpes (treatment and suppression), herpes zoster, chickenpox, HSV encephalitis, prophylaxis in transplant/chemotherapy patients.',
   'Nefrotoxicidade (cristais de aciclovir tubulares), neurotoxicidade (confusão, tremores, alucinações) em insuficiência renal, náuseas.',
   'Nephrotoxicity (tubular acyclovir crystals), neurotoxicity (confusion, tremors, hallucinations) in renal impairment, nausea.',
   'Ajustar dose estritamente à TFG. Hidratar bem (>1 L/dia) para prevenir cristalúria. Evitar em insuficiência renal não ajustada.',
   'Strictly adjust dose to eGFR. Hydrate well (>1 L/day) to prevent crystalluria. Avoid in unadjusted renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109',
   'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'
  ),
  ('cefixima',
   'A cefixima é uma cefalosporina de 3ª geração oral, ativa contra Gram-negativas incluindo Haemophilus influenzae produtoras de beta-lactamase. É utilizada em infeções urinárias, faringoamigdalites e otite média.',
   'Cefixime is an oral 3rd-generation cephalosporin active against Gram-negatives including beta-lactamase-producing Haemophilus influenzae. It is used in urinary tract infections, pharyngotonsillitis, and otitis media.',
   'Inibe a síntese da parede celular bacteriana via ligação às PBPs. Amplo espectro contra Gram-negativas (E. coli, Klebsiella, H. influenzae, Neisseria), mas fraca atividade contra Gram-positivos e anaeróbios. Resistente a beta-lactamases.',
   'Inhibits bacterial cell wall synthesis via binding to PBPs. Broad spectrum against Gram-negatives (E. coli, Klebsiella, H. influenzae, Neisseria), but weak activity against Gram-positives and anaerobes. Beta-lactamase resistant.',
   'Infeções urinárias não complicadas, faringoamigdalite estreptocócica, otite média aguda, bronquite aguda, gonorreia (dose única).',
   'Uncomplicated urinary tract infections, streptococcal pharyngotonsillitis, acute otitis media, acute bronchitis, gonorrhoea (single dose).',
   'Diarreia (comum), reações alérgicas (raramente anafilaxia), colite por C. difficile, candidíase oral.',
   'Diarrhoea (common), allergic reactions (rarely anaphylaxis), C. difficile colitis, oral candidiasis.',
   'Histórico de alergia a penicilinas — risco cruzado (~1-2%). Ajustar dose em insuficiência renal. Pode causar teste falso-positivo para glicosúria.',
   'Penicillin allergy history — cross-risk (~1-2%). Adjust dose in renal impairment. May cause false-positive glycosuria tests.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefixima (Suprax): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34',
   'DailyMed/FDA (NIH/NLM) — approved Cefixime (Suprax) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34'
  ),
  ('cefpodoxima',
   'A cefpodoxima é uma cefalosporina de 3ª geração oral, utilizada em infeções do trato respiratório, urinárias e dermatológicas. Tem boa biodisponibilidade oral e espectro similar à ceftriaxona IV.',
   'Cefpodoxime is an oral 3rd-generation cephalosporin used in respiratory tract, urinary, and dermatological infections. It has good oral bioavailability and a spectrum similar to IV ceftriaxone.',
   'Inibe a síntese da parede celular bacteriana via ligação às PBPs. Amplo espectro contra Gram-negativas (E. coli, Klebsiella, Proteus, H. influenzae, Moraxella) e alguns Gram-positivos (Streptococcus pneumoniae). Resistente a maioria das beta-lactamases.',
   'Inhibits bacterial cell wall synthesis via binding to PBPs. Broad spectrum against Gram-negatives (E. coli, Klebsiella, Proteus, H. influenzae, Moraxella) and some Gram-positives (Streptococcus pneumoniae). Resistant to most beta-lactamases.',
   'Infeções urinárias, sinusite aguda, bronquite aguda, pneumonia comunitária, otite média, faringoamigdalite, pielonefrite.',
   'Urinary tract infections, acute sinusitis, acute bronchitis, community-acquired pneumonia, otitis media, pharyngotonsillitis, pyelonephritis.',
   'Diarreia, náuseas, cefaleia, reações alérgicas (raramente anafilaxia), colite por C. difficile, alteração de provas de função hepática.',
   'Diarrhoea, nausea, headache, allergic reactions (rarely anaphylaxis), C. difficile colitis, hepatic function test alterations.',
   'Histórico de alergia a penicilinas — risco cruzado. Ajustar dose em insuficiência renal (clearance <30 mL/min: 100 mg q24h).',
   'Penicillin allergy history — cross-risk. Adjust dose in renal impairment (clearance <30 mL/min: 100 mg q24h).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefpodoxima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465',
   'DailyMed/FDA (NIH/NLM) — approved Cefpodoxime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465'
  ),
  ('telitromicina',
   'A telitromicina é uma cetolida, derivado da eritromicina com melhorias na estabilidade ácida e penetração tecidular. É utilizada em pneumonia comunitária, incluindo por germes multirresistentes.',
   'Telithromycin is a ketolide, an erythromycin derivative with improved acid stability and tissue penetration. It is used in community-acquired pneumonia, including drug-resistant pathogens.',
   'Inibe a síntese de proteínas bacterianas via ligação à subunidade 23S do ribossomo (dois sítios — diferente dos macrólidos). Atividade contra S. pneumoniae resistente a macrólidos, H. influenzae, M. catarrhalis, Legionella, Chlamydophila. Penetra bem em células alveolares.',
   'Inhibits bacterial protein synthesis via binding to the 23S ribosomal subunit (two sites — different from macrolides). Activity against macrolide-resistant S. pneumoniae, H. influenzae, M. catarrhalis, Legionella, Chlamydophila. Good penetration into alveolar cells.',
   'Pneumonia comunitária (incluindo multirresistente), exacerbação aguda de bronquite, sinusite aguda.',
   'Community-acquired pneumonia (including drug-resistant), acute exacerbation of bronchitis, acute sinusitis.',
   'Hepatotoxicidade (monitorizar transaminases), prolongamento do QTc (raro), visão turva, náuseas.',
   'Hepatotoxicity (monitor transaminases), QTc prolongation (rare), blurred vision, nausea.',
   'Contraindicado em insuficiência hepática grave. Evitar com medicamentos que prolongam o QT. Monitorizar função hepática durante tratamento prolongado.',
   'Contraindicated in severe hepatic impairment. Avoid with QT-prolonging medications. Monitor hepatic function during prolonged treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina (Ketek): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9',
   'DailyMed/FDA (NIH/NLM) — approved Telithromycin (Ketek) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'
  )
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
     indications_pt, indications_en, side_effects_pt, side_effects_en,
     precautions_pt, precautions_en, source_pt, source_en)
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
  ('penicilina-g',
   'Bactericida: inibe a síntese do peptidoglicano da parede celular bacteriana. Atividade contra streptococci, meningococci, Treponema pallidum, anaeróbios (exceto Bacteroides).',
   'Bactericidal: inhibits peptidoglycan synthesis in bacterial cell wall. Activity against streptococci, meningococci, Treponema pallidum, anaerobes (except Bacteroides).',
   'Liga-se às PBPs (penicillin-binding proteins), impedindo o cross-linking do peptidoglicano. Resulta em lise bacteriana osmótica.',
   'Binds to PBPs (penicillin-binding proteins), preventing peptidoglycan cross-linking. Results in osmotic bacterial lysis.',
   'Não é metabolizado hepaticamente — excretado renalmente por secreção tubular (>80% em 6 h). Probenecida bloqueia a secreção tubular.',
   'Not hepatically metabolised — renally excreted by tubular secretion (>80% in 6 h). Probenecid blocks tubular secretion.',
   'Inativado por ácido gástrico — administração IV/IM. Distribuição ampla (LCR, líquido sinovial, osso), mas baixa penetração em CSF sem inflamação meníngea.',
   'Inactivated by gastric acid — IV/IM administration. Wide distribution (CSF, synovial fluid, bone), but poor CSF penetration without meningeal inflammation.',
   '30 minutos (IV). Aproximadamente 6-12 h com probenecida.',
   '30 minutes (IV). Approximately 6-12 h with probenecid.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c',
   'DailyMed/FDA (NIH/NLM) — approved Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'
  ),
  ('sulfametoxazol-trimetoprima',
   'Bactericida (sinérgico): bloqueia duas etapas da síntese de folato. Sulfametoxazol inibe DHPS, trimetoprima inibe DHFR. Efeito aditivo/bactericida na combinação.',
   'Bactericidal (synergistic): blocks two steps in folate synthesis. Sulfamethoxazole inhibits DHPS, trimethoprim inhibits DHFR. Additive/bactericidal effect in combination.',
   'Sulfametoxazol: análogo estrutural do PABA — compete com PABA pela di-hidropteroato sintetase. Trimetoprima: inibe seletivamente a DHFR bacteriana (50.000x mais potente contra DHFR bacteriana vs. humana).',
   'Sulfamethoxazole: structural analogue of PABA — competes with PABA for dihydropteroate synthase. Trimethoprim: selectively inhibits bacterial DHFR (50,000x more potent against bacterial vs. human DHFR).',
   'Sulfametoxazol: acetilação hepática (N-acetiltransferase). Trimetoprima: metabolismo hepático parcial (CYP2C8). Ambos excretados renalmente.',
   'Sulfamethoxazole: hepatic acetylation (N-acetyltransferase). Trimethoprim: partial hepatic metabolism (CYP2C8). Both renally excreted.',
   'Sulfametoxazol: absorção oral completa (~90%), atinge pico em 1-4 h. Trimetoprima: absorção oral rápida e completa, atinge pico em 1-4 h.',
   'Sulfamethoxazole: complete oral absorption (~90%), peaks in 1-4 h. Trimethoprim: rapid and complete oral absorption, peaks in 1-4 h.',
   'Sulfametoxazol: 10 h. Trimetoprima: 8-10 h. Combinação: efeito sinérgico mantido durante todo o intervalo.',
   'Sulfamethoxazole: 10 h. Trimethoprim: 8-10 h. Combination: synergistic effect maintained throughout the interval.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
   'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
  ),
  ('clindamicina',
   'Bacteriostático (pode ser bactericida em altas doses): inibe a síntese de proteínas bacterianas. Excelente atividade contra anaeróbios e Gram-positivos. Ativa contra Toxoplasma gondii.',
   'Bacteriostatic (may be bactericidal at high doses): inhibits bacterial protein synthesis. Excellent activity against anaerobes and Gram-positives. Active against Toxoplasma gondii.',
   'Liga-se à subunidade 50S do ribossomo 70S bacteriano, bloqueando a translocação do peptidil-tRNA. Efeito pós-antibiótico prolongado. Ação predominante anti-anaeróbios.',
   'Binds to the 50S subunit of the 70S bacterial ribosome, blocking peptidyl-tRNA translocation. Prolonged post-antibiotic effect. Predominantly anti-anaerobic action.',
   'Metabolismo hepático via CYP3A4 (principal) e glucuronidação. Inibe levemente o CYP3A4. Múltiplos metabolitos inativos.',
   'Hepatic metabolism via CYP3A4 (major) and glucuronidation. Mildly inhibits CYP3A4. Multiple inactive metabolites.',
   'Absorção oral completa (>90%), mas biodisponibilidade reduzida com comida. Pico em 1 h (VO) e imediato (IV). Excelente penetração tecidular (osso,tecidos moles,abscesso).',
   'Complete oral absorption (>90%), but reduced bioavailability with food. Peaks at 1 h (PO) and immediately (IV). Excellent tissue penetration (bone, soft tissues, abscess).',
   '2-4 h (normal). 3-5 h em insuficiência renal/hepática.',
   '2-4 h (normal). 3-5 h in renal/hepatic impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd',
   'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'
  ),
  ('aciclovir',
   'Antivírico seletivo: ativa apenas em células infectadas por herpesvírus (HSV-1, HSV-2, VZV). Inibe a replicação viral com pouca toxicidade em células hóspede normais.',
   'Selective antiviral: active only in herpesvirus-infected cells (HSV-1, HSV-2, VZV). Inhibits viral replication with minimal toxicity to normal host cells.',
   'Fosforilado em 3 etapas: timidina quinase viral (1ª fosforilação) → fosfotransferases celulares (2ª e 3ª). O trifosfato de aciclovir compete com o dGTP pela DNA polimerase viral e termina a cadeia de DNA viral.',
   'Phosphorylated in 3 steps: viral thymidine kinase (1st phosphorylation) → cellular phosphotransferases (2nd and 3rd). Acyclovir triphosphate competes with dGTP for viral DNA polymerase and terminates viral DNA chain.',
   'Metabolismo mínimo: ~15% convertido a ACV (9-carboximetoximetilguanina) hepaticamente. A maioria excretada renalmente inalterada.',
   'Minimal metabolism: ~15% converted to ACV (9-carboxymethoxymethylguanine) hepatically. Most excreted renally unchanged.',
   'Biodisponibilidade oral: 15-30% (dose-dependente). Pico em 1-2 h. Distribuição ampla (líquidos corporais, CSF ~50% do sérico, pele).',
   'Oral bioavailability: 15-30% (dose-dependent). Peaks in 1-2 h. Wide distribution (body fluids, CSF ~50% of serum, skin).',
   '2,5-3,5 h (função renal normal). 20 h em insuficiência renal grave (anúria).',
   '2.5-3.5 h (normal renal function). 20 h in severe renal impairment (anuria).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109',
   'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'
  ),
  ('cefixima',
   'Bactericida: inibe a síntese da parede celular bacteriana via ligação às PBPs. Atividade contra Gram-negativas (E. coli, Klebsiella, Proteus, H. influenzae, N. gonorrhoeae). Fraca contra Gram-positivos e anaeróbios.',
   'Bactericidal: inhibits bacterial cell wall synthesis via binding to PBPs. Activity against Gram-negatives (E. coli, Klebsiella, Proteus, H. influenzae, N. gonorrhoeae). Weak against Gram-positives and anaerobes.',
   'Liga-se às PBPs 1a, 1b e 3 — resulta em bactericida. Resistente a beta-lactamases de amplo espectro (TEM, SHV). Cefalosporina de 3ª geração com maior estabilidade que cefalosporinas orais anteriores.',
   'Binds to PBPs 1a, 1b, and 3 — results in bactericidal action. Resistant to extended-spectrum beta-lactamases (TEM, SHV). 3rd-generation cephalosporin with greater stability than earlier oral cephalosporins.',
   'Não é metabolizado — excretado inalterado (~50%) renalmente e ~10% bile. Não há metabolitos ativos.',
   'Not metabolised — excreted unchanged (~50%) renally and ~10% bile. No active metabolites.',
   'Absorção oral: ~40-50% (influenciada pela comida). Pico em 2-6 h. Distribuição em tecidos e fluidos corporais.',
   'Oral absorption: ~40-50% (food-influenced). Peaks in 2-6 h. Distribution into tissues and body fluids.',
   '3-4 h (função renal normal). 10-15 h em insuficiência renal grave.',
   '3-4 h (normal renal function). 10-15 h in severe renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefixima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34',
   'DailyMed/FDA (NIH/NLM) — approved Cefixime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34'
  ),
  ('cefpodoxima',
   'Bactericida: inibe a síntese da parede celular bacteriana via ligação às PBPs. Amplo espectro contra Gram-negativas e alguns Gram-positivos. O pró-fármaco (proxetil) melhora a absorção oral.',
   'Bactericidal: inhibits bacterial cell wall synthesis via binding to PBPs. Broad spectrum against Gram-negatives and some Gram-positives. The prodrug (proxetil) improves oral absorption.',
   'Liga-se às PBPs 1a, 1b e 3. Atividade contra E. coli, Klebsiella, Proteus, H. influenzae, M. catarrhalis, S. pneumoniae. Resistente a beta-lactamases de amplo espectro.',
   'Binds to PBPs 1a, 1b, and 3. Activity against E. coli, Klebsiella, Proteus, H. influenzae, M. catarrhalis, S. pneumoniae. Resistant to extended-spectrum beta-lactamases.',
   'Não é metabolizado — excretado inalterado (~30%) renalmente. O pró-fármaco é hidrolisése por esterases intestinais ao cefpodoxima ativo.',
   'Not metabolised — excreted unchanged (~30%) renally. The prodrug is hydrolysed by intestinal esterases to active cefpodoxime.',
   'Pró-fármaco proxetil: absorção oral ~50%, hidrolisése por esterases intestinais. Pico em 2-3 h. Comida melhora absorção em ~20%.',
   'Prodrug proxetil: oral absorption ~50%, hydrolysed by intestinal esterases. Peaks in 2-3 h. Food improves absorption by ~20%.',
   '2-3 h (função renal normal). 8-9 h em insuficiência renal grave.',
   '2-3 h (normal renal function). 8-9 h in severe renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefpodoxima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465',
   'DailyMed/FDA (NIH/NLM) — approved Cefpodoxime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465'
  ),
  ('telitromicina',
   'Bactericida: inibe a síntese de proteínas bacterianas via ligação dupla ao ribossomo (23S rRNA). Atividade contra S. pneumoniae resistente a macrólidos, H. influenzae, M. catarrhalis, Legionella, Chlamydophila.',
   'Bactericidal: inhibits bacterial protein synthesis via dual binding to the ribosome (23S rRNA). Activity against macrolide-resistant S. pneumoniae, H. influenzae, M. catarrhalis, Legionella, Chlamydophila.',
   'Liga-se a dois sítios na subunidade 23S do ribossomo 50S (diferente dos macrólidos que ligam a um). Esta dupla ligação mantém a atividade contra estirpes com metilação erm (resistência a macrólidos). Bactericida contra S. pneumoniae.',
   'Binds to two sites on the 50S ribosomal subunit 23S (unlike macrolides which bind one). This dual binding maintains activity against erm-methylated strains (macrolide resistance). Bactericidal against S. pneumoniae.',
   'Metabolismo hepático via CYP3A4 (parcial) e desmetilação N-óxido. Inibe CYP3A4 (fraco a moderado). Metabolitos menos ativos.',
   'Hepatic metabolism via CYP3A4 (partial) and N-oxide demethylation. Inhibits CYP3A4 (weak to moderate). Less active metabolites.',
   'Absorção oral: ~57%, não influenciada pela comida. Pico em 1 h. Boa penetração em células alveolares e tecido tonsilar.',
   'Oral absorption: ~57%, not food-influenced. Peaks at 1 h. Good penetration into alveolar cells and tonsillar tissue.',
   '10 h (função renal normal). Não requer ajuste em insuficiência renal.',
   '10 h (normal renal function). No adjustment required in renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9',
   'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'
  )
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en,
     mechanism_pt, mechanism_en,
     metabolism_pt, metabolism_en,
     absorption_pt, absorption_en,
     half_life_pt, half_life_en,
     source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
