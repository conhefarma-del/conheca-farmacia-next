import { createClient } from '@/lib/supabase/server'
import { getArticles } from '@/lib/api/articles'
import { getEvents } from '@/lib/api/events'
import { featureEnabled } from '@/lib/features'

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
    'cientificos/autores': { pt: '/cientificos/autores', en: '/cientificos/autores' },
    eventos:       { pt: '/eventos',    en: '/events' },
    entrevistas:   { pt: '/entrevistas', en: '/entrevistas' },
    'entrevistas/entrevistados': { pt: '/entrevistas/entrevistados', en: '/entrevistas/entrevistados' },
    flashcards:    { pt: '/flashcards', en: '/flashcards' },
    praticar:      { pt: '/praticar',   en: '/praticar' },
    quiz:          { pt: '/quiz',       en: '/quiz' },
    sobre:         { pt: '/sobre',      en: '/about' },
    pesquisa:      { pt: '/pesquisa',   en: '/search' },
    interacoes:    { pt: '/interacoes', en: '/interactions' },
    medicamentos:  { pt: '/medicamentos', en: '/medicines' },
    faq:           { pt: '/faq',        en: '/faq' },
    'politica-privacidade': { pt: '/politica-privacidade', en: '/privacy-policy' },
    inscricao:     { pt: '/inscricao',  en: '/register' },
  }

  // Secções ocultas (lib/features.js): não entram no sitemap
  if (!featureEnabled('cientificos')) {
    delete SECTION_PATHS.cientificos
    delete SECTION_PATHS['cientificos/autores']
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

  // Lives/webinars fundidas em Eventos (migração 159) — sem entries próprias

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

  // Protocolos: ocultos via lib/features.js — fora do sitemap enquanto desligados
  let protocolEntries = []
  if (featureEnabled('protocolos')) {
  try {
    const supabase = await createClient()
    const { data: protocols } = await supabase
      .from('clinical_protocols')
      .select('slug, updated_at')
      .eq('status', 'published')
      .eq('is_archived', false)
    protocolEntries = (protocols ?? []).flatMap((protocol) => {
      const lastmod = protocol.updated_at || undefined
      const urls = {
        pt: `${SITE_URL}/pt/protocolos/${protocol.slug}`,
        en: `${SITE_URL}/en/protocols/${protocol.slug}`,
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
  }

  // Guias de estudo: slug PARTILHADO entre línguas — /pt/guias/{slug} ↔
  // /en/guides/{slug} (confirmado no generateMetadata). 1 entry por língua.
  let guideEntries = []
  try {
    const supabase = await createClient()
    const { data: courses } = await supabase
      .from('guide_courses')
      .select('slug, updated_at')
      .eq('status', 'published')
      .eq('is_archived', false)
    guideEntries = (courses ?? []).flatMap((course) => {
      const lastmod = course.updated_at || undefined
      const urls = {
        pt: `${SITE_URL}/pt/guias/${course.slug}`,
        en: `${SITE_URL}/en/guides/${course.slug}`,
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

  // Entrevistas: módulo apenas PT por agora (migration 152).
  let interviewEntries = []
  try {
    const supabase = await createClient()
    const { data: interviews } = await supabase
      .from('interviews')
      .select('slug, updated_at, date')
      .eq('status', 'published')
      .eq('is_archived', false)
    interviewEntries = (interviews ?? []).map((it) => ({
      url: `${SITE_URL}/pt/entrevistas/${it.slug}`,
      lastModified: it.updated_at || it.date || undefined,
      changeFrequency: 'monthly',
      priority: 0.6,
      alternates: {
        languages: {
          pt: `${SITE_URL}/pt/entrevistas/${it.slug}`,
          'x-default': `${SITE_URL}/pt/entrevistas/${it.slug}`,
        },
      },
    }))
  } catch {}

  // Entrevistados (154): slug PARTILHADO entre línguas (módulo só PT por
  // agora). Só pessoas ligadas a entrevistas publicadas e não arquivadas.
  let interviewPeopleEntries = []
  try {
    const supabase = await createClient()
    const { data: links } = await supabase
      .from('interview_person_links')
      .select('person_id')
      .in(
        'interview_id',
        supabase
          .from('interviews')
          .select('id')
          .eq('status', 'published')
          .eq('is_archived', false)
      )
    const ids = [...new Set((links ?? []).map((l) => l.person_id))]
    if (ids.length > 0) {
      const { data: people } = await supabase
        .from('interview_people')
        .select('slug, updated_at')
        .in('id', ids)
      interviewPeopleEntries = (people ?? []).map((person) => ({
        url: `${SITE_URL}/pt/entrevistas/entrevistados/${person.slug}`,
        lastModified: person.updated_at || undefined,
        changeFrequency: 'monthly',
        priority: 0.5,
        alternates: {
          languages: {
            pt: `${SITE_URL}/pt/entrevistas/entrevistados/${person.slug}`,
            'x-default': `${SITE_URL}/pt/entrevistas/entrevistados/${person.slug}`,
          },
        },
      }))
    }
  } catch {}

  // Artigos científicos: ocultos via lib/features.js — fora do sitemap
  let scientificEntries = []
  if (featureEnabled('cientificos')) {
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
  }
  // publicados e não arquivados (RLS anónima).
  let flashcardEntries = []
  try {
    const supabase = await createClient()
    const { data: decks } = await supabase
      .from('flashcard_decks')
      .select('slug, updated_at')
      .eq('status', 'published')
      .eq('is_archived', false)
    flashcardEntries = (decks ?? []).map((deck) => ({
      url: `${SITE_URL}/pt/flashcards/${deck.slug}`,
      lastModified: deck.updated_at || undefined,
      changeFrequency: 'weekly',
      priority: 0.6,
      alternates: {
        languages: {
          pt: `${SITE_URL}/pt/flashcards/${deck.slug}`,
          en: `${SITE_URL}/en/flashcards/${deck.slug}`,
          'x-default': `${SITE_URL}/pt/flashcards/${deck.slug}`,
        },
      },
    }))
  } catch {}

  // Autores científicos (144/145): slug PARTILHADO entre línguas. Cada autor
  // tem duas páginas — artigos (/cientificos/autores/{slug}) e perfil
  // (/cientificos/autores/{slug}/perfil). A RLS anónima de scientific_authors
  // só expõe autores ligados a artigos publicados e não arquivados, por isso
  // rascunhos ficam automaticamente fora do sitemap.
  let authorEntries = []
  if (featureEnabled('cientificos')) {
  try {
    const supabase = await createClient()
    const { data: authors } = await supabase
      .from('scientific_authors')
      .select('slug, updated_at')
    authorEntries = (authors ?? []).flatMap((author) => {
      const lastmod = author.updated_at || undefined
      const suffixes = ['', '/perfil']
      return LOCALES.flatMap((lang) =>
        suffixes.map((suffix) => ({
          url: `${SITE_URL}/${lang}/cientificos/autores/${author.slug}${suffix}`,
          lastModified: lastmod,
          changeFrequency: 'monthly',
          priority: 0.5,
          alternates: {
            languages: {
              ...Object.fromEntries(
                LOCALES.map((l) => [l, `${SITE_URL}/${l}/cientificos/autores/${author.slug}${suffix}`])
              ),
              'x-default': `${SITE_URL}/pt/cientificos/autores/${author.slug}${suffix}`,
            },
          },
        }))
      )
    })
  } catch {}
  }

  return [
    ...staticEntries,
    ...articleEntries,
    ...eventEntries,
    ...interviewEntries,
    ...interviewPeopleEntries,
    ...scientificEntries,
    ...authorEntries,
    ...flashcardEntries,
    ...drugEntries,
    ...protocolEntries,
    ...guideEntries,
  ]
}
