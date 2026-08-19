-- =====================================================================
-- 227 — Tabela drug_classes + FK em drugs + seed + mapeamento
-- ---------------------------------------------------------------------
-- Cria a tabela drug_classes com ~30 classes amplas agrupando os 234
-- class_pt específicos existentes. Adiciona class_id FK à tabela drugs.
-- Seed com descrições placeholder (DailyMed/EMC/HealthCanada).
-- Mapeamento automático via WHERE clauses no class_pt existente.
-- =====================================================================

-- =====================================================================
-- 1. Tabela drug_classes
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.drug_classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  atc_prefix TEXT NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_drug_classes_slug ON public.drug_classes(slug);

-- RLS
ALTER TABLE public.drug_classes ENABLE ROW LEVEL SECURITY;

-- Admin: full access
CREATE POLICY admin_all_drug_classes ON public.drug_classes
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: read published
CREATE POLICY anon_read_drug_classes ON public.drug_classes
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND NOT is_archived);

-- =====================================================================
-- 2. FK em drugs
-- =====================================================================
ALTER TABLE public.drugs
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES public.drug_classes(id) ON DELETE SET NULL;

-- =====================================================================
-- 3. Seed: ~30 classes amplas
-- =====================================================================
INSERT INTO public.drug_classes
  (slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order)
