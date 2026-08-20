'use client'

import { useState, useEffect, useRef, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import { getPendingInvites, acceptFriendInvite, declineFriendInvite } from '@/lib/actions/competition'
import { Bell, Check, X, Loader2 } from 'lucide-react'

export default function InviteNotifications({ lang }) {
  const { t } = useContext(LangContext)
  const [invites, setInvites] = useState([])
  const [loading, setLoading] = useState(true)
  const [open, setOpen] = useState(false)
  const [actionLoading, setActionLoading] = useState(null)
  const ref = useRef(null)

  useEffect(() => {
    async function load() {
      try {
        const data = await getPendingInvites()
        setInvites(data || [])
      } catch {} finally {
        setLoading(false)
      }
    }
    load()
    // Poll every 30s for new invites
    const interval = setInterval(load, 30000)
    return () => clearInterval(interval)
  }, [])

  // Close on outside click
  useEffect(() => {
    const onDocClick = (e) => {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false)
    }
    document.addEventListener('click', onDocClick)
    return () => document.removeEventListener('click', onDocClick)
  }, [])

  const handleAccept = async (inviteId) => {
    setActionLoading(inviteId)
    try {
      const result = await acceptFriendInvite(inviteId)
      if (result.success) {
        localStorage.setItem('comp_session', result.sessionId)
        window.location.href = `/${lang}/competicao/amigos/${result.accessCode}`
      } else {
        setInvites((prev) => prev.filter((i) => i.id !== inviteId))
      }
    } catch {
      setInvites((prev) => prev.filter((i) => i.id !== inviteId))
    } finally {
      setActionLoading(null)
    }
  }

  const handleDecline = async (inviteId) => {
    setActionLoading(inviteId)
    try {
      await declineFriendInvite(inviteId)
      setInvites((prev) => prev.filter((i) => i.id !== inviteId))
    } catch {} finally {
      setActionLoading(null)
    }
  }

  const count = invites.length

  return (
    <div className="bell-wrapper" ref={ref}>
      <button
        className="bell-btn"
        onClick={() => setOpen((o) => !o)}
        aria-label={`Notificações${count > 0 ? ` (${count})` : ''}`}
        aria-expanded={open}
        aria-haspopup="true"
      >
        <Bell size={20} />
        {count > 0 && <span className="bell-badge">{count}</span>}
      </button>

      <div className={`bell-dropdown${open ? ' is-open' : ''}`}>
        <div className="bell-dropdown-header">
          <span className="bell-dropdown-title">
            {t('friend_challenge.pending_title') || 'Desafios Pendentes'}
          </span>
          {count > 0 && <span className="bell-dropdown-count">{count}</span>}
        </div>
        <div className="bell-dropdown-divider" />

        {loading ? (
          <div className="bell-dropdown-empty">
            <Loader2 size={16} className="animate-spin text-brand-accent" />
          </div>
        ) : invites.length === 0 ? (
          <div className="bell-dropdown-empty">
            <span className="text-sm text-brand-deep/40">Sem convites pendentes</span>
          </div>
        ) : (
          <div className="bell-dropdown-list">
            {invites.map((inv) => (
              <div key={inv.id} className="bell-invite">
                <div className="bell-invite-info">
                  <div className="bell-invite-name">{inv.inviterName}</div>
                  <div className="bell-invite-comp">{inv.competitionName}</div>
                </div>
                <div className="bell-invite-actions">
                  <button
                    onClick={() => handleAccept(inv.id)}
                    disabled={actionLoading === inv.id}
                    className="bell-invite-btn bell-invite-accept"
                    title="Aceitar"
                  >
                    {actionLoading === inv.id ? (
                      <Loader2 size={12} className="animate-spin" />
                    ) : (
                      <Check size={12} />
                    )}
                  </button>
                  <button
                    onClick={() => handleDecline(inv.id)}
                    disabled={actionLoading === inv.id}
                    className="bell-invite-btn bell-invite-decline"
                    title="Rejeitar"
                  >
                    <X size={12} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {invites.length > 0 && (
          <>
            <div className="bell-dropdown-divider" />
            <Link
              href={`/${lang}/competicao/amigos`}
              className="bell-dropdown-link"
              onClick={() => setOpen(false)}
            >
              Ver todos os desafios →
            </Link>
          </>
        )}
      </div>
    </div>
  )
}
