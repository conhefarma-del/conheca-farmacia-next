'use server'

import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

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
    const supabase = await createClient()

    if (!email || !password) {
      return { success: false, error: 'Email e password são obrigatórios.' }
    }

    // 1. Autenticar com Supabase
    const { data, error: signInError } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (signInError) {
      return { success: false, error: 'Email ou password incorretos.' }
    }

    if (!data.user) {
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
      return { success: false, error: 'Acesso não autorizado.' }
    }

    // 3. Verificar se precisa de MFA (TOTP 2FA)
    try {
      const { data: mfaData, error: mfaError } =
        await supabase.auth.mfa.getAuthenticatorAssuranceLevel()

      if (!mfaError && mfaData) {
        const needsMFA =
          mfaData.nextLevel === 'aal2' && mfaData.currentLevel !== 'aal2'

        if (needsMFA) {
          // Listar fatores TOTP disponíveis
          const { data: factorsData } = await supabase.auth.mfa.listFactors()
          const totpFactor = factorsData?.totp?.find(
            (f) => f.status === 'verified'
          )

          if (totpFactor) {
            return {
              success: true,
              needsMFA: true,
              factorId: totpFactor.id,
            }
          }
        }
      }
    } catch {
      // MFA não configurado — continuar sem MFA
    }

    // 4. Login completo, sem MFA necessário
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
 */
export async function getGateQuestions() {
  try {
    const supabase = await createClient()

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
 * Verificar respostas do Gate.
 * O RPC verify_access_answers já faz hash SHA256 internamente.
 * Aceita answer_1 e answer_2 como texto raw (o RPC faz lower + trim + sha256).
 */
export async function verifyGateAnswers(answers) {
  try {
    const supabase = await createClient()

    if (!answers || !Array.isArray(answers) || answers.length < 2) {
      return { success: false, error: 'Respostas são obrigatórias.' }
    }

    // O RPC espera answer_1 e answer_2 como texto raw
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
      return { success: false, error: 'Erro ao verificar respostas.' }
    }

    if (!data) {
      return { success: false, error: 'Respostas incorretas.' }
    }

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
