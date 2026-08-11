import { createClient } from '@/lib/supabase/server'
import { getArticles } from '@/lib/api/articles'
import { getEvents } from '@/lib/api/events'
import { getLives } from '@/lib/api/lives'

export const revalidate = 43200 // 12 horas

const SITE_URL = 'https://conhecafarmacia.com'
const LOCALES = ['pt', 'en']

/**
 * Carrega todas as traduções EN existentes, agrupadas por tipo de entidade
 * e por entity_id. Devolve um Map<id, translationRow>.
 */
async function loadEnTranslationsMap(table) {
  try {
    const supabase = await createClient()
    const { data } = await supabase
      .from(table)
      .select('*')
      .eq('lang', 'en')
    return new Map((data ?? []).map((row) => [row.article_id || row.event_id || row.live_id, row]))
  } catch (err) {
    console.error(`[sitemap] loadEnTranslationsMap(${table}):`, err)
    return new Map()
  }
}

export default async function sitemap() {
  // Páginas estáticas × idiomas. Os slugs estruturais diferem entre línguas
  // (ver lib/i18n-routes.js): /pt/artigos ↔ /en/articles, /pt/interacoes ↔
  // /en/interactions, /pt/medicamentos ↔ /en/medicines, etc. O mapa usa o
  // path correto em cada língua (em vez do mesmo slug nas duas).
  const SECTION_PATHS = {
    '':            { pt: '',            en: '' },
    artigos:       { pt: '/artigos',    en: '/articles' },
    cientificos:   { pt: '/cientificos', en: '/cientificos' },
    eventos:       { pt: '/eventos',    en: '/events' },
    lives:         { pt: '/lives',      en: '/lives' },
    sobre:         { pt: '/sobre',      en: '/about' },
    pesquisa:      { pt: '/pesquisa',   en: '/search' },
    interacoes:    { pt: '/interacoes', en: '/interactions' },
    medicamentos:  { pt: '/medicamentos', en: '/medicines' },
  }
  const staticEntries = Object.entries(SECTION_PATHS).flatMap(([path, paths]) =>
    LOCALES.map((lang) => ({
      url: `${SITE_URL}/${lang}${paths[lang]}`,
      changeFrequency: path === '' ? 'daily' : 'weekly',
      priority: path === '' ? 1.0 : 0.8,
      alternates: {
        languages: Object.fromEntries(
          LOCALES.map((l) => [l, `${SITE_URL}/${l}${paths[l]}`])
        ),
      },
    }))
  )

  // Artigos: 1 entry PT + 1 entry EN (se houver tradução, com slug EN)
  let articleEntries = []
  try {
    const articles = await getArticles()
    const tMap = await loadEnTranslationsMap('article_translations')
    articleEntries = articles.flatMap((article) => {
      const t = tMap.get(article.id)
      const lastmod = t?.updated_at || article.updated_at || article.published_date
      const entries = [
        {
          url: `${SITE_URL}/pt/artigos/${article.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/artigos/${article.slug}`,
              ...(t && { en: `${SITE_URL}/en/articles/${t.slug}` }),
              'x-default': `${SITE_URL}/pt/artigos/${article.slug}`,
            },
          },
        },
      ]
      if (t) {
        entries.push({
          url: `${SITE_URL}/en/articles/${t.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/artigos/${article.slug}`,
              en: `${SITE_URL}/en/articles/${t.slug}`,
              'x-default': `${SITE_URL}/pt/artigos/${article.slug}`,
            },
          },
        })
      }
      return entries
    })
  } catch {}

  // Eventos: 1 entry PT + 1 entry EN (se houver tradução)
  let eventEntries = []
  try {
    const events = await getEvents()
    const tMap = await loadEnTranslationsMap('event_translations')
    eventEntries = events.flatMap((event) => {
      const t = tMap.get(event.id)
      const lastmod = t?.updated_at || event.updated_at || event.date
      const entries = [
        {
          url: `${SITE_URL}/pt/eventos/${event.slug}`,
          lastModified: lastmod,
          changeFrequency: 'weekly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/eventos/${event.slug}`,
              ...(t && { en: `${SITE_URL}/en/events/${t.slug}` }),
              'x-default': `${SITE_URL}/pt/eventos/${event.slug}`,
            },
          },
        },
      ]
      if (t) {
        entries.push({
          url: `${SITE_URL}/en/events/${t.slug}`,
          lastModified: lastmod,
          changeFrequency: 'weekly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/eventos/${event.slug}`,
              en: `${SITE_URL}/en/events/${t.slug}`,
              'x-default': `${SITE_URL}/pt/eventos/${event.slug}`,
            },
          },
        })
      }
      return entries
    })
  } catch {}

  // Lives: 1 entry PT + 1 entry EN (se houver tradução)
  let liveEntries = []
  try {
    const lives = await getLives()
    const tMap = await loadEnTranslationsMap('live_translations')
    liveEntries = lives.flatMap((live) => {
      const t = tMap.get(live.id)
      const lastmod = t?.updated_at || live.updated_at || live.data || live.date
      const entries = [
        {
          url: `${SITE_URL}/pt/lives/${live.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.5,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/lives/${live.slug}`,
              ...(t && { en: `${SITE_URL}/en/lives/${t.slug}` }),
              'x-default': `${SITE_URL}/pt/lives/${live.slug}`,
            },
          },
        },
      ]
      if (t) {
        entries.push({
          url: `${SITE_URL}/en/lives/${t.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.5,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/lives/${live.slug}`,
              en: `${SITE_URL}/en/lives/${t.slug}`,
              'x-default': `${SITE_URL}/pt/lives/${live.slug}`,
            },
          },
        })
      }
      return entries
    })
  } catch {}

  // Fármacos: o slug é PARTILHADO entre línguas (não há tabela de traduções
  // de slug — a página resolve o mesmo slug em /medicamento/{slug} e
  // /medicine/{slug} via getPublicDrugBySlug). 1 entry por língua, com
  // alternates para a outra.
  let drugEntries = []
  try {
    const supabase = await createClient()
    const { data: drugs } = await supabase
      .from('drugs')
      .select('slug, updated_at')
      .eq('status', 'published')
      .eq('is_archived', false)
    drugEntries = (drugs ?? []).flatMap((drug) => {
      const lastmod = drug.updated_at || undefined
      const urls = {
        pt: `${SITE_URL}/pt/medicamento/${drug.slug}`,
        en: `${SITE_URL}/en/medicine/${drug.slug}`,
      }
      return LOCALES.map((lang) => ({
        url: urls[lang],
        lastModified: lastmod,
        changeFrequency: 'monthly',
        priority: 0.6,
        alternates: {
          languages: {
            ...urls,
            'x-default': urls.pt,
          },
        },
      }))
    })
  } catch {}

  // Artigos científicos: 1 entry PT + 1 entry EN (se houver tradução),
  // rota própria /cientificos (partilhada entre línguas, slug EN diferente).
  let scientificEntries = []
  try {
    const supabase = await createClient()
    const { data: sciArticles } = await supabase
      .from('scientific_articles')
      .select('id, slug, updated_at, published_at')
      .eq('status', 'published')
      .eq('is_archived', false)
    const tMap = await loadEnTranslationsMap('scientific_article_translations')
    scientificEntries = (sciArticles ?? []).flatMap((article) => {
      const t = tMap.get(article.id)
      const lastmod = t?.updated_at || article.updated_at || article.published_at
      const entries = [
        {
          url: `${SITE_URL}/pt/cientificos/${article.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/cientificos/${article.slug}`,
              ...(t && { en: `${SITE_URL}/en/cientificos/${t.slug}` }),
              'x-default': `${SITE_URL}/pt/cientificos/${article.slug}`,
            },
          },
        },
      ]
      if (t) {
        entries.push({
          url: `${SITE_URL}/en/cientificos/${t.slug}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.6,
          alternates: {
            languages: {
              pt: `${SITE_URL}/pt/cientificos/${article.slug}`,
              en: `${SITE_URL}/en/cientificos/${t.slug}`,
              'x-default': `${SITE_URL}/pt/cientificos/${article.slug}`,
            },
          },
        })
      }
      return entries
    })
  } catch {}

  return [...staticEntries, ...articleEntries, ...eventEntries, ...liveEntries, ...scientificEntries, ...drugEntries]
}
