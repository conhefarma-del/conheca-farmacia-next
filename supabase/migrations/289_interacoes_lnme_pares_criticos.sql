-- =====================================================================
-- 289: LNME — pares fármaco-fármaco em falta + fecho da auditoria de
--      cobertura (28 LNME com zero pares no Fluxo 1)
-- =====================================================================
-- NOTA DE NUMERAÇÃO: o pedido original era "287", mas 287 está ocupada
-- pela gravidez (287_pregnancy_lotes34_final.sql, commit 437d642); a 288
-- é o fecho no_data da mesma dimensão. Esta é a 289 — mesmo critério
-- seguido na 272 (que subiu de 271 para 272 por colisão).
-- =====================================================================
-- CONTEXTO: a auditoria de cobertura FF (_temp/_auditar_fluxo1_lnme.mjs →
-- _temp/_fluxo1_coverage.json) identificou 782 pares published no Fluxo 1
-- e 28 fármacos LNME (Lotes 1–4) com ZERO pares FF. A verificação de
-- 2026-10-02 (_temp/_zero_pairs_artefacto.mjs) confirmou que os 28 são
-- reais (slugs activos e publicados — não é artefacto do merge 283).
--
-- Esta migração faz duas coisas:
--   PARTE A — cria os pares clinicamente documentados que faltavam
--             (21 pares), com prioridade aos críticos: flumazenil ×
--             benzodiazepinas, tiomamidas × anticoagulantes, dobutamina ×
--             betabloqueantes, nitroprussiato × anti-hipertensores.
--   PARTE B — fecha a auditoria de JUSTIFICAÇÕES: inventário dos 28 com
--             indicação de onde cada exclusão estava registada e das que
--             passam a estar documentadas aqui (14 estavam em falta).
--   PARTE C — limpeza de 4 pares órfãos duplicados (slugs underscore
--             arquivados pelo merge 283 a apontar para fármacos inactivos).
--
-- =====================================================================
-- INVENTÁRIO DOS 28 LNME SEM PARES (estado APÓS esta migração)
-- =====================================================================
-- Com par criado aqui (12):
--   flumazenil         → 1. midazolam (critical), 2. imipramina (critical)
--   dobutamina         → 3. metoprolol (critical), 4. propranolol (critical)
--   carbimazol         → 5. warfarina (critical), 17. iodopovidona (moderate)
--   propiltiouracilo   → 6. warfarina (critical), 18. iodopovidona (moderate)
--   nitroprussiato     → 7. enalapril (moderate), 8. metoprolol (moderate)
--   sulfato-zinco      → 9. ciprofloxacina (moderate), 10. sulfato-ferroso (moderate)
--   acido-ascorbico    → 11. deferoxamina (critical), 12. sulfato-ferroso (minor)
--   acido-folico       → 13. fenitoina (moderate)
--   mebendazol         → 14. cimetidina, 15. carbamazepina, 16. fenitoina (moderate)
--   iodopovidona       → 17/18. carbimazol, propiltiouracilo (moderate)
--   noreisterona       → 19. rifampicina (critical), 20. carbamazepina, 21. fenitoina (moderate)
--   deferoxamina       → 11. acido-ascorbico (critical)
--
-- Sem par — justificação JÁ registada na migração de origem (9):
--   clotrimazol        — 259, cabeçalho: "clotrimazol × amiodarona NÃO criado
--                        (absorção sistémica mínima do tópico — interação QT só
--                        relevante para fluconazol/itraconazol/cetoconazol orais)".
--   retinol            — 259, cabeçalho: "retinol × tetraciclina NÃO criado
--                        (falta rótulo mono-ingrediente retinol nos EUA)"; grupo
--                        "retinol/tiamina: SEM pares".
--   tiamina            — 259, cabeçalho: "tiamina × diltiazem NÃO criado";
--                        grupo "retinol/tiamina: SEM pares".
--   lidocaina          — 267, rodapé: "iodopovidona/clorexidina/tetracaina/
--                        lidocaina tópica: interações sistémicas clinicamente
--                        relevantes não documentadas nos rótulos mono-ingrediente".
--   tetracaina         — 267 rodapé (idem) + 271, rodapé: "tetracaina × lidocaina
--                        — anestésicos locais do mesmo grupo; toxicidade sistémica
--                        combinada é conceito de dose máxima (rótulo), não
--                        interação adversa entre fármacos distintos".
--   clorexidina        — 267, rodapé (idem: antisséptico tópico).
--   clomifeno          — 267, rodapé: "clomifeno × testosterona — sem
--                        documentação adversa direta".
--   piridoxina         — 267, cabeçalho: grupo "Vitamina C / zinco / piridoxina:
--                        SEM pares (suplementos sem interações clinicamente
--                        relevantes documentadas nos rótulos mono-ingrediente)".
--   espectinomicina    — 271, rodapé: "espectinomicina × outros aminoglicosídeos —
--                        ototoxicidade/nefrotoxicidade aditiva teoricamente evidente,
--                        mas sem rótulo humano a documentar (regra 13.1)".
--                        + 272, rodapé (idem).
--   permanganato-potassio — 272, rodapé: "permanganato × antiácidos/quinolonas —
--                        uso externo sem absorção sistémica relevante; interação
--                        sistémica não aplicável".
--   vitamina-d         — 267, rodapé ("vitamina-d × corticoide em doses
--                        fisiológicas: OMITIDOS") + 271, rodapé ("vitamina-d ×
--                        tiazidas — sem parceiro tiazida activo na base").
--   ciproterona        — 260/264/268, cabeçalhos: "sem rótulo FDA humano
--                        (Europa)" — nota de classe; ver nota nova em PARTE B.
--
-- Sem par — justificação DOCUMENTADA AGORA (5, era omissa):
--   pirantel, amoxicilina-acido-clavulanico, bupivacaina, progesterona,
--   ciproterona (nota explícita de pares FF, para além da nota de inclusão).
--   Ver PARTE B.
--
-- CORRECÇÃO DE AUDITORIA (transparência): o cabeçalho da 267 afirma que a ficha
--   do propiltiouracilo documenta "potencia o efeito dos anticoagulantes". Essa
--   frase pertence à ficha da LEVOTIROXINA SÓDICA (Prontuário 8.3, l. 25847-25852:
--   "Interac.: Potencia o efeito dos anticoagulantes, pelo que no início do
--   tratamento a dose destes fármacos deve ser reduzida de um terço a metade"),
--   não ao PTU — cuja ficha só refere indutores enzimáticos (l. 25890-25893).
--   O par tiomamidas × anticoagulantes criado aqui (itens 5/6) assenta, por isso,
--   na farmacologia do estado tiroideu face aos AVK e não nessa atribuição.
--
-- =====================================================================
-- Fontes (lista única de verdade, conforme Fluxo 1):
--   1. Rótulos com validação em linha:
--      - Flumazenil Injection USP (Pfizer), Warnings — convulsões de
--        abstinência em doentes dependentes de benzodiazepinas; exclusão em
--        intoxicação mista: https://labeling.pfizer.com/ShowLabeling.aspx?id=684
--      - Dobutamina (Pfizer labeling): "The inotropic effect of dobutamine
--        stems from stimulation of cardiac beta1 receptors, this effect is
--        reversed by concomitant administration of beta-blockers":
--        https://labeling.pfizer.com/ShowLabeling.aspx?id=16395
--      - EMC-UK — Dobutamine 5 mg/ml solution for infusion, SmPC 4.5 (efeitos
--        agonistas alfa com vasoconstrição periférica e subida da PA):
--        https://www.medicines.org.uk/emc/product/6462/smpc
--      - FDA — Desferal (deferoxamine mesylate), Drug Interactions (vitamina C:
--        disfunção cardíaca em sobrecarga férrica crónica grave com doses
--        > 500 mg/dia): https://www.accessdata.fda.gov/drugsatfda_docs/label/2007/016267s044lbl.pdf
--      - DailyMed — Ciprofloxacin (setID c47250c2-bece-46b5-8b3b-b7c97d9005d8,
--        validado na 267) para a quelação por catiões.
--   2. Prontuário Terapêutico INFARMED (11.ª ed., 2012) — referências por linha
--      do ficheiro fontes_interacoes/prontuario_utf8.txt:
--      - Mebendazol 1.4.1 (l. 4541-4545): carbamazepina/fenitoína reduzem as
--        concentrações do mebendazol (indução enzimática); cimetidina inibe o
--        seu metabolismo, potenciando os efeitos (só significativo em
--        terapêuticas prolongadas).
--      - Pirantel 1.4.1 (l. 4563): "O pirantel e a piperazina são antagonistas
--        não sendo, por isso, recomendada a sua co-administração."
--      - Quinolonas 1.1 (l. 2330-2332): "a sua absorção é significativamente
--        reduzida pelos fármacos com catiões bi e trivalentes como os antiácidos
--        com alumínio, magnésio ou cálcio, suplementos com ferro ou zinco".
--      - Ferro 4.1.1 (l. 17557-17562): "Reduzem a absorção do ferro: os
--        antiácidos, as penicilinas, as tetraciclinas, a trientina e o zinco. Os
--        sais de ferro reduzem a absorção de bifosfonatos, ciprofloxacina,
--        norfloxacina, ofloxacina, tetraciclinas, levodopa e zinco. O ácido
--        ascórbico potencia a absorção (30 mg para 200 mg de ferro)."
--      - Ácido fólico 4.1.2 (l. 17623-17626): "O ácido fólico pode aumentar o
--        metabolismo da fenitoína com redução das concentrações séricas do
--        antiepilético e possível aumento da frequência de convulsões."
--      - Fenitoína 2.6 (l. 6062): "aumenta o metabolismo dos corticosteróides,
--        dos contraceptivos orais e da nisoldipina".
--      - Carbamazepina 2.6 (l. 5996-5998): "redução do efeito dos anticoagulantes
--        e dos contraceptivos orais".
--      - Iodopovidona 13.1.1 (l. 32182-32188): "pode ser absorvido em quantidade
--        suficiente para afectar a tiróide fetal; evitar a utilização em feridas
--        extensas dado o risco de absorção sistémica; em doentes com perturbações
--        tiroideias e em IR. Interac.: Pode interferir no resultado dos testes de
--        função tiroideia."
--      - Nitroprussiato (l. 44322): "evitar utilização prolongada na IR".
--      - Anexo 7 — ARA II (l. 45529): "Aumentam o efeito hipotensor quando
--        associados a ARA II: ... Bloqueadores adrenérgicos beta, ... Moxonidina,
--        Nitroprussiato de sódio, Nitratos ...".
--      - Anexo 7 — Flumazenilo (l. 45027): "risco maior 24h a seguir à
--        administração pois pode voltar a aparecer efeito da benzodiazepina".
--      - Anexo 7 — Estrogénios/contraceptivos (l. 46301): "Estrogénios (com
--        possível redução do risco contraceptivo)" com indutores enzimáticos.
--      - Desferroxamina (l. 38118-38120): ficha DESFERAL (Interac. com
--        procloroperazina; excreção de gálio-67) — ver nota em PARTE B.
--   3. Literatura de suporte (tiomamidas × AVK):
--      - Drugs.com, monografia profissional Methimazole/Warfarin:
--        "Anticoagulation effects may be increased or decreased with the
--        concomitant use of antithyroid drugs and vitamin K antagonists."
--      - Howard-Thompson A. et al., Graves Disease and Treatment Effects on
--        Warfarin (PMC4065757): hiperfunção tiroideia ↑ sensibilidade à
--        varfarina, com INR supraterapêutico:
--        https://pmc.ncbi.nlm.nih.gov/articles/PMC4065757/
--   4. EMC-Portugal / Infomed — nomes DCI PT.
--
-- Metodologia (docs/INTERACOES_FLUXO_PESQUISA.md, Fluxo 1):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * severidade em {minor, moderate, critical} (padrão 052–059);
--   * idempotente: ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING.
-- =====================================================================

-- =====================================================================
-- PARTE A — pares fármaco-fármaco em falta (21 tuples)
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
-- 1. flumazenil × midazolam (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='flumazenil'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='flumazenil'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 'critical',
 'O Flumazenil reverte a sedação do Midazolam, mas pode precipitar convulsões de abstinência em doentes com uso crónico de benzodiazepinas ou em intoxicação mista, e a sedação reaparece após a reversão (resedação).',
 'Flumazenil reverses midazolam sedation but may precipitate withdrawal seizures in chronic benzodiazepine users or in mixed overdose, and sedation reappears after reversal (resedation).',
 'Antagonismo competitivo no receptor benzodiazepínico do GABA-A: a reversão abrupta remove o efeito depressor e desmascara um estado hiperexcitável com rebaixamento do limiar convulsivo; a semivida curta do flumazenil (≈1 h) é inferior à do midazolam, pelo que a sedação reaparece (Prontuário, Anexo 7 — Flumazenilo: "pode voltar a aparecer efeito da benzodiazepina").',
 'Competitive antagonism at the GABA-A benzodiazepine receptor: abrupt reversal removes the depressant effect and unmasks a hyperexcitable state with a lowered seizure threshold; flumazenil has a short half-life (≈1 h), shorter than midazolam, so sedation reappears (Prontuário, Annex 7 — Flumazenil: "the benzodiazepine effect may reappear").',
 'Usar apenas com indicação precisa (intoxicação por benzodiazepinas com depressão respiratória); excluir intoxicação mista com tricíclicos ou outros pró-convulsivantes antes de administrar; titular em incrementos de 0,2 mg e vigiar em local com suporte de via aérea e benzodiazepina de resgate disponível.',
 'Use only with a precise indication (benzodiazepine overdose with respiratory depression); exclude mixed overdose with tricyclics or other proconvulsants before administration; titrate in 0.2 mg increments and monitor where airway support and rescue benzodiazepine are available.',
 'Estado de consciência, frequência respiratória, SpO2 e ECG; reavaliar a sedação nas 2 h seguintes e aconselhar a não conduzir nas 24 h (Prontuário, Anexo 7).',
 'Consciousness, respiratory rate, SpO2 and ECG; reassess sedation over the next 2 h and advise against driving for 24 h (Prontuário, Annex 7).',
 'Convulsões, agitação paradoxal, reaparecimento da depressão respiratória.',
 'Seizures, paradoxical agitation, recurrence of respiratory depression.',
 'Rótulo Flumazenil Injection USP (Pfizer), Warnings — convulsões de abstinência em doentes dependentes de benzodiazepinas: https://labeling.pfizer.com/ShowLabeling.aspx?id=684; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Flumazenilo (reaparição do efeito da benzodiazepina).',
 'Flumazenil Injection USP (Pfizer) label, Warnings — withdrawal seizures in benzodiazepine-dependent patients: https://labeling.pfizer.com/ShowLabeling.aspx?id=684; INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Flumazenil (benzodiazepine effect may reappear).',
 'published', now()),

-- 2. flumazenil × imipramina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='flumazenil'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='flumazenil'), (SELECT id FROM public.drugs WHERE slug='imipramina')),
 'critical',
 'Em intoxicação mista por antidepressivos tricíclicos e benzodiazepinas, o Flumazenil pode precipitar convulsões e arritmias potencialmente fatais.',
 'In mixed overdose with tricyclic antidepressants and benzodiazepines, flumazenil may precipitate potentially fatal seizures and arrhythmias.',
 'O flumazenil remove o efeito protector das benzodiazepinas sobre um limiar convulsivo já reduzido pelo tricíclico (bloqueio dos canais de sódio, efeito antimuscarínico e pró-convulsivante); a sobreposição precipita convulsões e arritmias ventriculares — situação formalmente excluída do uso do flumazenil.',
 'Flumazenil removes the protective benzodiazepine effect on a seizure threshold already lowered by the tricyclic (sodium channel blockade, antimuscarinic and proconvulsant effects); the overlap precipitates seizures and ventricular arrhythmias — a situation formally excluded from flumazenil use.',
 'Não administrar flumazenil quando se suspeita intoxicação mista por tricíclicos; sedar com benzodiazepinas, tratar a cardiotoxicidade tricíclica com bicarbonato de sódio e contactar o centro de intoxicações.',
 'Do not give flumazenil when mixed tricyclic overdose is suspected; sedate with benzodiazepines, treat tricyclic cardiotoxicity with sodium bicarbonate and contact the poison centre.',
 'ECG (largura do QRS), gasometria, eletrólitos, estado neurológico, ritmo cardíaco em monitor.',
 'ECG (QRS width), blood gases, electrolytes, neurological status, monitored cardiac rhythm.',
 'Alargamento do QRS, convulsões, arritmias ventriculares, coma.',
 'QRS widening, seizures, ventricular arrhythmias, coma.',
 'Rótulo Flumazenil Injection USP (Pfizer) — uso excluído em intoxicação mista/doentes com risco convulsivo: https://labeling.pfizer.com/ShowLabeling.aspx?id=684; Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Imipramina (toxicidade cardiovascular e convulsiva do tricíclico).',
 'Flumazenil Injection USP (Pfizer) label — use excluded in mixed overdose/patients at seizure risk: https://labeling.pfizer.com/ShowLabeling.aspx?id=684; INFARMED Prontuário Terapêutico (11th ed., 2012), Imipramine entry (tricyclic cardiovascular and convulsive toxicity).',
 'published', now()),

