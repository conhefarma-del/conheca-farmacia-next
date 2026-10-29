import { completeAuthLink } from '@/lib/account-complete'

export const dynamic = 'force-dynamic'

/**
 * Destino do link de reposição de senha (`resetPasswordForEmail`).
 * Depois de trocar o código, a pessoa define a nova senha em
 * `/perfil/seguranca`.
 */
export async function GET(request) {
  return completeAuthLink(request, '/perfil/seguranca')
}
