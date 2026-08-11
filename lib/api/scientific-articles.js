import { createClient } from '@/lib/supabase/server'

/**
 * API layer — Artigos Científicos (tabela própria `scientific_articles`).
 *
 * Espelha o padrão de `lib/api/articles.js`: SELECT com colunas explícitas,
 * merge de traduções (`scientific_article_translations`), e comportamento
 * por língua idêntico ao dos artigos:
 *   - `pt` devolve sempre a base (o conteúdo canónico vive na base PT);
 *   - `en` só devolve artigos que têm tradução (sem fallback para PT na
 *     listagem); no detalhe, o fallback PT aplica-se quando o slug não
 *     resolve numa tradução (padrão `getArticleBySlug`).
 *
 * Categorias vêm da BD (`scientific_categories` — geríveis no admin),
 * não de constantes.
 */

const SCIENTIFIC_ARTICLE_COLUMNS =
  'id, slug, title, abstract, keywords, category_id, doi, authors, content, references_arr, read_time, status, featured, published_at, created_at, is_archived, view_count, journal, volume, issue, pages, license, license_url, scientific_categories(slug, name_pt, name_en, color)'

const SCIENTIFIC_TRANSLATION_COLUMNS =
  'id, article_id, lang, slug, title, abstract, keywords, content, references_arr, updated_at'

function pickCategory(cat, lang = 'pt') {
  if (!cat) return null
  const name = lang === 'en' && cat.name_en ? cat.name_en : cat.name_pt
  return { slug: cat.slug, name, color: cat.color }
}

/**
 * Normalize a scientific article row (snake_case, flat + embedded category)
 * to the frontend shape (camelCase, nested category, arrays).
 *
 * @param {object} row
 * @param {'pt'|'en'} lang
 * @returns {object}
 */
export function normalizeScientificArticle(row, lang = 'pt') {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    abstract: row.abstract,
    keywords: row.keywords || [],
    category: pickCategory(row.scientific_categories, lang),
    categoryId: row.category_id,
    doi: row.doi || '',
    authors: Array.isArray(row.authors) ? row.authors : [],
    content: row.content,
    references: row.references_arr || [],
    readTime: row.read_time,
    status: row.status,
    featured: row.featured || false,
    isArchived: row.is_archived || false,
    viewCount: row.view_count || 0,
    journal: row.journal || '',
    volume: row.volume || '',
    issue: row.issue || '',
    pages: row.pages || '',
    license: row.license || '',
    licenseUrl: row.license_url || '',
    publishedAt: row.published_at,
    date: row.published_at ? row.published_at.split('T')[0] : null,
  }
}

/**
 * Merge a base PT row with an optional translation row (per-language fields).
 * Non-translatable fields (doi, authors, category, dates) stay on the base.
 *
 * @param {object} base - already normalized
 * @param {object|null} translation
 * @param {'pt'|'en'} lang
 * @returns {object}
 */
export function mergeScientificTranslation(base, translation, lang) {
  if (!translation) {
    return { ...base, lang, has_translation: false }
  }
  const merged = { ...base }
  for (const field of ['title', 'abstract', 'keywords', 'content', 'references']) {
    const col = field === 'references' ? 'references_arr' : field
    const translated = translation[col]
    if (translated !== null && translated !== undefined) merged[field] = translated
  }
  merged.lang = lang
  merged.has_translation = true
  return merged
}

/**
 * All scientific categories, ordered by sort_order, with the name in `lang`.
 * Used by the public listing (filters) and the admin form (dropdown).
 *
 * @param {'pt'|'en'} lang
 * @returns {Promise<Array<{id: string, slug: string, name: string, color: string, sortOrder: number}>>}
 */
export async function getScientificCategories(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_categories')
    .select('id, slug, name_pt, name_en, color, sort_order')
    .order('sort_order', { ascending: true })

  if (error) throw error
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name: lang === 'en' && c.name_en ? c.name_en : c.name_pt,
    color: c.color,
    sortOrder: c.sort_order,
  }))
}

/**
 * Published, non-archived scientific articles, merged for `lang`.
 * On EN, only articles with a translation are returned (no PT fallback),
 * mirroring `getArticles()`.
 *
 * @param {'pt'|'en'} lang
 * @returns {Promise<Array<object>>}
 */
/**
 * Merge EN translations onto a list of normalized bases (shared by the
 * listing and the author pages). On EN only articles with a translation
 * are kept (no PT fallback), mirroring `getArticles()`.
 */
