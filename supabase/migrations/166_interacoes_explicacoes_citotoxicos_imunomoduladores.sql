-- 166: Fluxo 4 — Explicações longas dos pares do grupo 16 (Citotóxicos e Imunomoduladores)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en + explanation_pt/en)
-- dos 9 pares criados na migração 165.
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos de
--     risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nos rótulos citados na migração 165
--     (setIDs validados na API DailyMed) e no Prontuário Terapêutico.
--
-- Fontes (DailyMed/FDA — NIH/NLM), setIDs validados a 2026-08-17:
--   Ciclofosfamida (EVER Pharma)   571a5a63-fb66-0617-e063-6394a90a2d04
--   Flutamida (EULEXIN)            0a905e25-42b6-4937-a689-f01a8f22e644
--   Medroxiprogesterona (PROVERA)  a586be28-96af-4fed-a13f-9b94fd4c7405
--   Megestrol (Natco)              582cff8a-1def-43d6-ba7e-dce49e3e9f27
--   Degarelix (FIRMAGON)           ab11dd8a-0fd9-4013-89ab-e114557c7e4b
--   (parceiros: setIDs reutilizados da BD — regra 15.2)
--
-- Âncoras confirmadas no texto dos rótulos:
--   * Ciclofosfamida: "Concomitant use of protease inhibitors may increase the
--     concentration of cytotoxic metabolites and may enhance the toxicities of
--     cyclophosphamide".
--   * Flutamida: "Increases in prothrombin time have been noted in patients
--     receiving warfarin therapy".
--   * Medroxiprogesterona: "metabolized in-vitro primarily by hydroxylation via
--     the CYP3A4"; prontuário: "Rifampicina: redução do efeito".
--   * Megestrol: "may interact with warfarin and increase International
--     Normalized Ratio (INR). Closely monitor INR".
--   * Degarelix: prontuário 16.2.2.5 — "A utilização concomitante com fármacos
--     que prolonguem o intervalo QTc do ECG deve ser cuidadosamente avaliada
--     (e.g. fármacos anti-arrítmicos das classes Ia e III, metadona,
--     moxifloxacina e alguns antipsicóticos)".
--   * Metotrexato: prontuário 16.1.3 — "AINEs (excreção reduzida); penicilinas
--     (excreção reduzida); fenitoína (toxicidade aumentada)".
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug — reaplicar é
-- seguro. Aplicar na ordem 165 → 166.
-- =====================================================================

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ciclofosfamida + ritonavir: vigiar a toxicidade aumentada (mielossupressão, infeções, mucosite) — os inibidores da protease podem elevar os metabolitos citotóxicos.',
  summary_pro_en = 'Cyclophosphamide + ritonavir: monitor for enhanced toxicity (myelosuppression, infections, mucositis) — protease inhibitors may raise cytotoxic metabolites.',
  explanation_pt = 'O ritonavir, inibidor potente do CYP450, pode interferir com o metabolismo da ciclofosfamida, que é ativada por hidroxilação hepática (CYP2A6, 2B6, 3A, 2C9, 2C19) — o rótulo FDA documenta que os inibidores da protease "may increase the concentration of cytotoxic metabolites and may enhance the toxicities of cyclophosphamide, including higher incidence of infections, neutropenia, and mucositis". A consequência prática é um risco acrescido de toxicidade hematológica e infeciosa no doente oncológico. Em doentes com VIH ou a receber ritonavir como potenciador farmacocinético, monitorizar o hemograma e os sinais de infeção, e considerar o ajuste de dose da ciclofosfamida. Não há interação farmacocinética clinicamente trivial — requer vigilância ativa durante todo o ciclo.',
  explanation_en = 'Ritonavir, a potent CYP450 inhibitor, may interfere with cyclophosphamide metabolism, which is activated by hepatic hydroxylation (CYP2A6, 2B6, 3A, 2C9, 2C19) — the FDA label documents that protease inhibitors "may increase the concentration of cytotoxic metabolites and may enhance the toxicities of cyclophosphamide, including higher incidence of infections, neutropenia, and mucositis". The practical consequence is an increased risk of haematological and infectious toxicity in the oncology patient. In patients with HIV or receiving ritonavir as a pharmacokinetic booster, monitor the blood count and signs of infection, and consider cyclophosphamide dose adjustment. This is not a clinically trivial interaction — it requires active vigilance throughout the cycle.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciclofosfamida'),
                        (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciclofosfamida'),
                           (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Flutamida + varfarina: monitorizar o INR ao iniciar ou ajustar a flutamida — pode aumentar o efeito anticoagulante.',
  summary_pro_en = 'Flutamide + warfarin: monitor INR when starting or adjusting flutamide — it may increase the anticoagulant effect.',
  explanation_pt = 'O rótulo da flutamida documenta aumentos do tempo de protrombina em doentes a receber varfarina ("Increases in prothrombin time have been noted in patients receiving warfarin therapy"), e o prontuário regista o mesmo ("Aumenta o efeito da varfarina"). O mecanismo não está totalmente esclarecido, mas o efeito traduz-se em risco hemorrágico acrescido. O doente com cancro da próstata em terapêutica combinada com varfarina (ex.: por fibrilhação auricular ou tromboembolismo) deve fazer INR frequente nas primeiras semanas da associação e após qualquer alteração de dose de qualquer um dos fármacos. Ajustar a dose da varfarina ao valor-alvo e instruir o doente a vigiar sinais de hemorragia (gengivas, epistaxe, equimoses, fezes escuras).',
  explanation_en = 'The flutamide label documents increases in prothrombin time in patients receiving warfarin ("Increases in prothrombin time have been noted in patients receiving warfarin therapy"), and the Prontuário records the same ("Increases the effect of warfarin"). The mechanism is not fully established, but the effect translates into increased bleeding risk. The prostate cancer patient on combined therapy with warfarin (e.g., for atrial fibrillation or thromboembolism) should have frequent INR in the first weeks of the combination and after any dose change of either drug. Adjust the warfarin dose to target and instruct the patient to watch for bleeding signs (gums, epistaxis, bruising, dark stools).',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'flutamida'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'flutamida'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Medroxiprogesterona + rifampicina: vigiar a resposta hormonal — a rifampicina pode reduzir o efeito (indução do CYP3A4).',
  summary_pro_en = 'Medroxyprogesterone + rifampicin: monitor hormonal response — rifampicin may reduce the effect (CYP3A4 induction).',
  explanation_pt = 'A medroxiprogesterona é metabolizada sobretudo por hidroxilação via CYP3A4 ("Medroxyprogesterone acetate is metabolized in-vitro primarily by hydroxylation via the CYP3A4"), e o prontuário documenta "Rifampicina: redução do efeito". A rifampicina, indutora potente do CYP3A4, acelera o metabolismo do progestagénio e reduz a sua exposição, o que pode comprometer o controlo hormonal do cancro da mama ou do endométrio. A consequência é a possível perda de eficácia terapêutica durante a toma conjunta. Vigiar a resposta clínica ao tratamento hormonal e considerar alternativa terapêutica ou ajuste quando a associação for inevitável (ex.: tratamento de tuberculose concomitante). A monitorização de níveis não é rotina — o critério é clínico.',
  explanation_en = 'Medroxyprogesterone is metabolised mainly by hydroxylation via CYP3A4 ("Medroxyprogesterone acetate is metabolized in-vitro primarily by hydroxylation via the CYP3A4"), and the Prontuário documents "Rifampicin: reduction of effect". Rifampicin, a potent CYP3A4 inducer, accelerates progestogen metabolism and reduces its exposure, which may compromise hormonal control of breast or endometrial cancer. The consequence is possible loss of therapeutic efficacy during concomitant use. Monitor clinical response to hormonal therapy and consider a therapeutic alternative or adjustment when the combination is unavoidable (e.g., concomitant tuberculosis treatment). Level monitoring is not routine — the criterion is clinical.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'medroxiprogesterona'),
                        (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'medroxiprogesterona'),
                           (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Megestrol + varfarina: monitorizar o INR de perto — o megestrol pode aumentar o INR e o risco hemorrágico.',
  summary_pro_en = 'Megestrol + warfarin: monitor INR closely — megestrol may raise INR and bleeding risk.',
  explanation_pt = 'O rótulo do megestrol é explícito: "Megestrol acetate may interact with warfarin and increase International Normalized Ratio (INR). Closely monitor INR in patients taking megestrol acetate and warfarin". O mecanismo não está totalmente esclarecido, mas o efeito no INR pode ser clinicamente relevante, sobretudo em doentes oncológicos com caquexia em que o estado nutricional já é instável. Ao iniciar, ajustar ou suspender o megestrol, monitorizar o INR com frequência acrescida e ajustar a dose da varfarina ao alvo. Instruir o doente a comunicar sinais de hemorragia (gengivas, epistaxe, equimoses, fezes escuras) e evitar AINEs ou outros anticoagulantes sem supervisão.',
  explanation_en = 'The megestrol label is explicit: "Megestrol acetate may interact with warfarin and increase International Normalized Ratio (INR). Closely monitor INR in patients taking megestrol acetate and warfarin". The mechanism is not fully established, but the effect on INR may be clinically relevant, especially in oncology patients with cachexia whose nutritional status is already unstable. When starting, adjusting or stopping megestrol, monitor INR more frequently and adjust the warfarin dose to target. Instruct the patient to report bleeding signs (gums, epistaxis, bruising, dark stools) and to avoid NSAIDs or other anticoagulants without supervision.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Megestrol + rifampicina: vigiar a resposta hormonal — a rifampicina pode reduzir o efeito do megestrol.',
  summary_pro_en = 'Megestrol + rifampicin: monitor hormonal response — rifampicin may reduce the effect of megestrol.',
  explanation_pt = 'Tal como os restantes progestagénios, o megestrol é metabolizado por hidroxilação via CYP3A4, e o prontuário regista para a classe "Rifampicina: redução do efeito". A rifampicina, indutora potente do CYP3A4, reduz a exposição ao megestrol e pode comprometer o efeito paliativo hormonal no cancro da mama ou do endométrio (e o efeito orexígeno na caquexia). A associação é sobretudo relevante em doentes oncológicos que fazem tratamento de tuberculose. Vigiar a resposta clínica (controlo oncológico e estado nutricional) e considerar alternativa ou ajuste quando a associação for inevitável.',
  explanation_en = 'Like other progestogens, megestrol is metabolised by hydroxylation via CYP3A4, and the Prontuário records for the class "Rifampicin: reduction of effect". Rifampicin, a potent CYP3A4 inducer, reduces exposure to megestrol and may compromise the palliative hormonal effect in breast or endometrial cancer (and the orexigenic effect in cachexia). The combination is particularly relevant in oncology patients receiving tuberculosis treatment. Monitor clinical response (oncological control and nutritional status) and consider an alternative or adjustment when the combination is unavoidable.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
                        (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'megestrol'),
                           (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Degarelix + amiodarona: avaliar o risco de prolongamento do QT — preferir alternativa se possível.',
  summary_pro_en = 'Degarelix + amiodarone: assess QT prolongation risk — prefer an alternative if possible.',
  explanation_pt = 'O prontuário documenta para o degarelix que "a utilização concomitante com fármacos que prolonguem o intervalo QTc do ECG deve ser cuidadosamente avaliada (e.g. fármacos anti-arrítmicos das classes Ia e III, metadona, moxifloxacina e alguns antipsicóticos)". A amiodarona, anti-arrítmico de classe III, prolonga o intervalo QT de forma bem conhecida e a soma com o degarelix aumenta o risco de arritmias ventriculares, incluindo torsades de pointes. O risco é maior em doentes com QT basal prolongado, hipocaliemia, hipomagnesemia, idade avançada ou insuficiência renal/hepática. Se a associação for inevitável, monitorizar o ECG e os eletrólitos e preferir a menor duração possível; qualquer síncope ou palpitação deve ser avaliada com urgência.',
  explanation_en = 'The Prontuário documents for degarelix that "concomitant use with drugs that prolong the QTc interval should be carefully evaluated (e.g. class Ia and III antiarrhythmics, methadone, moxifloxacin and some antipsychotics)". Amiodarone, a class III antiarrhythmic, prolongs the QT interval in a well-known manner and adding it to degarelix increases the risk of ventricular arrhythmias, including torsades de pointes. The risk is higher in patients with prolonged baseline QT, hypokalaemia, hypomagnesaemia, advanced age or renal/hepatic impairment. If the combination is unavoidable, monitor the ECG and electrolytes and prefer the shortest possible duration; any syncope or palpitation must be assessed urgently.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
                        (SELECT id FROM public.drugs WHERE slug = 'amiodarona'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
                           (SELECT id FROM public.drugs WHERE slug = 'amiodarona'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Degarelix + moxifloxacina: evitar se possível — risco de prolongamento do QT (a moxifloxacina é citada no prontuário).',
  summary_pro_en = 'Degarelix + moxifloxacin: avoid if possible — risk of QT prolongation (moxifloxacin is cited in the Prontuário).',
  explanation_pt = 'O prontuário cita explicitamente a moxifloxacina entre os fármacos cuja associação com o degarelix deve ser "cuidadosamente avaliada" pelo risco de prolongamento do QTc. A moxifloxacina é das fluoroquinolonas com maior efeito no intervalo QT, e a soma com o degarelix aumenta o risco de arritmias ventriculares. Em doentes com cancro da próstata avançado e infeção respiratória ou urinária, preferir um antibiótico sem efeito no QT quando existir alternativa; se a moxifloxacina for inevitável, usar a menor duração, monitorizar ECG e eletrólitos em doentes de risco e vigiar síncope, palpitações ou tonturas.',
  explanation_en = 'The Prontuário explicitly cites moxifloxacin among the drugs whose combination with degarelix should be "carefully evaluated" because of the QTc prolongation risk. Moxifloxacin is among the fluoroquinolones with the greatest effect on the QT interval, and adding it to degarelix increases the risk of ventricular arrhythmias. In patients with advanced prostate cancer and respiratory or urinary infection, prefer an antibiotic without QT effect when an alternative exists; if moxifloxacin is unavoidable, use the shortest course, monitor ECG and electrolytes in at-risk patients and watch for syncope, palpitations or dizziness.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
                        (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'degarelix'),
                           (SELECT id FROM public.drugs WHERE slug = 'moxifloxacina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Metotrexato + amoxicilina: vigiar a toxicidade do metotrexato — as penicilinas reduzem a sua excreção renal.',
  summary_pro_en = 'Methotrexate + amoxicillin: monitor methotrexate toxicity — penicillins reduce its renal excretion.',
  explanation_pt = 'O prontuário documenta para o metotrexato "penicilinas (excreção reduzida)" entre as interações relevantes. As penicilinas competem com o metotrexato pela secreção tubular renal, reduzindo a sua eliminação e elevando os níveis plasmáticos, com risco de toxicidade (mielossupressão, mucosite, hepatotoxicidade). A associação é clinicamente relevante em doentes com doses altas de metotrexato ou função renal limítrofe. Se a antibioterapia com amoxicilina for necessária, vigiar o hemograma e sinais de mucosite, considerar a monitorização dos níveis de metotrexato em esquemas de dose alta e reforçar a hidratação. Qualquer febre, neutropenia ou úlceras orais deve levar a avaliação imediata.',
  explanation_en = 'The Prontuário documents for methotrexate "penicillins (reduced excretion)" among the relevant interactions. Penicillins compete with methotrexate for renal tubular secretion, reducing its elimination and raising plasma levels, with a risk of toxicity (myelosuppression, mucositis, hepatotoxicity). The combination is clinically relevant in patients on high-dose methotrexate or with borderline renal function. If amoxicillin therapy is needed, monitor the blood count and signs of mucositis, consider methotrexate level monitoring in high-dose regimens and reinforce hydration. Any fever, neutropenia or oral ulcers should prompt immediate evaluation.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                        (SELECT id FROM public.drugs WHERE slug = 'amoxicilina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                           (SELECT id FROM public.drugs WHERE slug = 'amoxicilina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Metotrexato + fenitoína: vigiar a toxicidade do metotrexato e os níveis de fenitoína — risco de toxicidade aumentada.',
  summary_pro_en = 'Methotrexate + phenytoin: monitor methotrexate toxicity and phenytoin levels — risk of increased toxicity.',
  explanation_pt = 'O prontuário documenta para o metotrexato "fenitoína (toxicidade aumentada)". A fenitoína é altamente ligada a proteínas plasmáticas e a associação envolve deslocação proteica e alterações metabólicas que podem aumentar a toxicidade do metotrexato; em sentido inverso, o metotrexato pode alterar os níveis de fenitoína. A associação é relevante em doentes oncológicos com epilepsia concomitante. Vigiar sinais de toxicidade do metotrexato (mielossupressão, mucosite) e, se aplicável, os níveis séricos de fenitoína; qualquer ataxia, nistagmo ou sintomas neurológicos deve levar a avaliação. Considerar alternativa anticonvulsivante quando o controlo da epilepsia o permitir.',
  explanation_en = 'The Prontuário documents for methotrexate "phenytoin (increased toxicity)". Phenytoin is highly protein-bound and the combination involves protein displacement and metabolic changes that may increase methotrexate toxicity; conversely, methotrexate may alter phenytoin levels. The combination is relevant in oncology patients with concomitant epilepsy. Monitor signs of methotrexate toxicity (myelosuppression, mucositis) and, if applicable, serum phenytoin levels; any ataxia, nystagmus or neurological symptoms should prompt evaluation. Consider an alternative anticonvulsant when seizure control allows.',
  updated_at = now()
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metotrexato'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));
