'use client'

import { useCallback } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import AdminSidebar from '@/components/layout/AdminSidebar'
import AdminTopBar from '@/components/layout/AdminTopBar'

/**
 * AdminSidebarWrapper — Client Component
 *
 * Combina Sidebar + TopBar + Content area.
 * Gere interatividade: sidebar toggle mobile, logout handler.
 * Recebe dados do servidor como props (user profile).
 */
export default function AdminSidebarWrapper({ lang, user, children }) {
  const router = useRouter()
  const params = useParams()
  const currentLang = lang || params.lang

  const handleLogout = useCallback(async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push(`/${currentLang}/admin`)
  }, [router, currentLang])

  return (
    <>
      <AdminSidebar
        lang={currentLang}
        user={user}
        onLogout={handleLogout}
      />
      <div className="admin-main-content">
        <AdminTopBar user={user} />
        <div className="admin-content">
          {children}
        </div>
      </div>
    </>
  )
}
