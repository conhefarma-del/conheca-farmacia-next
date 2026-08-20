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
          <div className="text-center py-20 md:py-32">
            <div className="w-12 h-12 rounded-full mx-auto mb-4" style={{ ...pulse, opacity: 0.3 }} />
            <div className="h-14 w-80 mx-auto rounded-2xl mb-4" style={{ ...pulse, opacity: 0.5 }} />
            <div className="h-6 w-64 mx-auto rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
          </div>
        </div>
      </section>

      <section className="py-16 bg-background">
        <div className="container-center max-w-xl mx-auto px-4 space-y-6">
          {/* Players skeleton */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6">
            <div className="h-6 w-32 rounded-lg mb-4" style={{ ...pulse, opacity: 0.5 }} />
            {Array.from({ length: 2 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 p-4 rounded-xl mb-3" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="w-10 h-10 rounded-full flex-shrink-0" style={{ ...pulse, opacity: 0.2 }} />
                <div className="flex-1">
                  <div className="h-4 w-32 rounded mb-1.5" style={{ ...pulse, opacity: 0.5 }} />
                  <div className="h-3 w-24 rounded" style={{ ...pulse, opacity: 0.3 }} />
                </div>
                <div className="w-6 h-6 rounded-full" style={{ ...pulse, opacity: 0.15 }} />
              </div>
            ))}
          </div>

          {/* Buttons skeleton */}
          <div className="flex gap-3">
            <div className="flex-1 h-14 rounded-xl" style={{ ...pulse, opacity: 0.2 }} />
            <div className="flex-1 h-14 rounded-xl" style={{ ...pulse, opacity: 0.2 }} />
          </div>
        </div>
      </section>
    </>
  )
}
