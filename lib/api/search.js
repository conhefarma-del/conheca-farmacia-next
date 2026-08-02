'use client'

import { createClient } from '../supabase/client'

/**
 * Search across public content types (articles, events, lives, guides,
 * protocols) in a given language.
 *
 * Behaviour:
 *  - `lang === 'pt'` (or omitted): searches the base tables directly,
 *    identical to the pre-i18n implementation.
 *  - `lang === 'en'`: searches the matching translation tables, which
 *    already contain EN slugs and EN text. Each result row carries the
 *    EN slug, so the UI navigates to `/en/articles/[en-slug]`.
 *  - Guides and protocols keep PT/EN columns in the same table (no
 *    separate translation tables), so the language is picked per row.
 *
 * @param {string} query
 * @param {'pt'|'en'} lang
 * @param {string} type - 'todos'|'artigos'|'eventos'|'lives'|'guias'|'protocolos'|'farmacos'
 * @param {string} order - 'recente'|'antigo'
 */
export async function searchAllContent(query, lang = 'pt', type = 'todos', order = 'recente') {
  if (!query || !query.trim()) {
    return { articles: [], events: [], lives: [], guides: [], protocolos: [], farmacos: [], total: 0 }
  }

  const supabase = createClient()
  const searchTerm = `%${query.trim()}%`
  const ascending = order === 'antigo'
  const isEn = lang === 'en'

  const queries = []

  // Articles
  if (type === 'todos' || type === 'artigos') {
    if (isEn) {
      queries.push(
        supabase
          .from('article_translations')
          .select('article_id, title, slug, excerpt, category_label')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .order('translated_at', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('articles')
          .select('id, title, slug, excerpt, image_url, category_label, author_name, published_date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('published_date', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Events
  if (type === 'todos' || type === 'eventos') {
    if (isEn) {
      queries.push(
        supabase
          .from('event_translations')
          .select('event_id, title, slug, location, events!inner(date)')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .order('events(date)', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('events')
          .select('id, title, slug, excerpt, image_url, category_label, location, date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('date', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Lives
  if (type === 'todos' || type === 'lives') {
    if (isEn) {
      queries.push(
        supabase
          .from('live_translations')
          .select('live_id, title, slug, topic, lives!inner(date)')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},description.ilike.${searchTerm},topic.ilike.${searchTerm}`)
          .order('lives(date)', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('lives')
          .select('id, title, slug, excerpt, image_url, platform, date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('date', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Study Guides — PT/EN na mesma linha (sem tabela de traduções)
  if (type === 'todos' || type === 'guias') {
    queries.push(
      supabase
        .from('guide_courses')
        .select('id, slug, name_pt, name_en, description_pt, description_en, hero_subtitle_pt, hero_subtitle_en, updated_at')
        .or(`name_pt.ilike.${searchTerm},name_en.ilike.${searchTerm},description_pt.ilike.${searchTerm},description_en.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('updated_at', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Clinical Protocols — PT/EN na mesma linha (sem tabela de traduções)
  if (type === 'todos' || type === 'protocolos') {
    queries.push(
      supabase
        .from('clinical_protocols')
        .select('id, slug, title_pt, title_en, description_pt, description_en, updated_at')
        .or(`title_pt.ilike.${searchTerm},title_en.ilike.${searchTerm},description_pt.ilike.${searchTerm},description_en.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('updated_at', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Fármacos (calculadora de interações) — PT/EN na mesma linha, aliases é array
  if (type === 'todos' || type === 'farmacos') {
    queries.push(
      supabase
        .from('drugs')
        .select('id, slug, name_pt, name_en, class_pt, class_en')
        .or(`name_pt.ilike.${searchTerm},name_en.ilike.${searchTerm},class_pt.ilike.${searchTerm},class_en.ilike.${searchTerm},aliases::text.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('name_pt', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  const [articlesRes, eventsRes, livesRes, guidesRes, protocolosRes, drugsRes] = await Promise.all(queries)

  let articles = articlesRes.data || []
  let events = eventsRes.data || []
  let lives = livesRes.data || []

  // Guias e protocolos: PT/EN na mesma linha — picar coluna conforme lang
  const guides = (guidesRes.data || []).map((g) => ({
    id: g.id,
    slug: g.slug,
    title: isEn ? g.name_en : g.name_pt,
    excerpt: isEn ? (g.description_en || g.hero_subtitle_en) : (g.description_pt || g.hero_subtitle_pt),
    date: g.updated_at,
  }))
  const protocolos = (protocolosRes.data || []).map((p) => ({
    id: p.id,
    slug: p.slug,
    title: isEn ? p.title_en : p.title_pt,
    excerpt: isEn ? p.description_en : p.description_pt,
    date: p.updated_at,
  }))
  const farmacos = (drugsRes.data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    title: isEn ? d.name_en : d.name_pt,
    excerpt: isEn ? d.class_en : d.class_pt,
    date: null,
  }))

  // Excluir arquivados: branch PT já filtra na query; branch EN precisa
  // de lookup pos-fetch (a query EN vai a *_translations, sem is_archived).
  if (isEn) {
    const articleIds = articles.map((a) => a.article_id)
    const eventIds = events.map((e) => e.event_id)
    const liveIds = lives.map((l) => l.live_id)

    const filters = []
    if (articleIds.length) {
      filters.push(
        supabase.from('articles').select('id').in('id', articleIds).eq('is_archived', false)
      )
    } else {
      filters.push(Promise.resolve({ data: [], error: null }))
    }
    if (eventIds.length) {
      filters.push(
        supabase.from('events').select('id').in('id', eventIds).eq('is_archived', false)
      )
    } else {
      filters.push(Promise.resolve({ data: [], error: null }))
    }
    if (liveIds.length) {
      filters.push(
        supabase.from('lives').select('id').in('id', liveIds).eq('is_archived', false)
      )
    } else {
      filters.push(Promise.resolve({ data: [], error: null }))
    }

    const [aF, eF, lF] = await Promise.all(filters)
    const aActive = new Set((aF.data || []).map((r) => r.id))
    const eActive = new Set((eF.data || []).map((r) => r.id))
    const lActive = new Set((lF.data || []).map((r) => r.id))
    articles = articles.filter((a) => aActive.has(a.article_id))
    events = events.filter((e) => eActive.has(e.event_id))
    lives = lives.filter((l) => lActive.has(l.live_id))

    // Opção B.2: achatar events.date / lives.date (do JOIN) para top-level
    // date — mantém o contrato do consumer (PesquisaPageClient.jsx lê item.date).
    events = events.map((e) => ({ ...e, id: e.event_id, date: e.events?.date ?? null }))
    lives = lives.map((l) => ({ ...l, id: l.live_id, date: l.lives?.date ?? null }))
  }

  return {
    articles,
    events,
    lives,
    guides,
    protocolos,
    farmacos,
    total: articles.length + events.length + lives.length + guides.length + protocolos.length + farmacos.length,
  }
}