-- 3. dobutamina × metoprolol (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='dobutamina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dobutamina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'critical',
 'O betabloqueio β1 antagoniza directamente o efeito inotrópico da Dobutamina, com risco de deterioração hemodinâmica em doentes dependentes do inotrópico.',
 'β1 blockade directly antagonises the inotropic effect of dobutamine, with a risk of haemodynamic deterioration in patients dependent on the inotrope.',
 'O efeito inotrópico da dobutamina resulta da estimulação dos receptores cardíacos β1 e é revertido pela administração concomitante de betabloqueantes; com o β1 bloqueado, os efeitos agonistas alfa tornam-se dominantes e podem causar vasoconstrição periférica e subida da tensão arterial.',
 'The inotropic effect of dobutamine derives from cardiac β1 receptor stimulation and is reversed by concomitant beta-blocker administration; with β1 blocked, alpha-agonist effects become dominant and may cause peripheral vasoconstriction and a rise in blood pressure.',
 'Titular a dose com monitorização hemodinâmica; em doente sob betabloqueante crónico prever resposta inotrópica reduzida e considerar alternativas não adrenérgicas (inibidores da fosfodiesterase III ou sensibilizador do cálcio) ou, em intoxicação por betabloqueante, tratar primeiro o antagonismo.',
 'Titrate the dose under haemodynamic monitoring; in patients on chronic beta-blockade expect a reduced inotropic response and consider non-adrenergic alternatives (phosphodiesterase III inhibitors or calcium sensitisers) or, in beta-blocker poisoning, treat the antagonism first.',
 'PA invasiva, índice cardíaco, ECG contínuo, lactatos, diurese e perfusão periférica.',
 'Invasive blood pressure, cardiac index, continuous ECG, lactate, urine output and peripheral perfusion.',
 'Hipotensão refractária, arritmias, oligúria, acidose láctica, extremidades frias.',
 'Refractory hypotension, arrhythmias, oliguria, lactic acidosis, cold extremities.',
 'Rótulo Dobutamine (Pfizer labeling) — "The inotropic effect of dobutamine stems from stimulation of cardiac beta1 receptors, this effect is reversed by concomitant administration of beta-blockers": https://labeling.pfizer.com/ShowLabeling.aspx?id=16395; EMC-UK — Dobutamine 5 mg/ml solution for infusion, SmPC 4.5 (efeitos alfa não opostos com vasoconstrição e hipertensão): https://www.medicines.org.uk/emc/product/6462/smpc',
 'Dobutamine label (Pfizer labeling) — "The inotropic effect of dobutamine stems from stimulation of cardiac beta1 receptors, this effect is reversed by concomitant administration of beta-blockers": https://labeling.pfizer.com/ShowLabeling.aspx?id=16395; EMC-UK — Dobutamine 5 mg/ml solution for infusion, SmPC 4.5 (unopposed alpha effects with vasoconstriction and hypertension): https://www.medicines.org.uk/emc/product/6462/smpc',
 'published', now()),

