-- =====================================================================
-- 183: Fluxo 4 — Explicações profissionais dos 34 pares restantes da 178
--      (QUADRO 2, Anexo 7 do Prontuário)
-- Preenche a camada editorial (summary_pro_pt/en + explanation_pt/en)
-- dos 34 pares 'moderate' criados na 178 que ficaram sem explicação
-- (a 180 cobriu apenas os 10 'critical').
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica,
--     grupos de risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nas MESMAS âncoras citadas na 178
--     (Prontuário Terapêutico do INFARMED, 11.ª ed., 2012 — Anexo 7,
--     QUADRO 2), lidas da própria BD antes da geração.
--
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug —
-- reaplicar é seguro. Aplicar na ordem 173 → 178 → 183 (depende dos
-- pares da 178).
-- =====================================================================

-- warfarina × cimetidina [moderate] — Anexo 7, QUADRO 2 (Cimetidina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Warfarina + cimetidina: a cimetidina inibe o metabolismo da varfarina e aumenta o INR — risco hemorrágico; monitorizar INR ao iniciar, ajustar ou suspender a cimetidina.',
  summary_pro_en = E'Warfarin + cimetidine: cimetidine inhibits warfarin metabolism and increases INR — bleeding risk; monitor INR when starting, adjusting or stopping cimetidine.',
  explanation_pt = E'A cimetidina é um inibidor não seletivo do CYP450 (incluindo CYP2C9, a principal enzima que metaboliza o S-varfarina ativo), pelo que reduz a depuração da varfarina e eleva o INR de forma clinicamente relevante. O QUADRO 2 do Anexo 7 regista a cimetidina entre os fármacos que aumentam o efeito dos anticoagulantes orais. O efeito é dose-dependente e costuma surgir nos primeiros dias após iniciar a cimetidina. Os doentes com INR previamente estável são os mais expostos a hemorragia, sobretudo idosos e polimedicados. Se for necessário um anti-H2, preferir famotidina ou um inibidor da bomba de protões (sem interação relevante com o CYP2C9); se a cimetidina for mantida, reforçar a monitorização do INR e ajustar a dose da varfarina.',
  explanation_en = E'Cimetidine is a non-selective CYP450 inhibitor (including CYP2C9, the main enzyme metabolising active S-warfarin), so it reduces warfarin clearance and raises INR in a clinically relevant way. QUADRO 2 of Annex 7 lists cimetidine among the drugs that increase the effect of oral anticoagulants. The effect is dose-dependent and usually appears within the first days of starting cimetidine. Patients with previously stable INR are the most exposed to bleeding, especially the elderly and those on multiple drugs. If an H2 blocker is needed, prefer famotidine or a proton pump inhibitor (no relevant CYP2C9 interaction); if cimetidine is kept, intensify INR monitoring and adjust the warfarin dose.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Cimetidina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Cimetidine)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'),
                        (SELECT id FROM public.drugs WHERE slug = 'cimetidina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'),
                           (SELECT id FROM public.drugs WHERE slug = 'cimetidina'));

-- levotiroxina × warfarina [moderate] — Anexo 7, QUADRO 2 (Anticoagulantes orais)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Levotiroxina + varfarina: alterações da função tiroideia modificam o efeito da varfarina — o hipotiroidismo aumenta e o hipertiroidismo diminui a resposta; monitorizar INR.',
  summary_pro_en = E'Levothyroxine + warfarin: changes in thyroid status alter warfarin effect — hypothyroidism increases and hyperthyroidism decreases the response; monitor INR.',
  explanation_pt = E'A função tiroideia influencia diretamente o turnover dos fatores de coagulação dependentes da vitamina K: no hipotiroidismo a degradação dos fatores é mais lenta, o que intensifica o efeito da varfarina; no hipertiroidismo ocorre o contrário. O QUADRO 2 do Anexo 7 regista esta interação na secção dos anticoagulantes orais. Na prática, ao iniciar ou ajustar a levotiroxina, a resposta à varfarina pode variar ao longo de semanas, acompanhando a normalização dos níveis de TSH. O risco é maior nos doentes com doses de varfarina estabilizadas que iniciam substituição tiroideia. Monitorizar o INR semanalmente durante o ajuste da levotiroxina e após atingir o eutiroidismo; alertar o doente para sinais de hemorragia ou trombose.',
  explanation_en = E'Thyroid status directly influences the turnover of vitamin K-dependent clotting factors: in hypothyroidism factor degradation is slower, intensifying warfarin effect; in hyperthyroidism the opposite occurs. QUADRO 2 of Annex 7 records this interaction in the oral anticoagulants section. In practice, when starting or adjusting levothyroxine, the warfarin response may vary over weeks, tracking the normalisation of TSH levels. The risk is greatest in patients with stabilised warfarin doses who start thyroid replacement. Monitor INR weekly during levothyroxine adjustment and after reaching euthyroidism; warn the patient of bleeding or thrombotic signs.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Oral anticoagulants)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- dabigatrano × amiodarona [moderate] — Anexo 7, QUADRO 2 (Anticoagulantes orais)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Dabigatrano + amiodarona: a amiodarona inibe a glicoproteína-P e aumenta a exposição ao dabigatrano — risco hemorrágico; considerar redução da dose e vigilância.',
  summary_pro_en = E'Dabigatran + amiodarone: amiodarone inhibits P-glycoprotein and increases dabigatran exposure — bleeding risk; consider dose reduction and surveillance.',
  explanation_pt = E'O dabigatrano etexilato é substrato da glicoproteína-P (P-gp) e a amiodarona é um inibidor da P-gp, aumentando a biodisponibilidade e as concentrações plasmáticas do dabigatrano. O QUADRO 2 do Anexo 7 regista esta associação entre os anticoagulantes orais com risco hemorrágico aumentado. O incremento da exposição é clinicamente relevante (na ordem de 12-60% conforme o estudo), sobretudo em idosos, baixo peso ou insuficiência renal, onde o dabigatrano já acumula por via renal. Em doentes com clearance de creatinina entre 30-50 ml/min, considerar reduzir a dose de dabigatrano para 110 mg duas vezes/dia quando associado a amiodarona. Vigiar sinais de hemorragia e reavaliar a função renal periodicamente.',
  explanation_en = E'Dabigatran etexilate is a P-glycoprotein (P-gp) substrate and amiodarone is a P-gp inhibitor, increasing dabigatran bioavailability and plasma concentrations. QUADRO 2 of Annex 7 records this combination among oral anticoagulants with increased bleeding risk. The exposure increase is clinically relevant (in the range of 12-60% depending on the study), especially in the elderly, low body weight or renal impairment, where dabigatran already accumulates renally. In patients with creatinine clearance 30-50 ml/min, consider reducing dabigatran to 110 mg twice daily when combined with amiodarone. Watch for bleeding signs and reassess renal function periodically.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Oral anticoagulants)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'),
                        (SELECT id FROM public.drugs WHERE slug = 'amiodarona'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'),
                           (SELECT id FROM public.drugs WHERE slug = 'amiodarona'));

-- rivaroxabano × diclofenac [moderate] — Anexo 7, QUADRO 2 (Anticoagulantes orais)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Rivaroxabano + diclofenac: efeito antiagregante/anti-inflamatório dos AINE adicionado à anticoagulação — risco hemorrágico gastrointestinal; evitar uso prolongado.',
  summary_pro_en = E'Rivaroxaban + diclofenac: antiplatelet/anti-inflammatory effect of NSAIDs added to anticoagulation — GI bleeding risk; avoid prolonged use.',
  explanation_pt = E'Os AINE, como o diclofenac, inibem a cicloxigenase e reduzem a agregação plaquetária, além de lesarem a mucosa gastrointestinal; o rivaroxabano antagoniza a via do fator Xa. O efeito na hemostase e na mucosa é aditivo, aumentando o risco de hemorragia, sobretudo digestiva alta. O QUADRO 2 do Anexo 7 regista esta associação na secção dos anticoagulantes orais. O risco é maior com doses elevadas, uso prolongado, idade avançada, história de úlcera péptica ou uso concomitante de antiagregantes. Preferir paracetamol ou AINE de curta duração à menor dose eficaz; se o AINE for inevitável, considerar proteção gástrica e vigilância de hemorragia oculta.',
  explanation_en = E'NSAIDs such as diclofenac inhibit cyclo-oxygenase and reduce platelet aggregation, and also damage the GI mucosa; rivaroxaban antagonises factor Xa. The effect on haemostasis and mucosa is additive, increasing the bleeding risk, particularly upper GI bleeding. QUADRO 2 of Annex 7 records this combination in the oral anticoagulants section. The risk is higher with high doses, prolonged use, advanced age, history of peptic ulcer or concomitant antiplatelet therapy. Prefer paracetamol or a short-course NSAID at the lowest effective dose; if an NSAID is unavoidable, consider gastric protection and surveillance for occult bleeding.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Oral anticoagulants)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'),
                        (SELECT id FROM public.drugs WHERE slug = 'diclofenac'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'),
                           (SELECT id FROM public.drugs WHERE slug = 'diclofenac'));

