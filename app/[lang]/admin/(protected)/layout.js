import '@/styles/admin/admin.css'
import { redirect } from 'next/navigation'
import AuthGuard from '@/components/admin/AuthGuard'
import AdminSidebarWrapper from '@/components/admin/AdminSidebarWrapper'
import { getAdminSession } from '@/lib/admin-guard'

export const dynamic = 'force-dynamic'

/**
 * Protected Admin Layout — Server Component
 *
 * SEC-ATH-02: sessão + nível de administração verificados no servidor antes
 * de renderizar qualquer página — pelo guard único (`lib/admin-guard`), que
 * exige `role` de admin e não apenas uma linha em `admin_users` (essa tabela
 * também guarda as contas `farmacia` do portal).
 *
 * SEC-ATH-06: a sessão normal do site (aal1) não abre o painel. Quem entra
 * com o e-mail e a palavra-passe da conta comum — mesmo sendo admin — fica
 * sem o segundo fator e é reenviado para /admin/2fa. Só `aal2` passa.
 *
 * A verificação é aqui, no servidor: o AuthGuard do cliente corria depois de
 * o HTML já ter sido gerado.
 */
export default async function AdminProtectedLayout({ children, params }) {
  const { lang } = await params

  const ctx = await getAdminSession()
  if (!ctx) redirect(`/${lang}/admin`)

  const { supabase, user } = ctx

  // SEC-ATH-06: segundo fator obrigatório. Sem TOTP inscrito, /admin/2fa é o
  // caminho (vive fora deste layout, por isso não há bloqueio circular).
  const { data: aal } = await supabase.auth.mfa.getAuthenticatorAssuranceLevel()

  if (aal?.currentLevel !== 'aal2') redirect(`/${lang}/admin/2fa`)

  const { data: adminUser } = await supabase
    .from('admin_users')
    .select('name, email')
    .eq('user_id', user.id)
    .single()

  const adminProfile = {
    name: adminUser?.name || '',
    email: adminUser?.email || user.email || '',
  }

  return (
    <AuthGuard>
      <AdminSidebarWrapper lang={lang} user={adminProfile}>
        {children}
      </AdminSidebarWrapper>
    </AuthGuard>
  )
}
