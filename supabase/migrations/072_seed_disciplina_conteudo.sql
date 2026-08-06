-- 072: Study guides — conteúdo explicativo por disciplina.
-- learning_* = "Importância na formação" (todas as disciplinas)
-- practice_* = "No dia a dia do profissional" (disciplinas-chave)
-- Bilingue PT/EN · idempotente (UPDATE por slug).
UPDATE public.guide_disciplines SET
  learning_pt = 'Anatomia é a primeira linguagem do corpo humano: nomeia cada órgão e estrutura que mais tarde será preciso localizar e compreender na farmacologia e na galénica.',
  learning_en = 'Anatomy is the first language of the human body: it names every structure you will later need to locate and understand in pharmacology and pharmaceutics.'
WHERE slug = 'farm-anatomia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A biologia celular e a genética explicam por que cada fármaco age como age. É a base da farmacogenética e dos alvos moleculares que estuda depois.',
  learning_en = 'Cell biology and genetics explain why each drug acts the way it does. This is the basis of pharmacogenetics and the molecular targets you study later.'
WHERE slug = 'farm-biologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Toda a química farmacêutica parte daqui: ligações, estequiometria e propriedades da matéria são os alicerces para perceber reações e estabilidade de medicamentos.',
  learning_en = 'All pharmaceutical chemistry starts here: bonds, stoichiometry and the properties of matter are the foundation for understanding drug reactions and stability.'
WHERE slug = 'farm-quimica-geral';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os fármacos são moléculas orgânicas. Dominar grupos funcionais e reatividade é a chave para a química farmacêutica e para saber como cada fármaco se comporta.',
  learning_en = 'Drugs are organic molecules. Mastering functional groups and reactivity is the key to medicinal chemistry and to knowing how each drug behaves.'
WHERE slug = 'farm-quimica-organica';

UPDATE public.guide_disciplines SET
  learning_pt = 'As plantas sempre foram a fonte de muitos medicamentos. Aprende-se aqui a reconhecer espécies de interesse farmacêutico, base da farmacognosia.',
  learning_en = 'Plants have always been a source of medicines. Here you learn to recognise species of pharmaceutical interest, the basis of pharmacognosy.',
  practice_pt = 'Na farmácia comunitária, a procura por fitoterápicos é constante. Reconhecer a identidade botânica das drogas vegetais evita erros de identificação e orienta o aconselhamento seguro de chás, extratos e cólicos.',
  practice_en = 'In the community pharmacy the demand for herbal medicines is constant. Recognising the botanical identity of vegetable drugs prevents identification errors and guides safe advice on teas, extracts and infusions.'
WHERE slug = 'farm-botanica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cinetica, diluições, concentrações e cálculos de dose dependem de física e matemática. São competências usadas todos os dias no farmacêutico.',
  learning_en = 'Kinetics, dilutions, concentrations and dose calculations depend on physics and maths. They are skills used every day in pharmacy practice.',
  practice_pt = 'Calcular diluições de uma solução-mãe, preparar um composto manipulado ou converter unidades são tarefas diárias onde a base física e matemática evita erros que custam caros.',
  practice_en = 'Preparing a dilution, compounding a formulation or converting units are daily tasks where a physics and maths foundation prevents costly errors.'
WHERE slug = 'farm-fisica-matematica';

UPDATE public.guide_disciplines SET
  learning_pt = 'A investigação ensina a ler criticamente a literatura e a conduzir com rigor o trabalho de fim de curso.',
  learning_en = 'Research teaches you to read the literature critically and to conduct your final thesis with rigour.'
WHERE slug = 'farm-investigacao';

UPDATE public.guide_disciplines SET
  learning_pt = 'O português garante a comunicação correta com o doente e a equipa; o inglês abre o acesso à literatura técnico‑científica.',
  learning_en = 'Portuguese ensures clear communication with patients and the team; English unlocks access to technical-scientific literature.'
WHERE slug = 'farm-linguas';

UPDATE public.guide_disciplines SET
  learning_pt = 'A deontologia e a legislação do medicamento definem os limites do exercício legal e seguro da profissão.',
  learning_en = 'Professional ethics and medicines law define the limits of legal, safe practice.'
WHERE slug = 'farm-etica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os fármacos agem sobre biomóléculas e vias metabólicas. A bioquímica é o elo entre a química e a farmacologia.',
  learning_en = 'Drugs act on biomolecules and metabolic pathways. Biochemistry is the link between chemistry and pharmacology.'
WHERE slug = 'farm-bioquimica';