-- 4. dobutamina × propranolol (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='dobutamina'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dobutamina'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 'critical',
 'O Propranolol bloqueia β1 e β2 e antagoniza o efeito inotrópico da Dobutamina de forma mais marcada, com risco de perda de suporte inotrópico, vasoconstrição periférica e hipertensão paradoxal.',
 'Propranolol blocks both β1 and β2 and antagonises the inotropic effect of dobutamine more markedly, with a risk of loss of inotropic support, peripheral vasoconstriction and paradoxical hypertension.',
 'Além da reversão do efeito β1 (inotrópico), o bloqueio β2 remove a vasodilatação mediada pelos receptores beta-2 vasculares, deixando os efeitos alfa da dobutamina não opostos — o resultado é vasoconstrição periférica com aumento da resistência vascular e da pressão arterial (rótulo do propranolol: interação com aminas simpaticomiméticas).',
 'Besides reversing the β1 (inotropic) effect, β2 blockade removes beta-2-mediated vasodilation, leaving dobutamine alpha effects unopposed — the result is peripheral vasoconstriction with increased vascular resistance and blood pressure (propranolol label: interaction with sympathomimetic amines).',
 'Evitar a associação em doentes que dependem do inotrópico; se o betabloqueante for indispensável, usar o menor efeito cronotrópico/inotrópico negativo possível e vigiar com monitorização invasiva; considerar inodilatador como alternativa.',
 'Avoid the combination in patients dependent on the inotrope; if the beta-blocker is indispensable, use the least negative chronotropic/inotropic option and monitor invasively; consider an inodilator as an alternative.',
 'PA invasiva, índice cardíaco e resistências vasculares, ECG contínuo, lactatos, perfusão periférica.',
 'Invasive blood pressure, cardiac index and vascular resistance, continuous ECG, lactate, peripheral perfusion.',
 'Hipotensão com extremidades frias, hipertensão paradoxal, oligúria, arritmias.',
 'Hypotension with cold extremities, paradoxical hypertension, oliguria, arrhythmias.',
 'Rótulo Dobutamine (Pfizer labeling): https://labeling.pfizer.com/ShowLabeling.aspx?id=16395; EMC-UK — Dobutamine 5 mg/ml solution for infusion, SmPC 4.5: https://www.medicines.org.uk/emc/product/6462/smpc; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Cardiotónicos 3.1 (aminas simpaticomiméticas exigem monitorização).',
 'Dobutamine label (Pfizer labeling): https://labeling.pfizer.com/ShowLabeling.aspx?id=16395; EMC-UK — Dobutamine 5 mg/ml solution for infusion, SmPC 4.5: https://www.medicines.org.uk/emc/product/6462/smpc; INFARMED Prontuário Terapêutico (11th ed., 2012), Cardiotonics 3.1 (sympathomimetic amines require monitoring).',
 'published', now()),

-- 5. carbimazol × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='carbimazol'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='carbimazol'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'O Carbimazol altera o estado tiroideu e modifica de forma imprevisível o efeito anticoagulante da Warfarina, com risco de hemorragia (INR supraterapêutico) ou de falha anticoagulante (INR infraterapêutico).',
 'Carbimazole changes thyroid status and unpredictably alters the anticoagulant effect of warfarin, with a risk of bleeding (supratherapeutic INR) or of anticoagulant failure (subtherapeutic INR).',
 'A hiperfunção tiroideia aumenta o catabolismo dos factores de coagulação dependentes da vitamina K e a sensibilidade à varfarina; quando a tiomamida restaura o eutiroidismo as necessidades de varfarina mudam (habitualmente com redução de dose), pelo que o efeito anticoagulante pode aumentar ou diminuir ao longo das 6–8 semanas de reequilíbrio tiroideu.',
 'Hyperthyroidism increases catabolism of vitamin K-dependent clotting factors and sensitivity to warfarin; when the thionamide restores euthyroidism, warfarin requirements change (usually a dose reduction), so the anticoagulant effect may increase or decrease over the 6–8 weeks of thyroid rebalancing.',
 'Determinar o INR antes de iniciar e a cada 1–2 semanas durante o ajuste da função tiroideia, com ajuste posológico em passos pequenos; o efeito é bidireccional, pelo que se vigia tanto hemorragia como trombose.',
 'Measure INR before starting and every 1–2 weeks while thyroid function is being adjusted, with small dose steps; the effect is bidirectional, so monitor for both bleeding and thrombosis.',
 'INR frequente, TSH e T4 livre, hemoglobina, sinais hemorrágicos e de trombose.',
 'Frequent INR, TSH and free T4, haemoglobin, bleeding and thrombotic signs.',
 'Epistaxis, gengivorragia, hematúria, melenas, cefaleia súbita; dor e edema de membro (trombose).',
 'Epistaxis, gum bleeding, haematuria, melaena, sudden headache; limb pain and swelling (thrombosis).',
 'Drugs.com, monografia profissional Methimazole/Warfarin — "Anticoagulation effects may be increased or decreased with the concomitant use of antithyroid drugs and vitamin K antagonists"; Howard-Thompson A. et al., Graves Disease and Treatment Effects on Warfarin (PMC4065757): https://pmc.ncbi.nlm.nih.gov/articles/PMC4065757/; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.3 Hormonas da tiróide e antitiroideus.',
 'Drugs.com professional monograph Methimazole/Warfarin — "Anticoagulation effects may be increased or decreased with the concomitant use of antithyroid drugs and vitamin K antagonists"; Howard-Thompson A. et al., Graves Disease and Treatment Effects on Warfarin (PMC4065757): https://pmc.ncbi.nlm.nih.gov/articles/PMC4065757/; INFARMED Prontuário Terapêutico (11th ed., 2012), 8.3 Thyroid hormones and antithyroid drugs.',
 'published', now()),

