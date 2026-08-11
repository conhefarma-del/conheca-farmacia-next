export default function Loading() {
  const pulse = { animation: 'pulse 1.5s ease-in-out infinite' }
  return (
    <div className="min-h-screen">
      <div className="sci-layout">
        {/* Coluna principal 2/3 */}
        <main className="sci-main">
          {/* Hero */}
          <div className="sci-hero">
            <div className="flex gap-2 mb-4">
              <div className="h-6 w-28 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
              <div className="h-6 w-10 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            </div>
            <div className="h-9 w-5/6 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-9 w-2/3 rounded mb-5" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-4 w-72 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>

          {/* Autores */}
          <div className="mb-8">
            <div className="h-4 w-24 rounded mb-4" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="flex items-center gap-3 rounded-xl p-3" style={{ border: '1px solid var(--color-brand-divider)' }}>
                  <div className="h-8 w-8 rounded-full" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                  <div className="space-y-2 flex-1">
                    <div className="h-3.5 w-2/3 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
                    <div className="h-3 w-1/2 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Abstract */}
          <div className="rounded-xl p-6 mb-8" style={{ background: 'var(--color-brand-bg-alt)' }}>
            <div className="h-3.5 w-20 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)' }} />
            <div className="h-4 w-full rounded mb-2" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
            <div className="h-4 w-5/6 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>

          {/* Corpo */}
          <div className="space-y-3">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="h-4 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6, width: `${90 - i * 4}%` }} />
            ))}
          </div>
        </main>

        {/* Sidebar 1/3 */}
        <aside className="sci-sidebar" aria-hidden="true">
          <div className="sci-sidebar-card">
            <div className="h-3.5 w-14 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
            <div className="h-8 w-full rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.6 }} />
          </div>
          <div className="sci-sidebar-card">
            <div className="h-3.5 w-20 rounded mb-3" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5 }} />
            <div className="space-y-2">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="h-3.5 rounded" style={{ ...pulse, background: 'var(--color-brand-divider)', opacity: 0.5, width: `${80 - i * 10}%` }} />
              ))}
            </div>
          </div>
        </aside>
      </div>
    </div>
  )
}
