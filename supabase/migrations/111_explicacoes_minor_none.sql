-- =====================================================================
-- 111 — Explicações fármaco-fármaco dos pares MINOR e NONE
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 11 pares minor e 3 pares none que os tinham vazios — com
-- esta migração, TODOS os 402 pares publicados ficam com explicação.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Os pares minor são interações ligeiras (monitorizar, sem contraindicação);
-- os pares none são associações sem interação adversa clinicamente
-- relevante (algumas usadas de forma intencional na prática).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/14 — [minor] ÁCIDO FÓLICO + CIPROFLOXACINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Associação geralmente sem interação relevante; pode manter-se a terapêutica habitual.',
  summary_pro_en = 'The combination is generally safe with no relevant interaction; usual therapy can be maintained.',
  explanation_pt = 'O ácido fólico e a ciprofloxacina não partilham vias farmacocinéticas ou farmacodinâmicas que justifiquem uma interação clinicamente relevante. Não há evidência de que a ciprofloxacina altere os níveis de folato ou que o ácido fólico interfira com a atividade antibacteriana da fluoroquinolona. A associação é comum na prática (por exemplo, profilaxia em doentes imunodeprimidos) e pode ser mantida sem ajustes, respeitando apenas os horários habituais de cada fármaco.',
  explanation_en = 'Folic acid and ciprofloxacin do not share pharmacokinetic or pharmacodynamic pathways that would justify a clinically relevant interaction. There is no evidence that ciprofloxacin alters folate levels or that folic acid interferes with the antibacterial activity of the fluoroquinolone. The combination is common in practice (for example, prophylaxis in immunocompromised patients) and can be maintained without adjustments, only respecting the usual schedules of each drug.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acido_folico'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acido_folico'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 2/14 — [minor] ADRENALINA + CIPROFLOXACINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Adrenalina + fluoroquinolona: risco teórico de prolongamento do QTc. Vigiar ECG em doentes de risco.',
  summary_pro_en = 'Epinephrine + fluoroquinolone: theoretical risk of QTc prolongation. Monitor the ECG in at-risk patients.',
  explanation_pt = 'Tanto a adrenalina como a ciprofloxacina podem, em circunstâncias particulares, contribuir para o prolongamento do intervalo QT, embora o risco aditivo seja essencialmente teórico para esta associação. Na prática clínica a combinação surge sobretudo em contexto de emergência (anafilaxia em doente a tomar ciprofloxacina) ou de infeção grave com instabilidade hemodinâmica. Não é necessário evitar a associação, mas em doentes com fatores de risco (QT longo congénito, hipocaliemia, bradicardia, outros fármacos que prolonguem o QT) é prudente vigiar o ECG e corrigir eletrólitos.',
  explanation_en = 'Both epinephrine and ciprofloxacin can, in particular circumstances, contribute to QT interval prolongation, although the additive risk is essentially theoretical for this combination. In clinical practice the combination arises mainly in emergencies (anaphylaxis in a patient taking ciprofloxacin) or in severe infection with haemodynamic instability. The combination does not need to be avoided, but in patients with risk factors (congenital long QT, hypokalaemia, bradycardia, other QT-prolonging drugs) it is prudent to monitor the ECG and correct electrolytes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

