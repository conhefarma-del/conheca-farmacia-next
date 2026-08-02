-- 044: Seed da Calculadora de Interações Medicamentosas
-- 35 fármacos comuns em Angola + 22 pares documentados (6 críticos, 13 moderados, 2 menores, 1 sem relevância).
-- Conteúdo clínico PT/EN; revisão e cura continuam no painel de administração.
-- Fonte declarada como literatura de referência (não se inventam citações específicas).

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order) VALUES
  ('enalapril', 'Enalapril', 'Enalapril', 'IECA (Inibidor da ECA)', 'ACE inhibitor', ARRAY['Renitec'], 'published', 1),
  ('captopril', 'Captopril', 'Captopril', 'IECA (Inibidor da ECA)', 'ACE inhibitor', ARRAY['Capoten'], 'published', 2),
  ('losartano', 'Losartano', 'Losartan', 'Antagonista da angiotensina II (ARA II)', 'Angiotensin II receptor blocker', ARRAY['Cozaar'], 'published', 3),
  ('espironolactona', 'Espironolactona', 'Spironolactone', 'Diurético poupador de potássio', 'Potassium-sparing diuretic', ARRAY['Aldactone'], 'published', 4),
  ('hidroclorotiazida', 'Hidroclorotiazida', 'Hydrochlorothiazide', 'Diurético tiazídico', 'Thiazide diuretic', ARRAY['HCTZ'], 'published', 5),
  ('furosemida', 'Furosemida', 'Furosemide', 'Diurético de ansa', 'Loop diuretic', ARRAY['Lasix'], 'published', 6),
  ('amlodipina', 'Amlodipina', 'Amlodipine', 'Bloqueador dos canais de cálcio', 'Calcium channel blocker', ARRAY['Norvasc'], 'published', 7),
  ('digoxina', 'Digoxina', 'Digoxin', 'Glicósido cardíaco', 'Cardiac glycoside', '{}', 'published', 8),
  ('amiodarona', 'Amiodarona', 'Amiodarone', 'Antiarrítmico classe III', 'Class III antiarrhythmic', ARRAY['Cordarone'], 'published', 9),
  ('warfarina', 'Warfarina', 'Warfarin', 'Anticoagulante oral', 'Oral anticoagulant', ARRAY['Marevan'], 'published', 10),
  ('aspirina', 'Ácido acetilsalicílico', 'Aspirin', 'Antiagregante plaquetário / AINE', 'Antiplatelet / NSAID', ARRAY['Aspirina'], 'published', 11),
  ('clopidogrel', 'Clopidogrel', 'Clopidogrel', 'Antiagregante plaquetário', 'Antiplatelet agent', ARRAY['Plavix'], 'published', 12),
  ('ibuprofeno', 'Ibuprofeno', 'Ibuprofen', 'Anti-inflamatório não esteroide (AINE)', 'Nonsteroidal anti-inflammatory drug (NSAID)', ARRAY['Brufen'], 'published', 13),
  ('diclofenac', 'Diclofenac', 'Diclofenac', 'Anti-inflamatório não esteroide (AINE)', 'Nonsteroidal anti-inflammatory drug (NSAID)', ARRAY['Voltaren'], 'published', 14),
  ('paracetamol', 'Paracetamol', 'Paracetamol', 'Analgésico e antipirético', 'Analgesic and antipyretic', ARRAY['Acetaminofeno'], 'published', 15),
  ('metformina', 'Metformina', 'Metformin', 'Biguanida (antidiabético oral)', 'Biguanide', ARRAY['Glucophage'], 'published', 16),
  ('glibenclamida', 'Glibenclamida', 'Glibenclamide', 'Sulfonilureia', 'Sulfonylurea', ARRAY['Daonil'], 'published', 17),
  ('ciprofloxacina', 'Ciprofloxacina', 'Ciprofloxacin', 'Fluorquinolona', 'Fluoroquinolone', ARRAY['Ciprobay'], 'published', 18),
  ('amoxicilina', 'Amoxicilina', 'Amoxicillin', 'Penicilina', 'Penicillin', ARRAY['Amoxil'], 'published', 19),
  ('claritromicina', 'Claritromicina', 'Clarithromycin', 'Macrólido', 'Macrolide', ARRAY['Klacid'], 'published', 20),
  ('doxiciclina', 'Doxiciclina', 'Doxycycline', 'Tetraciclina', 'Tetracycline', '{}', 'published', 21),
  ('cotrimoxazol', 'Cotrimoxazol', 'Co-trimoxazole', 'Sulfametoxazol + trimetoprim', 'Sulfamethoxazole + trimethoprim', ARRAY['Bactrim'], 'published', 22),
  ('omeprazol', 'Omeprazol', 'Omeprazole', 'Inibidor da bomba de protões (IBP)', 'Proton pump inhibitor (PPI)', ARRAY['Losec'], 'published', 23),
  ('antiacidos', 'Antiácidos', 'Antacids', 'Antiácidos (alumínio e magnésio)', 'Antacids (aluminium and magnesium)', ARRAY['Hidróxido de alumínio', 'Hidróxido de magnésio'], 'published', 24),
  ('sildenafil', 'Sildenafil', 'Sildenafil', 'Inibidor da fosfodiesterase-5', 'PDE-5 inhibitor', ARRAY['Viagra'], 'published', 25),
  ('nitroglicerina', 'Nitroglicerina', 'Nitroglycerin', 'Nitrato orgânico', 'Organic nitrate', '{}', 'published', 26),
  ('levotiroxina', 'Levotiroxina', 'Levothyroxine', 'Hormona tiroideia', 'Thyroid hormone', '{}', 'published', 27),
  ('alopurinol', 'Alopurinol', 'Allopurinol', 'Inibidor da xantina oxidase', 'Xanthine oxidase inhibitor', ARRAY['Zyloric'], 'published', 28),
  ('azatioprina', 'Azatioprina', 'Azathioprine', 'Imunossupressor', 'Immunosuppressant', ARRAY['Imuran'], 'published', 29),
  ('carbamazepina', 'Carbamazepina', 'Carbamazepine', 'Antiepiléptico', 'Antiepileptic', ARRAY['Tegretol'], 'published', 30),
  ('fluoxetina', 'Fluoxetina', 'Fluoxetine', 'Inibidor seletivo da recaptação da serotonina (ISRS)', 'Selective serotonin reuptake inhibitor (SSRI)', ARRAY['Prozac'], 'published', 31),
  ('sertralina', 'Sertralina', 'Sertraline', 'Inibidor seletivo da recaptação da serotonina (ISRS)', 'Selective serotonin reuptake inhibitor (SSRI)', ARRAY['Zoloft'], 'published', 32),
  ('tramadol', 'Tramadol', 'Tramadol', 'Analgésico opioide', 'Opioid analgesic', ARRAY['Tramal'], 'published', 33),
  ('atorvastatina', 'Atorvastatina', 'Atorvastatin', 'Estatina', 'Statin', ARRAY['Lipitor'], 'published', 34),
  ('prednisolona', 'Prednisolona', 'Prednisolone', 'Corticosteroide', 'Corticosteroid', '{}', 'published', 35);

