'use server'

import { createClient } from '@/lib/supabase/server'
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
    id: z.number(),
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
    const supabase = await createClient()
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
    const supabase = await createClient()
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

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
 * Retorna o user se autenticado e admin, caso contrário null.
 */
async function requireAdmin() {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()

  if (authError || !user) return null

  const { data: adminUser, error: adminError } = await supabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', user.id)
    .single()

  if (adminError || !adminUser) return null

  return { supabase, user }
}

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
    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id')
      .eq('user_id', data.user.id)
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
      .select('user_id')
      .eq('user_id', user.id)
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
    if (userId) {
      const { data: lockoutData } = await supabase.rpc('check_gate_lockout', {
        p_user_id: userId,
        p_max_fails: 3,
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

    const answer1 = answers[0]?.answer?.trim() || ''
    const answer2 = answers[1]?.answer?.trim() || ''

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