UPDATE public.guide_disciplines SET
  learning_pt = 'A doença é fisiologia alterada. Compreender o funcionamento normal do corpo é pré‑requisito para entender como os fármacos o corrigem.',
  learning_en = 'Disease is altered physiology. Understanding normal body function is a prerequisite for understanding how drugs correct it.'
WHERE slug = 'farm-fisiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A análise quantitativa e qualitativa é a base do controlo de qualidade de tudo o que se entrega ao doente.',
  learning_en = 'Quantitative and qualitative analysis is the basis of the quality control of what you deliver to the patient.',
  practice_pt = 'No laboratório do dia a dia, saber dose o princípio ativo, verificar a pureza e interpretar os ensaios é o coração do controlo de qualidade e da garantia da eficácia.',
  practice_en = 'In the daily laboratory, applying correct analysis to assay the active ingredient, check purity and interpret the tests is the heart of drug quality control and effectiveness.'
WHERE slug = 'farm-quimica-analitica';

UPDATE public.guide_disciplines SET
  learning_pt = 'A físico‑química dos colóides explica porque emulsões e suspensões se comportam assim na formulação.',
  learning_en = 'The physical chemistry of colloids explains why emulsions and suspensions behave as they do in formulation.'
WHERE slug = 'farm-biofisica';

UPDATE public.guide_disciplines SET
  learning_pt = 'O controlo microbiológico garante a segurança do medicamento, sobretudo em estéreis e manipulados.',
  learning_en = 'Microbiological control ensures medicine safety, especially for sterile and compounded products.',
  practice_pt = 'No laboratório industrial e de manipulação, verificar um assas, limites microbianos e esterilidade é o trabalho diário que evita que um produto contaminado chegue ao doente.',
  practice_en = 'In industry and compounding laboratories, checking sterility, microbial limits and cleanrooms is the daily work that stops a contaminated product from reaching the patient.'
WHERE slug = 'farm-microbiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A farmacognosia estuda as drogas de origem natural com atividade farmacológica — a porta de entrada da fitoterapia.',
  learning_en = 'Pharmacognosy studies natural-origin drugs with pharmacological activity: the gateway to phytotherapy.',
  practice_pt = 'Liga a botânica à terapêutica natural, permitido validar produtos fitoterápicos e responder com evidência a quem os procura na farmácia e na indústria.',
  practice_en = 'It links botany to natural therapeutics, letting the pharmacist validate herbal products and answer with evidence the people who seek them in the pharmacy and industry.'
WHERE slug = 'farm-farmacognosia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Ensina as interações entre a alimentação e o medicamento, a suplementação e a atenção nutricional.',
  learning_en = 'Food–drug interactions, supplementation and the nutrition of the body.',
  practice_pt = 'Aconselhar quando tomar o medicamento nas refeições, evitar as interações alimento‑fármaco e orientar a suplementação é um papel diário do farmacêutico.',
  practice_en = 'Advising the patient about when to take medicine relative to meals, avoiding food–drug interactions and guiding supplementation is a daily pharmacist role.'
WHERE slug = 'farm-nutricao';

UPDATE public.guide_disciplines SET
  learning_pt = 'A farmacologia é o coração de qualquer profissional dos fármacos: mecanismo de ação, efeitos, interações e reações adversas.',
  learning_en = 'Pharmacology is the heart of every medicine-related profession: mechanisms of action, effects, interactions and adverse reactions.',
  practice_pt = 'É a disciplina que distingue o farmacêutico: saber se um fármaco interage, como se toma e que reações pode causar é a base do aconselhamento seguro de todos os dias.',
  practice_en = 'It defines the pharmacist: knowing how a drug interacts, how it is taken, and what adverse reactions to watch for is the basis of daily, safe counselling.'
WHERE slug = 'farm-farmacologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A química farmacêutica é a base estratégica da relação estrutura‑efeito do fármaco.',
  learning_en = 'Medicinal chemistry explains the structure–activity relationship of drugs.',
  practice_pt = 'Ao dispensa, ajuda a perceber por que fármacos do mesmo grupo partilham efeitos; e na indústria, onde se desenham novas moléculas e se optimiza a eficácia.',
  practice_en = 'At dispensing it helps you see why drugs in the same group share effects; in industry it is where new molecules are designed and efficacy optimised.'
WHERE slug = 'farm-quimica-farmaceutica';

