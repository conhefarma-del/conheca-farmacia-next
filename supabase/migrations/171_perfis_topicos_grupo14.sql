-- =====================================================================
-- 171: Fluxo 6 — Perfis de fármacos tópicos do grupo 14
--      (Otorrinolaringológicos) — lote piloto
-- ---------------------------------------------------------------------
-- Critérios (secção 17 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * monografia própria no Prontuário Terapêutico (INFARMED, 11.ª ed.)
--     num subgrupo tópico (14.1.3 anti-histamínicos, 14.1.5 antibióticos);
--   * relevância de procura real nas farmácias;
--   * fonte disponível para ancorar o conteúdo (DailyMed/FDA preferida;
--     Prontuário quando o rótulo não existe — regra do padrão 088).
-- ---------------------------------------------------------------------
-- Lote: mupirocina (14.1.5), azelastina (14.1.3), levocabastina (14.1.3)
--       + enriquecimento da budesonida já existente (CSI inalado) com a
--       via nasal (mesma molécula — sem duplicar o slug).
-- ---------------------------------------------------------------------
-- Regras de conteúdo (17.3):
--   * drug_interactions: SEM pares (Fluxo 6 — nada de pares artificiais);
--   * drug_profiles: efeitos locais, precauções, ênfase em gravidez e em
--     sinais de absorção sistémica;
--   * drug_pharmacology: absorption_pt/en é o campo-chave (absorção
--     sistémica mínima dos tópicos);
--   * drug_pregnancy_info: sempre preenchida;
--   * drug_disease_interactions: só as documentadas;
--   * drug_food_interactions: só as documentadas (exceção: azelastina ×
--     álcool, documentada no rótulo — depressão do SNC).
-- ---------------------------------------------------------------------
-- Fontes:
--   * Mupirocina: DailyMed/FDA — pomada aprovada (setid
--     b8e115ce-c8ff-4d08-b865-71dc4d0e51a1, KESIN PHARMA) para
--     segurança/absorção; Prontuário 14.1.5 (BACTROBAN nasal 20 mg/g)
--     para a indicação de erradicação nasal de MRSA — o rótulo FDA da
--     pomada declara explicitamente "not for intranasal use", pelo que a
--     indicação nasal se ancora no Prontuário (o produto nasal específico
--     BACTROBAN NASAL não está indexado na API DailyMed).
--   * Azelastina: DailyMed/FDA — spray nasal aprovado (setid
--     77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56, ASCEND LABORATORIES).
--   * Levocabastina: descontinuada nos EUA (sem rótulo FDA), no Reino
--     Unido (EMC sem produto ativo) e no Canadá (Health Canada sem
--     registo) — fonte: Prontuário 14.1.3 (LIVOSTIN), conteúdo autoral
--     com a fonte citada (regra do padrão 088).
--   * Budesonida (via nasal): DailyMed/FDA — RHINOCORT AQUA (setid
--     ffca32a2-fbef-40bb-b0f0-73f63e18e747, Physicians Total Care) +
--     Prontuário 14.1.2.
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING (e (drug_id,
-- entity_slug)/(drug_id, condition_slug) nas dimensões). Aplicar na
-- ordem: fármacos → perfis/farmacologia → dimensões. Reaplicar é seguro.
-- =====================================================================

-- =====================================================================
-- 1. Fármacos novos (3) — padrão 7.3
-- =====================================================================
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
VALUES
  ('mupirocina', 'Mupirocina', 'Mupirocin', 'Antibiótico tópico (nasal/dérmico)', 'Topical antibiotic (nasal/dermal)', ARRAY['Mupirocina', 'Bactroban'], 'published', 202),
  ('azelastina', 'Azelastina', 'Azelastine', 'Anti-histamínico tópico (nasal)', 'Topical antihistamine (nasal)', ARRAY['Azelastina', 'Allergodil'], 'published', 203),
  ('levocabastina', 'Levocabastina', 'Levocabastine', 'Anti-histamínico tópico (nasal)', 'Topical antihistamine (nasal)', ARRAY['Levocabastina', 'Livostin'], 'published', 204);

-- =====================================================================
-- 2. Perfis (drug_profiles) — padrão 7.6
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
  ('mupirocina',
   E'A mupirocina é um antibiótico de uso tópico (pomada nasal ou creme) usado sobretudo para eliminar o Staphylococcus aureus resistente à meticilina (MRSA) da cavidade nasal e para tratar infeções superficiais da pele. A absorção sistémica é mínima, o que a torna segura para uso local, mas deve ser reservada para os casos indicados para evitar resistências.',
   E'Mupirocin is a topical antibiotic (nasal ointment or cream) used mainly to eliminate methicillin-resistant Staphylococcus aureus (MRSA) from the nasal cavity and to treat superficial skin infections. Systemic absorption is minimal, which makes it safe for local use, but it should be reserved for the indicated cases to avoid resistance.',
   E'Antibiótico tópico que inibe a síntese proteica bacteriana por ligação específica à isoleucil-tRNA sintetase (IleRS) bacteriana. O Prontuário Terapêutico reserva a pomada nasal (BACTROBAN 20 mg/g) para a erradicação de portadores nasais de MRSA em doentes e prestadores de saúde; a pomada deve ser aplicada 3 vezes ao dia durante 5 dias, com colheita de controlo 2 dias após a cessação, e o tratamento não deve exceder 7 dias nem ser repetido mais de uma vez (risco de resistência).',
   E'Topical antibiotic that inhibits bacterial protein synthesis by specific binding to bacterial isoleucyl-tRNA synthetase (IleRS). The Prontuário Terapêutico reserves the nasal ointment (BACTROBAN 20 mg/g) for eradicating nasal MRSA carriers in patients and healthcare workers; the ointment should be applied 3 times daily for 5 days, with a follow-up swab 2 days after stopping, and treatment should not exceed 7 days nor be repeated more than once (resistance risk).',
   E'• Erradicação de portadores nasais de Staphylococcus aureus resistente à meticilina (MRSA) — pomada nasal (Prontuário 14.1.5)\\n• Infeções superficiais da pele por cocos Gram-positivos sensíveis (impetigo — rótulo FDA)',
   E'• Eradication of nasal carriers of methicillin-resistant Staphylococcus aureus (MRSA) — nasal ointment (Prontuário 14.1.5)\\n• Superficial skin infections due to susceptible Gram-positive cocci (impetigo — FDA label)',
   E'• Irritação local e ligeira ardência no local de aplicação\\n• Raros casos de irritação e sensibilização (Prontuário)\\n• O rótulo FDA da pomada documenta irritação, prurido e eritema em ensaios clínicos',
   E'• Local irritation and mild burning at the application site\\n• Rare irritation and sensitisation (Prontuário)\\n• The FDA ointment label reports irritation, pruritus and erythema in clinical trials',
   E'• Evitar durante a gravidez e o aleitamento (Prontuário 14.1.5 — "Evitar durante a gravidez e o aleitamento")\\n• O rótulo FDA da pomada não é para uso intranasal, oftálmico ou em mucosas; a indicação nasal baseia-se no Prontuário (BACTROBAN nasal)\\n• Não usar em associação com outros produtos tópicos no mesmo local\\n• Duração limitada (máx. 7 dias) e sem repetição, para evitar resistência (Prontuário)',
   E'• Avoid during pregnancy and breastfeeding (Prontuário 14.1.5 — "Avoid during pregnancy and breastfeeding")\\n• The FDA ointment label is not for intranasal, ophthalmic or mucosal use; the nasal indication is based on the Prontuário (BACTROBAN nasal)\\n• Do not use with other topical products on the same site\\n• Limited duration (max. 7 days) and no repetition, to avoid resistance (Prontuário)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Mupirocina pomada (KESIN PHARMA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Mupirocina, 14.1.5',
   'DailyMed/FDA (NIH/NLM) — approved Mupirocin ointment label (KESIN PHARMA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Mupirocin, 14.1.5'),

  ('azelastina',
   E'A azelastina é um anti-histamínico aplicado diretamente no nariz (spray nasal) para aliviar os sintomas da rinite alérgica — espirros, corrimento e comichão nasal. Atua localmente, mas parte é absorvida para a circulação e pode causar sonolência, por isso deve ter-se cuidado com o álcool e com atividades que exijam atenção.',
   E'Azelastine is an antihistamine applied directly into the nose (nasal spray) to relieve allergic rhinitis symptoms — sneezing, runny nose and nasal itching. It acts locally, but part is absorbed into the circulation and can cause drowsiness, so caution is needed with alcohol and with activities requiring attention.',
   E'Anti-histamínico H1 de aplicação tópica nasal. Bloqueia os recetores H1 da histamina na mucosa nasal, reduzindo espirros, rinorreia e prurido. Após administração intranasal, a biodisponibilidade sistémica é de cerca de 40% (rótulo FDA), o que explica os efeitos sistémicos possíveis (sonolência). O rótulo documenta: "Concurrent use of Azelastine HCl Nasal Spray with alcohol or other central nervous system depressants should be avoided because reductions in alertness and impairment of central nervous system performance may occur".',
   E'H1 antihistamine for topical nasal use. Blocks H1 histamine receptors in the nasal mucosa, reducing sneezing, rhinorrhoea and itching. After intranasal administration, systemic bioavailability is about 40% (FDA label), which explains the possible systemic effects (drowsiness). The label documents: "Concurrent use of Azelastine HCl Nasal Spray with alcohol or other central nervous system depressants should be avoided because reductions in alertness and impairment of central nervous system performance may occur".',
   E'• Rinite alérgica (sazonal e permanente) — adultos e crianças > 6 anos (Prontuário 14.1.3)\\n• Rótulo FDA: sintomas da rinite alérgica sazonal (adultos e crianças ≥ 5 anos) e rinite vasomotora (adultos e adolescentes ≥ 12 anos)',
   E'• Allergic rhinitis (seasonal and perennial) — adults and children > 6 years (Prontuário 14.1.3)\\n• FDA label: symptoms of seasonal allergic rhinitis (adults and children ≥ 5 years) and vasomotor rhinitis (adults and adolescents ≥ 12 years)',
   E'• Irritação ocasional da mucosa nasal, alteração do gosto (sabor amargo)\\n• Sonolência e fadiga — efeito sistémico (absorção ~40%)\\n• Menos frequente: secura da boca e narinas, aumento do apetite e do peso, náuseas, vómitos, dor epigástrica, epistáxis e erupção (Prontuário)',
   E'• Occasional nasal mucosa irritation, taste alteration (bitter taste)\\n• Drowsiness and fatigue — systemic effect (~40% absorption)\\n• Less common: dry mouth and nose, increased appetite and weight, nausea, vomiting, epigastric pain, epistaxis and rash (Prontuário)',
   E'• Evitar o álcool e outros depressores do sistema nervoso central durante o uso (risco de redução do estado de alerta — rótulo FDA)\\n• Alergia à azelastina e ao cloreto de benzalcónio (contraindicação — Prontuário)\\n• Cautela na condução e em tarefas que exijam atenção enquanto se avalia a tolerância (sonolência)',
   E'• Avoid alcohol and other central nervous system depressants during use (risk of reduced alertness — FDA label)\\n• Allergy to azelastine and benzalkonium chloride (contraindication — Prontuário)\\n• Caution when driving and performing tasks requiring attention while tolerance is assessed (drowsiness)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Azelastina spray nasal (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Azelastina, 14.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Azelastine nasal spray label (ASCEND LABORATORIES): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Azelastine, 14.1.3'),

  ('levocabastina',
   E'A levocabastina é um anti-histamínico de aplicação tópica no nariz, indicado na rinite alérgica (sazonal e permanente). Atua localmente para aliviar espirros, corrimento e comichão nasal. Tal como outros anti-histamínicos, pode causar sonolência e irritação local. Está contraindicada na gravidez.',
   E'Levocabastine is a topically applied antihistamine for the nose, indicated for allergic rhinitis (seasonal and perennial). It acts locally to relieve sneezing, runny nose and nasal itching. Like other antihistamines, it can cause drowsiness and local irritation. It is contraindicated in pregnancy.',
   E'Anti-histamínico H1 de segunda geração de aplicação tópica nasal, indicado na rinite alérgica sazonal e permanente. Bloqueia os recetores H1 na mucosa nasal com início de ação rápido e efeito local; a absorção sistémica é limitada, mas podem ocorrer efeitos sistémicos ligeiros (sonolência). Descontinuado nos EUA, Reino Unido e Canadá — a monografia do Prontuário Terapêutico (LIVOSTIN, 0,5 mg/ml) é a fonte desta ficha (regra do padrão 088: conteúdo autoral com fonte citada).',
   E'Second-generation H1 antihistamine for topical nasal use, indicated for seasonal and perennial allergic rhinitis. Blocks H1 receptors in the nasal mucosa with rapid onset of action and local effect; systemic absorption is limited, but mild systemic effects (drowsiness) may occur. Discontinued in the US, UK and Canada — the Prontuário Terapêutico monograph (LIVOSTIN, 0.5 mg/ml) is the source for this profile (pattern 088 rule: authored content with cited source).',
   E'• Rinite alérgica (sazonal e permanente) — adultos e crianças > 12 anos (Prontuário 14.1.3)',
   E'• Allergic rhinitis (seasonal and perennial) — adults and children > 12 years (Prontuário 14.1.3)',
   E'• Irritação ocasional da mucosa nasal, alteração do gosto (sabor amargo)\\n• Sonolência e fadiga, irritabilidade, secura da boca e narinas, náuseas, epistáxis e erupção (Prontuário)',
   E'• Occasional nasal mucosa irritation, taste alteration (bitter taste)\\n• Drowsiness and fatigue, irritability, dry mouth and nose, nausea, epistaxis and rash (Prontuário)',
   E'• Contraindicada na gravidez (Prontuário 14.1.3 — "Alergia à levocabastina e gravidez")\\n• Alergia à levocabastina (contraindicação)\\n• Utilizar com precaução nos doentes com insuficiência renal (Prontuário)',
   E'• Contraindicated in pregnancy (Prontuário 14.1.3 — "Allergy to levocabastine and pregnancy")\\n• Allergy to levocabastine (contraindication)\\n• Use with caution in patients with renal impairment (Prontuário)',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Levocabastina, 14.1.3 (LIVOSTIN, 0,5 mg/ml). Fármaco descontinuado nos EUA/UK/CA — sem rótulo FDA, EMC ou Health Canada ativo',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Levocabastine, 14.1.3 (LIVOSTIN, 0.5 mg/ml). Drug discontinued in US/UK/CA — no active FDA, EMC or Health Canada label')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
        indications_pt, indications_en, side_effects_pt, side_effects_en,
        precautions_pt, precautions_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 3. Farmacologia (drug_pharmacology) — padrão 7.6; absorption é o
--    campo-chave (absorção sistémica mínima dos tópicos)
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
  ('mupirocina',
   E'Antibiótico tópico de largo espectro sobre Gram-positivos (incluindo S. aureus e S. pyogenes) e alguns Gram-negativos. A aplicação oclusiva na pele intacta durante 24 horas não produziu absorção sistémica mensurável (menos de 1,1 ng/ml de sangue total — rótulo FDA), o que confirma o perfil local do fármaco.',
   E'Topical antibiotic with broad activity against Gram-positive organisms (including S. aureus and S. pyogenes) and some Gram-negative organisms. Occlusive application to intact skin for 24 hours produced no measurable systemic absorption (less than 1.1 ng/ml whole blood — FDA label), confirming the drug\'s local profile.',
   E'Inibe a síntese proteica bacteriana por ligação reversível e específica à isoleucil-tRNA sintetase (IleRS), bloqueando a incorporação de isoleucina nos tRNA bacterianos — mecanismo sem homólogo estrutural nos mamíferos, o que explica a seletividade.',
   E'Inhibits bacterial protein synthesis by reversible, specific binding to isoleucyl-tRNA synthetase (IleRS), blocking the incorporation of isoleucine into bacterial tRNA — a mechanism with no structural homologue in mammals, which explains its selectivity.',
   E'O metabolismo é essencialmente local no local de aplicação; a fração absorvida é rapidamente metabolizada em ácido mupirocínico (inativo).',
   E'Metabolism is essentially local at the application site; the absorbed fraction is rapidly metabolised to the inactive mupirocic acid.',
   E'Absorção sistémica mínima pela mucosa nasal e pela pele intacta: aplicação oclusiva de pomada marcada durante 24 h não mostrou absorção mensurável (< 1,1 ng/ml) — "no measurable systemic absorption" (rótulo FDA). A segurança local é o perfil dominante.',
   E'Minimal systemic absorption through nasal mucosa and intact skin: occlusive application of radiolabelled ointment for 24 h showed no measurable absorption (< 1.1 ng/ml) — "no measurable systemic absorption" (FDA label). Local safety is the dominant profile.',
   E'Meia-vida de eliminação após administração intravenosa: 20 a 40 minutos para a mupirocina e 30 a 80 minutos para o metabolito (dados experimentais do rótulo FDA).',
   E'Elimination half-life after intravenous administration: 20 to 40 minutes for mupirocin and 30 to 80 minutes for the metabolite (experimental data from the FDA label).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Mupirocina pomada, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1',
   'DailyMed/FDA (NIH/NLM) — approved Mupirocin ointment label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1'),

  ('azelastina',
   E'Anti-histamínico H1 com ação antagonista seletiva sobre os recetores H1 da histamina; estabiliza adicionalmente os mastócitos em grau menor. O efeito clínico na rinite estabelece-se em minutos a horas após a aplicação intranasal.',
   E'H1 antihistamine with selective antagonism of histamine H1 receptors; it also stabilises mast cells to a lesser degree. The clinical effect in rhinitis develops within minutes to hours after intranasal application.',
   E'Bloqueio competitivo e seletivo dos recetores H1 da histamina na mucosa nasal, reduzindo a vasodilatação, o aumento da permeabilidade capilar e a estimulação das terminações nervosas responsáveis pelos espirros e pelo prurido.',
   E'Competitive, selective blockade of histamine H1 receptors in the nasal mucosa, reducing vasodilation, increased capillary permeability and the nerve-ending stimulation responsible for sneezing and itching.',
   E'Metabolizado no fígado, sobretudo pelo CYP3A4, com formação do metabolito ativo desmetilazelastina; a via principal de eliminação é renal (excreção urinária do fármaco e metabolitos).',
   E'Metabolised in the liver, mainly by CYP3A4, with formation of the active metabolite desmethylazelastine; the main route of elimination is renal (urinary excretion of the drug and metabolites).',
   E'Absorção sistémica relevante para um tópico: biodisponibilidade sistémica de aproximadamente 40% após administração intranasal, com concentrações máximas (Cmax) em 2 a 3 horas (rótulo FDA). É este perfil de absorção que explica os efeitos sistémicos possíveis (sonolência).',
   E'Relevant systemic absorption for a topical drug: systemic bioavailability of approximately 40% after intranasal administration, with maximum plasma concentrations (Cmax) achieved in 2 to 3 hours (FDA label). This absorption profile explains the possible systemic effects (drowsiness).',
   E'Volume de distribuição no estado estacionário de 14,5 L/kg (dados iv/oral); ligação às proteínas plasmáticas de aproximadamente 88% para a azelastina e 97% para a desmetilazelastina (rótulo FDA).',
   E'Steady-state volume of distribution of 14.5 L/kg (iv/oral data); plasma protein binding of approximately 88% for azelastine and 97% for desmethylazelastine (FDA label).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Azelastina spray nasal, secção 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56',
   'DailyMed/FDA (NIH/NLM) — approved Azelastine nasal spray label, section 12 Clinical Pharmacology: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56'),

  ('levocabastina',
   E'Anti-histamínico H1 de segunda geração de aplicação tópica nasal, com início de ação rápido (minutos) e duração prolongada do efeito local; a componente sistémica é limitada, mas não desprezável (sonolência ligeira possível).',
   E'Second-generation H1 antihistamine for topical nasal use, with rapid onset of action (minutes) and prolonged local effect; the systemic component is limited but not negligible (possible mild drowsiness).',
   E'Antagonismo competitivo e seletivo dos recetores H1 da histamina na mucosa nasal, com alívio do prurido, espirros e rinorreia da rinite alérgica.',
   E'Competitive, selective antagonism of histamine H1 receptors in the nasal mucosa, relieving the itching, sneezing and rhinorrhoea of allergic rhinitis.',
   E'Metabolismo hepático com excreção renal; a eliminação é predominantemente renal (por isso a precaução na insuficiência renal registada no Prontuário).',
   E'Hepatic metabolism with renal excretion; elimination is predominantly renal (hence the caution in renal impairment recorded in the Prontuário).',
   E'Fármaco tópico nasal com absorção sistémica limitada pela mucosa nasal; o perfil local é predominante, mas a fração absorvida é suficiente para efeitos sistémicos ligeiros (sonolência). A monografia do Prontuário não quantifica a absorção — valor não documentado na fonte.',
   E'Topical nasal drug with limited systemic absorption through the nasal mucosa; the local profile predominates, but the absorbed fraction is enough for mild systemic effects (drowsiness). The Prontuário monograph does not quantify absorption — value not documented in the source.',
   E'Meia-vida não documentada na monografia do Prontuário (fonte única disponível — fármaco descontinuado nos EUA/UK/CA).',
   E'Half-life not documented in the Prontuário monograph (only available source — drug discontinued in US/UK/CA).',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Levocabastina, 14.1.3 (LIVOSTIN, 0,5 mg/ml)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Levocabastine, 14.1.3 (LIVOSTIN, 0.5 mg/ml)')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
        metabolism_pt, metabolism_en, absorption_pt, absorption_en,
        half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 4. Gravidez (drug_pregnancy_info) — sempre preenchida (17.3)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('mupirocina', 'caution',
   E'Prontuário: "Evitar durante a gravidez e o aleitamento". Rótulo FDA (pomada): dados humanos insuficientes; sem toxicidade do desenvolvimento observada em ratos (160 mg/kg/dia) e coelhos (40 mg/kg/dia) — a absorção sistémica mínima reduz o risco de exposição fetal.',
   E'Prontuário: "Avoid during pregnancy and breastfeeding". FDA label (ointment): insufficient human data; no developmental toxicity observed in rats (160 mg/kg/day) and rabbits (40 mg/kg/day) — minimal systemic absorption reduces the risk of fetal exposure.',
   E'Absorção sistémica mínima; o risco de exposição fetal é baixo, mas o Prontuário recomenda evitar durante a gravidez.',
   E'Minimal systemic absorption; the risk of fetal exposure is low, but the Prontuário recommends avoiding during pregnancy.',
   E'Desconhecido se é excretado no leite; a absorção sistémica mínima sugere exposição infantil negligenciável, mas o Prontuário recomenda evitar durante o aleitamento.',
   E'Unknown whether it is excreted in breast milk; minimal systemic absorption suggests negligible infant exposure, but the Prontuário recommends avoiding during breastfeeding.',
   E'Não aplicável (uso tópico pontual; sem necessidade de contraceção específica).',
   E'Not applicable (occasional topical use; no need for specific contraception).',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Mupirocina, 14.1.5 ; DailyMed/FDA — rótulo aprovado Mupirocina pomada, secção 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Mupirocin, 14.1.5 ; DailyMed/FDA — approved Mupirocin ointment label, section 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8e115ce-c8ff-4d08-b865-71dc4d0e51a1'),

  ('azelastina', 'caution',
   E'Rótulo FDA: dados limitados de experiência pós-comercialização de décadas em grávidas não identificaram risco associado de aborto, malformações ou outros desfechos adversos materno-fetais; sem evidência de dano fetal em estudos animais nas doses orais ~5× a dose clínica diária.',
   E'FDA label: limited postmarketing data over decades of use in pregnant women have not identified an associated risk of miscarriage, birth defects or other adverse maternal-fetal outcomes; no evidence of fetal harm in animal studies at oral doses ~5× the clinical daily dose.',
   E'Pode ser usado na gravidez se o benefício justificar o risco; sem risco identificado nos dados disponíveis.',
   E'May be used in pregnancy if the benefit justifies the risk; no risk identified in the available data.',
   E'Sem dados sobre a presença no leite humano; monitorizar o lactente para sinais de rejeição do leite (relacionados com a alteração do gosto) durante o uso (rótulo FDA).',
   E'No data on presence in human milk; monitor the breastfed infant for signs of milk rejection (related to taste alteration) during use (FDA label).',
   E'Não aplicável (sem contraceção específica documentada).',
   E'Not applicable (no specific contraception documented).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Azelastina spray nasal, secção 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56',
   'DailyMed/FDA (NIH/NLM) — approved Azelastine nasal spray label, section 8 Use in Specific Populations: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56'),

  ('levocabastina', 'contraindicated',
   E'Prontuário 14.1.3: "Contra-Ind. e Prec.: Alergia à levocabastina e gravidez" — a gravidez é contraindicação explícita da levocabastina tópica nasal.',
   E'Prontuário 14.1.3: "Contraindications and precautions: allergy to levocabastine and pregnancy" — pregnancy is an explicit contraindication of topical nasal levocabastine.',
   E'Contraindicada em todos os trimestres.',
   E'Contraindicated in all trimesters.',
   E'Desconhecido se é excretado no leite; a contraindicação na gravidez e o perfil de segurança limitado desaconselham o uso durante o aleitamento.',
   E'Unknown whether it is excreted in breast milk; the contraindication in pregnancy and the limited safety profile discourage use during breastfeeding.',
   E'Contraceção eficaz recomendada em mulheres em idade fértil em uso do fármaco.',
   E'Effective contraception recommended in women of childbearing potential using the drug.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Levocabastina, 14.1.3',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Levocabastine, 14.1.3')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
        lactation_pt, lactation_en, contraception_pt, contraception_en,
        source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 5. Doença (drug_disease_interactions) — só as documentadas (17.3)
--    (levocabastina × insuficiência renal — Prontuário)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('levocabastina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal insufficiency', 'precaution', 'moderate',
   E'Prontuário 14.1.3: "Utilizar com precaução nos doentes com insuficiência renal" — a eliminação da levocabastina é predominantemente renal, pelo que a insuficiência renal pode aumentar a exposição sistémica e os efeitos adversos (sonolência).',
   E'Prontuário 14.1.3: "Use with caution in patients with renal impairment" — levocabastine elimination is predominantly renal, so renal impairment may increase systemic exposure and adverse effects (drowsiness).',
   E'Usar com precaução e vigiar sinais de efeitos sistémicos (sonolência, fadiga) em doentes com insuficiência renal.',
   E'Use with caution and monitor for signs of systemic effects (drowsiness, fatigue) in patients with renal impairment.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Levocabastina, 14.1.3',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Levocabastine, 14.1.3', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 6. Alimentos (drug_food_interactions) — só as documentadas (17.3)
--    (azelastina × álcool — depressão do SNC, rótulo FDA)
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('azelastina', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   E'Rótulo FDA, secção 7: "Concurrent use of Azelastine HCl Nasal Spray with alcohol or other central nervous system depressants should be avoided because reductions in alertness and impairment of central nervous system performance may occur" — a absorção sistémica (~40%) potencia a depressão do SNC induzida pelo álcool.',
   E'FDA label, section 7: "Concurrent use of Azelastine HCl Nasal Spray with alcohol or other central nervous system depressants should be avoided because reductions in alertness and impairment of central nervous system performance may occur" — systemic absorption (~40%) potentiates alcohol-induced CNS depression.',
   E'Evitar o álcool durante o tratamento com azelastina nasal; advertir para o risco de redução do estado de alerta (condução, máquinas).',
   E'Avoid alcohol during treatment with nasal azelastine; warn about the risk of reduced alertness (driving, machinery).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Azelastina spray nasal, secção 7 Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56',
   'DailyMed/FDA (NIH/NLM) — approved Azelastine nasal spray label, section 7 Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=77b20c6b-f30f-42a9-a0ef-d5d0bd3feb56', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
        mechanism_pt, mechanism_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- 7. Budesonida — enriquecimento da ficha existente (CSI inalado) com a
--    via nasal (mesma molécula; sem duplicar o slug). A interação CYP3A4
--    já está documentada (claritromicina) — não duplicar.
-- =====================================================================
UPDATE public.drug_profiles
SET indications_pt = indications_pt || E'\\n\\nVia nasal (rinite): profilaxia e tratamento da rinite alérgica e vasomotora; pólipos nasais (Prontuário 14.1.2; rótulo FDA RHINOCORT AQUA — rinite alérgica sazonal e perene em adultos e crianças ≥ 6 anos).',
    indications_en = indications_en || E'\\n\\nNasal route (rhinitis): prophylaxis and treatment of allergic and vasomotor rhinitis; nasal polyps (Prontuário 14.1.2; FDA label RHINOCORT AQUA — seasonal and perennial allergic rhinitis in adults and children ≥ 6 years).',
    updated_at = now()
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'budesonida');

UPDATE public.drug_pharmacology
SET absorption_pt = absorption_pt || E'\\n\\nVia nasal (RHINOCORT AQUA, 128 mcg): pico plasmático médio de ~0,3 nmol/L cerca de 0,5 h após a dose; ~34% da dose intranasal atinge a circulação sistémica, na sua maioria por absorção através da mucosa nasal (rótulo FDA).',
    absorption_en = absorption_en || E'\\n\\nNasal route (RHINOCORT AQUA, 128 mcg): mean peak plasma concentration of ~0.3 nmol/L about 0.5 h post-dose; approximately 34% of the delivered intranasal dose reaches the systemic circulation, mostly absorbed through the nasal mucosa (FDA label).',
    updated_at = now()
WHERE drug_id = (SELECT id FROM public.drugs WHERE slug = 'budesonida');
