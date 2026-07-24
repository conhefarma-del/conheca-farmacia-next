'use client'

import { useState, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { marcarCompareceu } from '@/lib/actions/content'
import { maskEmail } from '@/lib/validar'
import ComprovativoModal from '@/components/admin/ComprovativoModal'
import CertificadoParticipacao from '@/components/admin/CertificadoParticipacao'

export default function InscritosListPage({ lang, inscricoes, eventos, currentUserRole }) {
  const router = useRouter()

  const [filtroEvento, setFiltroEvento] = useState('')
  const [busca, setBusca] = useState('')
  const [erro, setErro] = useState(null)
  const [comprovativoId, setComprovativoId] = useState(null)
  const [certificadoId, setCertificadoId] = useState(null)
  const [loadingId, setLoadingId] = useState(null)

  // Estado local optimístico: sobrepõe o valor da prop inscricoes[i].compareceu
  const [localCompareceu, setLocalCompareceu] = useState({})

  // Valor "real" de compareceu: local override se existir, senão a prop original
  const getCompareceu = (inscricao) => {
    if (inscricao.id in localCompareceu) return localCompareceu[inscricao.id]
    return !!inscricao.compareceu
  }

  const filtrados = useMemo(() => {
    const termo = busca.trim().toLowerCase()
    return inscricoes.filter((i) => {
      const okEvento = !filtroEvento || i.evento_id === filtroEvento
      const okBusca =
        !termo ||
        (i.nome && i.nome.toLowerCase().includes(termo)) ||
        (i.email && i.email.toLowerCase().includes(termo))
      return okEvento && okBusca
    })
  }, [inscricoes, filtroEvento, busca])

  const inscricaoSel = inscricoes.find((i) => i.id === comprovativoId)
  const eventoSel = eventos.find((e) => e.id === inscricaoSel?.evento_id)

  const certInscricao = inscricoes.find((i) => i.id === certificadoId)
  // Usa estado local para saber se o inscrito do certificado tem compareceu ativo
  const certCompareceu = certInscricao ? getCompareceu(certInscricao) : false
  const certEvento = eventos.find((e) => e.id === certInscricao?.evento_id)

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
      <h1 style={{ marginBottom: 24, fontSize: 24, fontWeight: 700 }}>Inscritos</h1>

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
          onChange={(e) => setFiltroEvento(e.target.value)}
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
        <input
          type="search"
          placeholder="Buscar por nome ou email"
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
          className="admin-input"
          style={{ maxWidth: 300 }}
        />
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
            {filtrados.length === 0 && (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', padding: 32, color: '#888' }}>
                  Nenhuma inscrição encontrada.
                </td>
              </tr>
            )}
            {filtrados.map((i) => {
              const compareceu = getCompareceu(i)
              const isPending = loadingId === i.id

              return (
                <tr key={i.id}>
                  <td>{i.nome}</td>
                  <td>{maskEmail(i.email)}</td>
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
                        onClick={() => compareceu && setCertificadoId(i.id)}
                      >
                        Gerar certificado
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

      {certificadoId && certInscricao && certCompareceu && (
        <CertificadoParticipacao
          inscricao={certInscricao}
          evento={certEvento}
          certificadoToken={certInscricao.certificado_token}
          onClose={() => setCertificadoId(null)}
        />
      )}

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
