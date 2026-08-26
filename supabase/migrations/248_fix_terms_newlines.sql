-- 248: Fix literal \n in terms_sections content (replace with actual newlines)
-- PostgreSQL stores literal \n as two characters unless using E'' escape syntax

UPDATE public.terms_sections
SET content_pt = replace(content_pt, E'\\n', E'\n'),
    content_en = replace(content_en, E'\\n', E'\n')
WHERE content_pt LIKE E'%\\n%' OR content_en LIKE E'%\\n%';
