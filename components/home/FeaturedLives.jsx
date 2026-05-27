import LiveCard from '@/components/ui/LiveCard'

export default function FeaturedLives({ lives, lang, title = 'Lives e Webinars' }) {
  if (!lives || lives.length === 0) return null

  return (
    <section id="lives" className="section-padding bg-brand-bg-alt">
      <div className="container-center">
        <h2 className="section-title">
          {title}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {lives.map((live) => (
            <LiveCard key={live.slug} live={live} lang={lang} variant="home" />
          ))}
        </div>
      </div>
    </section>
  )
}
