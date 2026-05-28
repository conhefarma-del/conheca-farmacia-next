import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getArticleBySlug, getArticles } from '@/lib/api/articles'
import { buildArticleSchema, buildBreadcrumbSchema } from '@/lib/seo'
import { ARTICLE_CATEGORY_COLORS, SITE_URL } from '@/lib/constants'
import Breadcrumb from '@/components/ui/Breadcrumb'
import ArticleContent from '@/components/content/ArticleContent'
import ShareSection from '@/components/content/ShareSection'
import RelatedArticles from '@/components/content/RelatedArticles'
import ReadingTimeTracker from '@/components/content/ReadingTimeTracker'
import ViewCountTracker from '@/components/content/ViewCountTracker'
import Image from 'next/image'
import Link from 'next/link'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

function formatDate(dateStr, lang = 'pt') {
  try {
    const date = new Date(dateStr)
    const locale = lang === 'en' ? 'en-US' : 'pt-PT'
    return date.toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
  } catch {
    return dateStr
  }
}

export async function generateStaticParams() {
  try {
    const articles = await getArticles()
    return articles.map((article) => ({ slug: article.slug }))
  } catch {
    return []
  }
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  let article
  try {
    article = await getArticleBySlug(slug)
  } catch {
    return { title: 'Artigo — Conheça Farmácia' }
  }

  if (!article) {
    return { title: 'Artigo não encontrado — Conheça Farmácia' }
  }

  const articleUrl = `${SITE_URL}/${safeLang}/artigos/${article.slug}`

  return {
    title: `${article.title} — Conheça Farmácia`,
    description: article.metaDescription || article.excerpt || article.title,
    alternates: {
      canonical: articleUrl,
      languages: { 'pt': `/pt/artigos/${article.slug}`, 'en': `/en/artigos/${article.slug}` },
    },
    openGraph: {
      title: article.title,
      description: article.metaDescription || article.excerpt,
      url: articleUrl,
      type: 'article',
      publishedTime: article.published_date || article.date,
      authors: [article.author?.name || article.author_name || 'Conheça Farmácia'],
      images: article.image ? [{ url: article.image }] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title: article.title,
      description: article.metaDescription || article.excerpt,
      images: article.image ? [article.image] : [],
    },
  }
}

export default async function ArticleDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  let article
  try {
    article = await getArticleBySlug(slug)
  } catch (err) {
    console.error('Error fetching article:', err)
    notFound()
  }
  if (!article) notFound()

  const color = ARTICLE_CATEGORY_COLORS[article.category] || '#666'
  const articleUrl = `${SITE_URL}/${safeLang}/artigos/${article.slug}`

  // Get related articles
  let relatedArticles = []
  try {
    const allArticles = await getArticles()
    relatedArticles = allArticles
      .filter((a) => a.category === article.category && a.slug !== article.slug)
      .slice(0, 4)
  } catch {}

  // Breadcrumb levels
  const breadcrumbLevels = [
    { label: tFn('nav.inicio'), href: `/${safeLang}` },
    { label: tFn('nav.artigos'), href: `/${safeLang}/artigos` },
    { label: article.title },
  ]

  // JSON-LD schemas
  const articleSchema = buildArticleSchema(article, safeLang)
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbLevels.map((l) => ({
      ...l,
      href: l.href ? `${SITE_URL}${l.href}` : undefined,
    }))
  )

  const authorName = article.author?.name || article.author_name || 'CF'
  const authorInitials = authorName
    .split(' ')
    .map((w) => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <>
      {/* JSON-LD */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(articleSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />

      {/* Analytics trackers */}
      <ViewCountTracker articleSlug={article.slug} />
      <ReadingTimeTracker articleId={article.id} />

      {/* Breadcrumb */}
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbLevels} />
      </nav>

      {/* Article Hero Section */}
      <article className="article-hero">
        <div className="container-center">
          {/* Category Badge */}
          <div className="mb-6">
            <span
              className="article-tag"
              style={{
                backgroundColor: `${color}20`,
                color: color,
                border: `1px solid ${color}40`,
              }}
            >
              {article.categoryLabel}
            </span>
          </div>

          {/* Title */}
          <h1 className="article-hero-title mb-10">{article.title}</h1>

          {/* Featured Image */}
          {article.image && (
            <div className="article-hero-image-wrapper mb-12">
              <Image
                src={article.image}
                alt={article.title}
                width={1200}
                height={600}
                className="article-featured-image"
                unoptimized
                priority
              />
            </div>
          )}

          {/* Meta Information */}
          <div className="article-meta-bar">
            <div className="flex items-center gap-3">
              <div
                className="article-author-avatar"
                style={{ backgroundColor: article.author?.avatarBg || color }}
              >
                {authorInitials}
              </div>
              <div>
                <div className="font-semibold text-sm">{authorName}</div>
                {article.author?.role && (
                  <div className="text-xs text-brand-deep/60">{article.author.role}</div>
                )}
              </div>
            </div>
            <span className="text-sm text-brand-deep/60">·</span>
            {article.date && <time className="text-sm text-brand-deep/60" dateTime={article.published_date || article.date}>{formatDate(article.date, safeLang)}</time>}
            <span className="text-sm text-brand-deep/60">·</span>
            {article.readTime && <div className="text-sm text-brand-deep/60">{article.readTime} min leitura</div>}
          </div>
        </div>
      </article>

      {/* Article Content */}
      <section className="article-content-section">
        <div className="container-center">
          <div className="article-grid">
            {/* Main Content */}
            <div className="article-body-wrapper">
              <div className="article-body">
                <ArticleContent content={article.content} />
              </div>
            </div>

            {/* Sidebar: Author Card */}
            <aside className="article-sidebar">
              <div className="author-card-detailed">
                <div
                  className="author-card-avatar-lg"
                  style={{ backgroundColor: article.author?.avatarBg || color }}
                >
                  {authorInitials}
                </div>
                {article.author?.role && (
                  <div className="author-card-role">{article.author.role}</div>
                )}
                <h3 className="author-card-name-lg">{authorName}</h3>
                {article.author?.bio && (
                  <p className="author-card-bio">{article.author.bio}</p>
                )}
              </div>
            </aside>
          </div>
        </div>
      </section>

      {/* References */}
      {article.references && article.references.length > 0 && (
        <section className="article-references-section">
          <div className="container-center">
            <h2 className="section-title mb-8">{tFn('artigo_detail.references')}</h2>
            <div className="article-references-list">
              {article.references.map((ref, i) => (
                <div key={i} className="reference-item">
                  <span className="reference-number">{i + 1}.</span>
                  <span className="reference-text">{ref}</span>
                </div>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* Share */}
      <ShareSection
        articleId={article.id}
        articleSlug={article.slug}
        title={article.title}
        url={articleUrl}
      />

      {/* Related Articles */}
      <section className="article-related-section">
        <div className="container-center">
          <h2 className="section-title mb-12">{tFn('artigo_detail.related_articles')}</h2>
          <RelatedArticles articles={relatedArticles} lang={safeLang} />
        </div>
      </section>

      {/* Back to Articles CTA */}
      <section className="py-16 bg-brand-bg-alt">
        <div className="container-center text-center">
          <Link href={`/${safeLang}/artigos`} className="btn btn-primary">
            ← {tFn('artigo_detail.back_to_articles')}
          </Link>
        </div>
      </section>
    </>
  )
}
