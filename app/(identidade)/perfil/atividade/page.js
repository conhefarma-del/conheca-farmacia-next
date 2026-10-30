import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Activity } from 'lucide-react'
import { createClient, createLocalizadorClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { loadInscricoes } from '@/lib/account-inscricoes'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'
import { accountLocale, accountTranslator } from '@/lib/account-i18n'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Atividade',
  robots: { index: false, follow: false },
}

const fmt = (iso, locale) =>
  iso
    ? new Date(iso).toLocaleDateString(locale, {
        day: '2-digit',
        month: 'long',
        year: 'numeric',
      })
    : ''

/**
 * Atividade da conta.
 *
 * Uma linha temporal só de leitura: o que a pessoa guardou, reservou e em que
 * se inscreveu. Não é um registo de auditoria nem inventa eventos novos — se
 * alguma coisa não existe na base, não aparece aqui.
 */
export default async function AtividadePage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/atividade')

  const { lang, t } = accountTranslator(user)
  const locale = accountLocale(lang)

  const localizador = await createLocalizadorClient()

  const [favoritos, reservas, inscricoes] = await Promise.all([
    localizador
      .from('favorites')
      .select('id, created_at, drugs(id, name), pharmacies(name, slug)')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(40),
    localizador
      .from('reservations')
      .select('id, status, created_at, quantity, access_token, drugs(name), pharmacies(name, slug)')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(40),
    loadInscricoes(createAdminClient(), user, {
      select: 'id, evento_id, created_at, compareceu',
    }),
  ])

  const idsEventos = [...new Set((inscricoes || []).map((row) => row.evento_id).filter(Boolean))]
  let eventosPorId = new Map()
  if (idsEventos.length > 0) {
    const { data: eventos } = await supabase
      .from('events')
      .select('id, slug, title, date')
      .in('id', idsEventos)
    eventosPorId = new Map((eventos || []).map((evento) => [evento.id, evento]))
  }

  const itens = [
    ...(favoritos.data || []).map((row) => ({
      key: `favorito-${row.id}`,
      date: row.created_at,
      kind: t('account.activity.kindSaved'),
      title: row.drugs?.name || row.pharmacies?.name || t('account.activity.fallbackSaved'),
      meta: row.drugs
        ? t('account.activity.metaDrug')
        : row.pharmacies?.name
          ? t('account.activity.metaPharmacy')
          : '',
      href: row.drugs?.id
        ? `${LOCATOR_ORIGIN}/medicamento/${row.drugs.id}`
        : row.pharmacies?.slug
          ? `${LOCATOR_ORIGIN}/farmacia/${row.pharmacies.slug}`
          : null,
    })),
    ...(reservas.data || []).map((row) => ({
      key: `reserva-${row.id}`,
      date: row.created_at,
      kind: t('account.activity.kindReserved'),
      title: row.drugs?.name || t('account.activity.fallbackReservation'),
      meta: [row.pharmacies?.name, `${row.quantity} un.`, row.status].filter(Boolean).join(' · '),
      href:
        row.access_token && row.id
          ? `${LOCATOR_ORIGIN}/reserva/${row.id}?t=${row.access_token}`
          : null,
    })),
    ...(inscricoes || []).map((row) => {
      const evento = row.evento_id ? eventosPorId.get(row.evento_id) || null : null
      return {
        key: `inscricao-${row.id}`,
        date: row.created_at,
        kind: t('account.activity.kindRegistered'),
        title: evento?.title || t('account.activity.fallbackEvent'),
        meta: [
          fmt(evento?.date, locale),
          row.compareceu ? t('account.activity.attended') : t('account.activity.confirmed'),
        ]
          .filter(Boolean)
          .join(' · '),
        href: evento?.slug ? `${SITE_ORIGIN}/${lang}/eventos/${evento.slug}` : null,
      }
    }),
  ]
    .filter((item) => item.date)
    .sort((a, b) => String(b.date).localeCompare(String(a.date)))
    .slice(0, 40)

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{t('account.activity.title')}</h1>
          <p className="conta-sub">{t('account.activity.sub')}</p>
        </div>
      </header>

      {itens.length === 0 ? (
        <section className="conta-panel">
          <div className="conta-empty">
            <p className="conta-empty-title">{t('account.activity.emptyTitle')}</p>
            <p className="conta-empty-sub">{t('account.activity.emptySub')}</p>
            <p className="conta-empty-acts">
              <Link className="conta-btn conta-btn--primary" href={`${LOCATOR_ORIGIN}/pesquisa`}>
                {t('account.activity.searchDrug')}
              </Link>
              <a className="conta-btn conta-btn--ghost" href={`${SITE_ORIGIN}/${lang}/eventos`}>
                {t('account.activity.viewEvents')}
              </a>
            </p>
          </div>
        </section>
      ) : (
        <section className="conta-panel" aria-labelledby="conta-atividade">
          <div className="conta-panel-head">
            <h2 id="conta-atividade" className="conta-panel-title">
              <Activity size={14} aria-hidden="true" />
              {t('account.activity.timeline')}
            </h2>
            <span className="conta-panel-count">{itens.length}</span>
          </div>
          <ul className="conta-rows">
            {itens.map((item) => (
              <li key={item.key} className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-kicker">
                    {item.kind} · {fmt(item.date, locale)}
                  </span>
                  {item.href ? (
                    <a className="conta-row-title" href={item.href}>
                      {item.title}
                    </a>
                  ) : (
                    <span className="conta-row-title">{item.title}</span>
                  )}
                  {item.meta && <span className="conta-row-meta">{item.meta}</span>}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  )
}