-- 6. propiltiouracilo × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='propiltiouracilo'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='propiltiouracilo'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'O Propiltiouracilo altera o estado tiroideu e o equilíbrio dos factores dependentes da vitamina K, modificando de forma imprevisível o efeito da Warfarina, com risco hemorrágico ou de falha anticoagulante.',
 'Propylthiouracil changes thyroid status and the balance of vitamin K-dependent factors, unpredictably altering the effect of warfarin, with a bleeding risk or anticoagulant failure.',
 'Mecanismo sobreponível ao do carbimazol: a normalização da função tiroideia pela tiomamida altera a síntese/catabolismo dos factores dependentes da vitamina K e a sensibilidade à varfarina, sendo o efeito final variável (aumento ou redução do INR); a própria febre por agranulocitose ou a icterícia hepatotóxica do PTU podem mascarar ou confundir sinais hemorrágicos.',
 'Mechanism overlapping that of carbimazole: thionamide-induced normalisation of thyroid function alters the synthesis/catabolism of vitamin K-dependent factors and warfarin sensitivity, with a variable net effect (INR up or down); PTU-related agranulocytosis fever or hepatotoxic jaundice may also mask or confuse bleeding signs.',
 'Determinar o INR antes de iniciar e a cada 1–2 semanas durante o ajuste da função tiroideia; ajustar a varfarina em passos pequenos; num contexto de febre ou icterícia, excluir agranulocitose e hepatotoxicidade do PTU antes de atribuir a alteração ao INR.',
 'Measure INR before starting and every 1–2 weeks while adjusting thyroid function; adjust warfarin in small steps; in the setting of fever or jaundice, exclude PTU agranulocytosis and hepatotoxicity before attributing the change to INR.',
 'INR frequente, TSH e T4 livre, hemograma com neutrófilos, transaminases, sinais hemorrágicos.',
 'Frequent INR, TSH and free T4, full blood count with neutrophils, transaminases, bleeding signs.',
 'Hemorragia, febre com odinofagia (agranulocitose), icterícia, dor abdominal (hepatotoxicidade).',
 'Bleeding, fever with sore throat (agranulocytosis), jaundice, abdominal pain (hepatotoxicity).',
 'Drugs.com, monografia profissional Methimazole/Warfarin — efeito anticoagulante "increased or decreased" com fármacos antitiroideus; Howard-Thompson A. et al. (PMC4065757): https://pmc.ncbi.nlm.nih.gov/articles/PMC4065757/; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.3 — ficha Propiltiouracilo (acertos posológicos com indutores; redução na IR).',
 'Drugs.com professional monograph Methimazole/Warfarin — anticoagulant effect "increased or decreased" with antithyroid drugs; Howard-Thompson A. et al. (PMC4065757): https://pmc.ncbi.nlm.nih.gov/articles/PMC4065757/; INFARMED Prontuário Terapêutico (11th ed., 2012), 8.3 — Propylthiouracil entry (dose adjustments with inducers; reduction in renal impairment).',
 'published', now()),

-- 7. nitroprussiato × enalapril (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='nitroprussiato'), (SELECT id FROM public.drugs WHERE slug='enalapril')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='nitroprussiato'), (SELECT id FROM public.drugs WHERE slug='enalapril')),
 'moderate',
 'A vasodilatação do Nitroprussiato soma-se à do Enalapril, com risco de hipotensão profunda, sobretudo na primeira dose e em doentes hipovolémicos ou com estenose da artéria renal.',
 'Nitroprusside vasodilation adds to that of enalapril, with a risk of profound hypotension, particularly with the first dose and in hypovolaemic patients or those with renal artery stenosis.',
 'Efeito hipotensor aditivo por mecanismos complementares: o nitroprussiato é um dador de óxido nítrico com vasodilatação arterial e venosa directa, e o IECA reduz a angiotensina II e a aldosterona; o Prontuário (Anexo 7, tabela dos ARA II) lista o nitroprussiato de sódio entre os fármacos que aumentam o efeito hipotensor.',
 'Additive hypotensive effect through complementary mechanisms: nitroprusside is a nitric oxide donor causing direct arterial and venous vasodilation, while the ACE inhibitor reduces angiotensin II and aldosterone; the Prontuário (Annex 7, ARA II table) lists sodium nitroprusside among drugs that increase the hypotensive effect.',
 'Iniciar o nitroprussiato na dose mais baixa e titular por PA invasiva; corrigir a volemia antes de iniciar em urgência hipertensiva com IECA em curso; suspender o IECA se a hipotensão for refractária.',
 'Start nitroprusside at the lowest dose and titrate by invasive blood pressure; correct volume status before starting in a hypertensive emergency with an ongoing ACE inhibitor; stop the ACE inhibitor if hypotension is refractory.',
 'PA invasiva ou contínua, função renal e potássio, diurese; na perfusão prolongada, vigiar toxicidade por cianeto/tiocianato (sobretudo em insuficiência renal — Prontuário: "evitar utilização prolongada na IR").',
 'Invasive or continuous blood pressure, renal function and potassium, urine output; during prolonged infusion monitor cyanide/thiocyanate toxicity (particularly in renal impairment — Prontuário: "avoid prolonged use in renal impairment").',
 'Hipotensão, bradicardia, oligúria, acidose metabólica, alteração do estado mental.',
 'Hypotension, bradycardia, oliguria, metabolic acidosis, altered mental state.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — "Aumentam o efeito hipotensor ... Nitroprussiato de sódio" (l. 45529) e nota de utilização prolongada na IR (l. 44322); EMC-Portugal — nomes DCI PT.',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — "Increase the hypotensive effect ... Sodium nitroprusside" and note on prolonged use in renal impairment; EMC-Portugal — PT INN names.',
 'published', now()),

-- 8. nitroprussiato × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='nitroprussiato'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='nitroprussiato'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'O Metoprolol atenua a taquicardia reflexa que compensa a vasodilatação do Nitroprussiato, podendo agravar a hipotensão e a bradicardia.',
 'Metoprolol blunts the reflex tachycardia that compensates nitroprusside-induced vasodilation, potentially worsening hypotension and bradycardia.',
 'Efeito hipotensor aditivo: o nitroprussiato dilata arteríolas e veias e o betabloqueante impede a resposta cronotrópica compensatória; o Prontuário (Anexo 7) lista os bloqueadores adrenérgicos beta entre os fármacos que aumentam o efeito hipotensor.',
 'Additive hypotensive effect: nitroprusside dilates arterioles and veins while the beta-blocker prevents the compensatory chronotropic response; the Prontuário (Annex 7) lists beta-adrenergic blockers among drugs that increase the hypotensive effect.',
 'Reduzir a velocidade inicial de perfusão e titular lentamente por PA invasiva; se houver bradicardia sintomática, reduzir ou suspender o betabloqueante e considerar alternativa vasodilatadora.',
 'Reduce the initial infusion rate and titrate slowly by invasive blood pressure; if symptomatic bradycardia occurs, reduce or stop the beta-blocker and consider an alternative vasodilator.',
 'PA contínua, frequência cardíaca, ECG, diurese, lactatos; na perfusão prolongada, toxicidade por cianeto/tiocianato.',
 'Continuous blood pressure, heart rate, ECG, urine output, lactate; during prolonged infusion, cyanide/thiocyanate toxicity.',
 'Hipotensão, bradicardia, síncope, oligúria, confusão.',
 'Hypotension, bradycardia, syncope, oliguria, confusion.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — tabela dos ARA II: "Bloqueadores adrenérgicos beta ... Nitroprussiato de sódio" entre os fármacos que aumentam o efeito hipotensor (l. 45529).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — ARA II table: "Beta-adrenergic blockers ... Sodium nitroprusside" among drugs that increase the hypotensive effect.',
 'published', now()),

-- 9. sulfato-zinco × ciprofloxacina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='sulfato-zinco'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='sulfato-zinco'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 'moderate',
 'O Zinco forma quelatos com a Ciprofloxacina no tubo digestivo, reduzindo significativamente a sua absorção e o risco de falha terapêutica da infecção.',
 'Zinc forms chelates with ciprofloxacin in the gut, significantly reducing its absorption and risking treatment failure.',
 'Catiões bi e trivalentes (Zn2+) quelam as quinolonas, impedindo a sua absorção: o Prontuário (Quinolonas, l. 2330-2332) refere que "a sua absorção é significativamente reduzida pelos fármacos com catiões bi e trivalentes como os antiácidos com alumínio, magnésio ou cálcio, suplementos com ferro ou zinco e o sucralfato".',
 'Bi and trivalent cations (Zn2+) chelate quinolones and prevent their absorption: the Prontuário (Quinolones) states that "their absorption is significantly reduced by drugs with bi and trivalent cations such as aluminium, magnesium or calcium antacids, iron or zinc supplements and sucralfate".',
 'Administrar a quinolona 2 h antes ou 6 h depois do suplemento de zinco; nunca em simultâneo; em terapêutica curta, reforçar a adesão ao intervalo.',
 'Give the quinolone 2 h before or 6 h after the zinc supplement; never simultaneously; for short courses, reinforce adherence to the interval.',
 'Resposta clínica da infecção; níveis plasmáticos de quinolona em doente crítico.',
 'Clinical response of the infection; quinolone plasma levels in the critically ill.',
 'Febre persistente, agravamento dos sinais de infecção, falta de resposta ao antibiótico.',
 'Persistent fever, worsening infection signs, lack of antibiotic response.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Quinolonas 1.1 — quelação por catiões incluindo zinco (l. 2330-2332); DailyMed — rótulo Ciprofloxacin Tablet [Bayer, RLD Cipro], Drug Interactions (catiões): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Quinolones 1.1 — chelation by cations including zinc; DailyMed — Ciprofloxacin Tablet label [Bayer, RLD Cipro], Drug Interactions (cations): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'published', now()),

