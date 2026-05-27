'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { useIdleTimeout } from '@/hooks/useIdleTimeout'

/**
 * AuthGuard — SEC-ATH-02
 *
 * Verifica sessão Supabase E existência na tabela admin_users.
 * NUNCA confiar apenas na sessão (diretriz SEC-ATH-02).
 * Inclui idle timeout de 30min (SEC-ATH-03).
 */
export default function AuthGuard({ children }) {
  const router = useRouter()
  const params = useParams()
  const [loading, setLoading] = useState(true)
  const [authorized, setAuthorized] = useState(false)

  // SEC-ATH-03: 30min idle timeout auto-logout
  useIdleTimeout()

  useEffect(() => {
    const checkAuth = async () => {
      const supabase = createClient()

      // 1. Verificar sessão Supabase
      const { data: { user }, error: authError } = await supabase.auth.getUser()

      if (authError || !user) {
        router.push(`/${params.lang}/admin`)
        return
      }

      // 2. SEC-ATH-02: Verificar na tabela admin_users (NUNCA confiar apenas na sessão)
      const { data: adminUser, error: adminError } = await supabase
        .from('admin_users')
        .select('user_id')
        .eq('user_id', user.id)
        .single()

      if (adminError || !adminUser) {
        // Não é admin — terminar sessão e redirecionar
        await supabase.auth.signOut()
        router.push(`/${params.lang}/admin`)
        return
      }

      // 3. Autenticado e é admin
      setAuthorized(true)
      setLoading(false)
    }

    checkAuth()
  }, [router, params.lang])

  if (loading) {
    return (
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          background: 'var(--admin-bg)',
        }}
      >
        <div
          style={{
            width: 40,
            height: 40,
            border: '3px solid var(--admin-border)',
            borderTopColor: 'var(--admin-primary)',
            borderRadius: '50%',
            animation: 'admin-spin 1s linear infinite',
          }}
        />
        <style>{`@keyframes admin-spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    )
  }

  if (!authorized) return null

  return children
}
