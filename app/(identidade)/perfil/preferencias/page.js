import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import PreferenciasPanel from '@/components/account/PreferenciasPanel'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Preferências',
  robots: { index: false, follow: false },
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

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">A minha conta</p>
          <h1 className="conta-title">Preferências</h1>
          <p className="conta-sub">
            Idioma da conta, aparência e os dados de contacto que já vêm escritos nos formulários
            do site e do Localizador.
          </p>
        </div>
      </header>

      <PreferenciasPanel
        lang={meta.lang === 'en' || meta.preferred_lang === 'en' ? 'en' : 'pt'}
        theme={['light', 'dark', 'system'].includes(meta.theme) ? meta.theme : 'system'}
        phone={meta.phone || meta.inscricao?.telefone || ''}
        municipality={meta.municipality || ''}
      />
    </main>
  )
}
