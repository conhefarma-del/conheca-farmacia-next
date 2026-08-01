import Link from 'next/link'
import { CalendarDays, Clock, ListChecks, Signal } from 'lucide-react'

// Estimativa rápida para o card (o detalhe calcula sobre o conteúdo completo)
function readingMin(protocol) {
  const words = (protocol.description || '').split(/\s+/).filter(Boolean).length
  return Math.max(1, Math.round(words / 200))
}

export default function ProtocolCard({ protocol, lang, t }) {
  const dateStr = protocol.updatedAt ? protocol.updatedAt.slice(0, 7) : ''
  return (
    <Link href={`/${lang}/protocolos/${protocol.slug}`} className="protocol-card">
      <span className="protocol-card-top-strip" style={{ background: protocol.categoryColor }} />
      <div className="protocol-card-body">
        <span className="protocol-card-category">{protocol.categoryName}</span>
        {protocol.difficulty && (
          <span className={`protocol-difficulty protocol-difficulty--${protocol.difficulty}`}>
            <Signal size={12} aria-hidden="true" />
            {t(`protocolos_detalhe.dificuldade_${protocol.difficulty}`)}
          </span>
        )}
        <h2 className="protocol-card-title">{protocol.title}</h2>
        <p className="protocol-card-desc">{protocol.description}</p>
        <div className="protocol-card-meta">
          <span className="protocol-card-meta-item">
            <ListChecks size={14} aria-hidden="true" />
            {protocol.stepCount} {t('protocolos_page.passos')}
          </span>
          <span className="protocol-card-meta-item">
            <CalendarDays size={14} aria-hidden="true" />
            {dateStr}
          </span>
          <span className="protocol-card-meta-item">
            <Clock size={14} aria-hidden="true" />
            {readingMin(protocol)} {t('protocolos_page.minutos_leitura')}
          </span>
          {protocol.isUpdated && (
            <span className="protocol-card-updated">{t('protocolos_page.actualizado')}</span>
          )}
        </div>
      </div>
    </Link>
  )
}