-- 10. sulfato-ferroso × sulfato-zinco (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='sulfato-ferroso'), (SELECT id FROM public.drugs WHERE slug='sulfato-zinco')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='sulfato-ferroso'), (SELECT id FROM public.drugs WHERE slug='sulfato-zinco')),
 'moderate',
 'O Ferro e o Zinco competem pela mesma via de absorção intestinal e reduzem-se mutuamente, de modo que a suplementação simultânea pode não corrigir nenhuma das carências.',
 'Iron and zinc compete for the same intestinal absorption pathway and mutually reduce each other, so simultaneous supplementation may correct neither deficiency.',
 'Competição pelo transportador de catiões divalentes (DMT1) na mucosa intestinal: o Prontuário (Ferro 4.1.1, l. 17557-17562) indica que "Reduzem a absorção do ferro: os antiácidos, as penicilinas, as tetraciclinas, a trientina e o zinco" e que "os sais de ferro reduzem a absorção de ... zinco".',
 'Competition for the divalent cation transporter (DMT1) in the intestinal mucosa: the Prontuário (Iron 4.1.1) states that "Iron absorption is reduced by: antacids, penicillins, tetracyclines, trientine and zinc" and that "iron salts reduce the absorption of ... zinc".',
 'Separar as tomas em pelo menos 2 h e evitar a co-administração; reavaliar ferritina e zinco sérico após 8–12 semanas de esquema separado.',
 'Separate the doses by at least 2 h and avoid co-administration; reassess ferritin and serum zinc after 8–12 weeks on a separated schedule.',
 'Hemograma e ferritina, zinco sérico, adesão e tolerância gastrointestinal.',
 'Full blood count and ferritin, serum zinc, adherence and gastrointestinal tolerance.',
 'Anemia que não corrige, sintomas de défice de zinco (dermatite, diarreia, alterações do paladar).',
 'Non-correcting anaemia, zinc deficiency symptoms (dermatitis, diarrhoea, taste changes).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Ferro 4.1.1 — zinco entre os fármacos que reduzem a absorção do ferro e vice-versa (l. 17557-17562).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Iron 4.1.1 — zinc among drugs reducing iron absorption and vice versa.',
 'published', now()),

-- 11. deferoxamina × acido-ascorbico (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='deferoxamina'), (SELECT id FROM public.drugs WHERE slug='acido-ascorbico')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='deferoxamina'), (SELECT id FROM public.drugs WHERE slug='acido-ascorbico')),
 'critical',
 'Doses elevadas de Vitamina C (mais de 500 mg/dia) durante a terapêutica com Deferoxamina associaram-se a disfunção cardíaca em doentes com sobrecarga férrica crónica grave.',
 'High-dose vitamin C (more than 500 mg daily) during deferoxamine therapy has been associated with cardiac dysfunction in patients with severe chronic iron overload.',
 'A vitamina C aumenta a disponibilidade do ferro mobilizado e a formação de ferro livre, favorecendo lesão oxidativa do miocárdio já sobrecarregado; a disfunção cardíaca está descrita no rótulo da deferoxamina com terapêutica combinada em doses altas.',
 'Vitamin C increases the availability of mobilised iron and free iron formation, favouring oxidative injury to the already overloaded myocardium; cardiac dysfunction is described in the deferoxamine label with combined high-dose therapy.',
 'Se a carência de vitamina C estiver documentada, não exceder 500 mg/dia (na criança, 50 mg/dia) e iniciar apenas após estabilização com a deferoxamina; suspender de imediato se surgirem sinais de insuficiência cardíaca.',
 'If vitamin C deficiency is documented, do not exceed 500 mg daily (50 mg daily in children) and start only after stabilisation on deferoxamine; stop immediately if signs of heart failure appear.',
 'Ecocardiograma com avaliação da função ventricular, ferritina, função hepática, balanço hídrico e sintomas de insuficiência cardíaca.',
 'Echocardiogram with ventricular function assessment, ferritin, liver function, fluid balance and heart failure symptoms.',
 'Dispneia, edemas, ortopneia, taquicardia, ganho de peso rápido.',
 'Dyspnoea, oedema, orthopnoea, tachycardia, rapid weight gain.',
 'FDA — Desferal (deferoxamine mesylate) for injection, Drug Interactions (vitamina C: disfunção cardíaca em sobrecarga férrica grave com doses > 500 mg/dia): https://www.accessdata.fda.gov/drugsatfda_docs/label/2007/016267s044lbl.pdf; Novartis — DESFERAL prescrição; Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha DESFERROXAMINA (p. 520).',
 'FDA — Desferal (deferoxamine mesylate) for injection, Drug Interactions (vitamin C: cardiac dysfunction in severe iron overload with doses > 500 mg daily): https://www.accessdata.fda.gov/drugsatfda_docs/label/2007/016267s044lbl.pdf; Novartis — DESFERAL prescribing information; INFARMED Prontuário Terapêutico (11th ed., 2012), DEFEROXAMINE entry (p. 520).',
 'published', now()),

-- 12. acido-ascorbico × sulfato-ferroso (minor)
(LEAST((SELECT id FROM public.drugs WHERE slug='acido-ascorbico'), (SELECT id FROM public.drugs WHERE slug='sulfato-ferroso')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='acido-ascorbico'), (SELECT id FROM public.drugs WHERE slug='sulfato-ferroso')),
 'minor',
 'O Ácido ascórbico aumenta a absorção oral do Ferro; o efeito é frequentemente aproveitado de forma intencional, mas exige cautela em situações de sobrecarga férrica.',
 'Ascorbic acid increases oral iron absorption; the effect is often used intentionally but requires caution in iron overload states.',
 'Redução do ferro férrico a ferroso e manutenção da sua solubilidade no intestino delgado: o Prontuário (Ferro 4.1.1) indica que "O ácido ascórbico potencia a absorção (30 mg para 200 mg de ferro)".',
 'Reduction of ferric to ferrous iron and maintenance of its solubility in the small intestine: the Prontuário (Iron 4.1.1) states that "ascorbic acid potentiates absorption (30 mg per 200 mg of iron)".',
 'Aproveitar a potenciação na correção da anemia ferropénica; evitar doses farmacológicas de vitamina C em hemocromatose, talassemia ou outras sobrecargas de ferro.',
 'Use the potentiation to correct iron deficiency anaemia; avoid pharmacological vitamin C doses in haemochromatosis, thalassaemia or other iron overload states.',
 'Resposta hematológica (hemoglobina), ferritina; ferro e saturação da transferrina em doentes com risco de sobrecarga.',
 'Haematological response (haemoglobin), ferritin; iron and transferrin saturation in patients at risk of overload.',
 'Sinais de sobrecarga férrica (artralgias, hiperpigmentação, diabetes, cardiopatia).',
 'Signs of iron overload (arthralgia, hyperpigmentation, diabetes, cardiomyopathy).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Ferro 4.1.1 — "O ácido ascórbico potencia a absorção (30 mg para 200 mg de ferro)" (l. 17562).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Iron 4.1.1 — "Ascorbic acid potentiates absorption (30 mg per 200 mg of iron)".',
 'published', now()),