UPDATE public.guide_disciplines SET
  learning_pt = 'A galénica transforma o princípio ativo em medicamento utilizável, seguro e estável.',
  learning_en = 'Pharmaceutics turns the active principle into a usable, safe and stable medicine.',
  practice_pt = 'Qualquer farmácia manipuladora ou indústria depende destas competências: escolher a forma farmacêutica certa para cada fim e garantir a estabilidade do produto.',
  practice_en = 'Any compounding pharmacy or industry depends on these skills: choosing the right dosage form for each purpose and guaranteeing the product''s stability.'
WHERE slug = 'farm-galencia';

UPDATE public.guide_disciplines SET
  learning_pt = 'O uso clínico e seguro de produtos de origem natural com suporte na evidência. Procura em crescimento.',
  learning_en = 'The clinical use of natural products with safety and evidence. A growing demand.'
WHERE slug = 'farm-fitoterapia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Ensaios físicos, químicos e microbiológicos que garantem que o medicamento cumpre as especificações.',
  learning_en = 'Physical, chemical and microbiological tests ensuring the medicine meets specifications.',
  practice_pt = 'Antes de chegar ao doente, é aqui que se certifica identidade, dose e pureza. É a sentinela de segurança e a saúde no ponto de vista do medicamento.',
  practice_en = 'Before a medicine reaches the patient, it is verified for identity, dose and purity. This is the guardian of medicine safety and effectiveness.'
WHERE slug = 'farm-controle-qualidade';

UPDATE public.guide_disciplines SET
  learning_pt = 'Análise de alimentos e águas com relevância sanitária, complementando a segurança de produtos para a saúde.',
  learning_en = 'Analysis of foods and waters with sanitary relevance, complementing the safety of health products.'
WHERE slug = 'farm-bromatologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Efeitos adversos de substâncias, dose‑resposta e gestão de intoxicações.',
  learning_en = 'Adverse effects of substances, dose–response and the management of poisonings.',
  practice_pt = 'Identificar, reconhecer sinais de intoxicação, interpretar a dose‑resposta e orientar para a urgência podem decidir entre a vida e a morte no aconselhamento e no tratamento.',
  practice_en = 'Recognising signs of poisoning, interpreting dose–response and guiding to emergency care can be the difference between life and death in counselling.'
WHERE slug = 'farm-toxicologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Formulação de cosmético e dermocosméticos, um papel crescente.',
  learning_en = 'Formulation of cosmetics and dermocosmetics, a growing role in the pharmacy.'
WHERE slug = 'farm-cosmetologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Acompanhamento farmacoterápico do paciente para otimizar tratamento com resultado sem dano.',
  learning_en = 'Patient pharmacotherapy follow-up to optimise treatment, with outcomes without harm.',
  practice_pt = 'No atendimento, é onde acontece a consulta farmacêutica: entrevatar o doente, detec interações, garantir que a terapêutica certa cheg a certa à pessoa certa.',
  practice_en = 'Em retenção e farmácia hospitalar, é onde o farmacêutico entrevista o doente, detects interactions and ensures the right therapy reaches the right patient.'
WHERE slug = 'farm-farmacia-clinica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Gestão de medicamentos e dispositivos médicos no ambiente hospitalar.',
  learning_en = 'Management of medicines and devices in the hospital environment.'
WHERE slug = 'farm-farmacia-hospitalar';

UPDATE public.guide_disciplines SET
  learning_pt = 'Prática real em farmácia comunitária, hospitalar ou industrial: o ponto onde a teoria ganha corpo.',
  learning_en = 'Real practice in community, hospital or industrial pharmacy: the point where theory becomes practice.',
  practice_pt = 'É o estágio que abre a porta do mercado de trabalho: aplicar tudo o que se estudou sob supervisão e construir o primeiro portefólio de experiência clínica.',
  practice_en = 'Aplica all you studied under supervision and builds the first clinical portfolio that opens the door to the job market.'
WHERE slug = 'farm-estagio';

UPDATE public.guide_disciplines SET
  learning_pt = 'Investigação para a monografia final do curso.',
  learning_en = 'Final-year research and monograph.'
WHERE slug = 'farm-tcc';

UPDATE public.guide_disciplines SET
  learning_pt = 'Anatomia é o mapa do corpo: toda a semiologia, os procedimentos e a cirurgia assentam em conhecer a estrutura do organismo.',
  learning_en = 'Anatomy is the map of the body: all semiology, procedures and surgery rest on knowing the human structure.',
  practice_pt = 'No hospital, é indispensável para localizar um ponto de punctura, palpar um órgão, ou planear em segurança qualquer intervenção.',
  practice_en = 'In hospital, it is indispensable for locating a puncture site, palpating an organ or planning any procedure safely.'
