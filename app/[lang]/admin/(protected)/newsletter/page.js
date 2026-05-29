'use client'

import { useState, useCallback, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Users, UserCheck, UserX, Mail } from 'lucide-react'
import { getSubscribers, getNewsletterStats } from '@/lib/actions/newsletter'
import SendAlertForm from '@/components/admin/SendAlertForm'
import SubscribersTable from '@/components/admin/SubscribersTable'

/**
 * Newsletter Page — Client Component
 *
 * Gerir subscritores e enviar alertas de conteúdo.
 * Usa Client Component porque tem muita interatividade
 * (send mode radios, checkboxes, filtros, modais).
 *
 * Stats cards + SendAlertForm + SubscribersTable.
 */

function formatNumber(num) {
  return new Intl.NumberFormat('pt-PT').format(num)
}

const STAT_CARDS = [
  { key: 'total', label: 'Total', icon: Users, color: 'stat-blue' },
  { key: 'active', label: 'Ativos', icon: UserCheck, color: 'stat-green' },
  { key: 'unsubscribed', label: 'Cancelados', icon: UserX, color: 'stat-orange' },
]

const SEND_MODES = [
  { value: 'all', label: 'Todos os subscritores ativos' },
  { value: 'manual', label: 'Selecionar manualmente' },
  { value: 'random', label: 'Selecionar aleatoriamente' },
]

export default function NewsletterPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [subscribers, setSubscribers] = useState([])
  const [stats, setStats] = useState({ total: 0, active: 0, unsubscribed: 0, sentThisMonth: 0 })
  const [sendMode, setSendMode] = useState('all')
  const [randomCount, setRandomCount] = useState(10)
  const [selectedEmails, setSelectedEmails] = useState(new Set())

  // Carregar dados ao montar
  useEffect(() => {
    const loadData = async () => {
      try {
        const [subs, st] = await Promise.all([
          getSubscribers(),
          getNewsletterStats(),
        ])
        setSubscribers(subs)
        setStats(st)
      } catch {
        // Erro silencioso
      } finally {
        setLoading(false)
      }
    }
    loadData()
  }, [])

  const handleRefresh = useCallback(async () => {
    const [subs, st] = await Promise.all([getSubscribers(), getNewsletterStats()])
    setSubscribers(subs)
    setStats(st)
    router.refresh()
  }, [router])

  if (loading) {
    return (
      <>
        <div className="admin-page-header">
          <h1 className="admin-page-title">Newsletter</h1>
          <p className="admin-page-subtitle">Gerir subscritores e enviar alertas de conteúdo</p>
        </div>
        <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>A carregar...</p>
      </>
    )
  }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Newsletter</h1>
        <p className="admin-page-subtitle">Gerir subscritores e enviar alertas de conteúdo</p>
      </div>

      {/* Stats Grid — 4 cards: 3 scroll mobile + 1 full-width below */}
      <div className="admin-stats-grid admin-stats-grid-4" style={{ marginBottom: 24 }}>
        <div className="admin-stats-scroll">
          {STAT_CARDS.map(({ key, label, icon: Icon, color }) => (
            <div key={key} className={`admin-stat-card ${color}`}>
              <div className="admin-stat-card-icon">
                <Icon size={24} />
              </div>
              <div>
                <div className="admin-stat-card-value">{formatNumber(stats[key])}</div>
                <div className="admin-stat-card-label">{label}</div>
              </div>
            </div>
          ))}
        </div>
        <div className="admin-stat-card stat-cyan">
          <div className="admin-stat-card-icon">
            <Mail size={24} />
          </div>
          <div>
            <div className="admin-stat-card-value">{formatNumber(stats.sentThisMonth)}</div>
            <div className="admin-stat-card-label">Enviados (mês)</div>
          </div>
        </div>
      </div>

      {/* Send Alert Card */}
      <div className="admin-dashboard-card" style={{ marginBottom: 24 }}>
        <h3 style={{ marginBottom: 16 }}>Enviar Alerta de Conteúdo</h3>

        {/* Send Mode */}
        <div style={{ marginBottom: 16 }}>
          <label style={{ fontSize: 13, fontWeight: 600, color: 'var(--admin-text)', marginBottom: 8, display: 'block' }}>
            Modo de Envio
          </label>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, marginBottom: 12 }}>
            {SEND_MODES.map(({ value, label }) => (
              <label
                key={value}
                style={{
                  display: 'flex', alignItems: 'center', gap: 6,
                  padding: '6px 14px', borderRadius: 20, cursor: 'pointer',
                  border: '1px solid var(--admin-border)', fontSize: 13,
                  background: sendMode === value ? 'var(--admin-primary)' : 'var(--admin-card-bg)',
                  color: sendMode === value ? 'white' : 'var(--admin-text)',
                }}
              >
                <input
                  type="radio"
                  name="send-mode"
                  value={value}
                  checked={sendMode === value}
                  onChange={(e) => {
                    setSendMode(e.target.value)
                    setSelectedEmails(new Set())
                  }}
                  style={{ display: 'none' }}
                />
                {label}
              </label>
            ))}
          </div>

          {sendMode === 'random' && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <label style={{ fontSize: 13, color: 'var(--admin-text-muted)' }}>Quantos:</label>
              <input
                type="number"
                value={randomCount}
                onChange={(e) => setRandomCount(Math.max(1, parseInt(e.target.value) || 1))}
                className="admin-input"
                style={{ width: 80 }}
                min={1}
              />
            </div>
          )}

          {sendMode === 'manual' && (
            <p style={{ fontSize: 13, color: 'var(--admin-text-muted)', marginBottom: 8 }}>
              Selecione os subscritores na tabela abaixo ({selectedEmails.size} selecionados).
            </p>
          )}
        </div>

        <SendAlertForm
          sendMode={sendMode}
          randomCount={randomCount}
          selectedEmails={selectedEmails}
        />
      </div>

      {/* Subscribers Table */}
      <div className="admin-dashboard-card">
        <h3 style={{ marginBottom: 16 }}>Subscritores</h3>
        <SubscribersTable
          subscribers={subscribers}
          sendMode={sendMode}
          selectedEmails={selectedEmails}
          onSelectionChange={setSelectedEmails}
          onRefresh={handleRefresh}
        />
      </div>
    </>
  )
}
