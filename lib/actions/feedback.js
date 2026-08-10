'use server'

import { createClient } from '@/lib/supabase/server'
import { headers } from 'next/headers'
import { revalidatePath } from 'next/cache'

// Rate limit em memória por IP (padrão newsletter: 5 pedidos/min/IP, fail-open).
// O endpoint é público — sem limite seria um vetor de spam.
const FEEDBACK_RATE_MAX = 5
const FEEDBACK_RATE_WINDOW_MS = 60_000
const feedbackRate = new Map()

function checkFeedbackRate(ip) {
  const now = Date.now()
  const entry = feedbackRate.get(ip)
  if (!entry || entry.resetAt < now) {
    feedbackRate.set(ip, { count: 1, resetAt: now + FEEDBACK_RATE_WINDOW_MS })
    return true
  }
  if (entry.count >= FEEDBACK_RATE_MAX) return false
  entry.count += 1
  return true
}

const EMAIL_RE = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

/**
 * Helper — verifica sessão + admin_users (padrão de interacoes.js).
 */
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

/**
 * Submeter feedback (público, anónimo).
 * drugId é opcional (componente reutilizável noutras páginas); quando vem de
 * um cartão de interação, interactionType/interactionId/interactionLabel
 * identificam a interação exata ao admin.
 */
export async function submitDrugFeedback({ drugId, interactionType, interactionId, interactionLabel, tipo, mensagem, email, contexto }) {
  const headersList = await headers()
  const ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown'
  if (!checkFeedbackRate(ip)) {
    return { success: false, error: 'Demasiados pedidos. Tenta novamente em 1 minuto.' }
  }

  const cleanMessage = String(mensagem || '').trim()
  if (cleanMessage.length < 3 || cleanMessage.length > 2000) {
    return { success: false, error: 'A mensagem deve ter entre 3 e 2000 caracteres.' }
  }

  const validTypes = ['erro', 'sugestao', 'outro']
  const cleanTipo = validTypes.includes(tipo) ? tipo : 'outro'

  const cleanEmail = email ? String(email).trim() : null
  if (cleanEmail && (cleanEmail.length > 254 || !EMAIL_RE.test(cleanEmail))) {
    return { success: false, error: 'Endereço de email inválido.' }
  }

  const validInteractions = ['drug_drug', 'food', 'disease', 'pregnancy']
  const cleanInteractionType = validInteractions.includes(interactionType) ? interactionType : null

  try {
    const supabase = await createClient()
    const { error } = await supabase.from('drug_feedback').insert({
      drug_id: drugId || null,
      interaction_type: cleanInteractionType,
      interaction_id: interactionId || null,
      interaction_label: interactionLabel ? String(interactionLabel).slice(0, 300) : null,
      tipo: cleanTipo,
      mensagem: cleanMessage,
      email: cleanEmail,
      contexto: contexto ? String(contexto).slice(0, 500) : null,
      status: 'novo',
    })

    if (error) {
      return { success: false, error: 'Não foi possível enviar o feedback. Tenta novamente.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tenta novamente.' }
  }
}

/**
 * Admin — listar feedback. Devolve também o nome do fármaco (para mostrar
 * "de qual fármaco foi feito" mesmo com a tabela referenciada por id).
 */
export async function getDrugFeedback() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('drug_feedback')
      .select('id, drug_id, interaction_type, interaction_label, tipo, mensagem, email, contexto, status, created_at')
      .eq('is_archived', false)
      .order('created_at', { ascending: false })

    if (error) return []

    // Nomes dos fármacos em batch (evita depender do embedding do PostgREST).
    const drugIds = [...new Set((data || []).map((f) => f.drug_id).filter(Boolean))]
    const drugNames = new Map()
    if (drugIds.length > 0) {
      const { data: drugs } = await supabase
        .from('drugs')
        .select('id, slug, name_pt')
        .in('id', drugIds)
      for (const d of drugs || []) drugNames.set(d.id, d)
    }

    return (data || []).map((f) => ({
      id: f.id,
      drugId: f.drug_id,
      drugSlug: drugNames.get(f.drug_id)?.slug || null,
      drugName: drugNames.get(f.drug_id)?.name_pt || null,
      interactionType: f.interaction_type,
      interactionLabel: f.interaction_label,
      tipo: f.tipo,
      mensagem: f.mensagem,
      email: f.email,
      contexto: f.contexto,
      status: f.status,
      createdAt: f.created_at,
    }))
  } catch {
    return []
  }
}

/**
 * Admin — alterar estado (novo → em_revisao → resolvido) ou arquivar.
 */
export async function updateFeedbackStatus(id, status) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Sessão expirada.' }

  const { supabase } = ctx

  const cleanStatus = ['novo', 'em_revisao', 'resolvido'].includes(status) ? status : null
  if (!cleanStatus) return { success: false, error: 'Estado inválido.' }

  try {
    const { error } = await supabase
      .from('drug_feedback')
      .update({ status: cleanStatus, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao atualizar.' }
    revalidatePath('/[lang]/admin/feedback', 'page')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}

/**
 * Admin — arquivar feedback (soft delete).
 */
export async function archiveFeedback(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Sessão expirada.' }

  const { supabase, user } = ctx

  try {
    const { error } = await supabase
      .from('drug_feedback')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao arquivar.' }
    revalidatePath('/[lang]/admin/feedback', 'page')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}
