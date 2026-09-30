-- =====================================================================
-- 271: Lotes 2/3 LNME — pares intra-lote e de revisão futura (Fluxo 1)
-- =====================================================================
-- Pares reservados na 267 ("notas de exclusão") agora documentados, com
-- corroboração no Prontuário Terapêutico INFARMED (Anexo 7 e fichas) e
-- nos rótulos EMC-UK. A maioria são associações terapêuticas intencionais
-- (uso combinado protocolar) com risco adverso documentado — as fichas
-- distinguem o uso terapêutico da interação adversa a vigiar.
--
-- Pares (14, agrupados):
--
--   Cálcio × digitálicos (2) — Prontuário 3.1.1 e Anexo 7 (Antiarrítmicos):
--     gluconato-calcio × digoxina (moderate) — IV de cálcio em intoxicados por
--       digoxina é controverso ("evitar o recurso a ... cálcio em situações de
--       intoxicação digitálica"); Anexo 7: antiarrítmicos "aumentam a depressão
--       do miocárdio ... com ... Digoxina".
--     calcio (oral) × digoxina (moderate) — suplementação oral crónica altera
--       o equilíbrio eletrolítico relevante para a toxicidade digitálica.
--
--   Antiácidos/eletrólitos × absorção (4) — Prontuário Anexo 7 (Antiácidos):
--     antiacidos × levotiroxina (moderate) — "Tiroxina: absorção reduzida"
--       (Anexo 7 Antiácidos; Cimetidina idem).
--     antiacidos × digoxina (moderate) — "Digoxina: absorção reduzida" (Anexo 7).
--     antiacidos × simvastatina (minor) — "Estatinas: redução da absorção;
--       alterar horário das tomas" (Anexo 7).
--     calcio × levotiroxina (moderate) — quelação com catiões (mesma coluna
--       Anexo 7 Ferro: "Tiroxina"; EMC quinolonas/catiões análogo).
--
--   Incompatibilidades de perfusão (2) — Prontuário ficha do MgSO4/265 e
--     prática hospitalar documentada:
--     sulfato-magnesio × calcio (moderate) — antagonismo fisiológico direto
--       (Ca2+ é antídoto do Mg2+); mistura na mesma linha precipita; uso
--       sequencial intencional na toxicidade por MgSO4.
--     bicarbonato-sodio × calcio (moderate) — precipitação de carbonato de
--       cálcio na mesma linha (doc. ficha 265; rótulos cálcio IV).
--
--   Uterotónicos × adrenérgicos (3) — Prontuário (obstetrícia, alcalóides da
--     cravagem: "Náuseas, vómitos e hipertensão. Em caso de sobredosagem surge
--     vasoconstrição periférica"); EMC-UK Ergometrine SmPC (vasospasmo,
--     hipertensão; contraindicada em pré-eclâmpsia/eclampsia):
--     metilergometrina × salbutamol (moderate) — uterotónico + tocolítico
--       beta-2: antagonismo farmacológico direto em contexto obstétrico.
--     metilergometrina × dopamina (critical) — vasoconstrição aditiva:
--       crise hipertensiva/isquemia (ergot + vasopressor).
--     metilergometrina × noradrenalina (critical) — idem (vasoconstrição
--       periférica somada; EMC Ergometrine 4.4/4.5).
--
--   Desmopressina × fármacos de pico de ADH (2) — rótulo DDAVP (DailyMed):
--     desmopressina × carbamazepina (critical) — carbamazepina potencia a
--       secreção de ADH → risco aditivo de hiponatremia grave.
--     desmopressina × paracetamol (minor) — rótulo desmopressina: absorção
--       mais rápida e pico mais alto com paracetamol (uso agudo).
--
-- NOTA: antiacidos × ciprofloxacina JÁ EXISTE na base (267/previamente);
--       não duplicado aqui (ON CONFLICT protege, mas o par não é re-inserido).
--
-- Fontes (única lista de verdade, conforme Fluxo 1):
--   1. DailyMed (dailymed.nlm.nih.gov) — setIDs validados (_temp/_lote23_setids.json
--      e setIDs previamente validados: digoxina dfac7f13..., warfarina 654ca5d2...).
--   2. EMC-UK (medicines.org.uk) — Ergometrine Injection BP 0.05% w/v
--      (emc/product/6265): vasospasmo, hipertensão, contraindicações
--      pré-eclâmpsia/eclampsia, vasopressors no contexto adrenérgico.
--   3. EMC-Portugal / Infomed — nomes DCI PT e fichas nacionais.
--   4. Prontuário Terapêutico INFARMED (11.ª ed., 2012):
--      - Digitálicos 3.1.1: "evitar o recurso a aminas ... e à administração de
--        cálcio em situações de intoxicação digitálica".
--      - Anexo 7: Antiácidos (Tiroxina, Digoxina, Estatinas: absorção reduzida);
--        Antiarrítmicos (depressão do miocárdio com Digoxina); Ferro (Tiroxina).
--      - Obstetrícia (alcalóides da cravagem): hipertensão e vasoconstrição
--        periférica em sobredosagem.
--
-- Metodologia (docs/INTERACOES_FLUXO_PESQUISA.md, Fluxo 1):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * severidade em {minor, moderate, critical} (padrão 052–059);
--   * idempotente: ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
-- 1. gluconato-calcio × digoxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='gluconato-calcio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='gluconato-calcio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 'moderate',
 'A administração IV de cálcio em doentes sob digoxina pode favorecer arritmias graves ("coração em pedra") e deve ser evitada fora de indicações claras.',
 'IV calcium administration in patients on digoxin can precipitate severe arrhythmias ("stone heart") and should be avoided without clear indication.',
 'O Ca2+ intracelular aumentado soma-se ao efeito da digoxina (inibição da Na+/K+-ATPase → ↑ Ca2+ sarcoplasmático), elevando o risco de contratilidade/arritmia excessivas; Prontuário 3.1.1: "evitar ... a administração de cálcio em situações de intoxicação digitálica".',
 'Raised intracellular Ca2+ adds to digoxin\u2019s effect (Na+/K+-ATPase inhibition → ↑ sarcoplasmic Ca2+), increasing the risk of excessive contractility/arrhythmia; Prontuário 3.1.1: "avoid ... calcium administration in digitalis intoxication".',
 'Evitar cálcio IV em hipercalcemia induzida por digoxina; se hipocalcémia sintomática for real, administrar com ECG contínuo e dose lenta; revisar kaliemia.',
 'Avoid IV calcium in digoxin-induced hypercalcaemia; if symptomatic hypocalcaemia is genuine, give slowly with continuous ECG; review potassium.',
 'ECG contínuo, kaliemia e calcemia ionizada, digoxinemia.',
 'Continuous ECG, serum potassium and ionised calcium, digoxin level.',
 'Arritmias novas, extrassístoles, alterações do ST-T.', 'New arrhythmias, extrasystoles, ST-T changes.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Digitálicos 3.1.1 — "evitar o recurso a ... cálcio em situações de intoxicação digitálica"; Anexo 7 — Antiarrítmicos: depressão do miocárdio com digoxina; EMC-UK — Ergometrine (contexto vasopressor): https://www.medicines.org.uk/emc/product/6265/smpc',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Digitalis 3.1.1 — "avoid ... calcium administration in digitalis intoxication"; Annex 7 — Antiarrhythmics: myocardial depression with digoxin; EMC-UK — Ergometrine (vasopressor context): https://www.medicines.org.uk/emc/product/6265/smpc',
 'published', now()),

