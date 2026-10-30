import { redirect } from 'next/navigation'
import Link from 'next/link'
import { CalendarDays, CheckCircle2, Ticket } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { loadInscricoes } from '@/lib/account-inscricoes'
import { getEvents } from '@/lib/api/events'
import { SITE_ORIGIN } from '@/lib/account-urls'
import { accountLocale, accountTranslator } from '@/lib/account-i18n'
import CancelInscriptionButton from '@/components/account/CancelInscriptionButton'
import InscriptionDetailsForm from '@/components/account/InscriptionDetailsForm'

export const dynamic = 'force-dynamic'

export async function generateMetadata() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const { t } = accountTranslator(user)
  return { title: t('account.events.title'), robots: { index: false, follow: false } }
}

/** Quantos próximos eventos a página mostra antes de mandar ao site. */
const PROXIMOS = 3

/** Data local do dia, no formato `YYYY-MM-DD` — as datas dos eventos não têm hora. */
const hojeISO = () => {
  const now = new Date()
  now.setMinutes(now.getMinutes() - now.getTimezoneOffset())
  return now.toISOString().slice(0, 10)
}

/**
 * Eventos da conta: inscrições da pessoa e os próximos eventos do site.
 *
 * A ligação é pelo e-mail da sessão. `inscricoes` não guarda `user_id` (as
 * inscrições são feitas no formulário público, muitas vezes antes de haver
 * conta) e a RLS só deixa ler admins — por isso a leitura é server-side, com
 * a chave de serviço, e já filtrada pelo e-mail da pessoa. Nenhuma linha de
 * outra pessoa chega ao browser.
 */