VALUES
  ('antibacterianos', 'Antibacterianos', 'Antibacterials',
   'Os antibacterianos são fármacos que combatem infeções bacterianas, atuando por mecanismos que incluem a inibição da síntese da parede celular (beta-lactâmicos como amoxicilina, cefalexina, ceftriaxona), bloqueio da síntese proteica (macrólidos como azitromicina, claritromicina; aminoglicosídeos como gentamicina, amicacina; tetraciclinas como doxiciclina), inibição da síntese de ácidos nucleicos (fluorquinolonas como ciprofloxacina, levofloxacina) e inibição da síntese de ácido fólico (sulfametoxazol + trimetoprima). A terapêutica antibiótica deve ser orientada por antibiograma sempre que possível, respeitando o espectro de atividade, a farmacocinética (distribuição tecidular, via de eliminação) e o perfil de segurança. O uso inadequado promove resistência bacteriana — um dos maiores problemas de saúde pública globais (OMS, 2024). (Fontes: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'Antibacterials are drugs that fight bacterial infections by mechanisms including inhibition of cell wall synthesis (beta-lactams such as amoxicillin, cephalexin, ceftriaxone), blockade of protein synthesis (macrolides such as azithromycin, clarithromycin; aminoglycosides such as gentamicin, amikacin; tetracyclines such as doxycycline), inhibition of nucleic acid synthesis (fluoroquinolones such as ciprofloxacin, levofloxacin) and inhibition of folic acid synthesis (sulfamethoxazole + trimethoprim). Antibiotic therapy should be guided by culture and sensitivity testing whenever possible, respecting spectrum of activity, pharmacokinetics (tissue distribution, elimination route) and safety profile. Inappropriate use promotes bacterial resistance — one of the greatest global public health threats (WHO, 2024). (Sources: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'J01', 10),

  ('antimicobacteriais', 'Antimicobacteriais', 'Antimycobacterials',
   'Os antimicobacteriais são usados para tratar tuberculose (TB) e lepra. Os fármacos de primeira linha — isoniazida (inibidor da síntese de ácidos micólicos), rifampicina (inibidor da RNA polimerase dependente de DNA), pirazinamida (ativo em pH ácido no interior dos macrófagos) e etambutol (inibidor da síntese da arabinogalactana) — constituem o esquema RIPE, padrão de ouro para TB pulmonar sensível (mínimo 6 meses, directriz OMS/ATS). Fármacos de segunda linha incluem amicacina e capreomicina (aminoglicosídeos injetáveis — risco de ototoxicidade), cicloserina (análogo da D-alanina — bloqueio da síntese da parede), etionamida e protionamida (tioidazonas — inibição da síntese de ácidos micólicos), terizidona (oxazolidinona) e bedaquilina (inibidor da ATP sintase — novo mecanismo, MDR-TB). A clofazimina, originalmente antileprósico (J04BA01), é hoje essencial no tratamento de TB multirresistente. (Fontes: DailyMed/FDA, EMC-UK/MHRA, OMS Guidelines 2024)',
   'Antimycobacterials are used to treat tuberculosis (TB) and leprosy. First-line drugs — isoniazid (mycolic acid synthesis inhibitor), rifampicin (DNA-dependent RNA polymerase inhibitor), pyrazinamide (active in acidic pH within macrophages) and ethambutol (arabinogalactan synthesis inhibitor) — constitute the RIPE regimen, gold standard for drug-sensitive pulmonary TB (minimum 6 months, WHO/ATS guidelines). Second-line agents include amikacin and capreomycin (injectable aminoglycosides — ototoxicity risk), cycloserine (D-alanine analogue — cell wall synthesis blockade), ethionamide and protionamide (thioamides — mycolic acid synthesis inhibition), terizidone (oxazolidinone) and bedaquiline (ATP synthase inhibitor — novel mechanism, MDR-TB). Clofazimine, originally an anti-leprosy agent (J04BA01), is now essential in multidrug-resistant TB treatment. (Sources: DailyMed/FDA, EMC-UK/MHRA, WHO Guidelines 2024)',
   'J04', 15),

  ('antivirais', 'Antivíricos', 'Antivirals',
   'Os antivíricos tratam infeções virais atuando em diferentes etapas do ciclo de replicação viral. O aciclovir (análogo nucleósido — ativação por timidina quinase viral, inibição da DNA polimerase viral) é o fármaco de eleição para infeções por Herpes simplex e Varicela-zoster. O foscarneto (fosfonato — inibição direta da DNA polimerase) é alternativa para cepas resistentes ao aciclovir. Os inibidores da neuraminidase (oseltamivir, zanamivir) bloqueiam a libertação de novas partículas virais em infeções gripais. A ribavirina (análogo nucleósido de largo espetro) é usada em hepatite C em combinação com antivíricos de acção direta. Diferem dos antibacterianos por atuarem dentro das células hospedeiras, frequentemente com seletividade dependente de enzimas virais. (Fontes: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'Antivirals treat viral infections by acting on different stages of the viral replication cycle. Aciclovir (nucleoside analogue — activated by viral thymidine kinase, inhibits viral DNA polymerase) is the drug of choice for Herpes simplex and Varicella-zoster infections. Foscarnet (phosphonate — direct DNA polymerase inhibition) is an alternative for aciclovir-resistant strains. Neuraminidase inhibitors (oseltamivir, zanamivir) block release of new viral particles in influenza infections. Ribavirin (broad-spectrum nucleoside analogue) is used in hepatitis C in combination with direct-acting antivirals. Unlike antibacterials, they act inside host cells, often with selectivity dependent on viral enzymes. (Sources: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'J05', 20),

  ('antiretrovirais', 'Antirretrovirais', 'Antiretrovirals',
   'Os antirretrovirais são usados no tratamento da infeção pelo VIH/SIDA. Agrupam-se em: NRTIs (nucleosídeos/análogos nucleotídeos da transcriptase reversa — tenofovir, emtricitabina, lamivudina, abacavir, didanosina, estavudina) que competem com os nucleótidos naturais para incorporação no DNA viral; NNRTIs (nevirapina, efavirenz, etravirina, rilpivirina) que se ligam diretamente à transcriptase reversa; INSTIs (raltegravir, dolutegravir) que bloqueiam a integração do DNA viral no genoma humano; e IPs (ritonavir, atazanavir, darunavir, lopinavir) que inibem a protease viral, impedindo o processamento das poliproteínas. O lopinavir-ritonavir é uma combinação fixa onde o ritonavir atua como potenciador farmacocinético. O tratamento padrão combina 3 ou mais fármacos de diferentes classes (TARV) para suprimir a carga viral indetectável e prevenir resistência (OMS, directriz 2024). (Fontes: DailyMed/FDA, EMC-UK/MHRA)',
   'Antiretrovirals are used to treat HIV/AIDS. They include: NRTIs (nucleos(t)ide reverse transcriptase inhibitors — tenofovir, emtricitabine, lamivudine, abacavir, didanosine, stavudine) that compete with natural nucleotides for incorporation into viral DNA; NNRTIs (nevirapine, efavirenz, etravirine, rilpivirine) that bind directly to reverse transcriptase; INSTIs (raltegravir, dolutegravir) that block integration of viral DNA into the human genome; and PIs (ritonavir, atazanavir, darunavir, lopinavir) that inhibit viral protease, preventing polyprotein processing. Lopinavir-ritonavir is a fixed-dose combination where ritonavir acts as a pharmacokinetic booster. Standard treatment combines 3+ drugs from different classes (ART) to achieve undetectable viral load and prevent resistance (WHO, 2024 guidelines). (Sources: DailyMed/FDA, EMC-UK/MHRA)',
   'J05', 25),

  ('antifungicos', 'Antifúngicos', 'Antifungals',
   'Os antifúngicos tratam infeções por fungos (candidíase, aspergilose, criptococose, entre outras). Os poliênicos (nistatina para candidíase orofaríngea; anfotericina B — "anfoterico B" — para infeções sistémicas graves) ligam-se ao ergosterol da membrana fúngica, formando poros que causam perda de conteúdo celular. Os azóis inibem a 14-alfa-desmetilase (CYP51), enzima essencial na síntese de ergosterol — incluem fluconazol (candidíase, criptococose), cetoconazol (menos usado pela hepatotoxicidade), voriconazol (aspergilose invasive — primeira linha) e itraconazol (histoplasmose, blastomicose). As equinocandinas (caspofungina) inibem a sintase do 1,3-beta-D-glucano, comprometendo a parede celular fúngica — indicadas para infeções invasivas por Candida e Aspergillus em doentes imunocomprometidos. (Fontes: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'Antifungals treat fungal infections (candidiasis, aspergillosis, cryptococcosis, among others). Polyenes (nystatin for oropharyngeal candidiasis; amphotericin B for severe systemic infections) bind to ergosterol in the fungal membrane, forming pores that cause cellular content loss. Azoles inhibit 14-alpha-demethylase (CYP51), an enzyme essential for ergosterol synthesis — including fluconazole (candidiasis, cryptococcosis), ketoconazole (less used due to hepatotoxicity), voriconazole (invasive aspergillosis — first-line) and itraconazole (histoplasmosis, blastomycosis). Echinocandins (caspofungin) inhibit 1,3-beta-D-glucan synthase, compromising the fungal cell wall — indicated for invasive Candida and Aspergillus infections in immunocompromised patients. (Sources: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'J02', 30),

  ('antimalaricos', 'Antimaláricos', 'Antimalarials',
   'Os antimaláricos prevenem e tratam a malária, doença parasitária transmitida por mosquitos do género Anopheles. A cloroquina (4-aminoquinolina — acumulação no vacuolo digestivo do parasita, inibição da polimerização da hemozina) foi durante décadas o fármaco de eleição, mas a resistência extensiva de P. falciparum limita hoje o seu uso a P. vivax e P. ovale. A hidroxicloroquina é usada sobretudo em doenças autoimunes (lúpus eritematoso, artrite reumatoide). As combinações com artemisinina (ACT — artemeter-lumefantrina, artesunato-amodiaquina, diidroartemisinina-piperaquina) são o padrão de ouro OMS para malária não-complicada por P. falciparum, com ação rápida contra formas eritrocitárias young. A sulfadoxina-pirimetamina é usada para quimioprofilaxia em grávidas (IPTp) em zonas endémicas. A mefloquina e a tafenoquina (8-aminoquinolina) têm papel na profilaxia. A primaquina é essencial para erradicação de hipnozoítos de P. vivax (reated após exclusão de deficiência em G6PD). (Fontes: DailyMed/FDA, OMS Guidelines 2024, Health Canada)',
   'Antimalarials prevent and treat malaria, a parasitic disease transmitted by Anopheles mosquitoes. Chloroquine (4-aminoquinoline — accumulates in the parasite food vacuole, inhibits heme polymerization) was for decades the drug of choice, but extensive P. falciparum resistance now limits its use to P. vivax and P. ovale. Hydroxychloroquine is used mainly in autoimmune diseases (lupus erythematosus, rheumatoid arthritis). Artemisinin-based combinations (ACT — artemether-lumefantrine, artesunate-ammodiaquine, dihydroartemisinin-piperaquine) are the WHO gold standard for uncomplicated P. falciparum malaria, with rapid action against young erythrocytic forms. Sulfadoxine-pyrimethamine is used for chemoprophylaxis in pregnant women (IPTp) in endemic areas. Mefloquine and tafenoquine (8-aminoquinoline) have roles in prophylaxis. Primaquine is essential for radical cure of P. vivax hypnozoites (require G6PD deficiency screening). (Sources: DailyMed/FDA, WHO Guidelines 2024, Health Canada)',
   'P01', 35),

  ('cardiovasculares', 'Cardiovasculares', 'Cardiovasculars',
   'Os cardiovasculars abrangem um vasto grupo de fármacos que atuam no sistema cardiovascular. Os IECA (captopril, enalapril, ramipril, lisinopril) inibem a enzima conversora da angiotensina, reduzindo a formação de angiotensina II e a degradação de bradicinina — primeira linha em hipertensão e insuficiência cardíaca. Os BRA (losartana, valsartana) bloqueiam seletivamente o recetor AT1 da angiotensina II, com menos efeitos secundários (sem tosse seca). Os bloqueadores dos canais de cálcio incluem dihidropiridinas (nifedipina, amlodipina — vasodilatação), fenilalquilaminas (verapamilo — bradicardizante) e benzotiazepinas (diltiazem — ação intermédia). Os betabloqueadores (propranolol, metoprolol, atenolol, bisoprolol, carvedilol) inibem os recetores beta-adrenérgicos, reduzindo a frequência cardíaca e a pressão arterial. Os diuréticos tiazídicos (hidroclorotiazida, indapamida), de ansa (furosemida, bumetanida) e poupadores de potássio (espironolactona) promovem excreção renal de sódio e água. As estatinas (simvastatina, atorvastatina, rosuvastatina) inibem a HMG-CoA redutase, reduzindo o colesterol LDL. Os nitratos (isossorbida) são vasodilatadores venosos usados em angina de peito. (Fontes: DailyMed/FDA, EMC-UK/MHRA, NICE Guidelines)',
   'Cardiovasculars encompass a wide group of drugs acting on the cardiovascular system. ACE inhibitors (captopril, enalapril, ramipril, lisinopril) inhibit angiotensin-converting enzyme, reducing angiotensin II formation and bradykinin degradation — first-line for hypertension and heart failure. ARBs (losartan, valsartan) selectively block the AT1 receptor of angiotensin II, with fewer side effects (no dry cough). Calcium channel blockers include dihydropyridines (nifedipine, amlodipine — vasodilation), phenylalkylamines (verapamil — bradycardic) and benzothiazepines (diltiazem — intermediate action). Beta-blockers (propranolol, metoprolol, atenolol, bisoprolol, carvedilol) inhibit beta-adrenergic receptors, reducing heart rate and blood pressure. Thiazide diuretics (hydrochlorothiazide, indapamide), loop diuretics (furosemide, bumetanide) and potassium-sparing (spironolactone) promote renal sodium and water excretion. Statins (simvastatin, atorvastatin, rosuvastatin) inhibit HMG-CoA reductase, reducing LDL cholesterol. Nitrates (isosorbide) are venous vasodilators used in angina. (Sources: DailyMed/FDA, EMC-UK/MHRA, NICE Guidelines)',
   'C', 40),

  ('anticoagulantes', 'Anticoagulantes e Antitrombóticos', 'Anticoagulants & Antithrombotics',
   'Os anticoagulantes e antitrombóticos prevenem e tratam eventos tromboembólicos. Os anticoagulantes orais incluem a varfarina (antagonista da vitamina K — requer monitorização de INR, múltiplas interações medicamentosas) e os DOACs (dabigatrano — inibidor direto da trombina; rivaroxabano, apixabano — inibidores diretos do fator Xa), que não requerem monitorização routinária e têm menos interações. As heparinas de baixo peso molecular (enoxaparina) são usadas na profilaxia e tratamento de tromboembolismo venoso. Os antiagregantes plaquetários inibem a agregação plaquetária: a aspirina (inibição irreversível da COX-1 plaquetária), o clopidogrel (inibição irreversível do recetor P2Y12) e o ticagrelor (inibição reversível do P2Y12 — onset mais rápido). O acenocumarol é um cumarínico alternativo à varfarina, disponível em Portugal. A escolha terapêutica depende da indicação (FV, AVC, TEV), função renal, risco hemorrágico e interações medicamentosas. (Fontes: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'Anticoagulants and antithrombotics prevent and treat thromboembolic events. Oral anticoagulants include warfarin (vitamin K antagonist — requires INR monitoring, multiple drug interactions) and DOACs (dabigatran — direct thrombin inhibitor; rivaroxaban, apixaban — direct factor Xa inhibitors), which do not require routine monitoring and have fewer interactions. Low-molecular-weight heparins (enoxaparin) are used for venous thromboembolism prophylaxis and treatment. Antiplatelet agents inhibit platelet aggregation: aspirin (irreversible COX-1 inhibition), clopidogrel (irreversible P2Y12 receptor inhibition) and ticagrelor (reversible P2Y12 inhibition — faster onset). Acenocoumarol is a coumarin alternative to warfarin available in Portugal. Therapeutic choice depends on indication (AF, stroke, VTE), renal function, bleeding risk and drug interactions. (Sources: DailyMed/FDA, EMC-UK/MHRA, Health Canada)',
   'B01', 45),

  ('antiepilepticos', 'Antiepilépticos', 'Antiepileptics',
   'Os antiepilépticos controlam convulsões e são usados no tratamento da epilepsia, neuralgia do trigémio e síndrome de Lennox-Gastaut. Os bloqueadores de canais de sódio — fenitoína (uso IV em estado de mal epiléptico), carbamazepina (primeira linha em crises focais — risco de indução enzimática), lamotrigina (espetro amplo, bom perfil de tolerabilidade) e oxcarbazepina (análogo da carbamazepina com menos interações) — estabilizam os canais de sódio na sua conformação inativa. O valproato é um fármaco de amplo espetro (crises generalizadas, ausências), mas contraindicado em mulheres em idade fértil (teratogenicidade). A eslicarbazepina é um derivado da oxcarbazepina. O levetiracetam liga-se à proteína SV2A, modulando a libertação de neurotransmissores — amplo espetro, poucas interações. A pregabalina e a gabapentina ligam-se à subunidade alfa-2-delta dos canais de cálcio — usadas em dor neuropática e epilepsia. O topiramato tem múltiplos mecanismos (bloqueio de canais de sódio, potenciação do GABA, inibição da anidrase carbónica). A etossuximida é primeira linha em crises de ausência. (Fontes: DailyMed/FDA, EMC-UK/MHRA, ILAE Guidelines)',
   'Antiepileptics control seizures and are used in epilepsy, trigeminal neuralgia and Lennox-Gastaut syndrome. Sodium channel blockers — phenytoin (IV use in status epilepticus), carbamazepine (first-line for focal seizures — enzyme induction risk), lamotrigine (broad spectrum, good tolerability) and oxcarbazepine (carbamazepine analogue with fewer interactions) — stabilise sodium channels in their inactive conformation. Valproate is a broad-spectrum agent (generalised seizures, absences) but contraindicated in women of childbearing potential (teratogenicity). Eslicarbazepine is an oxcarbazepine derivative. Levetiracetam binds to SV2A protein, modulating neurotransmitter release — broad spectrum, few interactions. Pregabalin and gabapentin bind to the alpha-2-delta subunit of calcium channels — used in neuropathic pain and epilepsy. Topiramate has multiple mechanisms (sodium channel blockade, GABA potentiation, carbonic anhydrase inhibition). Ethosuximide is first-line for absence seizures. (Sources: DailyMed/FDA, EMC-UK/MHRA, ILAE Guidelines)',
   'N03', 50),

  ('antipsicoticos', 'Antipsicóticos', 'Antipsychotics',
   'Os antipsicóticos tratam esquizofrenia, perturbações bipolares, episódios maníacos e outros distúrbios psicóticos. Dividem-se em típicos (primeira geração) — haloperidol (antagonista D2 potente, primeiro eleito em agitação aguda), pimozida (difenilbutilpiperidina — usada em síndrome de Tourette) — e atípicos (segunda geração) — risperidona (antagonista D2/5-HT2A), olanzapina (perfil multi-receptor — risco metabólico), quetiapina (anti-histamínico sedativo — usada em insónia e bipolar), aripiprazol (agonista parcial D2 — menor risco de ganho de peso) e clozapina (o único eficaz em esquizofrenia resistente — requer monitorização de pancitopenia). Os típicos têm maior risco de efeitos extrapiramidais (parkinsonismo, akatisia, discinesia tardia); os atípicos têm maior risco de síndrome metabólica (ganho de peso, diabetes dislipidémia). (Fontes: DailyMed/FDA, EMC-UK/MHRA, NICE CG178)',
   'Antipsychotics treat schizophrenia, bipolar disorder, manic episodes and other psychotic disorders. They include typical (first generation) — haloperidol (potent D2 antagonist, first-choice in acute agitation), pimozide (diphenylbutylpiperidine — used in Tourette syndrome) — and atypical (second generation) — risperidone (D2/5-HT2A antagonist), olanzapine (multi-receptor profile — metabolic risk), quetiapine (sedative antihistamine — used in insomnia and bipolar), aripiprazole (partial D2 agonist — lower weight gain risk) and clozapine (the only effective agent in treatment-resistant schizophrenia — requires pancytopenia monitoring). Typicals have higher risk of extrapyramidal effects (parkinsonism, akathisia, tardive dyskinesia); atypicals have higher risk of metabolic syndrome (weight gain, dyslipidaemic diabetes). (Sources: DailyMed/FDA, EMC-UK/MHRA, NICE CG178)',
   'N05A', 55),

  ('antidepressivos', 'Antidepressivos', 'Antidepressants',
   'Os antidepressivos tratam a depressão maior, perturbações de ansiedade (generalizada, social, panic), TOC e dor neuropática. Os ISRS (fluoxetina, sertralina, paroxetina, escitalopram, citalopram) são primeira linha — inibem seletivamente a recaptação da serotonina, com melhor perfil de segurança que os tricíclicos. Os IRSN (venlafaxina, duloxetina) inibem a recaptação de serotonina e noradrenalina — úteis em depressão resistente e dor neuropática. Os tricíclicos (amitriptilina) inibem a recaptação de serotonina e noradrenalina não-seletivamente — eficazes mas com mais efeitos secundários (anticolinérgicos, cardiotoxicidade em sobredosagem). A mirtazapina (NaSSA — antagonista 5-HT2A/5-HT3/α2) tem perfil sedativo e é útil em doentes com insónia e perda de peso. O onset terapêutico é tipicamente 2-4 semanas. A descontinuação deve ser gradual para evitar síndrome de suspensão. (Fontes: DailyMed/FDA, EMC-UK/MHRA, NICE CG90)',
   'Antidepressants treat major depression, anxiety disorders (generalised, social, panic), OCD and neuropathic pain. SSRIs (fluoxetine, sertraline, paroxetine, escitalopram, citalopram) are first-line — they selectively inhibit serotonin reuptake, with better safety profile than tricyclics. SNRIs (venlafaxine, duloxetine) inhibit serotonin and noradrenaline reuptake — useful in treatment-resistant depression and neuropathic pain. Tricyclics (amitriptyline) non-selectively inhibit serotonin and noradrenaline reuptake — effective but with more side effects (anticholinergic, cardiotoxicity in overdose). Mirtazapine (NaSSA — 5-HT2A/5-HT3/α2 antagonist) has a sedative profile and is useful in patients with insomnia and weight loss. Therapeutic onset is typically 2-4 weeks. Discontinuation should be gradual to avoid withdrawal syndrome. (Sources: DailyMed/FDA, EMC-UK/MHRA, NICE CG90)',
   'N06A', 60),

  ('ansioliticos', 'Ansiolíticos e Hipnóticos', 'Anxiolytics & Hypnotics',
   'Os ansiolíticos e hipnóticos tratam ansiedade, insónia e convulsões. As benzodiazepinas (diazepam — also used IV em estado de mal epiléptico; lorazepam — used in anxiety and status epilepticus; clonazepam — broad-spectrum anticonvulsant; alprazolam — anxiolytic for panic disorder) potenciam a transmissão GABAérgica ao ligarem-se à subunidade alfa do recetor GABA-A, aumentando a frequência de abertura do canal de cloreto — produzindo efeitos ansiolíticos, sedativos, hipnóticos, relaxantes musculares e anticonvulsivantes. O risco de dependência e tolerância limita o uso crónico (máximo 2-4 semanas). Os Z-drugs (zolpidem) são agonistas seletivos do recetor GABA-Aω1 — induction mais rápida, meia-vida curta, indicados para insónia de início de manutenção. Devem ser evitados em idosos (risco de quedas e fracturas). (Fontes: DailyMed/FDA, EMC-UK/MHRA, BNF)',
   'Anxiolytics and hypnotics treat anxiety, insomnia and seizures. Benzodiazepines (diazepam — also used IV in status epilepticus; lorazepam — used in anxiety and status epilepticus; clonazepam — broad-spectrum anticonvulsant; alprazolam — anxiolytic for panic disorder) enhance GABAergic transmission by binding to the alpha subunit of the GABA-A receptor, increasing chloride channel opening frequency — producing anxiolytic, sedative, hypnotic, muscle relaxant and anticonvulsant effects. Dependence and tolerance risk limits chronic use (maximum 2-4 weeks). Z-drugs (zolpidem) are selective GABA-Aω1 receptor agonists — faster onset, short half-life, indicated for sleep-onset insomnia. Should be avoided in the elderly (falls and fractures risk). (Sources: DailyMed/FDA, EMC-UK/MHRA, BNF)',
   'N05B', 65),

  ('analgesicos', 'Analgésicos', 'Analguesics',
   'Os analgésicos aliviam a dor, classificada pela OMS em escalão 1 (não-opióides), 2 (opióides fracos) e 3 (opióides fortes). O paracetamol (analgesia e antipirese — mecanismo central, inibição da COX-3/PC-2) é o fármaco mais amplamente usado, mas com risco de hepatotoxicidade em sobredosagem. Os AINE (ibuprofeno, naproxeno, diclofenaco, nimesulida, piroxicam, meloxicam) inibem as ciclo-oxigenases COX-1 e/ou COX-2, reduzindo a síntese de prostaglandinas — ações analgésicas, anti-inflamatórias e antipiréticas, mas com risco GI e cardiovascular. A metamizol (pirazolona) tem potente efeito antipirético e espasmolítico, mas com risco de agranulocitose. Os opióides fracos — codeina (pro-fármaco convertido a morfina pelo CYP2D6), tramadol (recaptação serotonérgica/noradrenérgica + agonismo mu parcial) — são usados em dor moderada. Os opióides fortes — morfina (agonista mu puro — padrão de ouro), fentanilo (50-100x mais potente que morfina — patches e injetável), metadona (agonista mu + antagonista NMDA — used in opioid substitution therapy) — são usados em dor intensa e cuidados paliativos. (Fontes: DailyMed/FDA, EMC-UK/MHRA, OMS Escalão Analgésico)',
   'Analguesics relieve pain, classified by WHO into Step 1 (non-opioids), Step 2 (weak opioids) and Step 3 (strong opioids). Paracetamol (analgesic and antipyretic — central mechanism, COX-3/PC-2 inhibition) is the most widely used drug, but with hepatotoxicity risk in overdose. NSAIDs (ibuprofen, naproxen, diclofenac, nimesulide, piroxicam, meloxicam) inhibit cyclo-oxygenases COX-1 and/or COX-2, reducing prostaglandin synthesis — analgesic, anti-inflammatory and antipyretic actions, but with GI and cardiovascular risk. Metamizole (pyrazolone) has potent antipyretic and spasmolytic effects, but with agranulocytosis risk. Weak opioids — codeine (prodrug converted to morphine by CYP2D6), tramadol (serotonergic/noradrenergic reuptake inhibition + partial mu agonism) — are used in moderate pain. Strong opioids — morphine (pure mu agonist — gold standard), fentanyl (50-100x more potent than morphine — patches and injectable), methadone (mu agonist + NMDA antagonist — used in opioid substitution therapy) — are used in severe pain and palliative care. (Sources: DailyMed/FDA, EMC-UK/MHRA, WHO Analgesic Ladder)',
   'N02', 70),

  ('antiparkinsonianos', 'Antiparkinsonianos', 'Anti-Parkinson Drugs',
   'Os antiparkinsonianos tratam a doença de Parkinson. Incluem levodopa (precursor da dopamina), agonistas dopaminérgicos, inibidores da MAO-B, inibidores da COMT e amantadina. A levodopa + inhibidor da descarboxilase é a terapêutica de referência.',
   'Anti-Parkinson drugs treat Parkinson\'s disease. They include levodopa (dopamine precursor), dopamine agonists, MAO-B inhibitors, COMT inhibitors and amantadine. Levodopa + decarboxylase inhibitor is the standard therapy.',
   'N04', 75),

  ('antidiabeticos', 'Antidiabéticos', 'Antidiabetics',
   'Os antidiabéticos tratam a diabetes mellitus tipo 2. Incluem metformina (biguanida), sulfonilureias (glibenclamida, gliclazida), inibidores da DPP-4 (sitagliptina), inibidores do SGLT2 (dapagliflozina), agonistas do GLP-1 (liraglutida) e tiazolidinedionas (pioglitazona).',
   'Antidiabetics treat type 2 diabetes mellitus. They include metformin (biguanide), sulfonylureas (glibenclamide, gliclazide), DPP-4 inhibitors (sitagliptin), SGLT2 inhibitors (dapagliflozin), GLP-1 agonists (liraglutide) and thiazolidinediones (pioglitazone).',
   'A10', 80),

  ('respiratorios', 'Respiratórios', 'Respiratory Drugs',
   'Os respiratórios tratam doenças obstrutivas das vias aéreas (asma, DPOC). Incluem broncodilatadores (SABA como salbutamol, LABA como salmeterol/formoterol, LAMA como tiotropio), corticosteroides inalados (budesonida, fluticasona), e antagonistas dos leucotrienos (montelucaste).',
   'Respiratory drugs treat obstructive airway diseases (asthma, COPD). They include bronchodilators (SABA like salbutamol, LABA like salmeterol/formoterol, LAMA like tiotropium), inhaled corticosteroids (budesonide, fluticasone), and leukotriene antagonists (montelukast).',
   'R03', 85),

  ('gastrointestinais', 'Gastrointestinais', 'Gastrointestinal Drugs',
   'Os gastrointestinais tratam doenças do trato digestivo. Incluem IBP (omeprazol), antagonistas H2 (famotidina), procinéticos (metoclopramida, domperidona), antiácidos, antidiarreicos (loperamida) e mucolíticos (acetilcisteína).',
   'Gastrointestinal drugs treat digestive tract diseases. They include PPIs (omeprazole), H2 antagonists (famotidine), prokinetics (metoclopramide, domperidone), antacids, antidiarrheals (loperamide) and mucolytics (acetylcysteine).',
   'A02', 90),

  ('hormonas', 'Hormonas e Endocrinologia', 'Hormones & Endocrinology',
   'As hormonas e moduladores endócrinos incluem levotiroxina, tiamazol, estradiol, medroxiprogesterona, degarelix, anastrozol, tamoxifeno, calcitriol, colecalciferol e folinato de cálcio. Atuam no sistema endócrino para substituir hormonas em falta ou bloquear a sua ação.',
   'Hormones and endocrine modulators include levothyroxine, thiamazole, estradiol, medroxyprogesterone, degarelix, anastrozole, tamoxifen, calcitriol, cholecalciferol and calcium folinate. They act on the endocrine system to replace deficient hormones or block their action.',
   'H', 95),

  ('imunossupressores', 'Imunossupressores', 'Immunosuppressants',
   'Os imunossupressores preveem e tratam a rejeição de transplantes e doenças autoimunes. Incluem tacrolimus (inibidor da calcineurina), micofenolato (inibidor da IMPDH), sirolimus (inibidor do mTOR), ciclosporina, azatioprina e metotrexato.',
   'Immunosuppressants prevent and treat transplant rejection and autoimmune diseases. They include tacrolimus (calcineurin inhibitor), mycophenolate (IMPDH inhibitor), sirolimus (mTOR inhibitor), ciclosporin, azathioprine and methotrexate.',
   'L04', 100),

  ('antineoplasicos', 'Antineoplásicos', 'Antineoplastics',
   'Os antineoplásicos tratam o cancro. Incluem citotóxicos alquilantes (ciclofosfamida), hormonais (anastrozol, tamoxifeno, degarelix, flutamida, megestrol) e moduladores do recetor de estrogénio. A quimioterapia combina frequentemente múltiplos agentes.',
   'Antineoplastics treat cancer. They include alkylating agents (cyclophosphamide), hormonal agents (anastrozole, tamoxifen, degarelix, flutamide, megestrol) and selective estrogen receptor modulators. Chemotherapy often combines multiple agents.',
   'L', 105),

  ('musculoesqueleticos', 'Musculoesqueléticos', 'Musculoskeletal Drugs',
   'Os musculoesqueléticos tratam doenças do sistema musculoesquelético. Incluem AINE (ibuprofeno, diclofenaco, nimesulida), antagotosos (colchicina, alopurinol, febuxostat), bifosfonatos (alendronato) e relaxantes musculares (tizanidina).',
   'Musculoskeletal drugs treat musculoskeletal diseases. They include NSAIDs (ibuprofen, diclofenac, nimesulide), antigout agents (colchicine, allopurinol, febuxostat), bisphosphonates (alendronate) and muscle relaxants (tizanidine).',
   'M', 110),

  ('antidotoss', 'Antídotos', 'Antidotes',
   'Os antídotos neutralizam ou antagonizam venenos e efeitos adversos de fármacos. A naloxona (antagonista opioide competitivo do recetor mu — reversão rápida de depressão respiratória por opioides; dose IV/IN 0,4-2 mg). O carvão ativado (adsorvente não específico — eficaz até 1h após ingestão oral de maioria dos venenos e fármacos). A dissulfiram (inibidor irreversível da aldeído desidrogenase — tratamento de dependência alcoólica; acumulação de acetaldeído provoca náusea e vômitos). O folinato de cálcio (leucovorina — resgate do metotrexato em altas doses). Outros: N-acetilcisteína (resgate do paracetamol — reconhecimento de glutationa), etilenoglicol (competição com álcool etílico na ADH). (Fontes: DailyMed/FDA, EMC-UK/MHRA, TOXBASE)',
   'Antidotes neutralize or antagonize poisons and adverse drug effects. They include naloxone (opioid antagonist — opioid overdose rescue), activated charcoal (adsorbent — most poisons), disulfiram (ALDH inhibitor — alcohol dependence) and calcium folinate (methotrexate rescue).',
   'V03', 115),

  ('snc_outros', 'Outros do Sistema Nervoso', 'Other Nervous System Drugs',
   'Outros fármacos do sistema nervoso incluem anticolinesterásicos para Alzheimer (donepezilo, memantina), antiespasmódicos (hioscina), levodopa, cetamina (anestésico dissociativo), agonistas alfa-2 (tizanidina) e outros que atuam no SNC.',
   'Other nervous system drugs include anticholinesterase for Alzheimer\'s (donepezil, memantine), antispasmodics (scopolamine), levodopa, ketamine (dissociative anaesthetic), alpha-2 agonists (tizanidine) and others acting on the CNS.',
   'N', 120),

  ('nutricao', 'Nutrição e Eletrólitos', 'Nutrition & Electrolytes',
   'Nutrição e eletrólitos incluem soluções de aminoácidos, emulsões lipídicas, glicose, cloreto de potássio, sulfato de magnésio, ácido ascórbico, ácido fólico, cianocobalamina, ferro, zinco, colecalciferol e calcitriol. Usados em nutrição parentérica, correção de deficiências e suporte nutricional.',
   'Nutrition and electrolytes include amino acid solutions, lipid emulsions, glucose, potassium chloride, magnesium sulfate, ascorbic acid, folic acid, cyanocobalamin, iron, zinc, cholecalciferol and calcitriol. Used in parenteral nutrition, deficiency correction and nutritional support.',
   'B05', 125),

  ('anti_helminticos', 'Anti-helmínticos e Antiparasitários', 'Anthelmintics & Antiparasitics',
   'Anti-helmínticos e antiparasitários tratam infeções por parasitas. Incluem praziquantel (céstodos e tremátodos), metronidazol (protozoários), cotrimoxazol (Pneumocystis) e ivermectina.',
   'Anthelmintics and antiparasitics treat parasitic infections. They include praziquantel (cestodes and trematodes), metronidazole (protozoa), co-trimoxazole (Pneumocystis) and ivermectin.',
   'P02', 130),

  ('dermatologicos', 'Dermatológicos', 'Dermatologicals',
   'Os dermatológicos tratam doenças da pele. Incluem retinóides sistémicos (isotretinoína para acne severa, acitretina para psoríase), antibióticos tópicos (mupirocina) e antifúngicos tópicos.',
   'Dermatologicals treat skin diseases. They include systemic retinoids (isotretinoin for severe acne, acitretin for psoriasis), topical antibiotics (mupirocin) and topical antifungals.',
   'D', 135),

  ('anestesicos', 'Anestésicos', 'Anaesthetics',
   'Os anestésicos induzem perda reversível de consciência e/ou sensação. Incluem cetamina (anestésico dissociativo — antagonista NMDA) e outros usados em contexto hospitalar.',
   'Anaesthetics induce reversible loss of consciousness and/or sensation. They include ketamine (dissociative anaesthetic — NMDA antagonist) and others used in hospital settings.',
   'N01', 140),

  ('outros', 'Outros', 'Others',
   'Fármacos que não se encaixam nas classes acima, incluindo fatores de crescimento hematopoiético (filgrastim, epoetina alfa), surfactante pulmonar, anti-alérgicos e outros.',
   'Drugs not fitting the above classes, including haematopoietic growth factors (filgrastim, epoetin alfa), pulmonary surfactant, anti-allergics and others.',
   'V', 145)

ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 4. Mapeamento: UPDATE drugs SET class_id
-- =====================================================================

-- antibacterianos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antibacterianos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antibiótico%' OR class_pt ILIKE '%Antibacteriano%'
  OR slug IN ('penicilina-g','sulfametoxazol-trimetoprima','clindamicina','cefepima','cefixima',
    'cefpodoxima','telitromicina','ertapenem','cloranfenicol','minociclina','tetraciclina',
    'fosfomicina','daptomicina','aciclovir','nitrofurantoina')
);

-- antimicobacteriais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimicobacteriais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antituberculoso%' OR class_pt ILIKE '%Tubercul%'
  OR slug IN ('isoniazida','rifampicina','pirazinamida','etambutol','bedaquilina',
    'estreptomicina','cicloserina','clofazimina','amicacina','etionamida','protionamida',
    'terizidona','capreomicina','rifabutina')
);

-- antivirais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antivirais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antivírico%' OR class_pt ILIKE '%Antivir%'
);

