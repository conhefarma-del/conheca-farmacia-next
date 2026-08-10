-- =====================================================================
-- 097 — Explicações fármaco-fármaco dos pares moderados da WARFARINA (1/2)
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 26 pares moderados da warfarina com anti-infeciosos,
-- antimaláricos e antirretrovíricos que os tinham vazios — primeiro lote
-- dos 319 pares moderados sem explicação, começando pelo fármaco com mais
-- pares (warfarina, 44).
-- Padrão da 089: UPDATE com LEAST/GREATEST canónico (regra de ouro do
-- documento de fluxo) + updated_at = now(). Conteúdo autoral, ancorado nos
-- rótulos aprovados citados no campo source_* já existente de cada par
-- (DailyMed/FDA, EMA/EMC-UK, WHO). Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/26 — AMIODARONA + WARFARINA (inibição do CYP2C9)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A amiodarona inibe o CYP2C9 (e o CYP2C19/CYP3A4) e pode mais do que duplicar o INR. Reduzir a dose de warfarina em 30–50% ao iniciar, monitorizar o INR semanalmente e ajustar após suspender a amiodarona (efeito prolongado, semivida de semanas).',
  summary_pro_en = 'Amiodarone inhibits CYP2C9 (and CYP2C19/CYP3A4) and can more than double the INR. Reduce warfarin by 30–50% when starting, monitor INR weekly, and re-adjust after amiodarone is stopped (prolonged effect, half-life of weeks).',
  explanation_pt = 'A amiodarona é um inibidor potente do CYP2C9, a isoenzima que metaboliza o S-warfarin (o enantiómero mais ativo), além de inibir o CYP2C19 e o CYP3A4. O resultado é a subida acentuada do INR, que pode ocorrer logo nos primeiros dias mas continua a evoluir durante semanas porque a amiodarona tem uma semivida muito longa (20–100 dias) e acumula nos tecidos. O rótulo aprovado recomenda reduzir a dose de warfarina em 30–50% quando se inicia a amiodarona e monitorizar o INR de perto; o efeito persiste durante semanas ou meses após suspender a amiodarona, pelo que é preciso reajustar a warfarina nessa fase. Esta associação é frequente em doentes com fibrilhação auricular e exige disciplina no controlo do INR e vigilância de hemorragia.',
  explanation_en = 'Amiodarone is a potent inhibitor of CYP2C9, the isoenzyme that metabolises S-warfarin (the more active enantiomer), and also inhibits CYP2C19 and CYP3A4. The result is a marked rise in the INR, which can start within the first days but continues to evolve for weeks because amiodarone has a very long half-life (20–100 days) and accumulates in tissues. The approved label recommends reducing the warfarin dose by 30–50% when amiodarone is started and monitoring the INR closely; the effect persists for weeks to months after amiodarone is stopped, so warfarin must be re-adjusted during that phase. This combination is common in atrial fibrillation patients and demands disciplined INR control and vigilance for bleeding.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 2/26 — AMOXICILINA-CLAVULANATO + WARFARINA (flora intestinal e vitamina K)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Antibióticos de largo espectro podem potenciar a warfarina por redução da flora intestinal produtora de vitamina K e, alguns, por inibição enzimática. Monitorizar o INR durante e após o antibiótico e vigiar hemorragia.',
  summary_pro_en = 'Broad-spectrum antibiotics can potentiate warfarin by reducing the gut flora that produces vitamin K and, for some, by enzyme inhibition. Monitor the INR during and after the antibiotic and watch for bleeding.',
  explanation_pt = 'A amoxicilina-clavulanato elimina grande parte da flora bacteriana intestinal que sintetiza vitamina K, diminuindo a disponibilidade do cofator necessário à carboxilação dos fatores de coagulação dependentes de vitamina K (II, VII, IX, X). Como a warfarina atua exatamente por esse mecanismo (inibição da vitamina K epóxido redutase), a redução adicional da vitamina K endógena potencia o efeito anticoagulante e o INR sobe. O efeito é mais evidente em doentes com ingestão dietética marginal de vitamina K e pode aparecer dias após iniciar o antibiótico. A monitorização do INR durante e após o ciclo antibiótico é essencial; em doentes com INR já estável, considerar controlo mais frequente e alertar para sinais de hemorragia (hemorragia gengival, equimoses, melenas).',
  explanation_en = 'Amoxicillin-clavulanate eliminates much of the gut bacterial flora that synthesises vitamin K, reducing the availability of the cofactor needed to carboxylate the vitamin K-dependent coagulation factors (II, VII, IX, X). Since warfarin acts precisely through that pathway (inhibition of vitamin K epoxide reductase), the additional reduction of endogenous vitamin K potentiates the anticoagulant effect and the INR rises. The effect is more evident in patients with marginal dietary vitamin K intake and can appear days after starting the antibiotic. INR monitoring during and after the antibiotic course is essential; in patients with a previously stable INR, consider more frequent checks and alert for bleeding signs (gingival bleeding, bruising, melaena).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina-clavulanato'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amoxicilina-clavulanato'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 3/26 — AMPICILINA + WARFARINA (flora intestinal e vitamina K)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A ampicilina pode potenciar a warfarina por redução da flora intestinal produtora de vitamina K. Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Ampicillin can potentiate warfarin by reducing the gut flora that produces vitamin K. Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A ampicilina, como outros antibióticos de largo espectro, reduz a flora bacteriana intestinal que sintetiza vitamina K. Dado que a warfarina inibe a vitamina K epóxido redutase, a menor disponibilidade de vitamina K endógena traduz-se em aumento do INR e do risco hemorrágico. A interação é mais relevante em doentes com nutrição marginal, doença hepática ou antibioterapia prolongada. Recomenda-se monitorizar o INR durante o tratamento e após a sua conclusão e vigiar sinais de hemorragia; ajustar a dose de warfarina conforme o INR.',
  explanation_en = 'Ampicillin, like other broad-spectrum antibiotics, reduces the gut bacterial flora that synthesises vitamin K. Since warfarin inhibits vitamin K epoxide reductase, the lower availability of endogenous vitamin K translates into a higher INR and bleeding risk. The interaction is more relevant in patients with marginal nutrition, liver disease or prolonged antibiotic therapy. INR should be monitored during treatment and after its completion, with vigilance for bleeding signs; adjust the warfarin dose according to the INR.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ampicilina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 4/26 — ATAZANAVIR + WARFARINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O atazanavir inibe o CYP3A4 e o UGT1A1, podendo aumentar os níveis de warfarina e o INR. Monitorizar o INR ao iniciar, ajustar e suspender o atazanavir.',
  summary_pro_en = 'Atazanavir inhibits CYP3A4 and UGT1A1 and can raise warfarin levels and the INR. Monitor the INR when starting, adjusting and stopping atazanavir.',
  explanation_pt = 'O atazanavir é um inibidor do CYP3A4 (e do UGT1A1), enzimas envolvidas no metabolismo dos dois enantiómeros da warfarina. A inibição pode aumentar a exposição à warfarina e elevar o INR, com risco hemorrágico acrescido. Como o atazanavir é usado em associação com ritonavir ou cobicistate (também inibidores), o efeito pode ser ainda mais pronunciado. Recomenda-se monitorizar o INR com frequência no início, durante e após a suspensão do antirretrovírico, e ajustar a dose de warfarina em conformidade.',
  explanation_en = 'Atazanavir inhibits CYP3A4 (and UGT1A1), enzymes involved in the metabolism of both warfarin enantiomers. The inhibition can increase warfarin exposure and raise the INR, with increased bleeding risk. Since atazanavir is used with ritonavir or cobicistat (also inhibitors), the effect can be even more pronounced. The INR should be monitored frequently at initiation, during and after antiretroviral discontinuation, and the warfarin dose adjusted accordingly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atazanavir'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atazanavir'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 5/26 — ATOVAQUONA-PROGUANIL + WARFARINA (deslocação proteica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A atovaquona liga-se extensamente às proteínas plasmáticas e pode deslocar a warfarina, aumentando transitoriamente o INR. Monitorizar o INR ao iniciar e suspender a profilaxia antimalárica.',
  summary_pro_en = 'Atovaquone is extensively protein-bound and can displace warfarin, transiently raising the INR. Monitor the INR when starting and stopping antimalarial prophylaxis.',
  explanation_pt = 'A atovaquona tem uma ligação muito elevada às proteínas plasmáticas (superior a 99%) e, ao competir pelos mesmos locais de ligação, pode deslocar a warfarina e aumentar a fração livre ativa, com elevação transitória do INR. A proguanil não parece contribuir de forma significativa, mas a associação é usada em conjunto. O efeito é habitualmente modesto e transitório, mas em doentes com INR limítrofe pode desencadear hemorragia. Recomenda-se monitorizar o INR no início e no fim da profilaxia e ajustar a dose se necessário.',
  explanation_en = 'Atovaquone is very highly protein-bound (over 99%) and, by competing for the same binding sites, can displace warfarin and increase the active free fraction, with a transient INR rise. Proguanil does not appear to contribute significantly, but the two are used together. The effect is usually modest and transient, but in patients with a borderline INR it can trigger bleeding. The INR should be monitored at the start and end of prophylaxis and the dose adjusted if necessary.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atovaquona-proguanil'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atovaquona-proguanil'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 6/26 — AZITROMICINA + WARFARINA (flora intestinal e inibição ligeira)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Macrólidos podem potenciar a warfarina (flora intestinal + inibição enzimática). O efeito da azitromicina é menos consistente que o da claritromicina/eritromicina, mas exige monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Macrolides can potentiate warfarin (gut flora + enzyme inhibition). Azithromycin''s effect is less consistent than clarithromycin/erythromycin, but INR monitoring during and after the antibiotic is still required.',
  explanation_pt = 'A azitromicina, como os restantes macrólidos, pode aumentar o efeito da warfarina por dois mecanismos: redução da flora intestinal produtora de vitamina K e inibição (mais ligeira que a claritromicina e a eritromicina) do CYP3A4, que participa no metabolismo da warfarina. Os relatos clínicos com azitromicina são menos consistentes, mas existem casos de INR elevado e hemorragia. O rótulo da warfarina lista os macrólidos como fármacos que podem aumentar o efeito anticoagulante. Recomenda-se monitorizar o INR durante o ciclo antibiótico e nas semanas seguintes, ajustando a dose se necessário.',
  explanation_en = 'Azithromycin, like other macrolides, can increase the effect of warfarin through two mechanisms: reduction of the gut flora that produces vitamin K and inhibition (milder than clarithromycin and erythromycin) of CYP3A4, which participates in warfarin metabolism. Clinical reports with azithromycin are less consistent, but cases of elevated INR and bleeding exist. The warfarin label lists macrolides as drugs that can increase the anticoagulant effect. The INR should be monitored during the antibiotic course and in the following weeks, with dose adjustment if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'azitromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'azitromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 7/26 — CEFTRIAXONA + WARFARINA (flora intestinal e vitamina K)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefalosporinas podem potenciar a warfarina por redução da flora intestinal produtora de vitamina K. Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Cephalosporins can potentiate warfarin by reducing the gut flora that produces vitamin K. Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A ceftriaxona é uma cefalosporina de largo espectro que reduz a flora intestinal produtora de vitamina K. Sendo a warfarina um antagonista da vitamina K, a menor disponibilidade endógena do cofator aumenta o INR e o risco hemorrágico. O efeito é mais relevante em doentes desnutridos, idosos, com doença hepática ou com antibioterapia prolongada. Monitorizar o INR durante e após o tratamento e ajustar a dose de warfarina; vigiar sinais de hemorragia.',
  explanation_en = 'Ceftriaxone is a broad-spectrum cephalosporin that reduces the gut flora producing vitamin K. Since warfarin is a vitamin K antagonist, the lower endogenous availability of the cofactor raises the INR and the bleeding risk. The effect is more relevant in malnourished, elderly, liver-disease or prolonged-antibiotic patients. Monitor the INR during and after treatment and adjust the warfarin dose; watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ceftriaxona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ceftriaxona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 8/26 — CETOCONAZOL + WARFARINA (inibição do CYP2C9/CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O cetoconazol inibe o CYP2C9 e o CYP3A4 e pode aumentar muito o INR. Evitar se possível; se inevitável, reduzir a warfarina e monitorizar o INR de perto.',
  summary_pro_en = 'Ketoconazole inhibits CYP2C9 and CYP3A4 and can markedly raise the INR. Avoid if possible; if unavoidable, reduce warfarin and monitor the INR closely.',
  explanation_pt = 'O cetoconazol é um inibidor potente de várias isoenzimas do citocromo P450, incluindo o CYP2C9 (que metaboliza o S-warfarin ativo) e o CYP3A4 (que metaboliza o R-warfarin). A inibição resulta em níveis aumentados de warfarina, elevação do INR e risco hemorrágico significativo — o rótulo do cetoconazol e o da warfarina referem esta interação. Sempre que possível deve evitar-se a associação (existem alternativas antifúngicas com menos interações); se for inevitável, reduzir a dose de warfarina, monitorizar o INR com frequência no início e vigiar sinais de hemorragia.',
  explanation_en = 'Ketoconazole is a potent inhibitor of several cytochrome P450 isoenzymes, including CYP2C9 (which metabolises active S-warfarin) and CYP3A4 (which metabolises R-warfarin). The inhibition results in increased warfarin levels, INR elevation and significant bleeding risk — the ketoconazole and warfarin labels both mention this interaction. Whenever possible the combination should be avoided (alternative antifungals with fewer interactions exist); if unavoidable, reduce the warfarin dose, monitor the INR frequently at initiation and watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 9/26 — CIPROFLOXACINA + WARFARINA (inibição do CYP1A2/CYP3A4 + flora)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A ciprofloxacina inibe o CYP1A2/CYP3A4 e reduz a flora intestinal, podendo aumentar muito o INR. Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Ciprofloxacin inhibits CYP1A2/CYP3A4 and reduces gut flora, potentially raising the INR markedly. Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A ciprofloxacina aumenta o efeito da warfarina por três vias: inibição do CYP1A2 e do CYP3A4 (enzimas que metabolizam a warfarina), redução da flora intestinal produtora de vitamina K e, potencialmente, deslocação da ligação proteica. Existem relatos de aumentos acentuados do INR e hemorragia grave, incluindo casos fatais, pelo que o rótulo da warfarina recomenda monitorizar o INR quando se inicia ou suspende uma fluoroquinolona. A interação é mais marcada em idosos e doentes com múltiplas comorbilidades. Monitorizar o INR com frequência durante e após o ciclo antibiótico e ajustar a dose.',
  explanation_en = 'Ciprofloxacin increases the effect of warfarin through three pathways: inhibition of CYP1A2 and CYP3A4 (enzymes that metabolise warfarin), reduction of the gut flora producing vitamin K and, potentially, displacement of protein binding. There are reports of marked INR elevations and severe, sometimes fatal, bleeding, so the warfarin label recommends INR monitoring when a fluoroquinolone is started or stopped. The interaction is more pronounced in the elderly and in patients with multiple comorbidities. Monitor the INR frequently during and after the antibiotic course and adjust the dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 10/26 — CLARITROMICINA + WARFARINA (inibição do CYP3A4 + flora)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A claritromicina inibe o CYP3A4 e reduz a flora intestinal, podendo aumentar muito o INR e o risco de hemorragia. Monitorizar o INR durante e após o antibiótico; considerar alternativa.',
  summary_pro_en = 'Clarithromycin inhibits CYP3A4 and reduces gut flora, potentially raising the INR and bleeding risk markedly. Monitor the INR during and after the antibiotic; consider an alternative.',
  explanation_pt = 'A claritromicina é um inibidor potente do CYP3A4, a principal enzima do metabolismo do R-warfarin, e simultaneamente reduz a flora intestinal produtora de vitamina K. O resultado é a elevação do INR com risco hemorrágico acrescido, documentada em múltiplos relatos e referida nos rótulos aprovados. O efeito pode aparecer poucos dias após o início e persistir após a suspensão do antibiótico. Sempre que possível, escolher um antibiótico alternativo (ex.: azitromicina tem menor potencial de interação); se a claritromicina for necessária, monitorizar o INR com frequência e reduzir a dose de warfarina conforme necessário.',
  explanation_en = 'Clarithromycin is a potent CYP3A4 inhibitor, the main enzyme in R-warfarin metabolism, and simultaneously reduces the gut flora producing vitamin K. The result is INR elevation with increased bleeding risk, documented in many reports and mentioned in approved labels. The effect can appear within days of starting and persist after the antibiotic is stopped. Whenever possible, choose an alternative antibiotic (e.g. azithromycin has lower interaction potential); if clarithromycin is needed, monitor the INR frequently and reduce the warfarin dose as needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 11/26 — CLOROQUINA + WARFARINA (inibição enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A cloroquina pode aumentar o efeito da warfarina (inibição do metabolismo). Monitorizar o INR ao iniciar e suspender o antimalárico.',
  summary_pro_en = 'Chloroquine can increase the effect of warfarin (metabolism inhibition). Monitor the INR when starting and stopping the antimalarial.',
  explanation_pt = 'A cloroquina e os seus análogos podem inibir o metabolismo da warfarina e aumentar o INR, embora o mecanismo exato não esteja totalmente esclarecido (possível inibição do CYP2C9 e efeito na flora intestinal). Existem relatos de aumento do INR e hemorragia quando a cloroquina é adicionada à warfarina. Recomenda-se monitorizar o INR no início e no fim do tratamento antimalárico e ajustar a dose de warfarina; vigiar sinais de hemorragia, sobretudo em tratamentos prolongados (ex.: lúpus eritematoso sistémico, artrite reumatoide).',
  explanation_en = 'Chloroquine and its analogues can inhibit warfarin metabolism and raise the INR, although the exact mechanism is not fully established (possible CYP2C9 inhibition and an effect on gut flora). Reports exist of INR elevation and bleeding when chloroquine is added to warfarin. The INR should be monitored at the start and end of antimalarial treatment and the warfarin dose adjusted; watch for bleeding signs, especially in prolonged treatment (e.g. systemic lupus erythematosus, rheumatoid arthritis).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 12/26 — EFAVIRENZ + WARFARINA (indução enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O efavirenz induz o CYP2C9/CYP3A4 e pode REDUZIR o efeito da warfarina. Monitorizar o INR ao iniciar e suspender o antirretrovírico e ajustar a dose.',
  summary_pro_en = 'Efavirenz induces CYP2C9/CYP3A4 and can REDUCE the effect of warfarin. Monitor the INR when starting and stopping the antiretroviral and adjust the dose.',
  explanation_pt = 'O efavirenz é um indutor do CYP3A4 e do CYP2C9 (entre outras isoenzimas), acelerando o metabolismo da warfarina e reduzindo os seus níveis plasmáticos. O resultado habitual é a diminuição do INR, com risco de trombose se a dose não for ajustada; no entanto, o efeito é variável entre doentes e pode haver fases de instabilidade do INR em ambos os sentidos. Recomenda-se monitorizar o INR com frequência no início e na suspensão do efavirenz e ajustar a dose de warfarina em conformidade, alertando para sinais de tromboembolismo e de hemorragia.',
  explanation_en = 'Efavirenz induces CYP3A4 and CYP2C9 (among other isoenzymes), accelerating warfarin metabolism and reducing its plasma levels. The usual result is a decrease in the INR, with thrombosis risk if the dose is not adjusted; however, the effect varies between patients and there may be phases of INR instability in both directions. The INR should be monitored frequently at efavirenz initiation and discontinuation and the warfarin dose adjusted accordingly, with vigilance for thromboembolism and bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'efavirenz'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'efavirenz'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 13/26 — ERITROMICINA + WARFARINA (inibição do CYP3A4 + flora)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A eritromicina inibe o CYP3A4 e reduz a flora intestinal, podendo aumentar muito o INR. Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Erythromycin inhibits CYP3A4 and reduces gut flora, potentially raising the INR markedly. Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A eritromicina inibe o CYP3A4, enzima que metaboliza o R-warfarin, e reduz a flora intestinal produtora de vitamina K. Esta dupla ação aumenta o efeito anticoagulante, com elevação do INR e risco hemorrágico documentado em relatos clínicos e referido nos rótulos aprovados. O efeito pode ser rápido (dias) e persistir após o fim do antibiótico. Monitorizar o INR com frequência durante e após o tratamento e ajustar a dose de warfarina; considerar antibiótico alternativo quando possível.',
  explanation_en = 'Erythromycin inhibits CYP3A4, the enzyme that metabolises R-warfarin, and reduces the gut flora producing vitamin K. This dual action increases the anticoagulant effect, with INR elevation and bleeding risk documented in clinical reports and mentioned in approved labels. The effect can be rapid (days) and persist after the antibiotic ends. Monitor the INR frequently during and after treatment and adjust the warfarin dose; consider an alternative antibiotic when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'eritromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'eritromicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 14/26 — FLUCONAZOL + WARFARINA (inibição do CYP2C9)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O fluconazol inibe o CYP2C9 e pode aumentar muito o INR. Monitorizar o INR de perto e reduzir a dose de warfarina ao iniciar o antifúngico.',
  summary_pro_en = 'Fluconazole inhibits CYP2C9 and can markedly raise the INR. Monitor the INR closely and reduce the warfarin dose when starting the antifungal.',
  explanation_pt = 'O fluconazol é um inibidor potente do CYP2C9, a isoenzima que metaboliza o S-warfarin ativo; o efeito é dose-dependente e mais marcado com doses elevadas (ex.: 400 mg/dia). A inibição aumenta os níveis de warfarina e o INR, com risco hemorrágico significativo — interação bem documentada e referida nos rótulos aprovados do fluconazol e da warfarina. Recomenda-se reduzir a dose de warfarina ao iniciar o fluconazol, monitorizar o INR com frequência e ajustar após a suspensão do antifúngico; vigiar sinais de hemorragia.',
  explanation_en = 'Fluconazole is a potent inhibitor of CYP2C9, the isoenzyme that metabolises active S-warfarin; the effect is dose-dependent and more marked at high doses (e.g. 400 mg/day). The inhibition raises warfarin levels and the INR, with significant bleeding risk — a well-documented interaction mentioned in the approved fluconazole and warfarin labels. Reduce the warfarin dose when starting fluconazole, monitor the INR frequently and re-adjust after the antifungal is stopped; watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 15/26 — HIDROXICLOROQUINA + WARFARINA (inibição enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A hidroxicloroquina pode aumentar o efeito da warfarina. Monitorizar o INR ao iniciar e suspender, sobretudo em tratamentos prolongados (lúpus, artrite reumatoide).',
  summary_pro_en = 'Hydroxychloroquine can increase the effect of warfarin. Monitor the INR when starting and stopping, especially in prolonged treatment (lupus, rheumatoid arthritis).',
  explanation_pt = 'A hidroxicloroquina, como a cloroquina, pode inibir o metabolismo da warfarina e aumentar o INR, embora o mecanismo não esteja totalmente esclarecido. Os relatos são mais frequentes em doentes com lúpus eritematoso sistémico ou artrite reumatoide em tratamento crónico, nos quais a interação se pode manifestar semanas após o início. Recomenda-se monitorizar o INR no início e na suspensão da hidroxicloroquina e ajustar a dose de warfarina; vigiar sinais de hemorragia.',
  explanation_en = 'Hydroxychloroquine, like chloroquine, can inhibit warfarin metabolism and raise the INR, although the mechanism is not fully established. Reports are more frequent in patients with systemic lupus erythematosus or rheumatoid arthritis on chronic treatment, in whom the interaction can manifest weeks after initiation. The INR should be monitored at initiation and discontinuation of hydroxychloroquine and the warfarin dose adjusted; watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 16/26 — ISONIAZIDA + WARFARINA (inibição enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A isoniazida pode inibir o metabolismo da warfarina e aumentar o INR. Monitorizar o INR durante o tratamento da tuberculose e ajustar a dose.',
  summary_pro_en = 'Isoniazid can inhibit warfarin metabolism and raise the INR. Monitor the INR during tuberculosis treatment and adjust the dose.',
  explanation_pt = 'A isoniazida inibe várias isoenzimas do citocromo P450, incluindo o CYP2C9 e o CYP3A4, e pode reduzir o metabolismo da warfarina, aumentando o INR. O efeito é variável e coexiste com a complexidade dos esquemas antituberculosos (que incluem frequentemente a rifampicina, um indutor potente — a rede de interações é complexa e o INR pode oscilar nos dois sentidos). Recomenda-se monitorizar o INR com frequência ao iniciar, ajustar e suspender cada componente do esquema antituberculoso e ajustar a dose de warfarina conforme o resultado.',
  explanation_en = 'Isoniazid inhibits several cytochrome P450 isoenzymes, including CYP2C9 and CYP3A4, and can reduce warfarin metabolism, raising the INR. The effect is variable and coexists with the complexity of antituberculosis regimens (which often include rifampicin, a potent inducer — the interaction network is complex and the INR can swing in both directions). The INR should be monitored frequently when starting, adjusting and stopping each component of the antituberculosis regimen, and the warfarin dose adjusted accordingly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isoniazida'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 17/26 — ITRACONAZOL + WARFARINA (inibição do CYP3A4/CYP2C9)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O itraconazol inibe o CYP3A4 (e o CYP2C9) e pode aumentar muito o INR. Evitar se possível; se inevitável, reduzir a warfarina e monitorizar o INR de perto.',
  summary_pro_en = 'Itraconazole inhibits CYP3A4 (and CYP2C9) and can markedly raise the INR. Avoid if possible; if unavoidable, reduce warfarin and monitor the INR closely.',
  explanation_pt = 'O itraconazol é um inibidor potente do CYP3A4 e também afeta o CYP2C9, enzimas envolvidas no metabolismo da warfarina. A inibição resulta em níveis aumentados de warfarina, elevação do INR e risco hemorrágico — interação referida nos rótulos aprovados. Sempre que possível, escolher um antifúngico alternativo com menor potencial de interação; se o itraconazol for inevitável, reduzir a dose de warfarina, monitorizar o INR com frequência no início e durante o tratamento e vigiar sinais de hemorragia.',
  explanation_en = 'Itraconazole is a potent CYP3A4 inhibitor and also affects CYP2C9, enzymes involved in warfarin metabolism. The inhibition results in increased warfarin levels, INR elevation and bleeding risk — an interaction mentioned in approved labels. Whenever possible, choose an alternative antifungal with lower interaction potential; if itraconazole is unavoidable, reduce the warfarin dose, monitor the INR frequently at initiation and during treatment and watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 18/26 — LEVOFLOXACINA + WARFARINA (inibição enzimática + flora)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A levofloxacina pode aumentar o efeito da warfarina (inibição enzimática + flora intestinal). Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Levofloxacin can increase the effect of warfarin (enzyme inhibition + gut flora). Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A levofloxacina, como as restantes fluoroquinolonas, pode potenciar a warfarina por redução da flora intestinal produtora de vitamina K e inibição de isoenzimas do citocromo P450 (CYP1A2 e CYP3A4), embora o seu potencial de inibição seja menor que o da ciprofloxacina. Existem relatos de elevação do INR e hemorragia. Recomenda-se monitorizar o INR durante e após o ciclo antibiótico e ajustar a dose de warfarina; o risco é maior em idosos e doentes com função hepática ou renal diminuída.',
  explanation_en = 'Levofloxacin, like other fluoroquinolones, can potentiate warfarin by reducing the gut flora producing vitamin K and by inhibiting cytochrome P450 isoenzymes (CYP1A2 and CYP3A4), although its inhibition potential is lower than ciprofloxacin''s. Reports exist of INR elevation and bleeding. The INR should be monitored during and after the antibiotic course and the warfarin dose adjusted; the risk is higher in the elderly and in patients with reduced hepatic or renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'levofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levofloxacina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 19/26 — METRONIDAZOL + WARFARINA (inibição do CYP2C9)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O metronidazol inibe o CYP2C9 e pode aumentar muito o INR. Monitorizar o INR durante e após o antibiótico e considerar redução da dose de warfarina.',
  summary_pro_en = 'Metronidazole inhibits CYP2C9 and can markedly raise the INR. Monitor the INR during and after the antibiotic and consider a warfarin dose reduction.',
  explanation_pt = 'O metronidazol é um inibidor potente do CYP2C9, a enzima que metaboliza o S-warfarin ativo, e tem sido associado a aumentos acentuados do INR e hemorragia, incluindo casos graves. O efeito pode surgir poucos dias após o início do antibiótico. O rótulo da warfarina lista o metronidazol entre os fármacos que potenciam o seu efeito. Recomenda-se monitorizar o INR com frequência durante e após o tratamento, considerar reduzir a dose de warfarina e vigiar sinais de hemorragia; em doentes com INR limítrofe, a interação pode ser particularmente perigosa.',
  explanation_en = 'Metronidazole is a potent inhibitor of CYP2C9, the enzyme that metabolises active S-warfarin, and has been associated with marked INR elevations and bleeding, including severe cases. The effect can appear within days of starting the antibiotic. The warfarin label lists metronidazole among the drugs that potentiate its effect. The INR should be monitored frequently during and after treatment, a warfarin dose reduction should be considered, and bleeding signs watched for; in patients with a borderline INR the interaction can be particularly dangerous.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metronidazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 20/26 — NEVIRAPINA + WARFARINA (indução enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A nevirapina induz o CYP3A4/CYP2B6 e pode REDUZIR o efeito da warfarina. Monitorizar o INR ao iniciar e suspender o antirretrovírico.',
  summary_pro_en = 'Nevirapine induces CYP3A4/CYP2B6 and can REDUCE the effect of warfarin. Monitor the INR when starting and stopping the antiretroviral.',
  explanation_pt = 'A nevirapina é um indutor do CYP3A4 e do CYP2B6 e pode acelerar o metabolismo da warfarina, reduzindo os seus níveis e o INR. O risco é a perda de anticoagulação e o tromboembolismo se a dose não for ajustada; o efeito indutor desenvolve-se ao longo de 2–4 semanas e persiste após a suspensão. Recomenda-se monitorizar o INR com frequência no início e no fim da nevirapina e ajustar a dose de warfarina em conformidade, alertando para sinais de trombose.',
  explanation_en = 'Nevirapine induces CYP3A4 and CYP2B6 and can accelerate warfarin metabolism, reducing its levels and the INR. The risk is loss of anticoagulation and thromboembolism if the dose is not adjusted; the inducing effect develops over 2–4 weeks and persists after discontinuation. The INR should be monitored frequently at nevirapine initiation and discontinuation and the warfarin dose adjusted accordingly, with vigilance for thrombosis signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'nevirapina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'nevirapina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 21/26 — PIPERACILINA-TAZOBACTAM + WARFARINA (flora intestinal e vitamina K)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A piperacilina-tazobactam pode potenciar a warfarina por redução da flora intestinal produtora de vitamina K. Monitorizar o INR durante e após o antibiótico.',
  summary_pro_en = 'Piperacillin-tazobactam can potentiate warfarin by reducing the gut flora that produces vitamin K. Monitor the INR during and after the antibiotic.',
  explanation_pt = 'A piperacilina-tazobactam é um antibiótico de largo espetro que reduz a flora intestinal produtora de vitamina K, diminuindo a disponibilidade do cofator da carboxilação dos fatores de coagulação dependentes de vitamina K. Como a warfarina atua pela inibição da vitamina K epóxido redutase, o efeito anticoagulante é potenciado e o INR sobe. O risco é maior em doentes críticos, desnutridos, com doença hepática ou tratamentos prolongados — contexto frequente do uso deste antibiótico. Monitorizar o INR durante e após o tratamento e ajustar a dose de warfarina; vigiar hemorragia.',
  explanation_en = 'Piperacillin-tazobactam is a broad-spectrum antibiotic that reduces the gut flora producing vitamin K, decreasing the availability of the cofactor for carboxylation of the vitamin K-dependent coagulation factors. Since warfarin acts by inhibiting vitamin K epoxide reductase, the anticoagulant effect is potentiated and the INR rises. The risk is higher in critically ill, malnourished, liver-disease patients or with prolonged treatment — a frequent context for this antibiotic. Monitor the INR during and after treatment and adjust the warfarin dose; watch for bleeding.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'piperacilina-tazobactam'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'piperacilina-tazobactam'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 22/26 — QUININA + WARFARINA (inibição do CYP2C9/3A4 + deslocação proteica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A quinina inibe o CYP2C9/CYP3A4 e liga-se extensamente às proteínas, podendo aumentar muito o INR. Monitorizar o INR de perto e considerar redução da dose de warfarina.',
  summary_pro_en = 'Quinine inhibits CYP2C9/CYP3A4 and is highly protein-bound, potentially raising the INR markedly. Monitor the INR closely and consider a warfarin dose reduction.',
  explanation_pt = 'A quinina inibe o metabolismo da warfarina (CYP2C9 e CYP3A4) e, pela elevada ligação às proteínas plasmáticas, pode deslocar a fração livre ativa. O resultado é a elevação acentuada do INR com risco hemorrágico — interação bem documentada, com relatos de hemorragia grave em doentes que usam quinina (ou a bebida tónica com quinina em grandes quantidades) com warfarina. Recomenda-se monitorizar o INR com frequência durante o tratamento e após a suspensão, reduzir a dose de warfarina se necessário e alertar o doente para os sinais de hemorragia.',
  explanation_en = 'Quinine inhibits warfarin metabolism (CYP2C9 and CYP3A4) and, through its high plasma protein binding, can displace the active free fraction. The result is a marked INR elevation with bleeding risk — a well-documented interaction, with reports of severe bleeding in patients using quinine (or quinine-containing tonic water in large amounts) with warfarin. The INR should be monitored frequently during treatment and after discontinuation, the warfarin dose reduced if needed, and the patient alerted to bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 23/26 — RIFAMPICINA + WARFARINA (indução potente do CYP2C9/3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A rifampicina é um indutor potente do CYP2C9/CYP3A4 e pode REDUZIR muito o efeito da warfarina (INR baixo, risco de trombose). Pode ser necessário duplicar ou triplicar a dose de warfarina com monitorização apertada.',
  summary_pro_en = 'Rifampicin is a potent CYP2C9/CYP3A4 inducer and can markedly REDUCE the effect of warfarin (low INR, thrombosis risk). Warfarin may need to be doubled or tripled with close monitoring.',
  explanation_pt = 'A rifampicina é um dos indutores enzimáticos mais potentes do CYP2C9 e do CYP3A4, as enzimas que metabolizam a warfarina. A indução acelera a eliminação da warfarina e reduz drasticamente o INR, com risco de tromboembolismo; estudos mostram reduções superiores a 50% na exposição à warfarina. Em alguns doentes é necessário duplicar ou mesmo triplicar a dose de warfarina, com monitorização frequente do INR, e reajustar a dose nas 1–2 semanas após suspender a rifampicina, porque o efeito indutor desaparece gradualmente e o INR pode então subir. Esta interação é particularmente relevante no tratamento da tuberculose em doentes anticoagulados.',
  explanation_en = 'Rifampicin is one of the most potent inducers of CYP2C9 and CYP3A4, the enzymes that metabolise warfarin. The induction accelerates warfarin elimination and markedly reduces the INR, with thromboembolism risk; studies show reductions of more than 50% in warfarin exposure. Some patients need the warfarin dose doubled or even tripled, with frequent INR monitoring, and the dose must be re-adjusted in the 1–2 weeks after rifampicin is stopped, because the inducing effect fades gradually and the INR can then rise. This interaction is particularly relevant in tuberculosis treatment in anticoagulated patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 24/26 — RITONAVIR + WARFARINA (inibição/indução mista do CYP)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O ritonavir inibe e induz várias isoenzimas do CYP; o efeito líquido na warfarina é imprevisível (habitualmente aumento do INR). Monitorizar o INR de perto ao iniciar e suspender.',
  summary_pro_en = 'Ritonavir inhibits and induces several CYP isoenzymes; the net effect on warfarin is unpredictable (usually an INR increase). Monitor the INR closely when starting and stopping.',
  explanation_pt = 'O ritonavir tem um perfil farmacocinético complexo: é um inibidor potente do CYP3A4 e do CYP2D6, mas também um indutor de outras enzimas e transportadores. O efeito líquido na warfarina é variável e imprevisível entre doentes — a maioria dos relatos mostra aumento do INR, mas há casos de redução. Quando o ritonavir é usado em doses baixas como potenciador (com outros antirretrovíricos), o efeito é igualmente variável. Recomenda-se monitorizar o INR com frequência no início, durante e após a suspensão do ritonavir, ajustando a dose de warfarina conforme o resultado e alertando para sinais de hemorragia e de trombose.',
  explanation_en = 'Ritonavir has a complex pharmacokinetic profile: it is a potent inhibitor of CYP3A4 and CYP2D6, but also an inducer of other enzymes and transporters. The net effect on warfarin is variable and unpredictable between patients — most reports show an INR increase, but cases of reduction exist. When ritonavir is used at low boosting doses (with other antiretrovirals), the effect is equally variable. The INR should be monitored frequently at initiation, during and after ritonavir discontinuation, adjusting the warfarin dose according to the result and alerting for bleeding and thrombosis signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ritonavir'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 25/26 — SULFADOXINA-PIRIMETAMINA + WARFARINA (inibição do CYP2C9 + deslocação proteica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A sulfadoxina (sulfonamida) pode inibir o metabolismo da warfarina e deslocar a fração livre, aumentando o INR. Monitorizar o INR durante e após o antimalárico.',
  summary_pro_en = 'Sulfadoxine (a sulphonamide) can inhibit warfarin metabolism and displace the free fraction, raising the INR. Monitor the INR during and after the antimalarial.',
  explanation_pt = 'As sulfonamidas, como a sulfadoxina, têm sido associadas ao aumento do efeito da warfarina por múltiplos mecanismos: inibição do CYP2C9 (metabolismo do S-warfarin ativo), deslocação da ligação proteica e, potencialmente, redução da flora intestinal produtora de vitamina K. A pirimetamina contribui menos, mas a associação é usada em conjunto na profilaxia e tratamento da malária. Recomenda-se monitorizar o INR no início e no fim do tratamento e ajustar a dose de warfarina; vigiar sinais de hemorragia.',
  explanation_en = 'Sulphonamides, such as sulphadoxine, have been associated with increased warfarin effect through multiple mechanisms: CYP2C9 inhibition (metabolism of active S-warfarin), displacement of protein binding and, potentially, reduction of the gut flora producing vitamin K. Pyrimethamine contributes less, but the two are used together in malaria prophylaxis and treatment. The INR should be monitored at the start and end of treatment and the warfarin dose adjusted; watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sulfadoxina-pirimetamina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sulfadoxina-pirimetamina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 26/26 — VORICONAZOL + WARFARINA (inibição do CYP2C9/3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O voriconazol inibe o CYP2C9/CYP3A4 e pode aumentar muito o INR. Monitorizar o INR de perto e considerar redução da dose de warfarina.',
  summary_pro_en = 'Voriconazole inhibits CYP2C9/CYP3A4 and can markedly raise the INR. Monitor the INR closely and consider a warfarin dose reduction.',
  explanation_pt = 'O voriconazol é um inibidor do CYP2C9 (que metaboliza o S-warfarin ativo) e do CYP3A4, com efeito clinicamente relevante documentado: estudos com doses terapêuticas mostraram aumentos substanciais do INR e da exposição à warfarina quando o voriconazol é adicionado. O rótulo do voriconazol recomenda monitorizar o INR e ajustar a dose de warfarina. A interação é particularmente relevante em doentes com aspergilose invasiva, muitas vezes já em estado clínico frágil. Monitorizar o INR com frequência no início e na suspensão do voriconazol e vigiar sinais de hemorragia.',
  explanation_en = 'Voriconazole inhibits CYP2C9 (which metabolises active S-warfarin) and CYP3A4, with a clinically relevant documented effect: studies at therapeutic doses showed substantial increases in the INR and warfarin exposure when voriconazole is added. The voriconazole label recommends INR monitoring and warfarin dose adjustment. The interaction is particularly relevant in patients with invasive aspergillosis, often already in a fragile clinical state. Monitor the INR frequently at voriconazole initiation and discontinuation and watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'voriconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'voriconazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- =====================================================================
-- FIM — 097: 26 explicações de pares moderados da warfarina (1/2)
-- =====================================================================