-- 3/14 — [minor] ALOPURINOL + FEBUXOSTAT
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois inibidores da xantina-oxidase: sem benefício e com risco aumentado de reações de hipersensibilidade. Não associar.',
  summary_pro_en = 'Two xanthine oxidase inhibitors: no benefit and increased risk of hypersensitivity reactions. Do not combine.',
  explanation_pt = 'O alopurinol e o febuxostat atuam pelo mesmo mecanismo — inibição da xantina-oxidase — e a sua associação não acrescenta eficácia no controlo da hiperuricemia, mas pode aumentar o risco de reações de hipersensibilidade (incluindo síndrome de hipersensibilidade e, raramente, reações cutâneas graves). Na prática, a combinação não é utilizada: o doente deve estar medicado com um único inibidor da xantina-oxidase, na dose titulada, com profilaxia de crises gotosas nos primeiros meses e monitorização da uricemia. Se houver intolerância a um, considera-se a mudança para o outro, nunca a associação.',
  explanation_en = 'Allopurinol and febuxostat act by the same mechanism — xanthine oxidase inhibition — and combining them adds no efficacy in controlling hyperuricaemia, but can increase the risk of hypersensitivity reactions (including hypersensitivity syndrome and, rarely, severe skin reactions). In practice the combination is not used: the patient should be on a single xanthine oxidase inhibitor, at the titrated dose, with gout flare prophylaxis in the first months and uric acid monitoring. If intolerance to one occurs, switching to the other is considered, never combining them.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'), (SELECT id FROM public.drugs WHERE slug = 'febuxostat'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'), (SELECT id FROM public.drugs WHERE slug = 'febuxostat'));

-- 4/14 — [minor] ASPIRINA + HIDROXICLOROQUINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroxicloroquina + aspirina: risco gastrointestinal aditivo. Usar com precaução e vigiar sintomas digestivos.',
  summary_pro_en = 'Hydroxychloroquine + aspirin: additive gastrointestinal risk. Use with caution and monitor digestive symptoms.',
  explanation_pt = 'A aspirina, sobretudo em doses anti-inflamatórias ou com uso prolongado, pode irritar a mucosa gástrica; a hidroxicloroquina associa-se também a sintomas gastrointestinais (náuseas, diarreia, desconforto abdominal). A associação pode somar estes efeitos e aumentar o risco de dispepsia ou, mais raramente, de lesão da mucosa. Em doentes com história de úlcera, considerar gastroproteção, usar a menor dose eficaz de aspirina e vigiar sintomas digestivos; a toma com alimentos pode reduzir o desconforto.',
  explanation_en = 'Aspirin, especially at anti-inflammatory doses or with prolonged use, can irritate the gastric mucosa; hydroxychloroquine is also associated with gastrointestinal symptoms (nausea, diarrhoea, abdominal discomfort). The combination can add these effects and increase the risk of dyspepsia or, more rarely, mucosal injury. In patients with a history of ulcer, consider gastroprotection, use the lowest effective aspirin dose and monitor digestive symptoms; taking with food can reduce discomfort.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'));

