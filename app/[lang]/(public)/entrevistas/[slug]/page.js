import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getInterviewBySlug, getRelatedInterviews, getInterviewCategories } from '@/lib/api/interviews'
import { buildInterviewSchema, buildBreadcrumbSchema } from '@/lib/seo'
import { SITE_URL } from '@/lib/constants'
import Breadcrumb from '@/components/ui/Breadcrumb'
import ArticleContent from '@/components/content/ArticleContent'
import YouTubeLazyPlayer from '@/components/content/YouTubeLazyPlayer'
import ShareSection from '@/components/content/ShareSection'
import InterviewViewCounter from '@/components/content/InterviewViewCounter'
import InterviewAudioPlayer from '@/components/content/InterviewAudioPlayer'
import Link from 'next/link'
import Image from 'next/image'
import { notFound } from 'next/navigation'
import { Clock, Video, Mic, Calendar, BookOpen, Eye } from 'lucide-react'

export const revalidate = 3600

export async function generateStaticParams() {
  const { getInterviews } = await import('@/lib/api/interviews')
  try {
    const interviews = await getInterviews()
    return interviews.map((i) => ({ slug: i.slug }))
  } catch {
    return []
  }
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  let interview
  try {
    interview = await getInterviewBySlug(slug)
  } catch {
    return { title: 'Entrevista — Conheça Farmácia' }
  }
  if (!interview) return { title: 'Entrevista não encontrada — Conheça Farmácia' }

  const url = `${SITE_URL}/${safeLang}/entrevistas/${interview.slug}`

  return {
    title: `${interview.title} — Conheça Farmácia`,
    description: interview.metaDescription || interview.excerpt || interview.title,
    alternates: {
      canonical: url,
      languages: { pt: `${SITE_URL}/pt/entrevistas/${interview.slug}` },
    },
    openGraph: {
      title: interview.title,
      description: interview.excerpt,
      url,
      type: 'article',
      images: interview.thumbnailUrl ? [{ url: interview.thumbnailUrl }] : [],
    },
  }
}

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

