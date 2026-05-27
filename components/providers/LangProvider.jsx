'use client'

import { useMemo } from 'react'
import { LangContext } from '@/lib/contexts'

function lookupTranslation(translations, keyPath) {
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

export default function LangProvider({ lang, translations, children }) {
  const value = useMemo(() => ({
    lang,
    translations,
    t: (keyPath) => lookupTranslation(translations, keyPath),
  }), [lang, translations])

  return (
    <LangContext.Provider value={value}>
      {children}
    </LangContext.Provider>
  )
}
