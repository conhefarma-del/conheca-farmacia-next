'use server'

import { createAdminClient } from '@/lib/supabase/admin'
import { ensureUniqueEnSlug } from '@/lib/api/translations'
import { slugify } from '@/lib/utils/slugify'
import { sanitizeHtml } from '@/lib/sanitize'

// HIGH-01: fields rendered as HTML in admin preview / public page must be
// sanitized before they ever land in the DB. Plain-text fields (title,
// excerpt, host_role, etc.) are escaped at render time, not here.
const HTML_FIELDS = new Set(['content', 'description'])

const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions'
const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || 'google/gemma-4-31b-it:free'
const DAILY_CHAR_LIMIT = parseInt(process.env.TRANSLATION_DAILY_CHAR_LIMIT || '1000000', 10)
const TIMEOUT_MS = 30000

const SYSTEM_PROMPT = `You are a technical translator specialised in pharmacology and pharmaceutical sciences (PT→EN). Your task is to translate Portuguese text fields to natural, professional English suitable for a pharmaceutical-care audience.

Rules:
- Keep scientific terminology in English (e.g., "pharmacokinetics", "bioavailability", "drug interaction").
- Copy proper names (author names, host names) VERBATIM without translating.
- For empty or null values, return null.
- Respond ONLY with valid JSON, no markdown fences, no preamble.
- Use the exact field names provided in the user message.
- Preserve markdown formatting in content fields.`

const ENTITY_FIELDS = {
  article: ['title', 'excerpt', 'content', 'category_label', 'author_role', 'author_bio', 'meta_description'],
  event:   ['title', 'description', 'location', 'host_role', 'host_bio', 'meta_description'],
  live:    ['title', 'description', 'host_role', 'topic', 'meta_description'],
}

const ENTITY_TABLE = {
  article: 'articles',
  event: 'events',
  live: 'lives',
}

const TRANSLATION_TABLE = {
  article: 'article_translations',
  event: 'event_translations',
  live: 'live_translations',
}

const ENTITY_ID_COLUMN = {
  article: 'article_id',
  event: 'event_id',
  live: 'live_id',
}

/**
 * Verifica se o rate limit diário foi atingido.
 * Soma chars traduzidos nas últimas 24h; rejeita se >= DAILY_CHAR_LIMIT.
 */
async function checkRateLimit() {
  const supabase = await createAdminClient()
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const { data, error } = await supabase
    .from('translation_logs')
    .select('char_count')
    .gte('created_at', since)
  if (error) {
    console.error('[translation] checkRateLimit:', error)
    return { allowed: true, used: 0 } // fail open
  }
  const used = (data ?? []).reduce((sum, row) => sum + (row.char_count ?? 0), 0)
  return { allowed: used < DAILY_CHAR_LIMIT, used, limit: DAILY_CHAR_LIMIT }
}

/**
 * Devolve um existsFn(entityType, candidate) compatível com ensureUniqueEnSlug.
 */
function buildSlugExistsFn(supabase, entityType) {
  return async (candidate) => {
    const { data, error } = await supabase
      .from(TRANSLATION_TABLE[entityType])
      .select('slug')
      .eq('slug', candidate)
      .eq('lang', 'en')
      .maybeSingle()
    if (error) {
      console.error(`[translation] buildSlugExistsFn(${entityType}, ${candidate}):`, error)
      return false // fail open
    }
    return !!data
  }
}

/**
 * Chama OpenRouter para traduzir um objecto de campos PT → EN.
 */
async function callOpenRouter(sourceFields) {
  const apiKey = process.env.OPENROUTER_API_KEY
  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY not configured')
  }

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS)

  try {
    const response = await fetch(OPENROUTER_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://conhecafarmacia.com',
        'X-Title': 'Conheça Farmácia Translator',
      },
      body: JSON.stringify({
        model: OPENROUTER_MODEL,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: JSON.stringify(sourceFields) },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.2,
      }),
      signal: controller.signal,
    })

    if (!response.ok) {
      const errText = await response.text()
      throw new Error(`OpenRouter ${response.status}: ${errText.slice(0, 500)}`)
    }

    const result = await response.json()
    const content = result?.choices?.[0]?.message?.content
    if (!content) {
      throw new Error('OpenRouter returned empty content')
    }
    return JSON.parse(content)
  } finally {
    clearTimeout(timeout)
  }
}

