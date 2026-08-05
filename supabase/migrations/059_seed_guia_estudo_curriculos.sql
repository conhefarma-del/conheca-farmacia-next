-- 059: Study guides — curriculo essencial comparado (ISIA + UPRA + PIAGET)
-- Substitui/completa o conteúdo editorial de /guias com as disciplinas essenciais
-- selecionadas por frequência de aparecimento nas grades curriculares reais.
--
-- Metodologia (ver guia-de-estudo/COMPARACAO_CURRICULOS.md):
--  - As disciplinas foram comparadas entre universidades (ISIA, UPRA, PIAGET, UNIBELAS).
--  - Selecionadas as essenciais por frequência ≥ 75% (moda de ano quando divergente).
--  - Duração padrão: Enfermagem 4 anos, Ciências Farmacêuticas 5 anos,
--    Análises Clínicas 4 anos, Medicina 6 anos.
--
-- Reexecutável: usa DELETE + INSERT para as tabelas de conteúdo, mantendo RLS

-- ============================================================
-- 1) CURSOS — atualiza metadados e adiciona campos de duração
-- ============================================================
UPDATE public.guide_courses SET
  name_pt = 'Ciências Farmacêuticas',
  name_en = 'Pharmaceutical Sciences',
  description_pt = 'Formação centrada na descoberta, desenvolvimento, produção e uso racional de medicamentos. Curso de 5 anos.',
  description_en = 'Training focused on the discovery, development, production and rational use of medicines. A 5-year programme.',
  hero_subtitle_pt = 'Do laboratório ao balcão — a ciência que protege a saúde.',
  hero_subtitle_en = 'From the lab to the counter — the science that protects health.',
  icon_emoji = 'Pill',
  color = '#0a844f',
  status = 'published',
  sort_order = 1
WHERE slug = 'farmacia';

UPDATE public.guide_courses SET
  name_pt = 'Medicina',
  name_en = 'Medicine',
  description_pt = 'Formação médica generalista de 6 anos, com base nas ciências fundamentais, clínicas e no internato.',
  description_en = 'A 6-year generalist medical training grounded in the fundamental, clinical sciences and internship.',
  hero_subtitle_pt = 'A arte de curar, sustentada pela ciência.',
  hero_subtitle_en = 'The art of healing, grounded in science.',
  icon_emoji = 'Stethoscope',
  color = '#0a844f',
  status = 'published',
  sort_order = 2
WHERE slug = 'medicina';

UPDATE public.guide_courses SET
  name_pt = 'Enfermagem',
  name_en = 'Nursing',
  description_pt = 'Formação em cuidados de enfermagem, gestão e educação para a saúde. Curso de 4 anos.',
  description_en = 'Training in nursing care, management and health education. A 4-year programme.',
  hero_subtitle_pt = 'Cuidar é a nossa ciência.',
  hero_subtitle_en = 'Caring is our science.',
  icon_emoji = 'HeartHandshake',
  color = '#0a844f',
  status = 'published',
  sort_order = 3
WHERE slug = 'enfermagem';

UPDATE public.guide_courses SET
  name_pt = 'Análises Clínicas e Saúde Pública',
  name_en = 'Clinical Laboratory Science and Public Health',
  description_pt = 'Formação em diagnóstico laboratorial, controlo de qualidade e saúde pública. Curso de 4 anos.',
  description_en = 'Training in laboratory diagnostics, quality control and public health. A 4-year programme.',
  hero_subtitle_pt = 'A verdade escondida em cada amostra.',
  hero_subtitle_en = 'The truth hidden in every sample.',
  icon_emoji = 'Microscope',
  color = '#0a844f',
  status = 'published',
  sort_order = 4
WHERE slug = 'analises-clinicas';

-- ============================================================
-- 2) UNIVERSIDADES — completo/atualiza a partir de Universidades.txt
--    (ISIA, UPRA, UNIBELAS, UNIPIAGET — apenas as que lecionam cada curso)
-- ============================================================
DO $$
DECLARE
  v_farmacia UUID;
  v_medicina UUID;
  v_enfermagem UUID;
  v_analises UUID;
BEGIN
  SELECT id INTO v_farmacia FROM public.guide_courses WHERE slug = 'farmacia';
  SELECT id INTO v_medicina FROM public.guide_courses WHERE slug = 'medicina';
  SELECT id INTO v_enfermagem FROM public.guide_courses WHERE slug = 'enfermagem';
  SELECT id INTO v_analises FROM public.guide_courses WHERE slug = 'analises-clinicas';

  -- Limpa as universidades antigas (seed anterior tinha UAN/UJES/UCAN não confirmadas)
  DELETE FROM public.guide_universities
  WHERE course_id IN (v_farmacia, v_medicina, v_enfermagem, v_analises);

  -- FARMÁCIA (Ciências Farmacêuticas): ISIA, UNIBELAS, UNIPIAGET
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_farmacia, 'ISIA - Instituto Superior Politécnico Internacional de Angola', 'Luanda', false,
     'https://isia.co.ao', 'https://isia.co.ao/cursos', 'published', 1),
    (v_farmacia, 'UNIBELAS - Farmácia', 'Luanda', false,
     'https://unibelas.online', 'https://unibelas.online/courses/farmacia/', 'published', 2),
    (v_farmacia, 'UNIPIAGET - Universidade Jean Piaget de Angola', 'Viana, Luanda', false,
     'https://www.unipiaget-angola.org', 'https://www.unipiaget-angola.org/curso?cienciasfarmaceuticas', 'published', 3);

  -- MEDICINA: UPRA, UNIPIAGET
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_medicina, 'UPRA - Universidade Privada de Angola', 'Luanda Sul', false,
     'https://www.upra.ao', 'https://www.upra.ao/licenciaturas', 'published', 1),
    (v_medicina, 'UNIPIAGET - Universidade Jean Piaget de Angola', 'Viana, Luanda', false,
     'https://www.unipiaget-angola.org', 'https://www.unipiaget-angola.org/curso?medicina', 'published', 2);

  -- ENFERMAGEM: ISIA, UPRA, UNIBELAS, UNIPIAGET
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'ISIA - Instituto Superior Politécnico Internacional de Angola', 'Luanda', false,
     'https://isia.co.ao', 'https://isia.co.ao/cursos', 'published', 1),
    (v_enfermagem, 'UPRA - Universidade Privada de Angola', 'Luanda Sul', false,
     'https://www.upra.ao', 'https://www.upra.ao/licenciaturas', 'published', 2),
    (v_enfermagem, 'UNIBELAS - Enfermagem', 'Luanda', false,
     'https://unibelas.online', 'https://unibelas.online/courses/enfermagem/', 'published', 3),
    (v_enfermagem, 'UNIPIAGET - Universidade Jean Piaget de Angola', 'Viana, Luanda', false,
     'https://www.unipiaget-angola.org', 'https://www.unipiaget-angola.org/curso?enfermagem', 'published', 4);

  -- ANÁLISES CLÍNICAS: ISIA, UNIBELAS
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_analises, 'ISIA - Instituto Superior Politécnico Internacional de Angola', 'Luanda', false,
     'https://isia.co.ao', 'https://isia.co.ao/cursos', 'published', 1),
    (v_analises, 'UNIBELAS - Análises Clínicas e Saúde Pública', 'Luanda', false,
     'https://unibelas.online', 'https://unibelas.online/courses/analises-clinica/', 'published', 2);
END $$;

-- ============================================================
-- 3) DISCIPLINAS — popula por curso (essenciais por ano de consenso)
--    Subdivide em vários DO $$ para manter cada bloco legível e ID de curso resolvido.
-- ============================================================

-- ---------- FARMÁCIA (5 anos) ----------
DO $$
DECLARE
  c UUID;
