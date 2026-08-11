export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      <div className="sci-author-page">
        {/* Header do autor */}
        <div className="flex gap-4 rounded-2xl p-6 mb-6" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
          <div className="h-16 w-16 rounded-full flex-shrink-0" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="space-y-3 flex-1">
            <div className="h-6 w-64 max-w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-4 w-80 max-w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-6 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-2 mb-8">
          <div className="h-9 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          <div className="h-9 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
        </div>

        {/* Grid de artigos */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="rounded-xl p-5" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
              <div className="flex justify-between mb-4">
                <div className="h-5 w-24 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-5 w-8 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
              </div>
              <div className="h-4 w-full rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
              <div className="h-4 w-3/4 rounded mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
              <div className="h-3 w-24 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