-- 5/14 — [minor] ASPIRINA + IBUPROFENO
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O ibuprofeno pode reduzir o efeito cardioprotetor da aspirina de baixa dose. Tomar o ibuprofeno 30–60 min após a aspirina ou usar paracetamol.',
  summary_pro_en = 'Ibuprofen may reduce the cardioprotective effect of low-dose aspirin. Take ibuprofen 30–60 min after aspirin or use paracetamol.',
  explanation_pt = 'O ibuprofeno, quando tomado antes da aspirina de baixa dose (antiagregante), pode ocupar reversivelmente o local ativo da COX-1 plaquetária e impedir a acetilação irreversível pela aspirina, reduzindo o efeito antiagregante e a proteção cardiovascular. O risco é maior com ibuprofeno de venda livre tomado regularmente. Recomenda-se tomar o ibuprofeno pelo menos 30–60 minutos depois da aspirina (ou 8 horas antes, em dose única), ou preferir paracetamol para analgesia pontual. Em doentes com alto risco cardiovascular, esta interação deve ser evitada.',
  explanation_en = 'Ibuprofen, when taken before low-dose (antiplatelet) aspirin, can reversibly occupy the platelet COX-1 active site and prevent the irreversible acetylation by aspirin, reducing the antiplatelet effect and cardiovascular protection. The risk is higher with regular over-the-counter ibuprofen. Take ibuprofen at least 30–60 minutes after aspirin (or 8 hours before, as a single dose), or prefer paracetamol for occasional analgesia. In patients at high cardiovascular risk, this interaction should be avoided.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 6/14 — [minor] CALCITRIOL + FUROSEMIDA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Calcitriol + diurético de ansa: efeitos contrários sobre a calcemia. Monitorizar cálcio e função renal.',
  summary_pro_en = 'Calcitriol + loop diuretic: opposing effects on serum calcium. Monitor calcium and renal function.',
  explanation_pt = 'O calcitriol (vitamina D ativa) aumenta a absorção intestinal de cálcio e tende a elevar a calcemia, enquanto a furosemida aumenta a excreção urinária de cálcio e tende a reduzi-la. Os efeitos são contrários e, na prática, a combinação é por vezes usada (por exemplo, na hipercalcemia com hipercalciúria), mas exige monitorização: a furosemida pode mascarar a hipercalcemia induzida pelo calcitriol ou, em doentes desidratados, precipitar hipocalcemia. Recomenda-se vigiar o cálcio sérico, o magnésio e a função renal, e ajustar as doses conforme os objetivos terapêuticos.',
  explanation_en = 'Calcitriol (active vitamin D) increases intestinal calcium absorption and tends to raise serum calcium, while furosemide increases urinary calcium excretion and tends to lower it. The effects are opposing and, in practice, the combination is sometimes used (for example, in hypercalcaemia with hypercalciuria), but requires monitoring: furosemide can mask calcitriol-induced hypercalcaemia or, in dehydrated patients, precipitate hypocalcaemia. Monitor serum calcium, magnesium and renal function, and adjust doses according to therapeutic goals.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 7/14 — [minor] CIANOCOBALAMINA + OMEPRAZOL
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O uso prolongado de omeprazol pode reduzir a absorção da vitamina B12 alimentar, mas raramente afeta a cianocobalamina suplementar.',
  summary_pro_en = 'Long-term omeprazole may reduce absorption of dietary vitamin B12, but rarely affects supplemental cyanocobalamin.',
  explanation_pt = 'Os inibidores da bomba de protões, como o omeprazol, reduzem a secreção ácida gástrica necessária para libertar a vitamina B12 ligada às proteínas dos alimentos, pelo que o uso prolongado pode diminuir a absorção da B12 alimentar e, em casos raros, levar a défice de vitamina B12. A cianocobalamina suplementar em doses farmacológicas é absorvida por difusão passiva, independente do fator intrínseco e do pH, pelo que a suplementação oral mantém a eficácia. Em doentes com omeprazol crónico e fatores de risco (idosos, dieta vegetariana, gastrite atrófica), considerar vigiar a B12 e suplementar se necessário.',
  explanation_en = 'Proton pump inhibitors such as omeprazole reduce the gastric acid secretion needed to release protein-bound vitamin B12 from food, so long-term use can reduce dietary B12 absorption and, in rare cases, lead to vitamin B12 deficiency. Supplemental cyanocobalamin at pharmacological doses is absorbed by passive diffusion, independent of intrinsic factor and pH, so oral supplementation maintains efficacy. In patients on chronic omeprazole with risk factors (elderly, vegetarian diet, atrophic gastritis), consider monitoring B12 and supplementing if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cianocobalamina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cianocobalamina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 8/14 — [minor] DIFENIDRAMINA + SERTRALINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Anti-histamínico sedativo + ISRS: sedação aditiva ligeira. Vigiar sonolência diurna.',
  summary_pro_en = 'Sedating antihistamine + SSRI: mild additive sedation. Watch for daytime drowsiness.',
  explanation_pt = 'A difenidramina é um anti-histamínico de primeira geração com efeito sedativo central, e a sertralina pode causar sonolência ou fadiga, sobretudo no início do tratamento. A associação soma o efeito sedativo, podendo causar sonolência diurna, redução da concentração e maior risco de quedas em idosos. Não é contraindicada, mas recomenda-se precaução: preferir anti-histamínicos menos sedativos se necessário, evitar a toma ao volante e vigiar sintomas. Em idosos, considerar o risco anticolinérgico da difenidramina (confusão, retenção urinária, xerostomia).',
  explanation_en = 'Diphenhydramine is a first-generation antihistamine with central sedative effect, and sertraline can cause drowsiness or fatigue, especially at treatment start. The combination adds up the sedative effect, potentially causing daytime drowsiness, reduced concentration and a higher risk of falls in the elderly. It is not contraindicated, but caution is recommended: prefer less sedating antihistamines if needed, avoid driving and monitor symptoms. In the elderly, consider the anticholinergic burden of diphenhydramine (confusion, urinary retention, dry mouth).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'difenidramina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'difenidramina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 9/14 — [minor] FLUOXETINA + PSEUDOEFEDRINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Descongestionante + ISRS: possível aumento do efeito pressor. Vigiar pressão arterial e sintomas adrenérgicos.',
  summary_pro_en = 'Decongestant + SSRI: possible increased pressor effect. Monitor blood pressure and adrenergic symptoms.',
  explanation_pt = 'A pseudoefedrina é um simpaticomimético com efeito vasoconstritor e pressor; a fluoxetina pode potenciar os efeitos adrenérgicos (taquicardia, hipertensão, tremores) e há ainda um risco teórico de síndrome serotoninérgica pela componente serotonérgica da pseudoefedrina. A interação é ligeira na maioria dos doentes, mas recomenda-se precaução em hipertensos, cardiopatas e doentes com hipertiroidismo: vigiar a pressão arterial, usar a menor dose e o menor tempo de descongestionante, e preferir alternativas não simpaticomiméticas (corticoides nasais, soro fisiológico) quando possível.',
  explanation_en = 'Pseudoephedrine is a sympathomimetic with vasoconstrictor and pressor effects; fluoxetine can potentiate the adrenergic effects (tachycardia, hypertension, tremor) and there is also a theoretical risk of serotonin syndrome from the serotonergic component of pseudoephedrine. The interaction is mild in most patients, but caution is recommended in hypertensive, cardiac and hyperthyroid patients: monitor blood pressure, use the lowest dose and shortest duration of the decongestant, and prefer non-sympathomimetic alternatives (nasal corticosteroids, saline) when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'));