-- 13. acido-folico × fenitoina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='acido-folico'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='acido-folico'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 'moderate',
 'O Ácido fólico aumenta o metabolismo da Fenitoína, com redução das concentrações séricas do antiepiléptico e possível aumento da frequência das convulsões.',
 'Folic acid increases phenytoin metabolism, lowering serum concentrations of the antiepileptic and possibly increasing seizure frequency.',
 'Aumento do metabolismo da fenitoína pelo folato: o Prontuário (Ácido fólico 4.1.2, l. 17623-17626) refere que "O ácido fólico pode aumentar o metabolismo da fenitoína com redução das concentrações séricas do antiepilético e possível aumento da frequência de convulsões".',
 'Increased phenytoin metabolism by folate: the Prontuário (Folic acid 4.1.2) states that "folic acid may increase phenytoin metabolism with reduced serum concentrations of the antiepileptic and a possible increase in seizure frequency".',
 'Manter a suplementação quando indicada (por exemplo na gravidez) mas vigiar os níveis de fenitoína e o controlo das crises, com ajuste da dose do antiepiléptico; não alterar a posologia sem monitorização.',
 'Maintain supplementation when indicated (for example in pregnancy) but monitor phenytoin levels and seizure control, adjusting the antiepileptic dose; do not change dosing without monitoring.',
 'Níveis séricos de fenitoína, frequência das crises, hemograma e folato/B12.',
 'Serum phenytoin levels, seizure frequency, full blood count and folate/B12.',
 'Aumento da frequência ou da gravidade das crises, estado de mal epiléptico.',
 'Increased seizure frequency or severity, status epilepticus.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Ácido fólico 4.1.2 — metabolismo da fenitoína e risco convulsivo (l. 17623-17626).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Folic acid 4.1.2 — phenytoin metabolism and seizure risk.',
 'published', now()),

-- 14. mebendazol × cimetidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 'moderate',
 'A Cimetidina inibe o metabolismo do Mebendazol e potencia os seus efeitos farmacológicos; o significado clínico é sobretudo relevante em terapêuticas prolongadas.',
 'Cimetidine inhibits mebendazole metabolism and potentiates its pharmacological effects; the clinical relevance is mainly in prolonged therapy.',
 'Inibição do metabolismo hepático do mebendazol: o Prontuário (Mebendazol 1.4.1, l. 4541-4545) refere que "A cimetidina inibe o metabolismo do mebendazol, potenciando os seus efeitos farmacológicos (estas interacções só são clinicamente significativas quando em terapêuticas prolongadas)".',
 'Inhibition of hepatic mebendazole metabolism: the Prontuário (Mebendazole 1.4.1) states that "cimetidine inhibits mebendazole metabolism, potentiating its pharmacological effects (these interactions are only clinically significant in prolonged therapy)".',
 'Nas doses únicas (enterobíase, ascaridíase) o risco é mínimo; em terapêuticas prolongadas (hidatidose) preferir outro antiulceroso e vigiar os efeitos adversos do mebendazol.',
 'With single doses (enterobiasis, ascariasis) the risk is minimal; in prolonged therapy (hydatid disease) prefer another antiulcer agent and monitor mebendazole adverse effects.',
 'Enzimas hepáticas e hemograma nas doses altas ou prolongadas.',
 'Liver enzymes and full blood count at high or prolonged doses.',
 'Náuseas persistentes, icterícia, febre, citopenias.',
 'Persistent nausea, jaundice, fever, cytopenias.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Mebendazol 1.4.1 — cimetidina inibe o metabolismo do mebendazol (l. 4541-4545).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Mebendazole 1.4.1 — cimetidine inhibits mebendazole metabolism.',
 'published', now()),

-- 15. mebendazol × carbamazepina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'moderate',
 'A Carbamazepina reduz as concentrações plasmáticas do Mebendazol por indução enzimática, com risco de falha terapêutica nas parasitoses que exigem tratamento prolongado.',
 'Carbamazepine lowers mebendazole plasma concentrations through enzyme induction, risking treatment failure in parasitic infections requiring prolonged therapy.',
 'Indução enzimática do metabolismo do mebendazol: o Prontuário (Mebendazol 1.4.1) refere que "A co-administração de carbamazepina e fenitoína reduz as concentrações plasmáticas do mebendazol (indução enzimática)".',
 'Enzyme induction of mebendazole metabolism: the Prontuário (Mebendazole 1.4.1) states that "co-administration of carbamazepine and phenytoin reduces mebendazole plasma concentrations (enzyme induction)".',
 'Em terapêutica prolongada (hidatidose), discutir com especialista a necessidade de dose mais alta ou de alternativa, mantendo o anticonvulsivante; não suspender o antiepiléptico por causa desta interação.',
 'In prolonged therapy (hydatid disease), discuss with a specialist whether a higher dose or an alternative is needed while maintaining the anticonvulsant; do not stop the antiepileptic because of this interaction.',
 'Resposta clínica e imagiológica da parasitose, enzimas hepáticas.',
 'Clinical and imaging response of the parasitic disease, liver enzymes.',
 'Persistência ou progressão da parasitose, novas lesões em imagiologia.',
 'Persistence or progression of the parasitic infection, new lesions on imaging.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Mebendazol 1.4.1 — carbamazepina e fenitoína reduzem as concentrações do mebendazol (l. 4541-4545).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Mebendazole 1.4.1 — carbamazepine and phenytoin reduce mebendazole concentrations.',
 'published', now()),

-- 16. mebendazol × fenitoina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='mebendazol'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 'moderate',
 'A Fenitoína reduz as concentrações plasmáticas do Mebendazol por indução enzimática, com risco de falha terapêutica nas parasitoses que exigem tratamento prolongado.',
 'Phenytoin lowers mebendazole plasma concentrations through enzyme induction, risking treatment failure in parasitic infections requiring prolonged therapy.',
 'Indução enzimática do metabolismo do mebendazol: o Prontuário (Mebendazol 1.4.1) agrupa carbamazepina e fenitoína como indutores que reduzem as concentrações do mebendazol; a fenitoína é ainda indutora clássica do CYP3A4.',
 'Enzyme induction of mebendazole metabolism: the Prontuário (Mebendazole 1.4.1) groups carbamazepine and phenytoin as inducers that lower mebendazole concentrations; phenytoin is also a classic CYP3A4 inducer.',
 'Em terapêutica prolongada, discutir com especialista o ajuste de dose do mebendazol ou uma alternativa, mantendo o antiepiléptico; vigiar a resposta clínica.',
 'In prolonged therapy, discuss with a specialist adjusting the mebendazole dose or using an alternative while maintaining the antiepileptic; monitor the clinical response.',
 'Resposta clínica da parasitose, enzimas hepáticas; níveis de fenitoína se a dose for alterada.',
 'Clinical response of the parasitic infection, liver enzymes; phenytoin levels if dosing changes.',
 'Persistência da parasitose, crises epilépticas (se a fenitoína for mal ajustada).',
 'Persistence of the parasitic infection, seizures (if phenytoin is poorly adjusted).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Mebendazol 1.4.1 — carbamazepina e fenitoína reduzem as concentrações do mebendazol (l. 4541-4545).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Mebendazole 1.4.1 — carbamazepine and phenytoin reduce mebendazole concentrations.',
 'published', now()),

-- 17. iodopovidona × carbimazol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='iodopovidona'), (SELECT id FROM public.drugs WHERE slug='carbimazol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='iodopovidona'), (SELECT id FROM public.drugs WHERE slug='carbimazol')),
 'moderate',
 'A Iodopovidona aplicada em feridas extensas ou mucosas é absorvida em quantidade suficiente para afectar a tiróide, podendo desequilibrar a terapêutica antitiroideia e interferir com as provas de função tiroideia.',
 'Povidone-iodine applied to extensive wounds or mucosa is absorbed in sufficient amounts to affect the thyroid, potentially destabilising antithyroid therapy and interfering with thyroid function tests.',
 'Carga de iodo absorvida sistemicamente que altera a resposta da tiróide: o Prontuário (Iodopovidona 13.1.1, l. 32182-32188) refere que a iodopovidona "pode ser absorvido em quantidade suficiente para afectar a tiróide", exigindo cuidado "em doentes com perturbações tiroideias", e que "pode interferir no resultado dos testes de função tiroideia".',
 'Systemically absorbed iodine load that alters thyroid response: the Prontuário (Povidone-iodine 13.1.1) states it "may be absorbed in sufficient quantity to affect the thyroid", requiring caution "in patients with thyroid disorders", and that it "may interfere with the results of thyroid function tests".',
 'Evitar a aplicação prolongada em áreas extensas ou mucosas em doentes medicados com antitiroideus; preferir clorexidina; interpretar TSH e T4 livre com cautela nas semanas seguintes à exposição.',
 'Avoid prolonged application to extensive or mucosal areas in patients on antithyroid drugs; prefer chlorhexidine; interpret TSH and free T4 with caution in the weeks after exposure.',
 'TSH, T4 livre, T3 e clínica de hipo ou hipertiroidismo.',
 'TSH, free T4, T3 and clinical signs of hypo- or hyperthyroidism.',
 'Bócio de instalação recente, taquicardia, agravamento do hipertiroidismo, letargia (hipotiroidismo).',
 'Recently developing goitre, tachycardia, worsening hyperthyroidism, lethargy (hypothyroidism).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Iodopovidona 13.1.1 — absorção sistémica com efeito na tiróide e interferência nas provas tiroideias (l. 32182-32188).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Povidone-iodine 13.1.1 — systemic absorption affecting the thyroid and interfering with thyroid tests.',
 'published', now()),

