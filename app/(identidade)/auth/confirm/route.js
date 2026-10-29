import { completeAuthLink } from '@/lib/account-complete'

export const dynamic = 'force-dynamic'

/**
 * Destino dos links de confirmação de e-mail e do retorno do Google.
 * Sem `next` explícito, a conta abre no hub (`/perfil`).
 */
export async function GET(request) {
  return completeAuthLink(request, '/perfil')
}
