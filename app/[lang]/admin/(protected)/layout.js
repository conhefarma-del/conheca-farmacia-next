import '@/styles/admin/admin.css'
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import AuthGuard from '@/components/admin/AuthGuard'
import AdminSidebarWrapper from '@/components/admin/AdminSidebarWrapper'

/**
 * Protected Admin Layout — Server Component
 *
 * SEC-ATH-02: Verifica sessão + admin_users no servidor
 * antes de renderizar qualquer página admin protegida.
 *
 * Sidebar + TopBar envolvem todas as páginas internas.
 * Login page fica em app/[lang]/admin/page.js (sem este layout).
 */
export default async function AdminProtectedLayout({ children, params }) {
  const { lang } = await params

  // Buscar perfil do admin no servidor para passar ao TopBar
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  let adminProfile = null
  if (user) {
    const { data: adminUser } = await supabase
      .from('admin_users')
      .select('name, email')
      .eq('user_id', user.id)
      .single()

    if (adminUser) {
      adminProfile = {
        name: adminUser.name || '',
        email: adminUser.email || user.email || '',
      }
    }
  }

  return (
    <AuthGuard>
      <AdminSidebarWrapper lang={lang} user={adminProfile}>
        {children}
      </AdminSidebarWrapper>
    </AuthGuard>
  )
}