-- claritromicina × digoxina [moderate] — Anexo 7, QUADRO 2 (Digoxina; Macrólidos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Claritromicina + digoxina: inibição da P-gp pela claritromicina — toxicidade digitálica (náuseas, arritmias); reduzir dose e monitorizar.',
  summary_pro_en = E'Clarithromycin + digoxin: P-gp inhibition by clarithromycin — digitalis toxicity (nausea, arrhythmias); reduce dose and monitor.',
  explanation_pt = E'A digoxina é eliminada maioritariamente por excreção tubular renal mediada pela glicoproteína-P; a claritromicina (e outros macrólidos) inibem a P-gp e podem duplicar as concentrações de digoxina em poucos dias. O QUADRO 2 do Anexo 7 regista esta interação nas secções da digoxina e dos macrólidos. A toxicidade digitálica manifesta-se por náuseas, vómitos, anorexia, diarreia, bradicardia, bloqueio AV e arritmias ventriculares, sobretudo em idosos, hipocaliemia, hipomagnesemia ou insuficiência renal. Durante o tratamento com claritromicina, considerar reduzir a dose de digoxina para metade e monitorizar o ECG e a digoxinemia; preferir azitromicina quando o macrólido for necessário.',
  explanation_en = E'Digoxin is mostly eliminated by P-glycoprotein-mediated renal tubular secretion; clarithromycin (and other macrolides) inhibit P-gp and can double digoxin concentrations within days. QUADRO 2 of Annex 7 records this interaction in the digoxin and macrolide sections. Digitalis toxicity presents with nausea, vomiting, anorexia, diarrhoea, bradycardia, AV block and ventricular arrhythmias, especially in the elderly, hypokalaemia, hypomagnesaemia or renal impairment. During clarithromycin treatment, consider halving the digoxin dose and monitor ECG and digoxin levels; prefer azithromycin when a macrolide is needed.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Digoxina; Macrólidos)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Digoxin; Macrolides)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'),
                        (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'),
                           (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- espironolactona × digoxina [moderate] — Anexo 7, QUADRO 2 (Digoxina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Espironolactona + digoxina: a espironolactona reduz a secreção tubular de digoxina e interfere nos imunoensaios — risco de toxicidade digitálica; monitorizar.',
  summary_pro_en = E'Spironolactone + digoxin: spironolactone reduces tubular secretion of digoxin and interferes with immunoassays — risk of digitalis toxicity; monitor.',
  explanation_pt = E'A espironolactona compete com a digoxina pela secreção tubular renal (P-gp) e pode aumentar as concentrações plasmáticas de digoxina; além disso, pode interferir com alguns imunoensaios de digoxinemia, sobrestimando o resultado. O QUADRO 2 do Anexo 7 regista esta interação na secção da digoxina. A relevância clínica é maior com doses altas de espironolactona e em doentes com função renal reduzida. Monitorizar sinais de toxicidade digitálica (náuseas, bradicardia, arritmias), a função renal e o potássio — a hipocaliemia e a hipercaliemia ambas potenciam arritmias com digoxina. Considerar ajustar a dose de digoxina e usar o mesmo laboratório para seguimento da digoxinemia.',
  explanation_en = E'Spironolactone competes with digoxin for renal tubular secretion (P-gp) and may increase digoxin plasma concentrations; it may also interfere with some digoxin immunoassays, overestimating the result. QUADRO 2 of Annex 7 records this interaction in the digoxin section. Clinical relevance is greater with high spironolactone doses and in patients with reduced renal function. Monitor signs of digitalis toxicity (nausea, bradycardia, arrhythmias), renal function and potassium — both hypo- and hyperkalaemia potentiate digoxin arrhythmias. Consider adjusting the digoxin dose and use the same laboratory for digoxin level follow-up.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Digoxina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Digoxin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'),
                        (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'),
                           (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- colchicina × digoxina [moderate] — Anexo 7, QUADRO 2 (Digoxina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Colchicina + digoxina: inibição da P-gp e efeito aditivo na condução cardíaca — risco de toxicidade digitálica; monitorizar e reduzir dose se necessário.',
  summary_pro_en = E'Colchicine + digoxin: P-gp inhibition and additive effect on cardiac conduction — risk of digitalis toxicity; monitor and reduce dose if needed.',
  explanation_pt = E'A colchicina é substrato e inibidor da glicoproteína-P, podendo aumentar as concentrações de digoxina; ambos os fármacos também têm efeitos aditivos na condução cardíaca e no trato gastrointestinal. O QUADRO 2 do Anexo 7 regista esta interação na secção da digoxina. Os sinais de toxicidade incluem náuseas, diarreia, bradicardia e bloqueios de condução; a diarreia induzida pela colchicina pode ainda causar hipocaliemia, potenciando as arritmias digitálicas. O risco é maior em idosos, insuficiência renal ou hepática. Durante o uso concomitante, monitorizar a digoxinemia e o ECG, e reduzir a dose de digoxina se surgirem sintomas; hidratar e vigiar os eletrólitos.',
  explanation_en = E'Colchicine is a P-glycoprotein substrate and inhibitor, potentially increasing digoxin concentrations; both drugs also have additive effects on cardiac conduction and the GI tract. QUADRO 2 of Annex 7 records this interaction in the digoxin section. Toxicity signs include nausea, diarrhoea, bradycardia and conduction blocks; colchicine-induced diarrhoea can also cause hypokalaemia, potentiating digitalis arrhythmias. The risk is higher in the elderly and in renal or hepatic impairment. During concomitant use, monitor digoxin levels and ECG, and reduce the digoxin dose if symptoms appear; keep hydrated and monitor electrolytes.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Digoxina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Digoxin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'colchicina'),
                        (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colchicina'),
                           (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- colestiramina × digoxina [moderate] — Anexo 7, QUADRO 2 (Ácidos biliares — resinas)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Colestiramina + digoxina: adsorção da digoxina no lúmen intestinal — redução da absorção e do efeito; separar a toma 4 horas e monitorizar.',
  summary_pro_en = E'Cholestyramine + digoxin: adsorption of digoxin in the intestinal lumen — reduced absorption and effect; separate dosing by 4 hours and monitor.',
  explanation_pt = E'A colestiramina (resina de troca aniónica) liga-se à digoxina no lúmen intestinal, reduzindo a sua absorção e podendo baixar as concentrações plasmáticas. O QUADRO 2 do Anexo 7 regista esta interação na secção das resinas de ácidos biliares. O efeito é atenuado se as tomas forem separadas: administrar a digoxina pelo menos 4 horas antes ou depois da colestiramina. Na prática, a interação é mais relevante quando a colestiramina é introduzida ou suspensa em doentes estabilizados — a suspensão pode aumentar a absorção de digoxina e precipitar toxicidade. Monitorizar a digoxinemia e o efeito clínico nas semanas após alterações da terapêutica com resinas.',
  explanation_en = E'Cholestyramine (anion-exchange resin) binds digoxin in the intestinal lumen, reducing its absorption and potentially lowering plasma concentrations. QUADRO 2 of Annex 7 records this interaction in the bile-acid resin section. The effect is attenuated if doses are separated: give digoxin at least 4 hours before or after cholestyramine. In practice, the interaction is most relevant when cholestyramine is started or stopped in stabilised patients — stopping may increase digoxin absorption and precipitate toxicity. Monitor digoxin levels and clinical effect in the weeks after resin therapy changes.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ácidos biliares — resinas)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Bile acids — resins)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'colestiramina'),
                        (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colestiramina'),
                           (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- teofilina × verapamilo [moderate] — Anexo 7, QUADRO 2 (Teofilina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Teofilina + verapamilo: o verapamilo inibe o metabolismo da teofilina — risco de toxicidade (náuseas, taquicardia, convulsões); reduzir dose e monitorizar.',
  summary_pro_en = E'Theophylline + verapamil: verapamil inhibits theophylline metabolism — toxicity risk (nausea, tachycardia, seizures); reduce dose and monitor.',
  explanation_pt = E'O verapamilo inibe o CYP1A2, a principal enzima que metaboliza a teofilina, podendo aumentar as concentrações desta em 20-25% ou mais. O QUADRO 2 do Anexo 7 regista a teofilina entre os fármacos com interação com os bloqueadores da entrada de cálcio. A toxicidade da teofilina manifesta-se por náuseas, vómitos, taquicardia, tremores, insónia e, em níveis elevados, convulsões e arritmias. O risco é maior em fumadores que suspendem o tabaco, idosos ou com insuficiência cardíaca. Ao iniciar verapamilo, considerar reduzir a dose de teofilina e monitorizar os níveis séricos e sinais de toxicidade; preferir outros bloqueadores da entrada de cálcio quando possível.',
  explanation_en = E'Verapamil inhibits CYP1A2, the main enzyme metabolising theophylline, potentially increasing theophylline concentrations by 20-25% or more. QUADRO 2 of Annex 7 lists theophylline among drugs interacting with calcium channel blockers. Theophylline toxicity presents with nausea, vomiting, tachycardia, tremors, insomnia and, at high levels, seizures and arrhythmias. The risk is higher in smokers who stop tobacco, the elderly or those with heart failure. When starting verapamil, consider reducing the theophylline dose and monitor serum levels and toxicity signs; prefer other calcium channel blockers when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Teofilina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Theophylline)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                        (SELECT id FROM public.drugs WHERE slug = 'verapamilo'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                           (SELECT id FROM public.drugs WHERE slug = 'verapamilo'));

-- teofilina × fenobarbital [moderate] — Anexo 7, QUADRO 2 (Barbitúricos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Teofilina + fenobarbital: indução enzimática pelo fenobarbital — redução das concentrações de teofilina e do efeito broncodilatador; monitorizar.',
  summary_pro_en = E'Theophylline + phenobarbital: enzyme induction by phenobarbital — reduced theophylline concentrations and bronchodilator effect; monitor.',
  explanation_pt = E'O fenobarbital é um indutor do CYP1A2 e do CYP3A4, acelerando o metabolismo da teofilina e reduzindo as suas concentrações plasmáticas e o efeito broncodilatador. O QUADRO 2 do Anexo 7 regista esta interação na secção dos barbitúricos. A relevância clínica é maior em doentes asmáticos ou com DPOC cujo controlo piora após iniciar fenobarbital, podendo exigir aumento da dose de teofilina. Inversamente, se o fenobarbital for suspenso, os níveis de teofilina sobem e pode surgir toxicidade. Monitorizar a resposta clínica e, se disponível, a teofilinemia; ajustar a dose ao iniciar, ajustar ou suspender o barbitúrico.',
  explanation_en = E'Phenobarbital is a CYP1A2 and CYP3A4 inducer, accelerating theophylline metabolism and reducing its plasma concentrations and bronchodilator effect. QUADRO 2 of Annex 7 records this interaction in the barbiturate section. Clinical relevance is greater in asthmatic or COPD patients whose control worsens after starting phenobarbital, possibly requiring a theophylline dose increase. Conversely, if phenobarbital is stopped, theophylline levels rise and toxicity may appear. Monitor clinical response and, if available, theophylline levels; adjust the dose when starting, adjusting or stopping the barbiturate.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Barbitúricos)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Barbiturates)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'));

-- teofilina × rifampicina [moderate] — Anexo 7, QUADRO 2 (Rifampicina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Teofilina + rifampicina: indução enzimática pela rifampicina — redução acentuada das concentrações de teofilina e do efeito; monitorizar e ajustar dose.',
  summary_pro_en = E'Theophylline + rifampicin: enzyme induction by rifampicin — marked reduction of theophylline concentrations and effect; monitor and adjust dose.',
  explanation_pt = E'A rifampicina é um potente indutor do CYP1A2 e CYP3A4, podendo reduzir as concentrações de teofilina em 30-50% e comprometer o controlo broncodilatador. O QUADRO 2 do Anexo 7 regista esta interação na secção da rifampicina. A diminuição do efeito pode surgir em poucos dias e manter-se durante semanas após suspender a rifampicina. Doentes com asma ou DPOC podem piorar clinicamente e exigir aumento substancial da dose de teofilina; ao suspender a rifampicina, o risco é inverso (toxicidade). Monitorizar a teofilinemia quando disponível e a função respiratória; alertar o doente para o agravamento do broncospasmo.',
  explanation_en = E'Rifampicin is a potent CYP1A2 and CYP3A4 inducer, potentially reducing theophylline concentrations by 30-50% and compromising bronchodilator control. QUADRO 2 of Annex 7 records this interaction in the rifampicin section. The reduced effect may appear within days and persist for weeks after stopping rifampicin. Asthmatic or COPD patients may worsen clinically and require substantial theophylline dose increases; when rifampicin is stopped, the opposite risk (toxicity) applies. Monitor theophylline levels when available and respiratory function; warn the patient about worsening bronchospasm.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Rifampicina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Rifampicin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                        (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'teofilina'),
                           (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- metronidazol × fenitoina [moderate] — Anexo 7, QUADRO 2 (Fenitoína)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Metronidazol + fenitoína: o metronidazol inibe o metabolismo da fenitoína — risco de toxicidade (nistagmo, ataxia); monitorizar níveis e sinais clínicos.',
  summary_pro_en = E'Metronidazole + phenytoin: metronidazole inhibits phenytoin metabolism — toxicity risk (nystagmus, ataxia); monitor levels and clinical signs.',
  explanation_pt = E'O metronidazol inibe o CYP2C9, a enzima que metaboliza a fenitoína, podendo aumentar as suas concentrações plasmáticas e o risco de toxicidade. O QUADRO 2 do Anexo 7 regista esta interação na secção da fenitoína. Os sinais precoces de toxicidade incluem nistagmo, ataxia, disartria, sonolência e, em casos graves, convulsões paradoxais. O risco é maior em doentes com fenitoína em dose próxima do limite, idosos ou com hipoalbuminemia (mais fármaco livre). Monitorizar a fenitoinemia e os sinais neurológicos durante o tratamento com metronidazol; considerar reduzir a dose de fenitoína e usar antibiótico alternativo quando possível.',
  explanation_en = E'Metronidazole inhibits CYP2C9, the enzyme that metabolises phenytoin, potentially increasing its plasma concentrations and the risk of toxicity. QUADRO 2 of Annex 7 records this interaction in the phenytoin section. Early toxicity signs include nystagmus, ataxia, dysarthria, drowsiness and, in severe cases, paradoxical seizures. The risk is higher in patients on near-maximum phenytoin doses, the elderly or those with hypoalbuminaemia (more free drug). Monitor phenytoin levels and neurological signs during metronidazole treatment; consider reducing the phenytoin dose and using an alternative antibiotic when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Fenitoína)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Phenytoin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- fluconazol × fenitoina [moderate] — Anexo 7, QUADRO 2 (Antifúngicos Azol; Fenitoína)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Fluconazol + fenitoína: o fluconazol inibe o CYP2C9 — aumento da fenitoína e risco de toxicidade; monitorizar níveis e ajustar dose.',
  summary_pro_en = E'Fluconazole + phenytoin: fluconazole inhibits CYP2C9 — increased phenytoin and toxicity risk; monitor levels and adjust dose.',
  explanation_pt = E'O fluconazol (e outros azóis) inibe o CYP2C9, reduzindo o metabolismo da fenitoína e aumentando as suas concentrações plasmáticas. O QUADRO 2 do Anexo 7 regista esta interação nas secções dos antifúngicos azol e da fenitoína. A elevação da fenitoína pode ser clinicamente significativa já nos primeiros dias, com nistagmo, ataxia e sedação. O risco é maior com doses elevadas de fluconazol, idosos ou insuficiência hepática. Monitorizar a fenitoinemia e reduzir a dose de fenitoína se necessário; considerar azóis alternativos com menor inibição (ex.: anfotericina) e reforçar a vigilância clínica.',
  explanation_en = E'Fluconazole (and other azoles) inhibits CYP2C9, reducing phenytoin metabolism and increasing its plasma concentrations. QUADRO 2 of Annex 7 records this interaction in the azole antifungal and phenytoin sections. The phenytoin rise can be clinically significant within the first days, with nystagmus, ataxia and sedation. The risk is higher with high fluconazole doses, the elderly or hepatic impairment. Monitor phenytoin levels and reduce the phenytoin dose if needed; consider azoles with less inhibition (e.g. amphotericin) and reinforce clinical surveillance.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Antifúngicos Azol; Fenitoína)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Azole antifungals; Phenytoin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- cloranfenicol × fenitoina [moderate] — Anexo 7, QUADRO 2 (Cloranfenicol; Fenitoína)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Cloranfenicol + fenitoína: o cloranfenicol inibe o metabolismo da fenitoína — risco de toxicidade; monitorizar níveis e sinais neurológicos.',
  summary_pro_en = E'Chloramphenicol + phenytoin: chloramphenicol inhibits phenytoin metabolism — toxicity risk; monitor levels and neurological signs.',
  explanation_pt = E'O cloranfenicol inibe as enzimas microssomais hepáticas (incluindo o CYP2C9) e pode aumentar de forma acentuada as concentrações de fenitoína; inversamente, a fenitoína pode induzir o metabolismo do cloranfenicol, reduzindo a sua eficácia antibiótica. O QUADRO 2 do Anexo 7 regista esta interação nas secções do cloranfenicol e da fenitoína. A toxicidade da fenitoína (nistagmo, ataxia, sonolência) é a consequência mais temida, sobretudo em doentes com doses próximas do limite ou hipoalbuminemia. Monitorizar a fenitoinemia e os sinais clínicos; ajustar a dose de fenitoína ao iniciar ou suspender o cloranfenicol e considerar antibiótico alternativo quando possível.',
  explanation_en = E'Chloramphenicol inhibits hepatic microsomal enzymes (including CYP2C9) and can markedly increase phenytoin concentrations; conversely, phenytoin can induce chloramphenicol metabolism, reducing its antibiotic efficacy. QUADRO 2 of Annex 7 records this interaction in the chloramphenicol and phenytoin sections. Phenytoin toxicity (nystagmus, ataxia, drowsiness) is the most feared consequence, especially in patients on near-maximum doses or with hypoalbuminaemia. Monitor phenytoin levels and clinical signs; adjust the phenytoin dose when starting or stopping chloramphenicol and consider an alternative antibiotic when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Cloranfenicol; Fenitoína)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Chloramphenicol; Phenytoin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloranfenicol'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloranfenicol'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- rifampicina × fenitoina [moderate] — Anexo 7, QUADRO 2 (Fenitoína)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Rifampicina + fenitoína: indução enzimática — redução das concentrações de fenitoína e perda de controlo de crises; monitorizar e ajustar dose.',
  summary_pro_en = E'Rifampicin + phenytoin: enzyme induction — reduced phenytoin concentrations and loss of seizure control; monitor and adjust dose.',
  explanation_pt = E'A rifampicina induz o CYP2C9 e o CYP3A4, acelerando o metabolismo da fenitoína e reduzindo as suas concentrações plasmáticas e o efeito antiepilético. O QUADRO 2 do Anexo 7 regista esta interação na secção da fenitoína. A redução dos níveis pode levar a perda de controlo das crises em dias a semanas; ao suspender a rifampicina, os níveis de fenitoína sobem e pode surgir toxicidade. O risco é maior em doentes com epilepsia bem controlada que iniciam tuberculostáticos. Monitorizar a fenitoinemia e o controlo de crises; ajustar a dose de fenitoína ao iniciar, ajustar ou suspender a rifampicina.',
  explanation_en = E'Rifampicin induces CYP2C9 and CYP3A4, accelerating phenytoin metabolism and reducing its plasma concentrations and antiepileptic effect. QUADRO 2 of Annex 7 records this interaction in the phenytoin section. The fall in levels can lead to loss of seizure control within days to weeks; when rifampicin is stopped, phenytoin levels rise and toxicity may appear. The risk is higher in patients with well-controlled epilepsy starting antituberculosis therapy. Monitor phenytoin levels and seizure control; adjust the phenytoin dose when starting, adjusting or stopping rifampicin.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Fenitoína)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Phenytoin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- eslicarbazepina × fenitoina [moderate] — Anexo 7, QUADRO 2 (Acetato de Eslicarbazepina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Eslicarbazepina + fenitoína: indução do metabolismo e alteração dos níveis mútuos — risco de subdosagem ou toxicidade; monitorizar níveis.',
  summary_pro_en = E'Eslicarbazepine + phenytoin: mutual induction of metabolism and altered levels — risk of underdosing or toxicity; monitor levels.',
  explanation_pt = E'A eslicarbazepina induz o CYP3A4 e pode reduzir as concentrações de fenitoína; por outro lado, a fenitoína induz o metabolismo da eslicarbazepina, reduzindo a sua exposição e eficácia. O QUADRO 2 do Anexo 7 regista esta interação na secção do acetato de eslicarbazepina. O resultado prático é uma interação bidirecional com redução mútua dos níveis, podendo comprometer o controlo de crises de ambos os fármacos. O risco é maior em doentes politerapêuticos com epilepsia difícil. Monitorizar os níveis séricos de ambos quando disponíveis e o controlo clínico; ajustar as doses ao introduzir ou alterar qualquer um dos fármacos.',
  explanation_en = E'Eslicarbazepine induces CYP3A4 and may reduce phenytoin concentrations; conversely, phenytoin induces eslicarbazepine metabolism, reducing its exposure and efficacy. QUADRO 2 of Annex 7 records this interaction in the eslicarbazepine acetate section. The practical result is a bidirectional interaction with mutual reduction of levels, potentially compromising seizure control of both drugs. The risk is higher in polytherapy patients with difficult epilepsy. Monitor serum levels of both when available and clinical control; adjust doses when introducing or changing either drug.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Acetato de Eslicarbazepina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Eslicarbazepine acetate)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'eslicarbazepina'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'eslicarbazepina'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- amiodarona × litio [moderate] — Anexo 7, QUADRO 2 (Amiodarona)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Amiodarona + lítio: risco de toxicidade tiroid e sinergia na cardiotoxicidade — monitorizar função tiroideia, litemia e ECG.',
  summary_pro_en = E'Amiodarone + lithium: risk of thyroid toxicity and synergy in cardiotoxicity — monitor thyroid function, lithium levels and ECG.',
  explanation_pt = E'A amiodarona (rica em iodo) pode alterar a função tiroideia e o lítio também interfere na tiroide; ambos têm efeitos cardíacos (bradicardia, prolongamento QT, arritmias). O QUADRO 2 do Anexo 7 regista esta interação na secção da amiodarona. A associação pode potenciar hipotiroidismo ou hipertiroidismo e aumentar o risco de arritmias, sobretudo em idosos. O lítio tem margem terapêutica estreita e os seus níveis devem ser monitorizados, bem como o TSH, o ECG e os eletrólitos. Alertar o doente para sintomas de disfunção tiroideia (fadiga, intolerância ao frio/calor, palpitações) e para sinais de toxicidade do lítio (tremor, confusão).',
  explanation_en = E'Amiodarone (iodine-rich) can alter thyroid function and lithium also affects the thyroid; both have cardiac effects (bradycardia, QT prolongation, arrhythmias). QUADRO 2 of Annex 7 records this interaction in the amiodarone section. The combination may potentiate hypo- or hyperthyroidism and increase the arrhythmia risk, especially in the elderly. Lithium has a narrow therapeutic window and its levels must be monitored, along with TSH, ECG and electrolytes. Warn the patient of thyroid dysfunction symptoms (fatigue, cold/heat intolerance, palpitations) and of lithium toxicity signs (tremor, confusion).',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Amiodarona)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Amiodarone)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                        (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                           (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- tacrolimus × claritromicina [moderate] — Anexo 7, QUADRO 2 (Ciclosporina; Macrólidos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Tacrolimus + claritromicina: inibição do CYP3A4 e P-gp — aumento acentuado do tacrolimus e nefrotoxicidade; reduzir dose e monitorizar níveis.',
  summary_pro_en = E'Tacrolimus + clarithromycin: CYP3A4 and P-gp inhibition — marked tacrolimus increase and nephrotoxicity; reduce dose and monitor levels.',
  explanation_pt = E'O tacrolimus é metabolizado pelo CYP3A4 e é substrato da glicoproteína-P; a claritromicina inibe ambas as vias, podendo aumentar as concentrações de tacrolimus de forma acentuada (várias vezes) e precipitar nefrotoxicidade e neurotoxicidade. O QUADRO 2 do Anexo 7 regista esta interação nas secções da ciclosporina e dos macrólidos (aplicável aos inibidores da calcineurina). O risco é maior em transplantados com função renal já comprometida. Durante a claritromicina, reduzir a dose de tacrolimus (frequentemente para metade ou menos) e monitorizar os níveis séricos e a creatinina; preferir azitromicina quando possível.',
  explanation_en = E'Tacrolimus is metabolised by CYP3A4 and is a P-glycoprotein substrate; clarithromycin inhibits both pathways, potentially increasing tacrolimus concentrations several-fold and precipitating nephrotoxicity and neurotoxicity. QUADRO 2 of Annex 7 records this interaction in the cyclosporine and macrolide sections (applicable to calcineurin inhibitors). The risk is higher in transplant patients with already compromised renal function. During clarithromycin, reduce the tacrolimus dose (often by half or more) and monitor serum levels and creatinine; prefer azithromycin when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ciclosporina; Macrólidos)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Cyclosporine; Macrolides)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'tacrolimus'),
                        (SELECT id FROM public.drugs WHERE slug = 'claritromicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tacrolimus'),
                           (SELECT id FROM public.drugs WHERE slug = 'claritromicina'));

-- tacrolimus × diltiazem [moderate] — Anexo 7, QUADRO 2 (Bloqueadores da entrada de cálcio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Tacrolimus + diltiazem: inibição do CYP3A4 pelo diltiazem — aumento do tacrolimus; reduzir dose e monitorizar níveis e função renal.',
  summary_pro_en = E'Tacrolimus + diltiazem: CYP3A4 inhibition by diltiazem — increased tacrolimus; reduce dose and monitor levels and renal function.',
  explanation_pt = E'O diltiazem inibe o CYP3A4, a principal via de metabolização do tacrolimus, aumentando as suas concentrações plasmáticas e o risco de nefrotoxicidade. O QUADRO 2 do Anexo 7 regista esta interação na secção dos bloqueadores da entrada de cálcio. O aumento dos níveis costuma surgir nos primeiros dias após iniciar o diltiazem; a suspensão do diltiazem tem o efeito inverso. O risco é maior em transplantados renais ou hepáticos com margem terapêutica estreita. Monitorizar a tacrolimemia e a creatinina ao iniciar, ajustar ou suspender o diltiazem, e considerar reduzir a dose de tacrolimus (tipicamente 30-50%).',
  explanation_en = E'Diltiazem inhibits CYP3A4, the main metabolic pathway of tacrolimus, increasing its plasma concentrations and the risk of nephrotoxicity. QUADRO 2 of Annex 7 records this interaction in the calcium channel blocker section. The rise in levels usually appears within the first days of starting diltiazem; stopping diltiazem has the opposite effect. The risk is higher in renal or hepatic transplant patients with a narrow therapeutic margin. Monitor tacrolimus levels and creatinine when starting, adjusting or stopping diltiazem, and consider reducing the tacrolimus dose (typically 30-50%).',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Bloqueadores da entrada de cálcio)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Calcium channel blockers)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'tacrolimus'),
                        (SELECT id FROM public.drugs WHERE slug = 'diltiazem'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tacrolimus'),
                           (SELECT id FROM public.drugs WHERE slug = 'diltiazem'));

-- cetoconazol × sirolimus [moderate] — Anexo 7, QUADRO 2 (Antifúngicos Azol)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Cetoconazol + sirolimus: inibição do CYP3A4 e P-gp — aumento acentuado do sirolimus e toxicidade; associação a evitar ou com redução marcada da dose.',
  summary_pro_en = E'Ketoconazole + sirolimus: CYP3A4 and P-gp inhibition — marked sirolimus increase and toxicity; avoid or markedly reduce the dose.',
  explanation_pt = E'O sirolimus é metabolizado pelo CYP3A4 e é substrato da glicoproteína-P; o cetoconazol inibe fortemente ambas as vias e pode aumentar as concentrações de sirolimus de forma acentuada (até vários múltiplos), com risco de nefrotoxicidade, mielossupressão e hiperlipidemia. O QUADRO 2 do Anexo 7 regista esta interação na secção dos antifúngicos azol. A associação deve ser evitada; se inevitável, reduzir substancialmente a dose de sirolimus e monitorizar os níveis séricos e a função renal. Os idosos e os doentes com disfunção hepática ou renal são os mais vulneráveis. Preferir antifúngicos com menor inibição enzimática quando possível.',
  explanation_en = E'Sirolimus is metabolised by CYP3A4 and is a P-glycoprotein substrate; ketoconazole strongly inhibits both pathways and can increase sirolimus concentrations several-fold, with a risk of nephrotoxicity, myelosuppression and hyperlipidaemia. QUADRO 2 of Annex 7 records this interaction in the azole antifungal section. The combination should be avoided; if unavoidable, substantially reduce the sirolimus dose and monitor serum levels and renal function. The elderly and patients with hepatic or renal dysfunction are the most vulnerable. Prefer antifungals with less enzyme inhibition when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Antifúngicos Azol)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Azole antifungals)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'),
                        (SELECT id FROM public.drugs WHERE slug = 'sirolimus'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'),
                           (SELECT id FROM public.drugs WHERE slug = 'sirolimus'));

-- verapamilo × sirolimus [moderate] — Anexo 7, QUADRO 2 (Bloqueadores da entrada de cálcio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Verapamilo + sirolimus: inibição do CYP3A4 e P-gp — aumento do sirolimus; reduzir dose e monitorizar níveis.',
  summary_pro_en = E'Verapamil + sirolimus: CYP3A4 and P-gp inhibition — increased sirolimus; reduce dose and monitor levels.',
  explanation_pt = E'O verapamilo inibe o CYP3A4 e a glicoproteína-P, reduzindo o metabolismo e o efluxo do sirolimus e aumentando as suas concentrações plasmáticas. O QUADRO 2 do Anexo 7 regista esta interação na secção dos bloqueadores da entrada de cálcio. O aumento dos níveis pode ocorrer nos primeiros dias e manifestar-se por nefrotoxicidade, infeções ou anemia. O risco é maior em transplantados e idosos. Ao iniciar verapamilo, considerar reduzir a dose de sirolimus e monitorizar os níveis séricos e a função renal; preferir outros bloqueadores da entrada de cálcio quando possível.',
  explanation_en = E'Verapamil inhibits CYP3A4 and P-glycoprotein, reducing sirolimus metabolism and efflux and increasing its plasma concentrations. QUADRO 2 of Annex 7 records this interaction in the calcium channel blocker section. The rise in levels can occur within the first days and present with nephrotoxicity, infections or anaemia. The risk is higher in transplant patients and the elderly. When starting verapamil, consider reducing the sirolimus dose and monitor serum levels and renal function; prefer other calcium channel blockers when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Bloqueadores da entrada de cálcio)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Calcium channel blockers)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'verapamilo'),
                        (SELECT id FROM public.drugs WHERE slug = 'sirolimus'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'verapamilo'),
                           (SELECT id FROM public.drugs WHERE slug = 'sirolimus'));

-- naproxeno × ciprofloxacina [moderate] — Anexo 7, QUADRO 2 (Quinolonas)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Naproxeno + ciprofloxacina: as quinolonas e os AINE podem baixar o limiar convulsivo — risco de convulsões; evitar em doentes predispostos.',
  summary_pro_en = E'Naproxen + ciprofloxacin: quinolones and NSAIDs may lower the seizure threshold — seizure risk; avoid in predisposed patients.',
  explanation_pt = E'As fluoroquinolonas (como a ciprofloxacina) antagonizam os recetores GABA e podem baixar o limiar convulsivo; os AINE (como o naproxeno) têm um efeito sinérgico nesse sentido. O QUADRO 2 do Anexo 7 regista esta interação na secção das quinolonas. O risco de convulsões é maior em doentes com epilepsia, história de traumatismo craniano, AVC, insuficiência renal ou idosos. A associação deve ser evitada em doentes predispostos; se inevitável, usar a menor dose possível, por curta duração, e vigiar sintomas neurológicos. Considerar antibiótico alternativo ou AINE não associado a este risco quando apropriado.',
  explanation_en = E'Fluoroquinolones (such as ciprofloxacin) antagonise GABA receptors and may lower the seizure threshold; NSAIDs (such as naproxen) have a synergistic effect in this regard. QUADRO 2 of Annex 7 records this interaction in the quinolone section. The seizure risk is higher in patients with epilepsy, history of head trauma, stroke, renal impairment or the elderly. The combination should be avoided in predisposed patients; if unavoidable, use the lowest dose for the shortest duration and watch for neurological symptoms. Consider an alternative antibiotic or an NSAID not associated with this risk when appropriate.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Quinolonas)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Quinolones)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'),
                        (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'),
                           (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- furosemida × diclofenac [moderate] — Anexo 7, QUADRO 2 (AINEs)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Furosemida + diclofenac: os AINE reduzem o efeito diurético e podem agravar a função renal — risco de retenção hídrica e nefrotoxicidade; monitorizar.',
  summary_pro_en = E'Furosemide + diclofenac: NSAIDs reduce the diuretic effect and may worsen renal function — fluid retention and nephrotoxicity risk; monitor.',
  explanation_pt = E'Os AINE (como o diclofenac) inibem as prostaglandinas renais, reduzindo a resposta aos diuréticos de ansa e podendo causar retenção de sódio e água, elevação da pressão arterial e deterioração da função renal, sobretudo em doentes desidratados ou com insuficiência cardíaca. O QUADRO 2 do Anexo 7 regista esta interação na secção dos AINE. O risco de insuficiência renal aguda é maior nos idosos, hipovolémicos e com doença renal prévia. Monitorizar o peso, a pressão arterial, a creatinina e a resposta diurética; preferir paracetamol e usar AINE à menor dose e curta duração se inevitável.',
  explanation_en = E'NSAIDs (such as diclofenac) inhibit renal prostaglandins, reducing the response to loop diuretics and potentially causing sodium and water retention, blood pressure elevation and deterioration of renal function, especially in dehydrated patients or those with heart failure. QUADRO 2 of Annex 7 records this interaction in the NSAID section. The risk of acute kidney injury is higher in the elderly, hypovolaemic patients and those with pre-existing renal disease. Monitor weight, blood pressure, creatinine and diuretic response; prefer paracetamol and use the lowest NSAID dose for the shortest duration if unavoidable.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (AINEs)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (NSAIDs)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'),
                        (SELECT id FROM public.drugs WHERE slug = 'diclofenac'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'),
                           (SELECT id FROM public.drugs WHERE slug = 'diclofenac'));

-- ampicilina × estradiol [moderate] — Anexo 7, QUADRO 2 (Estrogénios)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Ampicilina + estradiol: alteração da flora intestinal — possível redução da eficácia contracetiva; reforçar método de barreira durante o tratamento.',
  summary_pro_en = E'Ampicillin + oestradiol: alteration of gut flora — possible reduced contraceptive efficacy; reinforce barrier method during treatment.',
  explanation_pt = E'Os antibióticos de largo espetro, como a ampicilina, podem alterar a flora intestinal e reduzir a hidrólise dos conjugados de estrogénios, diminuindo a sua reabsorção e, teoricamente, a eficácia contracetiva. O QUADRO 2 do Anexo 7 regista esta interação na secção dos estrogénios. Embora a evidência seja limitada e a maioria das mulheres não perca eficácia, recomenda-se prudência: usar método de barreira durante o tratamento antibiótico e até 7 dias após, sobretudo em doentes com diarreia ou vómitos. O risco de hemorragia irregular também pode ocorrer. Informar a doente e reforçar a adesão à toma do contracetivo.',
  explanation_en = E'Broad-spectrum antibiotics, such as ampicillin, may alter the gut flora and reduce the hydrolysis of oestrogen conjugates, decreasing their reabsorption and, theoretically, contraceptive efficacy. QUADRO 2 of Annex 7 records this interaction in the oestrogen section. Although the evidence is limited and most women do not lose efficacy, caution is recommended: use a barrier method during antibiotic treatment and for up to 7 days after, especially in patients with diarrhoea or vomiting. Irregular bleeding may also occur. Inform the patient and reinforce adherence to the contraceptive.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Estrogénios)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Oestrogens)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
                        (SELECT id FROM public.drugs WHERE slug = 'estradiol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'),
                           (SELECT id FROM public.drugs WHERE slug = 'estradiol'));

-- eslicarbazepina × levonorgestrel [moderate] — Anexo 7, QUADRO 2 (Acetato de Eslicarbazepina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Eslicarbazepina + levonorgestrel: indução enzimática — redução da eficácia do contracetivo hormonal; usar método de barreira.',
  summary_pro_en = E'Eslicarbazepine + levonorgestrel: enzyme induction — reduced hormonal contraceptive efficacy; use a barrier method.',
  explanation_pt = E'A eslicarbazepina induz o CYP3A4 e pode acelerar o metabolismo dos progestagénios (como o levonorgestrel) e dos estrogénios, reduzindo a eficácia dos contracetivos hormonais. O QUADRO 2 do Anexo 7 regista esta interação na secção do acetato de eslicarbazepina. O risco de falha contracetiva é real em mulheres em idade fértil com epilepsia. Recomendar contraceção de barreira ou método alternativo não hormonal durante o tratamento; nos contracetivos orais, considerar formulações com dose mais alta ou outro método. Reforçar a adesão e informar sobre hemorragia irregular como sinal de possível interação.',
  explanation_en = E'Eslicarbazepine induces CYP3A4 and may accelerate the metabolism of progestogens (such as levonorgestrel) and oestrogens, reducing the efficacy of hormonal contraceptives. QUADRO 2 of Annex 7 records this interaction in the eslicarbazepine acetate section. The risk of contraceptive failure is real in women of childbearing age with epilepsy. Recommend barrier contraception or an alternative non-hormonal method during treatment; for oral contraceptives, consider higher-dose formulations or another method. Reinforce adherence and inform about irregular bleeding as a possible sign of interaction.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Acetato de Eslicarbazepina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Eslicarbazepine acetate)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'eslicarbazepina'),
                        (SELECT id FROM public.drugs WHERE slug = 'levonorgestrel'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'eslicarbazepina'),
                           (SELECT id FROM public.drugs WHERE slug = 'levonorgestrel'));

-- ferro × levotiroxina [moderate] — Anexo 7, QUADRO 2 (Ferro)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Ferro + levotiroxina: o ferro quelata a levotiroxina no intestino — redução da absorção; separar as tomas ≥4 horas e monitorizar TSH.',
  summary_pro_en = E'Iron + levothyroxine: iron chelates levothyroxine in the gut — reduced absorption; separate doses by ≥4 hours and monitor TSH.',
  explanation_pt = E'O sulfato ferroso liga-se à levotiroxina no lúmen gastrointestinal, formando complexos insolúveis e reduzindo a absorção do hormônio (até 20-40%). O QUADRO 2 do Anexo 7 regista esta interação na secção do ferro. A consequência é a subdosagem efetiva de levotiroxina, com elevação do TSH e agravamento do hipotiroidismo. A prevenção é simples: administrar levotiroxina em jejum e o ferro com pelo menos 4 horas de intervalo (idealmente 4-6 horas). Monitorizar o TSH 6-8 semanas após iniciar ou alterar o ferro. O risco é maior em doentes com anemia ferropénica tratada cronicamente.',
  explanation_en = E'Ferrous sulphate binds to levothyroxine in the GI lumen, forming insoluble complexes and reducing hormone absorption (up to 20-40%). QUADRO 2 of Annex 7 records this interaction in the iron section. The consequence is effective levothyroxine underdosing, with TSH elevation and worsening hypothyroidism. Prevention is simple: give levothyroxine fasting and iron at least 4 hours apart (ideally 4-6 hours). Monitor TSH 6-8 weeks after starting or changing iron. The risk is higher in patients with iron-deficiency anaemia treated chronically.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ferro)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Iron)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ferro'),
                        (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ferro'),
                           (SELECT id FROM public.drugs WHERE slug = 'levotiroxina'));

-- metronidazol × dissulfiram [moderate] — Anexo 7, QUADRO 2 (Dissulfiram)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Metronidazol + dissulfiram: risco de reação psicótica aguda e confusão; associação a evitar — intervalo mínimo de 14 dias.',
  summary_pro_en = E'Metronidazole + disulfiram: risk of acute psychotic reaction and confusion; avoid — minimum interval of 14 days.',
  explanation_pt = E'A associação de metronidazol com dissulfiram tem sido associada a reações psicóticas agudas, confusão e delírio, mesmo em doses habituais; o mecanismo não está totalmente esclarecido, mas envolve provável interferência no metabolismo de aminas. O QUADRO 2 do Anexo 7 regista esta interação na secção do dissulfiram. A orientação é evitar a associação, respeitando um intervalo mínimo de cerca de 14 dias entre o fim de um fármaco e o início do outro. Se o metronidazol for indispensável num doente em dissulfiram, considerar antibiótico alternativo; vigiar sintomas neuropsiquiátricos (confusão, alucinações, agitação).',
  explanation_en = E'The combination of metronidazole with disulfiram has been associated with acute psychotic reactions, confusion and delirium, even at usual doses; the mechanism is not fully understood but probably involves interference with amine metabolism. QUADRO 2 of Annex 7 records this interaction in the disulfiram section. The guidance is to avoid the combination, respecting a minimum interval of about 14 days between stopping one drug and starting the other. If metronidazole is essential in a patient on disulfiram, consider an alternative antibiotic; watch for neuropsychiatric symptoms (confusion, hallucinations, agitation).',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Dissulfiram)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Disulfiram)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'),
                        (SELECT id FROM public.drugs WHERE slug = 'dissulfiram'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'),
                           (SELECT id FROM public.drugs WHERE slug = 'dissulfiram'));

-- indacaterol × salbutamol [moderate] — Anexo 7, QUADRO 2 (Indacaterol)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Indacaterol + salbutamol: efeito beta-2-adrenérgico aditivo — risco de taquicardia, tremores e hipocaliemia; usar com precaução.',
  summary_pro_en = E'Indacaterol + salbutamol: additive beta-2-adrenergic effect — risk of tachycardia, tremors and hypokalaemia; use with caution.',
  explanation_pt = E'O indacaterol (LABA de longa duração) e o salbutamol (SABA) ativam ambos os recetores beta-2-adrenérgicos; a utilização simultânea pode potenciar os efeitos sistémicos: taquicardia, palpitações, tremores, e hipocaliemia dose-dependente. O QUADRO 2 do Anexo 7 regista esta interação na secção do indacaterol. O risco é maior em doentes com doença cardiovascular, hipertiroidismo ou hipocaliemia prévia. O uso do salbutamol de resgate deve ser limitado à necessidade aguda; se o doente precisar de resgate frequente, reavaliar o controlo da doença de base. Monitorizar a frequência cardíaca, o potássio e os sintomas adrenérgicos.',
  explanation_en = E'Indacaterol (long-acting LABA) and salbutamol (SABA) both activate beta-2-adrenergic receptors; simultaneous use may potentiate systemic effects: tachycardia, palpitations, tremors and dose-dependent hypokalaemia. QUADRO 2 of Annex 7 records this interaction in the indacaterol section. The risk is higher in patients with cardiovascular disease, hyperthyroidism or pre-existing hypokalaemia. Rescue salbutamol use should be limited to acute need; if the patient needs frequent rescue, reassess control of the underlying disease. Monitor heart rate, potassium and adrenergic symptoms.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Indacaterol)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Indacaterol)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'indacaterol'),
                        (SELECT id FROM public.drugs WHERE slug = 'salbutamol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'indacaterol'),
                           (SELECT id FROM public.drugs WHERE slug = 'salbutamol'));

-- metoclopramida × levodopa [moderate] — Anexo 7, QUADRO 2 (Levodopa)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Metoclopramida + levodopa: antagonismo dopaminérgico — redução do efeito antiparkinsónico e risco de agravamento dos sintomas; evitar.',
  summary_pro_en = E'Metoclopramide + levodopa: dopaminergic antagonism — reduced antiparkinsonian effect and risk of worsening symptoms; avoid.',
  explanation_pt = E'A metoclopramida é um antagonista dopaminérgico (D2) e pode contrariar o efeito terapêutico da levodopa nos doentes com doença de Parkinson, agravando os sintomas motores; por outro lado, ambos podem causar discinesias. O QUADRO 2 do Anexo 7 regista esta interação na secção da levodopa. Em doentes parkinsónicos, evitar a metoclopramida como antiemético; preferir domperidona (que atravessa menos a barreira hematoencefálica) ou outros antieméticos não dopaminérgicos. Se a metoclopramida for inevitável, usá-la por curto período e vigiar o agravamento motor. O risco é maior em doentes com doses elevadas de levodopa ou doença avançada.',
  explanation_en = E'Metoclopramide is a dopaminergic (D2) antagonist and may counteract the therapeutic effect of levodopa in Parkinson''s disease patients, worsening motor symptoms; both drugs can also cause dyskinesias. QUADRO 2 of Annex 7 records this interaction in the levodopa section. In parkinsonian patients, avoid metoclopramide as an antiemetic; prefer domperidone (which crosses the blood-brain barrier less) or other non-dopaminergic antiemetics. If metoclopramide is unavoidable, use it for a short period and watch for motor worsening. The risk is higher in patients on high levodopa doses or advanced disease.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Levodopa)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Levodopa)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metoclopramida'),
                        (SELECT id FROM public.drugs WHERE slug = 'levodopa'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metoclopramida'),
                           (SELECT id FROM public.drugs WHERE slug = 'levodopa'));

-- amiodarona × atorvastatina [moderate] — Anexo 7, QUADRO 2 (Inibidores da HMG-CoA redutase)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Amiodarona + atorvastatina: inibição do CYP3A4 — aumento das estatinas e risco de miopatia/rabdomiólise; reduzir dose de estatina.',
  summary_pro_en = E'Amiodarone + atorvastatin: CYP3A4 inhibition — increased statin and risk of myopathy/rhabdomyolysis; reduce statin dose.',
  explanation_pt = E'A amiodarona inibe o CYP3A4, a via que metaboliza a atorvastatina (e a sinvastatina/lovastatina), aumentando as suas concentrações plasmáticas e o risco de miopatia e rabdomiólise. O QUADRO 2 do Anexo 7 regista esta interação na secção dos inibidores da HMG-CoA redutase. O risco é maior com doses elevadas de estatina, idosos, hipotiroidismo ou insuficiência renal. Se a associação for necessária, usar atorvastatina à menor dose eficaz (ou preferir pravastatina/rosuvastatina, menos dependentes do CYP3A4) e informar o doente para reportar mialgias, fraqueza ou urina escura. Monitorizar CPK se surgirem sintomas musculares.',
  explanation_en = E'Amiodarone inhibits CYP3A4, the pathway that metabolises atorvastatin (and simvastatin/lovastatin), increasing their plasma concentrations and the risk of myopathy and rhabdomyolysis. QUADRO 2 of Annex 7 records this interaction in the HMG-CoA reductase inhibitor section. The risk is higher with high statin doses, the elderly, hypothyroidism or renal impairment. If the combination is necessary, use atorvastatin at the lowest effective dose (or prefer pravastatin/rosuvastatin, less dependent on CYP3A4) and instruct the patient to report myalgia, weakness or dark urine. Monitor CPK if muscle symptoms appear.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Inibidores da HMG-CoA redutase)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (HMG-CoA reductase inhibitors)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                        (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'),
                           (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'));

-- rifampicina × glibenclamida [moderate] — Anexo 7, QUADRO 2 (Rifampicina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Rifampicina + glibenclamida: indução do CYP3A4 e da glicoproteína-P — redução do efeito hipoglicemiante; monitorizar glicemia e ajustar dose.',
  summary_pro_en = E'Rifampicin + glibenclamide: CYP3A4 and P-glycoprotein induction — reduced hypoglycaemic effect; monitor glucose and adjust dose.',
  explanation_pt = E'A rifampicina induz o CYP3A4 e a glicoproteína-P, acelerando o metabolismo e o efluxo da glibenclamida e reduzindo as suas concentrações e o efeito hipoglicemiante. O QUADRO 2 do Anexo 7 regista esta interação na secção da rifampicina. Em doentes diabéticos tratados com glibenclamida, a glicemia pode subir em dias e exigir aumento da dose ou mudança de antidiabético; ao suspender a rifampicina, o efeito inverso (hipoglicemia) pode ocorrer. Monitorizar a glicemia com frequência e ajustar a terapêutica; considerar outros antidiabéticos com menor interação quando possível.',
  explanation_en = E'Rifampicin induces CYP3A4 and P-glycoprotein, accelerating glibenclamide metabolism and efflux and reducing its concentrations and hypoglycaemic effect. QUADRO 2 of Annex 7 records this interaction in the rifampicin section. In diabetic patients on glibenclamide, glucose may rise within days and require a dose increase or a change of antidiabetic; when rifampicin is stopped, the opposite effect (hypoglycaemia) may occur. Monitor glucose frequently and adjust therapy; consider other antidiabetics with less interaction when possible.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Rifampicina)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Rifampicin)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'),
                        (SELECT id FROM public.drugs WHERE slug = 'glibenclamida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'),
                           (SELECT id FROM public.drugs WHERE slug = 'glibenclamida'));

-- ticagrelor × rifampicina [moderate] — Anexo 7, QUADRO 2 (Ticagrelor)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Ticagrelor + rifampicina: indução do CYP3A4 — redução acentuada do ticagrelor e perda de eficácia antiagregante; evitar ou monitorizar.',
  summary_pro_en = E'Ticagrelor + rifampicin: CYP3A4 induction — marked reduction of ticagrelor and loss of antiplatelet efficacy; avoid or monitor.',
  explanation_pt = E'O ticagrelor é metabolizado pelo CYP3A4 e a rifampicina é um potente indutor desta enzima, podendo reduzir drasticamente as concentrações do antiagregante e comprometer a proteção cardiovascular. O QUADRO 2 do Anexo 7 regista esta interação na secção do ticagrelor. A perda de eficácia antiagregante é clinicamente relevante em doentes com síndrome coronária aguda ou stent recente, aumentando o risco trombótico. A associação deve ser evitada; se a rifampicina for indispensável (ex.: tuberculose), considerar aumentar a dose de ticagrelor ou usar antiagregante alternativo não dependente do CYP3A4 (ex.: prasugrel ou clopidogrel conforme o perfil). Monitorizar sinais de eventos isquémicos.',
  explanation_en = E'Ticagrelor is metabolised by CYP3A4 and rifampicin is a potent inducer of this enzyme, potentially drastically reducing the antiplatelet concentrations and compromising cardiovascular protection. QUADRO 2 of Annex 7 records this interaction in the ticagrelor section. The loss of antiplatelet efficacy is clinically relevant in patients with acute coronary syndrome or recent stent, increasing thrombotic risk. The combination should be avoided; if rifampicin is essential (e.g. tuberculosis), consider increasing the ticagrelor dose or using an alternative antiplatelet not dependent on CYP3A4 (e.g. prasugrel or clopidogrel according to profile). Monitor for ischaemic events.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ticagrelor)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Ticagrelor)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ticagrelor'),
                        (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ticagrelor'),
                           (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- ticagrelor × sertralina [moderate] — Anexo 7, QUADRO 2 (Ticagrelor)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Ticagrelor + sertralina: efeito aditivo no risco hemorrágico (antiagregação + inibição da recaptação da serotonina); vigiar hemorragia.',
  summary_pro_en = E'Ticagrelor + sertraline: additive bleeding risk (antiplatelet + serotonin reuptake inhibition); watch for bleeding.',
  explanation_pt = E'A sertralina (ISRS) reduz a captação de serotonina nas plaquetas, diminuindo a sua agregação, e o ticagrelor inibe a agregação plaquetária via P2Y12 — o efeito é aditivo e aumenta o risco de hemorragia, sobretudo gastrointestinal. O QUADRO 2 do Anexo 7 regista esta interação na secção do ticagrelor. O risco é maior em idosos, história de úlcera péptica, uso concomitante de AINE ou anticoagulantes. A associação é frequente e geralmente tolerada, mas exige vigilância: alertar para melena, equimoses e hematúria, considerar proteção gástrica e reavaliar se surgir anemia ou hemorragia.',
  explanation_en = E'Sertraline (SSRI) reduces serotonin uptake in platelets, decreasing their aggregation, and ticagrelor inhibits platelet aggregation via P2Y12 — the effect is additive and increases bleeding risk, especially gastrointestinal. QUADRO 2 of Annex 7 records this interaction in the ticagrelor section. The risk is higher in the elderly, history of peptic ulcer, or concomitant NSAIDs or anticoagulants. The combination is common and generally tolerated, but requires surveillance: warn about melena, bruising and haematuria, consider gastric protection and reassess if anaemia or bleeding appears.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ticagrelor)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Ticagrelor)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ticagrelor'),
                        (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ticagrelor'),
                           (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- captopril × espironolactona [moderate] — Anexo 7, QUADRO 2 (Diuréticos poupadores de potássio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = E'Captopril + espironolactona: efeito aditivo na retenção de potássio — risco de hipercaliemia; monitorizar potássio e função renal.',
  summary_pro_en = E'Captopril + spironolactone: additive potassium retention — risk of hyperkalaemia; monitor potassium and renal function.',
  explanation_pt = E'O captopril (IECA) reduz a aldosterona e a espironolactona bloqueia o seu recetor; ambos diminuem a excreção renal de potássio e o efeito é aditivo, com risco de hipercaliemia. O QUADRO 2 do Anexo 7 regista esta interação na secção dos diuréticos poupadores de potássio. O risco é maior em idosos, insuficiência renal, diabetes ou uso concomitante de suplementos de potássio e AINE. Monitorizar a potassemia e a creatinina antes e após iniciar a associação e periodicamente; evitar suplementos de potássio e alertar para sintomas de hipercaliemia (fraqueza, palpitações, parestesias). Considerar ajustar doses ou alternativa se a TFG for baixa.',
  explanation_en = E'Captopril (ACE inhibitor) reduces aldosterone and spironolactone blocks its receptor; both decrease renal potassium excretion and the effect is additive, with a risk of hyperkalaemia. QUADRO 2 of Annex 7 records this interaction in the potassium-sparing diuretic section. The risk is higher in the elderly, renal impairment, diabetes or concomitant potassium supplements and NSAIDs. Monitor potassium and creatinine before and after starting the combination and periodically; avoid potassium supplements and warn about hyperkalaemia symptoms (weakness, palpitations, paraesthesia). Consider dose adjustment or an alternative if GFR is low.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Diuréticos poupadores de potássio)',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, QUADRO 2 (Potassium-sparing diuretics)'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'captopril'),
                        (SELECT id FROM public.drugs WHERE slug = 'espironolactona'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'captopril'),
                           (SELECT id FROM public.drugs WHERE slug = 'espironolactona'));

