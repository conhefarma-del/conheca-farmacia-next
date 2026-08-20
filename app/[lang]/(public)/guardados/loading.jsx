export default function Loading() {
  const pulse = {
    background: 'var(--color-brand-divider)',
    animation: 'pulse 1.5s ease-in-out infinite',
  }

  return (
    <>
      {/* Hero skeleton */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="w-14 h-14 rounded-2xl mx-auto mb-4" style={{ ...pulse, opacity: 0.2 }} />
            <div className="h-12 w-48 mx-auto rounded-2xl mb-3" style={{ ...pulse, opacity: 0.5 }} />
            <div className="h-5 w-64 mx-auto rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
          </div>
        </div>
      </section>

      {/* Tabs + Search skeleton */}
      <section className="saved-toolbar">
        <div className="container-center">
          <div className="saved-toolbar-inner">
            <div className="flex gap-2 overflow-hidden">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-9 rounded-lg flex-shrink-0" style={{ ...pulse, opacity: 0.2, width: 70 + i * 12 }} />
              ))}
            </div>
            <div className="h-10 w-48 rounded-lg" style={{ ...pulse, opacity: 0.15 }} />
          </div>
        </div>
      </section>

      {/* List skeleton */}
      <section className="saved-content">
        <div className="container-center">
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 p-4 rounded-xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="w-9 h-9 rounded-lg flex-shrink-0" style={{ ...pulse, opacity: 0.12 }} />
                <div className="flex-1">
                  <div className="h-4 w-36 rounded mb-1.5" style={{ ...pulse, opacity: 0.4 }} />
                  <div className="h-3 w-24 rounded" style={{ ...pulse, opacity: 0.2 }} />
                </div>
                <div className="h-3 w-12 rounded" style={{ ...pulse, opacity: 0.15 }} />
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}