/**
 * Auto-traduz uma entidade (article/event/live) de PT → EN.
 * Insere ou actualiza a tradução em article_translations/etc.
 *
 * @param {'article'|'event'|'live'} entityType
 * @param {string} entityId - UUID
 * @returns {Promise<{ok: boolean, translation?: object, error?: string, rateLimited?: boolean}>}
 */
export async function autoTranslateEntity(entityType, entityId) {
  if (!ENTITY_TABLE[entityType]) {
    return { ok: false, error: `Unknown entity type: ${entityType}` }
  }

  // 1. Rate limit
  const rate = await checkRateLimit()
  if (!rate.allowed) {
    return {
      ok: false,
      rateLimited: true,
      error: `Daily translation limit reached (${rate.used}/${rate.limit} chars in last 24h). Try again later.`,
    }
  }

  // 2. Ler registo PT base
  const supabase = await createAdminClient()
  const { data: entity, error: errEntity } = await supabase
    .from(ENTITY_TABLE[entityType])
    .select('*')
    .eq('id', entityId)
    .single()
  if (errEntity || !entity) {
    return { ok: false, error: `Entity not found: ${errEntity?.message || 'no row'}` }
  }

  // 3. Preparar input para IA
  const fields = ENTITY_FIELDS[entityType]
  const sourceObj = {}
  for (const f of fields) {
    sourceObj[f] = entity[f] ?? null
  }

  // 4. Chamar IA
  let translated
  try {
    translated = await callOpenRouter(sourceObj)
  } catch (err) {
    return { ok: false, error: `Translation failed: ${err.message}` }
  }

  // 5. Gerar slug EN único
  const baseSlug = slugify(translated.slug || entity.slug || entity.title || 'untitled')
  const existsFn = buildSlugExistsFn(supabase, entityType)
  const enSlug = await ensureUniqueEnSlug(baseSlug, existsFn)

  // 6. Construir payload (slug override após spread)
  // HIGH-01: sanitize HTML fields returned by the model before persisting.
  // The model should already produce clean markdown, but a malicious or
  // buggy prompt response could embed <script>/onerror — we strip them.
  const { slug: _ignored, ...translatedFields } = translated
  for (const [key, value] of Object.entries(translatedFields)) {
    if (HTML_FIELDS.has(key) && typeof value === 'string') {
      translatedFields[key] = sanitizeHtml(value)
    }
  }
  const translation = {
    [ENTITY_ID_COLUMN[entityType]]: entityId,
    lang: 'en',
    slug: enSlug,
    auto_translated: true,
    translated_at: new Date().toISOString(),
    ...translatedFields,
  }

  // 7. Upsert
  const { data: upserted, error: errUpsert } = await supabase
    .from(TRANSLATION_TABLE[entityType])
    .upsert(translation, {
      onConflict: `${ENTITY_ID_COLUMN[entityType]},lang`,
      ignoreDuplicates: false,
    })
    .select()
    .single()
  if (errUpsert) {
    return { ok: false, error: `Upsert failed: ${errUpsert.message}` }
  }

  // 8. Log
  const charCount = JSON.stringify(sourceObj).length
  await supabase.from('translation_logs').insert({
    entity_type: entityType,
    entity_id: entityId,
    lang: 'en',
    char_count: charCount,
    model: OPENROUTER_MODEL,
    cost_estimate: 0, // TODO: calcular baseado em tokens
  })

  return { ok: true, translation: upserted }
}

/**
 * Versão mais leve para gerar APENAS o slug EN (usado quando a tradução
 * foi feita manualmente e o admin quer gerar slug).
 */