export default async function EventosPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/eventos')

  // O idioma vem da preferência da conta (`lib/account-i18n`) — a mesma que
  // alimenta o LangProvider do layout. Sem preferência, PT.
  const meta = user.user_metadata || {}
  const { lang, t } = accountTranslator(user)
  const locale = accountLocale(lang)

  const dadosInscricao = meta.inscricao || {}
  const admin = createAdminClient()

  // Só os campos que a lista usa — nada de telefone ou profissão aqui.
  // Lê pelo `user_id` e por todos os e-mails da conta: uma troca de endereço
  // não pode esconder as inscrições antigas.
  const inscricoes = await loadInscricoes(admin, user, {
    select: 'id, created_at, compareceu, share_code, evento_id',
  })
  const inscricoesError = null

  const linhas = (inscricoes || []).sort((a, b) =>
    String(b.created_at).localeCompare(String(a.created_at)),
  )
  const ids = [...new Set(linhas.map((row) => row.evento_id).filter(Boolean))]

  let eventosPorId = new Map()
  if (ids.length > 0) {
    const { data: eventos } = await supabase
      .from('events')
      .select('id, slug, title, date, time, end_time, location, platform, is_archived')
      .in('id', ids)
    eventosPorId = new Map((eventos || []).map((evento) => [evento.id, evento]))
  }

  const hoje = hojeISO()
  const json = (id) => String(id)

  const minhas = linhas.map((row) => {
    const evento = row.evento_id ? eventosPorId.get(row.evento_id) || null : null
    return {
      id: json(row.id),
      shareCode: row.share_code || '',
      compareceu: Boolean(row.compareceu),
      evento,
      passado: !evento?.date || evento.date < hoje,
      arquivado: evento?.is_archived === true,
    }
  })

  const proximas = minhas
    .filter((item) => item.evento && !item.passado && !item.arquivado)
    .sort((a, b) => String(a.evento.date).localeCompare(String(b.evento.date)))

  const passadas = minhas
    .filter((item) => !item.evento || item.passado || item.arquivado)
    .sort((a, b) => String(b.evento?.date || '').localeCompare(String(a.evento?.date || '')))

  let proximosEventos = []
  try {
    const todos = await getEvents(lang)
    proximosEventos = todos
      .filter((evento) => evento.date && evento.date >= hoje)
      .sort((a, b) => String(a.date).localeCompare(String(b.date)))
      .slice(0, PROXIMOS)
  } catch {
    // O calendário é um extra: sem ele, as inscrições continuam a abrir.
    proximosEventos = []
  }

  const fmtData = (value) => {
    if (!value) return ''
    return new Date(`${value}T00:00:00`).toLocaleDateString(locale, {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
    })
  }

  const hrefEvento = (evento) => `${SITE_ORIGIN}/${lang}/eventos/${evento.slug}`

  const comprovativo = (item) =>
    item.shareCode
      ? `${SITE_ORIGIN}/api/comprovativo/${item.id}/pdf?code=${item.shareCode}&lang=${lang}`
      : null

  const estado = (item) => {
    if (!item.passado) return { label: t('account.events.confirmed'), tone: 'ok' }
    if (item.compareceu) return { label: t('account.events.attended'), tone: 'ok' }
    return { label: t('account.events.past'), tone: '' }
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{t('account.events.title')}</h1>
          <p className="conta-sub">{t('account.events.sub')}</p>
        </div>
        <div className="conta-head-acts">
          <Link className="conta-btn conta-btn--ghost conta-btn--sm" href="/perfil">
            {t('account.common.back')}
          </Link>
        </div>
      </header>

      {inscricoesError && (
        <p className="conta-alert conta-alert--bad" role="alert">
          {t('account.events.loadError')}
        </p>
      )}

      <section className="conta-panel" aria-labelledby="conta-inscricoes">
        <div className="conta-panel-head">
          <h2 id="conta-inscricoes" className="conta-panel-title">
            <Ticket size={15} aria-hidden="true" />
            {t('account.events.mine')}
            {proximas.length > 0 && <span className="conta-panel-count">{proximas.length}</span>}
          </h2>
        </div>

        {proximas.length === 0 ? (
          <div className="conta-empty">
            <p className="conta-empty-title">{t('account.events.emptyTitle')}</p>
            <p className="conta-empty-sub">{t('account.events.emptySub')}</p>
          </div>
        ) : (
          <ul className="conta-rows">
            {proximas.map((item) => {
              const selo = estado(item)
              return (
                <li key={item.id} className="conta-row">
                  <div className="conta-row-main">
                    <span className="conta-row-kicker">
                      {fmtData(item.evento.date)}
                      {item.evento.time ? ` · ${item.evento.time}` : ''}
                    </span>
                    <a className="conta-row-title" href={hrefEvento(item.evento)}>
                      {item.evento.title}
                    </a>
                    <span className="conta-row-meta">
                      {[item.evento.location || item.evento.platform, selo.label]
                        .filter(Boolean)
                        .join(' · ')}
                    </span>
                  </div>
                  <div className="conta-row-acts">
                    <a className="conta-btn conta-btn--ghost conta-btn--sm" href={hrefEvento(item.evento)}>
                      {t('account.common.viewEvent')}
                    </a>
                    {comprovativo(item) && (
                      <a
                        className="conta-btn conta-btn--ghost conta-btn--sm"
                        href={comprovativo(item)}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        {t('account.common.receipt')}
                      </a>
                    )}
                    <CancelInscriptionButton id={item.id} />
                  </div>
                </li>
              )
            })}
          </ul>
        )}
      </section>

      <section className="conta-panel" aria-labelledby="conta-dados-inscricao">
        <div className="conta-panel-head">
          <h2 id="conta-dados-inscricao" className="conta-panel-title">
            {t('account.inscription.title')}
          </h2>
        </div>
        <InscriptionDetailsForm
          email={user.email || ''}
          initial={{
            nome: dadosInscricao.nome || meta.full_name || meta.display_name || '',
            telefone: dadosInscricao.telefone || '',
            profissao: dadosInscricao.profissao || '',
            genero: dadosInscricao.genero || '',
            faixa_etaria: dadosInscricao.faixa_etaria || '',
            nivel_escolaridade: dadosInscricao.nivel_escolaridade || '',
          }}
        />
      </section>

      <section className="conta-panel" aria-labelledby="conta-proximos">
        <div className="conta-panel-head">
          <h2 id="conta-proximos" className="conta-panel-title">
            <CalendarDays size={15} aria-hidden="true" />
            {t('account.events.upcomingTitle')}
          </h2>
          <a
            className="conta-btn conta-btn--ghost conta-btn--sm"
            href={`${SITE_ORIGIN}/${lang}/eventos`}
          >
            {t('account.common.seeAll')}
          </a>
        </div>

        {proximosEventos.length === 0 ? (
          <div className="conta-empty">
            <p className="conta-empty-title">{t('account.events.upcomingEmptyTitle')}</p>
            <p className="conta-empty-sub">{t('account.events.upcomingEmptySub')}</p>
          </div>
        ) : (
          <ul className="conta-rows">
            {proximosEventos.map((evento) => (
              <li key={evento.id} className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-kicker">
                    {fmtData(evento.date)}
                    {evento.time ? ` · ${evento.time}` : ''}
                  </span>
                  <a className="conta-row-title" href={hrefEvento(evento)}>
                    {evento.title}
                  </a>
                  <span className="conta-row-meta">
                    {[evento.location || evento.platform, evento.categoryLabel]
                      .filter(Boolean)
                      .join(' · ')}
                  </span>
                </div>
                <div className="conta-row-acts">
                  <a className="conta-btn conta-btn--primary conta-btn--sm" href={hrefEvento(evento)}>
                    {t('account.common.viewAndRegister')}
                  </a>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>

      {passadas.length > 0 && (
        <section className="conta-panel" aria-labelledby="conta-passadas">
          <div className="conta-panel-head">
            <h2 id="conta-passadas" className="conta-panel-title">
              <CheckCircle2 size={15} aria-hidden="true" />
              {t('account.events.pastTitle')}
              <span className="conta-panel-count">{passadas.length}</span>
            </h2>
          </div>
          <ul className="conta-rows">
            {passadas.map((item) => (
              <li key={item.id} className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-kicker">
                    {item.evento ? fmtData(item.evento.date) : t('account.events.removedEvent')}
                  </span>
                  {item.evento ? (
                    <a className="conta-row-title" href={hrefEvento(item.evento)}>
                      {item.evento.title}
                    </a>
                  ) : (
                    <span className="conta-row-title">{t('account.events.unavailable')}</span>
                  )}
                  <span className="conta-row-meta">
                    {[item.evento?.location || item.evento?.platform, estado(item).label]
                      .filter(Boolean)
                      .join(' · ')}
                  </span>
                </div>
                <div className="conta-row-acts">
                  {comprovativo(item) && (
                    <a
                      className="conta-btn conta-btn--ghost conta-btn--sm"
                      href={comprovativo(item)}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Comprovativo
                    </a>
                  )}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  )
}
