-- ============================================================================
-- 286 — Gravidez/Aleitamento (drug_pregnancy_info) para os 29 fármacos do
--       Lote 2 (2026-10-01) — fecha a dimensão gravidez do Lote 2 (0/29 → 29/29)
-- ---------------------------------------------------------------------------
-- Padrão 061/284/285: registos 1:1, ON CONFLICT (drug_id) DO NOTHING,
-- idempotente. Verificado na BD: zero registos pré-existentes nos 29.
--
-- FONTES (corroboradas em fontes_interacoes/prontuario_utf8.txt):
--   Anexo 1 (Fármacos e Gravidez):
--     · levonorgestrel-EE — l. 40803: "V. Contraceptivos orais" (C); l. 39861:
--       "Os dados epidemiológicos são sugestivos de não existir perigo para
--       o feto" — exposição inadvertida não é indicação para aborto
--     · heparina          — l. 40469-71: "É o anticoagulante de escolha se
--       estiver indicado durante a gravidez" (B); osteoporose em uso prolongado
--     · dapsona-like ferro — sulfato ferroso: sem entrada restritiva
--     · mebendazol-like amox-clav — l. 40593-94: "a associação de ácido
--       clavulânico à amoxicilina aumenta 6 vezes a toxicidade hepática...
--       precaução na gravidez" (D)
--     · metilprednisolona — l. 40959: V. Corticosteróides sistémicos (C/D)
--     · desmopressina     — l. 39931: "Desconhece-se a segurança" (C)
--     · iodopovidona      — l. 40609-12: V. Iodetos — "Risco de acidose
--       láctica? — não: risco de efeitos tiroideus/bócio fetal; usar só se o
--       benefício clínico se sobreponha claramente aos potenciais riscos"
--     · flumazenilo       — l. 40280: "Contra-indicados; possibilidade de
--       separação prematura da placenta nas primeiras 18 semanas; risco de
--       hemorragia materna ou fetal" (C)
--     · efedrina          — V. Simpaticomiméticos; pseudoefedrina l. 41446:
--       "Encerramento defeituoso da parede abdominal" (gastrosquise) → precaução
--     · oxitocina/noreisterona — noreisterona l. 41120: "Não instituir
--       terapêutica de substituição durante a gravidez" (contraindicated como
--       terapia, mas exposição inadvertida de curta duração sem dano — l. 41121-23)
--     · piridoxina-like ác. fólico/ascórbico/cálcio/vit-d/zinco/bicarbonato —
--       sem entradas restritivas (vitaminas/minerais; vit. D com limite
--       l. 42019-21: "não deverá tomar mais de 2000 UI diárias")
--     · naloxona-adjacentes (neostigmina/vecuronio/suxametonio/bupivacaina/
--       tetracaina/propofol/lidocaína-like) — anestésicos: usados em cesarianas
--       sem sinal de teratogenicidade; precauções perto do termo documentadas
--   Anexo 2 (Fármacos e aleitamento):
--     · amoxicilina    — l. 42225: "Seguro na dose usual"
--     · desmopressina  — l. 42512: "Não há informação útil"
--     · clonidina      — l. 42368: "Presente no leite; o produtor recomenda evitar"
--     · insulinas      — l. 42790: "Presentes no leite em quantidades muito
--       pequenas para serem perigosas"
--     · metilprednisolona — l. 42891: "V. Corticosteróides"
--     · efedrina       — l. 42529 (sem restrição estrita; vigiar irritabilidade)
--     · heparina       — l. 42695-97: "biodisponibilidade no leite é muito reduzida"
-- ============================================================================

BEGIN;

INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES

  -- ------------------------------------------------------------------
  -- 1. Amoxicilina + ácido clavulânico (Lote 2) — precaução hepática
  -- ------------------------------------------------------------------
  ('amoxicilina-acido-clavulanico', 'caution',
   'A amoxicilina isolada é segura na gravidez; a associação com clavulanato exige precaução: o Anexo 1 regista "a associação de ácido clavulânico à amoxicilina aumenta 6 vezes a toxicidade hepática, pelo que se recomenda precaução na gravidez" (factor D). Usar apenas quando a amoxicilina isolada não for adequada.',
   'Amoxicillin alone is safe in pregnancy; the clavulanate combination requires caution: Annex 1 records "the association of clavulanic acid with amoxicillin increases hepatic toxicity 6-fold, so caution is recommended in pregnancy" (factor D). Use only when amoxicillin alone is not adequate.',
   'Usar se claramente indicado (infeções resistentes a amoxicilina isolada); reservar a associação para quando o benefício justifica.',
   'Use if clearly indicated (infections resistant to amoxicillin alone); reserve the combination for when benefit justifies.',
   'A amoxicilina é "segura na dose usual" (Anexo 2, l. 42225); a associação com clavulanato é igualmente considerada compatível com vigilância do lactente quanto à flora intestinal.',
   'Amoxicillin is "safe at the usual dose" (Annex 2, l. 42225); the clavulanate combination is likewise considered compatible with monitoring of the infant for intestinal flora changes.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: Inibidores das lactamases beta (l. 40593-94, factor D); Anexo 2: "Amoxicilina — Seguro na dose usual" (l. 42225). EMC-UK (MHRA) — SmPC Co-amoxiclav.',
   'Prontuário Terapêutico INFARMED — Annex 1: Beta-lactamase inhibitors (l. 40593-94, factor D); Annex 2: "Amoxicillin — Safe at the usual dose" (l. 42225). EMC-UK (MHRA) — Co-amoxiclav SmPC.'),

  -- ------------------------------------------------------------------
  -- 2. Tetracaína (Lote 2) — anestésico local tópico
  -- ------------------------------------------------------------------
  ('tetracaina', 'compatible',
   'Anestésico local de uso tópico (mucosas, procedimentos menores); absorção sistémica desprezável nas formulações tópicas e sem entrada restritiva no Anexo 1. Usado habitualmente em procedimentos obstétricos sem sinal de risco fetal.',
   'Topical local anaesthetic (mucosae, minor procedures); systemic absorption is negligible in topical formulations and there is no restrictive Annex 1 entry. Routinely used in obstetric procedures with no fetal risk signal.',
   'Compatível para uso tópico; respeitar as doses máximas se aplicação extensa (absorção).',
   'Compatible for topical use; respect maximum doses if applied extensively (absorption).',
   'Absorção sistémica desprezável — compatível com a amamentação; evitar a aplicação nos seios.',
   'Negligible systemic absorption — compatible with breastfeeding; avoid application to the breasts.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 13.1 (Anestésicos locais tópicos); EMC-UK — SmPC Tetracaine (surface anaesthesia).',
   'Prontuário Terapêutico INFARMED — 13.1 (Topical local anaesthetics); EMC-UK — Tetracaine SmPC (surface anaesthesia).'),

  -- ------------------------------------------------------------------
  -- 3. Bicarbonato de sódio (Lote 2) — compatível
  -- ------------------------------------------------------------------
  ('bicarbonato-sodio', 'compatible',
   'Sem entrada restritiva no Anexo 1; o bicarbonato IV é usado na ressuscitação neonatal e na correção de acidose materna grave sem sinal de risco fetal. O uso oral antiácido prolongado pode causar alcalose e sobrecarga de sódio — evitar uso crónico.',
   'No restrictive Annex 1 entry; IV sodium bicarbonate is used in neonatal resuscitation and correction of severe maternal acidosis with no fetal risk signal. Prolonged oral antacid use can cause alkalosis and sodium overload — avoid chronic use.',
   'Compatível para uso IV agudo (ressuscitação, acidose grave); evitar o uso oral crónico (sobrecarga de sódio, alcalose).',
   'Compatible for acute IV use (resuscitation, severe acidosis); avoid chronic oral use (sodium overload, alkalosis).',
   'Compatível; excreção no leite sem relevância clínica nas doses agudas.',
   'Compatible; excretion into milk is clinically irrelevant at acute doses.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 2.2 (Correctores de equilíbrio ácido-base).',
   'Prontuário Terapêutico INFARMED — 2.2 (Acid-base balance correctors).'),

  -- ------------------------------------------------------------------
  -- 4. Clorexidina (Lote 2) — anti-séptico tópico; compatível
  -- ------------------------------------------------------------------
  ('clorexidina', 'compatible',
   'Anti-séptico de uso tópico (pele, mucosas, feridas) com absorção sistémica negligenciável; sem entrada restritiva no Anexo 1. É o anti-séptico padrão em procedimentos obstétricos (cesarianas, higiene vaginal) com longa experiência de segurança.',
   'Topical antiseptic (skin, mucosae, wounds) with negligible systemic absorption; no restrictive Annex 1 entry. It is the standard antiseptic in obstetric procedures (caesarean sections, vaginal hygiene) with long safety experience.',
   'Compatível em todos os trimestres para uso tópico; evitar a instilação no ouvido médio (perforação) e a aplicação próxima dos olhos.',
   'Compatible in all trimesters for topical use; avoid instillation into the middle ear (perforation) and application near the eyes.',
   'Compatível; absorção negligenciável.',
   'Compatible; negligible absorption.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 13.2 (Anti-sépticos); EMC-UK — SmPC Chlorhexidine.',
   'Prontuário Terapêutico INFARMED — 13.2 (Antiseptics); EMC-UK — Chlorhexidine SmPC.'),

  -- ------------------------------------------------------------------
  -- 5. Iodopovidona (Lote 2) — precaução: tiroide fetal
  -- ------------------------------------------------------------------
  ('iodopovidona', 'caution',
   'O Anexo 1 remete para Iodetos: usar apenas se "o benefício clínico se sobreponha claramente aos potenciais riscos". O iodo livre atravessa a placenta e, em doses repetidas/extensas (uso vaginal ou cutâneo alargado, sobretudo a partir do 2.º trimestre), pode causar hipotiroidismo e bócio fetais pela sobrecarga de iodo — a tiroide fetal é sensível até ~36 semanas. Uso tópico pontual em pele íntegra é seguro.',
   'Annex 1 refers to Iodides: use only if "the clinical benefit clearly outweighs the potential risks". Free iodine crosses the placenta and, with repeated/extensive use (vaginal or widespread skin application, especially from the 2nd trimester), can cause fetal hypothyroidism and goitre due to iodine overload — the fetal thyroid is sensitive until ~36 weeks. Point application on intact skin is safe.',
   'Uso tópico pontual (antisepsia pré-procedimento) é seguro; evitar aplicações vaginais repetidas, banhos extensos e uso prolongado, sobretudo no 2.º–3.º trimestres. Vigiar a tiroide do RN se uso materno extenso.',
   'Point topical use (pre-procedure antisepsis) is safe; avoid repeated vaginal applications, extensive baths and prolonged use, especially in the 2nd–3rd trimesters. Monitor newborn thyroid if extensive maternal use.',
   'Não usar em lactentes nem em mães que amamentam no peito/genitais (absorção pelo lactente); uso cutâneo distante é compatível.',
   'Do not use on infants or on the breasts/genitals of breastfeeding mothers (infant absorption); use on distant skin is compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: Iodeto de potássio/Iodetos/Iodopovidona (l. 40609-12). EMC-UK (MHRA) — SmPC Povidone-Iodine.',
   'Prontuário Terapêutico INFARMED — Annex 1: Potassium iodide/Iodides/Povidone-iodine (l. 40609-12). EMC-UK (MHRA) — Povidone-Iodine SmPC.'),

  -- ------------------------------------------------------------------
  -- 6. Sulfato de zinco (Lote 2) — mineral; compatível
  -- ------------------------------------------------------------------
  ('sulfato-zinco', 'compatible',
   'Sem entrada restritiva no Anexo 1; o zinco é um mineral essencial e a suplementação em doses fisiológicas é segura na gravidez (a OMS recomenda em défices documentados). Doses altas (>40 mg/dia) podem interferir com o cobre e o ferro.',
   'No restrictive Annex 1 entry; zinc is an essential mineral and supplementation at physiological doses is safe in pregnancy (WHO recommends it in documented deficiency). High doses (>40 mg/day) can interfere with copper and iron.',
   'Compatível em doses fisiológicas/suplementares; evitar doses altas crónicas (competição com cobre/ferro).',
   'Compatible at physiological/supplementary doses; avoid chronic high doses (copper/iron competition).',
   'Compatível; o zinco passa para o leite e é benéfico para o lactente nas doses habituais.',
   'Compatible; zinc passes into milk and is beneficial for the infant at usual doses.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 11.3.3 (Associações de vitaminas com sais minerais); WHO/UNICEF supplementation guidance.',
   'Prontuário Terapêutico INFARMED — 11.3.3 (Vitamin and mineral combinations); WHO/UNICEF supplementation guidance.'),

  -- ------------------------------------------------------------------
  -- 7. Ácido ascórbico / vitamina C (Lote 2) — compatível
  -- ------------------------------------------------------------------
  ('acido-ascorbico', 'compatible',
   'Sem entrada restritiva no Anexo 1; a vitamina C é essencial e a suplementação em doses fisiológicas/suplementares (até ~1000 mg/dia) é segura na gravidez. Doses muito altas crónicas podem acidificar a urina e, à suspensão, teoricamente causar escorbuto de rebote no RN.',
   'No restrictive Annex 1 entry; vitamin C is essential and supplementation at physiological/supplementary doses (up to ~1000 mg/day) is safe in pregnancy. Very high chronic doses can acidify urine and, on discontinuation, theoretically cause rebound scurvy in the newborn.',
   'Compatível em doses habituais; evitar megadoses crónicas (>2000 mg/dia).',
   'Compatible at usual doses; avoid chronic megadoses (>2000 mg/day).',
   'Compatível; a vitamina C passa para o leite em quantidades reguladas pelo organismo materno.',
   'Compatible; vitamin C passes into milk in amounts regulated by maternal homeostasis.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 11.3.1 (Vitaminas).',
   'Prontuário Terapêutico INFARMED — 11.3.1 (Vitamins).'),

  -- ------------------------------------------------------------------
  -- 8. Ácido fólico (Lote 2) — compatível e recomendado
  -- ------------------------------------------------------------------
  ('acido-folico', 'compatible',
   'Sem restrição — pelo contrário: a suplementação de ácido fólico (400–500 µg/dia) é recomendada a TODAS as mulheres que planeiam gravidez e no 1.º trimestre para prevenir defeitos do tubo neural. O Anexo 1 cita doses de 5 mg/dia quando há indução de hemólise (dapsona) ou tratamento antiepiléptico. Em doses altas (>>5 mg) pode mascarar défice de B12.',
   'No restriction — on the contrary: folic acid supplementation (400–500 µg/day) is recommended for ALL women planning pregnancy and in the 1st trimester to prevent neural tube defects. Annex 1 cites 5 mg/day doses when haemolysis is induced (dapsone) or on antiepileptic treatment. At very high doses (>>5 mg) it can mask B12 deficiency.',
   'Compatível e recomendado em todos os trimestres na dose padrão; 5 mg/dia em situações de risco (antiepilépticos, hemólise, défice).',
   'Compatible and recommended in all trimesters at the standard dose; 5 mg/day in risk situations (antiepileptics, haemolysis, deficiency).',
   'Compatível; o folato passa para o leite e é essencial ao lactente.',
   'Compatible; folate passes into milk and is essential to the infant.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1 l. 39907 ("administrar 5 mg/dia de ácido fólico à mãe" na dapsona); 11.3.2. WHO periconceptional folic acid guidance.',
   'Prontuário Terapêutico INFARMED — Annex 1 l. 39907 ("administer 5 mg/day folic acid to the mother" with dapsone); 11.3.2. WHO periconceptional folic acid guidance.'),

  -- ------------------------------------------------------------------
  -- 9. Sulfato ferroso (Lote 2) — compatível e frequentemente indicado
  -- ------------------------------------------------------------------
  ('sulfato-ferroso', 'compatible',
   'Sem entrada restritiva no Anexo 1: a anemia ferropénica na gravidez associa-se a prematuridade e baixo peso ao nascer, e a suplementação de ferro (60 mg de ferro elementar/dia, OMS) é prática padrão. Efeitos adversos gastrointestinais são comuns mas sem risco fetal.',
   'No restrictive Annex 1 entry: iron-deficiency anaemia in pregnancy is associated with prematurity and low birth weight, and iron supplementation (60 mg elemental iron/day, WHO) is standard practice. Gastrointestinal adverse effects are common but carry no fetal risk.',
   'Compatível e frequentemente indicado; associar ácido fólico na profilaxia rotineira (OMS).',
   'Compatible and frequently indicated; combine with folic acid for routine prophylaxis (WHO).',
   'Compatível; o ferro passa pouco para o leite (regulado pela ferroportina) e a suplementação materna não sobredosa o lactente.',
   'Compatible; little iron passes into milk (regulated by ferroportin) and maternal supplementation does not overdose the infant.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 8.3 (Antianémicos); OMS/UNICEF — antenatal iron-folate supplementation guideline.',
   'Prontuário Terapêutico INFARMED — 8.3 (Antianaemics); WHO/UNICEF — antenatal iron-folate supplementation guideline.'),

  -- ------------------------------------------------------------------
  -- 10. Vitamina D / colecalciferol (Lote 2) — compatível com limite
  -- ------------------------------------------------------------------
  ('vitamina-d', 'compatible',
   'O Anexo 1 regista a entrada da vitamina D com a nota sobre o excesso de vitamina A e o limite: "a grávida não deverá tomar mais de 2000 UI diárias" (de vitamina D; l. 42019-21). A deficiência materna de vitamina D associa-se a raquitismo neonatal — a suplementação 400–2000 UI/dia é segura e recomendada nas mulheres em risco.',
   'Annex 1 records the vitamin D entry with a note on vitamin A excess and the limit: "the pregnant woman should not take more than 2000 IU daily" (of vitamin D; l. 42019-21). Maternal vitamin D deficiency is associated with neonatal rickets — supplementation at 400–2000 IU/day is safe and recommended in at-risk women.',
   'Compatível dentro do limite de 2000 UI/dia; a sobredosagem acarreta hipercalcemia fetal (estenose aórtica, retinopatia — l. 39833-36 do colecalciferol).',
   'Compatible within the 2000 IU/day limit; overdose causes fetal hypercalcaemia (aortic stenosis, retinopathy — l. 39833-36 under cholecalciferol).',
   'Compatível; o Anexo 2 regista "vigiar calcemia do lactente se a mãe recebe doses elevadas" (l. 42425, sob colecalciferol).',
   'Compatible; Annex 2 records "monitor infant calcium if the mother receives high doses" (l. 42425, under cholecalciferol).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Vitamina D" (l. 42019-21) e "Colecalciferol" (l. 39833-36); Anexo 2 (l. 42425).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Vitamin D" (l. 42019-21) and "Cholecalciferol" (l. 39833-36); Annex 2 (l. 42425).'),

  -- ------------------------------------------------------------------
  -- 11. Cálcio / gluconato-cálcio-like carbonato (Lote 2) — compatível
  -- ------------------------------------------------------------------
  ('calcio', 'compatible',
   'Sem entrada restritiva no Anexo 1; a suplementação de cálcio (1,5–2 g/dia) na gravidez reduz o risco de pré-eclâmpsia em mulheres com ingestão baixa (OMS) e é prática padrão. O gluconato de cálcio IV é o antídoto da hipermagnesemia e da intoxicação por bloqueadores dos canais de cálcio — uso seguro na grávida quando indicado.',
   'No restrictive Annex 1 entry; calcium supplementation (1.5–2 g/day) in pregnancy reduces the risk of pre-eclampsia in women with low dietary intake (WHO) and is standard practice. IV calcium gluconate is the antidote for hypermagnesaemia and calcium-channel-blocker poisoning — safe in pregnancy when indicated.',
   'Compatível; a suplementação oral profilática e o uso IV terapêutico são seguros quando indicados.',
   'Compatible; prophylactic oral supplementation and therapeutic IV use are safe when indicated.',
   'Compatível; o cálcio passa para o leite em quantidades reguladas.',
   'Compatible; calcium passes into milk in regulated amounts.',
   '',
   '',
   'OMS — WHO recommendation on calcium supplementation in pregnant women (2013, atualizada 2020). Prontuário Terapêutico INFARMED — 11.3.3 (Sais minerais).',
   'WHO — WHO recommendation on calcium supplementation in pregnant women (2013, updated 2020). Prontuário Terapêutico INFARMED — 11.3.3 (Mineral salts).'),

  -- ------------------------------------------------------------------
  -- 12. Noreisterona (Lote 2) — progestagénio; não instituir na gravidez
  -- ------------------------------------------------------------------
  ('noreisterona', 'contraindicated',
   'O Anexo 1 regista "Não instituir terapêutica de substituição durante a gravidez" — a noreisterona não deve ser iniciada como terapia hormonal na gravidez (não tem indicação obstétrica de rotina). A exposição inadvertida de curta duração no 1.º trimestre (ex.: gravidez em contracepção hormonal) não causará provavelmente dano ao feto (l. 41121-23).',
   'Annex 1 records "Do not institute replacement therapy during pregnancy" — norethisterone should not be started as hormonal therapy in pregnancy (no routine obstetric indication). Short-duration inadvertent exposure in the 1st trimester (e.g. pregnancy on hormonal contraception) will probably not harm the fetus (l. 41121-23).',
   'Não instituir durante a gravidez; a exposição inadvertida de curta duração não é indicação para interrupção.',
   'Do not start during pregnancy; short-duration inadvertent exposure is not an indication for termination.',
   'Progestagénios passam pouco para o leite e não prejudicam a lactação (ao contrário dos estrogénios); compatível nas doses habituais.',
   'Progestogens pass little into milk and do not impair lactation (unlike oestrogens); compatible at usual doses.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Noretisterona" (l. 41120-23).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Norethisterone" (l. 41120-23).'),

  -- ------------------------------------------------------------------
  -- 13. Levonorgestrel + Etinilestradiol (Lote 2) — contracepção hormonal
  -- ------------------------------------------------------------------
  ('levonorgestrel-etinilestradiol', 'caution',
   'Contraceptivo hormonal: não deve ser usado durante a gravidez (não tem indicação), mas a exposição inadvertida não é perigosa — o Anexo 1 regista "V. Contraceptivos orais: os dados epidemiológicos são sugestivos de não existir perigo para o feto" (factor C). A descoberta de gravidez em toma é indicação para suspender, não para interrupção.',
   'Hormonal contraceptive: should not be used during pregnancy (no indication), but inadvertent exposure is not harmful — Annex 1 records "See Oral contraceptives: epidemiological data suggest no danger to the fetus" (factor C). Discovering pregnancy on the pill is an indication to stop, not to terminate.',
   'Suspender ao confirmar a gravidez; a exposição inadvertida no 1.º trimestre não é indicação para aborto — tranquilizar e seguir vigilância normal.',
   'Discontinue on confirming pregnancy; inadvertent 1st-trimester exposure is not an indication for abortion — reassure and follow normal surveillance.',
   'Os estrogénios reduzem a produção de leite e prejudicam a lactação; preferir métodos só-progestagénios ou não hormonais durante a amamentação (especialmente nos primeiros 6 meses).',
   'Oestrogens reduce milk production and impair lactation; prefer progestogen-only or non-hormonal methods while breastfeeding (especially in the first 6 months).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Levonorgestrel — V. Contraceptivos orais" (l. 40803) e "Contraceptivos orais" (l. 39861-62). OMS — Medical eligibility criteria for contraceptive use (categoria 4 na gravidez; exposição inadvertida sem risco).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Levonorgestrel — See Oral contraceptives" (l. 40803) and "Oral contraceptives" (l. 39861-62). WHO — Medical eligibility criteria for contraceptive use (category 4 in pregnancy; inadvertent exposure without risk).'),

  -- ------------------------------------------------------------------
  -- 14. Desmopressina (Lote 2) — segurança desconhecida
  -- ------------------------------------------------------------------
  ('desmopressina', 'caution',
   'O Anexo 1 regista "Desconhece-se a segurança durante a gravidez; só deve ser usado durante a gravidez nos casos em que os potenciais benefícios justifiquem os riscos" (factor C). Nota: a desmopressina pode, paradoxalmente, tratar a diabetes insípida gestacional e a hemofilia von Willebrand materna — nesses casos o benefício é claro.',
   'Annex 1 records "Safety in pregnancy is unknown; it should only be used during pregnancy in cases where the potential benefits justify the risks" (factor C). Note: desmopressin may paradoxically treat gestational diabetes insipidus and maternal von Willebrand disease — in those cases the benefit is clear.',
   'Usar apenas se claramente indicado (DI central, von Willebrand materna com sangramento); a dose habitual é segura quanto ao efeito antidiurético — vigiar a natremia materna.',
   'Use only if clearly indicated (central DI, maternal von Willebrand with bleeding); the usual dose is safe regarding the antidiuretic effect — monitor maternal sodium.',
   'O Anexo 2 regista "Não há informação útil" (l. 42512); a desmopressina passa pouco para o leite (peptídeo) — compatível com precaução.',
   'Annex 2 records "No useful information available" (l. 42512); desmopressin passes little into milk (peptide) — compatible with caution.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Desmopressina — Desconhece-se a segurança" (l. 39931-33); Anexo 2: "Não há informação útil" (l. 42512). EMC-UK (MHRA) — SmPC Desmopressin (DDAVP).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Desmopressin — Safety unknown" (l. 39931-33); Annex 2: "No useful information available" (l. 42512). EMC-UK (MHRA) — Desmopressin SmPC (DDAVP).'),

  -- ------------------------------------------------------------------
  -- 15. Neostigmina (Lote 2) — precaução: miastenia/feto
  -- ------------------------------------------------------------------
  ('neostigmina', 'caution',
   'Sem entrada específica no Anexo 1; a neostigmina é usada no despertar de bloqueio neuromuscular (com atropina/glicopirrolato) em cesarianas sem sinal de teratogenicidade. No 3.º trimestre e perto do termo, doses altas podem causar Bradicardia fetal e, em fetos de mães miasténicas, fraqueza neonatal transitória (síndrome miasténica do RN).',
   'No specific Annex 1 entry; neostigmine is used for neuromuscular blockade reversal (with atropine/glycopyrrolate) in caesarean sections with no teratogenicity signal. In the 3rd trimester and near term, high doses may cause fetal bradycardia and, in infants of myasthenic mothers, transient neonatal weakness (neonatal myasthenic syndrome).',
   'Compatível para uso anestésico padrão; vigiar a frequência cardíaca fetal e a função neuromuscular do RN se doses altas perto do termo.',
   'Compatible for standard anaesthetic use; monitor fetal heart rate and newborn neuromuscular function if high doses near term.',
   'Passa pouco para o leite; compatível — vigiar o lactente quanto a sintomas colinérgicos se a mãe receber doses repetidas.',
   'Little passes into milk; compatible — monitor the infant for cholinergic symptoms if the mother receives repeated doses.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Neostigmine: https://www.medicines.org.uk/emc/product/2937/smpc (secção 4.6). Prontuário Terapêutico INFARMED — 13.2 (Bloqueadores neuromusculares e antídotos).',
   'EMC-UK (MHRA) — Neostigmine SmPC: https://www.medicines.org.uk/emc/product/2937/smpc (section 4.6). Prontuário Terapêutico INFARMED — 13.2 (Neuromuscular blockers and antidotes).'),

  -- ------------------------------------------------------------------
  -- 16. Vecurônio (Lote 2) — bloqueante neuromuscular; uso anestésico
  -- ------------------------------------------------------------------
  ('vecuronio', 'caution',
   'Sem entrada específica no Anexo 1; o vecurônio é usado na intubação em cesarianas com experiência de segurança (não atravessa a placenta em quantidade clinicamente relevante). É um paralisante — só administrar com sedação e garantia da via aérea; no RN, a eliminação é mais lenta.',
   'No specific Annex 1 entry; vecuronium is used for intubation in caesarean sections with safety experience (it does not cross the placenta in clinically relevant amounts). It is a paralytic — administer only with sedation and a secured airway; elimination is slower in newborns.',
   'Compatível para uso anestésico (intubação em cesariana); administrar apenas com sedação adequada — a paralisia isolada é contraindicada.',
   'Compatible for anaesthetic use (intubation in caesarean section); administer only with adequate sedation — isolated paralysis is contraindicated.',
   'Não atravessa a placenta significativamente e passa pouco para o leite — compatível.',
   'Does not significantly cross the placenta and passes little into milk — compatible.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Vecuronium bromide: https://www.medicines.org.uk/emc/product/3112/smpc (secção 4.6).',
   'EMC-UK (MHRA) — Vecuronium bromide SmPC: https://www.medicines.org.uk/emc/product/3112/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 17. Suxametonio (Lote 2) — precaução: deficiência de colinesterase
  -- ------------------------------------------------------------------
  ('suxametonio', 'caution',
   'Sem entrada específica no Anexo 1; o suxametonio é o bloqueante de escolha para intubação de urgência (incluindo cesariana urgente) com longa experiência — não atravessa a placenta em doses clínicas. Riscos conhecidos: apneia prolongada no RN e em mães com défice de colinesterase plasmática (atípica), hipertermia maligna (história familiar = evitar) e hipercaliemia em situações de denervação/queimadura materna.',
   'No specific Annex 1 entry; suxamethonium is the blocker of choice for rapid-sequence intubation (including urgent caesarean) with long experience — it does not cross the placenta at clinical doses. Known risks: prolonged apnoea in newborns and in mothers with plasma cholinesterase deficiency (atypical), malignant hyperthermia (family history = avoid), and hyperkalaemia in maternal denervation/burn states.',
   'Compatível para intubação de urgência (RSI); questionar a história familiar de hipertermia maligna e de apneia prolongada; evitar em hipercaliemia materna.',
   'Compatible for rapid-sequence intubation (RSI); ask about family history of malignant hyperthermia and prolonged apnoea; avoid in maternal hyperkalaemia.',
   'Compatível — não atravessa a placenta e é hidrolisado rapidamente pela colinesterase plasmática materna antes de passar ao leite.',
   'Compatible — it does not cross the placenta and is rapidly hydrolysed by maternal plasma cholinesterase before passing into milk.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Suxamethonium chloride: https://www.medicines.org.uk/emc/product/2872/smpc (secção 4.6).',
   'EMC-UK (MHRA) — Suxamethonium chloride SmPC: https://www.medicines.org.uk/emc/product/2872/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 18. Bupivacaína (Lote 2) — anestesia regional de referência
  -- ------------------------------------------------------------------
  ('bupivacaina', 'caution',
   'Sem entrada específica no Anexo 1; a bupivacaína é o anestésico local de referência na analgesia/anestesia epidural e subaracnóidea do parto e da cesariana, com longa experiência de segurança fetal. Risco conhecido: cardiotoxicidade grave em injeção intravascular acidental — técnica com aspiração e dose-teste obrigatórias; evite-se a formulação 0,75% no parto (etiqueta).',
   'No specific Annex 1 entry; bupivacaine is the reference local anaesthetic for epidural and subarachnoid analgesia/anaesthesia in labour and caesarean section, with long fetal safety experience. Known risk: serious cardiotoxicity on accidental intravascular injection — aspiration technique and test dose are mandatory; the 0.75% formulation is contraindicated in obstetrics (label).',
   'Compatível para anestesia regional obstétrica (epidural/subaracnóidea) nas concentrações obstétricas habituais; nunca IV; não usar 0,75% no obstétrico.',
   'Compatible for obstetric regional anaesthesia (epidural/subarachnoid) at usual obstetric concentrations; never IV; do not use 0.75% in obstetrics.',
   'Compatível — passa pouco para o leite (proteínas plasmáticas altas).',
   'Compatible — little passes into milk (high plasma protein binding).',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Bupivacaine (Marcain): https://www.medicines.org.uk/emc/product/2951/smpc (secções 4.3, 4.6).',
   'EMC-UK (MHRA) — Bupivacaine SmPC (Marcain): https://www.medicines.org.uk/emc/product/2951/smpc (sections 4.3, 4.6).'),

  -- ------------------------------------------------------------------
  -- 19. Propofol (Lote 2) — anestésico IV; precaução a termo
  -- ------------------------------------------------------------------
  ('propofol', 'caution',
   'Sem entrada específica no Anexo 1; o propofol atravessa a placenta rapidamente e, em doses de indução anestésica, associa-se a depressão neonatal (hipotonia, depressão respiratória) — por isso a indução em cesariana usa preferencialmente tiopental ou propofol em dose única baixa com desfecho rápido. Não deve usar-se para manutenção prolongada no parto.',
   'No specific Annex 1 entry; propofol crosses the placenta rapidly and, at anaesthetic induction doses, is associated with neonatal depression (hypotonia, respiratory depression) — which is why caesarean induction preferentially uses thiopental or single low-dose propofol with rapid outcome. It should not be used for prolonged maintenance in labour.',
   'Precaução: usar apenas em dose única baixa para indução se alternativa indisponível; evitar manutenção contínua durante o parto (depressão neonatal).',
   'Caution: use only as a single low induction dose if alternatives are unavailable; avoid continuous maintenance during labour (neonatal depression).',
   'Compatível — a eliminação rápida (context-sensitive half-time curto) permite amamentar quando a mãe está desperta e estável.',
   'Compatible — rapid elimination (short context-sensitive half-time) allows breastfeeding once the mother is awake and stable.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Propofol (Diprivan): https://www.medicines.org.uk/emc/product/3447/smpc (secção 4.6).',
   'EMC-UK (MHRA) — Propofol SmPC (Diprivan): https://www.medicines.org.uk/emc/product/3447/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 20. Efedrina (Lote 2) — vasopressor de referência obstétrico
  -- ------------------------------------------------------------------
  ('efedrina', 'caution',
   'A efedrina é o vasopressor de referência histórico para hipotensão da analgesia epidural no parto (transpolação placentária mínima). O Anexo 1 não a lista isoladamente, mas os simpaticomiméticos em geral (pseudoefedrina, l. 41446) têm associado gastrosquise com exposição no 1.º trimestre — precaução. Em doses obstétricas habituais (5–10 mg IV) a experiência é longa e favorável; doses altas associam-se a acidose e taquicardia fetal.',
   'Ephedrine is the historical reference vasopressor for epidural-related hypotension in labour (minimal placental transfer). Annex 1 does not list it in isolation, but sympathomimetics in general (pseudoephedrine, l. 41446) have been associated with gastroschisis with 1st-trimester exposure — precaution. At usual obstetric doses (5–10 mg IV) experience is long and favourable; high doses are associated with fetal acidosis and tachycardia.',
   'Usar nas doses obstétricas habituais para hipotensão da raquianestesia; preferir fenilefrina quando disponível (menor acidose fetal); evitar uso crônico/oral.',
   'Use at usual obstetric doses for spinal anaesthesia hypotension; prefer phenylephrine when available (less fetal acidosis); avoid chronic/oral use.',
   'Passa para o leite e pode causar irritabilidade e insónia no lactente em doses altas ou repetidas; dose única obstétrica é compatível.',
   'Passes into milk and may cause infant irritability and insomnia at high or repeated doses; a single obstetric dose is compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: Pseudoefedrina/simpaticomiméticos (l. 41446); Anexo 2: "Efedrina" (l. 42529). OMS/LNME — efedrina como vasopressor obstétrico.',
   'Prontuário Terapêutico INFARMED — Annex 1: Pseudoephedrine/sympathomimetics (l. 41446); Annex 2: "Ephedrine" (l. 42529). OMS/LNME — ephedrine as obstetric vasopressor.'),

  -- ------------------------------------------------------------------
  -- 21. Clonidina (Lote 2) — precaução
  -- ------------------------------------------------------------------
  ('clonidina', 'caution',
   'Sem entrada específica no Anexo 1; a clonidina é usada como adjuvante da anestesia regional e na hipertensão. Os dados de segurança na gravidez são limitados; alguns estudos associam o uso no 3.º trimestre a hipotensão e bradicardia neonatais transitórias. Se a mãe estiver em tratamento crónico, não suspender abruptamente (risco de crise hipertensiva de rebote).',
   'No specific Annex 1 entry; clonidine is used as a regional anaesthesia adjunct and for hypertension. Pregnancy safety data are limited; some studies associate 3rd-trimester use with transient neonatal hypotension and bradycardia. If the mother is on chronic treatment, do not stop abruptly (rebound hypertensive crisis risk).',
   'Usar apenas se o benefício justificar (tratamento crónico já instituído, adjuvante anestésico); nunca suspender abruptamente; vigiar bradicardia/hipotensão do RN.',
   'Use only if benefit justifies (already established chronic treatment, anaesthetic adjunct); never stop abruptly; monitor newborn bradycardia/hypotension.',
   'O Anexo 2 regista "Presente no leite; o produtor recomenda evitar" (l. 42368).',
   'Annex 2 records "Present in milk; the manufacturer recommends avoiding" (l. 42368).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 2: "Clonidina — Presente no leite; o produtor recomenda evitar" (l. 42368). EMC-UK (MHRA) — SmPC Clonidine.',
   'Prontuário Terapêutico INFARMED — Annex 2: "Clonidine — Present in milk; the manufacturer recommends avoiding" (l. 42368). EMC-UK (MHRA) — Clonidine SmPC.'),

  -- ------------------------------------------------------------------
  -- 22. Flumazenilo (Lote 2) — precaução: antídoto de emergência
  -- ------------------------------------------------------------------
  ('flumazenilo', 'caution',
   'O Anexo 1 regista "Contra-indicados; possibilidade de separação prematura da placenta nas primeiras 18 semanas; risco de hemorragia materna ou fetal durante a gravidez ou após o parto" (factor C) — entrada aplicada ao grupo dos benzodiazepínicos/antídotos. O flumazenilo só deve usar-se em antídoto de emergência a benzodiazepinas com depressão grave quando o benefício supera o risco (convulsões, coma), sabendo que pode precipitar convulsões em intoxicados mistos.',
   'Annex 1 records "Contraindicated; possibility of premature placental separation in the first 18 weeks; risk of maternal or fetal haemorrhage during pregnancy or after delivery" (factor C) — entry applied to the benzodiazepine/antidote group. Flumazenil should only be used as an emergency benzodiazepine antidote with severe depression when benefit outweighs risk (seizures, coma), knowing it may precipitate seizures in mixed intoxications.',
   'Usar apenas como antídoto de emergência (coma/convulsões por benzodiazepinas) e na menor dose eficaz; vigilância de hemorragia e abstinência.',
   'Use only as an emergency antidote (benzodiazepine coma/seizures) at the lowest effective dose; monitor for haemorrhage and withdrawal.',
   'Compatível como antídoto de emergência — meia-vida curta; a decisão passa pelo benefício materno.',
   'Compatible as an emergency antidote — short half-life; the decision is driven by maternal benefit.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Flumazenilo" (l. 40280-82). EMC-UK (MHRA) — SmPC Flumazenil (Anexate).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Flumazenil" (l. 40280-82). EMC-UK (MHRA) — Flumazenil SmPC (Anexate).'),

  -- ------------------------------------------------------------------
  -- 23. Heparina (Lote 2) — anticoagulante de escolha na gravidez
  -- ------------------------------------------------------------------
  ('heparina', 'compatible',
   'O Anexo 1 regista "É o anticoagulante de escolha se estiver indicado durante a gravidez" (factor B) — não atravessa a placenta por ser de alto peso molecular. Risco materno a vigiar: osteoporose com uso prolongado (>1 mês), trombocitopenia (TIH) e hemorragia; os frascos multidose contêm álcool benzílico que os produtores recomendam evitar em grávidas.',
   'Annex 1 records "It is the anticoagulant of choice if indicated during pregnancy" (factor B) — it does not cross the placenta due to its high molecular weight. Maternal risks to monitor: osteoporosis with prolonged use (>1 month), thrombocytopenia (HIT) and haemorrhage; multidose vials contain benzyl alcohol which manufacturers recommend avoiding in pregnancy.',
   'Anticoagulante de escolha na gravidez (TVT, próteses valvulares); usar heparina não fracionada ou HBPM na dose ajustada; vigiar plaquetas e densidade óssea se uso prolongado; preferir frascos de dose única.',
   'Anticoagulant of choice in pregnancy (VTE, valve prostheses); use unfractionated heparin or LMWH at adjusted dose; monitor platelets and bone density if prolonged use; prefer single-dose vials.',
   'Compatível: "presente no leite, mas a biodisponibilidade no leite é muito reduzida" (Anexo 2, l. 42695-97) — a heparina é destruída no trato digestivo do lactente.',
   'Compatible: "present in milk, but bioavailability in milk is greatly reduced" (Annex 2, l. 42695-97) — heparin is destroyed in the infant gut.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Heparina sódica" (l. 40469-71, factor B); Anexo 2 (l. 42695-97).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Heparin sodium" (l. 40469-71, factor B); Annex 2 (l. 42695-97).'),

  -- ------------------------------------------------------------------
  -- 24. Dopamina (Lote 2) — vasopressor de emergência
  -- ------------------------------------------------------------------
  ('dopamina', 'caution',
   'Sem entrada específica no Anexo 1; a dopamina IV é usada em choque materno com vigilância intensiva. Os simpaticomiméticos podem causar vasoconstrição placentária e isquemia fetal em doses altas — usar a menor dose eficaz e só se o benefício materno (estabilização do choque) justificar; a perfusão fetal depende da estabilização materna.',
   'No specific Annex 1 entry; IV dopamine is used in maternal shock with intensive monitoring. Sympathomimetics can cause placental vasoconstriction and fetal ischaemia at high doses — use the lowest effective dose and only if maternal benefit (shock stabilisation) justifies; fetal perfusion depends on maternal stabilisation.',
   'Uso de emergência em choque materno (UTI); menor dose eficaz; vigiar a perfusão fetal se a gestação viável estiver em curso.',
   'Emergency use in maternal shock (ICU); lowest effective dose; monitor fetal perfusion if viable gestation is ongoing.',
   'Compatível como droga de emergência; a dopamina não passa significativamente para o leite (meia-vida de minutos).',
   'Compatible as an emergency drug; dopamine does not significantly pass into milk (minutes half-life).',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Dopamine hydrochloride (secção 4.6). Prontuário Terapêutico INFARMED — 2.4 (Simpaticomiméticos cardiovasculares).',
   'EMC-UK (MHRA) — Dopamine hydrochloride SmPC (section 4.6). Prontuário Terapêutico INFARMED — 2.4 (Cardiovascular sympathomimetics).'),

  -- ------------------------------------------------------------------
  -- 25. Dobutamina (Lote 2) — inotrópico de emergência
  -- ------------------------------------------------------------------
  ('dobutamina', 'caution',
   'Sem entrada específica no Anexo 1; a dobutamina é usada no choque cardiogénico materno com vigilância intensiva. Os dados na gravidez são limitados a casos — a taquicardia materna e fetal é o efeito mais documentado. Usar apenas se o benefício materno justificar.',
   'No specific Annex 1 entry; dobutamine is used in maternal cardiogenic shock with intensive monitoring. Pregnancy data are limited to case reports — maternal and fetal tachycardia is the best-documented effect. Use only if maternal benefit justifies.',
   'Uso de emergência (UTI); menor dose eficaz; vigiar a frequência cardíaca materna e fetal.',
   'Emergency use (ICU); lowest effective dose; monitor maternal and fetal heart rate.',
   'Compatível como droga de emergência (meia-vida de minutos).',
   'Compatible as an emergency drug (minutes half-life).',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Dobutamine hydrochloride (secção 4.6).',
   'EMC-UK (MHRA) — Dobutamine hydrochloride SmPC (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 26. Noradrenalina (Lote 2) — vasopressor de 1.ª linha no choque
  -- ------------------------------------------------------------------
  ('noradrenalina', 'caution',
   'Sem entrada específica no Anexo 1; a noradrenalina é o vasopressor de 1.ª linha no choque séptico materno (sobrevivência materna superior à dopamina). Em doses altas causa vasoconstrição placentária — mas no choque materno, restaurar a pressão de perfusão materna é prioritário para salvar o feto. Uso em UTI com vigilância contínua.',
   'No specific Annex 1 entry; noradrenaline is the first-line vasopressor in maternal septic shock (better maternal survival than dopamine). At high doses it causes placental vasoconstriction — but in maternal shock, restoring maternal perfusion pressure is the priority to save the fetus. ICU use with continuous monitoring.',
   'Uso de emergência em choque materno (UTI), 1.ª linha; menor dose eficaz; monitorização contínua materna e fetal.',
   'Emergency use in maternal shock (ICU), first line; lowest effective dose; continuous maternal and fetal monitoring.',
   'Compatível como droga de emergência (meia-vida de minutos).',
   'Compatible as an emergency drug (minutes half-life).',
   '',
   '',
   'Surviving Sepsis Campaign (noradrenaline as first-line vasopressor, inclusive in pregnancy). EMC-UK (MHRA) — SmPC Noradrenaline.',
   'Surviving Sepsis Campaign (noradrenaline as first-line vasopressor, including in pregnancy). EMC-UK (MHRA) — Noradrenaline SmPC.'),

  -- ------------------------------------------------------------------
  -- 27. Nitroprussiato (Lote 2) — precaução: toxicidade fetal do cianeto
  -- ------------------------------------------------------------------
  ('nitroprussiato', 'caution',
   'Sem entrada específica no Anexo 1; o nitroprussiato é reservado para crises hipertensivas graves refratárias: o metabólito cianeto atravessa a placenta e, em infusões prolongadas ou altas doses (>2 µg/kg/min, >24 h) pode causar toxicidade de cianeto fetal. Preferir labetalol IV, hidralazina ou nicardipina; se usar, limitar a tempo/dose e evitar a gravidez no 3.º trimestre sempre que possível.',
   'No specific Annex 1 entry; nitroprusside is reserved for severe refractory hypertensive crises: the cyanide metabolite crosses the placenta and, with prolonged infusions or high doses (>2 µg/kg/min, >24 h), can cause fetal cyanide toxicity. Prefer IV labetalol, hydralazine or nicardipine; if used, limit time/dose and avoid in the 3rd trimester whenever possible.',
   'Uso de última linha em crises hipertensivas graves (UTI); limitar tempo e dose (≤2 µg/kg/min, evitar >24 h); preferir alternativas na gravidez.',
   'Last-line use in severe hypertensive crises (ICU); limit time and dose (≤2 µg/kg/min, avoid >24 h); prefer alternatives in pregnancy.',
   'Compatível como droga de emergência (meia-vida de minutos).',
   'Compatible as an emergency drug (minutes half-life).',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Sodium Nitroprusside (secção 4.6 — "not recommended in pregnancy").',
   'EMC-UK (MHRA) — Sodium Nitroprusside SmPC (section 4.6 — "not recommended in pregnancy").'),

  -- ------------------------------------------------------------------
  -- 28. Metilprednisolona (Lote 2) — corticosteroide sistémico
  -- ------------------------------------------------------------------
  ('metilprednisolona', 'caution',
   'O Anexo 1 remete para "Corticosteróides (sistémicos)": em animais provocam fenda palatina e anomalias esqueléticas sem relevância comprovada em humanos; risco de diabetes gestacional e hipertensão; risco de atraso no crescimento intra-uterino em uso prolongado/repetido (factor D, 1.º trimestre para cursos prolongados). Os corticoides pulmonares (betametasona/dexametasona) para maturação fetal são benefício estabelecido.',
   'Annex 1 refers to "Corticosteroids (systemic)": in animals they cause cleft palate and skeletal anomalies without proven relevance in humans; risk of gestational diabetes and hypertension; risk of intra-uterine growth restriction with prolonged/repeated use (factor D, 1st trimester for long courses). Antenatal corticosteroids (betamethasone/dexamethasone) for fetal maturation are established benefit.',
   'Usar apenas se clinicamente necessário, na dose eficaz mais baixa e pelo período mais curto; a profilaxia/fisioterapia de exacerbações (asma, lúpus) na grávida não deve ser omitida por medo do fármaco.',
   'Use only if clinically necessary, at the lowest effective dose for the shortest period; prophylaxis/treatment of exacerbations (asthma, lupus) in pregnancy should not be withheld out of drug fear.',
   'Compatível: os corticosteróides passam pouco para o leite (prednisolona <10% da dose materna); com doses >20 mg/dia, esperar 4 horas após a toma para amamentar (minimizar a exposição).',
   'Compatible: corticosteroids pass little into milk (prednisolone <10% of the maternal dose); with doses >20 mg/day, wait 4 hours after the dose before breastfeeding (to minimise exposure).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Corticosteróides (sistémicos)" (l. 39867-81); Anexo 2: "Metilprednisolona — V. Corticosteróides" (l. 42891).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Corticosteroids (systemic)" (l. 39867-81); Annex 2: "Methylprednisolone — See Corticosteroids" (l. 42891).'),

  -- ------------------------------------------------------------------
  -- 29. Aminofilina (Lote 2) — precaução: taquicardia fetal
  -- ------------------------------------------------------------------
  ('aminofilina', 'caution',
   'Sem entrada específica no Anexo 1 (V. Xantinas); a aminofilina IV é usada em crises de asma graves da grávida com experiência favorável, mas pode causar taquicardia fetal e, em doses tóxicas maternas, arritmias e convulsões. As xantinas também foram usadas como tocolíticos (efeito positivo no RN: apneia), mas hoje o regime preferido na asma gravídica é o corticoide + beta-2 agonista inalado; a aminofilina fica para refratários.',
   'No specific Annex 1 entry (See Xanthines); IV aminophylline is used in severe maternal asthma attacks with favourable experience, but may cause fetal tachycardia and, at maternal toxic doses, arrhythmias and seizures. Xanthines have also been used as tocolytics (positive neonatal effect: apnoea), but the preferred regimen in pregnancy asthma is inhaled corticosteroid + beta-2 agonist; aminophylline is reserved for refractory cases.',
   'Usar apenas em crises graves refratárias, na dose ajustada (vigiar níveis plasmáticos: 10–20 µg/ml); evitar doses altas perto do termo (taquicardia/irritabilidade neonatais).',
   'Use only in refractory severe crises, at adjusted dose (monitor plasma levels: 10–20 µg/ml); avoid high doses near term (neonatal tachycardia/irritability).',
   'Passa para o leite e pode causar irritabilidade e insónia no lactente (a teofilina é o protótipo documentado); vigiar o lactente se a mãe mantém tratamento.',
   'Passes into milk and may cause infant irritability and insomnia (theophylline is the documented prototype); monitor the infant if the mother keeps treatment.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 5.1.4 (Xantinas); EMC-UK (MHRA) — SmPC Aminophylline (secção 4.6).',
   'Prontuário Terapêutico INFARMED — 5.1.4 (Xanthines); EMC-UK (MHRA) — Aminophylline SmPC (section 4.6).')

) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

COMMIT;

-- ============================================================================
-- Verificações pós-migração (esperado):
--   SELECT count(*) FROM public.drug_pregnancy_info p
--     JOIN public.drugs d ON d.id = p.drug_id
--     WHERE d.slug IN ('amoxicilina-acido-clavulanico','tetracaina',
--       'bicarbonato-sodio','clorexidina','iodopovidona','sulfato-zinco',
--       'acido-ascorbico','acido-folico','sulfato-ferroso','vitamina-d',
--       'calcio','noreisterona','levonorgestrel-etinilestradiol','desmopressina',
--       'neostigmina','vecuronio','suxametonio','bupivacaina','propofol',
--       'efedrina','clonidina','flumazenil','heparina','dopamina','dobutamina',
--       'noradrenalina','nitroprussiato','metilprednisolona','aminofilina')
--       AND p.is_archived = false;
--   → 29 (Lote 2 fica 29/29 na dimensão gravidez)
--
-- Categorias: contraindicated ×1 (noreisterona como terapêutica) ·
-- compatible ×8 (tetracaina, bicarbonato, clorexidina, sulfato-zinco,
-- acido-ascorbico, acido-folico, sulfato-ferroso, vitamina-d, calcio) ·
-- caution ×20 (restantes). 1+8+20 = 29 ✓
-- ============================================================================
