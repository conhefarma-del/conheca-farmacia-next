'use client'

import { validateUrl } from '@/lib/security'
import { incrementLiveDownloadCount } from '@/lib/api/analytics'

export default function MaterialsList({ materials, liveSlug, t }) {
  if (!materials || !materials.length) return null

  const title = t ? t('live_detail.materiais') : 'Materiais de Apoio'

  return (
    <div className="materials-section">
      <h3 className="text-lg font-bold text-brand-deep mb-4">{title}</h3>
      <ul className="materials-list">
        {materials.map((material, i) => {
          const url = typeof material === 'string' ? material : material.url
          const label = typeof material === 'string'
            ? `Material ${i + 1}`
            : material.name || `Material ${i + 1}`

          return (
            <li key={i}>
              <a
                href={validateUrl(url)}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 p-3 rounded-xl border border-brand-divider/20 hover:bg-brand-bg-alt transition-colors"
                onClick={() => {
                  if (liveSlug) incrementLiveDownloadCount(liveSlug)
                }}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-brand-accent shrink-0">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                  <polyline points="7 10 12 15 17 10" />
                  <line x1="12" x2="12" y1="15" y2="3" />
                </svg>
                <span className="text-sm text-brand-deep">{label}</span>
              </a>
            </li>
          )
        })}
      </ul>
    </div>
  )
}
