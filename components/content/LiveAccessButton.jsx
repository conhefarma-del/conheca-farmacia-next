'use client'

import { incrementLiveAccessCount } from '@/lib/api/analytics'

export default function LiveAccessButton({ href, color, label, liveSlug }) {
  const handleClick = () => {
    incrementLiveAccessCount(liveSlug).catch(() => {})
  }

  return (
    <div className="quick-access-content">
      <a
        href={href}
        target="_blank"
        rel="noopener noreferrer"
        className="btn btn-primary btn-lg w-full"
        style={{ backgroundColor: color, borderColor: color }}
        onClick={handleClick}
      >
        {label}
      </a>
    </div>
  )
}