export default async function InterviewDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  let interview
  try {
    interview = await getInterviewBySlug(slug)
  } catch (err) {
    console.error('Error fetching interview:', err)
    notFound()
  }
  if (!interview) notFound()

  // Cores das categorias geríveis (interview_categories, 155)
  let categories = []
  try {
    categories = await getInterviewCategories()
  } catch {}
  const colorMap = Object.fromEntries(categories.map((c) => [c.slug, c.color]))
  const color = colorMap[interview.category] || '#0a844f'

  let related = []
  try {
    related = await getRelatedInterviews(slug, interview.category, 3)
  } catch {}

  const breadcrumbLevels = [
    { label: tFn('nav.inicio'), href: `/${safeLang}`, i18nKey: 'nav.inicio' },
    { label: tFn('nav.entrevistas'), href: `/${safeLang}/entrevistas`, i18nKey: 'nav.entrevistas' },
    { label: interview.title },
  ]

  const schema = buildInterviewSchema(interview, safeLang)
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbLevels.map((l) => ({ ...l, href: l.href ? `${SITE_URL}${l.href}` : undefined }))
  )

  // Entrevistados — lista (até 5) com fallback para o formato antigo (objeto)
  const interviewees =
    Array.isArray(interview.interviewees) && interview.interviewees.length > 0
      ? interview.interviewees
      : interview.interviewee?.name
        ? [interview.interviewee]
        : []
  const interviewee = interviewees[0] || {}
  const interviewer = interview.interviewer || {}

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }} />

      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbLevels} />
      </nav>

      <main className="interview-layout">
        {/* COLUNA PRINCIPAL 2/3 */}
        <div className="interview-main">
          <header className="interview-article-hero">
            <span className="interview-category-badge" style={{ background: `${color}18`, color }}>
              {interview.categoryLabel}
            </span>
            <h1 className="interview-title">{interview.title}</h1>
            <div className="interview-hero-meta">
              {interview.date && (
                <span>
                  <Calendar size={14} aria-hidden="true" />
                  {formatDate(interview.date, safeLang)}
                </span>
              )}
              {interview.readTime && (
                <span>
                  <Clock size={14} aria-hidden="true" />
                  {interview.readTime} {tFn('entrevistas_page.min_read')}
                </span>
              )}
              {interview.videoId && (
                <span>
                  <Video size={14} aria-hidden="true" />
                  {interview.videoDuration || tFn('entrevista_detail.has_video')}
                </span>
              )}
              {!interview.videoId && interview.audioUrl && (
                <span>
                  <Mic size={14} aria-hidden="true" />
                  {tFn('entrevista_detail.has_audio')}
                </span>
              )}
              <span title={tFn('entrevista_detail.views')}>
                <Eye size={14} aria-hidden="true" />
                {interview.viewCount || 0}
              </span>
            </div>
          </header>

          <InterviewViewCounter interviewId={interview.id} />

          {/* Entrevistados + Entrevistador — abaixo do tema, padrão Autores (científicos) */}
          {(interviewees.length > 0 || interviewer.name) && (
            <section className="interview-people-section">
              <div className="interview-people-grid">
                {interviewees.map((p, idx) => (
                  <div key={idx} className="interview-person-card">
                    <span className="avatar" style={{ background: p.avatarBg || color, width: 44, height: 44, fontSize: 16 }}>
                      {(p.avatar || (p.name || '?')[0]).toUpperCase()}
                    </span>
                    <div className="interview-people-info">
                      <span className="interview-people-label">
                        {interviewees.length > 1
                          ? tFn('entrevista_detail.interviewees')
                          : tFn('entrevista_detail.interviewee')}
                      </span>
                      {p.slug ? (
                        <Link
                          href={`/${safeLang}/entrevistas/entrevistados/${p.slug}`}
                          className="interview-people-name interview-people-link"
                        >
                          {p.name}
                        </Link>
                      ) : (
                        <div className="interview-people-name">{p.name}</div>
                      )}
                      {p.role && <div className="interview-people-role">{p.role}</div>}
                    </div>
                  </div>
                ))}
                {interviewer.name && (
                  <div className="interview-person-card">
                    <span className="avatar" style={{ background: interviewer.avatarBg || '#0a844f', width: 44, height: 44, fontSize: 16 }}>
                      {(interviewer.avatar || (interviewer.name || '?')[0]).toUpperCase()}
                    </span>
                    <div className="interview-people-info">
                      <span className="interview-people-label">{tFn('entrevista_detail.interviewer')}</span>
                      <div className="interview-people-name">{interviewer.name}</div>
                      {interviewer.role && <div className="interview-people-role">{interviewer.role}</div>}
                    </div>
                  </div>
                )}
              </div>
            </section>
          )}

          {/* Vídeo (condicional) */}
          {interview.videoId && (
            <YouTubeLazyPlayer
              videoId={interview.videoId}
              thumbnailUrl={interview.thumbnailUrl}
              title={interview.title}
            />
          )}

          {/* Áudio (só quando não há vídeo) — ouvir enquanto lê */}
          {!interview.videoId && interview.audioUrl && (
            <InterviewAudioPlayer audioUrl={interview.audioUrl} title={interview.title} />
          )}

          {/* Sumário executivo */}
          {interview.executiveSummary && (
            <div className="interview-summary-box">
              <span className="interview-summary-label">{tFn('entrevista_detail.summary')}</span>
              <p>{interview.executiveSummary}</p>
            </div>
          )}

          {/* Pull quotes */}
          {Array.isArray(interview.pullQuotes) && interview.pullQuotes.filter(Boolean).map((quote, i) => (
            <blockquote key={i} className="interview-pull-quote">
              <p>“{quote}”</p>
              {interviewee.name && <cite>— {interviewee.name}</cite>}
            </blockquote>
          ))}

          {/* Conteúdo */}
          {interview.content && (
            <div className="interview-content">
              <ArticleContent content={interview.content} />
            </div>
          )}

          {/* Q&A */}
          {Array.isArray(interview.qa) && interview.qa.length > 0 && (
            <section className="interview-qa-section">
              <h2>{tFn('entrevista_detail.questions')}</h2>
              {interview.qa.map((item, i) => (
                <div key={i} className="interview-qa-item">
                  <div className="interview-qa-question">
                    <span className="interview-qa-badge" style={{ background: `${color}18`, color }}>Q</span>
                    <span>{item.question}</span>
                  </div>
                  <div className="interview-qa-answer">{item.answer}</div>
                </div>
              ))}
            </section>
          )}

        </div>

        {/* SIDEBAR 1/3 */}
        <aside className="interview-sidebar">
          {interviewees.map((p, idx) => (
            <div key={idx} className="interview-sidebar-card interview-sidebar-people">
              <span className="interview-sidebar-label">
                {interviewees.length > 1
                  ? tFn('entrevista_detail.interviewees')
                  : tFn('entrevista_detail.interviewee')}
              </span>
              <div className="interview-person-row">
                <span className="avatar" style={{ background: p.avatarBg || color, width: 44, height: 44, fontSize: 16 }}>
                  {(p.avatar || (p.name || '?')[0]).toUpperCase()}
                </span>
                <div>
                  {p.slug ? (
                    <Link
                      href={`/${safeLang}/entrevistas/entrevistados/${p.slug}`}
                      className="interview-person-name interview-people-link"
                    >
                      {p.name}
                    </Link>
                  ) : (
                    <div className="interview-person-name">{p.name}</div>
                  )}
                  {p.role && <div className="interview-person-role">{p.role}</div>}
                </div>
              </div>
              {p.bio && <p className="interview-person-bio">{p.bio}</p>}
            </div>
          ))}

          {interviewer.name && (
            <div className="interview-sidebar-card interview-sidebar-people">
              <span className="interview-sidebar-label">{tFn('entrevista_detail.interviewer')}</span>
              <div className="interview-person-row">
                <span className="avatar" style={{ background: interviewer.avatarBg || '#0a844f', width: 44, height: 44, fontSize: 16 }}>
                  {(interviewer.avatar || (interviewer.name || '?')[0]).toUpperCase()}
                </span>
                <div>
                  <div className="interview-person-name">{interviewer.name}</div>
                  {interviewer.role && <div className="interview-person-role">{interviewer.role}</div>}
                </div>
              </div>
            </div>
          )}

          <div className="interview-sidebar-card">
            <span className="interview-sidebar-label">{tFn('entrevista_detail.share')}</span>
            <ShareSection
              title={interview.title}
              description={interview.excerpt}
              url={`${SITE_URL}/${safeLang}/entrevistas/${interview.slug}`}
            />
          </div>

          {related.length > 0 && (
            <div className="interview-sidebar-card">
              <span className="interview-sidebar-label">{tFn('entrevista_detail.related')}</span>
              <div className="interview-related-list">
                {related.map((r) => (
                  <Link key={r.slug} href={`/${safeLang}/entrevistas/${r.slug}`} className="interview-related-item">
                    <span className="interview-related-icon" style={{ color }}>
                      <BookOpen size={16} aria-hidden="true" />
                    </span>
                    <span className="interview-related-title">{r.title}</span>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </aside>
      </main>
    </>
  )
}
