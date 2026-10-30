import '@/styles/admin/admin.css'
import AuthGuard from '@/components/admin/AuthGuard'
import AdminSidebar from '@/components/layout/AdminSidebar'
import AdminTopBar from '@/components/layout/AdminTopBar'
import { getAdminSession } from '@/lib/admin-guard'

/**
 * Layout legado do admin (route group antigo). O gate verdadeiro continua a
 * ser o `AuthGuard` (cliente) e o layout `admin/(protected)` (servidor); o
 * perfil da top-bar sai do guard único, para não haver aqui uma segunda
 * definição de «quem é admin».
 */
export default async function AdminLayout({ children, params }) {
  const { lang } = await params

  const ctx = await getAdminSession()
  let adminProfile = null

  if (ctx) {
    const { supabase, user } = ctx
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
      <div className="admin-layout">
        <AdminSidebar lang={lang} />
        <div className="admin-main">
          <AdminTopBar user={adminProfile} />
          <div className="admin-content">
            {children}
          </div>
        </div>
      </div>
    </AuthGuard>
  )
}
