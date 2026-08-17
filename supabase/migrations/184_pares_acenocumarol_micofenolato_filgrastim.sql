-- =====================================================================
-- 184: Pares fármaco-fármaco dos 3 fármacos sistémicos que estavam sem par
--      (auditoria dos 12 fármacos sem par — docs/INTERACOES_FLUXO_PESQUISA.md)
-- Fecha a vertente fármaco-fármaco para:
--   * Acenocumarol  (10 pares) — Prontuário QUADRO 2: "Acenocumarol: V. Varfarina"
--     (as interações documentadas da varfarina aplicam-se ao acenocumarol)
--   * Micofenolato  (4 pares)  — DailyMed CellCept secção 7.1 + Prontuário QUADRO 2
--   * Filgrastim    (1 par)    — DailyMed Neupogen (Drug Interactions)
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * conteúdo autorado e ancorado nas fontes citadas (Prontuário INFARMED
--     Anexo 7 QUADRO 2, DailyMed/FDA); sem inventar fontes ou conteúdo
--   * severidade segundo o risco clínico (critical para hemorragia aditiva,
--     moderate para os restantes)
--   * texto corrido sem \n; aspas escapadas ('' ) quando necessário
--
-- Idempotente: INSERT com ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING —
-- reaplicar é seguro. Depende dos fármacos da 173/177 (probenecida,
-- colestiramina) e de fármacos já existentes na BD.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  -- =====================================================================
  -- ACENOCUMAROL (10) — "V. Varfarina" (QUADRO 2, Anexo 7)
  -- =====================================================================

  -- Acenocumarol × Amiodarona [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'amiodarona')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'amiodarona')),
   'moderate',
   'Acenocumarol + amiodarona: a amiodarona aumenta o efeito anticoagulante do acenocumarol, com risco de hemorragia — monitorizar o INR ao iniciar ou suspender a amiodarona.',
   'Acenocoumarol + amiodarone: amiodarone increases the anticoagulant effect of acenocoumarol, with bleeding risk — monitor INR when starting or stopping amiodarone.',
   'O QUADRO 2 do Anexo 7 (Varfarina) regista a amiodarona entre os fármacos que aumentam o efeito do anticoagulante com risco de hemorragia; o acenocumarol remete para a Varfarina ("Acenocumarol: V. Varfarina"), partilhando o mesmo perfil de interações dos derivados cumarínicos. A amiodarona inibe o metabolismo dos cumarínicos (CYP2C9) e desloca-os das proteínas plasmáticas, e o efeito persiste semanas após a suspensão devido à semi-vida longa da amiodarona.',
   'QUADRO 2 of Annex 7 (Warfarin) lists amiodarone among drugs that increase the anticoagulant effect with bleeding risk; acenocoumarol refers to warfarin ("Acenocoumarol: see Warfarin"), sharing the coumarin interaction profile. Amiodarone inhibits coumarin metabolism (CYP2C9) and displaces them from plasma proteins, and the effect persists for weeks after discontinuation due to amiodarone''s long half-life.',
   'Ao iniciar amiodarona em doente estabilizado com acenocumarol, reduzir a dose do anticoagulante (tipicamente 30-50%) e ajustar pelo INR; ao suspender a amiodarona, reavaliar a dose.',
   'When starting amiodarone in a patient stabilized on acenocoumarol, reduce the anticoagulant dose (typically 30-50%) and titrate by INR; when stopping amiodarone, reassess the dose.',
   'Monitorizar o INR 3-7 dias após iniciar, ajustar ou suspender a amiodarona, e depois periodicamente.',
   'Monitor INR 3-7 days after starting, adjusting or stopping amiodarone, and periodically thereafter.',
   'INR marcadamente elevado, hemorragia ou equimoses espontâneas após início da amiodarona.',
   'Markedly elevated INR, bleeding or spontaneous bruising after starting amiodarone.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Amiodarona)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Amiodarone)', 'published', now()),

  -- Acenocumarol × Diclofenac [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'diclofenac')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'diclofenac')),
   'moderate',
   'Acenocumarol + diclofenac: o diclofenac aumenta a resposta hipoprotrombinémica e agride a mucosa gástrica — risco hemorrágico aumentado.',
   'Acenocoumarol + diclofenac: diclofenac increases the hypoprothrombinemic response and irritates the gastric mucosa — increased bleeding risk.',
   'O QUADRO 2 (Varfarina) regista que "alguns agentes aumentam a resposta hipoprotrombinémica (diclofenac, ibuprofeno, cetorolac)". O diclofenac associa o efeito farmacodinâmico sobre a coagulação ao risco gastrolesivo dos AINEs, potenciando o risco hemorrágico dos cumarínicos.',
   'QUADRO 2 (Warfarin) records that "some agents increase the hypoprothrombinemic response (diclofenac, ibuprofen, ketorolac)". Diclofenac combines a pharmacodynamic effect on coagulation with the gastrotoxic risk of NSAIDs, potentiating the bleeding risk of coumarins.',
   'Preferir analgésicos alternativos (paracetamol em dose controlada) quando possível; se o diclofenac for inevitável, usar a menor dose e a menor duração, com proteção gástrica.',
   'Prefer alternative analgesics (paracetamol at controlled dose) when possible; if diclofenac is unavoidable, use the lowest dose and shortest duration, with gastric protection.',
   'Monitorizar o INR e sinais de hemorragia digestiva durante a co-administração.',
   'Monitor INR and signs of gastrointestinal bleeding during co-administration.',
   'Hematoquézia, melenas, INR elevado ou queda da hemoglobina com uso concomitante.',
   'Haematochezia, melaena, elevated INR or falling haemoglobin with concomitant use.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin)', 'published', now()),

  -- Acenocumarol × Cimetidina [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'cimetidina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'cimetidina')),
   'moderate',
   'Acenocumarol + cimetidina: a cimetidina inibe o metabolismo dos cumarínicos e aumenta o INR — risco hemorrágico; monitorizar ao iniciar, ajustar ou suspender.',
   'Acenocoumarol + cimetidine: cimetidine inhibits coumarin metabolism and increases INR — bleeding risk; monitor when starting, adjusting or stopping.',
   'O QUADRO 2 (Varfarina) lista a cimetidina entre os fármacos que aumentam o efeito do anticoagulante com risco de hemorragia. A cimetidina inibe as enzimas CYP (incluindo CYP2C9 e CYP3A4) responsáveis pelo metabolismo dos derivados cumarínicos, elevando as concentrações e o efeito anticoagulante.',
   'QUADRO 2 (Warfarin) lists cimetidine among drugs that increase the anticoagulant effect with bleeding risk. Cimetidine inhibits the CYP enzymes (including CYP2C9 and CYP3A4) responsible for coumarin metabolism, raising concentrations and anticoagulant effect.',
   'Considerar um antagonista H2 alternativo (ex.: famotidina) que não inibe o CYP; se a cimetidina for mantida, vigiar o INR e reduzir a dose do anticoagulante se necessário.',
   'Consider an alternative H2 antagonist (e.g. famotidine) that does not inhibit CYP; if cimetidine is kept, watch INR and reduce the anticoagulant dose if needed.',
   'Monitorizar o INR nos primeiros dias após iniciar ou suspender a cimetidina.',
   'Monitor INR in the first days after starting or stopping cimetidine.',
   'INR elevado ou hemorragia após início da cimetidina.',
   'Elevated INR or bleeding after starting cimetidine.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Cimetidina)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Cimetidine)', 'published', now()),

  -- Acenocumarol × Clopidogrel [critical]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'clopidogrel')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'clopidogrel')),
   'critical',
   'Acenocumarol + clopidogrel: hemorragia aditiva por dupla inibição da hemostase — evitar salvo indicação formal (ex.: stent) com monitorização apertada.',
   'Acenocoumarol + clopidogrel: additive bleeding from dual haemostasis inhibition — avoid unless formally indicated (e.g. stent) with tight monitoring.',
   'O QUADRO 2 (Varfarina) lista o clopidogrel entre os fármacos que aumentam o efeito do anticoagulante com risco de hemorragia. A associação de um cumarínico com um antiagregante plaquetar inibe duas vias da hemostase (coagulação e plaquetas), com risco hemorrágico aditivo significativo.',
   'QUADRO 2 (Warfarin) lists clopidogrel among drugs that increase the anticoagulant effect with bleeding risk. Combining a coumarin with an antiplatelet agent inhibits two haemostatic pathways (coagulation and platelets), with significant additive bleeding risk.',
   'Evitar a associação sempre que possível; quando indispensável (síndrome coronária aguda com stent em doente com indicação de anticoagulação), usar a menor duração de dupla terapêutica e doses tituladas pelo INR.',
   'Avoid the combination whenever possible; when essential (acute coronary syndrome with stent in a patient with anticoagulation indication), use the shortest duration of dual therapy and INR-titrated doses.',
   'Monitorização clínica apertada de sinais hemorrágicos e INR mais frequente.',
   'Close clinical monitoring of bleeding signs and more frequent INR.',
   'Hemorragia major, hemorragia intracraniana ou digestiva com a associação.',
   'Major bleeding, intracranial or gastrointestinal haemorrhage with the combination.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Clopidogrel)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Clopidogrel)', 'published', now()),

  -- Acenocumarol × Paracetamol [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'paracetamol')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'paracetamol')),
   'moderate',
   'Acenocumarol + paracetamol: doses elevadas ou uso prolongado de paracetamol podem potenciar o efeito anticoagulante — limitar a dose e vigiar o INR.',
   'Acenocoumarol + paracetamol: high doses or prolonged paracetamol use may potentiate the anticoagulant effect — limit the dose and watch INR.',
   'O QUADRO 2 (Varfarina) regista que o paracetamol "impede a síntese de factores da coagulação", potenciando o efeito do anticoagulante. A interação é dose-dependente, tornando-se clinicamente relevante sobretudo com doses elevadas (ex.: >2 g/dia) ou uso crónico.',
   'QUADRO 2 (Warfarin) records that paracetamol "prevents the synthesis of coagulation factors", potentiating the anticoagulant effect. The interaction is dose-dependent, becoming clinically relevant mainly with high doses (e.g. >2 g/day) or chronic use.',
   'Usar a menor dose eficaz de paracetamol e por curto prazo; em uso crónico, monitorizar o INR.',
   'Use the lowest effective paracetamol dose for the shortest time; with chronic use, monitor INR.',
   'Vigiar o INR em doentes que usam paracetamol diariamente em doses elevadas.',
   'Watch INR in patients using paracetamol daily at high doses.',
   'INR elevado inexplicado em doente com uso diário de paracetamol.',
   'Unexplained elevated INR in a patient with daily paracetamol use.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Paracetamol)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Paracetamol)', 'published', now()),

  -- Acenocumarol × Aspirina [critical]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'aspirina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'aspirina')),
   'critical',
   'Acenocumarol + aspirina: hemorragia aditiva (inibição plaquetar + efeito hipoprotrombinémico em doses elevadas) — evitar salvo indicação cardiovascular formal.',
   'Acenocoumarol + aspirin: additive bleeding (platelet inhibition + hypoprothrombinemic effect at high doses) — avoid unless formally indicated for cardiovascular disease.',
   'O QUADRO 2 (Varfarina) regista: "Salicilatos: inibição plaquetar com o ácido acetilsalicílico... em doses elevadas possuem efeito hipoprotrombinémico". A aspirina acrescenta à anticoagulação a inibição irreversível das plaquetas, com risco hemorrágico aditivo, sobretudo digestivo.',
   'QUADRO 2 (Warfarin) records: "Salicylates: platelet inhibition with acetylsalicylic acid... at high doses they have a hypoprothrombinemic effect". Aspirin adds irreversible platelet inhibition to anticoagulation, with additive bleeding risk, especially gastrointestinal.',
   'Evitar a associação; se a aspirina em baixa dose for clinicamente indispensável (ex.: doença coronária), adicionar proteção gástrica e vigiar de perto o INR e sinais hemorrágicos.',
   'Avoid the combination; if low-dose aspirin is clinically essential (e.g. coronary disease), add gastric protection and closely watch INR and bleeding signs.',
   'Monitorização de sinais de hemorragia digestiva e INR mais frequente durante a associação.',
   'Monitor for signs of gastrointestinal bleeding and more frequent INR during the combination.',
   'Melenas, hematoquézia, hematemese ou INR muito elevado com a associação.',
   'Melaena, haematochezia, haematemesis or very high INR with the combination.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Salicilatos)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Salicylates)', 'published', now()),

  -- Acenocumarol × Cotrimoxazol [critical]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol')),
   'critical',
   'Acenocumarol + cotrimoxazol: o sulfametoxazol-trimetoprim inibe o metabolismo do cumarínico e desloca-o das proteínas — aumento marcado do INR e risco hemorrágico.',
   'Acenocoumarol + cotrimoxazole: sulfamethoxazole-trimethoprim inhibits coumarin metabolism and displaces it from proteins — marked INR increase and bleeding risk.',
   'O QUADRO 2 (Varfarina) regista: "Sulfametoxazol + Trimetoprim: inibem o metabolismo da varfarina e deslocam-na da proteína de transporte". O cotrimoxazol combina a inibição enzimática com o deslocamento proteico, provocando um aumento rápido e por vezes acentuado do efeito anticoagulante.',
   'QUADRO 2 (Warfarin) records: "Sulfamethoxazole + Trimethoprim: inhibit warfarin metabolism and displace it from the transport protein". Cotrimoxazole combines enzyme inhibition with protein displacement, causing a rapid and sometimes marked increase in the anticoagulant effect.',
   'Evitar o cotrimoxazol em doentes sob cumarínicos quando existir alternativa; se inevitável, reduzir preventivamente a dose do anticoagulante e vigiar o INR de forma apertada.',
   'Avoid cotrimoxazole in patients on coumarins when an alternative exists; if unavoidable, preventively reduce the anticoagulant dose and monitor INR closely.',
   'Monitorizar o INR 2-4 dias após iniciar o cotrimoxazol e após a suspensão.',
   'Monitor INR 2-4 days after starting cotrimoxazole and after stopping it.',
   'INR muito elevado, hemorragia ou equimoses extensas durante ou após o antibiótico.',
   'Very high INR, bleeding or extensive bruising during or after the antibiotic.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Sulfametoxazol + Trimetoprim)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Sulfamethoxazole + Trimethoprim)', 'published', now()),

  -- Acenocumarol × Levotiroxina [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'levotiroxina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'levotiroxina')),
   'moderate',
   'Acenocumarol + levotiroxina: a tiroxina acelera o catabolismo dos factores da coagulação e pode reduzir o efeito anticoagulante — vigiar o INR quando se altera a dose da tiroxina.',
   'Acenocoumarol + levothyroxine: thyroxine accelerates coagulation factor catabolism and may reduce the anticoagulant effect — watch INR when the thyroxine dose changes.',
   'O QUADRO 2 (Varfarina) regista: "Tiroxina: acelera o catabolismo dos factores da coagulação". O aumento do catabolismo dos factores dependentes da vitamina K reduz o efeito anticoagulante; inversamente, a suspensão ou redução da tiroxina pode aumentá-lo.',
   'QUADRO 2 (Warfarin) records: "Thyroxine: accelerates the catabolism of coagulation factors". Increased catabolism of vitamin K-dependent factors reduces the anticoagulant effect; conversely, stopping or reducing thyroxine may increase it.',
   'Ao iniciar, ajustar ou suspender a levotiroxina, vigiar o INR e ajustar a dose do anticoagulante em conformidade.',
   'When starting, adjusting or stopping levothyroxine, monitor INR and adjust the anticoagulant dose accordingly.',
   'Monitorizar o INR sempre que houver alteração da dose de levotiroxina.',
   'Monitor INR whenever the levothyroxine dose changes.',
   'INR subitamente baixo após iniciar tiroxina ou INR elevado após a reduzir.',
   'Suddenly low INR after starting thyroxine or high INR after reducing it.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Tiroxina)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Thyroxine)', 'published', now()),

  -- Acenocumarol × Propafenona [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'propafenona')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'propafenona')),
   'moderate',
   'Acenocumarol + propafenona: a propafenona reduz provavelmente o metabolismo do anticoagulante — pode aumentar o INR; vigiar ao iniciar ou suspender.',
   'Acenocoumarol + propafenone: propafenone probably reduces anticoagulant metabolism — may increase INR; watch when starting or stopping.',
   'O QUADRO 2 (Varfarina) regista que a propafenona "reduz provavelmente o metabolismo do anticoagulante". A inibição enzimática da propafenona pode elevar as concentrações do cumarínico e potenciar o efeito anticoagulante.',
   'QUADRO 2 (Warfarin) records that propafenone "probably reduces the metabolism of the anticoagulant". Propafenone''s enzyme inhibition may raise coumarin concentrations and potentiate the anticoagulant effect.',
   'Ao iniciar a propafenona, reduzir preventivamente a dose do anticoagulante e ajustar pelo INR; reavaliar ao suspender.',
   'When starting propafenone, preventively reduce the anticoagulant dose and titrate by INR; reassess when stopping.',
   'Monitorizar o INR nos primeiros dias após iniciar ou suspender a propafenona.',
   'Monitor INR in the first days after starting or stopping propafenone.',
   'INR elevado ou hemorragia após início da propafenona.',
   'Elevated INR or bleeding after starting propafenone.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Propafenona)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Propafenone)', 'published', now()),

  -- Acenocumarol × Alopurinol [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
        (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'acenocumarol'),
            (SELECT id FROM public.drugs WHERE slug = 'alopurinol')),
   'moderate',
   'Acenocumarol + alopurinol: o alopurinol pode potenciar o efeito anticoagulante dos cumarínicos — vigiar o INR ao iniciar o alopurinol.',
   'Acenocoumarol + allopurinol: allopurinol may potentiate the anticoagulant effect of coumarins — watch INR when starting allopurinol.',
   'O QUADRO 2 (Varfarina) remete explicitamente "V. também: Álcool, Alopurinol", reconhecendo a potencial interação do alopurinol com os anticoagulantes cumarínicos (aumento do efeito anticoagulante, possivelmente por inibição metabólica).',
   'QUADRO 2 (Warfarin) explicitly refers "See also: Alcohol, Allopurinol", recognising the potential interaction of allopurinol with coumarin anticoagulants (increased anticoagulant effect, possibly via metabolic inhibition).',
   'Ao iniciar o alopurinol, vigiar o INR e ajustar a dose do anticoagulante se necessário.',
   'When starting allopurinol, monitor INR and adjust the anticoagulant dose if needed.',
   'Monitorizar o INR após iniciar ou alterar a dose de alopurinol.',
   'Monitor INR after starting or changing the allopurinol dose.',
   'INR elevado ou hemorragia após início do alopurinol.',
   'Elevated INR or bleeding after starting allopurinol.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina; Alopurinol)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin; Allopurinol)', 'published', now()),

  -- =====================================================================
  -- MICOFENOLATO (4) — DailyMed CellCept 7.1 + Prontuário QUADRO 2
  -- =====================================================================

  -- Micofenolato × Colestiramina [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
        (SELECT id FROM public.drugs WHERE slug = 'colestiramina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
            (SELECT id FROM public.drugs WHERE slug = 'colestiramina')),
   'moderate',
   'Micofenolato + colestiramina: a colestiramina liga-se ao micofenolato no intestino e reduz a sua absorção, podendo diminuir a exposição ao fármaco — separar as tomas.',
   'Mycophenolate + cholestyramine: cholestyramine binds mycophenolate in the gut and reduces its absorption, potentially decreasing drug exposure — separate doses.',
   'O DailyMed (CellCept) documenta interações estudadas com colestiramina, e o QUADRO 2 do Prontuário (Ácidos biliares — resinas sequestradoras) lista o micofenolato entre os fármacos cuja absorção pode ser reduzida pelas resinas. A colestiramina liga-se no lúmen intestinal ao micofenolato e interfere com a circulação entero-hepática do ácido micofenólico, reduzindo a exposição sistémica.',
   'DailyMed (CellCept) documents interaction studies with cholestyramine, and QUADRO 2 of the Prontuário (Bile acids — sequestering resins) lists mycophenolate among drugs whose absorption can be reduced by the resins. Cholestyramine binds mycophenolate in the gut lumen and interferes with the enterohepatic recirculation of mycophenolic acid, reducing systemic exposure.',
   'Administrar o micofenolato pelo menos 1-2 horas antes ou 4 horas depois da colestiramina; idealmente usar as duas tomas o mais espaçadas possível.',
   'Give mycophenolate at least 1-2 hours before or 4 hours after cholestyramine; ideally space the two doses as far apart as possible.',
   'Vigiar a eficácia imunossupressora (níveis de MPA quando disponíveis; sinais de rejeição) durante a associação.',
   'Watch immunosuppressive efficacy (MPA levels when available; signs of rejection) during the combination.',
   'Sinais de rejeição do enxerto ou níveis de MPA abaixo do alvo com toma simultânea.',
   'Signs of graft rejection or MPA levels below target with simultaneous intake.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado CellCept (Genentech), secção 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ácidos biliares — resinas sequestradoras)',
   'DailyMed/FDA (NIH/NLM) — approved CellCept label (Genentech), section 7.1: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Bile acids — sequestering resins)', 'published', now()),

  -- Micofenolato × Ferro [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
        (SELECT id FROM public.drugs WHERE slug = 'ferro')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
            (SELECT id FROM public.drugs WHERE slug = 'ferro')),
   'moderate',
   'Micofenolato + ferro: o ferro reduz a absorção oral do micofenolato, podendo diminuir a exposição — separar as tomas por pelo menos 2 horas.',
   'Mycophenolate + iron: iron reduces oral mycophenolate absorption, potentially decreasing exposure — separate doses by at least 2 hours.',
   'O QUADRO 2 do Prontuário (Ferro) lista o micofenolato entre os fármacos cuja absorção é reduzida com o ferro ("Fármacos cuja absorção é reduzida com o ferro: ... Micofenolato"). A quelação no lúmen intestinal com os sais de ferro reduz a biodisponibilidade oral do micofenolato.',
   'QUADRO 2 of the Prontuário (Iron) lists mycophenolate among drugs whose absorption is reduced with iron ("Drugs whose absorption is reduced with iron: ... Mycophenolate"). Chelation in the gut lumen with iron salts reduces the oral bioavailability of mycophenolate.',
   'Administrar o micofenolato e o ferro separados por pelo menos 2 horas; idealmente tomar o ferro a uma hora diferente do micofenolato.',
   'Give mycophenolate and iron at least 2 hours apart; ideally take iron at a different time of day from mycophenolate.',
   'Vigiar a eficácia imunossupressora durante a suplementação com ferro.',
   'Watch immunosuppressive efficacy during iron supplementation.',
   'Sinais de rejeição ou níveis de MPA abaixo do alvo com toma simultânea de ferro.',
   'Signs of rejection or MPA levels below target with simultaneous iron intake.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Ferro) ; DailyMed/FDA (NIH/NLM) — rótulo aprovado CellCept (Genentech): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Iron) ; DailyMed/FDA (NIH/NLM) — approved CellCept label (Genentech): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40', 'published', now()),

  -- Micofenolato × Probenecida [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
        (SELECT id FROM public.drugs WHERE slug = 'probenecida')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
            (SELECT id FROM public.drugs WHERE slug = 'probenecida')),
   'moderate',
   'Micofenolato + probenecida: a probenecida inibe a secreção tubular renal do metabolito MPAG, aumentando as suas concentrações plasmáticas — vigiar a toxicidade.',
   'Mycophenolate + probenecid: probenecid inhibits renal tubular secretion of the MPAG metabolite, raising its plasma concentrations — watch for toxicity.',
   'O DailyMed (CellCept) documenta que a coadministração de probenecida, um inibidor conhecido da secreção tubular, com micofenolato de mofetil eleva a AUC plasmática do MPAG em 3 vezes em estudos animais ("coadministration of probenecid... with mycophenolate mofetil in monkeys raises plasma AUC of MPAG by 3-fold"). Outros fármacos com secreção tubular renal podem comportar-se de forma semelhante.',
   'DailyMed (CellCept) documents that coadministration of probenecid, a known inhibitor of tubular secretion, with mycophenolate mofetil raises plasma AUC of MPAG by 3-fold in animal studies. Other drugs undergoing renal tubular secretion may behave similarly.',
   'Vigiar a tolerância (hematológica e gastrointestinal) durante a associação; considerar a monitorização de níveis de MPA se disponível.',
   'Watch tolerance (haematological and gastrointestinal) during the combination; consider MPA level monitoring if available.',
   'Vigiar contagens hematológicas e sintomas gastrointestinais durante a co-administração.',
   'Monitor blood counts and gastrointestinal symptoms during co-administration.',
   'Leucopenia, diarreia intensa ou vómitos com a associação.',
   'Leucopenia, severe diarrhoea or vomiting with the combination.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado CellCept (Genentech), secção 7.1 (Probenecid): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40',
   'DailyMed/FDA (NIH/NLM) — approved CellCept label (Genentech), section 7.1 (Probenecid): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40', 'published', now()),

  -- Micofenolato × Rifampicina [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
        (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'micofenolato'),
            (SELECT id FROM public.drugs WHERE slug = 'rifampicina')),
   'moderate',
   'Micofenolato + rifampicina: a rifampicina induz a glucuronidação e reduz a exposição sistémica ao ácido micofenólico — risco de perda de eficácia imunossupressora.',
   'Mycophenolate + rifampicin: rifampicin induces glucuronidation and reduces systemic exposure to mycophenolic acid — risk of losing immunosuppressive efficacy.',
   'O DailyMed (CellCept) regista que "o uso concomitante com fármacos que induzem a glucuronidação diminui a exposição sistémica ao MPA, potencialmente reduzindo a eficácia do CELLCEPT" (secção 7.1). A rifampicina é um indutor enzimático potente que acelera a glucuronidação do ácido micofenólico, reduzindo as concentrações ativas.',
   'DailyMed (CellCept) records that "concomitant use with drugs inducing glucuronidation decreases MPA systemic exposure, potentially reducing CELLCEPT efficacy" (section 7.1). Rifampicin is a potent enzyme inducer that accelerates mycophenolic acid glucuronidation, reducing active concentrations.',
   'Evitar a associação quando possível; se inevitável, vigiar de perto a eficácia imunossupressora e considerar ajuste de dose ou monitorização de níveis de MPA.',
   'Avoid the combination when possible; if unavoidable, closely monitor immunosuppressive efficacy and consider dose adjustment or MPA level monitoring.',
   'Vigiar sinais de rejeição e, quando disponível, níveis de MPA durante a rifampicina.',
   'Watch for signs of rejection and, when available, MPA levels during rifampicin.',
   'Sinais de rejeição do enxerto durante tratamento com rifampicina.',
   'Signs of graft rejection during rifampicin treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado CellCept (Genentech), secção 7.1 (Indutores da glucuronidação): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40',
   'DailyMed/FDA (NIH/NLM) — approved CellCept label (Genentech), section 7.1 (Glucuronidation inducers): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40', 'published', now()),

  -- =====================================================================
  -- FILGRASTIM (1) — DailyMed Neupogen (Drug Interactions)
  -- =====================================================================

  -- Filgrastim × Lítio [moderate]
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'filgrastim'),
        (SELECT id FROM public.drugs WHERE slug = 'litio')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'filgrastim'),
            (SELECT id FROM public.drugs WHERE slug = 'litio')),
   'moderate',
   'Filgrastim + lítio: o lítio pode potenciar a libertação de neutrófilos induzida pelo filgrastim — usar com precaução e vigiar a contagem de neutrófilos.',
   'Filgrastim + lithium: lithium may potentiate filgrastim-induced neutrophil release — use with caution and monitor neutrophil counts.',
   'O DailyMed (Neupogen) regista: "Drugs which may potentiate the release of neutrophils, such as lithium, should be used with caution" (secção Drug Interactions). Ambos os fármacos promovem a libertação de neutrófilos da medula óssea, pelo que a associação pode potenciar a neutrofilia e complicações associadas.',
   'DailyMed (Neupogen) records: "Drugs which may potentiate the release of neutrophils, such as lithium, should be used with caution" (Drug Interactions section). Both drugs promote neutrophil release from the bone marrow, so the combination may potentiate neutrophilia and related complications.',
   'Usar a associação com precaução, monitorizando a contagem absoluta de neutrófilos; ajustar a dose do filgrastim se a neutrofilia for excessiva.',
   'Use the combination with caution, monitoring the absolute neutrophil count; adjust filgrastim dose if neutrophilia is excessive.',
   'Vigiar a contagem de neutrófilos (risco de neutrofilia excessiva) durante a associação.',
   'Monitor neutrophil count (risk of excessive neutrophilia) during the combination.',
   'Neutrofilia marcada (contagem muito acima do alvo) durante a associação.',
   'Marked neutrophilia (count far above target) during the combination.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Neupogen (Amgen), secção Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=97cc73cc-b5b7-458a-a933-77b00523e193',
   'DailyMed/FDA (NIH/NLM) — approved Neupogen label (Amgen), Drug Interactions section: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=97cc73cc-b5b7-458a-a933-77b00523e193', 'published', now());

-- =====================================================================
-- FIM — 15 pares (acenocumarol ×10, micofenolato ×4, filgrastim ×1)
-- Aplicar no Supabase depois da 173/177 (probenecida, colestiramina) e
-- da 178 (acenocumarol, micofenolato existem desde a 177).
-- =====================================================================
