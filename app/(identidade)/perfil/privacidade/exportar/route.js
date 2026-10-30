import { createClient, createLocalizadorClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { loadInscricoes } from '@/lib/account-inscricoes'

export const dynamic = 'force-dynamic'

/**
 * Exportar os dados da conta.
 *
 * Um JSON com o que a conta guarda sobre a pessoa — não um dump da base.
 * `favorites` e `reservations` vivem no schema `localizador`; as inscrições
 * são lidas com a mesma regra da área de conta (`user_id` ou qualquer e-mail
 * da pessoa, incluindo os anteriores), para a exportação não perder o
 * histórico depois de uma troca de endereço.
 */
export async function GET() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return new Response('Sem sessão', { status: 401 })

  const meta = user.user_metadata || {}
  const localizador = await createLocalizadorClient()

  const [favoritos, reservas] = await Promise.all([
    localizador
      .from('favorites')
      .select('id, drug_id, pharmacy_id, created_at')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false }),
    localizador
      .from('reservations')
      .select(
        'id, status, quantity, confirmed_quantity, requester_name, requester_phone, requester_municipio, notes, created_at, resolved_at, drugs(name, form, dosage), pharmacies(name)',
      )
      .eq('user_id', user.id)
      .order('created_at', { ascending: false }),
  ])

  const inscricoes = await loadInscricoes(createAdminClient(), user)

  const payload = {
    exportado_em: new Date().toISOString(),
    conta: {
      id: user.id,
      email: user.email,
      email_confirmado_em: user.email_confirmed_at,
      criada_em: user.created_at,
      nome: meta.full_name || meta.display_name || null,
      telefone: meta.phone || null,
      municipio: meta.municipality || null,
      idioma: meta.lang || 'pt',
      aparencia: meta.theme || 'system',
      emails_anteriores: Array.isArray(meta.emails_anteriores) ? meta.emails_anteriores : [],
    },
    guardados: favoritos.data || [],
    reservas: reservas.data || [],
    inscricoes: inscricoes.map((row) => ({
      id: row.id,
      evento_id: row.evento_id,
      criada_em: row.created_at,
      compareceu: row.compareceu,
      municipio: row.municipio,
    })),
  }

  return new Response(JSON.stringify(payload, null, 2), {
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'content-disposition': `attachment; filename="conheca-farmacia-conta-${new Date().toISOString().slice(0, 10)}.json"`,
      'cache-control': 'no-store',
    },
  })
}