WHERE slug = 'med-anatomia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Mecanismos moleculares e genéticos da célula, base do da medicina de precisão.',
  learning_en = 'Molecular and genetic mechanisms of the cell, the basis of precision medicine.'
WHERE slug = 'med-biologia-genetica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Tecidos e desenvolvimento humano, a base do estudo de todos os órgãos.',
  learning_en = 'Tissolos e desenvolvimento humano, a morfologia base de todos os órgãos.'
WHERE slug = 'med-histologia-embriologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Física aplicada ao organismo, relevante para a fisiologia e para a imagiologia.',
  learning_en = 'Physics applied to the organism, relevant to physiology and medical imaging.'
WHERE slug = 'med-biofisica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Vias bioquímicas da normalidade e da doença. A base da interpretação dos exames laboratoriais.',
  learning_en = 'Biochemical pathways of normal condition and disease. The basis of interpreting laboratory tests.',
  practice_pt = 'A maioria dos marcadores de laboratório (função renal, hepática, enzimologia, glicose) assenta em bioquímica: quem domina pelas leituras dos valores com rigor.',
  practice_en = 'Most laboratory markers of renal, liver function, enzymes and glucose rest on biochemistry: mastering it lets you read test results with rigour.'
WHERE slug = 'med-bioquimica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Desenho de estudos e leitura crítica da literatura — a chave da medicina baseada na evidência.',
  learning_en = 'Study design and critical appraisal — the key to evidence-based medicine.'
WHERE slug = 'med-metodologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'O português para a comunicação clínica, o inglês para o acesso à literatura científica.',
  learning_en = 'Portuguese for clinical communication, English to access the scientific literature.'
WHERE slug = 'med-linguas';

UPDATE public.guide_disciplines SET
  learning_pt = 'As dimensões sociais e psicológicas da doença e da relação médico‑doente.',
  learning_en = 'The social and psychological dimensions of disease and of the doctor–patient relationship.'
WHERE slug = 'med-sociologia-psicologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Fundamentos éticos, históricos e legais de toda a atividade médica.',
  learning_en = 'Ethical, historical and legal foundations of all medical activity.'
WHERE slug = 'med-bioetica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Como o corpo funciona no normal e como a sua regulação produz a doença.',
  learning_en = 'How the body works in the normal and how its deregulation produces disease.',
  practice_pt = 'Com a maioria das queixas dos doentes há que perceber o funcionamento normal dos órgãos; os desvios que encontra na prática são sempre comparações com o normal.',
  practice_en = 'Most patient complaints require understanding the normal function of organs; the deviations you find in practice are always compared against the normal.'
WHERE slug = 'med-fisiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'O sistema imunitário e a ciência por trás da vacinação, da alergia e das doenças autoimunes.',
  learning_en = 'The immune system and the science behind vaccination, allergy and autoimmunity.'
WHERE slug = 'med-imunologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A farmacocinética e a farmacodinámica: como o fármaco circula e como age.',
  learning_en = 'Pharmacokinetics and pharmacodynamics: how a drug moves and how it acts.',
  practice_pt = 'Na prescrição e nos cuidados, saber como o fármaco se move e age no corpo é o que permite escolher a dose certa, prever interações e orientar o doente quanto aos efeitos e alertas.',
  practice_en = 'When prescribing and caring, knowing how a drug moves and acts lets you choose safe doses, anticipate interactions and guide the patient on effects and cautions.'
WHERE slug = 'med-farmacologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Nutrição, deficiências nutricionais e suporte — a desnutrição é um problema real em Angola.',
  learning_en = 'Nutrition, deficiency states and support — malnutrition is a real problem in Angola.'
WHERE slug = 'med-nutricao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os mecanismos da doença: lesão celular, inflamação, neoplasia. Ponte entre o básico e a clínica.',
  learning_en = 'The mechanisms of disease: cell injury, inflammation, neoplasia. The bridge between the basic and clinical sciences.',
  practice_pt = 'Ajuda a explicar ao doente (e a si) por que a doença se manifesta assim: é a ponte entre a fisiologia e o quadro clínico que vê no hospital.',
  practice_en = 'It helps explain to the patient — and yourself — why a disease presents as it does: the bridge between physiology and the clinical picture you see in hospital.'
WHERE slug = 'med-patologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Anamnese, exame físico e raciocínio por hipóteses.',
  learning_en = 'History taking, physical examination and diagnostic reasoning.',
  practice_pt = 'É a primeira competência que aplica ao chegar à enfermaria: uma boa história e um exame físico rigoroso dirigem o diagnóstico certo e poupam exames desnecessários.',
  practice_en = 'It is the first skill you put to work on the ward: a good history and a rigorous physical exam steer the right diagnosis and avoid unnecessary tests.'
