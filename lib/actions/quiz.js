'use server'

import { createClient } from '@/lib/supabase/server'
import { getQuizPools } from '@/lib/api/quiz'
import { buildSession, sameAnswer, severityLabel } from '@/lib/quiz/engine'

const VALID_MODES = ['deck', 'tipo', 'rapido', 'nivel']
const VALID_SOURCES = ['flashcard', 'pharmacology', 'interaction', 'protocol']
const VALID_LEVELS = ['facil', 'medio', 'dificil']

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users (padrão do projeto).
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
 * Monta a sessão de quiz a partir dos dados reais.
 * Nunca devolve o correctIndex ao cliente — a resposta é validada no
 * servidor (answerQuiz).
 */
export async function startQuiz({ mode = 'rapido', level = 'facil', deckSlug = '', source = 'mixed', count = 10 } = {}) {
  try {
    if (!VALID_MODES.includes(mode)) return { ok: false, error: 'Modo inválido' }
    if (mode === 'tipo' && !VALID_SOURCES.includes(source)) return { ok: false, error: 'Fonte inválida' }
    if (mode === 'nivel' && !VALID_LEVELS.includes(level)) return { ok: false, error: 'Nível inválido' }

    const pools = await getQuizPools()
    const questions = buildSession({
      mode,
      level: String(level || 'facil'),
      deckSlug: String(deckSlug || ''),
      source,
      count: Number(count) || 10,
      pools,
    })

    const deck = mode === 'deck' ? pools.decks.find((d) => d.slug === deckSlug) : null
    if (mode === 'deck' && !deck) return { ok: false, error: 'Deck não encontrado' }

    return {
      ok: true,
      questions: questions.map(({ correctIndex, ...q }) => q), // remove a correta
      deckId: deck?.id || null,
    }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao iniciar o quiz' }
  }
}

/**
 * Valida a resposta escolhida contra o dado real (nunca confia no cliente).
 * `key` identifica a pergunta: flashcard:<id> | pharmacology:<drugId>:<field>
 * | interaction:<id> | food:<id> | disease:<id> | protocol:<id>.
 */
export async function answerQuiz({ key = '', selected = '' } = {}) {
  try {
    const supabase = await createClient()
    const parts = String(key).split(':')
    const kind = parts[0]
    let correct = ''
    let explanation = ''
    let source = ''

    if (kind === 'flashcard') {
      const { data } = await supabase
        .from('flashcards')
        .select('back_pt, source_note')
        .eq('id', parts[1])
        .maybeSingle()
      correct = data?.back_pt || ''
      source = data?.source_note || 'Flashcards'
    } else if (kind === 'pharmacology') {
      const drugId = parts[1]
      const field = parts[2]
      if (field === 'classe') {
        const { data } = await supabase.from('drugs').select('class_pt').eq('id', drugId).maybeSingle()
        correct = data?.class_pt || ''
        source = 'Classificação interna (drugs.class_pt)'
      } else if (field === 'mecanismo') {
        const { data } = await supabase
          .from('drug_pharmacology')
          .select('mechanism_pt')
          .eq('drug_id', drugId)
          .maybeSingle()
        correct = data?.mechanism_pt || ''
        source = 'Farmacologia interna'
      } else if (field === 'meia_vida') {
        const { data } = await supabase
          .from('drug_pharmacology')
          .select('half_life_pt')
          .eq('drug_id', drugId)
          .maybeSingle()
        correct = data?.half_life_pt || ''
        source = 'Farmacologia interna'
      }
    } else if (kind === 'interaction') {
      const { data } = await supabase
        .from('drug_interactions')
        .select('summary_pt, severity')
        .eq('id', parts[1])
        .maybeSingle()
      correct = data?.summary_pt || ''
      explanation = data?.severity ? `Grau da interação: ${severityLabel(data.severity)}` : ''
      source = 'Banco de interações'
    } else if (kind === 'food') {
      const { data } = await supabase
        .from('drug_food_interactions')
        .select('entity_pt')
        .eq('id', parts[1])
        .maybeSingle()
      correct = data?.entity_pt || ''
      source = 'Banco de interações (alimentos)'
    } else if (kind === 'disease') {
      const { data } = await supabase
        .from('drug_disease_interactions')
        .select('condition_pt')
        .eq('id', parts[1])
        .maybeSingle()
      correct = data?.condition_pt || ''
      source = 'Banco de interações (doenças)'
    } else if (kind === 'protocol') {
      const { data } = await supabase
        .from('clinical_protocol_quizzes')
        .select('option_a_pt, option_b_pt, option_c_pt, option_d_pt, correct_index, explanation_pt')
        .eq('id', parts[1])
        .maybeSingle()
      if (data) {
        const opts = [data.option_a_pt, data.option_b_pt, data.option_c_pt, data.option_d_pt]
        correct = opts[data.correct_index] || ''
        explanation = data.explanation_pt || ''
        source = 'Protocolos clínicos'
      }
    }

    if (!correct) return { ok: false, error: 'Pergunta não encontrada' }

    return {
      ok: true,
      correct: sameAnswer(correct, selected),
      correctAnswer: correct,
      explanation,
      source,
    }
  } catch (err) {
    return { ok: false, error: err.message || 'Erro ao validar a resposta' }
  }
}

