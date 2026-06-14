'use client'

/**
 * BulkTranslateClient — UI para traduzir em massa via autoTranslateEntity.
 *
 * Faz pool de workers com concorrência limitada (default 5) e reporta
 * progresso + log em tempo real. Para automaticamente se detectar
 * rate limit (não desperdiça chamadas com 429).
 */

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { autoTranslateEntity } from '@/lib/actions/translation'

const CONCURRENCY = 5
const TYPE_LABELS = { article: 'Artigos', event: 'Eventos', live: 'Lives' }

export default function BulkTranslateClient({ groups, lang }) {
  const router = useRouter()
  const [running, setRunning] = useState(false)
  const [progress, setProgress] = useState({ done: 0, total: 0, failed: 0, current: null })
  const [log, setLog] = useState([])

  const all = [
    ...groups.article.map((e) => ({ ...e, type: 'article' })),
    ...groups.event.map((e) => ({ ...e, type: 'event' })),
    ...groups.live.map((e) => ({ ...e, type: 'live' })),
  ]

  async function translateAll() {
    if (typeof window !== 'undefined' && !window.confirm(`Traduzir ${all.length} entidades? Esta acção usa a API OpenRouter.`)) {
      return
    }
    setRunning(true)
    setLog([])
    setProgress({ done: 0, total: all.length, failed: 0, current: null })

    const queue = [...all]
    let done = 0
    let failed = 0
    let stop = false

    async function worker() {
      while (queue.length > 0 && !stop) {
        const item = queue.shift()
        if (!item) break
        setProgress((p) => ({ ...p, current: `${item.type}: ${item.title}` }))
        try {
          const result = await autoTranslateEntity(item.type, item.id)
          if (result?.ok) {
            done += 1
            setLog((l) => [`✓ ${item.type}/${item.title}`, ...l])
          } else if (result?.rateLimited) {
            setLog((l) => [`⛔ Rate limit atingido — parando.`, ...l])
            stop = true
            queue.length = 0
          } else {
            failed += 1
            setLog((l) => [
              `✗ ${item.type}/${item.title}: ${result?.error || 'erro desconhecido'}`,
              ...l,
            ])
          }
        } catch (err) {
          failed += 1
          setLog((l) => [`✗ ${item.type}/${item.title}: ${err?.message || String(err)}`, ...l])
        }
        setProgress((p) => ({ ...p, done, failed }))
      }
    }

    await Promise.all(
      Array.from({ length: Math.min(CONCURRENCY, all.length) }, worker)
    )
    setRunning(false)
    setProgress((p) => ({ ...p, current: null }))
    router.refresh()
  }

  return (
    <div>
      <div
        style={{
          marginBottom: '24px',
          display: 'flex',
          gap: '16px',
          alignItems: 'center',
          flexWrap: 'wrap',
        }}
      >
        <button
          type="button"
          onClick={translateAll}
          disabled={running || all.length === 0}
          style={{
            background: running ? '#9ca3af' : '#2563eb',
            color: 'white',
            border: 'none',
            padding: '10px 20px',
            borderRadius: '6px',
            cursor: running ? 'wait' : 'pointer',
            fontWeight: 600,
          }}
        >
          {running
            ? 'A traduzir...'
            : `✨ Traduzir todos os pendentes (${all.length})`}
        </button>
        {running && (
          <span>
            {progress.done}/{progress.total} ({progress.failed} erros)
          </span>
        )}
      </div>

      {progress.current && (
        <p style={{ color: '#6b7280' }}>
          A traduzir: <strong>{progress.current}</strong>
        </p>
      )}

      {(['article', 'event', 'live']).map((type) => {
        const items = groups[type]
        if (!items || items.length === 0) return null
        return (
          <section key={type} style={{ marginTop: '32px' }}>
            <h2 style={{ marginBottom: '12px' }}>
              {TYPE_LABELS[type]} por traduzir ({items.length})
            </h2>
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              {items.map((item) => (
                <li key={item.id} style={{ marginBottom: '8px' }}>
                  <a
                    href={`/${lang}/admin/${type}s/${item.id}`}
                    style={{ color: '#2563eb', textDecoration: 'underline' }}
                  >
                    {item.title}
                  </a>
                  <span
                    style={{
                      color: '#9ca3af',
                      marginLeft: '8px',
                      fontSize: '12px',
                    }}
                  >
                    /{item.slug}
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )
      })}

      {log.length > 0 && (
        <details style={{ marginTop: '32px' }}>
          <summary style={{ cursor: 'pointer', fontWeight: 600 }}>
            Log de execução ({log.length} entries)
          </summary>
          <pre
            style={{
              background: '#f3f4f6',
              padding: '12px',
              borderRadius: '4px',
              fontSize: '12px',
              maxHeight: '300px',
              overflow: 'auto',
            }}
          >
            {log.join('\n')}
          </pre>
        </details>
      )}

      {all.length === 0 && (
        <p style={{ color: '#059669', fontWeight: 600 }}>
          ✓ Tudo traduzido! Não há entidades pendentes.
        </p>
      )}
    </div>
  )
}