-- 10/14 — [minor] GLIBENCLAMIDA + METFORMINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hipoglicemia. A associação de dois antidiabéticos orais exige ajuste e vigilância; não é contraindicada.',
  summary_pro_en = 'Hypoglycaemia. Combining two oral antidiabetics requires dose adjustment and surveillance; not contraindicated.',
  explanation_pt = 'A glibenclamida (sulfonilureia) estimula a secreção de insulina e a metformina reduz a produção hepática de glicose e melhora a sensibilidade à insulina — mecanismos complementares e sinérgicos, sendo a associação uma opção habitual na diabetes tipo 2. O principal risco é a hipoglicemia, potenciada pela sulfonilureia, sobretudo em idosos, jejum prolongado, insuficiência renal ou redução da ingestão alimentar. Recomenda-se iniciar com doses baixas, titular lentamente, educar o doente para os sinais de hipoglicemia e ajustar a glibenclamida perante qualquer deterioração da função renal.',
  explanation_en = 'Glibenclamide (sulphonylurea) stimulates insulin secretion and metformin reduces hepatic glucose production and improves insulin sensitivity — complementary and synergistic mechanisms, making the combination a usual option in type 2 diabetes. The main risk is hypoglycaemia, potentiated by the sulphonylurea, especially in the elderly, prolonged fasting, renal impairment or reduced food intake. Start with low doses, titrate slowly, educate the patient about hypoglycaemia signs and adjust glibenclamide with any deterioration of renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- 11/14 — [minor] PSEUDOEFEDRINA + SERTRALINA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Descongestionante + ISRS: possível aumento do efeito pressor e serotonérgico. Vigiar pressão arterial.',
  summary_pro_en = 'Decongestant + SSRI: possible increased pressor and serotonergic effect. Monitor blood pressure.',
  explanation_pt = 'A pseudoefedrina tem efeito simpaticomimético (vasoconstrição, taquicardia) e a sertralina, como ISRS, pode potenciar os efeitos adrenérgicos e aumentar teoricamente o risco de síndrome serotoninérgica. Na maioria dos doentes a interação é ligeira e autolimitada, mas em hipertensos, cardiopatas ou doentes idosos recomenda-se vigiar a pressão arterial e os sintomas adrenérgicos (palpitações, tremores, agitação). Usar o descongestionante na menor dose e pelo menor tempo, preferindo alternativas locais (corticoides nasais) em doentes de risco.',
  explanation_en = 'Pseudoephedrine has a sympathomimetic effect (vasoconstriction, tachycardia) and sertraline, as an SSRI, can potentiate the adrenergic effects and theoretically increase the risk of serotonin syndrome. In most patients the interaction is mild and self-limited, but in hypertensive, cardiac or elderly patients monitor blood pressure and adrenergic symptoms (palpitations, tremor, agitation). Use the decongestant at the lowest dose and for the shortest time, preferring local alternatives (nasal corticosteroids) in at-risk patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'pseudoefedrina'), (SELECT id FROM public.drugs WHERE slug = 'sertralina'));

