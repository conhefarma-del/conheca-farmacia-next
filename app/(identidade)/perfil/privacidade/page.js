import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Download, KeyRound, ShieldCheck } from 'lucide-react'
import { createClient } from '@/lib/supabase/server'
import { SITE_ORIGIN } from '@/lib/account-urls'
import { accountTranslator } from '@/lib/account-i18n'

export const dynamic = 'force-dynamic'

export async function generateMetadata() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const { t } = accountTranslator(user)
  return { title: t('account.privacy.title'), robots: { index: false, follow: false } }
}

/**
 * Privacidade e dados.
 *
 * Duas coisas que a pessoa tem direito a fazer sozinha: levar os seus dados e
 * apagá-los. O apagar já existe em /perfil/seguranca (é uma Server Action que
 * exige a palavra escrita); o exportar é a rota irmã `exportar`.
 *
 * Nada aqui promete mais do que o código faz: o JSON sai com o perfil, os
 * guardados, as reservas e as inscrições; a conta interna não aparece porque
 * esta área é dos clientes.
 */
export default async function PrivacidadePage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/privacidade')

  const { lang, t } = accountTranslator(user)

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{t('account.privacy.title')}</h1>
          <p className="conta-sub">{t('account.privacy.sub')}</p>
        </div>
      </header>

      <div className="conta-grid2">
        <div>
          <section className="conta-panel" aria-labelledby="priv-dados">
            <div className="conta-panel-head">
              <h2 id="priv-dados" className="conta-panel-title">
                <ShieldCheck size={14} />
                {t('account.privacy.storeTitle')}
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{t('account.privacy.storeAccount')}</span>
                  <span className="conta-row-meta">{t('account.privacy.storeAccountSub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{t('account.privacy.storeSaved')}</span>
                  <span className="conta-row-meta">{t('account.privacy.storeSavedSub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{t('account.privacy.storeReservations')}</span>
                  <span className="conta-row-meta">{t('account.privacy.storeReservationsSub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{t('account.privacy.storeInscriptions')}</span>
                  <span className="conta-row-meta">{t('account.privacy.storeInscriptionsSub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{t('account.privacy.storeStudy')}</span>
                  <span className="conta-row-meta">{t('account.privacy.storeStudySub')}</span>
                </div>
              </li>
            </ul>
          </section>

          <section className="conta-panel" aria-labelledby="priv-exportar">
            <div className="conta-panel-head">
              <h2 id="priv-exportar" className="conta-panel-title">
                <Download size={14} />
                {t('account.privacy.exportTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.privacy.exportHint')}
              </p>
              {/* Route Handler de download, não uma página: `Link` faria uma
                  navegação de cliente e o ficheiro nunca chegava a
                  descarregar. */}
              <a
                className="conta-btn conta-btn--primary"
                href="/perfil/privacidade/exportar"
                download
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                <Download size={15} />
                {t('account.privacy.exportCta')}
              </a>
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel" aria-labelledby="priv-apagar">
            <div className="conta-panel-head">
              <h2 id="priv-apagar" className="conta-panel-title">
                <KeyRound size={14} />
                {t('account.privacy.deleteTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.privacy.deleteHint')}
              </p>
              <Link
                href="/perfil/seguranca"
                className="conta-btn conta-btn--ghost"
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                {t('account.privacy.openSecurity')}
              </Link>
            </div>
          </section>

          <section className="conta-panel" aria-labelledby="priv-politicas">
            <div className="conta-panel-head">
              <h2 id="priv-politicas" className="conta-panel-title">
                {t('account.privacy.policiesTitle')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                {t('account.privacy.policiesHint')}
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.4rem', marginTop: '0.75rem' }}>
                <a
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  href={`${SITE_ORIGIN}/${lang}/privacidade`}
                >
                  {t('account.privacy.privacy')}
                </a>
                <a
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  href={`${SITE_ORIGIN}/${lang}/termos`}
                >
                  {t('account.privacy.terms')}
                </a>
              </div>
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}
