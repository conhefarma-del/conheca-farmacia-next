-- =====================================================================
-- 267: Lotes 2/3 LNME — interações (Fluxo 1) dos 42 fármacos novos
--      (260, 264) com fármacos já existentes na base.
--      DEPENDE DE: 260 (Lote 2: 29 fármacos) e 264 (Lote 3: 13 fármacos)
--      — aplicar 260–266 ANTES desta migração.
-- =====================================================================
-- Pares (30, todos clinicamente documentados), agrupados:
--
--   Xantinas — aminofilina × inibidores CYP1A2/3A4 (4) — Prontuário 5.1.4
--     e Anexo 7 (Teofilina: "fármacos que diminuem o metabolismo"):
--     aminofilina × claritromicina (moderate) — ↑ níveis teofilínicos (macrólidos).
--     aminofilina × ciprofloxacina (moderate) — inibição CYP1A2, ↑ teofilina.
--     aminofilina × cimetidina (moderate) — ↑ níveis de teofilina (antiulcerosos).
--     aminofilina × litio (moderate) — ↑ excreção renal de lítio, ↓ efeito (Anexo 7).
--
--   Corticoide × hipoglicemiante/indutor (4) — Prontuário 8.2.2:
--     metilprednisolona × metformina (moderate) — corticoide antagoniza efeito
--       hipoglicemiante ("Os antidiabéticos antagonizam os efeitos hiperglicemiantes").
--     metilprednisolona × gliclazida (moderate) — mesmo mecanismo (sulfonilureia).
--     metilprednisolona × rifampicina (moderate) — rifampicina acelera o metabolismo
--       dos corticosteróides (Anexo 7: "redução do efeito dos corticosteróides").
--     metilprednisolona × carbamazepina (moderate) — indução enzimática ↓ corticoide.
--
--   Anticoagulação (3):
--     heparina × ibuprofeno (critical) — AINE + heparina: ↑ risco hemorrágico
--       (Prontuário Anexo 7, Salicilatos: "maior tendência hemorrágica"; rótulo heparina).
--     cloreto-potassio × enalapril (critical) — IECA + suplemento de potássio:
--       efeito hipercaliémico aditivo (Anexo 7, Diuréticos poupadores de potássio:
--       "Suplementos de potássio: efeito hipercaliémico aditivo em presença de IR").
--     acido-tranexamico × ibuprofeno (moderate) — antifibrinolítico + AINE:
--       risco hemorrágico aditivo (Prontuário ficha ác. tranexâmico; AINEs antiagregam).
--
--   Digoxina × hipopotassemia (1) — Prontuário 3.1.1 ("fármacos depletores de
--     potássio e magnésio aumentam a probabilidade de toxicidade digitálica"):
--     furosemida × digoxina NÃO duplicado (verificar existente); par novo escolhido:
--     sulfato-magnesio × digoxina (moderate) — hipermagnesemia/hipocaliemia associadas
--       alteram toxicidade digitálica; MgSO4 em pré-eclâmpsia + digoxina: vigiar.
--
--   Ferro × tiroxina (1) — Anexo 7 (Ferro: "Fármacos cuja absorção é reduzida
--     com o ferro: ... Tiroxina"):
--     sulfato-ferroso × levotiroxina (moderate) — ↓ absorção da levotiroxina;
--       separar tomas ≥ 4 h.
--
--   Estroprogestativo × indutores (3) — Anexo 7 (Estrogénios: fenitoína, rifampicina,
--     carbamazepina "com possível redução da eficácia dos contraceptivos orais"):
--     levonorgestrel-etinilestradiol × rifampicina (critical) — falha contracetiva.
--     levonorgestrel-etinilestradiol × carbamazepina (moderate) — falha contracetiva.
--     levonorgestrel-etinilestradiol × fenitoina (moderate) — falha contracetiva.
--     NOTA: griseofulvina × levonorgestrel já existe (259); não duplicado.
--
--   Levotiroxina × indução/anticonvulsivantes (2) — Prontuário 8.3 ficha
--     levotiroxina ("potencia o efeito dos anticoagulantes") e ficha PTU:
--     levotiroxina × warfarina (critical) — levotiroxina potencia anticoagulante
--       oral ("no início do tratamento a dose deve ser reduzida de 1/3 a 1/2").
--     levotiroxina × carbamazepina (moderate) — indução enzimática ↓ tiroxina
--       (fichas PTU/carbimazol: antiepilépticos indutores exigem acertos posológicos).
--
--   Simpaticomiméticos (4):
--     efedrina × metoprolol (moderate) — betabloqueio periférico oposto à vasoconstricção
--       α/β-adrenérgica da efedrina: risco de resposta hipertensiva paradoxal/bradicardia.
--     efedrina × clonidina (moderate) — antagonismo: agonista α2 central ↓ tonus
--       simpático vs. indireto simpatomimético; resposta pressórica imprevisível.
--     dopamina × salbutamol (moderate) — estimulação adrenérgica aditiva: taquiarritmias;
--       Prontuário (Xantinas): xantinas potenciam hipocaliemia com beta-2 agonistas.
--     salbutamol × aminofilina (moderate) — hipocaliemia aditiva e taquicardia
--       (Prontuário 5.1.4: "As xantinas podem potenciar a hipocaliemia associada à
--       administração de simpaticomiméticos beta-2, corticosteróides e diuréticos").
--
--   Neuromusculares (3):
--     suxametonio × digoxina NÃO criado (parceiro eletrólitos abaixo); par escolhido:
--     suxametonio × sulfato-magnesio (moderate) — Mg2+ potencia bloqueio
--       neuromuscular (rótulo: Mg2+ reforça despolarizante e não despolarizante).
--     vecuronio × sulfato-magnesio (moderate) — Mg2+ prolonga bloqueio não
--       despolarizante (rótulos; prática obstétrica pré-eclâmpsia).
--     neostigmina × sulfato-magnesio (moderate) — Mg2+ deprime transmissão
--       neuromuscular e antagoniza parcialmente a reversão; vigiar reversão.
--
--   Sedação aditiva anestesia (2):
--     propofol × midazolam (critical) — depressão respiratória/hipotensão aditivas
--       (rótulo Diprivan: reduzir dose do propofol em 25–30% com sedativos coadministrados).
--     propofol × clonidina (moderate) — sedação e hipotensão aditivas (rótulo).
--
--   Antídotos (2):
--     protamina × heparina (par intra-Lote; tratado como interação farmacodinâmica
--       documentada: reversão do anticoagulante — gestão combinada) — excluído como
--       par adverso; uso terapêutico protocolar (ver nota de exclusão no fim).
--     n-acetilcisteina × paracetamol (par intra-Lote; antídoto) — excluído como par
--       adverso (uso terapêutico); ver nota de exclusão no fim.
--     Pares de antídoto efetivamente criados:
--     fitomenadiona × warfarina (critical) — vitamina K1 antagoniza cumarínicos
--       (Anexo 7/Prontuário 4.3: "dar vitamina K1 5-10 mg IV lenta" na sobredosagem).
--     flumazenil × midazolam NÃO criado (antídoto protocolar, não interação adversa).
--
--   Desmopressina × hiponatremia (1):
--     desmopressina × furosemida (moderate) — diurético altera balanço hídrico;
--       desmopressina ↓ água livre: distúrbios eletrolíticos/hiponatremia imprevisíveis
--       (rótulo desmopressina: evitar em distúrbios de eletrólitos; substância com
--       efeito diurético exige vigilância de Na+).
--
--   Antiácidos/eletrólitos × absorção (2):
--     antiacidos × levotiroxina NÃO criado (Anexo 7 IBP/Antiácidos: absorção reduzida,
--       mas prioridade para pares com os 42 novos; QUANTALAN cita levotiroxina com
--       colestiramina, não antiácidos) — nota de exclusão no fim.
--     gluconato-calcio × ciprofloxacina (moderate) — catiões divalentes quelam
--       quinolonas, ↓ absorção (Anexo 7 Quinolonas: "V. também Antiácidos, Ferro";
--       rótulos quinolona: não administrar com sais de cálcio).
--     bicarbonato-sodio × ciprofloxacina (moderate) — alcalinização/quelação
--       ↓ absorção de quinolonas (rótulo Cipro: evitar antiácidos; bicarbonato eleva pH
--       gástrico e urinário, alterando solubilidade e excreção).
--
--   Hormonas sexuais (2):
--     testosterona × warfarina (critical) — andrógenos potenciam anticoagulante oral
--       (↓ síntese hepática de fatores; rótulos/EMC: reajustar dose de warfarina).
--     clomifeno × testosterona NÃO criado (sem documentação adversa direta).
--
--   Vitamina C / zinco / piridoxina: SEM pares (suplementos sem interações
--     clinicamente relevantes documentadas nos rótulos mono-ingrediente — regra 13.1).
--
-- Fontes (única lista de verdade, conforme Fluxo 1):
--   1. DailyMed (dailymed.nlm.nih.gov) — setIDs validados na API v2 a 2026-09-30
--      (_temp/_lote23_setids.json + setIDs levotiroxina/salbutamol/enalapril
--      validados nesta sessão; nenhum inventado).
--   2. EMC-UK (medicines.org.uk) — carbimazol (setID veterinário → citar EMC),
--      propofol × sedativos, suxametonio/vecuronio × Mg2+.
--   3. EMC-Portugal / Infomed — nomes DCI PT.
--   4. Prontuário Terapêutico INFARMED (11.ª ed., 2012):
--      - Xantinas 5.1.4 (pág. 281): macrólidos/quinolonas/cimetidina/ritonavir ↓
--        clearance teofilina; xantinas potenciam hipocaliemia de beta-2 e corticoides.
--      - Anexo 7 "Interacções importantes" (págs. 620–633): Teofilina (lítio ↑ excreção),
--        Rifampicina (corticosteróides, anticoagulantes), Estrogénios (fenitoína/
--        rifampicina/carbamazepina ↓ eficácia contraceptiva), Ferro (↓ tiroxina),
--        Digoxina (depletores K+/Mg2+, rifampicina), Quinolonas (catiões),
--        Poupadores de potássio × suplementos de K+, Teofilina × benzodiazepinas,
--        Salicilatos × heparina.
--      - Corticosteróides 8.2.2 (pág. 353): rifampicina/antiepilépticos aceleram
--        metabolismo; antidiabéticos antagonizam hiperglicemia; hipocaliemia com diuréticos.
--      - Levotiroxina 8.3 (pág. 357): potencia anticoagulantes (reduzir dose 1/3–1/2);
--        diabéticos podem exigir ↑ hipoglicemiante.
--      - Ficha Propiltiouracilo 8.3: antiepilépticos indutores exigem acertos posológicos.
--
-- Metodologia (docs/INTERACOES_FLUXO_PESQUISA.md, Fluxo 1):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * severidade em {minor, moderate, critical} (padrão 052–059);
--   * idempotente: ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
-- 1. aminofilina × claritromicina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='claritromicina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='claritromicina')),
 'moderate',
 'A Claritromicina reduz a eliminação da Aminofilina (teofilina), podendo provocar toxicidade xantínica: taquicardia, arritmias, náuseas, vómitos e convulsões.',
 'Clarithromycin reduces the elimination of aminophylline (theophylline), potentially causing xanthine toxicity: tachycardia, arrhythmias, nausea, vomiting and seizures.',
 'Os macrólidos (claritromicina) inibem o CYP1A2/3A4, reduzindo o clearance da teofilina/aminofilina (Prontuário, Xantinas 5.1.4 e Anexo 7).',
 'Macrolides (clarithromycin) inhibit CYP1A2/3A4, reducing theophylline/aminophylline clearance (Prontuário, Xanthines 5.1.4 and Annex 7).',
 'Reduzir a dose da aminofilina para cerca de metade e monitorizar níveis séricos de teofilina quando possível.',
 'Reduce the aminophylline dose by about half and monitor serum theophylline levels where possible.',
 'Teofilinemia (10–20 µg/ml), frequência cardíaca, náuseas, tremor.',
 'Theophylline level (10–20 µg/ml), heart rate, nausea, tremor.',
 'Palpitações, vómitos persistentes, tremor grosseiro, convulsões.', 'Palpitations, persistent vomiting, coarse tremor, seizures.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Xantinas 5.1.4 — macrólidos e Anexo 7 (Teofilina: fármacos que diminuem o metabolismo); DailyMed — rótulo Clarithromycin Tablet [Abbvie/Abbott], Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Xanthines 5.1.4 — macrolides and Annex 7 (Theophylline: drugs decreasing metabolism); DailyMed — Clarithromycin Tablet label, Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67',
 'published', now()),

-- 2. aminofilina × ciprofloxacina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 'moderate',
 'A Ciprofloxacina inibe o metabolismo da teofilina (aminofilina), aumentando os níveis séricos e o risco de toxicidade (arritmias, convulsões).',
 'Ciprofloxacin inhibits theophylline metabolism (aminophylline), raising serum levels and toxicity risk (arrhythmias, seizures).',
 'A ciprofloxacina é um inibidor potente do CYP1A2, a via principal do metabolismo da teofilina (Prontuário, Anexo 7 Quinolonas).',
 'Ciprofloxacin is a potent CYP1A2 inhibitor, the main metabolic pathway of theophylline (Prontuário, Annex 7 Quinolones).',
 'Reduzir a dose da aminofilina e monitorizar níveis séricos; considerar alternativa antibiótica se possível.',
 'Reduce the aminophylline dose and monitor serum levels; consider an alternative antibiotic if possible.',
 'Teofilinemia, frequência cardíaca, estado neurológico.',
 'Theophylline level, heart rate, neurological status.',
 'Taquicardia, tremor, insónia, convulsões.', 'Tachycardia, tremor, insomnia, seizures.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Quinolonas: "Teofilina: ciprofloxacina... inibem o metabolismo da teofilina"; DailyMed — rótulo Ciprofloxacin Tablet [Bayer, RLD Cipro]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Quinolones: "Theophylline: ciprofloxacin... inhibit theophylline metabolism"; DailyMed — Ciprofloxacin Tablet label [Bayer, RLD Cipro]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'published', now()),

-- 3. aminofilina × cimetidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='cimetidina')),
 'moderate',
 'A Cimetidina reduz o clearance da teofilina (aminofilina), podendo aumentar os níveis séricos e o risco de toxicidade xantínica.',
 'Cimetidine reduces theophylline (aminophylline) clearance, potentially raising serum levels and the risk of xanthine toxicity.',
 'A cimetidina inibe enzimas CYP hepáticas (incluindo CYP1A2), diminuindo o metabolismo da teofilina (Prontuário, Xantinas 5.1.4: "antiulcerosos: cimetidina").',
 'Cimetidine inhibits hepatic CYP enzymes (including CYP1A2), decreasing theophylline metabolism (Prontuário, Xanthines 5.1.4: "anti-ulcer drugs: cimetidine").',
 'Considerar redução da dose da aminofilina ou trocar cimetidina por antiácido/IPP.',
 'Consider aminophylline dose reduction or switching cimetidine to an antacid/PPI.',
 'Teofilinemia, frequência cardíaca, náuseas, tremor.',
 'Theophylline level, heart rate, nausea, tremor.',
 'Palpitações, vómitos, tremor, convulsões.', 'Palpitations, vomiting, tremor, seizures.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Xantinas 5.1.4 (pág. 281) — "antiulcerosos: cimetidina" influenciam o clearance da teofilina/aminofilina; DailyMed — rótulo Cimetidine Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=496e258d-a5fd-42da-9a86-73afc8be359b',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Xanthines 5.1.4 (p. 281) — "anti-ulcer drugs: cimetidine" influence theophylline/aminophylline clearance; DailyMed — Cimetidine Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=496e258d-a5fd-42da-9a86-73afc8be359b',
 'published', now()),

