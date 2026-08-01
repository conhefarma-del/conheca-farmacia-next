-- 041: Study guides — full bilingual seed + lucide icon names
-- 1) Substitui os emojis de icon_emoji por nomes de ícones Lucide
--    (resolvidos em components/guias/GuideCourseIcon.jsx).
-- 2) Completa o conteúdo editorial (disciplinas/livros/recursos) de todos
--    os cursos para que /guias e /guias/[slug] mostrem conteúdo real.

UPDATE public.guide_courses SET icon_emoji = 'Pill' WHERE slug = 'farmacia';
UPDATE public.guide_courses SET icon_emoji = 'Stethoscope' WHERE slug = 'medicina';
UPDATE public.guide_courses SET icon_emoji = 'HeartHandshake' WHERE slug = 'enfermagem';
UPDATE public.guide_courses SET icon_emoji = 'Microscope' WHERE slug = 'analises-clinicas';

DO $$
DECLARE
  c_id UUID;
  d_id UUID;
BEGIN
  -- ============ FARMÁCIA — Química Farmacêutica ============
  SELECT id INTO c_id FROM public.guide_courses WHERE slug = 'farmacia';
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('quimica-farmaceutica', c_id,
     'Química Farmacêutica', 'Medicinal Chemistry',
     'Desenho, síntese e propriedades físico-químicas dos fármacos, do composto-prototipo ao medicamento final.',
     'Design, synthesis and physicochemical properties of drugs, from the lead compound to the finished medicine.',
     '2º Ano', '2nd Year',
     'Explica por que um fármaco tem determinada estrutura e como pequenas alterações mudam a potência, a seletividade e a toxicidade — essencial para ler bulas e avaliar medicamentos genéricos.',
     'Explains why a drug has a given structure and how small changes alter potency, selectivity and toxicity — essential for reading leaflets and appraising generics.',
     'published', 2)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Foye - Principles of Medicinal Chemistry', 'Foye - Principles of Medicinal Chemistry',
     'Thomas L. Lemke, David A. Williams', '7ª Edição', 2013,
     'https://covers.openlibrary.org/b/isbn/9781609133450-L.jpg',
     'Referência clássica de química farmacêutica: relação estrutura-atividade, mecanismos moleculares e propriedades que determinam a acção dos fármacos.',
     'Classic reference in medicinal chemistry: structure-activity relationships, molecular mechanisms and the properties that determine drug action.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9781609133450"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'OpenStax - Chemistry: Atoms First', 'OpenStax - Chemistry: Atoms First',
     'Livro aberto gratuito de química geral — base para compreender ligações, reacções e propriedades moleculares.',
     'Free open textbook of general chemistry — the basis for understanding bonds, reactions and molecular properties.',
     'https://openstax.org/details/books/chemistry-atoms-first-2e', 'article', 'published', 1);

  -- ============ FARMÁCIA — Farmacoterapia ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('farmacoterapia', c_id,
     'Farmacoterapia', 'Pharmacotherapy',
     'Selecção racional de medicamentos para as doenças mais prevalentes, com base em evidência e no perfil individual do doente.',
     'Rational selection of medicines for the most prevalent diseases, based on evidence and the individual patient profile.',
     '3º Ano', '3rd Year',
     'Traduz a farmacologia em decisões clínicas reais: quando indicar, como ajustar doses, evitar interacções e monitorizar a resposta ao tratamento.',
     'Translates pharmacology into real clinical decisions: when to prescribe, how to adjust doses, avoid interactions and monitor treatment response.',
     'published', 3)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Pharmacotherapy: A Pathophysiologic Approach', 'Pharmacotherapy: A Pathophysiologic Approach',
     'Joseph T. DiPiro, Robert L. Talbert', '11ª Edição', 2020,
     'https://covers.openlibrary.org/b/isbn/9781260116816-L.jpg',
     'O tratado mais usado da farmacoterapia baseada na evidência: cada patologia com objectivos terapêuticos, opções e monitorização.',
     'The most used evidence-based pharmacotherapy text: every disease with therapeutic goals, options and monitoring.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9781260116816"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'NICE - Clinical Guidelines', 'NICE - Clinical Guidelines',
     'Guias clínicos NICE com recomendações baseadas na evidência para as principais áreas terapêuticas.',
     'NICE clinical guidelines with evidence-based recommendations for the main therapeutic areas.',
     'https://www.nice.org.uk/guidance', 'guideline', 'published', 1);

  -- ============ FARMÁCIA — Atenção Farmacêutica ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('atencao-farmaceutica', c_id,
     'Atenção Farmacêutica', 'Pharmaceutical Care',
     'Cuidado centrado no doente: seguimento farmacoterapêutico, reconciliação da medicação e educação para a saúde.',
     'Patient-centred care: pharmacotherapy follow-up, medication reconciliation and health education.',
     '4º Ano', '4th Year',
     'É a prática que distingue o farmacêutico clínico: acompanhar o doente e garantir que a medicação atinge o resultado pretendido sem dano.',
     'The practice that defines the clinical pharmacist: follow up patients and ensure medication achieves the intended outcome without harm.',
     'published', 4)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Pharmaceutical Care Practice', 'Pharmaceutical Care Practice',
     'Robert J. Cipolle, Linda M. Strand', '3ª Edição', 2012,
     'https://covers.openlibrary.org/b/isbn/9780071766388-L.jpg',
     'A obra fundadora da atenção farmacêutica: o processo de cuidado, a avaliação de problemas relacionados com medicamentos e o plano terapêutico.',
     'The founding work of pharmaceutical care: the care process, assessing drug-related problems and the care plan.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780071766388"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'OMS - Publicações sobre Medicamentos', 'WHO - Medicines Publications',
     'Publicações da Organização Mundial da Saúde sobre medicamentos essenciais e uso racional.',
     'World Health Organization publications on essential medicines and rational use.',
     'https://www.who.int/publications', 'guideline', 'published', 1);

  -- ============ MEDICINA — Anatomia ============
  SELECT id INTO c_id FROM public.guide_courses WHERE slug = 'medicina';
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('anatomia', c_id,
     'Anatomia Humana', 'Human Anatomy',
     'Estudo sistemático da estrutura do corpo humano — abordagem sistémica, topográfica e imagiológica.',
     'Systematic study of the structure of the human body — systemic, topographic and imaging approaches.',
     '1º Ano', '1st Year',
     'Base de toda a semiologia e das técnicas de diagnóstico e terapêutica; sem anatomia não há exame físico nem procedimento seguro.',
     'The foundation of all semiology and of diagnostic and therapeutic techniques; without anatomy there is no physical examination or safe procedure.',
     'published', 1)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Atlas de Anatomia Humana', 'Atlas of Human Anatomy',
     'Frank H. Netter', '7ª Edição', 2019,
     'https://covers.openlibrary.org/b/isbn/9780323393225-L.jpg',
     'O atlas mais usado no ensino médico: ilustrações precisas que ligam a anatomia à prática clínica.',
     'The most used atlas in medical education: precise illustrations linking anatomy to clinical practice.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780323393225"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'TeachMeAnatomy', 'TeachMeAnatomy',
     'Plataforma gratuita com notas, diagramas e imagens de anatomia por regiões do corpo.',
     'Free platform with anatomy notes, diagrams and images organised by body region.',
     'https://teachmeanatomy.info', 'article', 'published', 1);

  -- ============ MEDICINA — Fisiologia ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('fisiologia', c_id,
     'Fisiologia Médica', 'Medical Physiology',
     'Mecanismos que mantêm o funcionamento normal dos órgãos e sistemas — da célula ao organismo.',
     'Mechanisms that maintain the normal function of organs and systems — from cell to organism.',
     '1º Ano', '1st Year',
     'A doença é fisiologia desregulada; compreender os mecanismos normais é pré-requisito para a farmacologia e para a prática clínica.',
     'Disease is deregulated physiology; understanding normal mechanisms is a prerequisite for pharmacology and clinical practice.',
     'published', 2)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Guyton & Hall - Tratado de Fisiologia Médica', 'Guyton & Hall - Textbook of Medical Physiology',
     'John E. Hall, Michael E. Hall', '14ª Edição', 2021,
     'https://covers.openlibrary.org/b/isbn/9780323597128-L.jpg',
     'Referência internacional da fisiologia médica: linguagem clara, integração com a clínica e figuras didácticas.',
     'International reference in medical physiology: clear language, clinical integration and didactic figures.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780323597128"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'OpenStax - Anatomy and Physiology', 'OpenStax - Anatomy and Physiology',
     'Manual aberto gratuito de anatomia e fisiologia, com figuras e exercícios de autoavaliação.',
     'Free open textbook of anatomy and physiology with figures and self-assessment exercises.',
     'https://openstax.org/details/books/anatomy-and-physiology-2e', 'article', 'published', 1);

  -- ============ MEDICINA — Semiologia Médica ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('semiologia-medica', c_id,
     'Semiologia Médica', 'Clinical Examination',
     'Técnicas de colheita da história clínica e de exame físico, e a sua interpretação em hipóteses diagnósticas.',
     'Techniques for taking the clinical history and performing the physical examination, interpreted into diagnostic hypotheses.',
     '3º Ano', '3rd Year',
     'Converte o conhecimento teórico em raciocínio clínico — a primeira competência avaliada em qualquer estágio hospitalar.',
     'Turns theoretical knowledge into clinical reasoning — the first competency assessed in any hospital rotation.',
     'published', 3)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Bates - Guia de Exame Clínico', 'Bates - Guide to Physical Examination',
     'Lynn S. Bickley', '13ª Edição', 2021,
     'https://covers.openlibrary.org/b/isbn/9781496398170-L.jpg',
     'Guia completo da anamnese e do exame físico, com exemplos de achados normais e patológicos.',
     'Complete guide to history taking and physical examination, with examples of normal and abnormal findings.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9781496398170"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'Manual MSD - Profissional', 'MSD Manual - Professional',
     'Referência clínica gratuita com quadros de sinais, sintomas e procedimentos de exame.',
     'Free clinical reference with charts of signs, symptoms and examination procedures.',
     'https://www.msdmanuals.com/pt/profissional', 'article', 'published', 1);

  -- ============ ENFERMAGEM — Fundamentos de Enfermagem ============
  SELECT id INTO c_id FROM public.guide_courses WHERE slug = 'enfermagem';
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('fundamentos-enfermagem', c_id,
     'Fundamentos de Enfermagem', 'Fundamentals of Nursing',
     'Princípios básicos dos cuidados: higiene, mobilização, sinais vitais, administração de terapêutica e segurança do doente.',
     'Basic principles of care: hygiene, mobilisation, vital signs, medicine administration and patient safety.',
     '1º Ano', '1st Year',
     'É o primeiro contacto com a prática — os procedimentos aqui ensinados são usados todos os dias na vida profissional.',
     'The first contact with practice — the procedures taught here are used every day in professional life.',
     'published', 1)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Fundamentos de Enfermagem', 'Fundamentals of Nursing',
     'Patricia A. Potter, Anne G. Perry', '10ª Edição', 2023,
     'https://covers.openlibrary.org/b/isbn/9780323677721-L.jpg',
     'O manual de referência dos cuidados básicos: procedimentos passo a passo, segurança e pensamento crítico.',
     'The reference manual of basic care: step-by-step procedures, safety and critical thinking.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780323677721"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'OpenStax - Fundamentals of Nursing', 'OpenStax - Fundamentals of Nursing',
     'Manual aberto gratuito de fundamentos de enfermagem, com procedimentos e casos clínicos.',
     'Free open textbook of nursing fundamentals with procedures and clinical cases.',
     'https://openstax.org/details/books/fundamentals-nursing', 'article', 'published', 1);

  -- ============ ENFERMAGEM — Saúde Materno-Infantil ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('saude-materno-infantil', c_id,
     'Saúde Materno-Infantil', 'Maternal and Child Health',
     'Cuidados de enfermagem à grávida, parturiente, puérpera e recém-nascido, e à criança em idade escolar.',
     'Nursing care for the pregnant woman, labouring woman, postpartum woman, newborn and school-age child.',
     '3º Ano', '3rd Year',
     'A redução da mortalidade materno-infantil depende de cuidados competentes em todos os níveis — hospitalar, comunitário e domiciliário.',
     'Reducing maternal and child mortality depends on competent care at every level — hospital, community and home.',
     'published', 2)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Maternal Child Nursing Care', 'Maternal Child Nursing Care',
     'Shannon E. Perry, Marilyn J. Hockenberry', '6ª Edição', 2017,
     '',
     'Cuidados de enfermagem integrados à mulher, à criança e à família, do pré-natal à adolescência.',
     'Integrated nursing care for women, children and families, from prenatal care to adolescence.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780323549387"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'OMS - Saúde Materna', 'WHO - Maternal Health',
     'Guias e dados da Organização Mundial da Saúde sobre cuidados maternos e neonatais.',
     'World Health Organization guidelines and data on maternal and newborn care.',
     'https://www.who.int/health-topics/maternal-health', 'guideline', 'published', 1),
    (d_id,
     'UNICEF - Saúde da Criança', 'UNICEF - Child Health',
     'Programas e dados da UNICEF sobre imunização, nutrição e sobrevivência infantil.',
     'UNICEF programmes and data on immunisation, nutrition and child survival.',
     'https://www.unicef.org/health', 'article', 'published', 2);

  -- ============ ANÁLISES CLÍNICAS — Bioquímica Clínica ============
  SELECT id INTO c_id FROM public.guide_courses WHERE slug = 'analises-clinicas';
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('bioquimica-clinica', c_id,
     'Bioquímica Clínica', 'Clinical Biochemistry',
     'Análise e interpretação de biomarcadores séricos e urinários no diagnóstico e monitorização da doença.',
     'Analysis and interpretation of serum and urinary biomarkers in the diagnosis and monitoring of disease.',
     '2º Ano', '2nd Year',
     'Grande parte do diagnóstico laboratorial passa pela bioquímica — quem domina os métodos domina a fiabilidade do resultado.',
     'Much of laboratory diagnosis relies on biochemistry — mastering the methods means mastering result reliability.',
     'published', 1)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Tietz - Clinical Chemistry and Molecular Diagnostics', 'Tietz - Clinical Chemistry and Molecular Diagnostics',
     'Nader Rifai', '6ª Edição', 2018,
     'https://covers.openlibrary.org/b/isbn/9780323299680-L.jpg',
     'A referência mundial da bioquímica clínica: métodos, controlo de qualidade e interpretação de resultados.',
     'The world reference in clinical biochemistry: methods, quality control and result interpretation.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9780323299680"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'MedlinePlus - Testes Laboratoriais', 'MedlinePlus - Lab Tests',
     'Enciclopédia gratuita de testes laboratoriais: para que servem, como são feitos e o que significam.',
     'Free encyclopedia of laboratory tests: what they are for, how they are done and what they mean.',
     'https://medlineplus.gov/lab-tests/', 'article', 'published', 1);

  -- ============ ANÁLISES CLÍNICAS — Microbiologia Clínica ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('microbiologia-clinica', c_id,
     'Microbiologia Clínica', 'Clinical Microbiology',
     'Identificação de agentes infecciosos — bactérias, fungos e vírus — e testes de sensibilidade aos antimicrobianos.',
     'Identification of infectious agents — bacteria, fungi and viruses — and antimicrobial susceptibility testing.',
     '2º Ano', '2nd Year',
     'A antibioterapia dirigida depende de um diagnóstico microbiológico rápido e fiável — essencial contra a resistência aos antimicrobianos.',
     'Targeted antibiotic therapy depends on rapid, reliable microbiological diagnosis — essential against antimicrobial resistance.',
     'published', 2)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Manual of Clinical Microbiology', 'Manual of Clinical Microbiology',
     'Karen C. Carroll, Michael A. Pfaller', '12ª Edição', 2019,
     'https://covers.openlibrary.org/b/isbn/9781683672807-L.jpg',
     'O manual de referência da microbiologia clínica: desde a colheita à identificação e ao antibiograma.',
     'The reference manual of clinical microbiology: from specimen collection to identification and susceptibility testing.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9781683672807"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'EUCAST - Pontos de Corte', 'EUCAST - Breakpoints',
     'Tabelas oficiais de pontos de corte e metodologias de testes de sensibilidade aos antimicrobianos.',
     'Official breakpoint tables and methodologies for antimicrobial susceptibility testing.',
     'https://www.eucast.org', 'guideline', 'published', 1);

  -- ============ ANÁLISES CLÍNICAS — Hematologia Laboratorial ============
  INSERT INTO public.guide_disciplines
    (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES
    ('hematologia-laboratorial', c_id,
     'Hematologia Laboratorial', 'Laboratory Hematology',
     'Hemograma, coagulação e citologia: métodos e interpretação das alterações hematológicas.',
     'Complete blood count, coagulation and cytology: methods and interpretation of haematological changes.',
     '3º Ano', '3rd Year',
     'O hemograma é o exame mais pedido em qualquer serviço — a qualidade do resultado depende da técnica e do controlo de qualidade.',
     'The complete blood count is the most requested test in any service — result quality depends on technique and quality control.',
     'published', 3)
    RETURNING id INTO d_id;
  INSERT INTO public.guide_books
    (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES
    (d_id,
     'Williams - Hematologia', 'Williams - Hematology',
     'Kenneth Kaushansky, Marshall A. Lichtman', '9ª Edição', 2015,
     'https://covers.openlibrary.org/b/isbn/9781259641972-L.jpg',
     'Tratado de referência da hematologia clínica e laboratorial, da fisiopatologia à interpretação analítica.',
     'Reference text in clinical and laboratory haematology, from pathophysiology to analytical interpretation.',
     '[{"label_pt":"Ver na Amazon","label_en":"View on Amazon","url":"https://www.amazon.com/s?k=9781259641972"}]',
     'published', 1);
  INSERT INTO public.guide_resources
    (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES
    (d_id,
     'American Society of Hematology', 'American Society of Hematology',
     'Guias e educação clínica da sociedade internacional de referência em hematologia.',
     'Guidelines and clinical education from the international reference society in haematology.',
     'https://www.hematology.org', 'article', 'published', 1);
END $$;
