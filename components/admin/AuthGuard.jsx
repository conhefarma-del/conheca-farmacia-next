'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { createClient } from '../../lib/supabase/client'
import { ADMIN_ROLES } from '@/lib/admin-roles'
import { useIdleTimeout } from '@/hooks/useIdleTimeout'

/**
 * AuthGuard — SEC-ATH-02
 *
 * Verifica sessão Supabase E existência na tabela admin_users.
 * NUNCA confiar apenas na sessão (diretriz SEC-ATH-02).
 * Exige segundo fator confirmado — sessão `aal2` (SEC-ATH-06).
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
      // O `role` faz parte da verificação: contas `farmacia` vivem na mesma
      // tabela e não são administradoras do site. A lista vive em
      // `lib/admin-roles` para o servidor, o cliente e o proxy lerem a mesma.
      const { data: adminUser, error: adminError } = await supabase
        .from('admin_users')
        .select('user_id, role')
        .eq('user_id', user.id)
        .in('role', ADMIN_ROLES)
        .single()

      if (adminError || !adminUser) {
        // Não é admin — redirecionar. Sem `signOut`: a sessão é a da conta
        // pessoal (partilhada com o site e o Localizador) e sair daqui
        // desligava a pessoa de todo o lado.
        router.replace(`/${params.lang}/admin`)
        return
      }

      // 3. SEC-ATH-06: o segundo fator é obrigatório. Sem `aal2` não se
      // entra, mesmo com uma sessão de conta válida.
      const { data: aal } = await supabase.auth.mfa.getAuthenticatorAssuranceLevel()
      if (aal?.currentLevel !== 'aal2') {
        router.replace(`/${params.lang}/admin/2fa`)
        return
      }

      // 4. Autenticado, é admin e tem o segundo fator confirmado
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
