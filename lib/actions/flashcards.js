'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidateTag } from 'next/cache'
import { sanitizeHtml } from '@/lib/sanitize'
import { slugify } from '@/lib/utils/slugify'
import { isValidHexColor } from '@/lib/security'
import { sm2Next, SM2_DEFAULTS } from '@/lib/flashcards/sm2'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
 */
async function requireAdmin() {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return null

  const { data: adminUser, error: adminError } = await supabase
    .from('admin_users')
    .select('user_id, role')
    .eq('user_id', user.id)
    .single()
  if (adminError || !adminUser) return null

  return { supabase, user, role: adminUser.role || 'admin' }
}

/** Mestre (dominado) = intervalo ≥ 21 dias (Anki "mature"). */
const MASTERED_MIN_INTERVAL = 21

// ============================================================
//  REVISÃO (público — utilizador anónimo ou real)
// ============================================================

/**
 * Visão geral da revisão para a página principal: total de devidos hoje,
 * dominados, total de cartões e taxa de acerto (7 dias). Sem sessão →
 * devolve contagens a zero (o client pede ao utilizador iniciar sessão
 * anónima antes de chamar).
 */
export async function getFlashcardsReviewOverview() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return { loggedIn: false, dueTotal: 0, mastered: 0, cardTotal: 0, accuracy: null, perDeck: {} }
  }

  try {
    // Reviews do utilizador
    const { data: reviews, error: rErr } = await supabase
      .from('flashcard_reviews')
      .select('card_id, due_at, interval_days, last_grade, last_reviewed_at')
      .eq('user_id', user.id)
    if (rErr) throw rErr

    // Mapa cartão → deck (todos os cartões publicados, para não perder os do user)
    const { data: cards, error: cErr } = await supabase
      .from('flashcards')
      .select('id, deck_id')
      .eq('status', 'published')
      .eq('is_archived', false)
    if (cErr) throw cErr
    const deckByCard = new Map((cards || []).map((c) => [c.id, c.deck_id]))

    const { data: decks, error: dErr } = await supabase
      .from('flashcard_decks')
      .select('id')
      .eq('status', 'published')
      .eq('is_archived', false)
    if (dErr) throw dErr
    const deckIds = new Set((decks || []).map((d) => d.id))

    const now = Date.now()
    const weekAgo = new Date(now - 7 * 24 * 60 * 60 * 1000)
    let dueTotal = 0
    let mastered = 0
    let weekAnswers = 0
    let weekGood = 0
    const perDeck = {}

    for (const r of reviews || []) {
      const deckId = deckByCard.get(r.card_id)
      if (!deckId || !deckIds.has(deckId)) continue
      if (new Date(r.due_at).getTime() <= now) {
        dueTotal += 1
        perDeck[deckId] = (perDeck[deckId] || 0) + 1
      }
      if (r.interval_days >= MASTERED_MIN_INTERVAL) mastered += 1
      if (r.last_reviewed_at && new Date(r.last_reviewed_at) >= weekAgo) {
        weekAnswers += 1
        if (r.last_grade >= 2) weekGood += 1
      }
    }

    return {
      loggedIn: true,
      dueTotal,
      mastered,
      cardTotal: cards?.length || 0,
      accuracy: weekAnswers > 0 ? Math.round((weekGood / weekAnswers) * 100) : null,
      perDeck,
    }
  } catch {
    return { loggedIn: true, dueTotal: 0, mastered: 0, cardTotal: 0, accuracy: null, perDeck: {} }
  }
}

/**
 * Estado de revisão de um deck: cartões devidos (com review vencida),
 * cartões novos (sem review, limitados a 10 por sessão), dominados e totais.
 * Ordena a sessão: devidos por data, depois novos.
 */