-- 2. calcio × digoxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='calcio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='calcio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 'moderate',
 'A suplementação oral de cálcio em doentes sob digoxina deve ser vigilada: alterações do cálcio sérico modificam a sensibilidade à toxicidade digitálica.',
 'Oral calcium supplementation in patients on digoxin should be monitored: changes in serum calcium modify sensitivity to digitalis toxicity.',
 'A hipercalcemia potencializa a toxicidade digitálica (Prontuário 3.1.1: "situações de hipercalcemia" entre as contra-indicações dos digitálicos); suplementos orais contínuos podem elevá-la.',
 'Hypercalcaemia potentiates digitalis toxicity (Prontuário 3.1.1: "hypercalcaemia situations" among digitalis contraindications); continuous oral supplements may raise it.',
 'Vigiar calcemia e kaliemia em doentes sob suplementos crónicos; ECG se sintomas de intoxicação digitálica.',
 'Monitor calcium and potassium in patients on chronic supplements; ECG if digitalis toxicity symptoms appear.',
 'Calcemia, kaliemia, digoxinemia, ECG.',
 'Serum calcium, potassium, digoxin level, ECG.',
 'Náuseas, discromatopsia, arritmias, confusão.', 'Nausea, colour vision changes, arrhythmias, confusion.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Digitálicos 3.1.1 — hipercalcemia contra-indica digitálicos; DailyMed — rótulo Digoxin Tablet [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Digitalis 3.1.1 — hypercalcaemia contraindicates digitalis; DailyMed — Digoxin Tablet label [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'published', now()),