-- antiretrovirais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiretrovirais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antirretroviral%'
  OR slug IN ('tenofovir','emtricitabina','dolutegravir','lopinavir-ritonavir','darunavir',
    'abacavir','raltegravir','etravirina','rilpivirina','estavudina','didanosina')
);

-- antifungicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antifungicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antifúngico%'
  OR slug IN ('fluconazol','cetoconazol','voriconazol','itraconazol','nistatina')
);

-- antimalaricos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimalaricos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antimalárico%'
  OR slug IN ('cloroquina','hidroxicloroquina','mefloquina','artemeter-lumefantrina',
    'artesunato','artesunato-amodiaquina','atovaquona-proguanil','primaquina',
    'tafenoquina','sulfadoxina-pirimetamina','diidroartemisinina-piperaquina','quinina')
);

-- cardiovasculares
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%IECA%' OR class_pt ILIKE '%inibidor%enzima%conversora%'
  OR class_pt ILIKE '%BRA%' OR class_pt ILIKE '%Bloqueador%angiotensina%'
  OR class_pt ILIKE '%Bloqueador%canais%cálcio%' OR class_pt ILIKE '%Betabloqueador%'
  OR class_pt ILIKE '%Diurético%' OR class_pt ILIKE '%Estatin%'
  OR class_pt ILIKE '%Nitrato%' OR class_pt ILIKE '%Antiarrítmico%'
  OR class_pt ILIKE '%Glicósido%cardíaco%' OR class_pt ILIKE '%Alfabloqueante%'
  OR class_pt ILIKE '%Inibidor%canal%If%' OR class_pt ILIKE '%Inibidor%5-alfa-redutase%'
  OR slug IN ('lisinopril','losartana','nifedipina','metoprolol','atenolol','propranolol',
    'carvedilol','bisoprolol','rosuvastatina','simvastatina','isossorbida','verapamilo',
    'diltiazem','ivabradina','tansulosina','finasterida','dutasterida')
);

