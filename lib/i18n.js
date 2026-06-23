import fs from 'fs'
import path from 'path'
import { escapeHtml } from './security'

const SUPPORTED_LANGS = ['pt', 'en']
const DEFAULT_LANG = 'pt'

const translationCache = {}

export function loadTranslations(lang) {
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  if (translationCache[safeLang]) {
    return translationCache[safeLang]
  }

  const filePath = path.join(process.cwd(), 'public', 'i18n', `${safeLang}.json`)
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'))
  translationCache[safeLang] = data
  return data
}

// SEC-XSS-01: Sanitização de valores i18n para prevenir XSS
// Nódulo puro (strings) é escaped; HTML ints encional é permitido via marcação
// explícita no JSON (campos com sufixo _html requerem sanitizeHtml no importer).
export function t(translations, keyPath, params, options = { escape: true }) {
  const keys = keyPath.split('.')
  let value = translations

  for (const key of keys) {
    if (value && typeof value === 'object' && key in value) {
      value = value[key]
    } else {
      return keyPath
    }
  }

  if (typeof value !== 'string') return keyPath

  let result = value
  if (params) {
    result = result.replace(/\{(\w+)\}/g, (_, k) =>
      params[k] !== undefined ? String(params[k]) : `{${k}}`
    )
  }

  // SEC-XSS-01: escape HTML por default (previne XSS via tradução)
  if (options.escape !== false) {
    result = escapeHtml(result)
  }

  return result
}

export { SUPPORTED_LANGS, DEFAULT_LANG }