-- 18. iodopovidona × propiltiouracilo (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='iodopovidona'), (SELECT id FROM public.drugs WHERE slug='propiltiouracilo')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='iodopovidona'), (SELECT id FROM public.drugs WHERE slug='propiltiouracilo')),
 'moderate',
 'A Iodopovidona fornece uma carga de iodo com absorção sistémica que pode afectar a tiróide e desequilibrar a terapêutica com Propiltiouracilo, além de interferir nas provas de função tiroideia.',
 'Povidone-iodine provides a systemically absorbed iodine load that may affect the thyroid and destabilise propylthiouracil therapy, besides interfering with thyroid function tests.',
 'Tal como com o carbimazol, o iodo absorvido altera a resposta tiroideia e pode contrariar ou confundir o efeito do antitiroideu; o Prontuário (Iodopovidona 13.1.1) documenta esta absorção e a interferência nas provas tiroideias.',
 'As with carbimazole, absorbed iodine alters thyroid response and may counteract or confuse the antithyroid effect; the Prontuário (Povidone-iodine 13.1.1) documents this absorption and the interference with thyroid tests.',
 'Evitar a aplicação em áreas extensas ou mucosas durante a terapêutica antitiroideia; preferir clorexidina; reavaliar TSH e T4 livre após a exposição.',
 'Avoid application to extensive or mucosal areas during antithyroid therapy; prefer chlorhexidine; reassess TSH and free T4 after exposure.',
 'TSH, T4 livre, T3, sinais de hipo ou hipertiroidismo.',
 'TSH, free T4, T3, signs of hypo- or hyperthyroidism.',
 'Agravamento do hipertiroidismo ou instalação de hipotiroidismo, bócio.',
 'Worsening hyperthyroidism or developing hypothyroidism, goitre.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Iodopovidona 13.1.1 — absorção sistémica com efeito na tiróide (l. 32182-32188) e 8.3 Hormonas da tiróide e antitiroideus (ficha Propiltiouracilo).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Povidone-iodine 13.1.1 — systemic absorption affecting the thyroid, and 8.3 Thyroid hormones and antithyroid drugs (Propylthiouracil entry).',
 'published', now()),

-- 19. noreisterona × rifampicina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 'critical',
 'A Rifampicina induz fortemente o metabolismo da Noretisterona, com risco de falha contracetiva na contraceção só com progestagénio.',
 'Rifampicin strongly induces norethisterone metabolism, risking contraceptive failure with progestogen-only contraception.',
 'Indução enzimática (CYP3A4, com reforço da glucuronidação) que acelera a eliminação do progestagénio: o Prontuário (Anexo 7, Estrogénios/contraceptivos, l. 46301) regista "Estrogénios (com possível redução do risco contraceptivo)" com indutores, e a 267 já criou os pares equivalentes para o contracetivo combinado (levonorgestrel-etinilestradiol × rifampicina/carbamazepina/fenitoína).',
 'Enzyme induction (CYP3A4 plus enhanced glucuronidation) accelerating progestogen elimination: the Prontuário (Annex 7, Oestrogens/contraceptives) records "Oestrogens (with possible reduction of contraceptive cover)" with inducers, and migration 267 already created the equivalent pairs for the combined pill (levonorgestrel-etinilestradiol × rifampicin/carbamazepine/phenytoin).',
 'Adicionar método de barreira durante todo o tratamento e nas 4 semanas seguintes; em terapêutica antituberculosa prolongada, discutir contraceção não hormonal ou método de longa duração.',
 'Add a barrier method throughout treatment and for the following 4 weeks; in prolonged antituberculous therapy, discuss non-hormonal or long-acting contraception.',
 'Prova de gravidez se falha suspeitada, hemorragia de privação, spotting intermenstrual.',
 'Pregnancy test if failure is suspected, withdrawal bleeding, intermenstrual spotting.',
 'Amenorreia com gravidez indesejada, spotting persistente, hemorragia de privação ausente.',
 'Amenorrhoea with unintended pregnancy, persistent spotting, absent withdrawal bleeding.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Estrogénios/contraceptivos com indutores enzimáticos (l. 46301) e ficha Rifampicina; 267 (levonorgestrel-etinilestradiol × rifampicina, critical) para o contracetivo combinado.',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Oestrogens/contraceptives with enzyme inducers and Rifampicin entry; migration 267 (levonorgestrel-etinilestradiol × rifampicin, critical) for the combined pill.',
 'published', now()),

-- 20. noreisterona × carbamazepina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'moderate',
 'A Carbamazepina acelera o metabolismo da Noretisterona, podendo reduzir a eficácia contracetiva da contraceção só com progestagénio.',
 'Carbamazepine accelerates norethisterone metabolism, potentially reducing the contraceptive efficacy of progestogen-only contraception.',
 'Indução enzimática do metabolismo do progestagénio: o Prontuário (ficha Carbamazepina 2.6, l. 5996-5998) refere "redução do efeito dos anticoagulantes e dos contraceptivos orais"; a 267 já criou o par homólogo com o contracetivo combinado (moderate).',
 'Enzyme induction of progestogen metabolism: the Prontuário (Carbamazepine entry 2.6) states "reduced effect of anticoagulants and oral contraceptives"; migration 267 already created the homologous pair with the combined pill (moderate).',
 'Reforçar com método de barreira durante o tratamento e nas 4 semanas após a suspensão do indutor; reavaliar a necessidade de contraceção hormonal na epilepsia.',
 'Reinforce with a barrier method during treatment and for 4 weeks after stopping the inducer; reassess the need for hormonal contraception in epilepsy.',
 'Spotting intermenstrual, hemorragia de privação, prova de gravidez se falha suspeitada; níveis do anticonvulsivante se a dose mudar.',
 'Intermenstrual spotting, withdrawal bleeding, pregnancy test if failure is suspected; anticonvulsant levels if dosing changes.',
 'Hemorragia de privação ausente, spotting persistente, gravidez indesejada.',
 'Absent withdrawal bleeding, persistent spotting, unintended pregnancy.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Carbamazepina 2.6 — redução do efeito dos contraceptivos orais (l. 5996-5998); Anexo 7 — Estrogénios/contraceptivos.',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Carbamazepine entry 2.6 — reduced effect of oral contraceptives; Annex 7 — Oestrogens/contraceptives.',
 'published', now()),

-- 21. noreisterona × fenitoina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='noreisterona'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 'moderate',
 'A Fenitoína acelera o metabolismo da Noretisterona, podendo reduzir a eficácia contracetiva da contraceção só com progestagénio.',
 'Phenytoin accelerates norethisterone metabolism, potentially reducing the contraceptive efficacy of progestogen-only contraception.',
 'Indução enzimática: o Prontuário (ficha Fenitoína 2.6, l. 6062) refere que a fenitoína "aumenta o metabolismo dos corticosteróides, dos contraceptivos orais e da nisoldipina"; a 267 criou o par homólogo com o contracetivo combinado (moderate).',
 'Enzyme induction: the Prontuário (Phenytoin entry 2.6) states that phenytoin "increases the metabolism of corticosteroids, oral contraceptives and nisoldipine"; migration 267 created the homologous pair with the combined pill (moderate).',
 'Adicionar método de barreira durante o tratamento e nas 4 semanas seguintes; reavaliar a contraceção hormonal no contexto da epilepsia.',
 'Add a barrier method during treatment and for the following 4 weeks; reassess hormonal contraception in the epilepsy setting.',
 'Spotting intermenstrual, hemorragia de privação, prova de gravidez se falha suspeitada; níveis de fenitoína se a dose mudar.',
 'Intermenstrual spotting, withdrawal bleeding, pregnancy test if failure is suspected; phenytoin levels if dosing changes.',
 'Hemorragia de privação ausente, spotting persistente, gravidez indesejada.',
 'Absent withdrawal bleeding, persistent spotting, unintended pregnancy.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Fenitoína 2.6 — aumento do metabolismo dos contraceptivos orais (l. 6062); Anexo 7 — Estrogénios/contraceptivos (l. 46301).',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Phenytoin entry 2.6 — increased metabolism of oral contraceptives; Annex 7 — Oestrogens/contraceptives.',
 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Pares inseridos: 21 (itens 1–21; itens 9/10, 11/12 e 17/18 partilham fármacos
-- e são contados uma vez cada na lista de tuples).

