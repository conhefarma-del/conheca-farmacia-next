import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificArticleBySlug, getScientificArticles, findRelatedScientificArticles } from '@/lib/api/scientific-articles'
import { linkReferenceText } from '@/lib/utils/reference-links'
import { buildCoins } from '@/lib/citation'
import { buildBreadcrumbSchema, buildScholarlyArticleSchema } from '@/lib/seo'
import { SITE_URL } from '@/lib/constants'
import Breadcrumb from '@/components/ui/Breadcrumb'
import ScientificArticleContent from '@/components/content/ScientificArticleContent'
import CitationWidget from '@/components/content/CitationWidget'
import CitedByBadge from '@/components/content/CitedByBadge'
import ArticleLangToggle from '@/components/content/ArticleLangToggle'
import AuthorMenu from '@/components/content/AuthorMenu'
import ArticleViewCounter from '@/components/content/ArticleViewCounter'
import ShareSection from '@/components/content/ShareSection'
import { Clock } from 'lucide-react'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

function slugifyHeading(text) {
  return String(text)
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

function extractHeadings(markdown) {
  const out = []
  for (const line of String(markdown || '').split('\n')) {
    const m = line.match(/^##\s+(.+)$/)
    if (m) out.push({ id: slugifyHeading(m[1]), text: m[1].trim() })
  }
  return out
}

function formatDate(dateStr, lang = 'pt') {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  try {
    return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
  } catch {
    return dateStr
  }
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  let article
  try {
    article = await getScientificArticleBySlug(slug, safeLang)
  } catch {
    return { title: 'Artigo Científico — Conheça Farmácia' }
  }
  if (!article) {
    return { title: 'Artigo não encontrado — Conheça Farmácia' }
  }

  const articleUrl = `${SITE_URL}/${safeLang}/cientificos/${article.slug}`

  return {
    title: `${article.title} — Conheça Farmácia`,
    description: article.abstract || article.excerpt || article.title,
    alternates: {
      canonical: articleUrl,
      languages: {
        pt: `${SITE_URL}/pt/cientificos/${article.langSlugs?.pt || article.slug}`,
        ...(article.langSlugs?.en ? { en: `${SITE_URL}/en/cientificos/${article.langSlugs.en}` } : {}),
      },
    },
    openGraph: {
      title: article.title,
      description: article.abstract || article.title,
      url: articleUrl,
      type: 'article',
      publishedTime: article.publishedAt || undefined,
      authors: (article.authors || []).map((a) => a.name),
    },
    // Highwire Press citation meta tags (Google Scholar) — server-side,
    // sem JS no cliente (CSP). Arrays geram múltiplas <meta> com o mesmo name.
    other: {
      'citation_title': article.title,
      'citation_author': (article.authors || []).map((a) => a.name),
      'citation_publication_date': (article.date || '').replace(/-/g, '/'),
      'citation_journal_title': 'Conheça Farmácia',
      'citation_language': safeLang === 'en' ? 'en' : 'pt',
      'citation_keywords': article.keywords || [],
      ...(article.doi ? { 'citation_doi': article.doi } : {}),
      ...(article.abstract ? { 'citation_abstract': article.abstract } : {}),
    },
  }
}

export default async function CientificoDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  let article
  try {
    article = await getScientificArticleBySlug(slug, safeLang)
  } catch (err) {
    console.error('Error fetching scientific article:', err)
    notFound()
  }
  if (!article) notFound()

  const color = article.category?.color || '#0a844f'
  const langSlugs = article.langSlugs || { pt: article.slug, en: null }
  const articleUrl = `${SITE_URL}/${safeLang}/cientificos/${article.slug}`
  // Citação usa o URL PT canónico (independente da língua renderizada)
  const citationUrl = `${SITE_URL}/pt/cientificos/${langSlugs.pt}`
  // COinS (Zotero captura a citação automaticamente)
  const coins = buildCoins(article, citationUrl)

  // TOC gerado dos h2 do corpo
  const headings = extractHeadings(article.content)

  // Relacionados por similaridade de keywords (score = keywords em comum),
  // com fallback/desempate por mesma categoria — ver findRelatedScientificArticles
  let related = []
  try {
    const all = await getScientificArticles(safeLang)
    related = findRelatedScientificArticles(article, all, { limit: 4 })
  } catch {}

  const breadcrumbLevels = [
    { label: tFn('nav.inicio'), href: `/${safeLang}` },
    { label: tFn('nav.artigos'), href: `/${safeLang}/artigos` },
    { label: tFn('cientifico_detail.back_to_cientificos'), href: `/${safeLang}/cientificos` },
    { label: article.title },
  ]
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbLevels.map((l) => ({ ...l, href: l.href ? `${SITE_URL}${l.href}` : undefined }))
  )
  const scholarlySchema = buildScholarlyArticleSchema(article, safeLang)

  return (
    <>
      {/* JSON-LD */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />
      {scholarlySchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(scholarlySchema) }}
        />
      )}

      {/* Breadcrumb */}
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbLevels} />
      </nav>

      <div className="sci-layout">
        {/* Contador de leituras (mais lido) — renderiza nada, incrementa via RPC */}
        <ArticleViewCounter articleId={article.id} />

        {/* ===== COLUNA PRINCIPAL 2/3 ===== */}
        <main className="sci-main">
          {/* Hero */}
          <header className="sci-hero">
            <div className="sci-hero-badges">
              {article.category && (
                <span className="sci-badge sci-badge-cat" style={{ background: `${color}1a`, color }}>
                  {article.category.name}
                </span>
              )}
              <span className="sci-badge sci-badge-lang">
                {(article.lang || safeLang).toUpperCase()}
              </span>
              <ArticleLangToggle lang={safeLang} langSlugs={langSlugs} />
            </div>
            <h1 className="sci-hero-title">{article.title}</h1>

            <div className="sci-hero-meta">
              {article.date && <time dateTime={article.publishedAt}>{formatDate(article.date, safeLang)}</time>}
              {article.readTime && (
                <>
                  <span>·</span>
                  <span className="sci-hero-meta-readtime">
                    <Clock size={13} aria-hidden="true" />
                    {article.readTime} {tFn('cientifico_detail.min_read')}
                  </span>
                </>
              )}
              {article.doi && (
                <>
                  <span>·</span>
                  <span>{tFn('cientifico_detail.doi')}: {article.doi}</span>
                </>
              )}
            </div>
          </header>

          {/* Autores — acima do resumo, com nomes clicáveis (menu: artigos do autor / perfil) */}
          {(article.authors || []).length > 0 && (
            <section className="sci-authors-section">
              <div className="sci-section-title">{tFn('cientifico_detail.authors')}</div>
              <div className="sci-authors-grid">
                {article.authors.map((a, i) => (
                  <div key={i} className="sci-author-card">
                    <span className="sci-avatar" style={{ background: a.avatarBg || color }}>
                      {(a.avatar || (a.name || '?')[0]).toUpperCase()}
                    </span>
                    <div className="sci-author-info">
                      <AuthorMenu author={a} lang={safeLang} />
                      {(a.institution || a.department) && (
                        <div className="sci-author-inst">
                          {[a.institution, a.department].filter(Boolean).join(' · ')}
                        </div>
                      )}
                    </div>
                    {a.corresponding && (
                      <span className="sci-corresponding-dot" title="Autor correspondente" />
                    )}
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Abstract */}
          {article.abstract && (
            <div className="sci-abstract-box">
              <div className="sci-abstract-label">{tFn('cientifico_detail.abstract')}</div>
              <p className="sci-abstract-text">{article.abstract}</p>
            </div>
          )}

          {/* Sobre este artigo — fonte original, DOI, licença e nota de tradução */}
          {(article.journal || article.doi || article.license) && (
            <section className="sci-about-box">
              <div className="sci-about-title">{tFn('cientifico_detail.about_article')}</div>
              <dl className="sci-about-grid">
                {article.journal && (
                  <div className="sci-about-row">
                    <dt>{tFn('cientifico_detail.original_source')}</dt>
                    <dd>
                      {article.journal}
                      {article.volume ? ` · ${article.volume}${article.issue ? `(${article.issue})` : ''}` : ''}
                      {article.pages ? ` · ${article.pages}` : ''}
                      {article.date ? ` · ${article.date.slice(0, 4)}` : ''}
                    </dd>
                  </div>
                )}
                {article.doi && (
                  <div className="sci-about-row">
                    <dt>DOI</dt>
                    <dd>
                      <a
                        href={`https://doi.org/${article.doi}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="sci-about-doi"
                      >
                        {article.doi}
                      </a>
                    </dd>
                  </div>
                )}
                {article.license && (
                  <div className="sci-about-row">
                    <dt>{tFn('cientifico_detail.license')}</dt>
                    <dd>
                      {article.licenseUrl ? (
                        <a
                          href={article.licenseUrl}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="sci-about-license"
                        >
                          {article.license}
                        </a>
                      ) : (
                        article.license
                      )}
                    </dd>
                  </div>
                )}
                {article.doi && (
                  <div className="sci-about-row">
                    <dt>{tFn('cientifico_detail.cited_by')}</dt>
                    <dd>
                      <CitedByBadge doi={article.doi} variant="count" />
                    </dd>
                  </div>
                )}
              </dl>
              <p className="sci-about-note">{tFn('cientifico_detail.translation_note')}</p>
            </section>
          )}

          {/* Keywords */}
          {(article.keywords || []).length > 0 && (
            <div className="sci-keywords-row">
              {article.keywords.map((kw, i) => (
                <span key={i} className="sci-keyword-tag">{kw}</span>
              ))}
            </div>
          )}

          {/* Corpo do artigo */}
          <article className="sci-body" id="sci-body">
            <ScientificArticleContent content={article.content} />
          </article>

          {/* COinS — invisível; o Zotero usa <span class="Z3988"> para capturar a citação */}
          <span className="Z3988" title={coins} aria-hidden="true" />

          {/* Citação */}
          <CitationWidget article={article} url={citationUrl} />

          {/* Referências — com ids (#ref-n para as citações [n] do corpo) e DOI/PMID ligados */}
          {(article.references || []).length > 0 && (
            <section className="sci-references-section">
              <div className="sci-section-title">{tFn('cientifico_detail.references')}</div>
              <ul className="sci-references-list">
                {article.references.map((ref, i) => (
                  <li key={i} id={`ref-${i + 1}`} className="sci-reference-item">
                    <span dangerouslySetInnerHTML={{ __html: linkReferenceText(ref) }} />
                    <a
                      href="#sci-body"
                      className="sci-ref-back"
                      title={tFn('cientifico_detail.back_to_text')}
                      aria-label={tFn('cientifico_detail.back_to_text')}
                    >
                      ↑
                    </a>
                  </li>
                ))}
              </ul>
            </section>
          )}

          {/* Artigos relacionados — após as referências (mesma categoria) */}
          {related.length > 0 && (
            <section className="sci-related-section">
              <div className="sci-section-title">{tFn('cientifico_detail.related')}</div>
              <div className="sci-related-cards">
                {related.map((r) => {
                  const rCat = r.category
                  const rColor = rCat?.color || '#0a844f'
                  return (
                    <Link key={r.slug} href={`/${safeLang}/cientificos/${r.slug}`} className="sci-related-card">
                      {rCat && (
                        <span className="sci-category-badge" style={{ background: `${rColor}1a`, color: rColor }}>
                          {rCat.name}
                        </span>
                      )}
                      <h3 className="sci-related-card-title">{r.title}</h3>
                      <div className="sci-related-card-meta">
                        <time>{formatDate(r.date, safeLang)}</time>
                        {r.readTime && (
                          <>
                            <span>·</span>
                            <span>{r.readTime} {tFn('cientifico_detail.min_read')}</span>
                          </>
                        )}
                      </div>
                    </Link>
                  )
                })}
              </div>
            </section>
          )}
        </main>

        {/* ===== SIDEBAR 1/3 ===== */}
        <aside className="sci-sidebar">
          {article.doi && (
            <div className="sci-sidebar-card sci-sidebar-hide-mobile">
              <div className="sci-sidebar-label">{tFn('cientifico_detail.doi')}</div>
              <div className="sci-doi-box">{article.doi}</div>
            </div>
          )}

          {headings.length > 0 && (
            <div className="sci-sidebar-card sci-sidebar-hide-mobile">
              <div className="sci-sidebar-label">{tFn('cientifico_detail.topics')}</div>
              <div className="sci-toc-list">
                {headings.map((h) => (
                  <a key={h.id} href={`#${h.id}`}>{h.text}</a>
                ))}
              </div>
            </div>
          )}

          <div className="sci-sidebar-card">
            <div className="sci-sidebar-label">{tFn('cientifico_detail.share')}</div>
            <ShareSection
              articleId={article.id}
              articleSlug={article.slug}
              title={article.title}
              url={articleUrl}
            />
          </div>
        </aside>
      </div>
    </>
  )
}