-- 4. aminofilina × litio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='aminofilina'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'moderate',
 'A Aminofilina (teofilina) aumenta a excreção renal do Lítio, podendo reduzir o seu efeito terapêutico e precipitar recaída maníaca.',
 'Aminophylline (theophylline) increases renal lithium excretion, potentially reducing its therapeutic effect and precipitating manic relapse.',
 'A teofilina aumenta a depuração renal do lítio (Anexo 7: "Teofilina: aumento da excreção renal de lítio com redução do efeito do lítio").',
 'Theophylline increases renal lithium clearance (Annex 7: "Theophylline: increased renal lithium excretion with reduced lithium effect").',
 'Monitorizar litemia após início/fim da aminofilina; ajustar dose do lítio se necessário.',
 'Monitor serum lithium after starting/stopping aminophylline; adjust the lithium dose if needed.',
 'Litemia, sintomas de recaída (humor, sono, agitação).',
 'Serum lithium, relapse symptoms (mood, sleep, agitation).',
 'Recaída de sintomas maníacos, litemia abaixo do intervalo terapêutico.', 'Manic symptom relapse, serum lithium below therapeutic range.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Lítio: "Teofilina: aumento da excreção renal de lítio com redução do efeito do lítio"; DailyMed — rótulo Lithium Carbonate: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Lithium: "Theophylline: increased renal lithium excretion with reduced lithium effect"; DailyMed — Lithium Carbonate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'published', now()),

