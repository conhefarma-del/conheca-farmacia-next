'use client'

import { useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Flag, MessageSquareText, Mail, CheckCircle2, Archive, ExternalLink } from 'lucide-react'
import { updateFeedbackStatus, archiveFeedback } from '@/lib/actions/feedback'

const STATUS_META = {
  novo: { label: 'Novo', className: 'is-novo' },
  em_revisao: { label: 'Em revisão', className: 'is-revisao' },
  resolvido: { label: 'Resolvido', className: 'is-resolvido' },
}

const TIPO_LABEL = {
  erro: 'Erro',
  sugestao: 'Sugestão',
  outro: 'Outro',
}

export default function FeedbackAdminPage({ lang, initialFeedback }) {
  const router = useRouter()
  const [feedback, setFeedback] = useState(initialFeedback || [])
  const [filtro, setFiltro] = useState('todos')
  const [busca, setBusca] = useState('')
  const [erro, setErro] = useState(null)
  const [loadingId, setLoadingId] = useState(null)

  const filtrados = useMemo(() => {
    const termo = busca.trim().toLowerCase()
    return feedback.filter((f) => {
      const okStatus = filtro === 'todos' || f.status === filtro
      const okBusca =
        !termo ||
        (f.drugName && f.drugName.toLowerCase().includes(termo)) ||
        (f.mensagem && f.mensagem.toLowerCase().includes(termo)) ||
        (f.interactionLabel && f.interactionLabel.toLowerCase().includes(termo))
      return okStatus && okBusca
    })
  }, [feedback, filtro, busca])

  function onStatus(id, status) {
    setErro(null)
    setLoadingId(id)
    updateFeedbackStatus(id, status)
      .then((result) => {
        if (!result.success) {
          setErro(result.error || 'Erro ao atualizar.')
        } else {
          setFeedback((prev) =>
            prev.map((f) => (f.id === id ? { ...f, status } : f))
          )
        }
      })
      .catch(() => setErro('Erro ao atualizar.'))
      .finally(() => setLoadingId(null))
  }

  function onArchive(id) {
    if (!window.confirm('Arquivar este feedback?')) return
    setErro(null)
    setLoadingId(id)
    archiveFeedback(id)
      .then((result) => {
        if (!result.success) {
          setErro(result.error || 'Erro ao arquivar.')
        } else {
          setFeedback((prev) => prev.filter((f) => f.id !== id))
          router.refresh()
        }
      })
      .catch(() => setErro('Erro ao arquivar.'))
      .finally(() => setLoadingId(null))
  }

  const novos = feedback.filter((f) => f.status === 'novo').length

  return (
    <div className="admin-feedback">
      <div className="admin-page-header">
        <h1 className="admin-page-title">Feedback dos leitores</h1>
        <p className="admin-page-subtitle">
          Erros e sugestões enviados das fichas de fármaco
          {novos > 0 && (
            <span className="admin-feedback-badge">{novos} novos</span>
          )}
        </p>
      </div>

      {erro && <p className="admin-error-box">{erro}</p>}

      <div className="admin-feedback-toolbar">
        <div className="admin-feedback-filters" role="group" aria-label="Filtrar por estado">
          {[
            { value: 'todos', label: 'Todos' },
            { value: 'novo', label: 'Novos' },
            { value: 'em_revisao', label: 'Em revisão' },
            { value: 'resolvido', label: 'Resolvidos' },
          ].map((f) => (
            <button
              key={f.value}
              className={`admin-feedback-filter${filtro === f.value ? ' is-active' : ''}`}
              onClick={() => setFiltro(f.value)}
            >
              {f.label}
            </button>
          ))}
        </div>
        <input
          className="admin-feedback-search"
          type="search"
          placeholder="Procurar fármaco ou mensagem…"
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
        />
      </div>

      {filtrados.length === 0 ? (
        <p className="admin-feedback-empty">Sem feedback para mostrar.</p>
      ) : (
        <div className="admin-feedback-list">
          {filtrados.map((f) => (
            <article key={f.id} className="admin-feedback-item">
              <header className="admin-feedback-item-header">
                <span className="admin-feedback-drug">
                  <Flag size={14} aria-hidden="true" />
                  {f.drugName || 'Página genérica'}
                  {f.drugSlug && (
                    <a
                      className="admin-feedback-drug-link"
                      href={`/${lang}/admin/interacoes`}
                      title={f.drugSlug}
                    >
                      <ExternalLink size={11} aria-hidden="true" />
                    </a>
                  )}
                </span>
                <span className={`admin-feedback-tipo is-${f.tipo}`}>
                  {TIPO_LABEL[f.tipo] || f.tipo}
                </span>
                <span className={`admin-feedback-status ${STATUS_META[f.status]?.className || ''}`}>
                  {STATUS_META[f.status]?.label || f.status}
                </span>
              </header>

              {f.interactionLabel && (
                <p className="admin-feedback-interaction">
                  <MessageSquareText size={13} aria-hidden="true" />
                  {f.interactionLabel}
                </p>
              )}

              <p className="admin-feedback-mensagem">{f.mensagem}</p>

              <footer className="admin-feedback-item-footer">
                <span className="admin-feedback-meta">
                  {new Date(f.createdAt).toLocaleString('pt-PT')}
                </span>
                {f.email && (
                  <span className="admin-feedback-meta">
                    <Mail size={12} aria-hidden="true" />
                    {f.email}
                  </span>
                )}
                {f.contexto && (
                  <span className="admin-feedback-meta admin-feedback-contexto">
                    {f.contexto}
                  </span>
                )}
                <span className="admin-feedback-actions">
                  {f.status !== 'em_revisao' && (
                    <button
                      className="admin-feedback-action"
                      disabled={loadingId === f.id}
                      onClick={() => onStatus(f.id, 'em_revisao')}
                    >
                      Em revisão
                    </button>
                  )}
                  {f.status !== 'resolvido' && (
                    <button
                      className="admin-feedback-action is-ok"
                      disabled={loadingId === f.id}
                      onClick={() => onStatus(f.id, 'resolvido')}
                    >
                      <CheckCircle2 size={12} aria-hidden="true" />
                      Resolver
                    </button>
                  )}
                  <button
                    className="admin-feedback-action is-archive"
                    disabled={loadingId === f.id}
                    onClick={() => onArchive(f.id)}
                  >
                    <Archive size={12} aria-hidden="true" />
                    Arquivar
                  </button>
                </span>
              </footer>
            </article>
          ))}
        </div>
      )}
    </div>
  )
}