export async function getDeckReviewState(deckSlug) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return { loggedIn: false, sessionCards: [], mastered: 0, dueCount: 0, newCount: 0, totalCount: 0 }

  try {
    const { data: deck, error: dErr } = await supabase
      .from('flashcard_decks')
      .select('id')
      .eq('slug', deckSlug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (dErr || !deck) return { loggedIn: true, sessionCards: [], mastered: 0, dueCount: 0, newCount: 0, totalCount: 0 }

    const { data: cards, error: cErr } = await supabase
      .from('flashcards')
      .select('id')
      .eq('deck_id', deck.id)
      .eq('status', 'published')
      .eq('is_archived', false)
    if (cErr) throw cErr
    const cardIds = (cards || []).map((c) => c.id)

    let reviews = []
    if (cardIds.length > 0) {
      const { data, error } = await supabase
        .from('flashcard_reviews')
        .select('card_id, ease, interval_days, repetitions, lapses, due_at')
        .eq('user_id', user.id)
        .in('card_id', cardIds)
      if (!error) reviews = data || []
    }

    const reviewByCard = new Map(reviews.map((r) => [r.card_id, r]))
    const now = Date.now()
    const due = []
    const fresh = []

    for (const id of cardIds) {
      const r = reviewByCard.get(id)
      if (!r) fresh.push(id)
      else if (new Date(r.due_at).getTime() <= now) due.push({ id, ...r })
    }

    due.sort((a, b) => new Date(a.due_at) - new Date(b.due_at))
    // Novos: 10 por sessão (evita sessões gigantes para utilizadores novos)
    const sessionIds = [...due.map((d) => d.id), ...fresh.slice(0, 10)]
    const mastered = reviews.filter((r) => r.interval_days >= MASTERED_MIN_INTERVAL).length

    return {
      loggedIn: true,
      sessionIds,
      mastered,
      dueCount: due.length,
      newCount: Math.min(fresh.length, 10),
      totalCount: cardIds.length,
      reviewByCard: Object.fromEntries(reviews.map((r) => [r.card_id, r])),
    }
  } catch {
    return { loggedIn: true, sessionIds: [], mastered: 0, dueCount: 0, newCount: 0, totalCount: 0 }
  }
}

/**
 * Regista a resposta a um cartão (SM-2) e persiste o novo estado.
 * Requer sessão (anónima ou real). Devolve o novo estado para feedback.
 */
export async function answerCard(cardId, grade) {
  const gradeNum = Number(grade)
  if (!UUID_REGEX.test(String(cardId)) || ![0, 1, 2, 3].includes(gradeNum)) {
    return { ok: false, error: 'Parâmetros inválidos' }
  }

  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return { ok: false, error: 'Sessão em falta' }

  try {
    // Estado atual (se existir)
    const { data: existing, error: gErr } = await supabase
      .from('flashcard_reviews')
      .select('ease, interval_days, repetitions, lapses')
      .eq('user_id', user.id)
      .eq('card_id', cardId)
      .maybeSingle()
    if (gErr) throw gErr

    const next = sm2Next(gradeNum, existing || SM2_DEFAULTS)

    const { error: uErr } = await supabase
      .from('flashcard_reviews')
      .upsert(
        {
          user_id: user.id,
          card_id: cardId,
          ease: next.ease,
          interval_days: next.intervalDays,
          repetitions: next.repetitions,
          lapses: next.lapses,
          due_at: next.dueAt.toISOString(),
          last_reviewed_at: new Date().toISOString(),
          last_grade: gradeNum,
          review_count: (existing ? 1 : 0) + 1,
        },
        { onConflict: 'user_id,card_id' }
      )
    if (uErr) throw uErr

    revalidateTag('flashcards')
    return {
      ok: true,
      next: {
        intervalDays: next.intervalDays,
        ease: Math.round(next.ease * 100) / 100,
        dueAt: next.dueAt.toISOString(),
        isLapse: next.isLapse,
      },
    }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao guardar a resposta' }
  }
}

/**
 * Repõe o progresso de um deck (elimina as reviews do utilizador no deck).
 */
