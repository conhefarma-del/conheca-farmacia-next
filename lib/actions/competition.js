'use server'

import { createClient } from '@/lib/supabase/server'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { revalidatePath, revalidateTag } from 'next/cache'
import { z } from 'zod'

// ============================================================
//  Helper: requireAdmin
// ============================================================
async function requireAdmin() {
  const supabase = await createClient()
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return null
    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .maybeSingle()
    if (adminError || !adminUser) return null
    return { supabase, user, role: adminUser.role }
  } catch {
    return null
  }
}

// ============================================================
//  Schemas
// ============================================================
const schoolSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido'),
  name: z.string().min(1, 'Nome é obrigatório'),
  location: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('published'),
})

const classSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido'),
  school_id: z.string().uuid('Escola inválida'),
  name: z.string().min(1, 'Nome é obrigatório'),
  grade: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('published'),
})

const competitionSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido'),
  name: z.string().min(1, 'Nome é obrigatório'),
  access_code: z.string().min(4, 'Código deve ter pelo menos 4 caracteres').regex(/^[A-Z0-9-]+$/, 'Código deve ter apenas letras maiúsculas, números e hífens'),
  description: z.string().optional().default(''),
  question_types: z.array(z.string()).optional().default(['pharmacology', 'interaction', 'flashcard', 'protocol', 'drug_class']),
  questions_count: z.number().int().min(5).max(30).default(10),
  time_per_question: z.number().int().min(10).max(120).default(30),
  streak_bonus: z.boolean().default(true),
  school_ids: z.array(z.string().uuid()).optional().default([]),
})

// ============================================================
//  Helpers
// ============================================================
function slugify(str) {
  return (str || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

function generateAccessCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let code = 'CF-'
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return code
}

// ============================================================
//  ADMIN — Schools
// ============================================================
export async function getAllSchoolsAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('schools')
    .select('*')
    .order('name', { ascending: true })
  if (error) return []
  return data || []
}

