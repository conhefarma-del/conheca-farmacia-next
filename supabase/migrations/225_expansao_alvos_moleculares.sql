-- =====================================================================
-- 225: Expansão de alvos moleculares — 10 novos alvos + mapeamento
--      fármaco ↔ alvo (drug_target_roles)
--
-- Novos alvos: OCT2, OAT1/OAT3, hERG, SERT, DAT, NET, PXR,
--   PPAR-γ, UGT1A1, DPP-4
--
-- Fontes: DailyMed/FDA (NIH/NLM) e EMC-UK (MHRA) — únicas fontes
--   aceites pelo projeto (secção 2 de INTERACOES_FLUXO_PESQUISA.md).
--   Todo o conteúdo é autoral (nunca cópia direta) e ancorado nos
--   rótulos citados.
--
-- Idempotente: ON CONFLICT DO NOTHING em ambas as partes.
-- =====================================================================

-- ============================================================
-- 1. Novos alvos moleculares (molecular_targets)
-- ============================================================
INSERT INTO public.molecular_targets
  (slug, target_type, name_pt, name_en, full_name_pt, full_name_en, aliases,
   what_is_pt, what_is_en, role_pt, role_en,
   substrates_pt, substrates_en, inhibitors_pt, inhibitors_en,
   inducers_pt, inducers_en, clinical_notes_pt, clinical_notes_en,
   source_pt, source_en, sort_order)