export async function resetDeckProgress(deckId) {
  if (!UUID_REGEX.test(String(deckId))) return { ok: false, error: 'Deck inválido' }

  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return { ok: false, error: 'Sessão em falta' }

  try {
    const { data: cards } = await supabase
      .from('flashcards')
      .select('id')
      .eq('deck_id', deckId)
    const ids = (cards || []).map((c) => c.id)
    if (ids.length > 0) {
      const { error } = await supabase
        .from('flashcard_reviews')
        .delete()
        .eq('user_id', user.id)
        .in('card_id', ids)
      if (error) throw error
    }
    revalidateTag('flashcards')
    return { ok: true }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao repor o progresso' }
  }
}

// ============================================================
//  ADMIN — Decks
// ============================================================

const CARD_TYPES = ['mecanismo', 'classe', 'perfil', 'interacao', 'manual']
const STATUSES = ['draft', 'published']

export async function createFlashcardDeck(input) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  const { supabase } = ctx

  const namePt = sanitizeHtml(String(input?.name_pt || '').trim())
  if (!namePt) return { ok: false, error: 'Nome (PT) é obrigatório' }

  const slug = slugify(String(input?.slug || '')) || slugify(namePt)
  const color = isValidHexColor(input?.color) ? input.color : '#0a844f'
  const status = STATUSES.includes(input?.status) ? input.status : 'draft'
  const atcPrefix = input?.atc_prefix ? String(input.atc_prefix).trim().toUpperCase().slice(0, 3) : null

  const { data, error } = await supabase
    .from('flashcard_decks')
    .insert({
      slug,
      name_pt: namePt,
      name_en: input?.name_en ? sanitizeHtml(String(input.name_en).trim()) : null,
      description_pt: input?.description_pt ? sanitizeHtml(String(input.description_pt).trim()) : null,
      description_en: input?.description_en ? sanitizeHtml(String(input.description_en).trim()) : null,
      atc_prefix: atcPrefix || null,
      color,
      sort_order: Number.isFinite(Number(input?.sort_order)) ? Number(input.sort_order) : 0,
      status,
    })
    .select('id')
    .single()

  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true, id: data.id }
}

export async function updateFlashcardDeck(id, input) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  const { supabase } = ctx
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  const namePt = input?.name_pt !== undefined ? sanitizeHtml(String(input.name_pt).trim()) : undefined
  if (namePt !== undefined && !namePt) return { ok: false, error: 'Nome (PT) é obrigatório' }

  const patch = {}
  if (namePt !== undefined) patch.name_pt = namePt
  if (input?.name_en !== undefined) patch.name_en = sanitizeHtml(String(input.name_en).trim()) || null
  if (input?.description_pt !== undefined) patch.description_pt = sanitizeHtml(String(input.description_pt).trim()) || null
  if (input?.description_en !== undefined) patch.description_en = sanitizeHtml(String(input.description_en).trim()) || null
  if (input?.atc_prefix !== undefined) patch.atc_prefix = String(input.atc_prefix).trim().toUpperCase().slice(0, 3) || null
  if (input?.color !== undefined) patch.color = isValidHexColor(input.color) ? input.color : '#0a844f'
  if (input?.sort_order !== undefined) patch.sort_order = Number(input.sort_order) || 0
  if (input?.status !== undefined && STATUSES.includes(input.status)) patch.status = input.status
  patch.updated_at = new Date().toISOString()

  const { error } = await supabase.from('flashcard_decks').update(patch).eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

