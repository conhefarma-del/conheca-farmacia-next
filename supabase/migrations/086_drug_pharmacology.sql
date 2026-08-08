-- =====================================================================
-- 086 — Farmacologia do fármaco (drug_pharmacology)
-- ---------------------------------------------------------------------
-- Nova tabela 1:1 com public.drugs com a secção "Farmacologia" da ficha
-- dedicada por fármaco (/medicamento/[slug]): farmacodinâmica, mecanismo
-- de ação, metabolismo, absorção e meia-vida, PT/EN.
--
-- Seed piloto (conteúdo autoral, ancorado nas fontes citadas):
--   • 6 fármacos com perfil na 079 (warfarina, ibuprofeno, ramipril,
--     espironolactona, sotalol, furosemida), extraído da secção 12
--     CLINICAL PHARMACOLOGY dos rótulos aprovados (setIDs já validados
--     nas migrações 057/063/070/079);
--   • ibuprofeno: os rótulos DailyMed de venda livre não incluem a secção
--     12 — farmacologia autorada a partir da revisão clássica de
--     farmacocinética (Davies NM, Clin Pharmacokinet 1998; PMID 9515184)
--     e do resumo PharmGKB (PMC4355401).
-- Idempotente: reaplicar é seguro (ON CONFLICT DO NOTHING). Aplicar
-- manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DDL — drug_pharmacology
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.drug_pharmacology (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID NOT NULL UNIQUE REFERENCES public.drugs(id) ON DELETE CASCADE,
  pharmacodynamics_pt TEXT NOT NULL DEFAULT '',
  pharmacodynamics_en TEXT NOT NULL DEFAULT '',
  mechanism_pt TEXT NOT NULL DEFAULT '',
  mechanism_en TEXT NOT NULL DEFAULT '',
  metabolism_pt TEXT NOT NULL DEFAULT '',
  metabolism_en TEXT NOT NULL DEFAULT '',
  absorption_pt TEXT NOT NULL DEFAULT '',
  absorption_en TEXT NOT NULL DEFAULT '',
  half_life_pt TEXT NOT NULL DEFAULT '',
  half_life_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  updated_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS (mesmo padrão das restantes tabelas: admin_all + anon_read)
ALTER TABLE public.drug_pharmacology ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_drug_pharmacology" ON public.drug_pharmacology
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_drug_pharmacology" ON public.drug_pharmacology
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE TRIGGER set_drug_pharmacology_updated_at
  BEFORE UPDATE ON public.drug_pharmacology
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------------------------------------------------------------
-- 2. Seed — 6 fármacos (padrão 7.6: JOIN com ON d.slug = v.slug)
-- ---------------------------------------------------------------------
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en,
   half_life_pt, half_life_en, source_pt, source_en, status)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('warfarina',
   'Anticoagulante oral: o efeito anticoagulante surge normalmente nas primeiras 24 horas após a administração, mas o efeito máximo pode demorar 72 a 96 horas. A duração de ação de uma dose única é de 2 a 5 dias. A meia-vida dos fatores de coagulação dependentes da vitamina K explica esta dinâmica: fator II cerca de 60 h, fator VII 4 a 6 h, fator IX 24 h, fator X 48 a 72 h, e as proteínas anticoagulantes C e S cerca de 8 h e 30 h, respetivamente.',
   'Oral anticoagulant: the anticoagulant effect usually appears within 24 hours of administration, but peak effect may be delayed 72 to 96 hours. The duration of action of a single dose is 2 to 5 days. The half-lives of the vitamin K-dependent clotting factors explain this profile: factor II about 60 h, factor VII 4 to 6 h, factor IX 24 h, factor X 48 to 72 h, and the anticoagulant proteins C and S about 8 h and 30 h, respectively.',
   'A varfarina inibe a síntese dos fatores de coagulação dependentes da vitamina K (II, VII, IX e X) e das proteínas anticoagulantes C e S. A inibição da subunidade C1 do complexo enzimático VKORC1 (epóxido-redutase da vitamina K) reduz a regeneração da vitamina K a partir do seu epóxido, diminuindo a carboxilação gama dos fatores dependentes desta vitamina.',
   'Warfarin inhibits the synthesis of the vitamin K-dependent clotting factors (II, VII, IX and X) and of the anticoagulant proteins C and S. Inhibition of the C1 subunit of the VKORC1 enzyme complex (vitamin K epoxide reductase) reduces the regeneration of vitamin K from its epoxide, decreasing the gamma-carboxylation of the vitamin K-dependent factors.',
   'A eliminação é quase inteiramente por metabolismo hepático, de forma estereosseletiva: a S-warfarina (2 a 5 vezes mais ativa) é hidroxilada sobretudo pelo CYP2C9 (enzima polimórfica; os alelos variantes *2 e *3 reduzem a sua depuração), além de CYP2C19, 2C8, 2C18, 1A2 e 3A4, originando metabolitos hidroxilados inativos; redutases convertem-na em álcoois da varfarina com atividade mínima. Muito pouca varfarina é excretada inalterada na urina.',
   'Elimination is almost entirely by hepatic metabolism, stereoselectively: S-warfarin (2 to 5 times more active) is hydroxylated mainly by CYP2C9 (a polymorphic enzyme; the *2 and *3 variant alleles reduce its clearance), as well as CYP2C19, 2C8, 2C18, 1A2 and 3A4, yielding inactive hydroxylated metabolites; reductases convert it into warfarin alcohols with minimal activity. Very little warfarin is excreted unchanged in urine.',
   'A varfarina é essencialmente absorvida na totalidade após administração oral, com pico de concentração plasmática normalmente nas primeiras 4 horas. O volume de distribuição é de cerca de 0,14 L/kg e aproximadamente 99% do fármaco liga-se às proteínas plasmáticas.',
   'Warfarin is essentially completely absorbed after oral administration, with peak plasma concentrations usually reached within the first 4 hours. The volume of distribution is about 0.14 L/kg and approximately 99% of the drug is bound to plasma proteins.',
   'A meia-vida terminal após dose única é de cerca de 1 semana; contudo, a meia-vida efetiva varia entre 20 e 60 horas (média de cerca de 40 horas). A R-warfarina tem meia-vida de 37 a 89 horas e a S-warfarina de 21 a 43 horas. Até 92% da dose oral é recuperada na urina, sobretudo como metabolitos.',
   'The terminal half-life after a single dose is about 1 week; however, the effective half-life ranges from 20 to 60 hours (mean about 40 hours). R-warfarin has a half-life of 37 to 89 hours and S-warfarin of 21 to 43 hours. Up to 92% of the oral dose is recovered in urine, mainly as metabolites.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'DailyMed/FDA (NIH/NLM) — approved Warfarin label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057'),

  ('ibuprofeno',
   'AINE não seletivo com atividade analgésica, anti-inflamatória e antipirética. Em doses baixas inibe reversivelmente a agregação plaquetária. Nas condições crónicas, a resposta terapêutica surge em dias a semanas (habitualmente até duas semanas); para dor ligeira a moderada, doses de 400 mg a cada 4 a 6 horas, sem benefício adicional comprovado acima de 400 mg.',
   'Non-selective NSAID with analgesic, anti-inflammatory and antipyretic activity. At low doses it reversibly inhibits platelet aggregation. In chronic conditions a therapeutic response appears within days to weeks (usually by two weeks); for mild to moderate pain, 400 mg every 4 to 6 hours, with no proven added benefit above 400 mg.',
   'Inibe de forma não seletiva as ciclo-oxigenases COX-1 e COX-2, reduzindo a síntese de prostaglandinas (mediadores da inflamação, da dor e da febre). A inibição da COX-1 explica os efeitos gastrointestinais e plaquetários; a inibição da COX-2 está associada aos efeitos anti-inflamatório e analgésico.',
   'Non-selectively inhibits the cyclo-oxygenases COX-1 and COX-2, reducing the synthesis of prostaglandins (mediators of inflammation, pain and fever). COX-1 inhibition accounts for the gastrointestinal and platelet effects; COX-2 inhibition underlies the anti-inflammatory and analgesic effects.',
   'Metabolizado no fígado, sobretudo por hidroxilação e carboxilação mediadas pelo CYP2C9 (com menor participação do CYP2C19 e CYP3A4), originando metabolitos inativos, e por conjugação com ácido glucurónico. Os metabolitos são eliminados principalmente por via renal.',
   'Metabolised in the liver, mainly by CYP2C9-mediated hydroxylation and carboxylation (with a minor contribution from CYP2C19 and CYP3A4), yielding inactive metabolites, and by glucuronic acid conjugation. The metabolites are eliminated mainly by the kidneys.',
   'A absorção oral é rápida e quase completa; as concentrações plasmáticas máximas são atingidas 1 a 2 horas após a toma. A presença de alimentos retarda a absorção, embora a extensão da absorção não seja significativamente alterada.',
   'Oral absorption is rapid and almost complete; peak plasma concentrations are reached 1 to 2 hours after dosing. Food slows absorption, although the extent of absorption is not significantly changed.',
   'A meia-vida de eliminação é de cerca de 2 horas (1,8 a 3,5 h), permitindo a toma a cada 4 a 6 horas nas situações de dor aguda.',
   'The elimination half-life is about 2 hours (1.8 to 3.5 h), allowing dosing every 4 to 6 hours in acute pain.',
   'PubMed — Davies NM. Clinical pharmacokinetics of ibuprofen: the first 30 years. Clin Pharmacokinet. 1998;34(2):101-154 (PMID 9515184); PharmGKB summary: https://pmc.ncbi.nlm.nih.gov/articles/PMC4355401/; DailyMed/FDA (NIH/NLM) — guia de medicação dos AINEs',
   'PubMed — Davies NM. Clinical pharmacokinetics of ibuprofen: the first 30 years. Clin Pharmacokinet. 1998;34(2):101-154 (PMID 9515184); PharmGKB summary: https://pmc.ncbi.nlm.nih.gov/articles/PMC4355401/; DailyMed/FDA (NIH/NLM) — NSAIDs Medication Guide'),

  ('ramipril',
   'Doses únicas de 2,5 a 20 mg produzem cerca de 60 a 80% de inibição da enzima de conversão da angiotensina (ECA) às 4 horas e 40 a 60% às 24 horas. Com doses múltiplas de 2 mg ou mais, a atividade da ECA plasmática cai mais de 90% às 4 horas, mantendo-se mais de 80% de inibição às 24 horas.',
   'Single doses of 2.5 to 20 mg produce about 60 to 80% inhibition of angiotensin-converting enzyme (ACE) at 4 hours and 40 to 60% at 24 hours. With multiple doses of 2 mg or more, plasma ACE activity falls by more than 90% at 4 hours, with over 80% inhibition remaining at 24 hours.',
   'O ramipril é um pró-fármaco; o ramiprilato, o seu metabolito ativo, inibe a ECA (peptidil dipeptidase), reduzindo a conversão de angiotensina I em angiotensina II e a secreção de aldosterona, com diminuição da atividade vasopressora. Como a ECA é idêntica à cininase, a inibição pode aumentar a bradicinina, contribuindo para o efeito terapêutico.',
   'Ramipril is a prodrug; ramiprilat, its active metabolite, inhibits ACE (peptidyl dipeptidase), reducing the conversion of angiotensin I to angiotensin II and aldosterone secretion, with decreased vasopressor activity. Since ACE is identical to kininase, inhibition may increase bradykinin, contributing to the therapeutic effect.',
   'É quase completamente metabolizado: a clivagem do grupo éster (sobretudo no fígado) converte-o em ramiprilato (cerca de 6 vezes mais ativo) e formam-se metabolitos inativos (dicetopiperazina e glucurónidos). Biodisponibilidade absoluta de 28% (ramipril) e 44% (ramiprilato). Cerca de 60% da dose é eliminada na urina e 40% nas fezes.',
   'Almost completely metabolised: cleavage of the ester group (mainly in the liver) converts it to ramiprilat (about 6 times more active), and inactive metabolites are formed (diketopiperazine and glucuronides). Absolute bioavailability is 28% (ramipril) and 44% (ramiprilat). About 60% of the dose is eliminated in urine and 40% in faeces.',
   'Após administração oral, o pico plasmático do ramipril é atingido em cerca de 1 hora; a extensão da absorção é de pelo menos 50 a 60%. Os alimentos reduzem a velocidade, mas não a extensão da absorção. O pico do ramiprilato ocorre 2 a 4 horas após a toma. A ligação às proteínas plasmáticas é de cerca de 73% (ramipril) e 56% (ramiprilato).',
   'After oral administration, the plasma peak of ramipril is reached within about 1 hour; the extent of absorption is at least 50 to 60%. Food reduces the rate but not the extent of absorption. Ramiprilat peaks 2 to 4 hours after dosing. Plasma protein binding is about 73% (ramipril) and 56% (ramiprilat).',
   'O ramiprilato tem uma fase de eliminação aparente com meia-vida de 9 a 18 horas e uma fase terminal prolongada (mais de 50 horas), relacionada com a ligação/dissociação do complexo ECA. Com doses múltiplas de 5 a 10 mg, a meia-vida na faixa terapêutica é de 13 a 17 horas.',
   'Ramiprilat has an apparent elimination phase with a half-life of 9 to 18 hours and a prolonged terminal phase (over 50 hours) related to the binding/dissociation of the ACE complex. With multiple 5 to 10 mg doses, the half-life within the therapeutic range is 13 to 17 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ramipril, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa',
   'DailyMed/FDA (NIH/NLM) — approved Ramipril label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa'),

  ('espironolactona',
   'Diurético poupador de potássio e anti-hipertensor, ativo por antagonismo da aldosterona. É eficaz nos estados edematosos com hiperaldosteronismo secundário (insuficiência cardíaca congestiva, cirrose hepática, síndrome nefrótica) e no hiperaldosteronismo primário. Pode ser usado isolado ou com diuréticos que atuam mais proximalmente no túbulo renal.',
   'Potassium-sparing diuretic and antihypertensive, acting through aldosterone antagonism. It is effective in oedematous states with secondary hyperaldosteronism (congestive heart failure, hepatic cirrhosis, nephrotic syndrome) and in primary hyperaldosteronism. It may be used alone or with diuretics that act more proximally in the renal tubule.',
   'Antagonista específico da aldosterona: liga-se de forma competitiva aos recetores do trocador sódio-potássio dependente da aldosterona no túbulo contornado distal, aumentando a excreção de sódio e água e retendo potássio.',
   'Specific aldosterone antagonist: binds competitively to the receptors of the aldosterone-dependent sodium-potassium exchange site in the distal convoluted tubule, increasing sodium and water excretion while retaining potassium.',
   'É rápida e extensamente metabolizado. Os metabolitos ativos incluem a canrenona (sem o enxofre da molécula original) e os compostos com enxofre TMS e HTMS, com potências relativas de cerca de um terço da espironolactona. Os metabolitos são excretados principalmente na urina e secundariamente na bílis.',
   'Rapidly and extensively metabolised. The active metabolites include canrenone (without the sulphur of the parent molecule) and the sulphur-containing TMS and HTMS, with potencies of about one third relative to spironolactone. The metabolites are excreted mainly in urine and secondarily in bile.',
   'O pico plasmático da espironolactona ocorre em média às 2,6 horas e o da canrenona às 4,3 horas. Os alimentos aumentam a biodisponibilidade em cerca de 95%, pelo que se recomenda uma rotina consistente em relação às refeições. A ligação às proteínas plasmáticas é superior a 90%.',
   'Peak plasma levels of spironolactone occur on average at 2.6 hours and of canrenone at 4.3 hours. Food increases bioavailability by about 95%, so a consistent routine with regard to meals is recommended. Plasma protein binding is over 90%.',
   'A meia-vida da espironolactona é de cerca de 1,4 horas; a dos metabolitos canrenona, TMS e HTMS é de aproximadamente 16,5, 13,8 e 15 horas, respetivamente. A meia-vida terminal pode estar aumentada na ascite cirrótica.',
   'The half-life of spironolactone is about 1.4 hours; the half-lives of the metabolites canrenone, TMS and HTMS are approximately 16.5, 13.8 and 15 hours, respectively. The terminal half-life may be increased in cirrhotic ascites.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Espironolactona, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce',
   'DailyMed/FDA (NIH/NLM) — approved Spironolactone label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce'),

  ('sotalol',
   'Antiarrítmico com propriedades de classe II (betabloqueio beta-adrenérgico não cardioseletivo) e de classe III (prolongamento da duração do potencial de ação). Com doses orais de 160 a 640 mg/dia, prolonga os intervalos QT e QTc de forma dependente da dose (em média 40 a 100 ms e 10 a 40 ms), sem alterar significativamente o QRS.',
   'Antiarrhythmic with class II (non-cardioselective beta-adrenergic blockade) and class III (action potential duration prolongation) properties. With oral doses of 160 to 640 mg/day it prolongs the QT and QTc intervals dose-dependently (mean 40 to 100 ms and 10 to 40 ms), without significantly changing the QRS.',
   'O isómero l é responsável por praticamente toda a atividade betabloqueante; ambos os isómeros partilham os efeitos antiarrítmicos de classe III. O betabloqueio é metade do máximo a cerca de 80 mg/dia e máximo entre 320 e 640 mg/dia; efeitos de classe III significativos surgem a partir de 160 mg/dia. Não tem atividade agonista parcial nem estabilizadora de membrana.',
   'The l-isomer accounts for virtually all of the beta-blocking activity; both isomers share the class III antiarrhythmic effects. Beta-blockade is half maximal at about 80 mg/day and maximal between 320 and 640 mg/day; significant class III effects appear from 160 mg/day. It has no partial agonist or membrane-stabilising activity.',
   'Não é metabolizado e não inibe nem induz as enzimas do citocromo P450. É eliminado predominantemente por via renal na forma inalterada (filtração glomerular e, em pequena parte, secreção tubular), pelo que são necessárias doses menores na insuficiência renal.',
   'Not metabolised and does not inhibit or induce cytochrome P450 enzymes. Eliminated predominantly unchanged by the kidneys (glomerular filtration and, to a small degree, tubular secretion), so lower doses are required in renal impairment.',
   'Biodisponibilidade oral de 90 a 100%; o pico plasmático é atingido 2,5 a 4 horas após a administração e o estado estacionário em 2 a 3 dias. Não se liga às proteínas plasmáticas. A toma com uma refeição padrão reduz a absorção em cerca de 20%.',
   'Oral bioavailability of 90 to 100%; peak plasma concentrations are reached 2.5 to 4 hours after dosing and steady state within 2 to 3 days. It does not bind to plasma proteins. Administration with a standard meal reduces absorption by about 20%.',
   'A meia-vida média de eliminação é de cerca de 12 horas. A insuficiência renal prolonga a meia-vida (até 69 horas em doentes anúricos), exigindo ajuste de dose ou de intervalo com base na depuração da creatinina.',
   'The mean elimination half-life is about 12 hours. Renal impairment prolongs the half-life (up to 69 hours in anuric patients), requiring dose or interval adjustment based on creatinine clearance.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sotalol, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244',
   'DailyMed/FDA (NIH/NLM) — approved Sotalol label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244'),

  ('furosemida',
   'Diurético de alça de alta eficácia. O início da diurese após administração intravenosa ocorre em cerca de 5 minutos, com efeito máximo na primeira meia hora; a duração do efeito diurético é de aproximadamente 2 horas.',
   'Highly effective loop diuretic. Diuresis begins about 5 minutes after intravenous administration, with peak effect within the first half hour; the duration of the diuretic effect is approximately 2 hours.',
   'Inibe principalmente a reabsorção de sódio e cloreto na ansa de Henle (e também nos túbulos proximal e distal), de forma independente da anidrase carbónica e da aldosterona. Este local de ação único confere a sua alta eficácia.',
   'Inhibits mainly the reabsorption of sodium and chloride in the loop of Henle (and also in the proximal and distal tubules), independently of carbonic anhydrase and aldosterone. This unique site of action accounts for its high efficacy.',
   'A principal (ou única) via de biotransformação no homem é a formação do glucurónido da furosemida. Uma parte significativa da dose é eliminada na forma inalterada pela urina.',
   'The main (or only) biotransformation pathway in man is the formation of furosemide glucuronide. A significant proportion of the dose is eliminated unchanged in the urine.',
   'A furosemida liga-se extensamente às proteínas plasmáticas, sobretudo à albumina (91 a 99% para concentrações de 1 a 400 mcg/ml). A biodisponibilidade entérica relativamente à via intravenosa é de cerca de 79%.',
   'Furosemide is extensively bound to plasma proteins, mainly albumin (91 to 99% at concentrations of 1 to 400 mcg/ml). Enteral bioavailability relative to the intravenous route is about 79%.',
   'A meia-vida terminal é de aproximadamente 2 horas. Nos idosos, a ligação à albumina pode estar reduzida, com depuração renal menor e efeito diurético inicial diminuído.',
   'The terminal half-life is approximately 2 hours. In the elderly, albumin binding may be reduced, with lower renal clearance and a decreased initial diuretic effect.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Furosemida, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6d9caaab-d874-4cf1-b9fe-408452a18998',
   'DailyMed/FDA (NIH/NLM) — approved Furosemide label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6d9caaab-d874-4cf1-b9fe-408452a18998')
) AS v(
  slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
  metabolism_pt, metabolism_en, absorption_pt, absorption_en,
  half_life_pt, half_life_en, source_pt, source_en)
  ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