-- 12/14 — [none] AMLODIPINA + CAPTOPRIL
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sem interação adversa clinicamente relevante. Combinação de 1.ª linha em hipertensão; monitorizar a pressão arterial na titulação.',
  summary_pro_en = 'No clinically relevant adverse interaction. First-line antihypertensive combination; monitor blood pressure during titration.',
  explanation_pt = 'Um inibidor da enzima de conversão da angiotensina (captopril) associado a um bloqueador dos canais de cálcio (amlodipina) é uma combinação de primeira linha no tratamento da hipertensão, com efeitos anti-hipertensores complementares e sinérgicos. Não existe interação adversa clinicamente relevante; o único efeito esperado é o hipotensor aditivo, desejável na hipertensão não controlada, que requer apenas monitorização da pressão arterial durante a titulação. Em doentes idosos ou com hipotensão ortostática, iniciar com doses baixas e titular gradualmente.',
  explanation_en = 'An angiotensin-converting enzyme inhibitor (captopril) combined with a calcium-channel blocker (amlodipine) is a first-line combination in the treatment of hypertension, with complementary and synergistic antihypertensive effects. There is no clinically relevant adverse interaction; the only expected effect is additive hypotension, desirable in uncontrolled hypertension, which only requires blood pressure monitoring during titration. In elderly patients or those with orthostatic hypotension, start with low doses and titrate gradually.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'captopril'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'captopril'));

-- 13/14 — [none] AMLODIPINA + ENALAPRIL
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sem interação adversa clinicamente relevante. Combinação de 1.ª linha em hipertensão; monitorizar a pressão arterial na titulação.',
  summary_pro_en = 'No clinically relevant adverse interaction. First-line antihypertensive combination; monitor blood pressure during titration.',
  explanation_pt = 'O enalapril (IECA) e a amlodipina (bloqueador dos canais de cálcio) são frequentemente associados no tratamento da hipertensão e da doença coronária, com efeitos complementares: o IECA bloqueia o sistema renina-angiotensina e a amlodipina relaxa a musculatura vascular. Não há interação adversa relevante; o efeito hipotensor aditivo é o mecanismo terapêutico pretendido e exige apenas monitorização da pressão arterial, sobretudo no início e nos ajustes de dose. Em doentes com edema periférico induzido pela amlodipina, o IECA pode até atenuá-lo.',
  explanation_en = 'Enalapril (ACE inhibitor) and amlodipine (calcium-channel blocker) are frequently combined in the treatment of hypertension and coronary disease, with complementary effects: the ACE inhibitor blocks the renin-angiotensin system and amlodipine relaxes vascular smooth muscle. There is no relevant adverse interaction; the additive hypotensive effect is the intended therapeutic mechanism and only requires blood pressure monitoring, especially at start and at dose adjustments. In patients with amlodipine-induced peripheral oedema, the ACE inhibitor may even attenuate it.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'enalapril'));

-- 14/14 — [none] ESPIRONOLACTONA + HIDROCLOROTIAZIDA
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sem interação clinicamente relevante. Associação por vezes usada de forma intencional pelo efeito diurético sinérgico com menor hipocaliemia.',
  summary_pro_en = 'No clinically relevant interaction. The combination is sometimes used intentionally for synergistic diuresis with less hypokalaemia.',
  explanation_pt = 'A espironolactona (diurético poupador de potássio) e a hidroclorotiazida (tiazida) têm mecanismos complementares no túbulo renal: a tiazida aumenta a excreção de sódio e potássio, enquanto a espironolactona antagoniza a aldosterona e retém potássio. A associação é por vezes utilizada de forma intencional para potenciar a diurese e a natriurese com menor risco de hipocaliemia do que a tiazida isolada. Não há interação adversa clinicamente relevante, mas o equilíbrio eletrolítico deve ser monitorizado: o risco principal é a hipercaliemia em doentes com insuficiência renal ou com suplementos de potássio, e a hiponatremia em idosos.',
  explanation_en = 'Spironolactone (potassium-sparing diuretic) and hydrochlorothiazide (thiazide) have complementary mechanisms in the renal tubule: the thiazide increases sodium and potassium excretion, while spironolactone antagonises aldosterone and retains potassium. The combination is sometimes used intentionally to potentiate diuresis and natriuresis with less hypokalaemia than the thiazide alone. There is no clinically relevant adverse interaction, but the electrolyte balance must be monitored: the main risks are hyperkalaemia in patients with renal impairment or potassium supplements, and hyponatraemia in the elderly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));