/**
 * Guarda a tentativa final em quiz_attempts — apenas com sessão (anónima ou
 * real). Modo "sem registo" → não insere (saved: false).
 */
export async function finishQuiz({ mode = 'rapido', level = 'facil', source = 'mixed', deckId = null, total = 0, correct = 0, details = [] } = {}) {
  try {
    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { ok: true, saved: false }

    const safeTotal = Math.max(0, Math.min(100, Number(total) || 0))
    const safeCorrect = Math.max(0, Math.min(safeTotal, Number(correct) || 0))
    const safeDetails = Array.isArray(details)
      ? details.slice(0, 50).map((d) => ({ key: String(d?.key || ''), correct: Boolean(d?.correct) }))
      : []

    const { error } = await supabase.from('quiz_attempts').insert({
      user_id: user.id,
      mode: VALID_MODES.includes(mode) ? mode : 'rapido',
      deck_id: deckId || null,
      question_source: mode === 'nivel' ? `nivel:${VALID_LEVELS.includes(level) ? level : 'facil'}` : source,
      total: safeTotal,
      correct: safeCorrect,
      details: safeDetails,
      finished_at: new Date().toISOString(),
    })
    if (error) return { ok: false, saved: false, error: error.message }
    return { ok: true, saved: true }
  } catch (err) {
    return { ok: false, saved: false, error: err.message || 'Erro ao guardar a tentativa' }
  }
}

/** Estatísticas do admin (últimas 200 tentativas). */
export async function getQuizStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { attempts: 0, avgAccuracy: 0, byMode: [], bySource: [], recent: [] }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('quiz_attempts')
      .select('id, mode, question_source, total, correct, finished_at, created_at')
      .order('created_at', { ascending: false })
      .limit(200)
    if (error) throw error

    const rows = data || []
    const finished = rows.filter((r) => (r.total || 0) > 0)
    const avgAccuracy = finished.length
      ? Math.round((finished.reduce((s, r) => s + (r.correct / r.total), 0) / finished.length) * 100)
      : 0

    const byMode = {}
    const bySource = {}
    for (const r of rows) {
      byMode[r.mode] = (byMode[r.mode] || 0) + 1
      bySource[r.question_source] = (bySource[r.question_source] || 0) + 1
    }

    return {
      attempts: rows.length,
      avgAccuracy,
      byMode: Object.entries(byMode).map(([k, v]) => ({ key: k, count: v })),
      bySource: Object.entries(bySource).map(([k, v]) => ({ key: k, count: v })),
      recent: rows.slice(0, 10).map((r) => ({
        id: r.id,
        mode: r.mode,
        source: r.question_source,
        total: r.total,
        correct: r.correct,
        finishedAt: r.finished_at || r.created_at,
      })),
    }
  } catch {
    return { attempts: 0, avgAccuracy: 0, byMode: [], bySource: [], recent: [] }
  }
}