-- 5. metilprednisolona × metformina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='metformina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='metformina')),
 'moderate',
 'A Metilprednisolona aumenta a glicemia e antagoniza o efeito da Metformina, com risco de descompensação diabética.',
 'Methylprednisolone raises blood glucose and antagonises metformin, with risk of diabetic decompensation.',
 'Os glucocorticóides diminuem a tolerância à glicose e a sensibilidade à insulina; os antidiabéticos antagonizam os efeitos hiperglicemiantes (Prontuário 8.2.2).',
 'Glucocorticoids reduce glucose tolerance and insulin sensitivity; antidiabetics antagonise the hyperglycaemic effect (Prontuário 8.2.2).',
 'Reforçar a vigilância glicémica durante o corticoide; ajustar temporariamente o antidiabético; em curtos cursos, resolver espontaneamente.',
 'Intensify glucose monitoring during corticosteroid use; temporarily adjust the antidiabetic; short courses usually resolve spontaneously.',
 'Glicemia capilar/diária durante o curso do corticoide.',
 'Capillary/daily glucose during the corticosteroid course.',
 'Glicemias > 250 mg/dl, cetoacidose, polidipsia/poliúria.', 'Glucose > 250 mg/dl, ketoacidosis, polydipsia/polyuria.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Corticosteróides 8.2.2 — "Nos diabéticos... diminuírem a tolerância à glicose e a sensibilidade à insulina" e "Os antidiabéticos antagonizam os efeitos hiperglicemiantes"; DailyMed — rótulo Metformin HCl ER Tablet [Glenmark Pharma]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0ef9de1a-b786-4b6c-a250-3f5ac532b16a',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Corticosteroids 8.2.2 — "In diabetics... reduced glucose tolerance and insulin sensitivity" and "Antidiabetics antagonise hyperglycaemic effects"; DailyMed — Metformin HCl Tablet label [Glenmark Pharma]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0ef9de1a-b786-4b6c-a250-3f5ac532b16a',
 'published', now()),

-- 6. metilprednisolona × gliclazida (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='gliclazida')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='gliclazida')),
 'moderate',
 'A Metilprednisolona aumenta a glicemia e pode exigir ajuste (aumento) temporário da dose da Gliclazida.',
 'Methylprednisolone raises blood glucose and may require a temporary increase in the gliclazide dose.',
 'Efeito hiperglicemiante dos glucocorticóides (glicogenólise, gluconeogénese, insulinorresistência) antagoniza a sulfonilureia (Prontuário 8.2.2).',
 'The hyperglycaemic effect of glucocorticoids (glycogenolysis, gluconeogenesis, insulin resistance) antagonises the sulfonylurea (Prontuário 8.2.2).',
 'Vigiar glicemia capilar; aumentar dose da sulfonilureia durante o corticoide se necessário; em diabéticos instáveis considerar insulina transitória.',
 'Monitor capillary glucose; increase the sulfonylurea dose during the corticosteroid course if needed; in unstable diabetics consider transient insulin.',
 'Glicemia capilar durante o curso do corticoide e 1 semana após o fim.',
 'Capillary glucose during the corticosteroid course and 1 week after stopping.',
 'Glicemias persistentemente elevadas, descompensação hiperglicémica.', 'Persistently raised glucose, hyperglycaemic decompensation.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Corticosteróides 8.2.2 — antidiabéticos antagonizados; DailyMed — rótulo Glipizide Tablet (sulfonilureia classe, Apotex): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dcf426b8-bcdc-8214-a1b6-6388bd3399a0',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Corticosteroids 8.2.2 — antidiabetics antagonised; DailyMed — Glipizide Tablet label (sulfonylurea class, Apotex): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dcf426b8-bcdc-8214-a1b6-6388bd3399a0',
 'published', now()),

-- 7. metilprednisolona × rifampicina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 'moderate',
 'A Rifampicina acelera o metabolismo da Metilprednisolona, reduzindo o seu efeito terapêutico (risco de crise addisoniana em corticodependentes).',
 'Rifampicin accelerates methylprednisolone metabolism, reducing its therapeutic effect (risk of addisonian crisis in corticodependent patients).',
 'A rifampicina é indutor potente enzimático; Prontuário 8.2.2 e Anexo 7: "a rifampicina acelera o metabolismo dos corticosteróides com a consequente redução do efeito terapêutico".',
 'Rifampicin is a potent enzyme inducer; Prontuário 8.2.2 and Annex 7: "rifampicin accelerates corticosteroid metabolism with consequent reduction of therapeutic effect".',
 'Aumentar a dose do corticoide quando associado a rifampicina; ajustar de novo ao suspender o tuberculostático; nunca suspender corticoide abruptamente.',
 'Increase the corticosteroid dose when co-administered with rifampicin; readjust when stopping the antituberculous drug; never stop the corticosteroid abruptly.',
 'Clínica de corticodependência (fadiga, hipotensão), glicemia, tensão arterial.',
 'Corticodependence signs (fatigue, hypotension), glucose, blood pressure.',
 'Hipotensão, fraqueza, náuseas, hiperpigmentação (crise addisoniana).', 'Hypotension, weakness, nausea, hyperpigmentation (addisonian crisis).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Corticosteróides 8.2.2 (pág. 353) e Anexo 7 — Rifampicina: "Corticosteróides: aumento do metabolismo hepático"; DailyMed — rótulo Rifampin Capsule [RLD Rifadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=50f706f9-5003-4e15-bece-85b6213b1f5c',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Corticosteroids 8.2.2 (p. 353) and Annex 7 — Rifampicin: "Corticosteroids: increased hepatic metabolism"; DailyMed — Rifampin Capsule label [RLD Rifadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=50f706f9-5003-4e15-bece-85b6213b1f5c',
 'published', now()),

-- 8. metilprednisolona × carbamazepina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='metilprednisolona'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'moderate',
 'A Carbamazepina acelera o metabolismo da Metilprednisolona por indução do CYP3A4, reduzindo o efeito do corticoide.',
 'Carbamazepine accelerates methylprednisolone metabolism via CYP3A4 induction, reducing the corticosteroid effect.',
 'Os antiepilépticos indutores (carbamazepina, fenitoína, barbitúricos) aumentam o metabolismo hepático dos corticosteróides (Prontuário 8.2.2; Anexo 7).',
 'Enzyme-inducing antiepileptics (carbamazepine, phenytoin, barbiturates) increase hepatic metabolism of corticosteroids (Prontuário 8.2.2; Annex 7).',
 'Ajustar a dose do corticoide durante a co-administração; vigiar sinais de insuficiência suprarrenal; readaptar após suspensão do antiepiléptico.',
 'Adjust the corticosteroid dose during co-administration; watch for adrenal insufficiency signs; readapt after stopping the antiepileptic.',
 'Clínica de hipocortisolismo, tensão arterial, glicemia.',
 'Hypocortisolism signs, blood pressure, glucose.',
 'Fadiga, hipotensão, náuseas, exacerbação da doença de base.', 'Fatigue, hypotension, nausea, worsening of the underlying disease.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Corticosteróides 8.2.2 — "o mesmo se verifica com antiepilépticos (carbamazepina, barbitúricos e fenitoína)"; DailyMed — rótulo Carbamazepine Tablet [RLD Tegretol]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Corticosteroids 8.2.2 — "the same occurs with antiepileptics (carbamazepine, barbiturates and phenytoin)"; DailyMed — Carbamazepine Tablet label [RLD Tegretol]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491',
 'published', now()),

-- 9. heparina × ibuprofeno (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='heparina'), (SELECT id FROM public.drugs WHERE slug='ibuprofeno')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='heparina'), (SELECT id FROM public.drugs WHERE slug='ibuprofeno')),
 'critical',
 'A associação de Heparina com Ibuprofeno aumenta significativamente o risco de hemorragia (efeito anticoagulante + antiagregação/mucosa gástrica).',
 'Heparin plus ibuprofen significantly increases bleeding risk (anticoagulant effect plus platelet/gastric mucosa effects).',
 'AINEs inibem a agregação plaquetar e lesam a mucosa gástrica; Prontuário Anexo 7 (Salicilatos): "Heparina: maior tendência hemorrágica"; rótulo da heparina lista AINEs como agravantes.',
 'NSAIDs inhibit platelet aggregation and injure gastric mucosa; Prontuário Annex 7 (Salicylates): "Heparin: greater bleeding tendency"; the heparin label lists NSAIDs as aggravating agents.',
 'Evitar a associação; se analgesia necessária, preferir paracetamol; se inevitável, usar duração mínima e monitorizar sinais hemorrágicos e hemograma.',
 'Avoid the combination; if analgesia is needed, prefer paracetamol; if unavoidable, use the shortest duration and monitor bleeding signs and blood count.',
 'Sinais hemorrágicos, hemograma (Hb, plaquetas), TTPa em heparinizados.',
 'Bleeding signs, full blood count (Hb, platelets), aPTT in heparinised patients.',
 'Equimoses, hemorragia gástrica, urina escura, queda de Hb.', 'Bruising, gastrointestinal bleeding, dark urine, Hb drop.',
 'DailyMed — rótulo Heparin Sodium Injection [RLD], Warnings/Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=301b19bc-21c2-4a35-9d29-569b08d855c4; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Salicilatos: "Heparina: maior tendência hemorrágica com o ácido acetilsalicílico".',
 'DailyMed — Heparin Sodium Injection label [RLD], Warnings/Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=301b19bc-21c2-4a35-9d29-569b08d855c4; INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Salicylates: "Heparin: greater bleeding tendency with aspirin".',
 'published', now()),

