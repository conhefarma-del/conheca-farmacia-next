import ArticleCard from '@/components/ui/ArticleCard'

export default function FeaturedArticles({ articles, lang, title = 'Artigos em Destaque' }) {
  if (!articles || articles.length === 0) return null

  return (
    <section id="artigos" className="section-padding bg-brand-bg-alt">
      <div className="container-center">
        <h2 className="section-title text-3xl font-bold text-center mb-10">
          {title}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {articles.map((article) => (
            <ArticleCard key={article.slug} article={article} lang={lang} />
          ))}
        </div>
      </div>
    </section>
  )
}