WHERE slug = 'med-semiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Interpretação de radiologia convencional e das técnicas de imagem.',
  learning_en = 'Interpretation of conventional radiology and advanced imaging.'
WHERE slug = 'med-imagiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'O núcleo da clínica do adulto: cardios, pulmon, gastro, nefro, hemato, oncologia e outras.',
  learning_en = 'The core of adult clinical medicine: cardiovascular, pulmonar, gastro, renal, haematology, oncology and more.'
WHERE slug = 'med-medicina-interna';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cirurgia geral e especializada: indicações, contra-ndicações e cuidados cirúrgicos.',
  learning_en = 'General and specialised surgery: indications, contraindICATIONS and perioperative care.',
  practice_pt = 'Nos serviços de urgen é saber quando operar e quando apenas observar, e de que forma preparar o doente perioperatório.',
  practice_en = 'In the emergency room it is about knowing when to operate, when to observe, and how to prepare a patient perioperatively.'
WHERE slug = 'med-cirurgia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Anestesia, reanimação cardiorrespiratória e tratamento da dor.',
  learning_en = 'Anaesthesia, cardiopulmonary resuscitation and pain management.'
WHERE slug = 'med-anestesiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Gestão e economia de serviços e recursos de saúde.',
  learning_en = 'Health services and resources management and economics.'
WHERE slug = 'med-gestao-saude';

UPDATE public.guide_disciplines SET
  learning_pt = 'Saúde da mulher, gravidez, parto e puerpério.',
  learning_en = 'Women''s health, pregnancy, labour and postpartum.',
  practice_pt = 'O acompanhamento da grávida e do parto correto reduz o risco materno e neonatal; uma competência central do médico generalista em Angola.',
  practice_en = 'Proper antenatal and intrapartum care lowers maternal and neonatal risk; a core competency of the generalist in Angola.'
WHERE slug = 'med-ginecologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Saúde da criança, do recém‑nascido e do adolescente.',
  learning_en = 'Child, newborn and adolescent health.',
  practice_pt = 'No hospital, o cuidado da criança exige pesos, escalas e doses específicas: é a especialidade onde a margem de erro terapêutima é menor.',
  practice_en = 'In the hospital, paediatric care demands specific weights, scales and doses — the specialty with the narrowest therapeutic margin.'
WHERE slug = 'med-pediatria';

UPDATE public.guide_disciplines SET
  learning_pt = 'Doenças neurológicas e da saúde mental.',
  learning_en = 'Neurological disorders and mental health.'
WHERE slug = 'med-psiquiatria';

UPDATE public.guide_disciplines SET
  learning_pt = 'Aplicação da medicina à lei, deontologia e deveres profissionais.',
  learning_en = 'Medicine applied to law, medical ethics and professional duties.'
WHERE slug = 'med-medicina-legal';

UPDATE public.guide_disciplines SET
  learning_pt = 'Estágios práticos nas principais áreas clínicas.',
  learning_en = 'Rotating clinical internships in the main areas of medicine.',
  practice_pt = 'É a prática supervisionada de tudo o que aprendeu: o último grande ensaio no doente real antes de exercer a medicina de forma independente.',
  practice_en = 'The supervised application of everything you learned — the final great rehearsal on a real patient before practising medicine independently.'
WHERE slug = 'med-internato';

UPDATE public.guide_disciplines SET
  learning_pt = 'Projeto de investigação exigido para a conclusão do curso.',
  learning_en = 'Final-year research project.'
WHERE slug = 'med-tcc';

UPDATE public.guide_disciplines SET
  learning_pt = 'Biologia celular e genética, base da saúde e da doença.',
  learning_en = 'Cell biology and genetics — the basis of health and disease.'
WHERE slug = 'enf-biologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Psicologia e relação de apoio do enfermeiro para com o doente familiar.',
  learning_en = 'Psychology and the helping relationship of the nurse towards the patient and family.'
WHERE slug = 'enf-psicologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Dimensões sociais e culturais da saúde para a enfermagem comunitária.',
  learning_en = 'Social and cultural dimensions of health recalled by community nursing.'
WHERE slug = 'enf-sociologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Deontologia e legislação da enfermagem.',
  learning_en = 'Nursing ethics and legislation.'
