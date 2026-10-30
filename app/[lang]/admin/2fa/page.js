import Link from 'next/link'
import { redirect } from 'next/navigation'
import '@/styles/admin/admin.css'
import TwoFactorSection from '@/components/admin/TwoFactorSection'
import { getAdminSession } from '@/lib/admin-guard'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Verificação em dois passos | Administração',
  robots: { index: false, follow: false },
}

/**
 * Ativação do segundo fator — fora do layout `(protected)`.
 *
 * O gate do painel exige sessão `aal2`. Se esta página vivesse lá dentro,
 * um admin sem TOTP inscrito ficava sem forma de se inscrever (trancado
 * fora do próprio painel). Aqui basta a sessão de administração normal
 * (validada pelo guard único, que olha ao `role`); depois de ativar, a
 * entrada passa por /admin.
 */
export default async function AdminTwoFactorPage({ params }) {
  const { lang } = await params

  const ctx = await getAdminSession()
  if (!ctx) redirect(`/${lang}/admin`)

  return (
    <main style={{ maxWidth: 720, margin: '0 auto', padding: '48px 24px' }}>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Verificação em dois passos</h1>
        <p className="admin-page-subtitle">
          O painel só abre com a autenticação de dois fatores confirmada. Ative o TOTP abaixo e
          depois entre em <strong>/admin</strong> com a palavra-passe e o código de 6 dígitos.
        </p>
      </div>

      <TwoFactorSection />

      <p style={{ marginTop: 24, fontSize: 14, color: 'var(--admin-text-muted)' }}>
        Já tem o TOTP ativo?{' '}
        <Link href={`/${lang}/admin`} style={{ textDecoration: 'underline' }}>
          Entrar com o código
        </Link>
      </p>
    </main>
  )
}
