-- ---------------------------------------------------------------------
-- 149 — 'Sobre este artigo': fonte original + licença CC
-- ---------------------------------------------------------------------
-- Adiciona metadados editoriais de fonte a scientific_articles e preenche
-- os 5 artigos seed com os dados oficiais do Crossref/EuropePMC (verificado
-- em 2026-08-11):
--   * Human Vaccines & Immunotherapeutics 12(12):3146-3159 (2016) — sem
--     licença CC (author manuscript no PMC, © Taylor & Francis)
--   * Drug Safety 46(7):625-636 (2023) — CC BY-NC 4.0
--   * Evidence-Based Complementary and Alternative Medicine 2014:957362
--     (2014) — CC BY 3.0
--   * Antibiotics 11(10):1410 (2022) — CC BY 4.0
--   * BMC Medical Education 24:1435 (2024) — CC BY-NC-ND 4.0
-- A licença é exibida na caixa 'Sobre este artigo' apenas quando existe.
-- ---------------------------------------------------------------------

ALTER TABLE public.scientific_articles
  ADD COLUMN IF NOT EXISTS journal      TEXT,
  ADD COLUMN IF NOT EXISTS volume       TEXT,
  ADD COLUMN IF NOT EXISTS issue        TEXT,
  ADD COLUMN IF NOT EXISTS pages        TEXT,
  ADD COLUMN IF NOT EXISTS license      TEXT,
  ADD COLUMN IF NOT EXISTS license_url  TEXT;

UPDATE public.scientific_articles
SET
  journal     = v.journal,
  volume      = v.volume,
  issue       = v.issue,
  pages       = v.pages,
  license     = v.license,
  license_url = v.license_url
FROM (VALUES
  ('farmacias-comunitarias-vacinacao-adultos',
   'Human Vaccines & Immunotherapeutics', '12', '12', '3146–3159',
   NULL, NULL),
  ('subnotificacao-reacoes-adversas-medicamentos',
   'Drug Safety', '46', '7', '625–636',
   'CC BY-NC 4.0', 'https://creativecommons.org/licenses/by-nc/4.0/'),
  ('interacoes-ervas-varfarina',
   'Evidence-Based Complementary and Alternative Medicine', '2014', NULL, '957362',
   'CC BY 3.0', 'https://creativecommons.org/licenses/by/3.0/'),
  ('interacoes-farmacocineticas-antibioticos',
   'Antibiotics', '11', '10', '1410',
   'CC BY 4.0', 'https://creativecommons.org/licenses/by/4.0/'),
  ('simulacao-comunicacao-farmacia',
   'BMC Medical Education', '24', NULL, '1435',
   'CC BY-NC-ND 4.0', 'https://creativecommons.org/licenses/by-nc-nd/4.0/')
) AS v(slug, journal, volume, issue, pages, license, license_url)
WHERE public.scientific_articles.slug = v.slug;
