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
//  ensureSavedItem — garantir que existe saved_item para nota (cria se necessário)
// ============================================================
async function ensureSavedItem(supabase, userId, itemType, itemId, itemSlug, itemName) {
  // Tentar encontrar existente
  const existingId = await getSavedItemId(supabase, userId, itemType, itemId)
  if (existingId) return existingId

  // Criar novo saved_item (oculto, só para suportar nota)
  const { data, error } = await supabase
    .from('saved_items')
    .insert({
      user_id: userId,
      item_type: itemType,
      item_id: itemId,
      item_slug: itemSlug || '',
      item_name: itemName || '',
    })
    .select('id')
    .maybeSingle()

  if (error) {
    console.error('ensureSavedItem error:', error)
    return null
  }
  return data?.id || null
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
//  Cria saved_item automaticamente se não existe
// ============================================================
export async function upsertNote(itemType, itemId, content, itemSlug, itemName) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  // Content vazio → eliminar nota se existe
  if (!content || !content.trim()) {
    const savedItemId = await getSavedItemId(supabase, user.id, itemType, itemId)
    if (!savedItemId) return { success: false, error: 'not_found' }
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

  // Garantir que existe saved_item (cria se necessário)
  const savedItemId = await ensureSavedItem(supabase, user.id, itemType, itemId, itemSlug, itemName)
  if (!savedItemId) return { success: false, error: 'could_not_create_saved_item' }

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

  // Buscar notas com item associado
  let queryWithItem = supabase
    .from('saved_item_notes')
    .select(`
      id, content, created_at, updated_at, saved_item_id,
      saved_item:saved_items!inner (
        id, item_id, item_type, item_slug, item_name, item_subtitle
      )
    `, { count: 'exact' })
    .eq('user_id', user.id)
    .not('saved_item_id', 'is', null)

  // Buscar notas soltas
  let queryStandalone = supabase
    .from('saved_item_notes')
    .select(`
      id, content, created_at, updated_at, saved_item_id
    `, { count: 'exact' })
    .eq('user_id', user.id)
    .is('saved_item_id', null)

  // Filtro por tipo
  if (type && type !== 'all') {
    if (type === 'standalone') {
      // Só notas soltas
      queryWithItem = queryWithItem.eq('saved_item.item_type', '__none__')
    } else {
      queryStandalone = queryStandalone.eq('saved_item_id', '__none__')
      queryWithItem = queryWithItem.eq('saved_item.item_type', type)
    }
  }

  // Pesquisa por conteúdo + nome do item
  if (search && search.trim()) {
    const term = `%${search.trim()}%`
    queryWithItem = queryWithItem.or(`content.ilike.${term},saved_item.item_name.ilike.${term}`)
    queryStandalone = queryStandalone.ilike('content', term)
  }

  const offset = (page - 1) * limit

  // Executar ambas as queries
  const [resultWithItem, resultStandalone] = await Promise.all([
    queryWithItem
      .order('updated_at', { ascending: false })
      .range(0, limit * 3),
    queryStandalone
      .order('updated_at', { ascending: false })
      .range(0, limit * 3),
  ])

  // Combinar e normalizar resultados
  const notesWithItem = (resultWithItem.data || []).map(n => ({
    ...n,
    item_type: n.saved_item?.item_type,
    item_slug: n.saved_item?.item_slug,
    item_name: n.saved_item?.item_name,
    item_subtitle: n.saved_item?.item_subtitle,
    is_standalone: false,
  }))

  const notesStandalone = (resultStandalone.data || []).map(n => ({
    ...n,
    item_type: 'standalone',
    item_slug: null,
    item_name: 'Nota solta',
    item_subtitle: null,
    is_standalone: true,
  }))

  // Combinar, ordenar por updated_at e paginar
  const allNotes = [...notesWithItem, ...notesStandalone]
    .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))

  const total = allNotes.length
  const paginatedNotes = allNotes.slice(offset, offset + limit)

  return {
    notes: paginatedNotes,
    total,
    page,
    pages: Math.ceil(total / limit),
  }
}

// ============================================================
//  getNotesCount — contar notas por tipo
// ============================================================
export async function getNotesCount() {
  const { supabase, user } = await getUser()
  if (!user) return { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0, standalone: 0, total: 0 }

  // Notas com item
  const { data: dataWithItem } = await supabase
    .from('saved_item_notes')
    .select('saved_item:saved_items!inner (item_type)')
    .eq('user_id', user.id)
    .not('saved_item_id', 'is', null)

  // Notas soltas
  const { count: standaloneCount } = await supabase
    .from('saved_item_notes')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', user.id)
    .is('saved_item_id', null)

  const counts = { drug: 0, interaction: 0, drug_class: 0, molecular_target: 0, article: 0, standalone: standaloneCount || 0 }
  for (const item of dataWithItem || []) {
    const type = item.saved_item?.item_type
    if (type && counts[type] !== undefined) {
      counts[type]++
    }
  }
  counts.total = Object.values(counts).reduce((a, b) => a + b, 0)

  return counts
}

// ============================================================
//  hasNoteForItem — verificar se item tem nota (por item_type + item_id)
// ============================================================
export async function hasNoteForItem(itemType, itemId) {
  const { supabase, user } = await getUser()
  if (!user) return false

  // Buscar saved_item_id a partir de item_type + item_id
  const savedItemId = await getSavedItemId(supabase, user.id, itemType, itemId)
  if (!savedItemId) return false

  const { data } = await supabase
    .from('saved_item_notes')
    .select('id')
    .eq('saved_item_id', savedItemId)
    .eq('user_id', user.id)
    .maybeSingle()

  return !!data
}

// ============================================================
//  upsertStandaloneNote — criar ou atualizar nota solta (sem item associado)
// ============================================================
export async function upsertStandaloneNote(noteId, content) {
  const { supabase, user } = await getUser()
  if (!user) return { success: false, error: 'auth_required' }

  if (!content || !content.trim()) {
    return { success: false, error: 'content_required' }
  }

  if (content.trim().length > 5000) {
    return { success: false, error: 'content_too_long' }
  }

  let data, error

  if (noteId) {
    // Atualizar nota existente
    const result = await supabase
      .from('saved_item_notes')
      .update({ content: content.trim(), updated_at: new Date().toISOString() })
      .eq('id', noteId)
      .eq('user_id', user.id)
      .is('saved_item_id', null)
      .select('id, content, created_at, updated_at')
      .single()
    data = result.data
    error = result.error
  } else {
    // Criar nova nota solta
    const result = await supabase
      .from('saved_item_notes')
      .insert({
        user_id: user.id,
        content: content.trim(),
        saved_item_id: null,
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
//  deleteNoteById — eliminar nota por ID (funciona para todas)
// ============================================================
export async function deleteNoteById(noteId) {
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
//  getNoteById — buscar nota por ID (para NotesDrawer)
// ============================================================
export async function getNoteById(noteId) {
  const { supabase, user } = await getUser()
  if (!user) return null

  const { data, error } = await supabase
    .from('saved_item_notes')
    .select('id, content, created_at, updated_at')
    .eq('id', noteId)
    .eq('user_id', user.id)
    .maybeSingle()

  if (error || !data) return null
  return data
}

// ============================================================

