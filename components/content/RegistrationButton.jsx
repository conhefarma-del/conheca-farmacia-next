'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { useCapacityPolling } from '@/hooks/useCapacityPolling'
import Link from 'next/link'

/**
 * Botão de inscrição que se atualiza em tempo real consoante a capacidade do evento.
 * Quando o evento fica completo, o botão é desativado automaticamente.
 * Usa `eventId` (UUID) em vez de slug — o slug é tradutível (PT ↔ EN divergem) e
 * quebrar a navegação para `/inscricao?evento=<slug-en>` quando o InscricaoPage
 * faz lookup pelo slug PT.
 */
export default function RegistrationButton({ eventId, capacity, initialCount = 0, isPast, lang }) {
  const { t } = useContext(LangContext)
  const { inscriptionCount } = useCapacityPolling(eventId, initialCount)
  const isFull = capacity && inscriptionCount >= capacity

  if (isPast) {
    return (
      <button
        className="btn btn-lg btn-inscrever btn-secondary"
        disabled
      >
        {t('evento_detail.recording_btn') || 'Evento passado'}
      </button>
    )
  }

  if (isFull) {
    return (
      <button
        className="btn btn-primary btn-lg btn-inscrever btn-disabled"
        disabled
      >
        {t('evento_detail.full_btn') || 'Evento Completo'}
      </button>
    )
  }

  return (
    <Link
      href={`/${lang}/inscricao?eventoId=${eventId}`}
      className="btn btn-primary btn-lg btn-inscrever"
    >
      {t('evento_detail.register_btn') || 'Inscrever-me'}
    </Link>
  )
}