BEGIN
  SELECT id INTO c FROM public.guide_courses WHERE slug = 'farmacia';
  DELETE FROM public.guide_disciplines WHERE course_id = c;

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order) VALUES
    ('farm-anatomia', c, 'Anatomia Humana I e II', 'Human Anatomy I and II',
     'Estrutura macroscópica do corpo humano, com foco nos sistemas relevantes para a prática farmacêutica.',
     'Macroscopic structure of the human body, focusing on systems relevant to pharmacy practice.',
     '1º Ano', '1st Year',
     'Base para compreender a fisiologia, a farmacologia e a localização da ação dos fármacos.',
     'Foundation for understanding physiology, pharmacology and where drugs act.', 'published', 1),

    ('farm-biologia', c, 'Biologia Celular, Molecular e Genética', 'Cell, Molecular Biology and Genetics',
     'Mecanismos moleculares e genéticos da célula, pré-requisito para a bioquímica e a farmacogenética.',
     'Molecular and genetic mechanisms of the cell, a prerequisite for biochemistry and pharmacogenetics.',
     '1º Ano', '1st Year',
     'Farmacogenética e alvos moleculares exigem sólida base de biologia celular e genética.',
     'Pharmacogenetics and molecular targets require a solid basis in cell biology and genetics.', 'published', 2),

    ('farm-quimica-geral', c, 'Química Geral e Inorgânica', 'General and Inorganic Chemistry',
     'Ligações, estequiometria e propriedades da matéria, base de toda a química farmacêutica.',
     'Bonds, stoichiometry and properties of matter, the basis of all pharmaceutical chemistry.',
     '1º Ano', '1st Year',
     'Sem química não se compreendem as reações dos fármacos nem a estabilidade das formulações.',
     'Without chemistry one cannot understand drug reactions or formulation stability.', 'published', 3),

    ('farm-quimica-organica', c, 'Química Orgânica I e II', 'Organic Chemistry I and II',
     'Estrutura, reatividade e grupos funcionais dos compostos orgânicos, núcleo dos fármacos.',
     'Structure, reactivity and functional groups of organic compounds, the core of drugs.',
     '1º Ano', '1st Year',
     'Os fármacos são moléculas orgânicas; dominar a química orgânica é essencial.',
     'Drugs are organic molecules; mastering organic chemistry is essential.', 'published', 4),

    ('farm-botanica', c, 'Botânica Aplicada à Farmácia', 'Applied Botany for Pharmacy',
     'Plantas de interesse farmacêutico, base da farmacognosia e da fitoterapia.',
     'Plants of pharmaceutical interest, the basis of pharmacognosy and phytotherapy.',
     '1º Ano', '1st Year',
     'Grande parte dos compostos ativos provém de fontes naturais; a botânica é a porta de entrada.',
     'Much of the active compounds come from natural sources; botany is the gateway.', 'published', 5),

    ('farm-fisica-matematica', c, 'Física e Matemática', 'Physics and Mathematics',
     'Princípios físicos e matemáticos aplicados à análise química e galénica.',
     'Physical and mathematical principles applied to chemical and galenic analysis.',
     '1º Ano', '1st Year',
     'Cinética, diluições e cálculos de dose dependem de base física e matemática.',
     'Kinetics, dilutions and dose calculations depend on a physics and maths base.', 'published', 6),

    ('farm-investigacao', c, 'Metodologia de Investigação Científica', 'Scientific Research Methodology',
     'Métodos de pesquisa, análise de dados e comunicação científica.',
     'Research methods, data analysis and scientific communication.',
     '1º Ano', '1st Year',
     'Necessária para a leitura crítica da literatura e para os trabalhos de fim de curso.',
     'Needed for critical reading of the literature and final theses.', 'published', 7),

    ('farm-linguas', c, 'Língua Portuguesa e Inglesa', 'Portuguese and English Language',
     'Comunicação científica em português e inglês técnico-farmacêutico.',
     'Scientific communication in Portuguese and technical pharmaceutical English.',
     '1º Ano', '1st Year',
     'A maior parte da literatura técnica está em inglês; a comunicação em português é essencial na prática.',
     'Most technical literature is in English; communication in Portuguese is essential in practice.', 'published', 8),

    ('farm-etica', c, 'Ética e Legislação Farmacêutica', 'Ethics and Pharmaceutical Legislation',
     'Deontologia profissional, regulamentação da profissão e do medicamento.',
     'Professional ethics, regulation of the profession and of medicines.',
     '1º Ano', '1st Year',
     'O exercício legal e ético da profissão começa aqui.',
     'The legal and ethical practice of the profession starts here.', 'published', 9),

    ('farm-bioquimica', c, 'Bioquímica', 'Biochemistry',
     'Metabolismo celular, enzimas e biomoléculas, base do mecanismo de ação dos fármacos.',
     'Cellular metabolism, enzymes and biomolecules, the basis of drug mechanism of action.',
     '2º Ano', '2nd Year',
     'A farmacologia e a farmacocinética dependem da bioquímica.',
     'Pharmacology and pharmacokinetics depend on biochemistry.', 'published', 10),

    ('farm-fisiologia', c, 'Fisiologia Humana', 'Human Physiology',
     'Funcionamento normal dos órgãos e sistemas do corpo humano.',
     'Normal function of organs and systems of the human body.',
     '2º Ano', '2nd Year',
     'A doença é fisiologia alterada; a ação dos fármacos só se entende com a fisiologia.',
     'Disease is altered physiology; drug action is only understood with physiology.', 'published', 11),

    ('farm-quimica-analitica', c, 'Química Analítica I e II', 'Analytical Chemistry I and II',
     'Métodos de análise quantitativa e qualitativa, do titrimétrico ao instrumental.',
     'Quantitative and qualitative analytical methods, from titrimetric to instrumental.',
     '2º Ano', '2nd Year',
     'É a base do controlo de qualidade e da análise de medicamentos.',
     'It is the basis of quality control and drug analysis.', 'published', 12),

    ('farm-biofisica', c, 'Biofísica e Química Física dos Colóides', 'Biophysics and Physical Chemistry of Colloids',
     'Fenómenos físico-químicos aplicados a dispersões, emulsões e sistemas farmacêuticos.',
     'Physicochemical phenomena applied to dispersions, emulsions and pharmaceutical systems.',
     '2º Ano', '2nd Year',
     'Fundamental para a formulação galénica e estabilidade de medicamentos.',
     'Fundamental for formulation and the stability of medicines.', 'published', 13),

    ('farm-microbiologia', c, 'Microbiologia', 'Microbiology',
     'Microrganismos de interesse sanitário, controlo microbiológico e assepsia.',
     'Microorganisms of sanitary interest, microbiological control and asepsis.',
     '2º Ano', '2nd Year',
     'Controlo de qualidade microbiológico e produção estéril dependem desta base.',
     'Microbiological quality control and sterile production depend on this base.', 'published', 14),

    ('farm-farmacognosia', c, 'Farmacognosia', 'Pharmacognosy',
     'Drogas vegetais e produtos naturais com atividade farmacológica.',
     'Vegetable drugs and natural products with pharmacological activity.',
     '2º Ano', '2nd Year',
     'Base da fitoterapia e do desenvolvimento de medicamentos de origem natural.',
     'Basis of phytotherapy and the development of natural-origin medicines.', 'published', 15),

    ('farm-nutricao', c, 'Nutrição e Dietética', 'Nutrition and Dietetics',
     'Nutrientes, dietética e interação entre alimentação e medicamentos.',
     'Nutrients, dietetics and the interaction between food and medicines.',
     '2º Ano', '2nd Year',
     'Interações alimento-medicamento são parte da atenção farmacêutica.',
     'Food-drug interactions are part of pharmaceutical care.', 'published', 16),

    ('farm-farmacologia', c, 'Farmacologia', 'Pharmacology',
     'Mecanismos de ação, efeitos terapêuticos e adversos dos fármacos.',
     'Mechanisms of action, therapeutic and adverse effects of drugs.',
     '3º Ano', '3rd Year',
     'Base fundamental para qualquer profissional que lida com medicamentos e interações.',
     'The fundamental basis for any professional who works with medicines and interactions.', 'published', 17),

    ('farm-quimica-farmaceutica', c, 'Química Farmacêutica', 'Medicinal Chemistry',
     'Desenho e síntese de fármacos, relação estrutura-atividade e propriedades.',
     'Drug design and synthesis, structure-activity relationships and properties.',
     '3º Ano', '3rd Year',
     'Explica por que um fármaco tem determinada estrutura e potência.',
     'Explains why a drug has a given structure and potency.', 'published', 18),

    ('farm-galencia', c, 'Farmácia Galénica e Farmacotécnica', 'Pharmaceutics and Galenic Pharmacy',
     'Formulação, preparação e estabilidade de formas farmacêuticas.',
     'Formulation, preparation and stability of pharmaceutical dosage forms.',
     '3º Ano', '3rd Year',
     'É a arte de transformar o princípio ativo em medicamento utilizável.',
     'It is the art of turning the active principle into a usable medicine.', 'published', 19),

    ('farm-biofarmacia', c, 'Biofarmácia I e II', 'Biopharmaceutics I and II',
     'Relação entre a formulação, a libertação e a biodisponibilidade do fármaco.',
     'Relationship between formulation, release and bioavailability of the drug.',
     '3º Ano', '3rd Year',
     'Liga a galénica à farmacocinética: por que a forma do medicamento importa.',
     'Links pharmaceutics to pharmacokinetics: why the dosage form matters.', 'published', 20),

    ('farm-fitoterapia', c, 'Fitoterapia e Produtos Naturais', 'Phytotherapy and Natural Products',
     'Uso terapêutico de plantas e produtos naturais, com segurança e evidência.',
     'Therapeutic use of plants and natural products, with safety and evidence.',
     '3º Ano', '3rd Year',
     'Crescente procura de fitoterápicos exige competência técnica do farmacêutico.',
     'Rising demand for herbal products requires the pharmacist''s technical competence.', 'published', 21),

    ('farm-controle-qualidade', c, 'Controle de Qualidade de Medicamentos', 'Medicines Quality Control',
     'Ensaios físicos, químicos e microbiológicos que garantem a qualidade do medicamento.',
     'Physical, chemical and microbiological tests that guarantee medicine quality.',
     '3º Ano', '3rd Year',
     'Garante que o medicamento cumpre as especificações antes de chegar ao doente.',
     'Ensures the medicine meets specifications before reaching the patient.', 'published', 22),

    ('farm-bromatologia', c, 'Bromatologia e Hidrologia', 'Food and Water Analysis',
     'Análise de alimentos e águas com relevância farmacêutica e sanitária.',
     'Analysis of foods and waters with pharmaceutical and sanitary relevance.',
     '3º Ano', '3rd Year',
     'Complementa o controlo e a segurança de produtos para a saúde.',
     'Complements the control and safety of health products.', 'published', 23),

    ('farm-toxicologia', c, 'Toxicologia', 'Toxicology',
     'Efeitos adversos de substâncias, dose-resposta e gestão da intoxicação.',
     'Adverse effects of substances, dose-response and poison management.',
     '3º Ano', '3rd Year',
     'Essencial para a avaliação de segurança e a toxicovigilância.',
     'Essential for safety assessment and toxicovigilance.', 'published', 24),

    ('farm-cosmetologia', c, 'Cosmetologia', 'Cosmetology',
     'Formulação de produtos cosméticos e dermocosméticos.',
     'Formulation of cosmetic and dermocosmetic products.',
     '3º Ano', '3rd Year',
     'Área de exercício profissional em crescimento nas farmácias.',
     'A growing professional field in pharmacies.', 'published', 25),

    ('farm-administracao', c, 'Economia e Administração Farmacêutica', 'Pharmaceutical Economics and Management',
     'Gestão de farmácias, economia do medicamento e logística.',
     'Pharmacy management, economics of medicines and logistics.',
     '3º Ano', '3rd Year',
     'O farmacêutico moderno gere espaços de saúde; competências de gestão são essenciais.',
     'The modern pharmacist manages health spaces; management skills are essential.', 'published', 26),

    ('farm-farmacia-clinica', c, 'Farmácia Clínica', 'Clinical Pharmacy',
     'Acompanhamento farmacoterapêutico do doente e otimização da medicação.',
     'Patient pharmacotherapy follow-up and optimisation of medication.',
     '4º Ano', '4th Year',
     'É a prática que distingue o farmacêutico clínico: garantir resultados sem dano.',
     'The practice that defines the clinical pharmacist: outcomes without harm.', 'published', 27),

    ('farm-farmacia-hospitalar', c, 'Farmácia Hospitalar', 'Hospital Pharmacy',
     'Gestão de medicamentos e dispositivos no ambiente hospitalar.',
     'Management of medicines and devices in the hospital environment.',
     '4º Ano', '4th Year',
     'Pré-requisito para o estágio em farmácia hospitalar.',
     'A prerequisite for the hospital pharmacy internship.', 'published', 28),

    ('farm-estagio', c, 'Estágio Supervisionado', 'Supervised Internship',
     'Prática profissional em farmácia comunitária, hospitalar ou industrial.',
     'Professional practice in community, hospital or industrial pharmacy.',
     '4º-5º Ano', '4th-5th Year',
     'Momento de integração da teoria na prática clínica real.',
     'A time to integrate theory into real clinical practice.', 'published', 29),

    ('farm-tcc', c, 'Trabalho de Fim de Curso e Metodologia Científica', 'Final Thesis and Scientific Methodology',
     'Projeto de investigação e monografia de fim de curso.',
     'Research project and final monograph.',
     '5º Ano', '5th Year',
     'Avalia a capacidade de síntese, investigação e comunicação científica.',
     'Assesses synthesis, research and scientific communication skills.', 'published', 30);
