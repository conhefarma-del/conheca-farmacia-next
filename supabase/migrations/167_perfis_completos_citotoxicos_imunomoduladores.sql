-- =====================================================================
-- 167 — Perfil completo + farmacologia + 3 dimensões dos 5 fármacos
--        do grupo 16 (Citotóxicos e Imunomoduladores) criados na 165
-- ---------------------------------------------------------------------
-- Completa a camada editorial dos fármacos novos da 165 (ciclofosfamida,
-- flutamida, medroxiprogesterona, megestrol, degarelix): drug_profiles,
-- drug_pharmacology, drug_food_interactions, drug_disease_interactions e
-- drug_pregnancy_info — o mesmo pacote das migrações 137/164. Com esta
-- migração, os 200 fármacos ativos ficam todos com perfil + farmacologia
-- + as 3 dimensões.
--
-- Fontes (citadas por linha): rótulos aprovados DailyMed/FDA (NIH/NLM),
-- setIDs obtidos e revalidados na API durante a 165 (a 2026-08-17):
--   - Ciclofosfamida (EVER Pharma)   571a5a63-fb66-0617-e063-6394a90a2d04
--   - Flutamida (EULEXIN)            0a905e25-42b6-4937-a689-f01a8f22e644
--   - Medroxiprogesterona (PROVERA)  a586be28-96af-4fed-a13f-9b94fd4c7405
--   - Megestrol (Natco)              582cff8a-1def-43d6-ba7e-dce49e3e9f27
--   - Degarelix (FIRMAGON)           ab11dd8a-0fd9-4013-89ab-e114557c7e4b
-- Números/factos ancorados no texto dos rótulos (ex.: meia-vida da
-- ciclofosfamida "3 to 12 hours"; "half-life of approximately 53 days" e
-- "protein binding... approximately 90%" do degarelix; "metabolized
-- in-vitro primarily by hydroxylation via the CYP3A4" da medroxiprogesterona).
-- As indicações oncológicas seguem o Prontuário Terapêutico (INFARMED,
-- 11.ª ed., 2012; secção 16) e os rótulos. Conteúdo autoral (nunca copiado),
-- conforme a metodologia de docs/INTERACOES_FLUXO_PESQUISA.md.
--
-- Idempotente: ON CONFLICT (drug_id) DO NOTHING — reaplicar é seguro.
-- Padrão 7.6 (JOIN ON d.slug = v.slug). Aplicar na ordem 165 → 167.
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
  ('ciclofosfamida',
   E'A ciclofosfamida é um fármaco citotóxico usado no tratamento de vários cancros (linfomas, leucemias, tumores sólidos) e como imunossupressor em doenças autoimunes. É um pró-fármaco: precisa de ser ativado no fígado. Como afeta as células em divisão, tem efeitos adversos importantes — sobretudo na medula óssea, na bexiga (cistite hemorrágica) e na fertilidade — pelo que é sempre usado sob supervisão médica especializada.',
   E'Cyclophosphamide is a cytotoxic drug used to treat several cancers (lymphomas, leukaemias, solid tumours) and as an immunosuppressant in autoimmune diseases. It is a prodrug: it must be activated in the liver. Because it affects dividing cells, it has important adverse effects — mainly on the bone marrow, the bladder (haemorrhagic cystitis) and fertility — so it is always used under specialist supervision.',
   E'Citotóxico alquilante (pró-fármaco ativado no fígado por hidroxilação via CYP450 — CYP2A6, 2B6, 3A, 2C9, 2C19) usado em doenças malignas (linfomas, mieloma, leucemias, tumores sólidos) e como imunossupressor. O metabolito acroleína pode causar cistite hemorrágica — prevenível com hidratação e mesna. Meia-vida de 3–12 h ("half-life (t½) of cyclophosphamide ranges from 3 to 12 hours"). Requer monitorização hematológica e hidratação vigorosa; a gametogénese pode ser gravemente afetada.',
   E'Alkylating cytotoxic agent (prodrug activated in the liver by CYP450 hydroxylation — CYP2A6, 2B6, 3A, 2C9, 2C19) used in malignant disease (lymphomas, myeloma, leukaemias, solid tumours) and as an immunosuppressant. The acrolein metabolite can cause haemorrhagic cystitis — preventable with hydration and mesna. Half-life of 3–12 h ("half-life (t½) of cyclophosphamide ranges from 3 to 12 hours"). Requires haematological monitoring and vigorous hydration; gametogenesis may be severely affected.',
   E'• Doenças malignas: linfomas (Hodgkin e não-Hodgkin, incluindo Burkitt), mieloma múltiplo, leucemias, neuroblastoma, cancro da mama e do ovário, retinoblastoma\\n• Imunossupressor em doenças autoimunes selecionadas (sob supervisão especializada)',
   E'• Malignant disease: lymphomas (Hodgkin and non-Hodgkin, including Burkitt), multiple myeloma, leukaemias, neuroblastoma, breast and ovarian cancer, retinoblastoma\\n• Immunosuppressant in selected autoimmune diseases (under specialist supervision)',
   E'• Depressão da medula óssea (leucopenia, trombocitopenia) — principal toxicidade limitante\\n• Cistite hemorrágica (metabolito acroleína) — hidratação e mesna reduzem o risco\\n• Náuseas e vómitos\\n• Alopécia\\n• Cardiotoxicidade (doses altas), hepatotoxicidade\\n• Infertilidade e efeitos na gametogénese; teratogenicidade',
   E'• Bone marrow depression (leucopenia, thrombocytopenia) — main dose-limiting toxicity\\n• Haemorrhagic cystitis (acrolein metabolite) — hydration and mesna reduce the risk\\n• Nausea and vomiting\\n• Alopecia\\n• Cardiotoxicity (high doses), hepatotoxicity\\n• Infertility and effects on gametogenesis; teratogenicity',
   E'• CONTRAINDICADO na gravidez (malformações, aborto, restrição de crescimento fetal) e na hipersensibilidade\\n• Reduzir a dose na insuficiência renal; evitar na porfiria\\n• Hidratação vigorosa antes e após a administração IV; considerar mesna\\n• Monitorizar hemograma, função renal e hepática\\n• Prevenção da gravidez durante e após o tratamento; evitar aleitamento\\n• Interações: inibidores da protease aumentam a toxicidade (ver pares)',
   E'• CONTRAINDICATED in pregnancy (birth defects, miscarriage, fetal growth restriction) and in hypersensitivity\\n• Reduce dose in renal impairment; avoid in porphyria\\n• Vigorous hydration before and after IV administration; consider mesna\\n• Monitor blood count, renal and hepatic function\\n• Prevent pregnancy during and after treatment; avoid breastfeeding\\n• Interactions: protease inhibitors increase toxicity (see pairs)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Ciclofosfamida, 16.1.1',
   'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Cyclophosphamide, 16.1.1'),

  ('flutamida',
   E'A flutamida é um antiandrogénio oral usado no cancro da próstata, geralmente em associação com análogos da GnRH (castração química). Bloqueia a ação da testosterona nas células tumorais. Tem toxicidade hepática potencialmente grave, pelo que a função do fígado deve ser vigiada antes e durante o tratamento.',
   E'Flutamide is an oral antiandrogen used in prostate cancer, usually in combination with GnRH analogues (chemical castration). It blocks the action of testosterone on tumour cells. It has potentially serious liver toxicity, so liver function must be monitored before and during treatment.',
   E'Antiandrogénio não esteroide (derivado da anilida) usado no cancro da próstata em combinação com análogos da GnRH ("indicated for use in combination with LHRH-agonists for the management of locally confined Stage B2-C and Stage D2 metastatic carcinoma of the prostate"). Atua por inibição competitiva da ligação da testosterona/di-hidrotestosterona ao recetor androgénico. Extensamente metabolizado (o composto original é apenas ~2% do circulante); metabolito alfa-hidroxilado com meia-vida de ~6–8 h. Toxicidade hepática acentuada — "boxed warning".',
   E'Non-steroidal antiandrogen (anilide derivative) used in prostate cancer in combination with GnRH analogues ("indicated for use in combination with LHRH-agonists for the management of locally confined Stage B2-C and Stage D2 metastatic carcinoma of the prostate"). Acts by competitive inhibition of testosterone/dihydrotestosterone binding to the androgen receptor. Extensively metabolised (parent compound is only ~2% of circulating drug); alpha-hydroxylated metabolite with a half-life of ~6–8 h. Marked hepatic toxicity — "boxed warning".',
   E'• Cancro da próstata localmente confinado (estádio B2-C) e metastático (estádio D2), em associação com análogos da GnRH',
   E'• Locally confined prostate cancer (Stage B2-C) and metastatic disease (Stage D2), in combination with GnRH analogues',
   E'• Ginecomastia e diminuição da líbido (os mais frequentes)\\n• Diarreia, náuseas e vómitos\\n• Toxicidade hepática (potencialmente grave — vigiar transaminases)\\n• Alteração reversível da função renal\\n• Fotossensibilidade (menos frequente)',
   E'• Gynaecomastia and decreased libido (most common)\\n• Diarrhoea, nausea and vomiting\\n• Hepatic toxicity (potentially serious — monitor transaminases)\\n• Reversible renal function changes\\n• Photosensitivity (less common)',
   E'• CONTRAINDICADO na insuficiência hepática grave e na hipersensibilidade\\n• Testes de função hepática antes e durante o tratamento (toxicidade hepática grave possível)\\n• Interação: aumenta o tempo de protrombina da varfarina — vigiar INR\\n• Não usar em mulheres (indicação exclusiva no cancro da próstata)',
   E'• CONTRAINDICATED in severe hepatic impairment and in hypersensitivity\\n• Liver function tests before and during treatment (serious hepatic toxicity possible)\\n• Interaction: increases warfarin prothrombin time — monitor INR\\n• Not for use in women (indication restricted to prostate cancer)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Flutamida, 16.2.2.2',
   'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Flutamide, 16.2.2.2'),

  ('medroxiprogesterona',
   E'A medroxiprogesterona é uma hormona progestagénio usada no tratamento paliativo de cancros hormono-dependentes (mama, endométrio) e noutras indicações ginecológicas. Como hormona, interfere com o ambiente hormonal que alimenta alguns tumores, ajudando a controlar a doença. Tem efeitos adversos moderados e exige exclusão de gravidez antes do início.',
   E'Medroxyprogesterone is a progestogen hormone used in the palliative treatment of hormone-dependent cancers (breast, endometrium) and in other gynaecological indications. As a hormone, it interferes with the hormonal environment that feeds some tumours, helping to control the disease. It has moderate adverse effects and requires exclusion of pregnancy before starting.',
   E'Progestagénio (derivado da 17-hidroxiprogesterona) usado no cancro da mama e do endométrio hormono-dependentes e metastáticos (prontuário 16.2.1.3) e, em doses menores, em ginecologia (amenorreia secundária, hemorragia uterina anómala). Exerce efeito antiestrogénico por supressão da secreção de gonadotrofinas e efeito direto nas células tumorais hormono-dependentes. Metabolizada no fígado por hidroxilação via CYP3A4 com conjugação e eliminação renal ("metabolized in the liver via hydroxylation, with subsequent conjugation and elimination in the urine").',
   E'Progestogen (17-hydroxyprogesterone derivative) used in hormone-dependent and metastatic breast and endometrial cancer (Prontuário 16.2.1.3) and, at lower doses, in gynaecology (secondary amenorrhoea, abnormal uterine bleeding). Exerts an antioestrogenic effect by suppressing gonadotrophin secretion and a direct effect on hormone-dependent tumour cells. Metabolised in the liver by hydroxylation via CYP3A4 with conjugation and renal elimination ("metabolized in the liver via hydroxylation, with subsequent conjugation and elimination in the urine").',
   E'• Cancro da mama hormono-dependente e metastático\\n• Carcinoma do endométrio\\n• (Indicações ginecológicas: amenorreia secundária, hemorragia uterina anómala)',
   E'• Hormone-dependent and metastatic breast cancer\\n• Endometrial carcinoma\\n• (Gynaecological indications: secondary amenorrhoea, abnormal uterine bleeding)',
   E'• Hemorragias vaginais (irregulares)\\n• Alterações respiratórias (dispneia — menos frequente)\\n• Cefaleias, alterações da fala, da marcha ou da visão\\n• Retenção de líquidos e aumento de peso\\n• Alterações do humor',
   E'• Vaginal bleeding (irregular)\\n• Respiratory changes (dyspnoea — less common)\\n• Headache, speech, gait or vision changes\\n• Fluid retention and weight gain\\n• Mood changes',
   E'• Contraindicado em hemorragia genital não diagnosticada, cancro da mama conhecido ou suspeito (na formulação para uso oncológico é usado precisamente no cancro da mama — avaliação individual), neoplasia dependente de estrogénio/progesterona, TVP/EP ativa ou prévia, e suspeita de gravidez\\n• Interações: rifampicina (redução do efeito — indução do CYP3A4); ciclosporina (aumento da concentração); aminoglutetimida (redução)\\n• A hormona passa para o leite materno',
   E'• Contraindicated in undiagnosed genital bleeding, known or suspected breast cancer (in the oncology formulation it is used precisely in breast cancer — individual assessment), oestrogen/progesterone-dependent neoplasia, active or previous DVT/PE, and suspected pregnancy\\n• Interactions: rifampicin (reduced effect — CYP3A4 induction); ciclosporin (increased concentration); aminoglutethimide (reduction)\\n• The hormone passes into breast milk',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Medroxiprogesterona, 16.2.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Medroxyprogesterone, 16.2.1.3'),

  ('megestrol',
   E'O megestrol é um progestagénio usado no cancro da mama e do endométrio hormono-dependentes e, noutra indicação, para estimular o apetite e o peso em doentes com caquexia (perda de peso grave). Como hormona, bloqueia o ambiente hormonal que alimenta certos tumores. Pode causar hemorragias vaginais e retenção de líquidos; está contraindicado na gravidez.',
   E'Megestrol is a progestogen used in hormone-dependent breast and endometrial cancer and, in another indication, to stimulate appetite and weight in patients with cachexia (severe weight loss). As a hormone, it blocks the hormonal environment that feeds certain tumours. It may cause vaginal bleeding and fluid retention; it is contraindicated in pregnancy.',
   E'Progestagénio (derivado da progesterona) usado no cancro da mama e do endométrio hormono-dependentes e metastáticos (prontuário 16.2.1.3) e na anorexia/caquexia associada a doença crónica. Exerce efeito antiestrogénico e inibidor da secreção de gonadotrofinas, e efeito orexígeno (mecanismo não totalmente esclarecido). Metabolizado no fígado (via CYP3A4); a associação com varfarina pode aumentar o INR (documentado no rótulo).',
   E'Progestogen (progesterone derivative) used in hormone-dependent and metastatic breast and endometrial cancer (Prontuário 16.2.1.3) and in anorexia/cachexia associated with chronic disease. Exerts an antioestrogenic effect and inhibits gonadotrophin secretion, with an orexigenic effect (mechanism not fully established). Metabolised in the liver (via CYP3A4); the combination with warfarin may increase INR (documented in the label).',
   E'• Cancro da mama hormono-dependente e metastático\\n• Carcinoma do endométrio\\n• Anorexia e caquexia (perda de peso significativa) em doença crónica grave',
   E'• Hormone-dependent and metastatic breast cancer\\n• Endometrial carcinoma\\n• Anorexia and cachexia (significant weight loss) in severe chronic disease',
   E'• Hemorragias vaginais\\n• Retenção de líquidos e edema\\n• Alterações respiratórias (menos frequente)\\n• Cefaleias\\n• Hiperglicemia (vigiar em diabéticos)\\n• Insuficiência suprarrenal com suspensão brusca (uso prolongado)',
   E'• Vaginal bleeding\\n• Fluid retention and oedema\\n• Respiratory changes (less common)\\n• Headache\\n• Hyperglycaemia (monitor in diabetics)\\n• Adrenal insufficiency on abrupt withdrawal (long-term use)',
   E'• CONTRAINDICADO na gravidez (pode causar dano fetal) e na hipersensibilidade\\n• Vigiar sinais de trombose e de insuficiência suprarrenal em uso prolongado\\n• Interações: varfarina (aumenta o INR — monitorizar); rifampicina (redução do efeito — indução do CYP3A4)\\n• Usar com precaução em diabéticos (hiperglicemia)',
   E'• CONTRAINDICATED in pregnancy (may cause fetal harm) and in hypersensitivity\\n• Monitor for signs of thrombosis and adrenal insufficiency with long-term use\\n• Interactions: warfarin (increases INR — monitor); rifampicin (reduced effect — CYP3A4 induction)\\n• Use with caution in diabetics (hyperglycaemia)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Megestrol, 16.2.1.3',
   'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Megestrol, 16.2.1.3'),

  ('degarelix',
   E'O degarelix é um antagonista da GnRH usado no cancro da próstata avançado. Bloqueia diretamente o recetor da hormona libertadora de gonadotrofinas, reduzindo rapidamente a testosterona sem o pico inicial (flare) que os agonistas da GnRH causam. É administrado por injeção subcutânea, geralmente uma vez por mês, sob supervisão especializada.',
   E'Degarelix is a GnRH antagonist used in advanced prostate cancer. It directly blocks the gonadotrophin-releasing hormone receptor, rapidly reducing testosterone without the initial flare seen with GnRH agonists. It is given by subcutaneous injection, usually once a month, under specialist supervision.',
   E'Antagonista do recetor da GnRH indicado no cancro da próstata avançado ("indicated for treatment of patients with advanced prostate cancer"). Ao contrário dos agonistas, não causa o pico transitório de testosterona (flare) — permite a supressão androgénica rápida sem necessidade de antiandrogénio de cobertura. Forma um depósito no local de injeção com libertação lenta ("forms a depot upon subcutaneous administration") e meia-vida efetiva de ~53 dias. Não é substrato, indutor nem inibidor do CYP450 (interações farmacocinéticas clinicamente significativas improváveis — rótulo); a precaução QTc é documentada no prontuário.',
   E'GnRH receptor antagonist indicated for advanced prostate cancer ("indicated for treatment of patients with advanced prostate cancer"). Unlike agonists, it does not cause the transient testosterone flare — allowing rapid androgen suppression without the need for antiandrogen cover. It forms a depot at the injection site with slow release ("forms a depot upon subcutaneous administration") and an effective half-life of ~53 days. It is not a CYP450 substrate, inducer or inhibitor (clinically significant pharmacokinetic interactions unlikely — label); the QTc precaution is documented in the Prontuário.',
   E'• Cancro da próstata avançado hormono-dependente (terapêutica de supressão androgénica)',
   E'• Advanced hormone-dependent prostate cancer (androgen suppression therapy)',
   E'• Afrontamentos e sudação (esperados — efeito da supressão androgénica)\\n• Dor, eritema e reação no local de injeção\\n• Aumento de peso, fadiga\\n• Prolongamento do intervalo QT (vigiar com fármacos que prolongam o QT)\\n• Perda de densidade óssea (uso prolongado)\\n• Elevação das transaminases (transitória, frequente)',
   E'• Hot flushes and sweating (expected — effect of androgen suppression)\\n• Pain, erythema and injection-site reaction\\n• Weight gain, fatigue\\n• QT interval prolongation (monitor with QT-prolonging drugs)\\n• Bone mineral density loss (long-term use)\\n• Transaminase elevation (transient, common)',
   E'• CONTRAINDICADO na hipersensibilidade grave ao degarelix ou componentes\\n• Precaução em insuficiência hepática e renal (doentes não estudados)\\n• Avaliar o risco de prolongamento do QT em associação com fármacos que prolongam o QTc (anti-arrítmicos classe Ia/III, moxifloxacina, metadona)\\n• Risco de diminuição da densidade óssea e de alteração da tolerância à glucose (uso prolongado)\\n• Não recomendado na gravidez (indicação exclusiva masculina)',
   E'• CONTRAINDICATED in severe hypersensitivity to degarelix or components\\n• Caution in hepatic and renal impairment (patients not studied)\\n• Assess QT prolongation risk in combination with QT-prolonging drugs (class Ia/III antiarrhythmics, moxifloxacin, methadone)\\n• Risk of decreased bone mineral density and impaired glucose tolerance (long-term use)\\n• Not recommended in pregnancy (indication exclusively male)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Degarelix, 16.2.2.5',
   'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Degarelix, 16.2.2.5')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
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
  ('ciclofosfamida',
   E'Citotóxico alquilante que interfere com a replicação do ADN nas células em divisão; também usado como imunossupressor (linfolítico) em doenças autoimunes e na prevenção de rejeição de transplantes.',
   E'Alkylating cytotoxic agent that interferes with DNA replication in dividing cells; also used as an immunosuppressant (lympholytic) in autoimmune diseases and transplant rejection prevention.',
   E'Pró-fármaco ativado no fígado por hidroxilação (CYP2A6, 2B6, 3A, 2C9, 2C19) em metabolitos ativos (fosforamida mostarda) que alquilam o ADN, formando ligações cruzadas e impedindo a replicação celular. O metabolito acroleína é responsável pela cistite hemorrágica.',
   E'Prodrug activated in the liver by hydroxylation (CYP2A6, 2B6, 3A, 2C9, 2C19) to active metabolites (phosphoramide mustard) that alkylate DNA, forming cross-links and preventing cell replication. The acrolein metabolite causes haemorrhagic cystitis.',
   E'Ativada no fígado pelas isoenzimas CYP450 (CYP2A6, 2B6, 3A, 2C9, 2C19); os metabolitos e o fármaco inalterado são eliminados na urina — a depuração renal é uma via importante.',
   E'Activated in the liver by CYP450 isoenzymes (CYP2A6, 2B6, 3A, 2C9, 2C19); metabolites and unchanged drug are eliminated in urine — renal clearance is an important route.',
   E'Administração por via oral ou IV; a ativação hepática é obrigatória para a atividade, pelo que a biodisponibilidade oral depende da função hepática.',
   E'Administration by oral or IV route; hepatic activation is required for activity, so oral bioavailability depends on liver function.',
   E'Meia-vida de 3 a 12 horas ("half-life (t½) of cyclophosphamide ranges from 3 to 12 hours"); clearance de 4–5 L/h. A excreção é renal (fármaco inalterado e metabolitos).',
   E'Half-life of 3 to 12 hours ("half-life (t½) of cyclophosphamide ranges from 3 to 12 hours"); clearance of 4–5 L/h. Excretion is renal (unchanged drug and metabolites).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04',
   'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04'),

  ('flutamida',
   E'Antiandrogénio que bloqueia a ligação da testosterona e da di-hidrotestosterona ao recetor androgénico nas células prostáticas, complementando a castração química induzida pelos análogos da GnRH.',
   E'Antiandrogen that blocks testosterone and dihydrotestosterone binding to the androgen receptor in prostate cells, complementing the chemical castration induced by GnRH analogues.',
   E'Inibição competitiva da ligação dos androgénios ao recetor androgénico, impedindo a estimulação do crescimento tumoral hormono-dependente; não suprime a produção de testosterona (por isso associa-se aos análogos da GnRH).',
   E'Competitive inhibition of androgen binding to the androgen receptor, preventing stimulation of hormone-dependent tumour growth; it does not suppress testosterone production (hence combination with GnRH analogues).',
   E'Extensamente metabolizado no fígado — o composto original representa apenas ~2% do circulante; o metabolito ativo é o 2-hidroxiflutamida, com conjugação e eliminação renal.',
   E'Extensively metabolised in the liver — the parent compound represents only ~2% of circulating drug; the active metabolite is 2-hydroxyflutamide, with conjugation and renal elimination.',
   E'Boa absorção oral após administração; a cinética não difere por raça ("absorption, distribution, metabolism, or excretion due to race" não foram observadas diferenças clínicas).',
   E'Good oral absorption after administration; kinetics do not differ by race (no clinically observed differences in "absorption, distribution, metabolism, or excretion due to race").',
   E'Meia-vida do metabolito alfa-hidroxilado de aproximadamente 6 horas ("half-life for the alpha-hydroxylated metabolite... is approximately 6 hours"); o metabolito ativo (2-hidroxiflutamida) tem meia-vida de cerca de 8 horas.',
   E'Half-life of the alpha-hydroxylated metabolite of approximately 6 hours ("half-life for the alpha-hydroxylated metabolite... is approximately 6 hours"); the active metabolite (2-hydroxyflutamide) has a half-life of about 8 hours.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644',
   'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644'),

  ('medroxiprogesterona',
   E'Progestagénio com efeito antiestrogénico (supressão da secreção de gonadotrofinas e inibição do crescimento de tecidos e tumores hormono-dependentes).',
   E'Progestogen with an antioestrogenic effect (suppression of gonadotrophin secretion and inhibition of growth of hormone-dependent tissues and tumours).',
   E'Exerce efeito antiestrogénico por supressão da secreção hipofisária de gonadotrofinas (diminuição do estradiol) e efeito direto citostático nas células tumorais hormono-dependentes; em doses baixas, efeitos endometriais e contraceptivos.',
   E'Exerts an antioestrogenic effect by suppressing pituitary gonadotrophin secretion (decreased oestradiol) and a direct cytostatic effect on hormone-dependent tumour cells; at low doses, endometrial and contraceptive effects.',
   E'Metabolizada no fígado por hidroxilação, com conjugação e eliminação urinária ("metabolized in the liver via hydroxylation, with subsequent conjugation and elimination in the urine"); a via principal é o CYP3A4.',
   E'Metabolised in the liver by hydroxylation, with conjugation and urinary elimination ("metabolized in the liver via hydroxylation, with subsequent conjugation and elimination in the urine"); the main pathway is CYP3A4.',
   E'A biodisponibilidade oral absoluta não foi formalmente investigada ("No specific investigation on the absolute bioavailability of MPA in humans has been conducted"); a absorção é adequada por via oral.',
   E'Absolute oral bioavailability has not been formally investigated ("No specific investigation on the absolute bioavailability of MPA in humans has been conducted"); oral absorption is adequate.',
   E'Metabolito ativo com meia-vida de algumas horas; a eliminação é sobretudo renal após metabolização hepática (conjugados).',
   E'Active metabolite with a half-life of a few hours; elimination is mainly renal after hepatic metabolism (conjugates).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405',
   'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405'),

  ('megestrol',
   E'Progestagénio com efeito antiestrogénico no cancro hormono-dependente e efeito orexígeno (aumento do apetite e do peso) na caquexia; mecanismo orexígeno não totalmente esclarecido.',
   E'Progestogen with an antioestrogenic effect in hormone-dependent cancer and an orexigenic effect (increased appetite and weight) in cachexia; the orexigenic mechanism is not fully established.',
   E'Inibição da secreção de gonadotrofinas e efeito direto nas células tumorais hormono-dependentes (semelhante à medroxiprogesterona); o efeito no apetite parece envolver modulação de citocinas e do neuropéptido Y, sem mecanismo totalmente esclarecido.',
   E'Inhibition of gonadotrophin secretion and direct effect on hormone-dependent tumour cells (similar to medroxyprogesterone); the appetite effect appears to involve modulation of cytokines and neuropeptide Y, without a fully established mechanism.',
   E'Metabolizado no fígado, sobretudo via CYP3A4, com formação de metabolitos e eliminação renal e fecal.',
   E'Metabolised in the liver, mainly via CYP3A4, with formation of metabolites and renal and faecal elimination.',
   E'Boa absorção oral; a exposição é suficiente para efeito clínico nas indicações oncológicas e na caquexia.',
   E'Good oral absorption; exposure is sufficient for clinical effect in the oncology and cachexia indications.',
   E'Meia-vida de eliminação de cerca de 13–34 horas (dose-dependente), permitindo administração diária única.',
   E'Elimination half-life of about 13–34 hours (dose-dependent), allowing once-daily administration.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27',
   'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27'),

  ('degarelix',
   E'Antagonista do recetor da GnRH que suprime rapidamente a testosterona para níveis de castração sem o pico inicial (flare) observado com os agonistas.',
   E'GnRH receptor antagonist that rapidly suppresses testosterone to castration levels without the initial flare seen with agonists.',
   E'Bloqueio competitivo e reversível do recetor da GnRH na hipófise anterior, com supressão imediata da libertação de LH e FSH e consequente queda da testosterona; não é substrato, indutor nem inibidor do CYP450.',
   E'Competitive and reversible blockade of the GnRH receptor in the anterior pituitary, with immediate suppression of LH and FSH release and consequent fall in testosterone; it is not a CYP450 substrate, inducer or inhibitor.',
   E'Não é metabolizado pelo CYP450 de forma clinicamente relevante (interações farmacocinéticas clinicamente significativas improváveis — rótulo); é um decapéptido sintético degradado por peptidases.',
   E'Not metabolised by CYP450 in a clinically relevant manner (clinically significant pharmacokinetic interactions unlikely — label); it is a synthetic decapeptide degraded by peptidases.',
   E'Forma um depósito no local de injeção subcutânea, com libertação lenta e contínua para a circulação ("FIRMAGON forms a depot upon subcutaneous administration, from which degarelix is released to the circulation").',
   E'Forms a depot at the subcutaneous injection site, with slow continuous release into the circulation ("FIRMAGON forms a depot upon subcutaneous administration, from which degarelix is released to the circulation").',
   E'Meia-vida de aproximadamente 53 dias ("half-life of approximately 53 days"), consequência da libertação lenta do depósito subcutâneo; ligação proteica de ~90% ("protein binding of degarelix is estimated to be approximately 90%").',
   E'Half-life of approximately 53 days ("half-life of approximately 53 days"), a consequence of the slow release from the subcutaneous depot; protein binding of ~90% ("protein binding of degarelix is estimated to be approximately 90%").',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b',
   'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
        metabolism_pt, metabolism_en, absorption_pt, absorption_en,
        half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- Alimento / Bebida (drug_food_interactions)
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
  ('ciclofosfamida', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   E'O álcool aumenta o risco de hepatotoxicidade e pode agravar os efeitos gastrointestinais (náuseas, vómitos) durante o tratamento com ciclofosfamida.',
   E'Alcohol increases the risk of hepatotoxicity and may worsen gastrointestinal effects (nausea, vomiting) during cyclophosphamide treatment.',
   E'Evitar ou limitar fortemente o consumo de álcool durante o tratamento.',
   E'Avoid or strongly limit alcohol intake during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 1),
  ('flutamida', 'alcool', 'Álcool', 'Alcohol', 'minor',
   E'O álcool pode agravar a toxicidade hepática associada à flutamida.',
   E'Alcohol may worsen the hepatic toxicity associated with flutamide.',
   E'Limitar o consumo de álcool, sobretudo em doentes com função hepática limítrofe.',
   E'Limit alcohol intake, especially in patients with borderline liver function.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644', 'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644', 1),
  ('medroxiprogesterona', 'refeicoes_gordurosas', 'Refeições ricas em gordura', 'High-fat meals', 'minor',
   E'A toma com alimentos ricos em gordura não alterou de forma clinicamente relevante a meia-vida da medroxiprogesterona ("half-life of MPA was not changed with food") — pode tomar com ou sem alimentos.',
   E'Taking with high-fat food did not change medroxyprogesterone half-life in a clinically relevant way ("half-life of MPA was not changed with food") — it may be taken with or without food.',
   E'Tomar com ou sem alimentos, conforme a tolerância gástrica.',
   E'Take with or without food, according to gastric tolerance.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405', 'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405', 1),
  ('megestrol', 'refeicoes_gordurosas', 'Refeições ricas em gordura', 'High-fat meals', 'minor',
   E'As refeições ricas em gordura podem aumentar a absorção oral do megestrol (lipossolubilidade) — efeito não quantificado clinicamente.',
   E'High-fat meals may increase oral absorption of megestrol (liposolubility) — effect not clinically quantified.',
   E'Tomar com as refeições, sobretudo na caquexia em que o objetivo é a ingestão calórica.',
   E'Take with meals, especially in cachexia where the goal is caloric intake.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 1),
  ('megestrol', 'alcool', 'Álcool', 'Alcohol', 'minor',
   E'O álcool pode agravar os efeitos gastrointestinais e a sonolência associados ao megestrol.',
   E'Alcohol may worsen the gastrointestinal effects and drowsiness associated with megestrol.',
   E'Limitar o consumo de álcool durante o tratamento.',
   E'Limit alcohol intake during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
        mechanism_pt, mechanism_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- Doença / Condição (drug_disease_interactions)
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
  ('ciclofosfamida', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'Teratogénico e fetotóxico — "may cause birth defects, miscarriage, fetal growth retardation, and fetotoxic effects in the newborn" (rótulo); a gametogénese pode ser gravemente afetada.',
   E'Teratogenic and fetotoxic — "may cause birth defects, miscarriage, fetal growth retardation, and fetotoxic effects in the newborn" (label); gametogenesis may be severely affected.',
   E'Contraindicado na gravidez; exigir teste de gravidez e contraceção eficaz em mulheres em idade fértil antes, durante e após o tratamento.',
   E'Contraindicated in pregnancy; require a pregnancy test and effective contraception in women of childbearing potential before, during and after treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 1),
  ('ciclofosfamida', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'A eliminação renal da ciclofosfamida e dos seus metabolitos é importante — na insuficiência renal há risco de acumulação e toxicidade aumentada.',
   E'Renal elimination of cyclophosphamide and its metabolites is important — in renal impairment there is a risk of accumulation and increased toxicity.',
   E'Reduzir a dose na insuficiência renal e monitorizar a função renal e o hemograma.',
   E'Reduce the dose in renal impairment and monitor renal function and blood count.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04', 1),
  ('ciclofosfamida', 'porfiria', 'Porfiria', 'Porphyria', 'contraindication', 'moderate',
   E'O prontuário indica evitar a ciclofosfamida na porfiria (fármaco porfirinogénico).',
   E'The Prontuário indicates avoiding cyclophosphamide in porphyria (porphyrinogenic drug).',
   E'Evitar na porfiria; usar alternativa terapêutica.',
   E'Avoid in porphyria; use a therapeutic alternative.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Ciclofosfamida, 16.1.1', 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Cyclophosphamide, 16.1.1', 1),
  ('flutamida', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'contraindication', 'critical',
   E'Toxicidade hepática grave (boxed warning) — contraindicado na insuficiência hepática grave; risco de lesão hepática em doentes com doença hepática prévia.',
   E'Serious hepatic toxicity (boxed warning) — contraindicated in severe hepatic impairment; risk of liver injury in patients with pre-existing hepatic disease.',
   E'Testes de função hepática antes do início e durante o tratamento; suspender se elevação significativa das transaminases.',
   E'Liver function tests before starting and during treatment; discontinue if significant transaminase elevation.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644', 'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644', 1),
  ('medroxiprogesterona', 'trombose_ativa', 'Trombose ativa', 'Active thrombosis', 'contraindication', 'moderate',
   E'Contraindicado em TVP/EP ativa ou história destas condições e em doença tromboembólica arterial ativa (rótulo PROVERA).',
   E'Contraindicated in active DVT/PE or a history of these conditions and in active arterial thromboembolic disease (PROVERA label).',
   E'Evitar em doentes com trombose ativa ou história de tromboembolismo; avaliar o risco individual.',
   E'Avoid in patients with active thrombosis or a history of thromboembolism; assess individual risk.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405', 'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405', 1),
  ('medroxiprogesterona', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'moderate',
   E'Suspeita de gravidez é contraindicação (prontuário); a hormona pode afetar o desenvolvimento fetal.',
   E'Suspected pregnancy is a contraindication (Prontuário); the hormone may affect fetal development.',
   E'Excluir gravidez antes de iniciar e usar contraceção eficaz durante o tratamento.',
   E'Exclude pregnancy before starting and use effective contraception during treatment.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Medroxiprogesterona, 16.2.1.3', 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Medroxyprogesterone, 16.2.1.3', 1),
  ('megestrol', 'gravidez', 'Gravidez', 'Pregnancy', 'contraindication', 'critical',
   E'Pode causar dano fetal ("Megestrol acetate may cause fetal harm when administered to a pregnant woman" — rótulo); contraindicação formal.',
   E'May cause fetal harm ("Megestrol acetate may cause fetal harm when administered to a pregnant woman" — label); formal contraindication.',
   E'Contraindicado na gravidez; excluir gravidez antes de iniciar.',
   E'Contraindicated in pregnancy; exclude pregnancy before starting.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 1),
  ('megestrol', 'diabetes_mellitus', 'Diabetes mellitus', 'Diabetes mellitus', 'precaution', 'moderate',
   E'O megestrol pode causar hiperglicemia e agravamento do controlo glicémico (rótulo) — vigiar em diabéticos.',
   E'Megestrol may cause hyperglycaemia and worsening of glycaemic control (label) — monitor in diabetics.',
   E'Vigiar a glicemia em doentes diabéticos e ajustar a medicação antidiabética conforme necessário.',
   E'Monitor blood glucose in diabetic patients and adjust antidiabetic medication as needed.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27', 1),
  ('degarelix', 'prolongamento_qt', 'Prolongamento do intervalo QT', 'QT interval prolongation', 'precaution', 'moderate',
   E'O prontuário documenta que o degarelix pode a longo prazo causar prolongamento do intervalo QT; a associação com fármacos que prolongam o QTc deve ser cuidadosamente avaliada.',
   E'The Prontuário documents that degarelix may cause QT interval prolongation in the long term; combination with QT-prolonging drugs should be carefully evaluated.',
   E'Avaliar o risco individual (QT basal, eletrólitos); vigiar ECG em doentes de risco e com fármacos que prolongam o QT.',
   E'Assess individual risk (baseline QT, electrolytes); monitor ECG in at-risk patients and with QT-prolonging drugs.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Degarelix, 16.2.2.5', 'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Degarelix, 16.2.2.5', 1),
  ('degarelix', 'doenca_hepatica', 'Doença hepática', 'Hepatic disease', 'precaution', 'moderate',
   E'Doentes com disfunção hepática grave não foram estudados — precaução no uso (rótulo: "Patients with severe liver or kidney dysfunction have not been studied and caution is therefore warranted").',
   E'Patients with severe liver dysfunction have not been studied — caution with use (label: "Patients with severe liver or kidney dysfunction have not been studied and caution is therefore warranted").',
   E'Usar com precaução na doença hepática grave e monitorizar transaminases.',
   E'Use with caution in severe hepatic disease and monitor transaminases.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b', 'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b', 1),
  ('degarelix', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'precaution', 'moderate',
   E'Doentes com disfunção renal grave não foram estudados — precaução no uso (rótulo).',
   E'Patients with severe renal dysfunction have not been studied — caution with use (label).',
   E'Usar com precaução na insuficiência renal grave.',
   E'Use with caution in severe renal impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b', 'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
        reason_pt, reason_en, advice_pt, advice_en,
        source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- Gestação / Lactação (drug_pregnancy_info, 1:1 por fármaco)
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
  ('ciclofosfamida', 'contraindicated',
   E'Teratogénico e fetotóxico — "may cause birth defects, miscarriage, fetal growth retardation, and fetotoxic effects in the newborn" (rótulo).',
   E'Teratogenic and fetotoxic — "may cause birth defects, miscarriage, fetal growth retardation, and fetotoxic effects in the newborn" (label).',
   E'Contraindicado em qualquer trimestre; nunca usar durante a gravidez.',
   E'Contraindicated in any trimester; never use during pregnancy.',
   E'Excretado no leite materno — não amamentar durante o tratamento.',
   E'Excreted in breast milk — do not breastfeed during treatment.',
   E'Contraceção eficaz obrigatória em mulheres em idade fértil antes, durante e após o tratamento (teste de gravidez prévio).',
   E'Effective contraception mandatory in women of childbearing potential before, during and after treatment (prior pregnancy test).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ciclofosfamida (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04',
   'DailyMed/FDA (NIH/NLM) — approved Cyclophosphamide label (EVER Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=571a5a63-fb66-0617-e063-6394a90a2d04'),

  ('flutamida', 'contraindicated',
   E'Indicação exclusiva no cancro da próstata (população masculina); não usar em mulheres grávidas (rótulo: "Use in Women" — contraindicação).',
   E'Indication restricted to prostate cancer (male population); do not use in pregnant women (label: "Use in Women" — contraindication).',
   E'Não aplicável na gravidez (indicação exclusivamente masculina).',
   E'Not applicable in pregnancy (indication exclusively male).',
   E'Não aplicável (indicação masculina).',
   E'Not applicable (male indication).',
   E'Não aplicável.',
   E'Not applicable.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Flutamida (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644',
   'DailyMed/FDA (NIH/NLM) — approved Flutamide label (EULEXIN): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a905e25-42b6-4937-a689-f01a8f22e644'),

  ('medroxiprogesterona', 'caution',
   E'Suspeita de gravidez é contraindicação; a hormona pode afetar o desenvolvimento fetal — usar apenas se o benefício justificar.',
   E'Suspected pregnancy is a contraindication; the hormone may affect fetal development — use only if the benefit justifies it.',
   E'Evitar no 1.º trimestre; usar apenas se clinicamente necessário sob orientação médica.',
   E'Avoid in the first trimester; use only if clinically necessary under medical guidance.',
   E'A hormona passa para o leite materno ("The hormone in PROVERA can pass into your breast milk") — precaução durante a amamentação.',
   E'The hormone passes into breast milk ("The hormone in PROVERA can pass into your breast milk") — caution during breastfeeding.',
   E'Excluir gravidez antes de iniciar e usar contraceção eficaz durante o tratamento.',
   E'Exclude pregnancy before starting and use effective contraception during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Medroxiprogesterona (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405',
   'DailyMed/FDA (NIH/NLM) — approved Medroxyprogesterone label (PROVERA): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a586be28-96af-4fed-a13f-9b94fd4c7405'),

  ('megestrol', 'contraindicated',
   E'Pode causar dano fetal ("Megestrol acetate may cause fetal harm when administered to a pregnant woman" — rótulo).',
   E'May cause fetal harm ("Megestrol acetate may cause fetal harm when administered to a pregnant woman" — label).',
   E'Contraindicado em qualquer trimestre.',
   E'Contraindicated in any trimester.',
   E'Dados insuficientes na lactação — evitar a amamentação durante o tratamento.',
   E'Insufficient data during lactation — avoid breastfeeding during treatment.',
   E'Excluir gravidez antes de iniciar e usar contraceção eficaz durante o tratamento.',
   E'Exclude pregnancy before starting and use effective contraception during treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Megestrol (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27',
   'DailyMed/FDA (NIH/NLM) — approved Megestrol label (Natco): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=582cff8a-1def-43d6-ba7e-dce49e3e9f27'),

  ('degarelix', 'no_data',
   E'Segurança e eficácia em mulheres não estabelecidas (indicação exclusivamente masculina — cancro da próstata); dados animais mostram risco fetal.',
   E'Safety and efficacy in women not established (indication exclusively male — prostate cancer); animal data show fetal risk.',
   E'Não aplicável na gravidez (indicação exclusivamente masculina).',
   E'Not applicable in pregnancy (indication exclusively male).',
   E'Indicação masculina; sem relevância na lactação.',
   E'Male indication; not relevant during lactation.',
   E'Não aplicável.',
   E'Not applicable.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Degarelix (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b',
   'DailyMed/FDA (NIH/NLM) — approved Degarelix label (FIRMAGON): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
        lactation_pt, lactation_en, contraception_pt, contraception_en,
        source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
