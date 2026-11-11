'use server'

import { getAdminSession } from '@/lib/admin-guard'

import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { redirect } from 'next/navigation'
import { headers } from 'next/headers'
import { z } from 'zod'

// SEC-ATH-04: Zod schemas para validação de input
const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(1, 'Password é obrigatória'),
})

const mfaSchema = z.object({
  factorId: z.string().uuid('factorId inválido'),
  code: z.string().regex(/^\d{6}$/, 'Código deve ter 6 dígitos'),
})

const gateAnswersSchema = z.array(
  z.object({
    question_id: z.number(),
    answer: z.string().min(1, 'Resposta é obrigatória'),
  })
).min(2, 'São necessárias 2 respostas')

/**
 * SEC-ATH-05: djb2 hash truncado para rate limiting — não criptográfico,
 * apenas para evitar expor emails raw na tabela auth_attempts.
 */
function hashEmail(email) {
  let hash = 5381
  for (let i = 0; i < email.length; i++) {
    hash = ((hash << 5) + hash + email.charCodeAt(i)) >>> 0
  }
  return hash.toString(16).slice(0, 8)
}

/**
 * SEC-ATH-05: Rate limiting — tenta de login, gate, inscricao.
 * Retorna true se estiver rate limited.
 */
async function isRateLimited(p_email_hash, p_attempt_type = 'login', p_max_attempts = 5, p_window_seconds = 300) {
  try {
    // service-role: a 293 revogou estas RPCs ao anon/authenticated. Uma
    // tentativa de login chega sem sessão, portanto até aqui o papel era
    // `anon` — com a revogação, o cliente de sessão deixaria o limite a
    // falhar aberto.
    const supabase = createAdminClient()
    const headersList = await headers()
    const ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || null

    const { data, error } = await supabase.rpc('check_rate_limit', {
      p_ip: ip,
      p_email_hash,
      p_attempt_type,
      p_max_attempts,
      p_window_seconds,
    })

    if (error) throw error
    return data === true
  } catch {
    return false // falha aberta — não bloquear por erro de RPC
  }
}

/**
 * SEC-ATH-05: Log tenta de autenticação.
 */
async function logAuthAttempt(p_email_hash, p_attempt_type, p_success, p_user_id = null) {
  try {
    // service-role, como isRateLimited: a auditoria de tentativas não pode
    // depender do papel de quem tenta entrar.
    const supabase = createAdminClient()
    const headersList = await headers()
    const ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || null

    await supabase.rpc('log_auth_attempt', {
      p_ip: ip,
      p_email_hash,
      p_attempt_type,
      p_success,
      p_user_id,
    })
  } catch {
    // falha silenciosa — não quebrar o fluxo principal
  }
}
// SEC-ATH-02: verificação única em `@/lib/admin-guard` (sessão + role).
const requireAdmin = getAdminSession

/**
 * Login do administrador (email + password).
 * Verifica sessão + admin_users (SEC-ATH-02).
 * Retorna se precisa de MFA.
 */