-- anticoagulantes
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anticoagulantes')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anticoagulante%' OR class_pt ILIKE '%Antiagregante%'
  OR class_pt ILIKE '%Heparina%' OR class_pt ILIKE '%Antitrombótico%'
  OR slug IN ('warfarina','dabigatrano','rivaroxabano','apixabano','clopidogrel',
    'ticagrelor','enoxaparina','fondaparinux','acenocumarol','aspirina')
);

-- antiepilepticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiepilepticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antiepiléptico%' OR class_pt ILIKE '%Antiepilético%'
  OR slug IN ('carbamazepina','fenitoina','valproato','lamotrigina','levetiracetam',
    'gabapentina','pregabalina','topiramato','oxcarbazepina','eslicarbazepina',
    'etossuximida','clonazepam','zonisamida','lacosamida','primidona')
);

-- antipsicoticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antipsicoticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antipsicótico%' OR class_pt ILIKE '%neuroléptico%'
  OR slug IN ('risperidona','olanzapina','quetiapina','aripiprazol','clozapina',
    'haloperidol','pimozida')
);

-- antidepressivos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidepressivos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%ISRS%' OR class_pt ILIKE '%IRSN%'
  OR class_pt ILIKE '%Antidepressivo%' OR class_pt ILIKE '%Inibidor%recaptação%serotonina%'
  OR class_pt ILIKE '%tricíclico%' OR class_pt ILIKE '%NaSSA%'
  OR slug IN ('fluoxetina','sertralina','paroxetina','citalopram','escitalopram',
    'venlafaxina','duloxetina','amitriptilina','mirtazapina')
);

-- ansioliticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'ansioliticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Benzodiazepina%' OR class_pt ILIKE '%ansiolítico%'
  OR class_pt ILIKE '%Hipnótico%' OR class_pt ILIKE '%sedativo%'
  OR slug IN ('diazepam','lorazepam','clonazepam','zolpidem','alprazolam')
);

-- antiparkinsonianos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiparkinsonianos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antiparkinsónico%' OR class_pt ILIKE '%precursor%dopamina%'
  OR slug IN ('amantadina','levodopa')
);

-- antidiabeticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidiabeticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%antidiabético%' OR class_pt ILIKE '%Biguanida%'
  OR class_pt ILIKE '%Sulfonilureia%' OR class_pt ILIKE '%DPP-4%'
  OR class_pt ILIKE '%SGLT2%' OR class_pt ILIKE '%GLP-1%'
  OR class_pt ILIKE '%Tiazolidinediona%' OR class_pt ILIKE '%alfa-glucosidase%'
  OR slug IN ('metformina','glibenclamida','gliclazida','glimepirida','sitagliptina',
    'vildagliptina','saxagliptina','dapagliflozina','canagliflozina','empagliflozina',
    'liraglutida','dulaglutida','pioglitazona','acarbose')
);

-- respiratorios
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Broncodilatador%' OR class_pt ILIKE '%Corticosteroide%inal%'
  OR class_pt ILIKE '%Corticosteroide inalado%' OR class_pt ILIKE '%CSI%'
  OR class_pt ILIKE '%LTRA%' OR class_pt ILIKE '%leucotrieno%'
  OR class_pt ILIKE '%Mucolítico%' OR class_pt ILIKE '%Surfactante%'
  OR class_pt ILIKE '%PDE4%' OR class_pt ILIKE '%fosfodiesterase%'
  OR slug IN ('salbutamol','salmeterol','formoterol','budesonida','fluticasona',
    'beclometasona','tiotropio','ipratropio','montelukast','roflumilast',
    'indacaterol','teofilina','acetilcisteina','poractant_alfa')
);

