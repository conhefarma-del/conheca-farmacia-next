import { escapeHtml } from '@/lib/security'

/**
 * ActivityTimeline — Server Component
 *
 * Timeline de atividades recentes (audit_logs).
 * Usa classes CSS do admin.css existente (`.admin-timeline`).
 *
 * Props: { auditLogs }
 */

const tableLabels = {
  articles: 'Artigo',
  events: 'Evento',
  lives: 'Live',
}

const actionLabels = {
  CREATE: 'Criado',
  UPDATE: 'Atualizado',
  DELETE: 'Eliminado',
  PUBLISH: 'Publicado',
  UNPUBLISH: 'Despublicado',
}

function formatDateTime(dateStr) {
  const d = new Date(dateStr)
  const time = d.toLocaleTimeString('pt-PT', {
    hour: '2-digit',
    minute: '2-digit',
  })
  const date = d.toLocaleDateString('pt-PT', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
  return `${time} / ${date}`
}

export default function ActivityTimeline({ auditLogs = [] }) {
  if (!auditLogs || auditLogs.length === 0) {
    return (
      <div className="admin-activity-card">
        <h3>Atualizações Recentes</h3>
        <div className="admin-timeline">
          <div className="admin-timeline-item">
            <div className="admin-timeline-dot-wrapper">
              <div className="admin-timeline-dot action-create" />
            </div>
            <div className="admin-timeline-content">
              <div className="admin-timeline-text">Sem atividades recentes</div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="admin-activity-card">
      <h3>Atualizações Recentes</h3>
      <div className="admin-timeline">
        {auditLogs.map((item) => {
          const tableLabel = tableLabels[item.table_name] || item.table_name
          const actionLabel = actionLabels[item.action] || item.action
          const actionClass = item.action.toLowerCase()
          const badgeText = `${tableLabel} ${actionLabel}`
          const timeText = formatDateTime(item.created_at)

          // Extrair título do conteúdo de new_values
          let contentTitle = ''
          if (item.new_values) {
            const values =
              typeof item.new_values === 'string'
                ? JSON.parse(item.new_values)
                : item.new_values
            contentTitle = escapeHtml(values.title || values.name || '')
          }

          return (
            <div key={item.id} className="admin-timeline-item">
              <div className="admin-timeline-dot-wrapper">
                <div className={`admin-timeline-dot action-${actionClass}`} />
              </div>
              <div className="admin-timeline-content">
                <div className="admin-timeline-text">
                  {badgeText}
                  {contentTitle ? `: ${contentTitle}` : ''}
                </div>
                <div className="admin-timeline-badges">
                  <span
                    className={`admin-timeline-badge badge-type badge-${actionClass}`}
                  >
                    {badgeText}
                  </span>
                  <span className="admin-timeline-badge badge-time">
                    {timeText}
                  </span>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
