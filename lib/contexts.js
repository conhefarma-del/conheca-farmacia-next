'use client'

import { createContext } from 'react'

export const LangContext = createContext({
  lang: 'pt',
  translations: {},
  t: (key) => key,
})
