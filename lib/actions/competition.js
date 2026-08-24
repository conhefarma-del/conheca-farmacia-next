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
      .select('id, name, status, questions_count, time_per_question, question_types, streak_bonus, started_at, is_friend_challenge, created_by_user_id, max_players, access_code')
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
    // Use authenticated client for friend challenges (RLS requires auth)
    const supabase = await createClient()
    const { data, error } = await supabase
      .from('competition_sessions')
      .select('id, session_id, competition_id, student_name, total_score, correct_count, total_answered, current_streak, max_streak, answers, finished_at, questions')
      .eq('session_id', sessionId)
      .maybeSingle()

    if (error || !data) {
      // Fallback to anon client for regular competitions
      const anonSupabase = await createAnonClient()
      const { data: anonData } = await anonSupabase
        .from('competition_sessions')
        .select('id, session_id, competition_id, student_name, total_score, correct_count, total_answered, current_streak, max_streak, answers, finished_at, questions')
        .eq('session_id', sessionId)
        .maybeSingle()
      return anonData || null
    }
    return data
  } catch {
    return null
  }
}

// ============================================================
//  PUBLIC — Start Competition Quiz (generate + store questions)
// ============================================================
export async function startCompetitionQuiz(sessionId, accessCode) {
  try {
    const { buildSession } = await import('@/lib/quiz/engine')
    const { getQuizPools } = await import('@/lib/api/quiz')

    const supabase = await createAnonClient()

    // Get competition info
    const { data: comp, error: compError } = await supabase
      .from('competitions')
      .select('id, name, status, questions_count, time_per_question, question_types, streak_bonus')
      .eq('access_code', accessCode.toUpperCase())
      .eq('status', 'active')
      .maybeSingle()

    if (compError || !comp) {
      return { ok: false, error: 'Competição não encontrada ou inativa' }
    }

    // Get session
    const { data: session } = await supabase
      .from('competition_sessions')
      .select('id, session_id, finished_at')
      .eq('session_id', sessionId)
      .maybeSingle()

    if (!session) return { ok: false, error: 'Sessão não encontrada' }
    if (session.finished_at) return { ok: false, error: 'Competição já terminou' }

    // Generate questions
    const pools = await getQuizPools()
    const questions = buildSession({
      mode: 'rapido',
      level: 'medio',
      source: 'mixed',
      count: comp.questions_count || 10,
      pools,
    })

    // Store questions WITH correctIndex for server validation
    const { error: updateError } = await supabase
      .from('competition_sessions')
      .update({
        questions: JSON.parse(JSON.stringify(questions)),
        updated_at: new Date().toISOString(),
      })
      .eq('id', session.id)

    if (updateError) return { ok: false, error: 'Erro ao guardar perguntas' }

    // Return questions WITHOUT correctIndex
    return {
      ok: true,
      competitionId: comp.id,
      competitionName: comp.name,
      timePerQuestion: comp.time_per_question || 30,
      streakBonus: comp.streak_bonus !== false,
      questions: questions.map(({ correctIndex, ...q }) => q),
    }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao iniciar quiz' }
  }
}

// ============================================================
//  PUBLIC — Validate Competition Answer (server-side)
// ============================================================
export async function validateCompetitionAnswer(sessionId, { key, selected, questionIndex, timeMs }) {
  try {
    const { sameAnswer } = await import('@/lib/quiz/engine')
    const supabase = await createAnonClient()

    // Fetch session with stored questions
    const { data: session } = await supabase
      .from('competition_sessions')
      .select('id, questions, current_streak, max_streak, total_score')
      .eq('session_id', sessionId)
      .maybeSingle()

    if (!session) return { ok: false, error: 'Sessão não encontrada' }

    const questions = Array.isArray(session.questions) ? session.questions : []
    const q = questions[questionIndex]
    if (!q) return { ok: false, error: 'Pergunta não encontrada' }

    const correct = sameAnswer(selected, q.options[q.correctIndex])
    return {
      ok: true,
      correct,
      correctAnswer: q.options[q.correctIndex],
      explanation: q.explanation || '',
      source: q.source || '',
    }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao validar' }
  }
}

// ============================================================
//  PUBLIC — Submit Answer
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

