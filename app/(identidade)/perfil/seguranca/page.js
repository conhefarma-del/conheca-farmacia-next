import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import SegurancaClient from '@/components/account/SegurancaClient'
import { accountTranslator } from '@/lib/account-i18n'

export const dynamic = 'force-dynamic'

export async function generateMetadata() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const { t } = accountTranslator(user)
  return { title: t('account.security.title'), robots: { index: false, follow: false } }
}

/**
 * Segurança da conta.
 *
 * O `isInternal` sai da própria sessão (policy de leitura própria de
 * `admin_users`) e serve só para a UI esconder o botão de apagar: a Server
 * Action volta a verificar o mesmo antes de apagar — esconder um botão nunca
 * é autorização.
 */
export default async function SegurancaPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil/seguranca')

  const { data: interno } = await supabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle()

  return <SegurancaClient email={user.email || ''} isInternal={Boolean(interno)} />
}