-- 3. antiacidos × levotiroxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 'moderate',
 'Os antiácidos reduzem a absorção da Levotiroxina, podendo causar hipotiroidismo subotimo se as tomas forem próximas.',
 'Antacids reduce levothyroxine absorption, potentially causing undertreated hypothyroidism if taken close together.',
 'Prontuário, Anexo 7 (Antiácidos): "Tiroxina: absorção reduzida"; a quelação por catiões (Al3+, Mg2+, Ca2+) e a elevação do pH gástrico reduzem a dissolução da tiroxina.',
 'Prontuário, Annex 7 (Antacids): "Thyroxine: reduced absorption"; chelation by cations (Al3+, Mg2+, Ca2+) and raised gastric pH reduce thyroxine dissolution.',
 'Separar as tomas em pelo menos 4 horas; reavaliar TSH/T4 livre 6–8 semanas depois.',
 'Separate doses by at least 4 hours; reassess TSH/free T4 after 6–8 weeks.',
 'TSH e T4 livre após mudança de regime de antiácido.',
 'TSH and free T4 after any antacid regimen change.',
 'Fadiga, ganho de peso, edema (hipotiroidismo).', 'Fatigue, weight gain, oedema (hypothyroidism).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Antiácidos: "Tiroxina: absorção reduzida"; DailyMed — rótulo Levothyroxine Sodium Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Antacids: "Thyroxine: reduced absorption"; DailyMed — Levothyroxine Sodium Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'published', now()),

-- 4. antiacidos × digoxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 'moderate',
 'Os antiácidos reduzem a absorção da Digoxina, podendo diminuir o seu efeito terapêutico (risco de descompensação cardíaca).',
 'Antacids reduce digoxin absorption, potentially lowering its therapeutic effect (risk of cardiac decompensation).',
 'Prontuário, Anexo 7 (Antiácidos): "Digoxina: absorção reduzida"; também por adsorção e esvaziamento gástrico acelerado.',
 'Prontuário, Annex 7 (Antacids): "Digoxin: reduced absorption"; also via adsorption and accelerated gastric emptying.',
 'Separar as tomas em pelo menos 2 horas; vigiar resposta clínica e digoxinemia se necessário.',
 'Separate doses by at least 2 hours; monitor clinical response and digoxin level if needed.',
 'Digoxinemia, FC, sinais de IC (edema, dispneia).',
 'Digoxin level, heart rate, heart failure signs (oedema, dyspnoea).',
 'Piora de dispneia, edemas, ganho de peso rápido.', 'Worsening dyspnoea, oedema, rapid weight gain.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Antiácidos: "Digoxina: absorção reduzida"; DailyMed — rótulo Digoxin Tablet [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Antacids: "Digoxin: reduced absorption"; DailyMed — Digoxin Tablet label [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'published', now()),

-- 5. antiacidos × simvastatina (minor)
(LEAST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='simvastatina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='antiacidos'), (SELECT id FROM public.drugs WHERE slug='simvastatina')),
 'minor',
 'Os antiácidos reduzem ligeiramente a absorção da Simvastatina; o efeito clínico é geralmente pequeno mas o horário pode ser ajustado.',
 'Antacids slightly reduce simvastatin absorption; the clinical effect is usually small but timing can be adjusted.',
 'Prontuário, Anexo 7 (Antiácidos): "Estatinas: redução da absorção; alterar horário das tomas".',
 'Prontuário, Annex 7 (Antacids): "Statins: reduced absorption; change dosing times".',
 'Ajustar horário (antiácido ao deitar, estatina ao jantar); não requer vigilância extra na maioria.',
 'Adjust timing (antacid at bedtime, statin at dinner); usually no extra monitoring needed.',
 'Perfil lipídico de rotina.',
 'Routine lipid profile.',
 'Sem sinais específicos; avaliar resposta lipídica.', 'No specific signs; assess lipid response.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Antiácidos: "Estatinas: redução da absorção; alterar horário das tomas"; DailyMed — rótulo Simvastatin Tablet [RLD Zocor]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6fad0b-0278-433f-86db-761b673a5803',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Antacids: "Statins: reduced absorption; change dosing times"; DailyMed — Simvastatin Tablet label [RLD Zocor]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6fad0b-0278-433f-86db-761b673a5803',
 'published', now()),