export async function adminLogin(email, password) {
  try {
    // SEC-ATH-04: Validação de schema Zod
    const parseResult = loginSchema.safeParse({ email, password })
    if (!parseResult.success) {
      return {
        success: false,
        error: 'Dados inválidos.',
        details: parseResult.error.flatten(),
      }
    }

    const supabase = await createClient()

    if (!email || !password) {
      return { success: false, error: 'Email e password são obrigatórios.' }
    }

    // SEC-ATH-05: Rate limiting — 5 tentativas por 5 minutos
    const emailHash = hashEmail(email.toLowerCase().trim())
    const rateLimited = await isRateLimited(emailHash, 'login', 5, 300)
    if (rateLimited) {
      await logAuthAttempt(emailHash, 'login', false, null)
      return {
        success: false,
        error: 'Muitas tentativas falhadas. Tenta novamente em 5 minutos.',
        rateLimited: true,
      }
    }

    // 1. Autenticar com Supabase
    const { data, error: signInError } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (signInError) {
      await logAuthAttempt(emailHash, 'login', false, null)
      return { success: false, error: 'Email ou password incorretos.' }
    }

    if (!data.user) {
      await logAuthAttempt(emailHash, 'login', false, null)
      return { success: false, error: 'Erro ao autenticar.' }
    }

    // 2. SEC-ATH-02: Verificar se é admin
    // Só os níveis de administração entram: uma conta `farmacia` mora na
    // mesma tabela e não é admin do site.
    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', data.user.id)
      .in('role', ['admin', 'superadmin'])
      .single()

    if (adminError || !adminUser) {
      await supabase.auth.signOut()
      await logAuthAttempt(emailHash, 'login', false, data.user.id)
      return { success: false, error: 'Acesso não autorizado.' }
    }

    // 3. NEW-01: MFA é OBRIGATÓRIO para admins. Política: enforced no
    // primeiro login — o admin tem de ter um factor TOTP verificado para
    // receber { success: true }. O try/catch anterior engole erros do
    // Supabase MFA e deixa o utilizador entrar sem 2FA; agora qualquer
    // falha aborta o login com mensagem explícita.
    let aal
    try {
      const { data: mfaData, error: mfaError } =
        await supabase.auth.mfa.getAuthenticatorAssuranceLevel()
      if (mfaError) throw mfaError
      aal = mfaData
    } catch (mfaErr) {
      await supabase.auth.signOut()
      await logAuthAttempt(emailHash, 'login', false, data.user.id)
      return {
        success: false,
        error: 'Não foi possível verificar a autenticação de dois fatores. Tenta novamente.',
      }
    }

    const isAal2 = aal?.currentLevel === 'aal2'

    if (!isAal2) {
      // Listar fatores TOTP disponíveis — se houver um verificado,
      // devolvemos o factorId para o cliente iniciar o challenge.
      let totpFactor
      try {
        const { data: factorsData, error: listError } =
          await supabase.auth.mfa.listFactors()
        if (listError) throw listError
        totpFactor = factorsData?.totp?.find((f) => f.status === 'verified')
      } catch {
        totpFactor = null
      }

      if (totpFactor) {
        await logAuthAttempt(emailHash, 'login', true, data.user.id)
        return { success: true, needsMFA: true, factorId: totpFactor.id }
      }

      // Sem factor TOTP verificado: bloquear. O utilizador tem de ir
      // a /admin/definicoes configurar 2FA antes de conseguir login.
      await supabase.auth.signOut()
      await logAuthAttempt(emailHash, 'login', false, data.user.id)
      return {
        success: false,
        error: 'Autenticação de dois fatores obrigatória. Configura o TOTP nas definições antes de iniciar sessão.',
        requiresTwoFactorEnrollment: true,
      }
    }

    // 4. Login completo, MFA verificado
    await logAuthAttempt(emailHash, 'login', true, data.user.id)
    return { success: true, needsMFA: false }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Verificação de código TOTP para 2FA.
 * SEC-ATH-02: Verifica sessão antes de verificar MFA.
 */
export async function verifyMFA(factorId, code) {
  try {
    // SEC-ATH-04: Validação de schema Zod
    const parseResult = mfaSchema.safeParse({ factorId, code })
    if (!parseResult.success) {
      return {
        success: false,
        error: 'Dados inválidos.',
        details: parseResult.error.flatten(),
      }
    }

    const supabase = await createClient()

    // Verificar sessão ativa
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    if (!factorId || !code) {
      return { success: false, error: 'Código 2FA é obrigatório.' }
    }

    if (code.length !== 6 || !/^\d{6}$/.test(code)) {
      return { success: false, error: 'Código deve ter 6 dígitos.' }
    }

    // Criar challenge
    const { data: challengeData, error: challengeError } =
      await supabase.auth.mfa.challenge({ factorId })

    if (challengeError) {
      return { success: false, error: 'Erro ao criar challenge 2FA.' }
    }

    // Verificar código
    const { error: verifyError } = await supabase.auth.mfa.verify({
      factorId,
      challengeId: challengeData.id,
      code,
    })

    if (verifyError) {
      return { success: false, error: 'Código inválido ou expirado.' }
    }

    // SEC-ATH-02: Confirmar que continua sendo admin após MFA
    const { data: adminUser } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .in('role', ['admin', 'superadmin'])
      .single()

    if (!adminUser) {
      await supabase.auth.signOut()
      return { success: false, error: 'Acesso não autorizado.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Verificação das perguntas de segurança (Gate).
 * Usa RPC para buscar perguntas e verificar respostas (SHA256).
 * Verifica se as perguntas estão ativadas antes de retornar.
 */
export async function getGateQuestions() {
  try {
    const supabase = await createClient()

    // Verificar se as perguntas estão ativadas
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      const { data: adminUser } = await supabase
        .from('admin_users')
        .select('gate_questions_enabled')
        .eq('user_id', user.id)
        .single()

      // Se explicitamente desativadas, saltar gate
      if (adminUser && adminUser.gate_questions_enabled === false) {
        return { success: false, error: 'Perguntas desativadas.' }
      }
    }

    const { data, error } = await supabase.rpc('get_access_questions')

    if (error || !data || data.length === 0) {
      return {
        success: false,
        error: 'Erro ao carregar perguntas de segurança.',
      }
    }

    // RPC retorna TABLE(question_1 text, question_2 text)
    const row = data[0]
    if (!row.question_1 || !row.question_2) {
      return { success: false, error: 'Perguntas não configuradas.' }
    }

    return {
      success: true,
      questions: [
        { id: 1, question: row.question_1 },
        { id: 2, question: row.question_2 },
      ],
    }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Verificar respostas do Gate — SEC-ATH-05 com lockout.
 * O RPC verify_access_answers já faz hash SHA256 internamente.
 * Aceita answer_1 e answer_2 como texto raw (o RPC faz lower + trim + sha256).
 *
 * Gate lockout: 3 falhas → bloqueio de 5 minutos.
 */
export async function verifyGateAnswers(answers) {
  try {
    const supabase = await createClient()

    // Obter user_id se já autenticado (necessário para lockout por user)
    const { data: { user } } = await supabase.auth.getUser()
    const userId = user?.id || null

    // SEC-ATH-04: Validação de schema Zod
    const parseResult = gateAnswersSchema.safeParse(answers)
    if (!parseResult.success) {
      return {
        success: false,
        error: 'Respostas inválidas.',
        details: parseResult.error.flatten(),
      }
    }

    // SEC-ATH-05: Verificar gate lockout (3 falhas = 5min bloqueio)
      // SEC-ATH-05: Rate-limit / lockout
      // If unauthenticated, apply IP-based gate rate limiting (3 fails / 5min).
      const ipRateLimited = await isRateLimited(null, 'gate', 2, 300)
      if (ipRateLimited) {
        await logAuthAttempt(null, 'gate', false, userId)
        return {
          success: false,
          error: 'Muitas tentativas falhadas. Tenta novamente em 5 minutos.',
          rateLimited: true,
        }
      }

      // If authenticated, also check per-user lockout window using RPC
      if (userId) {
        // service-role: a 293 revogou esta RPC ao browser.
        const { data: lockoutData } = await createAdminClient().rpc('check_gate_lockout', {
          p_user_id: userId,
          p_max_fails: 2,
          p_lockout_secs: 300,
        })

        if (lockoutData?.locked) {
          const lockoutUntil = new Date(lockoutData.locked_until)
          const now = new Date()
          const minutesLeft = Math.ceil((lockoutUntil - now) / 60000)
          return {
            success: false,
            error: `Muitas tentativas falhadas. Tenta novamente em ${minutesLeft} minutos.`,
            locked: true,
            lockoutUntil: lockoutData.locked_until,
          }
        }
      }

    if (!answers || !Array.isArray(answers) || answers.length < 2) {
      return { success: false, error: 'Respostas são obrigatórias.' }
    }

    // Map answers by question id for robustness (accepts {id} or {question_id})
    const mapped = {}
    answers.forEach((a) => {
      const id = a.id || a.question_id || a.questionId || null
      if (id) mapped[id] = (a.answer || '').trim()
    })

    const answer1 = mapped[1] || ''
    const answer2 = mapped[2] || ''

    if (!answer1 || !answer2) {
      return { success: false, error: 'Respostas são obrigatórias.' }
    }

    const { data, error } = await supabase.rpc('verify_access_answers', {
      answer_1: answer1,
      answer_2: answer2,
    })

    if (error) {
      // Log falha
      await logAuthAttempt(null, 'gate', false, userId)
      return { success: false, error: 'Erro ao verificar respostas.' }
    }

    if (!data) {
      // Respostas incorretas — log falha
      await logAuthAttempt(null, 'gate', false, userId)
      return { success: false, error: 'Respostas incorretas.' }
    }

    // Sucesso — log sucesso
    await logAuthAttempt(null, 'gate', true, userId)
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Logout do administrador.
 * SEC-ATH-02: Verifica sessão antes de terminar.
 */
export async function adminLogout(lang = 'pt') {
  const supabase = await createClient()
  await supabase.auth.signOut()
  redirect(`/${lang}/admin`)
}

/**
 * PEDIDO DE REPOSIÇÃO DE SENHA DA CONTA DO SITE.
 *
 * Um projecto Supabase, três áreas. O e-mail de quem trabalha na farmácia ou
 * na plataforma existe em `auth.users` como qualquer utente, e
 * `resetPasswordForEmail` só olha para aí: mandava o link a essas contas, e
 * uma senha reposta no site passava a valer no localizador. Quem é de outra
 * área repõe onde entra — a reposição do localizador é que é dona dessas
 * contas (e é ela que exige o TOTP, quando existe).
 *
 * `localizador.admin_users` é a lista de pertença das outras áreas (farmácia
 * e plataforma). Quem lá está não recebe nada daqui.
 *
 * A resposta é `{ success: true }` mesmo quando não se envia nada: este
 * formulário nunca revelou se um e-mail tem conta, e continuar a não revelar
 * é o que impede usá-lo para descobrir quem trabalha na plataforma.
 */
export async function pedirReposicaoSenha(rawEmail) {
  const parsed = z.string().email().safeParse(String(rawEmail ?? '').trim().toLowerCase())
  if (!parsed.success) return { success: false, error: 'Email inválido.' }

  const email = parsed.data
  const emailHash = hashEmail(email)

  // 4 pedidos por hora e por e-mail (o projecto inteiro tem 30/h no Auth).
  if (await isRateLimited(emailHash, 'recovery', 4, 3600)) {
    return {
      success: false,
      error: 'Pediste vários e-mails seguidos. Tenta novamente daqui a uma hora.',
    }
  }

  const admin = createAdminClient()

  // `undefined` = a leitura falhou. Nesse caso segue-se em frente: o Supabase
  // só entrega o link a quem tem conta, e recusar por erro de rede deixaria
  // uma pessoa legítima sem reposição.
  const userId = await idDoEmail(admin, email)
  if (userId) {
    const { data: outraArea } = await admin
      .schema('localizador')
      .from('admin_users')
      .select('user_id')
      .eq('user_id', userId)
      .maybeSingle()

    if (outraArea) {
      await logAuthAttempt(emailHash, 'recovery', false, userId)
      return { success: true }
    }
  }

  // O pedido é feito no servidor para o código PKCE ficar nas cookies do
  // domínio pai (`lib/cookie-domain.js`): o link abre em conta.* e o
  // `/auth/reset` que o troca por sessão está no mesmo domínio.
  const h = await headers()
  const host = h.get('x-forwarded-host') || h.get('host') || ''
  const proto = h.get('x-forwarded-proto') || 'https'

  const supabase = await createClient()
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${proto}://${host}/auth/reset`,
  })

  if (error) {
    if (/rate limit|too many|once every/i.test(`${error.code || ''} ${error.message || ''}`)) {
      return {
        success: false,
        error: 'Já enviámos um e-mail há pouco. Espera um minuto e tenta outra vez.',
      }
    }
    return {
      success: false,
      error: 'Não foi possível enviar o e-mail agora. Tenta novamente.',
    }
  }

  await logAuthAttempt(emailHash, 'recovery', true, userId || null)
  return { success: true }
}

/**
 * `userId` de um e-mail, pelo admin API do Auth — o projecto não tem tabela de
 * perfis, a identidade vive em `auth.users`.
 *
 * Devolve `null` quando não há conta e `undefined` quando a leitura falhou.
 */
async function idDoEmail(admin, email) {
  try {
    for (let pagina = 1; pagina <= 5; pagina += 1) {
      const { data, error } = await admin.auth.admin.listUsers({ page: pagina, perPage: 1000 })
      if (error) throw error
      const encontrado = (data?.users || []).find(
        (u) => String(u.email || '').toLowerCase() === email,
      )
      if (encontrado) return encontrado.id
      if (!data?.nextPage || data.nextPage <= pagina) return null
    }
    return null
  } catch {
    return undefined
  }
}
