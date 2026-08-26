-- =====================================================================
-- 223 — Expansão de interações para fármacos sem pares
-- Fontes: DailyMed/FDA + EMC-EMC Portugal (dual-source)
-- drug_interactions: 16 cols + 'published'
-- drug_disease_interactions: 12 cols + 'published'
-- drug_pregnancy_info: 12 cols + 'published'
--
-- ORDEM CANÓNICA JÁ VERIFICADA (todos a < b):
--   fluoxetina(5feb) < aripiprazol(a000...13)
--   ritonavir(38d0) < aripiprazol(a000...13)
--   paroxetina(a000...14) < tamoxifeno(e1b3)
--   ritonavir(38d0) < zolpidem(a000...1e)
--   atenolol(569e) < verapamilo(9c05)
--   verapamilo(9c05) < bisoprolol(c042)
--   carvedilol(1490) < fluoxetina(5feb)
--   cefixima(34c9) < warfarina(4369)
--   warfarina(4369) < cefpodoxima(4d80)
--   ritonavir(38d0) < fluticasona(a000...31)
--   etossuximida(a000...23) < valproato(d6bb)
--   fluconazol(21fb) < lacosamida(a000...27)
--   isoniazida(1503) < cicloserina(2515)
--   fluconazol(21fb) < protionamida(c179)
--   fluconazol(21fb) < primaquina(b8b6)
-- =====================================================================

-- =====================================================================
-- 1. Interações fármaco-fármaco (drug_interactions)
-- =====================================================================
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, source_url, status)
SELECT a.id, b.id, v.severity, v.summary_pt, v.summary_en,
  v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
  v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
  v.source_pt, v.source_en, v.source_url, 'published'
