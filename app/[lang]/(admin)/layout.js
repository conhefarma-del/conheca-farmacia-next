import '@/styles/admin/admin.css'
import { createClient } from '@/lib/supabase/server'
import AuthGuard from '@/components/admin/AuthGuard'
import AdminSidebar from '@/components/layout/AdminSidebar'
import AdminTopBar from '@/components/layout/AdminTopBar'

export default async function AdminLayout({ children, params }) {
  const { lang } = await params

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
