'use client'

import { useState, useCallback, useEffect } from 'react'
import { Send } from 'lucide-react'
import { sendContentAlert, getPublishedContent } from '@/lib/actions/newsletter'

/**
 * SendAlertForm — Client Component
 *
 * Formulário para enviar alertas de conteúdo.
 * - Tipo: article/event/live
 * - Conteúdo: dropdown de items publicados
 * - Modo: all (todos), manual (selecionados), random (aleatório)
 *
 * Props:
 *   - sendMode: 'all' | 'manual' | 'random'
 *   - randomCount: number
 *   - selectedEmails: Set (para modo manual)
 */

const CONTENT_TYPES = [
  { value: 'article', label: 'Artigo' },
  { value: 'event', label: 'Evento' },
  { value: 'live', label: 'Live' },
]

const BASE_URL = 'https://conhecafarmacia.vercel.app'

function buildContentUrl(type, slug) {
  if (type === 'article') return `${BASE_URL}/artigo.html?id=${slug}`
  if (type === 'event') return `${BASE_URL}/evento.html?id=${slug}`
  return `${BASE_URL}/lives.html?id=${slug}`
}

export default function SendAlertForm({ sendMode = 'all', randomCount = 10, selectedEmails = new Set() }) {
  const [contentType, setContentType] = useState('article')
  const [contentItems, setContentItems] = useState([])
  const [selectedSlug, setSelectedSlug] = useState('')
  const [loadingContent, setLoadingContent] = useState(false)
  const [sending, setSending] = useState(false)
  const [status, setStatus] = useState(null)

  // Carregar conteúdo ao mudar tipo
  useEffect(() => {
    let cancelled = false
    const load = async () => {
      setLoadingContent(true)
      try {
        const items = await getPublishedContent(contentType)
        if (!cancelled) {
          setContentItems(items || [])
          setSelectedSlug('')
        }
      } catch {
        if (!cancelled) setContentItems([])
      } finally {
        if (!cancelled) setLoadingContent(false)
      }
    }
    load()
    return () => { cancelled = true }
  }, [contentType])

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setStatus(null)

    if (!selectedSlug) {
      setStatus({ type: 'error', message: 'Selecione um conteúdo.' })
      return
    }

    setSending(true)

    try {
      const selectedItem = contentItems.find(item => item.slug === selectedSlug || item.id === selectedSlug)
      if (!selectedItem) {
        setStatus({ type: 'error', message: 'Conteúdo não encontrado.' })
        setSending(false)
        return
      }

      const url = buildContentUrl(contentType, selectedItem.slug || selectedItem.id)

      // Determinar emails alvo
      let targetEmails = null
      if (sendMode === 'manual') {
        targetEmails = [...selectedEmails]
      } else if (sendMode === 'random') {
        targetEmails = [String(randomCount)]
      }

      const result = await sendContentAlert(
        contentType,
        {
          title: selectedItem.title,
          url,
          description: selectedItem.excerpt || '',
          date: selectedItem.date || '',
          platform: selectedItem.platform || '',
          location: selectedItem.location || '',
        },
        targetEmails,
        sendMode,
      )

      if (result.success) {
        const modeLabel = sendMode === 'manual' ? ' (selecionados)' : sendMode === 'random' ? ' (aleatório)' : ''
        setStatus({
          type: 'success',
          message: `Alerta enviado com sucesso para ${result.sent} de ${result.total} subscritores${modeLabel}.`,
        })
      } else {
        setStatus({ type: 'error', message: result.error || 'Erro ao enviar alertas.' })
      }
    } catch {
      setStatus({ type: 'error', message: 'Erro ao enviar alertas.' })
    } finally {
      setSending(false)
    }
  }, [selectedSlug, contentItems, contentType, sendMode, randomCount, selectedEmails])

  return (
    <form onSubmit={handleSubmit} className="admin-form">
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Tipo de Conteúdo</label>
          <select
            value={contentType}
            onChange={(e) => setContentType(e.target.value)}
            className="admin-input"
          >
            {CONTENT_TYPES.map(({ value, label }) => (
              <option key={value} value={value}>{label}</option>
            ))}
          </select>
        </div>

        <div className="admin-form-group">
          <label>Conteúdo</label>
          <select
            value={selectedSlug}
            onChange={(e) => setSelectedSlug(e.target.value)}
            className="admin-input"
            disabled={loadingContent}
          >
            <option value="">{loadingContent ? 'A carregar...' : 'Selecionar conteúdo...'}</option>
            {contentItems.map((item) => (
              <option key={item.slug || item.id} value={item.slug || item.id}>
                {item.title}
              </option>
            ))}
          </select>
        </div>
      </div>

      {status && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          fontSize: 14,
          background: status.type === 'success' ? 'rgba(10, 132, 79, 0.08)' : 'rgba(220, 38, 38, 0.08)',
          color: status.type === 'success' ? '#0a844f' : '#dc2626',
          border: `1px solid ${status.type === 'success' ? 'rgba(10, 132, 79, 0.2)' : 'rgba(220, 38, 38, 0.2)'}`,
        }}>
          {status.message}
        </div>
      )}

      <button type="submit" className="admin-btn admin-btn-primary" disabled={sending}>
        <Send size={16} />
        {sending ? 'A enviar...' : 'Enviar Alerta'}
      </button>
    </form>
  )
}
