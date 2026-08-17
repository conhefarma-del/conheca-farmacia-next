'use client'

import { createClient } from '../supabase/client'
import { featureEnabled } from '@/lib/features'

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
 * @param {string} type - 'todos'|'artigos'|'eventos'|'lives'|'guias'|'protocolos'|'cientificos'|'autores'|'farmacos'|'interacoes'|'entrevistas'|'entrevistados'|'flashcards'|'alvos'
 * @param {string} order - 'recente'|'antigo'
 */
export async function searchAllContent(query, lang = 'pt', type = 'todos', order = 'recente') {
  if (!query || !query.trim()) {
    return { articles: [], events: [], lives: [], guides: [], protocolos: [], cientificos: [], autores: [], farmacos: [], interacoes: [], entrevistas: [], entrevistados: [], flashcards: [], alvos: [], total: 0 }
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

  // Lives/webinars fundidas em Eventos (migração 159) — a pesquisa cobre-as
  // como eventos, sem tipo próprio.

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

  // Clinical Protocols — PT/EN na mesma linha (sem tabela de traduções).
  // Ocultos via lib/features.js: não são pesquisados enquanto desligados.
  if (featureEnabled('protocolos') && (type === 'todos' || type === 'protocolos')) {
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

  // Artigos Científicos — PT na base / EN na tabela de traduções (padrão
  // artigos). Ocultos via lib/features.js: não são pesquisados enquanto desligados.
  if (featureEnabled('cientificos') && (type === 'todos' || type === 'cientificos')) {
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

  // Autores científicos — a RLS anónima já limita aos de artigos publicados.
  // Ocultos juntamente com os Artigos Científicos (lib/features.js).
  if (featureEnabled('cientificos') && (type === 'todos' || type === 'autores')) {
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
  // Entrevistas — interviewee é JSONB; o cast interviewee::text dentro de
  // .or() não é suportado pelo PostgREST, por isso busca o publicado e filtra
  // em JS (inclui o nome/role do entrevistado no JSONB).
  if (type === 'todos' || type === 'entrevistas') {
    queries.push(
      supabase
        .from('interviews')
        .select('id, slug, title, excerpt, thumbnail_url, date, interviewee')
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

  // Alvos moleculares (CYP, COX, transportadores) — PT/EN na mesma linha,
  // aliases é array. Dataset pequeno: busca o publicado e filtra em JS (o
  // cast aliases::text dentro de .or() não é suportado pelo PostgREST).
  if (type === 'todos' || type === 'alvos') {
    queries.push(
      supabase
        .from('molecular_targets')
        .select('id, slug, name_pt, name_en, aliases, what_is_pt, what_is_en, role_pt, role_en, target_type, sort_order')
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('sort_order', { ascending: true })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Fármacos (calculadora de interações) — PT/EN na mesma linha, aliases é
  // array. Dataset pequeno (centenas): busca o publicado e filtra em JS.
  if (type === 'todos' || type === 'farmacos') {
    queries.push(
      supabase
        .from('drugs')
        .select('id, slug, name_pt, name_en, class_pt, class_en, aliases')
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

  const [articlesRes, eventsRes, guidesRes, protocolosRes, sciRes, authRes, interviewsRes, peopleRes, flashDecksRes, alvosRes, drugsRes, drugLookupRes, ffRes, foodRes, diseaseRes, pregRes] = await Promise.all(queries)

  let articles = articlesRes.data || []
  let events = eventsRes.data || []
  let farmacos = []
  let entrevistas = []
  let alvos = []

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
  // Fármacos: filtra em JS (nome, classe, aliases) — dataset pequeno.
  {
    const _q = query.trim().toLowerCase()
    const _hit = (...fields) =>
      fields.some((f) => f && String(f).toLowerCase().includes(_q))
    farmacos = (drugsRes.data || [])
      .filter((d) =>
        _hit(d.name_pt, d.name_en, d.class_pt, d.class_en, (d.aliases || []).join(' '))
      )
      .map((d) => ({
        id: d.id,
        slug: d.slug,
        title: isEn ? d.name_en : d.name_pt,
        excerpt: isEn ? d.class_en : d.class_pt,
        date: null,
      }))
  }
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
  // Entrevistas: filtra em JS (título, excerto, entrevistado no JSONB).
  {
    const _q = query.trim().toLowerCase()
    const _hit = (...fields) =>
      fields.some((f) => f && String(f).toLowerCase().includes(_q))
    entrevistas = (interviewsRes.data || [])
      .filter((i) => {
        const person = i.interviewee && typeof i.interviewee === 'object'
          ? [i.interviewee.name, i.interviewee.role].filter(Boolean).join(' ')
          : ''
        return _hit(i.title, i.excerpt, person)
      })
      .map((i) => ({
        id: i.id,
        slug: i.slug,
        title: i.title,
        excerpt: i.excerpt,
        date: i.date,
        image_url: i.thumbnail_url || null,
      }))
  }
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
  // Alvos moleculares: filtra em JS (nome, aliases, o que é, papel).
  {
    const _q = query.trim().toLowerCase()
    const _hit = (...fields) =>
      fields.some((f) => f && String(f).toLowerCase().includes(_q))
    alvos = (alvosRes.data || [])
      .filter((t) =>
        _hit(t.name_pt, t.name_en, t.what_is_pt, t.what_is_en, t.role_pt, t.role_en, (t.aliases || []).join(' '))
      )
      .map((t) => ({
        id: t.id,
        slug: t.slug,
        title: isEn ? (t.name_en || t.name_pt) : t.name_pt,
        excerpt: isEn ? (t.role_en || t.what_is_en || '') : (t.role_pt || t.what_is_pt || ''),
        date: null,
        image_url: null,
      }))
  }

  // Excluir arquivados: branch PT já filtra na query; branch EN precisa
  // de lookup pos-fetch (a query EN vai a *_translations, sem is_archived).
  if (isEn) {
    const articleIds = articles.map((a) => a.article_id)
    const eventIds = events.map((e) => e.event_id)

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

    const [aF, eF] = await Promise.all(filters)
    const aActive = new Set((aF.data || []).map((r) => r.id))
    const eActive = new Set((eF.data || []).map((r) => r.id))
    articles = articles.filter((a) => aActive.has(a.article_id))
    events = events.filter((e) => eActive.has(e.event_id))

    // Achatar events.date (do JOIN) para top-level date — mantém o contrato
    // do consumer (PesquisaPageClient.jsx lê item.date).
    events = events.map((e) => ({ ...e, id: e.event_id, date: e.events?.date ?? null }))
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
    guides,
    protocolos,
    cientificos,
    autores,
    farmacos,
    interacoes,
    entrevistas,
    entrevistados,
    flashcards,
    alvos,
    total:
      articles.length +
      events.length +
      guides.length +
      protocolos.length +
      cientificos.length +
      autores.length +
      farmacos.length +
      interacoes.length +
      entrevistas.length +
      entrevistados.length +
      flashcards.length +
      alvos.length,
  }
}