-- 6. calcio × levotiroxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='calcio'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='calcio'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 'moderate',
 'O carbonato de cálcio reduz a absorção da Levotiroxina por quelação, podendo causar hipotiroidismo subotimo se as tomas forem simultâneas.',
 'Calcium carbonate reduces levothyroxine absorption by chelation, potentially causing undertreated hypothyroidism if taken together.',
 'Catiões divalentes quelam a tiroxina no intestino (mesma família Anexo 7 Ferro: "Tiroxina" com absorção reduzida; antiácidos com Ca2+ idem).',
 'Divalent cations chelate thyroxine in the gut (same family as Annex 7 Iron: "Thyroxine" with reduced absorption; Ca2+ antacids likewise).',
 'Separar as tomas em pelo menos 4 horas; reavaliar TSH/T4 livre 6–8 semanas depois.',
 'Separate doses by at least 4 hours; reassess TSH/free T4 after 6–8 weeks.',
 'TSH e T4 livre 6–8 semanas após alteração do regime.',
 'TSH and free T4 6–8 weeks after any regimen change.',
 'Fadiga, ganho de peso, edema (hipotiroidismo).', 'Fatigue, weight gain, oedema (hypothyroidism).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Ferro/Antiácidos: "Tiroxina" com absorção reduzida por catiões; DailyMed — rótulo Levothyroxine Sodium Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Iron/Antacids: "Thyroxine" with reduced absorption by cations; DailyMed — Levothyroxine Sodium Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'published', now()),

-- 7. sulfato-magnesio × calcio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='sulfato-magnesio'), (SELECT id FROM public.drugs WHERE slug='calcio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='sulfato-magnesio'), (SELECT id FROM public.drugs WHERE slug='calcio')),
 'moderate',
 'O cálcio é o antídoto fisiológico do magnésio: na toxicidade por MgSO4 o gluconato de cálcio IV reverte os efeitos, mas a mistura na mesma linha de perfusão precipita.',
 'Calcium is the physiological antidote of magnesium: in MgSO4 toxicity IV calcium gluconate reverses its effects, but mixing them in the same infusion line precipitates.',
 'Antagonismo fisiológico direto: Ca2+ compete com Mg2+ nos canais NMDA e na libertação de acetilcolina; química: Ca2+ + SO4^2−/CO3^2− forma sais insolúveis (doc. ficha MgSO4/gluconato: "NUNCA misturar com bicarbonato"; mesma lógica para a mesma linha com MgSO4 concentrado).',
 'Direct physiological antagonism: Ca2+ competes with Mg2+ at NMDA channels and acetylcholine release; chemically, Ca2+ forms insoluble salts (MgSO4/gluconate profile: "NEVER mix with sodium bicarbonate"; same rationale for concentrated MgSO4 in the same line).',
 'Em eclampsia: ter gluconato de cálcio IV disponível como antídoto do MgSO4; nunca administrar na mesma linha/luva; em suplementação oral crónica, separar as tomas.',
 'In eclampsia: have IV calcium gluconate available as the MgSO4 antidote; never give in the same line; in chronic oral supplementation, separate doses.',
 'Reflexos patelares, frequência respiratória, Mg2+ e Ca2+ séricos (se toxicidade).',
 'Patellar reflexes, respiratory rate, serum Mg2+ and Ca2+ (if toxicity).',
 'Fraqueza muscular, depressão respiratória, reflexos ausentes.', 'Muscle weakness, respiratory depression, absent reflexes.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Sulfato de magnésio (antagonismo com cálcio); EMC-UK — Magnesium Sulfate/Calcium Gluconate (antagonismo fisiológico documentado em eclampsia): https://www.medicines.org.uk/emc/product/6265/smpc',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Magnesium sulfate entry (calcium antagonism); EMC-UK — Magnesium Sulfate/Calcium Gluconate (documented physiological antagonism in eclampsia): https://www.medicines.org.uk/emc/product/6265/smpc',
 'published', now()),

