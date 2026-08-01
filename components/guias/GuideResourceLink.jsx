const ICON_MAP = { pdf: '📄', guideline: '📋', article: '📰', other: '🔗' }

/**
 * Link de recurso gratuito (PDF/guideline/artigo/outro).
 * Abre em nova aba com rel="noopener noreferrer".
 */
export default function GuideResourceLink({ resource }) {
  return (
    <a
      href={resource.url}
      target="_blank"
      rel="noopener noreferrer"
      className="guide-resource-link"
    >
      <div className="guide-resource-icon">{ICON_MAP[resource.type] || '🔗'}</div>
      <div>
        <div className="guide-resource-title">{resource.title}</div>
        {resource.description && (
          <div className="guide-resource-desc">{resource.description}</div>
        )}
      </div>
    </a>
  )
}
