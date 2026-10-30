/**
 * Os níveis que administram o site.
 *
 * Vive num módulo puro (sem cookies nem Supabase) porque é lido em três
 * mundos que não podem partilhar `lib/supabase/server`: o servidor, o
 * cliente (`AuthGuard`) e o middleware do Edge (`proxy.js`).
 *
 * `admin` é o papel legado da 0001 — a RLS `is_admin()` continua a aceitá-lo
 * e a matriz interna trata-o como superadmin, por isso aqui também conta.
 */
export const ADMIN_ROLES = ['admin', 'superadmin']

/** É um nível de administração do site? */
export function isAdminRole(role) {
  return typeof role === 'string' && ADMIN_ROLES.includes(role)
}
