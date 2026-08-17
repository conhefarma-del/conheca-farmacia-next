-- =====================================================================
-- 176: Fluxo 4 — Explicações longas dos 24 pares restantes da migração
--      173 (24 fármacos sem pares + 5 parceiros novos)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en +
-- explanation_pt/en) dos 24 pares ainda sem explicação longa (a 175
-- cobriu os 12 de maior relevância clínica; a 176 cobre os restantes).
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos
--     de risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nos rótulos citados na migração 173
--     (setIDs validados na API DailyMed a 2026-08-17) e no Prontuário
--     Terapêutico do INFARMED (11.ª ed., 2012).
--
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug —
-- reaplicar é seguro. Aplicar na ordem 173 → 176 (não depende da 175).
-- =====================================================================

-- 1. Acetilcisteína × Nitroglicerina (Prontuário 5.2.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Acetilcisteína + nitroglicerina: risco de hipotensão e cefaleias — vigiar a tensão arterial na co-administração.',
  summary_pro_en = 'Acetylcysteine + nitroglycerin: risk of hypotension and headache — monitor blood pressure during co-administration.',
  explanation_pt = 'O Prontuário Terapêutico regista a interação entre a acetilcisteína e a nitroglicerina (hipotensão e cefaleias) na monografia da acetilcisteína (5.2.2). O mecanismo é a potenciação vasodilatadora: a acetilcisteína é um precursor do glutationa e aumenta a disponibilidade do óxido nítrico, reforçando o efeito vasodilatador e hipotensor da nitroglicerina. A associação é clinicamente relevante sobretudo no doente coronário que recebe nitratos e faz acetilcisteína (ex.: como mucolítico), porque a hipotensão sintomática e as cefaleias podem surgir nas primeiras administrações. A orientação prática é monitorizar a tensão arterial, advertir o doente para o risco de cefaleias e tonturas, e, em caso de hipotensão significativa, avaliar o espaçamento das tomas ou a suspensão de um dos fármacos. Não é uma interação de gravidade major, mas exige vigilância clínica ativa.',
  explanation_en = 'The Prontuário Terapêutico records the interaction between acetylcysteine and nitroglycerin (hypotension and headache) in the acetylcysteine monograph (5.2.2). The mechanism is vasodilatory potentiation: acetylcysteine is a glutathione precursor and increases nitric oxide availability, reinforcing the vasodilatory and hypotensive effect of nitroglycerin. The combination is clinically relevant mainly in the coronary patient receiving nitrates who takes acetylcysteine (e.g., as a mucolytic), because symptomatic hypotension and headache may occur in the first administrations. The practical guidance is to monitor blood pressure, warn the patient about the risk of headache and dizziness, and, in case of significant hypotension, assess dose spacing or discontinuation of one of the drugs. It is not a major-severity interaction, but requires active clinical vigilance.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Acetilcisteína, 5.2.2',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Acetylcysteine, 5.2.2'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'acetilcisteina'),
                        (SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acetilcisteina'),
                           (SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'));

-- 2. Ácido ursodesoxicólico × Colestiramina (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ácido ursodesoxicólico + colestiramina: a colestiramina reduz a absorção do ursodesoxicólico — separar as tomas por 4-6 horas.',
  summary_pro_en = 'Ursodeoxycholic acid + cholestyramine: cholestyramine reduces ursodiol absorption — separate doses by 4-6 hours.',
  explanation_pt = 'O rótulo FDA do ursodiol documenta na secção de interações que os sequestrantes de ácidos biliares podem interferir com a ação do ursodiol por redução da sua absorção ("Bile Acid Sequestering Agents: May interfere with the action of ursodiol tablets by reducing its absorption", 7.1). A colestiramina liga-se aos ácidos biliares e a outras moléculas no lúmen intestinal, reduzindo a biodisponibilidade oral do ácido ursodesoxicólico administrado em simultâneo. A consequência clínica é a perda de eficácia no tratamento da litíase biliar e da colangite biliar primária — o doente pode não responder à dose habitual. A orientação prática é separar as tomas: administrar o ursodesoxicólico pelo menos 1 hora antes ou 4-6 horas depois da colestiramina, e avaliar a resposta clínica. A mesma precaução aplica-se a outros sequestrantes (colestipol, colesevelam).',
  explanation_en = 'The FDA ursodiol label documents in the interactions section that bile acid sequestering agents may interfere with the action of ursodiol by reducing its absorption ("Bile Acid Sequestering Agents: May interfere with the action of ursodiol tablets by reducing its absorption", 7.1). Cholestyramine binds bile acids and other molecules in the gut lumen, reducing the oral bioavailability of ursodeoxycholic acid given simultaneously. The clinical consequence is loss of efficacy in gallstone disease and primary biliary cholangitis — the patient may not respond to the usual dose. The practical guidance is to separate the doses: give ursodiol at least 1 hour before or 4-6 hours after cholestyramine, and assess clinical response. The same precaution applies to other sequestrants (colestipol, colesevelam).',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ursodiol (BLUEPOINT LABORATORIES), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3c98080-0a4d-4a93-8dcb-02ab8533050b ; rótulo aprovado Colestiramina (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ursodiol label (BLUEPOINT LABORATORIES), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3c98080-0a4d-4a93-8dcb-02ab8533050b ; approved Cholestyramine label (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=430ac07e-8524-4dec-a599-b7ebc56d9563'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'acido_ursodesoxicolico'),
                        (SELECT id FROM public.drugs WHERE slug = 'colestiramina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acido_ursodesoxicolico'),
                           (SELECT id FROM public.drugs WHERE slug = 'colestiramina'));

-- 3. Ácido ursodesoxicólico × Antiácidos (rótulo FDA 7.2 + prontuário)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ácido ursodesoxicólico + antiácidos: os antiácidos com alumínio reduzem a absorção do ursodesoxicólico — separar as tomas.',
  summary_pro_en = 'Ursodeoxycholic acid + antacids: aluminium-containing antacids reduce ursodiol absorption — separate doses.',
  explanation_pt = 'O rótulo FDA do ursodiol documenta que os antiácidos à base de alumínio podem interferir com a ação do ursodiol por redução da absorção ("Aluminum-based Antacids: May interfere with the action of ursodiol tablets by reducing its absorption", 7.2), e o Prontuário Terapêutico regista a interação com o hidróxido de alumínio na monografia do ácido ursodesoxicólico (6.9.1). A adsorção aos catiões de alumínio no lúmen intestinal reduz a biodisponibilidade oral do ursodesoxicólico, comprometendo o efeito na litíase biliar. A orientação prática é separar a toma por pelo menos 2 horas e avaliar a resposta clínica durante a associação. No doente em tratamento da litíase biliar, a toma simultânea frequente pode traduzir-se em falta de resposta aparente.',
  explanation_en = 'The FDA ursodiol label documents that aluminium-based antacids may interfere with the action of ursodiol by reducing its absorption ("Aluminum-based Antacids: May interfere with the action of ursodiol tablets by reducing its absorption", 7.2), and the Prontuário Terapêutico records the interaction with aluminium hydroxide in the ursodeoxycholic acid monograph (6.9.1). Adsorption to aluminium cations in the gut lumen reduces the oral bioavailability of ursodiol, compromising its effect in gallstone disease. The practical guidance is to separate administration by at least 2 hours and assess clinical response during the combination. In the gallstone patient, frequent simultaneous intake may translate into apparent lack of response.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ursodiol (BLUEPOINT LABORATORIES), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3c98080-0a4d-4a93-8dcb-02ab8533050b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Ácido ursodesoxicólico, 6.9.1',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ursodiol label (BLUEPOINT LABORATORIES), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a3c98080-0a4d-4a93-8dcb-02ab8533050b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Ursodeoxycholic acid, 6.9.1'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'acido_ursodesoxicolico'),
                        (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acido_ursodesoxicolico'),
                           (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

-- 4. Cefalexina × Probenecida (rótulo FDA 7.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefalexina + probenecida: a probenecida inibe a secreção tubular da cefalexina — associação não recomendada.',
  summary_pro_en = 'Cephalexin + probenecid: probenecid inhibits cephalexin tubular secretion — combination not recommended.',
  explanation_pt = 'O rótulo FDA da cefalexina documenta explicitamente: "Probenecid - The renal excretion of cephalexin is inhibited by probenecid. Co-administration of probenecid with cephalexin is not recommended" (secção 7.2). A probenecida bloqueia a secreção tubular renal dos beta-lactâmicos, elevando e prolongando as concentrações séricas da cefalexina — o que historicamente foi usado para prolongar os níveis das penicilinas, mas aumenta o risco de efeitos adversos dose-dependentes (neurotoxicidade, diarreia, reações cutâneas). No idoso e no doente renal, o risco de neurotoxicidade (confusão, mioclonias) é maior. A orientação prática é evitar a associação; se a probenecida for essencial (ex.: como uricosúrico em doente com infeção), considerar a redução da dose ou o aumento do intervalo da cefalexina e vigiar sinais de toxicidade.',
  explanation_en = 'The FDA cephalexin label explicitly documents: "Probenecid - The renal excretion of cephalexin is inhibited by probenecid. Co-administration of probenecid with cephalexin is not recommended" (section 7.2). Probenecid blocks the renal tubular secretion of beta-lactams, raising and prolonging serum cephalexin concentrations — historically used to prolong penicillin levels, but increasing the risk of dose-dependent adverse effects (neurotoxicity, diarrhoea, skin reactions). In the elderly and renally impaired, the risk of neurotoxicity (confusion, myoclonus) is higher. The practical guidance is to avoid the combination; if probenecid is essential (e.g., as a uricosuric in a patient with infection), consider reducing the cephalexin dose or extending the interval and monitor for signs of toxicity.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefalexina (PREFERRED PHARMACEUTICALS), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=553485f8-890d-4929-a6bb-905221cf411d ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cephalexin label (PREFERRED PHARMACEUTICALS), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=553485f8-890d-4929-a6bb-905221cf411d ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefalexina'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefalexina'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));

-- 5. Cefazolina × Probenecida (rótulo FDA 7)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefazolina + probenecida: a probenecida diminui a secreção tubular da cefazolina — associação não recomendada.',
  summary_pro_en = 'Cefazolin + probenecid: probenecid decreases cefazolin tubular secretion — combination not recommended.',
  explanation_pt = 'O rótulo FDA da cefazolina documenta: "Probenecid may decrease renal tubular secretion of cephalosporins when used concurrently, resulting in increased and more prolonged cephalosporin blood levels. Co-administration of probenecid with Cefazolin is not recommended" (secção 7). O mecanismo é idêntico ao das outras cefalosporinas — bloqueio da secreção tubular renal pela probenecida, com elevação das concentrações séricas da cefazolina. A associação não tem benefício terapêutico na prática atual (ao contrário do uso histórico como adjuvante das penicilinas) e aumenta o risco de efeitos adversos dose-dependentes. A orientação prática é evitar a associação; se inevitável, considerar redução da dose da cefazolina e vigiar sinais de toxicidade, sobretudo no doente renal.',
  explanation_en = 'The FDA cefazolin label documents: "Probenecid may decrease renal tubular secretion of cephalosporins when used concurrently, resulting in increased and more prolonged cephalosporin blood levels. Co-administration of probenecid with Cefazolin is not recommended" (section 7). The mechanism is identical to other cephalosporins — probenecid blockade of renal tubular secretion, raising serum cefazolin concentrations. The combination has no therapeutic benefit in current practice (unlike the historical use as a penicillin adjuvant) and increases the risk of dose-dependent adverse effects. The practical guidance is to avoid the combination; if unavoidable, consider reducing the cefazolin dose and monitor for signs of toxicity, especially in the renally impaired.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefazolina (MEDICAL PURCHASING SOLUTIONS), secção 7: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=79787707-c84f-f229-e053-2a91aa0a1f16 ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefazolin label (MEDICAL PURCHASING SOLUTIONS), section 7: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=79787707-c84f-f229-e053-2a91aa0a1f16 ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefazolina'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefazolina'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));

-- 6. Cefepima × Amicacina (rótulo FDA 7.2 — classe aminoglicosídeos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefepima + amicacina: nefrotoxicidade e ototoxicidade aditivas (aminoglicosídeo) — monitorizar função renal e sintomas auditivos.',
  summary_pro_en = 'Cefepime + amikacin: additive nephrotoxicity and ototoxicity (aminoglycoside) — monitor renal function and auditory symptoms.',
  explanation_pt = 'O rótulo FDA da cefepima documenta a classe dos aminoglicosídeos na secção de interações ("Aminoglycosides: increased potential of nephrotoxicity and ototoxicity. Monitor renal function", 7.2). A amicacina é um aminoglicosídeo de largo espectro usado sobretudo contra Gram-negativos multirresistentes, e a associação com a cefepima é frequente em regimes empíricos de infeções graves (ex.: sépsis nosocomial, neutropenia febril). O risco renal e auditivo é aditivo e a ototoxicidade pode ser irreversível. A monitorização deve incluir creatinina e débito urinário, vigilância de tinitus, hipoacusia e vertigem, e, quando disponível, níveis séricos da amicacina. No idoso e no doente renal, prolongar o intervalo do aminoglicosídeo e reavaliar a necessidade da associação diariamente.',
  explanation_en = 'The FDA cefepime label documents the aminoglycoside class in the interactions section ("Aminoglycosides: increased potential of nephrotoxicity and ototoxicity. Monitor renal function", 7.2). Amikacin is a broad-spectrum aminoglycoside used mainly against multidrug-resistant Gram-negatives, and the combination with cefepime is common in empirical regimens for severe infections (e.g., nosocomial sepsis, febrile neutropenia). The renal and auditory risk is additive and ototoxicity can be irreversible. Monitoring should include creatinine and urine output, watch for tinnitus, hearing loss and vertigo, and, when available, amikacin serum levels. In the elderly and renally impaired, extend the aminoglycoside interval and reassess the need for the combination daily.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefepima (WG CRITICAL CARE), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefepime label (WG CRITICAL CARE), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                        (SELECT id FROM public.drugs WHERE slug = 'amicacina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                           (SELECT id FROM public.drugs WHERE slug = 'amicacina'));

-- 7. Cefepima × Tobramicina (rótulo FDA 7.2 — classe aminoglicosídeos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefepima + tobramicina: nefrotoxicidade e ototoxicidade aditivas (aminoglicosídeo) — monitorizar função renal e sintomas auditivos.',
  summary_pro_en = 'Cefepime + tobramycin: additive nephrotoxicity and ototoxicity (aminoglycoside) — monitor renal function and auditory symptoms.',
  explanation_pt = 'O rótulo FDA da cefepima documenta a classe dos aminoglicosídeos com aumento do potencial de nefrotoxicidade e ototoxicidade e recomendação de monitorização da função renal (7.2). A tobramicina é usada sobretudo em infeções por Pseudomonas e associa-se à cefepima em regimes dirigidos ou empíricos de infeções graves. O risco renal e auditivo é aditivo; a ototoxicidade (tinitus, hipoacusia, vertigem) pode ser irreversível e o compromisso renal é mais frequente no idoso e no doente com função renal limítrofe. A monitorização inclui creatinina, débito urinário e sintomas vestibulares/auditivos; quando aplicável, níveis séricos da tobramicina. Considerar a duração mais curta possível da associação.',
  explanation_en = 'The FDA cefepime label documents the aminoglycoside class with increased potential for nephrotoxicity and ototoxicity and a recommendation to monitor renal function (7.2). Tobramycin is used mainly in Pseudomonas infections and is combined with cefepime in directed or empirical regimens for severe infections. The renal and auditory risk is additive; ototoxicity (tinnitus, hearing loss, vertigo) can be irreversible and renal impairment is more frequent in the elderly and in patients with borderline renal function. Monitoring includes creatinine, urine output and vestibular/auditory symptoms; when applicable, tobramycin serum levels. Consider the shortest possible duration of the combination.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefepima (WG CRITICAL CARE), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; rótulo aprovado Tobramicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c4751a4f-c9c1-60c5-e053-2995a90aeba9',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefepime label (WG CRITICAL CARE), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; approved Tobramycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c4751a4f-c9c1-60c5-e053-2995a90aeba9'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                        (SELECT id FROM public.drugs WHERE slug = 'tobramicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                           (SELECT id FROM public.drugs WHERE slug = 'tobramicina'));

-- 8. Cefepima × Estreptomicina (rótulo FDA 7.2 — classe aminoglicosídeos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefepima + estreptomicina: nefrotoxicidade e ototoxicidade aditivas (aminoglicosídeo) — monitorizar função renal e sintomas auditivos.',
  summary_pro_en = 'Cefepime + streptomycin: additive nephrotoxicity and ototoxicity (aminoglycoside) — monitor renal function and auditory symptoms.',
  explanation_pt = 'O rótulo FDA da cefepima documenta a classe dos aminoglicosídeos com aumento do potencial de nefrotoxicidade e ototoxicidade (7.2). A estreptomicina é o aminoglicosídeo clássico, ainda usado em endocardites (ex.: por Streptococcus) e na tuberculose; a associação com cefepima tem risco renal e auditivo aditivo. A ototoxicidade vestibular e coclear da estreptomicina é conhecida e pode ser irreversível. A monitorização deve incluir função renal, sintomas vestibulares (vertigem, nistagmo) e auditivos (tinitus, hipoacusia), e a duração da associação deve ser a mais curta possível. No doente renal ou idoso, o intervalo do aminoglicosídeo deve ser prolongado.',
  explanation_en = 'The FDA cefepime label documents the aminoglycoside class with increased potential for nephrotoxicity and ototoxicity (7.2). Streptomycin is the classic aminoglycoside, still used in endocarditis (e.g., Streptococcus) and tuberculosis; the combination with cefepime has additive renal and auditory risk. Streptomycin vestibular and cochlear ototoxicity is well known and can be irreversible. Monitoring should include renal function, vestibular symptoms (vertigo, nystagmus) and auditory symptoms (tinnitus, hearing loss), and the duration of the combination should be as short as possible. In the renally impaired or elderly, the aminoglycoside interval should be extended.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefepima (WG CRITICAL CARE), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; rótulo aprovado Estreptomicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=78982c98-7866-49f1-989f-a289c4242358',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefepime label (WG CRITICAL CARE), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5fd857e5-591f-44ca-80cf-fd903660b03c ; approved Streptomycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=78982c98-7866-49f1-989f-a289c4242358'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                        (SELECT id FROM public.drugs WHERE slug = 'estreptomicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefepima'),
                           (SELECT id FROM public.drugs WHERE slug = 'estreptomicina'));

-- 9. Cefotaxima × Probenecida (Prontuário 1.1.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefotaxima + probenecida: a probenecida inibe a secreção tubular das cefalosporinas — eleva as concentrações séricas.',
  summary_pro_en = 'Cefotaxime + probenecid: probenecid inhibits cephalosporin tubular secretion — raises serum concentrations.',
  explanation_pt = 'O Prontuário Terapêutico documenta na introdução das cefalosporinas (1.1.2): "A probenecida inibe competitivamente a secreção tubular da maioria das cefalosporinas causando um aumento significativo das suas concentrações séricas". A cefotaxima é excretada por secreção tubular renal, pelo que a probenecida eleva e prolonga as suas concentrações plasmáticas. Embora a associação tenha sido historicamente usada para prolongar os níveis dos antibióticos, não é recomendada na prática atual — o aumento da exposição pode potenciar efeitos adversos dose-dependentes, incluindo neurotoxicidade no idoso e no doente renal. A orientação prática é evitar a associação; se a probenecida for essencial, considerar a redução da dose da cefotaxima e monitorizar sinais de toxicidade.',
  explanation_en = 'The Prontuário Terapêutico documents in the cephalosporin introduction (1.1.2): "Probenecid competitively inhibits the tubular secretion of most cephalosporins, causing a significant increase in their serum concentrations". Cefotaxime is excreted by renal tubular secretion, so probenecid raises and prolongs its plasma concentrations. Although the combination was historically used to prolong antibiotic levels, it is not recommended in current practice — the increased exposure may potentiate dose-dependent adverse effects, including neurotoxicity in the elderly and renally impaired. The practical guidance is to avoid the combination; if probenecid is essential, consider reducing the cefotaxime dose and monitor for signs of toxicity.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Cefalosporinas, 1.1.2 ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Cephalosporins, 1.1.2 ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefotaxima'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefotaxima'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));

-- 10. Cefuroxima × Levonorgestrel (rótulo FDA 7.1 — contracetivos orais)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefuroxima + contracetivos orais: alterações da flora intestinal podem reduzir a eficácia contracetiva — considerar método de barreira.',
  summary_pro_en = 'Cefuroxime + oral contraceptives: gut flora changes may reduce contraceptive efficacy — consider a barrier method.',
  explanation_pt = 'O rótulo FDA da cefuroxima documenta: "Oral Contraceptives: Effects on gut flora may lower estrogen reabsorption and reduce efficacy of oral contraceptives" (secção 7.1). Os antibióticos de largo espectro podem alterar a flora intestinal e reduzir a reabsorção de estrogénios, comprometendo a fiabilidade contracetiva dos contraceptivos orais combinados. O risco é maior com terapêuticas prolongadas, mas a precaução aplica-se a qualquer antibioterapia. A orientação prática é advertir as utilizadoras para o risco de perda de eficácia durante e até 7 dias após a antibioterapia e considerar método de barreira adicional; vigiar spotting ou hemorragia intermenstrual como sinal de possível perda de eficácia. O levonorgestrel (incluindo o DIU hormonal) não é afetado por este mecanismo — a interação aplica-se sobretudo aos contraceptivos orais combinados.',
  explanation_en = 'The FDA cefuroxime label documents: "Oral Contraceptives: Effects on gut flora may lower estrogen reabsorption and reduce efficacy of oral contraceptives" (section 7.1). Broad-spectrum antibiotics may alter gut flora and reduce oestrogen reabsorption, compromising the contraceptive reliability of combined oral contraceptives. The risk is higher with prolonged therapy, but the precaution applies to any antibiotic course. The practical guidance is to advise users about the risk of reduced efficacy during and up to 7 days after antibiotic therapy and consider an additional barrier method; watch for spotting or breakthrough bleeding as a sign of possible loss of efficacy. Levonorgestrel (including the hormonal IUD) is not affected by this mechanism — the interaction applies mainly to combined oral contraceptives.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefuroxima axetil (WOCKHARDT), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; rótulo aprovado Levonorgestrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefuroxime axetil label (WOCKHARDT), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; approved Levonorgestrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07567b80-d8a1-41c0-95e4-33afa584bbc4'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                        (SELECT id FROM public.drugs WHERE slug = 'levonorgestrel'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                           (SELECT id FROM public.drugs WHERE slug = 'levonorgestrel'));

-- 11. Cefuroxima × Antiácidos (rótulo FDA 7.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefuroxima + antiácidos: os antiácidos reduzem a biodisponibilidade da cefuroxima axetil oral — separar as tomas.',
  summary_pro_en = 'Cefuroxime + antacids: antacids reduce the bioavailability of oral cefuroxime axetil — separate doses.',
  explanation_pt = 'O rótulo FDA da cefuroxima documenta: "Drugs that reduce gastric acidity may lower the bioavailability of cefuroxime axetil tablets" (secção 7.2). A cefuroxima axetil oral é uma pró-fármaco cuja absorção depende de pH gástrico ácido; os antiácidos (e também os inibidores da bomba de protões e os antagonistas H2) reduzem essa absorção e podem comprometer a eficácia antibiótica. A consequência clínica é a falência terapêutica numa infeção tratada por via oral. A orientação prática é separar a toma da cefuroxima dos antiácidos por 2-3 horas e avaliar a resposta clínica; em infeções graves ou no doente com dispepsia que requeira supressão ácida contínua, considerar a via parentérica ou alternativa antibiótica.',
  explanation_en = 'The FDA cefuroxime label documents: "Drugs that reduce gastric acidity may lower the bioavailability of cefuroxime axetil tablets" (section 7.2). Oral cefuroxime axetil is a prodrug whose absorption depends on an acidic gastric pH; antacids (and also proton pump inhibitors and H2 antagonists) reduce that absorption and may compromise antibiotic efficacy. The clinical consequence is therapeutic failure in an orally treated infection. The practical guidance is to separate cefuroxime from antacids by 2-3 hours and assess clinical response; in severe infections or in patients with dyspepsia requiring continuous acid suppression, consider the parenteral route or an alternative antibiotic.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefuroxima axetil (WOCKHARDT), secção 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; rótulo aprovado Antiácidos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefuroxime axetil label (WOCKHARDT), section 7.2: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; approved Antacids label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                        (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                           (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

-- 12. Cefuroxima × Probenecida (rótulo FDA 7.3)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cefuroxima + probenecida: a probenecida aumenta a exposição sistémica à cefuroxima — associação não recomendada.',
  summary_pro_en = 'Cefuroxime + probenecid: probenecid increases systemic exposure to cefuroxime — combination not recommended.',
  explanation_pt = 'O rótulo FDA da cefuroxima documenta: "Co-administration with probenecid increases systemic exposure to cefuroxime axetil tablets and is therefore not recommended" (secção 7.3). A probenecida bloqueia a secreção tubular renal da cefuroxima, elevando as suas concentrações séricas e prolongando a exposição. Embora a associação tenha sido historicamente explorada para prolongar os níveis antibióticos, não é recomendada na prática atual — o aumento da exposição pode potenciar efeitos adversos dose-dependentes (neurotoxicidade, diarreia, reações cutâneas). A orientação prática é evitar a associação; se a probenecida for essencial (ex.: uricosúrico em doente com gota e infeção), considerar a redução da dose da cefuroxima e monitorizar sinais de toxicidade.',
  explanation_en = 'The FDA cefuroxime label documents: "Co-administration with probenecid increases systemic exposure to cefuroxime axetil tablets and is therefore not recommended" (section 7.3). Probenecid blocks the renal tubular secretion of cefuroxime, raising its serum concentrations and prolonging exposure. Although the combination was historically explored to prolong antibiotic levels, it is not recommended in current practice — the increased exposure may potentiate dose-dependent adverse effects (neurotoxicity, diarrhoea, skin reactions). The practical guidance is to avoid the combination; if probenecid is essential (e.g., uricosuric in a gout patient with infection), consider reducing the cefuroxime dose and monitor for signs of toxicity.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefuroxima axetil (WOCKHARDT), secção 7.3: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Cefuroxime axetil label (WOCKHARDT), section 7.3: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=708b7a4d-ba1f-47b5-be4d-a01c2a7017ff ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cefuroxima'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));

-- 13. Etilefrina × Salbutamol (Prontuário 3.2.4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Etilefrina + salbutamol: potenciação simpaticomimética — risco de taquicardia e tremor.',
  summary_pro_en = 'Etilefrine + salbutamol: sympathomimetic potentiation — risk of tachycardia and tremor.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da etilefrina (3.2.4) a potenciação de efeito quando administrada simultaneamente com outras substâncias simpaticomiméticas. O salbutamol é um agonista beta-2 usado na asma e na DPOC; a associação com a etilefrina (simpaticomimético beta-1 com componente alfa) tem efeitos aditivos — taquicardia, tremor e possível hipocaliemia, sobretudo em doses elevadas ou com inalações frequentes. O risco é maior no doente cardíaco e no asmático com broncodilatadores em uso crónico. A orientação prática é monitorizar a frequência cardíaca e os sintomas adrenérgicos, considerar o ajuste de dose e vigiar o potássio sérico em terapêuticas prolongadas.',
  explanation_en = 'The Prontuário Terapêutico documents in the etilefrine monograph (3.2.4) the potentiation of effect when administered simultaneously with other sympathomimetic substances. Salbutamol is a beta-2 agonist used in asthma and COPD; the combination with etilefrine (beta-1 sympathomimetic with an alpha component) has additive effects — tachycardia, tremor and possible hypokalaemia, especially at high doses or with frequent inhalations. The risk is higher in the cardiac patient and in the asthmatic on chronic bronchodilators. The practical guidance is to monitor heart rate and adrenergic symptoms, consider dose adjustment and monitor serum potassium in prolonged therapy.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Etilefrina, 3.2.4',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Etilefrine, 3.2.4'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'etilefrina'),
                        (SELECT id FROM public.drugs WHERE slug = 'salbutamol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'etilefrina'),
                           (SELECT id FROM public.drugs WHERE slug = 'salbutamol'));

-- 14. Famotidina × Cetoconazol (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Famotidina + cetoconazol: a famotidina reduz a absorção do cetoconazol (pH-dependente) — separar as tomas por ≥ 2 horas.',
  summary_pro_en = 'Famotidine + ketoconazole: famotidine reduces ketoconazole absorption (pH-dependent) — separate doses by ≥ 2 hours.',
  explanation_pt = 'O rótulo FDA da famotidina documenta a classe dos fármacos dependentes do pH gástrico: "Drugs Dependent on Gastric pH for Absorption: Systemic exposure of the concomitant drug may be significantly reduced leading to loss of efficacy" (secção 7.1). O cetoconazol (comprimidos) requer pH gástrico ácido para dissolver e absorver — a supressão ácida pela famotidina reduz drasticamente a sua biodisponibilidade e pode levar à falência do tratamento antifúngico (ex.: candidíase esofágica ou sistémica). A orientação prática é separar as tomas por pelo menos 2 horas, preferir administrar o cetoconazol com bebida ácida e, se a supressão ácida for contínua, considerar alternativa antifúngica menos pH-dependente (ex.: fluconazol). Avaliar a resposta clínica ao antifúngico durante a associação.',
  explanation_en = 'The FDA famotidine label documents the class of gastric pH-dependent drugs: "Drugs Dependent on Gastric pH for Absorption: Systemic exposure of the concomitant drug may be significantly reduced leading to loss of efficacy" (section 7.1). Ketoconazole (tablets) requires an acidic gastric pH to dissolve and absorb — famotidine acid suppression markedly reduces its bioavailability and may lead to failure of antifungal treatment (e.g., oesophageal or systemic candidiasis). The practical guidance is to separate doses by at least 2 hours, prefer giving ketoconazole with an acidic drink and, if acid suppression is continuous, consider a less pH-dependent antifungal alternative (e.g., fluconazole). Assess clinical response to the antifungal during the combination.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Famotidina (TEVA), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; rótulo aprovado Cetoconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dd0da52b-fc82-4ec9-854c-0d7c52e926fb',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Famotidine label (TEVA), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; approved Ketoconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dd0da52b-fc82-4ec9-854c-0d7c52e926fb'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                        (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                           (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 15. Famotidina × Itraconazol (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Famotidina + itraconazol: a famotidina reduz a absorção do itraconazol (pH-dependente) — separar as tomas por ≥ 2 horas.',
  summary_pro_en = 'Famotidine + itraconazole: famotidine reduces itraconazole absorption (pH-dependent) — separate doses by ≥ 2 hours.',
  explanation_pt = 'O rótulo FDA da famotidina documenta a classe dos fármacos dependentes do pH gástrico ("Drugs Dependent on Gastric pH for Absorption... may be significantly reduced leading to loss of efficacy", 7.1). As cápsulas de itraconazol requerem pH ácido para uma absorção adequada; a supressão ácida pela famotidina reduz a sua biodisponibilidade e pode comprometer o tratamento de infeções fúngicas (ex.: onicomicose, aspergilose). A orientação prática é separar as tomas por pelo menos 2 horas; quando a supressão ácida é contínua, considerar a solução oral de itraconazol (menos dependente do pH) ou alternativa antifúngica. Avaliar a resposta clínica ao antifúngico durante a associação.',
  explanation_en = 'The FDA famotidine label documents the class of gastric pH-dependent drugs ("Drugs Dependent on Gastric pH for Absorption... may be significantly reduced leading to loss of efficacy", 7.1). Itraconazole capsules require an acidic pH for adequate absorption; famotidine acid suppression reduces its bioavailability and may compromise treatment of fungal infections (e.g., onychomycosis, aspergillosis). The practical guidance is to separate doses by at least 2 hours; when acid suppression is continuous, consider itraconazole oral solution (less pH-dependent) or an alternative antifungal. Assess clinical response to the antifungal during the combination.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Famotidina (TEVA), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; rótulo aprovado Itraconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Famotidine label (TEVA), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; approved Itraconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                        (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                           (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 16. Famotidina × Atazanavir (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Famotidina + atazanavir: a famotidina reduz a absorção do atazanavir (pH-dependente) — risco de falência virológica.',
  summary_pro_en = 'Famotidine + atazanavir: famotidine reduces atazanavir absorption (pH-dependent) — risk of virological failure.',
  explanation_pt = 'O rótulo FDA da famotidina documenta a classe dos fármacos dependentes do pH gástrico (7.1). O atazanavir é um inibidor da protease do VIH cuja absorção depende de pH ácido; a supressão ácida pela famotidina reduz significativamente a sua exposição plasmática, com risco de falência virológica e resistência do vírus. Esta é uma das interações mais relevantes em doentes com VIH que necessitam de supressão ácida. A orientação prática é seguir as recomendações específicas do atazanavir: administrar a famotidina 10-12 horas antes ou depois da toma do atazanavir (espaçamento recomendado) e considerar o aumento da dose do atazanavir (com ritonavir) quando indicado; monitorizar a carga viral durante a associação prolongada. Em alternativa, preferir um antagonista H2 ou IBP com menor impacto documentado, sob orientação do especialista.',
  explanation_en = 'The FDA famotidine label documents the class of gastric pH-dependent drugs (7.1). Atazanavir is an HIV protease inhibitor whose absorption depends on an acidic pH; famotidine acid suppression significantly reduces its plasma exposure, with a risk of virological failure and viral resistance. This is one of the most relevant interactions in HIV patients requiring acid suppression. The practical guidance is to follow atazanavir-specific recommendations: give famotidine 10-12 hours before or after the atazanavir dose (recommended spacing) and consider increasing the atazanavir dose (with ritonavir) when indicated; monitor viral load during prolonged combination. Alternatively, prefer an H2 antagonist or PPI with less documented impact, under specialist guidance.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Famotidina (TEVA), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; rótulo aprovado Atazanavir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=165cff62-b284-4a27-a65d-9ec8a5bfcdd8',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Famotidine label (TEVA), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c6f4f9e-f3f5-4ecf-9f40-887e037e8847 ; approved Atazanavir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=165cff62-b284-4a27-a65d-9ec8a5bfcdd8'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                        (SELECT id FROM public.drugs WHERE slug = 'atazanavir'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'famotidina'),
                           (SELECT id FROM public.drugs WHERE slug = 'atazanavir'));

-- 17. Fenoximetilpenicilina × Probenecida (Prontuário 1.1.1.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fenoximetilpenicilina + probenecida: a probenecida inibe a secreção tubular das penicilinas — eleva as concentrações séricas.',
  summary_pro_en = 'Phenoxymethylpenicillin + probenecid: probenecid inhibits penicillin tubular secretion — raises serum concentrations.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da fenoximetilpenicilina (1.1.1.1): "A probenecida inibe competitivamente a secreção tubular das penicilinas causando um aumento significativo das suas concentrações séricas". Historicamente, a probenecida foi usada como adjuvante para prolongar os níveis séricos das penicilinas (incluindo no tratamento da sífilis e da gonorreia), mas essa prática é hoje reservada a indicações específicas e não deve ser feita por rotina. A elevação das concentrações pode potenciar efeitos adversos dose-dependentes das penicilinas (neurotoxicidade em altas doses, reações alérgicas mais intensas). A orientação prática é evitar a associação por rotina; se a probenecida for usada como adjuvante em indicação específica, monitorizar sinais de toxicidade e ajustar a dose da penicilina.',
  explanation_en = 'The Prontuário Terapêutico documents in the phenoxymethylpenicillin monograph (1.1.1.1): "Probenecid competitively inhibits the tubular secretion of penicillins, causing a significant increase in their serum concentrations". Historically, probenecid was used as an adjuvant to prolong serum penicillin levels (including in syphilis and gonorrhoea treatment), but this practice is now reserved for specific indications and should not be done routinely. The raised concentrations may potentiate dose-dependent adverse effects of penicillins (neurotoxicity at high doses, more intense allergic reactions). The practical guidance is to avoid the combination routinely; if probenecid is used as an adjuvant for a specific indication, monitor for signs of toxicity and adjust the penicillin dose.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Fenoximetilpenicilina, 1.1.1.1 ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Phenoxymethylpenicillin, 1.1.1.1 ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'fenoximetilpenicilina'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fenoximetilpenicilina'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));

-- 18. Memantina × Dextrometorfano (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Memantina + dextrometorfano: antagonistas NMDA em associação — usar com precaução.',
  summary_pro_en = 'Memantine + dextromethorphan: NMDA antagonists in combination — use with caution.',
  explanation_pt = 'O rótulo FDA da memantina documenta: "Use with other NMDA antagonists (amantadine, ketamine, and dextromethorphan) has not been systematically evaluated and such use should be approached with caution" (secção 7.1). O dextrometorfano, antitússico, é um antagonista NMDA de baixa afinidade; a associação com a memantina, antagonista NMDA de afinidade moderada, pode potenciar efeitos adversos do SNC — sedação, confusão, tonturas e, em casos extremos, alucinações. A associação é possível em doentes com demência que usam antitússicos, mas deve ser evitada ou usada com precaução. A orientação prática é vigiar alterações do estado mental e sedação; perante sintomas, reduzir ou suspender um dos fármacos.',
  explanation_en = 'The FDA memantine label documents: "Use with other NMDA antagonists (amantadine, ketamine, and dextromethorphan) has not been systematically evaluated and such use should be approached with caution" (section 7.1). Dextromethorphan, an antitussive, is a low-affinity NMDA antagonist; combining with memantine, a moderate-affinity NMDA antagonist, may potentiate CNS adverse effects — sedation, confusion, dizziness and, in extreme cases, hallucinations. The combination is possible in dementia patients using antitussives, but should be avoided or used with caution. The practical guidance is to monitor mental status changes and sedation; if symptoms occur, reduce or stop one of the drugs.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Memantina (NAMENDA XR), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=617dcd31-3215-4dd8-9b6e-d888d3bf30f3 ; rótulo aprovado Dextrometorfano: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d99237c-0b52-0af6-e063-6394a90aba14',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Memantine label (NAMENDA XR), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=617dcd31-3215-4dd8-9b6e-d888d3bf30f3 ; approved Dextromethorphan label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d99237c-0b52-0af6-e063-6394a90aba14'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                        (SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                           (SELECT id FROM public.drugs WHERE slug = 'dextrometorfano'));

-- 19. Memantina × Cetamina (rótulo FDA 7.1)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Memantina + cetamina: antagonistas NMDA em associação — usar com precaução (sedação profunda possível).',
  summary_pro_en = 'Memantine + ketamine: NMDA antagonists in combination — use with caution (possible profound sedation).',
  explanation_pt = 'O rótulo FDA da memantina documenta que a associação com outros antagonistas NMDA (incluindo a cetamina) não foi sistematicamente avaliada e deve ser abordada com precaução (secção 7.1). A cetamina é um antagonista NMDA potente, usado em anestesia e, cada vez mais, em doses baixas para depressão resistente e dor crónica; a soma do antagonismo NMDA com a memantina pode potenciar efeitos dissociativos, sedação profunda e compromisso psicomotor. A interação é relevante sobretudo no contexto perioperatório ou terapêutico com cetamina em doentes medicados com memantina (demência de Alzheimer). A orientação prática é informar a equipa anestésica da medicação em curso, monitorizar o nível de consciência e os sinais vitais, e ajustar as doses de cetamina em conformidade.',
  explanation_en = 'The FDA memantine label documents that the combination with other NMDA antagonists (including ketamine) has not been systematically evaluated and should be approached with caution (section 7.1). Ketamine is a potent NMDA antagonist, used in anaesthesia and increasingly in low doses for resistant depression and chronic pain; the additive NMDA antagonism with memantine may potentiate dissociative effects, profound sedation and psychomotor impairment. The interaction is relevant mainly in the perioperative or therapeutic ketamine setting in patients on memantine (Alzheimer dementia). The practical guidance is to inform the anaesthetic team of current medication, monitor level of consciousness and vital signs, and adjust ketamine doses accordingly.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Memantina (NAMENDA XR), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=617dcd31-3215-4dd8-9b6e-d888d3bf30f3 ; rótulo aprovado Cetamina (KETALAR): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Memantine label (NAMENDA XR), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=617dcd31-3215-4dd8-9b6e-d888d3bf30f3 ; approved Ketamine label (KETALAR): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14e8f864-8b8a-4e7e-8439-e510d3107063'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                        (SELECT id FROM public.drugs WHERE slug = 'cetamina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                           (SELECT id FROM public.drugs WHERE slug = 'cetamina'));

-- 20. Memantina × Warfarina (Prontuário — memantina)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Memantina + warfarina: a memantina pode potenciar o efeito anticoagulante da warfarina — monitorizar o INR.',
  summary_pro_en = 'Memantine + warfarin: memantine may potentiate the anticoagulant effect of warfarin — monitor INR.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da memantina a possibilidade de potenciar o efeito anticoagulante da varfarina. O mecanismo não está totalmente esclarecido, mas a interação é clinicamente relevante porque os doentes com demência (indicação da memantina) são frequentemente idosos polimedicados, incluindo anticoagulados. O risco é de sobredosagem da varfarina com INR supraterapêutico e hemorragia (equimoses, gengivorragia, melenas) quando a memantina é iniciada ou ajustada. A orientação prática é monitorizar o INR após iniciar, ajustar ou suspender a memantina em doentes anticoagulados com warfarina, e vigiar sinais hemorrágicos; a mesma precaução aplica-se aos novos anticoagulantes orais, ainda que menos documentada.',
  explanation_en = 'The Prontuário Terapêutico documents in the memantine monograph the possibility of potentiating the anticoagulant effect of warfarin. The mechanism is not fully clarified, but the interaction is clinically relevant because dementia patients (memantine indication) are frequently elderly and polymedicated, including anticoagulated. The risk is warfarin over-anticoagulation with supratherapeutic INR and bleeding (bruising, gum bleeding, melaena) when memantine is started or adjusted. The practical guidance is to monitor INR after starting, adjusting or stopping memantine in patients anticoagulated with warfarin, and watch for bleeding signs; the same precaution applies to the new oral anticoagulants, although less documented.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Memantina ; rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Memantine ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                        (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'memantina'),
                           (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 21. Montelucaste × Fenobarbital (Prontuário 5.1.3.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Montelucaste + fenobarbital: o fenobarbital pode reduzir a eficácia do montelucaste — monitorizar o controlo da asma.',
  summary_pro_en = 'Montelukast + phenobarbital: phenobarbital may reduce montelukast efficacy — monitor asthma control.',
  explanation_pt = 'O Prontuário Terapêutico documenta as interações do montelucaste com fenobarbital, fenitoína e rifampicina (5.1.3.2). Estes indutores enzimáticos aceleram o metabolismo do montelucaste (CYP3A4/2C9), podendo reduzir as suas concentrações plasmáticas e comprometer o controlo da asma. O fenobarbital é um indutor enzimático potente; a associação é possível em doentes com asma e epilepsia, mas a eficácia do antileucotrieno pode diminuir. A orientação prática é monitorizar o controlo da asma (sintomas, despertares noturnos, uso de broncodilatador de alívio, PEF) durante a associação e considerar o ajuste de dose ou alternativa terapêutica se houver perda de controlo.',
  explanation_en = 'The Prontuário Terapêutico documents montelukast interactions with phenobarbital, phenytoin and rifampicin (5.1.3.2). These enzyme inducers accelerate montelukast metabolism (CYP3A4/2C9), potentially reducing its plasma concentrations and compromising asthma control. Phenobarbital is a potent enzyme inducer; the combination is possible in patients with asthma and epilepsy, but leukotriene efficacy may decrease. The practical guidance is to monitor asthma control (symptoms, nocturnal awakenings, reliever use, PEF) during the combination and consider dose adjustment or a therapeutic alternative if control is lost.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Montelucaste, 5.1.3.2 ; rótulo aprovado Fenobarbital: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Montelukast, 5.1.3.2 ; approved Phenobarbital label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'));

-- 22. Montelucaste × Fenitoína (Prontuário 5.1.3.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Montelucaste + fenitoína: a fenitoína pode reduzir a eficácia do montelucaste — monitorizar o controlo da asma.',
  summary_pro_en = 'Montelukast + phenytoin: phenytoin may reduce montelukast efficacy — monitor asthma control.',
  explanation_pt = 'O Prontuário Terapêutico documenta a interação do montelucaste com a fenitoína (5.1.3.2). A fenitoína é um indutor do CYP3A4/2C9 e acelera o metabolismo do montelucaste, podendo reduzir as suas concentrações séricas e comprometer o efeito preventivo na asma. A associação é possível em doentes com asma e epilepsia em fenitoína. A orientação prática é monitorizar o controlo da asma (sintomas, uso de medicação de alívio, PEF) durante a associação; perante perda de controlo, considerar o ajuste de dose do montelucaste ou alternativa terapêutica. A interação é de gravidade moderada e não exige suspensão profilática, apenas vigilância clínica.',
  explanation_en = 'The Prontuário Terapêutico documents the montelukast interaction with phenytoin (5.1.3.2). Phenytoin is a CYP3A4/2C9 inducer and accelerates montelukast metabolism, potentially reducing its serum concentrations and compromising the preventive effect in asthma. The combination is possible in patients with asthma and epilepsy on phenytoin. The practical guidance is to monitor asthma control (symptoms, reliever use, PEF) during the combination; if control is lost, consider montelukast dose adjustment or a therapeutic alternative. The interaction is moderate in severity and does not require prophylactic discontinuation, only clinical vigilance.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Montelucaste, 5.1.3.2 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Montelukast, 5.1.3.2 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

-- 23. Montelucaste × Rifampicina (Prontuário 5.1.3.2)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Montelucaste + rifampicina: a rifampicina pode reduzir a eficácia do montelucaste — monitorizar o controlo da asma.',
  summary_pro_en = 'Montelukast + rifampicin: rifampicin may reduce montelukast efficacy — monitor asthma control.',
  explanation_pt = 'O Prontuário Terapêutico documenta a interação do montelucaste com a rifampicina (5.1.3.2). A rifampicina é um potente indutor do CYP3A4 e acelera o metabolismo do montelucaste, podendo reduzir significativamente as suas concentrações e comprometer o controlo da asma — relevante no doente asmático em tratamento de tuberculose. A orientação prática é monitorizar o controlo da asma (sintomas, uso de medicação de alívio, PEF) durante a associação e considerar o ajuste de dose do montelucaste ou alternativa terapêutica se houver perda de controlo. A interação é moderada, mas o efeito da rifampicina na indução enzimática é marcado, pelo que a vigilância deve ser ativa durante o esquema antituberculoso.',
  explanation_en = 'The Prontuário Terapêutico documents the montelukast interaction with rifampicin (5.1.3.2). Rifampicin is a potent CYP3A4 inducer and accelerates montelukast metabolism, potentially significantly reducing its concentrations and compromising asthma control — relevant in the asthmatic patient treated for tuberculosis. The practical guidance is to monitor asthma control (symptoms, reliever use, PEF) during the combination and consider montelukast dose adjustment or a therapeutic alternative if control is lost. The interaction is moderate, but rifampicin enzyme induction is marked, so vigilance should be active during the tuberculosis regimen.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Montelucaste, 5.1.3.2 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Montelukast, 5.1.3.2 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b389b1a3-672f-47e3-916c-4a9c044b211b'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                        (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'montelukast'),
                           (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 24. Pirazinamida × Probenecida (Prontuário 1.1.12)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Pirazinamida + probenecida: a pirazinamida antagoniza o efeito uricosúrico da probenecida.',
  summary_pro_en = 'Pyrazinamide + probenecid: pyrazinamide antagonises the uricosuric effect of probenecid.',
  explanation_pt = 'O Prontuário Terapêutico documenta na monografia da pirazinamida (1.1.12): "A pirazinamida antagoniza os efeitos da probenecida e da sulfimpirazona". A pirazinamida reduz a excreção renal de ácido úrico (efeito hiperuricemiante bem conhecido, dose-dependente), contrariando o efeito uricosúrico da probenecida — que depende do aumento da excreção tubular do urato. A consequência clínica é a perda de eficácia do tratamento uricosúrico em doentes com gota que fazem terapêutica antituberculosa. A orientação prática é monitorizar o ácido úrico sérico e os sinais de gota (dor articular aguda) em doentes tratados com probenecida durante a pirazinamida, e considerar o ajuste do uricosúrico ou alternativa durante o esquema antituberculoso.',
  explanation_en = 'The Prontuário Terapêutico documents in the pyrazinamide monograph (1.1.12): "Pyrazinamide antagonises the effects of probenecid and sulfinpyrazone". Pyrazinamide reduces renal uric acid excretion (a well-known, dose-dependent hyperuricaemic effect), counteracting the uricosuric effect of probenecid — which depends on increased tubular urate excretion. The clinical consequence is loss of efficacy of uricosuric treatment in gout patients undergoing antituberculosis therapy. The practical guidance is to monitor serum uric acid and gout signs (acute joint pain) in patients treated with probenecid during pyrazinamide, and consider adjusting the uricosuric or an alternative during the tuberculosis regimen.',
  source_pt = 'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Pirazinamida, 1.1.12 ; rótulo aprovado Probenecida (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
  source_en = 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Pyrazinamide, 1.1.12 ; approved Probenecid label (MARLEX): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'pirazinamida'),
                        (SELECT id FROM public.drugs WHERE slug = 'probenecida'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'pirazinamida'),
                           (SELECT id FROM public.drugs WHERE slug = 'probenecida'));