END $$;

-- ---------- MEDICINA (6 anos) ----------
DO $$
DECLARE
  c UUID;
BEGIN
  SELECT id INTO c FROM public.guide_courses WHERE slug = 'medicina';
  DELETE FROM public.guide_disciplines WHERE course_id = c;

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order) VALUES
    ('med-anatomia', c, 'Anatomia Humana (Sistemática e Topográfica)', 'Human Anatomy (Systemic and Topographic)',
     'Estudo sistemático e topográfico da estrutura do corpo humano, incluindo neuroanatomia.',
     'Systematic and topographic study of the human body structure, including neuroanatomy.',
     '1º Ano', '1st Year',
     'Base de toda a semiologia e dos procedimentos seguros.',
     'The foundation of all semiology and safe procedures.', 'published', 1),

    ('med-biologia-genetica', c, 'Biologia Celular, Molecular e Genética', 'Cell, Molecular Biology and Genetics',
     'Mecanismos moleculares e genéticos da célula e do desenvolvimento.',
     'Molecular and genetic mechanisms of the cell and development.',
     '1º Ano', '1st Year',
     'Alvo de novas terapias e da medicina de precisão.',
     'Target of new therapies and precision medicine.', 'published', 2),

    ('med-histologia-embriologia', c, 'Histologia e Embriologia', 'Histology and Embryology',
     'Tecidos, órgãos e desenvolvimento embrionário do ser humano.',
     'Tissues, organs and embryonic development of the human being.',
     '1º-2º Ano', '1st-2nd Year',
     'Base morfológica de todos os órgãos e sistemas.',
     'Morphological foundation of all organs and systems.', 'published', 3),

    ('med-biofisica', c, 'Biofísica / Física Médica', 'Biophysics / Medical Physics',
     'Princípios físicos aplicados ao organismo e às técnicas de imagem.',
     'Physical principles applied to the body and imaging techniques.',
     '1º Ano', '1st Year',
     'Relevante para a fisiologia e para a imagiologia.',
     'Relevant to physiology and imaging.', 'published', 4),

    ('med-bioquimica', c, 'Bioquímica e Metabolismo', 'Biochemistry and Metabolism',
     'Metabolismo celular, enzimas e vias bioquímicas da normalidade e da doença.',
     'Cellular metabolism, enzymes and biochemical pathways of health and disease.',
     '1º-2º Ano', '1st-2nd Year',
     'A interpretação de exames laboratoriais assenta na bioquímica.',
     'Laboratory test interpretation rests on biochemistry.', 'published', 5),

    ('med-bioestatistica', c, 'Bioestatística e Informática', 'Biostatistics and Informatics',
     'Métodos estatísticos e informáticos aplicados à investigação em saúde.',
     'Statistical and computational methods applied to health research.',
     '1º Ano', '1st Year',
     'Base da medicina baseada na evidência e da epidemiologia.',
     'Foundation of evidence-based medicine and epidemiology.', 'published', 6),

    ('med-metodologia', c, 'Metodologia de Investigação Médica', 'Medical Research Methodology',
     'Métodos de pesquisa clínica, desenho de estudos e análise crítica da literatura.',
     'Clinical research methods, study design and critical appraisal of the literature.',
     '1º Ano', '1st Year',
     'Capacita o futuro médico para a investigação e a prática baseada na evidência.',
     'Equips the future physician for research and evidence-based practice.', 'published', 7),

    ('med-epidemiologia', c, 'Epidemiologia e Demografia Sanitária', 'Epidemiology and Sanitary Demography',
     'Distribuição e determinantes das doenças na população, e dados demográficos.',
     'Distribution and determinants of disease in populations, and demographic data.',
     '1º-2º Ano', '1st-2nd Year',
     'Base da saúde pública e das políticas de saúde.',
     'Foundation of public health and health policies.', 'published', 8),

    ('med-linguas', c, 'Língua Portuguesa e Inglês Médico', 'Portuguese Language and Medical English',
     'Comunicação clínica e científica em português e inglês médico.',
     'Clinical and scientific communication in Portuguese and medical English.',
     '1º Ano', '1st Year',
     'A literatura médica dominante está em inglês; a comunicação clínica em português é essencial.',
     'The dominant medical literature is in English; clinical communication in Portuguese is essential.', 'published', 9),

    ('med-sociologia-psicologia', c, 'Sociologia e Psicologia Médica', 'Medical Sociology and Psychology',
     'Dimensões sociais e psicológicas da saúde, da doença e da relação médico-doente.',
     'Social and psychological dimensions of health, disease and the doctor-patient relationship.',
     '1º Ano', '1st Year',
     'Uma medicina humanista exige compreender o doente como pessoa.',
     'A humanist medicine requires understanding the patient as a person.', 'published', 10),

    ('med-bioetica', c, 'Bioética, História e Legislação Médica', 'Bioethics, Medical History and Legislation',
     'Fundamentos éticos, históricos e legais da prática médica.',
     'Ethical, historical and legal foundations of medical practice.',
     '1º-2º Ano', '1st-2nd Year',
     'A deontologia médica e os dilemas éticos atravessam toda a carreira.',
     'Medical deontology and ethical dilemmas run through the whole career.', 'published', 11),

    ('med-fisiologia', c, 'Fisiologia Humana', 'Human Physiology',
     'Mecanismos que mantêm o funcionamento normal dos órgãos e sistemas.',
     'Mechanisms that maintain the normal function of organs and systems.',
     '2º Ano', '2nd Year',
     'A doença é fisiologia desregulada; pré-requisito da farmacologia e da clínica.',
     'Disease is deregulated physiology; a prerequisite for pharmacology and clinical practice.', 'published', 12),

    ('med-microbiologia', c, 'Microbiologia e Parasitologia', 'Microbiology and Parasitology',
     'Agentes infecciosos e parasitários, e doenças infecto-contagiosas.',
     'Infectious and parasitic agents, and infectious-contagious diseases.',
     '2º Ano', '2nd Year',
     'Base do diagnóstico e tratamento das doenças infeciosas, muito prevalentes em Angola.',
     'Basis for diagnosis and treatment of infectious diseases, very prevalent in Angola.', 'published', 13),

    ('med-imunologia', c, 'Imunologia', 'Immunology',
     'Sistema imunitário, imunodeficiências, autoimunidade e alergia.',
     'Immune system, immunodeficiencies, autoimmunity and allergy.',
     '2º Ano', '2nd Year',
     'Essencial para vacinação, alergologia e doenças autoimunes.',
     'Essential for vaccination, allergology and autoimmune diseases.', 'published', 14),

    ('med-farmacologia', c, 'Farmacologia', 'Pharmacology',
     'Fundamentos da ação de fármacos, farmacocinética e farmacodinâmica.',
     'Fundamentals of drug action, pharmacokinetics and pharmacodynamics.',
     '2º-3º Ano', '2nd-3rd Year',
     'Base da terapêutica e da prescrição racional.',
     'Basis of therapeutics and rational prescribing.', 'published', 15),

    ('med-nutricao', c, 'Nutrição', 'Nutrition',
     'Nutrição, estados carenciais e suporte nutricional.',
     'Nutrition, deficiency states and nutritional support.',
     '2º Ano', '2nd Year',
     'A desnutrição é um importante problema de saúde em Angola.',
     'Malnutrition is a major health problem in Angola.', 'published', 16),

    ('med-patologia', c, 'Patologia Geral e Anatomia Patológica', 'General Pathology and Pathological Anatomy',
     'Mecanismos de doença, lesão celular, inflamação e neoplasia.',
     'Disease mechanisms, cell injury, inflammation and neoplasia.',
     '2º-3º Ano', '2nd-3rd Year',
     'Liga o básico à clínica: por que as doenças se manifestam assim.',
     'Links the basics to the clinic: why diseases present the way they do.', 'published', 17),

    ('med-semiologia', c, 'Semiologia Médica (Anamnese e Exame Físico)', 'Clinical Examination (History and Physical Exam)',
     'História clínica, exame físico e raciocínio por hipóteses diagnósticas.',
     'Clinical history, physical examination and diagnostic hypothesis reasoning.',
     '3º Ano', '3rd Year',
     'A primeira competência avaliada em qualquer estágio hospitalar.',
     'The first competency assessed in any hospital rotation.', 'published', 18),

    ('med-imagiologia', c, 'Imagiologia / Radiologia', 'Imaging / Radiology',
     'Interpretação de radiologia convencional e técnicas de imagem avançadas.',
     'Interpretation of conventional radiology and advanced imaging techniques.',
     '3º Ano', '3rd Year',
     'Essencial no diagnóstico das doenças e nas emergências.',
     'Essential in disease diagnosis and emergencies.', 'published', 19),

    ('med-farmacologia-clinica', c, 'Farmacologia Clínica', 'Clinical Pharmacology',
     'Aplicação da farmacologia à terapêutica por sistemas e especialidades.',
     'Application of pharmacology to therapy by systems and specialties.',
     '3º Ano', '3rd Year',
     'Traduz a farmacologia em decisões clínicas reais.',
     'Translates pharmacology into real clinical decisions.', 'published', 20),

    ('med-medicina-interna', c, 'Medicina Interna (Módulos por Sistemas)', 'Internal Medicine (Systems Modules)',
     'Clínica de Cardiologia, Pneumologia, Gastroenterologia, Nefrologia, Hematologia, Oncologia, Reumatologia, Infectologia, Neurologia, Endocrinologia, Dermatologia e Medicina Crítica.',
     'Clinical disciplines of Cardiology, Pulmonology, Gastroenterology, Nephrology, Haematology, Oncology, Rheumatology, Infectiology, Neurology, Endocrinology, Dermatology and Critical Care.',
     '4º Ano', '4th Year',
     'O núcleo da prática médica; percorre todas as especialidades clínicas de adulto.',
     'The core of medical practice; spans all adult clinical specialties.', 'published', 21),

    ('med-cirurgia', c, 'Cirurgia Geral e Especializada', 'General and Specialised Surgery',
     'Cirurgia geral e especialidades cirúrgicas: abdómen, tórax, neurocirurgia, ortopedia, oftalmologia, otorrinolaringologia, urologia.',
     'General surgery and surgical specialties: abdomen, thorax, neurosurgery, orthopaedics, ophthalmology, ENT, urology.',
     '4º-5º Ano', '4th-5th Year',
     'Compreende as indicações, contraindicações e cuidados cirúrgicos.',
     'Covers surgical indications, contraindications and care.', 'published', 22),

    ('med-anestesiologia', c, 'Anestesiologia, Reanimação e Terapia da Dor', 'Anaesthesiology, Resuscitation and Pain Therapy',
     'Anestesia, reanimação cardiorrespiratória e gestão da dor.',
     'Anaesthesia, cardiopulmonary resuscitation and pain management.',
     '4º Ano', '4th Year',
     'Competência crítica em salas de operações e emergências.',
     'Critical competency in operating rooms and emergencies.', 'published', 23),

    ('med-medicina-fisica', c, 'Medicina Física e Reabilitação', 'Physical Medicine and Rehabilitation',
     'Diagnóstico e tratamento da incapacidade funcional.',
     'Diagnosis and treatment of functional disability.',
     '4º-5º Ano', '4th-5th Year',
     'Relevante para sequelas de traumatismos e de doenças neurológicas.',
     'Relevant for sequelae of trauma and neurological diseases.', 'published', 24),

    ('med-gestao-saude', c, 'Gestão e Economia da Saúde', 'Health Management and Economics',
     'Administração de serviços de saúde, recursos e políticas sanitárias.',
     'Health services administration, resources and health policies.',
     '4º-5º Ano', '4th-5th Year',
     'O médico gere equipas e serviços; competências de gestão são necessárias.',
     'Physicians manage teams and services; management skills are needed.', 'published', 25),

    ('med-ginecologia', c, 'Ginecologia e Obstetrícia', 'Gynaecology and Obstetrics',
     'Saúde da mulher, gravidez, parto e puerpério.',
     'Women''s health, pregnancy, labour and postpartum.',
     '5º Ano', '5th Year',
     'A mortalidade materna é um problema prioritário em Angola; exige competência clínica.',
     'Maternal mortality is a priority problem in Angola; requires clinical competency.', 'published', 26),

    ('med-pediatria', c, 'Neonatologia e Pediatria', 'Neonatology and Paediatrics',
     'Saúde da criança, recém-nascido e adolescente.',
     'Child, newborn and adolescent health.',
     '5º Ano', '5th Year',
     'A mortalidade infantil é prioritária; o cuidado pediátrico é essencial.',
     'Infant mortality is a priority; paediatric care is essential.', 'published', 27),

    ('med-psiquiatria', c, 'Psiquiatria Clínica e Neurologia', 'Clinical Psychiatry and Neurology',
     'Doenças do sistema nervoso e perturbações mentais.',
     'Diseases of the nervous system and mental disorders.',
     '5º Ano', '5th Year',
     'Distúrbios neurológicos e mentais são causas importantes de incapacidade.',
     'Neurological and mental disorders are major causes of disability.', 'published', 28),

    ('med-medicina-legal', c, 'Medicina Legal e Deontologia', 'Forensic Medicine and Deontology',
     'Aplicação da medicina ao direito e deveres éticos profissionais.',
     'Application of medicine to law and professional ethical duties.',
     '5º-6º Ano', '5th-6th Year',
     'Competência médico-legal e ética necessária à prática responsável.',
     'Medicolegal and ethical competency needed for responsible practice.', 'published', 29),

    ('med-internato', c, 'Internato Rotativo (Medicina, Cirurgia, Pediatria, GO, Saúde Pública)', 'Rotating Internship (Medicine, Surgery, Paediatrics, OB-GYN, Public Health)',
     'Estágios práticos obrigatórios nas principais áreas clínicas.',
     'Mandatory practical rotations in the main clinical areas.',
     '6º Ano', '6th Year',
     'Aplicação supervisionada de todas as competências clínicas antes da licença.',
     'Supervised application of all clinical competencies before licensure.', 'published', 30),

    ('med-tcc', c, 'Trabalho de Fim de Curso / Monografia', 'Final Thesis / Monograph',
     'Projeto de investigação original como requisito de conclusão.',
     'Original research project as a completion requirement.',
     '6º Ano', '6th Year',
     'Avalia a capacidade de investigação e de comunicação científica.',
     'Assesses research and scientific communication skills.', 'published', 31);
