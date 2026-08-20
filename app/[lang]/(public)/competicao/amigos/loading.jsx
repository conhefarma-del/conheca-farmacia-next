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
          {/* Pending invites skeleton */}
          <div>
            <div className="h-6 w-40 rounded-lg mb-4" style={{ ...pulse, opacity: 0.6 }} />
            {Array.from({ length: 2 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 p-4 rounded-xl mb-3" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="w-10 h-10 rounded-full flex-shrink-0" style={{ ...pulse, opacity: 0.2 }} />
                <div className="flex-1">
                  <div className="h-4 w-32 rounded mb-1.5" style={{ ...pulse, opacity: 0.5 }} />
                  <div className="h-3 w-24 rounded" style={{ ...pulse, opacity: 0.3 }} />
                </div>
                <div className="flex gap-2">
                  <div className="h-8 w-8 rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
                  <div className="h-8 w-8 rounded-lg" style={{ ...pulse, opacity: 0.15 }} />
                </div>
              </div>
            ))}
          </div>

          {/* Create card skeleton */}
          <div className="p-5 rounded-2xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl" style={{ ...pulse, opacity: 0.15 }} />
              <div>
                <div className="h-5 w-36 rounded mb-1" style={{ ...pulse, opacity: 0.6 }} />
                <div className="h-3 w-48 rounded" style={{ ...pulse, opacity: 0.3 }} />
              </div>
            </div>
            <div className="h-10 w-full rounded-xl" style={{ ...pulse, opacity: 0.4 }} />
          </div>

          {/* Join code skeleton */}
          <div className="p-5 rounded-2xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
            <div className="h-5 w-32 rounded mb-3" style={{ ...pulse, opacity: 0.6 }} />
            <div className="flex gap-3">
              <div className="h-12 flex-1 rounded-xl" style={{ ...pulse, opacity: 0.3 }} />
              <div className="h-12 w-24 rounded-xl" style={{ ...pulse, opacity: 0.4 }} />
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
