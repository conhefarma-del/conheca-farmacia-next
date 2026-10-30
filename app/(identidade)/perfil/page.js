import { redirect } from 'next/navigation'
import { createClient, createLocalizadorClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import HubClient from '@/components/account/HubClient'
import { emailsDaConta, loadInscricoes } from '@/lib/account-inscricoes'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'
import { accountLocale, accountTranslator } from '@/lib/account-i18n'

export const dynamic = 'force-dynamic'

export async function generateMetadata() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const { t } = accountTranslator(user)
  return { title: t('account.kicker'), robots: { index: false, follow: false } }
}

/** Quantos guardados o hub mostra antes de mandar «ver tudo» para o Localizador. */
const VISIVEIS = 3

/** `Ben-u-ron` e `ben u ron` têm de casar: os dois catálogos são independentes. */
const normalize = (value) =>
  String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim()

/**
 * Os guardados da conta, já resolvidos para links.
 *
 * Lê `localizador.favorites` com um cliente no schema `localizador` que leva a
 * sessão da pessoa — a policy `user_id = auth.uid()` é a autoridade, e o filtro
 * explícito aqui é só para o plano de execução não varrer a tabela.
 *
 * Cada medicamento guardado tem dois destinos: a página do medicamento no site
 * (que **não** existe para todos — o catálogo do Localizador tem parafarmácia
 * que o site nunca publicará, e é por isso que o slug vem por nome) e a lista
 * de farmácias que o têm, no Localizador. As farmácias guardadas só têm o
 * segundo.
 */
async function loadSaved(supabase, userId, { t, lang }) {
  const localizador = await createLocalizadorClient()
  const { data: favorites } = await localizador
    .from('favorites')
    .select(
      'id, drug_id, pharmacy_id, drugs(id, name, molecule, form, dosage), pharmacies(id, slug, name, municipio)',
    )
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  const rows = favorites || []
  if (rows.length === 0) return { items: [], total: 0 }

  const drugNames = rows.filter((row) => row.drugs?.name).map((row) => row.drugs.name)
  let slugByName = new Map()
  if (drugNames.length > 0) {
    const { data: siteDrugs } = await supabase
      .from('drugs')
      .select('slug, name_pt')
      .eq('is_archived', false)
    slugByName = new Map((siteDrugs || []).map((drug) => [normalize(drug.name_pt), drug.slug]))
  }

  const items = rows
    .map((row) => {
      if (row.drug_id && row.drugs) {
        const slug = slugByName.get(normalize(row.drugs.name))
        return {
          key: `drug-${row.id}`,
          name: row.drugs.name,
          meta: [row.drugs.form, row.drugs.dosage, row.drugs.molecule].filter(Boolean).join(' · '),
          cta: t('account.overview.savedCtaDrug'),
          locatorHref: `${LOCATOR_ORIGIN}/medicamento/${row.drug_id}`,
          siteHref: slug ? `${SITE_ORIGIN}/${lang}/medicamento/${slug}` : null,
        }
      }
      if (row.pharmacy_id && row.pharmacies) {
        return {
          key: `pharmacy-${row.id}`,
          name: row.pharmacies.name,
          meta: row.pharmacies.municipio || t('account.overview.savedMetaPharmacy'),
          cta: t('account.overview.savedCtaPharmacy'),
          locatorHref: `${LOCATOR_ORIGIN}/farmacia/${row.pharmacies.slug}`,
          siteHref: null,
        }
      }
      // Item cujo catálogo desapareceu: o favorito continua lá, mas não há o
      // que ligar. Fica de fora em vez de virar uma linha morta.
      return null
    })
    .filter(Boolean)

  return { items: items.slice(0, VISIVEIS), total: items.length }
}

/**
 * O próximo evento em que a pessoa está inscrita.
 *
 * `inscricoes` não tem `user_id` e a RLS só deixa ler admins — a leitura é
 * server-side, com o e-mail da sessão, e só devolve o evento em si.
 */
async function loadProximaInscricao(supabase, user) {
  if (!user?.email && !emailsDaConta(user).length) return { evento: null, total: 0 }

  // Pelo `user_id` e por todos os e-mails da conta (incluindo os anteriores):
  // uma troca de endereço não esconde as inscrições antigas.
  const admin = createAdminClient()
  const linhas = await loadInscricoes(admin, user, { select: 'evento_id' })
  if (linhas.length === 0) return { evento: null, total: 0 }

  const ids = [...new Set(linhas.map((row) => row.evento_id).filter(Boolean))]
  if (ids.length === 0) return { evento: null, total: linhas.length }

  const hoje = new Date()
  hoje.setMinutes(hoje.getMinutes() - hoje.getTimezoneOffset())
  const hojeISO = hoje.toISOString().slice(0, 10)

  const { data: eventos } = await supabase
    .from('events')
    .select('id, slug, title, date, time, location, platform, is_archived')
    .in('id', ids)

  const evento =
    (eventos || [])
      .filter((item) => !item.is_archived && item.date && item.date >= hojeISO)
      .sort((a, b) => String(a.date).localeCompare(String(b.date)))[0] || null

  return { evento, total: linhas.length }
}

/**
 * Hub da conta.
 *
 * Lê a sessão no servidor (cookies partilhadas em `.conhecafarmacia.com`) e
 * passa ao cliente só o que a UI mostra — id, e-mail, nome, foto, data e os
 * guardados já resolvidos. O objecto `user` completo nunca atravessa a
 * fronteira: traz metadados que não têm nada que fazer no bundle.
 */
export default async function ContaPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) redirect('/entrar?next=/perfil')

  const meta = user.user_metadata || {}
  const { lang, t } = accountTranslator(user)

  const membroDesde = user.created_at
    ? t('account.overview.memberSinceValue', {
        date: new Date(user.created_at).toLocaleDateString(accountLocale(lang), {
          month: 'long',
          year: 'numeric',
        }),
      })
    : t('account.overview.accountDefault')

  const saved = await loadSaved(supabase, user.id, { t, lang })
  const eventos = await loadProximaInscricao(supabase, user)

  // Preferências que a conta já guarda (nascem todas em `user_metadata`).
  // O telefone cai para o das inscrições, para contas antigas não ficarem
  // com o campo vazio.
  const preferencias = {
    lang,
    theme: ['light', 'dark', 'system'].includes(meta.theme) ? meta.theme : 'system',
    phone: meta.phone || meta.inscricao?.telefone || '',
    municipality: meta.municipality || '',
  }

  return (
    <HubClient
      proximoEvento={eventos.evento}
      inscricoesTotal={eventos.total}
      preferencias={preferencias}
      profile={{
        id: user.id,
        email: user.email || '',
        name: meta.full_name || meta.display_name || '',
        avatarUrl: meta.avatar_url || '',
        verified: Boolean(user.email_confirmed_at || user.confirmed_at),
        membroDesde,
      }}
      saved={saved.items}
      savedTotal={saved.total}
    />
  )
}
