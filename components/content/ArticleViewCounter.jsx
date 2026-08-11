'use client'

import { useEffect, useRef } from 'react'
import { incrementScientificArticleView } from '@/lib/actions/scientific'

/**
 * ArticleViewCounter — contagem de leituras do artigo científico.
 * Renderiza null; no mount chama a server action `incrementScientificArticleView`
 * uma única vez por visitante (dedupe via localStorage), para o contador
 * "mais lido" não inflacionar com refreshes/bots da mesma sessão.
 */
export default function ArticleViewCounter({ articleId }) {
  const fired = useRef(false)

  useEffect(() => {
    if (!articleId || fired.current) return
    fired.current = true
    try {
      const key = `sci-viewed:${articleId}`
      if (window.localStorage.getItem(key)) return
      incrementScientificArticleView(articleId)
      try {
        window.localStorage.setItem(key, '1')
      } catch {
        // localStorage indisponível (quota/privado) — não bloquear a página
      }
    } catch {
      // SSR/ambiente sem window — ignorar
    }
  }, [articleId])

  return null
}
