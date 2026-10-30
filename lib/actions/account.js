'use server'

import { revalidatePath } from 'next/cache'
import { cookies, headers } from 'next/headers'
import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { emailsDaConta, reclamarInscricoes } from '@/lib/account-inscricoes'

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

/** `inscricoes.id` é bigint (UUID em registos antigos). */
const INSCRICAO_ID = /^(\d{1,18}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/i

/**
 * Cancelar a própria inscrição num evento.
 *
 * `inscricoes` não tem `user_id` — a ligação é o e-mail com que a pessoa se
 * inscreveu. O id vem do formulário, por isso a autorização não pode ser o
 * id: lemos a linha com a chave de serviço e comparamos o e-mail com o da
 * sessão. Só depois apagamos, e só antes de o evento acontecer.
 */
export async function cancelarInscricao(_estado, formData) {
  const id = String(formData?.get('id') || '').trim()
  if (!INSCRICAO_ID.test(id)) return { ok: false, error: 'INVALIDA' }

  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user?.email) return { ok: false, error: 'SEM_SESSAO' }
  // Confirmado é diferente de escrito. Sem esta guarda, uma conta criada com o
  // endereço de outra pessoa reclamava as inscrições dela (e podia cancelá-las)
  // antes de o dono alguma vez ter confirmado o e-mail.
  if (!user.email_confirmed_at) return { ok: false, error: 'EMAIL_NAO_CONFIRMADO' }

  const admin = createAdminClient()
  const { data: inscricao } = await admin
    .from('inscricoes')
    .select('id, email, compareceu, evento_id')
    .eq('id', id)
    .maybeSingle()

  if (!inscricao) return { ok: false, error: 'NAO_ENCONTRADA' }

  const mesmoEmail =
    String(inscricao.email || '').trim().toLowerCase() === user.email.trim().toLowerCase()
  if (!mesmoEmail) return { ok: false, error: 'SEM_PERMISSAO' }
  if (inscricao.compareceu) return { ok: false, error: 'JA_DECORREU' }

  if (inscricao.evento_id) {
    const { data: evento } = await admin
      .from('events')
      .select('date')
      .eq('id', inscricao.evento_id)
      .maybeSingle()

    const hoje = new Date()
    hoje.setMinutes(hoje.getMinutes() - hoje.getTimezoneOffset())
    const hojeISO = hoje.toISOString().slice(0, 10)

    if (!evento?.date || evento.date < hojeISO) return { ok: false, error: 'JA_DECORREU' }
  }

  const { error } = await admin.from('inscricoes').delete().eq('id', id)
  if (error) return { ok: false, error: 'FALHOU' }

  revalidatePath('/perfil/eventos')
  return { ok: true }
}

/** Opções aceites — as mesmas do formulário público de inscrição. */
const PROFISSOES = new Set([
  '',
  'enfermeiro',
  'medico',
  'farmaceutico',
  'estudante-saude',
  'tecnico-medio-saude',
  'tecnico-radiologia',
  'tecnico-analises-clinicas',
  'medico-dentista',
  'biologo-analista',
  'psicologo',
  'nutricionista',
  'fisioterapeuta',
  'outro',
])
const GENEROS = new Set(['', 'masculino', 'feminino'])
const FAIXAS = new Set(['', 'menor-18', '18-24', '25-34', '35-44', '45-54', '55+'])
const ESCOLARIDADES = new Set([
  '',
  'tecnico-profissional',
  'licenciatura',
  'pos-graduacao-mestrado',
  'doutoramento',
])

/**
 * Dados que o formulário público de inscrição usa para arrancar preenchido.
 *
 * Ficam em `user_metadata.inscricao` (o mesmo sítio do nome e da fotografia) —
 * não inscrevem em evento nenhum e não tocam em `inscricoes`. A inscrição
 * continua a ser validada pelo formulário público; isto é só conveniência.
 */
export async function guardarDadosInscricao(_estado, formData) {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'SEM_SESSAO' }

  const texto = (name, max) => String(formData?.get(name) || '').trim().slice(0, max)
  const nome = texto('nome', 200)
  const telefone = texto('telefone', 20)
  const profissao = texto('profissao', 40)
  const genero = texto('genero', 20)
  const faixaEtaria = texto('faixa_etaria', 20)
  const escolaridade = texto('nivel_escolaridade', 40)

  if (telefone && !/^[0-9+()\s-]{6,20}$/.test(telefone)) {
    return { ok: false, error: 'TELEFONE' }
  }
  if (
    !PROFISSOES.has(profissao) ||
    !GENEROS.has(genero) ||
    !FAIXAS.has(faixaEtaria) ||
    !ESCOLARIDADES.has(escolaridade)
  ) {
    return { ok: false, error: 'INVALIDO' }
  }

  const { error } = await supabase.auth.updateUser({
    data: {
      inscricao: {
        nome,
        telefone,
        profissao,
        genero,
        faixa_etaria: faixaEtaria,
        nivel_escolaridade: escolaridade,
      },
    },
  })
  if (error) return { ok: false, error: 'FALHOU' }

  revalidatePath('/perfil/eventos')
  revalidatePath('/perfil')
  return { ok: true }
}

