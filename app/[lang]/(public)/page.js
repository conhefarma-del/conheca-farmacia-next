import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getFeaturedArticles } from '@/lib/api/articles'
import { getFeaturedEvents } from '@/lib/api/events'
import { getFeaturedLives } from '@/lib/api/lives'
import { buildOrganizationSchema, buildWebSiteSchema } from '@/lib/seo'
import HeroAnimated from '@/components/home/HeroAnimated'
import FeaturedArticles from '@/components/home/FeaturedArticles'
import FeaturedEvents from '@/components/home/FeaturedEvents'
import FeaturedLives from '@/components/home/FeaturedLives'
import StatsSection from '@/components/home/StatsSection'


export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('hero.title')} | Conheça Farmácia`,
    description: tFn('hero.subtitle'),
    alternates: { languages: { pt: '/pt', en: '/en' } },
  }
}

export default async function HomePage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  let articles = []
  let events = []
  let lives = []

  try {
    const [a, e, l] = await Promise.all([
      getFeaturedArticles(3),
      getFeaturedEvents(2),
      getFeaturedLives(2),
    ])
    articles = a
    events = e
    lives = l
  } catch (err) {
    console.error('Error fetching homepage data:', err)
  }

  const orgSchema = buildOrganizationSchema()
  const siteSchema = buildWebSiteSchema()

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(orgSchema) }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(siteSchema) }} />

      {/* Hero Section */}
      <section id="inicio" className="hero">
        <div className="hero-container">
          {/* Left Column: Text and CTA */}
          <div className="hero-content">
            <h1 className="hero-title">
              {tFn('hero.title')}
            </h1>
            <p className="hero-subtitle">
              {tFn('hero.subtitle')}
            </p>
            <div className="hero-actions">
              <a
                href="https://wa.me/244925696002?text=Olá,%20Conheça%20Farmácia"
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-primary"
              >
                {tFn('hero.cta')}
              </a>
            </div>
          </div>

          {/* Right Column: Animated Card */}
          <HeroAnimated />
        </div>
      </section>

      {/* Artigos em Destaque */}
      <FeaturedArticles
        articles={articles}
        lang={safeLang}
        title={tFn('home.artigos_destaque')}
      />

      {/* Eventos em Destaque */}
      <FeaturedEvents
        events={events}
        lang={safeLang}
        title={tFn('home.eventos_destaque')}
      />

      {/* Lives e Webinars */}
      <FeaturedLives
        lives={lives}
        lang={safeLang}
        title={tFn('home.lives_webinars')}
      />

      {/* Impacto e Números */}
      <StatsSection />
    </>
  )
}
