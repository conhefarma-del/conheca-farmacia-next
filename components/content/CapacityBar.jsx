'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { useCapacityPolling } from '@/hooks/useCapacityPolling'

export default function CapacityBar({ eventId, capacity, initialCount = 0, isPast = false }) {
  const { t } = useContext(LangContext)
  const { inscriptionCount } = useCapacityPolling(eventId, initialCount)

  if (isPast) return null
  const percentage = capacity > 0 ? Math.min((inscriptionCount / capacity) * 100, 100) : 0
  const isFull = inscriptionCount >= capacity
  const barColor = isFull ? '#dc2626' : '#00493a'
  const vagasRestantes = capacity - inscriptionCount

  return (
    <>
      <div className="event-capacity-bar-wrapper">
        <div className="event-capacity-bar">
          <div
            id="event-capacity-filled"
            className="event-capacity-filled"
            style={{ width: `${percentage}%`, backgroundColor: barColor }}
          />
        </div>
        <p className="text-sm text-brand-deep/70 mt-3" id="event-capacity-text">
          {isFull
            ? t('evento_detail.event_full_no_spots')
            : t('evento_detail.spots_available_of', {
                count: vagasRestantes,
                capacity,
              })}
        </p>
      </div>
      <div className="capacity-status" id="capacity-status">
        <span className="status-dot" style={{ backgroundColor: isFull ? '#dc2626' : '#0a844f' }} />
        <span className="status-text" data-i18n="evento_detail.spots_updated_now">
          {t('evento_detail.spots_updated_now')}
        </span>
      </div>
    </>
  )
}
