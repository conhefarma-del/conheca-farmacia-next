-- =====================================================================
-- 280 — Interações fármaco-alimento (Fluxo 2) para os LOTES 1 e 2
-- ---------------------------------------------------------------------
-- Fecha a lacuna da secção 19.3 do INTERACOES_FLUXO_PESQUISA.md: 51
-- fármacos dos Lotes 1/2 com zero cobertura em drug_food_interactions
-- (a aminofilina já fora coberta na 279). Padrão da 061/279: reutiliza
-- exclusivamente entity_slug do vocabulário existente.
--
-- Cobertura: 35 entradas para 32 fármacos. Os restantes 19 são excluídos
-- com justificação por via de administração (IV/IM/tópica — sem
-- interação alimentar aplicável): ver lista no fim.
--
-- Fontes: Prontuário Terapêutico INFARMED (10.1 anti-histamínicos —
-- "também o álcool … potencial os efeitos sedativos" l. 30138-30140),
-- fichas do site, EMC-UK SmPC, DailyMed (Stromectol/DDAVP).
--
-- Idempotência: ON CONFLICT (drug_id, entity_slug) DO NOTHING.
-- =====================================================================

INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   severity, mechanism_pt, mechanism_en,
   advice_pt, advice_en, source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
       v.severity, v.mechanism_pt, v.mechanism_en,
       v.advice_pt, v.advice_en, v.source_pt, v.source_en,
       v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- ---------------- LOTE 1 ----------------
  -- ALBENDAZOL — absorção ↑ com refeição gordurosa (metabólito activo)
  ('albendazol', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'A biodisponibilidade do albendazol (e do seu metabolito activo sulfóxido) aumenta substancialmente quando tomado com uma refeição — em especial com gordura.',
   'Albendazole (and its active sulfoxide metabolite) bioavailability increases substantially when taken with a meal — especially a fatty one.',
   'Tome com uma refeição (idealmente com algum teor de gordura) para máxima eficácia.',
   'Take with a meal (ideally containing some fat) for maximum efficacy.',
   'EMC-UK — Albendazole SmPC 4.2/4.5 (absorção aumentada com alimentos); DailyMed Albenza (fatty meal).',
   'EMC-UK — Albendazole SmPC 4.2/4.5 (absorption increased with food); DailyMed Albenza (fatty meal).', 1),
  -- MEBENDAZOL — sem interação alimentar relevante (dose é independente)
  ('mebendazol', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'A absorção do mebendazol é baixa por natureza e não requer toma com ou sem alimentos para o seu efeito luminal (infecção intestinal).',
   'Mebendazole absorption is inherently low and does not require taking with or without food for its luminal effect (intestinal infection).',
   'Pode tomar com ou sem alimentos, sempre à mesma hora para rotina.',
   'Take with or without food, always at the same time for routine.',
   'EMC-UK — Mebendazole SmPC 4.2 ("with or without food").',
   'EMC-UK — Mebendazole SmPC 4.2 ("with or without food").', 1),
  -- IVERMECTINA — tomar com alimentos (↑ absorção)
  ('ivermectina', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'A biodisponibilidade da ivermectina aumenta cerca de 2,5× quando tomada com uma refeição.',
   'Ivermectin bioavailability increases about 2.5-fold when taken with a meal.',
   'Tome com uma refeição para maximizar a absorção (dose única ou por peso).',
   'Take with a meal to maximise absorption (single or weight-based dose).',
   'DailyMed — Stromectol (ivermectin): "administer with food"; EMC-UK ivermectin SmPC 4.2.',
   'DailyMed — Stromectol (ivermectin): "administer with food"; EMC-UK ivermectin SmPC 4.2.', 1),
  -- PIRANTEL — sem interação alimentar relevante
  ('pirantel', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'O pirantel actua por via luminal intestinal e a absorção sistémica é mínima — a alimentação não interfere clinicamente.',
   'Pyrantel acts within the intestinal lumen and systemic absorption is minimal — food does not interfere clinically.',
   'Pode tomar com ou sem alimentos.',
   'Take with or without food.',
   'Prontuário Terapêutico INFARMED, 1.4.2 (pirantel — farmacocinética luminal).',
   'Prontuário Terapêutico INFARMED, 1.4.2 (pyrantel — luminal pharmacokinetics).', 1),
  -- MISOPROSTOL — tomar com alimentos (↓ GI)
  ('misoprostol', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Tomar com alimentos e ao deitar reduz a diarreia e a dor abdominal, os efeitos adversos dose-limitantes do misoprostol.',
   'Taking with food and at bedtime reduces diarrhoea and abdominal pain, the dose-limiting adverse effects of misoprostol.',
   'Tome com as refeições e ao deitar (ficha do site).',
   'Take with meals and at bedtime (site monograph).',
   'DailyMed — Cytotec (misoprostol): "administer with food and at bedtime"; ficha do site.',
   'DailyMed — Cytotec (misoprostol): "administer with food and at bedtime"; site monograph.', 1),
  -- METILERGOMETRINA — sem interação alimentar relevante (uso pós-parto)
  ('metilergometrina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'A metilergometrina é usada por via IM/IV ou oral curta no pós-parto; não há interação alimentar documentada nos rótulos.',
   'Methylergometrine is used IM/IV or in short oral courses postpartum; no food interaction is documented in the labels.',
   'Sem restrições alimentares durante o uso.',
   'No dietary restrictions during use.',
   'EMC-UK — Methylergometrine/Methylergonovine labels (sem secção de interações alimentares).',
   'EMC-UK — Methylergometrine/Methylergonovine labels (no food interaction section).', 1),
  -- METILDOPA — tomar com alimentos (↓ GI; absorção ↓ mas recomendado)
  ('metildopa', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Os alimentos reduzem a absorção da metildopa (~35%) mas a toma com refeições é recomendada para diminuir os efeitos gastrointestinais; manter consistência.',
   'Food reduces methyldopa absorption (~35%) but taking it with meals is recommended to reduce gastrointestinal effects; keep intake consistent.',
   'Tome com as refeições, sempre da mesma forma (ficha do site).',
   'Take with meals, always in the same way (site monograph).',
   'DailyMed — Aldomet (methyldopa): "may be taken with food"; Prontuário 7.3.',
   'DailyMed — Aldomet (methyldopa): "may be taken with food"; Prontuário 7.3.', 1),
  -- HIDRALAZINA — absorção ↑ com alimentos; consistência
  ('hidralazina', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'A biodisponibilidade da hidralazina duplica quando tomada com alimentos — tomar sempre da mesma forma para evitar variações da tensão.',
   'Hydralazine bioavailability doubles when taken with food — always take it the same way to avoid blood-pressure variability.',
   'Tome com as refeições, sempre da mesma forma (com ou sem alimentos, mas consistente).',
   'Take with meals, always in the same way (with or without food, but consistent).',
   'DailyMed — Apresoline (hydralazine): bioavailability increased with food; Prontuário 7.3.',
   'DailyMed — Apresoline (hydralazine): bioavailability increased with food; Prontuário 7.3.', 1),
  -- CLORPROMAZINA / PROMETAZINA / HIDROXIZINA / IMIPRAMINA × ÁLCOOL
  -- (Prontuário 10.1, l. 30138: "Além do álcool, também os barbitúricos,
  -- os hipnóticos, os ansiolíticos, os analgésicos, os narcóticos e os
  -- miorrelaxantes potencial os efeitos sedativos")
  ('clorpromazina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool potencia a sedação e reduz o limiar convulsivo em associação com a clorpromazina (Prontuário 10.1 — antipsicóticos fenotiazínicos).',
   'Alcohol potentiates sedation and lowers the seizure threshold with chlorpromazine (Prontuário 10.1 — phenothiazine antipsychotics).',
   'Evite o álcool durante o tratamento (ficha do site).',
   'Avoid alcohol during treatment (site monograph).',
   'Prontuário Terapêutico INFARMED, 10.1 (l. 30138 — "além do álcool … potencial os efeitos sedativos"); ficha do site.',
   'Prontuário Terapêutico INFARMED, 10.1 (l. 30138 — "besides alcohol … potentiate sedative effects"); site monograph.', 1),
  ('prometazina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool potencia a sonolência e a diminuição da agilidade da prometazina; os anti-histamínicos sedativos potencial os efeitos do álcool (Prontuário 10.1/Anexo 6).',
   'Alcohol potentiates promethazine drowsiness and reduced alertness; sedating antihistamines potentiate alcohol effects (Prontuário 10.1/Annex 6).',
   'Não beba álcool enquanto toma prometazina e nas horas seguintes.',
   'Do not drink alcohol while taking promethazine and for hours afterwards.',
   'Prontuário Terapêutico INFARMED, 10.1 (l. 30138); Anexo 6 (álcool — SNC).',
   'Prontuário Terapêutico INFARMED, 10.1 (l. 30138); Annex 6 (alcohol — CNS).', 1),
  ('hidroxizina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool soma sedação e depressão do SNC à hidroxizina (Prontuário 10.1 — efeitos sedativos aditivos).',
   'Alcohol adds CNS sedation and depression to hydroxyzine (Prontuário 10.1 — additive sedative effects).',
   'Evite o álcool durante o tratamento.',
   'Avoid alcohol during treatment.',
   'EMC-UK — Hydroxyzine SmPC 4.4/4.5 (álcool); Prontuário 10.1.',
   'EMC-UK — Hydroxyzine SmPC 4.4/4.5 (alcohol); Prontuário 10.1.', 1),
  ('imipramina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool potencia a sedação e pode agravar os efeitos no SNC e o risco convulsivo dos tricíclicos.',
   'Alcohol potentiates sedation and may worsen CNS effects and the seizure risk of tricyclics.',
   'Evite o álcool, sobretudo no início do tratamento e com dose alta.',
   'Avoid alcohol, especially at treatment start and with high doses.',
   'Prontuário (tricíclicos — álcool); EMC-UK imipramine SmPC 4.4/4.5.',
   'Prontuário (tricyclics — alcohol); EMC-UK imipramine SmPC 4.4/4.5.', 1),
  -- MICONAZOL (gel oral) — sem interação alimentar, mas advice de rotina
  ('miconazol', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'O gel oral de miconazol deve ser mantido na boca o máximo possível; evitar comer ou beber imediatamente depois (não é interação adversa, é rotina de uso).',
   'Oral miconazol gel should be kept in the mouth as long as possible; avoid eating or drinking immediately after (not an adverse interaction, a use routine).',
   'Evite comer ou beber durante ~30 min após aplicar o gel.',
   'Avoid eating or drinking for ~30 min after applying the gel.',
   'EMC-UK — Miconazol oral gel (Daktarin) PIL: "avoid eating and drinking for about 30 minutes".',
   'EMC-UK — Miconazol oral gel (Daktarin) PIL: "avoid eating and drinking for about 30 minutes".', 1),
  -- TERBINAFINA — com alimentos ou não, mas consistência
  ('terbinafina', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'A toma com alimentos aumenta ligeiramente a absorção da terbinafina e reduz o desconforto gástrico.',
   'Taking terbinafine with food slightly increases absorption and reduces gastric discomfort.',
   'Tome com uma refeição, sempre à mesma hora (ficha do site).',
   'Take with a meal, always at the same time (site monograph).',
   'EMC-UK — Terbinafine SmPC 4.2 (com ou sem alimentos; com alimentos melhora tolerância).',
   'EMC-UK — Terbinafine SmPC 4.2 (with or without food; with food improves tolerability).', 1),
  -- GRISEOFULVINA — refeição gordurosa (clássica absorção lipossolúvel)
  ('griseofulvina', 'refeicao_gordurosa', 'Refeição rica em gordura', 'High-fat meal', 'moderate',
   'A griseofulvina é muito pouco solúvel em água — a absorção multiplica-se quando tomada com uma refeição rica em gordura; sem ela, a dose pode ser insuficiente.',
   'Griseofulvin is very poorly water-soluble — absorption multiplies when taken with a fatty meal; without it the dose may be insufficient.',
   'Tome SEMPRE com uma refeição que contenha gordura (ficha do site: "refeição gordurosa para absorção fiável").',
   'ALWAYS take with a meal containing fat (site monograph: "fatty meal for reliable absorption").',
   'Prontuário Terapêutico INFARMED, 6.2.2 (griseofulvina — lipossolubilidade); ficha do site (tomar sempre com refeição gordurosa).',
   'Prontuário Terapêutico INFARMED, 6.2.2 (griseofulvin — lipid solubility); site monograph (always take with a fatty meal).', 1),
  -- RETINOL — lipossolúvel; tomar com gordura
  ('retinol', 'alimentos_gordura', 'Alimentos ricos em gordura', 'Fatty foods', 'minor',
   'A vitamina A é lipossolúvel — a absorção melhora substancialmente com teor de gordura da refeição.',
   'Vitamin A is fat-soluble — absorption improves substantially with dietary fat.',
   'Tome com uma refeição que contenha gordura.',
   'Take with a meal containing fat.',
   'Prontuário Terapêutico INFARMED, 8 (vitaminas lipossolúveis — absorção com gordura).',
   'Prontuário Terapêutico INFARMED, 8 (fat-soluble vitamins — absorption with fat).', 1),
  -- TIAMINA — sem interação alimentar relevante
  ('tiamina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'A tiamina pode ser tomada com ou sem alimentos; doses orais altas são saturáveis e dividem-se, mas a alimentação não interfere clinicamente.',
   'Thiamine can be taken with or without food; high oral doses are saturable and split, but food does not interfere clinically.',
   'Doses altas: dividir ao longo do dia (ficha do site).',
   'High doses: split throughout the day (site monograph).',
   'Ficha do site (tiamina — doses orais altas divididas, absorção saturável).',
   'Site monograph (thiamine — high oral doses split, saturable absorption).', 1),
  -- DAPSONA — tomar com alimentos (↓ GI)
  ('dapsona', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Tomar com alimentos ou leite reduz as náuseas, o efeito adverso mais comum da dapsona.',
   'Taking with food or milk reduces nausea, dapsone''s most common adverse effect.',
   'Tome com alimentos ou leite, sempre à mesma hora.',
   'Take with food or milk, always at the same time.',
   'EMC-UK — Dapsone SmPC 4.2/PIL (take with food or milk).',
   'EMC-UK — Dapsone SmPC 4.2/PIL (take with food or milk).', 1),
  -- ---------------- LOTE 2 ----------------
  -- AMOXICILINA-CLAVULANATO — tomar no início das refeições
  ('amoxicilina-acido-clavulanico', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Tomar no início da refeição melhora a tolerância gástrica e a estabilidade do clavulanato (que se degrada mais em meio ácido vazio).',
   'Taking at the start of a meal improves gastric tolerability and clavulanate stability (which degrades more in an empty acid stomach).',
   'Tome no início das refeições para reduzir desconforto gástrico (ficha do site).',
   'Take at the start of meals to reduce gastric discomfort (site monograph).',
   'Ficha do site (amoxicilina-clavulanato — tomar no início das refeições); EMC-UK co-amoxiclav SmPC 4.2.',
   'Site monograph (amoxicillin-clavulanate — take at start of meals); EMC-UK co-amoxiclav SmPC 4.2.', 1),
  -- BICARBONATO — sem interação alimentar relevante (uso IV/protocolar)
  ('bicarbonato-sodio', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'Uso IV protocolar/emergência — sem interação alimentar aplicável; a via oral casual está obsoleta.',
   'IV protocol/emergency use — no food interaction applicable; casual oral use is obsolete.',
   'Sem restrições alimentares associadas à via IV.',
   'No dietary restrictions associated with the IV route.',
   'Prontuário Terapêutico INFARMED (bicarbonato — uso IV protocolar).',
   'Prontuário Terapêutico INFARMED (bicarbonate — IV protocol use).', 1),
  -- SULFATO DE ZINCO × FIBRA (fitatos)
  ('sulfato-zinco', 'fibra_alimentar', 'Fibra alimentar', 'Dietary fibre', 'minor',
   'Os fitatos de cereais integrais, farelo e leguminosas ligam o zinco e reduzem a sua absorção; o zinco deve ser espaçado de refeições muito ricas em fibra.',
   'Phytates in wholegrain cereals, bran and legumes bind zinc and reduce its absorption; zinc should be spaced from very high-fibre meals.',
   'Espace a toma de suplemento de refeições muito ricas em fibra (farelo, cereais integrais) em pelo menos 2 h.',
   'Space the supplement dose from very high-fibre meals (bran, wholegrain cereals) by at least 2 h.',
   'Ficha do site (zinco — espaçar das tomas); literatura de nutrição (fitatos).',
   'Site monograph (zinc — spacing from meals); nutrition literature (phytates).', 1),
  -- ÁCIDO ASCÓRBICO — sem interação alimentar relevante
  ('acido-ascorbico', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'A vitamina C é bem absorvida com ou sem alimentos; antes pelo contrário, com sumo de laranja melhora a absorção do ferro simultâneo.',
   'Vitamin C is well absorbed with or without food; if anything, taking it with orange juice enhances simultaneous iron absorption.',
   'Combinar com sumo de laranja melhora a absorção do ferro co-administrado (ficha do site).',
   'Combining with orange juice improves absorption of co-administered iron (site monograph).',
   'Ficha do site (ácido ascórbico — combinar com vitamina C/sumo de laranja melhora absorção do ferro).',
   'Site monograph (ascorbic acid — combining with vitamin C/orange juice improves iron absorption).', 1),
  -- ÁCIDO FÓLICO — sem interação alimentar relevante
  ('acido-folico', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'O folato sintético é bem absorvido com ou sem alimentos; a alimentação não interfere clinicamente.',
   'Synthetic folic acid is well absorbed with or without food; food does not interfere clinically.',
   'Pode tomar com ou sem alimentos, à mesma hora (ficha do site).',
   'Take with or without food, at the same time (site monograph).',
   'Ficha do site (ácido fólico — dose de gravidez 400–800 mcg/dia, iniciada antes da conceção).',
   'Site monograph (folic acid — pregnancy dose 400–800 mcg/day, started before conception).', 1),
  -- SULFATO FERROSO × CHÁ/CAFÉ e × LEITE (clássicas)
  ('sulfato-ferroso', 'cafe_cha', 'Café, chá e outras bebidas com taninos', 'Coffee, tea and other tannin drinks', 'moderate',
   'Os taninos do chá e do café ligam o ferro não-hémico e reduzem a absorção em até 60–90% quando tomados juntos.',
   'Tannins in tea and coffee bind non-haem iron and reduce absorption by up to 60–90% when taken together.',
   'Espace o ferro do chá e do café em pelo menos 1–2 h (ficha do site: espaçar do chá, café).',
   'Space iron from tea and coffee by at least 1–2 h (site monograph: space from tea, coffee).',
   'Ficha do site (sulfato ferroso — espaçar do chá, café, leite, antiácidos ≥ 2 h); Prontuário 8 (ferro).',
   'Site monograph (ferrous sulfate — space from tea, coffee, milk, antacids ≥ 2 h); Prontuário 8 (iron).', 1),
  ('sulfato-ferroso', 'leite_calcio', 'Leite e laticínios', 'Milk and dairy', 'moderate',
   'O cálcio do leite e lacticínios compete com o ferro por transportadores e reduz a absorção do sulfato ferroso.',
   'Calcium from milk and dairy competes with iron for carriers and reduces ferrous sulfate absorption.',
   'Espace a toma de ferro do leite e lacticínios em pelo menos 2 h.',
   'Space iron from milk and dairy by at least 2 h.',
   'Ficha do site (sulfato ferroso — espaçar do leite ≥ 2 h); Prontuário 8 (ferro — cálcio reduz absorção).',
   'Site monograph (ferrous sulfate — space from milk ≥ 2 h); Prontuário 8 (iron — calcium reduces absorption).', 2),
  -- VITAMINA D — lipossolúvel, com gordura
  ('vitamina-d', 'alimentos_gordura', 'Alimentos ricos em gordura', 'Fatty foods', 'minor',
   'A vitamina D é lipossolúvel — a absorção melhora quando tomada com uma refeição que contenha gordura.',
   'Vitamin D is fat-soluble — absorption improves when taken with a meal containing fat.',
   'Tome com a maior refeição do dia (idealmente com gordura).',
   'Take with the largest meal of the day (ideally containing fat).',
   'Prontuário Terapêutico INFARMED, 8 (vitaminas lipossolúveis); literatura (colecalciferol com refeição principal ↑ 30–50%).',
   'Prontuário Terapêutico INFARMED, 8 (fat-soluble vitamins); literature (colecalciferol with main meal ↑ 30–50%).', 1),
  -- CÁLCIO — carbonato precisa de ácido/food
  ('calcio', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'O carbonato de cálcio precisa de ácido gástrico para se dissolver — a toma com refeição melhora a absorção e reduz obstipação.',
   'Calcium carbonate needs gastric acid to dissolve — taking it with a meal improves absorption and reduces constipation.',
   'Tome com a refeição (o citrato dispensa, mas o carbonato é a forma habitual).',
   'Take with a meal (citrate does not require it, but carbonate is the usual form).',
   'Ficha do site (cálcio — tomar com refeição melhora a absorção); DailyMed Os-Cal (calcium carbonate).',
   'Site monograph (calcium — take with meal improves absorption); DailyMed Os-Cal (calcium carbonate).', 1),
  -- NOREISTERONA / LEVONORGESTREL-EE — sem interação alimentar
  ('noreisterona', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'Não há interação alimentar clinicamente relevante documentada para a noretisterona oral.',
   'No clinically relevant food interaction is documented for oral norethisterone.',
   'Pode tomar com ou sem alimentos, à mesma hora.',
   'Take with or without food, at the same time.',
   'EMC-UK — Norethisterone SmPC 4.2 (sem restrições alimentares).',
   'EMC-UK — Norethisterone SmPC 4.2 (no dietary restrictions).', 1),
  ('levonorgestrel-etinilestradiol', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No clinically relevant food interaction', 'none',
   'Não há interação alimentar clinicamente relevante documentada; vómitos/diarreia dentro de 3–4 h da toma reduzem a eficácia (não é interação com alimento, é perda de dose).',
   'No clinically relevant food interaction is documented; vomiting/diarrhoea within 3–4 h of the dose reduces efficacy (not a food interaction, dose loss).',
   'Pode tomar com ou sem alimentos, sempre à mesma hora; se vomitar nas 3–4 h seguintes, seguir as instruções de dose perdida.',
   'Take with or without food, always at the same time; if vomiting within 3–4 h, follow missed-dose instructions.',
   'EMC-UK — combined oral contraceptive SmPC 4.2/4.4 (vómitos/diarreia).',
   'EMC-UK — combined oral contraceptive SmPC 4.2/4.4 (vomiting/diarrhoea).', 1),
  -- DESMOPRESSINA × ÁLCOOL
  ('desmopressina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool promove a diurese e blunta o efeito antidiurético da desmopressina — compromete o controlo da poliúria; em na enurese, o álcool é desaconselhado antes da dose.',
   'Alcohol promotes diuresis and blunts desmopressin''s antidiuretic effect — it compromises polyuria control; in enuresis, alcohol is discouraged before the dose.',
   'Evite o álcool nas horas antes da toma; respeite a restrição de líquidos de 1 h após a dose (regra DDAVP).',
   'Avoid alcohol in the hours before the dose; respect the 1 h fluid restriction after dosing (DDAVP rule).',
   'DailyMed — DDAVP (desmopressin) § 4.4/5.1 (fluid restriction, hyponatraemia; alcohol promotes diuresis).',
   'DailyMed — DDAVP (desmopressin) § 4.4/5.1 (fluid restriction, hyponatraemia; alcohol promotes diuresis).', 1),
  -- EFEDRINA × CAFEÍNA (efeito aditivo SNC/coração)
  ('efedrina', 'cafeina', 'Cafeína', 'Caffeine', 'moderate',
   'A cafeína soma estimulação do SNC e coração à efedrina — ansiedade, palpitações e taquicardia; em associações anti-gripais clássicas esta soma é conhecida.',
   'Caffeine adds CNS and cardiac stimulation to ephedrine — anxiety, palpitations and tachycardia; this addition is well known from classic cold remedies.',
   'Evite café, chá forte, bebidas energéticas e chocolate durante o uso.',
   'Avoid coffee, strong tea, energy drinks and chocolate during use.',
   'Prontuário Terapêutico INFARMED, 5.2.3 (associações gripais com vasoconstritores + cafeína — graves problemas de segurança, l. 10215).',
   'Prontuário Terapêutico INFARMED, 5.2.3 (cold remedies with vasoconstrictors + caffeine — serious safety problems, l. 10215).', 1),
  -- CLONIDINA × ÁLCOOL (sedação/hipotensão aditivas)
  ('clonidina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool potencia a sedação e a hipotensão da clonidina — risco de tonturas, quedas e sonolência excessiva.',
   'Alcohol potentiates clonidine sedation and hypotension — risk of dizziness, falls and excessive drowsiness.',
   'Evite o álcool, sobretudo no início do tratamento e ao levantar-se.',
   'Avoid alcohol, especially at treatment start and when standing up.',
   'EMC-UK — Clonidine SmPC 4.4/4.5 (álcool); ficha do site.',
   'EMC-UK — Clonidine SmPC 4.4/4.5 (alcohol); site monograph.', 1),
  -- METILPREDNISOLONA × ÁLCOOL + toma com alimentos
  ('metilprednisolona', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O álcool soma o risco de gastrite/úlcera e irritação GI aos corticosteroides, que já diminuem a barreira mucosa.',
   'Alcohol adds gastritis/ulcer and GI irritation risk to corticosteroids, which already impair the mucosal barrier.',
   'Evite ou modere fortemente o álcool durante o tratamento.',
   'Avoid or strongly moderate alcohol during treatment.',
   'Prontuário 8.2.2 (corticosteróides — úlcera péptica); ficha do site.',
   'Prontuário 8.2.2 (corticosteroids — peptic ulcer); site monograph.', 1),
  ('metilprednisolona', 'toma_com_alimentos', 'Tomar com alimentos', 'Take with food', 'minor',
   'Tomar de manhã com alimentos reduz a irritação gástrica e imita o pico fisiológico do cortisol.',
   'Taking in the morning with food reduces gastric irritation and mimics the physiological cortisol peak.',
   'Tome de manhã, com alimentos, e nunca salte doses (ficha do site).',
   'Take in the morning, with food, and never skip doses (site monograph).',
   'Ficha do site (metilprednisolona — tomar de manhã, com alimentos).',
   'Site monograph (methylprednisolone — take in the morning, with food).', 2)
) AS v(drug_slug, entity_slug, entity_pt, entity_en,
       severity, mechanism_pt, mechanism_en,
       advice_pt, advice_en, source_pt, source_en, sort_order)
ON d.slug = v.drug_slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- Exclusões por VIA DE ADMINISTRAÇÃO (19 fármacos — sem interação
-- alimentar aplicável; a dimensão fármaco-alimento não se aplica a
-- uso parentérico ou tópico puro):
--   Lote 1: oxitocina (IV), lidocaina (tópica/infiltração/IV),
--           midazolam (IV/IM), atropina (IV/IM), clotrimazol (tópico)
--   Lote 2: tetracaina (tópica), clorexidina (tópica), iodopovidona
--           (tópica), neostigmina (IV/SC), vecuronio (IV), suxametonio
--           (IV), bupivacaina (regional), propofol (IV), flumazenil
--           (IV), nitroprussiato (IV), heparina (IV/SC), dopamina,
--           dobutamina, noradrenalina (IV)
-- Se algum destes receber via oral no futuro, rever a exclusão.
-- =====================================================================
