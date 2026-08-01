import { Download, FileText, Pill } from 'lucide-react'

/**
 * Sidebar do detalhe do protocolo (Server Component — recebe `t`).
 * TOC com âncoras para cada passo, fármacos mencionados, referências e botão PDF.
 */
export default function ProtocolSidebar({ protocol, steps, mentionedDrugs, t }) {
  return (
    <aside className="protocol-sidebar">
      <div className="sidebar-card">
        <div className="sidebar-card-title">{t('protocolos_detalhe.neste_protocolo')}</div>
        <nav className="sidebar-toc">
          {steps.map((step, i) => (
            <a key={step.id} href={`#passo-${i + 1}`} className="toc-link">
              <span className="toc-num">{i + 1}</span>
              {step.title}
            </a>
          ))}
        </nav>
      </div>

      {mentionedDrugs.length > 0 && (
        <div className="sidebar-card">
          <div className="sidebar-card-title">{t('protocolos_detalhe.farmacos_mencionados')}</div>
          <ul className="sidebar-drug-list">
            {mentionedDrugs.map((label) => (
              <li key={label} className="sidebar-drug-item">
                <Pill size={14} aria-hidden="true" />
                {label}
              </li>
            ))}
          </ul>
        </div>
      )}

      {protocol.references.length > 0 && (
        <div className="sidebar-card">
          <div className="sidebar-card-title">{t('protocolos_detalhe.referencias')}</div>
          <ul className="sidebar-ref-list">
            {protocol.references.map((ref, i) => (
              <li key={ref.id || i}>
                <a className="ref-link" href={ref.url} target="_blank" rel="noopener noreferrer">
                  <FileText size={14} aria-hidden="true" />
                  {ref.title}
                </a>
              </li>
            ))}
          </ul>
        </div>
      )}

      {protocol.pdfUrl && (
        <a
          className="download-btn"
          href={protocol.pdfUrl}
          target="_blank"
          rel="noopener noreferrer"
        >
          <Download size={16} aria-hidden="true" />
          {t('protocolos_detalhe.descarregar_pdf')}
        </a>
      )}
    </aside>
  )
}