export async function createSchool(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = schoolSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('schools').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function updateSchool(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = schoolSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase
    .from('schools')
    .update({ ...parsed.data, updated_at: new Date().toISOString() })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function archiveSchool(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('schools')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function restoreSchool(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('schools')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function deleteSchool(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('schools').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

// ============================================================
//  ADMIN — Classes
// ============================================================
export async function getAllClassesAdmin(schoolId) {
  const ctx = await requireAdmin()
  if (!ctx) return []
  let query = ctx.supabase
    .from('classes')
    .select('*, school:schools(id, name)')
    .order('name', { ascending: true })
  if (schoolId) query = query.eq('school_id', schoolId)
  const { data, error } = await query
  if (error) return []
  return data || []
}

export async function createClass(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = classSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('classes').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function updateClass(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = classSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase
    .from('classes')
    .update({ ...parsed.data, updated_at: new Date().toISOString() })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function archiveClass(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('classes')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function restoreClass(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('classes')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function deleteClass(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('classes').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

// ============================================================
//  ADMIN — Competitions
// ============================================================
export async function getAllCompetitionsAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('competitions')
    .select('*')
    .order('created_at', { ascending: false })
  if (error) return []

  // Contar participantes por competição
  const compIds = (data || []).map((c) => c.id)
  if (compIds.length === 0) return []

  const { data: sessions } = await ctx.supabase
    .from('competition_sessions')
    .select('competition_id')
    .in('competition_id', compIds)

  const counts = {}
  ;(sessions || []).forEach((s) => {
    counts[s.competition_id] = (counts[s.competition_id] || 0) + 1
  })

  return (data || []).map((c) => ({
    ...c,
    participantCount: counts[c.id] || 0,
  }))
}

export async function getCompetitionById(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null
  const { data, error } = await ctx.supabase
    .from('competitions')
    .select('*')
    .eq('id', id)
    .maybeSingle()
  if (error || !data) return null
  return data
}

export async function createCompetition(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  // Gerar slug e código se não fornecidos
  const slug = data.slug || slugify(data.name)
  const access_code = data.access_code || generateAccessCode()

  const parsed = competitionSchema.safeParse({ ...data, slug, access_code })
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }

  const { error } = await ctx.supabase.from('competitions').insert({
    ...parsed.data,
    created_by: ctx.user.id,
  })
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function updateCompetition(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = competitionSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase
    .from('competitions')
    .update({ ...parsed.data, updated_at: new Date().toISOString() })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function startCompetition(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('competitions')
    .update({
      status: 'lobby',
      started_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function activateCompetition(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('competitions')
    .update({
      status: 'active',
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function endCompetition(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('competitions')
    .update({
      status: 'ended',
      ended_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function cancelCompetition(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('competitions')
    .update({
      status: 'cancelled',
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

export async function deleteCompetition(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('competitions').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('competitions')
  return { success: true }
}

// ============================================================
//  ADMIN — Leaderboard
// ============================================================
export async function getCompetitionLeaderboardAdmin(competitionId) {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('competition_leaderboard')
    .select('*')
    .eq('competition_id', competitionId)
    .order('position', { ascending: true })
    .limit(100)
  if (error) return []
  return data || []
}

// ============================================================
//  PUBLIC — Join Competition
// ============================================================
export async function joinCompetition(accessCode, { studentName, schoolId, classId }) {
  try {
    const supabase = await createAnonClient()

    // Validar inputs
    if (!accessCode || !studentName) {
      return { success: false, error: 'Código e nome são obrigatórios' }
    }

    // Buscar competição pelo código
    const { data: comp, error: compError } = await supabase
      .from('competitions')
      .select('id, name, status, school_ids')
      .eq('access_code', accessCode.toUpperCase())
      .in('status', ['lobby', 'active'])
      .maybeSingle()

    if (compError || !comp) {
      return { success: false, error: 'Competição não encontrada ou inativa' }
    }

    // Verificar se a escola está convidada (se school_ids não estiver vazio)
    if (comp.school_ids && comp.school_ids.length > 0 && schoolId) {
      if (!comp.school_ids.includes(schoolId)) {
        return { success: false, error: 'A tua escola não está convidada para esta competição' }
      }
    }

    // Gerar session_id único
    const sessionId = `cs_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`

    // Criar sessão
    const { data: session, error: sessionError } = await supabase
      .from('competition_sessions')
      .insert({
        competition_id: comp.id,
        session_id: sessionId,
        student_name: studentName.trim(),
        school_id: schoolId || null,
        class_id: classId || null,
      })
      .select('id, session_id')
      .maybeSingle()

    if (sessionError) {
      // Pode ser duplicate (mesmo aluno na mesma competição)
      if (sessionError.code === '23505') {
        return { success: false, error: 'Já participaste nesta competição' }
      }
      return { success: false, error: 'Erro ao criar sessão' }
    }

    return {
      success: true,
      sessionId: session.session_id,
      competitionId: comp.id,
      competitionName: comp.name,
      status: comp.status,
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  PUBLIC — Get Competition Info (for lobby/quiz)
// ============================================================
export async function getCompetitionByCode(accessCode) {
  try {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('competitions')
      .select('id, name, status, questions_count, time_per_question, question_types, streak_bonus, started_at')
      .eq('access_code', accessCode.toUpperCase())
      .maybeSingle()

    if (error || !data) return null
    return data
  } catch {
    return null
  }
}

// ============================================================
//  PUBLIC — Get Session (for quiz state)
// ============================================================
export async function getCompetitionSession(sessionId) {
  try {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('competition_sessions')
      .select('id, session_id, competition_id, student_name, total_score, correct_count, total_answered, current_streak, max_streak, answers, finished_at')
      .eq('session_id', sessionId)
      .maybeSingle()

    if (error || !data) return null
    return data
  } catch {
    return null
  }
}

// ============================================================
//  PUBLIC — Submit Answer
// ============================================================
export async function submitAnswer(sessionId, { questionIndex, correct, points, timeMs }) {
  try {
    const supabase = await createAnonClient()

    // Buscar sessão atual
    const { data: session, error: fetchError } = await supabase
      .from('competition_sessions')
      .select('id, total_score, correct_count, total_answered, current_streak, max_streak, answers')
      .eq('session_id', sessionId)
      .maybeSingle()

    if (fetchError || !session) {
      return { success: false, error: 'Sessão não encontrada' }
    }

    if (session.finished_at) {
      return { success: false, error: 'Competição já terminou' }
    }

    // Calcular streak
    let newStreak = session.current_streak
    let newMaxStreak = session.max_streak
    if (correct) {
      newStreak += 1
      if (newStreak > newMaxStreak) newMaxStreak = newStreak
    } else {
      newStreak = 0
    }

    // Calcular pontos com streak bonus
    let finalPoints = points || 0
    if (correct && newStreak >= 3) {
      // Streak bonus: 3+ = +50, 5+ = +100, 8+ = +200, 12+ = +500
      if (newStreak >= 12) finalPoints += 500
      else if (newStreak >= 8) finalPoints += 200
      else if (newStreak >= 5) finalPoints += 100
      else finalPoints += 50
    }

    // Atualizar answers
    const currentAnswers = Array.isArray(session.answers) ? session.answers : []
    const newAnswers = [...currentAnswers, {
      qIdx: questionIndex,
      correct,
      points: finalPoints,
      streak_at: newStreak,
      time_ms: timeMs || 0,
    }]

    // Atualizar sessão
    const { error: updateError } = await supabase
      .from('competition_sessions')
      .update({
        total_score: session.total_score + finalPoints,
        correct_count: session.correct_count + (correct ? 1 : 0),
        total_answered: session.total_answered + 1,
        current_streak: newStreak,
        max_streak: newMaxStreak,
        answers: newAnswers,
        updated_at: new Date().toISOString(),
      })
      .eq('id', session.id)

    if (updateError) return { success: false, error: 'Erro ao guardar resposta' }

    return {
      success: true,
      correct,
      points: finalPoints,
      streak: newStreak,
      totalScore: session.total_score + finalPoints,
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  PUBLIC — Finish Competition
// ============================================================
export async function finishCompetition(sessionId) {
  try {
    const supabase = await createAnonClient()
    const { error } = await supabase
      .from('competition_sessions')
      .update({
        finished_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('session_id', sessionId)
      .is('finished_at', null)

    if (error) return { success: false, error: 'Erro ao finalizar' }
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  PUBLIC — Leaderboard (polling)
// ============================================================
export async function getCompetitionLeaderboard(competitionId, limit = 50) {
  try {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('competition_leaderboard')
      .select('id, student_name, total_score, correct_count, total_answered, max_streak, school_name, class_name, position')
      .eq('competition_id', competitionId)
      .order('position', { ascending: true })
      .limit(limit)

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

// ============================================================
//  PUBLIC — Polling (otimizado)
// ============================================================
export async function pollLeaderboard(competitionId, lastUpdate) {
  try {
    const supabase = await createAnonClient()

    // Se lastUpdate fornecido, só buscar sessões atualizadas depois disso
    let query = supabase
      .from('competition_sessions')
      .select('id, student_name, total_score, correct_count, total_answered, max_streak, school_id, class_id, updated_at')
      .eq('competition_id', competitionId)
      .gt('total_answered', 0)

    if (lastUpdate) {
      query = query.gt('updated_at', lastUpdate)
    }

    const { data: changed, error } = await query
    if (error) return { unchanged: true }

    // Se nada mudou, devolver unchanged
    if (!changed || changed.length === 0) {
      return { unchanged: true }
    }

    // Buscar leaderboard completo (top 50)
    const leaderboard = await getCompetitionLeaderboard(competitionId, 50)

    return {
      unchanged: false,
      leaderboard,
      lastUpdate: new Date().toISOString(),
    }
  } catch {
    return { unchanged: true }
  }
}

// ============================================================
//  PUBLIC — Get participant count
// ============================================================
export async function getCompetitionParticipantCount(competitionId) {
  try {
    const supabase = await createAnonClient()
    const { count, error } = await supabase
      .from('competition_sessions')
      .select('*', { count: 'exact', head: true })
      .eq('competition_id', competitionId)

    if (error) return 0
    return count || 0
  } catch {
    return 0
  }
}

// ============================================================
//  ACCOUNT — Claim Session to Account
// ============================================================
export async function claimSessionToAccount(sessionId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    // Atualizar sessão com user_id
    const { error: updateError } = await supabase
      .from('competition_sessions')
      .update({ user_id: user.id, updated_at: new Date().toISOString() })
      .eq('session_id', sessionId)
      .is('user_id', null)

    if (updateError) return { success: false, error: 'Erro ao ligar sessão' }

    // Enviar email de boas-vindas via Edge Function
    const nome = user.raw_user_meta_data?.full_name || user.email?.split('@')[0] || 'Utilizador'
    try {
      const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
      const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
      await fetch(`${supabaseUrl}/functions/v1/send-newsletter-email`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${supabaseAnonKey}`,
          'x-client-info': 'next.js',
        },
        body: JSON.stringify({
          type: 'welcome-account',
          email: user.email,
          nome,
        }),
      })
    } catch {
      // Email é best-effort — não falhar o claim por causa disso
      console.error('[competition] Failed to send welcome email')
    }

    return { success: true }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}
