import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'

const DECK_COLUMNS = 'id, slug, name_pt, name_en, description_pt, description_en, atc_prefix, color, sort_order, status'
const CARD_COLUMNS = 'id, deck_id, drug_id, card_type, front_pt, front_en, back_pt, back_en, source_note, status'

/**
 * Decks publicados com contagem total de cartões publicados de cada um.
 * As contagens de revisão (devidos/dominados) dependem do utilizador e são
 * carregadas client-side (ver getFlashcardsReviewOverview em actions).
 */
export const getFlashcardDecks = unstable_cache(
  async () => {
    const supabase = await createAnonClient()
    const { data: decks, error } = await supabase
      .from('flashcard_decks')
      .select(DECK_COLUMNS)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (error) throw error

    // Contagem de cartões por deck (uma query para todos)
    const { data: cards } = await supabase
      .from('flashcards')
      .select('deck_id')
      .eq('status', 'published')
      .eq('is_archived', false)

    const countByDeck = new Map()
    for (const c of cards || []) {
      countByDeck.set(c.deck_id, (countByDeck.get(c.deck_id) || 0) + 1)
    }

    return (decks || []).map((d) => ({
      id: d.id,
      slug: d.slug,
      name: d.name_pt,
      nameEn: d.name_en,
      description: d.description_pt,
      descriptionEn: d.description_en,
      atcPrefix: d.atc_prefix,
      color: d.color,
      sortOrder: d.sort_order,
      cardCount: countByDeck.get(d.id) || 0,
    }))
  },
  ['api', 'flashcards', 'decks'],
  { revalidate: 3600, tags: ['flashcards'] }
)

/**
 * Deck publicado por slug + os cartões publicados (sem estado do utilizador).
 * O estado de revisão é carregado client-side via getDeckReviewState.
 */
export const getFlashcardDeckBySlug = unstable_cache(
  async (slug) => {
    const supabase = await createAnonClient()
    const { data: deck, error } = await supabase
      .from('flashcard_decks')
      .select(DECK_COLUMNS)
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()

    if (error) throw error
    if (!deck) return null

    const { data: cards, error: cErr } = await supabase
      .from('flashcards')
      .select(CARD_COLUMNS)
      .eq('deck_id', deck.id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('card_type', { ascending: true })

    if (cErr) throw cErr

    return {
      id: deck.id,
      slug: deck.slug,
      name: deck.name_pt,
      nameEn: deck.name_en,
      description: deck.description_pt,
      descriptionEn: deck.description_en,
      atcPrefix: deck.atc_prefix,
      color: deck.color,
      sortOrder: deck.sort_order,
      cards: (cards || []).map((c) => ({
        id: c.id,
        deckId: c.deck_id,
        drugId: c.drug_id,
        cardType: c.card_type,
        front: c.front_pt,
        frontEn: c.front_en,
        back: c.back_pt,
        backEn: c.back_en,
        sourceNote: c.source_note,
      })),
    }
  },
  ['api', 'flashcards', 'deck-by-slug'],
  { revalidate: 3600, tags: ['flashcards'] }
)

/**
 * Nomes/fármacos ligados aos cartões (para os links "Ver perfil").
 * Devolve Map<drugId, {slug, name}> — usado na sessão de revisão.
 */
export const getFlashcardDrugMap = unstable_cache(
  async (drugIds) => {
    if (!drugIds || drugIds.length === 0) return new Map()
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('drugs')
      .select('id, slug, name_pt')
      .in('id', drugIds)
    if (error) return new Map()
    return new Map((data || []).map((d) => [d.id, { slug: d.slug, name: d.name_pt }]))
  },
  ['api', 'flashcards', 'drug-map'],
  { revalidate: 3600, tags: ['flashcards'] }
)
