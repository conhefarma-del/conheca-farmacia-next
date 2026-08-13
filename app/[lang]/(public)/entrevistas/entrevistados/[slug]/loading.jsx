export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      <div className="sci-author-page">
        {/* Header do entrevistado */}
        <div className="flex gap-4 rounded-2xl p-6 mb-6" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
          <div className="h-16 w-16 rounded-full flex-shrink-0" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
          <div className="space-y-3 flex-1">
            <div className="h-6 w-64 max-w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-4 w-80 max-w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-6 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
          </div>
        </div>

        {/* Bio */}
        <div className="rounded-xl p-5 mb-8" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
          <div className="h-3 w-16 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
          <div className="h-4 w-full rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
          <div className="h-4 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
        </div>

        {/* Título da secção */}
        <div className="h-5 w-40 rounded mb-6" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />

        {/* Grid de entrevistas */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="rounded-2xl overflow-hidden" style={{ border: '1px solid var(--color-brand-divider)', background: 'var(--color-brand-card, #fff)' }}>
              <div className="w-full" style={{ aspectRatio: '16 / 9', ...pulse, background: 'var(--color-brand-divider)', opacity: 0.7 }} />
              <div className="p-5 space-y-3">
                <div className="h-3.5 w-24 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                <div className="h-5 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                <div className="h-4 w-4/5 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                <div className="flex justify-between items-center pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                  <div className="flex items-center gap-2">
                    <div className="h-6 w-6 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                    <div className="h-3.5 w-20 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                  </div>
                  <div className="h-3.5 w-16 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
