-- =====================================================================
-- 156 — Flashcards com repetição espaçada (SM-2)
-- ---------------------------------------------------------------------
-- Decisões do plano 2026-08-13-flashcards: 1A (progresso em Supabase
-- anonymous sign-in), 2A (decks híbridos: seed por prefixo ATC + admin),
-- 3A (cartões gerados dos dados reais), 4A (algoritmo SM-2).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
-- Decks (curadoria + seed automático por prefixo ATC)
CREATE TABLE IF NOT EXISTS public.flashcard_decks (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug           TEXT NOT NULL UNIQUE,
  name_pt        TEXT NOT NULL,
  name_en        TEXT,
  description_pt TEXT,
  description_en TEXT,
  atc_prefix     TEXT,                    -- ex.: 'J01' | 'C' | NULL (deck manual)
  color          TEXT NOT NULL DEFAULT '#0a844f',
  sort_order     INTEGER NOT NULL DEFAULT 0,
  status         TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived    BOOLEAN NOT NULL DEFAULT false,
  archived_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);

-- Cartões (conteúdo gerado a partir do banco de Medicamentos ou manual)
CREATE TABLE IF NOT EXISTS public.flashcards (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  deck_id     UUID NOT NULL REFERENCES public.flashcard_decks(id) ON DELETE CASCADE,
  drug_id     UUID REFERENCES public.drugs(id) ON DELETE SET NULL,  -- origem opcional
  card_type   TEXT NOT NULL DEFAULT 'manual'
              CHECK (card_type IN ('mecanismo','classe','perfil','interacao','manual')),
  front_pt    TEXT NOT NULL,
  front_en    TEXT,
  back_pt     TEXT NOT NULL,
  back_en     TEXT,
  source_note TEXT,                       -- fonte da resposta (DailyMed/EMC)
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Progresso de revisão (SM-2) — uma linha por (user, card).
-- Funciona com anonymous sign-in (o utilizador anónimo tem auth.uid() próprio).
CREATE TABLE IF NOT EXISTS public.flashcard_reviews (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_id          UUID NOT NULL REFERENCES public.flashcards(id) ON DELETE CASCADE,
  ease             REAL NOT NULL DEFAULT 2.5,
  interval_days    INTEGER NOT NULL DEFAULT 0,
  repetitions      INTEGER NOT NULL DEFAULT 0,
  lapses           INTEGER NOT NULL DEFAULT 0,
  due_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_reviewed_at TIMESTAMPTZ,
  last_grade       INTEGER,               -- última resposta (0–3) p/ estatísticas
  review_count     INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, card_id)
);

-- Índice único parcial: cartões gerados são regeneráveis (ON CONFLICT)
-- por (deck_id, drug_id, card_type) — sem colidir com cartões manuais.
CREATE UNIQUE INDEX IF NOT EXISTS uq_flashcards_generated
  ON public.flashcards (deck_id, drug_id, card_type)
  WHERE card_type <> 'manual' AND drug_id IS NOT NULL;

-- ---------------------------------------------------------------------
-- 2. RLS (padrão do projeto)
-- ---------------------------------------------------------------------
ALTER TABLE public.flashcard_decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcard_reviews ENABLE ROW LEVEL SECURITY;

-- Público: decks e cartões publicados
CREATE POLICY "anon_read_flashcard_decks" ON public.flashcard_decks
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);
CREATE POLICY "anon_read_flashcards" ON public.flashcards
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);

-- Reviews: cada utilizador só vê/altera os seus (inclui anónimos)
CREATE POLICY "own_reviews_select" ON public.flashcard_reviews
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "own_reviews_insert" ON public.flashcard_reviews
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_reviews_update" ON public.flashcard_reviews
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_reviews_delete" ON public.flashcard_reviews
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Admin: decks e cartões (padrão admin_users)
CREATE POLICY "admin_all_flashcard_decks" ON public.flashcard_decks
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));
CREATE POLICY "admin_all_flashcards" ON public.flashcards
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- ---------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_flashcards_deck ON public.flashcards(deck_id, status);
CREATE INDEX IF NOT EXISTS idx_flashcards_drug ON public.flashcards(drug_id);
-- Índice para consultas de cartões devidos (due_at <= now())
-- Sem WHERE clause pois now() é VOLATILE; o índice em (user_id, due_at) 
-- ainda é usado eficientemente pelo planner para range scans em due_at
CREATE INDEX IF NOT EXISTS idx_reviews_user_due ON public.flashcard_reviews(user_id, due_at);

-- =====================================================================
-- FIM — 156: flashcards
-- =====================================================================