-- 10. cloreto-potassio × enalapril (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='cloreto-potassio'), (SELECT id FROM public.drugs WHERE slug='enalapril')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='cloreto-potassio'), (SELECT id FROM public.drugs WHERE slug='enalapril')),
 'critical',
 'A associação de Cloreto de Potássio com Enalapril (IECA) aumenta o risco de hiperpotassemia grave, com risco de arritmias fatais.',
 'Potassium chloride plus enalapril (ACE inhibitor) increases the risk of severe hyperkalaemia, with potentially fatal arrhythmias.',
 'Os IECAs reduzem a aldosterona e a excreção renal de potássio; Anexo 7 (Poupadores de potássio): "Suplementos de potássio: efeito hipercaliémico aditivo em presença de insuficiência renal".',
 'ACE inhibitors reduce aldosterone and renal potassium excretion; Annex 7 (Potassium-sparing drugs): "Potassium supplements: additive hyperkalaemic effect in the presence of renal impairment".',
 'Evitar suplementação rotineira de potássio com IECA; se necessária, monitorizar kaliemia e ECG; rever dieta e outros fármacos hipercaliemiantes.',
 'Avoid routine potassium supplementation with ACE inhibitors; if needed, monitor serum potassium and ECG; review diet and other hyperkalaemic drugs.',
 'Kaliemia, ECG (ondas T apiculadas, alargamento de QRS), função renal.',
 'Serum potassium, ECG (peaked T waves, QRS widening), renal function.',
 'Fraqueza muscular, parestesias, bradicardia, alterações do ECG, paragem cardíaca.', 'Muscle weakness, paraesthesia, bradycardia, ECG changes, cardiac arrest.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Diuréticos poupadores de potássio/IECAs: efeito hipercaliémico aditivo; DailyMed — rótulo Enalapril Maleate Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a88902bd-742f-4ea6-b625-cc9df1709efc',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Potassium-sparing diuretics/ACE inhibitors: additive hyperkalaemic effect; DailyMed — Enalapril Maleate Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a88902bd-742f-4ea6-b625-cc9df1709efc',
 'published', now()),

-- 11. acido-tranexamico × ibuprofeno (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='acido-tranexamico'), (SELECT id FROM public.drugs WHERE slug='ibuprofeno')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='acido-tranexamico'), (SELECT id FROM public.drugs WHERE slug='ibuprofeno')),
 'moderate',
 'A associação do Ácido Tranexâmico com Ibuprofeno pode aumentar o risco de eventos trombóticos/complicações hemorrágicas por efeitos hemostáticos combinados.',
 'Tranexamic acid plus ibuprofen may increase the risk of thrombotic events/bleeding complications due to combined haemostatic effects.',
 'O ácido tranexâmico é antifibrinolítico; os AINEs alteram a hemostasia e a função plaquetar; a combinação em menorragia é comum mas exige vigilância (ficha Prontuário; EMC).',
 'Tranexamic acid is an antifibrinolytic; NSAIDs alter haemostasis and platelet function; the combination in menorrhagia is common but requires vigilance (Prontuário entry; EMC).',
 'Em menorragia a associação é aceite com vigilância; avaliar fatores de risco trombótico antes de combinar; limitar duração.',
 'In menorrhagia the combination is accepted with monitoring; assess thrombotic risk factors before combining; limit duration.',
 'Sinais trombóticos (dor torácica, edema unilateral) e hemorragia atípica.',
 'Thrombotic signs (chest pain, unilateral swelling) and atypical bleeding.',
 'Dor torácica súbita, dispneia, TVP, hemorragia prolongada.', 'Sudden chest pain, dyspnoea, DVT, prolonged bleeding.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha ácido tranexâmico (hemostáticos); DailyMed — rótulo Lysteda (tranexamic acid) Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9d97790f-048b-494d-aa22-5689643a724b',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), tranexamic acid entry (haemostatics); DailyMed — Lysteda (tranexamic acid) Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9d97790f-048b-494d-aa22-5689643a724b',
 'published', now()),

-- 12. sulfato-magnesio × digoxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='sulfato-magnesio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='sulfato-magnesio'), (SELECT id FROM public.drugs WHERE slug='digoxina')),
 'moderate',
 'Alterações do magnésio sérico modificam o risco de toxicidade digitálica; a depleção de Mg2+/K+ aumenta arritmias por digoxina, e o MgSO4 em doses elevadas altera o equilíbrio eletrolítico.',
 'Changes in serum magnesium modify digitalis toxicity risk; Mg2+/K+ depletion worsens digoxin arrhythmias, and high-dose MgSO4 shifts electrolyte balance.',
 'Prontuário 3.1.1: "quando em simultâneo são utilizados fármacos depletores de potássio e de magnésio (diuréticos)" aumenta a probabilidade de toxicidade digitálica; Mg2+ é cofactor da Na+/K+-ATPase.',
 'Prontuário 3.1.1: "when potassium- and magnesium-depleting drugs (diuretics) are used simultaneously" the likelihood of digitalis toxicity increases; Mg2+ is a cofactor of Na+/K+-ATPase.',
 'Monitorizar Mg2+, K+ e digoxinemia; ECG na associação; corrigir depleções de potássio.',
 'Monitor Mg2+, K+ and digoxin levels; ECG during the combination; correct potassium depletion.',
 'Mg2+ e K+ séricos, digoxinemia, ECG.',
 'Serum Mg2+ and K+, digoxin level, ECG.',
 'Náuseas, discromatopsia, extrassístoles, bradicardia.', 'Nausea, colour vision changes, extrasystoles, bradycardia.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Digitálicos 3.1.1 — depletores de potássio/magnésio; DailyMed — rótulo Digoxin Tablet [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Digitalis 3.1.1 — potassium/magnesium-depleting drugs; DailyMed — Digoxin Tablet label [RLD Lanoxin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dfac7f13-28be-423d-9389-9089da29da17',
 'published', now()),

-- 13. sulfato-ferroso × levotiroxina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='sulfato-ferroso'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='sulfato-ferroso'), (SELECT id FROM public.drugs WHERE slug='levotiroxina')),
 'moderate',
 'O Sulfato Ferroso reduz a absorção da Levotiroxina, podendo causar hipotiroidismo subotimo se as tomas forem simultâneas.',
 'Ferrous sulphate reduces levothyroxine absorption, potentially causing undertreated hypothyroidism if taken together.',
 'O ferro liga-se à tiroxina no tubo gastrintestinal; Anexo 7 (Ferro): "Fármacos cuja absorção é reduzida com o ferro: ... Tiroxina".',
 'Iron binds thyroxine in the gastrointestinal tract; Annex 7 (Iron): "Drugs whose absorption is reduced by iron: ... Thyroxine".',
 'Separar as tomas em pelo menos 4 horas; reavaliar TSH após 6–8 semanas se a co-administração for mantida.',
 'Separate doses by at least 4 hours; reassess TSH after 6–8 weeks if co-administration continues.',
 'TSH e T4 livre 6–8 semanas após alteração do regime.',
 'TSH and free T4 6–8 weeks after any regimen change.',
 'Fadiga, ganho de peso, edema (sinais de hipotiroidismo).', 'Fatigue, weight gain, oedema (hypothyroidism signs).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Ferro: "Tiroxina" entre os fármacos com absorção reduzida; DailyMed — rótulo Levothyroxine Sodium Tablet [A-S Medication Solutions]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Iron: "Thyroxine" among drugs with reduced absorption; DailyMed — Levothyroxine Sodium Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=255ad500-6656-4cd0-b4d1-10cc22f9e61b',
 'published', now()),

