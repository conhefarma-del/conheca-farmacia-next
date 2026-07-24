'use client'

export default function PendingBadge({ label = 'Pendente', className = '' }) {
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium
        bg-amber-100 text-amber-800
        dark:bg-amber-900/30 dark:text-amber-300
        ${className}`}
    >
      {label}
    </span>
  )
}
