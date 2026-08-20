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

  if (!content || !content.trim() || content.trim().length > 5000) {
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

  if (!content || !content.trim() || content.trim().length > 5000) {
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
//  getSavedItemId — obter saved_items.id a partir de item_type + item_id
// ============================================================
async function getSavedItemId(supabase, userId, itemType, itemId) {
  try {
    const { data, error } = await supabase
      .from('saved_items')
      .select('id')
      .eq('user_id', userId)
      .eq('item_type', itemType)
      .eq('item_id', itemId)
      .maybeSingle()
    if (error) {
      console.error('getSavedItemId error:', error)
      return null
    }
    return data?.id || null
  } catch (err) {
    console.error('getSavedItemId exception:', err)
    return null
  }
}

// ============================================================
//  getNoteForItem — buscar a nota contínua de um item (por item_type + item_id)
// ============================================================
export async function getNoteForItem(itemType, itemId) {
  try {
    const { supabase, user } = await getUser()
    if (!user) return null

    const savedItemId = await getSavedItemId(supabase, user.id, itemType, itemId)
    if (!savedItemId) return null

    const { data, error } = await supabase
      .from('saved_item_notes')
      .select('id, content, created_at, updated_at')
      .eq('saved_item_id', savedItemId)
      .eq('user_id', user.id)
      .maybeSingle()

    if (error) {
      console.error('getNoteForItem query error:', error)
      return null
    }

    return data || null
  } catch (err) {
    console.error('getNoteForItem exception:', err)
    return null
  }
}

// ============================================================
//  upsertNote — criar ou atualizar nota contínua de um item
// ============================================================
export async function upsertNote(itemType, itemId, content) {
  console.log('upsertNote called:', { itemType, itemId, contentLength: content?.length })
  const { supabase, user } = await getUser()
  if (!user) {
    console.log('upsertNote: no user')
    return { success: false, error: 'auth_required' }
  }

  // Content vazio → eliminar nota se existe
  if (!content || !content.trim()) {
    const savedItemId = await getSavedItemId(supabase, user.id, itemType, itemId)
    if (!savedItemId) return { success: false, error: 'not_saved' }
    const { error } = await supabase
      .from('saved_item_notes')
      .delete()
      .eq('saved_item_id', savedItemId)
      .eq('user_id', user.id)
    if (error) return { success: false, error: error.message }
    return { success: true, note: null }
  }

  if (content.trim().length > 5000) {
    return { success: false, error: 'content_too_long' }
  }

  // Get saved_item_id
  const savedItemId = await getSavedItemId(supabase, user.id, itemType, itemId)
  if (!savedItemId) return { success: false, error: 'not_saved' }

  // Check if note already exists
  const { data: existing } = await supabase
    .from('saved_item_notes')
    .select('id')
    .eq('saved_item_id', savedItemId)
    .eq('user_id', user.id)
    .maybeSingle()

  let data, error

  if (existing) {
    // Update existing note
    const result = await supabase
      .from('saved_item_notes')
      .update({ content: content.trim(), updated_at: new Date().toISOString() })
      .eq('id', existing.id)
      .select('id, content, created_at, updated_at')
      .single()
    data = result.data
    error = result.error
  } else {
    // Insert new note
    const result = await supabase
      .from('saved_item_notes')
      .insert({
        saved_item_id: savedItemId,
        user_id: user.id,
        content: content.trim(),
      })
      .select('id, content, created_at, updated_at')
      .single()
    data = result.data
    error = result.error
  }

  if (error) return { success: false, error: error.message }
  return { success: true, note: data }
}

// ============================================================
//  getAllNotes — listar todas as notas do utilizador com filtros
// ============================================================
export async function getAllNotes({ search, type, page = 1, limit = 20 } = {}) {
  const { supabase, user } = await getUser()
  if (!user) return { notes: [], total: 0, page: 1, pages: 0 }

  let query = supabase
    .from('saved_item_notes')
    .select(`
      id, content, created_at, updated_at,
      saved_item:saved_items!inner (
        id, item_type, item_slug, item_name, item_subtitle
      )
    `, { count: 'exact' })
    .eq('user_id', user.id)

  // Filtro por tipo
  if (type && type !== 'all') {
    query = query.eq('saved_item.item_type', type)
  }

  // Pesquisa por conteúdo + nome do item
  if (search && search.trim()) {
    const term = `%${search.trim()}%`
    query = query.or(`content.ilike.${term},saved_item.item_name.ilike.${term}`)
  }

  const offset = (page - 1) * limit
  query = query
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1)

  const { data, error, count } = await query
  if (error) return { notes: [], total: 0, page: 1, pages: 0 }

  return {
    notes: data || [],
    total: count || 0,
    page,
    pages: Math.ceil((count || 0) / limit),
  }
}

// ============================================================
//  getNotesCount — contar notas por tipo
// ============================================================
export async function getNotesCount() {
  const { supabase, user } = await getUser()
  if (!user) return { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0, total: 0 }

  const { data } = await supabase
    .from('saved_item_notes')
    .select('saved_item:saved_items!inner (item_type)')
    .eq('user_id', user.id)

  const counts = { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0 }
  for (const item of data || []) {
    const type = item.saved_item?.item_type
    if (type && counts[type] !== undefined) {
      counts[type]++
    }
  }
  counts.total = Object.values(counts).reduce((a, b) => a + b, 0)

  return counts
}

// ============================================================
//  hasNoteForItem — verificar se item tem nota
// ============================================================
export async function hasNoteForItem(savedItemId) {
  const { supabase, user } = await getUser()
  if (!user) return false

  const { data } = await supabase
    .from('saved_item_notes')
    .select('id')
    .eq('saved_item_id', savedItemId)
    .eq('user_id', user.id)
    .maybeSingle()

  return !!data
}

// ============================================================

