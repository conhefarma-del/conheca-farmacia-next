import { BookOpen, FileText, Link2, ScrollText } from 'lucide-react'

// Ícones Lucide por tipo de recurso (substituem os antigos emojis)
const ICON_MAP = {
  pdf: FileText,
  guideline: ScrollText,
  article: BookOpen,
  other: Link2,
}

/**
 * Link de recurso gratuito (PDF/guideline/artigo/outro).
 * Abre em nova aba com rel="noopener noreferrer".
 */
export default function GuideResourceLink({ resource }) {
  const Icon = ICON_MAP[resource.type] || Link2
  return (
    <a
      href={resource.url}
      target="_blank"
      rel="noopener noreferrer"
      className="guide-resource-link"
    >
      <div className="guide-resource-icon">
        <Icon size={16} aria-hidden="true" />
      </div>
      <div>
        <div className="guide-resource-title">{resource.title}</div>
        {resource.description && (
          <div className="guide-resource-desc">{resource.description}</div>
        )}
      </div>
    </a>
  )
}