// ============================================================
//  FRIEND CHALLENGE — Create
// ============================================================
export async function createFriendChallenge({
  name,
  questionsCount = 10,
  timePerQuestion = 30,
  questionTypes = ['pharmacology', 'interaction', 'drug_class'],
  streakBonus = true,
  maxPlayers = 4,
  lobbyTimeout = 120,
}) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Precisas de ter conta para criar um desafio' }
    }

    if (!name || name.trim().length < 2) {
      return { success: false, error: 'Nome do desafio é obrigatório' }
    }
    if (maxPlayers < 2 || maxPlayers > 4) {
      return { success: false, error: 'Máximo de 2 a 4 jogadores' }
    }

    const slug = slugify(name) + '-' + Date.now().toString(36)
    const accessCode = generateAccessCode()

    const { data: comp, error: compError } = await supabase
      .from('competitions')
      .insert({
        slug,
        name: name.trim(),
        access_code: accessCode,
        description: '',
        question_types: questionTypes,
        questions_count: questionsCount,
        time_per_question: timePerQuestion,
        streak_bonus: streakBonus,
        school_ids: [],
        status: 'lobby',
        is_friend_challenge: true,
        created_by_user_id: user.id,
        max_players: maxPlayers,
        lobby_timeout_seconds: lobbyTimeout,
        created_by: user.id,
      })
      .select('id, slug, name, access_code, max_players, status')
      .maybeSingle()

    if (compError || !comp) {
      return { success: false, error: 'Erro ao criar desafio: ' + (compError?.message || '') }
    }

    // Criador entra automaticamente
    const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Jogador'
    const sessionId = `fc_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`

    const { error: sessionError } = await supabase
      .from('competition_sessions')
      .insert({
        competition_id: comp.id,
        session_id: sessionId,
        user_id: user.id,
        student_name: displayName.trim(),
        is_ready: false,
      })

    if (sessionError) {
      console.error('[friend-challenge] Failed to create creator session:', sessionError)
    }

    return {
      success: true,
      competitionId: comp.id,
      slug: comp.slug,
      name: comp.name,
      accessCode: comp.access_code,
      maxPlayers: comp.max_players,
      status: comp.status,
      sessionId,
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Search Users for Invite
// ============================================================
export async function searchUsersForInvite(query, excludeUserIds = []) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return []

    if (!query || query.trim().length < 2) return []

    const searchTerm = query.trim().toLowerCase()

    // Use rpc or direct query — fetch recent users and filter in JS
    const { data: users, error } = await supabase
      .from('auth.users')
      .select('id, email, raw_user_meta_data')
      .neq('id', user.id)
      .limit(50)

    if (error || !users) return []

    const filtered = users.filter((u) => {
      if (excludeUserIds.includes(u.id)) return false
      const email = (u.email || '').toLowerCase()
      const name = (u.raw_user_meta_data?.full_name || u.raw_user_meta_data?.display_name || '').toLowerCase()
      return email.includes(searchTerm) || name.includes(searchTerm)
    })

    return filtered.slice(0, 10).map((u) => ({
      id: u.id,
      email: u.email,
      name: u.raw_user_meta_data?.full_name || u.raw_user_meta_data?.display_name || u.email?.split('@')[0] || 'Utilizador',
      avatarUrl: u.raw_user_meta_data?.avatar_url || null,
    }))
  } catch {
    return []
  }
}

