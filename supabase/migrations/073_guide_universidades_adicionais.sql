-- 073: Study guides — universidades adicionais
-- Adiciona UAN, Universidade Metodista, ISKA, ISPEKA aos cursos respetivos
-- Baseado na informação fornecida pelo utilizador

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

  -- UAN (Universidade Agostinho Neto) — Pública
  -- Medicina
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_medicina, 'UAN - Universidade Agostinho Neto', 'Luanda', true,
     'https://www.uan.ao', 'https://www.uan.ao/detalhes/curso/medicina', 'published', 3);

  -- Análises Clínicas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_analises, 'UAN - Universidade Agostinho Neto', 'Luanda', true,
     'https://www.uan.ao', 'https://www.uan.ao/detalhes/curso/analises-clinicas-e-saude-publica', 'published', 3);

  -- Enfermagem
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'UAN - Universidade Agostinho Neto', 'Luanda', true,
     'https://www.uan.ao', 'https://www.uan.ao/detalhes/curso/enfermagem', 'published', 5);

  -- Ciências Farmacêuticas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_farmacia, 'UAN - Universidade Agostinho Neto', 'Luanda', true,
     'https://www.uan.ao', 'https://www.uan.ao/detalhes/curso/ciencias-farmaceuticas', 'published', 4);

  -- Universidade Metodista de Angola
  -- Enfermagem
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'Universidade Metodista de Angola', 'Luanda', false,
     'https://universidademetodista.ao', 'https://universidademetodista.ao/storage/cursos/plano-curricular/TiDaw0KO0IZdoueld2s9LjZRyR134ltetk9GIekH.pdf', 'published', 6);

  -- Análises Clínicas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_analises, 'Universidade Metodista de Angola', 'Luanda', false,
     'https://universidademetodista.ao', 'https://universidademetodista.ao/storage/cursos/plano-curricular/MYTEt81Ovd54yQRuRiX1shOPOymbziaTS7eRK2hd.pdf', 'published', 4);

  -- ISKA (Instituto Superior Politécnico de Kangonjo)
  -- Análises Clínicas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_analises, 'ISKA - Instituto Superior Politécnico de Kangonjo', 'Kangonjo', false,
     'https://iska.ao', '', 'published', 5);

  -- Ciências Farmacêuticas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_farmacia, 'ISKA - Instituto Superior Politécnico de Kangonjo', 'Kangonjo', false,
     'https://iska.ao', '', 'published', 5);

  -- Enfermagem
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'ISKA - Instituto Superior Politécnico de Kangonjo', 'Kangonjo', false,
     'https://iska.ao', '', 'published', 7);

  -- ISPEKA (Instituto Superior Politécnico Kalandula de Angola)
  -- Ciências Farmacêuticas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_farmacia, 'ISPEKA - Instituto Superior Politécnico Kalandula de Angola', 'Kalandula', false,
     'https://ispeka.ao', '', 'published', 6);

  -- Enfermagem
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_enfermagem, 'ISPEKA - Instituto Superior Politécnico Kalandula de Angola', 'Kalandula', false,
     'https://ispeka.ao', '', 'published', 8);

  -- Análises Clínicas
  INSERT INTO public.guide_universities (course_id, name, city, is_public, website_url, course_url, status, sort_order) VALUES
    (v_analises, 'ISPEKA - Instituto Superior Politécnico Kalandula de Angola', 'Kalandula', false,
     'https://ispeka.ao', '', 'published', 6);
END $$;