import { createClient } from '@/lib/supabase/server'
import { ADMIN_ROLES } from '@/lib/admin-roles'

/**
 * Sessão de administração do site — a ÚNICA verificação de admin.
 *
 * Antes disto havia catorze cópias de `requireAdmin()` espalhadas por
 * `lib/actions/*`, todas a perguntar só «existe linha em `admin_users`?».
 * Como essa tabela também guarda as contas `farmacia` do portal, qualquer
 * conta de balcão passava por administradora. A verificação certa é
 * sessão + **role** — e vive aqui, uma vez.
 *
 * Devolve `{ supabase, user, role }` (o cliente com a sessão, para quem
 * chama não repetir a leitura) ou `null`. Nunca lança: quem chama decide
 * entre devolver `{ success: false }` numa action ou `redirect()` numa
 * página.
 *
 * Não confundir com a área interna (`lib/platform/session.js`), que tem os
 * cinco níveis da equipa e exige `aal2` por acção. Esta é a do painel do
 * site: `admin` e `superadmin`.
 */
export async function getAdminSession() {
  const supabase = await createClient()

  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()

  if (authError || !user) return null

  const { data: adminUser, error: adminError } = await supabase
    .from('admin_users')
    .select('user_id, role')
    .eq('user_id', user.id)
    .in('role', ADMIN_ROLES)
    .single()

  if (adminError || !adminUser) return null

  return { supabase, user, role: adminUser.role }
}

/** Só a resposta sim/não, para páginas que não precisam do cliente. */
export async function isAdmin() {
  return Boolean(await getAdminSession())
}
