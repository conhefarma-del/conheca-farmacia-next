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
 * @param {string} type - 'todos'|'artigos'|'eventos'|'lives'|'guias'|'protocolos'|'cientificos'|'autores'|'farmacos'|'interacoes'|'entrevistas'|'entrevistados'|'flashcards'
 * @param {string} order - 'recente'|'antigo'
 */
export async function searchAllContent(query, lang = 'pt', type = 'todos', order = 'recente') {
  if (!query || !query.trim()) {
    return { articles: [], events: [], lives: [], guides: [], protocolos: [], cientificos: [], autores: [], farmacos: [], interacoes: [], entrevistas: [], entrevistados: [], flashcards: [], total: 0 }
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

  // Artigos Científicos — PT na base / EN na tabela de traduções (padrão artigos)
  if (type === 'todos' || type === 'cientificos') {
    if (isEn) {
      queries.push(
        supabase
          .from('scientific_article_translations')
          .select('article_id, title, slug, abstract, scientific_articles!inner(published_at)')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},abstract.ilike.${searchTerm}`)
          .eq('scientific_articles.status', 'published')
          .eq('scientific_articles.is_archived', false)
          .order('scientific_articles(published_at)', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('scientific_articles')
          .select('id, slug, title, abstract, published_at')
          .or(`title.ilike.${searchTerm},abstract.ilike.${searchTerm}`)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('published_at', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Autores científicos — a RLS anónima já limita aos de artigos publicados
  if (type === 'todos' || type === 'autores') {
    queries.push(
      supabase
        .from('scientific_authors')
        .select('id, slug, name, institution, department, role')
        .or(`name.ilike.${searchTerm},institution.ilike.${searchTerm},department.ilike.${searchTerm},role.ilike.${searchTerm}`)
        .order('name', { ascending: true })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Entrevistas — módulo apenas PT por agora (152); pesquisa título, excerto e
  // nomes dos entrevistados (interviewee JSONB, como os aliases dos fármacos)
  if (type === 'todos' || type === 'entrevistas') {
    queries.push(
      supabase
        .from('interviews')
        .select('id, slug, title, excerpt, thumbnail_url, date')
        .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm},interviewee::text.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('date', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Entrevistados (interview_people, 154) — a RLS anónima já limita aos de
  // entrevistas publicadas
  if (type === 'todos' || type === 'entrevistados') {
    queries.push(
      supabase
        .from('interview_people')
        .select('id, slug, name, role, bio')
        .or(`name.ilike.${searchTerm},role.ilike.${searchTerm},bio.ilike.${searchTerm}`)
        .order('name', { ascending: true })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Flashcards (decks) — PT/EN na mesma linha (sem tabela de traduções)
  if (type === 'todos' || type === 'flashcards') {
    queries.push(
      supabase
        .from('flashcard_decks')
        .select('id, slug, name_pt, name_en, description_pt, description_en, sort_order')
        .or(`name_pt.ilike.${searchTerm},name_en.ilike.${searchTerm},description_pt.ilike.${searchTerm},description_en.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('sort_order', { ascending: true })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Fármacos (calculadora de interações) — PT/EN na mesma linha, aliases é array.
  // Resultado próprio do filtro 'farmacos' (filtrado pelo termo procurado).
  if (type === 'todos' || type === 'farmacos') {
    queries.push(
      supabase
        .from('drugs')
        .select('id, slug, name_pt, name_en, class_pt, class_en')
        .or(`name_pt.ilike.${searchTerm},name_en.ilike.${searchTerm},class_pt.ilike.${searchTerm},class_en.ilike.${searchTerm},aliases::text.ilike.${searchTerm}`)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('name_pt', { ascending: true })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Lookup de TODOS os fármacos publicados — só para resolver nomes/slugs dos
  // registos de interação (não é resultado). Corre quando procuramos interações.
  if (type === 'todos' || type === 'interacoes') {
    queries.push(
      supabase
        .from('drugs')
        .select('id, slug, name_pt, name_en')
        .eq('status', 'published')
        .eq('is_archived', false)
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Interações — 4 dimensões (fármaco-fármaco, alimento/bebida, doença, gestação).
  // Datasets pequenos (centenas): busca o que está publicado e filtra em JS.
  const interQueries = [
    supabase
      .from('drug_interactions')
      .select('id, drug_a_id, drug_b_id, severity, summary_pt, summary_en')
      .eq('status', 'published')
      .eq('is_archived', false),
    supabase
      .from('drug_food_interactions')
      .select('id, drug_id, entity_pt, entity_en, severity, mechanism_pt, mechanism_en')
      .eq('status', 'published')
      .eq('is_archived', false),
    supabase
      .from('drug_disease_interactions')
      .select('id, drug_id, condition_pt, condition_en, severity, reason_pt, reason_en')
      .eq('status', 'published')
      .eq('is_archived', false),
    supabase
      .from('drug_pregnancy_info')
      .select('id, drug_id, pregnancy_category, risk_pt, risk_en')
      .eq('status', 'published')
      .eq('is_archived', false),
  ]
  if (type === 'todos' || type === 'interacoes') {
    queries.push(...interQueries)
  } else {
    interQueries.forEach(() => queries.push(Promise.resolve({ data: [], error: null })))
  }

  const [articlesRes, eventsRes, livesRes, guidesRes, protocolosRes, sciRes, authRes, interviewsRes, peopleRes, flashDecksRes, drugsRes, drugLookupRes, ffRes, foodRes, diseaseRes, pregRes] = await Promise.all(queries)

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
  const cientificos = (sciRes.data || []).map((a) => ({
    id: a.id,
    slug: a.slug,
    title: a.title,
    excerpt: a.abstract,
    date: a.published_at || a.scientific_articles?.published_at || null,
    image_url: null,
  }))
  const autores = (authRes.data || []).map((a) => ({
    id: a.id,
    slug: a.slug,
    title: a.name,
    excerpt: [a.role, a.institution, a.department].filter(Boolean).join(' · '),
    date: null,
    image_url: null,
  }))
  const entrevistas = (interviewsRes.data || []).map((i) => ({
    id: i.id,
    slug: i.slug,
    title: i.title,
    excerpt: i.excerpt,
    date: i.date,
    image_url: i.thumbnail_url || null,
  }))
  const entrevistados = (peopleRes.data || []).map((p) => ({
    id: p.id,
    slug: p.slug,
    title: p.name,
    excerpt: p.role || p.bio || '',
    date: null,
    image_url: null,
  }))
  const flashcards = (flashDecksRes.data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    title: isEn ? (d.name_en || d.name_pt) : d.name_pt,
    excerpt: isEn ? (d.description_en || d.description_pt) : d.description_pt,
    date: null,
    image_url: null,
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

  // ---- Interações: junta os fármacos aos registos e filtra pelo query ------
  const drugById = new Map((drugLookupRes.data || []).map((d) => [d.id, d]))
  const nameOf = (id) => {
    const d = drugById.get(id)
    if (!d) return ''
    return isEn ? (d.name_en || d.name_pt) : (d.name_pt || d.name_en)
  }
  const slugOf = (id) => drugById.get(id)?.slug || ''
  const q = query.trim().toLowerCase()

  const hit = (...fields) =>
    fields.some((f) => f && String(f).toLowerCase().includes(q))

  const interacoes = []

  // Fármaco-fármaco (pares canónicos)
  ;(ffRes.data || []).forEach((i) => {
    const a = nameOf(i.drug_a_id)
    const b = nameOf(i.drug_b_id)
    const summary = isEn ? i.summary_en : i.summary_pt
    const title = `${a} + ${b}`
    if (!hit(title, summary, a, b)) return
    interacoes.push({
      type: 'interacoes',
      id: `ff_${i.id}`,
      tab: 0,
      title,
      excerpt: summary,
      severity: i.severity,
      drugSlugA: slugOf(i.drug_a_id),
      drugSlugB: slugOf(i.drug_b_id),
      date: null,
    })
  })

  // Alimento / bebida
  ;(foodRes.data || []).forEach((i) => {
    const drugName = nameOf(i.drug_id)
    const entity = isEn ? i.entity_en : i.entity_pt
    const mechanism = isEn ? i.mechanism_en : i.mechanism_pt
    const title = `${drugName} × ${entity}`
    if (!hit(drugName, entity, mechanism)) return
    interacoes.push({
      type: 'interacoes',
      id: `food_${i.id}`,
      tab: 1,
      title,
      excerpt: mechanism,
      severity: i.severity,
      drugSlug: slugOf(i.drug_id),
      date: null,
    })
  })

  // Doença / condição
  ;(diseaseRes.data || []).forEach((i) => {
    const drugName = nameOf(i.drug_id)
    const condition = isEn ? i.condition_en : i.condition_pt
    const reason = isEn ? i.reason_en : i.reason_pt
    const title = `${drugName} × ${condition}`
    if (!hit(drugName, condition, reason)) return
    interacoes.push({
      type: 'interacoes',
      id: `disease_${i.id}`,
      tab: 2,
      title,
      excerpt: reason,
      severity: i.severity,
      drugSlug: slugOf(i.drug_id),
      date: null,
    })
  })

  // Gestação / lactação
  ;(pregRes.data || []).forEach((i) => {
    const drugName = nameOf(i.drug_id)
    const risk = isEn ? i.risk_en : i.risk_pt
    if (!hit(drugName, risk)) return
    interacoes.push({
      type: 'interacoes',
      id: `preg_${i.id}`,
      tab: 3,
      title: drugName,
      excerpt: risk,
      severity: i.pregnancy_category,
      drugSlug: slugOf(i.drug_id),
      date: null,
    })
  })

  return {
    articles,
    events,
    lives,
    guides,
    protocolos,
    cientificos,
    autores,
    farmacos,
    interacoes,
    entrevistas,
    entrevistados,
    flashcards,
    total:
      articles.length +
      events.length +
      lives.length +
      guides.length +
      protocolos.length +
      cientificos.length +
      autores.length +
      farmacos.length +
      interacoes.length +
      entrevistas.length +
      entrevistados.length +
      flashcards.length,
  }
}