export async function archiveFlashcardDeck(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  const { data: deck } = await ctx.supabase
    .from('flashcard_decks')
    .select('is_archived')
    .eq('id', id)
    .single()

  const { error } = await ctx.supabase
    .from('flashcard_decks')
    .update({ is_archived: !deck?.is_archived, archived_at: deck?.is_archived ? null : new Date().toISOString(), updated_at: new Date().toISOString() })
    .eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

export async function deleteFlashcardDeck(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (ctx.role !== 'superadmin') return { ok: false, error: 'Apenas superadmin' }
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  // Bloqueado com cartões (padrão do projeto)
  const { data: cards } = await ctx.supabase
    .from('flashcards')
    .select('id')
    .eq('deck_id', id)
    .limit(1)
  if (cards && cards.length > 0) {
    return { ok: false, error: 'O deck tem cartões — arquive-o em vez de eliminar' }
  }

  const { error } = await ctx.supabase.from('flashcard_decks').delete().eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

// ============================================================
//  ADMIN — Cartões
// ============================================================

export async function createFlashcard(input) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  const { supabase } = ctx

  const deckId = String(input?.deck_id || '')
  if (!UUID_REGEX.test(deckId)) return { ok: false, error: 'Deck inválido' }
  const frontPt = sanitizeHtml(String(input?.front_pt || '').trim())
  const backPt = sanitizeHtml(String(input?.back_pt || '').trim())
  if (!frontPt || !backPt) return { ok: false, error: 'Frente e verso (PT) são obrigatórios' }

  const cardType = CARD_TYPES.includes(input?.card_type) ? input.card_type : 'manual'
  const status = STATUSES.includes(input?.status) ? input.status : 'draft'
  const drugId = input?.drug_id && UUID_REGEX.test(String(input.drug_id)) ? input.drug_id : null

  const { data, error } = await supabase
    .from('flashcards')
    .insert({
      deck_id: deckId,
      drug_id: drugId,
      card_type: cardType,
      front_pt: frontPt,
      front_en: input?.front_en ? sanitizeHtml(String(input.front_en).trim()) : null,
      back_pt: backPt,
      back_en: input?.back_en ? sanitizeHtml(String(input.back_en).trim()) : null,
      source_note: input?.source_note ? String(input.source_note).trim().slice(0, 300) : null,
      status,
    })
    .select('id')
    .single()

  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true, id: data.id }
}

export async function updateFlashcard(id, input) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  const patch = {}
  const frontPt = input?.front_pt !== undefined ? sanitizeHtml(String(input.front_pt).trim()) : undefined
  const backPt = input?.back_pt !== undefined ? sanitizeHtml(String(input.back_pt).trim()) : undefined
  if (frontPt !== undefined) {
    if (!frontPt) return { ok: false, error: 'Frente (PT) é obrigatória' }
    patch.front_pt = frontPt
  }
  if (backPt !== undefined) {
    if (!backPt) return { ok: false, error: 'Verso (PT) é obrigatório' }
    patch.back_pt = backPt
  }
  if (input?.front_en !== undefined) patch.front_en = sanitizeHtml(String(input.front_en).trim()) || null
  if (input?.back_en !== undefined) patch.back_en = sanitizeHtml(String(input.back_en).trim()) || null
  if (input?.source_note !== undefined) patch.source_note = String(input.source_note).trim().slice(0, 300) || null
  if (input?.card_type !== undefined && CARD_TYPES.includes(input.card_type)) patch.card_type = input.card_type
  if (input?.status !== undefined && STATUSES.includes(input.status)) patch.status = input.status
  if (input?.deck_id !== undefined) {
    if (!UUID_REGEX.test(String(input.deck_id))) return { ok: false, error: 'Deck inválido' }
    patch.deck_id = input.deck_id
  }
  patch.updated_at = new Date().toISOString()

  const { error } = await ctx.supabase.from('flashcards').update(patch).eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

