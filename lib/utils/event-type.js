/**
 * Helpers for rendering event.type and event.hosts in PT/EN.
 *
 * `event.type` is stored as one of the literal values: 'presencial' |
 * 'online' | 'hibrido' (PT) — or in EN, the translated equivalent from
 * event_translations.type. We always normalise via toLowerCase().
 *
 * `event.hosts` is an array of { name, role, organization } stored in
 * events.hosts (JSONB) and mirrored in event_translations.hosts (JSONB).
 * After mergeEntity, the merged row will have an EN array if a translation
 * exists, otherwise the PT array — both have the same shape.
 */

const TYPE_ICONS = {
  online: '💻',
  presencial: '📍',
  hibrido: '🔀',
}

const TYPE_KEYS = {
  online: 'evento_detail.event_type_online',
  presencial: 'evento_detail.event_type_presencial',
  hibrido: 'evento_detail.event_type_hybrid',
}

/**
 * Return the { icon, label } pair for a given event.type literal.
 * `t(key, fallback)` is the i18n function (server or client).
 *
 * @param {string} type
 * @param {(key: string, fallback?: string) => string} t
 * @returns {{icon: string, label: string}}
 */
export function formatEventType(type, t) {
  const norm = (type || '').toLowerCase()
  const icon = TYPE_ICONS[norm] || '📍'
  const key = TYPE_KEYS[norm]
  const label = key ? t(key) : t('evento_detail.event_type_presencial')
  return { icon, label }
}

/**
 * Return a `hosts` array from an event row, preferring the EN translation
 * if it is non-empty, otherwise falling back to the PT base row.
 *
 * mergeEntity currently overwrites the whole `hosts` field with the EN
 * value when present, so this helper is mostly defensive — it normalises
 * both null and `[]` to `[]` and ensures each entry has the expected
 * shape.
 *
 * @param {object} event
 * @returns {Array<{name: string, role: string, organization: string}>}
 */
export function getEventHosts(event) {
  if (!event) return []
  const raw = Array.isArray(event.hosts) ? event.hosts : []
  return raw
    .filter((h) => h && typeof h === 'object')
    .map((h) => ({
      name: h.name ?? '',
      role: h.role ?? '',
      organization: h.organization ?? '',
    }))
}
