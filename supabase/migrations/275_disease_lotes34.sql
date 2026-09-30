-- =====================================================================
-- 275 — Interações fármaco-doença (Fluxo 2) para os Lotes 3 e 4
-- ---------------------------------------------------------------------
-- A tabela drug_disease_interactions (migração 060) tinha 563 registos,
-- mas ZERO cobertura para os 19 fármacos dos Lotes 3 (264–266) e 4
-- (268–270). Esta migração adiciona os pares clinicamente mais
-- relevantes, reutilizando o vocabulário de condition_slug já em uso na
-- BD (evita sinónimos duplicados como glaucoma_angulo_fechado/glaucoma).
--
-- Fontes (regra do projecto — Prontuário INFARMED + EMC-UK):
--   * Prontuário 8.7 Anti-hormonas (l. 27942): clomifeno contra-indicado
--     na doença hepática; "excluir-se a hipótese de gravidez"; não usar
--     na gravidez.
--   * Prontuário 8.3 (l. 25784): carbimazol contra-indicado em
--     "perturbações hepáticas, gravidez e aleitamento"; suspender em
--     neutropenia (agranulocitose).
--   * Prontuário 8.4 (l. 25973): insulina — "preocupação especial" em
--     doentes predispostos a hipoglicemia, alcoólicos, doença coronária
--     ou cerebrovascular (mascaramento/maior risco de hipoglicemia).
--   * Prontuário 4.3 (l. 19265): antifibrinolíticos (ácido tranexâmico)
--     contra-indicados em hemorragias/disseminação intravascular;
--     hemoptises=hemorragia ativa — ver exclusões.
--   * Prontuário 7.2 (l. 24074): sulfato de magnésio "usado com
--     precaução em caso de IH (insuficiência hepática?) — na verdade
--     IH = insuficiência hepática no contexto tocolítico; precaução em
--     doença renal (excreção exclusivamente renal → toxicidade).
--   * Prontuário ficha DESFERAL (l. 38155): deferoxamina — precauções
--     renais; as doses dependem da ferritina.
--   * Prontuário 4.3.1.1 (l. 25988): protamina — hipotensão grave e
--     reações anafilactoides; precaução em insuficiência cardíaca
--     descompensada e hipotensão.
--   * EMC-UK Testogel (product/8919) 4.3: contra-indicado em "known or
--     suspected prostate cancer or breast carcinoma" — cancro da
--     próstata e da mama (masculino).
--   * EMC-UK/Prontuário 8.3: levotiroxina precaução em doença
--     cardiovascular (Prontuário l. 25830: "cuidado especial em
--     doentes idosos e cardíacos").
--
-- Idempotência: ON CONFLICT (drug_id, condition_slug) DO NOTHING.
-- Reaplicar = 0 mudanças. Status 'published' (semeadura da 061).
--
-- Cobertura: 18 fármacos × 1–4 condições = 26 pares
-- (13 contraindication, 13 precaution).
-- =====================================================================

INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en, source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
       v.interaction_type, v.severity, v.reason_pt, v.reason_en,
       v.advice_pt, v.advice_en, v.source_pt, v.source_en,
       v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ------------------------------------------------------------------
  -- CLOMIFENO — Prontuário 8.7 (l. 27942)
  -- ------------------------------------------------------------------
  ('clomifeno', 'doenca_hepatica', 'Doença hepática', 'Liver disease',
   'contraindication', 'moderate',
   'O clomifeno está contra-indicado na doença hepática — o metabolismo hepático do fármaco é reduzido e o risco de hepatotoxicidade aumenta.',
   'Clomiphene is contraindicated in liver disease — hepatic metabolism is reduced and the risk of hepatotoxicity increases.',
   'Excluir doença hepática antes de iniciar; se surgirem sinais de hepatotoxicidade (icterícia, dor no hipocôndrio direito), suspender.',
   'Exclude liver disease before starting; if signs of hepatotoxicity appear (jaundice, right upper quadrant pain), discontinue.',
   'Prontuário Terapêutico INFARMED, 8.7 Anti-hormonas — Clomifeno: "Está contra-indicado na doença hepática".',
   'Prontuário Terapêutico INFARMED, 8.7 Anti-hormones — Clomiphene: "contraindicated in liver disease".', 1),
  ('clomifeno', 'gravidez', 'Gravidez', 'Pregnancy',
   'contraindication', 'moderate',
   'O clomifeno não deve usar-se na gravidez — a gravidez deve ser excluída antes de iniciar o tratamento.',
   'Clomiphene must not be used in pregnancy — pregnancy must be excluded before starting treatment.',
   'Antes de iniciar, excluir gravidez; suspender imediatamente se conceção ocorrer durante o ciclo.',
   'Exclude pregnancy before starting; stop immediately if conception occurs during the cycle.',
   'Prontuário Terapêutico INFARMED, 8.7 — Clomifeno: "Deve excluir-se a hipótese de gravidez... Não deve usar-se na gravidez".',
   'Prontuário Terapêutico INFARMED, 8.7 — Clomiphene: "exclude the possibility of pregnancy... not to be used in pregnancy".', 2),
  -- ------------------------------------------------------------------
  -- CARBIMAZOL — Prontuário 8.3 (l. 25784)
  -- ------------------------------------------------------------------
  ('carbimazol', 'doenca_hepatica_ativa', 'Doença hepática ativa', 'Active liver disease',
   'contraindication', 'moderate',
   'O carbimazol está contra-indicado em perturbações hepáticas — hepatotoxicidade idiossincrática pode ser fatal.',
   'Carbimazole is contraindicated in hepatic disorders — idiosyncratic hepatotoxicity can be fatal.',
   'Avaliar função hepática antes de iniciar; suspender se surgirem sintomas de hepatite (icterícia, colúria, prurido).',
   'Assess liver function before starting; discontinue if hepatitis symptoms develop (jaundice, dark urine, pruritus).',
   'Prontuário Terapêutico INFARMED, 8.3 — Carbimazol: "Contra-Ind. e Prec.: ... perturbações hepáticas, gravidez e aleitamento".',
   'Prontuário Terapêutico INFARMED, 8.3 — Carbimazole: "Contraindications and precautions: ... hepatic disorders, pregnancy and breastfeeding".', 1),
  ('carbimazol', 'neutropenia', 'Neutropenia / leucopenia', 'Neutropenia / leukopenia',
   'precaution', 'critical',
   'Agranulocitose é a reação adversa mais grave do carbimazol (rara mas fatal); a neutropenia prévia aumenta o risco e obriga a vigilância hematológica.',
   'Agranulocytosis is carbimazole''s most serious adverse reaction (rare but fatal); pre-existing neutropenia increases risk and requires haematological monitoring.',
   'Solicitar hemograma antes de iniciar e a qualquer suspeita de infeção (febre, garganta irritada); suspender em caso de neutropenia.',
   'Request full blood count before starting and at any suspicion of infection (fever, sore throat); discontinue if neutropenia develops.',
   'Prontuário Terapêutico INFARMED, 8.3 — Carbimazol: "raras mas graves situações de agranulocitose... suspender-se a medicação em caso de evidência de neutropenia".',
   'Prontuário Terapêutico INFARMED, 8.3 — Carbimazole: "rare but serious agranulocytosis... discontinue if evidence of neutropenia".', 2),
  -- ------------------------------------------------------------------
  -- PROPILENTIOURACILO — Prontuário 8.3 (hepatotoxicidade conhecida)
  -- ------------------------------------------------------------------
  ('propiltiouracilo', 'doenca_hepatica_ativa', 'Doença hepática ativa', 'Active liver disease',
   'contraindication', 'critical',
   'O propiltiouracilo causa hepatotoxicidade grave (insuficiência hepática fulminante descrita, sobretudo em adultos) — evitar na doença hepática ativa.',
   'Propylthiouracil causes severe hepatotoxicity (fulminant hepatic failure reported, mainly in adults) — avoid in active liver disease.',
   'Preferir carbimazol na doença hepática prévia; monitorizar transaminases na terapêutica com PTU.',
   'Prefer carbimazole if pre-existing liver disease; monitor transaminases during PTU therapy.',
   'Prontuário Terapêutico INFARMED, 8.3 — PTU: hepatotoxicidade idiossincrática; EMC-UK PTU SmPC 4.4 (aviso de insuficiência hepática).',
   'Prontuário Terapêutico INFARMED, 8.3 — PTU: idiosyncratic hepatotoxicity; EMC-UK PTU SmPC 4.4 (hepatic failure warning).', 1),
  -- ------------------------------------------------------------------
  -- INSULINAS — Prontuário 8.4 (l. 25973)
  -- ------------------------------------------------------------------
  ('insulina-regular', 'alcoolismo', 'Alcoolismo', 'Alcoholism',
   'precaution', 'moderate',
   'O álcool potencia a hipoglicemia induzida pela insulina (inibe a gluconeogénese hepática); o Prontuário marca "preocupação especial" nos alcoólicos.',
   'Alcohol potentiates insulin-induced hypoglycaemia (inhibits hepatic gluconeogenesis); the Prontuário flags "special concern" in alcoholics.',
   'Aconselhar a evitar álcool em jejum; reforçar auto-monitorização da glicemia e educação sobre sinais de hipoglicemia.',
   'Advise avoiding alcohol while fasting; reinforce glucose self-monitoring and hypoglycaemia awareness education.',
   'Prontuário Terapêutico INFARMED, 8.4 Insulinas: "preocupação especial... nos indivíduos... alcoólicos".',
   'Prontuário Terapêutico INFARMED, 8.4 Insulins: "special concern... alcoholics".', 1),
  ('insulina-regular', 'doenca_cardiovascular', 'Doença cardiovascular (enfarte, AVC)', 'Cardiovascular disease (MI, stroke)',
   'precaution', 'moderate',
   'A hipoglicemia em doentes com doença coronária ou cerebrovascular pode precipitar isquemia/arritmia — o Prontuário exige "preocupação especial".',
   'Hypoglycaemia in patients with coronary or cerebrovascular disease can precipitate ischaemia/arrhythmia — the Prontuário requires "special concern".',
   'Alvos glicémicos menos agressivos; evitar hipoglicemia documentada; vigilância reforçada.',
   'Less aggressive glycaemic targets; avoid documented hypoglycaemia; enhanced surveillance.',
   'Prontuário Terapêutico INFARMED, 8.4: "indivíduos com doença coronária ou cerebrovascular".',
   'Prontuário Terapêutico INFARMED, 8.4: "individuals with coronary or cerebrovascular disease".', 2),
  ('insulina-nph', 'alcoolismo', 'Alcoolismo', 'Alcoholism',
   'precaution', 'moderate',
   'O álcool potencia a hipoglicemia induzida pela insulina NPH (inibe a gluconeogénese hepática); risco maior com insulinas de acção intermédia.',
   'Alcohol potentiates NPH insulin-induced hypoglycaemia (inhibits hepatic gluconeogenesis); risk is higher with intermediate-acting insulins.',
   'Aconselhar a evitar álcool em jejum; reforçar auto-monitorização da glicemia e educação sobre sinais de hipoglicemia.',
   'Advise avoiding alcohol while fasting; reinforce glucose self-monitoring and hypoglycaemia awareness education.',
   'Prontuário Terapêutico INFARMED, 8.4 Insulinas: "preocupação especial... nos indivíduos... alcoólicos".',
   'Prontuário Terapêutico INFARMED, 8.4 Insulins: "special concern... alcoholics".', 1),
  ('insulina-nph', 'doenca_cardiovascular', 'Doença cardiovascular (enfarte, AVC)', 'Cardiovascular disease (MI, stroke)',
   'precaution', 'moderate',
   'A hipoglicemia em doentes com doença coronária ou cerebrovascular pode precipitar isquemia/arritmia.',
   'Hypoglycaemia in patients with coronary or cerebrovascular disease can precipitate ischaemia/arrhythmia.',
   'Alvos glicémicos menos agressivos; evitar hipoglicemia documentada; vigilância reforçada.',
   'Less aggressive glycaemic targets; avoid documented hypoglycaemia; enhanced surveillance.',
   'Prontuário Terapêutico INFARMED, 8.4: "indivíduos com doença coronária ou cerebrovascular".',
   'Prontuário Terapêutico INFARMED, 8.4: "individuals with coronary or cerebrovascular disease".', 2),
  -- ------------------------------------------------------------------
  -- PROGESTERONA — Prontuário 8.3 (gravidez? — ver exclusões)
  -- ------------------------------------------------------------------
  ('progesterona', 'doenca_hepatica', 'Doença hepática', 'Liver disease',
   'contraindication', 'moderate',
   'A progesterona é metabolizada no fígado e está contra-indicada na doença hepática grave (quase todos os progestagénios).',
   'Progesterone is hepatically metabolised and is contraindicated in severe liver disease (applies to most progestogens).',
   'Avaliar função hepática antes de iniciar terapêutica hormonal.',
   'Assess liver function before starting hormonal therapy.',
   'Prontuário Terapêutico INFARMED, 8.3 (progestagénios — contra-indicação hepática de classe).',
   'Prontuário Terapêutico INFARMED, 8.3 (progestogens — class hepatic contraindication).', 1),
  -- ------------------------------------------------------------------
  -- TESTOSTERONA — EMC-UK Testogel 8919 § 4.3
  -- ------------------------------------------------------------------
  ('testosterona', 'cancro_prostata_psa', 'Cancro da próstata / vigilância do PSA', 'Prostate cancer / PSA monitoring',
   'contraindication', 'critical',
   'A testosterona está contra-indicada no cancro da próstata conhecido ou suspeito — estimula o crescimento do tumor andrógeneo-dependente.',
   'Testosterone is contraindicated in known or suspected prostate cancer — it stimulates androgen-dependent tumour growth.',
   'Excluir cancro da próstata (toque rectal + PSA) antes de iniciar; reavaliar PSA periodicamente durante a terapêutica.',
   'Exclude prostate cancer (DRE + PSA) before starting; reassess PSA periodically during therapy.',
   'EMC-UK (MHRA) — SmPC Testogel 16.2 mg/g gel, § 4.3: "known or suspected prostate cancer or breast carcinoma": https://www.medicines.org.uk/emc/product/8919/smpc',
   'EMC-UK (MHRA) — Testogel 16.2 mg/g gel SmPC, § 4.3: "known or suspected prostate cancer or breast carcinoma": https://www.medicines.org.uk/emc/product/8919/smpc', 1),
  ('testosterona', 'cancro_mama', 'Cancro da mama (conhecido, suspeito ou história)', 'Breast cancer (known, suspected or history)',
   'contraindication', 'critical',
   'A testosterona está contra-indicada no carcinoma da mama (homens) — os andrógenos podem estimular receptores estrogénicos após aromatização periférica.',
   'Testosterone is contraindicated in breast carcinoma (men) — androgens may stimulate oestrogen receptors after peripheral aromatisation.',
   'Excluir carcinoma mamário antes de iniciar a terapêutica androgénica.',
   'Exclude breast carcinoma before starting androgen therapy.',
   'EMC-UK (MHRA) — SmPC Testogel, § 4.3: "known or suspected prostate cancer or breast carcinoma": https://www.medicines.org.uk/emc/product/8919/smpc',
   'EMC-UK (MHRA) — Testogel SmPC, § 4.3: "known or suspected prostate cancer or breast carcinoma": https://www.medicines.org.uk/emc/product/8919/smpc', 2),
  -- ------------------------------------------------------------------
  -- ÁCIDO TRANEXÂMICO — Prontuário 4.3 (antifibrinolíticos)
  -- ------------------------------------------------------------------
  ('acido-tranexamico', 'trombose_ativa', 'Trombose ativa', 'Active thrombosis',
   'contraindication', 'critical',
   'O ácido tranexâmico é antifibrinolítico — promove a estabilização do coágulo e está contra-indicado na doença tromboembólica ativa/história recente.',
   'Tranexamic acid is antifibrinolytic — it stabilises clots and is contraindicated in active/recent thromboembolic disease.',
   'Excluir TVP/EP/trombose arterial ativa antes de iniciar; suspender se sinais de trombose surgirem durante o tratamento.',
   'Exclude active DVT/PE/arterial thrombosis before starting; discontinue if thrombosis signs develop during treatment.',
   'Prontuário Terapêutico INFARMED, 4.3 Anticoagulantes e antitrombóticos — antifibrinolíticos: contra-indicados em estados pro-trombóticos.',
   'Prontuário Terapêutico INFARMED, 4.3 Anticoagulants and antithrombotics — antifibrinolytics: contraindicated in pro-thrombotic states.', 1),
  -- ------------------------------------------------------------------
  -- SULFATO DE MAGNÉSIO — Prontuário 7.2 (l. 24074)
  -- ------------------------------------------------------------------
  ('sulfato-magnesio', 'doenca_renal_cronica', 'Doença renal crónica', 'Chronic kidney disease',
   'precaution', 'critical',
   'O magnésio é excretado exclusivamente pela via renal — na doença renal crónica acumula-se causando depressão do SNC, paragem respiratória e bloqueio cardíaco.',
   'Magnesium is exclusively renally excreted — in chronic kidney disease it accumulates causing CNS depression, respiratory arrest and heart block.',
   'Reduzir dose e monitorizar magnesiemia e reflexos rotulianos em qualquer grau de disfunção renal.',
   'Reduce dose and monitor serum magnesium and patellar reflexes at any degree of renal impairment.',
   'Prontuário Terapêutico INFARMED, 7.2 Uterotónicos (MgSO4): "Pode ser administrado... monitorização dos níveis plasmáticos de magnésio"; excreção renal.',
   'Prontuário Terapêutico INFARMED, 7.2 Uterotonics (MgSO4): "...monitoring of plasma magnesium levels"; renal excretion.', 1),
  ('sulfato-magnesio', 'miastenia_gravis', 'Miastenia gravis', 'Myasthenia gravis',
   'contraindication', 'critical',
   'O magnésio inibe a libertação de acetilcolina na placa motora — pode desencadear crise miasténica grave.',
   'Magnesium inhibits acetylcholine release at the neuromuscular junction — it can trigger a severe myasthenic crisis.',
   'Evitar magnésio IV na miastenia; se inevitável, garantir suporte ventilatório disponível.',
   'Avoid IV magnesium in myasthenia; if unavoidable, ensure ventilatory support is available.',
   'EMC-UK — SmPC Magnesium sulfate injection § 4.3 (miastenia gravis); Prontuário (mecanismo neuromuscular).',
   'EMC-UK — Magnesium sulfate injection SmPC § 4.3 (myasthenia gravis); Prontuário (neuromuscular mechanism).', 2),
  -- ------------------------------------------------------------------
  -- CLORETO DE POTÁSSIO — hipercaliemia (excreção renal)
  -- ------------------------------------------------------------------
  ('cloreto-potassio', 'insuficiencia_renal_grave', 'Insuficiência renal grave', 'Severe renal impairment',
   'contraindication', 'critical',
   'Na insuficiência renal grave, a suplementação oral/IV de potássio causa hipercaliemia potencialmente fatal (arritmias, paragem cardíaca).',
   'In severe renal impairment, oral/IV potassium supplementation causes potentially fatal hyperkalaemia (arrhythmias, cardiac arrest).',
   'Contra-indicado na insuficiência renal grave (clearance muito reduzido); em graus ligeiros, monitorizar kaliemia rigorosamente.',
   'Contraindicated in severe renal impairment (markedly reduced clearance); in milder grades, monitor serum potassium rigorously.',
   'Prontuário Terapêutico INFARMED (eletrólitos): precaução renal; EMC-UK KCl SmPC 4.3 (insuficiência renal grave, hipercalemia).',
   'Prontuário Terapêutico INFARMED (electrolytes): renal precaution; EMC-UK KCl SmPC 4.3 (severe renal impairment, hyperkalaemia).', 1),
  ('cloreto-potassio', 'hipercaliemia', 'Hipercaliemia', 'Hyperkalaemia',
   'contraindication', 'critical',
   'A suplementação de potássio numa hipercaliemia estabelecida pode precipitar paragem cardíaca.',
   'Potassium supplementation in established hyperkalaemia can precipitate cardiac arrest.',
   'Dosear kaliemia antes e durante a terapêutica; suspender se kaliemia > 5,5 mmol/l.',
   'Measure potassium before and during therapy; discontinue if serum K+ > 5.5 mmol/l.',
   'EMC-UK — SmPC Potassium chloride § 4.3 (hipercaliemia).',
   'EMC-UK — Potassium chloride SmPC § 4.3 (hyperkalaemia).', 2),
  -- ------------------------------------------------------------------
  -- PROCTAMINA — Prontuário 4.3.1.1 (l. 25988)
  -- ------------------------------------------------------------------
  ('protamina', 'insuficiencia_cardiaca', 'IC descompensada', 'Decompensated HF',
   'precaution', 'moderate',
   'A protamina causa hipotensão grave e redução do débito cardíaco — precaução na insuficiência cardíaca descompensada.',
   'Protamine causes severe hypotension and reduced cardiac output — caution in decompensated heart failure.',
   'Administrar lentamente (≤ 50 mg/10 min) com monitorização hemodinâmica contínua.',
   'Administer slowly (≤ 50 mg/10 min) with continuous haemodynamic monitoring.',
   'Prontuário Terapêutico INFARMED, 4.3.1.1: "A protamina pode raramente ocasionar reacções anafilácticas..." e "hipotensão grave"; EMC-UK Prosulf SmPC § 4.2/4.4.',
   'Prontuário Terapêutico INFARMED, 4.3.1.1: "Protamine may rarely cause anaphylactic reactions..." and "severe hypotension"; EMC-UK Prosulf SmPC § 4.2/4.4.', 1),
  -- ------------------------------------------------------------------
  -- DEFEROXAMINA — Prontuário ficha DESFERAL (l. 38155)
  -- ------------------------------------------------------------------
  ('deferoxamina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'O complexo ferro-desferoxamina é excretado renal — na insuficiência renal a eliminação é reduzida e o ferro libertado re-distribui-se.',
   'The iron-deferoxamine complex is renally excreted — in renal impairment elimination is reduced and released iron redistributes.',
   'Ajustar dose conforme ferritina e função renal; considerar via IV lenta em hemodiálise (protocolo crónico do alumínio/ferro).',
   'Adjust dose according to ferritin and renal function; consider slow IV route during haemodialysis (chronic iron/aluminium protocol).',
   'Prontuário Terapêutico INFARMED, ficha DESFERAL (doses ajustadas à ferritina; infusão em hemodiálise).',
   'Prontuário Terapêutico INFARMED, DESFERAL monograph (doses adjusted to ferritin; haemodialysis infusion).', 1),
  -- ------------------------------------------------------------------
  -- N-ACETILCISTEÍNA — nefropatia por contraste (precaução)
  -- ------------------------------------------------------------------
  ('n-acetilcisteina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'minor',
   'A NAC é usada profilaticamente na nefropatia por contraste, mas a evidência é incerta — precaução na insuficiência renal (doses ajustadas).',
   'NAC is used prophylactically in contrast-induced nephropathy, but evidence is uncertain — caution in renal impairment (adjusted doses).',
   'Dose ajustada conforme clearance; não substituir hidratação IV por NAC.',
   'Dose adjusted to clearance; do not substitute IV hydration with NAC.',
   'EMC-UK — SmPC N-acetylcysteine (via IV, precauções renais).',
   'EMC-UK — N-acetylcysteine SmPC (IV route, renal precautions).', 1),
  -- ------------------------------------------------------------------
  -- FLUCLOXACILINA — Prontuário 6.1.1 (colestase hepática)
  -- ------------------------------------------------------------------
  ('flucloxacilina', 'colestase_obstrutiva', 'Colestase obstrutiva (obstrução biliar)', 'Obstructive cholestasis (biliary obstruction)',
   'precaution', 'moderate',
   'A flucloxacilina causa colestase hepática idiossincrática grave (com função hepática prévia alterada, risco aumentado) — evitar em doença biliar prévia.',
   'Flucloxacillin causes severe idiosyncratic cholestatic hepatitis (increased risk with pre-existing hepatic dysfunction) — avoid with prior biliary disease.',
   'Excluir doença biliar antes de iniciar; se icterícia surgir durante o tratamento, suspender imediatamente (colestase pode ser tardia e prolongada).',
   'Exclude biliary disease before starting; if jaundice develops during treatment, stop immediately (cholestasis can be late and prolonged).',
   'Prontuário Terapêutico INFARMED, 6.1.1 (flucloxacilina — colestase descrita); EMC-UK Flucloxacillin SmPC 4.4 (aviso hepatotoxicidade).',
   'Prontuário Terapêutico INFARMED, 6.1.1 (flucloxacillin — cholestasis reported); EMC-UK Flucloxacillin SmPC 4.4 (hepatotoxicity warning).', 1),
  -- ------------------------------------------------------------------
  -- ESPECTINOMICINA — Prontuário 7.3 (precauções renais)
  -- ------------------------------------------------------------------
  ('espectinomicina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'minor',
   'A espectinomicina é excretada predominantemente por via renal — precaução na insuficiência renal (sem ajuste formal validado, monitorizar).',
   'Spectinomycin is predominantly renally excreted — caution in renal impairment (no validated formal dose adjustment, monitor).',
   'Considerar alternativas na insuficiência renal grave; monitorizar função renal.',
   'Consider alternatives in severe renal impairment; monitor renal function.',
   'Prontuário Terapêutico INFARMED, 7.3 (espectinomicina — farmacocinética renal).',
   'Prontuário Terapêutico INFARMED, 7.3 (spectinomycin — renal pharmacokinetics).', 1),
  -- ------------------------------------------------------------------
  -- PERMANGANATO — uso externo; precaução dermatológica
  -- ------------------------------------------------------------------
  ('permanganato-potassio', 'deficiencia_g6pd', 'Deficiência de G6PD', 'G6PD deficiency',
   'precaution', 'minor',
   'Em uso prolongado/compressas oclusivas extensas, o permanganato pode causar hemólise oxidativa em doentes com deficiência de G6PD (raro, mas descrito).',
   'With prolonged use/large occlusive compresses, permanganate can cause oxidative haemolysis in G6PD-deficient patients (rare but reported).',
   'Evitar banhos/compressas extensas e prolongadas em doentes com G6PD.',
   'Avoid extensive, prolonged baths/compresses in G6PD-deficient patients.',
   'EMC-UK — Potassium permanganate (BC) tablets/pil: precauções de uso cutâneo; SPS NHS.',
   'EMC-UK — Potassium permanganate (BC) tablets/PIL: cutaneous use precautions; SPS NHS.', 1),
  -- ------------------------------------------------------------------
  -- CIPROTERONA — EMC-UK Co-cyprindiol 9760 § 4.3
  -- ------------------------------------------------------------------
  ('ciproterona', 'doenca_hepatica', 'Doença hepática', 'Liver disease',
   'contraindication', 'moderate',
   'A ciproterona está contra-indicada na doença hepática — metabolismo hepático e hepatotoxicidade (tumores hepáticos benignos descritos com antiandrogénios esteroideus).',
   'Cyproterone is contraindicated in liver disease — hepatic metabolism and hepatotoxicity (benign liver tumours reported with steroidal antiandrogens).',
   'Excluir doença hepática antes de iniciar; monitorizar função hepática se uso prolongado.',
   'Exclude liver disease before starting; monitor liver function with prolonged use.',
   'EMC-UK (MHRA) — SmPC Co-cyprindiol (product/9760) § 4.3 (doença hepática): https://www.medicines.org.uk/emc/product/9760/smpc',
   'EMC-UK (MHRA) — Co-cyprindiol SmPC (product/9760) § 4.3 (liver disease): https://www.medicines.org.uk/emc/product/9760/smpc', 1),
  ('ciproterona', 'trombose_ativa', 'Trombose ativa', 'Active thrombosis',
   'contraindication', 'critical',
   'A ciproterona (com estrogénio, como no Co-cyprindiol) está contra-indicada na doença tromboembólica ativa/história — risco de TEV (a acetato de ciproterona aumenta o risco de TEV mesmo isolada).',
   'Cyproterone (with oestrogen, as in Co-cyprindiol) is contraindicated in active/past thromboembolic disease — VTE risk (cyproterone acetate raises VTE risk even alone).',
   'Excluir história de TVP/EP antes de iniciar; suspender se sinais de TEV surgirem.',
   'Exclude history of DVT/PE before starting; discontinue if VTE signs develop.',
   'EMC-UK (MHRA) — SmPC Co-cyprindiol (product/9760) § 4.3 (TEV): https://www.medicines.org.uk/emc/product/9760/smpc',
   'EMC-UK (MHRA) — Co-cyprindiol SmPC (product/9760) § 4.3 (VTE): https://www.medicines.org.uk/emc/product/9760/smpc', 2)
) AS v(drug_slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en, sort_order)
ON d.slug = v.drug_slug;

-- =====================================================================
-- Exclusões com justificação (ver Prontuário/EMC — regra 13.1 do Fluxo 2):
--   * acido-tranexamico × hemorragia_ativa: o fármaco TRATA hemorragia
--     (não é interação fármaco-doença adversa) — a contraindicação só
--     se aplica a hemorragia com estados hiperfibrinolíticos
--     localizados (ver Prontuário 4.3); não registar.
--   * permanganato-potassio × doenca_hepatica: uso tópico sem absorção
--     sistémica significativa — não aplicável.
--   * piridoxina: sem contraindicações clínicas relevantes além da
--     neuropatia por sobredosagem (não é doença do doente, é efeito do
--     fármaco) — não registar.
--   * gluconato-calcio × hipercalcemia: já registado na BD (060–062),
--     não duplicar.
--   * insulinas × gravidez: a insulina é o padrão-ouro na gravidez
--     diabética — não é interação adversa; não registar.
--   * protamina × trombose_ativa: risco trombótico não documentado no
--     SmPC Prosulf — não registar sem fonte.
--   * espectinomicina × gravidez: segurança não estabelecida mas sem
--     contraindicação formal no SmPC — não registar sem fonte.
-- =====================================================================