WHERE slug = 'enf-etica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Comunicação profissional e científica na prática.',
  learning_en = 'Professional and scientific communication in the role.'
WHERE slug = 'enf-linguas';

UPDATE public.guide_disciplines SET
  learning_pt = 'Como funciona o corpo no normal e a base da doença.',
  learning_en = 'How the body works in the normal and the basis of disease.'
WHERE slug = 'enf-fisiologia-bioquimica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os fármacos e a sua administração segura.',
  learning_en = 'Drugs and their safe administration.'
WHERE slug = 'enf-farmacologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'O sistema imunitário e os parasitas de interesse em Angola.',
  learning_en = 'The immune system and the parasites of interest in Angola.'
WHERE slug = 'enf-imunologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os processos de doença, a inflamação e a adaptação celular.',
  learning_en = 'Disease processes, inflammation and cell adaptation.'
WHERE slug = 'enf-patologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Nutrição, dietoterapia e avaliação nutricional.',
  learning_en = 'Nutrition, diet therapy and nutritional assessment.'
WHERE slug = 'enf-nutricao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Promoção da saúde, vigilância sanitária e ambiental.',
  learning_en = 'Health promotion, sanitary and environmental surveillance.'
WHERE slug = 'enf-saude-publica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Procedimentos básicos, sinais vitais e os primeiros cuidados seguros.',
  learning_en = 'Basic procedures, vital signs and the first safe care.',
  practice_pt = 'No dia a dia, medir sinais vitais, posicionar e garantir segurança e conforto são os gestos que repete em cada turno, em todos os doentes.',
  practice_en = 'Every day, vital signs, positioning and safe, comfortable care are the gestures you repeat on every shift and every patient.'
WHERE slug = 'enf-fundamentos';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados de enfermagem ao adulto em contexto médico‑cirúrgico.',
  learning_en = 'Nursing care of the adult in medical-surgical settings.',
  practice_pt = 'É onde se aplica a maior parte das técnicas de enfermagem no doente adulto hospitalizado, do adulto estável ao pré e pós-operatório.',
  practice_en = 'This is where most nursing techniques are applied to the hospitalized adult, from the stable patient to pre- and post-operative care.'
WHERE slug = 'enf-saude-adulto';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados à mulher, gravidez, parto e puerpério.',
  learning_en = 'Care for women, pregnancy, labour and the postpartum.',
  practice_pt = 'No parto e no pós-parto, os cuidados materno-obstétricos corretos reduzem a mortalidade materna que é prioritária em Angola.',
  practice_en = 'In labour and the postpartum, correct maternal-obstetric care lowers maternal mortality — a priority in Angola.'
WHERE slug = 'enf-saude-mulher';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados à criança, neonato e adolescente.',
  learning_en = 'Nursing care for the child, newborn and adolescent.'
WHERE slug = 'enf-saude-crianca';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados de enfermagem ao idoso e à pessoa dependente.',
  learning_en = 'Nursing care for the elderly and the dependent person.'
WHERE slug = 'enf-saude-idoso';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados perioperatórios, assepsia e esterilização.',
  learning_en = 'Perioperative care, asepsis and sterilisation.'
WHERE slug = 'enf-cirurgico';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados na comunidade, prevenção e promoção da saúde.',
  learning_en = 'Community care, prevention and health promotion.'
WHERE slug = 'enf-comunitaria';

UPDATE public.guide_disciplines SET
  learning_pt = 'Gestão de serviços, equipas e recursos de enfermagem.',
  learning_en = 'Management of services, teams and nursing resources.'
WHERE slug = 'enf-administracao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Educação para a saúde e formação de doentes e comunidades.',
  learning_en = 'Health education and health promotion of patients and communities.'
WHERE slug = 'enf-pedagogia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Prática supervisionada em serviços de saúde.',
  learning_en = 'Supervised practice in health services.'
WHERE slug = 'enf-estagio';

UPDATE public.guide_disciplines SET
  learning_pt = 'Monografia e trabalho final.',
  learning_en = 'Final monograph and research project.'
WHERE slug = 'enf-tcc';

UPDATE public.guide_disciplines SET
  learning_pt = 'A estrutura humana com foco nos locais de colheita e de amostras.',
  learning_en = 'The human structure focusing on sampling and collection sites.'
WHERE slug = 'acl-anatomia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Biologia molecular e genética, base das técnicas moleculares do diagnóstico laboratório.',
  learning_en = 'Molecular biology and genetics, the basis of molecular diagnostic techniques.'
