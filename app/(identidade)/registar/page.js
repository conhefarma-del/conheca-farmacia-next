import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import RegistoClient from '@/components/auth/RegistoForm'
import { safeNext } from '@/lib/account-next'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Criar conta',
  robots: { index: false, follow: false },
}

/**
 * Criação de conta. O e-mail de confirmação volta a `/auth/confirm`, que troca
 * o código por sessão e segue para `/perfil` (ou para o `next` que veio).
 */
export default async function RegistarPage({ searchParams }) {
  const params = await searchParams
  const next = safeNext(params?.next, '/perfil')

  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (user) redirect(next)

  return <RegistoClient lang="pt" basePath="" nextUrl={next} confirmPath="/auth/confirm" />
}
