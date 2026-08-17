'use server'

import { createAnonClient } from '@/lib/supabase/server-anon'
import { unstable_cache } from 'next/cache'

// ============================================================
//  Helpers
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? ''
}

function mapTarget(row, lang) {
  return {
    id: row.id,
    slug: row.slug,
    targetType: row.target_type,
    name: pickLang(row, 'name', lang),
    fullName: pickLang(row, 'full_name', lang),
    aliases: row.aliases || [],
    whatIs: pickLang(row, 'what_is', lang),
    role: pickLang(row, 'role', lang),
    substrates: pickLang(row, 'substrates', lang),
    inhibitors: pickLang(row, 'inhibitors', lang),
    inducers: pickLang(row, 'inducers', lang),
    clinicalNotes: pickLang(row, 'clinical_notes', lang),
    source: pickLang(row, 'source', lang),
    sortOrder: row.sort_order || 0,
  }
}

// ============================================================
//  Queries públicas (ISR 3600s, tag 'alvos')
// ============================================================
export const getPublicTargets = unstable_cache(
  async (lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('molecular_targets')
      .select('*')
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })
    if (error) return []
    return (data || []).map((d) => mapTarget(d, lang))
  },
  ['api', 'alvos', 'list'],
  { revalidate: 3600, tags: ['alvos'] }
)

export const getPublicTargetBySlug = unstable_cache(
  async (slug, lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('molecular_targets')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (error || !data) return null
    return mapTarget(data, lang)
  },
  ['api', 'alvos', 'slug'],
  { revalidate: 3600, tags: ['alvos'] }
)