-- gastrointestinais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'gastrointestinais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%IBP%' OR class_pt ILIKE '%anti-ulceroso%'
  OR class_pt ILIKE '%Antiácido%' OR class_pt ILIKE '%Procinético%'
  OR class_pt ILIKE '%Antiemético%' OR class_pt ILIKE '%Antidiarreico%'
  OR class_pt ILIKE '%ácido%biliar%' OR class_pt ILIKE '%H2%'
  OR slug IN ('omeprazol','famotidina','cimetidina','metoclopramida','domperidona',
    'loperamida','ondansetron','antiacidos','sucralfato','acido_ursodesoxicolico',
    'butilbrometo_hioscina','mesalazina','sulfassalazina','nistatina')
);

-- hormonas
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'hormonas')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Hormona%' OR class_pt ILIKE '%Estrogénio%'
  OR class_pt ILIKE '%Progestagénio%' OR class_pt ILIKE '%Antitiroideu%'
  OR class_pt ILIKE '%Aromatase%' OR class_pt ILIKE '%SERM%'
  OR class_pt ILIKE '%Modulador%estrogénio%'
  OR slug IN ('levotiroxina','tiamazol','estradiol','medroxiprogesterona','megestrol',
    'degarelix','anastrozol','tamoxifeno','flutamida','calcitriol','colecalciferol',
    'acido_folico','folinato_calcio')
);