END $$;

-- ---------- ENFERMAGEM (4 anos) ----------
DO $$
DECLARE
  c UUID;
BEGIN
  SELECT id INTO c FROM public.guide_courses WHERE slug = 'enfermagem';
  DELETE FROM public.guide_disciplines WHERE course_id = c;

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order) VALUES
    ('enf-anatomia', c, 'Anatomia Humana', 'Human Anatomy',
     'Estrutura macroscópica do corpo humano, focada nos sistemas de interesse para os cuidados.',
     'Macroscopic structure of the human body, focusing on systems of interest for care.',
     '1º Ano', '1st Year',
     'Base para a semiologia e para os procedimentos de enfermagem.',
     'Foundation for semiology and nursing procedures.', 'published', 1),

    ('enf-biologia', c, 'Biologia Celular, Molecular e Genética', 'Cell, Molecular Biology and Genetics',
     'Mecanismos celulares e genéticos, base da saúde e da doença.',
     'Cellular and genetic mechanisms, the basis of health and disease.',
     '1º Ano', '1st Year',
     'Compreender a genética e a biologia molecular é essencial nos cuidados modernos.',
     'Understanding genetics and molecular biology is essential in modern care.', 'published', 2),

    ('enf-histologia', c, 'Histologia e Embriologia', 'Histology and Embryology',
     'Tecidos, órgãos e desenvolvimento embrionário do ser humano.',
     'Tissues, organs and embryonic development of the human being.',
     '1º Ano', '1st Year',
     'Base morfológica dos sistemas de órgãos.',
     'Morphological foundation of organ systems.', 'published', 3),

    ('enf-microbiologia', c, 'Microbiologia', 'Microbiology',
     'Microrganismos de interesse sanitário e medidas de prevenção de infeção.',
     'Microorganisms of sanitary interest and infection prevention measures.',
     '1º Ano', '1st Year',
     'Base das medidas de controlo de infeção hospitalar.',
     'Basis of hospital infection control measures.', 'published', 4),

    ('enf-epidemiologia', c, 'Epidemiologia e Bioestatística', 'Epidemiology and Biostatistics',
     'Distribuição das doenças na população e métodos estatísticos em saúde.',
     'Distribution of diseases in populations and statistical methods in health.',
     '1º Ano', '1st Year',
     'Base da enfermagem comunitária e da saúde pública.',
     'Basis of community nursing and public health.', 'published', 5),

    ('enf-investigacao', c, 'Metodologia de Investigação Científica', 'Scientific Research Methodology',
     'Métodos de investigação e prática baseada na evidência.',
     'Research methods and evidence-based practice.',
     '1º Ano', '1st Year',
     'Capacita o enfermeiro para avaliar evidência e melhorar os cuidados.',
     'Equips the nurse to appraise evidence and improve care.', 'published', 6),

    ('enf-psicologia', c, 'Psicologia e Relação de Ajuda', 'Psychology and Helping Relationship',
     'Dimensões psicológicas do doente e a relação terapêutica enfermeiro-doente.',
     'Psychological dimensions of the patient and the nurse-patient therapeutic relationship.',
     '1º Ano', '1st Year',
     'A comunicação e a empatia são competências centrais dos cuidados.',
     'Communication and empathy are central nursing competencies.', 'published', 7),

    ('enf-sociologia', c, 'Sociologia e Antropologia da Saúde', 'Sociology and Anthropology of Health',
     'Dimensões sociais e culturais da saúde e da doença.',
     'Social and cultural dimensions of health and disease.',
     '1º Ano', '1st Year',
     'Compreender a comunidade é essencial na enfermagem comunitária.',
     'Understanding the community is essential in community nursing.', 'published', 8),

    ('enf-etica', c, 'Ética e Legislação em Enfermagem', 'Ethics and Nursing Legislation',
     'Deontologia profissional e enquadramento legal do exercício de enfermagem.',
     'Professional ethics and legal framework of nursing practice.',
     '1º Ano', '1st Year',
     'O exercício legal e ético da profissão começa aqui.',
     'The legal and ethical practice of the profession starts here.', 'published', 9),

    ('enf-linguas', c, 'Língua Portuguesa e Inglesa', 'Portuguese and English Language',
     'Comunicação profissional e científica.',
     'Professional and scientific communication.',
     '1º Ano', '1st Year',
     'Instrumentos de comunicação com doentes, equipas e literatura.',
     'Tools for communicating with patients, teams and literature.', 'published', 10),

    ('enf-fisiologia-bioquimica', c, 'Fisiologia e Bioquímica', 'Physiology and Biochemistry',
     'Funcionamento normal do organismo e vias bioquímicas da doença.',
     'Normal body functioning and biochemical pathways of disease.',
     '2º Ano', '2nd Year',
     'Base para compreender a doença e a ação dos fármacos.',
     'Basis for understanding disease and drug action.', 'published', 11),

    ('enf-farmacologia', c, 'Farmacologia', 'Pharmacology',
     'Fármacos, administração segura e efeitos adversos.',
     'Drugs, safe administration and adverse effects.',
     '2º Ano', '2nd Year',
     'A administração de terapêutica é uma função diária e de alto risco do enfermeiro.',
     'Medicine administration is a daily, high-risk nursing function.', 'published', 12),

    ('enf-imunologia', c, 'Imunologia e Parasitologia', 'Immunology and Parasitology',
     'Sistema imunitário e parasitas de interesse sanitário.',
     'Immune system and parasites of sanitary interest.',
     '2º Ano', '2nd Year',
     'Relevante para as doenças parasitárias prevalentes em Angola.',
     'Relevant for the parasitic diseases prevalent in Angola.', 'published', 13),

    ('enf-patologia', c, 'Patologia Geral e Processos Patológicos', 'General Pathology and Pathological Processes',
     'Mecanismos de doença, inflamação e adaptação celular.',
     'Disease mechanisms, inflammation and cell adaptation.',
     '2º Ano', '2nd Year',
     'Liga a fisiologia à manifestação clínica da doença.',
     'Links physiology to the clinical manifestation of disease.', 'published', 14),

    ('enf-nutricao', c, 'Nutrição e Dietética', 'Nutrition and Dietetics',
     'Nutrição, dietoterapia e avaliação do estado nutricional.',
     'Nutrition, diet therapy and nutritional status assessment.',
     '2º Ano', '2nd Year',
     'A desnutrição é um problema prevalente; o enfermeiro faz triagem nutricional.',
     'Malnutrition is prevalent; the nurse performs nutritional screening.', 'published', 15),

    ('enf-saude-publica', c, 'Saúde Pública e Ambiental', 'Public and Environmental Health',
     'Promoção da saúde, vigilância sanitária e saúde ambiental.',
     'Health promotion, sanitary surveillance and environmental health.',
     '2º Ano', '2nd Year',
     'Base da prevenção e da saúde comunitária.',
     'Basis of prevention and community health.', 'published', 16),

    ('enf-fundamentos', c, 'Fundamentos de Enfermagem e Semiologia', 'Nursing Fundamentals and Semiology',
     'Procedimentos básicos, sinais vitais, sinais e sintomas.',
     'Basic procedures, vital signs, signs and symptoms.',
     '2º Ano', '2nd Year',
     'O primeiro contacto com a prática; procedimentos usados todos os dias.',
     'The first contact with practice; procedures used every day.', 'published', 17),

    ('enf-saude-adulto', c, 'Enfermagem em Saúde do Adulto (Médico-Cirúrgica)', 'Adult Health Nursing (Medical-Surgical)',
     'Cuidados de enfermagem ao adulto em contexto médico-cirúrgico.',
     'Nursing care of the adult in medical-surgical contexts.',
     '3º Ano', '3rd Year',
     'O núcleo dos cuidados hospitalares ao doente adulto.',
     'The core of hospital care for the adult patient.', 'published', 18),

    ('enf-saude-mulher', c, 'Enfermagem em Saúde da Mulher e Materno-Obstétrica', 'Women''s and Maternal-Obstetric Nursing',
     'Cuidados à mulher, grávida, parturiente e puérpera.',
     'Care for women, pregnant, labouring and postpartum women.',
     '3º Ano', '3rd Year',
     'A redução da mortalidade materna depende de cuidados de enfermagem competentes.',
     'Reducing maternal mortality depends on competent nursing care.', 'published', 19),

    ('enf-saude-crianca', c, 'Enfermagem em Saúde da Criança e Adolescente (Pediatria)', 'Child and Adolescent Health Nursing (Paediatrics)',
     'Cuidados de enfermagem à criança, recém-nascido e adolescente.',
     'Nursing care for the child, newborn and adolescent.',
     '3º Ano', '3rd Year',
     'A mortalidade infantil é prioritária; os cuidados pediátricos são essenciais.',
     'Infant mortality is a priority; paediatric care is essential.', 'published', 20),

    ('enf-saude-idoso', c, 'Enfermagem em Saúde do Idoso (Geriátrica)', 'Elderly Health Nursing (Geriatrics)',
     'Cuidados de enfermagem ao idoso e à pessoa dependente.',
     'Nursing care for the elderly and dependent person.',
     '3º Ano', '3rd Year',
     'O envelhecimento populacional torna os cuidados geriátricos cada vez mais centrais.',
     'Population ageing makes geriatric care increasingly central.', 'published', 21),

    ('enf-saude-mental', c, 'Enfermagem em Saúde Mental e Psiquiátrica', 'Mental Health and Psychiatric Nursing',
     'Cuidados à pessoa com perturbação mental e psiquiátrica.',
     'Care for people with mental and psychiatric disorders.',
     '3º Ano', '3rd Year',
     'Distúrbios mentais são causa importante de incapacidade; exigem cuidados especializados.',
     'Mental disorders are a major cause of disability; they require specialised care.', 'published', 22),

    ('enf-cirurgico', c, 'Enfermagem em Centro Cirúrgico e Esterilização', 'Operating Room and Sterilisation Nursing',
     'Cuidados perioperatórios, assepsia e esterilização.',
     'Perioperative care, asepsis and sterilisation.',
     '3º Ano', '3rd Year',
     'Competência técnica em bloco operatório e controlo de infeção.',
     'Technical competency in the operating theatre and infection control.', 'published', 23),

    ('enf-comunitaria', c, 'Enfermagem Comunitária e Cuidados Primários', 'Community Nursing and Primary Care',
     'Cuidados de saúde na comunidade, prevenção e promoção da saúde.',
     'Community health care, prevention and health promotion.',
     '3º Ano', '3rd Year',
     'O enfermeiro é a porta de entrada dos cuidados de saúde primários em Angola.',
     'The nurse is the gateway of primary health care in Angola.', 'published', 24),

    ('enf-administracao', c, 'Administração e Gestão em Enfermagem', 'Nursing Administration and Management',
     'Gestão de serviços de saúde, equipas e recursos de enfermagem.',
     'Management of health services, teams and nursing resources.',
     '3º-4º Ano', '3rd-4th Year',
     'O enfermeiro gere equipas e serviços; competências de gestão são essenciais.',
     'Nurses manage teams and services; management skills are essential.', 'published', 25),

    ('enf-pedagogia', c, 'Didática e Educação para a Saúde', 'Didactics and Health Education',
     'Ensino, formação e educação para a saúde de doentes e comunidades.',
     'Teaching, training and health education of patients and communities.',
     '3º-4º Ano', '3rd-4th Year',
     'O papel educativo do enfermeiro é central na prevenção.',
     'The nurse''s educational role is central to prevention.', 'published', 26),

    ('enf-estagio', c, 'Estágio Curricular Supervisionado', 'Supervised Curricular Internship',
     'Prática profissional supervisionada em serviços de saúde.',
     'Supervised professional practice in health services.',
     '4º Ano', '4th Year',
     'Integra a teoria na prática clínica real, sob supervisão.',
     'Integrates theory into real clinical practice, under supervision.', 'published', 27),

    ('enf-tcc', c, 'Trabalho de Fim de Curso / Monografia', 'Final Thesis / Monograph',
     'Projeto de investigação e monografia de fim de curso.',
     'Research project and final monograph.',
     '4º Ano', '4th Year',
     'Avalia a capacidade de síntese e investigação.',
     'Assesses synthesis and research skills.', 'published', 28);