export async function generateEnglishSlugAction(portugueseSlug) {
  // Tentar IA primeiro
  try {
    const apiKey = process.env.OPENROUTER_API_KEY
    if (apiKey) {
      const response = await fetch(OPENROUTER_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: [
            {
              role: 'system',
              content: 'Convert a Portuguese slug to an English kebab-case slug. Output ONLY the slug, no quotes, no explanation.',
            },
            { role: 'user', content: portugueseSlug },
          ],
          temperature: 0.1,
        }),
      })
      if (response.ok) {
        const data = await response.json()
        const slug = data?.choices?.[0]?.message?.content?.trim()
        if (slug && /^[a-z0-9-]+$/.test(slug)) return slug
      }
    }
  } catch (err) {
    console.warn('[translation] generateEnglishSlug IA failed, using fallback:', err)
  }
  // Fallback slugify (português → kebab, sem acentos)
  return slugify(portugueseSlug)
}

/**
 * Server action para guardar tradução EN manualmente.
 * Chamada pelo componente BilingualTabs quando o admin edita os campos EN.
 *
 * Projecta o input (camelCase vindo do form) para snake_case usando
 * `projectTranslatableInput` de lib/api/translations, e faz upsert.
 * Marca `auto_translated: false` para distinguir traduções manuais.
 *
 * @param {'article'|'event'|'live'} entityType
 * @param {string} entityId
 * @param {object} values  — campos EN vindos do form (camelCase)
 * @returns {Promise<{ok: boolean, translation?: object, error?: string}>}
 */
export async function saveTranslationAction(entityType, entityId, values) {
  if (!ENTITY_TABLE[entityType]) {
    return { ok: false, error: `Unknown entity type: ${entityType}` }
  }
  if (!entityId) {
    return { ok: false, error: 'entityId is required' }
  }

  // Import dinâmico para evitar ciclo (translations.js já é importado em use server actions)
  const { projectTranslatableInput } = await import('@/lib/api/translations')

  // 1. Ler slug PT base para derivar slug EN se não foi fornecido
  const supabase = await createAdminClient()
  const { data: entity, error: errEntity } = await supabase
    .from(ENTITY_TABLE[entityType])
    .select('slug, title')
    .eq('id', entityId)
    .single()
  if (errEntity || !entity) {
    return { ok: false, error: `Entity not found: ${errEntity?.message || 'no row'}` }
  }

  // 2. Derivar slug EN: usa o slug fornecido pelo admin; senão, slugify do título EN ou fallback PT
  const baseEnSlug =
    (typeof values.slug === 'string' && values.slug.trim()) ||
    (typeof values.title === 'string' && values.title.trim()) ||
    entity.title ||
    entity.slug ||
    'untitled'

  const table = TRANSLATION_TABLE[entityType]
  const existsFn = async (candidate) => {
    const { data, error: e } = await supabase
      .from(table)
      .select('slug')
      .eq('slug', candidate)
      .eq('lang', 'en')
      .limit(1)
    if (e) {
      console.error('[translation] saveTranslationAction existsFn:', e)
      return false
    }
    return (data?.length ?? 0) > 0
  }
  const enSlug = await ensureUniqueEnSlug(baseEnSlug, existsFn)

  // 3. Projectar input → payload snake_case
  const projected = projectTranslatableInput(values || {}, entityType, { slug: enSlug })

  // HIGH-01: sanitize HTML fields coming from the admin form. Admin input is
  // already validated client-side, but we sanitize server-side as a defense
  // in depth: a compromised admin session or a future API consumer could
  // bypass the form.
  for (const key of HTML_FIELDS) {
    if (typeof projected[key] === 'string') {
      projected[key] = sanitizeHtml(projected[key])
    }
  }

  const idCol = ENTITY_ID_COLUMN[entityType]
  const payload = {
    [idCol]: entityId,
    lang: 'en',
    auto_translated: false,
    translated_at: new Date().toISOString(),
    ...projected,
  }

  // 4. Upsert
  const { data, error } = await supabase
    .from(TRANSLATION_TABLE[entityType])
    .upsert(payload, {
      onConflict: `${idCol},lang`,
      ignoreDuplicates: false,
    })
    .select()
    .single()

  if (error) {
    console.error(`[translation] saveTranslationAction upsert:`, error)
    return { ok: false, error: error.message }
  }

  return { ok: true, translation: data }
}