// ============================================================
//  FRIEND CHALLENGE — Send Invite
// ============================================================
export async function sendFriendInvite(competitionId, inviteeUserId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    // Verify competition is owned by current user
    const { data: comp } = await supabase
      .from('competitions')
      .select('id, access_code, max_players, is_friend_challenge')
      .eq('id', competitionId)
      .eq('created_by_user_id', user.id)
      .eq('is_friend_challenge', true)
      .maybeSingle()

    if (!comp) {
      return { success: false, error: 'Competição não encontrada ou não és o criador' }
    }

    // Check if full
    const { count } = await supabase
      .from('competition_sessions')
      .select('*', { count: 'exact', head: true })
      .eq('competition_id', competitionId)

    if (count >= comp.max_players) {
      return { success: false, error: 'A competição está cheia' }
    }

    // Check existing invite
    const { data: existing } = await supabase
      .from('competition_invites')
      .select('id, status')
      .eq('competition_id', competitionId)
      .eq('invitee_user_id', inviteeUserId)
      .maybeSingle()

    if (existing && existing.status !== 'declined') {
      return { success: false, error: 'Já enviaste um convite a este utilizador' }
    }

    const { error: insertError } = await supabase
      .from('competition_invites')
      .insert({
        competition_id: competitionId,
        inviter_user_id: user.id,
        invitee_user_id: inviteeUserId,
        invite_code: comp.access_code,
        status: 'pending',
      })

    if (insertError) {
      if (insertError.code === '23505') {
        return { success: false, error: 'Já enviaste um convite a este utilizador' }
      }
      return { success: false, error: 'Erro ao enviar convite' }
    }

    return { success: true }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Accept Invite
// ============================================================
export async function acceptFriendInvite(inviteId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    const { data: invite } = await supabase
      .from('competition_invites')
      .select('id, competition_id, invite_code, status')
      .eq('id', inviteId)
      .eq('invitee_user_id', user.id)
      .eq('status', 'pending')
      .maybeSingle()

    if (!invite) {
      return { success: false, error: 'Convite não encontrado ou já processado' }
    }

    const { data: comp } = await supabase
      .from('competitions')
      .select('id, max_players, status')
      .eq('id', invite.competition_id)
      .maybeSingle()

    if (!comp || comp.status !== 'lobby') {
      return { success: false, error: 'A competição já começou ou terminou' }
    }

    const { count } = await supabase
      .from('competition_sessions')
      .select('*', { count: 'exact', head: true })
      .eq('competition_id', invite.competition_id)

    if (count >= comp.max_players) {
      return { success: false, error: 'A competição está cheia' }
    }

    const { data: existingSession } = await supabase
      .from('competition_sessions')
      .select('id')
      .eq('competition_id', invite.competition_id)
      .eq('user_id', user.id)
      .maybeSingle()

    if (existingSession) {
      return { success: false, error: 'Já participas nesta competição' }
    }

    // Update invite
    await supabase
      .from('competition_invites')
      .update({ status: 'accepted', responded_at: new Date().toISOString() })
      .eq('id', inviteId)

    // Create session
    const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Jogador'
    const sessionId = `fc_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`

    const { error: sessionError } = await supabase
      .from('competition_sessions')
      .insert({
        competition_id: invite.competition_id,
        session_id: sessionId,
        user_id: user.id,
        student_name: displayName.trim(),
        is_ready: false,
      })

    if (sessionError) {
      return { success: false, error: 'Erro ao entrar na competição' }
    }

    return {
      success: true,
      sessionId,
      competitionId: invite.competition_id,
      accessCode: invite.invite_code,
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Decline Invite
// ============================================================
export async function declineFriendInvite(inviteId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    const { error } = await supabase
      .from('competition_invites')
      .update({ status: 'declined', responded_at: new Date().toISOString() })
      .eq('id', inviteId)
      .eq('invitee_user_id', user.id)
      .eq('status', 'pending')

    if (error) return { success: false, error: 'Erro ao rejeitar convite' }
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Get Pending Invites (for bell)
// ============================================================
export async function getPendingInvites() {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return []

    const { data: invites, error } = await supabase
      .from('competition_invites')
      .select('id, invite_code, status, created_at, inviter_user_id, competitions(name, access_code, status)')
      .eq('invitee_user_id', user.id)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })

    if (error || !invites) return []

    // Fetch inviter names
    const inviterIds = [...new Set(invites.map((i) => i.inviter_user_id))]
    const { data: inviterProfiles } = await supabase
      .from('auth.users')
      .select('id, raw_user_meta_data')
      .in('id', inviterIds)

    const inviterMap = {}
    for (const u of (inviterProfiles || [])) {
      inviterMap[u.id] = u.raw_user_meta_data?.full_name || u.raw_user_meta_data?.display_name || 'Amigo'
    }

    return invites.map((i) => ({
      id: i.id,
      competitionName: i.competitions?.name || 'Desafio',
      accessCode: i.invite_code,
      competitionStatus: i.competitions?.status || 'unknown',
      inviterName: inviterMap[i.inviter_user_id] || 'Amigo',
      createdAt: i.created_at,
    }))
  } catch {
    return []
  }
}

// ============================================================
//  FRIEND CHALLENGE — Get Lobby Players
// ============================================================
export async function getFriendLobbyPlayers(competitionId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return []

    const { data: players, error } = await supabase
      .from('competition_sessions')
      .select('id, session_id, user_id, student_name, is_ready, created_at')
      .eq('competition_id', competitionId)
      .order('created_at', { ascending: true })

    if (error || !players) return []

    // Fetch avatars
    const userIds = players.filter((p) => p.user_id).map((p) => p.user_id)
    const { data: profiles } = await supabase
      .from('auth.users')
      .select('id, raw_user_meta_data')
      .in('id', userIds)

    const profileMap = {}
    for (const u of (profiles || [])) {
      profileMap[u.id] = u.raw_user_meta_data?.avatar_url || null
    }

    return players.map((p) => ({
      sessionId: p.session_id,
      userId: p.user_id,
      name: p.student_name,
      isReady: p.is_ready,
      isCurrentUser: p.user_id === user.id,
      avatarUrl: profileMap[p.user_id] || null,
    }))
  } catch {
    return []
  }
}

