'use client'

import { useMemo } from 'react'
import { LangContext } from '@/lib/contexts'

function lookupTranslation(translations, keyPath, params) {
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
  if (!params) return value
  return value.replace(/\{(\w+)\}/g, (_, k) =>
    params[k] !== undefined ? String(params[k]) : `{${k}}`
  )
}

export default function LangProvider({ lang, translations, children }) {
  const value = useMemo(() => ({
    lang,
    translations,
    t: (keyPath, params) => lookupTranslation(translations, keyPath, params),
  }), [lang, translations])

  return (
    <LangContext.Provider value={value}>
      {children}
    </LangContext.Provider>
  )
}