-- =====================================================================
-- PARTE B — fecho da auditoria de justificações (notas, sem tuples)
-- =====================================================================
-- As 5 justificações que estavam em falta nos cabeçalhos/rodapés das
-- migrações de origem dos 28 LNME sem pares FF:
--
-- * pirantel (L1) — NÃO cria par: o único antagonismo documentado no
--   Prontuário é com a piperazina (1.4.1, l. 4563: "O pirantel e a
--   piperazina são antagonistas não sendo, por isso, recomendada a sua
--   co-administração") e a piperazina não existe na base. Par reservado
--   para quando o fármaco for adicionado; o rótulo do pirantel não
--   documenta outras interacções clinicamente significativas.
--
-- * amoxicilina-acido-clavulanico (L2) — NÃO cria par nesta migração: os
--   pares históricos do slug pré-fusão (amoxicilina × alopurinol, 044/056)
--   não estão hoje ligados a este slug (verificado 2026-10-02: 0 pares
--   publicados). Candidatos documentáveis (varfarina, metotrexato) exigem
--   validação de rótulo mono-ingrediente do produto combinado (regra 13.1)
--   — fica para revisão futura, com nota de que não é omissão silenciosa.
--
-- * bupivacaina (L2) — NÃO cria par: anestésico local do grupo amida, de
--   uso regional; a toxicidade sistémica combinada com outros anestésicos
--   locais é um conceito de dose máxima (rótulo), não uma interacção
--   adversa entre fármacos em uso normal — mesmo critério já registado na
--   271 para tetracaína × lidocaína.
--
-- * progesterona (L3) — NÃO cria par: a evidência de classe disponível
--   (Prontuário, ficha Fenitoína 2.6 e ficha Carbamazepina 2.6, que referem
--   "contraceptivos orais"; Anexo 7 Estrogénios, l. 46301) aplica-se aos
--   progestagénios contracetivos — cobertos aqui pelos pares da
--   noretisterona (itens 19–21) e da 267 para o contracetivo combinado. A
--   progesterona micronizada (indicação obstétrica/ginecológica) não tem,
--   no Prontuário, interacção farmacológica registada; exige rótulo
--   mono-ingrediente validado — revisão futura.
--
-- * ciproterona (L4) — NÃO cria par: antiandrogénio esteróide sem rótulo
--   FDA humano (nota de inclusão já em 260/264/268); a interacção
--   clinicamente relevante (redução da eficácia contracetiva) é interna à
--   associação co-formulada com etinilestradiol (G03HB01), não um par entre
--   dois fármacos prescritos separadamente na base.
--
-- Distribuição dos 28 zeros por estado da justificação (verificação exaustiva
-- com `_temp/_verificar_justificacoes.mjs`: nome do fármaco procurado em linhas
-- de comentário de todas as migrações, janela de ±3 linhas, marcadores estritos
-- de ausência de pares; 289 excluída do varrimento):
--
--   A — Justificação explícita numa migração de PARES FF (16):
--      · 259 — clotrimazol (l. 19), retinol e tiamina (l. 64-66 e 568)
--      · 267 — lidocaina/clorexidina/tetracaina (l. 714), iodopovidona (l. 714),
--              sulfato-zinco e acido-ascorbico (l. 116 e 710-712),
--              vitamina-d (l. 711), flumazenil (l. 92 e 703), clomifeno (l. 114
--              e 710), propiltiouracilo (l. 52 — ver correcção abaixo),
--              piridoxina (l. 116)
--      · 271 — tetracaina × lidocaina (l. 310), vitamina-d × tiazidas (l. 313),
--              espectinomicina (l. 315)
--      · 272 — espectinomicina (l. 287), permanganato-potassio (l. 289)
--
--   B — Justificação registada apenas FORA das migrações de pares FF — a série
--      LNME nunca a herdou (3):
--      · mebendazol   — 058, l. 14: "Mebendazol OMITIDO: o rótulo FDA (incl.
--                       EMVERM) não documenta interações com os [fármacos da base]".
--      · pirantel     — 058, l. 18: "Flubendazol, piperazina e pirantel
--                       OMITIDOS (interações com fármacos fora da base)".
--      · deferoxamina — 168, l. 41: interação documentada com a procloroperazina,
--                       que "não existe na BD".
--
--   C — SEM QUALQUER JUSTIFICAÇÃO REGISTADA — omissões silenciosas (9):
--      amoxicilina-acido-clavulanico, acido-folico, bupivacaina, noreisterona,
--      nitroprussiato, dobutamina, progesterona, carbimazol, ciproterona.
--      Resolução nesta migração: 4 recebem justificação escrita (PARTE B) e 5
--      ficam cobertas com pares reais (acido-folico × fenitoina; noreisterona ×
--      rifampicina/carbamazepina/fenitoina; nitroprussiato × enalapril/
--      metoprolol; dobutamina × metoprolol/propranolol; carbimazol ×
--      warfarina/iodopovidona).
--
-- EXCLUSÕES ANTERIORES QUE ESTA MIGRAÇÃO REVÊ (a fonte disponível é mais forte
-- do que a nota original — fica registado para não se repetir o critério):
--   * mebendazol    — 058 omitiu por o rótulo FDA não documentar interações;
--                     o Prontuário 1.4.1 documenta cimetidina, carbamazepina e
--                     fenitoína (itens 14-16).
--   * sulfato-zinco — 267 omitiu por "documentação insuficiente"; o Prontuário
--                     (Quinolonas, l. 2330-2332) documenta explicitamente a
--                     quelação por zinco (item 9).
--   * iodopovidona  — 267 deu-a como sem "interacções sistémicas relevantes";
--                     a ficha do próprio Prontuário (13.1.1) descreve absorção
--                     sistémica com efeito na tiróide (itens 17-18).
--   * acido-ascorbico — 267 omitiu por falta de rótulo mono-ingrediente FDA; o
--                     Prontuário (Ferro 4.1.1) documenta a potenciação da
--                     absorção do ferro (item 12).
--   * flumazenil    — 267 excluiu-o como "antídoto protocolar, não interação
--                     adversa"; o rótulo documenta convulsões de abstinência e a
--                     exclusão em intoxicação mista (itens 1-2).
--   * propiltiouracilo — a justificação da 267 assentava numa citação mal
--                     atribuída (pertence à levotiroxina) — ver CORRECÇÃO DE
--                     AUDITORIA no cabeçalho.
--
-- Verificações efectuadas nesta sessão (2026-10-02):
--   _temp/_zero_pairs_artefacto.mjs — confirma que os 28 slugs estão activos
--     e publicados (não é artefacto do merge 283) e que os pares são 0.
--   _temp/_check_parceiros289.mjs — confirma que todos os slugs parceiros
--     usados na PARTE A existem e que nenhum dos 21 pares já existia.
--   _temp/_orfaos283.mjs + _temp/_cotrim_orfao.mjs — verificam os órfãos da
--     PARTE C (todos duplicados de pares já publicados nos slugs activos).
--
-- Nota adicional para revisão futura (não resolvida aqui):
--   espironolactona × losartano — par órfão (losartano arquivado) com um
--   par homólogo em losartana (critical) no slug activo; a escolha do slug
--   canónico do losartan exige decisão de dados, pelo que não se arquiva
--   nesta migração.

-- =====================================================================
-- PARTE C — limpeza de pares órfãos duplicados (merge 283)
-- =====================================================================
-- O merge 283 (fusão de duplicados underscore) arquivou os fármacos mas
-- deixou 4 pares a apontar para os registos arquivados, duplicando pares que
-- existem nos slugs activos (verificado com _temp/_orfaos283.mjs e
-- _temp/_cotrim_orfao.mjs). São arquivados aqui (nunca eliminados) e apenas
-- quando o par equivalente existe de facto no slug activo.
-- =====================================================================

UPDATE public.drug_interactions i
SET is_archived = true
FROM (VALUES
  ('cloreto_potassio', 'cloreto-potassio', 'enalapril'),
  ('sulfato_magnesio', 'sulfato-magnesio', 'digoxina'),
  ('sulfametoxazol-trimetoprima', 'cotrimoxazol', 'warfarina'),
  ('sulfametoxazol-trimetoprima', 'cotrimoxazol', 'metformina')
) AS v(slug_arquivado, slug_activo, slug_parceiro),
  public.drugs darq,
  public.drugs dact,
  public.drugs dpar
WHERE darq.slug = v.slug_arquivado
  AND darq.is_archived = true
  AND dact.slug = v.slug_activo
  AND dact.is_archived = false
  AND dpar.slug = v.slug_parceiro
  AND i.drug_a_id = LEAST(darq.id, dpar.id)
  AND i.drug_b_id = GREATEST(darq.id, dpar.id)
  AND i.is_archived = false
  AND EXISTS (
    SELECT 1 FROM public.drug_interactions j
    WHERE j.is_archived = false
      AND j.status = 'published'
      AND j.drug_a_id = LEAST(dact.id, dpar.id)
      AND j.drug_b_id = GREATEST(dact.id, dpar.id)
  );

-- Pares órfãos arquivados: 4 (só se o par equivalente estiver publicado no
-- slug activo — cloreto-potassio × enalapril, sulfato-magnesio × digoxina,
-- cotrimoxazol × warfarina, cotrimoxazol × metformina).
