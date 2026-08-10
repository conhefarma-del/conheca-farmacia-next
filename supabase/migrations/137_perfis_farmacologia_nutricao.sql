-- =====================================================================
-- 137 — Perfil completo + farmacologia dos 9 fármacos da 069 (nutrição)
-- ---------------------------------------------------------------------
-- Os 9 fármacos de nutrição/electrólitos criados na 069 (ácido ascórbico,
-- aminoácidos, carbonato de cálcio, cloreto de potássio, colecalciferol,
-- emulsão lipídica, glicose, sulfato de magnésio, zinco) nunca receberam
-- perfil (drug_profiles) nem farmacologia (drug_pharmacology). Com esta
-- migração, os 191 fármacos ativos ficam todos com perfil + farmacologia.
--
-- Fontes (citadas por linha):
--   • 7 fármacos: secções INDICATIONS AND USAGE, CONTRAINDICATIONS, WARNINGS
--     AND PRECAUTIONS, ADVERSE REACTIONS + secção 12 CLINICAL PHARMACOLOGY
--     dos rótulos aprovados DailyMed (setIDs validados na API):
--       - TrophAmine 10% (aminoácidos)         cb6d23ff-3ec5-445a-acbe-f88fd57949bf
--       - TUMS Ultra (carbonato de cálcio)     348d3dfa-6a52-4583-96e3-83c4bf2df45b
--       - KCl ER (cloreto de potássio)         16c775e4-0dd8-4e9f-b2bf-dd2b639374cf
--       - Intralipid (emulsão lipídica)        61e025f1-a38e-4af2-9e18-13ea12977cf5
--       - Dextrose 50% (glicose)               4ed365da-4e62-4329-c1b9-c197ab4fb6e1
--       - MgSO4 injetável (sulfato de magnésio) a5a9f565-639c-4b22-b9e5-718bac7cfcf3
--       - Zinc Chloride injetável (zinco)      2bd646d2-2a2a-4376-8da0-c7f08b0511ac
--   • ácido ascórbico e colecalciferol: sem rótulo DailyMed mono-ingrediente
--     com secções clínicas (OTC/suplemento) — perfil e farmacologia autorados
--     a partir do Prontuário Terapêutico (INFARMED, 11.ª ed., 2012; secções
--     9.6.3/11.3.1.1 Vitamina D e 11.3.1.3/11.3.2.1 Vitaminas e sais minerais)
--     e de MedlinePlus (NIH/NLM), com a regra do padrão 088 (conteúdo
--     autoral, nunca copiado).
-- Conteúdo autoral (não copiado), ancorado nos números das fontes.
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING — reaplicar é seguro.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 069 → 137.
-- =====================================================================

-- =====================================================================
-- Perfis (drug_profiles)
-- =====================================================================

INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   indications_pt, indications_en, side_effects_pt, side_effects_en,
   precautions_pt, precautions_en, source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.indications_pt, v.indications_en, v.side_effects_pt, v.side_effects_en,
       v.precautions_pt, v.precautions_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('acido_ascorbico',
   E'A vitamina C (ácido ascórbico) é uma vitamina hidrossolúvel que o organismo não consegue produzir: tem de vir da alimentação ou de suplementos. É essencial para a formação do colagénio (a "cola" dos tecidos), para a cicatrização, para a absorção do ferro e para a defesa contra infeções. A carência grave causa escorbuto, hoje raro, mas deficiências ligeiras podem surgir em fumadores, idosos e pessoas com alimentação pobre em fruta e vegetais.',
   E'Vitamin C (ascorbic acid) is a water-soluble vitamin the body cannot make on its own: it must come from food or supplements. It is essential for collagen formation (the "glue" of tissues), wound healing, iron absorption and immune defence. Severe deficiency causes scurvy, now rare, but mild deficiencies can occur in smokers, older people and those with a diet poor in fruit and vegetables.',
   E'Vitamina hidrossolúvel essencial à síntese do colagénio e do material intercelular; cofator de hidroxilases (prolil e lisil-hidroxilase) na maturação do colagénio e na síntese de carnitina e catecolaminas. A dieta é a fonte habitual (incapacidade de síntese por ausência da gulonolactona oxidase). Dose de manutenção habitual 60–100 mg/dia; doses de 1–2 g/dia são bem toleradas, mas acima de 2 g/dia associam-se a efeitos gastrintestinais.',
   E'Water-soluble vitamin essential for collagen and intercellular material synthesis; cofactor of hydroxylases (prolyl and lysyl hydroxylase) in collagen maturation and in carnitine and catecholamine synthesis. Diet is the usual source (inability to synthesise due to absence of gulonolactone oxidase). Usual maintenance dose 60–100 mg/day; doses of 1–2 g/day are well tolerated, but above 2 g/day gastrointestinal effects occur.',
   E'• Deficiência em vitamina C (escorbuto e estados carenciais)\\n• Acidificante urinário\\n• Suplemento durante a gravidez e o aleitamento\\n• Adjuvante na anemia ferropénica (potencia a absorção de ferro oral, 30 mg para 200 mg de ferro)',
   E'• Vitamin C deficiency (scurvy and deficiency states)\\n• Urinary acidifier\\n• Supplement during pregnancy and breastfeeding\\n• Adjunct in iron-deficiency anaemia (enhances oral iron absorption, 30 mg per 200 mg of iron)',
   E'• Em doses elevadas: diarreia, obstrução gastrintestinal, esofagite, hemólise, hiperoxalúria e insuficiência renal\\n• Irritação gástrica com doses altas\\n• Cálculos renais de oxalato em doentes predispostos',
   E'• At high doses: diarrhoea, gastrointestinal obstruction, oesophagitis, haemolysis, hyperoxaluria and renal failure\\n• Gastric irritation with high doses\\n• Oxalate kidney stones in predisposed patients',
   E'• Contraindicado em hemocromatose, talassemia, anemia sideroblástica, cálculos renais pré-existentes e défice de G-6-PD\\n• Pode interferir com testes laboratoriais (glicose urinária, sangue oculto nas fezes)\\n• Interações: antiácidos com alumínio, AAS em doses elevadas, desferroxamina, estrogénios, aminoglicosídeos e varfarina',
   E'• Contraindicated in haemochromatosis, thalassaemia, sideroblastic anaemia, pre-existing kidney stones and G-6-PD deficiency\\n• May interfere with laboratory tests (urinary glucose, faecal occult blood)\\n• Interactions: aluminium-containing antacids, high-dose aspirin, deferoxamine, oestrogens, aminoglycosides and warfarin',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Vitamina C, 11.3.1.3; MedlinePlus (NIH/NLM) — Ascorbic acid: https://medlineplus.gov/druginfo/meds/a601110.html',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Vitamin C, 11.3.1.3; MedlinePlus (NIH/NLM) — Ascorbic acid: https://medlineplus.gov/druginfo/meds/a601110.html'),

  ('aminoacidos',
   E'Os aminoácidos injetáveis (nutrição parentérica) fornecem ao corpo as "peças" de que este precisa para construir proteínas — músculo, pele, enzimas e defesas. São usados em ambiente hospitalar quando o doente não consegue comer nem usar o tubo digestivo, geralmente em conjunto com glicose e gordura, para manter a massa muscular e a cicatrização.',
   E'Injectable amino acids (parenteral nutrition) provide the body with the "building blocks" it needs to make proteins — muscle, skin, enzymes and defences. They are used in hospital when a patient cannot eat or use the digestive tract, usually together with glucose and fat, to preserve muscle mass and wound healing.',
   E'Mistura de aminoácidos essenciais e não essenciais (forma L) para nutrição parentérica, contendo também taurina e tirosina solúvel (N-acetil-L-tirosina). Composição específica (ex.: TrophAmine 10%) formulada para normalizar o perfil plasmático de aminoácidos em lactentes e crianças pequenas, quando administrada com cisteína. Fonte de azoto (15,5 g de azoto/litro na TrophAmine 10%) para síntese proteica.',
   E'Mixture of essential and non-essential amino acids (L-form) for parenteral nutrition, also containing taurine and soluble tyrosine (N-acetyl-L-tyrosine). The specific composition (e.g., TrophAmine 10%) is formulated to normalise the plasma amino acid profile in infants and young children when given with cysteine. Source of nitrogen (15.5 g nitrogen/litre in TrophAmine 10%) for protein synthesis.',
   E'• Suporte nutricional parentérico em lactentes (incl. baixo peso ao nascer) e crianças pequenas\\n• Via central ou periférica, quando a alimentação entérica é impossível ou insuficiente',
   E'• Parenteral nutritional support in infants (including low birth weight) and young children\\n• Central or peripheral route, when enteral feeding is impossible or insufficient',
   E'• Acidose metabólica\\n• Hiperamoniemia (sobretudo com doses elevadas ou insuficiência hepática)\\n• Reações de hipersensibilidade\\n• Flebite/trombose no local de infusão\\n• Sobrecarga hídrica e eletrolítica se infundido em excesso',
   E'• Metabolic acidosis\\n• Hyperammonaemia (especially at high doses or with hepatic impairment)\\n• Hypersensitivity reactions\\n• Phlebitis/thrombosis at the infusion site\\n• Fluid and electrolyte overload if over-infused',
   E'• Contraindicado em anúria não tratada, coma hepático, erros inatos do metabolismo dos aminoácidos (ex.: doença da urina com cheiro a xarope de ácer, acidemia isovalérica) e hipersensibilidade\\n• Vigiar equilíbrio ácido-base, eletrólitos e amoniemia\\n• Solução hipertónica (866 mOsm/l) — infundir com precaução; não infundir diretamente sem diluição/administração controlada',
   E'• Contraindicated in untreated anuria, hepatic coma, inborn errors of amino acid metabolism (e.g., maple syrup urine disease, isovaleric acidaemia) and hypersensitivity\\n• Monitor acid-base balance, electrolytes and ammonia\\n• Hypertonic solution (866 mOsm/L) — infuse with caution; do not infuse directly without controlled administration',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado TrophAmine 10% (B. Braun): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb6d23ff-3ec5-445a-acbe-f88fd57949bf',
   'DailyMed/FDA (NIH/NLM) — approved TrophAmine 10% label (B. Braun): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb6d23ff-3ec5-445a-acbe-f88fd57949bf'),

  ('carbonato_calcio',
   E'O cálcio é um mineral essencial para os ossos, os dentes, os músculos e o coração. O carbonato de cálcio é a forma mais comum de suplemento de cálcio e também atua como antiácido (alivia azia e má digestão). Quando o corpo não recebe cálcio suficiente da alimentação — por exemplo em idosos ou em pessoas com osteoporose — os suplementos ajudam a manter os ossos fortes.',
   E'Calcium is an essential mineral for bones, teeth, muscles and the heart. Calcium carbonate is the most common form of calcium supplement and also works as an antacid (relieves heartburn and indigestion). When the body does not get enough calcium from food — for example in older people or those with osteoporosis — supplements help keep bones strong.',
   E'Sal de cálcio usado como suplemento mineral (hipocalcemia, prevenção/tratamento da osteoporose, aumento das necessidades na infância/gravidez/aleitamento) e como antiácido (neutraliza o ácido gástrico; 40% de cálcio elementar por peso). A associação com vitamina D é usada na osteoporose porque a vitamina D favorece a absorção do cálcio. A via oral pode causar perturbações gastrintestinais (irritação e obstipação).',
   E'Calcium salt used as a mineral supplement (hypocalcaemia, prevention/treatment of osteoporosis, increased needs in childhood/pregnancy/breastfeeding) and as an antacid (neutralises gastric acid; 40% elemental calcium by weight). The combination with vitamin D is used in osteoporosis because vitamin D enhances calcium absorption. The oral route may cause gastrointestinal upset (irritation and constipation).',
   E'• Hipocalcemia e prevenção de patologias por carência de cálcio\\n• Aumento das necessidades: infância, gravidez, aleitamento, idosos (má absorção)\\n• Terapêutica parcial da osteoporose (idealmente com vitamina D)\\n• Como antiácido: alívio de azia, indigestão ácida e desconforto gástrico',
   E'• Hypocalcaemia and prevention of conditions due to calcium deficiency\\n• Increased needs: childhood, pregnancy, breastfeeding, older people (malabsorption)\\n• Partial therapy of osteoporosis (ideally with vitamin D)\\n• As an antacid: relief of heartburn, acid indigestion and gastric discomfort',
   E'• Obstrução/irritação gástrica e obstipação (os mais frequentes)\\n• Náuseas, flatulência, eructação\\n• Hipercalcemia se administração exagerada (anorexia, náuseas, vómitos, dor abdominal, obstipação, fraqueza muscular, poliúria, nefrocalcinose, cálculos renais)\\n• Calcificação de tecidos moles (parentérico)',
   E'• Gastric irritation and constipation (most common)\\n• Nausea, flatulence, belching\\n• Hypercalcaemia with excessive intake (anorexia, nausea, vomiting, abdominal pain, constipation, muscle weakness, polyuria, nephrocalcinosis, kidney stones)\\n• Soft-tissue calcification (parenteral)',
   E'• Risco de hipercalcemia aumentado na insuficiência renal e com vitamina D\\n• As tiazidas podem causar hipercalcemia — vigiar\\n• Pode reduzir a absorção de outros medicamentos (bifosfonatos, tetraciclinas, quinolonas, levotiroxina, ferro) — separar a toma\\n• Como antiácido: não exceder 7 comprimidos/24 h (5 na gravidez), nem usar a dose máxima por mais de 2 semanas sem aconselhamento médico\\n• Consultar médico/farmacêutico se estiver a tomar outros medicamentos sujeitos a receita',
   E'• Risk of hypercalcaemia increased in renal impairment and with vitamin D\\n• Thiazides may cause hypercalcaemia — monitor\\n• May reduce absorption of other medicines (bisphosphonates, tetracyclines, quinolones, levothyroxine, iron) — separate administration\\n• As an antacid: do not exceed 7 tablets/24 h (5 in pregnancy), nor use the maximum dose for more than 2 weeks without medical advice\\n• Ask a doctor or pharmacist before use if taking prescription drugs',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado TUMS Ultra (Haleon): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=348d3dfa-6a52-4583-96e3-83c4bf2df45b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Cálcio, 11.3.2.1.1',
   'DailyMed/FDA (NIH/NLM) — approved TUMS Ultra label (Haleon): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=348d3dfa-6a52-4583-96e3-83c4bf2df45b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium, 11.3.2.1.1'),

  ('cloreto_potassio',
   E'O potássio é um mineral essencial para o funcionamento do coração, dos músculos e dos nervos. O cloreto de potássio é usado para repor o potássio quando está baixo — por exemplo por diuréticos, diarreia ou vómitos. É um medicamento sério: tomá-lo em excesso (ou com os rins a falhar) pode ser perigoso para o coração.',
   E'Potassium is an essential mineral for the heart, muscles and nerves. Potassium chloride is used to replace potassium when it is low — for example due to diuretics, diarrhoea or vomiting. It is a serious medicine: taking too much (or with failing kidneys) can be dangerous for the heart.',
   E'Sal de potássio para o tratamento e profilaxia da hipocaliemia com ou sem alcalose metabólica, quando a gestão dietética ou a redução do diurético é insuficiente. O ião potássio é o principal catião intracelular (150–160 mEq/L intracelular vs 3,5–5 mEq/L plasmático); participa na manutenção da tonicidade, transmissão nervosa e contração muscular (cardíaca, esquelética e lisa).',
   E'Potassium salt for the treatment and prophylaxis of hypokalaemia with or without metabolic alkalosis, when dietary management or diuretic dose reduction is insufficient. The potassium ion is the principal intracellular cation (150–160 mEq/L intracellular vs 3.5–5 mEq/L plasma); it participates in maintenance of tonicity, nerve impulse transmission and muscle contraction (cardiac, skeletal and smooth).',
   E'• Tratamento e profilaxia da hipocaliemia, com ou sem alcalose metabólica\\n• Quando a dieta rica em potássio ou a redução do diurético são insuficientes',
   E'• Treatment and prophylaxis of hypokalaemia, with or without metabolic alkalosis\\n• When a potassium-rich diet or diuretic dose reduction is insufficient',
   E'• Náuseas, vómitos, flatulência, dor/desconforto abdominal e diarreia (os mais frequentes)\\n• Irritação gastrintestinal (comprimidos)\\n• Hipercaliemia se sobredosagem ou insuficiência renal (arritmias, parestesias, fraqueza)',
   E'• Nausea, vomiting, flatulence, abdominal pain/discomfort and diarrhoea (most common)\\n• Gastrointestinal irritation (tablets)\\n• Hyperkalaemia with overdose or renal impairment (arrhythmias, paraesthesias, weakness)',
   E'• Tomar com as refeições e com água; não esmagar, mastigar nem chupar os comprimidos de libertação prolongada\\n• Risco de hipercaliemia aumentado na insuficiência renal e com IECA/ARA II ou AINEs — iniciar com doses baixas e monitorizar a potassemia\\n• Evitar associação com diuréticos poupadores de potássio e suplementos de potássio\\n• Vigiar o potássio sérico e a função renal durante o tratamento',
   E'• Take with meals and water; do not crush, chew or suck extended-release tablets\\n• Risk of hyperkalaemia increased in renal impairment and with ACE inhibitors/ARBs or NSAIDs — start at low doses and monitor serum potassium\\n• Avoid combination with potassium-sparing diuretics and potassium supplements\\n• Monitor serum potassium and renal function during treatment',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Potassium Chloride ER (Aurobindo): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16c775e4-0dd8-4e9f-b2bf-dd2b639374cf',
   'DailyMed/FDA (NIH/NLM) — approved Potassium Chloride ER label (Aurobindo): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16c775e4-0dd8-4e9f-b2bf-dd2b639374cf'),

  ('colecalciferol',
   E'A vitamina D (colecalciferol) ajuda o corpo a absorver o cálcio, mantendo os ossos fortes. É produzida na pele com a exposição solar e também existe em alguns alimentos. A suplementação é útil em pessoas com défice — idosos, pessoas com pouca exposição solar, pele escura ou doenças que reduzem a absorção — e em associação com cálcio na osteoporose.',
   E'Vitamin D (cholecalciferol) helps the body absorb calcium, keeping bones strong. It is produced in the skin with sun exposure and also exists in some foods. Supplementation helps people with deficiency — older people, those with little sun exposure, dark skin or conditions that reduce absorption — and in combination with calcium in osteoporosis.',
   E'Vitamina lipossolúvel (D3) que regula a homeostasia do cálcio e do fósforo; favorece a absorção intestinal do cálcio, pelo que as associações com sais de cálcio são usadas na terapêutica da osteoporose. Precursor que sofre hidroxilação hepática (25-hidroxicolecalciferol) e renal (1,25-di-hidroxicolecalciferol, a forma ativa). Prevenção e tratamento da deficiência de vitamina D e das suas consequências (raquitismo, osteomalacia).',
   E'Fat-soluble vitamin (D3) that regulates calcium and phosphorus homeostasis; it enhances intestinal calcium absorption, which is why combinations with calcium salts are used in osteoporosis therapy. A precursor that undergoes hepatic (25-hydroxycholecalciferol) and renal (1,25-dihydroxycholecalciferol, the active form) hydroxylation. Prevention and treatment of vitamin D deficiency and its consequences (rickets, osteomalacia).',
   E'• Prevenção e tratamento da deficiência de vitamina D\\n• Raquitismo e osteomalacia\\n• Associado ao cálcio na osteoporose (favorece a absorção do cálcio)\\n• Suplementação em idosos, pouca exposição solar e má absorção',
   E'• Prevention and treatment of vitamin D deficiency\\n• Rickets and osteomalacia\\n• With calcium in osteoporosis (enhances calcium absorption)\\n• Supplementation in older people, low sun exposure and malabsorption',
   E'• Raros em doses habituais (hipervitaminose D é rara)\\n• Em doses muito elevadas: hipercalcemia (anorexia, náuseas, vómitos, obstipação, fraqueza, poliúria, cálculos renais)',
   E'• Rare at usual doses (hypervitaminosis D is rare)\\n• At very high doses: hypercalcaemia (anorexia, nausea, vomiting, constipation, weakness, polyuria, kidney stones)',
   E'• Contraindicado/evitar em hipercalcemia e hipercalciúria\\n• Risco de hipercalcemia aumentado na insuficiência renal e com suplementos de cálcio — monitorizar\\n• Vigiar a calcemia na terapêutica prolongada com doses altas\\n• Interações: anticonvulsivantes (fenobarbital, fenitoína) e corticosteroides podem reduzir o efeito; tiazidas podem aumentar a calcemia',
   E'• Contraindicated/avoid in hypercalcaemia and hypercalciuria\\n• Risk of hypercalcaemia increased in renal impairment and with calcium supplements — monitor\\n• Monitor serum calcium during prolonged high-dose therapy\\n• Interactions: anticonvulsants (phenobarbital, phenytoin) and corticosteroids may reduce the effect; thiazides may raise serum calcium',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Vitamina D, 9.6.3/11.3.1.1; DailyMed/FDA (NIH/NLM) — rótulo aprovado FILMTEC D3: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec15acc8-7475-4ddd-98c1-8e07d423fd07 ; MedlinePlus (NIH/NLM) — Cholecalciferol: https://medlineplus.gov/druginfo/meds/a601062.html',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Vitamin D, 9.6.3/11.3.1.1; DailyMed/FDA (NIH/NLM) — approved FILMTEC D3 label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec15acc8-7475-4ddd-98c1-8e07d423fd07 ; MedlinePlus (NIH/NLM) — Cholecalciferol: https://medlineplus.gov/druginfo/meds/a601062.html'),

  ('emulsao_lipidica',
   E'As emulsões lipídicas injetáveis (gordura para perfusão) fornecem calorias e ácidos gordos essenciais a doentes que não conseguem comer — por exemplo em nutrição parentérica no hospital. A gordura é uma fonte concentrada de energia e previne a carência de ácidos gordos essenciais, que causaria pele seca, atraso de crescimento e problemas neurológicos.',
   E'Injectable lipid emulsions (intravenous fat) provide calories and essential fatty acids to patients who cannot eat — for example on parenteral nutrition in hospital. Fat is a concentrated energy source and prevents essential fatty acid deficiency, which would cause dry skin, growth delay and neurological problems.',
   E'Emulsão de óleo de soja (triglicerídeos de cadeia longa) para nutrição parentérica, como fonte de calorias e de ácidos gordos essenciais (ácido linoleico e alfa-linolénico), e para prevenção da carência de ácidos gordos essenciais (EFAD). Os triglicerídeos são hidrolisados pela lipase lipoproteica; os ácidos gordos libertados são oxidados por beta-oxidação ou utilizados na estrutura das membranas e como precursores de moléculas bioativas.',
   E'Soybean oil emulsion (long-chain triglycerides) for parenteral nutrition, as a source of calories and essential fatty acids (linoleic and alpha-linolenic acid), and for prevention of essential fatty acid deficiency (EFAD). Triglycerides are hydrolysed by lipoprotein lipase; the released fatty acids are oxidised by beta-oxidation or used in membrane structure and as precursors of bioactive molecules.',
   E'• Fonte de calorias e de ácidos gordos essenciais em adultos e crianças que necessitam de nutrição parentérica\\n• Prevenção da carência de ácidos gordos essenciais (EFAD)',
   E'• Source of calories and essential fatty acids in adults and children requiring parenteral nutrition\\n• Prevention of essential fatty acid deficiency (EFAD)',
   E'• Hipertrigliceridemia transitória\\n• Reações de hipersensibilidade (raras)\\n• Risco de descompensação clínica com infusão rápida em recém-nascidos e lactentes (síndrome de distress respiratório agudo, acidose metabólica)\\n• Sobrecarga hídrica e infeção (cateter)\\n• Síndrome de sobrecarga de gordura (febre, hepatomegalia, coagulopatia) com doses excessivas',
   E'• Transient hypertriglyceridaemia\\n• Hypersensitivity reactions (rare)\\n• Risk of clinical decompensation with rapid infusion in neonates and infants (acute respiratory distress, metabolic acidosis)\\n• Fluid overload and infection (catheter)\\n• Fat overload syndrome (fever, hepatomegaly, coagulopathy) with excessive doses',
   E'• Contraindicado em hipersensibilidade ao ovo, soja ou amendoim e em perturbações graves do metabolismo lipídico com hipertrigliceridemia (> 1000 mg/dL)\\n• Infundir lentamente e monitorizar triglicerídeos\\n• Vigiar sinais de sobrecarga (dispneia, febre, icterícia) e parar a infusão se surgirem',
   E'• Contraindicated in hypersensitivity to egg, soybean or peanut, and in severe disorders of lipid metabolism with hypertriglyceridaemia (> 1000 mg/dL)\\n• Infuse slowly and monitor triglycerides\\n• Monitor for signs of overload (dyspnoea, fever, jaundice) and stop the infusion if they occur',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Intralipid (Fresenius Kabi): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=61e025f1-a38e-4af2-9e18-13ea12977cf5',
   'DailyMed/FDA (NIH/NLM) — approved Intralipid label (Fresenius Kabi): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=61e025f1-a38e-4af2-9e18-13ea12977cf5'),

  ('glicose',
   E'A glicose (dextrose) é o açúcar que dá energia ao corpo e é a principal fonte de energia do cérebro. Em ambiente hospitalar é usada por via intravenosa para tratar níveis muito baixos de açúcar no sangue (hipoglicemia) e como parte dos líquidos de perfusão para hidratação e nutrição.',
   E'Glucose (dextrose) is the sugar that provides energy to the body and is the main energy source for the brain. In hospital it is given intravenously to treat very low blood sugar (hypoglycaemia) and as part of infusion fluids for hydration and nutrition.',
   E'Açúcar de seis carbonos (monossacarídeo) usado por via intravenosa para restabelecer a glicemia e fornecer calorias de hidratos de carbono. A dextrose 50% está indicada no tratamento da hipoglicemia induzida por insulina (hiperinsulinemia, choque insulínico). A glicose é oxidada a dióxido de carbono e água, fornecendo aproximadamente 3,4 kcal/g.',
   E'Six-carbon sugar (monosaccharide) used intravenously to restore blood glucose and provide carbohydrate calories. Dextrose 50% is indicated for the treatment of insulin-induced hypoglycaemia (hyperinsulinaemia, insulin shock). Glucose is oxidised to carbon dioxide and water, providing approximately 3.4 kcal/g.',
   E'• Tratamento da hipoglicemia induzida por insulina (adultos e crianças ≥ 2 anos)\\n• Fonte de calorias e hidratação (soluções de dextrose em perfusão)\\n• Veículo para outros medicamentos intravenosos',
   E'• Treatment of insulin-induced hypoglycaemia (adults and children ≥ 2 years)\\n• Source of calories and hydration (dextrose infusion solutions)\\n• Vehicle for other intravenous medicines',
   E'• Hiperglicemia (a mais frequente)\\n• Reações de hipersensibilidade\\n• Hiponatremia\\n• Infeção (sistémica ou no local da perfusão), trombose venosa e flebite\\n• Desequilíbrio eletrolítico',
   E'• Hyperglycaemia (most common)\\n• Hypersensitivity reactions\\n• Hyponatraemia\\n• Infection (systemic or at the infusion site), venous thrombosis and phlebitis\\n• Electrolyte imbalance',
   E'• Contraindicado em hemorragia intracraniana ou intraspinal, desidratação grave, abstinência alcoólica e hipersensibilidade à dextrose\\n• Monitorizar a glicemia e a urina; administrar insulina conforme necessário\\n• Vigiar o equilíbrio eletrolítico e o estado de hidratação\\n• Evitar em doentes com intolerância à glicose não controlada (usar com precaução)',
   E'• Contraindicated in intracranial or intraspinal haemorrhage, severe dehydration, alcohol withdrawal and hypersensitivity to dextrose\\n• Monitor blood and urine glucose; give insulin as needed\\n• Monitor electrolyte balance and hydration status\\n• Avoid in uncontrolled glucose intolerance (use with caution)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dextrose 50% Injection (Hospira): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ed365da-4e62-4329-c1b9-c197ab4fb6e1',
   'DailyMed/FDA (NIH/NLM) — approved Dextrose 50% Injection label (Hospira): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ed365da-4e62-4329-c1b9-c197ab4fb6e1'),

  ('sulfato_magnesio',
   E'O magnésio é um mineral essencial para o funcionamento dos músculos e dos nervos. O sulfato de magnésio é usado no hospital, por via intravenosa, sobretudo para prevenir e tratar convulsões na pré-eclâmpsia e eclâmpsia (complicações graves da gravidez) e para repor o magnésio quando está baixo.',
   E'Magnesium is an essential mineral for muscle and nerve function. Magnesium sulfate is used in hospital, intravenously, mainly to prevent and treat seizures in pre-eclampsia and eclampsia (serious complications of pregnancy) and to replace magnesium when it is low.',
   E'Sal de magnésio com ação sobre a transmissão neuromuscular: o ião magnésio (Mg²⁺) reduz a libertação de acetilcolina na placa motora e bloqueia os recetores NMDA, o que explica o efeito anticonvulsivante e tocolítico. O magnésio é cofator de reações enzimáticas e importante na transmissão neuroquímica e na excitabilidade muscular. Indicado na prevenção e controlo de convulsões na pré-eclâmpsia e eclâmpsia.',
   E'Magnesium salt acting on neuromuscular transmission: the magnesium ion (Mg²⁺) reduces acetylcholine release at the motor end-plate and blocks NMDA receptors, explaining the anticonvulsant and tocolytic effect. Magnesium is a cofactor for enzymatic reactions and is important in neurochemical transmission and muscular excitability. Indicated for the prevention and control of seizures in pre-eclampsia and eclampsia.',
   E'• Prevenção e controlo de convulsões na pré-eclâmpsia e eclâmpsia\\n• Reposição de magnésio (carência) — oral ou parentérica\\n• Adjuvante em arritmias (torsades de pointes) e asma aguda grave (protocolos)',
   E'• Prevention and control of seizures in pre-eclampsia and eclampsia\\n• Magnesium replacement (deficiency) — oral or parenteral\\n• Adjunct in arrhythmias (torsades de pointes) and severe acute asthma (protocols)',
   E'• Rubor (flushing), sudação, hipotensão\\n• Reflexos deprimidos, paralisia flácida, hipotermia\\n• Colapso circulatório e depressão cardíaca e do SNC que progride a paralisia respiratória (intoxicação por magnésio)\\n• Hipocalcemia com sinais de tetania (terapêutica da eclâmpsia)\\n• Diarreia (sais orais)',
   E'• Flushing, sweating, hypotension\\n• Depressed reflexes, flaccid paralysis, hypothermia\\n• Circulatory collapse and cardiac/CNS depression progressing to respiratory paralysis (magnesium intoxication)\\n• Hypocalcaemia with signs of tetany (eclampsia therapy)\\n• Diarrhoea (oral salts)',
   E'• Contraindicado por via intravenosa nas 2 horas anteriores ao parto em mães com toxemia da gravidez\\n• Insuficiência renal grave: reduzir a dose e monitorizar a magnesemia com frequência\\n• Monitorizar os reflexos e a função respiratória durante a perfusão (antídoto: gluconato de cálcio)\\n• Sais orais: reduzir a absorção de bifosfonatos — tomar com horas de intervalo\\n• Evitar em bloqueio cardíaco e miastenia gravis (agrava)',
   E'• Contraindicated intravenously within 2 hours preceding delivery in mothers with toxaemia of pregnancy\\n• Severe renal impairment: reduce the dose and monitor serum magnesium frequently\\n• Monitor reflexes and respiratory function during infusion (antidote: calcium gluconate)\\n• Oral salts: reduce bisphosphonate absorption — separate administration\\n• Avoid in heart block and myasthenia gravis (worsens)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Magnesium Sulfate Injection (Civica): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5a9f565-639c-4b22-b9e5-718bac7cfcf3 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Magnésio, 11.3.2.1.2',
   'DailyMed/FDA (NIH/NLM) — approved Magnesium Sulfate Injection label (Civica): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5a9f565-639c-4b22-b9e5-718bac7cfcf3 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Magnesium, 11.3.2.1.2'),

  ('zinco',
   E'O zinco é um mineral essencial para a cicatrização, o crescimento, o paladar e o olfato e para o sistema imunitário. Em ambiente hospitalar é adicionado aos líquidos de nutrição parentérica para prevenir a carência de zinco em doentes que não conseguem comer.',
   E'Zinc is an essential mineral for wound healing, growth, taste and smell, and the immune system. In hospital it is added to parenteral nutrition fluids to prevent zinc deficiency in patients who cannot eat.',
   E'Oligoelemento essencial, cofator de mais de 70 enzimas (anidrase carbónica, fosfatase alcalina, lactato desidrogenase, RNA e DNA polimerase). Facilita a cicatrização de feridas, ajuda a manter o crescimento normal, a hidratação da pele e os sentidos do paladar e do olfato. Distribui-se por músculo, osso, pele, rim, fígado, pâncreas, retina e próstata, e liga-se à albumina plasmática, à alfa-2-macroglobulina e a aminoácidos plasmáticos.',
   E'Essential trace element, cofactor of more than 70 enzymes (carbonic anhydrase, alkaline phosphatase, lactate dehydrogenase, RNA and DNA polymerase). Facilitates wound healing, helps maintain normal growth, skin hydration and the senses of taste and smell. Distributed in muscle, bone, skin, kidney, liver, pancreas, retina and prostate, and binds to plasma albumin, alpha-2-macroglobulin and plasma amino acids.',
   E'• Suplemento de zinco em soluções intravenosas de nutrição parentérica (TPN)\\n• Prevenção e tratamento da carência de zinco',
   E'• Zinc supplement in intravenous parenteral nutrition solutions (TPN)\\n• Prevention and treatment of zinc deficiency',
   E'• Efeitos adversos raros quando usado como suplemento na dose recomendada\\n• Irritação tecidual significativa se injeção intramuscular ou intravenosa direta (pH ácido da solução)\\n• Em sobredosagem: náuseas, vómitos, diarreia, sabor metálico, anemia',
   E'• Adverse effects rare when used as a supplement at the recommended dose\\n• Significant tissue irritation with direct intramuscular or intravenous injection (acidic pH of the solution)\\n• In overdose: nausea, vomiting, diarrhoea, metallic taste, anaemia',
   E'• Contraindicada a injeção IM ou IV direta (apenas aditivo à nutrição parentérica em programa de mistura assética)\\n• Doença renal grave: reduzir ou omitir as doses de zinco\\n• A solução não contém conservantes — usar imediatamente e descartar o que sobrar\\n• Monitorizar o zinco sérico na terapêutica prolongada',
   E'• Direct IM or IV injection is contraindicated (only as an additive to parenteral nutrition under an aseptic admixture programme)\\n• Severe renal disease: reduce or omit zinc doses\\n• The solution contains no preservatives — use promptly and discard the remainder\\n• Monitor serum zinc during prolonged therapy',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Zinc Chloride Injection (Exela): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bd646d2-2a2a-4376-8da0-c7f08b0511ac',
   'DailyMed/FDA (NIH/NLM) — approved Zinc Chloride Injection label (Exela): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bd646d2-2a2a-4376-8da0-c7f08b0511ac')
) AS v(
  slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
  indications_pt, indications_en, side_effects_pt, side_effects_en,
  precautions_pt, precautions_en, source_pt, source_en)
  ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- Farmacologia (drug_pharmacology)
-- =====================================================================

INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en, absorption_pt, absorption_en,
   half_life_pt, half_life_en, source_pt, source_en, status)
