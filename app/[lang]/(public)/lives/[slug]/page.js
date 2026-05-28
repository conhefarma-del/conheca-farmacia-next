import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getLiveBySlug, getLives } from '@/lib/api/lives'
import { buildBreadcrumbSchema, buildLiveSchema } from '@/lib/seo'
import { LIVE_CATEGORY_COLORS, SITE_URL } from '@/lib/constants'
import { validateUrl } from '@/lib/security'
import Breadcrumb from '@/components/ui/Breadcrumb'
import LiveViewTracker from '@/components/content/LiveViewTracker'
import LiveAccessButton from '@/components/content/LiveAccessButton'
import MaterialLink from '@/components/content/MaterialLink'
import Image from 'next/image'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

export async function generateStaticParams() {
  try {
    const lives = await getLives()
    return lives.map((live) => ({ slug: live.slug }))
  } catch {
    return []
  }
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  let live
  try {
    live = await getLiveBySlug(slug)
  } catch {
    return { title: 'Live — Conheça Farmácia' }
  }

  if (!live) {
    return { title: 'Live não encontrada — Conheça Farmácia' }
  }

  const liveUrl = `${SITE_URL}/${safeLang}/lives/${live.slug}`

  return {
    title: `${live.titulo} — Conheça Farmácia`,
    description: live.resumo || live.titulo,
    alternates: {
      canonical: liveUrl,
      languages: { 'pt': `/pt/lives/${live.slug}`, 'en': `/en/lives/${live.slug}` },
    },
    openGraph: {
      title: live.titulo,
      description: live.resumo,
      url: liveUrl,
      images: live.imagem ? [{ url: live.imagem }] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title: live.titulo,
      description: live.resumo,
      images: live.imagem ? [live.imagem] : [],
    },
  }
}

function formatDuration(startTime, endTime) {
  if (!startTime || !endTime) return null
  const [sh, sm] = startTime.split(':').map(Number)
  const [eh, em] = endTime.split(':').map(Number)
  const totalMin = (eh * 60 + em) - (sh * 60 + sm)
  if (totalMin <= 0) return null
  const hours = Math.floor(totalMin / 60)
  const minutes = totalMin % 60
  if (hours > 0 && minutes > 0) return `${hours}h${minutes}min`
  if (hours > 0) return `${hours}h`
  return `${minutes}min`
}

function getEndTime(live) {
  if (live.hora_fim || live.end_time) return live.hora_fim || live.end_time
  if ((live.duracao || live.duration) && (live.hora || live.time)) {
    const dur = parseInt(live.duracao || live.duration, 10)
    if (!isNaN(dur)) {
      const [h, m] = (live.hora || live.time).split(':').map(Number)
      const endH = h + Math.floor((m + dur) / 60)
      const endM = (m + dur) % 60
      return `${String(endH).padStart(2, '0')}:${String(endM).padStart(2, '0')}`
    }
  }
  return null
}

function getInitials(name) {
  if (!name) return 'CF'
  return name.split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase()
}

function formatDate(dateStr, lang) {
  const d = new Date(dateStr + 'T00:00:00')
  return d.toLocaleDateString(lang === 'en' ? 'en' : 'pt-PT', {
    day: 'numeric', month: 'long', year: 'numeric',
  })
}

