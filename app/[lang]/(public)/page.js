import dynamic from 'next/dynamic'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getFeaturedArticles } from '@/lib/api/articles'
import { getFeaturedEvents } from '@/lib/api/events'
import { buildOrganizationSchema, buildWebSiteSchema } from '@/lib/seo'
import ToolsShowcase from '@/components/home/ToolsShowcase'
import FeaturedArticles from '@/components/home/FeaturedArticles'
import FeaturedEvents from '@/components/home/FeaturedEvents'
import StatsSection from '@/components/home/StatsSection'


export const revalidate = 3600

// Hero animado — lazy-loaded (P3): o gsap fica num chunk separado e deixa de
// fazer parte do bundle inicial. O fallback replica a estrutura exata do hero
// (mesmas classes/dimensões) para não causar CLS enquanto o chunk carrega.
const HeroAnimated = dynamic(
  () => import('@/components/home/HeroAnimated'),
  {
    loading: () => (
      <div className="hero-animated" aria-hidden="true">
        <div className="hero-ticker-top">
          <span className="hero-ticker-text hero-ticker-text--skeleton" />
          <span className="hero-ticker-text hero-ticker-text--prominent hero-ticker-text--skeleton" />
        </div>
        <div className="hero-animated-card">
          <div className="hero-animated-icon hero-animated-icon--skeleton" />
          <span className="hero-animated-text hero-animated-text--skeleton" />
        </div>
        <div className="hero-ticker-bottom">
          <span className="hero-ticker-text hero-ticker-text--prominent hero-ticker-text--skeleton" />
          <span className="hero-ticker-text hero-ticker-text--skeleton" />
        </div>
      </div>
    ),
  }
)

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

  try {
    const [a, e] = await Promise.all([
      getFeaturedArticles(3, safeLang),
      getFeaturedEvents(2, safeLang),
    ])
    articles = a
    events = e
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

      {/* Ferramentas + Artigos Científicos em destaque */}
      <ToolsShowcase lang={safeLang} tFn={tFn} />

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

      {/* Impacto e Números */}
      <StatsSection />
    </>
  )
}
