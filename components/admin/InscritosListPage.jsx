'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  marcarCompareceu,
  cancelarInscricaoAdmin,
  emitirCertificado,
} from '@/lib/actions/content'
import ComprovativoModal from '@/components/admin/ComprovativoModal'
import CertificadoParticipacao from '@/components/admin/CertificadoParticipacao'

export default function InscritosListPage({
  lang,
  inscricoes,
  eventos,
  currentUserRole,
  total = 0,
  page = 1,
  pageSize = 25,
  busca = '',
  filtroEvento = '',
}) {
  const router = useRouter()

  const [termo, setTermo] = useState(busca)
  const [erro, setErro] = useState(null)
  const [comprovativoId, setComprovativoId] = useState(null)
  const [certificado, setCertificado] = useState(null)
  const [certificadoLoading, setCertificadoLoading] = useState(null)
  const [loadingId, setLoadingId] = useState(null)
  const [cancelandoId, setCancelandoId] = useState(null)

  const totalPages = Math.max(1, Math.ceil(total / pageSize))
  const inicio = total === 0 ? 0 : (page - 1) * pageSize + 1
  const fim = Math.min(page * pageSize, total)

  // Filtros e paginação vivem na URL — o servidor só envia 25 linhas.
  function navegar(next = {}) {
    const params = new URLSearchParams()
    const q = next.q !== undefined ? next.q : termo
    const evento = next.evento !== undefined ? next.evento : filtroEvento
    const p = next.page !== undefined ? next.page : 1
    if (q) params.set('q', q)
    if (evento) params.set('evento', evento)
    if (p > 1) params.set('page', String(p))
    const qs = params.toString()
    router.push(`/${lang}/admin/inscritos${qs ? `?${qs}` : ''}`)
  }

  // Estado local optimístico: sobrepõe o valor da prop inscricoes[i].compareceu
  const [localCompareceu, setLocalCompareceu] = useState({})

  // Valor "real" de compareceu: local override se existir, senão a prop original
  const getCompareceu = (inscricao) => {
    if (inscricao.id in localCompareceu) return localCompareceu[inscricao.id]
    return !!inscricao.compareceu
  }

  const inscricaoSel = inscricoes.find((i) => i.id === comprovativoId)
  const eventoSel = eventos.find((e) => e.id === inscricaoSel?.evento_id)

  const certInscricao = certificado
    ? inscricoes.find((i) => i.id === certificado.id)
    : null
  const certCompareceu = certInscricao ? getCompareceu(certInscricao) : false
  const certEvento = eventos.find((e) => e.id === certInscricao?.evento_id)

  async function abrirCertificado(id) {
    setErro(null)
    setCertificadoLoading(id)
    const result = await emitirCertificado(id)
    if (result.success) {
      setCertificado({ id, token: result.token })
    } else {
      setErro(result.error || 'Não foi possível emitir o certificado.')
    }
    setCertificadoLoading(null)
  }

  async function cancelarInscricao(id) {
    const motivo = window.prompt('Motivo do cancelamento (opcional):')
    if (motivo === null) return
    setErro(null)
    setCancelandoId(id)
    const result = await cancelarInscricaoAdmin(id, motivo)
    if (!result.success) {
      setErro(result.error || 'Erro ao cancelar a inscrição.')
    } else {
      router.refresh()
    }
    setCancelandoId(null)
  }

  function onToggleCompareceu(id, novoValor) {
    setErro(null)
    setLoadingId(id)

    // Optimistic update: atualiza local instantaneamente
    setLocalCompareceu((prev) => ({ ...prev, [id]: novoValor }))

    // Server action em background
    marcarCompareceu(id, novoValor)
      .then((result) => {
        if (!result.success) {
          // Reverte optimistic update em caso de erro
          setLocalCompareceu((prev) => ({ ...prev, [id]: !novoValor }))
          setErro(result.error || 'Erro ao atualizar participação.')
        } else {
          // Refresh para sincronizar props
          router.refresh()
        }
      })
      .catch(() => {
        setLocalCompareceu((prev) => ({ ...prev, [id]: !novoValor }))
        setErro('Erro ao atualizar participação.')
      })
      .finally(() => {
        setLoadingId(null)
      })
  }

  return (
    <div className="admin-inscritos">
      <h1 style={{ marginBottom: 24, fontSize: 24, fontWeight: 700 }}>
        Inscritos <span style={{ fontSize: 14, color: '#6b7280', fontWeight: 400 }}>({total})</span>
      </h1>

      {/* Filtros */}
      <div
        style={{
          display: 'flex',
          gap: 12,
          marginBottom: 20,
          flexWrap: 'wrap',
          alignItems: 'center',
        }}
      >
        <select
          value={filtroEvento}
          onChange={(e) => navegar({ evento: e.target.value, page: 1 })}
          className="admin-input"
          style={{ maxWidth: 300 }}
        >
          <option value="">Todos os eventos</option>
          {eventos.map((ev) => (
            <option key={ev.id} value={ev.id}>
              {ev.title}
            </option>
          ))}
        </select>
        <form
          onSubmit={(e) => { e.preventDefault(); navegar({ q: termo, page: 1 }) }}
          style={{ display: 'flex', gap: 8 }}
        >
          <input
            type="search"
            placeholder="Buscar por nome ou email"
            value={termo}
            onChange={(e) => setTermo(e.target.value)}
            className="admin-input"
            style={{ maxWidth: 300 }}
          />
          <button type="submit" className="admin-btn admin-btn-secondary">Filtrar</button>
        </form>
        <a
          className="admin-btn admin-btn-secondary"
          href={`/api/admin/inscricoes/export?${new URLSearchParams({
            ...(termo ? { q: termo } : {}),
            ...(filtroEvento ? { evento: filtroEvento } : {}),
          }).toString()}`}
        >
          Exportar CSV
        </a>
      </div>

      {erro && (
        <div
          className="admin-error-message"
          style={{ display: 'block', marginBottom: 16 }}
        >
          {erro}
        </div>
      )}

      {/* Tabela */}
      <div className="admin-table-wrapper">
        <table className="admin-table">
          <thead>
            <tr>
              <th>Nome</th>
              <th>Email</th>
              <th>Evento</th>
              <th>Data inscrição</th>
              <th>Compareceu</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody>
            {inscricoes.length === 0 && (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', padding: 32, color: '#888' }}>
                  Nenhuma inscrição encontrada.
                </td>
              </tr>
            )}
            {inscricoes.map((i) => {
              const compareceu = getCompareceu(i)
              const isPending = loadingId === i.id

              return (
                <tr key={i.id}>
                  <td>
                    <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                      {i.nome}
                      {i.status === 'cancelada' && (
                        <span
                          title="Inscrição cancelada"
                          style={{
                            display: 'inline-block',
                            padding: '1px 8px',
                            borderRadius: 10,
                            background: '#f3f4f6',
                            color: '#4b5563',
                            border: '1px solid #d1d5db',
                            fontSize: 11,
                            fontWeight: 700,
                            lineHeight: '16px',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          Cancelada
                        </span>
                      )}
                      {i.menor_consentimento && (
                        <span
                          title="Inscrição de menor de 18 anos com consentimento do responsável legal"
                          style={{
                            display: 'inline-block',
                            padding: '1px 8px',
                            borderRadius: 10,
                            background: '#fff3cd',
                            color: '#856404',
                            border: '1px solid #ffc107',
                            fontSize: 11,
                            fontWeight: 700,
                            lineHeight: '16px',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          Menor
                        </span>
                      )}
                    </div>
                  </td>
                  <td>{i.email}</td>
                  <td>{i.evento?.title || i.evento_slug || '—'}</td>
                  <td>
                    {i.created_at
                      ? new Date(i.created_at).toLocaleDateString('pt-PT')
                      : '—'}
                  </td>
                  <td>
                    <div style={{ display: 'inline-flex', gap: 4 }}>
                      {/* Pill: Não */}
                      <button
                        type="button"
                        disabled={isPending}
                        onClick={() => onToggleCompareceu(i.id, false)}
                        style={{
                          padding: '4px 14px',
                          borderRadius: 6,
                          border: '1px solid #f5c6cb',
                          background: !compareceu ? '#f8d7da' : 'transparent',
                          color: !compareceu ? '#721c24' : '#888',
                          fontWeight: !compareceu ? 700 : 400,
                          fontSize: 13,
                          cursor: isPending ? 'not-allowed' : 'pointer',
                          opacity: isPending ? 0.6 : 1,
                          transition: 'all 0.15s ease',
                        }}
                      >
                        Não
                      </button>
                      {/* Pill: Sim */}
                      <button
                        type="button"
                        disabled={isPending}
                        onClick={() => onToggleCompareceu(i.id, true)}
                        style={{
                          padding: '4px 14px',
                          borderRadius: 6,
                          border: '1px solid #c3e6cb',
                          background: compareceu ? '#d4edda' : 'transparent',
                          color: compareceu ? '#155724' : '#888',
                          fontWeight: compareceu ? 700 : 400,
                          fontSize: 13,
                          cursor: isPending ? 'not-allowed' : 'pointer',
                          opacity: isPending ? 0.6 : 1,
                          transition: 'all 0.15s ease',
                        }}
                      >
                        Sim
                      </button>
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button
                        type="button"
                        className="admin-btn admin-btn-secondary"
                        style={{ fontSize: 13, padding: '4px 10px' }}
                        onClick={() => setComprovativoId(i.id)}
                      >
                        Ver comprovativo
                      </button>
                      <button
                        type="button"
                        className="admin-btn admin-btn-primary"
                        style={{
                          fontSize: 13,
                          padding: '4px 10px',
                          opacity: compareceu ? 1 : 0.4,
                        }}
                        disabled={!compareceu}
                        title={
                          compareceu
                            ? ''
                            : 'Selecione "Sim" primeiro'
                        }
                        onClick={() => compareceu && abrirCertificado(i.id)}
                      >
                        {certificadoLoading === i.id ? 'A emitir…' : 'Gerar certificado'}
                      </button>
                      <button
                        type="button"
                        className="admin-btn admin-btn-secondary"
                        style={{ fontSize: 13, padding: '4px 10px', color: '#b91c1c' }}
                        disabled={cancelandoId === i.id || i.status === 'cancelada'}
                        onClick={() => cancelarInscricao(i.id)}
                      >
                        {cancelandoId === i.id ? 'A cancelar…' : 'Cancelar'}
                      </button>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {/* Modais */}
      {comprovativoId && inscricaoSel && (
        <ComprovativoModal
          inscricao={inscricaoSel}
          evento={eventoSel}
          onClose={() => setComprovativoId(null)}
        />
      )}

      {certificado && certInscricao && certCompareceu && (
        <CertificadoParticipacao
          inscricao={certInscricao}
          evento={certEvento}
          certificadoToken={certificado.token}
          onClose={() => setCertificado(null)}
        />
      )}

      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          gap: 12,
          marginTop: 16,
        }}
      >
        <span style={{ fontSize: 13, color: '#6b7280' }}>
          {inicio}–{fim} de {total}
        </span>
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            type="button"
            className="admin-btn admin-btn-secondary"
            disabled={page <= 1}
            onClick={() => navegar({ page: page - 1 })}
          >
            Anterior
          </button>
          <button
            type="button"
            className="admin-btn admin-btn-secondary"
            disabled={page >= totalPages}
            onClick={() => navegar({ page: page + 1 })}
          >
            Próxima
          </button>
        </div>
      </div>

      <style>{`
        .admin-inscritos {
          padding: 24px;
        }
        .admin-inscritos .admin-table th,
        .admin-inscritos .admin-table td {
          padding: 10px 12px;
          text-align: left;
          border-bottom: 1px solid var(--admin-border, #e5e7eb);
        }
        .admin-inscritos .admin-table th {
          font-weight: 600;
          font-size: 13px;
          color: #6b7280;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }
        .admin-inscritos .admin-table td {
          font-size: 14px;
        }
        .admin-inscritos .admin-input {
          border: 1px solid var(--admin-border, #d1d5db);
          border-radius: 6px;
          padding: 8px 12px;
          font-size: 14px;
          background: var(--admin-input-bg, #fff);
          color: var(--admin-text, #111);
        }
        .admin-inscritos .admin-btn:disabled {
          opacity: 0.4;
          cursor: not-allowed;
        }
      `}</style>
    </div>
  )
}