export default async function LiveDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  let live
  try {
    live = await getLiveBySlug(slug)
  } catch (err) {
    console.error('Error fetching live:', err)
  }

  if (!live) notFound()

  const breadcrumbItems = [
    { label: tFn('nav.inicio'), href: `/${safeLang}` },
    { label: tFn('nav.lives'), href: `/${safeLang}/lives` },
    { label: live.titulo },
  ]

  const color = LIVE_CATEGORY_COLORS[live.categoria || live.category] || '#00493a'
  const hora = live.hora || live.time || ''
  const horaFim = getEndTime(live)
  const duracao = horaFim ? formatDuration(hora, horaFim) : null
  const plataforma = live.plataforma || live.platform || ''
  const categoriaLabel = live.categoriaLabel || live.category || live.categoria || ''
  const anfitriao = live.anfitriao || {}
  const nome = anfitriao.nome || live.host_name || ''
  const cargo = anfitriao.cargo || live.host_role || ''
  const organizacao = anfitriao.organizacao || live.host_organization || ''
  const materiais = live.materiais_apoio || live.materiais || live.materials || []
  const meetingId = live.id_reuniao || live.meeting_id || ''
  const senha = live.senha || live.password || ''

  const liveJsonLd = buildLiveSchema(live, safeLang)
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbItems.map((l) => ({
      ...l,
      href: l.href ? `${SITE_URL}${l.href}` : undefined,
    }))
  )

  const accessUrl = validateUrl(live.link_acesso || live.access_link || '#')

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(liveJsonLd) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />

      <LiveViewTracker liveSlug={slug} />

      {/* Breadcrumb — outside main, before hero */}
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbItems} />
      </nav>

      <main>
        {/* Live Hero Section */}
        <section className="event-hero">
          <div className="container-center">
            <div className="event-hero-content">
              {/* Category Badge */}
              <span
                className="event-category-badge"
                style={{ backgroundColor: `${color}20`, color, border: `1px solid ${color}40` }}
              >
                {categoriaLabel}
              </span>

              {/* Live Title */}
              <h1 className="event-hero-title">{live.titulo}</h1>

              {/* Featured Image */}
              {live.imagem && (
                <div className="event-hero-image-wrapper">
                  <Image
                    src={live.imagem}
                    alt={live.titulo}
                    width={1200}
                    height={675}
                    className="event-featured-image"
                    priority
                  />
                </div>
              )}

              {/* Live Meta Bar */}
              <div className="event-meta-bar">
                <div className="event-meta-group">
                  <span
                    className="event-meta-badge"
                    style={{ backgroundColor: `${color}20`, color }}
                  >
                    {plataforma}
                  </span>
                  <span className="text-sm font-semibold text-brand-deep/70">
                    {formatDate(live.data || live.date, safeLang)}
                  </span>
                </div>
                {(hora || duracao) && (
                  <div className="event-meta-group">
                    <span className="text-sm text-brand-deep/70">
                      {hora}{horaFim ? ` — ${horaFim}` : ''}{duracao ? ` (${duracao})` : ''}
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Live Content Section */}
        <section className="event-content-section">
          <div className="container-center">
            <div className="event-body-wrapper">
              {/* Description */}
              {live.resumo && (
                <div className="event-body mb-12">
                  <p>{live.resumo}</p>
                </div>
              )}

              {/* Quick Access Card */}
              <div className="event-details-card quick-access-card">
                <h2 className="text-2xl font-bold text-brand-deep mb-6">
                  {tFn('live_detail.quick_access')}
                </h2>

                <LiveAccessButton
                  href={accessUrl}
                  color={color}
                  label={tFn('live_detail.access_now')}
                  liveSlug={slug}
                  rpcName="increment_live_access_count"
                />

                {(meetingId || senha) && (
                  <div className="live-credentials mt-6 p-4 bg-brand-bg-alt rounded-lg">
                    <h3 className="text-lg font-bold text-brand-deep mb-3">
                      {tFn('live_detail.access_info')}
                    </h3>
                    {meetingId && (
                      <div className="mb-3">
                        <span className="font-semibold">{tFn('live_detail.meeting_id')}</span>
                        <span className="ml-2">{meetingId}</span>
                      </div>
                    )}
                    {senha && (
                      <div>
                        <span className="font-semibold">{tFn('live_detail.password')}</span>
                        <span className="ml-2">{senha}</span>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Materials Section */}
              {materiais.length > 0 && (
                <div className="event-details-card mt-8">
                  <h2 className="text-2xl font-bold text-brand-deep mb-4">
                    {tFn('live_detail.support_materials')}
                  </h2>
                  <ul className="materials-list space-y-2">
                    {materiais.map((material, idx) => (
                      <li key={idx}>
                        <MaterialLink
                          material={material}
                          index={idx}
                          color={color}
                          liveSlug={slug}
                        />
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {/* Host Card */}
              {nome && (
                <div className="host-card-event mt-8">
                  <div className="host-card-avatar" style={{ backgroundColor: color }}>
                    {getInitials(nome)}
                  </div>
                  {cargo && <div className="host-card-role">{cargo}</div>}
                  <div className="host-card-name">{nome}</div>
                  {organizacao && <div className="host-card-organization">{organizacao}</div>}
                </div>
              )}
            </div>
          </div>
        </section>

      </main>

    </>
  )
}
