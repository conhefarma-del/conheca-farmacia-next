'use client'

import { useEffect, useRef } from 'react'
import { incrementInterviewView } from '@/lib/actions/content'

/**
 * InterviewViewCounter — contagem de visualizações da entrevista.
 * Renderiza null; no mount chama a server action `incrementInterviewView`
 * uma única vez por visitante (dedupe via localStorage), para o contador
 * não inflacionar com refreshes/bots da mesma sessão.
 * Padrão do ArticleViewCounter (artigos científicos).
 */
export default function InterviewViewCounter({ interviewId }) {
  const fired = useRef(false)

  useEffect(() => {
    if (!interviewId || fired.current) return
    fired.current = true
    try {
      const key = `interview-viewed:${interviewId}`
      if (window.localStorage.getItem(key)) return
      incrementInterviewView(interviewId)
      try {
        window.localStorage.setItem(key, '1')
      } catch {
        // localStorage indisponível (quota/privado) — não bloquear a página
      }
    } catch {
      // SSR/ambiente sem window — ignorar
    }
  }, [interviewId])

  return null
}
