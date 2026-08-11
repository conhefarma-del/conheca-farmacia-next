import Link from 'next/link'
import CitedByBadge from '@/components/content/CitedByBadge'
import { ArrowLeft, BookOpen, UserRound, FileText } from 'lucide-react'

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  try {
    return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
  } catch {
    return dateStr
  }
}

/**
 * CientificosAuthorPage — página de autor dos Artigos Científicos.
 * Server component (sem LangContext): recebe a função de tradução `tFn`.
 *
 * variant:
 *   - 'articles' → grid de cards dos artigos publicados pelo autor
 *   - 'profile'  → perfil detalhado (função, instituição, departamento) + lista
 *
 * Header comum: identidade do autor (avatar, nome, afiliação, contagem) e
 * tabs "Artigos" / "Perfil" que navegam entre as duas páginas.
 */
export default function CientificosAuthorPage({ author, articles = [], lang = 'pt', variant = 'articles', tFn }) {
  const color = author.avatarBg || '#0a844f'
  const authorSlug = author.slug
  const countLabel =
    articles.length === 1
      ? tFn('cientifico_author.articles_count_one')
      : tFn('cientifico_author.articles_count_other', { count: articles.length })

  return (
    <>
      {/* ← Voltar para Artigos Científicos */}
      <div className="max-w-[1100px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={`/${lang}/cientificos`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {tFn('cientifico_author.back_to_cientificos')}
        </Link>
      </div>

      <section className="sci-author-page">
        {/* Identidade do autor */}
        <header className="sci-author-header">
          <span className="sci-author-avatar-lg" style={{ background: color }}>
            {(author.avatar || (author.name || '?')[0]).toUpperCase()}
          </span>
          <div className="sci-author-header-info">
            <h1 className="sci-author-name-lg">{author.name}</h1>
            {(author.institution || author.department || author.role) && (
              <p className="sci-author-affil">
                {[author.role, author.institution, author.department].filter(Boolean).join(' · ')}
              </p>
            )}
            <span className="sci-author-count">
              <FileText size={13} aria-hidden="true" /> {countLabel}
            </span>
          </div>
        </header>

        {/* Tabs: Artigos | Perfil */}
        <nav className="sci-author-tabs" aria-label="Autor">
          <Link
            href={`/${lang}/cientificos/autores/${authorSlug}`}
            className={`sci-author-tab ${variant === 'articles' ? 'active' : ''}`}
          >
            <BookOpen size={14} aria-hidden="true" />
            {tFn('cientifico_author.view_articles')}
          </Link>
          <Link
            href={`/${lang}/cientificos/autores/${authorSlug}/perfil`}
            className={`sci-author-tab ${variant === 'profile' ? 'active' : ''}`}
          >
            <UserRound size={14} aria-hidden="true" />
            {tFn('cientifico_author.view_profile')}
          </Link>
        </nav>

        {variant === 'profile' ? (
          <>
            {/* Perfil detalhado */}
            <div className="sci-profile-grid">
              {author.role && (
                <div className="sci-profile-item">
                  <div className="sci-profile-label">{tFn('cientifico_author.role')}</div>
                  <div className="sci-profile-value">{author.role}</div>
                </div>
              )}
              {author.institution && (
                <div className="sci-profile-item">
                  <div className="sci-profile-label">{tFn('cientifico_author.institution')}</div>
                  <div className="sci-profile-value">{author.institution}</div>
                </div>
              )}
              {author.department && (
                <div className="sci-profile-item">
                  <div className="sci-profile-label">{tFn('cientifico_author.department')}</div>
                  <div className="sci-profile-value">{author.department}</div>
                </div>
              )}
              {author.corresponding && (
                <div className="sci-profile-item">
                  <div className="sci-profile-label">{tFn('cientifico_author.corresponding')}</div>
                  <div className="sci-profile-value">✓</div>
                </div>
              )}
              {author.orcid && (
                <div className="sci-profile-item">
                  <div className="sci-profile-label">{tFn('cientifico_author.orcid')}</div>
                  <a
                    className="sci-profile-value sci-profile-orcid"
                    href={`https://orcid.org/${author.orcid}`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {author.orcid}
                  </a>
                </div>
              )}
            </div>

            {/* Artigos publicados */}
            <div className="sci-section-title" style={{ marginTop: 32 }}>
              {tFn('cientifico_author.published_articles')}
            </div>
            <div className="sci-profile-articles">
              {articles.map((a) => (
                <Link key={a.slug} href={`/${lang}/cientificos/${a.slug}`} className="sci-related-item">
                  {a.title}
                </Link>
              ))}
            </div>
          </>
        ) : (
          /* Artigos do autor — grid de cards (mesmo padrão da listagem) */
          <>
            {articles.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {articles.map((article) => {
                  const cat = article.category
                  const catColor = cat?.color || '#0a844f'
                  const authors = article.authors || []
                  return (
                    <Link
                      key={article.slug}
                      href={`/${lang}/cientificos/${article.slug}`}
                      className="sci-card"
                    >
                      <div className="sci-card-top">
                        {cat ? (
                          <span className="sci-category-badge" style={{ background: `${catColor}1a`, color: catColor }}>
                            {cat.name}
                          </span>
                        ) : (
                          <span
                            className="sci-category-badge"
                            style={{ background: 'var(--color-brand-bg-alt)', color: 'var(--color-brand-deep)' }}
                          >
                            {tFn('cientificos_page.filter_all')}
                          </span>
                        )}
                        <span className="lang-badge">{(article.lang || lang).toUpperCase()}</span>
                      </div>
                      <h2 className="sci-title">{article.title}</h2>
                      {article.abstract && <p className="sci-abstract">{article.abstract}</p>}
                      {article.keywords && article.keywords.length > 0 && (
                        <div className="sci-keywords">
                          {article.keywords.slice(0, 4).map((kw, i) => (
                            <span key={i} className="sci-keyword">{kw}</span>
                          ))}
                        </div>
                      )}
                      <div className="sci-meta">
                        <time>{formatDate(article.date, lang)}</time>
                        {article.readTime && (
                          <>
                            <span>·</span>
                            <span>{article.readTime} {tFn('cientificos_page.min_read')}</span>
                          </>
                        )}
                        <CitedByBadge doi={article.doi} />
                        {authors.length > 0 && (
                          <div className="sci-authors-preview">
                            {authors.slice(0, 3).map((a, i) => (
                              <div
                                key={i}
                                className="avatar"
                                style={{ background: a.avatarBg || catColor }}
                                title={a.name}
                              >
                                {(a.avatar || (a.name || '?')[0]).toUpperCase()}
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    </Link>
                  )
                })}
              </div>
            ) : (
              <div className="text-center py-16 text-gray-500">
                <p>{tFn('cientifico_author.no_articles')}</p>
              </div>
            )}
          </>
        )}
      </section>
    </>
  )
}
