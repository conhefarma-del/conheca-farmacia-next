import { getArticles } from '@/lib/api/articles'
import { getEvents } from '@/lib/api/events'
import { getLives } from '@/lib/api/lives'

export const revalidate = 43200 // 12 horas

const SITE_URL = 'https://conhecafarmacia.vercel.app'
const LOCALES = ['pt', 'en']

export default async function sitemap() {
  // Páginas estáticas × idiomas
  const staticPaths = ['', '/artigos', '/eventos', '/lives', '/sobre', '/pesquisa']
  const staticEntries = staticPaths.flatMap((path) =>
    LOCALES.map((lang) => ({
      url: `${SITE_URL}/${lang}${path}`,
      changeFrequency: path === '' ? 'daily' : 'weekly',
      priority: path === '' ? 1.0 : 0.8,
      alternates: {
        languages: Object.fromEntries(
          LOCALES.map((l) => [l, `${SITE_URL}/${l}${path}`])
        ),
      },
    }))
  )

  // Artigos × idiomas
  let articleEntries = []
  try {
    const articles = await getArticles()
    articleEntries = articles.flatMap((article) =>
      LOCALES.map((lang) => ({
        url: `${SITE_URL}/${lang}/artigos/${article.slug}`,
        lastModified: article.updated_at || article.published_date,
        changeFrequency: 'monthly',
        priority: 0.6,
        alternates: {
          languages: Object.fromEntries(
            LOCALES.map((l) => [l, `${SITE_URL}/${l}/artigos/${article.slug}`])
          ),
        },
      }))
    )
  } catch {}

  // Eventos × idiomas
  let eventEntries = []
  try {
    const events = await getEvents()
    eventEntries = events.flatMap((event) =>
      LOCALES.map((lang) => ({
        url: `${SITE_URL}/${lang}/eventos/${event.slug}`,
        lastModified: event.updated_at || event.date,
        changeFrequency: 'weekly',
        priority: 0.6,
        alternates: {
          languages: Object.fromEntries(
            LOCALES.map((l) => [l, `${SITE_URL}/${l}/eventos/${event.slug}`])
          ),
        },
      }))
    )
  } catch {}

  // Lives × idiomas
  let liveEntries = []
  try {
    const lives = await getLives()
    liveEntries = lives.flatMap((live) =>
      LOCALES.map((lang) => ({
        url: `${SITE_URL}/${lang}/lives/${live.slug}`,
        lastModified: live.updated_at || live.data || live.date,
        changeFrequency: 'monthly',
        priority: 0.5,
        alternates: {
          languages: Object.fromEntries(
            LOCALES.map((l) => [l, `${SITE_URL}/${l}/lives/${live.slug}`])
          ),
        },
      }))
    )
  } catch {}

  return [...staticEntries, ...articleEntries, ...eventEntries, ...liveEntries]
}