END $$;

-- ---------- ANÁLISES CLÍNICAS (4 anos) ----------
DO $$
DECLARE
  c UUID;
BEGIN
  SELECT id INTO c FROM public.guide_courses WHERE slug = 'analises-clinicas';
  DELETE FROM public.guide_disciplines WHERE course_id = c;

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order) VALUES
    ('acl-anatomia', c, 'Anatomia Humana', 'Human Anatomy',
     'Estrutura macroscópica do corpo humano com foco nos órgãos de colheita e amostragem.',
     'Macroscopic structure of the human body, focusing on collection and sampling sites.',
     '1º Ano', '1st Year',
     'Base para a colheita adequada de amostras biológicas.',
     'Foundation for proper collection of biological samples.', 'published', 1),

    ('acl-biologia', c, 'Biologia Celular, Molecular e Genética', 'Cell, Molecular Biology and Genetics',
     'Mecanismos celulares e genéticos, base das técnicas moleculares.',
     'Cellular and genetic mechanisms, the basis of molecular techniques.',
     '1º Ano', '1st Year',
     'A genética molecular é cada vez mais usada no diagnóstico laboratorial.',
     'Molecular genetics is increasingly used in laboratory diagnosis.', 'published', 2),

    ('acl-histologia', c, 'Histologia e Embriologia', 'Histology and Embryology',
     'Tecidos e órgãos, base da citologia e das anátomo-patologias.',
     'Tissues and organs, the basis of cytology and histopathology.',
     '1º Ano', '1st Year',
     'Key para a citologia e a interpretação de lâminas.',
     'Key to cytology and slide interpretation.', 'published', 3),

    ('acl-quimica', c, 'Química Geral e Orgânica', 'General and Organic Chemistry',
     'Princípios químicos e grupos funcionais, base das técnicas analíticas.',
     'Chemical principles and functional groups, the basis of analytical techniques.',
     '1º Ano', '1st Year',
     'Toda a análise laboratorial assenta em reações químicas.',
     'All laboratory analysis rests on chemical reactions.', 'published', 4),

    ('acl-bioestatistica', c, 'Bioestatística e Biofísica', 'Biostatistics and Biophysics',
     'Métodos estatísticos e princípios físicos aplicados ao laboratório.',
     'Statistical methods and physical principles applied to the laboratory.',
     '1º Ano', '1st Year',
     'O controlo de qualidade e validação de métodos dependem da estatística.',
     'Quality control and method validation depend on statistics.', 'published', 5),

    ('acl-investigacao', c, 'Metodologia de Investigação Científica', 'Scientific Research Methodology',
     'Métodos de investigação e validação de técnicas laboratoriais.',
     'Research methods and validation of laboratory techniques.',
     '1º Ano', '1st Year',
     'Capacita para a validação de métodos e a pesquisa em laboratório.',
     'Equips for method validation and laboratory research.', 'published', 6),

    ('acl-etica', c, 'Ética, Legislação e Biossegurança', 'Ethics, Legislation and Biosafety',
     'Deontologia, regulação e normas de segurança biológica.',
     'Deontology, regulation and biological safety standards.',
     '1º Ano', '1st Year',
     'A biossegurança protege o analista, o doente e os colegas.',
     'Biosafety protects the analyst, the patient and colleagues.', 'published', 7),

    ('acl-linguas', c, 'Língua Portuguesa e Sociologia da Saúde', 'Portuguese Language and Sociology of Health',
     'Comunicação científica e dimensões sociais da saúde pública.',
     'Scientific communication and social dimensions of public health.',
     '1º Ano', '1st Year',
     'A comunicação dos resultados exige rigor e clareza.',
     'Communicating results requires rigour and clarity.', 'published', 8),

    ('acl-fisiologia', c, 'Fisiologia Humana', 'Human Physiology',
     'Funcionamento normal do organismo e sua relação com os biomarcadores.',
     'Normal body functioning and its relationship with biomarkers.',
     '2º Ano', '2nd Year',
     'Compreender a fisiologia é essencial para interpretar valores de referência.',
     'Understanding physiology is essential to interpret reference values.', 'published', 9),

    ('acl-bioquimica', c, 'Bioquímica Geral e Clínica', 'General and Clinical Biochemistry',
     'Metabolismo e análise de biomarcadores séricos e urinários.',
     'Metabolism and analysis of serum and urinary biomarkers.',
     '2º Ano', '2nd Year',
     'Grande parte do diagnóstico laboratorial passa pela bioquímica clínica.',
     'Much of laboratory diagnosis relies on clinical biochemistry.', 'published', 10),

    ('acl-hematologia', c, 'Hematologia Laboratorial', 'Laboratory Haematology',
     'Hemograma, coagulação e citologia hematológica.',
     'Complete blood count, coagulation and haematological cytology.',
     '2º Ano', '2nd Year',
     'O hemograma é o exame mais pedido em qualquer serviço.',
     'The complete blood count is the most requested test in any service.', 'published', 11),

    ('acl-microbiologia', c, 'Microbiologia e Bacteriologia', 'Microbiology and Bacteriology',
     'Identificação de bactérias e testes de sensibilidade aos antibióticos.',
     'Identification of bacteria and antimicrobial susceptibility testing.',
     '2º Ano', '2nd Year',
     'A antibioterapia dirigida depende de diagnóstico microbiológico fiável.',
     'Targeted antibiotic therapy depends on reliable microbiological diagnosis.', 'published', 12),

    ('acl-imunologia', c, 'Imunologia', 'Immunology',
     'Sistema imunitário e técnicas imunológicas e sorológicas.',
     'Immune system and immunological and serological techniques.',
     '2º Ano', '2nd Year',
     'Base das técnicas de ELISA, aglutinação e imunodiagnóstico.',
     'Basis of ELISA, agglutination and immunodiagnostic techniques.', 'published', 13),

    ('acl-parasitologia', c, 'Parasitologia', 'Parasitology',
     'Identificação de parasitas de interesse clínico, muito prevalentes em Angola.',
     'Identification of clinically relevant parasites, very prevalent in Angola.',
     '2º Ano', '2nd Year',
     'As parasitoses são endémicas; o diagnóstico laboratorial é crítica.',
     'Parasitoses are endemic; laboratory diagnosis is critical.', 'published', 14),

    ('acl-virus-micologia', c, 'Virologia e Micologia', 'Virology and Mycology',
     'Identificação de vírus e fungos patogénicos.',
     'Identification of pathogenic viruses and fungi.',
     '3º Ano', '3rd Year',
     'Essencial para o diagnóstico de infeções virais e fúngicas.',
     'Essential for diagnosing viral and fungal infections.', 'published', 15),

    ('acl-urinanalise', c, 'Urinálise e Outros Fluidos Orgânicos', 'Urinalysis and Other Body Fluids',
     'Análise de urina e outros fluidos biológicos.',
     'Analysis of urine and other biological fluids.',
     '3º Ano', '3rd Year',
     'Análise rápida e essencial da função renal e metabólica.',
     'Rapid, essential analysis of renal and metabolic function.', 'published', 16),

    ('acl-hemoterapia', c, 'Hemoterapia e Banco de Sangue', 'Haemotherapy and Blood Bank',
     'Imuno-hematologia, tipagem e compatibilidade sanguínea.',
     'Immunohaematology, blood typing and compatibility.',
     '3º Ano', '3rd Year',
     'A segurança transfusional depende de rigor laboratorial.',
     'Transfusion safety depends on laboratory rigour.', 'published', 17),

    ('acl-bromatologia', c, 'Bromatologia e Análise de Águas e Alimentos', 'Food and Water Analysis',
     'Controlo de qualidade sanitária de alimentos e águas.',
     'Sanitary quality control of foods and waters.',
     '3º Ano', '3rd Year',
     'Relevante para a saúde pública e a segurança alimentar.',
     'Relevant to public health and food safety.', 'published', 18),

    ('acl-controle-qualidade', c, 'Controle de Qualidade e Amostragem', 'Quality Control and Specimen Collection',
     'Garantia de qualidade interna e externa, e amostragem correta.',
     'Internal and external quality assurance, and correct specimen collection.',
     '3º Ano', '3rd Year',
     'A fiabilidade do resultado depende do controlo de qualidade.',
     'Result reliability depends on quality control.', 'published', 19),

    ('acl-toxicologia', c, 'Toxicologia Analítica', 'Analytical Toxicology',
     'Deteção de substâncias tóxicas e monitorização terapêutica.',
     'Detection of toxic substances and therapeutic drug monitoring.',
     '3º Ano', '3rd Year',
     'Fontes de intoxicação e drogas de abuso exigem análise toxicológica.',
     'Intoxication sources and drugs of abuse require toxicological analysis.', 'published', 20),

    ('acl-epidemiologia', c, 'Epidemiologia e Saúde Ambiental', 'Epidemiology and Environmental Health',
     'Distribuição de doenças e vigilância sanitária e ambiental.',
     'Distribution of diseases and sanitary and environmental surveillance.',
     '3º Ano', '3rd Year',
     'Liga o laboratório à saúde pública e à vigilância de endemias.',
     'Links the laboratory to public health and disease surveillance.', 'published', 21),

    ('acl-gestao', c, 'Gestão de Laboratório e Gestão Hospitalar', 'Laboratory and Hospital Management',
     'Organização, gestão de qualidade e economia de laboratórios clínicos.',
     'Organisation, quality management and economics of clinical laboratories.',
     '3º-4º Ano', '3rd-4th Year',
     'Um laboratório eficiente depende de boa gestão e acreditação.',
     'An efficient laboratory depends on good management and accreditation.', 'published', 22),

    ('acl-estagio', c, 'Estágio Curricular Supervisionado', 'Supervised Curricular Internship',
     'Prática profissional em laboratórios de análises clínicas.',
     'Professional practice in clinical analysis laboratories.',
     '4º Ano', '4th Year',
     'Integra a teoria na prática laboratorial real.',
     'Integrates theory into real laboratory practice.', 'published', 23),

    ('acl-tcc', c, 'Trabalho de Fim de Curso / Diagnóstico de Doenças Tropicais', 'Final Thesis / Tropical Diseases Diagnosis',
     'Projeto de investigação e diagnóstico laboratorial de doenças tropicais negligenciadas.',
     'Research project and laboratory diagnosis of neglected tropical diseases.',
     '4º Ano', '4th Year',
     'As doenças tropicais negligenciadas são prioritárias em Angola e dependem do laboratório.',
     'Neglected tropical diseases are a priority in Angola and depend on the laboratory.', 'published', 24);