VALUES
  -- 1. OCT2 (SLC22A2) — transportador de cations orgânicos
  ('oct2', 'transporter', 'OCT2', 'OCT2',
   'Transportador de cations orgânicos 2 (SLC22A2)',
   'Organic cation transporter 2 (SLC22A2)',
   ARRAY['OCT2', 'SLC22A2', 'ROCT'],
   E'Transportador de captação (SLC22A2) expresso nos túbulos renais proximais e no rim, responsável pela secreção tubular de fármacos catiónicos como a metformina, a ranitidina e o dolutegravir. Também é relevante na eliminação de cisplatina e procainamida.',
   E'Uptake transporter (SLC22A2) expressed in the proximal renal tubules and kidney, responsible for tubular secretion of cationic drugs such as metformine, ranitidine and dolutegravir. Also relevant in the elimination of cisplatin and procainamide.',
   E'A inibição do OCT2 (ex.: cimetidina, trimetoprim) reduz a secreção tubular de metformina, aumentando as concentrações plasmáticas e o risco de efeitos adversos (acidose láctica). A ranitidina é tanto substrato como inibidor fraco do OCT2.',
   E'OCT2 inhibition (e.g. cimetidine, trimethoprim) reduces tubular secretion of metformine, raising plasma concentrations and the risk of adverse effects (lactic acidosis). Ranitidine is both a substrate and a weak OCT2 inhibitor.',
   E'Substratos: metformina, ranitidina, dolutegravir, procainamida, cisplatina, dofetilida.',
   E'Substrates: metformine, ranitidine, dolutegravir, procainamide, cisplatin, dofetilide.',
   E'Inibidores: cimetidina, trimetoprim, dolutegravir, ranitidina (fraco), procainamida (competição).',
   E'Inhibitors: cimetidine, trimethoprim, dolutegravir, ranitidine (weak), procainamide (competition).',
   E'Indutores: não há indutores clinicamente relevantes documentados.',
   E'Inducers: there are no clinically relevant inducers documented.',
   E'A interação metformina + cimetidina/trimetoprim pode elevar o risco de acidose láctica; monitorizar função renal quando associado a inibidores do OCT2.',
   E'The metformine + cimetidine/trimethoprim interaction may raise the risk of lactic acidosis; monitor renal function when combined with OCT2 inhibitors.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (metformina, ranitidina, dolutegravir); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (metformine, ranitidine, dolutegravir); EMC-UK (MHRA) — SmPC', 21),

  -- 2. OAT1/OAT3 (SLC22A6/8) — transportadores de aniões orgânicos
  ('oat1b3', 'transporter', 'OAT1/OAT3', 'OAT1/OAT3',
   'Transportadores de aniões orgânicos 1 e 3 (SLC22A6 / SLC22A8)',
   'Organic anion transporters 1 and 3 (SLC22A6 / SLC22A8)',
   ARRAY['OAT1', 'OAT3', 'SLC22A6', 'SLC22A8', 'ROAT1', 'ROAT3'],
   E'Transportadores de captação (SLC22A6/SLC22A8) expressos nos túbulos renais proximais, responsáveis pela secreção tubular de aniões orgânicos e fármacos aniónicos como antivirais (tenofovir, aciclovir), AINEs, diuréticos de alça e penicilinas.',
   E'Uptake transporters (SLC22A6/SLC22A8) expressed in the proximal renal tubules, responsible for tubular secretion of organic anions and anionic drugs such as antivirals (tenofovir, aciclovir), NSAIDs, loop diuretics and penicillins.',
   E'A inibição dos OAT1/OAT3 (ex.: probenecida, AINEs, cotrimoxazol) reduz a secreção tubular dos substratos e aumenta as concentrações plasmáticas; a probenecida é usada intencionalmente para prolongar a ação das penicilinas.',
   E'OAT1/OAT3 inhibition (e.g. probenecid, NSAIDs, cotrimoxazole) reduces tubular secretion of substrates and raises plasma concentrations; probenecid is intentionally used to prolong penicillin action.',
   E'Substratos: tenofovir, aciclovir, adefovir, ibuprofeno, naproxeno, furosemida, metotrexato, penicilinas.',
   E'Substrates: tenofovir, aciclovir, adefovir, ibuprofen, naproxen, furosemide, methotrexate, penicillins.',
   E'Inibidores: probenecida, indometacina, ibuprofeno, naproxeno, cetorolaco, piroxicam, meloxicam, cotrimoxazol (sulfametoxazol).',
   E'Inhibitors: probenecid, indomethacin, ibuprofen, naproxen, ketorolac, piroxicam, meloxicam, cotrimoxazole (sulfamethoxazole).',
   E'Indutores: rifampicina (indução transitória).',
   E'Inducers: rifampicin (transient induction).',
   E'A probenecida é usada clinicamente para prolongar a meia-vida das penicilinas (bloqueio da secreção tubular); os AINEs podem elevar os níveis de metotrexato e tenofovir por inibição dos OAT.',
   E'Probenecid is clinically used to prolong penicillin half-life (blocking tubular secretion); NSAIDs can raise methotrexate and tenofovir levels by OAT inhibition.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (tenofovir, aciclovir, furosemida, ibuprofeno); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (tenofovir, aciclovir, furosemide, ibuprofen); EMC-UK (MHRA) — SmPC', 22),

  -- 3. hERG (KCNH2) — canal de potássio cardíaco
  ('herg', 'receptor', 'hERG', 'hERG',
   'Canal de potássio retificador externo rápido (KCNH2 / hERG)',
   'Rapid delayed rectifier potassium channel (KCNH2 / hERG)',
   ARRAY['hERG', 'KCNH2', 'Kv11.1', 'canal_k'],
   E'Canal de potássio cardíaco (KCNH2) que controla a repolarização ventricular (intervalo QT no ECG). A inibição do hERG por fármacos pode prolongar o QT e desencadear arritmias ventriculares graves (torsades de pointes).',
   E'Cardiac potassium channel (KCNH2) that controls ventricular repolarisation (QT interval on ECG). Drug-induced hERG inhibition can prolong QT and trigger serious ventricular arrhythmias (torsades de pointes).',
   E'Muitos fármacos de classes diversas (antipsicóticos, antibióticos macrólidos, antiarrítmicos, antidepressivos) inibem o hERG e prolongam o QT; a coadministração de vários inibidores do hERG aumenta o risco de forma aditiva.',
   E'Many drugs from diverse classes (antipsychotics, macrolide antibiotics, antiarrhythmics, antidepressants) inhibit hERG and prolong QT; co-administration of multiple hERG inhibitors increases risk additively.',
   E'Substratos: canais de potássio Kv11.1 (alvo terapêutico dos antiarrítmicos classe III como sotalol).',
   E'Substrates: Kv11.1 potassium channels (therapeutic target of class III antiarrhythmics such as sotalol).',
   E'Inibidores do hERG (causam prolongamento QT): sotalol, amiodarona, haloperidol, pimozida, eritromicina, ciprofloxacina, fluconazol, citalopram, escitalopram, metadona, clozapina, olanzapina, quetiapina.',
   E'hERG inhibitors (cause QT prolongation): sotalol, amiodarone, haloperidol, pimozide, erythromycin, ciprofloxacin, fluconazole, citalopram, escitalopram, methadone, clozapine, olanzapine, quetiapine.',
   E'Indutores: não aplicável.',
   E'Inducers: not applicable.',
   E'O prolongamento do QT é um efeito de classe de muchos psicofármacos e antibióticos; evitar múltiplos inibidores do hERG em simultâneo, especialmente em doentes com risco (hipocalemia, cardiopatia, prolongamento QT basal).',
   E'QT prolongation is a class effect of many psychotropics and antibiotics; avoid multiple hERG inhibitors simultaneously, especially in at-risk patients (hypokalaemia, cardiac disease, baseline QT prolongation).',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (sotalol, haloperidol, eritromicina, citalopram); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (sotalol, haloperidol, erythromycin, citalopram); EMC-UK (MHRA) — SmPC', 23),

  -- 4. SERT (SLC6A4) — transportador de serotonina
  ('sert', 'transporter', 'SERT', 'SERT',
   'Transportador de serotonina (SLC6A4)',
   'Serotonin transporter (SLC6A4)',
   ARRAY['SERT', 'SLC6A4', '5-HTT', 'serotonin-transporter'],
   E'Transportador de captação (SLC6A4) localizado nos terminais serotoninérgicos, que recicla a serotonina para o interior do neurónio. É o alvo terapêutico dos ISRS (fluoxetina, sertralina, paroxetina, citalopram, escitalopram) e dos ISRN (venlafaxina, duloxetina).',
   E'Uptake transporter (SLC6A4) located on serotonergic terminals, which recycles serotonin into the neurone. It is the therapeutic target of SSRIs (fluoxetine, sertraline, paroxetine, citalopram, escitalopram) and SNRIs (venlafaxine, duloxetine).',
   E'A inibição do SERT aumenta a serotonina sináptica; a associação de vários fármacos serotoninérgicos (ISRS + tramadol, ISRS + IMAO, ISRS + linezolida) pode causar síndrome serotoninérgica.',
   E'SERT inhibition raises synaptic serotonin; combining multiple serotonergic drugs (SSRI + tramadol, SSRI + MAOI, SSRI + linezolid) can cause serotonin syndrome.',
   E'Substratos: serotonina (neurotransmissor endógeno).',
   E'Substrates: serotonin (endogenous neurotransmitter).',
   E'Inibidores (ISRS/ISRN): fluoxetina, sertralina, paroxetina, citalopram, escitalopram, venlafaxina, duloxetina, fluvoxamina; inibidores não seletivos: tramadol, linezolida, clomipramina.',
   E'Inhibitors (SSRIs/SNRIs): fluoxetine, sertraline, paroxetine, citalopram, escitalopram, venlafaxine, duloxetine, fluvoxamine; non-selective inhibitors: tramadol, linezolid, clomipramine.',
   E'Indutores: não há indutores clinicamente relevantes.',
   E'Inducers: there are no clinically relevant inducers.',
   E'A síndrome serotoninérgica é potencialmente fatal: hipertermia, agitação, mioclono, hiperreflexia. Risco máximo na combinação IMAO + ISRS (washout mínimo de 2 semanas).',
   E'Serotonin syndrome is potentially fatal: hyperthermia, agitation, myoclonus, hyperreflexia. Highest risk with MAOI + SSRI combination (minimum 2-week washout).',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (fluoxetina, sertralina, venlafaxina); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (fluoxetine, sertraline, venlafaxine); EMC-UK (MHRA) — SmPC', 24),

  -- 5. DAT (SLC6A3) — transportador de dopamina
  ('dat', 'transporter', 'DAT', 'DAT',
   'Transportador de dopamina (SLC6A3)',
   'Dopamine transporter (SLC6A3)',
   ARRAY['DAT', 'SLC6A3', 'dopamine-transporter'],
   E'Transportador de captação (SLC6A3) localizado nos terminais dopaminérgicos, que recicla a dopamina para o interior do neurónio. É o alvo terapêutico dos psicoestimulantes (metilfenidato) e do cocaína.',
   E'Uptake transporter (SLC6A3) located on dopaminergic terminals, which recycles dopamine into the neurone. It is the therapeutic target of psychostimulants (methylphenidate) and cocaine.',
   E'A inibição do DAT aumenta a dopamina sináptica; fármacos que inibem o DAT (metilfenidato, bupropiona) podem interagir com outros agentes dopaminérgicos.',
   E'DAT inhibition raises synaptic dopamine; drugs that inhibit DAT (methylphenidate, bupropion) can interact with other dopaminergic agents.',
   E'Substratos: dopamina (neurotransmissor endógeno).',
   E'Substrates: dopamine (endogenous neurotransmitter).',
   E'Inibidores: metilfenidato, bupropiona, cocaína, mazindol.',
   E'Inhibitors: methylphenidate, bupropion, cocaine, mazindol.',
   E'Indutores: não há indutores clinicamente relevantes.',
   E'Inducers: there are no clinically relevant inducers.',
   E'Importante na TDAH e na dependência de substâncias: a bupropiona (inibidor fraco do DAT e NET) pode reduzir a eficácia de fármacos dopaminérgicos e potenciar convulsões em doses altas.',
   E'Important in ADHD and substance dependence: bupropion (weak DAT and NET inhibitor) may reduce efficacy of dopaminergic drugs and potentiate seizures at high doses.',
   E'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bupropiona; EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved Bupropion label; EMC-UK (MHRA) — SmPC', 25),

  -- 6. NET (SLC6A2) — transportador de noradrenalina
  ('net', 'transporter', 'NET', 'NET',
   'Transportador de noradrenalina (SLC6A2)',
   'Norepinephrine transporter (SLC6A2)',
   ARRAY['NET', 'SLC6A2', 'NETT', 'norepinephrine-transporter'],
   E'Transportador de captação (SLC6A2) localizado nos terminais noradrenérgicos, que recicla a noradrenalina (adrenalina) para o interior do neurónio. É alvo dos SNRIs (venlafaxina, duloxetina) e da atomoxetina.',
   E'Uptake transporter (SLC6A2) located on noradrenergic terminals, which recycles norepinephrine (adrenaline) into the neurone. It is targeted by SNRIs (venlafaxine, duloxetine) and atomoxetine.',
   E'A inibição do NET aumenta a noradrenalina sináptica; fármacos serotoninérgicos que também inibem o NET (venlafaxina, duloxetina) podem causar hipertensão por potenciação noradrenérgica.',
   E'NET inhibition raises synaptic norepinephrine; serotonergic drugs that also inhibit NET (venlafaxine, duloxetine) may cause hypertension through noradrenergic potentiation.',
   E'Substratos: noradrenalina (adrenalina), epinefrina.',
   E'Substrates: norepinephrine (adrenaline), epinephrine.',
   E'Inibidores: venlafaxina, duloxetina, mirtazapina (fraco), atomoxetina, desipramina, nortriptilina, bupropiona (fraco).',
   E'Inhibitors: venlafaxine, duloxetine, mirtazapine (weak), atomoxetine, desipramine, nortriptyline, bupropion (weak).',
   E'Indutores: não há indutores clinicamente relevantes.',
   E'Inducers: there are no clinically relevant inducers.',
   E'Venlafaxina e duloxetina inibem both SERT e NET (ação dupla); a mirtazapina tem mecanismo diferente (antagonismo α2) mas efeitos noradrenérgicos aditivos.',
   E'Venlafaxine and duloxetine inhibit both SERT and NET (dual action); mirtazapine has a different mechanism (α2 antagonism) but additive noradrenergic effects.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (venlafaxina, duloxetina, mirtazapina); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (venlafaxine, duloxetine, mirtazapine); EMC-UK (MHRA) — SmPC', 26),

  -- 7. PXR (NR1I2) — receptor nuclear
  ('pxr', 'receptor', 'PXR', 'PXR',
   'Receptor pregnano X (NR1I2)',
   'Pregnane X receptor (NR1I2)',
   ARRAY['PXR', 'NR1I2', 'SXR', 'pregnane-x-receptor'],
   E'Receptor nuclear (NR1I2) ativado por xenobióticos que regula a expressão de enzimas metabólicas (CYP3A4, CYP2C9) e transportadores (P-gp, MRP2). É o "sensor" celular de fármacos e o indutor maestro do CYP3A4.',
   E'Nuclear receptor (NR1I2) activated by xenobiotics that regulates expression of metabolic enzymes (CYP3A4, CYP2C9) and transporters (P-gp, MRP2). It is the cellular "sensor" of drugs and the master inducer of CYP3A4.',
   E'Fármacos que ativam o PXR (ex.: rifampicina, carbamazepina, fenitoína) aumentam a transcrição de CYP3A4 e outros alvos, reduzindo as concentrações de múltiplos substratos — o mecanismo por trás das interações de múltiplos fármacos com a rifampicina.',
   E'Drugs that activate PXR (e.g. rifampicin, carbamazepine, phenytoin) increase transcription of CYP3A4 and other targets, lowering concentrations of multiple substrates — the mechanism behind rifampicin''s multiple drug interactions.',
   E'Substratos: xenobióticos lipofílicos (rifampicina, carbamazepina, fenitoína, dexametasona).',
   E'Substrates: lipophilic xenobiotics (rifampicin, carbamazepine, phenytoin, dexamethasone).',
   E'Inibidores: cetoconazol, fluconazol, ritonavir, clotrimazol.',
   E'Inhibitors: ketoconazole, fluconazole, ritonavir, clotrimazole.',
   E'Indutores: rifampicina (indutor mais potente do PXR), fenobarbital, carbamazepina, fenitoína, erva-de-são-joão.',
   E'Inducers: rifampicin (most potent PXR inducer), phenobarbital, carbamazepine, phenytoin, St John''s wort.',
   E'A rifampicina é o indutor mais potente do PXR e pode reduzir a eficácia de imunossupressores, anticoagulantes, antirretrovirais e muitos outros — exige ajuste de dose ou alternativa.',
   E'Rifampicin is the most potent PXR inducer and can reduce efficacy of immunosuppressants, anticoagulants, antiretrovirals and many others — requires dose adjustment or alternative.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (rifampicina, carbamazepina); PubMed (NIH/NLM) — farmacologia do PXR',
   E'DailyMed/FDA (NIH/NLM) — approved labels (rifampicin, carbamazepine); PubMed (NIH/NLM) — PXR pharmacology', 27),

  -- 8. PPAR-γ (PPARG) — receptor nuclear
  ('pparg', 'receptor', 'PPAR-γ', 'PPAR-γ',
   'Receptor activado por proliferadores peroxissómicos gama (PPARG)',
   'Peroxisome proliferator-activated receptor gamma (PPARG)',
   ARRAY['PPAR-γ', 'PPARG', 'PPARg', 'nr1c3'],
   E'Receptor nuclear (PPARG) ativado por tiazolidinedionas (pioglitazona, rosiglitazona) que regula a sensibilidade à insulina nos tecidos periféricos. É o alvo terapêutico das tiazolidinedionas no diabetes tipo 2.',
   E'Nuclear receptor (PPARG) activated by thiazolidinediones (pioglitazone, rosiglitazone) that regulates insulin sensitivity in peripheral tissues. It is the therapeutic target of thiazolidinediones in type 2 diabetes.',
   E'Fármacos que ativam o PPAR-γ (tiazolidinedionas) melhoram a sensibilidade à insulina mas podem causar retenção de líquidos, insuficiência cardíaca e fraturas; a associação com insulina ou sulfonilureias aumenta o risco de hipoglicemia.',
   E'Drugs that activate PPAR-γ (thiazolidinediones) improve insulin sensitivity but may cause fluid retention, heart failure and fractures; combination with insulin or sulfonylureas increases hypoglycaemia risk.',
   E'Substratos: ácidos gordos endógenos (ligandos fisiológicos do PPAR-γ).',
   E'Substrates: endogenous fatty acids (physiological PPAR-γ ligands).',
   E'Inibidores: não há inibidores clinicamente relevantes dos PPAR-γ.',
   E'Inhibitors: there are no clinically relevant PPAR-γ inhibitors.',
   E'Indutores: tiazolidinedionas (pioglitazona, rosiglitazona) — agonistas do PPAR-γ.',
   E'Inducers: thiazolidinediones (pioglitazone, rosiglitazone) — PPAR-γ agonists.',
   E'Contraindicado em insuficiência cardíaca (classe III/IV) e hepatopatia ativa; monitorizar peso, edema e sintomas cardíacos. Risco aumentado de fraturas (sobretudo mulheres).',
   E'Contraindicated in heart failure (class III/IV) and active liver disease; monitor weight, oedema and cardiac symptoms. Increased fracture risk (especially women).',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (pioglitazona, rosiglitazona); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (pioglitazone, rosiglitazone); EMC-UK (MHRA) — SmPC', 28),

  -- 9. UGT1A1 — enzima de glucuronidação
  ('ugt1a1', 'enzyme', 'UGT1A1', 'UGT1A1',
   'UDP-glucuronosiltransferase 1A1',
   'UDP-glucuronosyltransferase 1A1',
   ARRAY['UGT1A1', 'UGT1'],
   E'Enzima do complexo UDP-glucuronosiltransferase (família 1A) que catalisa a glucuronidação de fármacos e metabolitos endógenos (bilirrubina, morfina, paracetamol, AINEs). É expressa sobretudo no fígado.',
   E'Enzyme of the UDP-glucuronosyltransferase complex (family 1A) that catalyses glucuronidation of drugs and endogenous metabolites (bilirubin, morphine, paracetamol, NSAIDs). It is mainly expressed in the liver.',
   E'A inibição da UGT1A1 (ex.: valproato, fluconazol) pode aumentar a toxicidade de fármacos metabolizados por glucuronidação; a deficiência genética (síndrome de Gilbert) afecta a eliminação de irinotecano e bilirrubina.',
   E'UGT1A1 inhibition (e.g. valproate, fluconazole) may increase toxicity of drugs metabolised by glucuronidation; genetic deficiency (Gilbert syndrome) affects irinotecan and bilirubin elimination.',
   E'Substratos: morfina (→ morfina-6-glucurónido), paracetamol (via glucuronidação), bilirrubina, paradecam, AINEs (ibuprofeno, diclofenac).',
   E'Substrates: morphine (→ morphine-6-glucuronide), paracetamol (via glucuronidation), bilirubin, paradecam, NSAIDs (ibuprofen, diclofenac).',
   E'Inibidores: valproato, fluconazol, fluoxetina, probenecida, ácido valproico.',
   E'Inhibitors: valproate, fluconazole, fluoxetine, probenecid, valproic acid.',
   E'Indutores: rifampicina, carbamazepina, fenitoína (indução do UGT1A1 via PXR/CAR).',
   E'Inducers: rifampicin, carbamazepine, phenytoin (UGT1A1 induction via PXR/CAR).',
   E'A deficiência de UGT1A1 (Gilbert) é comum (5-10% da população) e aumenta a toxicidade do irinotecano; o valproato pode elevar as concentrações de morfina por inibição da glucuronidação.',
   E'UGT1A1 deficiency (Gilbert) is common (5-10% of the population) and increases irinotecan toxicity; valproate may raise morphine concentrations by inhibiting glucuronidation.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (morfina, paracetamol, valproato); PubMed (NIH/NLM) — farmacologia UGT1A1',
   E'DailyMed/FDA (NIH/NLM) — approved labels (morphine, paracetamol, valproate); PubMed (NIH/NLM) — UGT1A1 pharmacology', 29),

  -- 10. DPP-4 — enzima dipeptidil peptidase 4
  ('dpp4', 'enzyme', 'DPP-4', 'DPP-4',
   'Dipeptidil peptidase 4',
   'Dipeptidyl peptidase 4',
   ARRAY['DPP-4', 'CD26', 'dipeptidyl-peptidase-4'],
   E'Enzima membranear (CD26) que degrada os péptidos incretinas (GLP-1 e GIP), reduzindo a secreção de insulina estimulada por glucose. É o alvo terapêutico dos gliptinas (sitagliptina, vildagliptina, saxagliptina).',
   E'Membrane enzyme (CD26) that degrades incretin peptides (GLP-1 and GIP), reducing glucose-stimulated insulin secretion. It is the therapeutic target of gliptins (sitagliptine, vildagliptine, saxagliptine).',
   E'Os inibidores da DPP-4 (gliptinas) prolongam a ação das incretinas e aumentam a secreção de insulina; não devem ser associados a insulina ou secretagogos sem ajuste de dose (risco de hipoglicemia).',
   E'DPP-4 inhibitors (gliptins) prolong incretin action and increase insulin secretion; should not be combined with insulin or secretagogues without dose adjustment (hypoglycaemia risk).',
   E'Substratos: GLP-1, GIP (péptidos incretinas endógenos).',
   E'Substrates: GLP-1, GIP (endogenous incretin peptides).',
   E'Inibidores: sitagliptina, vildagliptina, saxagliptina, linagliptina.',
   E'Inhibitors: sitagliptine, vildagliptine, saxagliptine, linagliptine.',
   E'Indutores: não há indutores clinicamente relevantes.',
   E'Inducers: there are no clinically relevant inducers.',
   E'Os gliptinas são bem tolerados; precaução em insuficiência renal (ajuste de dose para sitagliptina, saxagliptina, vildagliptina); a linagliptina não requer ajuste renal.',
   E'Gliptins are well tolerated; caution in renal impairment (dose adjustment for sitagliptine, saxagliptine, vildagliptine); linagliptine does not require renal adjustment.',
   E'DailyMed/FDA (NIH/NLM) — rótulos aprovados (sitagliptina, vildagliptina, saxagliptina); EMC-UK (MHRA) — SmPC',
   E'DailyMed/FDA (NIH/NLM) — approved labels (sitagliptine, vildagliptine, saxagliptine); EMC-UK (MHRA) — SmPC', 30)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 2. Mapeamento fármaco ↔ alvo (drug_target_roles)
-- Derivado dos textos dos alvos e cruzado com os nomes/aliases
-- dos fármacos existentes na BD.
-- Fonte: DailyMed/FDA (NIH/NLM) e EMC-UK (MHRA) — rótulos aprovados.
-- Idempotente (ON CONFLICT DO NOTHING).
-- ============================================================
INSERT INTO public.drug_target_roles (drug_id, target_id, role, source_pt, status)
SELECT d.id, t.id, v.role, v.source_pt, 'published'
FROM (VALUES
  -- OCT2 (SLC22A2)
  ('metformina', 'oct2', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metformina, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('ranitidina', 'oct2', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ranitidina; EMC-UK (MHRA) — SmPC'),
  ('dolutegravir', 'oct2', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dolutegravir, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('cimetidina', 'oct2', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cimetidina; EMC-UK (MHRA) — SmPC'),
  ('cotrimoxazol', 'oct2', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cotrimoxazol (trimetoprim); EMC-UK (MHRA) — SmPC'),

  -- OAT1/OAT3 (SLC22A6/8)
  ('tenofovir', 'oat1b3', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tenofovir, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('aciclovir', 'oat1b3', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('ibuprofeno', 'oat1b3', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ibuprofeno; EMC-UK (MHRA) — SmPC'),
  ('furosemida', 'oat1b3', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Furosemida, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('metotrexato', 'oat1b3', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metotrexato; EMC-UK (MHRA) — SmPC'),
  ('probenecida', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida; EMC-UK (MHRA) — SmPC'),
  ('indometacina', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Indometacina; EMC-UK (MHRA) — SmPC'),
  ('naproxeno', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Naproxeno; EMC-UK (MHRA) — SmPC'),
  ('ketorolaco', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ketorolaco; EMC-UK (MHRA) — SmPC'),
  ('piroxicam', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Piroxicam; EMC-UK (MHRA) — SmPC'),
  ('meloxicam', 'oat1b3', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Meloxicam; EMC-UK (MHRA) — SmPC'),

  -- hERG (KCNH2) — inibidores (causam prolongamento QT)
  ('sotalol', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sotalol, secção 12 Clinical Pharmacology; EMC-UK (MHRA) — SmPC'),
  ('amiodarona', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amiodarona; EMC-UK (MHRA) — SmPC'),
  ('haloperidol', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Haloperidol; EMC-UK (MHRA) — SmPC'),
  ('pimozida', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pimozida; EMC-UK (MHRA) — SmPC'),
  ('eritromicina', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Eritromicina; EMC-UK (MHRA) — SmPC'),
  ('ciprofloxacina', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciprofloxacina; EMC-UK (MHRA) — SmPC'),
  ('fluconazol', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluconazol; EMC-UK (MHRA) — SmPC'),
  ('citalopram', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Citalopram; EMC-UK (MHRA) — SmPC'),
  ('escitalopram', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Escitalopram; EMC-UK (MHRA) — SmPC'),
  ('metadona', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metadona; EMC-UK (MHRA) — SmPC'),
  ('clozapina', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clozapina; EMC-UK (MHRA) — SmPC'),
  ('olanzapina', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Olanzapina; EMC-UK (MHRA) — SmPC'),
  ('quetiapina', 'herg', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Quetiapina; EMC-UK (MHRA) — SmPC'),

  -- SERT (SLC6A4) — substratos e inibidores
  ('fluoxetina', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluoxetina; EMC-UK (MHRA) — SmPC'),
  ('sertralina', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sertralina; EMC-UK (MHRA) — SmPC'),
  ('paroxetina', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Paroxetina; EMC-UK (MHRA) — SmPC'),
  ('citalopram', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Citalopram; EMC-UK (MHRA) — SmPC'),
  ('escitalopram', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Escitalopram; EMC-UK (MHRA) — SmPC'),
  ('venlafaxina', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Venlafaxina; EMC-UK (MHRA) — SmPC'),
  ('duloxetina', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Duloxetina; EMC-UK (MHRA) — SmPC'),
  ('tramadol', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tramadol; EMC-UK (MHRA) — SmPC'),
  ('linezolida', 'sert', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Linezolida; EMC-UK (MHRA) — SmPC'),

  -- DAT (SLC6A3) — inibidores
  ('bupropiona', 'dat', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bupropiona; EMC-UK (MHRA) — SmPC'),

  -- NET (SLC6A2) — substratos e inibidores
  ('venlafaxina', 'net', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Venlafaxina; EMC-UK (MHRA) — SmPC'),
  ('duloxetina', 'net', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Duloxetina; EMC-UK (MHRA) — SmPC'),
  ('mirtazapina', 'net', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Mirtazapina; EMC-UK (MHRA) — SmPC'),
  ('bupropiona', 'net', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bupropiona; EMC-UK (MHRA) — SmPC'),

  -- PXR (NR1I2) — substratos (induzem CYP3A4 via PXR) e inibidores
  ('rifampicina', 'pxr', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rifampicina, secção 12 Clinical Pharmacology; PubMed (NIH/NLM)'),
  ('carbamazepina', 'pxr', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Carbamazepina; EMC-UK (MHRA) — SmPC'),
  ('fenitoina', 'pxr', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fenitoína; EMC-UK (MHRA) — SmPC'),
  ('fenobarbital', 'pxr', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fenobarbital; EMC-UK (MHRA) — SmPC'),
  ('efavirenz', 'pxr', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Efavirenz; EMC-UK (MHRA) — SmPC'),
  ('cetoconazol', 'pxr', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cetoconazol; EMC-UK (MHRA) — SmPC'),
  ('fluconazol', 'pxr', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluconazol; EMC-UK (MHRA) — SmPC'),
  ('ritonavir', 'pxr', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ritonavir; EMC-UK (MHRA) — SmPC'),

  -- PPAR-γ (PPARG) — não há fármacos da BD como substratos/inibidores
  -- (pioglitazona e rosiglitazona não existem na BD)

  -- UGT1A1 — substratos e inibidores
  ('morfina', 'ugt1a1', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Morfina, secção 12 Clinical Pharmacology; PubMed (NIH/NLM)'),
  ('paracetamol', 'ugt1a1', 'substrate', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Paracetamol; PubMed (NIH/NLM)'),
  ('valproato', 'ugt1a1', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Valproato; EMC-UK (MHRA) — SmPC'),
  ('fluconazol', 'ugt1a1', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluconazol; EMC-UK (MHRA) — SmPC'),
  ('fluoxetina', 'ugt1a1', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluoxetina; EMC-UK (MHRA) — SmPC'),
  ('probenecida', 'ugt1a1', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecida; EMC-UK (MHRA) — SmPC'),

  -- DPP-4 — inibidores
  ('sitagliptina', 'dpp4', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sitagliptina; EMC-UK (MHRA) — SmPC'),
  ('vildagliptina', 'dpp4', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Vildagliptina; EMC-UK (MHRA) — SmPC'),
  ('saxagliptina', 'dpp4', 'inhibitor', 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Saxagliptina; EMC-UK (MHRA) — SmPC')
) AS v(drug_slug, target_slug, role, source_pt)
JOIN public.drugs d ON d.slug = v.drug_slug
JOIN public.molecular_targets t ON t.slug = v.target_slug
ON CONFLICT (drug_id, target_id, role) DO NOTHING;

-- =====================================================================
-- FIM — 10 novos alvos (1 transportador renal, 1 transportador renal,
--   1 receptor cardíaco, 3 transportadores monoamina, 1 receptor nuclear,
--   1 receptor nuclear, 1 enzima de glucuronidação, 1 enzima incretina)
--   + ~60 linhas drug_target_roles.
-- Aplicar no Supabase e depois ./revalidar.sh (se o site já o ler).
-- =====================================================================
