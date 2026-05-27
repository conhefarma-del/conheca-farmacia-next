'use client'

import { incrementLiveDownloadCount } from '@/lib/api/analytics'

export default function MaterialLink({ material, index, color, liveSlug }) {
  const handleClick = () => {
    incrementLiveDownloadCount(liveSlug).catch(() => {})
  }

  const isString = typeof material === 'string'
  const href = isString ? material : (material?.url || material?.link || '#')
  const name = isString ? `Material ${index + 1}` : (material?.name || material?.nome || `Material ${index + 1}`)

  return (
    <a
      href={String(href || '#')}
      target="_blank"
      rel="noopener noreferrer"
      className="text-[var(--accent)] hover:underline flex items-center gap-2"
      style={{ color }}
      onClick={handleClick}
    >
      → {name}
    </a>
  )
}