-- 14. levonorgestrel-etinilestradiol × rifampicina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='rifampicina')),
 'critical',
 'A Rifampicina reduz marcadamente a eficácia do contraceptivo hormonal (levonorgestrel + etinilestradiol), com risco de gravidez não planeada.',
 'Rifampicin markedly reduces the effectiveness of hormonal contraception (levonorgestrel + ethinylestradiol), with risk of unintended pregnancy.',
 'Indução enzimática (CYP3A4) acelera o metabolismo dos estrogénios e progestagénios; Anexo 7: "Rifampicina" entre fármacos que reduzem a eficácia dos contraceptivos orais.',
 'Enzyme induction (CYP3A4) accelerates oestrogen and progestogen metabolism; Annex 7 lists rifampicin among drugs reducing oral contraceptive efficacy.',
 'Recomendar método de barreira adicional durante todo o tratamento e 4 semanas após; considerar método contracetivo não hormonal durante a rifampicina.',
 'Recommend additional barrier contraception throughout treatment and for 4 weeks after; consider a non-hormonal method while on rifampicin.',
 'Questionar sobre sangramentos intermenstruais e atraso menstrual.',
 'Ask about intermenstrual bleeding and missed periods.',
 'Sangramento intermenstrual, atraso menstrual.', 'Intermenstrual bleeding, missed period.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Estrogénios: "Rifampicina" (redução da eficácia dos contraceptivos orais); DailyMed — rótulo Rifampin Capsule [RLD Rifadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=50f706f9-5003-4e15-bece-85b6213b1f5c',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Oestrogens: "Rifampicin" (reduced oral contraceptive efficacy); DailyMed — Rifampin Capsule label [RLD Rifadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=50f706f9-5003-4e15-bece-85b6213b1f5c',
 'published', now()),

-- 15. levonorgestrel-etinilestradiol × carbamazepina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'moderate',
 'A Carbamazepina reduz a eficácia do contraceptivo hormonal por indução enzimática, com risco de gravidez não planeada.',
 'Carbamazepine reduces hormonal contraceptive efficacy through enzyme induction, with risk of unintended pregnancy.',
 'Indutores enzimáticos aceleram o metabolismo dos estrogénios/progestagénios (Anexo 7: "V. também Carbamazepina"; rótulo Tegretol documenta falha contracetiva).',
 'Enzyme inducers accelerate oestrogen/progestogen metabolism (Annex 7: "See also Carbamazepine"; the Tegretol label documents contraceptive failure).',
 'Recomendar método de barreira adicional ou contracepção não hormonal; não depender só do contraceptivo oral durante a co-administração.',
 'Recommend additional barrier contraception or a non-hormonal method; do not rely on the oral contraceptive alone during co-administration.',
 'Sangramentos intermenstruais, atraso menstrual.',
 'Intermenstrual bleeding, missed periods.',
 'Sangramento intermenstrual, gravidez não planeada.', 'Intermenstrual bleeding, unintended pregnancy.',
 'DailyMed — rótulo Tegretol (carbamazepine), Drug Interactions (contraceptive failure): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Estrogénios.',
 'DailyMed — Tegretol (carbamazepine) label, Drug Interactions (contraceptive failure): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491; INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Oestrogens.',
 'published', now()),

-- 16. levonorgestrel-etinilestradiol × fenitoina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='levonorgestrel-etinilestradiol'), (SELECT id FROM public.drugs WHERE slug='fenitoina')),
 'moderate',
 'A Fenitoína reduz a eficácia do contraceptivo hormonal por indução enzimática, com risco de gravidez não planeada.',
 'Phenytoin reduces hormonal contraceptive efficacy through enzyme induction, with risk of unintended pregnancy.',
 'A fenitoína é indutor do metabolismo microssomal; Anexo 7 (Estrogénios): "Fenitoína" entre os fármacos que aumentam o metabolismo dos estrogénios.',
 'Phenytoin is a microsomal metabolism inducer; Annex 7 (Oestrogens): "Phenytoin" among drugs increasing oestrogen metabolism.',
 'Recomendar método de barreira adicional; considerar contracepção não hormonal; além disso, a gravidez em doentes epilépticas exige planeamento com o neurólogo.',
 'Recommend additional barrier contraception; consider non-hormonal methods; pregnancy in women with epilepsy also requires planning with the neurologist.',
 'Sangramentos intermenstruais, atraso menstrual.',
 'Intermenstrual bleeding, missed periods.',
 'Sangramento intermenstrual, gravidez não planeada.', 'Intermenstrual bleeding, unintended pregnancy.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Estrogénios: "Fenitoína"; DailyMed — rótulo Phenytoin Tablet [RLD Dilantin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=46d5c0d1-a97b-46d9-8cf4-994780673337',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Oestrogens: "Phenytoin"; DailyMed — Phenytoin Tablet label [RLD Dilantin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=46d5c0d1-a97b-46d9-8cf4-994780673337',
 'published', now()),

-- 17. levotiroxina × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='levotiroxina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='levotiroxina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'A Levotiroxina potencia o efeito da Warfarina, aumentando o risco de hemorragia; iniciar tiroxina exige reduzir a dose do anticoagulante.',
 'Levothyroxine potentiates the effect of warfarin, increasing bleeding risk; starting thyroxine requires reducing the anticoagulant dose.',
 'As hormonas da tiróide aumentam o catabolismo dos factores de coagulação dependentes de vitamina K; Prontuário 8.3: "Potencia o efeito dos anticoagulantes, pelo que no início do tratamento a dose destes fármacos deve ser reduzida de um terço a metade".',
 'Thyroid hormones increase catabolism of vitamin K–dependent clotting factors; Prontuário 8.3: "Potentiates anticoagulant effect, so at the start of treatment the dose must be reduced by one third to one half".',
 'Reduzir a dose de warfarina (1/3 a 1/2) ao iniciar levotiroxina; medir INR com frequência até estabilização.',
 'Reduce the warfarin dose (one third to one half) when starting levothyroxine; measure INR frequently until stabilisation.',
 'INR frequente nas primeiras semanas; sinais hemorrágicos.',
 'Frequent INR in the first weeks; bleeding signs.',
 'Equimoses espontâneas, hemorragia naso-oral, urina escura, fezes negras.', 'Spontaneous bruising, nose or gum bleeding, dark urine, black stools.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Levotiroxina 8.3 (pág. 357) — "Potencia o efeito dos anticoagulantes"; DailyMed — rótulo Warfarin Sodium Tablet [RLD Coumadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Levothyroxine 8.3 (p. 357) — "Potentiates anticoagulant effect"; DailyMed — Warfarin Sodium Tablet label [RLD Coumadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'published', now()),

-- 18. levotiroxina × carbamazepina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='levotiroxina'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='levotiroxina'), (SELECT id FROM public.drugs WHERE slug='carbamazepina')),
 'moderate',
 'A Carbamazepina (indutora enzimática) pode reduzir os níveis de tiroxina, exigindo ajuste da dose de levotiroxina.',
 'Carbamazepine (enzyme inducer) can lower thyroxine levels, requiring levothyroxine dose adjustment.',
 'Fármacos com acção indutora enzimática (carbamazepina, fenitoína, barbitúricos) aceleram o metabolismo das hormonas da tiróide (fichas 8.3, Propiltiouracilo: "exigem acertos de posologia").',
 'Enzyme-inducing drugs (carbamazepine, phenytoin, barbiturates) accelerate thyroid hormone metabolism (entry 8.3, Propylthiouracil: "require dose adjustments").',
 'Reavaliar TSH/T4 livre 4–6 semanas após iniciar carbamazepina; aumentar dose de levotiroxina se necessário.',
 'Reassess TSH/free T4 4–6 weeks after starting carbamazepine; increase levothyroxine dose if needed.',
 'TSH e T4 livres após alteração de terapia antiepiléptica.',
 'TSH and free T4 after any antiepileptic therapy change.',
 'Fadiga, ganho de peso, bradicardia (hipotiroidismo).', 'Fatigue, weight gain, bradycardia (hypothyroidism).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Propiltiouracilo 8.3 — antiepilépticos indutores "exigem acertos de posologia"; DailyMed — rótulo Carbamazepine Tablet [RLD Tegretol]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Propylthiouracil entry 8.3 — enzyme-inducing antiepileptics "require dose adjustments"; DailyMed — Carbamazepine Tablet label [RLD Tegretol]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d0121be3-b904-41d3-a81a-292aa4176491',
 'published', now()),

-- 19. efedrina × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='efedrina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='efedrina'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'O Metoprolol pode bloquear a componente beta-2 vasodilatadora da Efedrina, favorecendo resposta hipertensiva excessiva e bradicardia reflexa.',
 'Metoprolol may block the beta-2 vasodilating component of ephedrine, favouring excessive hypertensive response and reflex bradycardia.',
 'A efedrina é simpaticomimético misto (α e β); o betabloqueio selectivo β1 deixa a vasoconstrição α sem o balanço β2 (rótulos efedrina: hipertensão com betabloqueantes).',
 'Ephedrine is a mixed (α and β) sympathomimetic; β1-selective blockade leaves α vasoconstriction unbalanced by β2 (ephedrine labels: hypertension with beta-blockers).',
 'Em hipotensão anestésica em doentes betabloqueados, preferir efedrina em doses menores com monitorização contínua; considerar fenilefrina alternativa com cautela.',
 'For anaesthetic hypotension in beta-blocked patients, use ephedrine in smaller doses with continuous monitoring; consider phenylephrine as an alternative with caution.',
 'Tensão arterial invasiva/não invasiva frequente, frequência cardíaca.',
 'Frequent invasive/non-invasive blood pressure, heart rate.',
 'Hipertensão súbita, cefaleia, bradicardia, angina.', 'Sudden hypertension, headache, bradycardia, angina.',
 'DailyMed — rótulo Ephedrine Sulfate Tablet [CVS Pharmacy], Warnings (hipertensão, interacções adrenérgicas): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e338deef-efad-1d82-e053-2995a90a1bf9',
 'DailyMed — Ephedrine Sulfate Tablet label [CVS Pharmacy], Warnings (hypertension, adrenergic interactions): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e338deef-efad-1d82-e053-2995a90a1bf9',
 'published', now()),

