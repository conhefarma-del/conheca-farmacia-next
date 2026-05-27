import '@/styles/admin/admin.css'
import AuthGuard from '@/components/admin/AuthGuard'
import AdminSidebar from '@/components/layout/AdminSidebar'
import AdminTopBar from '@/components/layout/AdminTopBar'

export default async function AdminLayout({ children, params }) {
  const { lang } = await params

  return (
    <AuthGuard>
      <div className="admin-layout">
        <AdminSidebar lang={lang} />
        <div className="admin-main">
          <AdminTopBar />
          <div className="admin-content">
            {children}
          </div>
        </div>
      </div>
    </AuthGuard>
  )
}
