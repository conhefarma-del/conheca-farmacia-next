-- ============================================================================
-- 143 — Seed de artigos científicos reais (5, um por categoria)
-- ----------------------------------------------------------------------------
-- Validação editorial: 2026-08-11 (utilizador aceitou os 5 candidatos).
-- Fontes verificadas nas páginas PubMed/PMC (metadados, abstracts e afiliações).
-- Licenças de acesso livre documentadas por artigo (CC BY / CC BY-NC / CC BY-NC-ND).
-- Conteúdo PT: resumo estruturado fiel ao abstract original (Objetivo/Métodos/
-- Resultados/Conclusão) + ligação à fonte. Requer a migração 142 (categorias).
-- ============================================================================

WITH seed(slug, title, abstract, keywords, category_slug, doi, authors, content, references_arr, read_time, featured, published_at) AS (
  VALUES
    -- ===== 1. FARMACOLOGIA CLÍNICA =========================================
    -- Cattaneo D, Gervasoni C, Corona A. Antibiotics (Basel). 2022;11(10):1410.
    -- DOI 10.3390/antibiotics11101410 · PMID 36290068 · PMCID PMC9598487 · CC BY 4.0
    (
      'interacoes-farmacocineticas-antibioticos'::text,
      'Interações fármaco-fármaco farmacocinéticas com antibióticos: uma revisão narrativa'::text,
      'Os doentes em unidades de cuidados intensivos (UCI) apresentam um risco elevado de interações fármaco-fármaco potenciais (pDDIs) devido à complexidade dos seus esquemas terapêuticos. Estas interações podem ser de natureza farmacocinética ou farmacodinâmica e ter consequências clínicas relevantes, desde falência terapêutica a eventos adversos relacionados com fármacos. Esta revisão narrativa analisa as pDDIs de natureza farmacocinética que envolvem antibióticos em doentes adultos em UCI. A maioria das interações identificadas diz respeito a antibióticos mais antigos; as moléculas mais recentes apresentam baixo potencial de interação, com exceção da oritavancina (potencial causadora) e da eravaciclina (vítima de indutores fortes do CYP3A).'::text,
      ARRAY['antibióticos','doentes críticos','interações fármaco-fármaco','farmacocinética']::text[],
      'farmacologia-clinica'::text,
      '10.3390/antibiotics11101410'::text,
      '[
        {"name": "Dario Cattaneo", "institution": "Unidade de Farmacologia Clínica, Hospital Universitário ASST Fatebenefratelli Sacco, Milão, Itália", "role": "Autor correspondente", "avatar": "DC", "avatarBg": "#006171", "corresponding": true},
        {"name": "Cristina Gervasoni", "institution": "Departamento de Doenças Infecciosas, Hospital Universitário ASST Fatebenefratelli Sacco, Milão, Itália", "role": "Investigadora", "avatar": "CG", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Alberto Corona", "institution": "Departamento de Urgência, Anestesiologia e Cuidados Intensivos, Hospitais de Esine e Edolo, ASST Valcamonica, Brescia, Itália", "role": "Investigador", "avatar": "AC", "avatarBg": "#002a32", "corresponding": false}
      ]'::jsonb,
      E'## Resumo\n\nOs doentes em unidades de cuidados intensivos (UCI) apresentam um risco elevado de interações fármaco-fármaco potenciais (pDDIs) devido à complexidade dos seus esquemas terapêuticos. Estas interações podem ser de natureza farmacocinética ou farmacodinâmica e ter consequências clínicas relevantes, desde falência terapêutica a eventos adversos relacionados com fármacos.\n\n## Objetivo\n\nRever as pDDIs de natureza farmacocinética que envolvem antibióticos em doentes adultos em UCI, identificando antibióticos como vítimas ou como causadores de interação.\n\n## Métodos\n\nPesquisa na MEDLINE/PubMed de artigos publicados entre janeiro de 2000 e junho de 2022, cruzando os termos drug-drug interactions com pharmacokinetics, antibiotics e ICU ou critically-ill patients, complementada por estudos identificados nas listas de referências dos artigos recuperados.\n\n## Resultados\n\nForam identificadas pDDIs farmacocinéticas importantes com antibióticos, quer como vítimas quer como causadoras, embora nem sempre especificamente em contexto de UCI. A maioria envolve antibióticos mais antigos; as moléculas mais recentes apresentam baixo potencial de interação, com duas exceções: a oritavancina (potencial causadora de interação) e a eravaciclina (vítima de indutores fortes do CYP3A).\n\n## Conclusão\n\nEsquemas terapêuticos personalizados, apoiados em verificadores de interações fármaco-fármaco disponíveis na web e eventualmente combinados com monitorização terapêutica de fármacos, têm potencial para melhorar a resposta dos doentes em UCI à antibioterapia.\n\n---\n\n**Ligação à fonte:** artigo original de acesso livre (licença CC BY 4.0) — [PubMed 36290068](https://pubmed.ncbi.nlm.nih.gov/36290068/) · [PMC9598487](https://pmc.ncbi.nlm.nih.gov/articles/PMC9598487/)'::text,
      ARRAY['Cattaneo D, Gervasoni C, Corona A. The issue of pharmacokinetic-driven drug–drug interactions of antibiotics: a narrative review. Antibiotics (Basel). 2022;11(10):1410. doi:10.3390/antibiotics11101410']::text[],
      15::int,
      false::boolean,
      '2022-10-13'::date
    ),
    -- ===== 2. SAÚDE PÚBLICA ================================================
    -- Burson RC, Buttenheim AM, Armstrong A, Feemster KA. Hum Vaccin Immunother.
    -- 2016;12(12):3146-3159. DOI 10.1080/21645515.2016.1215393 · PMID 27715409
    -- PMCID PMC5215426 · acesso livre via PMC
    (
      'farmacias-comunitarias-vacinacao-adultos'::text,
      'Farmácias comunitárias como locais de vacinação de adultos: uma revisão sistemática'::text,
      'As mortes evitáveis por vacinação entre adultos continuam a ser uma preocupação major de saúde pública, apesar dos esforços para aumentar as taxas de vacinação. Esta revisão sistemática avalia a viabilidade, a aceitabilidade e a eficácia das farmácias comunitárias como locais de vacinação de adultos. Foram identificados 47 artigos a partir de 5 bases de dados eletrónicas. Os serviços de imunização em farmácia comunitária são amplamente aceites por doentes e profissionais, melhoram o acesso e aumentam as taxas de vacinação, embora barreiras políticas e organizacionais limitem a sua viabilidade e eficácia.'::text,
      ARRAY['farmácia comunitária','imunização','vacinação de adultos','política de saúde']::text[],
      'saude-publica'::text,
      '10.1080/21645515.2016.1215393'::text,
      '[
        {"name": "Randall C. Burson", "institution": "Departamento de Anestesiologia e Cuidados Críticos, Perelman School of Medicine, Universidade da Pensilvânia, Filadélfia, EUA", "role": "Autor correspondente", "avatar": "RB", "avatarBg": "#006171", "corresponding": true},
        {"name": "Alison M. Buttenheim", "institution": "Departamento de Saúde Familiar e Comunitária, Escola de Enfermagem, Universidade da Pensilvânia, EUA", "role": "Investigadora", "avatar": "AB", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Allison Armstrong", "institution": "Escola de Enfermagem, Universidade da Pensilvânia, EUA", "role": "Investigadora", "avatar": "AA", "avatarBg": "#ff6c23", "corresponding": false},
        {"name": "Kristen A. Feemster", "institution": "Divisão de Doenças Infecciosas, Hospital Pediátrico de Filadélfia, EUA", "role": "Investigadora", "avatar": "KF", "avatarBg": "#002a32", "corresponding": false}
      ]'::jsonb,
      E'## Resumo\n\nNos Estados Unidos, cerca de 50.000 mortes evitáveis por vacinação ocorrem anualmente entre adultos, e as taxas de vacinação mantêm-se abaixo das metas recomendadas. Esta revisão sistemática avalia as farmácias comunitárias como locais alternativos de prestação de vacinação a adultos.\n\n## Objetivo\n\nSintetizar a evidência sobre a viabilidade, a aceitabilidade e a eficácia dos serviços de imunização em farmácia comunitária (PBIS) enquanto alternativa de prestação de vacinação a adultos.\n\n## Métodos\n\nPesquisa em 5 bases de dados eletrónicas (PubMed, EMBASE, Scopus, Cochrane e LILACS) por estudos publicados até junho de 2016. Foram identificados 47 artigos relevantes.\n\n## Resultados\n\nOs serviços de imunização em farmácia foram facilitados por alterações regulamentares e programas de formação que permitem aos farmacêuticos administrar vacinas diretamente. Estes serviços são amplamente aceites por doentes e por profissionais das farmácias e são capazes de melhorar o acesso e aumentar as taxas de vacinação. Contudo, barreiras políticas e organizacionais limitam a sua viabilidade e eficácia.\n\n## Conclusão\n\nA evidência recolhida informa políticas e esforços organizacionais que promovam a eficácia e a sustentabilidade dos serviços de imunização em farmácia comunitária.\n\n---\n\n**Ligação à fonte:** artigo de acesso livre via PMC — [PubMed 27715409](https://pubmed.ncbi.nlm.nih.gov/27715409/) · [PMC5215426](https://pmc.ncbi.nlm.nih.gov/articles/PMC5215426/)'::text,
      ARRAY['Burson RC, Buttenheim AM, Armstrong A, Feemster KA. Community pharmacies as sites of adult vaccination: a systematic review. Hum Vaccin Immunother. 2016;12(12):3146-3159. doi:10.1080/21645515.2016.1215393']::text[],
      15::int,
      false::boolean,
      '2016-08-15'::date
    ),
    -- ===== 3. FARMACOVIGILÂNCIA ============================================
    -- García-Abeijon P, Costa C, Taracido M, Herdeiro MT, Torre C, Figueiras A.
    -- Drug Saf. 2023;46(7):625-636. DOI 10.1007/s40264-023-01302-7 · PMID 37277678
    -- PMCID PMC10279571 · CC BY-NC 4.0 · PROSPERO CRD42021227944
    (
      'subnotificacao-reacoes-adversas-medicamentos'::text,
      'Fatores associados à subnotificação de reações adversas a medicamentos pelos profissionais de saúde: uma atualização da revisão sistemática'::text,
      'A subnotificação é a principal limitação do sistema de notificação espontânea de reações adversas a medicamentos (RAM). Esta atualização da revisão sistemática de 2009 avaliou os fatores sociodemográficos, de conhecimento e de atitudes associados à subnotificação de RAM pelos profissionais de saúde, com base em 65 artigos publicados entre 2007 e 2021. As características sociodemográficas não influenciaram a subnotificação, mas o conhecimento e as atitudes continuam a ter um efeito significativo: ignorância (86,2%), letargia (84,6%), complacência (46,2%), difidência (44,6%), insegurança (33,8%) e ausência de feedback (9,2%).'::text,
      ARRAY['farmacovigilância','reações adversas a medicamentos','subnotificação','notificação espontânea','profissionais de saúde']::text[],
      'farmacovigilancia'::text,
      '10.1007/s40264-023-01302-7'::text,
      '[
        {"name": "Patricia García-Abeijon", "institution": "Departamento de Saúde Pública, Universidade de Santiago de Compostela, Espanha", "role": "Investigadora", "avatar": "PG", "avatarBg": "#e85d18", "corresponding": false},
        {"name": "Catarina Costa", "institution": "Faculdade de Farmácia, Universidade de Lisboa, Portugal", "role": "Investigadora", "avatar": "CC", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Margarita Taracido", "institution": "Departamento de Saúde Pública, Universidade de Santiago de Compostela, Espanha", "role": "Investigadora", "avatar": "MT", "avatarBg": "#006171", "corresponding": false},
        {"name": "Maria Teresa Herdeiro", "institution": "Instituto de Biomedicina (iBiMED), Universidade de Aveiro, Portugal", "role": "Investigadora", "avatar": "MH", "avatarBg": "#002a32", "corresponding": false},
        {"name": "Carla Torre", "institution": "Faculdade de Farmácia, Universidade de Lisboa, Portugal", "role": "Investigadora", "avatar": "CT", "avatarBg": "#ff6c23", "corresponding": false},
        {"name": "Adolfo Figueiras", "institution": "Departamento de Saúde Pública, Universidade de Santiago de Compostela, Espanha", "role": "Autor correspondente", "avatar": "AF", "avatarBg": "#0a844f", "corresponding": true}
      ]'::jsonb,
      E'## Resumo\n\nA subnotificação é a principal limitação do sistema de notificação espontânea de reações adversas a medicamentos (RAM). Uma revisão sistemática de 2009 mostrou que o conhecimento e as atitudes dos profissionais de saúde estavam fortemente associados à subnotificação. Esta revisão atualiza esses dados.\n\n## Objetivo\n\nDeterminar os fatores — sociodemográficos, de conhecimento e de atitudes — associados à subnotificação de RAM pelos profissionais de saúde.\n\n## Métodos\n\nPesquisa nas bases MEDLINE e EMBASE por estudos publicados entre 2007 e 2021, em inglês, francês, português ou espanhol, envolvendo profissionais de saúde, que avaliassem fatores associados à subnotificação de RAM por notificação espontânea. Foram incluídos 65 artigos. Registo PROSPERO: CRD42021227944.\n\n## Resultados\n\nAs características sociodemográficas dos profissionais não influenciaram a subnotificação, mas o conhecimento e as atitudes continuam a ter um efeito significativo:\n\n1. **Ignorância** (só as RAM graves devem ser notificadas) — 86,2%;\n2. **Letargia** (adiamento, falta de interesse e outras desculpas) — 84,6%;\n3. **Complacência** (crença de que só fármacos bem tolerados estão no mercado) — 46,2%;\n4. **Difidência** (receio de parecer ridículo por notificar RAM meramente suspeitas) — 44,6%;\n5. **Insegurança** (é quase impossível determinar se um fármaco é responsável por uma reação) — 33,8%;\n6. **Ausência de feedback** — 9,2%.\n\nA não obrigatoriedade da notificação e a confidencialidade emergem como novos motivos de subnotificação.\n\n## Conclusão\n\nAs atitudes face à notificação de reações adversas continuam a ser os principais determinantes da subnotificação. Embora sejam fatores potencialmente modificáveis por intervenções educativas, observaram-se mudanças mínimas desde 2009.\n\n---\n\n**Ligação à fonte:** artigo de acesso livre (licença CC BY-NC 4.0, sem uso comercial) — [PubMed 37277678](https://pubmed.ncbi.nlm.nih.gov/37277678/) · [PMC10279571](https://pmc.ncbi.nlm.nih.gov/articles/PMC10279571/)'::text,
      ARRAY[
        'García-Abeijon P, Costa C, Taracido M, Herdeiro MT, Torre C, Figueiras A. Factors associated with underreporting of adverse drug reactions by health care professionals: a systematic review update. Drug Saf. 2023;46(7):625-636. doi:10.1007/s40264-023-01302-7',
        'Lopez-Gonzalez E, Herdeiro MT, Figueiras A. Determinants of under-reporting of adverse drug reactions: a systematic review. Drug Saf. 2009;32(1):19-31.'
      ]::text[],
      20::int,
      false::boolean,
      '2023-06-06'::date
    ),
    -- ===== 4. EDUCAÇÃO FARMACÊUTICA ========================================
    -- Foucault-Fruchard L, et al. BMC Med Educ. 2024;24:1435.
    -- DOI 10.1186/s12909-024-06338-6 · PMID 39696320 · PMCID PMC11654339
    -- CC BY-NC-ND 4.0 · PROSPERO CRD42022371915
    (
      'simulacao-comunicacao-farmacia'::text,
      'O impacto da aprendizagem baseada em simulação no desenvolvimento das competências de comunicação de estudantes de farmácia e farmacêuticos: uma revisão sistemática'::text,
      'A comunicação eficaz nos cuidados de saúde é crucial para a qualidade dos cuidados. Esta revisão sistemática examinou o impacto da educação baseada em simulação nas competências de comunicação de estudantes de farmácia e farmacêuticos, com base em 20 artigos e 3337 participantes. A formação por simulação melhora significativamente a perceção, a confiança e as competências de comunicação, frequentemente com recurso a doentes simulados. A ausência de instrumentos de avaliação normalizados limita a validade da evidência.'::text,
      ARRAY['farmácia clínica','comunicação','simulação','estudantes de farmácia','formação']::text[],
      'educacao-farmaceutica'::text,
      '10.1186/s12909-024-06338-6'::text,
      '[
        {"name": "Laura Foucault-Fruchard", "institution": "Serviço de Farmácia, CHU Tours, França", "role": "Autor correspondente", "avatar": "LF", "avatarBg": "#006171", "corresponding": true},
        {"name": "Vanessa Michelet-Barbotin", "institution": "CHU Rennes, França", "role": "Investigadora", "avatar": "VM", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Alison Leichnam", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigadora", "avatar": "AL", "avatarBg": "#002a32", "corresponding": false},
        {"name": "Martine Tching-Sin", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigadora", "avatar": "MT", "avatarBg": "#ff6c23", "corresponding": false},
        {"name": "Pierre Nizet", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigador", "avatar": "PN", "avatarBg": "#6b7280", "corresponding": false},
        {"name": "Sophie Tollec", "institution": "CHU Orléans, França", "role": "Investigadora", "avatar": "ST", "avatarBg": "#e85d18", "corresponding": false},
        {"name": "Fabien Nativel", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigador", "avatar": "FN", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Elise Vene", "institution": "CHU Rennes, França", "role": "Investigadora", "avatar": "EV", "avatarBg": "#006171", "corresponding": false},
        {"name": "Clémentine Fronteau", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigadora", "avatar": "CF", "avatarBg": "#002a32", "corresponding": false},
        {"name": "Jean-François Huon", "institution": "Universidade de Nantes / CHU Nantes, França", "role": "Investigador", "avatar": "JH", "avatarBg": "#ff6c23", "corresponding": false}
      ]'::jsonb,
      E'## Resumo\n\nA comunicação eficaz nos cuidados de saúde — entre profissionais e entre profissionais e doentes — é crucial para a prestação de cuidados de qualidade. Embora a simulação transfira bem as competências técnicas para a prática clínica, o seu impacto na comunicação, particularmente na farmácia, está menos documentado.\n\n## Objetivo\n\nExaminar o impacto da educação baseada em simulação nas competências de comunicação de estudantes de farmácia e farmacêuticos, identificando os tipos de simulação usados, os resultados obtidos e a eficácia no reforço das competências, da perceção e da confiança.\n\n## Métodos\n\nPesquisas em MEDLINE, LISSA, EMBASE e PsycINFO por artigos sobre formação em comunicação por simulação para estudantes e farmacêuticos, desde o início até 31 de agosto de 2022. Três investigadores avaliaram de forma independente cada título e resumo; a qualidade dos estudos foi avaliada com o Mixed Methods Appraisal Tool (MMAT). Registo PROSPERO: CRD42022371915.\n\n## Resultados\n\nForam incluídos 20 artigos, num total de 3337 participantes, publicados maioritariamente nos Estados Unidos na última década; apenas um estudo se focou em farmacêuticos comunitários. Os desenhos quase-experimentais predominaram, com frequente recurso à autoavaliação dos participantes com questionários não validados. A aprendizagem por simulação — frequentemente com doentes simulados e em contextos interprofissionais, com doentes e famílias — melhorou as competências de comunicação, a perceção da sua importância e a confiança.\n\n## Conclusão\n\nApesar da heterogeneidade dos estudos, a formação baseada em simulação melhora significativamente a perceção, a confiança e as competências de comunicação. O desenvolvimento de orientações claras e de instrumentos de avaliação normalizados melhoraria substancialmente a validade e a fiabilidade da investigação futura.\n\n---\n\n**Ligação à fonte:** artigo de acesso livre (licença CC BY-NC-ND 4.0, sem uso comercial e sem derivados) — [PubMed 39696320](https://pubmed.ncbi.nlm.nih.gov/39696320/) · [PMC11654339](https://pmc.ncbi.nlm.nih.gov/articles/PMC11654339/)'::text,
      ARRAY['Foucault-Fruchard L, Michelet-Barbotin V, Leichnam A, et al. The impact of using simulation-based learning to further develop communication skills of pharmacy students and pharmacists: a systematic review. BMC Med Educ. 2024;24:1435. doi:10.1186/s12909-024-06338-6']::text[],
      18::int,
      false::boolean,
      '2024-12-18'::date
    ),
    -- ===== 5. FITOTERAPIA ==================================================
    -- Ge B, Zhang Z, Zuo Z. Evid Based Complement Alternat Med. 2014;2014:957362.
    -- DOI 10.1155/2014/957362 · PMID 24790635 · PMCID PMC3976951 · CC BY
    (
      'interacoes-ervas-varfarina'::text,
      'Atualizações sobre as interações ervas–varfarina com evidência clínica'::text,
      'O uso crescente e inadvertido de plantas medicinais torna as interações ervas–fármacos um foco de investigação. A utilização concomitante de varfarina com plantas medicinais suscita preocupações de segurança devido à estreita janela terapêutica da varfarina. Entre 38 plantas avaliadas, Cannabis, camomila, arando, alho, ginkgo, toranja, Lycium, trevo-vermelho e hipericão (erva-de-são-joão) foram classificadas com interação de gravidade major com a varfarina.'::text,
      ARRAY['fitoterapia','plantas medicinais','interações ervas–fármacos','varfarina','anticoagulantes']::text[],
      'fitoterapia'::text,
      '10.1155/2014/957362'::text,
      '[
        {"name": "Beikang Ge", "institution": "Escola de Farmácia, Faculdade de Medicina, Universidade Chinesa de Hong Kong", "role": "Investigador", "avatar": "BG", "avatarBg": "#006171", "corresponding": false},
        {"name": "Zhen Zhang", "institution": "Escola de Farmácia, Faculdade de Medicina, Universidade Chinesa de Hong Kong", "role": "Investigador", "avatar": "ZZ", "avatarBg": "#0a844f", "corresponding": false},
        {"name": "Zhong Zuo", "institution": "Escola de Farmácia, Faculdade de Medicina, Universidade Chinesa de Hong Kong", "role": "Autor correspondente", "avatar": "ZU", "avatarBg": "#002a32", "corresponding": true}
      ]'::jsonb,
      E'## Resumo\n\nO uso crescente e inadvertido de plantas medicinais torna as interações ervas–fármacos um foco de investigação. A utilização concomitante de varfarina — um anticoagulante oral de elevada eficácia — com plantas medicinais suscita preocupações de segurança devido à estreita janela terapêutica da varfarina.\n\n## Objetivo\n\nApresentar uma atualização dos achados clínicos sobre as interações ervas–varfarina, destacando os resultados clínicos, a gravidade das interações documentadas e a qualidade da evidência clínica.\n\n## Métodos\n\nRevisão da literatura clínica publicada sobre interações entre 38 plantas medicinais e a varfarina, com classificação da gravidade da interação e da probabilidade de interação com base na qualidade da evidência.\n\n## Resultados\n\nEntre as 38 plantas avaliadas, Cannabis, camomila, arando (cranberry), alho, ginkgo, toranja (grapefruit), Lycium, trevo-vermelho e hipericão (erva-de-são-joão) foram avaliadas como tendo interação de gravidade major com a varfarina. Quanto à probabilidade de interação com base na evidência: 4 plantas altamente prováveis (nível I), 3 prováveis (nível II), 10 possíveis (nível III) e 21 duvidosas (nível IV). O mecanismo geral das interações ervas–varfarina permanece em grande parte desconhecido, embora se estimem fatores farmacocinéticos e farmacodinâmicos a influenciar o efeito da varfarina.\n\n## Conclusão\n\nAs interações ervas–varfarina, em especial os efeitos clínicos das plantas na terapêutica com varfarina, devem ser investigadas em estudos multicêntricos com amostras maiores.\n\n---\n\n**Ligação à fonte:** artigo de acesso livre (licença CC BY) — [PubMed 24790635](https://pubmed.ncbi.nlm.nih.gov/24790635/) · [PMC3976951](https://pmc.ncbi.nlm.nih.gov/articles/PMC3976951/)'::text,
      ARRAY['Ge B, Zhang Z, Zuo Z. Updates on the clinical evidenced herb-warfarin interactions. Evid Based Complement Alternat Med. 2014;2014:957362. doi:10.1155/2014/957362']::text[],
      20::int,
      false::boolean,
      '2014-03-18'::date
    )
)
INSERT INTO public.scientific_articles
  (slug, title, abstract, keywords, category_id, doi, authors, content, references_arr, read_time, status, featured, published_at)
SELECT
  v.slug,
  v.title,
  v.abstract,
  v.keywords,
  c.id,
  v.doi,
  v.authors,
  v.content,
  v.references_arr,
  v.read_time,
  'published',
  v.featured,
  v.published_at::timestamptz
FROM seed v
JOIN public.scientific_categories c ON c.slug = v.category_slug
ON CONFLICT (slug) DO NOTHING;