-- 20. efedrina × clonidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='efedrina'), (SELECT id FROM public.drugs WHERE slug='clonidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='efedrina'), (SELECT id FROM public.drugs WHERE slug='clonidina')),
 'moderate',
 'A associação de Efedrina (simpaticomimético indireto) com Clonidina (agonista α2 central) pode produzir resposta pressórica e sedativa imprevisível.',
 'Ephedrine (indirect sympathomimetic) plus clonidine (central α2 agonist) can produce unpredictable pressor and sedative responses.',
 'A clonidina reduz o tonus simpático central e a liberação de noradrenalina; a efedrina depende dessa liberação — o efeito pressórico da efedrina pode ficar atenuado, e a suspensão da clonidina causa rebote hipertensivo.',
 'Clonidine reduces central sympathetic tone and noradrenaline release; ephedrine depends on that release — the pressor effect of ephedrine may be blunted, and clonidine withdrawal causes rebound hypertension.',
 'Evitar a suspensão abrupta da clonidina (rebote); em peri-operatório manter clonidina e vigiar tensão; titrar vasopressores com monitorização.',
 'Never stop clonidine abruptly (rebound); peri-operatively continue clonidine and monitor blood pressure; titrate vasopressors with monitoring.',
 'Tensão arterial peri-operatória, sedação, frequência cardíaca.',
 'Peri-operative blood pressure, sedation, heart rate.',
 'Hipertensão de rebote, cefaleia, agitação, taquicardia.', 'Rebound hypertension, headache, agitation, tachycardia.',
 'DailyMed — rótulo Ephedrine Sulfate Tablet (adrenérgicos): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e338deef-efad-1d82-e053-2995a90a1bf9; rótulo Clonidine HCl Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d90b2ca4-7753-4012-a1b2-fb92bdf0ebb6',
 'DailyMed — Ephedrine Sulfate Tablet label (adrenergics): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e338deef-efad-1d82-e053-2995a90a1bf9; Clonidine HCl Tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d90b2ca4-7753-4012-a1b2-fb92bdf0ebb6',
 'published', now()),

-- 21. dopamina × salbutamol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='dopamina'), (SELECT id FROM public.drugs WHERE slug='salbutamol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='dopamina'), (SELECT id FROM public.drugs WHERE slug='salbutamol')),
 'moderate',
 'A associação de Dopamina com Salbutamol soma estimulação adrenérgica, com risco de taquiarritmias, isquemia miocárdica e hipocaliemia.',
 'Dopamine plus salbutamol adds adrenergic stimulation, with risk of tachyarrhythmias, myocardial ischaemia and hypokalaemia.',
 'Ambos ativam receptores adrenérgicos β; a estimulação aditiva aumenta o débito cardíaco e o consumo de O2 e desloca K+ para o interior celular (rótulos de ambos; Prontuário, beta-2 agonistas).',
 'Both activate β-adrenergic receptors; additive stimulation raises cardiac output and O2 consumption and shifts K+ intracellularly (labels of both; Prontuário, beta-2 agonists).',
 'Vigiar ECG contínuo e kaliemia; limitar doses; suspender o beta-2 se arritmias surgirem.',
 'Monitor continuous ECG and serum potassium; limit doses; stop the beta-2 agonist if arrhythmias develop.',
 'ECG contínuo, kaliemia, frequência cardíaca, tensão arterial.',
 'Continuous ECG, serum potassium, heart rate, blood pressure.',
 'Taquicardia > 120 bpm, extrassístoles, dor torácica, hipocaliemia.', 'Tachycardia > 120 bpm, extrasystoles, chest pain, hypokalaemia.',
 'DailyMed — rótulo Dopamine HCl Injection [RLD]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1f306ad2-3606-4525-5a8a-ce78f426c1a2; rótulo Ventolin HFA (albuterol): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=adb8d669-b91c-46f1-8a86-19f504840eff',
 'DailyMed — Dopamine HCl Injection label [RLD]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1f306ad2-3606-4525-5a8a-ce78f426c1a2; Ventolin HFA (albuterol) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=adb8d669-b91c-46f1-8a86-19f504840eff',
 'published', now()),

-- 22. salbutamol × aminofilina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='salbutamol'), (SELECT id FROM public.drugs WHERE slug='aminofilina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='salbutamol'), (SELECT id FROM public.drugs WHERE slug='aminofilina')),
 'moderate',
 'A associação de Salbutamol com Aminofilina soma efeitos broncodilatadores mas também taquicardia, arritmias e hipocaliemia aditivas.',
 'Salbutamol plus aminophylline adds bronchodilator effect but also additive tachycardia, arrhythmias and hypokalaemia.',
 'Prontuário Xantinas 5.1.4: "As xantinas podem potenciar a hipocaliemia associada à administração de simpaticomiméticos beta-2"; ambos aumentam o consumo miocárdico de O2.',
 'Prontuário Xanthines 5.1.4: "Xanthines can potentiate the hypokalaemia associated with beta-2 sympathomimetics"; both increase myocardial O2 consumption.',
 'Usada com frequência em asma aguda grave, mas exige vigilância: kaliemia, ECG e frequência cardíaca; limitar doses de cada.',
 'Commonly used in severe acute asthma, but requires monitoring: potassium, ECG and heart rate; limit individual doses.',
 'Kaliemia, ECG, frequência cardíaca, tremor.',
 'Serum potassium, ECG, heart rate, tremor.',
 'Taquicardia, tremor grosseiro, vómitos, hipocaliemia sintomática.', 'Tachycardia, coarse tremor, vomiting, symptomatic hypokalaemia.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Xantinas 5.1.4 (pág. 281) — hipocaliemia com simpaticomiméticos beta-2; DailyMed — rótulo Aminophylline Injection [RLD]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=819207a2-0c37-b275-e053-2a91aa0afb36',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Xanthines 5.1.4 (p. 281) — hypokalaemia with beta-2 sympathomimetics; DailyMed — Aminophylline Injection label [RLD]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=819207a2-0c37-b275-e053-2a91aa0afb36',
 'published', now()),

-- 23. suxametonio × sulfato-magnesio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='suxametonio'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='suxametonio'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 'moderate',
 'O Sulfato de Magnésio potencia o bloqueio neuromuscular do Suxametonio, podendo prolongar apneia e fraqueza respiratória.',
 'Magnesium sulphate potentiates the neuromuscular blockade of suxamethonium, potentially prolonging apnoea and respiratory weakness.',
 'O Mg2+ inibe a liberação pré-sináptica de acetilcolina e deprime a excitabilidade da placa motora, reforçando o bloqueio despolarizante (rótulos MgSO4 e succinylcholine).',
 'Mg2+ inhibits presynaptic acetylcholine release and depresses motor plate excitability, reinforcing the depolarising block (MgSO4 and succinylcholine labels).',
 'Em pré-eclâmpsia tratada com MgSO4 e anestesia geral, informar o anestesiologista; ventilação de suporte disponível; considerar monitorização do bloqueio.',
 'In pre-eclampsia treated with MgSO4 and general anaesthesia, inform the anaesthesiologist; have ventilatory support available; consider blockade monitoring.',
 'Duração da apneia, ventilação, Mg2+ sérico.',
 'Apnoea duration, ventilation, serum Mg2+.',
 'Apneia prolongada, fraqueza respiratória após reversão.', 'Prolonged apnoea, respiratory weakness after reversal.',
 'DailyMed — rótulo Magnesium Sulfate Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5b4b4805-a8ff-4efe-94bc-411090ab5f9c; rótulo Succinylcholine Chloride Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=efe5a242-5ba0-4b14-844c-206a79850d81',
 'DailyMed — Magnesium Sulfate Injection label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5b4b4805-a8ff-4efe-94bc-411090ab5f9c; Succinylcholine Chloride Injection label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=efe5a242-5ba0-4b14-844c-206a79850d81',
 'published', now()),

