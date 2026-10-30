import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import PreferenciasPanel from '@/components/account/PreferenciasPanel'
import { accountTranslator } from '@/lib/account-i18n'

export const dynamic = 'force-dynamic'

export async function generateMetadata() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const { t } = accountTranslator(user)
  return { title: t('account.preferences.title'), robots: { index: false, follow: false } }
}

/**
 * Preferências da conta.
 *
 * A página é a casa do painel que antes vivia na visão geral: idioma,
 * aparência e os dados de contacto (telefone e município) que pré-preenchem
 * formulários no site e no Localizador.
 */
export default async function PreferenciasPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/preferencias')

  const meta = user.user_metadata || {}
  const { lang, t } = accountTranslator(user)

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{t('account.preferences.title')}</h1>
          <p className="conta-sub">{t('account.preferences.sub')}</p>
        </div>
      </header>

      <PreferenciasPanel
        lang={lang}
        theme={['light', 'dark', 'system'].includes(meta.theme) ? meta.theme : 'system'}
        phone={meta.phone || meta.inscricao?.telefone || ''}
        municipality={meta.municipality || ''}
      />
    </main>
  )
}
