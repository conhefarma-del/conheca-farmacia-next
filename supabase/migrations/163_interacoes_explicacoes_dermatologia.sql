-- 163: Fluxo 4 — Explicações longas dos pares do grupo 13 (Dermatologia)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en + explanation_pt/en)
-- dos 18 pares criados na migração 162.
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos de
--     risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nos rótulos já citados na migração 162
--     (setIDs validados na API DailyMed).
--
-- Fontes (DailyMed/FDA — NIH/NLM), setIDs validados a 2026-08-17:
--   Isotretinoína: d5a26c5e-9c3e-4781-8c08-62b91d21a68d
--   Acitretina:    a6546625-acb8-460e-b34e-f795bfb3680a
--   Tetraciclina:  02e88b4a-57ae-4ef6-ba48-97c657202b94
--   Minociclina:   a5fc4d50-50b2-46e0-b722-4c6b2ec47d06
--   (parceiros: setIDs da migração 162)
--
-- Âncoras confirmadas no texto dos rótulos:
--   * Isotretinoína: pseudotumor cerebri com tetraciclinas ("should be avoided");
--     fenitoína/corticosteróides "may weaken your bones".
--   * Acitretina: metotrexato + etretinato "increased risk of hepatitis...
--     contraindicated"; acitretina + tetraciclinas "combined use is
--     contraindicated" (pressão intracraneana); fenitoína "protein binding may
--     be reduced".
--   * Tetraciclina: "depress plasma prothrombin activity... anticoagulant
--     dosage"; "avoid giving tetracycline in conjunction with penicillin";
--     "absorption impaired by antacids... iron, zinc".
--   * Minociclina: mesma classe; "Administration of isotretinoin should be
--     avoided... during... minocycline therapy".
--
-- Idempotente: WHERE canónico LEAST/GREATEST. Aplicar após a migração 162.
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isotretinoína + doxiciclina: evitar a associação — risco de pseudotumor cerebri (hipertensão intracraneana benigna) por efeito aditivo.',
  summary_pro_en = 'Isotretinoin + doxycycline: avoid the combination — risk of pseudotumor cerebri (benign intracranial hypertension) by additive effect.',
  explanation_pt = 'Tanto a isotretinoína como as tetraciclinas (doxiciclina) estão associadas a casos de pseudotumor cerebri, uma hipertensão intracraneana benigna com risco de dano visual. O rótulo da isotretinoína documenta casos com uso concomitante de tetraciclinas e recomenda evitar o tratamento combinado. O mecanismo é aditivo, sem dose segura definida. Se a associação for inevitável, vigiar sinais precoces — cefaleias persistentes, náuseas, vómitos e alterações visuais — e referenciar com urgência se surgir papiledema. Na acne severa, considerar alternativas terapêuticas que não combinem as duas classes.',
  explanation_en = 'Both isotretinoin and tetracyclines (doxycycline) are associated with cases of pseudotumor cerebri, a benign intracranial hypertension with a risk of visual damage. The isotretinoin label documents cases with concomitant tetracycline use and recommends avoiding the combined treatment. The mechanism is additive, with no defined safe dose. If the combination is unavoidable, monitor early signs — persistent headache, nausea, vomiting and visual disturbances — and refer urgently if papilledema appears. In severe acne, consider therapeutic alternatives that do not combine the two classes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isotretinoína + minociclina: evitar a administração durante e logo após a minociclina — risco de pseudotumor cerebri.',
  summary_pro_en = 'Isotretinoin + minocycline: avoid administration during and shortly after minocycline — risk of pseudotumor cerebri.',
  explanation_pt = 'O rótulo da minociclina é explícito: a administração de isotretinoína deve ser evitada pouco antes, durante e pouco depois da terapêutica com minociclina, porque cada fármaco, isoladamente, está associado a pseudotumor cerebri. O risco é de efeito aditivo na pressão intracraneana, com potencial de dano visual permanente se não for reconhecido. Em doentes que necessitem de ambas as terapêuticas em momentos diferentes da evolução da acne, deve garantir-se um intervalo sem sobreposição e vigiar cefaleias, vómitos e alterações visuais, encaminhando com urgência qualquer suspeita de papiledema.',
  explanation_en = 'The minocycline label is explicit: isotretinoin administration should be avoided shortly before, during and shortly after minocycline therapy, because each drug alone is associated with pseudotumor cerebri. The risk is an additive effect on intracranial pressure, with the potential for permanent visual damage if unrecognized. In patients who need both therapies at different times in the course of acne, a non-overlapping interval should be ensured and headache, vomiting and visual disturbances monitored, with urgent referral for any suspicion of papilledema.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'minociclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'minociclina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isotretinoína + fenitoína: precaução — possível efeito aditivo na perda óssea (osteomalácia da fenitoína).',
  summary_pro_en = 'Isotretinoin + phenytoin: caution — possible additive effect on bone loss (phenytoin osteomalacia).',
  explanation_pt = 'A fenitoína é conhecida por causar osteomalácia e a isotretinoína também pode afetar o metabolismo ósseo, sobretudo em adolescentes em fase de crescimento. O rótulo da isotretinoína não encontrou alteração da farmacocinética da fenitoína, mas não foram conduzidos estudos formais sobre o efeito interativo na perda óssea e recomenda precaução. O risco é maior em tratamentos prolongados, doentes com osteoporose, anorexia nervosa ou terapêutica crónica que afete a vitamina D. Considerar vigilância da saúde óssea e reavaliar a necessidade de cada fármaco em tratamentos longos.',
  explanation_en = 'Phenytoin is known to cause osteomalacia and isotretinoin may also affect bone metabolism, especially in growing adolescents. The isotretinoin label found no change in phenytoin pharmacokinetics, but no formal studies assessed the interactive effect on bone loss and caution is recommended. The risk is higher in prolonged treatment, osteoporosis, anorexia nervosa or chronic therapy affecting vitamin D. Consider bone health monitoring and reassess the need for each drug during long-term treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isotretinoína + prednisolona: precaução — os corticosteróides sistémicos podem aumentar a perda óssea com a isotretinoína.',
  summary_pro_en = 'Isotretinoin + prednisolone: caution — systemic corticosteroids may increase bone loss with isotretinoin.',
  explanation_pt = 'Os corticosteróides sistémicos, como a prednisolona, podem induzir osteoporose e osteomalácia, sobretudo em terapêuticas prolongadas. O rótulo da isotretinoína alerta que fármacos que causam osteoporose/osteomalácia induzida, incluindo corticosteróides sistémicos, colocam o doente em risco acrescido de perda óssea e fraturas quando usados em conjunto. O risco é particularmente relevante em adolescentes e em doentes que pratiquem desporto de impacto. Usar a menor dose e a menor duração possível de corticosteróide, considerar a suplementação de cálcio/vitamina D conforme o caso e vigiar sintomas osteomusculares.',
  explanation_en = 'Systemic corticosteroids, such as prednisolone, may induce osteoporosis and osteomalacia, especially in prolonged therapy. The isotretinoin label warns that drugs causing drug-induced osteoporosis/osteomalacia, including systemic corticosteroids, place the patient at increased risk of bone loss and fractures when used together. The risk is particularly relevant in adolescents and in patients practising impact sports. Use the lowest corticosteroid dose and shortest duration possible, consider calcium/vitamin D supplementation as appropriate and monitor musculoskeletal symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'isotretinoina'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Acitretina + metotrexato: CONTRAINDICADO — risco aumentado de hepatite com a combinação.',
  summary_pro_en = 'Acitretin + methotrexate: CONTRAINDICATED — increased risk of hepatitis with the combination.',
  explanation_pt = 'O rótulo da acitretina é explícito: foi reportado um risco aumentado de hepatite com o uso combinado de metotrexato e etretinato (o precursor da acitretina) e, consequentemente, a combinação de metotrexato com acitretina está contraindicada. Ambos os fármacos são hepatotóxicos potenciais e o risco de lesão hepática é aditivo. Na psoríase grave, se o metotrexato for uma opção, a acitretina não deve ser usada em conjunto; considerar monoterapia ou alternativa (ex.: fototerapia, biológicos) e vigiar a função hepática em qualquer exposição acidental.',
  explanation_en = 'The acitretin label is explicit: an increased risk of hepatitis has been reported with the combined use of methotrexate and etretinate (the precursor of acitretin) and, consequently, the combination of methotrexate with acitretin is contraindicated. Both drugs are potentially hepatotoxic and the risk of liver injury is additive. In severe psoriasis, if methotrexate is an option, acitretin should not be used together; consider monotherapy or an alternative (e.g., phototherapy, biologics) and monitor liver function after any accidental exposure.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Acitretina + doxiciclina: CONTRAINDICADO — ambas podem causar aumento da pressão intracraneana.',
  summary_pro_en = 'Acitretin + doxycycline: CONTRAINDICATED — both may cause increased intracranial pressure.',
  explanation_pt = 'O rótulo da acitretina indica que, como tanto a acitretina como as tetraciclinas podem causar aumento da pressão intracraneana (pseudotumor cerebri), o seu uso combinado está contraindicado. A doxiciclina é a tetraciclina mais usada na dermatologia, pelo que o par é o mais relevante da classe. Em psoríase que necessite de acitretina e infeção que exija tetraciclina, escolher uma classe antibiótica alternativa e vigiar cefaleias persistentes, náuseas e alterações visuais em caso de exposição acidental.',
  explanation_en = 'The acitretin label states that, since both acitretin and tetracyclines can cause increased intracranial pressure (pseudotumor cerebri), their combined use is contraindicated. Doxycycline is the most commonly used tetracycline in dermatology, making this the most relevant pair of the class. In psoriasis requiring acitretin and an infection requiring a tetracycline, choose an alternative antibiotic class and monitor persistent headache, nausea and visual disturbances after accidental exposure.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Acitretina + fenitoína: a acitretina pode reduzir a ligação proteica da fenitoína, aumentando a fração livre.',
  summary_pro_en = 'Acitretin + phenytoin: acitretin may reduce phenytoin protein binding, increasing the free fraction.',
  explanation_pt = 'Quando a acitretina é administrada com fenitoína, a ligação proteica da fenitoína pode ser reduzida, aumentando a fração livre farmacologicamente ativa e o potencial de toxicidade. A fenitoína tem índice terapêutico estreito, pelo que um aumento da fração livre pode provocar nistagmo, ataxia e sonolência mesmo com níveis totais aparentemente normais. Usar com precaução, considerar a monitorização da fenitoína livre e vigiar sinais clínicos de toxicidade, sobretudo no início da associação.',
  explanation_en = 'When acitretin is given with phenytoin, the protein binding of phenytoin may be reduced, increasing the pharmacologically active free fraction and the potential for toxicity. Phenytoin has a narrow therapeutic index, so an increase in the free fraction may cause nystagmus, ataxia and drowsiness even with apparently normal total levels. Use with caution, consider monitoring free phenytoin and watch for clinical signs of toxicity, especially when starting the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acitretina'), (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + varfarina: as tetraciclinas deprimem a protrombina — ajustar a dose do anticoagulante e vigiar o INR.',
  summary_pro_en = 'Tetracycline + warfarin: tetracyclines depress prothrombin — adjust the anticoagulant dose and monitor INR.',
  explanation_pt = 'As tetraciclinas demonstraram deprimir a atividade da protrombina plasmática, potenciando o efeito dos anticoagulantes orais como a varfarina. Em doentes em terapêutica anticoagulante que iniciem tetraciclina, pode ser necessário reduzir a dose do anticoagulante. O INR deve ser vigiado de perto no início e no fim do antibiótico, e o doente alertado para sinais de hemorragia — sangramento gengival, hematomas ou fezes escuras. A interação é relevante sobretudo em idosos e doentes com INR instável.',
  explanation_en = 'Tetracyclines have been shown to depress plasma prothrombin activity, potentiating the effect of oral anticoagulants such as warfarin. In patients on anticoagulant therapy starting a tetracycline, a downward adjustment of the anticoagulant dose may be required. The INR should be closely monitored at the start and end of the antibiotic, and the patient alerted to signs of bleeding — gum bleeding, bruising or dark stools. The interaction is especially relevant in the elderly and in patients with unstable INR.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + ampicilina: evitar — o efeito bacteriostático da tetraciclina pode interferir com a ação bactericida da penicilina.',
  summary_pro_en = 'Tetracycline + ampicillin: avoid — the bacteriostatic effect of tetracycline may interfere with the bactericidal action of penicillin.',
  explanation_pt = 'Os fármacos bacteriostáticos, como a tetraciclina, podem interferir com a ação bactericida das penicilinas (ampicilina), reduzindo a eficácia do tratamento de infeções graves. O rótulo da tetraciclina aconselha a evitar a associação com penicilinas. Na prática, a combinação é por vezes usada de forma intencional em infeções mistas; nesses casos, considerar o antagonismo potencial e, sempre que possível, escolher uma alternativa ou separar o esquema. Vigiar a resposta clínica à infeção.',
  explanation_en = 'Bacteriostatic drugs, such as tetracycline, may interfere with the bactericidal action of penicillins (ampicillin), reducing the effectiveness of treatment for serious infections. The tetracycline label advises avoiding the combination with penicillins. In practice, the combination is sometimes used intentionally in mixed infections; in those cases, consider the potential antagonism and, whenever possible, choose an alternative or separate the regimen. Monitor the clinical response of the infection.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'ampicilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'ampicilina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + antiácidos: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Tetracycline + antacids: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'Os antiácidos contendo alumínio, cálcio ou magnésio quelam a tetraciclina no lúmen gastrointestinal, formando complexos insolúveis que reduzem a absorção e a eficácia do antibiótico. O rótulo da tetraciclina documenta esta interação. A solução prática é separar a toma da tetraciclina dos antiácidos por pelo menos 2–4 horas, preferindo a tetraciclina em jejum. Em infeções urinárias ou sistémicas, uma absorção reduzida pode comprometer a erradicação bacteriana; vigiar a resposta clínica.',
  explanation_en = 'Antacids containing aluminum, calcium or magnesium chelate tetracycline in the gastrointestinal lumen, forming insoluble complexes that reduce absorption and the effectiveness of the antibiotic. The tetracycline label documents this interaction. The practical solution is to separate tetracycline dosing from antacids by at least 2–4 hours, preferring tetracycline on an empty stomach. In urinary or systemic infections, reduced absorption may compromise bacterial eradication; monitor the clinical response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + zinco: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Tetracycline + zinc: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'As preparações contendo zinco quelam a tetraciclina no intestino, reduzindo a sua absorção e a eficácia antibiótica — interação documentada no rótulo da tetraciclina. A separação das tomas por pelo menos 2–4 horas minimiza o problema. Relevante em doentes que usam suplementos de zinco (comum na dermatologia e na suplementação) ou em formulações multivitamínicas. Vigiar a resposta à terapêutica antibiótica.',
  explanation_en = 'Preparations containing zinc chelate tetracycline in the gut, reducing its absorption and antibiotic efficacy — an interaction documented in the tetracycline label. Separating dosing by at least 2–4 hours minimizes the problem. Relevant in patients taking zinc supplements (common in dermatology and supplementation) or multivitamin formulations. Monitor the response to antibiotic therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + ferro: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Tetracycline + iron: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'As preparações contendo ferro quelam a tetraciclina no lúmen gastrointestinal, reduzindo a sua absorção e eficácia — interação documentada no rótulo. É especialmente relevante em doentes com anemia ferropénica tratados com sulfato ferroso. Separar a toma da tetraciclina do ferro por pelo menos 2–4 horas e, idealmente, tomar a tetraciclina em jejum. Vigiar a resposta clínica à infeção, sobretudo em infeções urinárias.',
  explanation_en = 'Preparations containing iron chelate tetracycline in the gastrointestinal lumen, reducing its absorption and efficacy — an interaction documented in the label. It is especially relevant in patients with iron-deficiency anaemia treated with ferrous sulfate. Separate tetracycline dosing from iron by at least 2–4 hours and, ideally, take tetracycline on an empty stomach. Monitor the clinical response to infection, especially in urinary tract infections.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Tetraciclina + cálcio: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Tetracycline + calcium: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'Os produtos contendo cálcio (antiácidos, suplementos, leite em grandes quantidades) quelam a tetraciclina no lúmen gastrointestinal, reduzindo a sua absorção e eficácia — interação documentada no rótulo. Separar as tomas por pelo menos 2–4 horas. Relevante em doentes com suplementação de cálcio (osteoporose) ou terapêutica antiácida prolongada. Vigiar a resposta à terapêutica antibiótica.',
  explanation_en = 'Calcium-containing products (antacids, supplements, large amounts of milk) chelate tetracycline in the gastrointestinal lumen, reducing its absorption and efficacy — an interaction documented in the label. Separate dosing by at least 2–4 hours. Relevant in patients on calcium supplementation (osteoporosis) or prolonged antacid therapy. Monitor the response to antibiotic therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'tetraciclina'), (SELECT id FROM public.drugs WHERE slug = 'carbonato_calcio'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Minociclina + varfarina: as tetraciclinas deprimem a protrombina — ajustar a dose do anticoagulante e vigiar o INR.',
  summary_pro_en = 'Minocycline + warfarin: tetracyclines depress prothrombin — adjust the anticoagulant dose and monitor INR.',
  explanation_pt = 'Tal como as restantes tetraciclinas, a minociclina pode deprimir a atividade da protrombina plasmática e potenciar o efeito dos anticoagulantes orais. Em doentes em varfarina que iniciem minociclina, o INR deve ser vigiado no início e no fim do antibiótico, com ajuste da dose do anticoagulante conforme necessário. Alertar o doente para sinais de hemorragia (sangramento gengival, hematomas, fezes escuras), sobretudo em idosos ou com INR instável.',
  explanation_en = 'Like other tetracyclines, minocycline may depress plasma prothrombin activity and potentiate the effect of oral anticoagulants. In patients on warfarin starting minocycline, the INR should be monitored at the start and end of the antibiotic, with adjustment of the anticoagulant dose as needed. Alert the patient to signs of bleeding (gum bleeding, bruising, dark stools), especially in the elderly or those with unstable INR.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Minociclina + ampicilina: evitar — o efeito bacteriostático pode interferir com a ação bactericida da penicilina.',
  summary_pro_en = 'Minocycline + ampicillin: avoid — the bacteriostatic effect may interfere with the bactericidal action of penicillin.',
  explanation_pt = 'Como fármaco bacteriostático da classe das tetraciclinas, a minociclina pode interferir com a ação bactericida das penicilinas, como a ampicilina. O rótulo da minociclina aconselha a evitar a associação com penicilinas. Em infeções mistas em que a combinação seja considerada, ponderar o antagonismo potencial e vigiar a resposta clínica. Sempre que possível, escolher um antibiótico alternativo ou separar os esquemas terapêuticos.',
  explanation_en = 'As a bacteriostatic drug of the tetracycline class, minocycline may interfere with the bactericidal action of penicillins, such as ampicillin. The minocycline label advises avoiding the combination with penicillins. In mixed infections where the combination is considered, weigh the potential antagonism and monitor the clinical response. Whenever possible, choose an alternative antibiotic or separate the therapeutic regimens.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'ampicilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'ampicilina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Minociclina + antiácidos: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Minocycline + antacids: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'Os antiácidos com alumínio, cálcio ou magnésio quelam a minociclina no lúmen gastrointestinal, reduzindo a absorção e a eficácia do antibiótico. O rótulo da minociclina documenta a redução de absorção com antiácidos. Separar as tomas por pelo menos 2–4 horas. Relevante em doentes com dispepsia tratados com antiácidos ou com suplementos de cálcio. Vigiar a resposta clínica à infeção.',
  explanation_en = 'Antacids with aluminum, calcium or magnesium chelate minocycline in the gastrointestinal lumen, reducing absorption and antibiotic efficacy. The minocycline label documents reduced absorption with antacids. Separate dosing by at least 2–4 hours. Relevant in patients with dyspepsia treated with antacids or with calcium supplements. Monitor the clinical response to infection.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Minociclina + zinco: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Minocycline + zinc: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'As preparações contendo zinco quelam a minociclina no intestino, reduzindo a sua absorção e eficácia. A classe das tetraciclinas tem esta interação documentada no rótulo (absorção comprometida por preparações com zinco). Separar as tomas por pelo menos 2–4 horas. Relevante em doentes com suplementação de zinco, comum na dermatologia. Vigiar a resposta à terapêutica antibiótica.',
  explanation_en = 'Preparations containing zinc chelate minocycline in the gut, reducing its absorption and efficacy. The tetracycline class has this interaction documented in the label (absorption impaired by zinc-containing preparations). Separate dosing by at least 2–4 hours. Relevant in patients with zinc supplementation, common in dermatology. Monitor the response to antibiotic therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'zinco'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Minociclina + ferro: a absorção fica comprometida por quelação — separar as tomas por 2–4 horas.',
  summary_pro_en = 'Minocycline + iron: absorption is impaired by chelation — separate dosing by 2–4 hours.',
  explanation_pt = 'As preparações contendo ferro quelam a minociclina no lúmen gastrointestinal, reduzindo a sua absorção e eficácia — interação documentada na classe das tetraciclinas. Relevante em doentes com anemia ferropénica tratados com sulfato ferroso. Separar as tomas por pelo menos 2–4 horas e, idealmente, tomar a minociclina em jejum. Vigiar a resposta clínica à infeção.',
  explanation_en = 'Preparations containing iron chelate minocycline in the gastrointestinal lumen, reducing its absorption and efficacy — an interaction documented in the tetracycline class. Relevant in patients with iron-deficiency anaemia treated with ferrous sulfate. Separate dosing by at least 2–4 hours and, ideally, take minocycline on an empty stomach. Monitor the clinical response to infection.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'minociclina'), (SELECT id FROM public.drugs WHERE slug = 'ferro'));
