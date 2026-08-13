import Link from 'next/link'
import { ArrowLeft, Clock, Eye, Mic, Video, FileText, Music2 } from 'lucide-react'
import { parseAudioEmbed } from '@/lib/utils/audio-embed'

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  try {
    return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
  } catch {
    return dateStr
  }
}

function getMediaBadge(i) {
  if (i.videoId) return { icon: Video, labelKey: 'entrevistas_page.media_video' }
  if (i.audioUrl) {
    const embed = parseAudioEmbed(i.audioUrl)
    if (embed?.type === 'spotify') {
      return { icon: Music2, labelKey: 'entrevistas_page.media_spotify' }
    }
    return { icon: Mic, labelKey: 'entrevistas_page.media_audio' }
  }
  return { icon: FileText, labelKey: 'entrevistas_page.media_text' }
}

/**
 * EntrevistadoProfilePage — mini perfil de um entrevistado.
 * Server component (sem LangContext): recebe a função de tradução `tFn`.
 * Mostra: avatar, nome, cargo, bio (o que houver preenchido) e as
 * entrevistas em que participou, com a contagem.
 */
export default function EntrevistadoProfilePage({ person, interviews = [], lang = 'pt', tFn }) {
  const color = person.avatarBg || '#00493a'
  const countLabel =
    interviews.length === 1
      ? tFn('entrevistado_profile.interviews_count_one')
      : tFn('entrevistado_profile.interviews_count_other', { count: interviews.length })

  return (
    <>
      {/* ← Voltar para Entrevistados */}
      <div className="max-w-[1100px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={`/${lang}/entrevistas/entrevistados`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {tFn('entrevistado_profile.back_to_entrevistados')}
        </Link>
      </div>

      <section className="sci-author-page">
        {/* Identidade */}
        <header className="sci-author-header">
          <span className="sci-author-avatar-lg" style={{ background: color }}>
            {(person.avatar || (person.name || '?')[0]).toUpperCase()}
          </span>
          <div className="sci-author-header-info">
            <h1 className="sci-author-name-lg">{person.name}</h1>
            {person.role && (
              <p className="sci-author-affil">{person.role}</p>
            )}
            <span className="sci-author-count">
              <Mic size={13} aria-hidden="true" /> {countLabel}
            </span>
          </div>
        </header>

        {/* Bio */}
        {person.bio && (
          <div className="interview-summary-box" style={{ maxWidth: 760 }}>
            <span className="interview-summary-label">{tFn('entrevistado_profile.about')}</span>
            <p>{person.bio}</p>
          </div>
        )}

        {/* Entrevistas em que participou */}
        <div className="sci-section-title" style={{ marginTop: 32 }}>
          {tFn('entrevistado_profile.interviews')}
        </div>

        {interviews.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {interviews.map((i) => {
              const media = getMediaBadge(i)
              const MediaIcon = media.icon
              return (
                <Link
                  key={i.slug}
                  href={`/${lang}/entrevistas/${i.slug}`}
                  className="interview-card"
                >
                  <div className="interview-card-thumb" style={{ background: `${color}15` }}>
                    {i.thumbnailUrl ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img src={i.thumbnailUrl} alt="" className="interview-card-thumb-img" loading="lazy" />
                    ) : (
                      <div className="interview-card-thumb-placeholder">
                        {i.videoId ? (
                          <Video size={40} strokeWidth={1.5} style={{ color }} aria-hidden="true" />
                        ) : (
                          <Mic size={40} strokeWidth={1.5} style={{ color }} aria-hidden="true" />
                        )}
                      </div>
                    )}
                    {i.videoId && (
                      <span className="interview-play-overlay">
                        <span className="interview-play-btn" style={{ color }}>
                          <Video size={16} aria-hidden="true" />
                        </span>
                      </span>
                    )}
                    {i.videoDuration && (
                      <span className="interview-duration">{i.videoDuration}</span>
                    )}
                    <span className="interview-media-badge" title={tFn(media.labelKey)}>
                      <MediaIcon size={11} aria-hidden="true" /> {tFn(media.labelKey)}
                    </span>
                  </div>

                  <div className="interview-card-body">
                    <div className="interview-card-meta">
                      <time>{formatDate(i.date, lang)}</time>
                      {i.readTime && (
                        <>
                          <span>·</span>
                          <span className="inline-flex items-center gap-1">
                            <Clock size={12} aria-hidden="true" /> {i.readTime} {tFn('entrevistas_page.min_read')}
                          </span>
                        </>
                      )}
                      <span title={tFn('entrevistas_page.views')}>
                        <Eye size={12} aria-hidden="true" /> {i.viewCount || 0}
                      </span>
                    </div>
                    <h2 className="interview-card-title">{i.title}</h2>
                    {i.excerpt && <p className="interview-card-excerpt">{i.excerpt}</p>}
                    <div className="interview-card-footer">
                      <div className="interview-card-person">
                        <span className="avatar" style={{ background: person.avatarBg || color }}>
                          {(person.avatar || (person.name || '?')[0] || '?').toUpperCase()}
                        </span>
                        <span>{person.name}</span>
                      </div>
                      <span className="interview-card-cta">
                        {i.videoId
                          ? tFn('entrevistas_page.watch_cta')
                          : tFn('entrevistas_page.read_cta')}
                      </span>
                    </div>
                  </div>
                </Link>
              )
            })}
          </div>
        ) : (
          <p className="text-center py-16 text-gray-500">
            {tFn('entrevistado_profile.no_interviews')}
          </p>
        )}
      </section>
    </>
  )
}
