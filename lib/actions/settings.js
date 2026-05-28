'use server'

import { createClient } from '@/lib/supabase/server'

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
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
 * Buscar perfil do administrador atual.
 */
export async function getAdminProfile() {
  const ctx = await requireAdmin()
  if (!ctx) return null

  const { supabase, user } = ctx

  const { data: adminUser } = await supabase
    .from('admin_users')
    .select('name, email, recovery_email, gate_questions_enabled')
    .eq('user_id', user.id)
    .single()

  if (!adminUser) return null

  return {
    name: adminUser.name || '',
    email: adminUser.email || user.email || '',
    recovery_email: adminUser.recovery_email || '',
    gate_questions_enabled: adminUser.gate_questions_enabled !== false,
  }
}

/**
 * Atualizar perfil do administrador (nome, email de recuperação).
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function updateProfile(name, recoveryEmail) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    if (!name || name.trim().length < 2) {
      return { success: false, error: 'Nome deve ter pelo menos 2 caracteres.' }
    }

    const { error } = await supabase
      .from('admin_users')
      .update({
        name: name.trim(),
        recovery_email: recoveryEmail?.trim() || null,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', user.id)

    if (error) {
      return { success: false, error: 'Erro ao atualizar perfil.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Alterar password do administrador.
 * SEC-ATH-02: Verifica sessão antes de alterar.
 */
export async function changePassword(currentPassword, newPassword) {
  try {
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    if (!currentPassword || !newPassword) {
      return { success: false, error: 'Password atual e nova são obrigatórias.' }
    }

    if (newPassword.length < 8) {
      return { success: false, error: 'Nova password deve ter pelo menos 8 caracteres.' }
    }

    // Verificar password atual re-autenticando
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: user.email,
      password: currentPassword,
    })

    if (signInError) {
      return { success: false, error: 'Password atual incorreta.' }
    }

    // Alterar password
    const { error: updateError } = await supabase.auth.updateUser({
      password: newPassword,
    })

    if (updateError) {
      return { success: false, error: 'Erro ao alterar password.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Iniciar setup de 2FA — retorna QR code e factorId.
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function enrollMFA() {
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase } = ctx

    const { data, error } = await supabase.auth.mfa.enroll({
      factorType: 'totp',
    })

    if (error) {
      return { success: false, error: error.message }
    }

    return {
      success: true,
      factorId: data.id,
      qrCode: data.totp.qr_code,
      secret: data.totp.secret,
    }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Confirmar enrollment de 2FA com código TOTP.
 * SEC-ATH-02: Verifica sessão.
 */
export async function verifyMFAEnrollment(factorId, code) {
  try {
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    if (!factorId || !code) {
      return { success: false, error: 'FactorId e código são obrigatórios.' }
    }

    // Criar challenge
    const { data: challengeData, error: challengeError } =
      await supabase.auth.mfa.challenge({ factorId })

    if (challengeError) {
      return { success: false, error: 'Erro ao criar challenge.' }
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

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Desativar 2FA.
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function unenrollMFA(factorId) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase } = ctx

    if (!factorId) {
      return { success: false, error: 'FactorId é obrigatório.' }
    }

    const { error } = await supabase.auth.mfa.unenroll({ factorId })

    if (error) {
      return { success: false, error: 'Erro ao desativar 2FA.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Listar fatores TOTP do utilizador atual.
 */
export async function listMFAFactors() {
  try {
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) return { success: false, factors: [] }

    const { data, error } = await supabase.auth.mfa.listFactors()

    if (error) return { success: false, factors: [] }

    return {
      success: true,
      factors: data?.totp || [],
    }
  } catch {
    return { success: false, factors: [] }
  }
}

/**
 * Buscar perguntas de segurança (Gate) para edição.
 */
export async function getGateQuestionsForEdit() {
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada.' }
    }

    const { supabase } = ctx

    const { data, error } = await supabase.rpc('get_access_questions')

    if (error) {
      return { success: false, error: 'Erro ao carregar perguntas.' }
    }

    // RPC retorna TABLE(question_1 text, question_2 text)
    const row = data?.[0]
    const questions = []
    if (row?.question_1) questions.push({ id: 1, question: row.question_1 })
    if (row?.question_2) questions.push({ id: 2, question: row.question_2 })

    return {
      success: true,
      questions,
    }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Obter estado das perguntas de segurança (ativadas/desativadas).
 */
export async function getGateQuestionsEnabled() {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, enabled: true }

    const { supabase, user } = ctx

    const { data } = await supabase
      .from('admin_users')
      .select('gate_questions_enabled')
      .eq('user_id', user.id)
      .single()

    return { success: true, enabled: data?.gate_questions_enabled !== false }
  } catch {
    return { success: false, enabled: true }
  }
}

/**
 * Ativar/desativar perguntas de segurança.
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function toggleGateQuestions(enabled) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada.' }

    const { supabase, user } = ctx

    const { error } = await supabase
      .from('admin_users')
      .update({ gate_questions_enabled: enabled })
      .eq('user_id', user.id)

    if (error) return { success: false, error: 'Erro ao atualizar.' }

    return { success: true, enabled }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}

/**
 * Guardar perguntas de segurança (Gate).
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function saveGateQuestions(q1, a1, q2, a2) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase } = ctx

    if (!q1?.trim() || !a1?.trim() || !q2?.trim() || !a2?.trim()) {
      return { success: false, error: 'Todas as perguntas e respostas são obrigatórias.' }
    }

    // O RPC save_access_questions já faz hash SHA256 internamente
    // Parâmetros: q1 text, a1 text, q2 text, a2 text
    const { data, error } = await supabase.rpc('save_access_questions', {
      q1: q1.trim(),
      a1: a1.trim(),
      q2: q2.trim(),
      a2: a2.trim(),
    })

    if (error) {
      return { success: false, error: 'Erro ao guardar perguntas.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}
