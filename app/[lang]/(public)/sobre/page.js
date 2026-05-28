import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import Image from 'next/image'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('sobre.hero_title')} | Conheça Farmácia`,
    description: tFn('sobre.hero_subtitle'),
    alternates: { languages: { pt: '/pt/sobre', en: '/en/sobre' } },
  }
}

export default async function SobrePage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return (
    <>
      {/* Section 1: Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {tFn('sobre.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {tFn('sobre.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Section 2: Nossa Missão */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="mission-section">
            <h2 className="section-title">{tFn('sobre.missao_title')}</h2>
            <div className="mission-text text-center">
              <p className="mb-6">{tFn('sobre.missao_p1')}</p>
              <p>{tFn('sobre.missao_p2')}</p>
            </div>
          </div>
        </div>
      </section>

      {/* Section 3: O Que Fazemos */}
      <section className="section-padding bg-brand-bg">
        <div className="container-center">
          <h2 className="section-title">{tFn('sobre.oque_title')}</h2>
          <div className="what-we-do-grid">
            <div className="what-we-do-card">
              <img src="/assets/icons/Asset 20-verde.svg" alt="" className="icon-wrapper" />
              <h3 className="text-xl font-bold text-brand-deep mb-3">
                {tFn('sobre.card1_title')}
              </h3>
              <p className="text-brand-deep/70 text-sm leading-relaxed">
                {tFn('sobre.card1_text')}
              </p>
            </div>
            <div className="what-we-do-card">
              <img src="/assets/icons/Asset 16-verde.svg" alt="" className="icon-wrapper" />
              <h3 className="text-xl font-bold text-brand-deep mb-3">
                {tFn('sobre.card2_title')}
              </h3>
              <p className="text-brand-deep/70 text-sm leading-relaxed">
                {tFn('sobre.card2_text')}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Section 4: Público-Alvo */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <h2 className="section-title">{tFn('sobre.publico_title')}</h2>
          <div className="audience-grid">
            <div className="audience-item">
              <img src="/assets/icons/Asset 6-verde.svg" alt="" className="audience-icon" />
              <span className="audience-label">{tFn('sobre.publico_profissionais')}</span>
            </div>
            <div className="audience-item">
              <img src="/assets/icons/Asset 5-verde.svg" alt="" className="audience-icon" />
              <span className="audience-label">{tFn('sobre.publico_estudantes')}</span>
            </div>
            <div className="audience-item">
              <img src="/assets/icons/Asset 13-verde.svg" alt="" className="audience-icon" />
              <span className="audience-label">{tFn('sobre.publico_instituicoes')}</span>
            </div>
            <div className="audience-item">
              <img src="/assets/icons/Asset 38-verde.svg" alt="" className="audience-icon" />
              <span className="audience-label">{tFn('sobre.publico_clinicas')}</span>
            </div>
          </div>
        </div>
      </section>

      {/* Section 5: Pull Quote */}
      <section className="pull-quote-section">
        <div className="pull-quote-container">
          <p className="pull-quote-text">{tFn('sobre.pull_quote')}</p>
        </div>
      </section>

    </>
  )
}
