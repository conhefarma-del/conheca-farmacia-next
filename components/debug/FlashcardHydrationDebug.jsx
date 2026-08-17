'use client'

import { Component, useEffect } from 'react'

/**
 * FlashcardHydrationDebug — diagnóstico temporário do erro React #441
 * (hydration mismatch) em /flashcards/[slug].
 *
 * - ErrorBoundary: captura erros de render/hydration dos filhos e imprime no
 *   console o erro completo (mensagem, stack, componentStack) com prefixo
 *   [FLASHCARD-DEBUG].
 * - HydrationLogger: no mount, compara o deck recebido (props) e imprime um
 *   resumo + o conteúdo dos cartões em JSON, para comparar com o que o
 *   servidor enviou (log correspondente em page.js).
 *
 * REMOVER quando o bug estiver resolvido.
 */
export default function FlashcardHydrationDebug({ deck, drugMap }) {
  useEffect(() => {
    const summarize = (obj, maxLen = 400) => {
      try {
        const json = JSON.stringify(obj)
        return json.length > maxLen ? json.slice(0, maxLen) + '…' : json
      } catch {
        return String(obj)
      }
    }

    console.log('[FLASHCARD-DEBUG] client mount deck:', summarize(deck))
    console.log('[FLASHCARD-DEBUG] client mount drugMap:', summarize(drugMap))

    // Captura erros não tratados (incl. hydration) com stack completo
    const onError = (e) => {
      console.error('[FLASHCARD-DEBUG] window.onerror:', {
        message: e.message,
        filename: e.filename,
        lineno: e.lineno,
        colno: e.colno,
        error: e.error && { message: e.error.message, stack: e.error.stack },
      })
    }
    const onRejection = (e) => {
      console.error('[FLASHCARD-DEBUG] unhandledrejection:', {
        reason: e.reason && { message: e.reason.message, stack: e.reason.stack },
      })
    }
    window.addEventListener('error', onError)
    window.addEventListener('unhandledrejection', onRejection)

    // Após a hidratação terminar, log de confirmação
    const t = setTimeout(() => {
      console.log('[FLASHCARD-DEBUG] hydration window finished (2s após mount)')
    }, 2000)

    return () => {
      window.removeEventListener('error', onError)
      window.removeEventListener('unhandledrejection', onRejection)
      clearTimeout(t)
    }
  }, [])

  return null
}

export class FlashcardErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, info) {
    console.error('[FLASHCARD-DEBUG] componentDidCatch:', {
      error: { message: error.message, stack: error.stack },
      componentStack: info.componentStack,
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: 40, textAlign: 'center' }}>
          <p>Falha ao renderizar a sessão de revisão. Ver o console para [FLASHCARD-DEBUG].</p>
          <button onClick={() => this.setState({ hasError: false, error: null })}>Tentar novamente</button>
        </div>
      )
    }
    return this.props.children
  }
}