SELECT d.id, v.pharmacodynamics_pt, v.pharmacodynamics_en, v.mechanism_pt, v.mechanism_en,
       v.metabolism_pt, v.metabolism_en, v.absorption_pt, v.absorption_en,
       v.half_life_pt, v.half_life_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('acido_ascorbico',
   E'Vitamina essencial com atividade antioxidante e cofator de hidroxilases. As funções dependem da concentração tecidular: síntese de colagénio, carnitina e catecolaminas; melhora a absorção do ferro não-heme. Não há evidência de que doses diárias elevadas previnam ou reduzam a duração das constipações.',
   E'Essential vitamin with antioxidant activity and cofactor of hydroxylases. Functions depend on tissue concentration: collagen, carnitine and catecholamine synthesis; enhances non-haem iron absorption. There is no evidence that high daily doses prevent colds or shorten their duration.',
   E'Doador de eletrões em reações de oxidação-redução; cofator das hidroxilases prolil e lisil (hidroxilação da prolina e lisina na síntese do colagénio), da dopamina-beta-hidroxilase (catecolaminas) e de enzimas da síntese de carnitina. Reduz o ferro férrico a ferroso no duodeno, favorecendo a absorção.',
   E'Electron donor in oxidation-reduction reactions; cofactor of prolyl and lysyl hydroxylases (proline and lysine hydroxylation in collagen synthesis), of dopamine beta-hydroxylase (catecholamines) and of carnitine synthesis enzymes. Reduces ferric to ferrous iron in the duodenum, favouring absorption.',
   E'Metabolizado parcialmente no fígado (oxidação a ácido desidroascórbico e depois a oxalato, ácido treónico e ascorbato-2-sulfato). O oxalato é eliminado na urina — daí o risco de litíase em doses elevadas em doentes predispostos.',
   E'Partially metabolised in the liver (oxidation to dehydroascorbic acid and then to oxalate, threonic acid and ascorbate-2-sulfate). Oxalate is eliminated in urine — hence the stone risk at high doses in predisposed patients.',
   E'A absorção intestinal é ativa e saturável no intestino delgado (transportador dependente de sódio); a fração absorvida diminui com a dose (quase total até ~200 mg, menor acima de 1 g). A vitamina C é hidrossolúvel; o excesso não absorvido fica no lúmen e causa diarreia osmótica.',
   E'Intestinal absorption is active and saturable in the small intestine (sodium-dependent transporter); the absorbed fraction decreases with dose (nearly complete up to ~200 mg, lower above 1 g). Vitamin C is water-soluble; unabsorbed excess stays in the lumen and causes osmotic diarrhoea.',
   E'Meia-vida dependente da dose: cerca de 8–12 dias em níveis corporais baixos, diminuindo para 1–2 horas em concentrações muito elevadas (excreção renal do excesso). A excreção é renal, na forma inalterada e de metabolitos (oxalato).',
   E'Half-life depends on dose: about 8–12 days at low body levels, decreasing to 1–2 hours at very high concentrations (renal excretion of the excess). Excretion is renal, unchanged and as metabolites (oxalate).',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Vitamina C, 11.3.1.3; MedlinePlus (NIH/NLM) — Ascorbic acid: https://medlineplus.gov/druginfo/meds/a601110.html',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Vitamin C, 11.3.1.3; MedlinePlus (NIH/NLM) — Ascorbic acid: https://medlineplus.gov/druginfo/meds/a601110.html'),

  ('aminoacidos',
   E'Fonte de azoto para a síntese proteica: fornece aminoácidos essenciais e não essenciais que são incorporados nas proteínas corporais. A composição da TrophAmine (com taurina e N-acetil-L-tirosina) normaliza o perfil plasmático de aminoácidos para o de um lactente amamentado, quando administrada com cisteína.',
   E'Source of nitrogen for protein synthesis: provides essential and non-essential amino acids that are incorporated into body proteins. The TrophAmine composition (with taurine and N-acetyl-L-tyrosine) normalises the plasma amino acid profile to that of a breast-fed infant when given with cysteine.',
   E'Os aminoácidos administrados por via parentérica entram no pool de aminoácidos plasmáticos e são utilizados na síntese proteica (anabolismo) ou catabolizados, fornecendo azoto para a síntese de compostos não proteicos. A cisteína (condicionalmente essencial no recém-nascido) é adicionada porque a sua síntese endógena é limitada.',
   E'Parenterally administered amino acids enter the plasma amino acid pool and are used for protein synthesis (anabolism) or catabolised, providing nitrogen for the synthesis of non-protein compounds. Cysteine (conditionally essential in the neonate) is added because its endogenous synthesis is limited.',
   E'Metabolizados no fígado e noutros tecidos: transaminação, desaminação e incorporação em proteínas; o azoto é excretado sobretudo como ureia. A taurina é excretada principalmente na forma inalterada na urina.',
   E'Metabolised in the liver and other tissues: transamination, deamination and incorporation into proteins; nitrogen is excreted mainly as urea. Taurine is excreted mostly unchanged in urine.',
   E'Administração exclusivamente parentérica (IV); a biodisponibilidade é completa por definição da via. A infusão deve ser lenta e controlada (solução hipertónica de ~866 mOsm/L na TrophAmine 10%).',
   E'Administration is exclusively parenteral (IV); bioavailability is complete by definition of the route. Infusion must be slow and controlled (hypertonic solution of ~866 mOsm/L in TrophAmine 10%).',
   E'A meia-vida não se aplica de forma clássica (mistura de aminoácidos endógenos); a cinética é a do turnover proteico, com eliminação do azoto em horas a dias conforme o estado metabólico do doente.',
   E'Half-life does not apply classically (mixture of endogenous amino acids); kinetics follow protein turnover, with nitrogen elimination over hours to days depending on the patient metabolic state.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado TrophAmine 10% (B. Braun): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb6d23ff-3ec5-445a-acbe-f88fd57949bf',
   'DailyMed/FDA (NIH/NLM) — approved TrophAmine 10% label (B. Braun): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb6d23ff-3ec5-445a-acbe-f88fd57949bf'),

  ('carbonato_calcio',
   E'Fornece cálcio ionizado essencial para a formação óssea, a contração muscular, a transmissão nervosa e a coagulação. Como antiácido, neutraliza o ácido gástrico de forma rápida e duradoura (o efeito acidificante de rebote é mínimo com doses habituais).',
   E'Provides ionised calcium essential for bone formation, muscle contraction, nerve transmission and coagulation. As an antacid, it neutralises gastric acid quickly and durably (rebound acidification is minimal at usual doses).',
   E'Reage com o ácido clorídrico gástrico formando cloreto de cálcio, água e dióxido de carbono (neutralização direta, antiácido); o ião cálcio é essencial para a mineralização óssea e a excitabilidade neuromuscular. A vitamina D aumenta a absorção intestinal do cálcio.',
   E'Reacts with gastric hydrochloric acid forming calcium chloride, water and carbon dioxide (direct neutralisation, antacid); the calcium ion is essential for bone mineralisation and neuromuscular excitability. Vitamin D increases intestinal calcium absorption.',
   E'O cálcio absorvido é incorporado no osso ou excretado; o equilíbrio é regulado pela PTH, calcitriol e calcitonina. O carbonato é pouco metabolizado; o cálcio não absorvido é eliminado nas fezes.',
   E'Absorbed calcium is incorporated into bone or excreted; the balance is regulated by PTH, calcitriol and calcitonin. The carbonate is poorly metabolised; unabsorbed calcium is eliminated in faeces.',
   E'A absorção oral do cálcio é dependente da vitamina D e da acidez gástrica (o carbonato requer pH ácido) — melhor absorvido com alimentos; a fração absorvida é cerca de 25–35% e diminui com doses únicas elevadas (absorção saturável).',
   E'Oral calcium absorption depends on vitamin D and gastric acidity (carbonate requires acidic pH) — best absorbed with food; the absorbed fraction is about 25–35% and decreases with high single doses (saturable absorption).',
   E'A meia-vida do cálcio plasmático é de minutos a horas (rápido intercâmbio com o osso); o tempo de permanência no osso é de anos. A excreção é renal e fecal.',
   E'The half-life of plasma calcium is minutes to hours (rapid exchange with bone); bone residence time is years. Excretion is renal and faecal.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado TUMS Ultra (Haleon): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=348d3dfa-6a52-4583-96e3-83c4bf2df45b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Cálcio, 11.3.2.1.1',
   'DailyMed/FDA (NIH/NLM) — approved TUMS Ultra label (Haleon): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=348d3dfa-6a52-4583-96e3-83c4bf2df45b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium, 11.3.2.1.1'),

  ('cloreto_potassio',
   E'Repõe o potássio intracelular, corrigindo a hipocaliemia e as suas consequências (arritmias, fraqueza muscular, íleo paralítico). O potássio é o principal catião intracelular (150–160 mEq/L), contra 3,5–5 mEq/L no plasma, gradiente mantido pela Na⁺/K⁺-ATPase.',
   E'Replaces intracellular potassium, correcting hypokalaemia and its consequences (arrhythmias, muscle weakness, paralytic ileus). Potassium is the principal intracellular cation (150–160 mEq/L) versus 3.5–5 mEq/L in plasma, a gradient maintained by Na⁺/K⁺-ATPase.',
   E'O ião potássio participa na manutenção da tonicidade intracelular, na transmissão dos impulsos nervosos, na contração do músculo cardíaco, esquelético e liso e na função renal normal. O gradiente transmembranar é essencial para o potencial de repouso e a excitabilidade.',
   E'The potassium ion participates in maintenance of intracellular tonicity, nerve impulse transmission, contraction of cardiac, skeletal and smooth muscle, and normal renal function. The transmembrane gradient is essential for resting potential and excitability.',
   E'O potássio não é metabolizado; é eliminado principalmente pelos rins (secreção distal regulada pela aldosterona) e, em menor grau, pelo trato gastrointestinal.',
   E'Potassium is not metabolised; it is eliminated mainly by the kidneys (distal secretion regulated by aldosterone) and, to a lesser extent, by the gastrointestinal tract.',
   E'Comprimidos de libertação prolongada: o cloreto de potássio é completamente absorvido antes de sair do intestino delgado; a matriz de cera não é absorvida e é excretada nas fezes. A extensão da absorção é semelhante à de uma solução verdadeira.',
   E'Extended-release tablets: potassium chloride is completely absorbed before leaving the small intestine; the wax matrix is not absorbed and is excreted in faeces. The extent of absorption is similar to that of a true solution.',
   E'A meia-vida do potássio plasmático é de horas (distribuição rápida); a eliminação renal ajusta-se à ingestão, com excreção diária de cerca de 90% do ingerido no indivíduo com função renal normal.',
   E'The half-life of plasma potassium is hours (rapid distribution); renal elimination adapts to intake, with daily excretion of about 90% of intake in individuals with normal renal function.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Potassium Chloride ER (Aurobindo): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16c775e4-0dd8-4e9f-b2bf-dd2b639374cf',
   'DailyMed/FDA (NIH/NLM) — approved Potassium Chloride ER label (Aurobindo): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=16c775e4-0dd8-4e9f-b2bf-dd2b639374cf'),

  ('colecalciferol',
   E'Vitamina lipossolúvel que regula a homeostasia do cálcio e do fósforo: aumenta a absorção intestinal do cálcio, a reabsorção renal e a mineralização óssea. A deficiência causa raquitismo na criança e osteomalacia no adulto.',
   E'Fat-soluble vitamin that regulates calcium and phosphorus homeostasis: increases intestinal calcium absorption, renal reabsorption and bone mineralisation. Deficiency causes rickets in children and osteomalacia in adults.',
   E'Pró-hormona: o colecalciferol é hidroxilado no fígado em 25-hidroxicolecalciferol (forma de reserva, medida no soro) e depois no rim em 1,25-di-hidroxicolecalciferol (calcitriol, a forma ativa), que atua no recetor da vitamina D (VDR) no intestino, osso e rim, regulando a expressão de proteínas de transporte do cálcio.',
   E'Prohormone: cholecalciferol is hydroxylated in the liver to 25-hydroxycholecalciferol (storage form, measured in serum) and then in the kidney to 1,25-dihydroxycholecalciferol (calcitriol, the active form), which acts on the vitamin D receptor (VDR) in the intestine, bone and kidney, regulating expression of calcium transport proteins.',
   E'Metabolizado por hidroxilações sucessivas (hepática e renal); os metabolitos inativos são eliminados na bílis e, em menor grau, na urina.',
   E'Metabolised by successive hydroxylations (hepatic and renal); inactive metabolites are eliminated in bile and, to a lesser extent, in urine.',
   E'A absorção oral é dependente de sais biliares e gorduras (lipossolúvel) — melhor absorvido com as refeições; em doentes com esteatorreia ou doença celíaca a absorção pode estar reduzida.',
   E'Oral absorption depends on bile salts and fat (fat-soluble) — best absorbed with meals; in patients with steatorrhoea or coeliac disease absorption may be reduced.',
   E'A 25-hidroxivitamina D tem meia-vida de cerca de 2–3 semanas (forma circulante principal); o calcitriol tem meia-vida de horas. Em excesso, a vitamina D armazena-se no tecido adiposo (meia-vida corporal prolongada de semanas a meses).',
   E'25-Hydroxyvitamin D has a half-life of about 2–3 weeks (main circulating form); calcitriol has a half-life of hours. In excess, vitamin D is stored in adipose tissue (prolonged body half-life of weeks to months).',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Vitamina D, 9.6.3/11.3.1.1; MedlinePlus (NIH/NLM) — Cholecalciferol: https://medlineplus.gov/druginfo/meds/a601062.html',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Vitamin D, 9.6.3/11.3.1.1; MedlinePlus (NIH/NLM) — Cholecalciferol: https://medlineplus.gov/druginfo/meds/a601062.html'),

  ('emulsao_lipidica',
   E'Fornece calorias (cerca de 1,1–2 kcal/mL conforme a concentração) e ácidos gordos essenciais. A farmacodinâmica não está totalmente caracterizada; o efeito principal é metabólico (substrato energético e estrutural).',
   E'Provides calories (about 1.1–2 kcal/mL depending on concentration) and essential fatty acids. Pharmacodynamics are not fully characterised; the main effect is metabolic (energy and structural substrate).',
   E'Os triglicerídeos da emulsão são hidrolisados pela lipase lipoproteica em ácidos gordos livres, que são oxidados por beta-oxidação (principal via de produção de energia) ou utilizados na estrutura das membranas, como precursores de moléculas bioativas (prostaglandinas) e como reguladores da expressão génica.',
   E'The emulsion triglycerides are hydrolysed by lipoprotein lipase into free fatty acids, which are oxidised by beta-oxidation (main energy-producing pathway) or used in membrane structure, as precursors of bioactive molecules (prostaglandins) and as regulators of gene expression.',
   E'O ácido linoleico (ómega-6) e o alfa-linolénico (ómega-3) são metabolizados numa via bioquímica comum por sucessivas dessaturações e alongamentos da cadeia. A infusão é metabolizada conforme as necessidades energéticas e a capacidade oxidativa do doente.',
   E'Linoleic (omega-6) and alpha-linolenic (omega-3) acids are metabolised in a common biochemical pathway through successive desaturation and elongation steps. The infusion is metabolised according to the patient energy needs and oxidative capacity.',
   E'Administração exclusivamente intravenosa; a biodisponibilidade é completa por definição da via. A depuração depende da lipase lipoproteica e da capacidade de captação tecidular.',
   E'Administration is exclusively intravenous; bioavailability is complete by definition of the route. Clearance depends on lipoprotein lipase and tissue uptake capacity.',
   E'Não se aplica meia-vida clássica (substrato endógeno); os triglicerídeos infundidos são depurados em horas, com os ácidos gordos a entrarem nos pools metabólicos corporais.',
   E'Classical half-life does not apply (endogenous substrate); infused triglycerides are cleared within hours, with fatty acids entering body metabolic pools.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Intralipid (Fresenius Kabi): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=61e025f1-a38e-4af2-9e18-13ea12977cf5',
   'DailyMed/FDA (NIH/NLM) — approved Intralipid label (Fresenius Kabi): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=61e025f1-a38e-4af2-9e18-13ea12977cf5'),

  ('glicose',
   E'Restabelece a glicemia e fornece calorias de hidratos de carbono (aproximadamente 3,4 kcal/g). A relação exposição-resposta e o curso temporal da resposta farmacodinâmica não estão totalmente caracterizados.',
   E'Restores blood glucose and provides carbohydrate calories (approximately 3.4 kcal/g). The exposure-response relationship and time course of the pharmacodynamic response are not fully characterised.',
   E'A glicose é o principal substrato energético celular; a sua entrada nas células é mediada pela insulina (transportadores GLUT). No cérebro, a glicose é praticamente o único combustível, o que explica a necessidade de corrigir rapidamente a hipoglicemia.',
   E'Glucose is the main cellular energy substrate; its entry into cells is mediated by insulin (GLUT transporters). In the brain, glucose is virtually the only fuel, which explains the need to correct hypoglycaemia quickly.',
   E'A glicose administrada é oxidada a dióxido de carbono e água (via glicólise, ciclo de Krebs e fosforilação oxidativa) ou armazenada como glicogénio hepático e muscular; o excesso pode ser convertido em gordura (lipogénese).',
   E'Administered glucose is oxidised to carbon dioxide and water (via glycolysis, Krebs cycle and oxidative phosphorylation) or stored as hepatic and muscle glycogen; excess can be converted to fat (lipogenesis).',
   E'Administração exclusivamente intravenosa; biodisponibilidade completa por definição da via. A distribuição é rápida no espaço extracelular, com captação celular dependente de insulina.',
   E'Administration is exclusively intravenous; complete bioavailability by definition of the route. Distribution is rapid in the extracellular space, with insulin-dependent cellular uptake.',
   E'Não se aplica meia-vida clássica (substrato endógeno); a glicemia é regulada por mecanismos hormonais (insulina, glucagon) com resposta em minutos. Em doentes diabéticos pode ocorrer hiperglicemia persistente.',
   E'Classical half-life does not apply (endogenous substrate); blood glucose is regulated by hormonal mechanisms (insulin, glucagon) with response within minutes. In diabetic patients persistent hyperglycaemia may occur.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dextrose 50% Injection (Hospira): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ed365da-4e62-4329-c1b9-c197ab4fb6e1',
   'DailyMed/FDA (NIH/NLM) — approved Dextrose 50% Injection label (Hospira): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4ed365da-4e62-4329-c1b9-c197ab4fb6e1'),

  ('sulfato_magnesio',
   E'O magnésio é cofator de reações enzimáticas e importante na transmissão neuroquímica e na excitabilidade muscular. O efeito anticonvulsivante e tocolítico depende da concentração plasmática; a monitorização clínica (reflexos, frequência respiratória) é essencial durante a perfusão.',
   E'Magnesium is a cofactor for enzymatic reactions and important in neurochemical transmission and muscular excitability. The anticonvulsant and tocolytic effect depends on plasma concentration; clinical monitoring (reflexes, respiratory rate) is essential during infusion.',
   E'O ião magnésio (Mg²⁺) reduz a libertação de acetilcolina na junção neuromuscular e antagoniza o recetor NMDA, reduzindo a excitabilidade neuronal e a contratilidade muscular — mecanismo do efeito anticonvulsivante (eclâmpsia) e tocolítico. Em doses elevadas deprime o SNC e o sistema cardiovascular.',
   E'The magnesium ion (Mg²⁺) reduces acetylcholine release at the neuromuscular junction and antagonises the NMDA receptor, decreasing neuronal excitability and muscle contractility — the mechanism of the anticonvulsant (eclampsia) and tocolytic effect. At high doses it depresses the CNS and cardiovascular system.',
   E'O magnésio não é metabolizado; é excretado exclusivamente pelo rim, a uma taxa proporcional à concentração sérica e à filtração glomerular. Na insuficiência renal a dose deve ser reduzida.',
   E'Magnesium is not metabolised; it is excreted solely by the kidney, at a rate proportional to serum concentration and glomerular filtration. In renal impairment the dose should be reduced.',
   E'Após administração intravenosa, o magnésio é imediatamente absorvido (biodisponibilidade completa). Cerca de 1–2% do magnésio corporal total está no líquido extracelular; liga-se 30% à albumina.',
   E'After intravenous administration, magnesium is immediately absorbed (complete bioavailability). About 1–2% of total body magnesium is in the extracellular fluid; it is 30% bound to albumin.',
   E'A meia-vida sérica é de cerca de 4 horas após infusão; a eliminação renal ajusta-se rapidamente. Em doentes com função renal normal, o excesso é excretado em horas.',
   E'Serum half-life is about 4 hours after infusion; renal elimination adjusts rapidly. In patients with normal renal function, the excess is excreted within hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Magnesium Sulfate Injection (Civica): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5a9f565-639c-4b22-b9e5-718bac7cfcf3 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Magnésio, 11.3.2.1.2',
   'DailyMed/FDA (NIH/NLM) — approved Magnesium Sulfate Injection label (Civica): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a5a9f565-639c-4b22-b9e5-718bac7cfcf3 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Magnesium, 11.3.2.1.2'),

  ('zinco',
   E'Oligoelemento essencial, cofator de mais de 70 enzimas; facilita a cicatrização de feridas, ajuda a manter o crescimento normal, a hidratação da pele e os sentidos do paladar e do olfato.',
   E'Essential trace element, cofactor of more than 70 enzymes; facilitates wound healing, helps maintain normal growth, skin hydration and the senses of taste and smell.',
   E'Cofator enzimático estrutural e catalítico: participa na atividade da anidrase carbónica, fosfatase alcalina, lactato desidrogenase e RNA/DNA polimerases; estabiliza estruturas proteicas (dedos de zinco) e modula a resposta imunitária.',
   E'Structural and catalytic enzyme cofactor: participates in the activity of carbonic anhydrase, alkaline phosphatase, lactate dehydrogenase and RNA/DNA polymerases; stabilises protein structures (zinc fingers) and modulates the immune response.',
   E'O zinco não é metabolizado significativamente; é excretado principalmente nas fezes (via bílis e secreção intestinal) e, em menor grau, na urina.',
   E'Zinc is not significantly metabolised; it is excreted mainly in faeces (via bile and intestinal secretion) and, to a lesser extent, in urine.',
   E'Na nutrição parentérica é administrado por via intravenosa (biodisponibilidade completa); liga-se à albumina plasmática, à alfa-2-macroglobulina e a aminoácidos plasmáticos (histidina, cisteína). Distribui-se por músculo, osso, pele, rim, fígado, pâncreas, retina e próstata.',
   E'In parenteral nutrition it is given intravenously (complete bioavailability); it binds to plasma albumin, alpha-2-macroglobulin and plasma amino acids (histidine, cysteine). Distributed in muscle, bone, skin, kidney, liver, pancreas, retina and prostate.',
   E'A meia-vida sérica do zinco é de horas a dias, com um pool corporal total de cerca de 2 g e turnover lento (semanas). A cinética depende do estado nutricional e da função renal.',
   E'Serum zinc half-life is hours to days, with a total body pool of about 2 g and slow turnover (weeks). Kinetics depend on nutritional status and renal function.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Zinc Chloride Injection (Exela): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bd646d2-2a2a-4376-8da0-c7f08b0511ac',
   'DailyMed/FDA (NIH/NLM) — approved Zinc Chloride Injection label (Exela): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2bd646d2-2a2a-4376-8da0-c7f08b0511ac')
) AS v(
  slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
  metabolism_pt, metabolism_en, absorption_pt, absorption_en,
  half_life_pt, half_life_en, source_pt, source_en)
  ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- FIM — 137: 9 perfis + 9 farmacologias (nutrição/electrólitos)
-- =====================================================================
