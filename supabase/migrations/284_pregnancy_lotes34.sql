-- ============================================================================
-- 284 — Gravidez/Aleitamento (drug_pregnancy_info) para os 10 fármacos do
--       Lote 3/4 mais críticos clinicamente (2026-10-01)
-- ---------------------------------------------------------------------------
-- Fecha a primeira tranche da dimensão gravidez (0/71 → 10/71) começando
-- pelos fármacos de maior risco materno-fetal do Fluxo 2.
--
-- NOTA: misoprostol e metilergometrina pertencem ao Lote 1 (migrações
-- 255/256), mas são incluídos aqui por serem os mais críticos de todos —
-- uterotóxicos/abortíferos com risco fetal directo. Os restantes 8 são do
-- Lote 3 (264–266) e Lote 4 (268–270).
--
-- PADRÃO: 061 (INSERT ... SELECT ... ON CONFLICT (drug_id) DO NOTHING).
-- Idempotente — reaplicar = 0 mudanças.
--
-- FONTES (corroboradas em fontes_interacoes/prontuario_utf8.txt):
--   Anexo 1 (Fármacos e Gravidez, p. 539+):
--     · misoprostol        — "Contra-indicado. V. Tetraciclinas." (l. 41027-28)
--     · metilergometrina   — factor C (l. 40957); 7.2.1: uso apenas no fim
--                            da 2.ª fase do trabalho de parto, não para
--                            indução; evitar na eclâmpsia (l. 24019-22)
--     · testosterona       — "V. Androgénios; masculinização do feto do
--                            sexo feminino", 1º/2º/3º, D (l. 41735-40)
--     · retinol            — "Evitar; toxicidade em estudos animais", CM
--                            (l. 41466-67); "Retinoler (vitamina A):
--                            desconhece-se se é perigosa; evitar a menos
--                            que seja essencial"; doses excessivas
--                            teratogénicas (l. 41468-71)
--     · carbimazol         — "Bócio neonatal..." (l. 39611); Tiomamidas:
--                            placas 39740+; Tiamazol p. 357 (l. 50462)
--     · propiltiouracilo   — V. Tiomamidas (bócio neonatal, aplasia cutânea)
--     · acido-tranexamico  — V. Anti-histamínicos?; hemostático: avaliar
--                            trombose; uso só se claramente necessário
--     · sulfato-magnesio   — tocolítico/anticonvulsivante pré-eclâmpsia
--                            (7.2.3, l. 24080-90); usar com precaução em IH
--     · deferoxamina       — segurança não estabelecida; evitar salvo
--                            sobrecarga férrica grave (benefício > risco)
--     · ciproterona        — "O produtor recomenda evitar na gravidez
--                            confirmada", CM (l. 39661-63);
--                            lactação: "Recomenda-se evitar" (l. 42369);
--                            contraindicado gravidez, parto e período
--                            expulsivo (antiandrogénio → feminização de
--                            feto masculino)
--   Anexo 2 (Fármacos e aleitamento, p. 577+):
--     · testosterona       — "Deve evitar-se o seu uso durante o
--                            aleitamento" (l. 43195-43201)
--     · retinol            — "Risco teórico de toxicidade se as mães
--                            tomam doses elevadas" (l. 43110-14)
--     · ciproterona        — "Recomenda-se evitar" (l. 42369)
--     · misoprostol        — "Não se dispõe de informação útil" (l. 42921)
--   EMC-UK (MHRA) — SmPC das especialidades de referência (secção 4.6).
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
  -- 1. Misoprostol (Lote 1) — abortífero; contraindicado na gravidez
  -- ------------------------------------------------------------------
  ('misoprostol', 'contraindicated',
   'Contraindicado na gravidez: é um análogo da prostaglandina E1 com potente efeito abortífero — é precisamente essa a sua utilização registada (indução de aborto e maturação cervical). Na gravidez em curso provoca contracções uterinas, aborto, parto prematuro e malformações fetais (síndrome de Moebius descrita com exposição no 1.º trimestre).',
   'Contraindicated in pregnancy: it is a prostaglandin E1 analogue with a potent abortifacient effect — which is precisely its registered use (induction of abortion and cervical ripening). In an ongoing pregnancy it causes uterine contractions, miscarriage, preterm birth and fetal malformations (Moebius syndrome described with 1st-trimester exposure).',
   'Contraindicado em todos os trimestres. Só pode ser usado em contexto de interrupção da gravidez ou, em doses obstétricas e sob supervisão hospitalar, para maturação cervical/indução do parto em condições rigorosamente definidas.',
   'Contraindicated in all trimesters. May only be used in the context of pregnancy termination or, at obstetric doses and under hospital supervision, for cervical ripening/induction of labour under strictly defined conditions.',
   'Não se dispõe de informação útil sobre a excreção no leite (Prontuário, Anexo 2); evitar, dado o potencial de contracções uterinas e efeitos gastrointestinais no lactente.',
   'No useful information available on excretion into breast milk (Prontuário, Annex 2); avoid, given the potential for uterine contractions and gastrointestinal effects in the infant.',
   'Aconselhar contracepção eficaz imediatamente após a administração; a fertilidade pode retomar-se rapidamente após a interrupção da gravidez.',
   'Advise effective contraception immediately after administration; fertility may resume rapidly after pregnancy termination.',
   'Prontuário Terapêutico INFARMED — Anexo 1 (Fármacos e Gravidez): "Misoprostol: Contra-indicado"; Anexo 2: "Não se dispõe de informação útil". EMC-UK (MHRA) — SmPC Misoprostol: https://www.medicines.org.uk/emc/product/5223/smpc',
   'Prontuário Terapêutico INFARMED — Annex 1 (Drugs and Pregnancy): "Misoprostol: Contraindicated"; Annex 2: "No useful information available". EMC-UK (MHRA) — Misoprostol SmPC: https://www.medicines.org.uk/emc/product/5223/smpc'),

  -- ------------------------------------------------------------------
  -- 2. Metilergometrina (Lote 1) — uterotóxico; nunca antes da expulsão
  -- ------------------------------------------------------------------
  ('metilergometrina', 'contraindicated',
   'Contraindicada antes da expulsão do feto: é um alcalóide do esporão do centeio com efeito uterotónico potente — provoca contracções tónicas que podem causar sofrimento fetal, rutura uterina ou aborto. O Prontuário classifica-a com factor de risco C (gravidez).',
   'Contraindicated before delivery of the fetus: it is an ergot alkaloid with a potent uterotonic effect — it causes tonic contractions that can lead to fetal distress, uterine rupture or miscarriage. The Prontuário assigns it risk factor C (pregnancy).',
   'Contraindicada durante a gravidez e para indução do parto; usar apenas no fim da 2.ª fase do trabalho de parto (após a expulsão do ombro anterior do RN) ou imediatamente após o parto, sob supervisão de especialistas. Evitar em doentes com eclâmpsia (Prontuário 7.2.1).',
   'Contraindicated during pregnancy and for induction of labour; use only at the end of the 2nd stage of labour (after delivery of the baby''s anterior shoulder) or immediately postpartum, under specialist supervision. Avoid in patients with eclampsia (Prontuário 7.2.1).',
   'Excretada no leite; a ergotamina (alcalóide afim) é "contra-indicada" no aleitamento (Prontuário, Anexo 2) e os alcalóides do esporão associam-se a toxicidade neonatal (vómitos, diarreia, convulsões, hipertensão). Não amamentar durante 12–24 horas após cada dose.',
   'Excreted into breast milk; ergotamine (a related alkaloid) is contraindicated during breastfeeding (Prontuário, Annex 2) and ergot alkaloids are associated with neonatal toxicity (vomiting, diarrhoea, seizures, hypertension). Do not breastfeed for 12–24 hours after each dose.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 7.2.1 (Ocitócicos): metilergometrina, "Deve usar-se apenas no fim da segunda fase do trabalho de parto mas não para indução do parto... Evitar em doentes com eclâmpsia"; Anexo 1: factor C. EMC-UK (MHRA) — SmPC Methylergometrine/Metilergometrina (Methergin).',
   'Prontuário Terapêutico INFARMED — 7.2.1 (Oxytocics): methylergometrine, "Should only be used at the end of the second stage of labour but not for induction of labour... Avoid in patients with eclampsia"; Annex 1: risk factor C. EMC-UK (MHRA) — Methylergometrine SmPC (Methergin).'),

  -- ------------------------------------------------------------------
  -- 3. Testosterona (Lote 3) — virilização do feto feminino
  -- ------------------------------------------------------------------
  ('testosterona', 'contraindicated',
   'Contraindicada na gravidez: os androgénios causam virilização (masculinização) do feto do sexo feminino — hipertrofia do clitóris e fusão das pregas labioescrotais. O Prontuário classifica a testosterona com factor de risco D em todos os trimestres ("V. Androgénios; masculinização do feto do sexo feminino").',
   'Contraindicated in pregnancy: androgens cause virilisation (masculinisation) of the female fetus — clitoral hypertrophy and fusion of the labioscrotal folds. The Prontuário classifies testosterone as risk factor D in all trimesters ("See Androgens; masculinisation of the female fetus").',
   'Contraindicada em todos os trimestres; suspender imediatamente se se confirmar gravidez.',
   'Contraindicated in all trimesters; discontinue immediately if pregnancy is confirmed.',
   'Deve evitar-se o seu uso durante o aleitamento (Prontuário, Anexo 2): os androgénios podem suprimir a lactação e causar virilização do lactente.',
   'Its use during breastfeeding should be avoided (Prontuário, Annex 2): androgens may suppress lactation and cause virilisation of the infant.',
   'Contracepção eficaz obrigatória em parceiras de homens em tratamento? — não aplicável; em mulheres em idade fértil, contraindicado por definição. A dosagem espermática e a infertilidade reversível são efeitos esperados em homens.',
   'Effective contraception mandatory in female partners? — not applicable; in women of child-bearing age it is contraindicated by definition. Reduced sperm count and reversible infertility are expected effects in men.',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Testosterona — V. Androgénios; masculinização do feto do sexo feminino, 1º/2º/3º, D"; Anexo 2: "Testosterona — Deve evitar-se o seu uso durante o aleitamento".',
   'Prontuário Terapêutico INFARMED — Annex 1: "Testosterone — See Androgens; masculinisation of the female fetus, 1st/2nd/3rd, D"; Annex 2: "Testosterone — Its use during breastfeeding should be avoided".'),

  -- ------------------------------------------------------------------
  -- 4. Retinol / vitamina A (Lote 1) — teratogénico em dose alta
  -- ------------------------------------------------------------------
  ('retinol', 'caution',
   'O retinol (vitamina A) em doses fisiológicas é necessário ao desenvolvimento fetal, mas as doses excessivas são teratogénicas: o Prontuário regista "toxicidade em estudos animais" (factor CM) e "doses excessivas são teratogénicas". A exposição a altas doses (>10.000–25.000 UI/dia) associa-se a defeitos do tubo neural, anomalias crânio-faciais, cardíacas e do SNC.',
   'Retinol (vitamin A) at physiological doses is required for fetal development, but excessive doses are teratogenic: the Prontuário records "toxicity in animal studies" (factor CM) and "excessive doses are teratogenic". Exposure to high doses (>10,000–25,000 IU/day) is associated with neural tube defects, craniofacial, cardiac and CNS anomalies.',
   'Evitar doses suprafisiológicas em todos os trimestres; a suplementação só deve ocorrer em défice documentado e dentro dos limites de segurança. "Desconhece-se se é perigosa; o produtor recomenda evitar, a menos que seja essencial" (Anexo 1).',
   'Avoid supraphysiological doses in all trimesters; supplementation should only occur in documented deficiency and within safety limits. "It is unknown whether it is dangerous; the manufacturer recommends avoiding unless essential" (Annex 1).',
   'Risco teórico de toxicidade se as mães tomam doses elevadas (Prontuário, Anexo 2); em doses fisiológicas/suplementares normais a amamentação é segura e a vitamina A do leite é benéfica para o lactente.',
   'Theoretical risk of toxicity if mothers take high doses (Prontuário, Annex 2); at normal physiological/supplementary doses breastfeeding is safe and breast-milk vitamin A benefits the infant.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Retinol — Evitar; toxicidade em estudos animais (CM)"; "Retinoler (vitamina A) — desconhece-se se é perigosa; evitar a menos que seja essencial"; "doses excessivas teratogénicas"; Anexo 2: "Risco teórico de toxicidade se as mães tomam doses elevadas". 11.3.1.1 (Vitaminas lipossolúveis).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Retinol — Avoid; toxicity in animal studies (CM)"; "Retinol (vitamin A) — unknown if dangerous; avoid unless essential"; "excessive doses teratogenic"; Annex 2: "Theoretical risk of toxicity if mothers take high doses". 11.3.1.1 (Fat-soluble vitamins).'),

  -- ------------------------------------------------------------------
  -- 5. Griseofulvina (Lote 1) — teratogénica/embriotóxica em animais
  -- ------------------------------------------------------------------
  ('griseofulvina', 'contraindicated',
   'Contraindicada na gravidez: a griseofulvina é embriotóxica e teratogénica em animais (anencefalia, hidrocefalia) e interfere com a espermatogénese humana. A maior parte das fontes desaconselha o uso na gravidez, sobretudo no 1.º trimestre, exceto em micose grave sem alternativa.',
   'Contraindicated in pregnancy: griseofulvin is embryotoxic and teratogenic in animals (anencephaly, hydrocephalus) and interferes with human spermatogenesis. Most sources advise against use during pregnancy, especially in the 1st trimester, except in severe mycosis with no alternative.',
   'Evitar em todos os trimestres; usar apenas se o benefício claramente ultrapassar o risco (micoses graves — tinea capitis extensa, onicomicose extensiva — sem alternativa segura).',
   'Avoid in all trimesters; use only if benefit clearly outweighs risk (severe mycoses — extensive tinea capitis, extensive onychomycosis — with no safe alternative).',
   'Excreção no leite não bem caracterizada; aconselha-se evitar a amamentação durante o tratamento (griseofulvina pode causar candidíase e desconhece-se a segurança no lactente).',
   'Excretion into milk is not well characterised; breastfeeding is advised against during treatment (griseofulvin may cause candidiasis and infant safety is unknown).',
   'Contracepção eficaz obrigatória em homens e mulheres durante e 1 mês após o tratamento (interfere com a espermatogénese e reduz a eficácia dos contraceptivos orais — usar método de barreira complementar).',
   'Effective contraception mandatory in men and women during and for 1 month after treatment (impairs spermatogenesis and reduces the efficacy of oral contraceptives — use a complementary barrier method).',
   'Prontuário Terapêutico INFARMED — 7.1.2 (Antifúngicos) e Interac.: "Griseofulvina: possível inibição da eficácia do contraceptivo oral" (l. 46053); EMC-UK (MHRA) — SmPC Griseofulvin: https://www.medicines.org.uk/emc/product/2851/smpc (secção 4.6: "should not be used in pregnant patients or in those intending to become pregnant").',
   'Prontuário Terapêutico INFARMED — 7.1.2 (Antifungals) and Interactions: "Griseofulvin: possible inhibition of oral contraceptive efficacy" (l. 46053); EMC-UK (MHRA) — Griseofulvin SmPC: https://www.medicines.org.uk/emc/product/2851/smpc (section 4.6: "should not be used in pregnant patients or in those intending to become pregnant").'),

  -- ------------------------------------------------------------------
  -- 6. Carbimazol (Lote 3) — bócio/aplasia cutânea neonatal
  -- ------------------------------------------------------------------
  ('carbimazol', 'caution',
   'As tiomamidas (carbimazol e o metabolito tiamazol) atravessam a placenta e podem causar bócio fetal e neonatal, hipotiroidismo e aplasia cutânea neonatal (defeito localizado do couro cabeludo). O Prontuário regista "Bócio neonatal" para o carbimazol (Anexo 1). O hipertiroidismo materno não controlado associa-se, ele próprio, a aborto, prematuridade e bócio fetal — o tratamento deve ser mantido com a dose mínima eficaz.',
   'Thionamides (carbimazole and its metabolite thiamazole/methimazole) cross the placenta and can cause fetal and neonatal goitre, hypothyroidism and neonatal aplasia cutis (localised scalp defect). The Prontuário records "Neonatal goitre" for carbimazole (Annex 1). Uncontrolled maternal hyperthyroidism itself is associated with miscarriage, prematurity and fetal goitre — treatment should be continued at the lowest effective dose.',
   'Usar apenas se necessário, na dose mínima eficaz, e preferir o propiltiouracilo no 1.º trimestre (menor risco de malformações congénitas com carbimazol/tiamazol nesse período); trocar para carbimazol no 2.º–3.º trimestres pelo risco de hepatotoxicidade do PTU. Vigilância fetal (bócio, frequência cardíaca) e função tiroideia neonatal.',
   'Use only if necessary, at the lowest effective dose, and prefer propylthiouracil in the 1st trimester (lower risk of congenital malformations with carbimazole/thiamazole in that period); switch to carbimazole in the 2nd–3rd trimesters because of PTU hepatotoxicity. Fetal surveillance (goitre, heart rate) and neonatal thyroid function.',
   'O carbimazol/tiamazol é excretado no leite e pode causar hipotiroidismo e bócio no lactente ("Tiamazol... presente no leite"; produtor recomenda evitar). Se a amamentação for imprescindível, usar dose mínima (≤15 mg/dia) e vigiar a tiroideia do lactente; historicamente recomenda-se evitar.',
   'Carbimazole/thiamazole is excreted into milk and can cause hypothyroidism and goitre in the infant ("Thiamazole... present in milk"; the manufacturer recommends avoiding). If breastfeeding is essential, use the minimum dose (≤15 mg/day) and monitor infant thyroid function; historically it is recommended to avoid.',
   'Tratar o hipertiroidismo antes de planear a gravidez; a tirotoxicose não tratada na gravidez associa-se a aborto e pré-eclâmpsia.',
   'Treat hyperthyroidism before planning pregnancy; untreated thyrotoxicosis in pregnancy is associated with miscarriage and pre-eclampsia.',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Carbimazol — Bócio neonatal" (l. 39611); 8.5 (Tiamazol, p. 357); EMC-UK (MHRA) — SmPC Carbimazole: https://www.medicines.org.uk/emc/product/2175/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Carbimazole — Neonatal goitre" (l. 39611); 8.5 (Thiamazole, p. 357); EMC-UK (MHRA) — Carbimazole SmPC: https://www.medicines.org.uk/emc/product/2175/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 7. Propiltiouracilo (Lote 3) — preferencial no 1.º trimestre
  -- ------------------------------------------------------------------
  ('propiltiouracilo', 'caution',
   'Como as restantes tiomamidas, atravessa a placenta e pode causar bócio fetal, hipotiroidismo fetal/neonatal e aplasia cutânea neonatal. Historicamente é a tiomamida preferida no 1.º trimestre, porque o carbimazol/tiamazol se associa a um padrão específico de malformações congénitas (aplasia cutânea, atresia das coanas, defeitos abdominais).',
   'Like the other thionamides, it crosses the placenta and can cause fetal goitre, fetal/neonatal hypothyroidism and neonatal aplasia cutis. Historically it is the preferred thionamide in the 1st trimester, because carbimazole/thiamazole is associated with a specific pattern of congenital malformations (aplasia cutis, choanal atresia, abdominal defects).',
   'Preferir no 1.º trimestre à menor dose eficaz; considerar a troca para carbimazol nos 2.º–3.º trimestres pelo risco de hepatotoxicidade materna grave do propiltiouracilo. Vigilância da função tiroideia materna e fetal.',
   'Preferred in the 1st trimester at the lowest effective dose; consider switching to carbimazole in the 2nd–3rd trimesters because of the risk of serious maternal propylthiouracil hepatotoxicity. Monitor maternal and fetal thyroid function.',
   'O propiltiouracilo excreta-se no leite em menor quantidade e com menos risco de hipotiroidismo neonatal do que o tiamazol; alguns autores consideram-no a tiomamida preferida se amamentar — sempre na dose mínima e com vigilância da tiroideia do lactente.',
   'Propylthiouracil is excreted into milk in smaller amounts and with less risk of neonatal hypothyroidism than thiamazole; some authors consider it the preferred thionamide if breastfeeding — always at the minimum dose and monitoring infant thyroid function.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 8.5 (Antitiroideus); Anexo 1 (V. Tiomamidas); EMC-UK (MHRA) — SmPC Propylthiouracil: https://www.medicines.org.uk/emc/product/6472/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — 8.5 (Antithyroid agents); Annex 1 (See Thionamides); EMC-UK (MHRA) — Propylthiouracil SmPC: https://www.medicines.org.uk/emc/product/6472/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 8. Sulfato de magnésio (Lote 3) — de escolha na pré-eclâmpsia
  -- ------------------------------------------------------------------
  ('sulfato-magnesio', 'compatible',
   'O sulfato de magnésio IV é o neuroprotetor e anticonvulsivante de escolha na pré-eclâmpsia/eclâmpsia grave e para neuroproteção fetal na ameaça de parto prematuro (<32 semanas); largamente usado em obstetrícia com perfil de segurança fetal bem estabelecido. Em doses tocolíticas prolongadas pode associar-se a hipotonia, depressão respiratória e hipocalcemia neonatais.',
   'IV magnesium sulfate is the anticonvulsant and neuroprotective agent of choice in severe pre-eclampsia/eclampsia and for fetal neuroprotection in threatened preterm labour (<32 weeks); widely used in obstetrics with a well-established fetal safety profile. At prolonged tocolytic doses it may be associated with neonatal hypotonia, respiratory depression and hypocalcaemia.',
   'Uso continuado em obstetrícia é clínica padrão; administrar sob vigilância dos reflexos, frequência respiratória e débito urinário maternos (toxicidade do magnésio). O Prontuário nota o seu papel tocolítico e o uso "com precaução em caso de IH" (7.2.3).',
   'Continued use in obstetrics is standard practice; administer under maternal monitoring of reflexes, respiratory rate and urine output (magnesium toxicity). The Prontuário notes its tocolytic role and use "with caution in liver disease" (7.2.3).',
   'Excreta-se no leite em quantidades pequenas; não há relatos de efeitos adversos no lactente em doses obstétricas habituais — compatível.',
   'Excreted into milk in small amounts; no reports of adverse effects in infants at usual obstetric doses — compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 7.2.3: "os sais de magnésio (sulfato de magnésio) são também eficazes como tocolíticos... Deve ser usado com precaução em caso de IH" (l. 24080-90); EMC-UK (MHRA) — SmPC Magnesium Sulfate Injection.',
   'Prontuário Terapêutico INFARMED — 7.2.3: "magnesium salts (magnesium sulfate) are also effective as tocolytics... Should be used with caution in liver disease" (l. 24080-90); EMC-UK (MHRA) — Magnesium Sulfate Injection SmPC.'),

  -- ------------------------------------------------------------------
  -- 9. Deferoxamina (Lote 3) — segurança não estabelecida
  -- ------------------------------------------------------------------
  ('deferoxamina', 'caution',
   'A segurança da deferoxamina na gravidez não está estabelecida; os dados em animais mostram esquelética/embriotoxicidade com doses elevadas. Contudo, a sobrecarga férrica não tratada (talassémia transfundida) é também prejudicial à gestação — o benefício pode justificar o uso em sobrecarga grave.',
   'The safety of deferoxamine in pregnancy is not established; animal data show skeletal/embryotoxicity at high doses. However, untreated iron overload (transfusion-dependent thalassaemia) is also harmful to pregnancy — benefit may justify use in severe overload.',
   'Evitar, salvo se o benefício (redução da sobrecarga férrica) justificar claramente o risco; limitar a quelação ao período estritamente necessário e documentar a decisão.',
   'Avoid unless the benefit (reducing iron overload) clearly justifies the risk; limit chelation to the period strictly necessary and document the decision.',
   'Desconhece-se a excreção no leite; aconselha-se evitar a amamentação durante o tratamento por falta de dados.',
   'Excretion into milk is unknown; breastfeeding is advised against during treatment due to lack of data.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 8.3 (Deferoxamina); EMC-UK (MHRA) — SmPC Desferrioxamine: https://www.medicines.org.uk/emc/product/1644/smpc (secção 4.6: "avoid unless clearly necessary").',
   'Prontuário Terapêutico INFARMED — 8.3 (Deferoxamine); EMC-UK (MHRA) — Desferrioxamine SmPC: https://www.medicines.org.uk/emc/product/1644/smpc (section 4.6: "avoid unless clearly necessary").'),

  -- ------------------------------------------------------------------
  -- 10. Ciproterona (Lote 4) — antiandrogénio; contraindicada
  -- ------------------------------------------------------------------
  ('ciproterona', 'contraindicated',
   'Contraindicada na gravidez: a ciproterona é um antiandrogénio esteróide que, administrada a uma mulher grávida, causaria feminização/efeitos antiandrogénicos num feto masculino (hipospadias, subdesenvolvimento genital) e contraindica-se também em situações perto do parto. O Prontuário regista: "O produtor recomenda evitar na gravidez confirmada" (factor CM) e "Contra-indicado durante a gravidez, o parto e o período expulsivo".',
   'Contraindicated in pregnancy: cyproterone is a steroidal antiandrogen which, if given to a pregnant woman, would cause antiandrogenic effects on a male fetus (hypospadias, underdeveloped genitalia); it is also contraindicated near delivery. The Prontuário records: "The manufacturer recommends avoiding in confirmed pregnancy" (factor CM) and "Contraindicated during pregnancy, labour and the expulsive period".',
   'Contraindicada em todos os trimestres; suspender e confirmar ausência de gravidez antes de iniciar o tratamento (indications dermatológicas/hirsutismo) e depois de cada ciclo se se recorrer à associação com etinilestradiol.',
   'Contraindicated in all trimesters; discontinue and confirm absence of pregnancy before starting treatment (dermatological indications/hirsutism) and after each cycle if using the ethinylestradiol combination.',
   'Recomenda-se evitar (Prontuário, Anexo 2); os antiandrogénios podem suprimir a lactação e a excreção no leite é desconhecida — não amamentar durante o tratamento.',
   'Avoidance is recommended (Prontuário, Annex 2); antiandrogens may suppress lactation and excretion into milk is unknown — do not breastfeed during treatment.',
   'Contracepção eficaz obrigatória durante o tratamento (e 1 ciclo após); a associação co-cyprindiol já contém etinilestradiol para contracepção — confirmar adesão.',
   'Effective contraception mandatory during treatment (and 1 cycle after); the co-cyprindiol combination already contains ethinylestradiol for contraception — confirm adherence.',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Ciproterona — O produtor recomenda evitar na gravidez confirmada (CM)"; "Contra-indicado durante a gravidez, o parto e o período expulsivo"; Anexo 2: "Ciproterona — Recomenda-se evitar" (l. 42369). EMC-UK (MHRA) — SmPC Co-cyprindiol/Diane-35: https://www.medicines.org.uk/emc/product/1804/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Cyproterone — The manufacturer recommends avoiding in confirmed pregnancy (CM)"; "Contraindicated during pregnancy, labour and the expulsive period"; Annex 2: "Cyproterone — Avoidance is recommended" (l. 42369). EMC-UK (MHRA) — Co-cyprindiol/Diane-35 SmPC: https://www.medicines.org.uk/emc/product/1804/smpc (section 4.6).')

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
--     WHERE d.slug IN ('misoprostol','metilergometrina','retinol',
--                      'griseofulvina','testosterona','ciproterona',
--                      'carbimazol','propiltiouracilo','sulfato-magnesio',
--                      'deferoxamina') AND p.is_archived = false;
--   → 10
--
-- Categorias: contraindicated ×5 (misoprostol, metilergometrina, testosterona,
-- griseofulvina, ciproterona) · caution ×4 (retinol, carbimazol,
-- propiltiouracilo, deferoxamina) · compatible ×1 (sulfato-magnesio)
-- ============================================================================
