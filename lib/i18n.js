import fs from 'fs'
import path from 'path'

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

export function t(translations, keyPath) {
  const keys = keyPath.split('.')
  let value = translations

  for (const key of keys) {
    if (value && typeof value === 'object' && key in value) {
      value = value[key]
    } else {
      return keyPath
    }
  }

  return typeof value === 'string' ? value : keyPath
}

export { SUPPORTED_LANGS, DEFAULT_LANG }
