-- 075: Rollback 074 — remove livros/recursos de Enfermagem (teste 404)
-- DELETE CASCADE via discipline_id remove livros/recursos automaticamente
-- Mas para garantir, limpa explicitamente

DELETE FROM public.guide_books
WHERE discipline_id IN (
  SELECT id FROM public.guide_disciplines 
  WHERE course_id = (SELECT id FROM public.guide_courses WHERE slug = 'enfermagem')
);

DELETE FROM public.guide_resources
WHERE discipline_id IN (
  SELECT id FROM public.guide_disciplines 
  WHERE course_id = (SELECT id FROM public.guide_courses WHERE slug = 'enfermagem')
);

-- Verificação
SELECT 'livros restantes enfermagem=' || count(*) FROM guide_books b
JOIN guide_disciplines d ON d.id=b.discipline_id
JOIN guide_courses c ON c.id=d.course_id WHERE c.slug='enfermagem';

SELECT 'recursos restantes enfermagem=' || count(*) FROM guide_resources r
JOIN guide_disciplines d ON d.id=r.discipline_id
JOIN guide_courses c ON c.id=d.course_id WHERE c.slug='enfermagem';