WHERE slug = 'acl-biologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Tecidos e órgãos, base da citologia e dos anatomo-patológicos.',
  learning_en = 'Tissues and organs, the basis of cytology and histopathology.'
WHERE slug = 'acl-histologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Química geral e orgânica, a base de todas as técnicas analíticas.',
  learning_en = 'General and organic chemistry, the basis of all analytical techniques.'
WHERE slug = 'acl-quimica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Estatística e biofísica aplicadas à validação de métodos e ao controlo de qualidade.',
  learning_en = 'Statistics and biophysics applied to method validation and quality control.'
WHERE slug = 'acl-bioestatistica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Investigação e validação de técnicas laboratoriais.',
  learning_en = 'Research and validation of laboratory techniques.'
WHERE slug = 'acl-investigacao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Ética, legislação e biossegurança do laboratório.',
  learning_en = 'Ethics, legislation and laboratory biosafety.'
WHERE slug = 'acl-etica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Portugues e sociologia da saúde.',
  learning_en = 'Portuguese language and the sociology of health.'
WHERE slug = 'acl-linguas';

UPDATE public.guide_disciplines SET
  learning_pt = 'Como o corpo funciona no normal, para o entendimento dos valores de referência.',
  learning_en = 'How the body works in the normal, for interpreting reference values.'
WHERE slug = 'acl-fisiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Biomarcadores séricos e urinários — o coração da análise clínica.',
  learning_en = 'Serum and urinary biomarkers — the heart of clinical laboratory analysis.',
  practice_pt = 'Grande parte dos exames do dia (glicose, lípidos, função renal e hepática) passa pela bioquímica clínica; dominar é interpretar e validar os resultados com rigor.',
  practice_en = 'Most daily tests — glucose, lipids, renal and liver function — go through clinical biochemistry; mastering it means interpreting and validating results with rigour.'
WHERE slug = 'acl-bioquimica';

UPDATE public.guide_disciplines SET
  learning_pt = 'O hemograma, coagulação e citológico hematológica.',
  learning_en = 'Complete blood count, coagulation and haematological cytology.',
  practice_pt = 'O hemograma é o exame mais pedido: saber identificar anemia, leucopenias e hemoglobinopatias orienta o laboratório e o clínico no diagnóstico.',
  practice_en = 'The blood count is the most requested test: identifying anaemia, leucopenia and haemoglobinopathies guides both laboratory and clinician toward the diagnosis.'
WHERE slug = 'acl-hematologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Identificação das bactérias e antibiograma.',
  learning_en = 'Identification of bacteria and antimicrobial susceptibility.',
  practice_pt = 'O antibiograma correto orienta a antibioterapia dirigida e ajuda no combate à resistência microbiana: o resultado certo muda o desfecho do doente.',
  practice_en = 'A correct antibiogram guides targeted antibiotics and helps fight microbial resistance: the right result changes the patient outcome.'
WHERE slug = 'acl-microbiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Técnicas imunológicas e sorológicas essenciais.',
  learning_en = 'Immunological and serological techniques.'
WHERE slug = 'acl-imunologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Identificação dos parasitas, uma ameaça real e endémica em Angola.',
  learning_en = 'Identification of the parasites, an endemic threat in Angola.',
  practice_pt = 'Com malária e outras parasitoses endémicas em Angola, o laboratório correto é o primeiro passo para o tratamento oportuno.',
  practice_en = 'With malaria and other parasitic diseases endemic in Angola, a correct laboratory is the first step to timely treatment.'
WHERE slug = 'acl-parasitologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Virologia e micologia dos vírus e fungos patogénicos.',
  learning_en = 'Virology and mycology of the common viruses and fungi.'
WHERE slug = 'acl-virus-micologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Imuno‑hematologia e a tipagem e compatibilidade — a segurança transfusional.',
  learning_en = 'Immunohaematology, blood typing and compatibility — the safety of transfusion.',
  practice_pt = 'A segurança transfusional depende da tipagem da qualificação rígida; um erro de compatibilidade pode ser fatal.',
  practice_en = 'Transfusion safety depends on pre-rigorous typing and cross-match; a compatibility error can be fatal.'
WHERE slug = 'acl-hemoterapia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Análise sanitária de alimentos e águas.',
  learning_en = 'Sanitary analysis of foods and waters.'
WHERE slug = 'acl-bromatologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Garantia de qualidade interna e externa e amostragem correta.',
  learning_en = 'Internal and external quality assurance and correct specimen collection.'
WHERE slug = 'acl-controle-qualidade';

