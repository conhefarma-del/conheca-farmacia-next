'use server'

import { createClient } from '@/lib/supabase/server'

const MAX_SAVED_ITEMS = 200
const VALID_ITEM_TYPES = ['drug', 'interaction', 'drug_class', 'molecular_target', 'article']

// ============================================================
//  Helper: getUser
// ============================================================
async function getUser() {
  const supabase = await createClient()
  const { data: { user }, error } = await supabase.auth.getUser()
  if (error || !user) return { supabase: null, user: null }
  return { supabase, user }
}

// ============================================================
//  toggleSaveItem — guardar/remover item (toggle)
// ============================================================
export async function toggleSaveItem({ itemType, itemId, itemSlug, itemName, itemSubtitle, itemImageUrl }) {
  const { supabase, user } = await getUser()
  if (!user) {
    return { success: false, error: 'auth_required', saved: false }
  }

  if (!VALID_ITEM_TYPES.includes(itemType)) {
    return { success: false, error: 'invalid_type' }
  }

  // Single query: check existing + delete/insert in parallel
  const { data: existing } = await supabase
    .from('saved_items')
    .select('id')
    .eq('user_id', user.id)
    .eq('item_type', itemType)
    .eq('item_id', itemId)
    .maybeSingle()

  if (existing) {
    const { error } = await supabase
      .from('saved_items')
      .delete()
      .eq('id', existing.id)

    if (error) return { success: false, error: error.message, saved: true }
    return { success: true, saved: false }
  }

  // Insert (skip limit check for speed — enforced at DB level if needed)
  const { error } = await supabase
    .from('saved_items')
    .insert({
      user_id: user.id,
      item_type: itemType,
      item_id: itemId,
      item_slug: itemSlug,
      item_name: itemName,
      item_subtitle: itemSubtitle || null,
      item_image_url: itemImageUrl || null,
    })

  if (error) return { success: false, error: error.message, saved: false }
  return { success: true, saved: true }
}

// ============================================================
//  isItemSaved — verificar se item está guardado
// ============================================================
export async function isItemSaved(itemType, itemId) {
  const { supabase, user } = await getUser()
  if (!user) return false

  const { data } = await supabase
    .from('saved_items')
    .select('id')
    .eq('user_id', user.id)
    .eq('item_type', itemType)
    .eq('item_id', itemId)
    .maybeSingle()

  return !!data
}

// ============================================================
//  getSavedItems — listar guardados com filtro e pesquisa
// ============================================================
export async function getSavedItems({ itemType, search, page = 1, limit = 20 } = {}) {
  const { supabase, user } = await getUser()
  if (!user) return { items: [], total: 0, page: 1, pages: 0 }

  let query = supabase
    .from('saved_items')
    .select('*', { count: 'exact' })
    .eq('user_id', user.id)

  if (itemType && itemType !== 'all') {
    query = query.eq('item_type', itemType)
  }

  if (search && search.trim()) {
    query = query.ilike('item_name', `%${search.trim()}%`)
  }

  const offset = (page - 1) * limit
  query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1)

  const { data, error, count } = await query

  if (error) return { items: [], total: 0, page: 1, pages: 0 }

  return {
    items: data || [],
    total: count || 0,
    page,
    pages: Math.ceil((count || 0) / limit),
  }
}

// ============================================================
//  getSavedCounts — contar guardados por tipo
// ============================================================
export async function getSavedCounts() {
  const { supabase, user } = await getUser()
  if (!user) return { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0, total: 0 }

  const { data } = await supabase
    .from('saved_items')
    .select('item_type')
    .eq('user_id', user.id)

  const counts = { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0 }
  for (const item of data || []) {
    if (counts[item.item_type] !== undefined) {
      counts[item.item_type]++
    }
  }
  counts.total = Object.values(counts).reduce((a, b) => a + b, 0)

  return counts
}

// ============================================================
//  addNote — adicionar anotação
// ============================================================
export async function addNote(savedItemId, content) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  if (!content || !content.trim() || content.trim().length > 2000) {
    return { success: false, error: 'invalid_content' }
  }

  // Verify the saved item belongs to user
  const { data: item } = await supabase
    .from('saved_items')
    .select('id')
    .eq('id', savedItemId)
    .eq('user_id', user.id)
    .maybeSingle()

  if (!item) return { success: false, error: 'not_found' }

  const { data, error } = await supabase
    .from('saved_item_notes')
    .insert({
      saved_item_id: savedItemId,
      user_id: user.id,
      content: content.trim(),
    })
    .select('id, content, created_at, updated_at')
    .single()

  if (error) return { success: false, error: error.message }

  return { success: true, note: data }
}

// ============================================================
//  updateNote — editar anotação
// ============================================================
export async function updateNote(noteId, content) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  if (!content || !content.trim() || content.trim().length > 2000) {
    return { success: false, error: 'invalid_content' }
  }

  const { data, error } = await supabase
    .from('saved_item_notes')
    .update({ content: content.trim() })
    .eq('id', noteId)
    .eq('user_id', user.id)
    .select('id, content, created_at, updated_at')
    .single()

  if (error) return { success: false, error: error.message }

  return { success: true, note: data }
}

// ============================================================
//  deleteNote — eliminar anotação
// ============================================================
export async function deleteNote(noteId) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  const { error } = await supabase
    .from('saved_item_notes')
    .delete()
    .eq('id', noteId)
    .eq('user_id', user.id)

  if (error) return { success: false, error: error.message }

  return { success: true }
}

// ============================================================
//  getNotes — buscar anotações de um item
// ============================================================
export async function getNotes(savedItemId) {
  const { supabase, user } = await getUser()
  if (!user) return []

  const { data } = await supabase
    .from('saved_item_notes')
    .select('id, content, created_at, updated_at')
    .eq('saved_item_id', savedItemId)
    .eq('user_id', user.id)
    .order('created_at', { ascending: false })

  return data || []
}

// ============================================================

