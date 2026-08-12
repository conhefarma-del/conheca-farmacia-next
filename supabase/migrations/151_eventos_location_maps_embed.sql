-- ============================================================================
-- 151_eventos_location_maps_embed.sql
-- Adiciona um URL de embed (iframe) do Google Maps por evento.
--
-- Distinção importante:
--   * location_maps_url      (150) — link de partilha (maps.app.goo.gl ou
--                                    google.com/maps?q=...). Abre em nova aba,
--                                    NÃO pode ser usado num iframe (X-Frame-Options).
--   * location_maps_embed_url (151) — URL "Incorporar um mapa" do Google
--                                    (google.com/maps/embed?pb=...). Usado no
--                                    <iframe> da página de detalhe do evento.
-- ============================================================================

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS location_maps_embed_url TEXT;

COMMENT ON COLUMN public.events.location_maps_embed_url IS 'URL de embed (iframe) do Google Maps — obtido em Google Maps > Partilhar > Incorporar um mapa. Migration 151.';

-- ============================================================================
-- Sanity check
-- ============================================================================
DO $$
DECLARE
  has_col BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'events'
      AND column_name = 'location_maps_embed_url'
  ) INTO has_col;
  IF NOT has_col THEN
    RAISE EXCEPTION '151: coluna location_maps_embed_url não foi criada em events';
  END IF;
  RAISE NOTICE '151: location_maps_embed_url criada em events (ok)';
END;
$$;