/** Idiomas e aparências que a conta aceita — a UI não é a autoridade. */
const LANGS = new Set(['pt', 'en'])
const THEMES = new Set(['light', 'dark', 'system'])

/**
 * Preferências da conta: idioma, aparência, telefone e município.
 *
 * Ficam em `user_metadata`, como o nome e a fotografia (não há tabela
 * `profiles`). O idioma é o que a página de Eventos já lê; o telefone é o que
 * o formulário de reserva do Localizador passa a usar para pré-preencher.
 *
 * A aparência é escrita também na cookie `cf-theme` do domínio pai — é essa
 * cookie que o script anti-FOUC lê antes do primeiro paint e é ela que faz a
 * escolha atravessar www, conta e Localizador.
 */
export async function guardarPreferencias({ lang, theme, phone, municipality } = {}) {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return { ok: false, error: 'SEM_SESSAO' }

  const idioma = LANGS.has(lang) ? lang : null
  const aparencia = THEMES.has(theme) ? theme : null
  if (!idioma || !aparencia) return { ok: false, error: 'INVALIDO' }

  const telefone = String(phone || '').replace(/\D/g, '').slice(0, 15)
  if (telefone && telefone.length < 9) return { ok: false, error: 'TELEFONE' }

  const municipio = String(municipality || '').trim().slice(0, 80)

  const { error } = await supabase.auth.updateUser({
    data: {
      lang: idioma,
      preferred_lang: idioma,
      theme: aparencia,
      phone: telefone || null,
      municipality: municipio || null,
    },
  })
  if (error) return { ok: false, error: 'FALHOU' }

  const jar = await cookies()
  const h = await headers()
  const host = (h.get('host') || '').split(':')[0]
  const shared = host === 'conhecafarmacia.com' || host.endsWith('.conhecafarmacia.com')
  jar.set('cf-theme', aparencia, {
    path: '/',
    maxAge: 60 * 60 * 24 * 365,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    ...(shared ? { domain: '.conhecafarmacia.com' } : {}),
  })

  revalidatePath('/perfil')
  revalidatePath('/perfil/preferencias')
  revalidatePath('/perfil/eventos')
  return { ok: true }
}

/**
 * Pedir a alteração do e-mail da conta.
 *
 * Antes de disparar a confirmação do Supabase, faz duas coisas para que as
 * inscrições não desapareçam quando o endereço muda:
 *
 *   1. reclama as inscrições que ainda só existiam pelo e-mail atual
 *      (`user_id` a null) — passam a estar ligadas à conta;
 *   2. guarda os endereços atuais em `emails_anteriores`, porque até a
 *      confirmação chegar o e-mail da conta ainda é o antigo e a leitura
 *      cruza as duas fontes.
 *
 * A mudança em si continua a ser confirmada no novo endereço: nada muda para
 * a pessoa antes de ela clicar no link.
 */
export async function pedirAlteracaoEmail(novoEmail) {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user?.email) return { ok: false, error: 'SEM_SESSAO' }
  // Confirmado é diferente de escrito. Sem esta guarda, uma conta criada com o
  // endereço de outra pessoa reclamava as inscrições dela (e podia cancelá-las)
  // antes de o dono alguma vez ter confirmado o e-mail.
  if (!user.email_confirmed_at) return { ok: false, error: 'EMAIL_NAO_CONFIRMADO' }

  const next = String(novoEmail || '').trim().toLowerCase()
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(next)) return { ok: false, error: 'EMAIL_INVALIDO' }
  if (next === user.email.trim().toLowerCase()) return { ok: false, error: 'MESMO_EMAIL' }

  const admin = createAdminClient()
  await reclamarInscricoes(admin, user)

  const { error: metaError } = await supabase.auth.updateUser({
    data: { emails_anteriores: emailsDaConta(user) },
  })
  if (metaError) return { ok: false, error: 'FALHOU' }

  const { error } = await supabase.auth.updateUser({ email: next })
  if (error) {
    return {
      ok: false,
      error: error.message?.toLowerCase().includes('already') ? 'JA_EXISTE' : 'FALHOU',
    }
  }

  return { ok: true }
}