END $$;


-- ============================================================
-- 4) LIVROS E RECURSOS — disciplinas-núcleo de cada curso
--    (resolve a disciplina por slug; preserva o valor do seed original)
-- ============================================================
DO $$
DECLARE
  d UUID;
BEGIN
  -- FARMÁCIA · Farmacologia (herança do seed original 038)
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'farm-farmacologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
     'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
     'Laurence L. Brunton, Bjorn Knollmann', '14ª Edição', 2023,
     'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1681245397i/63289543.jpg',
     'Considerado a "bíblia" da farmacologia. Essencial para o estudante que quer compreender em profundidade os mecanismos de ação, interações e efeitos dos fármacos.',
     'Considered the "bible" of pharmacology. Essential for the student who wants a deep understanding of drug mechanisms, interactions and effects.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1260464164"},{"label_pt":"Ver na Editora","label_en":"View on Publisher","url":"https://www.mhprofessional.com"}]',
     'published', 1);
  INSERT INTO public.guide_resources (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order) VALUES
    (d, 'Lista Modelo de Medicamentos Essenciais OMS 2025', 'WHO Model List of Essential Medicines 2025',
     'Lista atualizada de medicamentos essenciais da Organização Mundial da Saúde.',
     'Updated model list of essential medicines by the World Health Organization.',
     'https://www.who.int/publications/i/item/EML2025', 'guideline', 'published', 1),
    (d, 'Formulário Nacional de Medicamentos de Angola', 'Angola National Medicines Formulary',
     'Formulário oficial dos medicamentos disponíveis no sistema nacional de saúde angolano.',
     'Official formulary of medicines available in the Angolan national health system.',
     'https://www.minsa.gov.ao', 'guideline', 'published', 2);

  -- FARMÁCIA · Farmácia Galénica
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'farm-galencia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Aulton''s Pharmaceutics: The Design and Manufacture of Medicines',
     'Aulton''s Pharmaceutics: The Design and Manufacture of Medicines',
     'Michael E. Aulton, Kevin M.G. Taylor', '6ª Edição', 2021,
     'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1630185649i/58254499.jpg',
     'Referência mundial da farmácia galénica: formulação, fabrico e estabilidade das formas farmacêuticas.',
     'World reference of pharmaceutics: formulation, manufacture and stability of dosage forms.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0702081549"}]',
     'published', 1);

  -- FARMÁCIA · Química Farmacêutica
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'farm-quimica-farmaceutica';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Foye''s Principles of Medicinal Chemistry',
     'Foye''s Principles of Medicinal Chemistry',
     'Thomas L. Lemke, David A. Williams', '8ª Edição', 2020,
     'https://images-na.ssl-images-amazon.com/images/I/81W1G1vJzXL.jpg',
     'Base da relação estrutura-atividade e do desenho de fármacos.',
     'The foundation of structure-activity relationships and drug design.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1496386817"}]',
     'published', 1);

  -- FARMÁCIA · Farmacognosia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'farm-farmacognosia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Trease and Evans'' Pharmacognosy',
     'Trease and Evans'' Pharmacognosy',
     'William Charles Evans', '16ª Edição', 2009,
     'https://images-na.ssl-images-amazon.com/images/I/51K73S-4prL._SX382_BO1,204,203,200_.jpg',
     'Obra clássica das drogas vegetais e dos produtos naturais com atividade farmacológica.',
     'Classic work on vegetable drugs and natural products with pharmacological activity.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0702029334"}]',
     'published', 1);

  -- ============ MEDICINA ============

  -- MEDICINA · Farmacologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-farmacologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Basic and Clinical Pharmacology',
     'Basic and Clinical Pharmacology',
     'Bertram G. Katzung, Todd W. Vanderah', '16ª Edição', 2023,
     'https://images-na.ssl-images-amazon.com/images/I/91hzGptmW6L.jpg',
     'Referência prática que liga a farmacologia básica à utilização clínica dos fármacos.',
     'A practical reference linking basic pharmacology to clinical drug use.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1265522087"}]',
     'published', 1);

  -- MEDICINA · Fisiologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-fisiologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Guyton & Hall — Tratado de Fisiologia Médica', 'Guyton & Hall Textbook of Medical Physiology',
     'John E. Hall, Michael E. Hall', '14ª Edição', 2020,
     'https://images-na.ssl-images-amazon.com/images/I/81tyF6T8vLL.jpg',
     'O manual de fisiologia mais usado no mundo, essencial para a base clínica.',
     'The most widely used physiology textbook in the world, essential for the clinical basis.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323597120"}]',
     'published', 1);

  -- MEDICINA · Patologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-patologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Robbins & Cotran — Bases Patológicas das Doenças', 'Robbins & Cotran Pathologic Basis of Disease',
     'Vinay Kumar, Abul K. Abbas, Jon C. Aster', '10ª Edição', 2020,
     'https://images-na.ssl-images-amazon.com/images/I/91H5GqMBkCL.jpg',
     'Obra de referência da patologia, ligando os mecanismos de doença à manifestação clínica.',
     'Reference pathology textbook linking disease mechanisms to clinical presentation.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323531136"}]',
     'published', 1);

  -- MEDICINA · Semiologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-semiologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Bates — Propedêutica Médica', 'Bates'' Guide to Physical Examination and History Taking',
     'Lynn S. Bickley, Peter G. Szilagyi', '13ª Edição', 2020,
     'https://images-na.ssl-images-amazon.com/images/I/91jX7jB7-8L.jpg',
     'Guia essencial da anamnese e do exame físico, base da prática clínica.',
     'Essential guide to history taking and physical examination, the basis of clinical practice.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1496398173"}]',
     'published', 1);

  -- MEDICINA · Medicina Interna
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-medicina-interna';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Harrison''s Principles of Internal Medicine',
     'Harrison''s Principles of Internal Medicine',
     'Joseph Loscalzo, Anthony Fauci, Dennis Kasper, Stephen Hauser, Dan Longo, J. Larry Jameson', '21ª Edição', 2022,
     'https://images-na.ssl-images-amazon.com/images/I/81V3WBXk1dL.jpg',
     'A referência internacional da medicina interna, indispensável no ciclo clínico.',
     'The international reference of internal medicine, indispensable in the clinical cycle.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1264268506"}]',
     'published', 1);

  -- MEDICINA · Pediatria
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-pediatria';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Tratado de Pediatria — Nelson', 'Nelson Textbook of Pediatrics',
     'Robert M. Kliegman, Joseph St. Geme, Nathan Blum, Samir S. Shah, Richard Tasker, Karen Wilson', '22ª Edição', 2024,
     'https://images-na.ssl-images-amazon.com/images/I/91UkXjE9P8L.jpg',
     'A referência mundial da pediatria, central para os cuidados à criança em Angola.',
     'The world reference of paediatrics, central to child care in Angola.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323883889"}]',
     'published', 1);

  -- MEDICINA · Ginecologia e Obstetrícia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'med-ginecologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Williams Obstetrics', 'Williams Obstetrics',
     'F. Gary Cunningham, Kenneth J. Leveno, Jodi S. Dashe, Barbara L. Hoffman, Brian M. Casey, Catherine Y. Spong', '26ª Edição', 2022,
     'https://images-na.ssl-images-amazon.com/images/I/91t5sy1fhdL.jpg',
     'Referência da obstetrícia, chave para reduzir a mortalidade materna.',
     'Reference of obstetrics, key to reducing maternal mortality.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1260462730"}]',
     'published', 1);

  -- ============ ENFERMAGEM ============

  -- ENFERMAGEM · Fundamentos
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'enf-fundamentos';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Tratado de Enfermagem Médico-Cirúrgica — Brunner & Suddarth', 'Brunner & Suddarth''s Textbook of Medical-Surgical Nursing',
     'Janice L. Hinkle, Kerry H. Cheever', '15ª Edição', 2021,
     'https://images-na.ssl-images-amazon.com/images/I/81QYhdvDGtL.jpg',
     'O manual mais completo da enfermagem médico-cirúrgica, dos fundamentos à prática avançada.',
     'The most complete medical-surgical nursing textbook, from fundamentals to advanced practice.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1975161051"}]',
     'published', 1);

  -- ENFERMAGEM · Saúde da Mulher
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'enf-saude-mulher';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Enfermagem Materno-Infantil e Obstétrica — Lowdermilk', 'Maternity & Women''s Health Care — Lowdermilk',
     'Debra A. Wilson, Shannon E. Perry, Marilyn J. Hockenberry, Mary Catherine Cooper', '13ª Edição', 2022,
     'https://images-na.ssl-images-amazon.com/images/I/81lYQaIB7kL.jpg',
     'Referência dos cuidados materno-infantis, essencial para reduzir a mortalidade perinatal.',
     'Reference of maternal and child care, essential to reduce perinatal mortality.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323811337"}]',
     'published', 1);

  -- ENFERMAGEM · Saúde Pública
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'enf-saude-publica';
  INSERT INTO public.guide_resources (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order) VALUES
    (d, 'Estratégias para a Cobertura Universal de Saúde (OMS)', 'Strategies towards Universal Health Coverage (WHO)',
     'Documento da OMS sobre o reforço dos cuidados de saúde primários e a cobertura universal.',
     'WHO document on strengthening primary health care and universal coverage.',
     'https://www.who.int/publications/i/item/9789241512236', 'guideline', 'published', 1);

  -- ============ ANÁLISES CLÍNICAS ============

  -- ANÁLISES CLÍNICAS · Bioquímica Clínica
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'acl-bioquimica';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Tietz Fundamentals of Clinical Chemistry and Molecular Diagnostics',
     'Tietz Fundamentals of Clinical Chemistry and Molecular Diagnostics',
     'Nader Rifai, Andrea Rita Horvath, Carl T. Wittwer', '9ª Edição', 2022,
     'https://images-na.ssl-images-amazon.com/images/I/81m3vZOW4uL.jpg',
     'A referência mundial da química clínica e do diagnóstico molecular no laboratório.',
     'The world reference of clinical chemistry and molecular diagnostics in the laboratory.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323885482"}]',
     'published', 1);

  -- ANÁLISES CLÍNICAS · Hematologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'acl-hematologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Rodak''s Hematology: Clinical Principles and Applications',
     'Rodak''s Hematology: Clinical Principles and Applications',
     'Elaine M. Keohane, Catherine N. Otto, Jeanine M. Walenga', '7ª Edição', 2025,
     'https://images-na.ssl-images-amazon.com/images/I/91m0ZFELElL.jpg',
     'Referência da hematologia laboratorial, do hemograma à coagulação e à citologia.',
     'Reference of laboratory haematology, from blood count to coagulation and cytology.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/0323847268"}]',
     'published', 1);

  -- ANÁLISES CLÍNICAS · Microbiologia
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'acl-microbiologia';
  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order) VALUES
    (d, 'Manual of Clinical Microbiology (ASM)',
     'Manual of Clinical Microbiology (ASM)',
     'Karen C. Carroll, Michael A. Pfaller, Marie Louise Landry', '13ª Edição', 2023,
     'https://images-na.ssl-images-amazon.com/images/I/91M1PmObLAL.jpg',
     'O manual de referência da microbiologia clínica e do antibiograma.',
     'The reference manual of clinical microbiology and susceptibility testing.',
     '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1683675561"}]',
     'published', 1);

  -- ANÁLISES CLÍNICAS · Controle de Qualidade
  SELECT id INTO d FROM public.guide_disciplines WHERE slug = 'acl-controle-qualidade';
  INSERT INTO public.guide_resources (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order) VALUES
    (d, 'Normas ISO 15189 — Laboratórios Clínicos', 'ISO 15189 — Medical Laboratories',
     'Norma internacional para a qualidade e competência dos laboratórios de análises clínicas.',
     'International standard for the quality and competence of medical laboratories.',
     'https://www.iso.org/standard/76677.html', 'guideline', 'published', 1);
END $$;

-- ============================================================
-- Nota para aplicação via CLI:
--   supabase db push   (ou colar o ficheiro no dashboard SQL)
-- Reexecução: DELETE+INSERT tornam o seed idempotente no conteúdo.
-- ============================================================