-- ============================================================
-- Pares de interações (canónicos: drug_a_id < drug_b_id)
-- ============================================================
DO $$
DECLARE
  v_enalapril UUID; v_captopril UUID; v_losartano UUID; v_espironolactona UUID;
  v_hidroclorotiazida UUID; v_furosemida UUID; v_amlodipina UUID; v_digoxina UUID;
  v_amiodarona UUID; v_warfarina UUID; v_aspirina UUID; v_clopidogrel UUID;
  v_ibuprofeno UUID; v_diclofenac UUID; v_paracetamol UUID; v_metformina UUID;
  v_glibenclamida UUID; v_ciprofloxacina UUID; v_amoxicilina UUID; v_claritromicina UUID;
  v_doxiciclina UUID; v_cotrimoxazol UUID; v_omeprazol UUID; v_antiacidos UUID;
  v_sildenafil UUID; v_nitroglicerina UUID; v_levotiroxina UUID; v_alopurinol UUID;
  v_azatioprina UUID; v_carbamazepina UUID; v_fluoxetina UUID; v_sertralina UUID;
  v_tramadol UUID; v_atorvastatina UUID; v_prednisolona UUID;
BEGIN
  SELECT id INTO v_enalapril FROM public.drugs WHERE slug = 'enalapril';
  SELECT id INTO v_captopril FROM public.drugs WHERE slug = 'captopril';
  SELECT id INTO v_losartano FROM public.drugs WHERE slug = 'losartano';
  SELECT id INTO v_espironolactona FROM public.drugs WHERE slug = 'espironolactona';
  SELECT id INTO v_hidroclorotiazida FROM public.drugs WHERE slug = 'hidroclorotiazida';
  SELECT id INTO v_furosemida FROM public.drugs WHERE slug = 'furosemida';
  SELECT id INTO v_amlodipina FROM public.drugs WHERE slug = 'amlodipina';
  SELECT id INTO v_digoxina FROM public.drugs WHERE slug = 'digoxina';
  SELECT id INTO v_amiodarona FROM public.drugs WHERE slug = 'amiodarona';
  SELECT id INTO v_warfarina FROM public.drugs WHERE slug = 'warfarina';
  SELECT id INTO v_aspirina FROM public.drugs WHERE slug = 'aspirina';
  SELECT id INTO v_clopidogrel FROM public.drugs WHERE slug = 'clopidogrel';
  SELECT id INTO v_ibuprofeno FROM public.drugs WHERE slug = 'ibuprofeno';
  SELECT id INTO v_diclofenac FROM public.drugs WHERE slug = 'diclofenac';
  SELECT id INTO v_paracetamol FROM public.drugs WHERE slug = 'paracetamol';
  SELECT id INTO v_metformina FROM public.drugs WHERE slug = 'metformina';
  SELECT id INTO v_glibenclamida FROM public.drugs WHERE slug = 'glibenclamida';
  SELECT id INTO v_ciprofloxacina FROM public.drugs WHERE slug = 'ciprofloxacina';
  SELECT id INTO v_amoxicilina FROM public.drugs WHERE slug = 'amoxicilina';
  SELECT id INTO v_claritromicina FROM public.drugs WHERE slug = 'claritromicina';
  SELECT id INTO v_doxiciclina FROM public.drugs WHERE slug = 'doxiciclina';
  SELECT id INTO v_cotrimoxazol FROM public.drugs WHERE slug = 'cotrimoxazol';
  SELECT id INTO v_omeprazol FROM public.drugs WHERE slug = 'omeprazol';
  SELECT id INTO v_antiacidos FROM public.drugs WHERE slug = 'antiacidos';
  SELECT id INTO v_sildenafil FROM public.drugs WHERE slug = 'sildenafil';
  SELECT id INTO v_nitroglicerina FROM public.drugs WHERE slug = 'nitroglicerina';
  SELECT id INTO v_levotiroxina FROM public.drugs WHERE slug = 'levotiroxina';
  SELECT id INTO v_alopurinol FROM public.drugs WHERE slug = 'alopurinol';
  SELECT id INTO v_azatioprina FROM public.drugs WHERE slug = 'azatioprina';
  SELECT id INTO v_carbamazepina FROM public.drugs WHERE slug = 'carbamazepina';
  SELECT id INTO v_fluoxetina FROM public.drugs WHERE slug = 'fluoxetina';
  SELECT id INTO v_sertralina FROM public.drugs WHERE slug = 'sertralina';
  SELECT id INTO v_tramadol FROM public.drugs WHERE slug = 'tramadol';
  SELECT id INTO v_atorvastatina FROM public.drugs WHERE slug = 'atorvastatina';
  SELECT id INTO v_prednisolona FROM public.drugs WHERE slug = 'prednisolona';

  -- ===== CRÍTICAS =====

  INSERT INTO public.drug_interactions
    (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
     management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
     source_pt, source_en, status, updated_at) VALUES
  (LEAST(v_enalapril, v_espironolactona), GREATEST(v_enalapril, v_espironolactona), 'critical',
   'Hipercalemia grave. A associação de um IECA (Enalapril) com um diurético poupador de potássio (Espironolactona) aumenta significativamente o risco de hipercalemia, sobretudo em doentes com compromisso renal, diabetes ou suplementos de potássio.',
   'Severe hyperkalaemia. Combining an ACE inhibitor (Enalapril) with a potassium-sparing diuretic (Spironolactone) significantly increases the risk of hyperkalaemia, especially in patients with renal impairment, diabetes or potassium supplements.',
   'O Enalapril reduz a aldosterona (menor excreção de K+), efeito potenciado pela Espironolactona, que bloqueia diretamente o recetor da aldosterona — o K+ sérico sobe por duas vias.',
   'Enalapril lowers aldosterone (less K+ excretion), an effect amplified by Spironolactone, which directly blocks the aldosterone receptor — serum K+ rises through two pathways.',
   'Monitorizar K+ sérico uma semana após o início. Considerar reduzir a dose ou alternativas terapêuticas. Informar o doente sobre os sintomas de hipercalemia.',
   'Check serum K+ one week after starting. Consider dose reduction or therapeutic alternatives. Educate the patient on hyperkalaemia symptoms.',
   'K+ sérico e creatinina na 1.ª semana, depois a cada 4–6 semanas nos primeiros 3 meses.',
   'Serum K+ and creatinine in week 1, then every 4–6 weeks for the first 3 months.',
   'Fraqueza muscular, parestesias, arritmias, ondas T altas no ECG.',
   'Muscle weakness, paraesthesia, arrhythmias, tall T waves on ECG.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_warfarina, v_ibuprofeno), GREATEST(v_warfarina, v_ibuprofeno), 'critical',
   'Risco hemorrágico grave. Os AINE (Ibuprofeno) aumentam o risco de hemorragia gastrointestinal e potenciam o efeito anticoagulante da Warfarina.',
   'Severe bleeding risk. NSAIDs (Ibuprofen) increase gastrointestinal bleeding and potentiate the anticoagulant effect of Warfarin.',
   'Lesão da mucosa gástrica + inibição plaquetária + deslocação da Warfarina da albumina.',
   'Gastric mucosal injury + platelet inhibition + displacement of Warfarin from albumin.',
   'Evitar a associação. Usar Paracetamol; se um AINE for indispensável, avaliar proteção gástrica e INR apertado.',
   'Avoid the combination. Use Paracetamol; if an NSAID is essential, consider gastric protection and strict INR.',
   'INR e vigilância de sinais hemorrágicos; hemograma se suspeita de perda oculta.',
   'INR and bleeding surveillance; FBC if occult loss is suspected.',
   'Hematemeses, melenas, sangue nas fezes, hematomas extensos.',
   'Haematemesis, melaena, blood in stool, extensive bruising.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_warfarina, v_aspirina), GREATEST(v_warfarina, v_aspirina), 'critical',
   'Risco hemorrágico muito elevado. A dupla anticoagulação + antiagregação quase duplica a taxa de hemorragia major.',
   'Very high bleeding risk. Combined anticoagulation + antiplatelet therapy almost doubles major bleeding rates.',
   'Efeito antiplaquetário irreversível da Aspirina somado à anticoagulação da Warfarina.',
   'Aspirin''s irreversible antiplatelet effect added to Warfarin anticoagulation.',
   'Evitar exceto em indicações específicas (ex.: válvulas mecânicas) e sob supervisão especializada.',
   'Avoid except for specific indications (e.g. mechanical valves) under specialist supervision.',
   'INR apertado e vigilância hemorrágica regular.',
   'Strict INR and regular bleeding surveillance.',
   'Hemorragia gastrointestinal; hemorragia intracraniana (cefaleia súbita e grave).',
   'GI bleeding; intracranial haemorrhage (sudden severe headache).',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_sildenafil, v_nitroglicerina), GREATEST(v_sildenafil, v_nitroglicerina), 'critical',
   'Hipotensão grave potencialmente fatal. Nunca associar inibidores da fosfodiesterase-5 com nitratos.',
   'Potentially fatal severe hypotension. Never combine PDE-5 inhibitors with nitrates.',
   'Ambos aumentam o GMPc — vasodilatação extrema e queda acentuada da pressão arterial.',
   'Both raise cGMP — extreme vasodilation and marked blood pressure drop.',
   'Contraindicação absoluta. Se o doente tomou Sildenafil, aguardar pelo menos 24 horas antes de usar um nitrato.',
   'Absolute contraindication. If the patient took Sildenafil, wait at least 24 hours before any nitrate.',
   'Vigilância imediata de PA; procurar cuidados de emergência se síncope ou dor torácica.',
   'Immediate BP monitoring; seek emergency care on syncope or chest pain.',
   'Síncope, tonturas graves, dor torácica, taquicardia.',
   'Syncope, severe dizziness, chest pain, tachycardia.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_alopurinol, v_azatioprina), GREATEST(v_alopurinol, v_azatioprina), 'critical',
   'Mielossupressão grave. O Alopurinol inibe o metabolismo da Azatioprina, com risco de leucopenia grave e infeções.',
   'Severe myelosuppression. Allopurinol inhibits Azathioprine metabolism, with risk of severe leucopenia and infections.',
   'A xantina oxidase (inibida pelo Alopurinol) é responsável pela inativação do metabolito ativo 6-mercaptopurina.',
   'Xanthine oxidase (inhibited by Allopurinol) inactivates the active metabolite 6-mercaptopurine.',
   'Reduzir a dose de Azatioprina para cerca de 25% da habitual e monitorizar o hemograma.',
   'Reduce Azathioprine to about 25% of the usual dose and monitor the full blood count.',
   'Hemograma completo a cada 1–2 semanas no início da associação.',
   'Full blood count every 1–2 weeks when starting the combination.',
   'Febre, infeções recorrentes, faringite, equimoses espontâneas.',
   'Fever, recurrent infections, sore throat, spontaneous bruising.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_claritromicina, v_carbamazepina), GREATEST(v_claritromicina, v_carbamazepina), 'critical',
   'Toxicidade por Carbamazepina. A Claritromicina inibe o CYP3A4 e aumenta muito os níveis de Carbamazepina.',
   'Carbamazepine toxicity. Clarithromycin inhibits CYP3A4 and greatly raises Carbamazepine levels.',
   'A Carbamazepina é metabolizada pelo CYP3A4, enzima fortemente inibida pela Claritromicina.',
   'Carbamazepine is metabolised by CYP3A4, potently inhibited by Clarithromycin.',
   'Evitar a associação; escolher um antibiótico alternativo ou monitorizar os níveis de Carbamazepina.',
   'Avoid the combination; choose an alternative antibiotic or monitor Carbamazepine levels.',
   'Carbamazepinemia e sinais de toxicidade nos primeiros dias.',
   'Carbamazepine levels and toxicity signs in the first days.',
   'Nistagmo, diplopia, ataxia, sedação, náuseas.',
   'Nystagmus, diplopia, ataxia, sedation, nausea.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  -- ===== MODERADAS =====

  (LEAST(v_enalapril, v_hidroclorotiazida), GREATEST(v_enalapril, v_hidroclorotiazida), 'moderate',
   'Potencialização do efeito hipotensor. A associação pode causar hipotensão sintomática nas primeiras semanas, sobretudo com depleção de volume prévia.',
   'Enhanced hypotensive effect. The combination may cause symptomatic hypotension in the first weeks, especially with prior volume depletion.',
   'A tiazida reduz o volume circulante e o IECA reduz a resistência periférica — o efeito sinérgico baixa a PA de forma mais acentuada.',
   'The thiazide lowers circulating volume and the ACE inhibitor lowers peripheral resistance — the synergistic effect lowers BP more sharply.',
   'Iniciar com doses baixas. Monitorizar PA e função renal nas primeiras 2 semanas.',
   'Start at low doses. Monitor BP and renal function in the first 2 weeks.',
   'PA na 1.ª semana; creatinina e eletrólitos (K+, Na+) às 2 semanas.',
   'BP in week 1; creatinine and electrolytes (K+, Na+) at 2 weeks.',
   'Tonturas, síncope, cãibras, sede intensa — possíveis sinais de hipotensão ou hiponatremia.',
   'Dizziness, syncope, cramps, intense thirst — possible signs of hypotension or hyponatraemia.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-04-02 10:00:00+00'),

  (LEAST(v_losartano, v_espironolactona), GREATEST(v_losartano, v_espironolactona), 'moderate',
   'Risco acrescido de hipercalemia. Tanto o Losartano (ARA II) como a Espironolactona elevam o K+ sérico; a associação exige vigilância.',
   'Increased risk of hyperkalaemia. Both Losartan (ARB) and Spironolactone raise serum K+; the combination requires monitoring.',
   'O ARA II bloqueia o recetor da angiotensina II (reduz aldosterona) e a Espironolactona bloqueia o recetor da aldosterona — retenção de K+ por duas vias.',
   'The ARB blocks the angiotensin II receptor (lower aldosterone) and Spironolactone blocks the aldosterone receptor — K+ retention via two pathways.',
   'Iniciar com doses baixas e monitorizar K+ e creatinina ao fim de 1 semana.',
   'Start at low doses and check K+ and creatinine after 1 week.',
   'K+ sérico e função renal na 1.ª semana e mensalmente.',
   'Serum K+ and renal function at week 1 and monthly.',
   'Fraqueza, palpitações, ritmo irregular — possíveis sinais de hipercalemia.',
   'Weakness, palpitations, irregular rhythm — possible signs of hyperkalaemia.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_enalapril, v_ibuprofeno), GREATEST(v_enalapril, v_ibuprofeno), 'moderate',
   'Redução do efeito anti-hipertensor e risco de lesão renal. Os AINE atenuam a ação do IECA e aumentam o risco de insuficiência renal, sobretudo em doentes idosos ou desidratados.',
   'Reduced antihypertensive effect and risk of renal injury. NSAIDs blunt the ACE inhibitor and increase the risk of renal impairment, especially in elderly or dehydrated patients.',
   'Os AINE inibem as prostaglandinas renais e retêm sódio/água, opondo-se ao mecanismo do IECA.',
   'NSAIDs inhibit renal prostaglandins and retain sodium/water, opposing the ACE inhibitor mechanism.',
   'Preferir Paracetamol como analgésico. Se o AINE for necessário, usar a menor dose durante o menor tempo, com monitorização da função renal.',
   'Prefer Paracetamol as analgesic. If an NSAID is needed, use the lowest dose for the shortest time, with renal function monitoring.',
   'PA e creatinina a partir das 2 semanas de uso regular do AINE.',
   'BP and creatinine after 2 weeks of regular NSAID use.',
   'Edema, diminuição do débito urinário, elevação da PA.',
   'Oedema, reduced urine output, rising BP.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_amiodarona, v_digoxina), GREATEST(v_amiodarona, v_digoxina), 'moderate',
   'A Amiodarona aumenta os níveis plasmáticos de Digoxina, com risco de toxicidade digitálica.',
   'Amiodarone raises plasma Digoxin levels, with risk of digitalis toxicity.',
   'A Amiodarona inibe a P-glicoproteína e o metabolismo hepático da Digoxina, podendo duplicar as suas concentrações.',
   'Amiodarone inhibits P-glycoprotein and hepatic metabolism of Digoxin, potentially doubling its levels.',
   'Reduzir a dose de Digoxina (habitualmente para metade) e monitorizar os níveis séricos.',
   'Reduce the Digoxin dose (usually by half) and monitor serum levels.',
   'Digoxinemia a partir da 1.ª semana e vigilância de sintomas.',
   'Digoxin levels from week 1 and symptom surveillance.',
   'Náuseas, visão amarela ou esborratada, bradicardia, arritmias.',
   'Nausea, yellow or blurred vision, bradycardia, arrhythmias.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_amiodarona, v_warfarina), GREATEST(v_amiodarona, v_warfarina), 'moderate',
   'A Amiodarona potencia o efeito anticoagulante da Warfarina, aumentando o INR e o risco hemorrágico.',
   'Amiodarone potentiates Warfarin''s anticoagulant effect, raising INR and bleeding risk.',
   'Inibe o CYP2C9, principal enzima que metaboliza a Warfarina.',
   'Inhibits CYP2C9, the main enzyme metabolising Warfarin.',
   'Reduzir a dose de Warfarina em 25–50% e monitorizar o INR com maior frequência.',
   'Reduce the Warfarin dose by 25–50% and monitor INR more frequently.',
   'INR semanal nas primeiras semanas após iniciar a Amiodarona.',
   'Weekly INR in the first weeks after starting Amiodarone.',
   'Sangramento anormal, equimoses espontâneas, hemorragia gengival.',
   'Unusual bleeding, spontaneous bruising, gum bleeding.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_clopidogrel, v_omeprazol), GREATEST(v_clopidogrel, v_omeprazol), 'moderate',
   'Redução da eficácia do Clopidogrel. O Omeprazol inibe o CYP2C19, reduzindo a ativação do pró-fármaco.',
   'Reduced Clopidogrel efficacy. Omeprazole inhibits CYP2C19, reducing pro-drug activation.',
   'O Clopidogrel precisa do CYP2C19 para se tornar ativo; o Omeprazol é um inibidor potente dessa enzima.',
   'Clopidogrel requires CYP2C19 for activation; Omeprazole potently inhibits that enzyme.',
   'Preferir Pantoprazol (menor interação) ou outro protetor gástrico quando necessário.',
   'Prefer Pantoprazole (less interaction) or another gastric protectant when needed.',
   'Vigiar eventos trombóticos (dor torácica, sintomas neurológicos).',
   'Watch for thrombotic events (chest pain, neurological symptoms).',
   'Novos eventos trombóticos — dor torácica, fraqueza súbita unilateral, alterações da fala.',
   'New thrombotic events — chest pain, sudden unilateral weakness, speech changes.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_claritromicina, v_atorvastatina), GREATEST(v_claritromicina, v_atorvastatina), 'moderate',
   'Risco de miopatia e rabdomiólise. A Claritromicina aumenta os níveis de Atorvastatina.',
   'Risk of myopathy and rhabdomyolysis. Clarithromycin raises Atorvastatin levels.',
   'Inibição do CYP3A4, via principal de metabolização da Atorvastatina.',
   'Inhibition of CYP3A4, the main Atorvastatin metabolic pathway.',
   'Suspender a estatina durante um tratamento curto com Claritromicina ou preferir Azitromicina.',
   'Hold the statin during a short course of Clarithromycin or prefer Azithromycin.',
   'Sintomas musculares (dor, fraqueza, urina escura) durante e após o antibiótico.',
   'Muscle symptoms (pain, weakness, dark urine) during and after the antibiotic.',
   'Dor muscular intensa, fraqueza proximal, urina de cor escura (possível rabdomiólise).',
   'Severe muscle pain, proximal weakness, dark-coloured urine (possible rhabdomyolysis).',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_antiacidos, v_ciprofloxacina), GREATEST(v_antiacidos, v_ciprofloxacina), 'moderate',
   'Redução acentuada da absorção da Ciprofloxacina. Os catiões divalentes (alumínio, magnésio, cálcio, ferro) quelam a fluoroquinolona.',
   'Markedly reduced Ciprofloxacin absorption. Divalent cations (aluminium, magnesium, calcium, iron) chelate the fluoroquinolone.',
   'Quelação entre o antibiótico e os catiões no lúmen gastrointestinal.',
   'Chelation between the antibiotic and cations in the gastrointestinal lumen.',
   'Administrar o antiácido 2 horas depois (ou 6 horas antes) da Ciprofloxacina.',
   'Give the antacid 2 hours after (or 6 hours before) Ciprofloxacin.',
   'Vigiar eficácia antibiótica (febre, sinais de infeção não resolvida).',
   'Watch antibiotic efficacy (fever, unresolved infection signs).',
   'Febre persistente, agravamento dos sintomas ou novo foco de infeção.',
   'Persistent fever, worsening symptoms or a new infection focus.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_antiacidos, v_doxiciclina), GREATEST(v_antiacidos, v_doxiciclina), 'moderate',
   'Redução da absorção da Doxiciclina por quelação com catiões.',
   'Reduced Doxycycline absorption through cation chelation.',
   'Quelação da tetraciclina com alumínio, magnésio, cálcio e ferro no intestino.',
   'Chelation of the tetracycline with aluminium, magnesium, calcium and iron in the gut.',
   'Separar a toma do antiácido por 2–3 horas da Doxiciclina.',
   'Separate the antacid dose from Doxycycline by 2–3 hours.',
   'Eficácia da antibioterapia.',
   'Antibiotic efficacy.',
   'Febre, dor ou secreções persistentes — infeção possivelmente não controlada.',
   'Persistent fever, pain or discharge — infection possibly uncontrolled.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_levotiroxina, v_omeprazol), GREATEST(v_levotiroxina, v_omeprazol), 'moderate',
   'Redução da absorção da Levotiroxina com a elevação do pH gástrico.',
   'Reduced Levothyroxine absorption with higher gastric pH.',
   'A dissolução da Levotiroxina depende do pH ácido do estômago; o IBP reduz essa absorção.',
   'Levothyroxine dissolution depends on gastric acid; the PPI reduces absorption.',
   'Administrar a Levotiroxina 30–60 minutos antes do pequeno-almoço e monitorizar TSH.',
   'Give Levothyroxine 30–60 minutes before breakfast and monitor TSH.',
   'TSH 6–8 semanas após iniciar o IBP.',
   'TSH 6–8 weeks after starting the PPI.',
   'Fadiga persistente, ganho de peso, intolerância ao frio — possíveis sinais de hipotiroidismo.',
   'Persistent fatigue, weight gain, cold intolerance — possible signs of hypothyroidism.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_digoxina, v_furosemida), GREATEST(v_digoxina, v_furosemida), 'moderate',
   'A hipocaliemia induzida pela Furosemida aumenta a toxicidade da Digoxina.',
   'Furosemide-induced hypokalaemia increases Digoxin toxicity.',
   'A perda renal de potássio sensibiliza o miocárdio ao efeito da Digoxina.',
   'Renal potassium loss sensitises the myocardium to Digoxin.',
   'Monitorizar K+ e repor precocemente; ajustar a dose de Digoxina se houver alteração da função renal.',
   'Monitor K+ and replace early; adjust the Digoxin dose if renal function changes.',
   'Eletrólitos e digoxinemia; ECG se houver sintomas.',
   'Electrolytes and digoxin levels; ECG if symptoms occur.',
   'Náuseas, anorexia, bradicardia, arritmias, confusão.',
   'Nausea, anorexia, bradycardia, arrhythmias, confusion.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_fluoxetina, v_tramadol), GREATEST(v_fluoxetina, v_tramadol), 'moderate',
   'Risco de síndrome serotoninérgica. A Fluoxetina inibe o CYP2D6, aumentando os níveis de Tramadol.',
   'Risk of serotonin syndrome. Fluoxetine inhibits CYP2D6, raising Tramadol levels.',
   'Acumulação de serotonina: efeito do ISRS somado ao do Tramadol, mais inibição do seu metabolismo.',
   'Serotonin accumulation: the SSRI effect added to Tramadol''s, plus inhibition of its metabolism.',
   'Usar uma alternativa analgésica ou vigiar sinais; evitar combinar dois fármacos serotonérgicos sem necessidade.',
   'Use an alternative analgesic or monitor signs; avoid combining two serotonergic drugs unless needed.',
   'Sinais de serotonina nos primeiros dias.',
   'Serotonin signs in the first days.',
   'Agitação, hipertermia, diarreia, tremores, clónus, confusão.',
   'Agitation, hyperthermia, diarrhoea, tremor, clonus, confusion.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  (LEAST(v_ibuprofeno, v_prednisolona), GREATEST(v_ibuprofeno, v_prednisolona), 'moderate',
   'Risco hemorrágico gastrointestinal acrescido pela associação de corticoide com AINE.',
   'Increased gastrointestinal bleeding risk with corticosteroid plus NSAID.',
   'Efeitos lesivos na mucosa gástrica somados (redução de prostaglandinas protetoras).',
   'Additive gastric mucosal injury (reduced protective prostaglandins).',
   'Considerar proteção gástrica (IBP) se a associação for inevitável; usar as menores doses eficazes.',
   'Consider gastric protection (PPI) if the combination is unavoidable; use the lowest effective doses.',
   'Vigiar sintomas dispépticos e sangue oculto nas fezes.',
   'Watch for dyspepsia and occult blood in stool.',
   'Dor abdominal intensa, melenas, hematemeses.',
   'Severe abdominal pain, melaena, haematemesis.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-03-15 10:00:00+00'),

  -- ===== MENORES =====

  (LEAST(v_aspirina, v_ibuprofeno), GREATEST(v_aspirina, v_ibuprofeno), 'minor',
   'O Ibuprofeno pode reduzir o efeito cardioprotetor da Aspirina de baixa dose.',
   'Ibuprofen may reduce the cardioprotective effect of low-dose Aspirin.',
   'O Ibuprofeno ocupa o local de ligação da ciclo-oxigenase-1, impedindo a inibição irreversível pela Aspirina.',
   'Ibuprofen occupies the COX-1 binding site, blocking Aspirin''s irreversible inhibition.',
   'Se ambos forem necessários, tomar o Ibuprofeno 2 horas depois da Aspirina de libertação imediata.',
   'If both are needed, take Ibuprofen 2 hours after immediate-release Aspirin.',
   'Sem monitorização laboratorial; considerar uma alternativa analgésica em doentes de alto risco.',
   'No laboratory monitoring; consider an alternative analgesic in high-risk patients.',
   'Sinais de novo evento cardiovascular — dor torácica, falta de ar súbita.',
   'Signs of a new cardiovascular event — chest pain, sudden shortness of breath.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-02-10 10:00:00+00'),

  (LEAST(v_glibenclamida, v_metformina), GREATEST(v_glibenclamida, v_metformina), 'minor',
   'Hipoglicemia. A associação de dois antidiabéticos orais exige ajuste e vigilância; não é contraindicada.',
   'Hypoglycaemia. Combining two oral antidiabetics requires dose adjustment and surveillance; not contraindicated.',
   'Efeito hipoglicemiante aditivo: a sulfonilureia estimula a insulina e a metformina reduz a produção hepática de glicose.',
   'Additive glucose-lowering effect: the sulfonylurea stimulates insulin and metformin reduces hepatic glucose output.',
   'Iniciar a sulfonilureia em dose baixa e ajustar conforme as glicemias.',
   'Start the sulfonylurea at a low dose and titrate on glucose readings.',
   'Glicemia capilar e sinais de hipoglicemia.',
   'Capillary glucose and hypoglycaemia signs.',
   'Tremor, sudação, confusão, palidez — sinais de hipoglicemia.',
   'Tremor, sweating, confusion, pallor — signs of hypoglycaemia.',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-02-10 10:00:00+00'),

  -- ===== SEM RELEVÂNCIA =====

  (LEAST(v_espironolactona, v_hidroclorotiazida), GREATEST(v_espironolactona, v_hidroclorotiazida), 'none',
   'Sem interação clinicamente relevante. A associação é por vezes usada de forma intencional pelo efeito diurético sinérgico com menor hipocaliemia.',
   'No clinically relevant interaction. The combination is sometimes used intentionally for synergistic diuresis with less hypokalaemia.',
   '', '', '', '',
   '', '', '', '',
   'Literatura de referência (Stockley''s Drug Interactions; Micromedex)',
   'Reference literature (Stockley''s Drug Interactions; Micromedex)',
   'published', '2026-02-10 10:00:00+00');
END $$;