export async function archiveFlashcard(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  const { data: card } = await ctx.supabase
    .from('flashcards')
    .select('is_archived')
    .eq('id', id)
    .single()

  const { error } = await ctx.supabase
    .from('flashcards')
    .update({
      is_archived: !card?.is_archived,
      archived_at: card?.is_archived ? null : new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

export async function deleteFlashcard(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (!UUID_REGEX.test(String(id))) return { ok: false, error: 'ID inválido' }

  const { error } = await ctx.supabase.from('flashcards').delete().eq('id', id)
  if (error) return { ok: false, error: error.message }
  revalidateTag('flashcards')
  return { ok: true }
}

// ============================================================
//  ADMIN — Geração assistida (picker de fármaco → cartão pré-preenchido)
// ============================================================

/**
 * Pré-preenche um cartão a partir dos dados reais de um fármaco.
 * Devolve { frontPt, backPt, sourceNote } para o form (não grava nada).
 */
export async function generateCardFromDrug(drugId, cardType) {
  const ctx = await requireAdmin()
  if (!ctx) return { ok: false, error: 'Não autorizado' }
  if (!UUID_REGEX.test(String(drugId))) return { ok: false, error: 'Fármaco inválido' }
  if (!CARD_TYPES.includes(cardType) || cardType === 'manual') {
    return { ok: false, error: 'Tipo de cartão inválido para geração' }
  }

  const { supabase } = ctx

  try {
    const { data: drug, error: dErr } = await supabase
      .from('drugs')
      .select('id, name_pt, class_pt')
      .eq('id', drugId)
      .single()
    if (dErr || !drug) return { ok: false, error: 'Fármaco não encontrado' }

    let frontPt = ''
    let backPt = ''
    let sourceNote = ''

    if (cardType === 'mecanismo') {
      const { data: ph } = await supabase
        .from('drug_pharmacology')
        .select('mechanism_pt, source_pt')
        .eq('drug_id', drugId)
        .maybeSingle()
      if (!ph || !ph.mechanism_pt) return { ok: false, error: 'Fármaco sem farmacologia (mecanismo)' }
      frontPt = `Qual é o mecanismo de ação de ${drug.name_pt}?`
      backPt = ph.mechanism_pt
      sourceNote = ph.source_pt || 'Farmacologia interna'
    } else if (cardType === 'classe') {
      if (!drug.class_pt) return { ok: false, error: 'Fármaco sem classe preenchida' }
      frontPt = `${drug.name_pt} — a que classe terapêutica pertence?`
      backPt = drug.class_pt
      sourceNote = 'Classificação interna (drugs.class_pt)'
    } else if (cardType === 'perfil') {
      const { data: pf } = await supabase
        .from('drug_profiles')
        .select('overview_public_pt')
        .eq('drug_id', drugId)
        .maybeSingle()
      if (!pf || !pf.overview_public_pt) return { ok: false, error: 'Fármaco sem perfil (visão geral)' }
      frontPt = `Qual é a visão geral / indicação de ${drug.name_pt}?`
      backPt = pf.overview_public_pt
      sourceNote = 'Perfil do medicamento (drug_profiles)'
    } else if (cardType === 'interacao') {
      const { data: pair } = await supabase
        .from('drug_interactions')
        .select('summary_pt, severity, source_pt')
        .or(`drug_a_id.eq.${drugId},drug_b_id.eq.${drugId}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .in('severity', ['critical', 'moderate'])
        .limit(1)
        .maybeSingle()
      if (!pair || !pair.summary_pt) return { ok: false, error: 'Sem interações críticas/moderadas publicadas para este fármaco' }
      frontPt = `Interação: ${drug.name_pt} + outro fármaco — qual é a interação?`
      backPt = `${pair.summary_pt}\n\nGrau: ${pair.severity === 'critical' ? 'Crítico' : 'Moderado'}`
      sourceNote = pair.source_pt || 'Banco de interações'
    }

    return { ok: true, frontPt, backPt, sourceNote }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao gerar o cartão' }
  }
}

/**
 * Picker de fármacos do admin (pesquisa por nome/slug) — só publicado.
 */
export async function searchDrugsForFlashcards(query) {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const q = String(query || '').trim()
  if (q.length < 2) return []

  try {
    let req = ctx.supabase
      .from('drugs')
      .select('id, slug, name_pt, class_pt')
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('name_pt', { ascending: true })
      .limit(12)
    if (q) req = req.ilike('name_pt', `%${q}%`)
    const { data, error } = await req
    if (error) return []
    return data || []
  } catch {
    return []
  }
}