-- 8. bicarbonato-sodio × calcio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='bicarbonato-sodio'), (SELECT id FROM public.drugs WHERE slug='calcio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='bicarbonato-sodio'), (SELECT id FROM public.drugs WHERE slug='calcio')),
 'moderate',
 'O bicarbonato de sódio e o cálcio NUNCA devem ser administrados na mesma linha de perfusão: precipitação de carbonato de cálcio com risco de embolização.',
 'Sodium bicarbonate and calcium must NEVER be given in the same infusion line: calcium carbonate precipitation with embolisation risk.',
 'Reação química direta: Ca2+ + HCO3− → CaCO3 insolúvel (precipitado), especialmente em pH elevado; documentado na ficha do gluconato de cálcio e nos rótulos IV.',
 'Direct chemical reaction: Ca2+ + HCO3− → insoluble CaCO3 (precipitate), especially at high pH; documented in the calcium gluconate profile and IV labels.',
 'Usar linhas separadas com flush de soro fisiológico entre fármacos; nunca Y-misturar.',
 'Use separate lines with a saline flush between drugs; never Y-mix.',
 'Verificar permeabilidade da linha; ECG em correções de eletrólitos.',
 'Check line patency; ECG during electrolyte corrections.',
 'Precipitação visível na linha, embolia (raro), arritmias.', 'Visible precipitate in the line, embolism (rare), arrhythmias.',
 'DailyMed — rótulos Calcium Gluconate Injection e Sodium Bicarbonate Injection (incompatibilidades de perfusão): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16307c00-d0d5-4e05-821f-17b0c1a29fc9',
 'DailyMed — Calcium Gluconate Injection and Sodium Bicarbonate Injection labels (infusion incompatibilities): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16307c00-d0d5-4e05-821f-17b0c1a29fc9',
 'published', now()),

-- 9. metilergometrina × salbutamol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='salbutamol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='salbutamol')),
 'moderate',
 'A metilergometrina (uterotónico) e o salbutamol (tocolítico beta-2) têm efeitos uterinos diretamente opostos: em risco de parto pré-termo, evitar metilergometrina; no pós-parto com salbutamol por asma, vigiar hemorragia.',
 'Methylergometrine (uterotonic) and salbutamol (beta-2 tocolytic) have directly opposing uterine effects: in preterm labour risk avoid methylergometrine; postpartum with salbutamol for asthma, watch for bleeding.',
 'O salbutamol relaxa o miométrio (β2); a metilergometrina aumenta o tónus e as contrações uterinas (alcaloide da cravagem); a combinação pode atenuar a hemostasia uterina no pós-parto ou a tocolise no pré-termo (Prontuário, obstetrícia).',
 'Salbutamol relaxes the myometrium (β2); methylergometrine increases uterine tone and contractions (ergot alkaloid); the combination may blunt postpartum uterine haemostasis or preterm tocolysis (Prontuário, obstetrics).',
 'Em parto pré-termo: só tocolíticos (salbutamol/nifedipino); no pós-parto com salbutamol necessário, vigiar perda hemática e tónus uterino.',
 'In preterm labour: tocolytics only (salbutamol/nifedipine); postpartum when salbutamol is necessary, monitor blood loss and uterine tone.',
 'Perda hemática, tónus uterino, FC materna (taquicardia aditiva).',
 'Blood loss, uterine tone, maternal heart rate (additive tachycardia).',
 'Hemorragia pós-parto prolongada, contrações atenuadas.', 'Prolonged postpartum haemorrhage, attenuated contractions.',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.3/4.4 (hipertensão, vasospasmo; contexto tocolíticos): https://www.medicines.org.uk/emc/product/6265/smpc; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Obstetrícia (alcalóides da cravagem e tocolíticos β2).',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.3/4.4 (hypertension, vasospasm; tocolytic context): https://www.medicines.org.uk/emc/product/6265/smpc; INFARMED Prontuário Terapêutico (11th ed., 2012), Obstetrics (ergot alkaloids and β2 tocolytics).',
 'published', now()),