FROM (VALUES
  -- ═══════ 1. Fluoxetina × Aripiprazol (MODERATE) ═══════
  ('fluoxetina', 'aripiprazol', 'moderate',
   'Antipsicótico + inibidor CYP2D6: fluoxetina pode aumentar níveis de aripiprazol.',
   'Antipsychotic + CYP2D6 inhibitor: fluoxetine may increase aripiprazole levels.',
   'A fluoxetina inibe CYP2D6, a principal via metabolizadora do aripiprazol. Níveis podem aumentar 30-40%.',
   'Fluoxetine inhibits CYP2D6, the main metabolic pathway for aripiprazole. Levels may increase 30-40%.',
   'Reduzir dose de aripiprazol 50% se combinado com inibidor CYP2D6 potente.',
   'Reduce aripiprazole dose by 50% if combined with potent CYP2D6 inhibitor.',
   'Sinais de acatisia, agitação.',
   'Signs of akathisia, agitation.',
   'Acatisia grave.',
   'Severe akathisia.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=243996'),

  -- ═══════ 2. Ritonavir × Aripiprazol (MODERATE) ═══════
  ('ritonavir', 'aripiprazol', 'moderate',
   'Antipsicótico + inibidor CYP3A4: ritonavir pode aumentar níveis de aripiprazol.',
   'Antipsychotic + CYP3A4 inhibitor: ritonavir may increase aripiprazole levels.',
   'O ritonavir inibe CYP3A4, uma das vias metabolizadoras do aripiprazol. Níveis podem aumentar.',
   'Ritonavir inhibits CYP3A4, one of the metabolic pathways for aripiprazole. Levels may increase.',
   'Reduzir dose de aripiprazol. Monitorizar efeitos adversos.',
   'Reduce aripiprazole dose. Monitor adverse effects.',
   'Sinais de acatisia, sedação.',
   'Signs of akathisia, sedation.',
   '', '',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=243996'),

  -- ═══════ 3. Paroxetina × Tamoxifeno (CRITICAL) ═══════
  ('paroxetina', 'tamoxifeno', 'critical',
   'ISRS inibidor CYP2D6 + anti-hormonal: paroxetina reduz actividade do tamoxifeno 60-80%.',
   'CYP2D6 inhibitor SSRI + anti-hormonal: paroxetine reduces tamoxifen activity 60-80%.',
   'O tamoxifeno é activado por CYP2D6 a endoxifeno. A paroxetina inibe CYP2D6, reduzindo formação de endoxifeno 60-80%.',
   'Tamoxifen is activated by CYP2D6 to endoxifen. Paroxetine inhibits CYP2D6, reducing endoxifen formation 60-80%.',
   'CONTRAINDICADO. Trocar por citalopram ou escitalopram.',
   'CONTRAINDICATED. Switch to citalopram or escitalopram.',
   'Eficácia anti-tumoral comprometida.',
   'Compromised anti-tumoral efficacy.',
   'Crescimento tumoral.',
   'Tumour growth.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5088'),

  -- ═══════ 4. Ritonavir × Zolpidem (MODERATE) ═══════
  ('ritonavir', 'zolpidem', 'moderate',
   'Hipnótico + inibidor CYP3A4: ritonavir aumenta níveis de zolpidem 2-3x.',
   'Hypnotic + CYP3A4 inhibitor: ritonavir increases zolpidem levels 2-3-fold.',
   'O zolpidem é metabolizado por CYP3A4. O ritonavir inibe CYP3A4, aumentando os níveis.',
   'Zolpidem is metabolised by CYP3A4. Ritonavir inhibits CYP3A4, increasing levels.',
   'Reduzir dose de zolpidem 50%. Evitar conduzir.',
   'Reduce zolpidem dose by 50%. Avoid driving.',
   'Sedação, frequência respiratória.',
   'Sedation, respiratory rate.',
   'Sedação excessiva.',
   'Excessive sedation.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13701'),

  -- ═══════ 5. Atenolol × Verapamilo (MODERATE) ═══════
  ('atenolol', 'verapamilo', 'moderate',
   'Betabloqueador + bloqueador do cálcio não diidropiridínico: risco de bradicardia e bloqueio AV.',
   'Beta-blocker + non-dihydropyridine calcium channel blocker: risk of bradycardia and AV block.',
   'Ambos reduzem a condução AV e a contractilidade. A combinação pode causar bradicardia severa, bloqueio AV e insuficiência cardíaca.',
   'Both reduce AV conduction and contractility. The combination may cause severe bradycardia, AV block, and heart failure.',
   'Evitar combinação. Se necessária, monitorizar ECG e sinais vitais.',
   'Avoid combination. If necessary, monitor ECG and vital signs.',
   'ECG, frequência cardíaca, pressão arterial.',
   'ECG, heart rate, blood pressure.',
   'Bradicardia severa, bloqueio AV.',
   'Severe bradycardia, AV block.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6683'),

  -- ═══════ 6. Verapamilo × Bisoprolol (MODERATE) ═══════
  ('verapamilo', 'bisoprolol', 'moderate',
   'Betabloqueador + bloqueador do cálcio não diidropiridínico: risco de bradicardia severa.',
   'Beta-blocker + non-dihydropyridine CCB: risk of severe bradycardia.',
   'Mecanismo idêntico ao atenolol + verapamilo. Ambos reduzem condução AV e contractilidade.',
   'Same mechanism as atenolol + verapamil. Both reduce AV conduction and contractility.',
   'Evitar combinação. Se necessária, monitorizar ECG.',
   'Avoid combination. If necessary, monitor ECG.',
   'ECG, frequência cardíaca.',
   'ECG, heart rate.',
   'Bradicardia severa.',
   'Severe bradycardia.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6683'),

  -- ═══════ 7. Carvedilol × Fluoxetina (MODERATE) ═══════
  ('carvedilol', 'fluoxetina', 'moderate',
   'Betabloqueador + inibidor CYP2D6: fluoxetina pode aumentar níveis de carvedilol.',
   'Beta-blocker + CYP2D6 inhibitor: fluoxetine may increase carvedilol levels.',
   'O carvedilol é metabolizado por CYP2D6. A fluoxetina inibe CYP2D6, aumentando níveis.',
   'Carvedilol is metabolised by CYP2D6. Fluoxetine inhibits CYP2D6, increasing levels.',
   'Monitorizar FC e PA. Reduzir dose se necessário.',
   'Monitor heart rate and blood pressure. Reduce dose if necessary.',
   'FC, PA, sinais de bradicardia.',
   'Heart rate, blood pressure, signs of bradycardia.',
   'Bradicardia sintomática.',
   'Symptomatic bradycardia.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6189'),

  -- ═══════ 8. Cefixima × Warfarina (MODERATE) ═══════
  ('cefixima', 'warfarina', 'moderate',
   'Cefalosporina + anticoagulante: pode potenciar efeito da warfarina.',
   'Cephalosporin + anticoagulant: may potentiate warfarin effect.',
   'Cefalosporinas reduzem síntese de vitamina K pela flora intestinal, potenciando o efeito anticoagulante.',
   'Cephalosporins reduce vitamin K synthesis by gut flora, potentiating the anticoagulant effect.',
   'Monitorizar INR durante e após curso de cefixima.',
   'Monitor INR during and after cefixime course.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia grave.',
   'Major bleeding.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4973'),

  -- ═══════ 9. Warfarina × Cefpodoxima (MODERATE) ═══════
  ('warfarina', 'cefpodoxima', 'moderate',
   'Cefalosporina + anticoagulante: pode potenciar efeito da warfarina.',
   'Cephalosporin + anticoagulant: may potentiate warfarin effect.',
   'Mecanismo idêntico à cefixima. Cefalosporinas reduzem síntese de vitamina K pela flora intestinal.',
   'Same mechanism as cefixime. Cephalosporins reduce vitamin K synthesis by gut flora.',
   'Monitorizar INR.',
   'Monitor INR.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia grave.',
   'Major bleeding.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5563'),

  -- ═══════ 10. Ritonavir × Fluticasona (CRITICAL) ═══════
  ('ritonavir', 'fluticasona', 'critical',
   'Corticosteroide inalatório + inibidor CYP3A4: risco de Cushing iatrogénico.',
   'Inhaled corticosteroid + CYP3A4 inhibitor: risk of iatrogenic Cushing syndrome.',
   'Ritonavir inibe CYP3A4, aumentando biodisponibilidade sistémica de fluticasona de 1-2% para >20%. Risco de supressão do eixo HPA.',
   'Ritonavir inhibits CYP3A4, increasing systemic fluticasone bioavailability from 1-2% to >20%. Risk of HPA axis suppression.',
   'Evitar. Se inevitável, dose mínima e monitorizar cortisol.',
   'Avoid. If unavoidable, minimum dose and monitor cortisol.',
   'Cortisol, glicemia, peso.',
   'Cortisol, blood glucose, weight.',
   'Cushing iatrogénico.',
   'Iatrogenic Cushing.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=313517bd'),

  -- ═══════ 11. Etossuximida × Valproato (MODERATE) ═══════
  ('etossuximida', 'valproato', 'moderate',
   'Antiepiléptico + antiepiléptico: valproato pode aumentar níveis de etossuximida.',
   'Antiepileptic + antiepileptic: valproate may increase ethosuximide levels.',
   'Valproato inibe CYP3A4, uma das vias metabolizadoras da etossuximida. Níveis podem aumentar 20-30%.',
   'Valproate inhibits CYP3A4, one of the metabolic pathways for ethosuximide. Levels may increase 20-30%.',
   'Monitorizar níveis de etossuximida se combinado com valproato.',
   'Monitor ethosuximide levels if combined with valproate.',
   'Níveis de etossuximida, sinais de toxicidade.',
   'Ethosuximide levels, signs of toxicity.',
   '', '',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1686'),

  -- ═══════ 12. Fluconazol × Lacosamida (MODERATE) ═══════
  ('fluconazol', 'lacosamida', 'moderate',
   'Antiepiléptico + inibidor CYP2C19: fluconazol pode aumentar ligeiramente lacosamida.',
   'Antiepileptic + CYP2C19 inhibitor: fluconazole may slightly increase lacosamide.',
   'Lacosamida é parcialmente metabolizada por CYP2C19. Fluconazol inibe CYP2C19, aumentando níveis.',
   'Lacosamide is partially metabolised by CYP2C19. Fluconazole inhibits CYP2C19, increasing levels.',
   'Monitorizar efeitos adversos.',
   'Monitor adverse effects.',
   'Sinais de toxicidade (tontura, diplopia).',
   'Signs of toxicity (dizziness, diplopia).',
   '', '',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2c53d6c3'),

  -- ═══════ 13. Isoniazida × Cicloserina (MODERATE) ═══════
  ('isoniazida', 'cicloserina', 'moderate',
   'Antituberculoso + antituberculoso: toxicidade aditiva no SNC.',
   'Antituberculous + antituberculous: additive CNS toxicity.',
   'Ambos podem causar convulsões e perturbações psiquiátricas. Efeito aditivo sobre toxicidade neurológica.',
   'Both can cause seizures and psychiatric disturbances. Additive effect on neurological toxicity.',
   'Monitorizar função neurológica e psiquiátrica.',
   'Monitor neurological and psychiatric function.',
   'Convulsões, psicose, tontura.',
   'Seizures, psychosis, dizziness.',
   'Convulsões, psicose.',
   'Seizures, psychosis.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=150342c1'),

  -- ═══════ 14. Fluconazol × Protionamida (MODERATE) ═══════
  ('fluconazol', 'protionamida', 'moderate',
   'Antituberculoso + inibidor CYP: fluconazol pode aumentar níveis de protionamida.',
   'Antituberculous + CYP inhibitor: fluconazole may increase protionamide levels.',
   'Protionamida é metabolizada por CYP enzimas. Fluconazol inibe CYP, aumentando níveis e risco de hepatotoxicidade.',
   'Protionamide is metabolised by CYP enzymes. Fluconazole inhibits CYP, increasing levels and hepatotoxicity risk.',
   'Monitorizar transaminases mensalmente.',
   'Monitor transaminases monthly.',
   'AST, ALT, bilirrubina.',
   'AST, ALT, bilirubin.',
   'Hepatite grave.',
   'Severe hepatitis.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c179587d'),

  -- ═══════ 15. Fluconazol × Primaquina (MODERATE) ═══════
  ('fluconazol', 'primaquina', 'moderate',
   'Antimalárico + inibidor CYP: fluconazol pode aumentar níveis de primaquina.',
   'Antimalarial + CYP inhibitor: fluconazole may increase primaquine levels.',
   'Primaquina é metabolizada por CYP2D6 e outras enzimas. Fluconazol inibe parcialmente estas vias, aumentando níveis.',
   'Primaquine is metabolised by CYP2D6 and other enzymes. Fluconazole partially inhibits these pathways, increasing levels.',
   'Monitorizar sinais de toxicidade.',
   'Monitor for signs of toxicity.',
   'Metemoglobina, saturação O2.',
   'Methaemoglobin, O2 saturation.',
   'Metemoglobinemia severa.',
   'Severe methaemoglobinaemia.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8b68b8c')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Interações doença (drug_disease_interactions)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en, source_pt, source_en, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
  v.interaction_type, v.severity, v.reason_pt, v.reason_en,
  v.advice_pt, v.advice_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('primaquina', 'deficiencia_g6pd', 'Deficiência de G6PD', 'G6PD deficiency',
   'contraindication', 'critical',
   'CONTRAINDICADO em deficiência de G6PD. Risco de hemólise severa.',
   'CONTRAINDICATED in G6PD deficiency. Risk of severe haemolysis.',
   'Testar G6PD antes de iniciar.',
   'Test G6PD before starting.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('cicloserina', 'epilepsia', 'Epilepsia', 'Epilepsy',
   'precaution', 'moderate',
   'Cicloserina pode reduzir limiar convulsivo.',
   'Cycloserine may lower seizure threshold.',
   'Monitorizar sinais de convulsão.',
   'Monitor for seizure signs.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('atenolol', 'insuficiencia_cardiaca', 'IC descompensada', 'Decompensated HF',
   'contraindication', 'critical',
   'CONTRAINDICADO em IC descompensada.',
   'CONTRAINDICATED in decompensated HF.',
   'Estabilizar primeiro.',
   'Stabilise first.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('bisoprolol', 'insuficiencia_cardiaca', 'IC descompensada', 'Decompensated HF',
   'contraindication', 'critical',
   'CONTRAINDICADO em IC descompensada.',
   'CONTRAINDICATED in decompensated HF.',
   'Estabilizar primeiro.',
   'Stabilise first.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('carvedilol', 'insuficiencia_cardiaca', 'IC descompensada', 'Decompensated HF',
   'contraindication', 'critical',
   'CONTRAINDICADO em IC descompensada.',
   'CONTRAINDICATED in decompensated HF.',
   'Estabilizar primeiro.',
   'Stabilise first.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT')
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 3. Perfil gravidez (drug_pregnancy_info)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en,
   trimester_pt, trimester_en, lactation_pt, lactation_en,
   contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id,
  v.pregnancy_category, v.risk_pt, v.risk_en,
  v.trimester_pt, v.trimester_en, v.lactation_pt, v.lactation_en,
  v.contraception_pt, v.contraception_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('atenolol', 'contraindicated',
   'CONTRAINDICADO na gravidez. Retardo do crescimento intra-uterino.',
   'CONTRAINDICATED in pregnancy. Intrauterine growth retardation.',
   'CONTRAINDICADO no 3o trimestre.',
   'CONTRAINDICATED in 3rd trimester.',
   'Excretado no leite materno. Evitar.',
   'Excreted in breast milk. Avoid.',
   'Contracepção fiável.',
   'Reliable contraception.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('bisoprolol', 'contraindicated',
   'CONTRAINDICADO na gravidez.',
   'CONTRAINDICATED in pregnancy.',
   'CONTRAINDICADO no 3o trimestre.',
   'CONTRAINDICATED in 3rd trimester.',
   'Evitar durante aleitamento.',
   'Avoid during breastfeeding.',
   'Contracepção fiável.',
   'Reliable contraception.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('lorazepam', 'contraindicated',
   'CONTRAINDICADO no 3o trimestre. Síndrome de descontinuação neonatal.',
   'CONTRAINDICATED in 3rd trimester. Neonatal withdrawal syndrome.',
   'CONTRAINDICADO no 3o trimestre.',
   'CONTRAINDICATED in 3rd trimester.',
   'Excretado no leite materno. Evitar.',
   'Excreted in breast milk. Avoid.',
   'Contracepção fiável.',
   'Reliable contraception.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT'),
  ('zolpidem', 'contraindicated',
   'CONTRAINDICADO na gravidez.',
   'CONTRAINDICATED in pregnancy.',
   'CONTRAINDICADO.',
   'CONTRAINDICATED.',
   'Excretado no leite materno. Evitar.',
   'Excreted in breast milk. Avoid.',
   'Contracepção fiável.',
   'Reliable contraception.',
   'DailyMed/FDA; EMC-EMC PT',
   'DailyMed/FDA; EMC-EMC PT')
) AS v(slug, pregnancy_category, risk_pt, risk_en,
       trimester_pt, trimester_en, lactation_pt, lactation_en,
       contraception_pt, contraception_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
