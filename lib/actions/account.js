'use server'

import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'

/**
 * Apagar a própria conta (área de conta, /perfil/seguranca).
 *
 * O cliente só pode pedir; quem apaga é o servidor, com a chave de serviço —
 * `auth.admin.deleteUser` não existe para o papel `authenticated`. Antes de
 * apagar:
 *
 *   1. exige a palavra escrita («APAGAR») — evita o clique acidental num
 *      botão que não tem desfazer;
 *   2. exige sessão válida (nunca apagar por id vindo do formulário);
 *   3. recusa contas da equipa interna (`admin_users`): apagar a conta de
 *      quem gere conteúdo deixaria o CMS sem autor e não é um pedido que se
 *      resolva sozinho na área de conta.
 *
 * O que acontece aos dados: `localizador.favorites` e `public.saved_items`
 * saem em cascata com o `auth.users`; as reservas do Localizador ficam com
 * `user_id = null` (são registo operacional da farmácia e não se apagam).
 */
export async function deleteMyAccount(confirmacao) {
  if (String(confirmacao || '').trim().toUpperCase() !== 'APAGAR') {
    return { ok: false, error: 'CONFIRMACAO' }
  }

  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'SEM_SESSAO' }

  // A policy de leitura própria de `admin_users` deixa confirmar isto com o
  // token da pessoa — não é preciso service-role para a decisão.
  const { data: interno } = await supabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle()
  if (interno) return { ok: false, error: 'CONTA_INTERNA' }

  const admin = createAdminClient()
  const { error } = await admin.auth.admin.deleteUser(user.id)
  if (error) return { ok: false, error: 'FALHOU' }

  // A sessão deixa de valer quando o user desaparece, mas as cookies ficam no
  // browser até alguém as limpar. Sair aqui (scope global) faz o resto.
  try {
    await supabase.auth.signOut({ scope: 'global' })
  } catch {
    // Sem sessão para terminar — o delete já aconteceu.
  }

  return { ok: true }
}