// ============================================================
//  FRIEND CHALLENGE — Set Player Ready
// ============================================================
export async function setPlayerReady(sessionId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    const { error } = await supabase
      .from('competition_sessions')
      .update({ is_ready: true, updated_at: new Date().toISOString() })
      .eq('session_id', sessionId)
      .eq('user_id', user.id)

    if (error) return { success: false, error: 'Erro ao marcar como pronto' }
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Start Quiz (creator only)
// ============================================================
export async function startFriendQuiz(competitionId) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Não autenticado' }
    }

    const { data: comp } = await supabase
      .from('competitions')
      .select('id, status, created_by_user_id, questions_count, time_per_question, question_types, streak_bonus')
      .eq('id', competitionId)
      .eq('created_by_user_id', user.id)
      .eq('is_friend_challenge', true)
      .maybeSingle()

    if (!comp) {
      return { success: false, error: 'Não tens permissão para iniciar este desafio' }
    }

    if (comp.status !== 'lobby') {
      return { success: false, error: 'O desafio já começou ou terminou' }
    }

    // Check all players ready
    const { data: players } = await supabase
      .from('competition_sessions')
      .select('id, is_ready, questions')
      .eq('competition_id', competitionId)

    if (!players || players.length < 2) {
      return { success: false, error: 'Precisas de pelo menos 2 jogadores' }
    }

    const allReady = players.every((p) => p.is_ready)
    if (!allReady) {
      return { success: false, error: 'Nem todos os jogadores estão prontos' }
    }

    const now = new Date().toISOString()

    // Persist questions to every player's session (so each player — including
    // a previously invited one whose row was blocked by RLS — can read them
    // from their own session and leave the lobby when the quiz goes active).
    const persistQuestions = async (questionsPayload) => {
      const json = JSON.parse(JSON.stringify(questionsPayload))
      for (const player of players) {
        const { error: upErr } = await supabase
          .from('competition_sessions')
          .update({
            questions: json,
            started_at: now,
            updated_at: now,
          })
          .eq('id', player.id)
        if (upErr) {
          console.error('[friend-challenge] failed to write questions to session', player.id, upErr.message)
        }
      }
    }

    // Check if questions were already generated (partial success from a
    // previous attempt). Use the FIRST player that actually has questions as
    // the source, and make sure every player ends up with them before marking
    // the competition active.
    const hasQuestions = players.some(p => Array.isArray(p.questions) && p.questions.length > 0)
    if (hasQuestions) {
      const source = players.find(p => Array.isArray(p.questions) && p.questions.length > 0)
      if (source) {
        // Re-persist to players that are still missing questions, then activate.
        await persistQuestions(source.questions)
        await supabase
          .from('competitions')
          .update({ status: 'active', started_at: now, updated_at: now })
          .eq('id', competitionId)

        return {
          success: true,
          timePerQuestion: comp.time_per_question || 30,
          streakBonus: comp.streak_bonus !== false,
          questions: source.questions.map(({ correctIndex, ...q }) => q),
        }
      }
    }

    // Generate questions
    const { buildSession } = await import('@/lib/quiz/engine')
    const { getQuizPools } = await import('@/lib/api/quiz')
    const pools = await getQuizPools()

    const questions = buildSession({
      mode: 'rapido',
      level: 'medio',
      source: 'mixed',
      count: comp.questions_count || 10,
      pools,
    })

    await persistQuestions(questions)

    await supabase
      .from('competitions')
      .update({ status: 'active', started_at: now, updated_at: now })
      .eq('id', competitionId)

    return {
      success: true,
      timePerQuestion: comp.time_per_question || 30,
      streakBonus: comp.streak_bonus !== false,
      questions: questions.map(({ correctIndex, ...q }) => q),
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Leaderboard (polling 3s)
// ============================================================
export async function getFriendLeaderboard(competitionId, lastUpdate) {
  try {
    const supabase = await createClient()

    let query = supabase
      .from('competition_sessions')
      .select('id, session_id, user_id, student_name, total_score, correct_count, total_answered, max_streak, finished_at, updated_at')
      .eq('competition_id', competitionId)
      .order('total_score', { ascending: false })

    if (lastUpdate) {
      query = query.gt('updated_at', lastUpdate)
    }

    const { data: sessions, error } = await query
    if (error || !sessions || sessions.length === 0) return { unchanged: true }

    // Fetch avatars
    const userIds = sessions.filter((s) => s.user_id).map((s) => s.user_id)
    const { data: profiles } = await supabase
      .from('auth.users')
      .select('id, raw_user_meta_data')
      .in('id', userIds)

    const profileMap = {}
    for (const u of (profiles || [])) {
      profileMap[u.id] = u.raw_user_meta_data?.avatar_url || null
    }

    const leaderboard = sessions.map((s, idx) => ({
      position: idx + 1,
      sessionId: s.session_id,
      userId: s.user_id,
      name: s.student_name,
      score: s.total_score || 0,
      correct: s.correct_count || 0,
      total: s.total_answered || 0,
      accuracy: s.total_answered > 0 ? Math.round((s.correct_count / s.total_answered) * 100) : 0,
      streak: s.max_streak || 0,
      isFinished: !!s.finished_at,
      avatarUrl: profileMap[s.user_id] || null,
    }))

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
//  FRIEND CHALLENGE — Join by Code
// ============================================================
export async function joinFriendChallengeByCode(accessCode) {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return { success: false, error: 'Precisas de ter conta para entrar num desafio de amigos' }
    }

    const { data: comp } = await supabase
      .from('competitions')
      .select('id, name, status, max_players, is_friend_challenge, access_code')
      .eq('access_code', accessCode.toUpperCase())
      .eq('is_friend_challenge', true)
      .in('status', ['lobby', 'active'])
      .maybeSingle()

    if (!comp) {
      return { success: false, error: 'Desafio não encontrado ou inativo' }
    }

    if (comp.status !== 'lobby') {
      return { success: false, error: 'O desafio já começou' }
    }

    const { count } = await supabase
      .from('competition_sessions')
      .select('*', { count: 'exact', head: true })
      .eq('competition_id', comp.id)

    if (count >= comp.max_players) {
      return { success: false, error: 'O desafio está cheio' }
    }

    const { data: existing } = await supabase
      .from('competition_sessions')
      .select('id, session_id')
      .eq('competition_id', comp.id)
      .eq('user_id', user.id)
      .maybeSingle()

    if (existing) {
      return { success: true, sessionId: existing.session_id, competitionId: comp.id, accessCode: comp.access_code }
    }

    const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Jogador'
    const sessionId = `fc_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`

    // Auto-fill school/class from user profile if available
    const schoolName = user.user_metadata?.school || null
    const className = user.user_metadata?.class_name || null

    const { error: sessionError } = await supabase
      .from('competition_sessions')
      .insert({
        competition_id: comp.id,
        session_id: sessionId,
        user_id: user.id,
        student_name: displayName.trim(),
        is_ready: false,
      })

    if (sessionError) {
      if (sessionError.code === '23505') return { success: false, error: 'Já participas neste desafio' }
      return { success: false, error: 'Erro ao entrar no desafio' }
    }

    return {
      success: true,
      sessionId,
      competitionId: comp.id,
      accessCode: comp.access_code,
      competitionName: comp.name,
    }
  } catch (err) {
    return { success: false, error: err.message || 'Erro interno' }
  }
}

// ============================================================
//  FRIEND CHALLENGE — Challenge History
// ============================================================
export async function getFriendChallengeHistory() {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return []

    const { data: sessions } = await supabase
      .from('competition_sessions')
      .select('id, total_score, correct_count, total_answered, max_streak, finished_at, competition_id, competitions(name, is_friend_challenge)')
      .eq('user_id', user.id)
      .not('finished_at', 'is', null)
      .order('finished_at', { ascending: false })
      .limit(20)

    if (!sessions) return []

    const results = []
    for (const s of sessions) {
      if (!s.competitions?.is_friend_challenge) continue

      const { data: opponents } = await supabase
        .from('competition_sessions')
        .select('student_name, total_score')
        .eq('competition_id', s.competition_id)
        .neq('user_id', user.id)
        .order('total_score', { ascending: false })

      const myScore = s.total_score || 0
      const opponentsList = (opponents || []).map((o) => ({
        name: o.student_name,
        score: o.total_score || 0,
      }))

      const allScores = [myScore, ...opponentsList.map((o) => o.score)].sort((a, b) => b - a)
      const position = allScores.indexOf(myScore) + 1

      results.push({
        id: s.id,
        competitionName: s.competitions?.name || 'Desafio',
        myScore,
        accuracy: s.total_answered > 0 ? Math.round((s.correct_count / s.total_answered) * 100) : 0,
        maxStreak: s.max_streak || 0,
        position,
        opponents: opponentsList,
        finishedAt: s.finished_at,
      })
    }

    return results
  } catch {
    return []
  }
}