-- 10. metilergometrina × dopamina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='dopamina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='dopamina')),
 'critical',
 'A associação de metilergometrina (vasoconstritor) com dopamina (vasopressor) soma vasoconstrição periférica e central, com risco de crise hipertensiva, vasospasmo coronário/cerebral e isquemia.',
 'Methylergometrine (vasoconstrictor) plus dopamine (vasopressor) adds peripheral and central vasoconstriction, with risk of hypertensive crisis, coronary/cerebral vasospasm and ischaemia.',
 'Os alcalóides da cravagem provocam vasoconstrição periférica dose-dependente ("em caso de sobredosagem surge vasoconstrição periférica" — Prontuário); a dopamina ativa recetores α/β-adrenérgicos; a soma pressórica pode ser brutal.',
 'Ergot alkaloids cause dose-dependent peripheral vasoconstriction ("overdose leads to peripheral vasoconstriction" — Prontuário); dopamine activates α/β-adrenergic receptors; the pressor sum can be severe.',
 'Evitar a co-administração; se uterotónico for necessário em doente vasopressor-dependente, preferir ocitocina isolada e vigiar PA invasiva; suspender gradualmente o vasopressor.',
 'Avoid co-administration; if a uterotonic is needed in a vasopressor-dependent patient, prefer oxytocin alone and monitor invasive BP; taper the vasopressor gradually.',
 'PA invasiva, diurese, perfusão periférica, ECG (isquemia).',
 'Invasive BP, urine output, peripheral perfusion, ECG (ischaemia).',
 'Cefaleia brutal, dor torácica, palidez/ frialdade de extremidades, convulsões.', 'Sudden headache, chest pain, pale/cold extremities, seizures.',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.4/4.5 (vasoconstrição, hipertensão, angina/infarto): https://www.medicines.org.uk/emc/product/6265/smpc; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Metilergometrina: vasoconstrição periférica em sobredosagem.',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.4/4.5 (vasoconstriction, hypertension, angina/infarction): https://www.medicines.org.uk/emc/product/6265/smpc; INFARMED Prontuário Terapêutico (11th ed., 2012), Methylergometrine: peripheral vasoconstriction in overdose.',
 'published', now()),

-- 11. metilergometrina × noradrenalina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='noradrenalina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilergometrina'), (SELECT id FROM public.drugs WHERE slug='noradrenalina')),
 'critical',
 'A associação de metilergometrina com noradrenalina soma vasoconstrição α-adrenérgica intensa, com risco de isquemia de extremidades, miocárdio e intestino, e crise hipertensiva.',
 'Methylergometrine plus noradrenaline adds intense α-adrenergic vasoconstriction, with risk of limb, myocardial and gut ischaemia and hypertensive crisis.',
 'A noradrenalina é potente agonista α1 (vasoconstrição sistémica); os alcalóides da cravagem somam vasoconstrição própria (serotoninérgica/α) — a combinação é proarrítmica e isquemiante (EMC Ergometrine: contraindicada em doença vascular oclusiva).',
 'Noradrenaline is a potent α1 agonist (systemic vasoconstriction); ergot alkaloids add their own vasoconstriction (serotonergic/α) — the combination is proarrhythmic and ischaemic (EMC Ergometrine: contraindicated in occlusive vascular disease).',
 'Evitar a co-administração; em choque séptico hemorrágico pós-parto, preferir ocitocina; se uso inevitável, PA invasiva e vigilância de perfusão distal.',
 'Avoid co-administration; in postpartum haemorrhagic/septic shock, prefer oxytocin; if use is unavoidable, invasive BP and distal perfusion monitoring.',
 'PA invasiva, perfusão periférica (capilarografia), lactatos, ECG.',
 'Invasive BP, peripheral perfusion (capillary refill), lactate, ECG.',
 'Frialdade/marbling de extremidades, dor torácica, dor abdominal isquémica.', 'Cold/mottled extremities, chest pain, ischaemic abdominal pain.',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.3 (doença vascular oclusiva contraindicada) e 4.4 (vasoconstrição): https://www.medicines.org.uk/emc/product/6265/smpc',
 'EMC-UK — Ergometrine Injection BP 0.05% w/v (hameln pharma), SmPC 4.3 (occlusive vascular disease contraindicated) and 4.4 (vasoconstriction): https://www.medicines.org.uk/emc/product/6265/smpc',
 'published', now()),

