-- ============================================================================
-- 150_eventos_location_maps_url.sql
-- Adiciona um link do Google Maps (ou outro mapa) por evento, para os
-- inscritos obterem a localização exata a partir da página de detalhe.
-- ============================================================================

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS location_maps_url TEXT;

COMMENT ON COLUMN public.events.location_maps_url IS 'URL do Google Maps (ou outro mapa) com a localização exata do evento. Migration 150.';

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
      AND column_name = 'location_maps_url'
  ) INTO has_col;
  IF NOT has_col THEN
    RAISE EXCEPTION '150: coluna location_maps_url não foi criada em events';
  END IF;
  RAISE NOTICE '150: location_maps_url criada em events (ok)';
END;
$$;