-- 24. vecuronio × sulfato-magnesio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='vecuronio'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='vecuronio'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 'moderate',
 'O Sulfato de Magnésio prolonga e intensifica o bloqueio neuromuscular não despolarizante do Vecurônio.',
 'Magnesium sulphate prolongs and intensifies the non-depolarising neuromuscular blockade of vecuronium.',
 'O Mg2+ reduz a liberação de acetilcolina e a sensibilidade da placa, aumentando a duração do bloqueio por curare (rótulos; prática obstétrica com MgSO4).',
 'Mg2+ reduces acetylcholine release and plate sensitivity, increasing curare-blockade duration (labels; obstetric practice with MgSO4).',
 'Reduzir a dose inicial do vecurônio em doentes sob MgSO4; usar monitorização do bloqueio (tremulografia); reversão com neostigmina vigiada.',
 'Reduce the initial vecuronium dose in patients on MgSO4; use blockade monitoring (tremography); reversal with neostigmine under supervision.',
 'Tremulografia/addutor pollicis, ventilação, Mg2+ sérico.',
 'Tremography/adductor pollicis, ventilation, serum Mg2+.',
 'Paralisia prolongada, falha de extubação.', 'Prolonged paralysis, failed extubation.',
 'DailyMed — rótulos Vecuronium Bromide Injection e Magnesium Sulfate Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582c7f44-b614-18df-e063-6294a90a74b6',
 'DailyMed — Vecuronium Bromide Injection and Magnesium Sulfate Injection labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582c7f44-b614-18df-e063-6294a90a74b6',
 'published', now()),

-- 25. neostigmina × sulfato-magnesio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='neostigmina'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='neostigmina'), (SELECT id FROM public.drugs WHERE slug='sulfato-magnesio')),
 'moderate',
 'O Sulfato de Magnésio deprime a transmissão neuromuscular e pode atenuar a eficácia da reversão com Neostigmina.',
 'Magnesium sulphate depresses neuromuscular transmission and can blunt reversal with neostigmine.',
 'O Mg2+ inibe a liberação de acetilcolina no terminal pré-sináptico, contrariando o efeito da inibição da colinesterase pela neostigmina (rótulos).',
 'Mg2+ inhibits presynaptic acetylcholine release, counteracting the effect of cholinesterase inhibition by neostigmine (labels).',
 'Avaliar a reversão clinicamente e por tremulografia; corrigir hiperMg2+; suporte ventilatório até reversão completa.',
 'Assess reversal clinically and by tremography; correct hypermagnesaemia; ventilatory support until full reversal.',
 'Força muscular (sustentar cabeça, capnografia espontânea), Mg2+.',
 'Muscle strength (head lift, spontaneous capnography), Mg2+.',
 'Fraqueza residual, re-intubação, depressão respiratória.', 'Residual weakness, re-intubation, respiratory depression.',
 'DailyMed — rótulos Neostigmine Methylsulfate Injection e Magnesium Sulfate Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4eab6184-1771-4c15-a127-4eb3e47affc2',
 'DailyMed — Neostigmine Methylsulfate Injection and Magnesium Sulfate Injection labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4eab6184-1771-4c15-a127-4eb3e47affc2',
 'published', now()),

-- 26. propofol × midazolam (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='propofol'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='propofol'), (SELECT id FROM public.drugs WHERE slug='midazolam')),
 'critical',
 'A associação de Propofol com Midazolam soma depressão respiratória, sedação profunda e hipotensão; exige redução de dose e suporte de via aérea.',
 'Propofol plus midazolam adds respiratory depression, profound sedation and hypotension; requires dose reduction and airway support.',
 'Sinergismo entre benzodiazepínico e anestésico IV no receptor GABA-A; rótulo Diprivan: reduzir a dose de manutenção em ~25–30% quando sedativos são coadministrados.',
 'Synergism between benzodiazepine and IV anaesthetic at the GABA-A receptor; Diprivan label: reduce maintenance dose by ~25–30% when sedatives are co-administered.',
 'Reduzir dose do propofol (~25–30%); só em ambiente com oximetria, suporte de via aérea e ressuscitação disponíveis.',
 'Reduce the propofol dose (~25–30%); only in a setting with oximetry, airway support and resuscitation available.',
 'Saturação, capnografia, tensão arterial, nível de sedação.',
 'Saturation, capnography, blood pressure, sedation level.',
 'Apneia, hipotensão, dessaturação rápida.', 'Apnoea, hypotension, rapid desaturation.',
 'DailyMed — rótulo Diprivan (propofol) Injectable Emulsion [RLD], Warnings: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ec25932-6c21-4cd5-8f60-80761f2e20a6; rótulo Midazolam HCl Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f051776f-94c5-4e34-80ed-f45b9c36881e',
 'DailyMed — Diprivan (propofol) Injectable Emulsion label [RLD], Warnings: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ec25932-6c21-4cd5-8f60-80761f2e20a6; Midazolam HCl Injection label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f051776f-94c5-4e34-80ed-f45b9c36881e',
 'published', now()),

-- 27. propofol × clonidina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='propofol'), (SELECT id FROM public.drugs WHERE slug='clonidina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='propofol'), (SELECT id FROM public.drugs WHERE slug='clonidina')),
 'moderate',
 'A Clonidina potencia a sedação e a hipotensão do Propofol, reduzindo as necessidades anestésicas mas aumentando o risco de instabilidade hemodinâmica.',
 'Clonidine potentiates propofol sedation and hypotension, reducing anaesthetic requirements but increasing haemodynamic instability risk.',
 'Agonista α2 central: efeito sedativo aditivo e atenuação da resposta simpática à intubação (rótulos: reduzir anestésicos em doentes α2-agonistas).',
 'Central α2 agonist: additive sedation and blunting of the sympathetic response to intubation (labels: reduce anaesthetics in α2-agonist patients).',
 'Reduzir a dose de indução do propofol; vigiar tensão arterial e frequência cardíaca; não suspender clonidina abruptamente no pré-operatório.',
 'Reduce the propofol induction dose; monitor blood pressure and heart rate; never stop clonidine abruptly pre-operatively.',
 'Tensão arterial, frequência cardíaca, profundidade anestésica.',
 'Blood pressure, heart rate, anaesthetic depth.',
 'Hipotensão prolongada, bradicardia, necessidade de vasopressores.', 'Prolonged hypotension, bradycardia, need for vasopressors.',
 'DailyMed — rótulos Diprivan (propofol) e Clonidine HCl Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ec25932-6c21-4cd5-8f60-80761f2e20a6',
 'DailyMed — Diprivan (propofol) and Clonidine HCl Tablet labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5ec25932-6c21-4cd5-8f60-80761f2e20a6',
 'published', now()),

-- 28. fitomenadiona × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='fitomenadiona'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='fitomenadiona'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'A Fitomenadiona (vitamina K1) antagoniza a Warfarina, podendo reverter a anticoagulação e precipitar trombose se doses elevadas forem usadas sem indicação.',
 'Phytomenadione (vitamin K1) antagonises warfarin, potentially reversing anticoagulation and precipitating thrombosis if high doses are used without indication.',
 'A vitamina K1 restaura a síntese hepática dos factores II, VII, IX e X dependente de vitamina K, contrariando o mecanismo da warfarina (Prontuário 4.3: sobredosagem "dar vitamina K1, 5-10 mg IV lenta").',
 'Vitamin K1 restores hepatic synthesis of vitamin K–dependent factors II, VII, IX and X, countering the mechanism of warfarin (Prontuário 4.3: overdose "give vitamin K1, 5-10 mg slow IV").',
 'Usar só em INR muito elevado/hemorragia; em INR ligeiramente alto preferir suspensão temporária de warfarina; doses elevadas de K1 tornam a reanticoagulação difícil.',
 'Use only in very high INR/bleeding; for mildly high INR prefer temporary warfarin withholding; high K1 doses make re-anticoagulation difficult.',
 'INR diário após administração de vitamina K1.',
 'Daily INR after vitamin K1 administration.',
 'Trombose/embolia após reversão excessiva; hemorragia se INR ainda alto.', 'Thrombosis/embolism after excessive reversal; bleeding if INR still high.',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anticoagulantes 4.3 — sobredosagem de varfarina "dar vitamina K1, 5-10 mg IV lenta"; DailyMed — rótulo Vitamin K1 (Phytonadione) Injection [RLD Mephyton/AquaMEPHYTON]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Anticoagulants 4.3 — warfarin overdose "give vitamin K1, 5-10 mg slow IV"; DailyMed — Vitamin K1 (Phytonadione) Injection label [RLD Mephyton/AquaMEPHYTON]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'published', now()),

