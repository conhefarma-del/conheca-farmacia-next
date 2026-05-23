-- Add featured column to articles, events, and lives tables
-- This allows admins to select which items appear on the homepage

ALTER TABLE articles ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT false;
ALTER TABLE events ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT false;
ALTER TABLE lives ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT false;

-- Mark current homepage articles as featured
UPDATE articles SET featured = true WHERE slug IN (
  '001-genericos-similares',
  '002-praticas-clinicas',
  '003-bula-corretamente'
);

-- Mark first 2 upcoming published events as featured
UPDATE events SET featured = true WHERE id IN (
  SELECT id FROM events WHERE status = 'published' ORDER BY date ASC LIMIT 2
);

-- Mark first 2 upcoming published lives as featured
UPDATE lives SET featured = true WHERE id IN (
  SELECT id FROM lives WHERE status = 'published' ORDER BY date ASC LIMIT 2
);