-- imunossupressores
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'imunossupressores')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Imunossupressor%' OR class_pt ILIKE '%DMARD%'
  OR slug IN ('tacrolimus','micofenolato','sirolimus','ciclosporina','azatioprina',
    'metotrexato','leflunomida')
);

-- antineoplasicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antineoplasicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Citotóxico%' OR class_pt ILIKE '%antitumoral%'
  OR slug IN ('ciclofosfamida')
);

-- musculoesqueleticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'musculoesqueleticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%AINE%' OR class_pt ILIKE '%Anti-inflamatório%'
  OR class_pt ILIKE '%antigotoso%' OR class_pt ILIKE '%Uricosúrico%'
  OR class_pt ILIKE '%Relaxante%muscular%'
  OR slug IN ('ibuprofeno','diclofenaco','naproxeno','celecoxib','ketorolaco',
    'piroxicam','meloxicam','nimesulida','indometacina','colchicina','alopurinol',
    'febuxostat','penicilamina','alendronato','tizanidina')
);

-- antidotoss
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidotoss')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antídoto%' OR class_pt ILIKE '%anti-alcoólico%'
  OR slug IN ('naloxona','dissulfiram')
);

-- snc_outros
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'snc_outros')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Acetilcolinesterase%' OR class_pt ILIKE '%Alzheimer%'
  OR class_pt ILIKE '%Antiespasmódico%'
  OR slug IN ('donepezilo','memantina','levodopa')
);

-- nutricao
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'nutricao')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Nutrição%' OR class_pt ILIKE '%Eletrólito%'
  OR class_pt ILIKE '%Vitamina%' OR class_pt ILIKE '%Sais%minerais%'
  OR class_pt ILIKE '%Oligoelemento%'
  OR slug IN ('aminoacidos','emulsao_lipidica','glicose','cloreto_potassio',
    'sulfato_magnesio','acido_ascorbico','cianocobalamina','ferro','zinco')
);

-- anti_helminticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anti_helminticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anti-helmíntico%' OR class_pt ILIKE '%Bacteriano%antiparasitário%'
  OR slug IN ('praziquantel','metronidazol','cotrimoxazol')
);

-- dermatologicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'dermatologicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Retinóide%' OR class_pt ILIKE '%tópico%dérmico%'
  OR slug IN ('isotretinoina','acitretina','mupirocina')
);

-- anestesicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anestesicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anestésico%'
  OR slug IN ('cetamina')
);

-- outros (fallback: drugs still without class_id)
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'outros')
WHERE class_id IS NULL AND status = 'published';