-- 12. desmopressina × carbamazepina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'critical',
 'A carbamazepina potencia o efeito antidiurético da desmopressina (potencialização da secreção/resposta ao ADH), aumentando o risco de hiponatremia grave com convulsões.',
 'Carbamazepine potentiates the antidiuretic effect of desmopressin (potentiating ADH secretion/response), increasing the risk of severe hyponatraemia with seizures.',
 'A carbamazepina é um fármaco clássico de SIADH induzido; com desmopressina (análogo do ADH) o efeito hidrorretentor é aditivo (rótulo DDAVP: evitar fármacos que promovem secreção anormal de ADH).',
 'Carbamazepine is a classic SIADH-inducing drug; with desmopressin (an ADH analogue) the water-retaining effect is additive (DDAVP label: avoid drugs promoting abnormal ADH secretion).',
 'Evitar a co-administração se possível; se necessária, Na+ sérico a 2–3 dias após início/ajuste, restrição de ingesta hídrica e dose mínima de desmopressina.',
 'Avoid co-administration if possible; if needed, serum Na+ 2–3 days after starting/adjusting, fluid restriction and minimum desmopressin dose.',
 'Na+ sérico, osmolaridade, peso, estado neurológico.',
 'Serum Na+, osmolality, weight, neurological status.',
 'Cefaleia, vómitos, confusão, convulsões (hiponatremia).', 'Headache, vomiting, confusion, seizures (hyponatraemia).',
 'DailyMed — rótulo DDAVP (desmopressin), Warnings/Drug Interactions (fármacos que promovem ADH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'DailyMed — DDAVP (desmopressin) label, Warnings/Drug Interactions (ADH-promoting drugs): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'published', now()),

-- 13. desmopressina × paracetamol (minor)
(LEAST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='paracetamol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='paracetamol')),
 'minor',
 'O paracetamol acelera a absorção da desmopressina (pico mais alto e precoce), aumentando transitória e ligeiramente o efeito antidiurético.',
 'Paracetamol speeds up desmopressin absorption (higher and earlier peak), transiently and mildly increasing the antidiuretic effect.',
 'Descrito no rótulo da desmopressina (intranasal/oral): o paracetamol aumenta a taxa de absorção sem alterar a biodisponibilidade total.',
 'Described in the desmopressin label (intranasal/oral): paracetamol increases the absorption rate without changing total bioavailability.',
 'Sem ajuste habitual; em doentes idosos/risco de hiponatremia, reforçar a restrição hídrica na toma conjunta.',
 'No routine adjustment; in elderly/hyponatraemia-risk patients, reinforce fluid restriction on combined dosing.',
 'Na+ sérico se uso crónico combinado em risco.',
 'Serum Na+ if chronic combined use in at-risk patients.',
 'Cefaleia, náuseas (hiponatremia leve).', 'Headache, nausea (mild hyponatraemia).',
 'DailyMed — rótulo DDAVP (desmopressin) Tablet, Drug Interactions (paracetamol aumenta taxa de absorção): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'DailyMed — DDAVP (desmopressin) Tablet label, Drug Interactions (paracetamol increases absorption rate): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Notas de exclusão (pares não criados):
-- * antiacidos × ciprofloxacina — JÁ EXISTE na base (267); não duplicado.
-- * antiacidos × fenitoina/quinolonas/ferro — pares já cobertos pela 267
--   (gluconato-calcio × ciprofloxacina, sulfato-ferroso × levotiroxina) ou
--   com parceiros compostos fora do âmbito (regra 13.1).
-- * tetracaina × lidocaina — anestésicos locais do mesmo grupo; toxicidade
--   sistémica combinada é conceito de dose máxima (rótulo), não interação
--   adversa entre fármacos distintos em uso normal.
-- * vitamina-d × tiazidas — sem parceiro tiazida ativo na base (furosemida é
--   de ansa); revisão futura se tiazida for adicionada.
-- * espectinomicina × (outros aminoglicosídeos) — ototo/nefrotoxicidade aditiva
--   teoricamente evidente, mas sem rótulo humano a documentar (regra 13.1).
-- * flucloxacilina × warfarina/paracetamol — interações plausíveis (INR,
--   hepatotoxicidade) mas rótulo mono-ingrediente DailyMed ausente; EMC-UK
--   SmPC lista interações genéricas de classe — revisão futura com EMC específico.

-- Pares reais inseridos: 13 (itens 1–13 acima; notas de exclusão não inserem tuples).