async function mergeLangTranslations(supabase, bases, lang) {
  if (lang === 'pt' || bases.length === 0) return bases

  const ids = bases.map((a) => a.id)
  const { data: translations, error: trErr } = await supabase
    .from('scientific_article_translations')
    .select(SCIENTIFIC_TRANSLATION_COLUMNS)
    .eq('lang', lang)
    .in('article_id', ids)

  if (trErr) {
    console.error('mergeLangTranslations error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.article_id, t]))
  return bases
    .map((base) => mergeScientificTranslation(base, byId.get(base.id) || null, lang))
    .filter((merged) => (lang === 'en' ? merged.has_translation === true : true))
}

export async function getScientificArticles(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_articles')
    .select(SCIENTIFIC_ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('published_at', { ascending: false })

  if (error) throw error
  const bases = (data || []).map((row) => normalizeScientificArticle(row, lang))
  return mergeLangTranslations(supabase, bases, lang)
}

/**
 * Single published scientific article by slug, in `lang`.
 *
 * Resolution (mirrors `getArticleBySlug`):
 *   1. If `lang !== 'pt'`, look up `scientific_article_translations` by
 *      (slug, lang); if found, load the base by article_id and merge.
 *   2. Otherwise look up the base `scientific_articles` row by slug
 *      (PT fallback — the canonical row is PT).
 *
 * Attaches `langSlugs: { pt, en }` so the local PT/EN toggle can navigate
 * between the two slugs (en is null when no translation exists).
 *
 * @param {string} slug
 * @param {'pt'|'en'} lang
 * @returns {Promise<object|null>}
 */
export async function getScientificArticleBySlug(slug, lang = 'pt') {
  const supabase = await createClient()

  let translation = null
  if (lang !== 'pt') {
    const { data, error } = await supabase
      .from('scientific_article_translations')
      .select(SCIENTIFIC_TRANSLATION_COLUMNS)
      .eq('slug', slug)
      .eq('lang', lang)
      .maybeSingle()
    if (!error && data) translation = data
  }

  let base = null
  if (translation) {
    const { data, error } = await supabase
      .from('scientific_articles')
      .select(SCIENTIFIC_ARTICLE_COLUMNS)
      .eq('id', translation.article_id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .single()
    if (!error && data) base = data
  } else {
    const { data, error } = await supabase
      .from('scientific_articles')
      .select(SCIENTIFIC_ARTICLE_COLUMNS)
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (!error && data) base = data
  }

  if (!base) return null

  const normalized = mergeScientificTranslation(
    normalizeScientificArticle(base, lang),
    translation,
    lang
  )

  // Slugs para o toggle PT/EN local (o EN só existe se houver tradução).
  const langSlugs = { pt: base.slug, en: null }
  if (translation) {
    langSlugs.en = translation.slug
  } else {
    const { data: enTr } = await supabase
      .from('scientific_article_translations')
      .select('slug')
      .eq('article_id', base.id)
      .eq('lang', 'en')
      .maybeSingle()
    if (enTr) langSlugs.en = enTr.slug
  }
  normalized.langSlugs = langSlugs

  // Identidade de autores a partir do registo (144/145): id/slug/orcid
  // para os nomes clicáveis apontarem ao autor certo (slugs desambiguados).
  return enrichAuthorsWithRegistry(supabase, normalized)
}

/**
 * Enrich a single article's authors with registry identity (id, slug, orcid)
 * from `scientific_authors`, so the detail page can link to author pages
 * with the disambiguated slug (two same-named authors → different slugs).
 * Falls back to the raw JSONB authors if the 144/145 tables don't exist yet.
 */
async function enrichAuthorsWithRegistry(supabase, article) {
  const authors = article.authors || []
  const names = authors.map((a) => a.name).filter(Boolean)
  if (names.length === 0) return article

  try {
    const { data: rows } = await supabase
      .from('scientific_authors')
      .select('id, name, slug, orcid, institution')
      .in('name', names)

    if (!rows || rows.length === 0) return article

    // Agrupar por nome — quando há vários com o mesmo nome, desambiguar
    // pela instituição do artigo (a mesma regra da 145/sync).
    const byName = new Map()
    for (const r of rows) {
      if (!byName.has(r.name)) byName.set(r.name, [])
      byName.get(r.name).push(r)
    }

    article.authors = authors.map((a) => {
      const candidates = byName.get(a.name)
      if (!candidates || candidates.length === 0) return a
      const match =
        candidates.length === 1
          ? candidates[0]
          : candidates.find((c) => c.institution && c.institution === a.institution) || candidates[0]
      return { ...a, id: match.id, slug: match.slug, orcid: match.orcid || null }
    })
  } catch (err) {
    // Tabelas 144/145 ainda não aplicadas — mantém JSONB puro (fallback slugify)
    console.warn('enrichAuthorsWithRegistry skipped:', err.message)
  }
  return article
}

/**
 * Author index (/cientificos/autores) — todos os autores do registo com a
 * contagem de artigos publicados. A RLS anónima de scientific_authors e da
 * junction só expõe autores/ligações de artigos publicados e não arquivados,
 * por isso rascunhos ficam automaticamente de fora (contagens e tudo).
 *
 * @param {'pt'|'en'} lang - apenas usado para consistência da assinatura
 * @returns {Promise<Array<{id, name, slug, orcid, institution, department, role, avatar, avatarBg, articleCount}>>}
 */
export async function getScientificAuthors(lang = 'pt') {
  const supabase = await createClient()
  const { data: authors, error: authErr } = await supabase
    .from('scientific_authors')
    .select('id, name, slug, orcid, institution, department, role, avatar, avatar_bg')
    .order('name', { ascending: true })
  if (authErr) throw authErr

  const counts = new Map()
  const correspondingIds = new Set()
  if ((authors || []).length > 0) {
    const { data: links, error: linkErr } = await supabase
      .from('scientific_article_authors')
      .select('author_id, corresponding')
    if (!linkErr && links) {
      for (const l of links) {
        counts.set(l.author_id, (counts.get(l.author_id) || 0) + 1)
        if (l.corresponding) correspondingIds.add(l.author_id)
      }
    }
  }

  return (authors || []).map((a) => ({
    id: a.id,
    name: a.name,
    slug: a.slug,
    orcid: a.orcid || null,
    institution: a.institution,
    department: a.department,
    role: a.role,
    avatar: a.avatar,
    avatarBg: a.avatar_bg || '#0a844f',
    articleCount: counts.get(a.id) || 0,
    isCorresponding: correspondingIds.has(a.id),
  }))
}

/**
 * Author pages — resolve um autor pelo slug ÚNICO do registo
 * (`scientific_authors.slug`, desambiguado) e devolve o seu perfil
 * consolidado + todos os artigos publicados onde aparece, pela ordem
 * da junction (position).
 *
 * @param {string} authorSlug - scientific_authors.slug
 * @param {'pt'|'en'} lang - segue o comportamento da listagem (EN só artigos traduzidos)
 * @returns {Promise<{ author: object, articles: Array<object> } | null>}
 */
export async function getScientificAuthor(authorSlug, lang = 'pt') {
  const supabase = await createClient()

  const { data: authorRow, error: authErr } = await supabase
    .from('scientific_authors')
    .select('id, name, slug, orcid, institution, department, role, avatar, avatar_bg, bio')
    .eq('slug', authorSlug)
    .maybeSingle()
  if (authErr) throw authErr
  if (!authorRow) return null

  const { data: links, error: linkErr } = await supabase
    .from('scientific_article_authors')
    .select('article_id, position, corresponding')
    .eq('author_id', authorRow.id)
    .order('position', { ascending: true })
  if (linkErr) throw linkErr

  let articles = []
  const ids = (links || []).map((l) => l.article_id)
  if (ids.length > 0) {
    const { data: rows, error: artErr } = await supabase
      .from('scientific_articles')
      .select(SCIENTIFIC_ARTICLE_COLUMNS)
      .eq('status', 'published')
      .eq('is_archived', false)
      .in('id', ids)
    if (!artErr && rows) {
      const bases = rows.map((r) => normalizeScientificArticle(r, lang))
      const byId = new Map(bases.map((a) => [a.id, a]))
      const ordered = links.map((l) => byId.get(l.article_id)).filter(Boolean)
      articles = await mergeLangTranslations(supabase, ordered, lang)
    }
  }

  return {
    author: {
      id: authorRow.id,
      name: authorRow.name,
      slug: authorRow.slug,
      orcid: authorRow.orcid || null,
      institution: authorRow.institution,
      department: authorRow.department,
      role: authorRow.role,
      avatar: authorRow.avatar,
      avatarBg: authorRow.avatar_bg || '#0a844f',
      bio: authorRow.bio,
    },
    articles,
  }
}

/**
 * All scientific articles regardless of status/archive — admin only
 * (RLS restringe a admin; o caller deve garantir a sessão).
 *
 * @returns {Promise<Array<object>>}
 */
export async function getAllScientificArticlesAdmin() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_articles')
    .select(SCIENTIFIC_ARTICLE_COLUMNS)
    .order('created_at', { ascending: false })

  if (error) throw error
  return (data || []).map((row) => normalizeScientificArticle(row))
}