UPDATE public.guide_disciplines SET
  learning_pt = 'Toxicologia analítica e monitorização terapêutica dos dados.',
  learning_en = 'Analytical toxicology and therapeutic drug monitoring.'
WHERE slug = 'acl-toxicologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Vigilância sanitária e ambiental, e epidemiológica.',
  learning_en = 'Health and environmental surveillance, and epidemiology.'
WHERE slug = 'acl-epidemiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Gestão de laboratório, qualidade e acreditação.',
  learning_en = 'Laboratory management, quality and accreditation.'
WHERE slug = 'acl-gestao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Emprego em laboratório de análises clínicas reais.',
  learning_en = 'Practice in a clinical laboratory.'
WHERE slug = 'acl-estagio';

UPDATE public.guide_disciplines SET
  learning_pt = 'Trabalho final e diagnóstico de doenças tropicais.',
  learning_en = 'Final thesis and tropical disease diagnostics.'
WHERE slug = 'acl-tcc';

UPDATE public.guide_disciplines SET
  learning_pt = 'Liga a formulação à farmacocinética: por que a forma (comprimido, injetável, creme) muda a libertação e a absorção do fármaco.',
  learning_en = 'Links formulation to pharmacokinetics: why the dosage form changes drug release and absorption.'
WHERE slug = 'farm-biofarmacia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Gestão de farmácia, economia do medicamento e logística: o farmacêutico também é gestor de espaço de saúde.',
  learning_en = 'Pharmacy management, medicines economy and logistics: the pharmacist is also a health manager.'
WHERE slug = 'farm-administracao';

UPDATE public.guide_disciplines SET
  learning_pt = 'A estatística e a informática aplicam‑se a análise de estudos clínicos e na investigação hospitalar.',
  learning_en = 'Statistics and informatics applied to clinical studies and hospital research.'
WHERE slug = 'med-bioestatistica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Distribuição e determinantes das doenças na população.',
  learning_en = 'Sharing of the distribution and determinants of disease in populations.',
  practice_pt = 'Em Angola, o terreno, entender as endo (malária, febre tifóide, cólera) e os seus determinantes permite intervir na prevenção e priorizar o diagnóstico.',
  practice_en = 'Understanding the local endemic diseases and their determinants allows effective prevention and prioritised diagnosis.'
WHERE slug = 'med-epidemiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Os agentes infeciosos e parasitas; a base de múltiplas doenças essenciais em Angola.',
  learning_en = 'Infectious and parasitic agents; the basis of many essential diseases in Angola.'
WHERE slug = 'med-microbiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A foxo-farmacologia aplica a farmacologia à terapêutica de cada orgiana.',
  learning_en = 'Applies pharmacology to the therapeutics of each body system.'
WHERE slug = 'med-farmacologia-clinica';

UPDATE public.guide_disciplines SET
  learning_pt = 'Diagnóstico e reabilitação da incapacidade funcional.',
  learning_en = 'Diagnosis and rehabilitation of functional disability.'
WHERE slug = 'med-medicina-fisica';

UPDATE public.guide_disciplines SET
  learning_pt = 'A estrutura humana que se precisa para a semiologia e para os procedimentos.',
  learning_en = 'The human structure needed for semiology and procedures.'
WHERE slug = 'enf-anatomia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Tecidos e órgãos, a base morfológica do corpo.',
  learning_en = 'Tissues and organs, the morphological basis of the body.'
WHERE slug = 'enf-histologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Micróbios de interesse sanitário e a base do controlo de infecção.',
  learning_en = 'Microbes of sanitary interest and the basis of infection control.'
WHERE slug = 'enf-microbiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'A distribuição das doenças e os métodos de estatística.',
  learning_en = 'The distribution of disease and the statistics methods in health.'
WHERE slug = 'enf-epidemiologia';

UPDATE public.guide_disciplines SET
  learning_pt = 'Investigação e prática baseada na evidência para melhorar os cuidados.',
  learning_en = 'Research and evidence-based practice to improve care.'
WHERE slug = 'enf-investigacao';

UPDATE public.guide_disciplines SET
  learning_pt = 'Cuidados à pessoa com saúde mental e psiquiátrica.',
  learning_en = 'Mental and psychiatric care.'
WHERE slug = 'enf-saude-mental';

UPDATE public.guide_disciplines SET
  learning_pt = 'Análise de urina e de outros fluids orgânicos — um exame rápido essencial da função renal e metabólica.',
  learning_en = 'Urinalysis and the analysis of other body fluids — a fast, essential test of renal and metabolic function.'
WHERE slug = 'acl-urinanalise';
