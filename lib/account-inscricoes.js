/**
 * Inscrições de uma conta.
 *
 * `inscricoes` nasceu ligada só pelo e-mail — não havia `user_id`. Uma troca
 * de endereço apagava o histórico da área de conta. A ligação passa a ter
 * duas pernas:
 *
 *   1. `user_id` (migração 292), reclamado quando a pessoa entra ou pede a
 *      troca de e-mail;
 *   2. a lista de e-mails da conta, incluindo os anteriores, que ficam em
 *      `user_metadata.emails_anteriores` no momento da troca.
 *
 * Ler pelas duas e juntar por id é o que faz a inscrição antiga continuar a
 * aparecer numa conta cujo e-mail mudou. A leitura é sempre server-side com
 * service-role: a RLS de `inscricoes` não abre leitura ao público.
 */

/** E-mails da conta, actuais e anteriores, em minúsculas e sem repetições. */
export function emailsDaConta(user, meta = user?.user_metadata || {}) {
  const anteriores = Array.isArray(meta?.emails_anteriores) ? meta.emails_anteriores : []
  const lista = [user?.email, ...anteriores]
    .filter(Boolean)
    .map((email) => String(email).trim().toLowerCase())
  return [...new Set(lista)]
}

const COLUNAS = 'id, email, evento_id, created_at, compareceu, share_code, municipio'

/**
 * Todas as inscrições da pessoa, sem repetir linhas que entraram pelas duas
 * vias. `select` permite pedir só as colunas que cada página usa.
 */
export async function loadInscricoes(admin, user, { select = COLUNAS } = {}) {
  const porId = new Map()

  if (user?.id) {
    const { data } = await admin.from('inscricoes').select(select).eq('user_id', user.id)
    for (const row of data || []) porId.set(String(row.id), row)
  }

  const emails = emailsDaConta(user)
  if (emails.length > 0) {
    // `email.eq.` é exacto e os emails são gravados em minúsculas; valores
    // PostgREST não podem levar vírgulas nem parênteses — e um e-mail não os
    // tem. Sem `or`, cada e-mail seria uma query.
    const filtro = emails.map((email) => `email.eq.${email}`).join(',')
    const { data } = await admin.from('inscricoes').select(select).or(filtro)
    for (const row of data || []) {
      const key = String(row.id)
      if (!porId.has(key)) porId.set(key, row)
    }
  }

  return [...porId.values()]
}

/**
 * Passa a `user_id` as inscrições que só existiam pelo e-mail. Chamado antes
 * de o endereço mudar — a partir daí o histórico já viaja com a conta.
 */
export async function reclamarInscricoes(admin, user) {
  const emails = emailsDaConta(user)
  if (!user?.id || emails.length === 0) return 0

  const { data, error } = await admin
    .from('inscricoes')
    .update({ user_id: user.id })
    .in('email', emails)
    .is('user_id', null)
    .select('id')

  if (error) return 0
  return (data || []).length
}
