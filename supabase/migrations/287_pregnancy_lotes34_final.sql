-- ============================================================================
-- 287 — Gravidez/Aleitamento (drug_pregnancy_info) para os 12 fármacos
--       restantes dos Lotes 3/4 (2026-10-01) — FECHA A DIMENSÃO GRAVIDEZ
--       DOS LNME: 71/71 (284: 10 · 285: 19 · 286: 29 · 287: 12 + carbimazol
--       já coberto na 284)
-- ---------------------------------------------------------------------------
-- Verificado na BD: zero registos pré-existentes nos 12. Padrão 061/284-286,
-- ON CONFLICT (drug_id) DO NOTHING, idempotente.
--
-- FONTES (corroboradas em fontes_interacoes/prontuario_utf8.txt):
--   Anexo 1 (Fármacos e Gravidez):
--     · clomifeno          — l. 39741-43: "Não é recomendada durante a gravidez;
--                            evitar a menos que o potencial benefício seja
--                            superior aos riscos; não pode ser excluída a
--                            possibilidade de efeitos adversos no
--                            desenvolvimento embriofetal com base em estudos
--                            animais" (1º, D). Clínica: indutor da ovulação —
--                            não tem indicação em gravidez; teste de gravidez
--                            antes de cada ciclo.
--     · progesterona       — l. 41373-74: Progestagénios/Progesterona "o
--                            produtor recomenda que se use apenas se o
--                            benefício potencial for superior ao possível
--                            risco" (B/C). Clínica: uso obstétrico em amenorreia
--                            secundária e ameaça de aborto por insuficiência
--                            luteínica; compatível quando indicado.
--     · insulinas          — l. 40605 + 40619-23: "As necessidades de insulina
--                            devem ser avaliadas frequentemente... na insulina
--                            lispro não há aumento de malformações
--                            congénitas. Evitar insulinas inaladas." A insulina
--                            é o ANTIDIABÉTICO DE ESCOLHA na gravidez.
--     · piridoxina         — l. 41338: sem entrada restritiva; vitamina B6,
--                            compatível (usada no vómito gravídico).
--     · flucloxacilina     — l. 40277: "V. Penicilinas"; l. 41286-87: "Penicilinas
--                            — Não há risco fetal" (B).
--   Anexo 2 (Fármacos e aleitamento):
--     · clomifeno          — l. 42359: "Pode inibir a lactação"
--     · progesterona       — l. 43100-01: "Evitar; pequenas quantidades presentes
--                            no leite" (nota: o texto refere evitar a via
--                            injetável de depósito; progestagénios usados na
--                            contracepção lactacional)
--     · piridoxina         — l. 43039: "Pode suprimir a lactação" (doses altas)
--     · penicilinas        — l. 43017-19: "Presente no leite em quantidade muito
--                            pequena para ser perigosa"
--   Sem entrada nos anexos (cobertura por EMC-UK SmPC 4.6 e via de administração):
--     · acido-tranexamico, protamina, gluconato-calcio, n-acetilcisteina,
--       espectinomicina, permanganato-potassio, insulinas (anexo 2: l. 42790
--       "presentes no leite em quantidades muito pequenas para serem perigosas")
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
  -- 1. Clomifeno (Lote 3) — indutor da ovulação; não usar na gravidez
  -- ------------------------------------------------------------------
  ('clomifeno', 'contraindicated',
   'Contraindicado na gravidez — é um antiestrogénio indutor da ovulação e não tem qualquer indicação em gravidez instalada. O Anexo 1 regista "não é recomendada durante a gravidez; evitar a menos que o potencial benefício seja superior aos riscos; não pode ser excluída a possibilidade de efeitos adversos no desenvolvimento embriofetal com base em estudos animais" (factor D). Estudos em humanos (exposição inadvertida) não mostraram aumento claro de malformações.',
   'Contraindicated in pregnancy — it is an ovulation-inducing anti-oestrogen with no indication in an established pregnancy. Annex 1 records "not recommended during pregnancy; avoid unless the potential benefit outweighs the risks; the possibility of adverse effects on embryofetal development, based on animal studies, cannot be excluded" (factor D). Human studies (inadvertent exposure) have not shown a clear increase in malformations.',
   'Contraindicado; confirmação de gravidez (β-hCG) antes de cada ciclo de tratamento; suspender ao confirmar a gravidez.',
   'Contraindicated; confirm absence of pregnancy (β-hCG) before each treatment cycle; discontinue on confirming pregnancy.',
   'Pode inibir a lactação (Prontuário, Anexo 2, l. 42359) — evitar durante a amamentação.',
   'May inhibit lactation (Prontuário, Annex 2, l. 42359) — avoid while breastfeeding.',
   'Confirmar ausência de gravidez antes de cada ciclo; contracepção se a ovulação for estimulada sem intenção conceptual.',
   'Confirm absence of pregnancy before each cycle; contraception if ovulation is induced without conception intent.',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Clomifeno" (l. 39741-43, factor D); Anexo 2: "Pode inibir a lactação" (l. 42359). EMC-UK (MHRA) — SmPC Clomifene (Clomid): https://www.medicines.org.uk/emc/product/4479/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Clomifene" (l. 39741-43, factor D); Annex 2: "May inhibit lactation" (l. 42359). EMC-UK (MHRA) — Clomifene SmPC (Clomid): https://www.medicines.org.uk/emc/product/4479/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 2. Progesterona (Lote 3) — compatível quando indicada
  -- ------------------------------------------------------------------
  ('progesterona', 'compatible',
   'A progesterona natural é usada em obstetrícia (amenorreia secundária, hemorragia por insuficiência luteínica, ameaça de aborto e prevenção de parto prematuro em colo curto). O Anexo 1 regista "o produtor recomenda que se use apenas se o benefício potencial for superior ao possível risco" (factor B/C); os estudos de progesterona vaginal/IM na prevenção do parto prematuro são favoráveis. Progestagénios sintéticos de 1.ª geração em dose alta têm sinal de virilização de fetos femininos — a progesterona natural não.',
   'Natural progesterone is used in obstetrics (secondary amenorrhoea, bleeding from luteal insufficiency, threatened miscarriage and preterm birth prevention with short cervix). Annex 1 records "the manufacturer recommends using only if the potential benefit outweighs the possible risk" (factor B/C); studies of vaginal/IM progesterone for preterm birth prevention are favourable. First-generation synthetic progestogens at high doses have a virilisation signal in female fetuses — natural progesterone does not.',
   'Compatível quando indicado (insuficiência luteínica, prevenção de parto prematuro); usar a progesterona natural e não progestagénios sintéticos de dose alta.',
   'Compatible when indicated (luteal insufficiency, preterm birth prevention); use natural progesterone, not high-dose synthetic progestogens.',
   'Evitar; pequenas quantidades presentes no leite (Prontuário, Anexo 2, l. 43100-01) — a progesterona natural em doses fisiológicas é compatível com a amamentação; os progestagénios não suprimem a produção de leite (ao contrário dos estrogénios).',
   'Avoid; small amounts present in milk (Prontuário, Annex 2, l. 43100-01) — natural progesterone at physiological doses is compatible with breastfeeding; progestogens do not suppress milk production (unlike oestrogens).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: Progestagénios/Progesterona (l. 41372-74, factors B/C); Anexo 2 (l. 43100-01). EMC-UK (MHRA) — SmPC Progesterone (Utrogestan).',
   'Prontuário Terapêutico INFARMED — Annex 1: Progestogens/Progesterone (l. 41372-74, factors B/C); Annex 2 (l. 43100-01). EMC-UK (MHRA) — Progesterone SmPC (Utrogestan).'),

  -- ------------------------------------------------------------------
  -- 3. Ácido tranexâmico (Lote 3) — antifibrinolítico; precaução
  -- ------------------------------------------------------------------
  ('acido-tranexamico', 'caution',
   'Sem entrada específica no Anexo 1; o ácido tranexâmico atravessa a placenta e está presente no leite. Os rótulos (EMC/Cyklokapron) recomendam não usar na gravidez salvo se claramente necessário — os dados em hemorragia pós-parto (Woman trial) são tranquilizadores quanto a desfechos fetais. Não deve usar-se em hematuria por risco de trombose do trato urinário.',
   'No specific Annex 1 entry; tranexamic acid crosses the placenta and is present in milk. Labels (EMC/Cyklokapron) recommend avoiding in pregnancy unless clearly necessary — postpartum haemorrhage data (Woman trial) are reassuring for fetal outcomes. Do not use in haematuria due to urinary tract thrombosis risk.',
   'Usar apenas se claramente necessário (hemorragia grave); o uso no PPH é benefício estabelecido — a exposição fetal nesse contexto é irrelevante (feto já nascido).',
   'Use only if clearly necessary (severe bleeding); PPH use has established benefit — fetal exposure is irrelevant in that context (baby already delivered).',
   'Presente no leite em pequenas quantidades; a dose pediátrica equivalente é baixa — compatível com vigilância (EMC: "tranexamic acid is present in milk at about 1/100th of maternal serum levels").',
   'Present in milk in small amounts; the equivalent paediatric dose is low — compatible with monitoring (EMC: "tranexamic acid is present in milk at about 1/100th of maternal serum levels").',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Tranexamic Acid (Cyklokapron): https://www.medicines.org.uk/emc/product/2168/smpc (secção 4.6). WOMAN trial (Lancet 2017).',
   'EMC-UK (MHRA) — Tranexamic Acid SmPC (Cyklokapron): https://www.medicines.org.uk/emc/product/2168/smpc (section 4.6). WOMAN trial (Lancet 2017).'),

  -- ------------------------------------------------------------------
  -- 4. Protamina (Lote 3) — antídoto IV; emergência
  -- ------------------------------------------------------------------
  ('protamina', 'caution',
   'Sem entrada nos anexos do Prontuário; a protamina é o antídoto da heparina (1 mg por 100 UI de heparina), administrada por via IV em contexto de emergência (excesso de anticoagulação, reversão em cirurgia cardiopulmonar). A decisão de usar é ditada pelo benefício materno; a heparina não atravessa a placenta, pelo que a hipocoagulabilidade fetal por protamina transitória é raramente relevante.',
   'No entry in the Prontuário annexes; protamine is the antidote for heparin (1 mg per 100 IU of heparin), given IV in emergency settings (over-anticoagulation, reversal in cardiac surgery). The decision to use is driven by maternal benefit; heparin does not cross the placenta, so transient fetal hypocoagulability is rarely relevant.',
   'Uso IV de emergência conforme o benefício materno; doses excessivas causam hipotensão e efeitos anticoagulantes próprios.',
   'Emergency IV use as maternal benefit dictates; excessive doses cause hypotension and protamine''s own anticoagulant effects.',
   'Compatível como antídoto de emergência — proteína degradada; sem relatos de efeitos no lactente.',
   'Compatible as an emergency antidote — degraded protein; no reports of effects on the infant.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 8.6 (Anticoagulantes): reversão com sulfato de protamina (l. 18121-24). EMC-UK (MHRA) — SmPC Protamine Sulphate.',
   'Prontuário Terapêutico INFARMED — 8.6 (Anticoagulants): reversal with protamine sulphate (l. 18121-24). EMC-UK (MHRA) — Protamine Sulphate SmPC.'),

  -- ------------------------------------------------------------------
  -- 5. Gluconato de cálcio (Lote 3) — compatível
  -- ------------------------------------------------------------------
  ('gluconato-calcio', 'compatible',
   'Sem entrada restritiva no Anexo 1; o gluconato de cálcio IV é o antídoto da hipermagnesemia (complicação do sulfato de magnésio tocolítico) e da intoxicação por bloqueadores dos canais de cálcio, e faz parte da reposição de cálcio na pré-eclâmpsia. Uso seguro na gravidez quando indicado.',
   'No restrictive Annex 1 entry; IV calcium gluconate is the antidote for hypermagnesaemia (a complication of tocolytic magnesium sulfate) and calcium-channel-blocker poisoning, and is part of calcium replacement in pre-eclampsia. Safe in pregnancy when indicated.',
   'Compatível para uso IV terapêutico quando indicado (hipocalcemia sintomática, hiperkaliemia/hipermagnesemia, intoxicação por BCC).',
   'Compatible for therapeutic IV use when indicated (symptomatic hypocalcaemia, hyperkalaemia/hypermagnesaemia, CCB poisoning).',
   'Compatível; o cálcio passa para o leite em quantidades reguladas pelo organismo.',
   'Compatible; calcium passes into milk in amounts regulated by the body.',
   '',
   '',
   'OMS — WHO recommendation on calcium supplementation in pregnant women. Prontuário Terapêutico INFARMED — 11.3.3 (Sais minerais) e 2.2 (Correctores).',
   'WHO — WHO recommendation on calcium supplementation in pregnant women. Prontuário Terapêutico INFARMED — 11.3.3 (Mineral salts) and 2.2 (Correctors).'),

  -- ------------------------------------------------------------------
  -- 6. N-acetilcisteína (Lote 3) — antídoto; compatível
  -- ------------------------------------------------------------------
  ('n-acetilcisteina', 'compatible',
   'Sem entrada nos anexos; a NAC IV é o antídoto da intoxicação por paracetamol — nestas situações de emergência, o benefício materno (salvar a vida) é absoluto e o tratamento deve ser administrado sem hesitação. Dados observacionais de gravidezes expostas não mostram malformações. A NAC não é teratogénica em animais.',
   'No entry in the annexes; IV NAC is the antidote for paracetamol poisoning — in these emergencies maternal benefit (life-saving) is absolute and treatment must be given without hesitation. Observational data of exposed pregnancies show no malformations. NAC is not teratogenic in animals.',
   'Uso de emergência sem restrição (intoxicação por paracetamol, profilaxia de contraste); o benefício materno prevalece sempre.',
   'Emergency use without restriction (paracetamol poisoning, contrast prophylaxis); maternal benefit always prevails.',
   'Compatível; doses do antídoto são válidas durante a amamentação.',
   'Compatible; antidote doses are valid during breastfeeding.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Acetylcysteine: https://www.medicines.org.uk/emc/product/3501/smpc (secção 4.6). MHRA — paracetamol overdose treatment guideline.',
   'EMC-UK (MHRA) — Acetylcysteine SmPC: https://www.medicines.org.uk/emc/product/3501/smpc (section 4.6). MHRA — paracetamol overdose treatment guideline.'),

  -- ------------------------------------------------------------------
  -- 7. Piridoxina / vitamina B6 (Lote 3) — compatível
  -- ------------------------------------------------------------------
  ('piridoxina', 'compatible',
   'Sem entrada restritiva no Anexo 1 (l. 41338); a vitamina B6 é compatível com a gravidez e tem uso documentado no tratamento do vómito gravídico (isolada ou com doxilamina). Doses muito altas e prolongadas (>500 mg/dia) podem causar neuropatia periférica materna.',
   'No restrictive Annex 1 entry (l. 41338); vitamin B6 is compatible with pregnancy and has documented use in nausea and vomiting of pregnancy (alone or with doxylamine). Very high prolonged doses (>500 mg/day) can cause maternal peripheral neuropathy.',
   'Compatível em doses habituais (10–25 mg 3×/dia no vómito gravídico); evitar megadoses crónicas.',
   'Compatible at usual doses (10–25 mg 3×/day for pregnancy nausea); avoid chronic megadoses.',
   'Pode suprimir a lactação em doses altas (Prontuário, Anexo 2, l. 43039); nas doses habituais de suplementação, compatível.',
   'May suppress lactation at high doses (Prontuário, Annex 2, l. 43039); at usual supplementation doses, compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Piridoxina" (l. 41338); Anexo 2: "Pode suprimir a lactação" (l. 43039). 11.3.2 (Vitaminas hidrossolúveis).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Pyridoxine" (l. 41338); Annex 2: "May suppress lactation" (l. 43039). 11.3.2 (Water-soluble vitamins).'),

  -- ------------------------------------------------------------------
  -- 8. Insulina regular (Lote 4) — antidiabético de escolha na gravidez
  -- ------------------------------------------------------------------
  ('insulina-regular', 'compatible',
   'A insulina é o ANTIDIABÉTICO DE ESCOLHA na gravidez (não atravessa a placenta em quantidade relevante e controla a glicemia materna). O Anexo 1 regista "as necessidades de insulina devem ser avaliadas frequentemente por um diabetologista... na insulina lispro não há aumento de malformações congénitas. Evitar insulinas inaladas." As necessidades aumentam no 2.º–3.º trimestres e caem bruscamente após o parto.',
   'Insulin is the ANTIDIABETIC OF CHOICE in pregnancy (it does not cross the placenta in relevant amounts and controls maternal glycaemia). Annex 1 records "insulin requirements should be assessed frequently by a diabetologist... with insulin lispro there is no increase in congenital malformations. Avoid inhaled insulins." Requirements rise in the 2nd–3rd trimesters and fall sharply after delivery.',
   'Compatível e indicado; ajustar as necessidades com frequência (NPH/regular ou análogos lispro/aspart); vigilância obstétrica especializada (malformações associam-se à hiperglicemia materna, não à insulina).',
   'Compatible and indicated; adjust requirements frequently (NPH/regular or lispro/aspart analogues); specialised obstetric surveillance (malformations are linked to maternal hyperglycaemia, not insulin).',
   'Compatível: "presentes no leite em quantidades muito pequenas para serem perigosas" (Anexo 2, l. 42790); a insulina é degradada no trato digestivo do lactente.',
   'Compatible: "present in milk in amounts too small to be harmful" (Annex 2, l. 42790); insulin is degraded in the infant gut.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Insulinas" (l. 40605, 40619-23); Anexo 2 (l. 42790). EMC-UK (MHRA) — SmPC Insulin Human (Actrapid): https://www.medicines.org.uk/emc/product/1221/smpc.',
   'Prontuário Terapêutico INFARMED — Annex 1: "Insulins" (l. 40605, 40619-23); Annex 2 (l. 42790). EMC-UK (MHRA) — Insulin Human SmPC (Actrapid): https://www.medicines.org.uk/emc/product/1221/smpc.'),

  -- ------------------------------------------------------------------
  -- 9. Insulina NPH (Lote 4) — antidiabético de escolha na gravidez
  -- ------------------------------------------------------------------
  ('insulina-nph', 'compatible',
   'Como a insulina regular, a NPH é o antidiabético de escolha na gravidez — o pico intermédio cobre as necessidades basais e é o basal mais estudado em gestação. O Anexo 1 regista o uso com avaliação frequente das necessidades; a hipoglicemia materna grave é o principal risco a vigiar (neutroglicemia pode prejudicar o feto).',
   'Like regular insulin, NPH is the antidiabetic of choice in pregnancy — the intermediate peak covers basal needs and it is the most studied basal insulin in gestation. Annex 1 records use with frequent assessment of requirements; severe maternal hypoglycaemia is the main risk to monitor (neuroglycopenia can harm the fetus).',
   'Compatível e indicado; na diabetes gestacional o esquema típico é NPH basal + regular pré-refeições; vigiar hipoglicemias maternas, sobretudo no 1.º trimestre.',
   'Compatible and indicated; in gestational diabetes the typical regimen is NPH basal + regular pre-meals; monitor maternal hypoglycaemia, especially in the 1st trimester.',
   'Compatível (ver insulina regular, l. 42790).',
   'Compatible (see regular insulin, l. 42790).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Insulinas" (l. 40605, 40619-23); Anexo 2 (l. 42790). EMC-UK (MHRA) — SmPC Insulin Human (Insulatard).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Insulins" (l. 40605, 40619-23); Annex 2 (l. 42790). EMC-UK (MHRA) — Insulin Human SmPC (Insulatard).'),

  -- ------------------------------------------------------------------
  -- 10. Flucloxacilina (Lote 4) — penicilina; compatível
  -- ------------------------------------------------------------------
  ('flucloxacilina', 'compatible',
   'O Anexo 1 remete para Penicilinas: "não há risco fetal" (factor B). A flucloxacilina é a penicilina antistafilocócica de escolha nas infeções da gravidez quando indicado; dose habitual 250–500 mg 4×/dia. Nota: tomar em jejum (30–60 min antes das refeições) para maximizar a absorção — ver interação fármaco-alimento na 280.',
   'Annex 1 refers to Penicillins: "no fetal risk" (factor B). Flucloxacillin is the antistaphylococcal penicillin of choice in pregnancy infections when indicated; usual dose 250–500 mg 4×/day. Note: take on an empty stomach (30–60 min before meals) to maximise absorption — see the drug-food interaction in 280.',
   'Compatível em todos os trimestres; usar quando indicado por suscetibilidade.',
   'Compatible in all trimesters; use when indicated by susceptibility.',
   'Compatível: as penicilinas passam para o leite "em quantidade muito pequena para ser perigosa" (Anexo 2, l. 43017-19); vigiar candidíase e alteração da flora intestinal do lactente.',
   'Compatible: penicillins pass into milk "in amounts too small to be harmful" (Annex 2, l. 43017-19); monitor the infant for thrush and gut flora changes.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Flucloxacilina — V. Penicilinas" (l. 40277) e "Penicilinas — Não há risco fetal" (l. 41286-87); Anexo 2 (l. 43017-19).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Flucloxacillin — See Penicillins" (l. 40277) and "Penicillins — No fetal risk" (l. 41286-87); Annex 2 (l. 43017-19).'),

  -- ------------------------------------------------------------------
  -- 11. Espectinomicina (Lote 4) — aminociclitol IM; precaução
  -- ------------------------------------------------------------------
  ('espectinomicina', 'caution',
   'Sem entrada no Anexo 1 do Prontuário; a espectinomicina IM é alternativa na gonorreia da grávida alérgica a cefalosporinas (guidelines CDC/OMS a consideram opção quando não há alternativa). Os dados humanos são limitados mas não mostram sinal de teratogenicidade; o EMC recomenda usar apenas se claramente necessário.',
   'No entry in the Prontuário Annex 1; IM spectinomycin is an alternative in pregnancy gonorrhoea for cefalosporin-allergic patients (CDC/WHO guidelines list it when no alternative exists). Human data are limited but show no teratogenicity signal; EMC recommends use only if clearly necessary.',
   'Usar apenas se não houver alternativa (alergia) e o tratamento for obrigatório (gonorreia não tratada prejudica a gestação).',
   'Use only when no alternative exists (allergy) and treatment is mandatory (untreated gonorrhoea harms pregnancy).',
   'Excreção no leite não caracterizada; usar com precaução e vigiar o lactente (flora intestinal).',
   'Milk excretion not characterised; use with caution and monitor the infant (gut flora).',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Spectinomycin (Trobicin): https://www.medicines.org.uk/emc/product/2997/smpc (secção 4.6). CDC STI Treatment Guidelines (gonorrhoea in pregnancy).',
   'EMC-UK (MHRA) — Spectinomycin SmPC (Trobicin): https://www.medicines.org.uk/emc/product/2997/smpc (section 4.6). CDC STI Treatment Guidelines (gonorrhoea in pregnancy).'),

  -- ------------------------------------------------------------------
  -- 12. Permanganato de potássio (Lote 4) — tópico; compatível
  -- ------------------------------------------------------------------
  ('permanganato-potassio', 'compatible',
   'Sem entrada no Anexo 1; o permanganato de potássio é antisséptico/astringente de uso tópico (banhos diluídos 1:10.000 em feridas e dermatites), com absorção sistémica negligenciável. Sem restrição na gravidez para uso tópico externo; nunca ingerir nem aplicar concentrado (risco de queimaduras químicas).',
   'No entry in the Annex 1; potassium permanganate is a topical antiseptic/astringent (diluted 1:10,000 baths for wounds and dermatitis) with negligible systemic absorption. No restriction in pregnancy for external topical use; never ingest or apply concentrated (chemical burn risk).',
   'Compatível para uso tópico externo na diluição correcta (1:10.000 — solução cor-de-rosa pálido).',
   'Compatible for external topical use at the correct dilution (1:10,000 — pale pink solution).',
   'Compatível; absorção negligenciável; evitar a aplicação nos seios (o lactente pode ingerir resíduos).',
   'Compatible; negligible absorption; avoid applying to the breasts (the infant may ingest residues).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 13.2 (Anti-sépticos): banhos de permanganato de potássio a 1:10.000 (l. 32106, 33641).',
   'Prontuário Terapêutico INFARMED — 13.2 (Antiseptics): potassium permanganate 1:10,000 baths (l. 32106, 33641).')

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
--     WHERE d.slug IN ('clomifeno','progesterona','acido-tranexamico',
--       'protamina','gluconato-calcio','n-acetilcisteina','piridoxina',
--       'insulina-regular','insulina-nph','flucloxacilina','espectinomicina',
--       'permanganato-potassio') AND p.is_archived = false;
--   → 12 (Lotes 3/4 fecham: 71/71 na dimensão gravidez)
--
-- Categorias: contraindicated ×1 (clomifeno) · compatible ×8 (progesterona,
-- gluconato-calcio, n-acetilcisteina, piridoxina, insulina-regular,
-- insulina-nph, flucloxacilina, permanganato-potassio) · caution ×3
-- (acido-tranexamico, protamina, espectinomicina). 1+8+3 = 12 ✓
-- ============================================================================