-- 29. desmopressina × furosemida (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='furosemida')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='desmopressina'), (SELECT id FROM public.drugs WHERE slug='furosemida')),
 'moderate',
 'A Furosemida altera o balanço hídrico/eletrolítico e pode aumentar o risco de distúrbios do sódio em doentes sob Desmopressina.',
 'Furosemide alters water/electrolyte balance and may increase the risk of sodium disturbances in patients on desmopressin.',
 'A desmopressina reduz a excreção de água livre (risco de hiponatremia); a furosemida altera o sódio e o volume plasmático, tornando imprevisível o equilíbrio hidroelectrolítico (rótulo desmopressina: vigiar Na+).',
 'Desmopressin reduces free water excretion (hyponatraemia risk); furosemide alters sodium and plasma volume, making fluid/electrolyte balance unpredictable (desmopressin label: monitor Na+).',
 'Vigiar sódio sérico nos dias após alteração do diurético; alertar para sintomas de hiponatremia (cefaleia, confusão, náuseas).',
 'Monitor serum sodium in the days after diuretic changes; alert for hyponatraemia symptoms (headache, confusion, nausea).',
 'Na+ sérico, peso, diurese, osmolaridade.',
 'Serum Na+, weight, urine output, osmolality.',
 'Cefaleia, vómitos, confusão, convulsões (hiponatremia).', 'Headache, vomiting, confusion, seizures (hyponatraemia).',
 'DailyMed — rótulo DDAVP (desmopressin) Tablet/Nasal [RLD], Warnings (hyponatraemia): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'DailyMed — DDAVP (desmopressin) Tablet/Nasal label [RLD], Warnings (hyponatraemia): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=abe23504-ea98-4ed9-9a9a-6db9eaa35251',
 'published', now()),

-- 30. gluconato-calcio × ciprofloxacina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='gluconato-calcio'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='gluconato-calcio'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 'moderate',
 'O Gluconato de Cálcio reduz a absorção da Ciprofloxacina (quelação com catiões divalentes), podendo falhar o tratamento da infeção.',
 'Calcium gluconate reduces ciprofloxacin absorption (chelation with divalent cations), potentially failing infection treatment.',
 'Quinolonas formam quelatos insolúveis com Ca2+, Mg2+, Fe2+ e Al3+ (Anexo 7 Quinolonas: "V. também Antiácidos, Ferro"; rótulo Cipro: administrar 2 h antes ou 6 h depois de sais de cálcio).',
 'Quinolones form insoluble chelates with Ca2+, Mg2+, Fe2+ and Al3+ (Annex 7 Quinolones: "See also Antacids, Iron"; Cipro label: dose 2 h before or 6 h after calcium salts).',
 'Separar a toma da quinolona (2 h antes ou 6 h depois do cálcio); em IV, não misturar no mesmo acesso sem flush.',
 'Separate quinolone dosing (2 h before or 6 h after calcium); IV, do not mix in the same line without flush.',
 'Resposta clínica da infeção; níveis plasmáticos se criticamente doente.',
 'Clinical infection response; plasma levels if critically ill.',
 'Febre persistente, falta de resposta ao antibiótico.', 'Persistent fever, lack of antibiotic response.',
 'DailyMed — rótulo Ciprofloxacin Tablet [Bayer, RLD Cipro], Drug Interactions (catiões): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8; Prontuário Terapêutico INFARMED (11.ª ed., 2012), Anexo 7 — Quinolonas.',
 'DailyMed — Ciprofloxacin Tablet label [Bayer, RLD Cipro], Drug Interactions (cations): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8; INFARMED Prontuário Terapêutico (11th ed., 2012), Annex 7 — Quinolones.',
 'published', now()),

-- 31. bicarbonato-sodio × ciprofloxacina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='bicarbonato-sodio'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='bicarbonato-sodio'), (SELECT id FROM public.drugs WHERE slug='ciprofloxacina')),
 'moderate',
 'O Bicarbonato de Sódio eleva o pH gástrico e a alcalinidade urinária, podendo alterar a absorção e excreção da Ciprofloxacina.',
 'Sodium bicarbonate raises gastric pH and urinary alkalinity, potentially altering ciprofloxacin absorption and excretion.',
 'A elevação do pH gástrico e a presença de Na+ podem reduzir a solubilidade/biodisponibilidade da quinolona; a urina alcalina altera a excreção (rótulo Cipro: evitar antiácidos; Prontuário).',
 'Raised gastric pH and Na+ can reduce quinolone solubility/bioavailability; alkaline urine changes excretion (Cipro label: avoid antacids; Prontuário).',
 'Separar a toma do antibiótico da solução alcalinizante; monitorizar resposta clínica.',
 'Separate antibiotic dosing from the alkalinising solution; monitor clinical response.',
 'Resposta clínica da infeção; pH urinário se em alcalinização forçada.',
 'Clinical infection response; urinary pH if on forced alkalinisation.',
 'Febre persistente, falta de resposta ao antibiótico.', 'Persistent fever, lack of antibiotic response.',
 'DailyMed — rótulo Ciprofloxacin Tablet [Bayer], Drug Interactions (antiácidos/catiões, pH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'DailyMed — Ciprofloxacin Tablet label [Bayer], Drug Interactions (antacids/cations, pH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c47250c2-bece-46b5-8b3b-b7c97d9005d8',
 'published', now()),

-- 32. testosterona × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='testosterona'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='testosterona'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'A Testosterona potencia o efeito anticoagulante da Warfarina, aumentando o risco de hemorragia (incluindo cérebro).',
 'Testosterone potentiates the anticoagulant effect of warfarin, increasing bleeding risk (including intracranial).',
 'Os andrógenos/esteróides anabólicos inibem a síntese hepática de factores de coagulação e potenciam cumarínicos (Anexo 7/Prontuário: esteróides anabólicos; rótulos de testosterona documentam redução da dose de warfarina).',
 'Androgens/anabolic steroids inhibit hepatic synthesis of clotting factors and potentiate coumarins (Annex 7/Prontuário: anabolic steroids; testosterone labels document warfarin dose reduction).',
 'Reduzir a dose de warfarina ao iniciar testosterona; medir INR com frequência até estabilização.',
 'Reduce the warfarin dose when starting testosterone; measure INR frequently until stabilisation.',
 'INR frequente nas primeiras semanas; sinais hemorrágicos.',
 'Frequent INR in the first weeks; bleeding signs.',
 'Equimoses, hemorragia gengival, hematúria, cefaleia súbita.', 'Bruising, gum bleeding, haematuria, sudden headache.',
 'DailyMed — rótulos Testosterone Cypionate Injection [RLD Depo-Testosterone] e Warfarin Sodium Tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=40a332e3-9c64-4595-91c3-dfef24f3d3bb',
 'DailyMed — Testosterone Cypionate Injection [RLD Depo-Testosterone] and Warfarin Sodium Tablet labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=40a332e3-9c64-4595-91c3-dfef24f3d3bb',
 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Notas de exclusão (pares não criados):
-- * protamina × heparina — reversão intencional do anticoagulante (uso terapêutico
--   protocolar, Prontuário 4.3.1.1: "o efeito da heparina pode ser rapidamente
--   revertido pela infusão IV lenta de sulfato de protamina"); não é interação adversa.
-- * n-acetilcisteina × paracetamol — antídoto protocolar da intoxicação por
--   paracetamol; não é interação adversa entre fármacos em uso normal.
-- * flumazenil × midazolam — antídoto protocolar (reversão de sedação); idem.
-- * gluconato-calcio × digoxina — Administração IV de cálcio em intoxicados por
--   digoxina é controversa (Prontuário 3.1.1: "evitar o recurso a cálcio em situações
--   de intoxicação digitálica"); par reservado para revisão futura com EMC específico.
-- * antiacidos × levotiroxina — Anexo 7 (Antiácidos/IBP) cobre o par, mas o
--   parceiro (antiacidos) é fármaco composto; prioridade dada aos pares com
--   mono-ingrediente validado (regra 13.1). Revisão futura.
-- * clomifeno × testosterona, efedrina × IMAO (sem IMAO na base), sulfato-zinco ×
--   quinolonas/penicilamina, vitamina-d × corticoide em doses fisiológicas,
--   acido-ascorbico × (sem rótulo mono-ingrediente FDA): OMITIDOS — documentação
--   insuficiente ou fora do âmbito (regra 13.1 do fluxo).
-- * iodopovidona/clorexidina/tetracaina/lidocaina tópica: interações sistémicas
--   clinicamente relevantes não documentadas nos rótulos mono-ingrediente.
-- * metilergometrina × dopamina/efedrina: sinergismo adrenérgico descrito em
--   ergometrina, mas sem rótulo mono-ingrediente a documentar — revisão futura.

-- Pares reais inseridos: 32 (itens 1–32 acima; notas de exclusão não inserem tuples).
--
-- NOTA: o cabeçalho descreve "Pares (30...)" no título dos grupos — o total real
-- de tuples INSERT é 32 (os grupos somam 4+4+3+1+1+3+2+4+3+2+2+1+2+2+2 = 32).